# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Ricky(dot)Kaiser(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketEmail;
## nofilter(TidyAll::Plugin::OTRS::Perl::DBObject)

use strict;
use warnings;

use Mail::Address;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

# KIX4OTRS-capeIT
use base qw(Kernel::Modules::BaseTicketTemplateHandler);
# EO KIX4OTRS-capeIT

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    # get the dynamic fields for this screen
    $Self->{DynamicField} = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet(
        Valid       => 1,
        ObjectType  => [ 'Ticket', 'Article' ],
        FieldFilter => $Config->{DynamicField} || {},
    );

    # get form id
    $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'FormID' );

    # create form id
    if ( !$Self->{FormID} ) {
        $Self->{FormID} = $Kernel::OM->Get('Kernel::System::Web::UploadCache')->FormIDCreate();
    }

    # KIX4OTRS-capeIT
    # handle for quick ticket templates
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    $Self->{DefaultSet} = $ParamObject->GetParam( Param => 'DefaultSet' ) || 0;
    $Self->{DefaultSetTypeChanged} =
        $ParamObject->GetParam( Param => 'DefaultSetTypeChanged' ) || 0;
    $Self->{ActionReal} = $Self->{Action};

    # EO KIX4OTRS-capeIT

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    # store last queue screen
    if ( $Self->{LastScreenOverview} && $Self->{LastScreenOverview} !~ /Action=AgentTicketEmail/ ) {
        $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastScreenOverview',
            Value     => $Self->{RequestedURL},
        );
    }

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get upload cache object
    my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

    # get needed objects
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $QueueObject  = $Kernel::OM->Get('Kernel::System::Queue');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Debug = $Param{Debug} || 0;
    my $Config = $ConfigObject->Get("Ticket::Frontend::$Self->{Action}");

    # get params
    my %GetParam;
    for my $Key (
        qw(Year Month Day Hour Minute To Cc Bcc TimeUnits PriorityID Subject Body
        TypeID ServiceID SLAID OwnerAll ResponsibleAll NewResponsibleID NewUserID
        NextStateID StandardTemplateID
        Dest DefaultSetTypeChanged SelectedConfigItemIDs CustomerID
        )
        )
    {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # KIX4OTRS-capeIT
    my @SelectedCIIDs;
    if ( defined $GetParam{SelectedConfigItemIDs} && $GetParam{SelectedConfigItemIDs} ) {
        my $ConfigItemIDStrg = $GetParam{SelectedConfigItemIDs};
        $ConfigItemIDStrg =~ s/^,//g;
        @SelectedCIIDs = split( ',', $ConfigItemIDStrg );
    }
    $GetParam{DefaultSet} = $Self->{DefaultSet} || 0;
    $GetParam{LinkTicketID} = $ParamObject->GetParam( Param => 'LinkTicketID' ) || '';

    # EO KIX4OTRS-capeIT

    # ACL compatibility translation
    my %ACLCompatGetParam;
    $ACLCompatGetParam{OwnerID} = $GetParam{NewUserID};

    # If is an action about attachments
    my $IsUpload = ( $ParamObject->GetParam( Param => 'AttachmentUpload' ) ? 1 : 0 );

    # hash for check duplicated entries
    my %AddressesList;

    # MultipleCustomer To-field
    my @MultipleCustomer;
    my $CustomersNumber = $ParamObject->GetParam( Param => 'CustomerTicketCounterToCustomer' ) || 0;
    my $Selected = $ParamObject->GetParam( Param => 'CustomerSelected' ) || '';

    # get check item object
    my $CheckItemObject = $Kernel::OM->Get('Kernel::System::CheckItem');

    if ($CustomersNumber) {
        my $CustomerCounter = 1;
        for my $Count ( 1 ... $CustomersNumber ) {
            my $CustomerElement = $ParamObject->GetParam( Param => 'CustomerTicketText_' . $Count );
            my $CustomerSelected = ( $Selected eq $Count ? 'checked="checked"' : '' );
            my $CustomerKey = $ParamObject->GetParam( Param => 'CustomerKey_' . $Count )
                || '';

            if ($CustomerElement) {

                if ( $GetParam{To} ) {
                    $GetParam{To} .= ', ' . $CustomerElement;
                }
                else {
                    $GetParam{To} = $CustomerElement;
                }

                my $CustomerErrorMsg = 'CustomerGenericServerErrorMsg';
                my $CustomerError    = '';
                my $CustomerDisabled = '';
                my $CountAux         = $CustomerCounter++;

                if ( !$IsUpload ) {

                    # check email address
                    for my $Email ( Mail::Address->parse($CustomerElement) ) {
                        if ( !$CheckItemObject->CheckEmail( Address => $Email->address() ) )
                        {
                            $CustomerErrorMsg = $CheckItemObject->CheckErrorType()
                                . 'ServerErrorMsg';
                            $CustomerError = 'ServerError';
                        }
                    }

                    # check for duplicated entries
                    if ( defined $AddressesList{$CustomerElement} && $CustomerError eq '' ) {
                        $CustomerErrorMsg = 'IsDuplicatedServerErrorMsg';
                        $CustomerError    = 'ServerError';
                    }

                    if ( $CustomerError ne '' ) {
                        $CustomerDisabled = 'disabled="disabled"';
                        $CountAux         = $Count . 'Error';
                    }
                }

                push @MultipleCustomer, {
                    Count            => $CountAux,
                    CustomerElement  => $CustomerElement,
                    CustomerSelected => $CustomerSelected,
                    CustomerKey      => $CustomerKey,
                    CustomerError    => $CustomerError,
                    CustomerErrorMsg => $CustomerErrorMsg,
                    CustomerDisabled => $CustomerDisabled,
                };
                $AddressesList{$CustomerElement} = 1;
            }
        }
    }

    # MultipleCustomer Cc-field
    my @MultipleCustomerCc;
    my $CustomersNumberCc = $ParamObject->GetParam( Param => 'CustomerTicketCounterCcCustomer' ) || 0;

    if ($CustomersNumberCc) {
        my $CustomerCounterCc = 1;
        for my $Count ( 1 ... $CustomersNumberCc ) {
            my $CustomerElementCc = $ParamObject->GetParam( Param => 'CcCustomerTicketText_' . $Count );
            my $CustomerKeyCc     = $ParamObject->GetParam( Param => 'CcCustomerKey_' . $Count )
                || '';

            if ($CustomerElementCc) {
                my $CustomerErrorMsgCc = 'CustomerGenericServerErrorMsg';
                my $CustomerErrorCc    = '';
                my $CustomerDisabledCc = '';
                my $CountAuxCc         = $CustomerCounterCc++;

                if ( !$IsUpload ) {

                    if ( $GetParam{Cc} ) {
                        $GetParam{Cc} .= ', ' . $CustomerElementCc;
                    }
                    else {
                        $GetParam{Cc} = $CustomerElementCc;
                    }

                    # check email address
                    for my $Email ( Mail::Address->parse($CustomerElementCc) ) {
                        if ( !$CheckItemObject->CheckEmail( Address => $Email->address() ) )
                        {
                            $CustomerErrorMsgCc = $CheckItemObject->CheckErrorType()
                                . 'ServerErrorMsg';
                            $CustomerErrorCc = 'ServerError';
                        }
                    }

                    # check for duplicated entries
                    if ( defined $AddressesList{$CustomerElementCc} && $CustomerErrorCc eq '' ) {
                        $CustomerErrorMsgCc = 'IsDuplicatedServerErrorMsg';
                        $CustomerErrorCc    = 'ServerError';
                    }

                    if ( $CustomerErrorCc ne '' ) {
                        $CustomerDisabledCc = 'disabled="disabled"';
                        $CountAuxCc         = $Count . 'Error';
                    }
                }

                push @MultipleCustomerCc, {
                    Count            => $CountAuxCc,
                    CustomerElement  => $CustomerElementCc,
                    CustomerKey      => $CustomerKeyCc,
                    CustomerError    => $CustomerErrorCc,
                    CustomerErrorMsg => $CustomerErrorMsgCc,
                    CustomerDisabled => $CustomerDisabledCc,
                };
                $AddressesList{$CustomerElementCc} = 1;
            }
        }
    }

    # MultipleCustomer Bcc-field
    my @MultipleCustomerBcc;
    my $CustomersNumberBcc = $ParamObject->GetParam( Param => 'CustomerTicketCounterBccCustomer' ) || 0;

    if ($CustomersNumberBcc) {
        my $CustomerCounterBcc = 1;
        for my $Count ( 1 ... $CustomersNumberBcc ) {
            my $CustomerElementBcc = $ParamObject->GetParam( Param => 'BccCustomerTicketText_' . $Count );
            my $CustomerKeyBcc     = $ParamObject->GetParam( Param => 'BccCustomerKey_' . $Count )
                || '';

            if ($CustomerElementBcc) {

                my $CustomerDisabledBcc = '';
                my $CountAuxBcc         = $CustomerCounterBcc++;
                my $CustomerErrorMsgBcc = 'CustomerGenericServerErrorMsg';
                my $CustomerErrorBcc    = '';
                if ( !$IsUpload ) {

                    if ( $GetParam{Bcc} ) {
                        $GetParam{Bcc} .= ', ' . $CustomerElementBcc;
                    }
                    else {
                        $GetParam{Bcc} = $CustomerElementBcc;
                    }

                    # check email address
                    for my $Email ( Mail::Address->parse($CustomerElementBcc) ) {
                        if ( !$CheckItemObject->CheckEmail( Address => $Email->address() ) )
                        {
                            $CustomerErrorMsgBcc = $CheckItemObject->CheckErrorType()
                                . 'ServerErrorMsg';
                            $CustomerErrorBcc = 'ServerError';
                        }
                    }

                    # check for duplicated entries
                    if ( defined $AddressesList{$CustomerElementBcc} && $CustomerErrorBcc eq '' ) {
                        $CustomerErrorMsgBcc = 'IsDuplicatedServerErrorMsg';
                        $CustomerErrorBcc    = 'ServerError';
                    }

                    if ( $CustomerErrorBcc ne '' ) {
                        $CustomerDisabledBcc = 'disabled="disabled"';
                        $CountAuxBcc         = $Count . 'Error';
                    }
                }

                push @MultipleCustomerBcc, {
                    Count            => $CountAuxBcc,
                    CustomerElement  => $CustomerElementBcc,
                    CustomerKey      => $CustomerKeyBcc,
                    CustomerError    => $CustomerErrorBcc,
                    CustomerErrorMsg => $CustomerErrorMsgBcc,
                    CustomerDisabled => $CustomerDisabledBcc,
                };
                $AddressesList{$CustomerElementBcc} = 1;
            }
        }
    }

    # set an empty value if not defined
    $GetParam{Cc}  = '' if !defined $GetParam{Cc};
    $GetParam{Bcc} = '' if !defined $GetParam{Bcc};

    # get Dynamic fields form ParamObject
    my %DynamicFieldValues;

    # get needed objects
    my $DynamicFieldBackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
    my $LayoutObject              = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # KIX4OTRS-capeIT
    # get needed objects
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    # handle email quick ticket configuration
    if ( $Self->{Action} eq 'AgentTicketEmailQuick' ) {
        $Self->{Action} = 'AgentTicketEmail';
        $Config = $ConfigObject->Get("Ticket::Frontend::$Self->{Action}");
        my $QuickConfig = $ConfigObject->Get('Ticket::Frontend::AgentTicketEmailQuick')
            || '';
        if ( $QuickConfig && ref($QuickConfig) eq 'HASH' ) {
            for my $Key ( keys %{$QuickConfig} ) {
                $Config->{$Key} = $QuickConfig->{$Key};
            }
        }
    }

    # get all dynamic fields
    $Self->{NotShownDynamicFields} = $DynamicFieldObject->DynamicFieldList(
        Valid      => 1,
        ObjectType => [ 'Ticket', 'Article' ],
        ResultType => 'HASH',
    );

    # create a lookup list
    %{ $Self->{NotShownDynamicFields} } = reverse %{ $Self->{NotShownDynamicFields} };

    for my $DynamicField ( sort keys %{ $Config->{DynamicField} } ) {

        # check if each field is active
        if ( $Config->{DynamicField}->{$DynamicField} ) {

            # remove all the fields that are actived for this screen
            delete $Self->{NotShownDynamicFields}->{$DynamicField};
        }
    }

    # prevent comparison errors by filling the non existent dynamic fields in the screen
    # configuration
    for my $DynamicField ( sort keys %{ $Self->{NotShownDynamicFields} } ) {
        if ( !defined $Config->{DynamicField}->{$DynamicField} ) {
            $Config->{DynamicField}->{$DynamicField} = 0;
        }
    }

    # Core.AJAX.js does not admit an empty string, then is necessary to define a string that
    # will set to empty right before is assigned to the HTML element (non select).
    $Self->{EmptyString} = '_DynamicTicketTemplate_EmptyString_Dont_Use_It_Please';

    # EO KIX4OTRS-capeIT

    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # extract the dynamic field value form the web request
        $DynamicFieldValues{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldValueGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            ParamObject        => $ParamObject,
            LayoutObject       => $LayoutObject,
        );
    }

    # convert dynamic field values into a structure for ACLs
    my %DynamicFieldACLParameters;
    DYNAMICFIELD:
    for my $DynamicField ( sort keys %DynamicFieldValues ) {
        next DYNAMICFIELD if !$DynamicField;
        next DYNAMICFIELD if !$DynamicFieldValues{$DynamicField};

        $DynamicFieldACLParameters{ 'DynamicField_' . $DynamicField } = $DynamicFieldValues{$DynamicField};
    }
    $GetParam{DynamicField} = \%DynamicFieldACLParameters;

    # transform pending time, time stamp based on user time zone
    if (
        defined $GetParam{Year}
        && defined $GetParam{Month}
        && defined $GetParam{Day}
        && defined $GetParam{Hour}
        && defined $GetParam{Minute}
        )
    {
        %GetParam = $LayoutObject->TransformDateSelection(
            %GetParam,
        );
    }

    # KIX4OTRS-capeIT

    # moved from below
    # get user preferences
    my %UserPreferences = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
        UserID => $Self->{UserID},
    );

    if ( $Self->{DefaultSet} && ( !$Self->{Subaction} || $Self->{Subaction} ne 'AJAXUpdate' ) )
    {

        my %TemplateData = $Self->TicketTemplateReplace(
            IsUpload         => $IsUpload,
            Data             => \%GetParam,
            DefaultSet       => $Self->{DefaultSet},
            MultipleCustomer => \@MultipleCustomer,
            MultipleCustomerCc => \@MultipleCustomerCc,
            MultipleCustomerBcc => \@MultipleCustomerBcc,
        );

        for my $Key ( keys %TemplateData ) {
            next if $Key =~ m/^MultipleCustomer(Bc|C)?c?$/;
            $GetParam{$Key} = $TemplateData{$Key};
        }
        @MultipleCustomer       = @{ $TemplateData{MultipleCustomer} } if defined $TemplateData{MultipleCustomer} && ref $TemplateData{MultipleCustomer}  eq 'ARRAY';
        @MultipleCustomerCc     = @{ $TemplateData{MultipleCustomerCc} } if defined $TemplateData{MultipleCustomerCc} && ref $TemplateData{MultipleCustomerCc}  eq 'ARRAY';
        @MultipleCustomerBcc    = @{ $TemplateData{MultipleCustomerBcc} } if defined $TemplateData{MultipleCustomerBcc} && ref $TemplateData{MultipleCustomerBcc}  eq 'ARRAY';
    }

    # EO KIX4OTRS-capeIT

    if ( !$Self->{Subaction} || $Self->{Subaction} eq 'Created' ) {

        # header
        $Output .= $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        # KIX4OTRS-capeIT
        # ticket split based on given ticket ID and without given article ID
        $GetParam{ArticleID} = $ParamObject->GetParam( Param => 'ArticleID' ) || '';
        $GetParam{LinkTicketID} = $ParamObject->GetParam( Param => 'LinkTicketID' )
            || '';
        if (
            $GetParam{ArticleID}
            && $GetParam{ArticleID} eq 'Split'
            && $GetParam{LinkTicketID}
            )
        {
            my %Article = $TicketObject->ArticleFirstArticle(
                TicketID => $GetParam{LinkTicketID},
            );
            $GetParam{ArticleID} = $Article{ArticleID} || '';
        }

        # get split article if given
        my %Article;
        my %CustomerData;
        if ( $GetParam{ArticleID} && $GetParam{ArticleID} ne 'Split' ) {
            %Article = $TicketObject->ArticleGet( ArticleID => $GetParam{ArticleID} );
            $GetParam{QuickTicketSubject} ||= $TicketObject->TicketSubjectClean(
                TicketNumber => $Article{TicketNumber},
                Subject => $Article{Subject} || '',
            );

            # body preparation for plain text processing
            $GetParam{QuickTicketBody} ||= $LayoutObject->ArticleQuote(
                TicketID           => $Article{TicketID},
                ArticleID          => $GetParam{ArticleID},
                FormID             => $Self->{FormID},
                UploadCacheObject  => $UploadCacheObject,
                AttachmentsInclude => 1,
            );

            # show customer info
            if ( $Article{CustomerUserID} ) {
                $GetParam{QuickTicketCustomer} = $Article{CustomerUserID};
            }

            # for initial service and SLA search
            $GetParam{QuickTicketServiceID} = $Article{ServiceID} || '';
            $GetParam{QuickTicketSLAID}     = $Article{SLAID}     || '';
        }

        # EO KIX4OTRS-capeIT

        # if there is no ticket id!
        if ( !$Self->{TicketID} || ( $Self->{TicketID} && $Self->{Subaction} eq 'Created' ) ) {

            # notify info
            if ( $Self->{TicketID} ) {
                my %Ticket = $TicketObject->TicketGet( TicketID => $Self->{TicketID} );
                $Output .= $LayoutObject->Notify(
                    Info => $LayoutObject->{LanguageObject}->Translate(
                        'Ticket "%s" created!',
                        $Ticket{TicketNumber},
                    ),
                    Link => $LayoutObject->{Baselink}
                        . 'Action=AgentTicketZoom;TicketID='
                        . $Ticket{TicketID},
                );
            }

            # KIX4OTRS-capeIT
            # get needed objects
            my $TypeObject = $Kernel::OM->Get('Kernel::System::Type');
            my $StateObject = $Kernel::OM->Get('Kernel::System::State');
            my $ServiceObject = $Kernel::OM->Get('Kernel::System::Service');
            my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
            my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

            # get customer from quick ticket
            my %CustomerData = ();
            if ( $GetParam{QuickTicketCustomer} ) {
                %CustomerData = $CustomerUserObject->CustomerUserDataGet(
                    User => $GetParam{QuickTicketCustomer},
                );
                if (
                    $CustomerData{UserCustomerID}
                    && $CustomerData{UserID}
                    && $CustomerData{UserEmail}
                    )
                {
                    my $CustomerName = $CustomerUserObject
                        ->CustomerName( UserLogin => $CustomerData{UserID} );
                    $GetParam{To}
                        = '"' . $CustomerName . '" '
                        . '<' . $CustomerData{UserEmail} . '>';
                    $GetParam{CustomerID}            = $CustomerData{UserCustomerID};
                    $GetParam{CustomerUserID}        = $CustomerData{UserID};
                    $CustomerData{CustomerUserLogin} = $CustomerData{UserID};
                }
                else {
                    $GetParam{To} = $GetParam{QuickTicketCustomer};
                }
            }

            # get default queue and build selected string
            $GetParam{DefaultQueue}
                = $ConfigObject->Get('Ticket::CreateOptions::DefaultQueue')
                || '';
            if ( $Self->{QueueID} ) {
                my $QueueName = $QueueObject->QueueLookup(
                    QueueID => $Self->{QueueID}
                );
                $GetParam{DefaultQueueSelected} = $Self->{QueueID} . "||" . $QueueName;
            }
            elsif ( $GetParam{DefaultQueue} ) {
                my $QueueID = $QueueObject->QueueLookup(
                    Queue => $GetParam{DefaultQueue}
                );
                $Self->{QueueID} = $QueueID;
                $GetParam{DefaultQueueSelected}
                    = $Self->{QueueID} . "||" . $GetParam{DefaultQueue};
                $GetParam{DefaultQueueSet} = 1;
            }

            # get default ticket type and lookup type ID
            $GetParam{DefaultTicketType} =
                $ConfigObject->Get('Ticket::CreateOptions::DefaultTicketType') || '';

            if ( !$GetParam{DefaultTypeID} && $GetParam{DefaultTicketType} ) {

                # Blanks remove
                $GetParam{DefaultTicketType} =~ s/^\s+|\s+$//g;

                # select TypeID from Name
                my $DefaultTypeID = '';
                my $TypeList      = $Self->_GetTypes(
                    QueueID => $Self->{QueueID} || 1,
                    DefaultSet => $Self->{DefaultSet}
                );
                for my $ID ( keys %{$TypeList} ) {
                    my $Name = $TypeList->{$ID};
                    if ( $Name eq $GetParam{DefaultTicketType} ) {
                        $DefaultTypeID = $ID;
                        last;
                    }
                }
                $GetParam{DefaultTypeID} = $DefaultTypeID;
            }

            # check for default ticketstate for this tickettype
            my $DefaultStateRef =
                $ConfigObject->Get('TicketStateWorkflow::DefaultTicketState');
            my $DefaultStateExtendedRef
                = $ConfigObject->Get('TicketStateWorkflowExtension::DefaultTicketState');
            if ( defined $DefaultStateExtendedRef && ref $DefaultStateExtendedRef eq 'HASH' ) {
                for my $Extension ( sort keys %{$DefaultStateExtendedRef} ) {
                    for my $Type ( keys %{ $DefaultStateExtendedRef->{$Extension} } ) {
                        $DefaultStateRef->{$Type} = $DefaultStateExtendedRef->{$Extension}->{$Type};
                    }
                }
            }
            my $DefaultStateName = '';
            my $DefaultStateID   = '';
            if ( $GetParam{DefaultTypeID} ) {
                my %Type = $TypeObject->TypeGet(
                    ID => $GetParam{DefaultTypeID},
                );
                if ( $DefaultStateRef->{ $Type{Name} } ) {
                    $DefaultStateName = $DefaultStateRef->{ $Type{Name} };
                }
                elsif ( $DefaultStateRef->{''} ) {
                    $DefaultStateName = $DefaultStateRef->{''};
                }
            }
            elsif ( $DefaultStateRef->{''} ) {
                $DefaultStateName = $DefaultStateRef->{''};
            }
            if ( $DefaultStateName && !$GetParam{DefaultNextState} ) {
                my %DefaultState = $StateObject->StateGet(
                    Name => $DefaultStateName,
                );
                if ( $DefaultState{ID} ) {
                    $GetParam{DefaultNextStateID} = $DefaultState{ID};
                    $GetParam{DefaultNextState}   = $DefaultStateName;
                }
            }

            # check for default queue for this tickettype...
            my $DefaultQueueRef =
                $ConfigObject->Get('TicketStateWorkflow::DefaultTicketQueue');
            my $DefaultQueueExtendedRef
                = $ConfigObject->Get('TicketStateWorkflowExtension::DefaultTicketQueue');
            if ( defined $DefaultQueueExtendedRef && ref $DefaultQueueExtendedRef eq 'HASH' ) {
                for my $Extension ( sort keys %{$DefaultQueueExtendedRef} ) {
                    for my $Type ( keys %{ $DefaultQueueExtendedRef->{$Extension} } ) {
                        $DefaultQueueRef->{$Type} = $DefaultQueueExtendedRef->{$Extension}->{$Type};
                    }
                }
            }
            my $DefaultQueueName = "";
            my $DefaultQueueID   = "";
            if ( $GetParam{DefaultTypeID} ) {
                my %Type = $TypeObject->TypeGet(
                    ID => $GetParam{DefaultTypeID},
                );
                if ( $DefaultQueueRef->{ $Type{Name} } ) {
                    $DefaultQueueName = $DefaultQueueRef->{ $Type{Name} };
                }
                elsif ( $DefaultQueueRef->{''} ) {
                    $DefaultQueueName = $DefaultQueueRef->{''};
                }
            }
            elsif ( $DefaultQueueRef->{''} ) {
                $DefaultQueueName = $DefaultQueueRef->{''};
            }
            if (
                $DefaultQueueName
                &&
                (
                    !$Self->{QueueID} || (
                        $Self->{QueueID} && $GetParam{DefaultQueueSet}
                    )
                )
                )
            {
                my $QueueID = $QueueObject->QueueLookup(
                    Queue => $DefaultQueueName,
                );
                $Self->{QueueID} = $QueueID;
                $GetParam{DefaultQueueSelected} = $Self->{QueueID} . "||" . $DefaultQueueName;
            }

            # get user preferences
            my %UserPreferences = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
                UserID => $Self->{UserID},
            );

            # store the dynamic fields default values or used specific default values to be used as
            # ACLs info for all fields
            my %DynamicFieldDefaults;

            # cycle through the activated Dynamic Fields for this screen
            DYNAMICFIELD:
            for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
                next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
                next DYNAMICFIELD if !IsHashRefWithData( $DynamicFieldConfig->{Config} );
                next DYNAMICFIELD if !$DynamicFieldConfig->{Name};

                # get default value from dynamic field config (if any)
                my $DefaultValue = $DynamicFieldConfig->{Config}->{DefaultValue} || '';

                # override the value from user preferences if is set
                if ( $UserPreferences{ 'UserDynamicField_' . $DynamicFieldConfig->{Name} } ) {
                    $DefaultValue = $UserPreferences{ 'UserDynamicField_' . $DynamicFieldConfig->{Name} };
                }

                next DYNAMICFIELD if $DefaultValue eq '';
                next DYNAMICFIELD
                    if ref $DefaultValue eq 'ARRAY' && !IsArrayRefWithData($DefaultValue);

                $DynamicFieldDefaults{ 'DynamicField_' . $DynamicFieldConfig->{Name} } = $DefaultValue;
            }
            $GetParam{DynamicField} = \%DynamicFieldDefaults;

            # KIX4OTRS-capeIT
            # get defaults from ticket template
            for my $DefaultDynamicField ( keys %{ $GetParam{QuickTicketDynamicFieldHash} } ) {
                $GetParam{DynamicField}->{$DefaultDynamicField}
                    = $GetParam{QuickTicketDynamicFieldHash}->{$DefaultDynamicField};
            }

            # EO KIX4OTRS-capeIT
            # get split article if given
            # create html strings for all dynamic fields
            my %DynamicFieldHTML;

            # cycle through the activated Dynamic Fields for this screen
            DYNAMICFIELD:
            for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
                next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

                # KIX4OTRS-capeIT
                # my $PossibleValuesFilter;
                # EO KIX4OTRS-capeIT

                my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                    DynamicFieldConfig => $DynamicFieldConfig,
                    Behavior           => 'IsACLReducible',
                );

                if ($IsACLReducible) {

                    # get PossibleValues
                    my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                        DynamicFieldConfig => $DynamicFieldConfig,
                    );

                    # check if field has PossibleValues property in its configuration
                    if ( IsHashRefWithData($PossibleValues) ) {

                        # convert possible values key => value to key => key for ACLs using a Hash slice
                        my %AclData = %{$PossibleValues};
                        @AclData{ keys %AclData } = keys %AclData;

                        # set possible values filter from ACLs
                        my $ACL = $TicketObject->TicketAcl(
                            %GetParam,
                            %ACLCompatGetParam,
                            Action        => $Self->{Action},
                            ReturnType    => 'Ticket',
                            ReturnSubType => 'DynamicField_' . $DynamicFieldConfig->{Name},
                            Data          => \%AclData,
                            UserID        => $Self->{UserID},
                        );
                        if ($ACL) {
                            my %Filter = $TicketObject->TicketAclData();

                            # convert Filer key => key back to key => value using map
                        # KIX4OTRS-capeIT
                        # %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} }
                        %{$DynamicFieldConfig->{ShownPossibleValues}} = map { $_ => $PossibleValues->{$_} }
                        # EO KIX4OTRS-capeIT
                                keys %Filter;
                        }
                    }
                }

                # to store dynamic field value from database (or undefined)
                my $Value;

                # override the value from user preferences if is set
                if ( $UserPreferences{ 'UserDynamicField_' . $DynamicFieldConfig->{Name} } ) {
                    $Value = $UserPreferences{ 'UserDynamicField_' . $DynamicFieldConfig->{Name} };
                }

                # KIX4OTRS-capeIT
                elsif ( $GetParam{ 'QuickTicketDynamicField_' . $DynamicFieldConfig->{Name} } )
                {
                    $Value
                        = $GetParam{ 'QuickTicketDynamicField_' . $DynamicFieldConfig->{Name} };
                }

                # EO KIX4OTRS-capeIT

                # get field html
                $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } =
                    $DynamicFieldBackendObject->EditFieldRender(
                    DynamicFieldConfig   => $DynamicFieldConfig,
                    # KIX4OTRS-capeIT
                    # PossibleValuesFilter => $PossibleValuesFilter,
                    PossibleValuesFilter => $DynamicFieldConfig->{ShownPossibleValues},
                    # EO KIX4OTRS-capeIT
                    Value                => $Value,
                    Mandatory =>
                        $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                    LayoutObject    => $LayoutObject,
                    ParamObject     => $ParamObject,
                    AJAXUpdate      => 1,
                    UpdatableFields => $Self->_GetFieldsToUpdate(),

                    # KIX4OTRS-capeIT
                    Template => $GetParam{QuickTicketDynamicFieldHash},

                    # EO KIX4OTRS-capeIT
                    );
            }

            # KIX4OTRS-capeIT
            $Self->_GetShownDynamicFields();
            # EO KIX4OTRS-capeIT

            # run compose modules
            if (
                ref $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') eq
                'HASH'
                )
            {
                my %Jobs = %{ $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') };
                for my $Job ( sort keys %Jobs ) {

                    # load module
                    if ( !$MainObject->Require( $Jobs{$Job}->{Module} ) ) {
                        return $LayoutObject->FatalError();
                    }

                    my $Object = $Jobs{$Job}->{Module}->new(
                        %{$Self},
                        Debug => $Debug,
                    );

                    # get params
                    # KIX4OTRS-capeIT
                    # redefinition of %GetParam
                    # my %GetParam;
                    # EO KIX4OTRS-capeIT
                    for my $Parameter ( $Object->Option( %GetParam, Config => $Jobs{$Job} ) ) {
                        $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter );
                    }

                    # run module
                    $Object->Run( %GetParam, Config => $Jobs{$Job} );
                }
            }

            # KIX4OTRS-capeIT
            if ( $GetParam{QuickTicketSubject} ) {
                $Config->{Subject} = $GetParam{QuickTicketSubject};
            }
            if ( $GetParam{QuickTicketBody} ) {
                $Config->{Body} = $GetParam{QuickTicketBody};
            }

            # EO KIX4OTRS-capeIT

            # get and format default subject and body
            my $Subject = $LayoutObject->Output(
                Template => $Config->{Subject} || '',
            );

            my $Body = $LayoutObject->Output(
                Template => $Config->{Body} || '',
            );

            # make sure body is rich text
            # KIX4OTRS-capeIT
            # if ( $LayoutObject->{BrowserRichText} ) {
            if ( $LayoutObject->{BrowserRichText} && !$GetParam{QuickTicketBody} ) {

                # EO KIX4OTRS-capeIT
                $Body = $LayoutObject->Ascii2RichText(
                    String => $Body,
                );
            }

            # html output
            my $Services = $Self->_GetServices(
                QueueID => $Self->{QueueID} || 1,

                # KIX4OTRS-capeIT
                %GetParam,
                CustomerUserID => $CustomerData{CustomerUserLogin} || '',
                TypeID => $GetParam{TypeID} || $GetParam{DefaultTypeID},

                # EO KIX4OTRS-capeIT
            );
            my $SLAs = $Self->_GetSLAs(
                QueueID => $Self->{QueueID} || 1,
                Services => $Services,
                %GetParam,
                %ACLCompatGetParam,

                # KIX4OTRS-capeIT
                ServiceID => $GetParam{ServiceID} || $GetParam{QuickTicketServiceID},
                TypeID    => $GetParam{TypeID}    || $GetParam{DefaultTypeID},

                # EO KIX4OTRS-capeIT
            );

            # KIX4OTRS-capeIT
            my $Signature = '';
            if ( $Self->{QueueID} ) {
                $Signature = $Self->_GetSignature( QueueID => $Self->{QueueID} ) || '';
            }
            if ( $LayoutObject->{BrowserRichText} ) {
                $Signature = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToAscii( String => $Signature, );
            }

            # EO KIX4OTRS-capeIT

            $Output .= $Self->_MaskEmailNew(
                QueueID    => $Self->{QueueID},
                NextStates => $Self->_GetNextStates(
                    %GetParam,
                    %ACLCompatGetParam,

                    # KIX4OTRS-capeIT
                    CustomerUserID => $CustomerData{CustomerUserLogin} || '',

                    # EO KIX4OTRS-capeIT
                    QueueID => $Self->{QueueID} || 1,

                    # KIX4OTRS-capeIT
                    TypeID     => $GetParam{TypeID}   || $GetParam{DefaultTypeID},
                    DefaultSet => $Self->{DefaultSet} || '',

                    # EO KIX4OTRS-capeIT
                ),
                Priorities => $Self->_GetPriorities(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID} || 1,

                    # KIX4OTRS-capeIT
                    DefaultSet => $Self->{DefaultSet} || '',

                    # EO KIX4OTRS-capeIT
                ),
                Types => $Self->_GetTypes(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID} || 1,

                    # KIX4OTRS-capeIT
                    DefaultSet => $Self->{DefaultSet} || '',

                    # EO KIX4OTRS-capeIT
                ),

                # KIX4OTRS-capeIT
                NextState               => $GetParam{DefaultNextState}             || '',
                DefaultDiffTime         => $GetParam{DefaultPendingOffset}         || '',
                DefaultTypeID           => $GetParam{DefaultTypeID}                || '',
                TypeID                  => $GetParam{TypeID}                       || '',
                DefaultQueueSelected    => $GetParam{DefaultQueueSelected}         || '',
                PriorityID              => $GetParam{QuickTicketPriorityID}        || '',
                UserSelected            => $GetParam{QuickTicketOwnerID}           || '',
                ResponsibleUserSelected => $GetParam{QuickTicketResponsibleUserID} || '',
                TimeUnits               => $GetParam{QuickTicketTimeUnits}         || '',
                ServiceID               => $GetParam{QuickTicketServiceID},
                SLAID                   => $GetParam{QuickTicketSLAID},
                Signature               => $Signature,
                LinkTicketID            => $GetParam{LinkTicketID}                 || '',

                # EO KIX4OTRS-capeIT

                Services          => $Services,
                SLAs              => $SLAs,
                StandardTemplates => $Self->_GetStandardTemplates(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID} || '',
                ),
                Users => $Self->_GetUsers(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID}
                ),
                ResponsibleUsers => $Self->_GetResponsibles(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID}
                ),
                FromList => $Self->_GetTos(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $Self->{QueueID},
                    # KIX4OTRS-capeIT
                    CustomerUserID => $CustomerData{CustomerUserLogin} || '',
                    TypeID         => $GetParam{TypeID}                || $Param{DefaultTypeID},
                    # EO KIX4OTRS-capeIT
                ),
                To                => '',
                Subject           => $Subject,
                Body              => $Body,

                # KIX4OTRS-capeIT
                # CustomerID        => '',
                # CustomerUser      => '',
                # CustomerData      => {},
                CustomerUser => $GetParam{QuickTicketCustomer} || $Article{CustomerUserID},
                CustomerID   => $GetParam{CustomerID},
                CustomerUser => $GetParam{CustomerUserID}
                    || $ParamObject->GetParam( Param => 'SelectedCustomerUser' ),
                CustomerData => \%CustomerData,

                # EO KIX4OTRS-capeIT

                TimeUnitsRequired => (
                    $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime')
                    ? 'Validate_Required'
                    : ''
                ),
                DynamicFieldHTML    => \%DynamicFieldHTML,
                MultipleCustomer    => \@MultipleCustomer,
                MultipleCustomerCc  => \@MultipleCustomerCc,
                MultipleCustomerBcc => \@MultipleCustomerBcc,

                # KIX4OTRS-capeIT
                SelectedConfigItemIDs => $GetParam{SelectedConfigItemIDs},

                # EO KIX4OTRS-capeIT
            );
        }

        $Output .= $LayoutObject->Footer();
        return $Output;
    }

    # deliver signature
    elsif ( $Self->{Subaction} eq 'Signature' ) {
        my $QueueID = $ParamObject->GetParam( Param => 'QueueID' );
        if ( !$QueueID ) {
            my $Dest = $ParamObject->GetParam( Param => 'Dest' ) || '';
            ($QueueID) = split( /\|\|/, $Dest );
        }

        # start with empty signature (no queue selected) - if we have a queue, get the sig.
        my $Signature = '';
        if ($QueueID) {
            $Signature = $Self->_GetSignature( QueueID => $QueueID );
        }
        my $MimeType = 'text/plain';
        if ( $LayoutObject->{BrowserRichText} ) {
            $MimeType  = 'text/html';
            $Signature = $LayoutObject->RichTextDocumentComplete(
                String => $Signature,
            );
        }

        return $LayoutObject->Attachment(
            ContentType => $MimeType . '; charset=' . $LayoutObject->{Charset},
            Content     => $Signature,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # create new ticket and article
    elsif ( $Self->{Subaction} eq 'StoreNew' ) {

        my %Error;
        my $NextStateID = $ParamObject->GetParam( Param => 'NextStateID' ) || '';
        my %StateData;
        if ($NextStateID) {
            %StateData = $Kernel::OM->Get('Kernel::System::State')->StateGet(
                ID => $NextStateID,
            );
        }
        my $NextState        = $StateData{Name};
        my $NewResponsibleID = $ParamObject->GetParam( Param => 'NewResponsibleID' ) || '';
        my $NewUserID        = $ParamObject->GetParam( Param => 'NewUserID' ) || '';
        my $Dest             = $ParamObject->GetParam( Param => 'Dest' ) || '';

        # see if only a name has been passed
        if ( $Dest && $Dest !~ m{ \A (\d+)? \| \| .+ \z }xms ) {

            # see if we can get an ID for this queue name
            my $DestID = $QueueObject->QueueLookup(
                Queue => $Dest,
            );

            if ($DestID) {
                $Dest = $DestID . '||' . $Dest;
            }
            else {
                $Dest = '';
            }
        }

        my ( $NewQueueID, $From ) = split( /\|\|/, $Dest );
        if ( !$NewQueueID ) {
            $GetParam{OwnerAll} = 1;
        }
        else {
            my %Queue = $QueueObject->GetSystemAddress( QueueID => $NewQueueID );
            $GetParam{From} = $Queue{Email};
        }

        # get sender queue from
        # KIX4OTRS-capeIT
        # my $Signature = '';
        my $Signature = $ParamObject->GetParam( Param => 'Signature' ) || '';

        # EO KIX4OTRS-capeIT

        if ($NewQueueID) {
            $Signature = $Self->_GetSignature( QueueID => $NewQueueID );
        }
        my $CustomerUser = $ParamObject->GetParam( Param => 'CustomerUser' )
            || $ParamObject->GetParam( Param => 'PreSelectedCustomerUser' )
            || $ParamObject->GetParam( Param => 'SelectedCustomerUser' )
            || '';
        my $CustomerID = $ParamObject->GetParam( Param => 'CustomerID' ) || '';
        my $SelectedCustomerUser = $ParamObject->GetParam( Param => 'SelectedCustomerUser' )
            || '';
        my $ExpandCustomerName = $ParamObject->GetParam( Param => 'ExpandCustomerName' )
            || 0;
        my %FromExternalCustomer;
        $FromExternalCustomer{Customer} = $ParamObject->GetParam( Param => 'PreSelectedCustomerUser' )
            || $ParamObject->GetParam( Param => 'CustomerUser' )
            || '';
        $GetParam{QueueID}            = $NewQueueID;
        $GetParam{ExpandCustomerName} = $ExpandCustomerName;

        if ( $ParamObject->GetParam( Param => 'OwnerAllRefresh' ) ) {
            $GetParam{OwnerAll} = 1;
            $ExpandCustomerName = 3;
        }
        if ( $ParamObject->GetParam( Param => 'ResponsibleAllRefresh' ) ) {
            $GetParam{ResponsibleAll} = 1;
            $ExpandCustomerName = 3;
        }
        if ( $ParamObject->GetParam( Param => 'ClearTo' ) ) {
            $GetParam{To} = '';
            $ExpandCustomerName = 3;
        }
        for my $Number ( 1 .. 2 ) {
            my $Item = $ParamObject->GetParam( Param => "ExpandCustomerName$Number" ) || 0;
            if ( $Number == 1 && $Item ) {
                $ExpandCustomerName = 1;
            }
            elsif ( $Number == 2 && $Item ) {
                $ExpandCustomerName = 2;
            }
        }

        # attachment delete
        my @AttachmentIDs = map {
            my ($ID) = $_ =~ m{ \A AttachmentDelete (\d+) \z }xms;
            $ID ? $ID : ();
        } $ParamObject->GetParamNames();

        COUNT:
        for my $Count ( reverse sort @AttachmentIDs ) {
            my $Delete = $ParamObject->GetParam( Param => "AttachmentDelete$Count" );
            next COUNT if !$Delete;
            $Error{AttachmentDelete} = 1;
            $UploadCacheObject->FormIDRemoveFile(
                FormID => $Self->{FormID},
                FileID => $Count,
            );
            $IsUpload = 1;
        }

        # attachment upload
        if ( $ParamObject->GetParam( Param => 'AttachmentUpload' ) ) {
            $IsUpload                = 1;
            %Error                   = ();
            $Error{AttachmentUpload} = 1;
            my %UploadStuff = $ParamObject->GetUploadAll(
                Param => 'FileUpload',
            );
            $UploadCacheObject->FormIDAddFile(
                FormID      => $Self->{FormID},
                Disposition => 'attachment',
                %UploadStuff,
            );
        }

        # create html strings for all dynamic fields
        my %DynamicFieldHTML;

        # cycle through the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            # KIX4OTRS-capeIT
            # my $PossibleValuesFilter;
            # EO KIX4OTRS-capeIT

            my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            if ($IsACLReducible) {

                # get PossibleValues
                my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                    DynamicFieldConfig => $DynamicFieldConfig,
                );

                # check if field has PossibleValues property in its configuration
                if ( IsHashRefWithData($PossibleValues) ) {

                    # convert possible values key => value to key => key for ACLs using a Hash slice
                    my %AclData = %{$PossibleValues};
                    @AclData{ keys %AclData } = keys %AclData;

                    # set possible values filter from ACLs
                    my $ACL = $TicketObject->TicketAcl(
                        %GetParam,
                        %ACLCompatGetParam,
                        CustomerUserID => $CustomerUser || '',
                        Action         => $Self->{Action},
                        ReturnType     => 'Ticket',
                        ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                        Data           => \%AclData,
                        UserID         => $Self->{UserID},
                    );
                    if ($ACL) {
                        my %Filter = $TicketObject->TicketAclData();

                        # convert Filer key => key back to key => value using map
                        # KIX4OTRS-capeIT
                        # %{$PossibleValuesFilter} = map { $_ => $PossibleValues->{$_} }
                        %{$DynamicFieldConfig->{ShownPossibleValues}} = map { $_ => $PossibleValues->{$_} }
                        # EO KIX4OTRS-capeIT
                            keys %Filter;
                    }
                }
            }
        # KIX4OTRS-capeIT
        }

        # get shown or hidden fields
        $Self->_GetShownDynamicFields();

        # cycle trough the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            # EO KIX4OTRS-capeIT

            my $ValidationResult;

            # KIX4OTRS-capeIT
            # do not validate on attachment upload or if field is disabled
            # if ( !$IsUpload && !$ExpandCustomerName ) {
            if (
                !$IsUpload
                && !$ExpandCustomerName
                && $DynamicFieldConfig->{Shown}
                )
            {

                # EO KIX4OTRS-capeIT

                $ValidationResult = $DynamicFieldBackendObject->EditFieldValueValidate(
                    DynamicFieldConfig   => $DynamicFieldConfig,
                    # KIX4OTRS-capeIT
                    # PossibleValuesFilter => $PossibleValuesFilter,
                    PossibleValuesFilter => $DynamicFieldConfig->{ShownPossibleValues},
                    # EO KIX4OTRS-capeIT
                    ParamObject          => $ParamObject,
                    Mandatory =>
                        $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                );

                if ( !IsHashRefWithData($ValidationResult) ) {
                    return $LayoutObject->ErrorScreen(
                        Message =>
                            $LayoutObject->{LanguageObject}
                            ->Translate( 'Could not perform validation on field %s!', $DynamicFieldConfig->{Label} ),
                        Comment => Translatable('Please contact the admin.'),
                    );
                }

                # propagate validation error to the Error variable to be detected by the frontend
                if ( $ValidationResult->{ServerError} ) {
                    $Error{ $DynamicFieldConfig->{Name} } = ' ServerError';
                }
            }

            # get field html
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } = $DynamicFieldBackendObject->EditFieldRender(
                DynamicFieldConfig   => $DynamicFieldConfig,
                # KIX4OTRS-capeIT
                # PossibleValuesFilter => $PossibleValuesFilter,
                PossibleValuesFilter => $DynamicFieldConfig->{ShownPossibleValues},
                # EO KIX4OTRS-capeIT
                Mandatory =>
                    $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                ServerError  => $ValidationResult->{ServerError}  || '',
                ErrorMessage => $ValidationResult->{ErrorMessage} || '',
                LayoutObject => $LayoutObject,
                ParamObject  => $ParamObject,
                AJAXUpdate   => 1,
                UpdatableFields => $Self->_GetFieldsToUpdate(),
            );
        }

        # get all attachments meta data
        my @Attachments = $UploadCacheObject->FormIDGetAllFilesMeta(
            FormID => $Self->{FormID},
        );

        # get customer user object
        my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');

        # Expand Customer Name
        my %CustomerUserData;
        if ( $ExpandCustomerName == 1 ) {

            # search customer
            my %CustomerUserList;
            %CustomerUserList = $CustomerUserObject->CustomerSearch(
                Search => $GetParam{To},
            );

            # check if just one customer user exists
            # if just one, fillup CustomerUserID and CustomerID
            $Param{CustomerUserListCount} = 0;
            for my $CustomerUserKey ( sort keys %CustomerUserList ) {
                $Param{CustomerUserListCount}++;
                $Param{CustomerUserListLast}     = $CustomerUserList{$CustomerUserKey};
                $Param{CustomerUserListLastUser} = $CustomerUserKey;
            }
            if ( $Param{CustomerUserListCount} == 1 ) {
                $GetParam{To}              = $Param{CustomerUserListLast};
                $Error{ExpandCustomerName} = 1;
                my %CustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                    User => $Param{CustomerUserListLastUser},
                );
                if ( $CustomerUserData{UserCustomerID} ) {
                    $CustomerID = $CustomerUserData{UserCustomerID};
                }
                if ( $CustomerUserData{UserLogin} ) {
                    $CustomerUser = $CustomerUserData{UserLogin};
                }
            }

            # if more the one customer user exists, show list
            # and clean CustomerUserID and CustomerID
            else {

                # don't check email syntax on multi customer select
                $ConfigObject->Set(
                    Key   => 'CheckEmailAddresses',
                    Value => 0
                );
                $CustomerID = '';

                # KIX4OTRS-capeIT
                $Param{ToOptions} = \%CustomerUserList;

                # EO KIX4OTRS-capeIT

                # clear to if there is no customer found
                if ( !%CustomerUserList ) {
                    $GetParam{To} = '';
                }
                $Error{ExpandCustomerName} = 1;
            }
        }

        # get from and customer id if customer user is given
        elsif ( $ExpandCustomerName == 2 ) {
            %CustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                User => $CustomerUser,
            );
            my %CustomerUserList = $CustomerUserObject->CustomerSearch(
                UserLogin => $CustomerUser,
            );
            for my $CustomerUserKey ( sort keys %CustomerUserList ) {
                $GetParam{To} = $CustomerUserList{$CustomerUserKey};
            }
            if ( $CustomerUserData{UserCustomerID} ) {
                $CustomerID = $CustomerUserData{UserCustomerID};
            }
            if ( $CustomerUserData{UserLogin} ) {
                $CustomerUser = $CustomerUserData{UserLogin};
            }
            if ( $FromExternalCustomer{Customer} ) {
                my %ExternalCustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                    User => $FromExternalCustomer{Customer},
                );
                $FromExternalCustomer{Email} = $ExternalCustomerUserData{UserEmail};
            }
            $Error{ExpandCustomerName} = 1;
        }

        # if a new destination queue is selected
        elsif ( $ExpandCustomerName == 3 ) {
            $Error{NoSubmit} = 1;
            $CustomerUser = $SelectedCustomerUser;
        }

        # KIX4OTRS-capeIT
        # get To if customer user is given,
        # BUT get customer id only if given customer id is wrong or empty
        elsif ( $ExpandCustomerName == 5 ) {
            if ($CustomerUser) {
                %CustomerUserData = $CustomerUserObject->CustomerUserDataGet(
                    User => $CustomerUser,
                );
                my %CustomerUserList = $CustomerUserObject->CustomerSearch(
                    UserLogin => $CustomerUser,
                );
                for my $KeyCustomerUser ( keys %CustomerUserList ) {
                    $GetParam{To} = $CustomerUserList{$KeyCustomerUser};
                }
                if (
                    ( !$CustomerID && $CustomerUserData{UserCustomerID} ) ||
                    (
                        $CustomerID &&
                        (
                            $CustomerID ne $CustomerUserData{UserCustomerID} &&
                            $CustomerUserData{UserCustomerIDs} !~ /(^|,\s*)$CustomerID(,\s*|$)/
                        )
                    )
                    )
                {
                    $CustomerID = $CustomerUserData{UserCustomerID};
                }
                if ( $CustomerUserData{UserLogin} ) {
                    $CustomerUser = $CustomerUserData{UserLogin};
                }
            }
            $Error{ExpandCustomerName} = 1;
            $IsUpload = 1;
        }

        # EO KIX4OTRS-capeIT

        # show customer info
        my %CustomerData;
        if ( $ConfigObject->Get('Ticket::Frontend::CustomerInfoCompose') ) {
            if ( $CustomerUser || $SelectedCustomerUser ) {
                %CustomerData = $CustomerUserObject->CustomerUserDataGet(
                    User => $CustomerUser || $SelectedCustomerUser,
                );
            }

            # KIX4OTRS-capeIT
            # OTRS-bug: CustomerUserDataGet needs param User
            # elsif ($CustomerID) {
            #     %CustomerData = $CustomerUserObject->CustomerUserDataGet(
            #         CustomerID => $CustomerID,
            #     );
            # }
            # EO KIX4OTRS-capeIT

        }

        # check email address
        PARAMETER:
        for my $Parameter (qw(To Cc Bcc)) {
            next PARAMETER if !$GetParam{$Parameter};
            for my $Email ( Mail::Address->parse( $GetParam{$Parameter} ) ) {
                if ( !$CheckItemObject->CheckEmail( Address => $Email->address() ) ) {
                    $Error{ $Parameter . 'ErrorType' }
                        = $Parameter . $CheckItemObject->CheckErrorType() . 'ServerErrorMsg';
                    $Error{ $Parameter . 'Invalid' } = 'ServerError';
                }

                my $IsLocal = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressIsLocalAddress(
                    Address => $Email->address()
                );
                if ($IsLocal) {
                    $Error{ $Parameter . 'IsLocalAddress' } = 'ServerError';
                }
            }
        }

        # if it is not a subaction about attachments, check for server errors
        if ( !$IsUpload && !$ExpandCustomerName ) {
            if ( !$GetParam{To} ) {
                $Error{'ToInvalid'} = 'ServerError';
            }
            if ( !$GetParam{Subject} ) {
                $Error{'SubjectInvalid'} = 'ServerError';
            }
            if ( !$NewQueueID ) {
                $Error{'DestinationInvalid'} = 'ServerError';
            }
            if ( !$GetParam{Body} ) {
                $Error{'BodyInvalid'} = 'ServerError';
            }

            # check if date is valid
            if (
                !$ExpandCustomerName
                && $StateData{TypeName}
                && $StateData{TypeName} =~ /^pending/i
                )
            {

                # get time object
                my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

                if ( !$TimeObject->Date2SystemTime( %GetParam, Second => 0 ) ) {
                    $Error{'DateInvalid'} = 'ServerError';
                }
                if (
                    $TimeObject->Date2SystemTime( %GetParam, Second => 0 )
                    < $TimeObject->SystemTime()
                    )
                {
                    $Error{'DateInvalid'} = 'ServerError';
                }
            }

            if (
                $ConfigObject->Get('Ticket::Service')
                && $GetParam{SLAID}
                && !$GetParam{ServiceID}
                )
            {
                $Error{'ServiceInvalid'} = 'ServerError';
            }

            # check mandatory service
            if (
                $ConfigObject->Get('Ticket::Service')
                && $Config->{ServiceMandatory}
                && !$GetParam{ServiceID}
                )
            {
                $Error{'ServiceInvalid'} = ' ServerError';
            }

            # check mandatory sla
            if (
                $ConfigObject->Get('Ticket::Service')
                && $Config->{SLAMandatory}
                && !$GetParam{SLAID}
                )
            {
                $Error{'SLAInvalid'} = ' ServerError';
            }

            if ( $ConfigObject->Get('Ticket::Type') && !$GetParam{TypeID} ) {
                $Error{'TypeInvalid'} = 'ServerError';
            }
            if (
                $ConfigObject->Get('Ticket::Frontend::AccountTime')
                && $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime')
                && $GetParam{TimeUnits} eq ''
                )
            {
                $Error{'TimeUnitsInvalid'} = 'ServerError';
            }
        }

        # run compose modules
        my %ArticleParam;
        if ( ref $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') eq 'HASH' ) {
            my %Jobs = %{ $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') };
            for my $Job ( sort keys %Jobs ) {

                # load module
                if ( !$MainObject->Require( $Jobs{$Job}->{Module} ) ) {
                    return $LayoutObject->FatalError();
                }

                my $Object = $Jobs{$Job}->{Module}->new(
                    %{$Self},
                    Debug => $Debug,
                );

                # get params
                for my $Parameter ( $Object->Option( %GetParam, Config => $Jobs{$Job} ) ) {
                    $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter );
                }

                # run module
                $Object->Run( %GetParam, Config => $Jobs{$Job} );

                # ticket params
                %ArticleParam = (
                    %ArticleParam,
                    $Object->ArticleOption( %GetParam, Config => $Jobs{$Job} ),
                );

                # get errors
                %Error = (
                    %Error,
                    $Object->Error( %GetParam, Config => $Jobs{$Job} ),
                );
            }
        }

        if (%Error) {

            if ( $Error{ToIsLocalAddress} ) {
                $LayoutObject->Block(
                    Name => 'ToIsLocalAddressServerErrorMsg',
                    Data => \%GetParam,
                );
            }

            if ( $Error{CcIsLocalAddress} ) {
                $LayoutObject->Block(
                    Name => 'CcIsLocalAddressServerErrorMsg',
                    Data => \%GetParam,
                );
            }

            if ( $Error{BccIsLocalAddress} ) {
                $LayoutObject->Block(
                    Name => 'BccIsLocalAddressServerErrorMsg',
                    Data => \%GetParam,
                );
            }

            # get and format default subject and body
            my $Subject = $LayoutObject->Output(
                Template => $Config->{Subject} || '',
            );

            my $Body = $LayoutObject->Output(
                Template => $Config->{Body} || '',
            );

            # make sure body is rich text
            if ( $LayoutObject->{BrowserRichText} ) {
                $Body = $LayoutObject->Ascii2RichText(
                    String => $Body,
                );
            }

            #set Body and Subject parameters for Output
            if ( !$GetParam{Subject} ) {
                $GetParam{Subject} = $Subject;
            }

            if ( !$GetParam{Body} ) {
                $GetParam{Body} = $Body;
            }

            # get services
            my $Services = $Self->_GetServices(
                %GetParam,
                %ACLCompatGetParam,
                CustomerUserID => $CustomerUser || '',
                QueueID        => $NewQueueID   || 1,
            );

            # reset previous ServiceID to reset SLA-List if no service is selected
            # KIX4OTRS-capeIT
            # if ( !$GetParam{ServiceID} || !$Services->{ $GetParam{ServiceID} } ) {
            if (
                ( !$GetParam{ServiceID} || !$Services->{ $GetParam{ServiceID} } )
                && (
                    !$GetParam{QuickTicketServiceID}
                    || !$Services->{ $GetParam{QuickTicketServiceID} }
                )
                )
            {

                # EO KIX4OTRS-capeIT
                $GetParam{ServiceID} = '';

                # KIX4OTRS-capeIT
            }
            elsif (
                ( !$GetParam{ServiceID} || !$Services->{ $GetParam{ServiceID} } )
                && $GetParam{QuickTicketServiceID} && $Services->{ $GetParam{QuickTicketServiceID} }
                )
            {
                $GetParam{ServiceID} = $GetParam{QuickTicketServiceID};
            }

            # EO KIX4OTRS-capeIT

            my $SLAs = $Self->_GetSLAs(
                %GetParam,
                %ACLCompatGetParam,
                QueueID => $NewQueueID || 1,
                Services => $Services,
            );

            # header
            $Output .= $LayoutObject->Header();
            $Output .= $LayoutObject->NavigationBar();

            # html output
            $Output .= $Self->_MaskEmailNew(
                QueueID => $Self->{QueueID},
                Users   => $Self->_GetUsers(
                    %GetParam,
                    %ACLCompatGetParam,

                    # KIX4OTRS-capeIT
                    # QueueID  => $NewQueueID,
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,

                    # EO KIX4OTRS-capeIT
                    AllUsers => $GetParam{OwnerAll},
                ),

                # KIX4OTRS-capeIT
                # UserSelected     => $GetParam{NewUserID},
                UserSelected => $GetParam{NewUserID} || $GetParam{QuickTicketOwnerID},

                # EO KIX4OTRS-capeIT
                ResponsibleUsers => $Self->_GetResponsibles(
                    %GetParam,
                    %ACLCompatGetParam,

                    # KIX4OTRS-capeIT
                    # QueueID  => $NewQueueID,
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,

                    # EO KIX4OTRS-capeIT
                    AllUsers => $GetParam{ResponsibleAll}
                ),

                # KIX4OTRS-capeIT
                # ResponsibleUserSelected => $GetParam{NewResponsibleID},
                ResponsibleUserSelected => $GetParam{NewResponsibleID}
                    || $GetParam{QuickTicketResponsibleUserID},

                # EO KIX4OTRS-capeIT
                NextStates => $Self->_GetNextStates(
                    %GetParam,
                    %ACLCompatGetParam,
                    CustomerUserID => $CustomerUser || '',

                    # KIX4OTRS-capeIT
                    # QueueID => $NewQueueID || 1,
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,
                    TypeID => $GetParam{TypeID},

                    # EO KIX4OTRS-capeIT
                ),
                NextState  => $NextState,
                Priorities => $Self->_GetPriorities(
                    %GetParam,
                    %ACLCompatGetParam,
                    CustomerUserID => $CustomerUser || '',

                    # KIX4OTRS-capeIT
                    # QueueID => $NewQueueID || 1,
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,

                    # EO KIX4OTRS-capeIT
                ),
                Types => $Self->_GetTypes(
                    %GetParam,
                    %ACLCompatGetParam,
                    CustomerUserID => $CustomerUser || '',

                    # KIX4OTRS-capeIT
                    # QueueID => $NewQueueID || 1,
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,

                    # EO KIX4OTRS-capeIT
                ),
                Services          => $Services,
                SLAs              => $SLAs,
                StandardTemplates => $Self->_GetStandardTemplates(
                    %GetParam,
                    %ACLCompatGetParam,
                    QueueID => $NewQueueID || '',
                ),
                CustomerID        => $LayoutObject->Ascii2Html( Text => $CustomerID ),
                CustomerUser      => $CustomerUser,
                CustomerData      => \%CustomerData,
                TimeUnitsRequired => (
                    $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime')
                    ? 'Validate_Required'
                    : ''
                ),

                # KIX4OTRS-capeIT
                # FromList     => $Self->_GetTos(),
                FromList => $Self->_GetTos(
                    # QueueID => $NewQueueID
                    QueueID => $NewQueueID || $Self->{QueueID} || 1,
                    TypeID => $GetParam{TypeID},
                ),
                LinkTicketID => $GetParam{LinkTicketID} || '',
                To  => $GetParam{To}  || '',
                Cc  => $GetParam{Cc}  || '',
                Bcc => $GetParam{Bcc} || '',

                # EO KIX4OTRS-capeIT

                FromSelected => $Dest,

                # KIX4OTRS-capeIT
                ToOptions => $Param{ToOptions},

                # EO KIX4OTRS-capeIT
                Subject      => $LayoutObject->Ascii2Html( Text => $GetParam{Subject} ),
                Body         => $LayoutObject->Ascii2Html( Text => $GetParam{Body} ),
                Errors       => \%Error,
                Attachments  => \@Attachments,
                Signature    => $Signature,
                %GetParam,
                DynamicFieldHTML     => \%DynamicFieldHTML,
                MultipleCustomer     => \@MultipleCustomer,
                MultipleCustomerCc   => \@MultipleCustomerCc,
                MultipleCustomerBcc  => \@MultipleCustomerBcc,
                FromExternalCustomer => \%FromExternalCustomer,

                # KIX4OTRS-capeIT
                SelectedConfigItemIDs => $GetParam{SelectedConfigItemIDs},
                PriorityID            => $GetParam{PriorityID} || $GetParam{QuickTicketPriorityID},
                Priority              => $GetParam{Priority} || $GetParam{QuickTicketPriority},
                ServiceID             => $GetParam{ServiceID} || $GetParam{QuickTicketServiceID},
                SLAID                 => $GetParam{SLAID} || $GetParam{QuickTicketSLAID},
                Subject               => $GetParam{Subject} || $GetParam{QuickTicketSubject},
                Body                  => $GetParam{Body} || $GetParam{QuickTicketBody},
                TimeUnits             => $GetParam{TimeUnits} || $GetParam{QuickTicketTimeUnits},

                # EO KIX4OTRS-capeIT
            );

            $Output .= $LayoutObject->Footer();
            return $Output;
        }

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # create new ticket, do db insert
        my $TicketID = $TicketObject->TicketCreate(
            Title        => $GetParam{Subject},
            QueueID      => $NewQueueID,
            Subject      => $GetParam{Subject},
            Lock         => 'unlock',
            TypeID       => $GetParam{TypeID},
            ServiceID    => $GetParam{ServiceID},
            SLAID        => $GetParam{SLAID},
            StateID      => $NextStateID,
            PriorityID   => $GetParam{PriorityID},
            OwnerID      => 1,
            CustomerID   => $CustomerID,
            CustomerUser => $SelectedCustomerUser,
            UserID       => $Self->{UserID},
        );

        # set ticket dynamic fields
        # cycle through the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Ticket';

            # set the value
            my $Success = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $TicketID,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                UserID             => $Self->{UserID},
            );
        }

        # get pre loaded attachment
        @Attachments = $UploadCacheObject->FormIDGetAllFilesData(
            FormID => $Self->{FormID},
        );

        # get submit attachment
        my %UploadStuff = $ParamObject->GetUploadAll(
            Param => 'FileUpload',
        );
        if (%UploadStuff) {
            push @Attachments, \%UploadStuff;
        }

        # prepare subject
        my $Tn = $TicketObject->TicketNumberLookup( TicketID => $TicketID );
        $GetParam{Subject} = $TicketObject->TicketSubjectBuild(
            TicketNumber => $Tn,
            Subject      => $GetParam{Subject} || '',
            Type         => 'New',
        );

        # KIX4OTRS-capeIT
        # get signature an replace ticket data placeholder
        $Signature = $Self->_GetSignature(
            QueueID  => $NewQueueID,
            TicketID => $TicketID,
        );

        # EO KIX4OTRS-capeIT

        # check if new owner is given (then send no agent notify)
        my $NoAgentNotify = 0;
        if ($NewUserID) {
            $NoAgentNotify = 1;
        }

        my $MimeType = 'text/plain';
        if ( $LayoutObject->{BrowserRichText} ) {
            $MimeType = 'text/html';
            $GetParam{Body} .= '<br/><br/>' . $Signature;

            # remove unused inline images
            my @NewAttachmentData;
            ATTACHMENT:
            for my $Attachment (@Attachments) {
                my $ContentID = $Attachment->{ContentID};
                if (
                    $ContentID
                    && ( $Attachment->{ContentType} =~ /image/i )
                    && ( $Attachment->{Disposition} eq 'inline' )
                    )
                {
                    my $ContentIDHTMLQuote = $LayoutObject->Ascii2Html(
                        Text => $ContentID,
                    );

                    # workaround for link encode of rich text editor, see bug#5053
                    my $ContentIDLinkEncode = $LayoutObject->LinkEncode($ContentID);
                    $GetParam{Body} =~ s/(ContentID=)$ContentIDLinkEncode/$1$ContentID/g;

                    # ignore attachment if not linked in body
                    next ATTACHMENT
                        if $GetParam{Body} !~ /(\Q$ContentIDHTMLQuote\E|\Q$ContentID\E)/i;
                }

                # remember inline images and normal attachments
                push @NewAttachmentData, \%{$Attachment};
            }
            @Attachments = @NewAttachmentData;

            # verify html document
            $GetParam{Body} = $LayoutObject->RichTextDocumentComplete(
                String => $GetParam{Body},
            );
        }
        else {
            $GetParam{Body} .= "\n\n" . $Signature;
        }

        # lookup sender
        my $TemplateGenerator = $Kernel::OM->Get('Kernel::System::TemplateGenerator');
        my $Sender            = $TemplateGenerator->Sender(
            QueueID => $NewQueueID,
            UserID  => $Self->{UserID},
        );

        # send email
        my $ArticleID = $TicketObject->ArticleSend(
            NoAgentNotify  => $NoAgentNotify,
            Attachment     => \@Attachments,
            TicketID       => $TicketID,
            ArticleType    => $Config->{ArticleType},
            SenderType     => $Config->{SenderType},
            From           => $Sender,
            To             => $GetParam{To},
            Cc             => $GetParam{Cc},
            Bcc            => $GetParam{Bcc},
            Subject        => $GetParam{Subject},
            Body           => $GetParam{Body},
            Charset        => $LayoutObject->{UserCharset},
            MimeType       => $MimeType,
            UserID         => $Self->{UserID},
            HistoryType    => $Config->{HistoryType},
            HistoryComment => $Config->{HistoryComment}
                || "\%\%$GetParam{To}, $GetParam{Cc}, $GetParam{Bcc}",
            %ArticleParam,
        );
        if ( !$ArticleID ) {
            return $LayoutObject->ErrorScreen();
        }

        # set article dynamic fields
        # cycle through the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);
            next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Article';

            # set the value
            my $Success = $DynamicFieldBackendObject->ValueSet(
                DynamicFieldConfig => $DynamicFieldConfig,
                ObjectID           => $ArticleID,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                UserID             => $Self->{UserID},
            );
        }

        # remove pre-submitted attachments
        $UploadCacheObject->FormIDRemove( FormID => $Self->{FormID} );

        # set owner (if new user id is given)
        if ($NewUserID) {
            $TicketObject->TicketOwnerSet(
                TicketID  => $TicketID,
                NewUserID => $NewUserID,
                UserID    => $Self->{UserID},
            );

            # set lock
            $TicketObject->TicketLockSet(
                TicketID => $TicketID,
                Lock     => 'lock',
                UserID   => $Self->{UserID},
            );
        }

        # else set owner to current agent but do not lock it
        else {
            $TicketObject->TicketOwnerSet(
                TicketID           => $TicketID,
                NewUserID          => $Self->{UserID},
                SendNoNotification => 1,
                UserID             => $Self->{UserID},
            );
        }

        # set responsible (if new user id is given)
        if ($NewResponsibleID) {
            $TicketObject->TicketResponsibleSet(
                TicketID  => $TicketID,
                NewUserID => $NewResponsibleID,
                UserID    => $Self->{UserID},
            );
        }

        # time accounting
        if ( $GetParam{TimeUnits} ) {
            $TicketObject->TicketAccountTime(
                TicketID  => $TicketID,
                ArticleID => $ArticleID,
                TimeUnit  => $GetParam{TimeUnits},
                UserID    => $Self->{UserID},
            );
        }

        # should i set an unlock?
        if ( $StateData{TypeName} =~ /^close/i ) {

            # set lock
            $TicketObject->TicketLockSet(
                TicketID => $TicketID,
                Lock     => 'unlock',
                UserID   => $Self->{UserID},
            );
        }

        # set pending time
        elsif ( $StateData{TypeName} =~ /^pending/i ) {

            # set pending time
            $TicketObject->TicketPendingTimeSet(
                UserID   => $Self->{UserID},
                TicketID => $TicketID,
                %GetParam,
            );
        }

        # KIX4OTRS-capeIT
        # provide link functionallity in general (not only with ITSMIncidentProblemManagement)
        # get the temporarily links
            # get the temporarily links
            my $TempLinkList = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkList(
                Object => 'Ticket',
                Key    => $Self->{FormID},
                State  => 'Temporary',
                UserID => $Self->{UserID},
            );

            if ( $TempLinkList && ref $TempLinkList eq 'HASH' && %{$TempLinkList} ) {

                for my $TargetObjectOrg ( sort keys %{$TempLinkList} ) {

                    # extract typelist
                    my $TypeList = $TempLinkList->{$TargetObjectOrg};

                    for my $Type ( sort keys %{$TypeList} ) {

                        # extract direction list
                        my $DirectionList = $TypeList->{$Type};

                        for my $Direction ( sort keys %{$DirectionList} ) {

                            for my $TargetKeyOrg ( sort keys %{ $DirectionList->{$Direction} } ) {

                                # delete the temp link
                                $Kernel::OM->Get('Kernel::System::LinkObject')->LinkDelete(
                                    Object1 => 'Ticket',
                                    Key1    => $Self->{FormID},
                                    Object2 => $TargetObjectOrg,
                                    Key2    => $TargetKeyOrg,
                                    Type    => $Type,
                                    UserID  => $Self->{UserID},
                                );

                                my $SourceObject = $TargetObjectOrg;
                                my $SourceKey    = $TargetKeyOrg;
                                my $TargetObject = 'Ticket';
                                my $TargetKey    = $TicketID;

                                if ( $Direction eq 'Target' ) {
                                    $SourceObject = 'Ticket';
                                    $SourceKey    = $TicketID;
                                    $TargetObject = $TargetObjectOrg;
                                    $TargetKey    = $TargetKeyOrg;
                                }

                                # add the permanently link
                                my $Success = $Kernel::OM->Get('Kernel::System::LinkObject')->LinkAdd(
                                    SourceObject => $SourceObject,
                                    SourceKey    => $SourceKey,
                                    TargetObject => $TargetObject,
                                    TargetKey    => $TargetKey,
                                    Type         => $Type,
                                    State        => 'Valid',
                                    UserID       => $Self->{UserID},
                                );
                            }
                        }
                    }
                }
            }

        # link split ticket
        if (
            $GetParam{LinkTicketID}
            && $Config->{SplitLinkType}
            && $Config->{SplitLinkType}->{LinkType}
            && $Config->{SplitLinkType}->{Direction}
            )
        {

            my $SourceKey = $GetParam{LinkTicketID};
            my $TargetKey = $TicketID;

            if ( $Config->{SplitLinkType}->{Direction} eq 'Source' ) {
                $SourceKey = $TicketID;
                $TargetKey = $GetParam{LinkTicketID};
            }

            # link the tickets
            $Kernel::OM->Get('Kernel::System::LinkObject')->LinkAdd(
                SourceObject => 'Ticket',
                SourceKey    => $SourceKey,
                TargetObject => 'Ticket',
                TargetKey    => $TargetKey,
                Type         => $Config->{SplitLinkType}->{LinkType} || 'Normal',
                State        => 'Valid',
                UserID       => $Self->{UserID},
            );
        }

        my $LinkType = $ConfigObject->Get('KIXSidebarConfigItemLink::LinkType')
            || 'Normal';
        for my $CurrKey (@SelectedCIIDs) {
            $Kernel::OM->Get('Kernel::System::LinkObject')->LinkAdd(
                SourceObject => 'ITSMConfigItem',
                SourceKey    => $CurrKey,
                TargetObject => 'Ticket',
                TargetKey    => $TicketID,
                Type         => $LinkType,
                State        => 'Valid',
                UserID       => $Self->{UserID},
            );
        }

        # EO KIX4OTRS-capeIT

        # get redirect screen
        my $NextScreen = $Self->{UserCreateNextMask} || 'AgentTicketEmail';

        # redirect
        return $LayoutObject->Redirect(
            OP => "Action=$NextScreen;Subaction=Created;TicketID=$TicketID",
        );
    }
    elsif ( $Self->{Subaction} eq 'AJAXUpdate' ) {
        my $Dest           = $ParamObject->GetParam( Param => 'Dest' ) || '';
        my $CustomerUser   = $ParamObject->GetParam( Param => 'SelectedCustomerUser' );
        my $ElementChanged = $ParamObject->GetParam( Param => 'ElementChanged' ) || '';

        # get From based on selected queue
        my $QueueID = '';
        if ( $Dest =~ /^(\d{1,100})\|\|.+?$/ ) {
            $QueueID = $1;
            my %Queue = $QueueObject->GetSystemAddress( QueueID => $QueueID );
            $GetParam{From} = $Queue{Email};
        }

        # KIX4OTRS-capeIT
        if ( $ConfigObject->Get('Frontend::Agent::CreateOptions::ViewAllOwner') ) {
            $GetParam{OwnerAll}       = 1;
            $GetParam{ResponsibleAll} = 1;
        }
        $ElementChanged = $GetParam{ElementChanged} || $ElementChanged;
        my $ServiceID =
            $GetParam{ServiceID}
            || $ParamObject->GetParam( Param => 'ServiceID' )
            || '';

        if ( $ElementChanged eq 'ServiceID' && $ServiceID ) {

            # retrieve service data...
            my %ServiceData = $Kernel::OM->Get('Kernel::System::Service')->ServiceGet(
                ServiceID => $ServiceID,
                UserID    => 1,
            );

            my $DefaultSetQueueID = "";
            if ( $Self->{DefaultSet} ) {
                my %TicketTemplate = $TicketObject->TicketTemplateGet(
                    ID => $Self->{DefaultSet},
                );
                $DefaultSetQueueID = $TicketTemplate{QueueID};
            }

            if ( !$DefaultSetQueueID && %ServiceData && $ServiceData{AssignedQueueID} ) {
                $QueueID = $ServiceData{AssignedQueueID};
                $Dest    = 'SetByQueueID';
            }

        }

        # EO KIX4OTRS-capeIT

        # get list type
        my $TreeView = 0;
        if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
            $TreeView = 1;
        }

        my $Tos = $Self->_GetTos(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID => $QueueID,
        );

        my $NewTos;

        if ($Tos) {
            TOs:
            for my $KeyTo ( sort keys %{$Tos} ) {
                next TOs if ( $Tos->{$KeyTo} eq '-' );
                $NewTos->{"$KeyTo||$Tos->{$KeyTo}"} = $Tos->{$KeyTo};
            }
        }
        my $Signature = '';
        if ($QueueID) {
            $Signature = $Self->_GetSignature( QueueID => $QueueID );
        }
        my $Users = $Self->_GetUsers(
            %GetParam,
            %ACLCompatGetParam,
            QueueID  => $QueueID,
            AllUsers => $GetParam{OwnerAll},
        );
        my $ResponsibleUsers = $Self->_GetResponsibles(
            %GetParam,
            %ACLCompatGetParam,
            QueueID  => $QueueID,
            AllUsers => $GetParam{ResponsibleAll},
        );

        # KIX4OTRS-capeIT
        my %NewTo = ();
        for my $QueueKey ( keys( %{$Tos} ) ) {
            $NewTo{ $QueueKey . "||" . $Tos->{$QueueKey} } = $Tos->{$QueueKey};
        }
        if ( $QueueID && $Dest eq 'SetByQueueID' ) {
            $Dest = $QueueID . "||" . $Tos->{$QueueID};
        }

        # EO KIX4OTRS-capeIT
        my $NextStates = $Self->_GetNextStates(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,

            # KIX4OTRS-capeIT
            TypeID     => $GetParam{TypeID},
            DefaultSet => $GetParam{DefaultSet},

            # EO KIX4OTRS-capeIT
        );
        my $Priorities = $Self->_GetPriorities(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );
        my $Services = $Self->_GetServices(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );
        my $SLAs = $Self->_GetSLAs(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
            Services       => $Services,
        );
        my $StandardTemplates = $Self->_GetStandardTemplates(
            %GetParam,
            %ACLCompatGetParam,
            QueueID => $QueueID || '',
        );
        my $Types = $Self->_GetTypes(
            %GetParam,
            %ACLCompatGetParam,
            CustomerUserID => $CustomerUser || '',
            QueueID        => $QueueID      || 1,
        );

        # update Dynamic Fields Possible Values via AJAX
        my @DynamicFieldAJAX;
        # KIX4OTRS-capeIT
        my %DynamicFieldHTML;
        # EO KIX4OTRS-capeIT

        # cycle through the activated Dynamic Fields for this screen
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
            next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

            my $IsACLReducible = $DynamicFieldBackendObject->HasBehavior(
                DynamicFieldConfig => $DynamicFieldConfig,
                Behavior           => 'IsACLReducible',
            );

            # KIX4OTRS-capeIT
            # next DYNAMICFIELD if !$IsACLReducible;
            if ( !$IsACLReducible ) {
                $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } =
                    $DynamicFieldBackendObject->EditFieldRender(
                        DynamicFieldConfig => $DynamicFieldConfig,
                        Mandatory =>
                            $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                        LayoutObject    => $LayoutObject,
                        ParamObject     => $ParamObject,
                        AJAXUpdate      => 0,
                        UpdatableFields => $Self->_GetFieldsToUpdate(),
                        UseDefaultValue => 1,
                    );
                next DYNAMICFIELD;
            }
            # EO KIX4OTRS-capeIT

            my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
                DynamicFieldConfig => $DynamicFieldConfig,
            );

            # convert possible values key => value to key => key for ACLs using a Hash slice
            my %AclData = %{$PossibleValues};
            @AclData{ keys %AclData } = keys %AclData;

            # set possible values filter from ACLs
            my $ACL = $TicketObject->TicketAcl(
                %GetParam,
                %ACLCompatGetParam,
                CustomerUserID => $CustomerUser || '',
                Action         => $Self->{Action},
                TicketID       => $Self->{TicketID},
                QueueID        => $QueueID      || 0,
                ReturnType     => 'Ticket',
                ReturnSubType  => 'DynamicField_' . $DynamicFieldConfig->{Name},
                Data           => \%AclData,
                UserID         => $Self->{UserID},
            );
            if ($ACL) {
                my %Filter = $TicketObject->TicketAclData();

                # convert Filer key => key back to key => value using map
                %{$PossibleValues} = map { $_ => $PossibleValues->{$_} } keys %Filter;
            }

            my $DataValues = $DynamicFieldBackendObject->BuildSelectionDataGet(
                DynamicFieldConfig => $DynamicFieldConfig,
                PossibleValues     => $PossibleValues,
                Value              => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
            ) || $PossibleValues;

            # KIX4OTRS-capeIT
            $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } =
                $DynamicFieldBackendObject->EditFieldRender(
                    DynamicFieldConfig   => $DynamicFieldConfig,
                    PossibleValuesFilter => $DynamicFieldConfig->{ShownPossibleValues},
                    Mandatory =>
                        $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} } == 2,
                    LayoutObject    => $LayoutObject,
                    ParamObject     => $ParamObject,
                    AJAXUpdate      => 1,
                    UpdatableFields => $Self->_GetFieldsToUpdate(),
                    UseDefaultValue => 1,
                );
            # EO KIX4OTRS-capeIT

            # add dynamic field to the list of fields to update
            push(
                @DynamicFieldAJAX,
                {
                    Name        => 'DynamicField_' . $DynamicFieldConfig->{Name},
                    Data        => $DataValues,
                    SelectedID  => $DynamicFieldValues{ $DynamicFieldConfig->{Name} },
                    Translation => $DynamicFieldConfig->{Config}->{TranslatableValues} || 0,
                    Max         => 100,
                }
            );
        }

        # KIX4OTRS-capeIT
        # use only dynamic fields which passed the acl
        my %TicketAclFormData = $TicketObject->TicketAclFormData();
        my %Output;
        DYNAMICFIELD:
        for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {

            next DYNAMICFIELD if $DynamicFieldConfig->{ObjectType} ne 'Ticket';

            # hide DynamicFields only if we have ACL's
            if (
                IsHashRefWithData( \%TicketAclFormData )
                && defined $TicketAclFormData{ $DynamicFieldConfig->{Name} }
                )
            {
                $DynamicFieldConfig->{Shown} = 0;

                if ( $TicketAclFormData{ $DynamicFieldConfig->{Name} } ) {
                    $DynamicFieldConfig->{Shown} = 1;
                }
            }

            # else show them by default
            else {
                $DynamicFieldConfig->{Shown} = 1;

                # if the field is set in config as 1 (show) or 2 (mandatory) it is shown
                if (
                    defined $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} }
                    && $Config->{DynamicField}->{ $DynamicFieldConfig->{Name} }
                    )
                {
                    $DynamicFieldConfig->{Shown} = 1;
                }
            }

            if ( $DynamicFieldConfig->{Shown} == 1 && $DynamicFieldHTML{ $DynamicFieldConfig->{Name} } ) {

                $Output{ ( "DynamicField_" . $DynamicFieldConfig->{Name} ) } = (
                    $DynamicFieldHTML{ $DynamicFieldConfig->{Name} }->{Label}
                        . qq~\n<div class="Field">~
                        . $DynamicFieldHTML{ $DynamicFieldConfig->{Name} }->{Field}
                        . qq~\n</div>\n<div class="Clear"></div>\n~
                );
            }
            else {
                $Output{ ( "DynamicField_" . $DynamicFieldConfig->{Name} ) } = "";
            }
        }

        my @FormDisplayOutput;
        if ( IsHashRefWithData( \%Output ) ) {
            push @FormDisplayOutput, {
                Name => 'FormDisplay',
                Data => \%Output,
                Max  => 10000,
            };
        }
        # EO KIX4OTRS-capeIT

        my @TemplateAJAX;

        # update ticket body and attachements if needed.
        if ( $ElementChanged eq 'StandardTemplateID' ) {
            my @TicketAttachments;
            my $TemplateText;

            # remove all attachments from the Upload cache
            my $RemoveSuccess = $UploadCacheObject->FormIDRemove(
                FormID => $Self->{FormID},
            );
            if ( !$RemoveSuccess ) {
                $Kernel::OM->Get('Kernel::System::Log')->Log(
                    Priority => 'error',
                    Message  => "Form attachments could not be deleted!",
                );
            }

            # get the template text and set new attachments if a template is selected
            if ( IsPositiveInteger( $GetParam{StandardTemplateID} ) ) {
                my $TemplateGenerator = $Kernel::OM->Get('Kernel::System::TemplateGenerator');

                # set template text, replace smart tags (limited as ticket is not created)
                $TemplateText = $TemplateGenerator->Template(
                    TemplateID => $GetParam{StandardTemplateID},
                    UserID     => $Self->{UserID},
                );

                # create StdAttachmentObject
                my $StdAttachmentObject = $Kernel::OM->Get('Kernel::System::StdAttachment');

                # add std. attachments to ticket
                my %AllStdAttachments = $StdAttachmentObject->StdAttachmentStandardTemplateMemberList(
                    StandardTemplateID => $GetParam{StandardTemplateID},
                );
                for ( sort keys %AllStdAttachments ) {
                    my %AttachmentsData = $StdAttachmentObject->StdAttachmentGet( ID => $_ );
                    $UploadCacheObject->FormIDAddFile(
                        FormID      => $Self->{FormID},
                        Disposition => 'attachment',
                        %AttachmentsData,
                    );
                }

                # send a list of attachments in the upload cache back to the clientside JavaScript
                # which renders then the list of currently uploaded attachments
                @TicketAttachments = $UploadCacheObject->FormIDGetAllFilesMeta(
                    FormID => $Self->{FormID},
                );
            }

            @TemplateAJAX = (
                {
                    Name => 'UseTemplateCreate',
                    Data => '0',
                },
                {
                    Name => 'RichText',
                    Data => $TemplateText || '',
                },
                {
                    Name     => 'TicketAttachments',
                    Data     => \@TicketAttachments,
                    KeepData => 1,
                },
            );
        }

        my @ExtendedData;

        # run compose modules
        if ( ref $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') eq 'HASH' ) {

            # use QueueID from web request in compose modules
            $GetParam{QueueID} = $QueueID;

            my %Jobs = %{ $ConfigObject->Get('Ticket::Frontend::ArticleComposeModule') };
            JOB:
            for my $Job ( sort keys %Jobs ) {

                # load module
                next JOB if !$MainObject->Require( $Jobs{$Job}->{Module} );

                my $Object = $Jobs{$Job}->{Module}->new(
                    %{$Self},
                    Debug => $Debug,
                );

                # get params
                for my $Parameter ( $Object->Option( %GetParam, Config => $Jobs{$Job} ) ) {
                    $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter );
                }

                # run module
                my %Data = $Object->Data( %GetParam, Config => $Jobs{$Job} );

                # get AJAX param values
                if ( $Object->can('GetParamAJAX') ) {
                    %GetParam = ( %GetParam, $Object->GetParamAJAX(%GetParam) )
                }

                my $Key = $Object->Option( %GetParam, Config => $Jobs{$Job} );
                if ($Key) {
                    push(
                        @ExtendedData,
                        {
                            Name        => $Key,
                            Data        => \%Data,
                            SelectedID  => $GetParam{$Key},
                            Translation => 1,
                            Max         => 100,
                        }
                    );
                }
            }
        }

        # convert Signature to ASCII, if RichText is on
        if ( $LayoutObject->{BrowserRichText} ) {

            #            $Signature = $Kernel::OM->Get('Kernel::System::HTMLUtils')->ToAscii( String => $Signature, );
        }

        # KIX4OTRS-capeIT
        # create hash with DisabledOptions
        my $ListOptionJson = $LayoutObject->AgentListOptionJSON(
            [
                {
                    Name => 'Dest',
                    Data => \%NewTo,
                },
                {
                    Name => 'Services',
                    Data => $Services,
                },
            ],
        );

        # EO KIX4OTRS-capeIT
        my $JSON = $LayoutObject->BuildSelectionJSON(
            [
                {
                    Name            => 'Dest',
                    # KIX4OTRS-capeIT
                    # Data         => $NewTos,
                    Data            => $ListOptionJson->{Dest}->{Data},
                    SelectedID      => $Dest,
                    # EO KIX4OTRS-capeIT
                    Translation     => 0,
                    # KIX4OTRS-capeIT
                    # PossibleNone    => 1,
                    PossibleNone    => 0,
                    # EO KIX4OTRS-capeIT
                    TreeView        => $TreeView,
                    Max             => 100,
                    # KIX4OTRS-capeIT
                    DisabledOptions => $ListOptionJson->{Dest}->{DisabledOptions} || 0,
                    # EO KIX4OTRS-capeIT
                },
                {
                    Name         => 'Signature',
                    Data         => $Signature,
                    Translation  => 1,
                    PossibleNone => 1,
                    Max          => 100,
                },
                {
                    Name         => 'NewUserID',
                    Data         => $Users,
                    SelectedID   => $GetParam{NewUserID},
                    Translation  => 0,
                    PossibleNone => 1,
                    Max          => 100,
                },
                {
                    Name         => 'NewResponsibleID',
                    Data         => $ResponsibleUsers,
                    SelectedID   => $GetParam{NewResponsibleID},
                    Translation  => 0,
                    PossibleNone => 1,
                    Max          => 100,
                },
                {
                    Name        => 'NextStateID',
                    Data        => $NextStates,
                    SelectedID  => $GetParam{NextStateID},
                    Translation => 1,
                    Max         => 100,
                },
                {
                    Name        => 'PriorityID',
                    Data        => $Priorities,
                    SelectedID  => $GetParam{PriorityID},
                    Translation => 1,
                    Max         => 100,
                },
                {
                    Name => 'ServiceID',

                    # KIX4OTRS-capeIT
                    # Data         => $Services,
                    Data => $ListOptionJson->{Services}->{Data},

                    # EO KIX4OTRS-capeIT
                    SelectedID   => $GetParam{ServiceID},
                    PossibleNone => 1,
                    Translation  => 0,
                    TreeView     => $TreeView,

                    # KIX4OTRS-capeIT
                    DisabledOptions => $ListOptionJson->{Services}->{DisabledOptions} || 0,

                    # EO KIX4OTRS-capeIT
                    Max => 100,
                },
                {
                    Name         => 'SLAID',
                    Data         => $SLAs,
                    SelectedID   => $GetParam{SLAID},
                    PossibleNone => 1,
                    Translation  => 0,
                    Max          => 100,
                },
                {
                    Name         => 'StandardTemplateID',
                    Data         => $StandardTemplates,
                    SelectedID   => $GetParam{StandardTemplateID},
                    PossibleNone => 1,
                    Translation  => 1,
                    Max          => 100,
                },
                {
                    Name         => 'TypeID',
                    Data         => $Types,
                    SelectedID   => $GetParam{TypeID},
                    PossibleNone => 1,
                    Translation  => 0,
                    Max          => 100,
                },
                # KIX4OTRS-capeIT
                @FormDisplayOutput,
                # EO KIX4OTRS-capeIT
                @DynamicFieldAJAX,
                @TemplateAJAX,
                @ExtendedData,
            ],
        );
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # KIX4OTRS-capeIT
    # update position
    elsif ( $Self->{Subaction} eq 'UpdatePosition' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my @Backends = $ParamObject->GetArray( Param => 'Backend' );

        # get new order
        my $Key  = $Self->{Action} . 'Position';
        my $Data = '';
        for my $Backend (@Backends) {
            $Data .= $Backend . ';';
        }

        # update ssession
        $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => $Key,
            Value     => $Data,
        );

        # update preferences
        if ( !$ConfigObject->Get('DemoSystem') ) {
            $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                UserID => $Self->{UserID},
                Key    => $Key,
                Value  => $Data,
            );
        }

        # redirect
        return $LayoutObject->Attachment(
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => '',
        );
    }

    # EO KIX4OTRS-capeIT
    else {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('No Subaction!'),
            Comment => Translatable('Please contact your administrator'),
        );
    }
}

