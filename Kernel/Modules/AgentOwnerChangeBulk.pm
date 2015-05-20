# --
# Kernel/Modules/AgentOwnerChangeBulk.pm - bulk closing of tickets
# Copyright (C) 2015 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentOwnerChangeBulk;

use strict;
use warnings;

use Kernel::System::State;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (
        qw(ParamObject DBObject TicketObject LayoutObject LogObject QueueObject ConfigObject TimeObject)
        )
    {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( Message => "Got no $Needed!" );
        }
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my @TicketIDs = $Self->{ParamObject}->GetArray( Param => 'TicketID' );
    my $ID        = $Self->{ParamObject}->GetParam( Param => 'QuickClose' );

    # check needed stuff
    if ( !@TicketIDs ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    if ( !$ID ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => 'No OwnerID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    my @NoAccess;

    TICKETID:
    for my $TicketID ( @TicketIDs ) {

        # check permissions
        my $Access = $Self->{TicketObject}->TicketPermission(
            Type     => $Self->{Config}->{Permission},
            TicketID => $TicketID,
            UserID   => $Self->{UserID}
        );

        # error screen, don't show ticket
        if ( !$Access ) {
            push @NoAccess, $TicketID;
            next TICKETID;
        }

        $Self->{TicketObject}->TicketOwnerSet(
            TicketID  => $TicketID,
            NewUserID => $ID,
            UserID    => $Self->{UserID},
        );
    }

    # redirect parent window to last screen overview on closed tickets
    if ( !@NoAccess ) {
        my $LastView = $Self->{LastScreenOverview} || $Self->{LastScreenView} || 'Action=AgentDashboard';

        return $Self->{LayoutObject}->Redirect(
            OP => $LastView,
        );

    }
    else {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => 'No Access to these Tickets (IDs: ' . join( ", ", @NoAccess ) . ')',
            Comment => 'Please contact the admin.',
        );
    }
}

1;
