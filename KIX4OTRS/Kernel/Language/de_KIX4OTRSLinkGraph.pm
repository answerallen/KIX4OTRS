# --
# Kernel/Language/de_KIX4OTRSLinkGraph.pm - provides german translation for object graph
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Ricky(dot)Kaiser(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Language::de_KIX4OTRSLinkGraph;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    # KIX4OTRS_AgentLinkGraph.xml
    $Lang->{'Link Graph'} = 'Verknüpfungsgraph';
    $Lang->{'Shows this object in its relation to other linked objects'}
        = 'Zeigt dieses Objekt in seinen Beziehungen zu anderen verknüpften Objekten';
    $Lang->{
        'This frame should show the current object with its linked objects, depending on your current selection'
        }
        = 'Dieses Frame zeigt das aktuelle Objekt mit seinen verknüpften Objekten, in Abhängigkeit von Ihrer akt. Auswahl an';
    $Lang->{'Defines parameters for the AgentTicketZoomTab "LinkGraph".'} =
        'Bestimmt die Parameter für AgentTicketZoomTab "Verknüpfungsgraph".';
    $Lang->{'Defines the parameters for the "AgentLinkGraphIFrameDefault".'} =
        'Bestimmt die Parameter für "AgentLinkGraphIFrameDefault".';
    $Lang->{
        'Required permissions to use the ticket zoom screen in the agent interface.'
        }
        = 'Benötigte Berechtigungen, um den Ticket Zoom Tab im Agenten-Interface nutzen zu können.';
    $Lang->{
        'Defines the preselected maximum search depth for IDDFS (iterative deepening depth-first search) in the object graph.'
        }
        = 'Definiert die vorselektierte maximale Suchtiefe für IDDFS (Iterative Tiefensuche) im Objekt-Graphen';
    $Lang->{
        'Defines the colors for link visualization - links are just black if no color is given.'
        }
        = 'Bestimmt die Farben für die Verknüpfungen - ohne Farbe ist die Verknüpfung schwarz.';
    $Lang->{
        'Defines which attribute should be considered for the icons. Sub-attributes are possible. Value must be key not name of attribute!'
        }
        = 'Bestimmt welches Attribut für die Icons beachtet werden soll. Unterattribute sind möglich. Der Wert muss der Key, nicht der Name des Attributes sein!';
    $Lang->{
        'Defines the icons for node visualization - key could be "Ticket" alone or followed by a triple colon and a value of the specified attribute (if attribute is "Type" - e.g. "Ticket:::Problem"). The Icon for "Ticket" is the fallback if no icon for the ticket-attribute is specified and "Default" is the fallback if no icon for "Ticket" is specified.'
        }
        = 'Definiert die Icons für die Knotendarstellung - der Schlüssel kann "Ticket" allein oder gefolgt von einem dreifachen Doppelpunkt und einem Wert des angegebenen Attributes (falls "Type" das Attribut ist - z.B. "Ticket:::Problem") sein. Das Icon für "Ticket" ist der Fallback, falls kein Icon für das Attribute definiert ist und "Default" ist der Fallback, wenn kein Icon für "Ticket" angegeben ist.';

    $Lang->{'Link-Types to follow'}     = 'Zu verfolgende Verknüpfungstypen';
    $Lang->{'Max Link Depth'}           = 'Max. Verknüpfungstiefe';
    $Lang->{'Adjusting Strength'}       = 'Ausrichtungsstärke';
    $Lang->{'Strong'}                   = 'Stark';
    $Lang->{'Medium'}                   = 'Mittel';
    $Lang->{'Weak'}                     = 'Schwach';
    $Lang->{'Show Graph'}               = 'Graph anzeigen';
    $Lang->{'Graph View Configuration'} = 'Konfiguration Graphanzeige';
    $Lang->{'Graph Display'}            = 'Graphanzeige';
    $Lang->{'This feature requires a browser that is capable of displaying SVG-elements.'}
        = 'Diese Funktion erfordert einen Browser, der in der Lage ist SVG-Elemente anzuzeigen.';
    $Lang->{'Something went wrong! Please look into the error-log for more information.'} =
        'Etwas lief falsch! Bitte schauen Sie in das Error-Log für mehr Informationen.';
    $Lang->{'No Objects!'}             = 'Keine Objekte!';
    $Lang->{'No objects displayable.'} = 'Keine Objekte darstellbar.';

    # context menu
    $Lang->{'Show'}                        = 'Zeige';
    $Lang->{'Add link with displayed'}     = 'Verknüpfe mit dargestelltem';
    $Lang->{'Add link with not displayed'} = 'Verknüpfe mit nicht dargestelltem';

    $Lang->{'link with'}                                              = 'verknüpfen mit';
    $Lang->{'Link as'}                                                = 'Verknüpfen als';
    $Lang->{'Not possible!'}                                          = 'Nicht möglich!';
    $Lang->{'Either search is empty or there is no matching object!'} =
        'Entweder ist das Suchfeld leer oder es gibt kein passendes Objekt!';
    $Lang->{'Impossible to link a node with itself!'} =
        'Ein Knoten kann nicht mit sich selbst verknüpft werden!';
    $Lang->{'Link-Type does already exists!'} = 'Dieser Verknüpfungstyp besteht bereits!';
    $Lang->{'Either search is empty or there is no matching ticket!'} =
        'Entweder ist das Suchfeld leer oder es gibt kein passendes Ticket!';
    $Lang->{'Impossible to link a ticket with itself!'} =
        'Ein Ticket kann nicht mit sich selbst verknüpft werden!';
    $Lang->{'Adjust'}                       = 'Ausrichten';
    $Lang->{'Graph could not be adjusted!'} = 'Der Graph konnte nicht ausgerichtet werden!';
    $Lang->{
        'Maybe the graph is too complex or too "simple". But you can change the adjusting strength and try again if you like. (simple -> increase; complex -> reduce)'
        }
        = 'Vielleicht ist der Graph zu komplex oder zu "einfach". Aber Sie können die Ausrichtungsstärke reduzieren und es gern noch einmal versuchen.</br>(einfach -> erhöhen; komplex -> reduzieren)';
    $Lang->{'Current zoom level'}             = 'Aktuelle Zoom-Stufe';
    $Lang->{'Default size'}                   = 'Standardgröße';
    $Lang->{'Fit in'}                         = 'Einpassen';

    $Lang->{'Fits the graph into the visible area'} = 'Passt den Graph in den sichtbaren Bereich ein';
    $Lang->{'Zoom in'} = 'Vergrößern';
    $Lang->{'Zoom out'} = 'Verkleinern';
    $Lang->{'Zoom to 100%'} = 'Auf 100% vergrößern';
    $Lang->{'Tool for defining a zoom-area'} = 'Werkzeug zum Aufziehen des Zoombereiches';
    $Lang->{'Adjust the graph'} = 'Den Graph ausrichten';
    $Lang->{'Save the graph'} = 'Den Graph speichern';
    $Lang->{'Print the graph'} = 'Den Graph drucken';

    $Lang->{'Do you want to set a new link type or delete this connection?'} =
        'Möchten Sie einen neuen Verknüpfungstyp zuweisen oder die Verknüpfung löschen?';
    $Lang->{'Link new as'}                = 'Neu verknüpfen als';
    $Lang->{'Set'}                        = 'Zuweisen';
    $Lang->{'Change direction?'}          = 'Richtung ändern?';
    $Lang->{'as source'}                  = 'als Quelle';
    $Lang->{'as target'}                  = 'als Ziel';
    $Lang->{'Print'}                      = 'Drucken';
    $Lang->{'Followed Link-Types'}        = 'Verfolgte Verknüpungstypen';
    $Lang->{'Link not created!'}          = 'Verknüpfung nicht angelegt!';
    $Lang->{'Link could not be removed!'} = 'Verknüpfung konnte nicht entfernt werden!';
    $Lang->{'Please look into the error-log for more information.'} =
        'Bitte schauen Sie in das Error-Log für mehr Informationen.';
    $Lang->{'Load Graph'}                   = 'Graph Laden';
    $Lang->{'Saved graphs for this object'} = 'Gespeicherte Graphen für dieses Objekt';
    $Lang->{'There are no saved graphs!'}   = 'Es gibt keine gespeicherten Graphen!';
    $Lang->{'Save'}                         = 'Speichern';
    $Lang->{'No name is given!'}            = 'Kein Name angegeben!';
    $Lang->{'There is already a saved graph with this name!'} =
        'Es gibt bereits einen gespeicherten Graphen mit diesem Namen!';
    $Lang->{'Saved'}                      = 'Gespeichert';
    $Lang->{'Graph could not be saved!'}  = 'Graph konnte nicht gespeichert werden!';
    $Lang->{'Load'}                       = 'Laden';
    $Lang->{'Graph could not be loaded!'} = 'Graph konnte nicht geladen werden!';
    $Lang->{'The standard configuration was used instead.'} =
        'Die Standard-Konfiguration wurde stattdessen benutzt.';
    $Lang->{'Information about loaded graph'} = 'Informationen zum geladenen Graphen';
    $Lang->{'No longer existent nodes'}       = 'Nicht mehr vorhandene Knoten';
    $Lang->{'New nodes'}                      = 'Neue Knoten';
    $Lang->{'Save graph for'}                 = 'Graph speichern für';
    $Lang->{'What should be done?'}           = 'Was soll getan werden?';
    $Lang->{'Create new'}                     = 'Neu anlegen';
    $Lang->{'Overwrite'}                      = 'Überschreiben';
    $Lang->{'Which one?'}                     = 'Welchen?';
    $Lang->{''}                               = '';

    return 0;

    # $$STOP$$
}

1;