sub _GetNextStates {
    my ( $Self, %Param ) = @_;

    my %NextStates;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %NextStates = $Kernel::OM->Get('Kernel::System::Ticket')->TicketStateList(
            %Param,
            Action => $Self->{Action},
            UserID => $Self->{UserID},
        );
    }
    return \%NextStates;
}

sub _GetUsers {
    my ( $Self, %Param ) = @_;

    # get users
    my %ShownUsers;
    my %AllGroupsMembers = $Kernel::OM->Get('Kernel::System::User')->UserList(
        Type  => 'Long',
        Valid => 1,
    );

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # just show only users with selected custom queue
    if ( $Param{QueueID} && !$Param{AllUsers} ) {
        my @UserIDs = $TicketObject->GetSubscribedUserIDsByQueueID(%Param);
        for my $GroupMemberKey ( sort keys %AllGroupsMembers ) {
            my $Hit = 0;
            for my $UID (@UserIDs) {
                if ( $UID eq $GroupMemberKey ) {
                    $Hit = 1;
                }
            }
            if ( !$Hit ) {
                delete $AllGroupsMembers{$GroupMemberKey};
            }
        }
    }

    # check show users
    if ( $Kernel::OM->Get('Kernel::Config')->Get('Ticket::ChangeOwnerToEveryone') ) {
        %ShownUsers = %AllGroupsMembers;
    }

    # show all users who are owner or rw in the queue group
    elsif ( $Param{QueueID} ) {
        my $GID = $Kernel::OM->Get('Kernel::System::Queue')->GetQueueGroupID( QueueID => $Param{QueueID} );
        my %MemberList = $Kernel::OM->Get('Kernel::System::Group')->PermissionGroupGet(
            GroupID => $GID,
            Type    => 'owner',
        );
        for my $MemberKey ( sort keys %MemberList ) {
            if ( $AllGroupsMembers{$MemberKey} ) {
                $ShownUsers{$MemberKey} = $AllGroupsMembers{$MemberKey};
            }
        }
    }

    # workflow
    my $ACL = $TicketObject->TicketAcl(
        %Param,

        Action        => $Self->{Action},
        ReturnType    => 'Ticket',
        ReturnSubType => 'Owner',
        Data          => \%ShownUsers,
        UserID        => $Self->{UserID},
    );

    return { $TicketObject->TicketAclData() } if $ACL;

    return \%ShownUsers;
}

