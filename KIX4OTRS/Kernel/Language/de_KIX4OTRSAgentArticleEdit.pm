# --
# Kernel/Language/de_KIX4OTRSAgentArticleEdit.pm - provides german language translation for module AgentTicketArticleEdit
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Anna(dot)Litvinova(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSAgentArticleEdit;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Edit article'}      = 'Artikel bearbeiten';
    $Lang->{'Article edit'}      = 'Artikel bearbeiten';
    $Lang->{'Edit article data'} = 'Artikeldaten bearbeiten';
    $Lang->{'Required permissions to use this option.'}
        = 'Benötigte Rechte zur Bearbeitung des Artikels.';
    $Lang->{'Defines if a ticket lock is required to edit articles'}
        = 'Definiert, ob für die Artikelbearbeitung das Ticket gesperrt werden soll.';
    $Lang->{
        'Article free text options shown in the article edit screen in the agent interface. Possible settings: 0 = Disabled, 1 = Enabled, 2 = Enabled and required.'
        }
        = 'Definiert Anzeige der Artikelfreitextoptionen in der Artikelbearbeitenansicht. Mögliche Werte: 0 = inaktiv, 1 = aktiviert, 2 = aktiviert und Pflicht.';
    $Lang->{'Only ticket responsible can edit articles of the ticket.'}
        = 'Nur der Ticketverantwortlicher darf Artikel des Tickets bearbeiten.';

    # KIX4OTRS_AgentArticleEdit.xml
    $Lang->{'History type for this action.'} = 'Historientyp für diese Aktion.';
    $Lang->{'Frontend module registration for the AgentArticleEdit.'}
        = 'Frontendmodul-Registrierung von AgentArticleEdit.';
    $Lang->{'Required permissions to edit articles.'}
        = 'Benötigte Rechte zur Bearbeitung von Artikeln.';
    $Lang->{'Defines if a ticket lock is required to edit articles.'}
        = 'Definiert, ob für die Artikelbearbeitung das Ticket gesperrt werden soll.';

    return 0;

    # $$STOP$$
}

1;
