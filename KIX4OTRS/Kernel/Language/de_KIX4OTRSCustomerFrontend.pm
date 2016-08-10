# --
# Kernel/Language/de_KIX4OTRSCustomerFrontend.pm - provides german language translation for customer frontend extensions
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_KIX4OTRSCustomerFrontend;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    # CustomerSearch
    $Lang->{'Defines Output filter to provide possibility to open customer ticket search result for result form "print" in new tab.'}       = 'Definiert einen Outputfilter, welcher die Möglichkeit bereitstellt, das Ergebnis der Ticketsuche im Kundenfrontend bei Suchergebnisformat "Drucken" in einem neuen Tab zu öffnen.';
    $Lang->{'Customer ticket search result for "Print" opens in new tab.'} = 'Suchergebnis der Ticketsuche im Kundenfrontend für "Drucken" öffnet in einem neuen Tab.';
    # EO CustomerSearch

    return 0;

    # $$STOP$$
}

1;