sub _GetResponsibles {
    my ( $Self, %Param ) = @_;

    # get users
    my %ShownUsers;
    my %AllGroupsMembers = $Kernel::OM->Get('Kernel::System::User')->UserList(
        Type  => 'Long',
        Valid => 1,
    );

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # just show only users with selected custom queue
    if ( $Param{QueueID} && !$Param{AllUsers} ) {
        my @UserIDs = $TicketObject->GetSubscribedUserIDsByQueueID(%Param);
        for my $GroupMemberKey ( sort keys %AllGroupsMembers ) {
            my $Hit = 0;
            for my $UID (@UserIDs) {
                if ( $UID eq $GroupMemberKey ) {
                    $Hit = 1;
                }
            }
            if ( !$Hit ) {
                delete $AllGroupsMembers{$GroupMemberKey};
            }
        }
    }

    # check show users
    if ( $Kernel::OM->Get('Kernel::Config')->Get('Ticket::ChangeOwnerToEveryone') ) {
        %ShownUsers = %AllGroupsMembers;
    }

    # show all users who are responsible or rw in the queue group
    elsif ( $Param{QueueID} ) {
        my $GID = $Kernel::OM->Get('Kernel::System::Queue')->GetQueueGroupID( QueueID => $Param{QueueID} );
        my %MemberList = $Kernel::OM->Get('Kernel::System::Group')->PermissionGroupGet(
            GroupID => $GID,
            Type    => 'responsible',
        );
        for my $MemberKey ( sort keys %MemberList ) {
            if ( $AllGroupsMembers{$MemberKey} ) {
                $ShownUsers{$MemberKey} = $AllGroupsMembers{$MemberKey};
            }
        }
    }

    # workflow
    my $ACL = $TicketObject->TicketAcl(
        %Param,

        Action        => $Self->{Action},
        ReturnType    => 'Ticket',
        ReturnSubType => 'Responsible',
        Data          => \%ShownUsers,
        UserID        => $Self->{UserID},
    );

    return { $TicketObject->TicketAclData() } if $ACL;

    return \%ShownUsers;
}

