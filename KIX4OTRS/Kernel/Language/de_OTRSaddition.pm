# --
# Kernel/Language/de_OTRSaddition.pm - provides missing de translation for OTRS
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Tom(dot)Lorenz(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSaddition;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Article sender type'} = 'Artikel-Absender-Typ';

    $Lang->{'Add entry'}                 = 'Eintrag hinzufügen';
    $Lang->{'Create new email ticket.'}  = 'Neues Email-Ticket erstellen.';
    $Lang->{'Create new phone ticket.'}  = 'Neues Telefon-Ticket erstellen.';
    $Lang->{'Agents <-> Groups'}         = 'Agenten <-> Gruppen';
    $Lang->{'Agents <-> Roles'}          = 'Agenten <-> Rollen';
    $Lang->{'Auto Responses <-> Queues'} = 'Auto Antworten <-> Queues';
    $Lang->{'Change password'}           = 'Passwort ändern';
    $Lang->{'Please supply your new password!'}
        = 'Bitte geben Sie ein neues Passwort ein!';

    $Lang->{'Companies'}                 = 'Kunden-Firma';
    $Lang->{'Customer company updated!'} = 'Kunden-Firma aktualisiert';
    $Lang->{'Company Tickets'}           = 'Firmen Tickets';
    $Lang->{'Customers <-> Groups'}      = 'Kunden <-> Gruppen';
    $Lang->{'Customers <-> Services'}    = 'Kunden <-> Services';
    $Lang->{'Customer Services'}         = 'Kunden-Services';
    $Lang->{'Limit'}                     = 'Limitierung';
    $Lang->{'timestamp'}                 = 'Zeitstempel';
    $Lang->{'Types'}                     = 'Typen';
    $Lang->{'Bulk-Action'}               = 'Sammelaktion';
    $Lang->{'Responsible Tickets'}       = 'Verantwortliche Tickets';
    $Lang->{'Ticket is locked for another agent!'} =
        'Ticket ist durch einen anderen Agenten gesperrt';
    $Lang->{'Link this ticket to other objects!'} =
        'Ticket mit anderen Objekten verknüpfen!';
    $Lang->{"Wildcards like '*' are allowed."}   = "Platzhalter wie '*' sind erlaubt.";
    $Lang->{'Search for customers.'}             = 'Suche nach Kunden.';
    $Lang->{'Change the ticket classification!'} = 'ändern der Ticket-Klassifizierung!';
    $Lang->{'Change the ticket responsible!'}    = 'ändern des Ticket-Verantwortlichen!';
    $Lang->{'Select new owner'}                  = 'Neuen Besitzer auswählen';
    $Lang->{'Select old owner'}                  = 'Vorherigen Besitzer auswählen';

    # $$STOP$$

    return 0;
}

1;
