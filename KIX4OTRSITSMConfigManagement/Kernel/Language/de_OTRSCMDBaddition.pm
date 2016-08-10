# --
# Kernel/Language/de_OTRSCMDBaddition.pm - provides missing de translation for CMDB of OTRS::ITSM
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
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

package Kernel::Language::de_OTRSCMDBaddition;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'NEW'}       = 'NEU';
    $Lang->{'Classes'}   = 'Klassen';
    $Lang->{'DeplState'} = 'Verwendungsstatus';
    $Lang->{'InciState'} = 'Vorfallsstatus';

    $Lang->{'Config Item Search Result: Class'} = 'Such-Ergebnis: Config Item: Klasse';
    $Lang->{'ITSM ConfigItem'}                  = 'Config Item';

    # $$STOP$$

    return 0;
}

1;
