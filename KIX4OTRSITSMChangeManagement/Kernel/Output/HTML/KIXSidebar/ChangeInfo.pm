# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Output::HTML::KIXSidebar::ChangeInfo;

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
    $Self->{Config} = $ConfigObject->Get('ITSMChange::Frontend::AgentITSMChangeZoom');

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

    my $ChangeID = $Param{ChangeID};
    my $Output;

    # get the change that workorder belongs to
    my $Change = $ChangeObject->ChangeGet(
        ChangeID => $Param{ChangeID},
        UserID   => $Self->{UserID},
    );

    # get change builder data
    my %ChangeBuilderUser = $UserObject->GetUserData(
        UserID => $Change->{ChangeBuilderID},
        Cached => 1,
    );

    # get create user data
    my %CreateUser = $UserObject->GetUserData(
        UserID => $Change->{CreateBy},
        Cached => 1,
    );

    # get change user data
    my %ChangeUser = $UserObject->GetUserData(
        UserID => $Change->{ChangeBy},
        Cached => 1,
    );

    # all postfixes needed for user information
    my @Postfixes = qw(UserLogin UserFirstname UserLastname);

    # get user information for ChangeBuilder, CreateBy, ChangeBy
    for my $Postfix (@Postfixes) {
        $Change->{ 'ChangeBuilder' . $Postfix } = $ChangeBuilderUser{$Postfix};
        $Change->{ 'Create' . $Postfix }        = $CreateUser{$Postfix};
        $Change->{ 'Change' . $Postfix }        = $ChangeUser{$Postfix};
    }

    # output meta block
    $LayoutObject->Block(
        Name => 'Meta',
        Data => {
            %{$Change},
        },
    );

    # show values or dash ('-')
    for my $BlockName (qw(PlannedStartTime PlannedEndTime ActualStartTime ActualEndTime)) {
        if ( $Change->{$BlockName} ) {
            $LayoutObject->Block(
                Name => $BlockName,
                Data => {
                    $BlockName => $Change->{$BlockName},
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
    for my $BlockName (qw(RequestedTime PlannedEffort AccountedTime)) {

        # skip if block is switched off in SysConfig
        next BLOCKNAME if !$Self->{Config}->{$BlockName};

        # show block
        $LayoutObject->Block(
            Name => 'Show' . $BlockName,
        );

        # show value or dash
        if ( $Change->{$BlockName} ) {
            $LayoutObject->Block(
                Name => $BlockName,
                Data => {
                    $BlockName => $Change->{$BlockName},
                },
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'Empty' . $BlockName,
            );
        }
    }

    # show CIP
    for my $Type (qw(Category Impact Priority)) {
        $LayoutObject->Block(
            Name => $Type,
            Data => { %{$Change} },
        );
    }

    # get all change freekey and freetext numbers from change
    my %ChangeFreeTextFields;
    ATTRIBUTE:
    for my $Attribute ( keys %{$Change} ) {

        # get the freetext number, only look at the freetext field,
        # as we do not want to show empty fields in the zoom view
        if ( $Attribute =~ m{ \A ChangeFreeText ( \d+ ) }xms ) {

            # do not show empty freetext values (number zero is allowed)
            next ATTRIBUTE if $Change->{$Attribute} eq '';

            # get the freetext number
            my $Number = $1;

            # remember the freetext number
            $ChangeFreeTextFields{$Number}++;
        }
    }

    # show change freetext fields block
    if (%ChangeFreeTextFields) {

        $LayoutObject->Block(
            Name => 'ChangeFreeTextFields',
            Data => {},
        );
    }

    # show the change freetext fields
    for my $Number ( sort { $a <=> $b } keys %ChangeFreeTextFields ) {

        $LayoutObject->Block(
            Name => 'ChangeFreeText' . $Number,
            Data => {
                %{$Change},
            },
        );
        $LayoutObject->Block(
            Name => 'ChangeFreeText',
            Data => {
                ChangeFreeKey  => $Change->{ 'ChangeFreeKey' . $Number },
                ChangeFreeText => $Change->{ 'ChangeFreeText' . $Number },
            },
        );

        # show freetext field as link
        if ( $ConfigObject->Get( 'ChangeFreeText' . $Number . '::Link' ) ) {

            $LayoutObject->Block(
                Name => 'ChangeFreeTextLink' . $Number,
                Data => {
                    %{$Change},
                },
            );
            $LayoutObject->Block(
                Name => 'ChangeFreeTextLink',
                Data => {
                    %{$Change},
                    ChangeFreeTextLink => $ConfigObject->Get(
                        'ChangeFreeText' . $Number . '::Link'
                    ),
                    ChangeFreeKey  => $Change->{ 'ChangeFreeKey' . $Number },
                    ChangeFreeText => $Change->{ 'ChangeFreeText' . $Number },
                },
            );
        }

        # show freetext field as plain text
        else {
            $LayoutObject->Block(
                Name => 'ChangeFreeTextPlain' . $Number,
                Data => {
                    %{$Change},
                },
            );
            $LayoutObject->Block(
                Name => 'ChangeFreeTextPlain',
                Data => {
                    %{$Change},
                    ChangeFreeKey  => $Change->{ 'ChangeFreeKey' . $Number },
                    ChangeFreeText => $Change->{ 'ChangeFreeText' . $Number },
                },
            );
        }
    }

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
    for my $LinkType ( keys %{$TicketsRef} ) {

        my $TicketRef = $TicketsRef->{$LinkType}->{Source};
        for my $TicketID ( keys %{$TicketRef} ) {

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
        $LayoutObject->Block(
            Name => 'ChangeInitiatorExists',
        );
    }

    my $ChangeInitiators = '';
    for my $UserID ( keys %ChangeInitiatorsID ) {
        my %User;

        # get customer user info if CI is a customer user
        if ( $ChangeInitiatorsID{$UserID} eq 'CustomerUser' ) {
            %User = $CustomerUserObject->CustomerUserDataGet(
                User => $UserID,
            );
        }

        # otherwise get user info
        else {
            %User = $UserObject->GetUserData(
                UserID => $UserID,
            );
        }

        # if user info exist
        if (%User) {
            $LayoutObject->Block(
                Name => 'ChangeInitiator',
                Data => {%User},
            );

            $ChangeInitiators .= sprintf "%s (%s %s)",
                $User{UserLogin},
                $User{UserFirstname},
                $User{UserLastname};
        }
    }

    # show dash if no change initiator exists
    if ( !$ChangeInitiators ) {
        $LayoutObject->Block(
            Name => 'EmptyChangeInitiators',
        );
    }

    # display a string with all changeinitiators
    $Change->{'Change Initators'} = $ChangeInitiators;

    # get change manager data
    my %ChangeManagerUser;
    if ( $Change->{ChangeManagerID} ) {

        # get change manager data
        %ChangeManagerUser = $UserObject->GetUserData(
            UserID => $Change->{ChangeManagerID},
            Cached => 1,
        );
    }

    # get change manager information
    for my $Postfix (qw(UserLogin UserFirstname UserLastname)) {
        $Change->{ 'ChangeManager' . $Postfix } = $ChangeManagerUser{$Postfix} || '';
    }

    # output change manager block
    if (%ChangeManagerUser) {

        # show name and mail address if user exists
        $LayoutObject->Block(
            Name => 'ChangeManager',
            Data => {
                %{$Change},
            },
        );
    }
    else {

        # show dash if no change manager exists
        $LayoutObject->Block(
            Name => 'EmptyChangeManager',
            Data => {},
        );
    }

    # show CAB block when there is a CAB
    if ( @{ $Change->{CABAgents} } || @{ $Change->{CABCustomers} } ) {

        # output CAB block
        $LayoutObject->Block(
            Name => 'CAB',
            Data => {
                %{$Change},
            },
        );

        # build and output CAB agents
        CABAGENT:
        for my $CABAgent ( @{ $Change->{CABAgents} } ) {
            next CABAGENT if !$CABAgent;

            my %CABAgentUserData = $UserObject->GetUserData(
                UserID => $CABAgent,
                Cache  => 1,
            );

            next CABAGENT if !%CABAgentUserData;

            # build content for agent block
            my %CABAgentData;
            for my $Postfix (@Postfixes) {
                $CABAgentData{ 'CABAgent' . $Postfix } = $CABAgentUserData{$Postfix};
            }

            # output agent block
            $LayoutObject->Block(
                Name => 'CABAgent',
                Data => {
                    %CABAgentData,
                },
            );
        }

        # build and output CAB customers
        CABCUSTOMER:
        for my $CABCustomer ( @{ $Change->{CABCustomers} } ) {
            next CABCUSTOMER if !$CABCustomer;

            my %CABCustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                User => $CABCustomer,
            );

            next CABCUSTOMER if !%CABCustomerUserData;

            # build content for CAB customer block
            my %CABCustomerData;
            for my $Postfix (@Postfixes) {
                $CABCustomerData{ 'CABCustomer' . $Postfix } = $CABCustomerUserData{$Postfix};
            }

            # output CAB customer block
            $LayoutObject->Block(
                Name => 'CABCustomer',
                Data => {
                    %CABCustomerData,
                },
            );
        }
    }

    # show dash when no CAB exists
    else {
        $LayoutObject->Block(
            Name => 'EmptyCAB',
        );
    }

    # get the dynamic fields for this screen
    my $DynamicField = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => 'ITSMChange',
        FieldFilter => $Self->{Config}->{DynamicField} || {},
    );

    # cycle trough the activated Dynamic Fields
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{$DynamicField} ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $Value = $DynamicFieldBackendObject->ValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ObjectID           => $ChangeID,
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
                    %{$Change},
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
        TemplateFile => 'AgentKIXSidebarChangeInfo',
        Data         => {
            %{ $Self->{Config} },
            %{$Change},
            %{ $Param{Config} }
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Output;
}

1;
