# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::DynamicFieldObjectReferenceAJAXHandler;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # create needed objects
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    $Self->{CallingAction}    = $ParamObject->GetParam( Param => 'CallingAction' )    || '';
    $Self->{DirectLinkAnchor} = $ParamObject->GetParam( Param => 'DirectLinkAnchor' ) || '';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $BackendObject      = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $EncodeObject       = $Kernel::OM->Get('Kernel::System::Encode');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');

    my $JSON = '0';

    # get needed params
    my $Search = $ParamObject->GetParam( Param => 'Term' ) || '';
    $Search = '*' . $Search . '*';
    my $MaxResults = int( $ParamObject->GetParam( Param => 'MaxResults' ) || 20 );
    my $ObjectReference = $ParamObject->GetParam( Param => 'ObjectReference' )
        ;    # User, CustomerUser, CustomerCompany
    my $CallingAction = $ParamObject->GetParam( Param => 'CallingAction' );
    my $FormData
        = $ParamObject->GetParam( Param => 'FormData' );    # separated string with all form data
    my $DynamicField
        = $ParamObject->GetParam( Param => 'DynamicField' );    # name of autocomplete field

    if ( $DynamicField =~ m/^DynamicField_(.*)/ ) {
        $DynamicField = $1;
    }

# extract keys and values from form data string, template is needed for EditFieldValueGet() to use existing value and not one from ParamObject
    my %GetParam;
    my %Template;
    my @FormDataArray = split( /;/, $FormData );
    for my $Key (@FormDataArray) {
        if ( $Key =~ m/(.*?)=(.*)/ ) {
            $GetParam{$1} = $2;
            $Template{$1} = $2;
        }
    }

    if ( $CallingAction eq 'KIXSidebarDynamicFieldAJAXHandler' ) {
        $CallingAction = 'KIXSidebarDynamicField';
    }

    # get the dynamic fields for this screen
    $Self->{Config}       = $ConfigObject->Get("Ticket::Frontend::$CallingAction");
    $Self->{DynamicField} = $DynamicFieldObject->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => ['Ticket'],
        FieldFilter => $Self->{Config}->{DynamicField} || {},
    );

    # get Dynamic fields
    my %DynamicFieldValues;

    # cycle trough the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # extract the dynamic field value form the web request
        $DynamicFieldValues{ $DynamicFieldConfig->{Name} }
            = $BackendObject->EditFieldValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ParamObject        => $ParamObject,
            LayoutObject       => $LayoutObject,
            Template           => \%Template
            );
    }

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldACLParameters;
    DYNAMICFIELD:
    for my $DynamicField ( sort keys %DynamicFieldValues ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField }
            = $DynamicFieldValues{$DynamicField};
    }
    $GetParam{DynamicField} = \%DynamicFieldACLParameters;

    my %PossibleValuesHash;
    my %DynamicFieldHash;

    # get possible values
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {

        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
        next DYNAMICFIELD if $DynamicFieldConfig->{Name} ne $DynamicField;

        my $PossibleValuesFilter;

        my $IsACLReducible = $BackendObject->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );

        if ($IsACLReducible) {

            # get PossibleValues
            my $PossibleValues = $BackendObject->PossibleValuesGet(
                DynamicFieldConfig    => $DynamicFieldConfig,
                Search                => $Search,
                GetAutocompleteValues => 1
            );

            $DynamicFieldHash{ $DynamicFieldConfig->{ID} } = $DynamicFieldConfig->{Name};

            # check if field has PossibleValues property in its configuration
            if ( IsHashRefWithData($PossibleValues) ) {

                # convert possible values key => value to key => key for ACLs using a Hash slice
                my %AclData = %{$PossibleValues};
                @AclData{ keys %AclData } = keys %AclData;

                # set possible values filter from ACLs
                my $ACL;
                if ( $CallingAction =~ /^CustomerTicket/ ) {
                    my $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        Action         => $CallingAction,
                        ReturnType     => 'Ticket',
                        ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data           => \%AclData,
                        CustomerUserID => $Self->{UserID},
                    );
                }
                else {
                    my $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        Action        => $CallingAction,
                        ReturnType    => 'Ticket',
                        ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data          => \%AclData,
                        UserID        => $Self->{UserID},
                    );
                }

                if ($ACL) {
                    my %Filter = $TicketObject->TicketAclData();

                    # convert Filer key => key back to key => value using map
                    %{$PossibleValuesFilter}
                        = map { $_ => $PossibleValues->{$_} }
                        keys %Filter;

                    $PossibleValuesHash{ $DynamicFieldConfig->{Name} } = $PossibleValuesFilter;
                }
                else {
                    $PossibleValuesHash{ $DynamicFieldConfig->{Name} } = $PossibleValues;
                }
            }
        }
    }

    # workaround, all auto completion requests get posted by utf8 anyway
    # convert any to 8bit string if application is not running in utf8
    $Search = $EncodeObject->Convert(
        Text => $Search,
        From => 'utf-8',
        To   => $LayoutObject->{UserCharset},
    );

    # get result list
    my %ObjectList;

    # search customer users
    if ( $ObjectReference eq 'CustomerUser' ) {
        %ObjectList = $CustomerUserObject->CustomerSearch(
            Search => $Search,
        );
    }

    # search users
    elsif ( $ObjectReference eq 'User' ) {
        my %UserList = $UserObject->UserSearch(
            Search => $Search,
        );

        for my $User ( keys %UserList ) {
            my %UserData = $UserObject->GetUserData(
                UserID => $User,
            );

            $ObjectList{ $UserData{UserLogin} }
                = $UserData{UserFirstname} . " "
                . $UserData{UserLastname} . " <"
                . $UserData{UserEmail} . ">";
        }
    }

    # search customer companies
    elsif ( $ObjectReference eq 'CustomerCompany' ) {
        my %CompanyList = $CustomerCompanyObject->CustomerCompanyList(
            Search => $Search,
        );

        for my $Company ( keys %CompanyList ) {
            $ObjectList{$Company} = $CompanyList{$Company};
        }

    }

    # eliminate values if they are not in possible list
    %ObjectList
        = map { $_ => $ObjectList{$_} } grep { defined $PossibleValuesHash{$DynamicField}->{$_} }
        keys %ObjectList;

    # create data hash for return
    my %DataHash = ();
    if ( scalar keys %ObjectList ) {

        # build data
        for my $DynamicFieldName ( keys %PossibleValuesHash ) {

            my $MaxResultCount = $MaxResults;
            my @Data;

            # create data for autocomplete field
            if ( $DynamicField eq $DynamicFieldName ) {
                for my $ObjectID (
                    sort { $ObjectList{$a} cmp $ObjectList{$b} }
                    keys %ObjectList
                    )
                {
                    push @Data, {
                        Key   => $ObjectID,
                        Value => $ObjectList{$ObjectID},
                    };

                    $MaxResultCount--;
                    last if $MaxResultCount <= 0;
                }
            }

            # create data for other fields affected by depending field acl
            else {
                for my $PossibleValue (
                    sort {
                        $PossibleValuesHash{$DynamicFieldName}->{$a}
                            cmp $PossibleValuesHash{$DynamicFieldName}->{$b}
                    }
                    keys %{ $PossibleValuesHash{$DynamicFieldName} }
                    )
                {
                    push @Data, {
                        Key   => $PossibleValue,
                        Value => $PossibleValuesHash{$DynamicFieldName}->{$PossibleValue},
                    };

                    $MaxResultCount--;
                    last if $MaxResultCount <= 0;
                }
            }

            # add data array to data hash
            $DataHash{$DynamicFieldName} = \@Data;
        }
    }

    # build JSON output
    $JSON = $LayoutObject->JSONEncode(
        Data => \%DataHash,
    );

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );

}

1;
