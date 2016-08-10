# --
# Kernel/Language/de_KIX4OTRS.pm - provides de translation for KIX4OTRS
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Frank(dot)Oberender(at)cape(dash)it(dot)de
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

##########################################
#
# Zeilen die auskommentiert sind,
# muessen noch übersetzt werden
# Nicht ohne weiteres rauslöschen!
#
##########################################

package Kernel::Language::de_KIX4OTRS;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    # FAQWorkflow...
    $Lang->{'Suggest as FAQ-Entry'} = 'Als FAQ-Eintrag vorschlagen';
    $Lang->{'Defines if the trigger flag at the source ticket/article is reset.'}
        = 'Definiert ob das auslösende Flag am Quellticket/-artikel zurückgesetzt wird.';
    $Lang->{'Defines if the new FAQ-article is linked with the source ticket.'}
        = 'Definiert ob der neue FAQ-Artikel mit dem Quellticket verknüpft wird.';
    $Lang->{'Basic settings for FAQ edit workflow.'}
        = 'Grundlegende Einstellungen für den FAQ-Redaktionsprozess';
    $Lang->{'Enables creation of a FAQ entry from currently created article.'}
        = 'Aktiviert die Erstellung eines FAQ-Eintrags aus dem akt. erzeugtem Artikel.'
        ;
    $Lang->{'KIX4OTRS: Define the free key field 3 for articles. Its a new article property.'}
        = 'KIX4OTRS: Definition des FreiSchlüsselFeldes 3 für Artikel. Hierüber kann einen zusätzliches Artikel-Attribut definiert werden.';

    # custom article types...
    $Lang->{'note-workaround-external'} = 'Workaroundbeschreibung (sichtbar für Kunde)';
    $Lang->{'note-workaround-internal'} = 'Workaroundbeschreibung (unsichtbar für Kunde)';
    $Lang->{'note-reason-external'}     = 'Ursachenbeschreibung (sichtbar für Kunde)';
    $Lang->{'note-reason-internal'}     = 'Ursachenbeschreibung (unsichtbar für Kunde)';
    $Lang->{'note-close-external'}      = 'Abschlussnotiz (sichtbar für Kunde)';
    $Lang->{'note-close-internal'}      = 'Abschlussnotiz (unsichtbar für Kunde)';
    $Lang->{'email-notification-ext'}   = 'Email-Benachrichtigung (sichtbar für Kunde)';
    $Lang->{'email-notification-int'}   = 'Email-Benachrichtigung (unsichtbar für Kunde)';
    $Lang->{'fax'}                      = 'Fax (sichtbar für Kunde)';

    # other translations...
    $Lang->{'KIX Online Help'}                 = 'Onlinehilfe für KIX';
    $Lang->{'pending auto reopen'}             = 'warten zur Wiedervorlage';
    $Lang->{'Ticketnumber'}                    = 'Ticket-Nummer';
    $Lang->{'Ticket number'}                   = 'Ticket-Nummer';
    $Lang->{'Invalid ticket number!'}          = 'Ungültige Ticket-Nummer!';
    $Lang->{'Ticket bounced'}                  = 'Ticket umgeleitet';
    $Lang->{'ZIP'}                             = 'PLZ';
    $Lang->{'ZIP Code'}                        = 'PLZ';
    $Lang->{'ZIP-Code'}                        = 'PLZ';
    $Lang->{'Street'}                          = 'Strasse';
    $Lang->{'Mobile'}                          = 'Mobil';
    $Lang->{'Phone number'}                    = 'Telefon-Nr.';
    $Lang->{'Phonenumber'}                     = 'Telefonnummer';
    $Lang->{'Function'}                        = 'Funktion';
    $Lang->{'County'}                          = 'Land';
    $Lang->{'Company'}                         = 'Firma';
    $Lang->{' (minutes)'}                      = ' (Minuten)';
    $Lang->{' (hours)'}                        = ' (Stunden)';
    $Lang->{'Accounted time for this article'} = 'Erfasste Zeit für diesen Artikel';
    $Lang->{'Click to change CustomerID'}      = 'Hier Klicken um Kunden# zu ändern';
    $Lang->{'Multiple Selection'}              = 'Mehrfachauswahl';
    $Lang->{'current'}                         = 'aktuell';
    $Lang->{'desired date'}                    = 'Wunschtermin';
    $Lang->{'Desired date'}                    = 'Wunschtermin';
    $Lang->{'Please click the button below to create a ticket of the desired template.'} =
        'Bitte klicken Sie auf den jeweiligen Button, um ein Ticket aus der gewünschten Vorlage zu erstellen.';
    $Lang->{'Don\'t write \'Fwd:\' into subject'}    = 'Kein \'Fwd:\' in den Betreff schreiben';
    $Lang->{'Don\'t write \'Re:\' into subject'}     = 'Kein \'Re:\' in den Betreff schreiben';
    $Lang->{'Write a mail, using an empty template'} = 'Leere E-Mail verfassen';
    $Lang->{'Empty mail'}                            = 'Leere Email';
    $Lang->{'Link ticket'}                           = 'Ticket verknüpfen';
    $Lang->{'Check to activate this date'}           = 'Haken setzten um Datum zu aktivieren';
    $Lang->{'All Tickets'}                           = 'Alle Tickets';
    $Lang->{'Open linked Tickets'}                   = 'Offene verknüpfte Tickets';
    $Lang->{'All linked Tickets'}                    = 'Alle verknüpften Tickets';
    $Lang->{'The icon file to be used as favicon (relative to Frontend::ImagePath).'} =
        'Die Icondatei welche als Favicon genutzt werden soll (relativ zu Frontend::ImagePath).';
    $Lang->{"This field's content can not be longer than %s characters."} =
        'Der Inhalt dieses Felds kann max. %s Zeichen betragen.';
    $Lang->{"This field is required and its content can not be longer than %s characters."} =
        'Dieses Feld wird benötigt und der Inhalt kann max. %s Zeichen betragen.';
    $Lang->{'Do you really want to delete the selected links?'}
        = 'Möchten Sie die ausgewählten Verlinkungen wirklich löschen ?';
    $Lang->{'Search Template'}         = 'Suchvorlage';
    $Lang->{'My Search Profiles'}      = 'Meine Suchvorlagen';
    $Lang->{'Clone customer'}          = 'Kunde kopieren';
    $Lang->{'Search Profile Category'} = 'Kategorie der Suchvorlage';
    $Lang->{'Search Profile'}          = 'Suchvorlage';
    $Lang->{'Please select a category to add the shared search profile. Or enter a new category.'}
        = 'Kategorie wählen, zu der die geteilte Suchvorlage hinzugefügt werden soll. Oder eine neue Kategorie anlegen.';
    $Lang->{'Name for new search template category'} = 'Name der neuen Suchvorlagen-Kategorie';
    $Lang->{'Subscribe'}      = 'Abonnieren';
    $Lang->{'Clone agent'}    = 'Agent kopieren';
    $Lang->{'with link type'} = 'mit Verknüpfungstyp';
    $Lang->{'Select all the existing article attachments which should be attached too.'} =
        'Wählen Sie die Artikel-Anlagen aus, die ebenfalls angehangen werden sollen.';
    $Lang->{'A previously saved draft (Subject and Text) exists. Load the draft or delete ?'} =
        'Ein gespeicherter Entwurf (Betreff und Text) ist vorhanden. Soll dieser geladen oder gelöscht werden ?';
    $Lang->{'Save As Draft (Subject and Text)'} = 'Als Entwurf (Betreff und Text) speichern';
    $Lang->{'Defines the attributes to save form content as draft.'}
        = 'Legt die Attribute fest, die beim Als-Entwurf-Speichern gesichert werden sollen.';
    $Lang->{'Activates the save as draft button.'} = 'Aktiviert den Button: Als Entwurf speichern.';
    $Lang->{'Module Registration for the SaveAsDraft AJAXHandler.'}
        = 'Modulregistrierung für den AJAXHandler zu: Als Entwurf speichern.';
    $Lang->{'Module Registration for the PopupSize AJAXHandler.'}
        = 'Modulregistrierung für den AJAXHandler zu: Popupgröße ändern.';
    $Lang->{'Show DynamicField in frontend modules'}
        = 'Das Dynamische Feld wird in diesen Frontendmodulen angezeigt';
    $Lang->{'Mandatory in frontend modules'}   = 'Pflichtfeld in diesen Frontendmodulen';
    $Lang->{'DynamicField SysConfig Settings'} = 'SysConfig-Einstellungen für das Dynamische Feld';
    $Lang->{'Saving module assignments in SysConfig'} = 'Modulzuweisungen werden in SysConfig gespeichert';
    $Lang->{'Please select all frontend modules which should display the dynamic field.'}
        = 'Bitte wählen Sie alle Frontendmodule,<br /> in denen das Dynamische Feld angezeigt werden soll.';
    $Lang->{
        'Please select all frontend modules which should have the dynamic field as a mandatory field.'
        }
        = 'Bitte wählen Sie alle Frontendmodule,<br /> in denen das Dynamische Feld Pflichtfeld sein soll.';
    $Lang->{'Defines the interval to save form content as draft in milliseconds.'}
        = 'Legt das Intervall fest, in dem der Inhalt des Formulars gesichert werden soll. Der Wert ist in Millisekunden angegeben.';
    $Lang->{'Defines the message to be displayed when a draft exists and can be loaded.'}
        = 'Legt die Meldung fest, die angezeigt wird, wenn ein Entwurf existiert und geladen werden kann.';
    $Lang->{'ObjectReference'}          = 'Objektreferenz';
    $Lang->{'Attachments Download'}     = 'Anlagen herunterladen';
    $Lang->{'Tickets New'}              = 'Tickets, neu';
    $Lang->{'Tickets Total'}            = 'Tickets insgesamt';
    $Lang->{'Tickets Reminder Reached'} = 'Tickets, Erinnerungszeit erreicht';
    $Lang->{'Ticket Customer'}          = 'Ticketkunde';
    $Lang->{'Third Party'}              = 'Dritte';
    $Lang->{'Customer Contact'}         = 'Kundenkontakt';
    $Lang->{'Contact Information'}      = 'Kontaktinformationen';
    $Lang->{'Link Type'}                = 'Linktyp';
    $Lang->{'Not set'}                  = 'Nicht gesetzt';
    $Lang->{
        'Defines possible search criteria in the agents link interface for target object "Ticket". Order is important. Value is used as internal name.'
        }
        = 'Legt mögliche Suchkriterien im Agenteninterface für das Zielobjekt "Ticket" fest. Der Wert wird als interner Name genutzt.';
    $Lang->{
        'Defines displayed name for configured search criteria. Key has to be one of the internal names (see above); Value is used as name in the interface.'
        }
        = 'Legt den Anzeigename für die konfigurierten Suchkriterien fest. Der Schlüssel muss einer der vorher definierten internen Namen - siehe oben - sein. Der Wert ist der angezeigte Name in der Nutzeroberfläche.';
    $Lang->{
        'Defines data source for configured search criteria. Key has to be one of the internal names (see above); Value is used as name in the interface.'
        }
        = 'Legt die Datenquellen für die konfigurierten Suchkriterien fest. Der Schlüssel muss einer der vorher definierten internen Namen - siehe oben - sein.';
    $Lang->{'Determines the way the linked objects are displayed in each zoom mask.'}
        = 'Bestimmt die Art, wie verlinkte Objekte in jeder Zoom-Maske angezeigt werden.';
    $Lang->{'Create new linked person on create new Article or Update Owner.'}
        = 'Erstellt eine neue verlinkte Person, wenn ein Artikel erstellt oder ein Besitzer neu gesetzt wird.';
    $Lang->{'Defines which persons should not be added on AutoCreateLinkedPerson'}
        = 'Legt fest, welche Personen nicht automatisch bei AutoCreateLinkedPerson hinzugefügt werden sollen.';
    $Lang->{'This setting defines the person link type "agent".'}
        = 'Diese Einstellung definiert den Personen-Link-Typ "Agent".';
    $Lang->{'This setting defines the person link type "customer".'}
        = 'Diese Einstellung definiert den Personen-Link-Typ "Kunde".';
    $Lang->{'This setting defines the person link type "3rd party".'}
        = 'Diese Einstellung definiert den Personen-Link-Typ "Dritte".';
    $Lang->{
        'This setting defines that a "Ticket" object can be linked with persons using the "agent" link type.'
        }
        = 'Diese Einstellung legt fest, dass ein Ticketobjekt als "Agent" mit einer Person verlinkt werden kann.';
    $Lang->{
        'This setting defines that a "Ticket" object can be linked with persons using the "customer" link type.'
        }
        = 'Diese Einstellung legt fest, dass ein Ticketobjekt als "Kunde" mit einer Person verlinkt werden kann.';
    $Lang->{
        'This setting defines that a "Ticket" object can be linked with persons using the "3rd party" link type.'
        }
        = 'Diese Einstellung legt fest, dass ein Ticketobjekt als "Dritte" mit einer Person verlinkt werden kann.'
        ;
    $Lang->{'List of CSS files to always be loaded for the customer interface.'}
        = 'Liste von CSS-Dateien, die immer im Kunden-Interface geladen werden.';
    $Lang->{'Configure an stylesheet dependent on ticket state.'}
        = 'Legt ein Stylesheet fest, welches auf dem Ticketstatus basiert.';
    $Lang->{'List of CSS files to always be loaded for the agent interface.'}
        = 'Liste von CSS-Dateien, die immer im Agenten-Interface geladen werden.';
    $Lang->{'PostmasterFilter which sets destination queue in X-headers depending on email suffix.'}
        = 'PostmasterFilter, welcher eine Zielqueue im X-Header in Abhängigkeit vom Email-Suffix setzt.';
    $Lang->{
        'Registers an identifier for the email filters. Value is used in the following config options. The keys will use for sorting.'
        }
        = 'Registriert einen Bezeichner für Emailfilter. Der Wert wird für die folgenden Optionen benötigt. Die Schlüssel legen die Sortierreihenfolge fest.';
    $Lang->{
        'Key has to be one of the identifier (see above). Values have to be an email address or a regexp as the sender which will be matched in from field of email.'
        } = 'Der Schlüssel muss einer der Bezeichner von oben sein. Werte müssen Emailadressen oder reguläre Ausdrücke sein, welche auf den Absender im "Von"-Feld passen.';
    $Lang->{
        'Key has to be one of the identifier (see above). Values have to be a regexp decribes the external reference number format which will be matched in subject field of the email.'
        } = 'Der Schlüssel muss einer der Bezeichner von oben sein. Werte müssen reguläre Ausdrücke sein, welche auf die externe Referenznummer im Betreff-Feld der Email passen.';
    $Lang->{
        'Key has to be one of the identifier (see above). Values have to be dynamic field names in which the external reference numbers will be saved. this fields will be used for extended follow up.'
        } = 'Der Schlüssel muss einer der Bezeichner von oben sein. Werte müssen Namen von dynamischen Feldern sein, in welchen die jeweiligen Referenznummern gespeichert werden sollen. Dieses Feld wird für das ExtendedFollowUp genutzt.';
    $Lang->{'Sort order for the age of the follow up tickets.'}
        = 'Sortierreihenfolge für das Alter der Follow-Up-Tickets.';
    $Lang->{
        'State types of follow up tickets which will be considered. If open/pending tickets was selected and no one was found all tickets will be considered.'
        } = 'Statustypen des FollowUpTickets, welche berücksichtigt werden sollen. Wenn "offene/wartende Tickets" gewählt und keine Tickets gefunden wurden, werden alle Tickets berücksichtigt.';
    $Lang->{'First open/pending tickets'}
        = 'Zuerst offene/wartende Tickets.';
    $Lang->{'Show merged tickets in linked objects table.'}
        = 'Anzeige zusammengefasster Tickets in der Tabelle mit den verknüpften Objekten.';
    $Lang->{'Show Merged Tickets in Linked Objects'}
        = 'Zusammengefasste Tickets anzeigen.';
    $Lang->{'Sets the default link object target identifier.'} = 'Setzt den Standard LinkObject Identifikator beim Erstellen von Email- oder Phonetickets.';
    $Lang->{'Defines Output filter to change link object target identifier.'} = 'Definiert einen Outputfilter, um den TargetIdentifier für die verlinkten Objekte im Email- und Phoneticket anzupassen.';
    $Lang->{'Defines Output filter to provide multiselect fields to assign dynamic fields easily to frontend modules.'} = 'Definiert einen Outputfilter, um Mehrfachauswahlfelder zum schnellen Zuweisen von dynamischen Feldern zu Frontendmodulen einzublenden.';
    $Lang->{'Alternative Display'} = 'Alternative Anzeige';
    $Lang->{'Here you can specify an alternative display string using placeholders for variables. If empty, the default will be taken.'} = 'Hier können Sie eine Alternative für die Darstellung angeben, unter Nutzung von Platzhaltern für Variablen. Falls nichts angegeben ist, wird der Standard genutzt.';
    $Lang->{'saved'} = 'gespeichert';
    $Lang->{'All agents who are linked with this ticket and have been selected (Linked Persons)'}
        = 'Alle Agenten die mit dem Ticket verlinkt sind und auswählt wurden (Verlinkte Personen)';
    $Lang->{'All customer users who are linked with this ticket and have been selected (Linked Persons)'}
        = 'Alle Kundennutzer die mit dem Ticket verlinkt sind und auswählt wurden (Verlinkte Personen)';
    $Lang->{'All 3rd person contacts who are linked with this ticket and have been selected (Linked Persons)'}
        = 'Alle "Dritte" die mit dem Ticket verlinkt sind und auswählt wurden (Verlinkte Personen)';


    # ticket template extensions
    $Lang->{'Create new ticket from template'} = 'Neues Ticket aus Vorlage erstellen';
    $Lang->{'Create new ticket from predefined template'} =
        'Neues Ticket aus vordefinierter Vorlage erstellen';
    $Lang->{'New Template Ticket'}           = 'Neues Vorlage-Ticket';
    $Lang->{'Template Description'}          = 'Vorlagenbeschreibung';
    $Lang->{'Template'}                      = 'Vorlage';
    $Lang->{'Ticket Templates'}              = 'Ticketvorlagen';
    $Lang->{'Ticket-Template'}               = 'Ticketvorlage';
    $Lang->{'Ticket-Template selection'}     = 'Ticket-Vorlagen-Auswahl';
    $Lang->{'Create new quick-email ticket'} = 'Neues Schnell-Email-Ticket erstellen';
    $Lang->{'Create new quick-phone ticket'} = 'Neues Schnell-Telefon-Ticket erstellen';
    $Lang->{'Incident Solved At Once'}       = 'Störung Sofort Gelöst';
    $Lang->{'New Problem Candidate'}         = 'Neuer Problemkandidat';
    $Lang->{'Create new ticket from predefined template.'} =
        'Neues Ticket aus einer Vorlage erstellen.';
    $Lang->{'Module Registration for TicketTemplate Base Module.'}
        = 'Modulregistrierung für das Ticketvorlagen Basismodul.';
    $Lang->{'TicketTemplate Base Module'} = 'Ticketvorlagen Basismodul';

    # ticket template configurator
    $Lang->{'Save template'}                  = 'Vorlage speichern';
    $Lang->{'Save new quick ticket template'} = 'Neue Ticket-Vorlage speichern';
    $Lang->{'Save changes'}                   = 'Änderungen speichern';
    $Lang->{'Change template'}                = 'Vorlage ändern';
    $Lang->{'Save changes for this quick ticket template'} =
        'Änderungen für diese Ticket-Vorlage speichern';
    $Lang->{'Attachments cannot be part of a quick ticket template'}
        = 'Ticket-Vorlagen können keine Anhänge beinhalten';
    $Lang->{'Create/Change quickticket templates'} = 'Ticket-Vorlagen erstellen/ändern';
    $Lang->{'Ticket-Template configurator'}        = 'Ticket-Vorlagen-Konfigurator';
    $Lang->{'Start creating a new ticket template'}
        = 'Eine neue Ticket-Vorlagen anlegen';
    $Lang->{'Name for new ticket template'} = 'Name der neuen Ticket-Vorlage';
    $Lang->{'Delete selected ticket template and its configuration'}
        = 'Ausgewählte Ticket-Vorlagen und zugehörige Konfiguration löschen';
    $Lang->{'Are you sure you want to delete this template and its configuration?'}
        = 'Sind Sie sicher, dass Sie diese Vorlage und die zugehörige Konfiguration löschen möchten?';
    $Lang->{'Top of page'} = 'Zum Anfang der Seite';

    # ticket search and ticket search template extensions
    $Lang->{'Ticket Pending Time (before/after)'}    = 'Ticket-Wartezeit (vor/nach)';
    $Lang->{'Ticket Pending Time (between)'}         = 'Ticket-Wartezeit (zwischen)';
    $Lang->{'Ticket Escalation Time (before/after)'} = 'Ticket-Eskalationszeit (vor/nach)';
    $Lang->{'Ticket Escalation Time (between)'}      = 'Ticket-Eskalationszeit (zwischen)';
    $Lang->{'Name for new search template'}          = 'Name der neuen Suchvorlage';
    $Lang->{'Share this new template with all agents'}
        = 'Neue Suchvorlage allen Agenten zur Verfügung stellen';
    $Lang->{'Assign to agents'}                     = 'Allen Agenten zuweisen';
    $Lang->{'Start creating a new search template'} = 'Eine neue Suchvorlage anlegen';
    $Lang->{'Show template as queue'}               = 'Suchvorlage als virtuelle Queue anzeigen';
    $Lang->{'Show the search result as a virtual queue in the queue view'} =
        'Suchergebnis als virtuelle Queue in der Queue-Ansicht anzeigen';
    $Lang->{'Share this new template with other agents'}
        = 'Diese Suchvorlage mit anderen Agenten teilen.';
    $Lang->{'Escalation Destination Date'} = 'Eskalationszeitpunkt';
    $Lang->{'Escalation Destination In'}   = 'Eskalationszeit';

    # dashboard translations...
    $Lang->{'FAQ News'}                  = 'FAQ - Neuigkeiten';
    $Lang->{'14 Day Stats'}              = '14 Tage-Statistik';
    $Lang->{'1 Month Stats'}             = '1 Monat-Statistik';
    $Lang->{'Closed last week'}          = 'Geschlossen letzte Woche';
    $Lang->{'Created last week'}         = 'Erstellt letzte Woche';
    $Lang->{'Closed last month'}         = 'Geschlossen letzten Monat';
    $Lang->{'Created last month'}        = 'Erstellt letzten Monat';
    $Lang->{'Time of ticket creation'}   = 'Zeitpunkt der Ticket-Erstellung';
    $Lang->{'Time of ticket escalation'} = 'Zeitpunkt der Ticket-Eskalation';
    $Lang->{'no information for this ticket type available'}
        = 'keine Zusatzinformation für diesen Ticket-Typ verfügbar';
    $Lang->{'News about KIX4OTRS releases!'} = 'Neuigkeiten zu KIX4OTRS!';
    $Lang->{'Ticket Count Overview'}         = 'Ticketanzahlen';
    $Lang->{'Statetype'}                     = 'Statustyp';
    $Lang->{'Show Column Total'}             = 'Spaltensumme';
    $Lang->{'Show Row Total'}                = 'Zeilesumme';
    $Lang->{'StateTypes'}                    = 'Statustypen';
    $Lang->{'Row'}                           = 'Zeile';
    $Lang->{'Column'}                        = 'Spalte';

    # customer dashboard...
    $Lang->{'View all information for a selected customer'}
        = 'Alle Information zu einen ausgewählten Kunden einsehen';
    $Lang->{'Search for Customer'} = 'Kunden-Auswahl';
    $Lang->{'Search input'}        = 'Such-Eingabe';
    $Lang->{'Create new ticket'}   = 'Neues Ticket erstellen';
    $Lang->{'Create Phone Ticket'} = 'Telefon-Ticket erstellen';
    $Lang->{'Create Email Ticket'} = 'Email-Ticket erstellen';
    $Lang->{'Create a new phone or new email ticket for the selected customer.'} =
        'Neues Telefon- oder Email-Ticket für den ausgewählten Kundennutzer erstellen.';
    $Lang->{'Shows all assigned services for the selected customer.'}
        = 'Zeigt alle zugeordneten Services für den ausgewählten Kundennutzer.';
    $Lang->{'Assigned Services'}    = 'Zugeordnete Services';
    $Lang->{'Shown Services'}       = 'Gezeigte Services';
    $Lang->{'Max. table height'}    = 'Max. Tabellenhöhe';
    $Lang->{'No serivces assigned'} = 'Es sind keine Services zugeordnet';
    $Lang->{'Search for the customer, whose data should be shown in other dashboard plugins.'}
        = 'Suche nach Kunden, deren Daten in anderen Dashboard-Plugins angezeigt werden soll.';
    $Lang->{'Please select a customer first!'} = 'Bitte wählen Sie zuerst einen Kunden aus!';
    $Lang->{'Customer company'}                = 'Kunden-Firma';
    $Lang->{'Customer Companies'}              = 'Kunden-Firmen';
    $Lang->{'Create and manage companies.'}    = 'Unternehmen erzeugen und verwalten.';
    $Lang->{'Link customers to services.'}     = 'Kunden zu Services zuordnen.';
    $Lang->{'Customer Company Information'} = 'Kundenfirmeninformation';
    $Lang->{'Further Information'} = 'Weitere Informationen';

    # CustomerTicketCustomerIDSelection
    $Lang->{'New Customer Ticket'}        = 'Neues Kundenticket';
    $Lang->{'Create new customer ticket'} = 'Neues Kundenticket erstellen';
    $Lang->{'Selection'}                  = 'Auswahl';
    $Lang->{'Assigned customer IDs'}      = 'Zugeordnete Kundennummern';
    $Lang->{'Selected customer ID'}       = 'Ausgewählte Kundennummer';
    $Lang->{'Select customer ID: %s'}     = 'Auswahl der Kundennummer: %s';
    $Lang->{'Select customer ID for this ticket: %s'} =
        'Folgende Kundennummer für dieses Ticket verwenden: %s';
    $Lang->{'Proceed'} = 'Fortfahren';
    $Lang->{'Proceed with ticket creation for the selected customer ID'}
        = 'Fortfahren mit der Ticket-Erstellung für die ausgewählten KundenID';
    $Lang->{'Please select the customer ID to which your request is related'}
        = 'Bitte wählen Sie die Kundennummer aus, auf die sich Ihre Anfrage bezieht';

    # queue/service tree view extensions
    $Lang->{'Change Service'}               = 'Service ändern';
    $Lang->{'Queue-Tree'}                   = 'Queue-Baum';
    $Lang->{'Service-Tree'}                   = 'Service-Baum';
    $Lang->{'Hide or show queue selection'} = 'Queue-Auswahl zeigen oder verstecken';
    $Lang->{'Hide or show service selection'} = 'Service-Auswahl zeigen oder verstecken';
    $Lang->{'Expand All'}                   = 'Alle aufklappen';
    $Lang->{'Collapse All'}                 = 'Alle zuklappen';
    $Lang->{'Queue view - layout'}          = '"Ansicht nach Queues" - Layout';
    $Lang->{'Service view - layout'}          = '"Ansicht nach Services" - Layout';
    $Lang->{'Select queue view layout.'}    = 'Layout der "Ansicht nach Queues" auswählen.';
    $Lang->{'Select service view layout.'}    = 'Layout der "Ansicht nach Services" auswählen.';
    $Lang->{'Layout style'}                 = 'Layout-Stil';
    $Lang->{'Queue view - show all tickets'}
        = '"Ansicht nach Queues" - Alle Tickets anzeigen';
    $Lang->{'Service view - show all tickets'}
        = '"Ansicht nach Services" - Alle Tickets anzeigen';
    $Lang->{'View All Tickets'} = 'Alle Tickets anzeigen';
    $Lang->{'Choose weather to show all (locked and unlocked) tickets in queueview.'} =
        'Auswahl, ob alle (gesperrte und entsperrte) Tickets in der "Ansicht nach Queues" angezeigt werden sollen';
    $Lang->{'Choose whether to show all (locked and unlocked) tickets in service view.'} =
        'Auswahl, ob alle (gesperrte und entsperrte) Tickets in der "Ansicht nach Queues" angezeigt werden sollen';
    $Lang->{'Display mode'}                      = 'Anzeige-Art';
    $Lang->{'All (locked and unlocked) tickets'} = 'Alle Tickets (entsperrte und gesperrte)';
    $Lang->{'Unlocked tickets only'}             = 'Nur entsperrte Tickets';
    $Lang->{'Column Settings'}                   = 'Spalteneinstellungen';
    $Lang->{'Possible Columns'}                  = 'Verfügbare Spalten';
    $Lang->{'Selected Columns'}                  = 'Gewählte Spalten';
    $Lang->{'FromTitle'}                         = 'Von / Titel (Letzter Kundenbetreff)';
    $Lang->{'My Tickets (all)'} = 'Meine Tickets (alle)';
    $Lang->{'My Tickets (open)'} = 'Meine Tickets (offen)';
    $Lang->{'Tickets unlocked'} = 'Entsperrte Tickets';

    # out of office substitute
    $Lang->{'Substitute'}      = 'Vertreter';
    $Lang->{'Substitute note'} = 'Vertreterhinweis';

    # KIX4OTRS_PreferencesExtensions.xml
    $Lang->{'My Removable Article Flags'} = 'Meine entfernbaren Artikelmarkierungen';
    $Lang->{'Select article flags which should be removed after ticket close.'}
        = 'Wählen Sie Artikelmarkierungen aus, die beim Schließen des Tickets entfernt werden sollen';
    $Lang->{
        'Defines the use preference to select article flags which could be removed after ticket close.'
        }
        = 'Legt die Nutzereinstellung fest, mit welcher die Artikelmarkierungen gewählt werden können, die beim Schließen des Tickets entfernt werden';
    $Lang->{'Frontend module registration for the SearchProfileAJAXHandler.'}
        = 'Frontend-Modulregistrierung für SearchProfileAJAXHandler.';
    $Lang->{
        'Select search profiles from other agents. They are sorted by category and could be copied or subscribed.'
        }
        = 'Auswahl von Suchprofilen anderer Agenten. Diese sind nach Kategorien sortiert und können kopiert oder abonniert werden.';
    $Lang->{'Defines the use preference, to select search profiles from other agents.'}
        = 'Legt die Nutzereinstellung fest, mit welcher Suchprofile anderer Agenten ausgewählt werden können.';
    $Lang->{'Defines the user preference to select the queue move selection style.'}
        = 'Legt die Nutzereinstellung fest, mit welcher das Aussehen der Queueauswahl geändert werden kann.';
    $Lang->{'Parameters for the Out Of Office Substitute object in the preference view.'}
        = 'Parameter für die Abwesenheitsvertretung in den Nutzereinstellungen.';
    $Lang->{'Out Of Office Substitute'} = 'Abwesenheitsvertretung';
    $Lang->{'Select your out of office substitute.'}
        = 'Waehlen Sie fuer Ihre Abwesenheit eine Vertretung aus.';
    $Lang->{'Removable Article Flag'} = 'Entfernbare Artikelmarkierungen';
    $Lang->{
        'Defines the user preference, to auto-subscribe search profiles from other agents depending on selected categories.'
        }
        = 'Legt die Nutzereinstellung fest, mit welcher Suchprofile automatisch abonniert werden können in Abhängigkeit von der gewählten Kategorie.';
    $Lang->{'My Auto-subscribe Search Profile Categories'}
        = 'Meine automatisch abonnierten Suchprofilkategorien';
    $Lang->{'Auto-subscribe search profiles from other agents depending on selected categories.'}
        = 'Automatisches Abonnieren von Suchprofilen anderer Agenten auf der Grundlage von gewählten Kategorien.';

    # OTRS - changed translations
    $Lang->{'Article(s)'}    = 'Artikel';
    $Lang->{'Your language'} = 'Ihre bevorzugte Sprache';
    $Lang->{'Search Result'} = 'Suchergebnisse';
    $Lang->{'Linked as'}     = 'Verknüpft als';

    # KIX4OTRS_ServiceQueueAssignment.xml
    $Lang->{
        'Registration of service attribute AssignedQueueID which is used for automatic queue updates upon service updates.'
        } =
        'Registrierung des Service-Attributes AssignedQueueID, welches für die automatische Queue-Änderung bei Service-Updates genutzt wird.';
    $Lang->{'Assign a preferred queue to this service'} =
        'Diesem Service eine bevorzugte Queue zuweisen.';

    # KIX4OTRS_Ticket.xml
    $Lang->{'Shows all owners and responsibles in selecetions.'} =
        'Legt die Anzeige aller Besitzer und Verantwortlichen als Standard fest.';
    $Lang->{'Default body for a forwarded email.'} =
        'Standardinhalt für eine weitergeleitete Email.';
    $Lang->{'Sets the search paramater for the ticket count in customer info block.'} =
        'Festlegung, welches Attribut für die Anzeige der Ticketanzahl in den Kundendaten genutzt werden soll.';
    $Lang->{
        'Overloads (redefines) existing functions in Kernel::System::Ticket. Used to easily add customizations.'
        }
        = 'Überschreibt (redefiniert) bestehende Funktionen in Kernel::System::Ticket. Dies vereinfacht das Hinzufügen von Anpassungen.';
    $Lang->{
        'Defines whether results of possible actions of multiple ACLs are subsumed, thus allowing a more modular approach to ACLS (OTRS-default behavior is disabled).'
        }
        = 'Definiert ob die "Possible"-Ergebnisse für Aktionen mehrerer ACLs subsummiert werden. Dadurch wird ein modularer Ansatz für ACLs ermoeglicht (OTRS-Standardverhalten ist deakviert).';
    $Lang->{
        'Defines whether results of PossibleNot for tickets of multiple ACLs are subsumed, thus allowing a more modular approach to ACLS (OTRS-default behavior is disabled).'
        }
        = 'Definiert ob die "PossibleNot"-Ergebnisse für Ticket-Eigenschaften mehrerer ACLs subsummiert werden. Dadurch wird ein modularer Ansatz für ACLs ermoeglicht (OTRS-Standardverhalten ist deakviert).';
    $Lang->{
        'Determines the next possible ticket states, after the creation of a new phone ticket in the agent interface.'
        }
        = 'Legt den naechsten moeglich Ticketstatus nach dem Erzeugen einens Telfontickets im Agentenfrontend fest.';
    $Lang->{'Sets the default link type of splitted tickets in the agent interface.'}
        = 'Setzt einen Standard-Linktyp für geteilte Tickets im Agentenfrontend.';
    $Lang->{
        'Shows a link in the menu that allows linking a ticket with another object in the ticket zoom view of the agent interface.'
        }
        = 'Zeigt eine Verknuepfung in der TicketZoomView an, die es ermoeglicht ein Ticket mit einem anderen Objekt zu verknuepfen.';
    $Lang->{
        'Shows a link in the menu that allows merging tickets in the ticket zoom view of the agent interface.'
        }
        = 'Zeigt eine Verknuepfung in der TicketZoomView an, die es ermoeglicht ein Ticket mit einem anderen zusammenzufuegen.';
    $Lang->{
        'Shows a link in the menu to see the priority of a ticket in the ticket zoom view of the agent interface.'
        }
        = 'Zeigt eine Verknuepfung in der TicketZoomView an, die es ermoeglicht die Prioritaet eines Tickets zu sehen.';
    $Lang->{
        'Enable a smart style for time inputs (SysConfig-option TimeInputFormat will be ignored)'
        }
        = 'Aktivieren einer smarten Darstellung für die Zeiteingabe (die SysConfig-Option TimeInputFormat werden ignoriert)';
    $Lang->{
        'Enable a smart style for date inputs (SysConfig-option TimeInputFormat will be ignored)'
        }
        = 'Aktivieren einer smarten Darstellung für die Datumseingabe (die SysConfig-Option DateInputFormat werden ignoriert)';
    $Lang->{'Set interval for minute in time selections. Hash key is template file regex, value is time interval from 1 to 60. '}
        = 'Festlegung des Intervalls für Minuten in den Zeitauswahlen. Der Hash-Key enthält die RegEx für die Template-File, der Hash-Wert ist das Minuten-Intervall mit Werten von 1 bis 60.';
    $Lang->{
        'Infostring that will be used to show customer data if no specific infostring is defined in customer data backends.'
        }
        = 'Der Infostring, der fuer die Anzeige der Kundendaten genutzt wird, wenn keine spezifische Darstellung in den Kundendaten-Backends definiert ist.';
    $Lang->{
        'Autocomplete search attributes for ticket id, comma-eparated.'
        }
        = 'Autocomplete Suchattribute für die TicketID, kommagetrennt.';
    $Lang->{
        'Configures which dynamic fields were disabled depending on used frontend module, attributes like service, type, state or priority and its value. The key is composed like FrontendModule:::Attribute::Value. The key should contain the names of the disabled fields using regular expressions. If dynamic fields should be hidden on empty values, use EMPTY like FrontendModule:::Attribute::EMPTY.'
        }
        = 'Legt fest, welche Dynamischen Felder ausgeblendet werden sollen abhängig vom genutzten Frontendmodul, Attributen wie Service, Typ, Status oder Priorität und ihrem jeweiligen Wert. Der Schlüssel besteht dabei aus Frontendmodul:::Attribut:::Wert und Wert aus den zu verbergenden Dynamischen Felder. Diese können als RegExp angegeben werden. Falls Dynamische Felder bei leeren Werten ausgeblendet werden sollen, muss EMPTY in dieser Form genutzt werden: FrontendModule:::Attribute::EMPTY';
    $Lang->{
        'Defines how many chars should be shown for dynamic fields in ticket info sidebar. Disable this key to show all chars.'
        }
        = 'Legt fest, wie viele Zeichen für den Wert eines Dynamischen Feldes in der TicketInfo Sidebar angezeigt werden sollen. Um keine Einschränkungen vorzunehmen, kann der SysConfig-Schlüssel deaktiviert werden.';

    # KIX4OTRS_QuickTicket.xml
    $Lang->{
        'Frontend module registration for the Quickticket via AgentTicketPhone object in the agent interface.'
        }
        = 'Frontendmodul-Registration des Quickticket-via-AgentTicketPhone-Objekts im Agent-Interface.';
    $Lang->{
        'Defines the quickticket customer. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Kunden. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket ticket type. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Tickettyp. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket queue. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Queue. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket service. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Service. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket SLA. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-SLA. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket user (user must sign up for configured queue). Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Besitzer (Nutzer muss diese Queue als Meine-Queue markiert haben). Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket responsible (user must sign up for configured queue). Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Verantwortlichen (Nutzer muss diese Queue als Meine-Queue markiert haben). Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket article subject. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Artikelbetreff (und somit Tickettitel). Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket article body (only one line). Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Artikelinhalt (nur einzeilig). Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket ticket state. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Ticketstatus. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket pending time (in minutes). Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert die Quickticket-Wartezeit (in Minuten). Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket priority. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Prioritaet. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines the quickticket freekey. Key must be the value of param DefaultSet in object registration followed by double-colon and desired freetext index.'
        }
        = 'Definiert den Quickticket-Freitextschluessel. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung  gefolgt von Doppel-Doppelpunkt und gewuenschtem Freitextindex verwendet werden.';
    $Lang->{
        'Defines the quickticket freetext. Key must be the value of param DefaultSet in object registration followed by double-colon and desired freetext index.'
        }
        = 'Definiert den Quickticket-Freitextwert. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung  gefolgt von Doppel-Doppelpunkt und gewuenschtem Freitextindex verwendet werden.';
    $Lang->{
        'Defines the quickticket time accounting value. Key must be the value of param DefaultSet in object registration.'
        }
        = 'Definiert den Quickticket-Zeitaufwand. Als Schluessel muss der Wert des Parameters DefaultSet in der Objektregistirerung verwendet werden.';
    $Lang->{
        'Defines link direction for quickticket templates - possible: Source or Target. Link will not be created, if there is no split action.'
        }
        = 'Definiert die Verlinksrichtung bei Quickticket-Vorlagen - möglich: Source oder Target. Ein Link wird nur angelegt, falls eine Split-Aktion vorausgeht.';
    $Lang->{
        'Defines link type for quickticket templates. Link will not be created, if there is no split action.'
        }
        = 'Definiert die Verlinksart bei Quickticket-Vorlagen. Ein Link wird nur angelegt, falls eine Split-Aktion vorausgeht.';
    $Lang->{
        'Create new phone ticket from "default user support"-template'
        }
        = 'Erstellt neues Telefonticket von der Vorlage "default user support"';
    $Lang->{'Defines whether the ticket type should be translated in the selection box.'} = 'Definiert, ob der Tickettyp in der Auswahlbox übersetzt wird.';

    # KIX4OTRS_PersonTicket.xml
    $Lang->{'This setting defines the link type \'Person\'.'} = 'Definiert den Linktyp \'Person\'.';
    $Lang->{
        'This setting defines that a \'Ticket\' object can be linked with persons using the \'Person\' link type.'
        }
        = 'Definiert, dass ein \'Ticket\'-Objekt mit dem Linktyp \'Person\' mit Personen verlinkt werden kann.';
    $Lang->{'suspended'} = 'ausgesetzt';
    $Lang->{'Escalation suspended due to ticket state'}
        = 'Die Lösungszeit wurde abhängig vom Ticketstatus ausgesetzt.';

    # EO KIX4OTRS_PersonTicket.xml
    # KIX4OTRS_SLADisabled.xml
    $Lang->{'Defines MethodName.'} = 'Defines Methodenname.';
    $Lang->{
        'Defines state names for which the SLA time is disabled. Is a ticket set to on of these states, the SLA-destination times are set to hold. The time a ticket stays in this state is not SLA-relevant.'
        }
        = 'Definiert Statusnamen für die SLA-Zeiten ausgesetzt werden. Wird ein Ticket in einen dieser Status gesetzt, wird die SLA-Zielberechnung ausgesetzt. Die Dauer die ein Ticket in diesen Status verbringt, wird nicht auf SLA-Erfuellungszeiten angerechnet.';
    $Lang->{'Defines ticket type names for which the SLA calulation time is disabled.'}
        = 'Definiert Tickettypen für die keine SLA-Zeiten berechnet werden.';
    $Lang->{
        'Additional and extended ticket methods which may overwrite original ticket methods (but not methods in Kernel::System::Ticket).'
        }
        = 'Zusaetzliche und erweiterte Ticket-Methoden die Original-methoden ueberschreiben koennen (ausser Methoden in Kernel::System::Ticket).';

    # EO KIX4OTRS_SLADisabled.xml
    # KIX4OTRS_Defaults.xml
    $Lang->{'The identifier for a ticket, e.g. Ticket#, Call#, MyTicket#. The default is Ticket#.'}
        = 'Ticket-Identifikator, z. B. Ticket#,Call#, MyTicket#. Als Standard wird Ticket# verwendet.';
    $Lang->{'Parameters for the FollowUpNotify object in the preference view.'}
        = 'Parameter für das FollowUpNotify-Objekt in der Ansicht für die Einstellungen.';
    $Lang->{
        'Select your TicketStorageModule to safe the attachments of articles. "DB" stores all data in the database. Don\'t use this module if big attachments will be stored. "FS" stores the data in the filesystem. This is faster but webserver user should be the otrs user. You can switch between the modules even on a running system without any loss of data.'
        }
        = 'Wählen Sie das TicketStorage-Modul aus und legen sie fest, wie die Anhänge zu Artikeln gespeichert werden sollen. "DB" speichert alle Daten in der Datenbank. Wird nur mit kleinen Anhängen gearbeitet, ist das kein Problem. "FS" legt die Daten im Filesystem ab, der Zugriff ist schneller. Allerdings sollte bei Verwendung von "FS" der WEB-Server unter dem selben Benutzer laufen, der auch für OTRS verwendet wird. Sie können das Modul auch für laufende Systeme ändern, es wird trotzdem weiter auf alle Daten zugegriffen und auch die Daten, die mit Hilfe des anderen Moduls gespeichert wurden, bleiben verfügbar.';
    $Lang->{
        'Would you like to execute followup checks on In-Reply-To or References headers for mails, that don\'t have a ticket number in the subject?'
        }
        = 'Sollen auf die Header-Einträge für In-Reply-To und References-Header Follow-up- Checks ausgeführt werden, wenn im Betreff einer Mail keine Ticketnummer angegeben ist?';
    $Lang->{
        'Would you like to execute followup checks in mail body, that don\'t have a ticket number in the subject?'
        }
        = 'Sollen in den Email-Body Follow-up- Checks ausgeführt werden, wenn im Betreff einer Mail keine Ticketnummer angegeben ist?';
    $Lang->{
        'Would you like to execute followup checks in mail plain/raw, that don\'t have a ticket number in the subject?'
        }
        = 'Sollen in den Email-Plain/Raw Follow-up- Checks ausgeführt werden, wenn im Betreff einer Mail keine Ticketnummer angegeben ist?';
    $Lang->{'The postmaster default queue.'} = 'Postmaster default Queue.';
    $Lang->{'Enable ticket responsible feature.'}
        = 'Aktivieren des Ticket-Verantwortlichkeits-Features.';

    # KIX4OTRS_Escalation.xml
    $Lang->{'Disables response time SLA, if the newly created ticket is a phone ticket.'}
        = 'Deaktiviert Antwortzeit-SLA wenn Ticket ein Telefonticket ist.';
    $Lang->{'Restricts the ResponsetimeSetByPhoneTicket to these ticket types.'}
        = 'Beschränkt die ResponsetimeSetByPhoneTicket auf diese Tickettypen.';
    $Lang->{
        'Defines state names for which the SLA time is disabled. Is a ticket set to on of these states, the SLA-destination times are set to hold. The time a ticket stays in this state is not SLA-relevant.'
        }
        = 'Definiert Statusnamen für die SLA-Zeiten ausgesetzt werden. Wird ein Ticket in einen dieser Status gesetzt, wird die SLA-Zielberechnung ausgesetzt. Die Dauer die ein Ticket in diesen Status verbringt, wird nicht auf SLA-Erfuellungszeiten angerechnet.';
    $Lang->{'List of JS files to always be loaded for the agent interface.'}
        = 'Liste von JS-Dateien, die immer im Agenten-Interface geladen werden.';
    $Lang->{
        'Defines a dynamic field of type date/time which is used as start time for solution SLA-computation rather than ticket creation time, thus allowing to start SLA-countdown with begin of customer desired times. "Index" is only fallback for old configuration upgraded from OTRS 3.1 or previous to be workable. In this case dynamic field named TicketFreeTime"Index" is used.'
        }
        = 'Definiert ein Dynamisches Feld vom Typ Datum/Zeit welches anstelle des Ticketerstellzeitpunktes als SLA-Startzeitpunkt für die Lösungszielzeit genutzt wird. Somit kann die SLA-Zeit erst ab dem Kundenwunschtermin starten. "Index" ist nur ein Fallback, um ältere Konfigurationen, welche von OTRS 3.1 oder älter angehoben wurden, funktionstüchtig zu halten. In diesem Falle wird ein Dynamisches Feld mit dem Namen TicketFreeTime"Index" genutzt.';
    $Lang->{'Disables response time SLA, if an auto reply was sent for this ticket.'} = '';
    $Lang->{'Restricts the ResponsetimeSetByAutoReply to these ticket types.'}        = '';
    $Lang->{'Defines queue names for which the SLA calulation time is disabled.'}     = '';

    # EO KIX4OTRS_Escalation.xml

    # KIX4OTRS_FrontendTicketRestrictions.xml
    $Lang->{'Ticket-ACL to restrict some ticket data selections based on current ticket data.'}
        = 'Ticket-ACL, um bestimmte Auswahlmöglichkeiten basierend auf den aktuellen Ticketdaten zu verbieten.';
    $Lang->{
        'Registers an identifier for the ticket restrictions. Value is used in the following config options.'
        }
        = 'Registriert einen Bezeichner für die TicketDataRestrictions. Der Wert wird für die folgenden Konfigurationsoptionen benötigt.';
    $Lang->{
        'Defines which ticket actions have to be restricted (agent and customer frontend is possible). Key has to be one of the identifier (see above). Value defines restricted ticket actions and has to be filled at any time. Multiple actions can be seperated by ;.'
        }
        = 'Legt fest, welche Ticketaktionen eingeschränkt werden sollen (Agenten- und Kundenfrontend möglich). Der Schlüssel muss einer der Bezeichner (siehe oben) sein.';
    $Lang->{
        'Defines ticket match properties (e.g. type:::default). Key has to be one of the identifier (see above). Value defines matching ticket data type and its values, separated by :::. Multiple values can be seperated by ;. Split multiple match criteria by |||. Leave it empty for always matching.'
        }
        = 'Legt die Eigenschaften fest, auf die geprüft werden soll (z.B. type:::default). Der Schlüssel muss einer der Bezeichner (siehe oben) sein. Die Werte legen die Daten fest, auf die geprüft werden soll, getrennt durch :::. Mehrfache Werte können durch ; getrennt werden. Mehrfache Prüfkritierien durch |||. Wird das Feld leer gelassen, passt der Wert immer.';

    $Lang->{
        'Registers additional information for the ticket excluded data restrictions. Use it like the old configuration above.'
        }
        = 'Registriert ergänzende Informationen für die ExcludedDataRestrictions. Genutzt werden kann dies wie die bisherige Konfiguration, siehe oben.';

    $Lang->{
        'Allows overriding of Data character limits, hard coded in TTs. The key has the following format: &lt;TemplateFilePattern&gt;::(&lt;VariableNamePattern&gt;), the value is the numeric character limit that should be used. You can use RegEx.'
        }
        = 'Ermöglicht das Überschreiben von Data-Zeichenlimits, die in TTs fest eingetragen sind. Der Schlüssel hat das folgende Format: <TemplateFilePattern>::<VariableNamePattern>, der Wert ist das zu verwendende nummerische Zeichenlimit. RegEx kann genutzt werden.';
    $Lang->{'Replaces the default Data character limits.'} = 'Überschreibt die Standard-Data-Zeichenlimits.';

    # KIX4OTRS_CustomerDashboard.xml
    $Lang->{'Pending Tickets'}      = 'Wartende Tickets';
    $Lang->{'All pending tickets.'} = 'Alle wartenden Tickets.';

    # EO KIX4OTRS_CustomerDashboard.xml

    # KIX4OTRS_TicketStateWorkflow.xml
    $Lang->{'no state update possible - no common next states'} =
        'kein Statuswechsel möglich - keine gemeinsamen Folgestatus';
    $Lang->{'Ticket-ACLs to define the following possible state.'}
        = 'Ticket-ACLs zur Definition der moeglichen Folgestatus.';
    $Lang->{
        'Settings for TicketStateWorkflow to define the following possible state. States have to be comma separated. placeholders are _ANY_ , _PREVIOUS_ and _NONE_.'
        }
        = 'Einstellungen für den Ticketstatusworkflow, zur Definition der moeglichen Folgestatus. Status werden kommasepariert aufgelistet. Als Platzhalter dienen _ANY_ , _PREVIOUS_ und _NONE_.';
    $Lang->{'Settings for Default TicketState to define the following possible state.'}
        = 'Einstellungen für den DefaultTicketstatus, zur Definition der moeglichen Folgestatus.';
    $Lang->{'Settings for DefaultTicket-Queue.'} = 'Einstellungen für die Standard-Queue.';
    $Lang->{'Sets default ticket type in AgentTicketPhone and AgentTicketEmail.'}
        = 'Setzt den Standard-Tickettyp in AgentTicketPhone und AgentTicketEmail.';
    $Lang->{'Sets default queue in AgentTicketPhone and AgentTicketEmail.'}
        = 'Setzt die Standard-Queue in AgentTicketPhone und AgentTicketEmail.';
    $Lang->{
        'Ticket event module to force a new ticket state after lock action. As key you have to define the ticket type + ":::" + current state and the next state as content after lock action.'
        }
        = 'Ticket Event Modul für automatisches Setzen eines neuen Ticketstatus nach dem das Ticket gesperrt wurde. Der Schlüssel ist der Tickettyp + ":::" + aktueller Status, der Inhalt der Status nach dem Sperren.';
    $Lang->{'Updates ticket state if configured or required after type update.'}
        = 'Aktualisiert Ticketstatus sofern konfiguriert oder notwendig nach Aenderung des Tickettyps.';
    $Lang->{
        'Set a true-value for key (ticket type) if a type update forces a state update to the default state. The update is done whenever the original ticket state does not appear in the new ticket types workflow definition.'
        }
        = 'Setzen Sie einen True-Wert für den Schluessel (Tickettyp), falls eine Tickettypaenderung einen Statuswechsel in den Standardstatus erzwingen soll. Die Aktualisierung wird immer durchgefuehrt wenn der aktuelle Ticketstatus nicht in der Workflowdefinition des neuen Tickettyps vorhanden ist.';
    $Lang->{
        'The state if a ticket got a follow-up (use _PREVIOUS_ as placeholder for the very last state in ticket history before current).'
        }
        = 'Status für ein Ticket, für das ein Follow-up eintrifft (nutzen Sie _PREVIOUS_ als Platzhalter für den letzten Status in der Tickethistorie vor dem aktuellen).';
    $Lang->{
        'Checks if the sender of a follow-up message is contained in customer database an has an identical customer-ID as the ticket. If so, the email is considered as email-external, otherwise it is considered as email-internal. Default OTRS-behavior if disabled.'
        }
        = 'Prüft ob der Absender einer Nachricht als Kundennutzer hinterlegt ist und dieselbe Kunden-ID hat wie am Ticket hinterlegt ist. Ist dem so wird die Email als "email-external" betrachtet, andernfalls als "email-internal". Standard OTRS-Verhalten wenn deaktiviert.';
    $Lang->{
        'Checks if the sender of a follow-up message is contained in agent database, and if so sets sender type "agent".'
        }
        = 'Prüft ob der Absender einer Nachricht als Agent hinterlegt ist und setzt den SenderTyp "agent" wenn dem so ist.';
    $Lang->{'Moves ticket after state update.'} = 'Verschiebt Ticket nach Statusaktualisierung.';
    $Lang->{
        'Automatically sets the state named by value if the state named in key is reached. Key may be prefixed by a certain ticket type name for which this state transition is valid only.'
        }
        = 'Setzt automatisch den Status in Wert, sobald der Status in Schluessel erreicht wird. Im Schluessel kann ein Praefix des Tickettyps diesen Statuswechsel auf genau diesen Tickettyp einschraenken.';
    $Lang->{
        'If the automatically set state is a pending state, the pending offset time can be defined here (business minutes). Key must be the same as in NextStateSet.'
        }
        = 'Wenn der automatisch zu setzende Status ein warten-Status ist, kann hier die Wartezeit in Geschaeftsminuten definiert werden. Der Schluessel muss identisch zu dem entsprechenden Uebergang in NextStateSet sein.';
    $Lang->{
        'Define which State should be set automatically (Value) after pending time of State (Key) has been reached.'
        }
        = 'Definition welche Status automatisch gesetzt werden soll (Inhalt) nach dem erreichen des "Warten Zeit" (Schlüssel).';
    $Lang->{
        'Automatically moves ticket to configured queue if state is set - use of wildcards possible (e.g. &lt;OTRS_TicketDynamicField1&gt;).'
        }
        = 'Verschiebt Ticket automat. in konfigurierte Queue sobald der Status gesetzt wird - Verwendung von Platzhaltern möglich (z.B. &lt;OTRS_TicketDynamicField1&gt;).';
    $Lang->{
        'Choose to add a failure article to ticket, if target queue for automatic queue move does not exists.'
        }
        = 'Festlegung für eine Fehler-Notiz am Ticket, falls die Zielqueue für das automatsiche Verschieben nicht existiert.';
    $Lang->{'New ticket queue, if target queue for automatic queue move does not exists.'}
        = 'Gesetzte Ticket-Queue, falls die Zielqueue für das automatsiche Verschieben nicht existiert.';
    $Lang->{'New ticket state, if target state for automatic state change does not exists.'}
        = 'Gesetzter Ticket-Status, falls der Zielstatus für die automatische Änderung nicht existiert.';
    $Lang->{'Defines which state will unlock the ticket.'}
        = 'Definiert die Status die zum Freigeben des Tickets führen.';
    $Lang->{
        'Performs ticket update actions after state update - currently limited to state update.'
        }
        = 'Führt Ticketaktionen nach Statusaktualisierung durch - derzeit beschränkt auf Statuswechsel.';
    $Lang->{
        'Settings for Default TicketState to define the default following possible state un lock.'
        }
        = 'Einstellungen fuer den Ticketstatus, zur Definition des Default-Folgestatus nach dem Sperren.';
    $Lang->{
        'Settings for Default TicketState to define the default following possible state on unlock.'
        }
        = 'Einstellungen fuer den Ticketstatus, zur Definition des Default-Folgestatus nach dem Freigeben.';
    $Lang->{
        'Settings for TicketState to define the following possible state. States have to be comma separated.'
        }
        = 'Einstellungen fuer den nichtüberschreibbaren Ticketstatus, zur Definition der moeglichen Folgestatus. Status werden kommasepariert aufgelistet.';
    $Lang->{
        'Settings for TicketState to define the following possible state. States have to be comma separated.'
        }
        = 'Einstellungen fuer den nichtüberschreibbaren Ticketstatus, zur Definition der moeglichen Folgestatus. Status werden kommasepariert aufgelistet.';
    $Lang->{'Updates ticket state after unlock ticket based on selected ticket type.'}
        = 'Aktualisiert Ticketstatus nach Sperren / Entsperren basierend auf dem gesetzten Tickettyp.';
    $Lang->{'Defines Queue, TicketType and new State for TicketQueueMoveWorkflowState.'}
        = 'Definiert Queue, TicketType und den zu setzenden Folgestatus für TicketQueueMoveWorkflowState';
    $Lang->{'Updates ticket state if configured or required after queue move.'}
        = 'Aktualisiert den Ticket Status nach einem Queuewechsel.';
    $Lang->{'Defines Queue, TicketType and new TicketType for TicketQueueMoveWorkflowTickettype.'}
        = 'Definiert Queue, TicketType und den zu setzenden Folgetyp für TicketQueueMoveWorkflowTickettyp.';
    $Lang->{'Updates ticket type if configured or required after queue move.'}
        = 'Aktualisiert den Ticket Typ nach einem Queuewechsel.';
    $Lang->{
        'State update for closed tickets if a new article of type webrequest is created in customer interface.'
        }
        = 'Statusupdate für geschlossene Tickets wenn ein neuer Artikel vom Typ Webrequest in der Kundenoberfläche erstellt wird.';

    # EO KIX4OTRS_TicketStateWorkflow.xml

    # AgentArticleCopyMove
    $Lang->{'Copy/Move/Delete'}             = 'Kopieren/Verschieben/löschen';
    $Lang->{'of destination ticket'}        = 'des Zieltickets';
    $Lang->{'Copy, Move or Delete Article'} = 'Kopieren, Verschieben oder löschen eines Artikels';
    $Lang->{'Copy, move or delete selected article'} =
        'Kopieren, Verschieben oder löschen des ausgewählten Artikels';
    $Lang->{'Action to be performed'} = 'Auszuführende Aktion';
    $Lang->{'Copy'}                   = 'Kopieren';
    $Lang->{'You cannot asign more time units as in the source article!'} =
        'Sie können nicht mehr Zeiteinheiten zuweisen, als im Original-Artikel!';
    $Lang->{'Options for Copy'}            = 'Optionen zum Kopieren';
    $Lang->{'Options for Delete'}          = 'Optionen zum löschen';
    $Lang->{'Options for Move'}            = 'Optionen zum Verschieben';
    $Lang->{'Really delete this article?'} = 'Diesen Artikel wirklich löschen?';
    $Lang->{'Copied time units of the source article'} =
        'Zu übernehmende Zeiteinheiten des Original-Artikels';
    $Lang->{'Handling of accounted time from source article?'} =
        'Umgang mit Zeitbuchung am Original-Artikel?';
    $Lang->{'Change to residue'}   = 'Auf Rest verringern';
    $Lang->{'Leave unchanged'}     = 'Unverändert lassen';
    $Lang->{'Owner / Responsible'} = 'Besitzer / Verantwortlicher';
    $Lang->{'Change the ticket owner and responsible!'} =
        'Ändern des Ticket-Besitzers und -Verantwortlichen!';
    $Lang->{'Perhaps, you forgot to enter a ticket number!'} =
        'Bitte geben Sie eine Ticket-Nummer ein';
    $Lang->{'Sorry, no ticket found for ticket number: '} =
        'Es konnte kein Ticket gefunden werden für Ticket-Nummer: ';
    $Lang->{'Sorry, you need to be owner of the new ticket to do this action!'} =
        'Sie müssen der Besitzer des neuen Tickets sein, um diese Aktion auszuführen!';
    $Lang->{'Sorry, you need to be owner of the selected ticket to do this action!'} =
        'Sie müssen der Besitzer des ausgewählten Tickets sein, um diese Aktion auszuführen!';
    $Lang->{'Please contact your admin.'}     = 'Bitte kontaktieren Sie Ihren Administrator.';
    $Lang->{'Please change the owner first.'} = 'Bitte ändern Sie zunächst den Besitzer.';
    $Lang->{'Sorry, you are not a member of allowed groups!'} =
        'Bitte entschuldigen Sie, aber Sie nicht Mitglied der berechtigten Gruppen!';

    # EO AgentArticleCopyMove

    # Link person
    $Lang->{'Persons login'}                   = 'Personen-Login';
    $Lang->{'Persons attributes'}              = 'Personen-Attribute';
    $Lang->{'3rd party'}                       = 'Dritte';
    $Lang->{'3rdParty'}                        = 'Dritte';
    $Lang->{'Linked Persons'}                  = 'Verlinkte Personen';
    $Lang->{'Person Type'}                     = 'Personentyp';
    $Lang->{'Show or hide the linked persons'} = 'Verlinkte Personen zeigen oder verstecken';
    $Lang->{'Select this person to receive a copy of the new article via email'} =
        'Dieser Person eine Kopie des Artikels per Mail zu kommen lassen';
    $Lang->{'Add this person to list of recipients'}
        = 'Diese Person als Empfänger hinzufügen';
    $Lang->{'Click to view detailed informations for this persons'} =
        'Klicken um detaillierte Informationen zu dieser Person einzusehen';
    $Lang->{'Select frontend agent modules where linked persons are activated.'} =
        'Festlegung in welchen Agent-Frontend-Modulen die Verlinkten Personen aktiviert sind.';
    $Lang->{'Defines how the linked persons can be included in emails.'} =
        'Definiert die Arten wie Verlinkte Personen in Emails eingebunden werden können.';
    $Lang->{'Defines which person attributes are displayed in detail presentation.'} =
        'Definiert welche Personen-Attribute in der Detailansicht gezeigt werden.';
    $Lang->{'Defines which person attributes are displayed in complex link presentation.'}
        = 'Definiert welche Personen-Attribute in der komplexen Link-Ansicht gezeigt werden.';
    $Lang->{
        'Defines the column headers of the person attributes displayed in complex presentation.'
        }
        = 'Definiert die Spaltenüberschriften der Personen-Attribute, die in der komplexen Link-Ansicht gezeigt werden.';
    $Lang->{
        'Defines if linked persons of types "Customer" and "3rd Party" can be selected for notification of internal articles.'
        } =
        'Definiert, ob verlinkte Personen vom Typ "Kunde" oder "Dritte" für die Benachrichtigung bei internen Artikeln ausgewählt werden dürfen.';
    $Lang->{'PLEASE NOTE'} = 'BITTE BEACHTEN';
    $Lang->{
        'Persons of types "Customer" and "3rd Party" will not be notified when an internal article is created!'
        } =
        'Personen vom Typ "Kunde" und "Dritte" werden nicht benachrichtigt wenn ein interner Artikel erstellt wird.';
    $Lang->{'Person Information'} = 'Informationen zur Person';

    # EO Link person

    # KIX4OTRS_TicketZoom.xml
    $Lang->{'Module to show empty mail link in menu.'} =
        'Link zu der Erstellung einer leeren Email im Menue der Ticketansicht.';
    $Lang->{'Screen after ticket closure'} = 'Ansicht nach Ticket-Abschluss';
    $Lang->{'Defines which page is shown after a ticket has been closed.'} =
        'Definiert welche Ansicht aufgerufen, wird nach dem ein Ticket geschlossen wurde';
    $Lang->{'Redirect target'}             = 'Weiterleitungsziel';
    $Lang->{'Last screen overview'}        = 'Letzte Ticket-Übersicht';
    $Lang->{'Ticket zoom'}                 = 'Ticket-Inhalt';
    $Lang->{'Ticket Zoom - article handling'} =
        'Artikel-Verhalten in Ticket-Detailansicht';
    $Lang->{'Initially shown article in agent\'s ticket zoom mask.'} =
        'Inital angezeigter Artikel in der Ticket-Detailansicht der Agentenoberfläche';
    $Lang->{'Shown article'}         = 'Angezeigter Artikel';
    $Lang->{'First article'}         = 'Erster Artikel';
    $Lang->{'Last article'}          = 'Letzter Artikel';
    $Lang->{'Last customer article'} = 'Letzter Kunden-Artikel';
    $Lang->{'Defines which ticket data parameters are displayed in direct data presentation.'} =
        'Definiert welche Daten in der Direktdatenanzeige dargestellt werden.';
    $Lang->{'Frontend module registration for AgentArticleCopyMove.'} =
        'Frontendmodul-Registrierung von AgentArticleCopyMove.';
    $Lang->{'Defines email-actions allowed for article types.'} =
        'Definiert E-Mail-Aktionen für Artikeltypen.';

    # EO KIX4OTRS_TicketZoom.xml
    # KIX4OTRS_LinkObject.xml
    $Lang->{'Allows a search with empty search parameters in link object mask.'} =
        'Erlaubt Suche mit leeren Suchparametern in LinkObject-Maske.';
    $Lang->{
        'Frontend module registration for the AgentLinkObjectUtils.'
        }
        = 'Frontendmodul-Registration des Moduls AgentLinkObjectUtils.';

