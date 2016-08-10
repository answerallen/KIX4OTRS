# --
# Kernel/Language/de_KIX4OTRSTemplateConfigurator.pm - provides german language translation for TemplateConfigurator
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSTemplateConfigurator;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return 0 if ref $Lang ne 'HASH';

    # $$START$$
    # redirect messages
    $Lang->{'Ticket template successfully updated!'} = 'Ticket-Vorlage erfolgreich aktualisiert!';
    $Lang->{'Ticket template could not be updated!'}
        = 'Ticket-Vorlage konnte nicht aktualisiert werden!';
    $Lang->{'Copy of ticket template successfully created!'}
        = 'Kopie der Ticket-Vorlage erfolgreich angelegt!';
    $Lang->{'Ticket template could not be copied!'} = 'Ticket-Vorlage konnte nicht kopiert werden!';
    $Lang->{'Ticket template successfully deleted!'} = 'Ticket-Vorlage erfolgreich gelöscht!';
    $Lang->{'Ticket template could not be deleted!'}
        = 'Ticket-Vorlage konnte nicht gelöscht werden!';

    # frontend
    $Lang->{'Pending Date Offset'} = 'Warten bis-Verschiebung';
    $Lang->{
        'Time in minutes that gets added to the actual time if setting a pending-state (e.g. 1440 = 1 day)'
        }
        = 'Zeit in Minuten, die zur aktuellen Zeit addiert wird, wenn ein Warte-Status gesetzt wird (z.B. 1440 = 1 Tag)';
    $Lang->{'This field will be filled by customer data. It cannot be prepopulated.'}
        = 'Dieses Feld wird durch die Kunden-Daten bestimmt. Es kann nicht vorausgefüllt werden.';
    $Lang->{'First of all, please select or add a ticket template.'}
        = 'Bitte wählen Sie zunächst eine Ticket-Vorlage aus oder legen Sie eine neue an.';
    $Lang->{'Please insert the template name for the copy of the selected template.'}
        = 'Bitte geben Sie einen Template-Namen für die Kopie der ausgewählten Vorlage an.';
    $Lang->{'Name for new template'}        = 'Name der neuen Vorlage';
    $Lang->{'Add ticket template'}          = 'Ticketvorlage hinzufügen';
    $Lang->{'Ticket Template Configurator'} = 'Ticketvorlagen Konfigurator';
    $Lang->{'Create new quick ticket template or change existing.'}
        = 'Quick-Ticket-Vorlagen erzeugen und verwalten.';
    $Lang->{'Link type'}      = 'Verknüpfungstyp';
    $Lang->{'Link direction'} = 'Verknüpfungsrichtung';
    $Lang->{
        'Old ticket templates have to be migrated from SysConfig to database before dealing with!'
        }
        = 'Alte Ticketvorlagen müssen von der SysConfig in die Datenbank übertragen werden, bevor mit ihnen gearbeitet werden kann!';
    $Lang->{'Click here to migrate ticket templates'} = 'Klicken, um Ticketvorlagen zu übertragen';
    $Lang->{'Click here to add a ticket template'}    = 'Klicken, um Ticketvorlage hinzuzufügen';
    $Lang->{'Migrate ticket templates'}               = 'Ticketvorlagen übertragen';
    $Lang->{'Ticket template migration successful'} = 'übertragen der Ticketvorlagen erfolgreich.';
    $Lang->{'No existing or matching quick tickets'}
        = 'Es sind keine oder keine passenden Ticket-Vorlagen vorhanden';
    $Lang->{'A: agent frontend; C: customer frontend'}
        = 'A: Agenten-Frontend, C: Kunden-Frontend';
    $Lang->{'delete'} = 'Löschen';
    $Lang->{'Download all ticket templates'} = 'Alle Ticketvorlagen herunterladen';
    $Lang->{'Upload ticket templates'} = 'Ticketvorlagen hochladen';
    $Lang->{'Available for user groups'} = 'Verfügbar für Nutzergruppen';
    $Lang->{'Empty value'} = 'leerer Wert';

    return 0;

    # $$STOP$$
}
1;
