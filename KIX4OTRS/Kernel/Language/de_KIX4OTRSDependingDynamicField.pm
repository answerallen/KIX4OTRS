# --
# Kernel/Language/de_KIX4OTRSDependingDynamicField.pm - provides german language translation for depending dynamic fields
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSDependingDynamicField;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return 0 if ref $Lang ne 'HASH';

    # $$START$$
    # admin frontend
    $Lang->{'Selected Field From Source Field'} = 'Gewählter Wert im Quellfeld';
    $Lang->{'Available Target Fields'}          = 'Verfügbare Zielfelder';
    $Lang->{'Available Target Values'}          = 'Verfügbare Werte im Zielfeld';
    $Lang->{'Depending Dynamic Field Edit'}     = 'Abhängige Dynamische Felder bearbeiten';
    $Lang->{'Available Dynamic Fields'}         = 'Verfügbare Dynamische Felder';
    $Lang->{'Add Depending Field'}              = 'Abhängiges Feld hinzufügen';
    $Lang->{'Add Dynamic Field'}                = 'Dynamisches Feld hinzufügen';
    $Lang->{'Remove Dynamic Field'}             = 'Dynamisches Feld entfernen';
    $Lang->{'Tree Name'}                        = 'Name des Baumes';
    $Lang->{'Selected Dynamic Field'}           = 'Gewähltes Dynamisches Feld';
    $Lang->{'Possible Values'}                  = 'Mögliche Werte';
    $Lang->{'Depending Dynamic Field Add'}      = 'Abhängiges Dynamisches Feld hinzufügen';
    $Lang->{'Depending Dynamic Fields'}         = 'Abhängige Dynamische Felder';
    $Lang->{'Click here to add a depending field'} =
        'Klicken, um ein abhängiges Feld hinzuzufügen';
    $Lang->{'Depending Dynamic Fields - Tree View'} = 'Abhängige Dynamische Felder - Baumansicht';
    $Lang->{'Depending Dynamic Fields Management'}  = 'Verwaltung - Abhängige Dynamische Felder';
    $Lang->{'Create new depending dynamic field or change existing.'} =
        'Abhängige Dynamische Felder erzeugen und verwalten';
    $Lang->{
        'Frontend module registration for the depending dynamic field configuration in the admin interface.'
        } =
        'Frontend Modul Registrierung für die Konfiguration der abhängigen Dynamische Felder in der Administrator-Oberfläche.';
    $Lang->{'Ticket-ACLs to define dynamic fields dependencies.'}         = 'Ticket-ACLs, um Abhängigkeiten bei dynamischen Feldern festzulegen.';
    $Lang->{'Do you really want to delete this depending field and all of its other depending fields ?'} = 'Möchten Sie wirklich das abhängige Feld und alle von diesem abhängigen Felder löschen?';

    return 0;

    # $$STOP$$
}
1;