#$Lang->{'Defines possible search criteria in the agents link interface for target object "Ticket". Order is important. Value is used as internal name.'} = '';
#$Lang->{'Defines displayed name for configured search criteria. Key has to be one of the internal names (see above); Value is used as name in the interface.'} = '';
#$Lang->{'Defines data source for configured search criteria. Key has to be one of the internal names (see above); Value is used as name in the interface.'} = '';
# EO KIX4OTRS_LinkObject.xml
# KIX4OTRS_ResponsibleAutoSetPerTicketType.xml
    $Lang->{'Workflowmodule which sets the ticket responsible based on ticket type if not given.'} =
        'Workflowmodule welches auf den Ticketverantwortlichen auf Basis des Tickettyps setzt, sofern dieser noch nicht vorgegeben wurde.';
    $Lang->{
        'If ticket responsible feature is enabled, set automatically the owner as responsible on owner set.'
        } =
        'Wenn das Ticket-Verantwortlichkeits-Featues aktiviert ist, wird beim nicht gesetzten Verantwortlichen der Besitzer auch automatisch als Verantwortlich gesetzt.';

    #EO KIX4OTRS_ResponsibleAutoSetPerTicketType.xml
    $Lang->{'Preselect old ticket data in chosen ticket note functions'} =
        'Vorauswahl der vorherigen Ticket-Daten in den ausgewählten Ticket-Notiz-Funktionen';
    $Lang->{'Defines where it is possible to move a ticket into an other queue.'} =
        'Legt fest wo es möglich ist, ein Ticket in eine andere Queue zu verschieben.';

    # KIX4OTRS_FrontendMenuChanges.xml
    $Lang->{'Reporting'}            = 'Berichtswesen';
    $Lang->{'Default user support'} = 'Standard Anwenderunterstützung';
    $Lang->{''}                     = '';

    # KIX4OTRS_SysConfigChangeLog.xml
    $Lang->{
        'Logs the configuration changes of SysConfig options.'
        }
        = 'Loggt die Konfigurationsänderungen von SysConfig-Optionen.';
    $Lang->{
        'Log module for the SysConfig. "File" writes all messages in a given logfile, "SysLog" uses the syslog daemon of the system, e.g. syslogd.'
        }
        = 'Logmodul für die SysConfig. "File" schreibt in eine anzugebende Datei, "SysLog" logt mit Hilfe des systemspezifischen Logdaemons, z. B. syslogd.';
    $Lang->{
        'Set this config parameter to "Yes", if you want to add a suffix with the actual year and month to the SysConfig logfile. A logfile for every month will be created.'
        }
        = 'Wird dieser Konfigurationsparameter aktiviert, wird an das SysConfig Logfile eine Endung mit dem aktuellen Monat und Jahr angehängt und monatlich ein neues Logfile geschrieben.';

    # EO KIX4OTRS_SysConfigChangeLog.xml

    # KIXSidebar
    $Lang->{'Parameters for the KIXSidebar backend TextModules.'} =
        'Parameter für das KIXSidebar-Backend TextModules.';
    $Lang->{'Parameters for the KIXSidebar backend LinkedPersons.'} =
        'Parameter für das KIXSidebar-Backend LinkedPersons.';
    $Lang->{'Parameters for the KIXSidebar backend CustomerInfo.'} =
        'Parameter für das KIXSidebar-Backend CustomerInfo.';
    $Lang->{'Parameters for the KIXSidebar backend CustomizeForm.'} =
        'Parameter für das KIXSidebar-Backend CustomizeForm.';
    $Lang->{'Parameters for the KIXSidebar backend Scratchpad (Remarks).'} =
        'Parameter für das KIXSidebar-Backend Scratchpad (Bemerkungen)';
    $Lang->{'Parameters for the KIXSidebar backend TicketInfo.'} =
        'Parameter für das KIXSidebar-Backend TicketInfo.';
    $Lang->{'Show more information about this customer'} =
        "Zeige mehr Informationen über diesen Kunden";
    $Lang->{
        'Registers an identifier for the KIXSidebarTools. Value is used in the following config options.'
        } =
        "Registriert einen Indentifikator für die KIXSidebarTools. Der Wert wird für die folgende Konfiguration benötigt.";
    $Lang->{
        'Defines which ticket actions have to be used (agent and customer frontend is possible). Key has to be one of the identifier (see above). Value defines used ticket actions and has to be filled at any time. Multiple actions can be separated by ;.'
        } =
        "Definiert, welche Ticket-Actions betroffen sind (Agenten- und Kundenfrontend möglich). Der Schlüssel muss einer der zuvor definierten Identifikatoren sein (siehe oben). Die Werte definieren die genutzten Ticket-Actions und müssen ausgefüllt werden. Mehrfache Actions können durch ; getrennt werden.";
    $Lang->{
        'Defines connection data (e.g. Example:::Database). Key has to be one of the identifier (see above).'
        } =
        "Definiert die Verbindungsdaten (z.B. Example:::Database). Der Schlüssel muss einer der zuvor definierten Identifikatoren sein. (siehe oben)";
    $Lang->{'Defines for which actions the linked persons should be informed by email.'}
        = 'Legt fest, für welche Actions die verlinkten Personen per Mail informiert werden sollen.';
    $Lang->{'Behavior of KIXSidebar "ContactInfo" contact selection'}
        = 'Verhalten der Kontaktauswahl in der KIXSidebar "Kontaktinformation"';
    $Lang->{'Article Contacts'} = 'Artikelkontakte';
    $Lang->{'Defines parameters for user preference to set behavior of KIXSidebar contact selection.'} = 'Legt Parameter für die Nutzereinstellung fest, welche das Verhalten der Kontaktauswahl in der KIXSidebar "Kontaktinformation" festlegt.';
    $Lang->{'Select all dynamic fields that should be displayed.'} = 'Wählen Sie alle dynamischen Felder, die angezeigt werden sollen.';
    $Lang->{'Defines the default item state for new items. It should be one of the item states out of the list below.'} = 'Definiert den Standardstatus, der genutzt wird, wenn neue Items angelegt werden. Es sollte ein Item-Status aus der unten folgenden Liste sein.';
    $Lang->{'Defines all possible item states for the checklist sidebar. Key has to be unique and used for StateIcon list and StateStyle list below.'} = 'Definiert alle möglichen Item-Status für die Checkliste. Der Schlüssel muss eindeutig sein und wird für die unten folgenden Listen für Style und Icon mit genutzt.';
    $Lang->{'Module Registration for the KIXSidebarChecklist AJAXHandler.'} = 'Modulregistrierung für den KIXSidebarChecklist AJAXHandler.';
    $Lang->{'Defines the item state icons for the item states defined above.'} = 'Definiert die Icons für die oben definierten Item-Status.';
    $Lang->{'Defines the item state styles for the item states defined above. Use CSS-styles.'} = 'Definiert die Styles für die oben definierten Item-Status. CSS-Styles können genutzt werden.';
    $Lang->{'Defines all the ticket states in which the checklist cannot be changed.'} = 'Definiert alle Ticketstatus in denen die Checkliste nicht verändert werden kann.';
    $Lang->{'Defines all the ticket state types in which the checklist cannot be changed.'} = 'Definiert alle Ticketstatustypen in denen die Checkliste nicht verändert werden kann.';
    $Lang->{'Significant changes of item descriptions will cause state loss.'} = 'Signifikante Änderungen am Text der einzelnen Items führen zum Verlust des gesetzten Status.';
    $Lang->{'Checklist'} = 'Checkliste';
    $Lang->{'No checklist available.'} = 'Keine Checkliste vorhanden.';
    # EO KIXSidebar

    # Service2QueueAssignment...
    $Lang->{'Assigned Queue'}                  = 'Zugewiesene Queue';
    $Lang->{'Assign a queue to this service.'} = 'Diesem Service eine Queue zuordnen.';
    $Lang->{'Assign a prefered queue to this service'} =
        'Diesem Service eine bevorzugte Queue zuordnen';

    # EO Service2QueueAssignment...

    # KIX4OTRS_CustomerPreferences
    $Lang->{'Default ticket type'}       = 'Standard-Tickettyp für Ticketerstellung';
    $Lang->{'Your default ticket type'}  = 'Ihr Standard-Tickettyp';
    $Lang->{'Default ticket queue'}      = 'Standard-Queue für Ticketerstellung';
    $Lang->{'Your default ticket queue'} = 'Ihre Standard-Queue';
    $Lang->{'Default service'}           = 'Standard-Service für Ticketerstellung';
    $Lang->{'Your default service'}      = 'Ihr Standard-Service';

    # EO KIX4OTRS_CustomerPreferences

    # UserQueueSelectionStyle...
    $Lang->{'Queue selection style'}       = 'Queueauswahl - Methode';
    $Lang->{'Owner selection style'}       = 'Besitzerauswahl - Methode';
    $Lang->{'Responsible selection style'} = 'Verantwortlichenauswahl - Methode';
    $Lang->{'Selection Style'}             = 'Auswahlmethode';
    $Lang->{'Configuration of the mapping for the search type. example: Module:::Element => Typ'} =
        'Konfiguration des Mappings für die Suche eingeben. Beispiel: Module::: Element => Typ';

    # EO UserQueueSelectionStyle...

    $Lang->{'LastSubject'}         = 'Letzter Betreff';
    $Lang->{'LastCustomerSubject'} = 'Letzter Kundenbetreff';
    $Lang->{'TicketNumber'}        = 'Ticket-Nummer';
    $Lang->{'EscalationTime'}      = 'Eskalationszeit';
    $Lang->{'Width'}               = 'Breite';
    $Lang->{'Pending Time'}        = 'Erinnerungszeit';
    $Lang->{'Pending DateTime'}    = 'Wartezeitpunkt';
    $Lang->{'Pending UntilTime'}   = 'Warten bis';
    $Lang->{'OwnerLogin'}          = 'Besitzer (Login)';
    $Lang->{'Owner Login'}         = 'Besitzer (Login)';
    $Lang->{'Owner Information'}   = 'Information Besitzer';
    $Lang->{'ResponsibleLogin'}    = 'Verantw. (Login)';
    $Lang->{'Responsible Login'}   = 'Verantw. (Login)';
    $Lang->{'Responsible Information'} = 'Information Verantwortlicher';
    $Lang->{'CustomerCompanyName'} = 'Firma';
    $Lang->{'CustomerUserEmail'}   = 'Kunden-Email';
    $Lang->{'MarkedAs'}            = 'Markiert als';
    $Lang->{'at first select relevant marks above'} = 'relevante Markierungen zuvor oberhalb auswählen';

    # Article Flags...
    $Lang->{'Flagged Tickets'}   = 'Markierte Tickets';
    $Lang->{'My Flagged Tickets'}   = 'Meine markierten Tickets';
    $Lang->{'Defines the default ticket attribute for ticket sorting in the ticket article flag view of the agent interface.'} = '';    # explicitely without translation
    $Lang->{'Defines the default ticket order in the ticket article flag view of the agent interface. Up: oldest on top. Down: latest on top.'} = ''; # explicitely without translation
    # EO Article Flags...

    # $$STOP$$

    return 0;
}

1;
