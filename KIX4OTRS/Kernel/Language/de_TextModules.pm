# --
# Kernel/Language/de_TextModules.pm - provides german language translation for TextModules
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_TextModules;

use strict;
use utf8;
use warnings;

# --
sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Text Modules'}            = 'Text-Bausteine';
    $Lang->{'Text modules'}            = 'Text-Bausteine';
    $Lang->{'Text modules selection'}  = 'Text-Bausteine Auswahl';
    $Lang->{'Text module'}             = 'Text-Baustein';
    $Lang->{'Filter for text modules'} = 'Filter für Text-Bausteine';
    $Lang->{'Filter for queues'}       = 'Filter für Queues';
    $Lang
        ->{'A text module is default text to write faster answer (with default text) to customers.'}
        = 'Ein Text-Baustein ist ein vordefinierter Text, um Kunden schneller antworten zu können.';
    $Lang->{'Don\'t forget to add a new text module a queue!'}
        = 'Ein neuer Text-Baustein muss einer Queue zugewiesen werden!';
    $Lang->{'add a text module'}               = 'Einen Text-Baustein hinzufügen';
    $Lang->{'delete this text module'}         = 'Diesen Text-Baustein löschen';
    $Lang->{'edit'}                            = 'Bearbeiten';
    $Lang->{'(Click here to add)'}             = '(Hier klicken um hinzufügen)';
    $Lang->{'Click here to add a text module'} = 'Hier klicken um einen Text-Baustein hinzufügen';
    $Lang->{'Change Queue relations for text modules'}
        = 'Ändern der Queue-Zuordnung für Text-Baustein';
    $Lang->{'Change text modules relations for Queue'}
        = 'Ändern der Text-Baustein-Zuordnung für Queue';
    $Lang->{'Change text module settings'}
        = 'Ändern der Text-Baustein Einstellungen';
    $Lang->{'A text module should have a name!'}
        = 'Ein Text-Baustein sollte einen Namen haben!';
    $Lang->{'A text module should have a content!'}
        = 'Ein Text-Baustein sollte einen Inhalt haben!';
    $Lang->{'Assume to text'} = 'In den Text übernehmen';
    $Lang->{'Double click on the text module, which should be added to the body'}
        = 'Auf den Text-Baustein doppelt klicken, der in den Text übernommen werden soll';
    $Lang->{'Move over the text module, which should be displayed'}
        = 'Über den Text-Baustein fahren, der angezeigt werden soll';
    $Lang->{'Undo'}                    = 'Rückgängig';
    $Lang->{'Paste'}                   = 'Einfügen';
    $Lang->{'Queue Assignment'}        = 'Zuordnung zu Queue';
    $Lang->{'Ticket Type Assignment'}  = 'Zuordnung zu Tickettyp';
    $Lang->{'Ticket State Assignment'} = 'Zuordnung zu Ticketstatus';
    $Lang->{'Filter Overview'}         = 'übersicht einschränken';
    $Lang->{'Limit Results'}           = 'Anzahl limitieren';
    $Lang->{'Add a new text module'}   = 'Einen neuen Textbaustein hinzufügen';
    $Lang->{'New text module'}         = 'neuer Textbaustein';
    $Lang->{'Add text module'}         = 'Textbaustein anlegen';
    $Lang->{'entries shown'}           = 'Einträge angezeigt';
    $Lang->{'Download'}                = 'Herunterladen';
    $Lang->{'Text Modules Management'} = 'Verwaltung Textbausteine';
    $Lang->{'Upload text modules'}     = 'Textbausteine hochladen';
    $Lang->{'Import failed - No file uploaded/received'}
        = 'Import fehlgeschlagen - keine Datei hochgeladen/empfangen';
    $Lang->{'Result of the upload'}      = 'Ergebnis des Imports';
    $Lang->{'entries uploaded'}          = 'Hochgeladene Einträge';
    $Lang->{'updated'}                   = 'aktualisiert';
    $Lang->{'added'}                     = 'hinzugefügt';
    $Lang->{'update failed'}             = 'Aktualisierung fehlgeschlagen';
    $Lang->{'insert failed'}             = 'Hinzufügen fehlgeschlagen';
    $Lang->{'Download all text modules'} = 'Alle Textbausteine herunterladen';
    $Lang->{'Download result as XML'}
        = 'Herunterladen des Ergebnisses als XML';
    $Lang->{'Summary'}           = 'Zusammenfassung';
    $Lang->{'Available in'}      = 'Verfügbar in';
    $Lang->{'Agent Frontend'}    = 'Agentenfrontend';
    $Lang->{'Customer Frontend'} = 'Kundenfrontend';
    $Lang->{'Public Frontend'}   = 'Öffentliches Frontend';
    $Lang->{'A: agent frontend; C: customer frontend, P: public frontend'} =
        'A: Agentenoberfläche; C: Kundenoberfläche; P: Öffentliche Oberfläche';
    $Lang->{'Assigend To'} = 'Zugeordnet zu';
    $Lang->{'No existing or matching text module'}
        = 'Es sind keine oder keine passenden Text-Bausteine vorhanden';
    $Lang->{'Categories'}                      = 'Kategorien';
    $Lang->{'Text Module Category Management'} = 'Verwaltung Textbaustein-Kategorien';
    $Lang->{'Text Module Categories'}          = 'Text-Baustein-Kategorien';
    $Lang->{'Create and manage text module categories.'}
        = 'Erstellen und Verwalten von Textbaustein-Kategorien.';
    $Lang->{'Category Selection'}  = 'Kategorienauswahl';
    $Lang->{'Category Assignment'} = 'Zuordnung zur Kategorie';
    $Lang->{'List for category'}   = 'Liste für Kategorie';
    $Lang->{'ALL'}                 = 'ALLE';
    $Lang->{'NOT ASSIGNED'}        = 'NICHT ZUGEWIESEN';
    $Lang->{'Do you really want to delete this category and all of it\'s subcategories ?'}
        = 'Wollen Sie diese Kategorie und alle ihre Unterkategorien wirklich löschen ?';
    $Lang->{'Keywords'}                = 'Schlüsselwörter';
    $Lang->{'Add category'}            = 'Kategorie hinzufügen';
    $Lang->{'Download all categories'} = 'Alle Kategorien herunterladen';
    $Lang->{'Upload categories'}       = 'Kategorien hochladen';
    $Lang->{'Parent Category'}         = 'Übergeordnete Kategorie';
    $Lang->{'Text module category'}    = 'Textmodulkategorie';
    $Lang->{'successful loaded.'}    = 'erfolgreich hochgeladen.';
    $Lang->{'Import failed - No file uploaded/received.'}    = 'Import fehlgeschlagen - Keine Datei hochgeladen/erhalten.';

    # KIX4OTRS_TextModules.xml
    $Lang->{'Frontend module registration for the AdmintTextModules object in the admin interface.'}
        =
        'Frontendmodul-Registration des AdminTextModules-Objekts im Admin-Interface.';
    $Lang->{'Frontend module registration for the AdminQueueTextModules object in the admin area.'}
        =
        'Frontendmodul-Registration des AdminQueueTextModules-Objekts im Admin-Bereich.';
    $Lang->{
        'Defines if the messages body is reset after ticket type or queue change. Relevant for automatic loading of a single text module.'
        } =
        'Definiert ob die Nachricht bei Aenderung von Tickettyp oder Queue zurueckgesetzt wird. Relevant fuer autom. Laden eines einzelnen Textbausteins.';
    $Lang->{'Default value for maximum number of entries shown in TextModule overview.'} =
        'Standardauswahl fuer maximale Anzahl an angezeigten Textbausteinen in Uebersicht.';
    $Lang->{'Default value for Do-Not-Add-Flag in XML-textmodule upload.'} =
        'Standardauswahl fuer Nicht-Hinzufuegen-Kennung in XML-Textbausteinupload.';
    $Lang->{
        'If activated queues offered for use in EditView are limited by the selected language (language short identifier must be contained as subqueuename in complete queue name).'
        } =
        'Wenn aktiviert, werden die Queues in der Bearbeitenansicht basierend auf der Sprachauswahl eingeschraenkt (Sprachkuerzel muss als Subqueuename in vollstaendigem Queuenamen enthalten sein).';
    $Lang->{'Select frontend agent modules where text modules are activated.'} =
        'Festlegung in welchen Agent-Frontend-Modulen die Textbausteine aktiviert sind.';
    $Lang->{'Additional and extended TextModule methods.'} =
        'Zusaetzliche und erweiterte TextModule-Methoden.';
    $Lang->{'Default values for uploaded TextModules.'} =
        'Standardwerte fuer hochgeladene Textbausteine.';
    $Lang->{'List of JS files to always be loaded for the customer interface.'} =
        'Liste von JS-Dateien, die immer im Kunden-Interface geladen werden.';
    $Lang->{'Show or hide the text modules'} = 'Text-Bausteine zeigen oder verstecken';

    $Lang->{'Create and manage text templates.'} = 'Erstellen und verwalten von Textbausteinen.';
    $Lang->{'Text module Management'}            = 'Text-Bausteine Verwaltung';
    $Lang->{'Text modules <-> Queue Management'} = 'Text-Bausteine <-> Queue Verwaltung';
    $Lang->{'Text Modules <-> Queues'}           = 'Text-Bausteine <-> Queues';
    $Lang->{'Assign text templates to queues.'}  = 'Textbausteine zu Queues zuordnen.';

    $Lang->{''} = '';

    # EO KIX4OTRS_TextModules.xml

    # $$STOP$$

    return 0;
}

1;
