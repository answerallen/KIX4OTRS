# --
# Kernel/Language/de_AgentTicketMergeToCustomer - provides german language
# translation for AgentTicketMergeToCustomer module
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Tom(dot)Lorenz(at)cape(dash)it(dot)de
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

package Kernel::Language::de_KIX4OTRSAgentTicketMergeToCustomer;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};
    return if ref $Lang ne 'HASH';

    # $$START$$
    $Lang->{'All tickets with this customerID'} = 'Alle Tickets mit dieser Kunden-ID';
    $Lang->{'De-/Select this ticket for merging'}
        = 'Dieses Ticket für das Zusammenfassen auswählen';
    $Lang->{'De-/Select all tickets'}           = 'Alle Tickets aus-/abwählen';
    $Lang->{'View this ticket in a new window'} = 'Dieses Ticket in einem neuen Fenster betrachten';
    $Lang->{'Replied'}                          = 'Beantwortet';
    $Lang->{'Merge to'}                         = 'Zusammenfassen zu';
    $Lang->{'oldest ticket'}                    = 'ältestem Ticket';
    $Lang->{'newest ticket'}                    = 'neuestem Ticket';
    $Lang->{'current ticket'}                   = 'aktuellem Ticket';
    $Lang->{'Merge customer tickets'}           = 'Kundentickets zusammenfassen';
    $Lang->{'Merge all tickets from this customer'} = 'Tickets des aktuellen Kunden zusammenfassen';

    # KIX4OTRS_AgentTicketMergeToCustomer.xml
    $Lang->{
        'Frontend module registration for the AgentTicketMergeToCustomer object in the agent interface.'
        }
        = 'Frontendmodul-Registration des AgentTicketMergeToCustomer-Objekts im Agenten-Oberfläche.';
    $Lang->{
        'Shows a link in the menu that allows to merge all tickets from the ticket customer in the ticket zoom view of the agent interface.'
        }
        = 'Zeigt einen Link im Menü der Ticket-Detailansicht der Agenten-Oberfläche an, der das Zusammenfassen aller Tickets des Ticketkunden ermöglicht.';
    $Lang->{
        'Shows a link in the menu that allows to merge all tickets from the ticket customer in the ticket overview of the agent interface.'
        }
        = 'Zeigt einen Link im Menü der Ticket-übersicht der Agenten-Oberfläche an, der das Zusammenfassen aller Tickets des Ticketkunden ermöglicht.';
    $Lang->{'Selected history types to classify a ticket to be answered.'}
        = 'Auswahl der Historie-Typen, die ein Ticket als beantwortet kennzeichnen.';
    $Lang->{'Selected state types to restrict shown customer tickets.'}
        = 'Auswahl der Status-Typen zur Einschränkung der angezeigten Kundentickets.'
        ;
    return 0;

    # $$STOP$$
}

1;
