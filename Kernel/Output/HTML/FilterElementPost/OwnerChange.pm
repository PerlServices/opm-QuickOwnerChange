# --
# Kernel/Output/HTML/FilterElementPost/OwnerChange.pm
# Copyright (C) 2015 - 2023 Perl-Services.de, https://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::OwnerChange;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::System::Ticket
    Kernel::System::Group
    Kernel::System::User
    Kernel::System::Queue
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = { %Param };
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );
    return 1 if !$TicketID;

    my %Ticket = $TicketObject->TicketGet(
        TicketID => $TicketID,
        UserID   => $Self->{UserID},
    );

    my %UserGroups = $GroupObject->PermissionUserGet(
        UserID => $LayoutObject->{UserID},
        Type   => 'rw',
    );

    my %GroupNames = reverse %UserGroups;

    my %ViewPermissions = %{ $ConfigObject->Get('QuickOwnerChange::ViewPermission') || {} };
    if ( $ViewPermissions{ $Ticket{Queue} } ) {
        my (@Groups) = split /\s*,\s*/, $ViewPermissions{ $Ticket{Queue} };

        my $IsAllowed = grep{ $GroupNames{$_} }@Groups;
        return 1 if !$IsAllowed;
    }

    my @GroupPermissions = @{ $ConfigObject->Get('QuickOwnerChange::ViewPermissionByGroup') || [] };
    if ( @GroupPermissions ) {
        my $IsAllowed = grep{ $GroupNames{$_} }@GroupPermissions;
        return 1 if !$IsAllowed;
    }

    my $GroupID = $QueueObject->GetQueueGroupID(
        QueueID => $Ticket{QueueID},
    );

    my $AgentGroup = $ConfigObject->Get('QuickOwnerChange::OwnerGroup');
    if ( $AgentGroup ) {
        $GroupID = $GroupObject->GroupLookup( Group => $AgentGroup );
    }

    my $QueueAgentGroup = $ConfigObject->Get('QuickOwnerChange::QueueGroups') || {};
    if ( $QueueAgentGroup && $QueueAgentGroup->{ $Ticket{Queue} } ) {
        my $GroupName = $QueueAgentGroup->{ $Ticket{Queue} };
        $GroupID = $GroupObject->GroupLookup( Group => $GroupName );
    }

    my $Type = $ConfigObject->Get('QuickOwnerChange::Permissions') || 'rw';
    my %User = $GroupObject->GroupMemberList(
        GroupID => $GroupID,
        Type    => $Type,
        Result  => 'HASH',
    );

    $User{$_} = $UserObject->UserName( UserID => $_ ) for keys %User;

    my @Data = map{ { Key => $_, Value => $User{$_} } }sort{ $User{$a} cmp $User{$b} }keys %User;
    
    my $Label = $ConfigObject->Get('QuickOwnerChange::NoneLabel') || 'Quick Owner Change';

    unshift @Data, {
        Key   => '0',
        Value => ' - ' . $LayoutObject->{LanguageObject}->Translate( $Label ) . ' - ',
    };

    my $Select = $LayoutObject->BuildSelection(
        Name       => 'QuickOwnerChange',
        Data       => \@Data,
        Class      => 'Modernize',
    );
    
    my $Snippet = $LayoutObject->Output(
        TemplateFile => 'QuickOwnerChangeSnippet',
        Data         => {
            TicketID => $TicketID,
            Select   => $Select,
        },
    ); 

    #scan html output and generate new html input
    my $LinkType = $ConfigObject->Get('Ticket::Frontend::MoveType');
    if ( $LinkType eq 'form' ) {
        ${ $Param{Data} } =~ s{(<li \s+ class="" .*? <select [^>]*? name="DestQueueID".*?</li>)}{$Snippet $1}xms;
    }
    else {
        ${ $Param{Data} } =~ s{(<li \s+ <a \s+ href=".*?Action=AgentTicketMove;TicketID=\d+;".*?</li>)}{$Snippet $1}xms;
    }

    return 1;
}

1;
