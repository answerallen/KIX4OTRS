# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
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

package Kernel::Modules::AgentITSMWorkOrderZoom;

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

    # get needed object
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get needed WorkOrderID
    my $WorkOrderID = $ParamObject->GetParam( Param => 'WorkOrderID' );

    # check needed stuff
    if ( !$WorkOrderID ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No WorkOrderID is given!'),
            Comment => Translatable('Please contact the admin.'),
        );
    }

    # get needed objects
    my $WorkOrderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');

    # get config of frontend module
    $Self->{Config} = $ConfigObject->Get("ITSMWorkOrder::Frontend::$Self->{Action}");

    # check permissions
    my $Access = $WorkOrderObject->Permission(
        Type        => $Self->{Config}->{Permission},
        Action      => $Self->{Action},
        WorkOrderID => $WorkOrderID,
        UserID      => $Self->{UserID},
    );

    # error screen
    if ( !$Access ) {
        return $LayoutObject->NoPermission(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'You need %s permissions!', $Self->{Config}->{Permission} ),
            WithHeader => 'yes',
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
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'WorkOrder "%s" not found in database!', $WorkOrderID ),
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

    # KIX4OTRS-capeIT
    # get the change that workorder belongs to
    my $ChangeObject = $Kernel::OM->Get('Kernel::System::ITSMChange');
    my $Change = $ChangeObject->ChangeGet(
        ChangeID => $WorkOrder->{ChangeID},
        UserID   => $Self->{UserID},
    );
    # EO KIX4OTRS-capeIT

    # handle DownloadAttachment
    if ( $Self->{Subaction} eq 'DownloadAttachment' ) {

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

    # KIX4OTRS-capeIT
    # generate output
    my $Output;
    $Output = $LayoutObject->Header(
        Value => $WorkOrder->{WorkOrderTitle},
    );
    $Output .= $LayoutObject->NavigationBar();
    $Output .= $Self->_MaskAgentZoom(
        %Param,
        Change      => $Change,
        WorkOrder   => $WorkOrder,
        WorkOrderID => $WorkOrderID,
    );
    $Output .= $LayoutObject->Footer();

    # EO KIX4OTRS-capeIT
    return $Output;
}

sub _MaskAgentZoom {
    my ( $Self, %Param ) = @_;

    my $Change      = $Param{Change};
    my $WorkOrder   = $Param{WorkOrder};
    my $WorkOrderID = $Param{WorkOrderID};

    # get needed object
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $MainObject      = $Kernel::OM->Get('Kernel::System::Main');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $WorkOrderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');

    $LayoutObject->Block(
        Name => 'Header',
        Data => {
            %{$WorkOrder},
            %{$Change}
        },
    );

    $Param{KIXSidebarContent}
        = $LayoutObject->AgentKIXSidebar(
        %Param,
        %{$Change},
        %{$WorkOrder}
        );
    $LayoutObject->Block(
        Name => 'Sidebar',
        Data => {
            %Param,
        },
    );

    # generate menu
    my %Menus   = %{ $ConfigObject->Get('ITSMWorkOrder::Frontend::MenuModule') };
    my $Counter = 0;

    for my $Menu ( sort keys %Menus ) {

        # load module
        if ( $MainObject->Require( $Menus{$Menu}->{Module} ) ) {
            my $Object = $Menus{$Menu}->{Module}->new(
                %{$Self},
                WorkOrderID => $WorkOrderID,
            );

            # set classes
            if ( $Menus{$Menu}->{Target} ) {

                if ( $Menus{$Menu}->{Target} eq 'PopUp' ) {
                    $Menus{$Menu}->{MenuClass} = 'AsPopup';
                }
                elsif ( $Menus{$Menu}->{Target} eq 'Back' ) {
                    $Menus{$Menu}->{MenuClass} = 'HistoryBack';
                }
                elsif ( $Menus{$Menu}->{Target} eq 'ConfirmationDialog' ) {
                    $Menus{$Menu}->{MenuClass} = 'AsConfirmationDialog';
                }

            }

            # run module
            $Counter = $Object->Run(
                %Param,
                WorkOrder => $WorkOrder,
                Counter   => $Counter,
                Config    => $Menus{$Menu},
                MenuID    => $Menu,
            );
        }
        else {
            return $LayoutObject->FatalError();
        }
    }

    # generate content of ticket zoom tabs
    my $WorkOrderZoomBackendRef = $ConfigObject->Get('AgentITSMWorkOrderZoomBackend');
    if ( $WorkOrderZoomBackendRef && ref($WorkOrderZoomBackendRef) eq 'HASH' ) {
        for my $CurrKey ( sort keys %{$WorkOrderZoomBackendRef} ) {
            my $BackendShortRef = $WorkOrderZoomBackendRef->{$CurrKey};
            my $Access          = $WorkOrderObject->Permission(
                Type        => 'ro',
                WorkOrderID => $Param{WorkOrderID},
                UserID      => $Self->{UserID},
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

    return $LayoutObject->Output(
        TemplateFile => 'AgentITSMWorkOrderZoom',
        Data => { %Param, %{$WorkOrder} },
    );
}

sub _CountLinkedObjects {
    my ( $Self, %Param ) = @_;

    # get linked objects
    my $LinkListWithData = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkListWithData(
        Object => 'ITSMWorkOrder',
        Key    => $Param{WorkOrderID},
        State  => 'Valid',
        UserID => $Self->{UserID},
    );

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
