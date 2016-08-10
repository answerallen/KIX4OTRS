// --
// Core.KIX4OTRS.TicketZoomTabs.js - provides the special module functions for TicketZoom
// based on Core.Agent.TicketZoom.js: Copyright (C) 2001-2011 OTRS AG, http://otrs.org/
// Copyright (C) 2006-2015 c.a.p.e. IT GmbH, http://www.cape-it.de
//
// written/edited by:
//   Torsten(dot)Thau(at)cape(dash)it(dot)de
//   Rene(dot)Boehm(at)cape(dash)it(dot)de
//   Martin(dot)Balzarek(at)cape(dash)it(dot)de
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
 * @exports TargetNS as Core.KIX4OTRS.TicketZoomTabs
 * @description This namespace contains the special module functions for
 *              TicketZoomTab.
 */
Core.KIX4OTRS.TicketZoomTabs = (function(TargetNS) {

    /**
     * @name InitWidgetActionTabToggle
     * @memberof TicketZoomTabs - taken form Core.UI.js
     * @function
     * @description
     *      This function initializes the toggle mechanism for all widgets with a WidgetAction toggle icon in tabs.
     */
    TargetNS.InitWidgetActionTabToggle = function () {
        $("#ContentItemTabs .WidgetAction.Toggle > a").each(function () {
            var $WidgetElement = $(this).closest("div.Header").parent('div'),
                ContentDivID = Core.UI.GetID($WidgetElement.children('.Content'));

            // fallback to Expanded if default state was not given
            if (!$WidgetElement.hasClass('Expanded') && !$WidgetElement.hasClass('Collapsed')){
                $WidgetElement.addClass('Expanded');
            }

            $(this)
                .attr('aria-controls', ContentDivID)
                .attr('aria-expanded', $WidgetElement.hasClass('Expanded'));
        })
        .unbind('click.WidgetToggle')
        .bind('click.WidgetToggle', function () {
            var $WidgetElement = $(this).closest("div.Header").parent('div'),
                Animate = $WidgetElement.hasClass('Animate'),
                $that = $(this);

            function ToggleWidget() {
                $WidgetElement
                    .toggleClass('Collapsed')
                    .toggleClass('Expanded')
                    .end()
                    .end()
                    .attr('aria-expanded', $that.closest("div.Header").parent('div').hasClass('Expanded'));
                    Core.App.Publish('Event.UI.ToggleWidget', [$WidgetElement]);
            }

            if (Animate && Core.Config.Get('AnimationEnabled')) {
                $WidgetElement.addClass('AnimationRunning').find('.Content').slideToggle("fast", function () {
                    ToggleWidget();
                    $WidgetElement.removeClass('AnimationRunning');
                });
            } else {
                ToggleWidget();
            }

            return false;
        });
    }

    /**
     * @function
     * @param {String}
     *            TicketID of ticket which get's shown
     * @return nothing Mark all articles as seen in frontend and backend.
     *         Article Filters will not be considered
     */
    TargetNS.MarkTicketAsSeen = function (TicketID) {
        TargetNS.TicketMarkAsSeenTimeout = window.setTimeout(function () {
            // Mark old row as readed
            $('#ArticleTable .ArticleID').closest('tr').removeClass('UnreadArticles').find('span.UnreadArticles').remove();

            // Mark article as seen in backend
            var Data = {
                // Action: 'AgentTicketZoom',
                Action : 'AgentTicketZoomTabArticle',
                Subaction: 'TicketMarkAsSeen',
                TicketID: TicketID
            };
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function () {}
            );
        }, 3000);
    };

    /**
     * @function
     * @param {String}
     *            TicketID of ticket which get's shown
     * @param {String}
     *            ArticleID of article which get's shown
     * @return nothing Mark an article as seen in frontend and backend.
     */
    TargetNS.MarkAsSeen = function(TicketID, ArticleID) {
        TargetNS.MarkAsSeenTimeout = window.setTimeout(function() {
            // Mark old row as readed
            $('#ArticleTable .ArticleID[value=' + ArticleID + ']').closest('tr').removeClass('UnreadArticles').find('span.UnreadArticles').remove();

            // Mark article as seen in backend
            var Data = {
                    // Action: 'AgentTicketZoom',
                    Action : 'AgentTicketZoomTabArticle',
                    Subaction : 'MarkAsSeen',
                    TicketID : TicketID,
                    ArticleID : ArticleID
                };
            Core.AJAX.FunctionCall(
                Core.Config.Get('CGIHandle'),
                Data,
                function () {}
            );
        }, 3000);
    };

    /**
     * @function
     * @return nothing This function sets a new width for the column which
     *         contents the article flag icons
     */
    TargetNS.SetArticleFlagColumnWidth = function() {
        var CounterArray = new Array(), CountMax = 0, IconWidth = 25; // used space for one icon (pixel)

        // count flag icons for each article
        $('.UnreadArticles').find('.FlagIcon').each(function() {
            var InformationArray = $(this).attr('id').split("_"), ArticleID = InformationArray[1];

            if (CounterArray[ArticleID]) {
                CounterArray[ArticleID]++;
            } else {
                CounterArray[ArticleID] = 1;
            }

            // get max count
            if (CounterArray[ArticleID] > CountMax) {
                CountMax = CounterArray[ArticleID];
            }

        });

        // set new width for column
        if (CountMax) {
            var TdWidth = CountMax * IconWidth;
            $('.UnreadArticles').css({
                "width" : TdWidth
            });
        }
    };

    /**
     * @function
     * @return nothing This function shows the article flag options dialog box (
     *         edit / delete )
     */
    TargetNS.ShowArticleFlagOptionsDialog = function() {
        $('.FlagIcon')
            .unbind('click')
            .bind('click', function() {
                var FlagInformationArray = $(this).attr('id').split("_"),
                    ArticleID = FlagInformationArray[1],
                    ArticleFlagKey = FlagInformationArray[2],
                    Position = $(this).offset();

                Core.UI.Dialog.ShowContentDialog($('#ArticleFlagOptions_' + ArticleID + '_' + ArticleFlagKey), 'Article Flag Options', Position.top, parseInt(Position.left, 10) + 25);
            });
    };

    /**
     * @function
     * @return nothing This function adds a new flag to an article
     */
    TargetNS.ArticleFlagAdd = function($Element, ApplyText, SetText) {

        var ArticleFlagKey = $Element.val(),
            ArticleFlagValue = $Element.html(),
            FormID = $Element.parent().attr('id').split('_'),
            ArticleID = FormID[1],
            $DialogBox = $('#ArticleFlagDialog');

        $DialogBox.find('input[name=ArticleFlagKey]').val(ArticleFlagKey);
        $DialogBox.find('input[name=ArticleID]').val(ArticleID);

        if (ArticleFlagKey != 0) {
            Core.UI.Dialog
                .ShowContentDialog($('#ArticleFlagDialog'), SetText + ' ' + ArticleFlagValue + ' for Article #' + ArticleID, '20px', 'Center', true, [ {
                    Label : ApplyText,
                    Function : function() {
                        var $FormID = $('#ArticleFlagDialogForm'), Data = Core.AJAX.SerializeForm($FormID);

                        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function() {
                            location.reload();
                        }, 'text');
                    }
                } ]);
        }
        return false;
    };

    /**
     * @function
     * @return nothing This function executes the article flag options like
     *         edit, show or delete
     */
    TargetNS.ArticleFlagOptions = function(TicketID, ApplyText, SetText) {

        $(document.body).on('click', '.ArticleFlagOptionsDialog > a', function(event) {

                var FlagString = $(this).attr('rel'),
                    FlagInformationArray = FlagString.split("_"),
                    ArticleFlagKey = FlagInformationArray[1],
                    Title = $(this).attr('title'),
                    TitleArray = Title.split(" "),
                    ArticleFlagValue = TitleArray[4],
                    Action = TitleArray[0],
                    ArticleID = FlagInformationArray[0];

                if (Action == 'show') {
                    Core.UI.Dialog
                        .ShowContentDialog($('#ArticleFlagDialog_' + FlagString), SetText + ' ' + ArticleFlagValue + ' for Article #' + ArticleID, '20px', 'Center', true, [
                            {
                                Label : ApplyText,
                                Function : function() {
                                    var $FormID = $('#ArticleFlagDialog_' + FlagString + '_Form'),
                                        Data = Core.AJAX.SerializeForm($FormID);

                                    Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function() {
                                        location.reload();
                                    }, 'text');
                                }
                            } ]);
                    $('.Dialog').css({ "width" : "530px" });
                } else {
                    var URL = Core.Config.Get('CGIHandle') + '?Action=AgentTicketZoomTabArticle;Subaction=ArticleFlagDelete;TicketID=' + TicketID
                        + ';ArticleID=' + ArticleID + ';ArticleFlagKey=' + ArticleFlagKey;

                    Core.AJAX.ContentUpdate($('#ArticleFlag_' + FlagString), URL, function() {});
                }

                $('.ArticleFlagOptionsDialog').closest('.Dialog').addClass('Hidden');
                event.preventDefault();
            });
    };

    /**
     * @function
     * @return nothing This function initializes the application and executes
     *         the needed functions the differenct to the global init function
     *         is the disabled InitNavigation call.
     */
    TargetNS.Init = function() {
        var Action = Core.Config.Get('Action');

        // for tab init we must not run InitNavigation again
        // InitNavigation();
        Core.Exception.Init();
        if ( Action.match(/AgentTicketZoomTab/) ) {
            TargetNS.InitWidgetActionTabToggle()
        }
        Core.UI.InitMessageBoxClose();
        Core.Form.Validate.Init();
        if ( Action.match(/AgentTicketZoomTab/) ) {
            Core.UI.InputFields.Init();
            Core.UI.InputFields.CloseAllOpenFieldsInTabs();
            Core.UI.Popup.Init();
        }
        // late execution of accessibility code
        Core.UI.TreeSelection.InitTreeSelection();
        Core.UI.TreeSelection.InitDynamicFieldTreeViewRestore();
        // late execution of accessibility code
        Core.UI.Accessibility.Init();
    };

    /**
     * @function
     * @return nothing This function initializes the pop up views for all
     *         relevant ticket actions
     */
    TargetNS.PopUpInit = function() {
        // $('a.TabAsPopup').removeAttr('onClick');
        $('a.TabAsPopup').bind('click', function(Event) {
            var Matches, PopupType = 'TicketAction';

            Matches = $(this).attr('class').match(/PopupType_(\w+)/);
            if (Matches) {
                PopupType = Matches[1];
            }
            $(this).addClass('PopupCalled');
            $('a.TabAsPopup.PopupCalled').removeAttr('onClick');
            $('a.TabAsPopup.PopupCalled').bind('click', function(Event) {
                $(this).removeClass('PopupCalled');
                return false;
            });
            Core.UI.Popup.OpenPopup($(this).attr('href'), PopupType);
            return false;
        });
    };

    /**
     * @function
     * @return nothing
     * @description This namespace contains the special module functions for
     *              TicketZoomTabAttachments.
     */
    TargetNS.AttachmentsInit = function(Options) {
        var $THead = $('#AttachmentTable thead'), $TBody = $('#AttachmentTable tbody');

        // Table sorting
        Core.UI.Table.Sort.Init($('#AttachmentTable'), function() {
            $(this).find('tr').removeClass('Even').filter(':even').addClass('Even').end().removeClass('Last').filter(':last').addClass('Last');
        });
    };

    return TargetNS;
}(Core.KIX4OTRS.TicketZoomTabs || {}));
