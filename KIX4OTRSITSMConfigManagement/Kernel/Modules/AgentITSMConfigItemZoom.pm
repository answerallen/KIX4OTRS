# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Ricky(dot)Kaiser(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMConfigItemZoom;

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

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get params
    my $ConfigItemID = $ParamObject->GetParam( Param => 'ConfigItemID' ) || 0;
    my $VersionID    = $ParamObject->GetParam( Param => 'VersionID' )    || 0;

    # get layout object
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # KIX4OTRS-capeIT
    # get needed objects
    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # required further down in tab link generation...
    $Param{ConfigItemID} = $ConfigItemID;
    $Param{VersionID}    = $VersionID;
    $Param{ImageID}      = $ParamObject->GetParam( Param => 'ImageID' ) || '';
    $Param{FileUploaded} = $ParamObject->GetParam( Param => 'FileUploaded' ) || 0;

    # possible params for graph
    # not enabled yet...
    # my $Param{RelevantObjectTypes} = $ParamObject->GetParam( Param => 'RelevantObjectTypes' );
    $Param{RelevantObjectSubTypes} =
        $ParamObject->GetParam( Param => 'RelevantObjectSubTypes' );
    $Param{RelevantLinkTypes} = $ParamObject->GetParam( Param => 'RelevantLinkTypes' );
    $Param{MaxSearchDepth}    = $ParamObject->GetParam( Param => 'MaxSearchDepth' );
    $Param{UsedStrength}      = $ParamObject->GetParam( Param => 'UsedStrength' );

    # EO KIX4OTRS-capeIT

    # check needed stuff
    if ( !$ConfigItemID ) {
        return $LayoutObject->ErrorScreen(
            Message => "No ConfigItemID is given!",
            Comment => 'Please contact the admin.',
        );
    }

    # get needed object
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');

    # check for access rights
    my $HasAccess = $ConfigItemObject->Permission(
        Scope  => 'Item',
        ItemID => $ConfigItemID,
        UserID => $Self->{UserID},
        Type   => $ConfigObject->Get("ITSMConfigItem::Frontend::$Self->{Action}")->{Permission},
    );

    if ( !$HasAccess ) {

        # error page
        return $LayoutObject->ErrorScreen(
            Message => 'Can\'t show item, no access rights for ConfigItem are given!',
            Comment => 'Please contact the admin.',
        );
    }

    # set show versions
    $Param{ShowVersions} = 0;
    if ( $ParamObject->GetParam( Param => 'ShowVersions' ) ) {
        $Param{ShowVersions} = 1;
    }

    # KIX4OTRS-capeIT
    # get selected tab
    $Param{SelectedTab} = $ParamObject->GetParam( Param => 'SelectedTab' );
    if ( !$Param{SelectedTab} ) {
        $Param{SelectedTab} = '0';
    }

    # EO KIX4OTRS-capeIT

    # get content
    my $ConfigItem = $ConfigItemObject->ConfigItemGet(
        ConfigItemID => $ConfigItemID,
    );
    if ( !$ConfigItem->{ConfigItemID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "ConfigItemID $ConfigItemID not found in database!",
            Comment => 'Please contact the admin.',
        );
    }

    # get version list
    my $VersionList = $ConfigItemObject->VersionZoomList(
        ConfigItemID => $ConfigItemID,
    );
    if ( !$VersionList->[0]->{VersionID} ) {
        return $LayoutObject->ErrorScreen(
            Message => "No Version found for ConfigItemID $ConfigItemID!",
            Comment => 'Please contact the admin.',
        );
    }

    # set version id
    if ( !$VersionID ) {
        $VersionID = $VersionList->[-1]->{VersionID};
    }
    if ( $VersionID ne $VersionList->[-1]->{VersionID} ) {
        $Param{ShowVersions} = 1;
    }

    # set version id in param hash (only for menu module)
    if ($VersionID) {
        $Param{VersionID} = $VersionID;
    }

    # run config item menu modules
    if ( ref $ConfigObject->Get('ITSMConfigItem::Frontend::MenuModule') eq 'HASH' ) {
        my %Menus   = %{ $ConfigObject->Get('ITSMConfigItem::Frontend::MenuModule') };
        my $Counter = 0;
        for my $Menu ( sort keys %Menus ) {

            # load module
            if ( $Kernel::OM->Get('Kernel::System::Main')->Require( $Menus{$Menu}->{Module} ) ) {

                my $Object = $Menus{$Menu}->{Module}->new(
                    %{$Self},
                    ConfigItemID => $Self->{ConfigItemID},
                );

                # set classes
                if ( $Menus{$Menu}->{Target} ) {

                    if ( $Menus{$Menu}->{Target} eq 'PopUp' ) {
                        $Menus{$Menu}->{MenuClass} = 'AsPopup';
                    }
                    elsif ( $Menus{$Menu}->{Target} eq 'Back' ) {
                        $Menus{$Menu}->{MenuClass} = 'HistoryBack';
                    }

                }

                # run module
                $Counter = $Object->Run(
                    %Param,
                    ConfigItem => $ConfigItem,
                    Counter    => $Counter,
                    Config     => $Menus{$Menu},
                );
            }
            else {
                return $LayoutObject->FatalError();
            }
        }
    }

    # KIX4OTRS-capeIT
    # outsourced version tree generation

    # load and build tabs
    my $ConfigItemZoomBackendRef = $ConfigObject->Get('AgentITSMConfigItemZoomBackend');
    if ( $ConfigItemZoomBackendRef && ref($ConfigItemZoomBackendRef) eq 'HASH' ) {
        for my $CurrKey ( sort( keys( %{$ConfigItemZoomBackendRef} ) ) ) {

            my $Count = '';
            if ( $ConfigItemZoomBackendRef->{$CurrKey}->{CountMethod} ) {

                # perform count if method registered...
                if (

                    $ConfigItemZoomBackendRef->{$CurrKey}->{CountMethod} =~
                    /CallMethod::(\w+)Object::(\w+)::(\w+)/
                    ||
                    $ConfigItemZoomBackendRef->{$CurrKey}->{CountMethod}
                    =~ /CallMethod::(\w+)Object::(\w+)/
                    )
                {
                    my $ObjectType = $1;
                    my $Method     = $2;
                    my $Hashresult = $3;
                    my $ObjectPath = 'System';

                    if ( $ObjectType eq 'Layout' ) {
                        $ObjectPath = 'Output::HTML';
                    }

                    my $DisplayResult;
                    my $Object;
                    if ( $Hashresult && $Hashresult ne '' ) {
                        eval {
                            $Object =  $Kernel::OM->Get('Kernel::' . $ObjectPath . '::'.$ObjectType);
                            $DisplayResult = {
                                $Object->$Method(
                                    %Param,
                                    )
                            }->{$Hashresult};
                        };
                    }
                    else {
                        eval {
                            $Object = $Kernel::OM->Get('Kernel::' . $ObjectPath . '::'.$ObjectType);
                            $DisplayResult =
                                $Object->$Method(
                                %Param,
                                );
                        };
                    }

                    if ($DisplayResult) {
                        $Count = $DisplayResult;
                    }
                    if ($@) {
                        $LogObject->Log(
                            Priority => 'error',
                            Message  =>
                                "KIX4OTRS::Kernel::Modules::AgentITSMConfigItemZoom::TabCount - "
                                . " invalid CallMethod ($Object->$Method) configured "
                                . "(" . $@ . ")!",
                        );
                    }
                }
            }

            my $DirectLinkAnchor = $ConfigItemZoomBackendRef->{$CurrKey}->{Description};
            $DirectLinkAnchor =~ s/\s/_/g;

            my $Link = $ConfigItemZoomBackendRef->{$CurrKey}->{Link};
            if ($Link) {
                $Link =~ s/\$Param{"([^"]+)"}/$Param{$1}/mg;

                # image tab
                if ( $Link =~ m/(.*?)ZoomTabImages(.*)/ ) {
                    $Link .= ";ImageID=" . $Param{ImageID};
                    $Link .= ";FileUploaded=" . $Param{FileUploaded};
                }

                # graph tab
                if (
                    $Link =~ m/(.*?)ZoomTabLinkGraph(.*)/
                    && defined $Param{RelevantObjectSubTypes}
                    )
                {
                    $Link .= ";RelevantObjectSubTypes=" . $Param{RelevantObjectSubTypes};
                    $Link .= ";RelevantLinkTypes=" . $Param{RelevantLinkTypes};
                    $Link .= ";MaxSearchDepth=" . $Param{MaxSearchDepth};
                    $Link .= ";UsedStrength=" . $Param{UsedStrength};
                }

                $LayoutObject->Block(
                    Name => 'DataTabDataLink',
                    Data => {
                        Link        => $Link . ";DirectLinkAnchor=" . $DirectLinkAnchor,
                        Description => $ConfigItemZoomBackendRef->{$CurrKey}->{Description},
                        Label       => $ConfigItemZoomBackendRef->{$CurrKey}->{Title},
                        LabelCount  => $Count ? " (" . $Count . ")" : '',
                        }
                );
            }
            if ( $ConfigItemZoomBackendRef->{$CurrKey}->{PreloadModule} ) {
                $LayoutObject->Block(
                    Name => 'DataTabDataPreloaded',
                    Data => {
                        Anchor      => $CurrKey,
                        Description => $ConfigItemZoomBackendRef->{$CurrKey}->{Description},
                        Label       => $ConfigItemZoomBackendRef->{$CurrKey}->{Title},
                        LabelCount  => $Count ? " (" . $Count . ")" : '',
                        }
                );

                # check for existence of module
                my $Module = $ConfigItemZoomBackendRef->{$CurrKey}->{PreloadModule};
                return if !$Kernel::OM->Get('Kernel::System::Main')->Require($Module);
                my $Object = $Module->new( %{$Self} );

                # and run reloadmodule
                my $ContentStrg = $Object->Run(%Param) || '';

                $LayoutObject->Block(
                    Name => 'DataTabContentPreloaded',
                    Data => {
                        Anchor      => $CurrKey,
                        ContentStrg => $ContentStrg,
                        }
                );
            }
        }
    }

    # EO KIX4OTRS-capeIT

    # get last version
    my $LastVersion = $VersionList->[-1];

    # set incident signal
    my %InciSignals = (
        operational => 'greenled',
        warning     => 'yellowled',
        incident    => 'redled',
    );

    # to store the color for the deployment states
    my %DeplSignals;

    # get general catalog object
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    # get list of deployment states
    my $DeploymentStatesList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::DeploymentState',
    );

    # set deployment style colors
    my $StyleClasses = '';

    ITEMID:
    for my $ItemID ( sort keys %{$DeploymentStatesList} ) {

        # get deployment state preferences
        my %Preferences = $GeneralCatalogObject->GeneralCatalogPreferencesGet(
            ItemID => $ItemID,
        );

        # check if a color is defined in preferences
        next ITEMID if !$Preferences{Color};

        # get deployment state
        my $DeplState = $DeploymentStatesList->{$ItemID};

        # remove any non ascii word characters
        $DeplState =~ s{ [^a-zA-Z0-9] }{_}msxg;

        # store the original deployment state as key
        # and the ss safe coverted deployment state as value
        $DeplSignals{ $DeploymentStatesList->{$ItemID} } = $DeplState;

        # covert to lower case
        my $DeplStateColor = lc $Preferences{Color};

        # add to style classes string
        $StyleClasses .= "
            .Flag span.$DeplState {
                background-color: #$DeplStateColor;
            }
        ";
    }

    # wrap into style tags
    if ($StyleClasses) {
        $StyleClasses = "<style>$StyleClasses</style>";
    }

    # KIX4OTRS-capeIT
    # outsourced version tree generation
    # EO KIX4OTRS-capeIT

    # output header
    my $Output = $LayoutObject->Header( Value => $ConfigItem->{Number} );
    $Output .= $LayoutObject->NavigationBar();

    # get version
    my $Version = $ConfigItemObject->VersionGet(
        VersionID => $VersionID,
    );

    # KIX4OTRS-capeIT

    $Param{KIXSidebarContent}
        = $LayoutObject->AgentKIXSidebar(
        %Param,
        %{$ConfigItem},
        );

    $LayoutObject->Block(
        Name => 'Sidebar',
        Data => {
            %Param,
        },
    );

    # EO KIX4OTRS-capeIT

    # store last screen
    $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenView',
        Value     => $Self->{RequestedURL},
    );

    # start template output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentITSMConfigItemZoom',
        Data         => {
            %Param,
            %{$LastVersion},
            %{$ConfigItem},
            CurInciSignal => $InciSignals{ $LastVersion->{CurInciStateType} },
            CurDeplSignal => $DeplSignals{ $LastVersion->{DeplState} },
            StyleClasses  => $StyleClasses,
        },
    );

    # add footer
    $Output .= $LayoutObject->Footer();

    return $Output;
}

# KIX4OTRS-capeIT
# outsourced _XMLOutput
# EO KIX4OTRS-capeIT

1;
