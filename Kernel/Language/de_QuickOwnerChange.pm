# --
# Kernel/Language/de_QuickOwnerChange.pm - the German translation for QuickOwnerChange
# Copyright (C) 2014 - 2022 Perl-Services, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_QuickOwnerChange;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/QuickOwnerChange.xml
    $Lang->{'Frontend module registration for the QuickOwnerChange agent interface.'} =
        'Frontendmodul-Registration für das QuickOwnerChange Agenten Interface.';
    $Lang->{'Quick owner change.'} = '';
    $Lang->{'Quick Owner Change'} = '';
    $Lang->{'Frontend module registration for the bulk QuickOwnerChange agent interface.'} =
        'Frontendmodul-Registration für das MassenQuickOwnerChange Agenten Interface.';
    $Lang->{'Bulk quick owner change.'} = '';
    $Lang->{'Bulk Quick Owner Change'} = '';
    $Lang->{'Module to show OuputfilterOwnerChange.'} = 'Modul zum Anzeigen von OuputfilterOwnerChange.';
    $Lang->{'Module to show OuputfilterOwnerChange in ticket overviews.'} =
        'Modul zum Anzeigen von OuputfilterOwnerChange in Ticketübersichten.';
    $Lang->{'Label for the NULL option in dropdown.'} = '';
    $Lang->{'Minimum permissions for the agent on the queue of the ticket to be listed as a possible owner.'} = '';
    $Lang->{'If enabled, the ticket will be locked after change.'} = '';
    $Lang->{'If enabled, the responsible is set to the selected owner.'} = '';
    $Lang->{'If enabled, the possible owners have to be a member of the defined group.'} = '';
    $Lang->{'If enabled, the possible owners are defined by the queue the tickets is assigned to and the group.'} = '';
    $Lang->{'If enabled, for the given queues only agents of the given group(s) can view the dropdown. If you want all members of the groups \'users\' and \'admin\' to see the dropdown in tickets that are in the queue \'Raw\', you have to write \'users,admin\' as the value.'} = '';
    $Lang->{'If enabled, only agents of the given groups can see the dropdown.'} = '';
    $Lang->{'Yes'} = 'Ja';
    $Lang->{'No'} = 'Nein';

    # Kernel/Modules/AgentTicketOwnerChangeBulk.pm
    $Lang->{'No TicketID is given!'} = 'Keine TicketID übermittelt!';
    $Lang->{'Please contact the administrator.'} = '';
    $Lang->{'No OwnerID is given!'} = '';
    $Lang->{'No access to these tickets (IDs: %s)'} = '';

    # Kernel/Output/HTML/Templates/Standard/QuickOwnerChangeSnippet.tt
    $Lang->{'QuickOwnerChange ticket'} = '';
    $Lang->{'QuickOwnerChange'} = '';

    return 1;
}

1;
