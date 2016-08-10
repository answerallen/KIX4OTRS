# --
# Kernel/Language/de_KIX4OTRSGeneralCatalog.pm - provides german language translation for Document package
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

package Kernel::Language::de_KIX4OTRSGeneralCatalog;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    $Lang->{'Select a General Catalog Class.'} = 'Wählen Sie eine General Catalog Klasse.';

    return 0;

    # $$STOP$$
}

1;
