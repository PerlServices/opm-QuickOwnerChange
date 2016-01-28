# --
# Kernel/Output/HTML/FilterElementPost/OwnerChange.pm
# Copyright (C) 2015 - 2016 Perl-Services.de, http://www.perl-services.de/
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

    if ( $Templatename  =~ m{AgentTicketZoom\z} ) {
        my ($TicketID) = $ParamObject->GetParam( Param => 'TicketID' );

        my %Ticket = $TicketObject->TicketGet(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

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
        
        unshift @Data, {
            Key => '', 
            Value => ' - ' . ($ConfigObject->Get( 'QuickOwnerChange::NoneLabel' ) || 'QuickOwnerChange')  . ' - ',
        };

        my $Select = $LayoutObject->BuildSelection(
            Name       => 'QuickOwnerChange',
            Data       => \@Data,
            SelectedID => '',
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
            ${ $Param{Data} } =~ s{(<select name="DestQueueID".*?</li>)}{$1 $Snippet}mgs;
        }
        else {
            ${ $Param{Data} } =~ s{(<a href=".*?Action=AgentTicketMove;TicketID=\d+;".*?</li>)}{$1 $Snippet}mgs;
        }
    }

    return ${ $Param{Data} };
}

1;
