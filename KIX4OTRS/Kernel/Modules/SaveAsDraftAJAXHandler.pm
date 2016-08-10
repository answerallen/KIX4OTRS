# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::SaveAsDraftAJAXHandler;

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
    my $EncodeObject      = $Kernel::OM->Get('Kernel::System::Encode');
    my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject       = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $CallingAction = $ParamObject->GetParam( Param => 'CallingAction' );
    $Self->{Config} = $ConfigObject->Get("Ticket::SaveAsDraftAJAXHandler");

    # get params
    my %GetParam;
    for my $Key ( @{ $Self->{Config}->{Attributes} } )
    {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' ) || 0;

    # the hardcoded unix timestamp 2147483646 is necessary for UploadCache FS backend
    my $FormID
        = '2147483646.SaveAsDraftAJAXHandler.'
        . $CallingAction . '.'
        . $Self->{UserID} . '.'
        . $TicketID;
    my $JSON = '1';

    # cleanup cache
    if ( $Self->{Subaction} ne 'GetFormContent' ) {
        $UploadCacheObject->FormIDRemove( FormID => $FormID );
    }

    if ( $Self->{Subaction} eq 'SaveFormContent' ) {

        # add attachment
        for my $Key ( keys %GetParam ) {

            # save file only if content given
            if ( defined $GetParam{$Key} && $GetParam{$Key} ) {
                my $FileID = $UploadCacheObject->FormIDAddFile(
                    FormID      => $FormID,
                    Filename    => $Key,
                    Content     => $GetParam{$Key},
                    ContentType => 'text/xml',
                );
            }
        }
    }
    elsif ( $Self->{Subaction} eq 'GetFormContent' ) {
        my @ContentItems = $UploadCacheObject->FormIDGetAllFilesData(
            FormID => $FormID,
        );

        my @Result;
        for my $Item (@ContentItems) {
            $Item->{Content} = $EncodeObject->Convert(
                Text => $Item->{Content},
                From => 'utf-8',
                To   => 'iso-8859-1',
            );
            push @Result, { Label => $Item->{Filename}, Value => $Item->{Content} };
        }

        $JSON = $LayoutObject->JSONEncode(
            Data => \@Result,
        );
    }
    elsif ( $Self->{Subaction} eq 'DeleteFormContent' ) {
        $JSON = $UploadCacheObject->FormIDRemove( FormID => $FormID ) || '0';
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON || '',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