sub _GetPriorities {
    my ( $Self, %Param ) = @_;

    # get priority
    my %Priorities;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Priorities = $Kernel::OM->Get('Kernel::System::Ticket')->TicketPriorityList(
            %Param,
            Action => $Self->{Action},
            UserID => $Self->{UserID},
        );
    }
    return \%Priorities;
}

sub _GetTypes {
    my ( $Self, %Param ) = @_;

    # get type
    my %Type;
    if ( $Param{QueueID} || $Param{TicketID} ) {
        %Type = $Kernel::OM->Get('Kernel::System::Ticket')->TicketTypeList(
            %Param,
            Action => $Self->{Action},
            UserID => $Self->{UserID},
        );
    }
    return \%Type;
}

sub _GetServices {
    my ( $Self, %Param ) = @_;

    # get service
    my %Service;

    # check needed
    return \%Service if !$Param{QueueID} && !$Param{TicketID};

    # get options for default services for unknown customers
    my $DefaultServiceUnknownCustomer
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Service::Default::UnknownCustomer');

    # check if no CustomerUserID is selected
    # if $DefaultServiceUnknownCustomer = 0 leave CustomerUserID empty, it will not get any services
    # if $DefaultServiceUnknownCustomer = 1 set CustomerUserID to get default services
    if ( !$Param{CustomerUserID} && $DefaultServiceUnknownCustomer ) {
        $Param{CustomerUserID} = '<DEFAULT>';
    }

    # get service list
    if ( $Param{CustomerUserID} ) {
        %Service = $Kernel::OM->Get('Kernel::System::Ticket')->TicketServiceList(
            %Param,
            Action => $Self->{Action},
            UserID => $Self->{UserID},
        );
    }
    return \%Service;
}

