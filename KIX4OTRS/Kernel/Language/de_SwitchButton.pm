# --
# Kernel/Language/de_SwitchButton.pm - provides german translation for SwitchButton
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
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Language::de_SwitchButton;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;
    my $Lang = $Self->{Translation};

    return 0 if ref $Lang ne 'HASH';

    # $$START$$

    # KIX4OTRS_SwitchButton.xml
    $Lang->{'Frontend module registration for the SwitchButton object in the Customer interface.'} =
        'Frontendmodul-Registration des SwitchButton-Objekts im Customer-Interface.';
    $Lang->{'Frontend module registration for the SwitchButton object in the Agents interface.'} =
        'Frontendmodul-Registration des SwitchButton-Objekts im Agenten Interface.';

    # EO KIX4OTRS_SwitchButton.xml

    $Lang->{'Switch Button'}                     = 'Wechsel-Button';
    $Lang->{'switch button'}                     = 'Wechsel-Button';
    $Lang->{'Switch-Button'}                     = 'Wechsel-Button';
    $Lang->{'Switch to customer frontend and login automatically'} =
        'In das Kunden-Frontend wechseln und automatisch einloggen';
    $Lang->{'Switch to agent frontend and login automatically'} =
        'In das Agenten-Frontend wechseln und automatisch einloggen';

    return 0;

    # $$STOP$$
}

1;
