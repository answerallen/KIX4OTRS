# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Modules::AgentITSMChangeZoom;

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

    # change id lookup
    # KIX4OTRS-capeIT
    if ( !$Self->{ChangeID} ) {
        $Self->{ChangeID} = $ParamObject->GetParam( Param => 'ChangeID' );
    }

    # EO KIX4OTRS-capeIT

    # get params
    my $ChangeID = $ParamObject->GetParam( Param => "ChangeID" );

    # KIX4OTRS-capeIT
    $Param{ChangeID} = $ChangeID;

    # EO KIX4OTRS-capeIT

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
    $Self->{Config} = $ConfigObject->Get("ITSMChange::Frontend::$Self->{Action}");

    # check permissions
    my $Access = $ChangeObject->Permission(
        Type     => $Self->{Config}->{Permission},
        Action   => $Self->{Action},
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

    # KIX4OTRS-capeIT
    # get selected tab
    $Param{SelectedTab} = $ParamObject->GetParam( Param => 'SelectedTab' );
    if ( !$Param{SelectedTab} ) {
        $Param{SelectedTab} = '0';
    }

    # EO KIX4OTRS-capeIT

    # clean the rich text fields from active HTML content
    ATTRIBUTE:
    for my $Attribute (qw(Description Justification)) {

        next ATTRIBUTE if !$Change->{$Attribute};

        # remove active html content (scripts, applets, etc...)
        my %SafeContent = $Kernel::OM->Get('Kernel::System::HTMLUtils')->Safety(
            String       => $Change->{$Attribute},
            NoApplet     => 1,
            NoObject     => 1,
            NoEmbed      => 1,
            NoIntSrcLoad => 0,
            NoExtSrcLoad => 0,
            NoJavaScript => 1,
        );

        # take the safe content if neccessary
        if ( $SafeContent{Replace} ) {
            $Change->{$Attribute} = $SafeContent{String};
        }
    }

    # get log object
    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # handle HTMLView
    if ( $Self->{Subaction} eq 'HTMLView' ) {

        # get param
        my $Field = $ParamObject->GetParam( Param => "Field" );

        # needed param
        if ( !$Field ) {
            $LogObject->Log(
                Message  => "Needed Param: $Field!",
                Priority => 'error',
            );
            return;
        }

        # error checking
        if ( $Field ne 'Description' && $Field ne 'Justification' ) {
            $LogObject->Log(
                Message  => "Unknown field: $Field! Field must be either Description or Justification!",
                Priority => 'error',
            );
            return;
        }

        # get the Field content
        my $FieldContent = $Change->{$Field};

        # build base URL for in-line images if no session cookies are used
        my $SessionID = '';
        if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {
            $SessionID = ';' . $Self->{SessionName} . '=' . $Self->{SessionID};
            $FieldContent =~ s{
                (Action=AgentITSMChangeZoom;Subaction=DownloadAttachment;Filename=.+;ChangeID=\d+)
            }{$1$SessionID}gmsx;
        }

        # get HTML utils object
        my $HTMLUtilsObject = $Kernel::OM->Get('Kernel::System::HTMLUtils');

        # detect all plain text links and put them into an HTML <a> tag
        $FieldContent = $HTMLUtilsObject->LinkQuote(
            String => $FieldContent,
        );

        # set target="_blank" attribute to all HTML <a> tags
        # the LinkQuote function needs to be called again
        $FieldContent = $HTMLUtilsObject->LinkQuote(
            String    => $FieldContent,
            TargetAdd => 1,
        );

        # add needed HTML headers
        $FieldContent = $HTMLUtilsObject->DocumentComplete(
            String  => $FieldContent,
            Charset => 'utf-8',
        );

        # return complete HTML as an attachment
        return $LayoutObject->Attachment(
            Type        => 'inline',
            ContentType => 'text/html',
            Content     => $FieldContent,
        );
    }

    # handle DownloadAttachment
    elsif ( $Self->{Subaction} eq 'DownloadAttachment' ) {

        # get data for attachment
        my $Filename = $ParamObject->GetParam( Param => 'Filename' );
        my $AttachmentData = $ChangeObject->ChangeAttachmentGet(
            ChangeID => $ChangeID,
            Filename => $Filename,
        );

        # return error if file does not exist
        if ( !$AttachmentData ) {
            $LogObject->Log(
                Message  => "No such attachment ($Filename)! May be an attack!!!",
                Priority => 'error',
            );
            return $LayoutObject->ErrorScreen();
        }

        return $LayoutObject->Attachment(
            %{$AttachmentData},
            Type => 'attachment',
        );
    }

    # get session object
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

    # Store LastChangeView, for backlinks from change specific pages
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastChangeView',
        Value     => $Self->{RequestedURL},
    );

    # Store LastScreenOverview, for backlinks from AgentLinkObject
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenOverview',
        Value     => $Self->{RequestedURL},
    );

    # Store LastScreenOverview, for backlinks from AgentLinkObject
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenView',
        Value     => $Self->{RequestedURL},
    );

    # Store LastScreenWorkOrders, for backlinks from ITSMWorkOrderZoom
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenWorkOrders',
        Value     => $Self->{RequestedURL},
    );

    # run change menu modules
    if ( ref $ConfigObject->Get('ITSMChange::Frontend::MenuModule') eq 'HASH' ) {

        # get items for menu
        my %Menus   = %{ $ConfigObject->Get('ITSMChange::Frontend::MenuModule') };
        my $Counter = 0;

        for my $Menu ( sort keys %Menus ) {

            # load module
            if ( $Kernel::OM->Get('Kernel::System::Main')->Require( $Menus{$Menu}->{Module} ) ) {
                my $Object = $Menus{$Menu}->{Module}->new(
                    %{$Self},
                    ChangeID => $ChangeID,
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
                    Change  => $Change,
                    Counter => $Counter,
                    Config  => $Menus{$Menu},
                    MenuID  => $Menu,
                );
            }
            else {
                return $LayoutObject->FatalError();
            }
        }
    }

    # output header
    my $Output = $LayoutObject->Header(
        Value => $Change->{ChangeTitle},
    );
    $Output .= $LayoutObject->NavigationBar();

    # get needed objects
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    # build workorder graph in layout object
    my $WorkOrderGraph = $LayoutObject->ITSMChangeBuildWorkOrderGraph(
        Change             => $Change,
        WorkOrderObject    => $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder'),
        DynamicFieldObject => $DynamicFieldObject,
        BackendObject      => $DynamicFieldBackendObject,
    );

    # display graph within an own block
    $LayoutObject->Block(
        Name => 'WorkOrderGraph',
        Data => {
            WorkOrderGraph => $WorkOrderGraph,
        },
    );

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    # get agents preferences
    my %UserPreferences = $UserObject->GetPreferences(
        UserID => $Self->{UserID},
    );

    # remember if user already closed message about links in iframes
    if ( !defined $Self->{DoNotShowBrowserLinkMessage} ) {
        if ( $UserPreferences{UserAgentDoNotShowBrowserLinkMessage} ) {
            $Self->{DoNotShowBrowserLinkMessage} = 1;
        }
        else {
            $Self->{DoNotShowBrowserLinkMessage} = 0;
        }
    }

    # show message about links in iframes, if user didn't close it already
    if ( !$Self->{DoNotShowBrowserLinkMessage} ) {
        $LayoutObject->Block(
            Name => 'BrowserLinkMessage',
        );
    }

    # get security restriction setting for iframes
    # security="restricted" may break SSO - disable this feature if requested
    my $MSSecurityRestricted;
    if ( $ConfigObject->Get('DisableMSIFrameSecurityRestricted') ) {
        $MSSecurityRestricted = '';
    }
    else {
        $MSSecurityRestricted = 'security="restricted"';
    }

    $Param{KIXSidebarContent}
        = $LayoutObject->AgentKIXSidebar(
        %Param,
        %{$Change},
        );
    $LayoutObject->Block(
        Name => 'Sidebar',
        Data => {
            %Param,
        },
    );

    # generate content of change zoom tabs
    my $ChangeZoomBackendRef = $ConfigObject->Get('AgentITSMChangeZoomBackend');
    if ( $ChangeZoomBackendRef && ref($ChangeZoomBackendRef) eq 'HASH' ) {
        for my $CurrKey ( sort keys %{$ChangeZoomBackendRef} ) {
            my $BackendShortRef = $ChangeZoomBackendRef->{$CurrKey};
            my $Access          = $ChangeObject->Permission(
                Type     => 'ro',
                ChangeID => $Self->{ChangeID},
                UserID   => $Self->{UserID},
            );
            next if !$Access;
            my $DirectLinkAnchor = $BackendShortRef->{Description};
            $DirectLinkAnchor =~ s/\s/_/g;
            my $Link = $BackendShortRef->{Link};
            if ($Link) {
                $Link =~ s{
                      \$Param{"([^"]+)"}
                    }
                    {
                      if ( defined $1 ) {
                        $Param{$1} || '';
                      }
                    }egx;

                my $Count;
                if ( $CurrKey =~ /LinkedObjects/ && $BackendShortRef->{CountMethod} ) {
                    $Count = $Self->_CountLinkedObjects(
                        %Param,
                        %{$Change}
                    );
                    if ($Count) {
                        $Count = '(' . $Count . ')';
                    }
                }

                $LayoutObject->Block(
                    Name => 'DataTabDataLink',
                    Data => {
                        Link        => $Link . ";DirectLinkAnchor=" . $DirectLinkAnchor,
                        Description => $BackendShortRef->{Description},
                        Label       => $BackendShortRef->{Title},
                        LabelCount  => $Count || ''
                    },
                );
            }
        }
    }

    # start template output
    $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentITSMChangeZoom',
        Data         => {
            %Param,
            %{$Change},
        },
    );

    # add footer
    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _CountLinkedObjects {
    my ( $Self, %Param ) = @_;

    # get needed
    my $Change = $Param{Change};

    return if !$Change;

    # get linked objects which are directly linked with this change object
    my $LinkListWithData = $Self->{LinkObject}->LinkListWithData(
        Object => 'ITSMChange',
        Key    => $Param{ChangeID},
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

    # get change initiators info
    if ( keys %ChangeInitiatorsID ) {
        $Self->{LayoutObject}->Block(
            Name => 'ChangeInitiatorExists',
        );
    }

    my $ChangeInitiators = '';
    for my $UserID ( sort keys %ChangeInitiatorsID ) {
        my %User;

        # get customer user info if CI is a customer user
        if ( $ChangeInitiatorsID{$UserID} eq 'CustomerUser' ) {
            %User = $Self->{CustomerUserObject}->CustomerUserDataGet(
                User => $UserID,
            );
        }

        # otherwise get user info
        else {
            %User = $Self->{UserObject}->GetUserData(
                UserID => $UserID,
            );
        }

        # if user info exist
        if (%User) {
            $Self->{LayoutObject}->Block(
                Name => 'ChangeInitiator',
                Data => {%User},
            );

            $User{UserLogin}     ||= '';
            $User{UserFirstname} ||= '';
            $User{UserLastname}  ||= '';

            $ChangeInitiators .= sprintf "%s (%s %s)",
                $User{UserLogin},
                $User{UserFirstname},
                $User{UserLastname};
        }
    }

    # show dash if no change initiator exists
    if ( !$ChangeInitiators ) {
        $Self->{LayoutObject}->Block(
            Name => 'EmptyChangeInitiators',
        );
    }

    # display a string with all changeinitiators
    $Change->{'Change Initators'} = $ChangeInitiators;

    # store the combined linked objects from all workorders of this change
    my $LinkListWithDataCombinedWorkOrders = {};
    for my $WorkOrderID ( @{ $Change->{WorkOrderIDs} } ) {

        # get linked objects of this workorder
        my $LinkListWithDataWorkOrder = $Self->{LinkObject}->LinkListWithData(
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

    # count...
    my $Result = 0;
    for my $LinkObject ( keys %{$LinkListWithData} ) {
        for my $LinkType ( keys %{ $LinkListWithData->{$LinkObject} } ) {
            for my $LinkSource ( keys %{ $LinkListWithData->{$LinkObject}->{$LinkType} } ) {
                $Result += scalar(
                    keys %{ $LinkListWithData->{$LinkObject}->{$LinkType}->{$LinkSource} }
                );
            }
        }
    }

    # return result
    return $Result;
}

1;