sub _GetSLAs {
    my ( $Self, %Param ) = @_;

    # get sla
    my %SLA;
    if ( $Param{ServiceID} && $Param{Services} && %{ $Param{Services} } ) {
        if ( $Param{Services}->{ $Param{ServiceID} } ) {
            %SLA = $Kernel::OM->Get('Kernel::System::Ticket')->TicketSLAList(
                %Param,
                Action => $Self->{Action},
                UserID => $Self->{UserID},
            );
        }
    }
    return \%SLA;
}

sub _GetTos {
    my ( $Self, %Param ) = @_;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check own selection
    my %NewTos;
    if ( $ConfigObject->Get('Ticket::Frontend::NewQueueOwnSelection') ) {
        %NewTos = %{ $ConfigObject->Get('Ticket::Frontend::NewQueueOwnSelection') };
    }
    else {

        # SelectionType Queue or SystemAddress?
        my %Tos;
        if ( $ConfigObject->Get('Ticket::Frontend::NewQueueSelectionType') eq 'Queue' ) {
            %Tos = $Kernel::OM->Get('Kernel::System::Ticket')->MoveList(
                %Param,
                Type   => 'create',
                Action => $Self->{Action},
                UserID => $Self->{UserID},

                # KIX4OTRS-capeIT
                QueueID => $Param{QueueID},
                TypeID  => $Param{TypeID},

                # EO KIX4OTRS-capeIT

            );
        }
        else {
            %Tos = $Kernel::OM->Get('Kernel::System::DB')->GetTableData(
                Table => 'system_address',
                What  => 'queue_id, id',
                Valid => 1,
                Clamp => 1,
            );
        }

        # get create permission queues
        my %UserGroups = $Kernel::OM->Get('Kernel::System::Group')->PermissionUserGet(
            UserID => $Self->{UserID},
            Type   => 'create',
        );

        # build selection string
        QUEUEID:
        for my $QueueID ( sort keys %Tos ) {
            my %QueueData = $Kernel::OM->Get('Kernel::System::Queue')->QueueGet( ID => $QueueID );

            # permission check, can we create new tickets in queue
            next QUEUEID if !$UserGroups{ $QueueData{GroupID} };

            my $String = $ConfigObject->Get('Ticket::Frontend::NewQueueSelectionString')
                || '<Realname> <<Email>> - Queue: <Queue>';
            $String =~ s/<Queue>/$QueueData{Name}/g;
            $String =~ s/<QueueComment>/$QueueData{Comment}/g;
            if ( $ConfigObject->Get('Ticket::Frontend::NewQueueSelectionType') ne 'Queue' )
            {
                my %SystemAddressData = $Kernel::OM->Get('Kernel::System::SystemAddress')->SystemAddressGet(
                    ID => $Tos{$QueueID},
                );
                $String =~ s/<Realname>/$SystemAddressData{Realname}/g;
                $String =~ s/<Email>/$SystemAddressData{Name}/g;
            }
            $NewTos{$QueueID} = $String;
        }
    }

    # add empty selection
    $NewTos{''} = '-';
    return \%NewTos;
}

