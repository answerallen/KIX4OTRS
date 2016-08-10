# --
# Kernel/Language/de_KIX4OTRSPreferences.pm - provides german language translation for preferences extensions
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSPreferences;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    # CustomerSearch
    $Lang->{'Show pending time as remaining time or as point of time with date and time.'}
        = 'Zeigt die Wartezeit als verbleibende Zeit oder als Zeitpunkt mit Datum und Zeit an.';
    $Lang->{'Defines user preference to decide how pending time should be displayed.'} = 'Legt die Nutzereinstellung fest, welche entscheidet, wie die Wartezeit angezeigt werden soll.';
    $Lang->{'Display of pending time'} = 'Anzeige der Wartezeit';
    $Lang->{'Show pending time as'} = 'Anzeige der Wartezeit als';
    $Lang->{'Remaining Time'} = 'Verbleibende Zeit';
    $Lang->{'Point of Time'} = 'Zeitpunkt';
    # EO CustomerSearch

    $Lang->{'Select to decide whether article colors should be used.'} = 'Wählen Sie, ob Artikelfarben genutzt werden sollen.';
    $Lang->{'Use article colors'} = 'Artikelfarben werden genutzt.';
    $Lang->{'Defines user preference to decide whether article colors should be used.'} = 'Legt fest, ob Artikelfarben genutzt werden sollen';
    $Lang->{'Column ticket filters for linked objects.'} = 'Ticket-Filter-Spalte für Ticketübersichten in den verknüpften Objekten.';
    $Lang->{'Overwrite existing search profiles?'} = 'Existierende Suchprofile überschreiben?';
    $Lang->{'Search profiles with same name already exists. Type new search profile name into the textfield to rename copied profile.'} = 'Suchprofile mit gleichem Namen existieren bereits. Tragen Sie einen neuen Profilnamen in das Textfeld ein, um das kopierte Profil umzubenennen.';

    return 0;

    # $$STOP$$
}

1;
