# --
# Kernel/Output/HTML/OutputFilterOwnerChange.pm
# Copyright (C) 2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterOwnerChange;

use strict;
use warnings;

use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::Ticket;
use Kernel::System::User;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = { %Param };
    bless( $Self, $Type );

    # get needed objects
    for my $Object ( qw(MainObject ConfigObject LogObject LayoutObject ParamObject) ) {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    return 1 if !$Self->{TicketObject};

    if ( $Templatename  =~ m{AgentTicketZoom\z} ) {
        my ($TicketID) = $Self->{ParamObject}->GetParam( Param => 'TicketID' );

        my %Ticket = $Self->{TicketObject}->TicketGet(
            TicketID => $TicketID,
            UserID   => $Self->{UserID},
        );

        my $GroupID = $Self->{QueueObject}->GetQueueGroupID(
            QueueID => $Ticket{QueueID},
        );

        my $Type = $Self->{ConfigObject}->Get('QuickOwnerChange::Permissions') || 'rw';
        my %User = $Self->{GroupObject}->GroupMemberList(
            GroupID => $GroupID,
            Type    => $Type,
            Result  => 'HASH',
        );

        $User{$_} = $Self->{UserObject}->UserName( UserID => $_ ) for keys %User;

        my @Data = map{ { Key => $_, Value => $User{$_} } }sort{ $User{$a} cmp $User{$b} }keys %User;
        
        unshift @Data, {
            Key => '', 
            Value => ' - ' . ($Self->{ConfigObject}->Get( 'QuickOwnerChange::NoneLabel' ) || 'QuickOwnerChange')  . ' - ',
        };

        my $Select = $Self->{LayoutObject}->BuildSelection(
            Name       => 'QuickOwnerChange',
            Data       => \@Data,
            SelectedID => '',
        );
        
        my $Snippet = $Self->{LayoutObject}->Output(
            TemplateFile => 'QuickOwnerChangeSnippet',
            Data         => {
                TicketID => $TicketID,
                Select   => $Select,
            },
        ); 

        #scan html output and generate new html input
        my $LinkType = $Self->{ConfigObject}->Get('Ticket::Frontend::MoveType');
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
