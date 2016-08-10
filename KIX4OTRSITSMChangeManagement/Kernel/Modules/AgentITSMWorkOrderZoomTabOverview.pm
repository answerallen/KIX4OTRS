# --
# based upon AgentITSMWorkOrderZoom.pm
# original Copyright (C) 2001-2015 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMWorkOrderZoomTabOverview;

use strict;
use warnings;

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
        Type        => $Self->{Config}->{'0100-Overview'}->{Permission},
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

    # clean the rich text fields from active HTML content
    ATTRIBUTE:
    for my $Attribute (qw(Instruction Report)) {

        next ATTRIBUTE if !$WorkOrder->{$Attribute};

        # remove active html content (scripts, applets, etc...)
        my %SafeContent = $Kernel::OM->Get('Kernel::System::HTMLUtils')->Safety(
            String       => $WorkOrder->{$Attribute},
            NoApplet     => 1,
            NoObject     => 1,
            NoEmbed      => 1,
            NoIntSrcLoad => 0,
            NoExtSrcLoad => 0,
            NoJavaScript => 1,
        );

        # take the safe content if neccessary
        if ( $SafeContent{Replace} ) {
            $WorkOrder->{$Attribute} = $SafeContent{String};
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
        if ( $Field ne 'Instruction' && $Field ne 'Report' ) {
            $LogObject->Log(
                Message  => "Unknown field: $Field! Field must be either Instruction or Report!",
                Priority => 'error',
            );
            return;
        }

        # get the Field content
        my $FieldContent = $WorkOrder->{$Field};

        # build base URL for in-line images if no session cookies are used
        my $SessionID = '';
        if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {
            $SessionID = ';' . $Self->{SessionName} . '=' . $Self->{SessionID};
            $FieldContent =~ s{
                (Action=AgentITSMWorkOrderZoom;Subaction=DownloadAttachment;Filename=.+;WorkOrderID=\d+)
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
        my $Type     = $ParamObject->GetParam( Param => 'Type' );
        my $AttachmentData = $WorkOrderObject->WorkOrderAttachmentGet(
            WorkOrderID    => $WorkOrderID,
            Filename       => $Filename,
            AttachmentType => $Type,
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

    # check if LayoutObject has TranslationObject
    if ( $LayoutObject->{LanguageObject} ) {

        # translate parameter
        PARAM:
        for my $Param (qw(WorkOrderType)) {

            # check for parameter
            next PARAM if !$WorkOrder->{$Param};

            # translate
            $WorkOrder->{$Param} = $LayoutObject->{LanguageObject}->Translate(
                $WorkOrder->{$Param},
            );
        }
    }

    # get session object
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

    # Store LastWorkOrderView, for backlinks from workorder specific pages
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastWorkOrderView',
        Value     => $Self->{RequestedURL},
    );

    # Store LastScreenOverview, for backlinks from AgentLinkObject
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenOverView',
        Value     => $Self->{RequestedURL},
    );

    # Store LastScreenOverview, for backlinks from 'AgentLinkObject'
    $SessionObject->UpdateSessionID(
        SessionID => $Self->{SessionID},
        Key       => 'LastScreenView',
        Value     => $Self->{RequestedURL},
    );

    # get the change that workorder belongs to
    my $Change = $Kernel::OM->Get('Kernel::System::ITSMChange')->ChangeGet(
        ChangeID => $WorkOrder->{ChangeID},
        UserID   => $Self->{UserID},
    );

    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');

    $LayoutObject->Block(
        Name => 'TabContent',
        Data => {
            %Param,
            %{$Change},
            %{$WorkOrder}
        },
    );

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
        $Param{MSSecurityRestricted} = '';
    }
    else {
        $Param{MSSecurityRestricted} = 'security="restricted"';
    }

    # show the HTML field blocks as iframes
    for my $Field (qw(Instruction Report)) {

        $LayoutObject->Block(
            Name => 'ITSMContent',
            Data => {
                WorkOrderID          => $WorkOrderID,
                Field                => $Field,
                MSSecurityRestricted => $MSSecurityRestricted,
            },
        );
    }

    # get attachments
    my @Attachments = $WorkOrderObject->WorkOrderAttachmentList(
        WorkOrderID => $WorkOrderID,
    );

    # show attachments
    ATTACHMENT:
    for my $Filename (@Attachments) {

        # get info about file
        my $AttachmentData = $WorkOrderObject->WorkOrderAttachmentGet(
            WorkOrderID => $WorkOrderID,
            Filename    => $Filename,
        );

        # check for attachment information
        next ATTACHMENT if !$AttachmentData;

        # do not show inline attachments in attachments list (they have a content id)
        next ATTACHMENT if $AttachmentData->{Preferences}->{ContentID};

        # show block
        $LayoutObject->Block(
            Name => 'AttachmentRow',
            Data => {
                %{$WorkOrder},
                %{$AttachmentData},
            },
        );
    }

    # get report attachments
    my @ReportAttachments = $WorkOrderObject->WorkOrderReportAttachmentList(
        WorkOrderID => $WorkOrderID,
    );

    # show report attachments
    ATTACHMENT:
    for my $Filename (@ReportAttachments) {

        # get info about file
        my $AttachmentData = $WorkOrderObject->WorkOrderAttachmentGet(
            WorkOrderID    => $WorkOrderID,
            Filename       => $Filename,
            AttachmentType => 'WorkOrderReport',
        );

        # check for attachment information
        next ATTACHMENT if !$AttachmentData;

        # do not show inline attachments in attachments list (they have a content id)
        next ATTACHMENT if $AttachmentData->{Preferences}->{ContentID};

        # show block
        $LayoutObject->Block(
            Name => 'ReportAttachmentRow',
            Data => {
                %{$WorkOrder},
                %{$AttachmentData},
            },
        );
    }

    my $Output .= $LayoutObject->Output(
        TemplateFile => 'AgentITSMWorkOrderZoomTabOverview',
        Data => { %Param, %{$Change}, %{$WorkOrder} },
    );

    # add footer
    # $Output .= $LayoutObject->Footer( Type => 'ITSMZoomTab' );
    $Output .= $LayoutObject->Footer( Type => 'TicketZoomTab' );

    return $Output;
}

1;
