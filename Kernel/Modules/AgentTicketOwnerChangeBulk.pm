# --
# Copyright (C) 2015 - 2018 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketOwnerChangeBulk;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @TicketIDs = $ParamObject->GetArray( Param => 'TicketID' );
    my $ID        = $ParamObject->GetParam( Param => 'QuickOwnerChange' );

    # check needed stuff
    if ( !@TicketIDs ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No TicketID is given!'),
            Comment => Translatable('Please contact the administrator.'),
        );
    }

    if ( !$ID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No OwnerID is given!'),
            Comment => Translatable('Please contact the administrator.'),
        );
    }

    my @NoAccess;
    my @NoAccessNewOwner;

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

        # check permissions
        my $AccessNewOwner = $TicketObject->TicketPermission(
            Type     => 'rw',
            TicketID => $TicketID,
            UserID   => $ID,
        );

        # error screen, don't show ticket
        if ( !$AccessNewOwner ) {
            push @NoAccessNewOwner, $TicketID;
            next TICKETID;
        }

        $TicketObject->TicketOwnerSet(
            TicketID  => $TicketID,
            NewUserID => $ID,
            UserID    => $Self->{UserID},
        );
        
        if ( $ConfigObject->Get('QuickOwnerChange::SetLock') ) {
	    if ($ID == 1 ) {
	      $TicketObject->TicketLockSet(
		  Lock     => 'unlock',
		  TicketID  => $TicketID,
		  UserID    => $Self->{UserID},
	      );
	    } else {
	      $TicketObject->TicketLockSet(
		  Lock     => 'lock',
		  TicketID  => $TicketID,
		  UserID    => $Self->{UserID},
	      );
	    }
        }

        if ( $ConfigObject->Get('QuickOwnerChange::SetResponsible') ) {
            $TicketObject->TicketResponsibleSet(
                TicketID  => $TicketID,
                NewUserID => $ID,
                UserID    => $Self->{UserID},
            );
        }
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
        my $Message = sprintf "%s<br />%s",
            $LayoutObject->{LanguageObject}->Translate(
                'No access to these tickets (IDs: %s)', join( ", ", @NoAccess )
            ),
            $LayoutObject->{LanguageObject}->Translate(
                'No access for given new owner to these tickets (IDs: %s)', join( ", ", @NoAccessNewOwner )
            );

        return $LayoutObject->ErrorScreen(
            Message => $Message,
            Comment => Translatable('Please contact the administrator.'),
        );
    }
}

1;