sub _GetSignature {
    my ( $Self, %Param ) = @_;

    # prepare signature
    my $TemplateGenerator = $Kernel::OM->Get('Kernel::System::TemplateGenerator');
    my $Signature         = $TemplateGenerator->Signature(
        QueueID => $Param{QueueID},
        Data    => \%Param,
        UserID  => $Self->{UserID},

        # KIX4OTRS-capeIT
        TicketID => $Param{TicketID},

        # EO KIX4OTRS-capeIT
    );

    return $Signature;
}

sub _GetStandardTemplates {
    my ( $Self, %Param ) = @_;

    # get create templates
    my %Templates;

    # check needed
    return \%Templates if !$Param{QueueID} && !$Param{TicketID};

    my $QueueID = $Param{QueueID} || '';
    if ( !$Param{QueueID} && $Param{TicketID} ) {

        # get QueueID from the ticket
        my %Ticket = $Kernel::OM->Get('Kernel::System::Ticket')->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 0,
            UserID        => $Self->{UserID},
        );
        $QueueID = $Ticket{QueueID} || '';
    }

    # fetch all std. templates
    my %StandardTemplates = $Kernel::OM->Get('Kernel::System::Queue')->QueueStandardTemplateMemberList(
        QueueID       => $QueueID,
        TemplateTypes => 1,
    );

    # return empty hash if there are no templates for this screen
    return \%Templates if !IsHashRefWithData( $StandardTemplates{Create} );

    # return just the templates for this screen
    return $StandardTemplates{Create};
}

