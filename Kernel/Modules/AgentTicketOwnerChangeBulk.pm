# --
# Kernel/Modules/AgentTicketOwnerChangeBulk.pm - bulk closing of tickets
# Copyright (C) 2015 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketOwnerChangeBulk;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Web::Request
    Kernel::Output::HTML::Layout
    Kernel::System::Ticket
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

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my @TicketIDs = $ParamObject->GetArray( Param => 'TicketID' );
    my $ID        = $ParamObject->GetParam( Param => 'QuickOwnerChange' );

    # check needed stuff
    if ( !@TicketIDs ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    if ( !$ID ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No OwnerID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    my @NoAccess;

    TICKETID:
    for my $TicketID ( @TicketIDs ) {

        # check permissions
        my $Access = $TicketObject->TicketPermission(
            Type     => 'owner',
            TicketID => $TicketID,
            UserID   => $Self->{UserID}
        );

        # error screen, don't show ticket
        if ( !$Access ) {
            push @NoAccess, $TicketID;
            next TICKETID;
        }

        $TicketObject->TicketOwnerSet(
            TicketID  => $TicketID,
            NewUserID => $ID,
            UserID    => $Self->{UserID},
        );
    }

    # redirect parent window to last screen overview on closed tickets
    if ( !@NoAccess ) {
        my $LastView = $Self->{LastScreenOverview} || $Self->{LastScreenView} || 'Action=AgentDashboard';
        my $OP       = @TicketIDs == 1 ? 'Action=AgentTicketZoom&TicketID=' . $TicketIDs[0] :  $LastView;

        return $LayoutObject->Redirect(
            OP => $OP,
        );

    }
    else {
        return $LayoutObject->ErrorScreen(
            Message => 'No Access to these Tickets (IDs: ' . join( ", ", @NoAccess ) . ')',
            Comment => 'Please contact the admin.',
        );
    }
}

1;
