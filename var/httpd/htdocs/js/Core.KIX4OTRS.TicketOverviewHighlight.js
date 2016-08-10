// --
// Core.KIX4OTRS.TicketOverviewHighlight.js - provides javascript to format text
// according to state
//
// Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de
//
// written/edited by
//   Frank(dot)Oberender(at)cape(dash)it(dot)de
//
// --
// $Id$
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.KIX4OTRS = Core.KIX4OTRS || {};

/**
 * @namespace
 * @exports TargetNS as Core.KIX4OTRS.TicketOverviewHighlight
 * @description Provides functions for ticket highlighting in ticket overviews.
 */
Core.KIX4OTRS.TicketOverviewHighlight = (function(TargetNS) {
    var $TicketOverviewRows = $('.TicketOverviewHighlightClass');

    if (!$TicketOverviewRows.length)
        return;

    $TicketOverviewRows.each(function() {
        // takes stylesheet from parent element
        var CurrTicketState = $(this).attr('style');

        if (CurrTicketState) {
            // reformat style of all child elements
            $(this).children().attr('style', CurrTicketState);
            $(this).find('a').attr('style', CurrTicketState);
        }
    });

    return TargetNS;
}(Core.KIX4OTRS.TicketOverviewHighlight || {}));
