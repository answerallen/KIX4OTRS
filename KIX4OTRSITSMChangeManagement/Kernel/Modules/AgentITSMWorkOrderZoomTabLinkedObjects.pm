# --
# based upon AgentITSMWorkOrderZoom.pm
# original Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Modules::AgentITSMWorkOrderZoomTabLinkedObjects;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed object
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get needed WorkOrderID
    my $WorkOrderID = $ParamObject->GetParam( Param => 'WorkOrderID' );

    # check needed stuff
    if ( !$WorkOrderID ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No WorkOrderID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # get needed objects
    my $WorkOrderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');

    # get config of frontend module
    $Self->{Config} = $ConfigObject->Get("AgentITSMWorkOrderZoomBackend");

    # check permissions
    my $Access = $WorkOrderObject->Permission(
        Type        => $Self->{Config}->{'0200-LinkedObjects'}->{Permission},
        WorkOrderID => $WorkOrderID,
        UserID      => $Self->{UserID},
    );

    # error screen
    if ( !$Access ) {
        return $LayoutObject->NoPermission(
            Message    => "You need $Self->{Config}->{'0100-Overview'}->{Permission} permissions!",
            WithHeader => 'no',
        );
    }

    # get workorder data
    my $WorkOrder = $WorkOrderObject->WorkOrderGet(
        WorkOrderID => $WorkOrderID,
        UserID      => $Self->{UserID},
    );

    # check error
    if ( !$WorkOrder ) {
        return $LayoutObject->ErrorScreen(
            Message => "WorkOrder '$WorkOrderID' not found in database!",
            Comment => 'Please contact the admin.',
        );
    }

    # get linked objects
    my $LinkListWithData = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkListWithData(
        Object => 'ITSMWorkOrder',
        Key    => $WorkOrderID,
        State  => 'Valid',
        UserID => $Self->{UserID},
    );

    for my $LinkObject ( keys %{$LinkListWithData} ) {
        for my $LinkType ( keys %{ $LinkListWithData->{$LinkObject} } ) {
            for my $LinkDirection ( keys %{ $LinkListWithData->{$LinkObject}->{$LinkType} } ) {
                for my $LinkItem ( keys %{ $LinkListWithData->{$LinkObject}->{$LinkType}->{$LinkDirection} } ) {
                    $LinkListWithData->{$LinkObject}->{$LinkType}->{$LinkDirection}->{$LinkItem}->{SourceObject} = 'ITSMWorkOrder';
                    $LinkListWithData->{$LinkObject}->{$LinkType}->{$LinkDirection}->{$LinkItem}->{SourceKey}    = $Param{WorkOrderID};
                }
            }
        }
    }

    my $Config = $ConfigObject->Get('ITSMWorkOrder::Frontend::AgentITSMWorkOrderZoomTabLinkedObjects');
    if ($Config->{QuickLink}) {
        my $QuickLinkStrg = $LayoutObject->BuildQuickLinkHTML(
            Object => 'ITSMWorkOrder',
            Key    => $WorkOrderID,
            RefreshURL => "Action=$Self->{Action};WorkOrderID=$WorkOrderID",
        );
        $LayoutObject->Block(
            Name => 'QuickLink',
            Data => {
                QuickLinkContent => $QuickLinkStrg,
            },
        );
    }

    # get link table view mode
    my $LinkTableViewMode = $ConfigObject->Get('LinkObject::ViewMode');

    # create the link table
    my $LinkTableStrg = $LayoutObject->LinkObjectTableCreate(
        LinkListWithData => $LinkListWithData,
        ViewMode         => $LinkTableViewMode.'Delete',
        GetPreferences   => 0,
    );

    my $PreferencesLinkTableStrg = $LayoutObject->LinkObjectTableCreate(
        LinkListWithData => $LinkListWithData,
        ViewMode         => $LinkTableViewMode.'Delete',
        GetPreferences   => 1,
    );

    $LayoutObject->Block(
        Name => 'TabContent',
        Data => {},
    );

    # output the link table
    if ($LinkTableStrg) {
        $LayoutObject->Block(
            Name => 'LinkTable',
            Data => {
                LinkTableStrg => $LinkTableStrg,
                PreferencesLinkTableStrg => $PreferencesLinkTableStrg,
            },
        );
    }

    # return output
    my $UserLanguage = $LayoutObject->{UserLanguage};

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentITSMWorkOrderZoomTabLinkedObjects',
        Data => { %Param, UserLanguage => $UserLanguage },
    );

    # add footer
    # $Output .= $LayoutObject->Footer( Type => 'ITSMZoomTab' );
    $Output .= $LayoutObject->Footer( Type => 'TicketZoomTab' );

    return $Output;

}

1;
