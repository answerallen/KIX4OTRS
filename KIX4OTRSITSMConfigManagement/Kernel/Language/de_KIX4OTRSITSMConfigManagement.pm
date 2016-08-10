# --
# Kernel/Language/de_KIX4OTRSITSMConfigManagement.pm - provides german language
# translation for KIX4OTRSITSMConfigManagement
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Ricky(dot)Kaiser(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSITSMConfigManagement;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # $$START$$

    # other translations...
    $Lang->{'Please check the config item which is affected by your request'} =
        'Bitte markieren Sie das Config Item, auf welches sich Ihre Anfrage bezieht';
    $Lang->{'Create and manage the definitions for Configuration Items.'} =
        'Erstellen und verwalten Sie die Definitionen für Configuration Items.';
    $Lang->{'Images'}                          = 'Bilder';
    $Lang->{'Load image'}                      = 'Bild laden';
    $Lang->{'Set image text'}                  = 'Bildtext festlegen';
    $Lang->{'Delete image'}                    = 'Bild löschen';
    $Lang->{'Assigned CIs'}                    = 'Zugewiesene CIs';
    $Lang->{'Config Item Data'}                = 'CI Daten';
    $Lang->{'Show CILinks Selection'}          = 'Anzahl der verlinkten ConfigItems pro Seite';
    $Lang->{'Customer info CILinks selection'} = 'Kundeninfo: verlinkte ConfigItems';
    $Lang->{'File is no image or image type not supported. Please contact your admin.'}
        = 'Datei ist kein Bild oder Bildtyp wird nicht unterstützt.';
    $Lang->{'Shows a link in the menu to create an email ticket.'}
        = 'Erstellt einen Link im Menu, um ein Emailticket zu erstellen.';
    $Lang->{'Shows a link in the menu to create a phone ticket.'}
        = 'Erstellt einen Link im Menu, um ein Telefonticket zu erstellen.';
    $Lang->{'Defines parameters for the AgentITSMConfigItemZoomTab ConfigItem.'}
        = 'Legt Parameter für das AgentITSMConfigItemZoomTab ConfigItem fest.';
    $Lang->{'Defines parameters for the AgentITSMConfigItemZoomTab Linked Objects.'}
        = 'Legt Parameter für das AgentITSMConfigItemZoomTab Verlinkte Objekte fest.';
    $Lang->{'Defines parameters for the AgentITSMConfigItemZoomTab Images.'}
        = 'Legt Parameter für das AgentITSMConfigItemZoomTab Bilder fest.';
    $Lang->{'Defines parameters for the AgentTicketZoomTab Dummy Tab.'}
        = 'Legt Parameter für das AgentITSMConfigItemZoomTab Dummy fest.';
    $Lang->{
        'Overloads (redefines) existing functions in Kernel::System::ITSMConfigItem. Used to easily add customizations.'
        }
        = 'Überlädt (redefiniert) existierende Funktionen in Kernel::System::ITSMConfigItem. Wird genutzt, um einfach Anpassungen hinzufügen zu können.';
    $Lang->{'ConfigItem link direction for propagating of warning/error incident states.'}
        = 'ConfigItem Linkrichtung zur Übertragung von Warnungs-/Fehlervorfallstatus.';
    $Lang->{'Shows the most important information about this change'}
        = 'Zeigt die wichtigsten Informationen zu diesem Change.';
    $Lang->{'Parameters for the KIXSidebar backend ChangeInfo.'}
        = 'Parameter für das KIXSidebar-Backend ChangeInfo.';
    $Lang->{'Parameters for the KIXSidebar backend ConfigItemInfo.'}
        = 'Parameter für das KIXSidebar-Backend ConfigItemInfo.';
    $Lang->{'Defines the path to save the images.'}
        = 'Legt den Speicherpfad für die ConfigItem-Bilder fest.';
    $Lang->{'Defines an overview module to show the custom view of a configuration item list.'}
        = 'Definiert ein Übersichtsmodul, um die Custom-Ansicht (C) einer ConfigItem-Liste anzuzeigen.';
    $Lang->{'Parameters for the KIXSidebar backend WorkOrderInfo.'}
        = 'Parameter für das KIXSidebar-Backend WorkOrderInfo.';
    $Lang->{'Parameters for the KIXSidebar backend linked config items.'}
        = 'Parameter für das KIXSidebar-Backend Linked Config Items (Zugewiesene CIs).';
    $Lang->{'Frontend module registration for the KIXSidebarLinkedCIsAJAXHandler object.'}
        = 'Frontend Modulregistrierung für das KIXSidebarLinkedCIsAJAXHandler Objekt.';
    $Lang->{
        'Parameters for the pages (in which the CIs are shown) of the custom config item overview. This is a list of available column values can be chosen.'
        }
        = 'Parameter für die Seiten (auf welchen CIs als Liste angezeigt werden) mit Custom Config Item Overview (C). Es wird eine Liste von verfügbaren Spalten angezeigt, die gewählt werden können.';
    $Lang->{'Defined DeploymentStates to hide ConfigItems.'}
        = 'Festgelegte Verwendungsstatus, um ConfigItems zu verstecken.';
    $Lang->{'Defined IncidentStates to hide ConfigItems.'}
        = 'Festgelegte Vorfallstatus, um ConfigItems zu verstecken.';
    $Lang->{'Frontend module registration for the customer interface.'}
        = 'Frontend Modulregistrierung für das Kundenfrontend.';
    $Lang->{'Current Incident Signal'} = 'Aktueller Vorfallstatus (als Icon)';
    $Lang->{'Current Deployment Signal'} = 'Aktueller Verwendungstatus (als Icon)';
    $Lang->{'Last Changed'}            = 'Zuletzt geändert';
    $Lang->{'WarrantyExpirationDate'}  = 'Garantieablaufdatum';
    $Lang->{'ConfigItemSearch behavior for search over all config item classes'}
        = 'Verhalten der CI-Suche beim Suchen über alle Klassen';
    $Lang->{'Linked config items'} = 'Verknüpfte ConfigItems';
    $Lang->{'All Attributes'}      = 'Alle Attribute';
    $Lang->{'Common Attributes'}   = 'Gemeinsame Attribute';
    $Lang->{'Number of Linked ConfigItems per Page'}
        = 'Anzahl der verknüpften ConfigItems pro Seite';
    $Lang->{'Defines parameters for the AgentITSMWorkOrderZoomTab "Linked Objects".'}
        = 'Legt Parameter fest für das AgentITSMWorkOrderZoomTab "Linked Objects".';
    $Lang->{'Defines the image types.'} = 'Legt die Bildtype fest, die geladen werden können.';
    $Lang->{'Parameters for the pages (in which the configuration items are shown).'}
        = 'Parameter für die Seiten, auf denen ConfigItems angezeigt werden.';
    $Lang->{
        'Defines parameters for user preference to set ConfigItemSearch behavior for search over all config item classes.'
        }
        = 'Legt Parameter fest für die Nutzereinstellungen zum Suchverhalten, wenn über alle ConfigItem Attribute gesucht werden soll.';
    $Lang->{
        'Parameters for the dashboard backend of the customer assigned config items widget of the agent interface . "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'
        }
        = 'Parameter für das Dashboardbackend des Widgets für die dem Nutzer zugeordneten CIs. "Group" wird genutzt, um den Zugriff einzuschränken  (z.B. Group: admin;group1;group2;). "Default" bestimmt, ob das Plugin standardmäßig aktiviert ist oder ob der Nutzer es manuell aktivieren muss. "CacheTTLLocal" ist die Cachezeit in Minuten für dieses Plugin.';
    $Lang->{'Defines parameters for the AgentITSMChangeZoomTab "Linked Objects".'}
        = 'Legt Parameter für das AgentITSMChangeZoomTab "Linked Objects" fest.';
    $Lang->{'Select Class'} = 'Klasse auswählen';
    $Lang->{'Settings for custom ticket list view'} = 'Einstellungen für persönliche Ticketlistendarstellung';

    # graph visualization related translations...
    $Lang->{'CI-Classes to consider'} = 'Zu betrachtende CI-Klassen';
    $Lang->{'Defines parameters for the AgentITSMConfigItemZoomTab "LinkGraph".'} =
        'Bestimmt die Parameter für AgentITSMConfigItemZoomTab "Verknüpfungsgraph".';
    $Lang->{
        'Required permissions to use the ITSM configuration item zoom screen in the agent interface.'
        }
        = 'Benötigte Berechtigungen, um den ITSM Configuration Item Zoom Tab im Agenten-Interface nutzen zu können.';
    $Lang->{
        'Defines which class-attribute should be considered for the icons. Sub-attributes are possible. Value must be key not name of attribute!'
        }
        = 'Bestimmt welches Klassen-Attribut für die Icons beachtet werden soll. Unterattribute sind möglich. Der Wert muss der Key, nicht der Name des Attributes sein!';
    $Lang->{
        'Defines the icons for node visualization - key could be a CI-Class (if applicable - e.g. "Computer") or a CI-Class followed by a triple colon and a value of the specified class-attribute (if attribute is "Type" - e.g. "Computer:::Server"). The Icon for a CI-Class is the fallback if no icon for the class-attribute is specified and "Default" is the fallback if no icon for a CI-Class is specified.'
        }
        = 'Definiert die Icons für die Knotendarstellung - der Schlüssel kann eine CI-Klasse (falls zutreffend - z.B. "Computer") oder eine CI-Klasse gefolgt von einem dreifachen Doppelpunkt und einem Wert des angegebenen Klassenattributes (falls "Type" das Attribut ist - z.B. "Computer:::Server") sein. Das Icon der CI-Klasse ist der Fallback, falls kein Icon für das Klassenattribute definiert ist und "Default" ist der Fallback wenn kein Icon für eine CI-Klasse angegeben ist.';
    $Lang->{
        'Defines the icons for node visualization if CIs with a certain deployment state are not shown in CMDB overview (postproductive or configured) - key could be a CI-Class (if applicable - e.g. "Computer") or a CI-Class followed by a triple colon and a value of the specified class-attribute (if attribute is "Type" - e.g. "Computer:::Server"). The Icon for a CI-Class is the fallback if no icon for the class-attribute is specified and "Default" is the fallback if no icon for a CI-Class is specified.'
        }
        = 'Definiert die Icons für die Knotendarstellung falls CIs mit einem bestimmten Verwendungsstatus in der CMDB-Übersicht nicht angezeigt werden (postproductive oder konfiguriert) - der Schlüssel kann eine CI-Klasse (falls zutreffend - z.B. "Computer") oder eine CI-Klasse gefolgt von einem dreifachen Doppelpunkt und einem Wert des angegebenen Klassenattributes (falls "Type" das Attribut ist - z.B. "Computer:::Server") sein. Das Icon der CI-Klasse ist der Fallback, falls kein Icon für das Klassenattribute definiert ist und "Default" ist der Fallback wenn kein Icon für eine CI-Klasse angegeben ist.';
    $Lang->{
        'Defines the icons for the incident-states - key is the state-type (if applicable - e.g. "operational").'
        }
        = 'Definiert die Icons für die Vorfallstatus - der Schlüssel ist der Status (falls zutreffend - z.B. "operational")';
    $Lang->{'Show linked services'}     = 'Zeige verknüpfte Services';
    $Lang->{'Linked Services'}          = 'Verknüpfte Services';
    $Lang->{'No linked Services'}       = 'Keine verknüpften Services vorhanden.';
    $Lang->{'Considered CI-Classes'}    = 'Betrachtete CI-Klassen';
    $Lang->{'Saved graphs for this CI'} = 'Gespeicherte Graphen für dieses CI';

    $Lang->{''} = '';

    # KIX4OTRS_ITSMConfigItemEvents.xml
    $Lang->{
        'Config item event module that shows passed parameters BEFORE action is perdormed. May be used as template for own CI-events.'
        }
        = 'Event-Modul für ConfigItems, welches die übergebenden Parameter anzeigt BEVOR die Aktion ausgeführt wurde. Kann als Vorlage für eigene CI-Events genutzt werden.';
    $Lang->{
        'Config item event module that shows passed parameters AFTER action is performed. May be used as template for own CI-events.'
        }
        = 'Event-Modul für ConfigItems, welches die übergebenden Parameter anzeigt NACHDEM die Aktion erfolgt ist. Kann als Vorlage für eigene CI-Events genutzt werden.';
    $Lang->{
        'Defines the config parameters of this item, to show CILinks and be shown in the preferences view.'
        }
        = 'Definiert die Konfigurationsparameter für die verlinkten Config Items in der KIXSidebar und zeigt eine Auswahl in der Nutzereinstellungen an.';

    $Lang->{''} = '';

    # KIX4OTRS_ITSMConfigItemCompare
    $Lang->{'Compare'}                       = 'Vergleichen';
    $Lang->{'Compare Versions'}              = 'Versionen vergleichen';
    $Lang->{'Compare different versions of'} = 'Vergleich verschiedener Versionen von';
    $Lang->{'Select two versions to compare'} =
        'Wählen Sie zwei Versionen, die Sie vergleichen möchten';
    $Lang->{'Do not compare two similar versions!'} =
        'Vergleich von zwei gleichen Versionen nicht möglich.';
    $Lang->{'Compare of'}   = 'Vergleich von';
    $Lang->{'version'}      = 'Version';
    $Lang->{'with version'} = 'mit Version';
    $Lang->{'Added'}        = 'Hinzugefügt';
    $Lang->{'Removed'}      = 'Entfernt';
    $Lang->{'Legend'}       = 'Legende';
    $Lang->{
        'Required permissions to use the compare ITSM configuration item screen in the agent interface.'
        }
        = 'Benötigte Berechtigungen, um die Anzeige zum vergleichen von ConfigItem Versionen im Agentenfrontend zu nutzen.';
    $Lang->{'Frontend module registration for the agent interface.'}
        = 'Frontend Modulregistrierung für den Agenten.';
    $Lang->{'Shows a link in the menu to compare a configuration item with an other.'}
        = 'Zeigt einen Link im Menu an, um zwei ConfigItems miteinander zu vergleichen.';
    $Lang->{
        'Configure an highlightning for a row in the compare table depending on compare result.'
        }
        = 'Konfiguriert die farbliche Hervorhebung für das Vergleichsergebnis.';
    $Lang->{
        'Changes the behaviour of Config Item Version Compare. "Structure" will mark swapped items as changed'
        }
        = 'Ändert das Verhalten vom CI-Versionsvergleich. "Struktur" markiert auch Attribute als geändert, bei denen sich nur die Reihenfolge geändert hat.';

    # LinkedCIs
    $Lang->{
        'Defines in which CI-classes (keys) which attributes need to match the search pattern (values, comma separated if more than one attribute should be searched). For use with sub-attributes try this, key: attribute::sub-attribute, value: owner'
        }
        = 'Legt fest, in welchen CI-Klassen (Schlüssel) welche Attribute mit dem Suchmuster (Inhalt, getrennt durch Komma, falls mehr als ein Attribut gesucht werden soll) übereinstimmen müssen. Bei Verwendung von Sub-Attributen, muss folgendes eingestellt werden, Schlüssel: Attribut::Sub-Attribut, Inhalt: Such-Attribut';
    $Lang->{'Defines which attributes are shown in customer table.'} =
        'Legt fest, welche Attribute in der Customer-Tabelle angezeigt werden.';
    $Lang->{
        'Defines the link type which is used for the link creation between ticket and config item.'
        }
        = 'Legt den Link-Typ fest, welcher für die Erzeugung eines Links zwischen Ticket und Config Item genutzt wird.';
    $Lang->{'Common Parameters for the KIXSidebarLinkedCIs backend. You can use CI class specific customer user attributes (SearchAttribute:::&lt;CIClass&gt;) as well as multiple customer user attributes, separated by comma.'} =
        'Allgemeine Parameter für das KIXSidebarLinkedCIs Backend. Sie können CI-Klassen-spezifische Kundennutzer-Attribute (SearchAttribute:::&lt;CIClass&gt;), sowie mehrere Kundennutzer-Attribute verwenden, getrennt mit Komma.';
    $Lang->{'Shows all config items assigned to selected customers.'}
        = 'Zeigt alle Config Items, welche den ausgewählten Kunden zugewiesen sind.';
    $Lang->{'Defines a css style element depending on config item deployment state.'}
        = 'Definiert ein CSS Style Element auf Grundlage des Verwendungsstatus (Deployment State).';
    $Lang->{
        'Defines whether config items with postproductive deployment state should be shown or not.'
        }
        = 'Legt fest, ob ConfigItems vom Verwendungsstatus postproductive in der Übersicht angezeigt werden sollen.';
    $Lang->{
        'Defines which deployment states should not be shown in config item overview. Separate different states by comma.'
        }
        = 'Legt fest, welche Verwendungsstatus in der Übersicht nicht mit angezeigt werden sollen. Mehrere Werte werden durch Komma getrennt.';

    $Lang->{'Only attributes of the following types are shown in the list'} = 'Nur Attribute folgender Typen werden in der Liste angezeigt';

    # $$STOP$$

    return 0;
}

1;
