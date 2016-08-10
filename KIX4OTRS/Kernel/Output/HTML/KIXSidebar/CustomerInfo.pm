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

package Kernel::Output::HTML::KIXSidebar::CustomerInfo;

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

    # create needed objects
    my $ConfigObject       = $Kernel::OM->Get('Kernel::Config');
    my $CustomerUserObject = $Kernel::OM->Get('Kernel::System::CustomerUser');
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Content;

    if ( !$Param{CustomerData} && $Param{CustomerUserID} ) {
        my %CustomerUserData = $CustomerUserObject->CustomerUserDataGet(
            User => $Param{CustomerUserID},
        );
        $Param{CustomerData} = \%CustomerUserData;
    }

    if ( $Param{TicketID} && !$Param{TicketData} ) {
        my %Ticket = $TicketObject->TicketGet(
            TicketID      => $Param{TicketID},
            DynamicFields => 1,
            UserID        => $Param{UserID} || 1,
        );
        $Param{TicketData} = \%Ticket;
    }

    if ( $Param{ArticleID} && !$Param{ArticleData} ) {
        my %Article = $TicketObject->ArticleGet(
            ArticleID     => $Param{ArticleID},
            DynamicFields => 1,
            UserID        => $Param{UserID} || 1,
        );
        $Param{ArticleData} = \%Article;
    }

    # join Data parts
    my %Ticket;
    if ( $Param{TicketData} ) {
        %Ticket = %{ $Param{TicketData} };
    }
    my %Article;
    if ( $Param{ArticleData} ) {
        %Article = %{ $Param{ArticleData} };
    }
    $Param{TicketData} = {
        %Ticket,
        %Article,
    };

    # customer info string
    if ( ref( $Param{CustomerData} ) eq 'HASH' && %{ $Param{CustomerData} } ) {
        my $CustomerInfoString = $ConfigObject->Get('DefaultCustomerInfoString');

        $Param{CustomerTable} = $LayoutObject->AgentCustomerViewTable(
            Data   => $Param{CustomerData},
            Ticket => $Param{TicketData},
            Max    => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
            CallingAction => $Param{Action}
        );

        if ($CustomerInfoString) {
            $Param{CustomerDetailsTable} = $LayoutObject->AgentCustomerDetailsViewTable(
                Data   => $Param{CustomerData},
                Ticket => $Param{TicketData},
                Max => $ConfigObject->Get('Ticket::Frontend::CustomerInfoComposeMaxSize'),
            );
            $LayoutObject->Block(
                Name => 'CustomerDetailsMagnifier',
                Data => \%Param,
            );

        }

        $LayoutObject->Block(
            Name => 'CustomerDetails',
            Data => \%Param,
        );
    }

    # show customer email selection
    if ( $Self->{Action} eq 'AgentTicketZoom' ) {

        # create empty dropdown
        $Param{CustomerEmailSelection} = $LayoutObject->BuildSelection(
            Name         => 'CustomerUserEmail',
            Data         => [],
            Translation  => 0,
            PossibleNone => 0,
        );

        $LayoutObject->Block(
            Name => 'CustomerEmailSelection',
            Data => \%Param,
        );
    }

    # output result
    $Content = $LayoutObject->Output(
        TemplateFile => 'AgentKIXSidebarCustomerInfo',
        Data         => {
            %Param,
            %{ $Self->{Config} },
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Content;
}

1;
