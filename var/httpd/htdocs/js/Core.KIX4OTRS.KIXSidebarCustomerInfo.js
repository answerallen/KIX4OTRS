// --
// Core.KIX4OTRS.KIXSidebarCustomerInfo.js - provides the special module functions for the KIXSidebarCustomerInfo
// Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de
//
// written/edited by:
//   Rene(dot)Boehm(at)cape(dash)it.de
//   Dorothea(dot)Doerffel(at)cape(dash)it.de
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
 * @exports TargetNS as Core.KIX4OTRS.KIXSidebarCustomerInfo
 * @description This namespace contains the special module functions for the Dashboard.
 */
Core.KIX4OTRS.KIXSidebarCustomerInfo = (function(TargetNS) {


    /**
     * @function
     * @return nothing This function initializes the special module functions
     */

    TargetNS.UpdateContactSelection = function(CGIHandle,TicketID,ArticleID,SelectedCustomerID) {

        if ( ArticleID == '' || ArticleID == TicketID ) {
            var ArticleLoaded = 0,
                ActiveInterval;

            ActiveInterval = window.setInterval(function(){
                var $ArticleBox = $('#ArticleItems > div > div.WidgetSimple.Expanded');

                // check if article already loaded
                ArticleLoaded = $ArticleBox.length;

                // if article loaded
                if ( ArticleLoaded != 0 ) {
                    window.clearInterval(ActiveInterval);
                    // get article id and do content update
                    if ( $ArticleBox.prev('a').attr('name') !== undefined ) {
                        ArticleID = $ArticleBox.prev('a').attr('name').substring(7);
                        URL = CGIHandle + 'Action=KIXSidebarCustomerInfoAJAXHandler;Subaction=LoadCustomerEmails;TicketID='+TicketID+';ArticleID='+ArticleID+';SelectedCustomerID='+SelectedCustomerID+';';
                        Core.AJAX.ContentUpdate($('#CustomerUserEmail'), URL, function () {},false);
                    }
                }
            }, 100);
        }

        else {
            URL = CGIHandle + 'Action=KIXSidebarCustomerInfoAJAXHandler;Subaction=LoadCustomerEmails;TicketID='+TicketID+';ArticleID='+ArticleID+';SelectedCustomerID='+SelectedCustomerID+';';
            Core.AJAX.ContentUpdate($('#CustomerUserEmail'), URL, function () {},false);
        }

    }

    return TargetNS;
}(Core.KIX4OTRS.KIXSidebarCustomerInfo || {}));
