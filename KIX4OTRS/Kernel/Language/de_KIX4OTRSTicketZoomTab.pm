# --
# Kernel/Language/de_KIX4OTRSTicketZoomTab - provides de translation for KIX4OTRS
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSTicketZoomTab;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return 0 if ref $Lang ne 'HASH';

    # $$START$$
    $Lang->{'Person not found'}                  = 'Person nicht gefunden';
    $Lang->{'Article Subject'}                   = 'Artikel Betreff';
    $Lang->{'Article Body'}                      = 'Artikel Inhalt';
    $Lang->{'Accounted Time'}                    = 'Erfasste Zeit';
    $Lang->{'Lock State'}                        = 'Sperrstatus';
    $Lang->{'New Note'}                          = 'Neue Notiz';
    $Lang->{'Articles'}                          = 'Artikel';
    $Lang->{'DynamicFields'}                     = 'Dynamische Felder';
    $Lang->{'Remarks'}                           = 'Anmerkungen';
    $Lang->{'Remarks successfully saved!'}       = 'Anmerkungen erfolgreich gespeichert!';
    $Lang->{'Remarks could not be saved!'}       = 'Anmerkungen konnten nicht gespeichert werden!';
    $Lang->{'Ticket data successfully updated!'} = 'Ticket-Daten erfolgreich aktualisiert!';
    $Lang->{'Ticket data could not be updated!'} =
        'Ticket-Daten konnten nicht aktualisiert werden!';
    $Lang->{'DynamicField successfully updated!'} =
        'Dynamisches Feld erfolgreich aktualisiert!';
    $Lang->{'DynamicField could not be updated!'} =
        'Dynamisches Feld konnte nicht aktualisiert werden!';
    $Lang->{'DynamicField successfully saved!'} =
        'Dynamisches Feld erfolgreich gespeichert!';
    $Lang->{'DynamicField could not be saved!'} =
        'Dynamisches Feld konnte nicht gespeichert werden!';
    $Lang->{'Show ticket ScratchPad in ticket view.'} =
        'Anzeigen des Ticket-Notizblocks in der Ticket-Ansicht.';
    $Lang->{'No attachments available'}     = 'Keine Anlagen vorhanden';
    $Lang->{'Direct URL to article %s: %s'} = 'Link zum Artikel %s: %s';
    $Lang->{'Filter for attachments'}       = 'Filter für Anlagen';
    $Lang->{'Defines which ticket data parameters are displayed in direct data presentation'} =
        'Definiert welche Daten in der Direktdatenanzeige dargestellt werden.';
    $Lang->{'Defines which ticket freetext data parameters are displayed.'} =
        'Definiert welche TicketFreitext Daten dargestellt werden.';
    $Lang->{'Preloaded Content Dummy'} = 'Vorab geladener Dummyinhalt';
    $Lang->{'Shows some preloaded content dummy page'} =
        'Zeigt vorgeladenden Inhalt einer Platzhalterseite';
    $Lang->{'Shows all objects linked with this ticket'} =
        'Zeigt alle mit diesem Ticket verknüpften Objekte';
    $Lang->{'Shows a list of all article attachments of this ticket'} =
        'Zeigt eine Liste aller Artikelanhänge dieses Tickets';
    $Lang->{'Shows all article of this ticket'} = 'Zeigt die Artikel dieses Tickets';
    $Lang->{'Shows the most important information about this ticket'} =
        'Zeigt die wichtigsten Informationen dieses Tickets';
    $Lang->{'Redefine the FreeTextField 3 for article to use it as FAQ-Workflow trigger.'} =
        'Definiert bevorzugte Beschriftungen fuer interne Ticketattributnamen.';
    $Lang->{'Defines parameters for the AgentTicketZoomTab "Ticket Core Data".'}
        = 'Definiert Parameter für das AgentTicketZoomTab "Ticketkerndaten".';
    $Lang->{'Required permissions to use the ticket note screen in the agent interface.'} =
        'Benötigte Rechte, um das Notiztab im Agenteninterface zu nutzen.';
    $Lang->{
        'Defines if a ticket lock is required in the ticket note screen of the agent interface (if the ticket is not locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'
        } =
        'Legt fest, ob ein Ticket gesperrt werden muss im Notiztab. Falls das Ticket noch nicht gesperrt ist, wird es gesperrt und der aktuelle Agent wird automatisch als Besitzer gesetzt.';
    $Lang->{'Defines if ticket move is enabled in this screen.'} =
        'Legt fest, ob der Queuewechsel in dieser Ansicht aktiviert ist.';
    $Lang->{
        'Sets the ticket type in the ticket note screen of the agent interface (Ticket::Type needs to be activated).'
        } =
        'Aktiviert die Tickettypauswahl im Notiztab des Agenteninterfaces (Ticket::Type muss aktiviert sein).';
    $Lang->{
        'Sets the service in the ticket note screen of the agent interface (Ticket::Service needs to be activated).'
        } =
        'Aktiviert die Serviceauswahl im Notiztab des Agenteninterfaces (Ticket::Service muss aktiviert sein).';
    $Lang->{'Sets the ticket owner in the ticket note screen of the agent interface.'} =
        'Aktiviert die Ticketbesitzerauswahl im Notiztab des Agenteninterfaces.';
    $Lang->{'Sets if ticket owner must be selected by the agent.'} =
        'Legt fest, ob die Auswahl des Besitzers ein Pflichtfeld ist.';
    $Lang->{
        'Sets the responsible agent of the ticket in the ticket note screen of the agent interface.'
        } =
        'Aktiviert die Auswahl für den verantwortlichen Agenten im Notiztab des Agenteninterfaces.';
    $Lang->{
        'If a note is added by an agent, sets the state of a ticket in the ticket note screen of the agent interface.'
        } =
        'Aktiviert die Auswahl für den Status im Notiztab des Agenteninterfaces.';
    $Lang->{
        'Defines the next state of a ticket after adding a note, in the ticket note screen of the agent interface.'
        } =
        'Definiert die möglichen Folgestatus nach Hinzufügen einer Notiz.';
    $Lang->{
        'Defines the default next state of a ticket after adding a note, in the ticket note screen of the agent interface.'
        } =
        'Definiert den Standard-Folgestatus nach Hinzufügen einer Notiz.';
    $Lang->{'Allows adding notes in the ticket note screen of the agent interface.'} =
        'Legt fest, ob das Notizfeld angezeigt werden soll.';
    $Lang->{
        'Sets the default subject for notes added in the ticket note screen of the agent interface.'
        } =
        'Legt den Standardbetreff für das Notiztab fest.';
    $Lang->{
        'Sets the default body text for notes added in the ticket note screen of the agent interface.'
        } =
        'Legt den Standardbody für das Notiztab fest.';
    $Lang->{
        'Shows a list of all the involved agents on this ticket, in the ticket note screen of the agent interface.'
        } =
        'Zeigt eine Liste der involvierten Agenten zu diesem Ticket.';
    $Lang->{
        'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket note screen of the agent interface.'
        } =
        'Zeigt eine Liste aller möglichen Agenten zu diesem Ticket (alle Agenten, welche die Berechtigung note haben bzgl. des Tickets oder der Queue), um festzulegen, wer über die neue Notiz informiert werden sollte.';
    $Lang->{
        'Defines the default type of the note in the ticket note screen of the agent interface.'
        }
        =
        'Legt den Standardtyp für das Notiztab fest.';
    $Lang->{'Specifies the different note types that will be used in the system.'} =
        'Spezifiziert die verschiedenen genutzten Notiztypen';
    $Lang->{'Shows the ticket priority options in the ticket note screen of the agent interface.'} =
        'Aktiviert die Auswahl für die Priorität im Notiztab des Agenteninterfaces.';
    $Lang->{'Defines the default ticket priority in the ticket note screen of the agent interface.'}
        =
        'Legt die Standardpriorität für das Notiztab fest.';
    $Lang->{'Shows the title fields in the ticket note screen of the agent interface.'} =
        'Zeigt das Titelfeld im Notiztab.';
    $Lang->{
        'Defines the history type for the ticket note screen action, which gets used for ticket history in the agent interface.'
        } =
        'Legt den History-Typ, welcher für die Ticket-Historie genutzt wird, für das Notiztab fest.';
    $Lang->{
        'Defines the history comment for the ticket note screen action, which gets used for ticket history in the agent interface.'
        } =
        'Legt den History-Kommentar, welcher für die Ticket-Historie genutzt wird, für das Notiztab fest.';
    $Lang->{
        'Dynamic fields shown in the ticket note screen of the agent interface. Possible settings: 0 = Disabled, 1 = Enabled, 2 = Enabled and required.'
        } =
        'Dynamische Felder, die im Notiztab angezeigt werden sollen. Mögliche Einstellungen: 0 = Deaktiviert, 1 = Aktiviert, 2 = Aktiviert und Pflicht.';
    $Lang->{'Required permissions to use the ticket core data tab in the agent interface.'} =
        'Benötigte Rechte, um das Kerndatentab im Agenteninterface zu nutzen.';
    $Lang->{
        'Defines if a ticket lock is required in the ticket core data tab of the agent interface (if the ticket is not locked yet, the ticket gets locked and the current agent will be set automatically as its owner).'
        } =
        'Legt fest, ob ein Ticket im Kerndatentab gesperrt sein muss. Falls das Ticket noch nicht gesperrt ist, wird es gesperrt und der aktuelle Agent wird automatisch als Besitzer gesetzt.';
    $Lang->{
        'Sets the ticket type in the ticket core data tab of the agent interface (Ticket::Type needs to be activated).'
        } =
        'Aktiviert die Tickettypauswahl im Kerndatentab des Agenteninterfaces (Ticket::Type muss aktiviert sein).';
    $Lang->{
        'Sets the service in the ticket core data tab of the agent interface (Ticket::Service needs to be activated).'
        } =
        'Aktiviert die Serviceauswahl im Kerndatentab des Agenteninterfaces (Ticket::Service muss aktiviert sein).';
    $Lang->{'Sets the ticket owner in the ticket core data tab of the agent interface.'} =
        'Aktiviert die Ticketbesitzerauswahl im Kerndatentab des Agenteninterfaces.';
    $Lang->{
        'Sets the responsible agent of the ticket in the ticket core data tab of the agent interface.'
        } =
        'Aktiviert die Auswahl für den verantwortlichen Agenten im Kerndatentab des Agenteninterfaces.';
    $Lang->{
        'If a note is added by an agent, sets the state of a ticket in the ticket core data tab of the agent interface.'
        } =
        'Aktiviert die Auswahl für den Status im Kerndatentab des Agenteninterfaces.';
    $Lang->{
        'Defines the next state of a ticket after adding a note, in the ticket core data tab of the agent interface.'
        } =
        'Legt den Folgestatus für das Kerndatentab fest.';
    $Lang->{
        'Defines the default next state of a ticket after adding a note, in the ticket core data tab of the agent interface.'
        } =
        'Legt den Standardfolgestatus für das Kerndatentab fest.';
    $Lang->{'Allows adding notes in the ticket core data tab of the agent interface.'} =
        'Erlaubt das Hinzufügen von Notizen im Kerndatentab.';
    $Lang->{
        'Sets the default subject for notes added in the ticket core data tab of the agent interface.'
        } =
        'Legt den Standardbetreff für das Kerndatentab fest.';
    $Lang->{
        'Sets the default body text for notes added in the ticket core data tab of the agent interface.'
        } =
        'Legt den Standardbody für das Kerndatentab fest.';
    $Lang->{
        'Shows a list of all the involved agents on this ticket, in the ticket core data tab of the agent interface.'
        } =
        'Zeigt eine Liste der involvierten Agenten zu diesem Ticket.';
    $Lang->{
        'Shows a list of all the possible agents (all agents with note permissions on the queue/ticket) to determine who should be informed about this note, in the ticket core data tab of the agent interface.'
        } =
        'Zeigt eine Liste aller möglichen Agenten zu diesem Ticket (alle Agenten, welche die Berechtigung note haben bzgl. des Tickets oder der Queue), um festzulegen, wer über die neue Notiz informiert werden sollte.';
    $Lang->{
        'Defines the default type of the note in the ticket core data tab of the agent interface.'
        }
        =
        'Legt den Standardtyp für das Kerndatentab fest.';
    $Lang->{'Shows the ticket priority options in the ticket core data tab of the agent interface.'}
        =
        'Aktiviert die Auswahl für die Priority im Kerndatentab des Agenteninterfaces.';
    $Lang->{
        'Defines the default ticket priority in the ticket core data tab of the agent interface.'
        }
        =
        'Legt den Standardbetreff für das Kerndatentab fest.';
    $Lang->{'Shows the title fields in the ticket core data tab of the agent interface.'} =
        'Aktiviert das Titelfeld im Kerndatentab des Agenteninterfaces.';
    $Lang->{
        'Defines the history type for the ticket core data tab action, which gets used for ticket history in the agent interface.'
        } =
        'Legt den Standardbetreff für das Kerndatentab fest.';
    $Lang->{
        'Defines the history comment for the ticket core data tab action, which gets used for ticket history in the agent interface.'
        } =
        'Legt den History-Kommentar, welcher für die Ticket-Historie genutzt wird, für das Kerndatentab fest.';
    $Lang->{
        'Dynamic fields shown in the edit core data tab of the agent interface. Possible settings: 0 = Disabled, 1 = Enabled, 2 = Enabled and required.'
        } =
        'Dynamische Felder, die im Kerndatentab angezeigt werden sollen. Mögliche Einstellungen: 0 = Deaktiviert, 1 = Aktiviert, 2 = Aktiviert und Pflicht.';
    $Lang->{'Ticket Core Data'}             = 'Ticketkerndaten';
    $Lang->{'Edit this tickets core data!'} = 'Die Kerndaten dieses Tickets bearbeiten!';
    $Lang->{'Question'}                     = 'Frage';
    $Lang->{'Delete Attachments'}           = 'Anlagen löschen';
    $Lang->{'Download Attachments'}         = 'Anlagen herunterladen';
    $Lang->{'Do you really want to delete the selected attachments?'} = 'Möchten Sie die ausgewählten Anlagen wirklich löschen?';
    $Lang->{'Defines article flags.'} =
        'Definiert Artikel Flags';
    $Lang->{'Article Flag'} =
        'Artikel Flag';
    $Lang->{'Defines icons for article icons.'} =
        'Definiert Icons zu den Artikel Flags.';
    $Lang->{
        'Dynamic fields shown in the article tab of the agent interface. Possible settings: 0 = Disabled, 1 = Enabled, 2 = Enabled and required.'
        } =
        'Dynamische Felder, welche im Artikeltab der Agentenoberfläche angezeigt werden. Mögliche Einstellungen: 0 = deaktiviert, 1 = aktiviert, 2 = aktiviert und benötigt.';
    $Lang->{'Notes'}               = 'Notizen';
    $Lang->{'Set article flag'}    = 'Setze Artikel Flag';
    $Lang->{'show details / edit'} = 'Details anzeigen / editieren';
    $Lang->{'remove'}              = 'Artikel Flag entfernen';
    $Lang->{'- mark as -'}         = '- markieren als -';
    $Lang->{'Link ticket with:'}   = 'Verknüpfe Ticket mit:';
    $Lang->{'Link Configuration Item with:'}   = 'Verknüpfe Configuration Item mit:';
    $Lang->{'Link Change with:'}   = 'Verknüpfe Change mit:';
    $Lang->{'Link Workorder with:'}   = 'Verknüpfe Workorder mit:';
    $Lang->{'Enable quick link in linked objects tab (different backends have to be defined first)'}
        =
        'Aktiviert QuickLink im Tab Verlinkte Objekte (die unterschiedlichen Backends müssen vorher aktiviert und konfiguriert werden.)';
    $Lang->{'QuickLink backend registration.'} = 'QuickLink Backend Registrierung.';

    $Lang->{'Defines either realname or realname and email address should be shown in the article detail view.'} = 'Legt fest, ob nur der Name oder Name und Email-Adresse in den Artikeldetails angezeigt werden sollen.';
    $Lang->{'Defines either realname or realname and email address should be shown in the article list.'} = 'Legt fest, ob nur der Name oder Name und Email-Adresse in der Artikelliste angezeigt werden sollen.';
    $Lang->{'Realname and email address'} = 'Name und Emailadresse';
    $Lang->{'Realname'} = 'Name';
    $Lang->{'Ticket-ACLs to define shown tabs if ticket is process ticket.'} = 'Ticket-ACL um angezeigte Tabs festzulegen, wenn das Ticket ein Prozessticket ist.';
    $Lang->{'There could be more linked objects than displayed due to lack of permissions.'} = 'Aufgrund fehlender Berechtigungen können mehr verlinkte Objekte existieren, als angezeigt werden.';

    # $$STOP$$
    return 0;
}
1;
