# --
# Kernel/Language/de_Document.pm - provides german language translation for Document package
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_Document;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Filename'}       = 'Dateiname';
    $Lang->{'Path'}           = 'Pfad';
    $Lang->{'DisplayPath'}    = 'Anzeigepfad';
    $Lang->{'DocumentLink'}   = 'Dokument';
    $Lang->{'Document'}       = 'Dokument';
    $Lang->{'Document Name'}  = 'Dokumentenname';
    $Lang->{'Ignore Case'}    = 'Gross-/Kleinschreibung ignorieren';
    $Lang->{'no access'}      = 'Kein Zugriff';
    $Lang->{'link not found'} = 'Keine Verknüpfung gefunden';

    # KIX4OTRS_Document.xml
    $Lang->{'This setting defines the link type \'DocumentLink\'.'} =
        'Definiert den Linktyp \'DocumentLink\'.';
    $Lang->{
        'This setting defines that a \'Ticket\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'Ticket\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'This setting defines that a \'Service\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'Service\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'This setting defines that a \'SLA\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'SLA\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'This setting defines that a \'ITSMConfigItem\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'ITSMConfigItem\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'This setting defines that a \'ITSMWorkOrder\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'ITSMWorkOrder\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'This setting defines that a \'ITSMChange\' object can be linked with documents using the \'DocumentLink\' link type.'
        } =
        'Definiert, dass ein \'ITSMChange\'-Objekt mit dem Linktyp \'DocumentLink\' mit Dokumenten verlinkt werden kann.';
    $Lang->{
        'Define the sources of documents. Use key in the following document settings. Prefer short keys.'
        } =
        'Definition der Quellen für Dokumente. Der Schlüssel wird für alle folgenden Einstellungen benötigt. Schlüsselbezeichnung kurz halten.';
    $Lang->{
        'Specify the backend typ for document link source. Equals modul name in document backend folder.'
        } =
        'Gibt das benutzte Backend für die Dokumentenverknüpfung an. Entspricht dem Namen des Dokumentenbackends.';
    $Lang->{'Specify the parameters of the document source.'} =
        'Gibt die Parameter für die Dokumentenquelle an.';
    $Lang->{'Specify groups that will have access the document source.'} =
        'Legt die Gruppen fest, die auf diese Dokumentenquelle zugreifen können.';
    $Lang->{
        'Specify the search type in FS sources ("live" is slower but does a live search in the directory tree and updates the meta data of the resulting files in the DB, "meta" is fast but only uses the meta data stored in the DB).'
        } =
        'Legt den Suchtyp in FS-Quellen fest ("live" ist langsamer, führt aber eine Live-Suche im Verzeichnisbaum durch und aktualisiert die Metadaten der gefundenen Files in der DB, "meta" ist schnell, nutzt aber lediglich die Metadaten in der DB).';
    $Lang->{'Specify the sync type for the periodic full sync of filesystem document sources.'} =
        'Legt den Sync-Typ für die periodische Voll-Synchronisation von Filesystem-Dokumentenquellen fest.';
    $Lang->{'Specify the path and name of the meta data file if sync type is MetaFile.'} =
        'Legt den Pfad und Namen der Metadaten-File für den Sync-Typ MetaFile fest.';
    $Lang->{
        'Columns that can be filtered in the linked object view of the agent interface. Possible settings: 0 = Disabled, 1 = Available, 2 = Enabled by default.'
        } = 'Spalten, die in der Anzeige der verlinkten Objekte in der Agentenoberfläche gefiltert werden. Mögliche Einstellungen, 1 = Verfügbar, 2 = Aktiv als Standard.';
    # EO KIX4OTRS_Document.xml

    return 0;

    # $$STOP$$
}

1;
