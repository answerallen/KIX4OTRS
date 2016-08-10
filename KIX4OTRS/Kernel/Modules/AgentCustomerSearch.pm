# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Modules::AgentCustomerSearch;
## nofilter(TidyAll::Plugin::OTRS::Perl::DBObject)

use strict;
use warnings;

use Kernel::Language qw(Translatable);

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

    my $JSON = '';

    # get needed objects
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $EncodeObject       = $Kernel::OM->Get('Kernel::System::Encode');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');

    # get config for frontend
    $Self->{Config} = $ConfigObject->Get("Ticket::Frontend::$Self->{Action}");

    # search customers
    if ( !$Self->{Subaction} ) {

        # get needed params
        my $Search = $ParamObject->GetParam( Param => 'Term' ) || '';
        my $MaxResults = int( $ParamObject->GetParam( Param => 'MaxResults' ) || 20 );
        my $IncludeUnknownTicketCustomers
            = int( $ParamObject->GetParam( Param => 'IncludeUnknownTicketCustomers' ) || 0 );

        my $UnknownTicketCustomerList;

        if ($IncludeUnknownTicketCustomers) {

            # add customers that are not saved in any backend
            $UnknownTicketCustomerList = $TicketObject->SearchUnknownTicketCustomers(
                SearchTerm => $Search,
            );
        }

        # get customer list
        my %CustomerUserList = $CustomerUserObject->CustomerSearch(
            Search => $Search,
        );
        map { $CustomerUserList{$_} = $UnknownTicketCustomerList->{$_} } keys %{$UnknownTicketCustomerList};

        # build data
        my @Data;
        CUSTOMERUSERID:
        for my $CustomerUserID ( sort keys %CustomerUserList )
        {

            my $CustomerValue = $CustomerUserList{$CustomerUserID};

            # replace new lines with one space (see bug#11133)
            $CustomerValue =~ s/\n/ /gs;
            $CustomerValue =~ s/\r/ /gs;

            if ( !( grep { $_->{CustomerValue} eq $CustomerValue } @Data ) ) {
                push @Data, {
                    CustomerKey   => $CustomerUserID,
                    CustomerValue => $CustomerValue,
                };
            }
            last CUSTOMERUSERID if scalar @Data >= $MaxResults;
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => \@Data,
        );
    }

    # get customer info
    elsif ( $Self->{Subaction} eq 'CustomerInfo' ) {

        # KIX4OTRS-capeIT
        my $CallingAction = $ParamObject->GetParam( Param => 'CallingAction' ) || '';

        # EO KIX4OTRS-capeIT

        # get params
        my $CustomerUserID = $ParamObject->GetParam( Param => 'CustomerUserID' ) || '';

        my $CustomerID              = '';
        my $CustomerTableHTMLString = '';

        # KIX4OTRS-capeIT
        my $CustomerDetailsTableHTMLString = '';

        # EO KIX4OTRS-capeIT

        # get customer data
        my %CustomerData = $CustomerUserObject->CustomerUserDataGet(
            User => $CustomerUserID,
        );

        # get customer id
        if ( $CustomerData{UserCustomerID} ) {
            $CustomerID = $CustomerData{UserCustomerID};
        }

        # build html for customer info table
        # KIX4OTRS-capeIT
        # if ( $ConfigObject->Get('Ticket::Frontend::CustomerInfoCompose') ) {
        if ( %CustomerData && $ConfigObject->Get('Ticket::Frontend::CustomerInfoCompose') ) {

            # EO KIX4OTRS-capeIT

            $CustomerTableHTMLString = $LayoutObject->AgentCustomerViewTable(

                # KIX4OTRS-capeIT
                # Data => {%CustomerData},
                Data => { %CustomerData, CallingAction => $CallingAction, AJAX => 1 },

                # EO KIX4OTRS-capeIT
                Max => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
            );

            # KIX4OTRS-capeIT
            $CustomerDetailsTableHTMLString = $LayoutObject->AgentCustomerDetailsViewTable(
                Data => { %CustomerData, CallingAction => $CallingAction, AJAX => 1 },
                Max => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
            );

            # EO KIX4OTRS-capeIT
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                CustomerID              => $CustomerID,
                CustomerTableHTMLString => $CustomerTableHTMLString,

                # KIX4OTRS-capeIT
                CustomerDetailsTableHTMLString => $CustomerDetailsTableHTMLString,

                # EO KIX4OTRS-capeIT
            },
        );
    }

    # get customer tickets
    elsif ( $Self->{Subaction} eq 'CustomerTickets' ) {

        # get params
        my $CustomerUserID = $ParamObject->GetParam( Param => 'CustomerUserID' ) || '';
        my $CustomerID     = $ParamObject->GetParam( Param => 'CustomerID' )     || '';

        # get secondary customer ids
        my @CustomerIDs;
        if ($CustomerUserID) {
            @CustomerIDs = $CustomerUserObject->CustomerIDs(
                User => $CustomerUserID,
            );
        }

        # add own customer id
        if ($CustomerID) {
            push @CustomerIDs, $CustomerID;
        }

        my $View    = $ParamObject->GetParam( Param => 'View' )    || '';
        my $SortBy  = $ParamObject->GetParam( Param => 'SortBy' )  || 'Age';
        my $OrderBy = $ParamObject->GetParam( Param => 'OrderBy' ) || 'Down';

        my @ViewableTickets;
        if (@CustomerIDs) {
            @ViewableTickets = $TicketObject->TicketSearch(
                Result        => 'ARRAY',
                Limit         => 250,
                SortBy        => [$SortBy],
                OrderBy       => [$OrderBy],
                CustomerIDRaw => \@CustomerIDs,
                UserID        => $Self->{UserID},
                Permission    => 'ro',
            );
        }

        my $LinkSort = 'Subaction=' . $Self->{Subaction}
            . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';
        my $LinkPage = 'Subaction=' . $Self->{Subaction}
            . ';View=' . $LayoutObject->Ascii2Html( Text => $View )
            . ';SortBy=' . $LayoutObject->Ascii2Html( Text => $SortBy )
            . ';OrderBy=' . $LayoutObject->Ascii2Html( Text => $OrderBy )
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';
        my $LinkFilter = 'Subaction=' . $Self->{Subaction}
            . ';CustomerUserID=' . $LayoutObject->Ascii2Html( Text => $CustomerUserID )
            . ';CustomerID=' . $LayoutObject->Ascii2Html( Text => $CustomerID )
            . '&';

        my $CustomerTicketsHTMLString = '';
        if (@ViewableTickets) {
            $CustomerTicketsHTMLString .= $LayoutObject->TicketListShow(
                TicketIDs  => \@ViewableTickets,
                Total      => scalar @ViewableTickets,
                Env        => $Self,
                View       => $View,
                TitleName  => Translatable('Customer History'),
                LinkPage   => $LinkPage,
                LinkSort   => $LinkSort,
                LinkFilter => $LinkFilter,
                Output     => 'raw',

                OrderBy => $OrderBy,
                SortBy  => $SortBy,
                AJAX    => 1,
            );
        }

        # build JSON output
        $JSON = $LayoutObject->JSONEncode(
            Data => {
                CustomerTicketsHTMLString => $CustomerTicketsHTMLString,
            },
        );
    }

    # send JSON response
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );

}

1;
