# --
# based upon AgentITSMChangeZoom.pm
# Copyright (C) 2001-2015 OTRS AG, http://otrs.org/
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

package Kernel::Modules::AgentITSMChangeZoomTabOverview;

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
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

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
    $Self->{Config} = $ConfigObject->Get("ITSMChange::Frontend::$Self->{Action}");

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

    #--------------------------------------------------------------------------------#
    # Download attachments
    #--------------------------------------------------------------------------------#
    # handle DownloadAttachment
    if ( $Self->{Subaction} eq 'DownloadAttachment' ) {

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

    #--------------------------------------------------------------------------------#
    # Output: Change Graph
    #--------------------------------------------------------------------------------#
    $LayoutObject->Block(
        Name => 'TabContent',
        Data => {
            %Param,
            %{$Change},
        },
    );

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

    # show the HTML field blocks as iframes
    for my $Field (qw(Description Justification)) {

        $LayoutObject->Block(
            Name => 'ITSMContent',
            Data => {
                ChangeID             => $ChangeID,
                Field                => $Field,
                MSSecurityRestricted => $MSSecurityRestricted,
            },
        );
    }

    #--------------------------------------------------------------------------------#
    # Output: Change Data
    #--------------------------------------------------------------------------------#

    # get attachments
    my @Attachments = $ChangeObject->ChangeAttachmentList(
        ChangeID => $ChangeID,
    );

    # show attachments
    ATTACHMENT:
    for my $Filename (@Attachments) {

        # get info about file
        my $AttachmentData = $ChangeObject->ChangeAttachmentGet(
            ChangeID => $ChangeID,
            Filename => $Filename,
        );

        # check for attachment information
        next ATTACHMENT if !$AttachmentData;

        # do not show inline attachments in attachments list (they have a content id)
        next ATTACHMENT if $AttachmentData->{Preferences}->{ContentID};

        # show block
        $LayoutObject->Block(
            Name => 'AttachmentRow',
            Data => {
                %{$Change},
                %{$AttachmentData},
            },
        );
    }

    #--------------------------------------------------------------------------------#
    # Output: return
    #--------------------------------------------------------------------------------#

    my $Output = $LayoutObject->Output(
        TemplateFile => 'AgentITSMChangeZoomTabOverview',
        Data         => {
            %Param,
            %{$Change},
        },
    );

    # add footer
    # $Output .= $LayoutObject->Footer( Type => 'ITSMZoomTab' );
    $Output .= $LayoutObject->Footer( Type => 'TicketZoomTab' );

    return $Output;
}

1;
