# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
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

package Kernel::Modules::ToolbarSearchProfileAJAXHandler;

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

    # get needed objects
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $Result;

    for my $Needed (qw(Subaction SearchProfile)) {
        $Param{$Needed} = $ParamObject->GetParam( Param => $Needed ) || '';
        if ( !$Param{$Needed} ) {
            return $LayoutObject->ErrorScreen( Message => "Need $Needed!", );
        }
    }

    my $Config = $ConfigObject->Get('ToolbarSearchProfile');
    my %SearchProfileData;

    $Param{SearchProfile} =~ /(.*?)Search(.*?)::(.*)/;
    my @Module = split( /::/, $Config->{$1}->{Module} );
    $SearchProfileData{Action}    = $Module[2];
    $SearchProfileData{Subaction} = $Config->{$1}->{Subaction};
    $SearchProfileData{Profile}   = $3;

    if ($2) {
        $SearchProfileData{ClassID} = $2;
    }

    if ( $1 ne 'Ticket' ) {
        my @TmpArray = split( /::/, $3 );
        pop(@TmpArray);
        $SearchProfileData{Profile} = join( "::", @TmpArray );
    }

    my $JSON = $LayoutObject->JSONEncode(
        Data => \%SearchProfileData,
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
