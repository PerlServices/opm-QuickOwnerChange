# --
# Kernel/Output/HTML/FilterElementPost/OwnerChangeTicketView.pm
# Copyright (C) 2015 - 2022 Perl-Services.de, https://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OwnerChangeTicketView;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Output::HTML::Layout
    Kernel::System::User
    Kernel::System::Group
    Kernel::System::Queue
    Kernel::System::Web::Request
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    my %UserGroups = $GroupObject->PermissionUserGet(
        UserID => $LayoutObject->{UserID},
        Type   => 'rw',
    );

    my %GroupNames = reverse %UserGroups;

    my @GroupPermissions = @{ $ConfigObject->Get('QuickOwnerChange::ViewPermissionByGroup') || [] };
    if ( @GroupPermissions ) {
        my $IsAllowed = grep{ $GroupNames{$_} }@GroupPermissions;
        return 1 if !$IsAllowed;
    }

    my %User = $UserObject->UserList(
        Type    => 'Long',
    );

    my $Type       = $ConfigObject->Get('QuickOwnerChange::Permissions') || 'rw';
    my $AgentGroup = $ConfigObject->Get('QuickOwnerChange::OwnerGroup');

    if ( $AgentGroup ) {
        my $GroupID = $GroupObject->GroupLookup( Group => $AgentGroup );

        %User = $GroupObject->GroupMemberList(
            GroupID => $GroupID,
            Type    => $Type,
            Result  => 'HASH',
        );

        $User{$_} = $UserObject->UserName( UserID => $_ ) for keys %User;
    }

    my $QueueID         = $ParamObject->GetParam( Param => 'QueueID' );
    my $QueueAgentGroup = $ConfigObject->Get('QuickOwnerChange::QueueGroups') || {};
    my $UseQueueGroup   = $ConfigObject->Get('QuickOwnerChange::UseQueueGroup');

    my $QueueName = '';
    if ( $QueueID ) {
        $QueueName = $QueueObject->QueueLookup( QueueID => $QueueID );

        if ( $UseQueueGroup ) {
            my %Queue = $QueueObject->QueueGet( ID => $QueueID );

            $QueueAgentGroup->{$QueueName} = $GroupObject->GroupLookup( GroupID => $Queue{GroupID} );
        }
    }

    if ( $QueueAgentGroup && $QueueName && $QueueAgentGroup->{ $QueueName } ) {
        my $GroupName = $QueueAgentGroup->{ $QueueName };
        my $GroupID   = $GroupObject->GroupLookup( Group => $GroupName );

        %User = $GroupObject->GroupMemberList(
            GroupID => $GroupID,
            Type    => $Type,
            Result  => 'HASH',
        );

        $User{$_} = $UserObject->UserName( UserID => $_ ) for keys %User;
    }

    my @Data = map{ { Key => $_, Value => $User{$_} } }sort{ $User{$a} cmp $User{$b} }keys %User;
    
    my $Label = $ConfigObject->Get('QuickOwnerChange::NoneLabel') || 'Quick Owner Change';

    unshift @Data, {
        Key   => '0',
        Value => ' - ' . $LayoutObject->{LanguageObject}->Translate( $Label )  . ' - ',
    };
    
    my $Select = $LayoutObject->BuildSelection(
        Data       => \@Data,
        Name       => 'QuickOwnerChange',
        Size       => 1,
        HTMLQuote  => 1,
        SelectedID => 0,
        Class      => 'QuickOwnerChangeSelect Modernize',
    );

    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'QuickOwnerChangeSnippetTicketView',
        Data         => {
            Select => $Select,
        },
    ); 

    #scan html output and generate new html input
    ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$1 $Snippet}xmgs;

    return 1;
}

1;
