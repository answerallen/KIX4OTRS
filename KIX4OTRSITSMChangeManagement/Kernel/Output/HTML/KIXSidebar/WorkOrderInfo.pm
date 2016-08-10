# --
# Kernel/Output/HTML/KIXSidebar/WorkOrderInfo.pm
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Output::HTML::KIXSidebar::WorkOrderInfo;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerUser',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::LinkObject',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # create needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # get config options
    $Self->{Config} = $ConfigObject->Get('ITSMWorkOrder::Frontend::AgentITSMWorkOrderZoom');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # create needed objects
    my $ConfigObject              = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ChangeObject              = $Kernel::OM->Get('Kernel::System::ITSMChange');
    my $UserObject                = $Kernel::OM->Get('Kernel::System::User');
    my $CustomerUserObject        = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $LinkObject                = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $DynamicFieldObject        = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    my $WorkOrder = $Param{WorkOrder};
    my $Output;

    # get the change that workorder belongs to
    my $Change = $ChangeObject->ChangeGet(
        ChangeID => $WorkOrder->{ChangeID},
        UserID   => $Self->{UserID},
    );

    # get create user data
    my %CreateUser = $UserObject->GetUserData(
        UserID => $WorkOrder->{CreateBy},
        Cached => 1,
    );

    # get CreateBy user information
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $WorkOrder->{ 'Create' . $Postfix } = $CreateUser{$Postfix};
    }

    # get change user data
    my %ChangeUser = $UserObject->GetUserData(
        UserID => $WorkOrder->{ChangeBy},
        Cached => 1,
    );

    # get ChangeBy user information
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $WorkOrder->{ 'Change' . $Postfix } = $ChangeUser{$Postfix};
    }

    # output meta block
    $LayoutObject->Block(
        Name => 'Meta',
        Data => {
            %{$WorkOrder},
        },
    );

    # show values or dash ('-')
    for my $BlockName (
        qw(WorkOrderType PlannedStartTime PlannedEndTime ActualStartTime ActualEndTime)
        )
    {
        if ( $WorkOrder->{$BlockName} ) {
            $LayoutObject->Block(
                Name => $BlockName,
                Data => {
                    $BlockName => $WorkOrder->{$BlockName},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'Empty' . $BlockName,
            );
        }
    }

    # show configurable blocks
    BLOCKNAME:
    for my $BlockName (qw(PlannedEffort AccountedTime)) {

        # skip if block is switched off in SysConfig
        next BLOCKNAME if !$Self->{Config}->{$BlockName};

        # show block
        $LayoutObject->Block(
            Name => 'Show' . $BlockName,
        );

        # show value or dash
        if ( $WorkOrder->{$BlockName} ) {
            $LayoutObject->Block(
                Name => $BlockName,
                Data => {
                    $BlockName => $WorkOrder->{$BlockName},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'Empty' . $BlockName,
            );
        }
    }

    # get all workorder freekey and freetext numbers from workorder
    my %WorkOrderFreeTextFields;
    ATTRIBUTE:
    for my $Attribute ( keys %{$WorkOrder} ) {

        # get the freetext number, only look at the freetext field,
        # as we do not want to show empty fields in the zoom view
        if ( $Attribute =~ m{ \A WorkOrderFreeText ( \d+ ) }xms ) {

            # do not show empty freetext values
            next ATTRIBUTE if $WorkOrder->{$Attribute} eq '';

            # get the freetext number
            my $Number = $1;

            # remember the freetext number
            $WorkOrderFreeTextFields{$Number}++;
        }
    }

    # show workorder freetext fields block
    if (%WorkOrderFreeTextFields) {

        $LayoutObject->Block(
            Name => 'WorkOrderFreeTextFields',
            Data => {},
        );
    }

    # show the workorder freetext fields
    for my $Number ( sort { $a <=> $b } keys %WorkOrderFreeTextFields ) {

        $LayoutObject->Block(
            Name => 'WorkOrderFreeText' . $Number,
            Data => {
                %{$WorkOrder},
            },
        );
        $LayoutObject->Block(
            Name => 'WorkOrderFreeText',
            Data => {
                WorkOrderFreeKey  => $WorkOrder->{ 'WorkOrderFreeKey' . $Number },
                WorkOrderFreeText => $WorkOrder->{ 'WorkOrderFreeText' . $Number },
            },
        );

        # show freetext field as link
        if ( $ConfigObject->Get( 'WorkOrderFreeText' . $Number . '::Link' ) ) {

            $LayoutObject->Block(
                Name => 'WorkOrderFreeTextLink' . $Number,
                Data => {
                    %{$WorkOrder},
                },
            );
            $LayoutObject->Block(
                Name => 'WorkOrderFreeTextLink',
                Data => {
                    %{$WorkOrder},
                    WorkOrderFreeTextLink => $ConfigObject->Get(
                        'WorkOrderFreeText' . $Number . '::Link'
                    ),
                    WorkOrderFreeKey  => $WorkOrder->{ 'WorkOrderFreeKey' . $Number },
                    WorkOrderFreeText => $WorkOrder->{ 'WorkOrderFreeText' . $Number },
                },
            );
        }

        # show freetext field as plain text
        else {
            $LayoutObject->Block(
                Name => 'WorkOrderFreeTextPlain' . $Number,
                Data => {
                    %{$WorkOrder},
                },
            );
            $LayoutObject->Block(
                Name => 'WorkOrderFreeTextPlain',
                Data => {
                    %{$WorkOrder},
                    WorkOrderFreeKey  => $WorkOrder->{ 'WorkOrderFreeKey' . $Number },
                    WorkOrderFreeText => $WorkOrder->{ 'WorkOrderFreeText' . $Number },
                },
            );
        }
    }

    # get change builder user
    my %ChangeBuilderUser;
    if ( $Change->{ChangeBuilderID} ) {
        %ChangeBuilderUser = $UserObject->GetUserData(
            UserID => $Change->{ChangeBuilderID},
            Cached => 1,
        );
    }

    # get change builder information
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $WorkOrder->{ 'ChangeBuilder' . $Postfix } = $ChangeBuilderUser{$Postfix} || '';
    }

    # output change builder block
    if (%ChangeBuilderUser) {

        # show name and mail address if user exists
        $LayoutObject->Block(
            Name => 'ChangeBuilder',
            Data => {
                %{$WorkOrder},
            },
        );
    }
    else {

        # show dash if no change builder exists
        $LayoutObject->Block(
            Name => 'EmptyChangeBuilder',
            Data => {},
        );
    }

    # get workorder agent user
    if ( $WorkOrder->{WorkOrderAgentID} ) {
        my %WorkOrderAgentUser = $UserObject->GetUserData(
            UserID => $WorkOrder->{WorkOrderAgentID},
            Cached => 1,
        );

        if (%WorkOrderAgentUser) {

            # get WorkOrderAgent information
            for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
                $WorkOrder->{ 'WorkOrderAgent' . $Postfix } = $WorkOrderAgentUser{$Postfix} || '';
            }

            # output WorkOrderAgent information
            $LayoutObject->Block(
                Name => 'WorkOrderAgent',
                Data => {
                    %{$WorkOrder},
                },
            );
        }
    }

    # output if no WorkOrderAgent is found
    if ( !$WorkOrder->{WorkOrderAgentUserLogin} ) {
        $LayoutObject->Block(
            Name => 'EmptyWorkOrderAgent',
            Data => {},
        );
    }

    # get the dynamic fields for this screen
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => 'ITSMWorkOrder',
        FieldFilter => $Self->{Config}->{DynamicField} || {},
    );

    # cycle trough the activated Dynamic Fields
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $WorkOrder->{WorkOrderID},
        );

        # get print string for this dynamic field
        my $ValueStrg = $DynamicFieldBackendObject->DisplayValueRender(
            DynamicFieldConfig => $DynamicFieldConfig,
            Value              => $Value,
            ValueMaxChars      => 100,
            LayoutObject       => $LayoutObject,
        );

        # for empty values
        if ( !$ValueStrg->{Value} ) {
            $ValueStrg->{Value} = '-';
        }

        my $Label = $DynamicFieldConfig->{Label};

        $LayoutObject->Block(
            Name => 'DynamicField',
            Data => {
                Label => $Label,
            },
        );
        if ( $ValueStrg->{Link} ) {

            # output link element
            $LayoutObject->Block(
                Name => 'DynamicFieldLink',
                Data => {
                    %{$WorkOrder},
                    Value                       => $ValueStrg->{Value},
                    Title                       => $ValueStrg->{Title},
                    Link                        => $ValueStrg->{Link},
                    $DynamicFieldConfig->{Name} => $ValueStrg->{Title}
                },
            );
        }
        else {

            # output non link element
            $LayoutObject->Block(
                Name => 'DynamicFieldPlain',
                Data => {
                    Value => $ValueStrg->{Value},
                    Title => $ValueStrg->{Title},
                },
            );
        }

        # example of dynamic fields order customization
        $LayoutObject->Block(
            Name => 'DynamicField' . $DynamicFieldConfig->{Name},
            Data => {
                Label => $Label,
                Value => $ValueStrg->{Value},
                Title => $ValueStrg->{Title},
            },
        );
    }

    $Output = $LayoutObject->Output(
        TemplateFile => 'AgentKIXSidebarWorkOrderInfo',
        Data         => {
            %{ $Self->{Config} },
            %{$WorkOrder},
            %{ $Param{Config} }
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Output;
}

1;
