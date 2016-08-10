# --
# based upon AgentITSMChangeZoom.pm
# original Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMChangeZoomTabLinkedObjects;

use strict;
use warnings;

use Kernel::Language qw(Translatable);
use Kernel::System::VariableCheck qw(:all);

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

    # get needed objects
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get params
    my $ChangeID = $ParamObject->GetParam( Param => "ChangeID" );

    # check needed stuff
    if ( !$ChangeID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No ChangeID is given!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # get needed objects
    my $ChangeObject = $Kernel::OM->Get('Kernel::System::ITSMChange');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get config of frontend module
    $Self->{Config} = $ConfigObject->Get("AgentITSMChangeZoomBackend");

    # check permissions
    my $Access = $ChangeObject->Permission(
        Type     => $Self->{Config}->{'0200-LinkedObjects'}->{Permission},
        ChangeID => $ChangeID,
        UserID   => $Self->{UserID},
    );

    # error screen, don't show change zoom
    if ( !$Access ) {
        return $LayoutObject->NoPermission(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'You need %s permissions!', $Self->{Config}->{Permission} ),
            WithHeader => 'yes',
        );
    }

    # get change data
    my $Change = $ChangeObject->ChangeGet(
        ChangeID => $ChangeID,
        UserID   => $Self->{UserID},
    );

    # check error
    if ( !$Change ) {
        return $LayoutObject->ErrorScreen(
            Message => $LayoutObject->{LanguageObject}->Translate( 'Change "%s" not found in database!', $ChangeID ),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # get customer user object
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

    # get link object
    my $LinkObject = $Kernel::OM->Get('Kernel::System::LinkObject');

    # get linked objects which are directly linked with this change object
    my $LinkListWithData = $LinkObject->LinkListWithData(
        Object => 'ITSMChange',
        Key    => $ChangeID,
        State  => 'Valid',
        UserID => $Self->{UserID},
    );

    # get change initiators (customer users of linked tickets)
    my $TicketsRef = $LinkListWithData->{Ticket} || {};
    my %ChangeInitiatorsID;
    for my $LinkType ( sort keys %{$TicketsRef} ) {

        my $TicketRef = $TicketsRef->{$LinkType}->{Source};
        for my $TicketID ( sort keys %{$TicketRef} ) {

            # get id of customer user
            my $CustomerUserID = $TicketRef->{$TicketID}->{CustomerUserID};

            # if a customer
            if ($CustomerUserID) {
                $ChangeInitiatorsID{$CustomerUserID} = 'CustomerUser';
            }
            else {
                my $OwnerID = $TicketRef->{$TicketID}->{OwnerID};
                $ChangeInitiatorsID{$OwnerID} = 'User';
            }
        }
    }

    # store the combined linked objects from all workorders of this change
    my $LinkListWithDataCombinedWorkOrders = {};
    for my $WorkOrderID ( @{ $Change->{WorkOrderIDs} } ) {

        # get linked objects of this workorder
        my $LinkListWithDataWorkOrder = $LinkObject->LinkListWithData(
            Object => 'ITSMWorkOrder',
            Key    => $WorkOrderID,
            State  => 'Valid',
            UserID => $Self->{UserID},
        );

        OBJECT:
        for my $Object ( sort keys %{$LinkListWithDataWorkOrder} ) {

            # only show linked services and config items of workorder
            if ( $Object ne 'Service' && $Object ne 'ITSMConfigItem' ) {
                next OBJECT;
            }

            LINKTYPE:
            for my $LinkType ( sort keys %{ $LinkListWithDataWorkOrder->{$Object} } ) {

                DIRECTION:
                for my $Direction (
                    sort keys %{ $LinkListWithDataWorkOrder->{$Object}->{$LinkType} }
                    )
                {

                    ID:
                    for my $ID (
                        sort
                        keys %{ $LinkListWithDataWorkOrder->{$Object}->{$LinkType}->{$Direction} }
                        )
                    {

                        # combine the linked object data from all workorders
                        $LinkListWithDataCombinedWorkOrders->{$Object}->{$LinkType}->{$Direction}
                            ->{$ID} = $LinkListWithDataWorkOrder->{$Object}->{$LinkType}->{$Direction}
                            ->{$ID};
                    }
                }
            }
        }
    }

    # add combined linked objects from workorder to linked objects from change object
    $LinkListWithData = {
        %{$LinkListWithData},
        %{$LinkListWithDataCombinedWorkOrders},
    };

    # get link table view mode
    my $LinkTableViewMode = $ConfigObject->Get('LinkObject::ViewMode');

    my $Config = $ConfigObject->Get('ITSMWorkOrder::Frontend::AgentITSMWorkOrderZoomTabLinkedObjects');
    if ($Config->{QuickLink}) {
        my $QuickLinkStrg = $LayoutObject->BuildQuickLinkHTML(
            Object     => 'ITSMChange',
            Key        => $ChangeID,
            RefreshURL => "Action=$Self->{Action};ChangeID=$ChangeID",
        );
        $LayoutObject->Block(
            Name => 'QuickLink',
            Data => {
                QuickLinkContent => $QuickLinkStrg,
            },
        );
    }

    $LayoutObject->Block(
        Name => 'TabContent',
        Data => {}
    );

    # create the link table
    my $LinkTableStrg = $LayoutObject->LinkObjectTableCreate(
        LinkListWithData => $LinkListWithData,
        ViewMode         => $LinkTableViewMode . 'Delete',
        GetPreferences   => 0,
    );

    my $PreferencesLinkTableStrg = $LayoutObject->LinkObjectTableCreate(
        LinkListWithData => $LinkListWithData,
        ViewMode         => $LinkTableViewMode . 'Delete',
        GetPreferences   => 1,
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

    # store last screen
    if ( $Self->{CallingAction} ) {
        $Self->{RequestedURL} =~ s/DirectLinkAnchor=.+?(;|$)//;
        $Self->{RequestedURL} =~ s/CallingAction=.+?(;|$)//;
        $Self->{RequestedURL} =~ s/(^|;|&)Action=.+?(;|$)//;
        $Self->{RequestedURL}
            = "Action="
            . $Self->{CallingAction} . ";"
            . $Self->{RequestedURL} . "#"
            . $Self->{DirectLinkAnchor};
    }

    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenView',
        Value     => $Self->{RequestedURL},
    );

    # return output
    my $UserLanguage = $LayoutObject->{UserLanguage};

    # start template output
    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentITSMChangeZoomTabLinkedObjects',
        Data         => {
            %{$Change},
            UserLanguage => $UserLanguage
        },
    );

    # add footer
    $Output .= $LayoutObject->Footer();

    return $Output;
}

1;
