# --
# Kernel/Output/HTML/FilterElementPost/OwnerChangeTicketView.pm
# Copyright (C) 2015 - 2016 Perl-Services.de, http://www.perl-services.de/
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

    my $QueueName = '';
    if ( $QueueID ) {
        $QueueName = $QueueObject->QueueLookup( QueueID => $QueueID );
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
        Key   => '',
        Value => ' - ' . $LayoutObject->{LanguageObject}->Translate( $Label )  . ' - ',
    };
    
    my $Select = $LayoutObject->BuildSelection(
        Data       => \@Data,
        Name       => 'QuickOwnerChange',
        Size       => 1,
        HTMLQuote  => 1,
        SelectedID => 0,
        Class      => 'Modernize',
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
