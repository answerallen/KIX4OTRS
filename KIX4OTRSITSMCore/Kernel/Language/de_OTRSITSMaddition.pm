# --
# Kernel/Language/de_OTRSITSMaddition.pm - provides missing de translation for OTRS::ITSM
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_OTRSITSMaddition;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Impact \ Criticality'}   = 'Auswirkung \ Kritikalität';
    $Lang->{'TicketAccumulationITSM'} = 'Ticket-Aufkommen ITSM';

    # $$STOP$$

    return 0;
}

1;