sub _MaskEmailNew {
    my ( $Self, %Param ) = @_;

    $Param{FormID} = $Self->{FormID};

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # KIX4OTRS-capeIT
    # get layout object - moved from below
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my @Templates = $TicketObject->TicketTemplateList(
        Result   => 'ID',
        Frontend => 'Agent',
        UserID => $Self->{UserID},
    );

    if ( scalar @Templates ) {

        my %TemplateHash;
        for my $TemplateKeys (@Templates) {
            $TemplateHash{$TemplateKeys} = $TicketObject->TicketTemplateLookup(
                ID => $TemplateKeys
            );
        }

        my $DefaultSetSelection = $LayoutObject->BuildSelection(
            Data         => \%TemplateHash,
            SelectedID   => $Self->{DefaultSet} || 0,
            Translation  => 0,
            Name         => 'DefaultSetSelection',
            PossibleNone => 1,
            Class        => 'Modernize'
        );
        $LayoutObject->Block(
            Name => 'DefaultSetSelection',
            Data => {
                DefaultSetSelStr => $DefaultSetSelection,
            },
        );
    }

    # EO KIX4OTRS-capeIT

    # get list type
    my $TreeView = 0;
    if ( $ConfigObject->Get('Ticket::Frontend::ListType') eq 'tree' ) {
        $TreeView = 1;
    }

    # get layout object
    # KIX4OTRS-capeIT
    # moved upwards
    # my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    # EO KIX4OTRS-capeIT

    # build customer search autocomplete field
    $LayoutObject->Block(
        Name => 'CustomerSearchAutoComplete',
    );

    # build string
    $Param{Users}->{''} = '-';
    $Param{OptionStrg} = $LayoutObject->BuildSelection(
        Data       => $Param{Users},
        SelectedID => $Param{UserSelected},
        Name       => 'NewUserID',
        Class      => 'Modernize',
    );

    my $Config = $Kernel::OM->Get('Kernel::Config')->Get("Ticket::Frontend::$Self->{Action}");

    # build next states string
    $Param{NextStatesStrg} = $LayoutObject->BuildSelection(
        Data          => $Param{NextStates},
        Name          => 'NextStateID',
        Class         => 'Modernize',
        Translation   => 1,
        SelectedValue => $Param{NextState} || $Config->{StateDefault},
    );

    # build Destination string
    my %NewTo;
    if ( $Param{FromList} ) {
        for my $FromKey ( sort keys %{ $Param{FromList} } ) {
            $NewTo{"$FromKey||$Param{FromList}->{$FromKey}"} = $Param{FromList}->{$FromKey};
        }
    }

    if ( $ConfigObject->Get('Ticket::Frontend::NewQueueSelectionType') eq 'Queue' ) {
        $Param{FromStrg} = $LayoutObject->AgentQueueListOption(
            Data           => \%NewTo,
            Multiple       => 0,
            Size           => 0,
            Class          => 'Validate_Required Modernize ' . ( $Param{Errors}->{DestinationInvalid} || ' ' ),
            Name           => 'Dest',
            TreeView       => $TreeView,

            # KIX4OTRS-capeIT
            # SelectedID     => $Param{FromSelected},
            SelectedID => $Param{FromSelected} || $Param{DefaultQueueSelected} || '',
            Translation => 0,

            # EO KIX4OTRS-capeIT

            OnChangeSubmit => 0,
        );
    }
    else {
        $Param{FromStrg} = $LayoutObject->BuildSelection(
            Data       => \%NewTo,
            Class      => 'Validate_Required Modernize ' . ( $Param{Errors}->{DestinationInvalid} || ' ' ),
            Name       => 'Dest',
            TreeView   => $TreeView,
            SelectedID => $Param{FromSelected},
        );
    }

    # KIX4OTRS-capeIT
    # customer info string
    # if ( $ConfigObject->Get('Ticket::Frontend::CustomerInfoCompose') ) {
    #     $Param{CustomerTable} = $LayoutObject->AgentCustomerViewTable(
    #         Data => $Param{CustomerData},
    #         Max  => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
    #     );
    #     $LayoutObject->Block(
    #         Name => 'CustomerTable',
    #         Data => \%Param,
    #     );
    # }

    # load KIXSidebar
    $Param{KIXSidebarContent} = $LayoutObject->AgentKIXSidebar(%Param);

    # EO KIX4OTRS-capeIT

    # prepare errors!
    if ( $Param{Errors} ) {
        for my $ErrorKey ( sort keys %{ $Param{Errors} } ) {
            $Param{$ErrorKey} = $LayoutObject->Ascii2Html( Text => $Param{Errors}->{$ErrorKey} );
        }
    }

    # From external
    my $ShowErrors = 1;
    if (
        defined $Param{FromExternalCustomer}
        &&
        defined $Param{FromExternalCustomer}->{Email} &&
        defined $Param{FromExternalCustomer}->{Customer}
        )
    {
        $ShowErrors = 0;
        $LayoutObject->Block(
            Name => 'FromExternalCustomer',
            Data => $Param{FromExternalCustomer},
        );
    }

    # Cc
    my $CustomerCounterCc = 0;
    if ( $Param{MultipleCustomerCc} ) {
        for my $Item ( @{ $Param{MultipleCustomerCc} } ) {
            if ( !$ShowErrors ) {

                # set empty values for errors
                $Item->{CustomerError}    = '';
                $Item->{CustomerDisabled} = '';
                $Item->{CustomerErrorMsg} = 'CustomerGenericServerErrorMsg';
            }
            $LayoutObject->Block(
                Name => 'CcMultipleCustomer',
                Data => $Item,
            );
            $LayoutObject->Block(
                Name => 'Cc' . $Item->{CustomerErrorMsg},
                Data => $Item,
            );
            if ( $Item->{CustomerError} ) {
                $LayoutObject->Block(
                    Name => 'CcCustomerErrorExplantion',
                );
            }
            $CustomerCounterCc++;
        }
    }

    if ( !$CustomerCounterCc ) {
        $Param{CcCustomerHiddenContainer} = 'Hidden';
    }

    # set customer counter
    $LayoutObject->Block(
        Name => 'CcMultipleCustomerCounter',
        Data => {
            CustomerCounter => $CustomerCounterCc++,
        },
    );

    # Bcc
    my $CustomerCounterBcc = 0;
    if ( $Param{MultipleCustomerBcc} ) {
        for my $Item ( @{ $Param{MultipleCustomerBcc} } ) {
            if ( !$ShowErrors ) {

                # set empty values for errors
                $Item->{CustomerError}    = '';
                $Item->{CustomerDisabled} = '';
                $Item->{CustomerErrorMsg} = 'CustomerGenericServerErrorMsg';
            }
            $LayoutObject->Block(
                Name => 'BccMultipleCustomer',
                Data => $Item,
            );
            $LayoutObject->Block(
                Name => 'Bcc' . $Item->{CustomerErrorMsg},
                Data => $Item,
            );
            if ( $Item->{CustomerError} ) {
                $LayoutObject->Block(
                    Name => 'BccCustomerErrorExplantion',
                );
            }
            $CustomerCounterBcc++;
        }
    }

    if ( !$CustomerCounterBcc ) {
        $Param{BccCustomerHiddenContainer} = 'Hidden';
    }

    # set customer counter
    $LayoutObject->Block(
        Name => 'BccMultipleCustomerCounter',
        Data => {
            CustomerCounter => $CustomerCounterBcc++,
        },
    );

    # To
    my $CustomerCounter = 0;
    if ( $Param{MultipleCustomer} ) {
        for my $Item ( @{ $Param{MultipleCustomer} } ) {
            if ( !$ShowErrors ) {

                # set empty values for errors
                $Item->{CustomerError}    = '';
                $Item->{CustomerDisabled} = '';
                $Item->{CustomerErrorMsg} = 'CustomerGenericServerErrorMsg';
            }
            $LayoutObject->Block(
                Name => 'MultipleCustomer',
                Data => $Item,
            );
            $LayoutObject->Block(
                Name => $Item->{CustomerErrorMsg},
                Data => $Item,
            );
            if ( $Item->{CustomerError} ) {
                $LayoutObject->Block(
                    Name => 'CustomerErrorExplantion',
                );
            }
            $CustomerCounter++;
        }
    }

    if ( !$CustomerCounter ) {
        $Param{CustomerHiddenContainer} = 'Hidden';
    }

    # set customer counter
    $LayoutObject->Block(
        Name => 'MultipleCustomerCounter',
        Data => {
            CustomerCounter => $CustomerCounter++,
        },
    );

    if ( $Param{ToInvalid} && $Param{Errors} && !$Param{Errors}->{ToErrorType} ) {
        $LayoutObject->Block(
            Name => 'ToServerErrorMsg',
        );
    }
    if ( $Param{Errors}->{ToErrorType} || !$ShowErrors ) {
        $Param{ToInvalid} = '';
    }

    if ( $Param{CcInvalid} && $Param{Errors} && !$Param{Errors}->{CcErrorType} ) {
        $LayoutObject->Block(
            Name => 'CcServerErrorMsg',
        );
    }
    if ( $Param{Errors}->{CcErrorType} || !$ShowErrors ) {
        $Param{CcInvalid} = '';
    }

    if ( $Param{BccInvalid} && $Param{Errors} && !$Param{Errors}->{BccErrorType} ) {
        $LayoutObject->Block(
            Name => 'BccServerErrorMsg',
        );
    }
    if ( $Param{Errors}->{BccErrorType} || !$ShowErrors ) {
        $Param{BccInvalid} = '';
    }

    my $DynamicFieldNames = $Self->_GetFieldsToUpdate(
        OnlyDynamicFields => 1
    );

    # create a string with the quoted dynamic field names separated by commas
    # KIX4OTRS-capeIT
    if ( !$Param{DynamicFieldNamesStrg} ) {
        $Param{DynamicFieldNamesStrg} = '';
    }

    # EO KIX4OTRS-capeIT
    if ( IsArrayRefWithData($DynamicFieldNames) ) {
        for my $Field ( @{$DynamicFieldNames} ) {
            $Param{DynamicFieldNamesStrg} .= ", '" . $Field . "'";
        }
    }

    # build type string
    if ( $ConfigObject->Get('Ticket::Type') ) {
        $Param{TypeStrg} = $LayoutObject->BuildSelection(
            Data         => $Param{Types},
            Name         => 'TypeID',
            Class        => 'Validate_Required Modernize ' . ( $Param{Errors}->{TypeInvalid} || ' ' ),

            # KIX4OTRS-capeIT
            # SelectedID   => $Param{TypeID},
            SelectedID => $Param{TypeID} || $Param{DefaultTypeID},

            # EO KIX4OTRS-capeIT

            PossibleNone => 1,
            Sort         => 'AlphanumericValue',
            Translation  => 0,
        );
        $LayoutObject->Block(
            Name => 'TicketType',
            Data => {%Param},
        );
    }

    # build service string
    if ( $ConfigObject->Get('Ticket::Service') ) {

        # KIX4OTRS-capeIT
        my $ListOptionJson = $LayoutObject->AgentListOptionJSON(
            [
                {
                    Name => 'Services',
                    Data => $Param{Services},
                },
            ],
        );

        # EO KIX4OTRS-capeIT

        if ( $Config->{ServiceMandatory} ) {
            $Param{ServiceStrg} = $LayoutObject->BuildSelection(

                # KIX4OTRS-capeIT
                # Data         => $Param{Services},
                Data => $ListOptionJson->{Services}->{Data},

                # EO KIX4OTRS-capeIT
                Name         => 'ServiceID',
                Class        => 'Validate_Required Modernize ' . ( $Param{Errors}->{ServiceInvalid} || ' ' ),
                SelectedID   => $Param{ServiceID},
                PossibleNone => 1,
                TreeView     => $TreeView,
                Sort         => 'TreeView',

                # KIX4OTRS-capeIT
                DisabledOptions => $ListOptionJson->{Services}->{DisabledOptions} || 0,

                # EO KIX4OTRS-capeIT
                Translation  => 0,
                Max          => 200,
            );
            $LayoutObject->Block(
                Name => 'TicketServiceMandatory',
                Data => {%Param},
            );
        }
        else {
            $Param{ServiceStrg} = $LayoutObject->BuildSelection(

                # KIX4OTRS-capeIT
                # Data         => $Param{Services},
                Data => $ListOptionJson->{Services}->{Data},

                # EO KIX4OTRS-capeIT
                Name         => 'ServiceID',
                Class        => 'Modernize ' . ( $Param{Errors}->{ServiceInvalid} || ' ' ),
                SelectedID   => $Param{ServiceID},
                PossibleNone => 1,
                TreeView     => $TreeView,
                Sort         => 'TreeView',

                # KIX4OTRS-capeIT
                DisabledOptions => $ListOptionJson->{Services}->{DisabledOptions} || 0,

                # EO KIX4OTRS-capeIT
                Translation  => 0,
                Max          => 200,
            );
            $LayoutObject->Block(
                Name => 'TicketService',
                Data => {%Param},
            );
        }

        if ( $Config->{SLAMandatory} ) {
            $Param{SLAStrg} = $LayoutObject->BuildSelection(
                Data         => $Param{SLAs},
                Name         => 'SLAID',
                SelectedID   => $Param{SLAID},
                Class        => 'Validate_Required Modernize ' . ( $Param{Errors}->{SLAInvalid} || ' ' ),
                PossibleNone => 1,
                Sort         => 'AlphanumericValue',
                Translation  => 0,
                Max          => 200,
            );
            $LayoutObject->Block(
                Name => 'TicketSLAMandatory',
                Data => {%Param},
            );
        }
        else {
            $Param{SLAStrg} = $LayoutObject->BuildSelection(
                Data         => $Param{SLAs},
                Name         => 'SLAID',
                SelectedID   => $Param{SLAID},
                Class        => 'Modernize',
                PossibleNone => 1,
                Sort         => 'AlphanumericValue',
                Translation  => 0,
                Max          => 200,
            );
            $LayoutObject->Block(
                Name => 'TicketSLA',
                Data => {%Param},
            );
        }
    }

    # check if exists create templates regardless the queue
    my %StandardTemplates = $Kernel::OM->Get('Kernel::System::StandardTemplate')->StandardTemplateList(
        Valid => 1,
        Type  => 'Create',
    );

    # build text template string
    if ( IsHashRefWithData( \%StandardTemplates ) ) {
        $Param{StandardTemplateStrg} = $LayoutObject->BuildSelection(
            Data       => $Param{StandardTemplates}  || {},
            Name       => 'StandardTemplateID',
            SelectedID => $Param{StandardTemplateID} || '',
            Class      => 'Modernize',
            PossibleNone => 1,
            Sort         => 'AlphanumericValue',
            Translation  => 1,
            Max          => 200,
        );
        $LayoutObject->Block(
            Name => 'StandardTemplate',
            Data => {%Param},
        );
    }

    # build priority string
    if ( !$Param{PriorityID} ) {
        $Param{Priority} = $Config->{Priority};
    }
    $Param{PriorityStrg} = $LayoutObject->BuildSelection(
        Data          => $Param{Priorities},
        Name          => 'PriorityID',
        SelectedID    => $Param{PriorityID},
        Class         => 'Modernize',
        SelectedValue => $Param{Priority},
        Translation   => 1,
    );

    # pending data string
    $Param{PendingDateString} = $LayoutObject->BuildDateSelection(
        %Param,
        Format               => 'DateInputFormatLong',
        YearPeriodPast       => 0,
        YearPeriodFuture     => 5,

        # KIX4OTRS-capeIT
        # DiffTime         => $ConfigObject->Get('Ticket::Frontend::PendingDiffTime') || 0,
        DiffTime => $Param{DefaultDiffTime}
            || $ConfigObject->Get('Ticket::Frontend::PendingDiffTime')
            || 0,

        # EO KIX4OTRS-capeIT

        Class                => $Param{Errors}->{DateInvalid} || ' ',
        Validate             => 1,
        ValidateDateInFuture => 1,
    );

    # show owner selection
    if ( $ConfigObject->Get('Ticket::Frontend::NewOwnerSelection') ) {
        $LayoutObject->Block(
            Name => 'OwnerSelection',
            Data => \%Param,
        );
    }

    # show responsible selection
    if (
        $ConfigObject->Get('Ticket::Responsible')
        && $ConfigObject->Get('Ticket::Frontend::NewResponsibleSelection')
        )
    {
        $Param{ResponsibleUsers}->{''} = '-';
        $Param{ResponsibleOptionStrg} = $LayoutObject->BuildSelection(
            Data       => $Param{ResponsibleUsers},
            SelectedID => $Param{ResponsibleUserSelected},
            Name       => 'NewResponsibleID',
            Class      => 'Modernize',
        );
        $LayoutObject->Block(
            Name => 'ResponsibleSelection',
            Data => \%Param,
        );
    }

    # Dynamic fields
    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        # skip fields that HTML could not be retrieved
        next DYNAMICFIELD if !IsHashRefWithData(
            $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} }
        );

        # get the html strings form $Param
        my $DynamicFieldHTML = $Param{DynamicFieldHTML}->{ $DynamicFieldConfig->{Name} };

        # KIX4OTRS-capeIT
        my $Class = "";
        if ( !$DynamicFieldConfig->{Shown} ) {
            $Class = " Hidden";
            $DynamicFieldHTML->{Field} =~ s/Validate_Required//ig;
        }

        # EO KIX4OTRS-capeIT

        $LayoutObject->Block(
            Name => 'DynamicField',
            Data => {
                Name  => $DynamicFieldConfig->{Name},
                Label => $DynamicFieldHTML->{Label},
                Field => $DynamicFieldHTML->{Field},

                # KIX4OTRS-capeIT
                Class => $Class,

                # EO KIX4OTRS-capeIT
            },
        );

        # example of dynamic fields order customization
        $LayoutObject->Block(
            Name => 'DynamicField_' . $DynamicFieldConfig->{Name},
            Data => {
                Name  => $DynamicFieldConfig->{Name},
                Label => $DynamicFieldHTML->{Label},
                Field => $DynamicFieldHTML->{Field},
            },
        );
    }

    # show time accounting box
    if ( $ConfigObject->Get('Ticket::Frontend::AccountTime') ) {
        if ( $ConfigObject->Get('Ticket::Frontend::NeedAccountedTime') ) {
            $LayoutObject->Block(
                Name => 'TimeUnitsLabelMandatory',
                Data => \%Param,
            );
        }
        else {
            $LayoutObject->Block(
                Name => 'TimeUnitsLabel',
                Data => \%Param,
            );
        }
        $LayoutObject->Block(
            Name => 'TimeUnits',
            Data => \%Param,
        );
    }

    my $ShownOptionsBlock;

    # show spell check
    if ( $LayoutObject->{BrowserSpellChecker} ) {

        # check if need to call Options block
        if ( !$ShownOptionsBlock ) {
            $LayoutObject->Block(
                Name => 'TicketOptions',
                Data => {
                    %Param,
                },
            );

            # set flag to "true" in order to prevent calling the Options block again
            $ShownOptionsBlock = 1;
        }

        $LayoutObject->Block(
            Name => 'SpellCheck',
            Data => {
                %Param,
            },
        );
    }

    # show address book if the module is registered and java script support is available
    if (
        $ConfigObject->Get('Frontend::Module')->{AgentBook}
        && $LayoutObject->{BrowserJavaScriptSupport}
        )
    {

        # check if need to call Options block
        if ( !$ShownOptionsBlock ) {
            $LayoutObject->Block(
                Name => 'TicketOptions',
                Data => {
                    %Param,
                },
            );

            # set flag to "true" in order to prevent calling the Options block again
            $ShownOptionsBlock = 1;
        }

        $LayoutObject->Block(
            Name => 'AddressBook',
            Data => {
                %Param,
            },
        );
    }

    # show customer edit link
    my $OptionCustomer = $LayoutObject->Permission(
        Action => 'AdminCustomerUser',
        Type   => 'rw',
    );
    if ($OptionCustomer) {

        # check if need to call Options block
        if ( !$ShownOptionsBlock ) {
            $LayoutObject->Block(
                Name => 'TicketOptions',
                Data => {
                    %Param,
                },
            );

            # set flag to "true" in order to prevent calling the Options block again
            $ShownOptionsBlock = 1;
        }

        $LayoutObject->Block(
            Name => 'OptionCustomer',
            Data => {
                %Param,
            },
        );
    }

    # KIX4OTRS-capeIT
    # check if need to call Options block to provide link functionallity
    if ( !$ShownOptionsBlock ) {
        $LayoutObject->Block(
            Name => 'TicketOptions',
            Data => {
                %Param,
            },
        );

        # set flag to "true" in order to prevent calling the Options block again
        $ShownOptionsBlock = 1;
    }

    # EO KIX4OTRS-capeIT

    # show attachments
    ATTACHMENT:
    for my $Attachment ( @{ $Param{Attachments} } ) {
        if (
            $Attachment->{ContentID}
            && $LayoutObject->{BrowserRichText}
            && ( $Attachment->{ContentType} =~ /image/i )
            && ( $Attachment->{Disposition} eq 'inline' )
            )
        {
            next ATTACHMENT;
        }
        $LayoutObject->Block(
            Name => 'Attachment',
            Data => $Attachment,
        );
    }

    # add rich text editor
    if ( $LayoutObject->{BrowserRichText} ) {

        # use height/width defined for this screen
        $Param{RichTextHeight} = $Config->{RichTextHeight} || 0;
        $Param{RichTextWidth}  = $Config->{RichTextWidth}  || 0;

        $LayoutObject->Block(
            Name => 'RichText',
            Data => \%Param,
        );
    }

    # KIX4OTRS-capeIT
    # show right header
    my $HeaderTitle
        = $ConfigObject->Get('Frontend::Module')->{ $Self->{ActionReal} }
        ->{Description};
    $LayoutObject->Block(
        Name => 'MaskHeader',
        Data => {
            Text => $HeaderTitle,
        },
    );

    # EO KIX4OTRS-capeIT

    # get output back
    # KIX4OTRS-capeIT
    # return $LayoutObject->Output( TemplateFile => 'AgentTicketEmail', Data => \%Param );
    return $LayoutObject->Output(
        TemplateFile => 'AgentTicketEmail',
        Data         => {
            %Param,
            DefaultSet => $Self->{DefaultSet} || '',
        },
    );

    # EO KIX4OTRS-capeIT
}

