# --
# Kernel/Language/hu_QuickOwnerChange.pm - the Hungarian translation for QuickOwnerChange
# Copyright (C) 2014 - 2022 Perl-Services, https://www.perl-services.de
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_QuickOwnerChange;

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
        'Előtétprogram-modul regisztráció a gyors tulajdonosváltás ügyintézői felülethez.';
    $Lang->{'Quick owner change.'} = 'Gyors tulajdonosváltás.';
    $Lang->{'Quick Owner Change'} = 'Gyors tulajdonosváltás';
    $Lang->{'Frontend module registration for the bulk QuickOwnerChange agent interface.'} =
        'Előtétprogram-modul regisztráció a tömeges gyors tulajdonosváltás ügyintézői felülethez.';
    $Lang->{'Bulk quick owner change.'} = 'Tömeges gyors tulajdonosváltás.';
    $Lang->{'Bulk Quick Owner Change'} = 'Tömeges gyors tulajdonosváltás';
    $Lang->{'Module to show OuputfilterOwnerChange.'} = 'Egy modul a tulajdonosváltás kimenetszűrő megjelenítéséhez.';
    $Lang->{'Module to show OuputfilterOwnerChange in ticket overviews.'} =
        'Egy modul a tulajdonosváltás kimenetszűrő megjelenítéséhez a jegyáttekintőkben.';
    $Lang->{'Label for the NULL option in dropdown.'} = 'Címke az üres lehetőséghez a legördülőben.';
    $Lang->{'Minimum permissions for the agent on the queue of the ticket to be listed as a possible owner.'} =
        'Az ügyintéző legkisebb jogosultságai a jegy várólistáján, hogy lehetséges tulajdonosként legyen felsorolva.';
    $Lang->{'If enabled, the ticket will be locked after change.'} =
        'Ha engedélyezve van, akkor a jegy zárolva lesz a változtatás után.';
    $Lang->{'If enabled, the responsible is set to the selected owner.'} =
        'Ha engedélyezve van, akkor a felelős is be lesz állítva a választott tulajdonosra.';
    $Lang->{'If enabled, the possible owners have to be a member of the defined group.'} =
        'Ha engedélyezve van, akkor a lehetséges tulajdonosoknak a meghatározott csoport tagjának kell lennie.';
    $Lang->{'If enabled, the possible owners are defined by the queue the tickets is assigned to and the group.'} =
        'Ha engedélyezve van, akkor a lehetséges tulajdonosokat a csoport, valamint az a várólista határozza meg, amelyhez a jegyek hozzá vannak rendelve.';
    $Lang->{'If enabled, for the given queues only agents of the given group(s) can view the dropdown. If you want all members of the groups \'users\' and \'admin\' to see the dropdown in tickets that are in the queue \'Raw\', you have to write \'users,admin\' as the value.'} =
        'Ha engedélyezve van, akkor a megadott várólistáknál csak a megadott csoportok ügyintézői láthatják a legördülőt. Ha azt szeretné, hogy a „users” és az „admin” csoport összes tagja lássa a legördülőt azokban a jegyekben, amelyek a „Raw” várólistában vannak, akkor „users,admin” értéket kell beírnia.';
    $Lang->{'If enabled, only agents of the given groups can see the dropdown.'} =
        'Ha engedélyezve van, akkor csak a megadott csoportok ügyintézői láthatják a legördülőt.';
    $Lang->{'Yes'} = 'Igen';
    $Lang->{'No'} = 'Nem';

    # Kernel/Modules/AgentTicketOwnerChangeBulk.pm
    $Lang->{'No TicketID is given!'} = 'Nincs jegyazonosító megadva!';
    $Lang->{'Please contact the administrator.'} = 'Vegye fel a kapcsolatot a rendszergazdával.';
    $Lang->{'No OwnerID is given!'} = 'Nincs tulajdonosazonosító megadva!';
    $Lang->{'No access to these tickets (IDs: %s)'} = 'Nincs hozzáférés ezekhez a jegyekhez (azonosítók: %s)';

    # Kernel/Output/HTML/Templates/Standard/QuickOwnerChangeSnippet.tt
    $Lang->{'QuickOwnerChange ticket'} = 'Jegy gyors tulajdonosváltása';
    $Lang->{'QuickOwnerChange'} = 'Gyors tulajdonosváltás';

    return 1;
}

1;