sub _GetFieldsToUpdate {
    my ( $Self, %Param ) = @_;

    my @UpdatableFields;

    # set the fields that can be updateable via AJAXUpdate
    if ( !$Param{OnlyDynamicFields} ) {
        @UpdatableFields = qw(
            TypeID Dest NextStateID PriorityID ServiceID SLAID SignKeyID CryptKeyID To Cc Bcc
            StandardTemplateID
        );
    }

    # cycle through the activated Dynamic Fields for this screen
    DYNAMICFIELD:
    for my $DynamicFieldConfig ( @{ $Self->{DynamicField} } ) {
        next DYNAMICFIELD if !IsHashRefWithData($DynamicFieldConfig);

        my $IsACLReducible = $Kernel::OM->Get('Kernel::System::DynamicField::Backend')->HasBehavior(
            DynamicFieldConfig => $DynamicFieldConfig,
            Behavior           => 'IsACLReducible',
        );
        next DYNAMICFIELD if !$IsACLReducible;

        push @UpdatableFields, 'DynamicField_' . $DynamicFieldConfig->{Name};
    }

    return \@UpdatableFields;
}

# KIX4OTRS-capeIT
sub _GetShownDynamicFields {
    my ( $Self, %Param ) = @_;

    # get ticket object
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    # use only dynamic fields which passed the acl
    my %TicketAclFormData = $TicketObject->TicketAclFormData();

    # cycle through dynamic fields to get shown or hidden fields
    for my $DynamicField ( @{ $Self->{DynamicField} } ) {

        # if field was not configured initially set it as not visible
        if ( $Self->{NotShownDynamicFields}->{ $DynamicField->{Name} } ) {
            $DynamicField->{Shown} = 0;
        }
        else {

            # hide DynamicFields only if we have ACL's
            if (
                IsHashRefWithData( \%TicketAclFormData )
                && defined $TicketAclFormData{ $DynamicField->{Name} }
                )
            {
                if ( $TicketAclFormData{ $DynamicField->{Name} } >= 1 ) {
                    $DynamicField->{Shown} = 1;
                }
                else {
                    $DynamicField->{Shown} = 0;
                }
            }

            # else show them by default
            else {
                $DynamicField->{Shown} = 1;
            }
        }
    }

    return 1;
}
# EO KIX4OTRS-capeIT

1;
