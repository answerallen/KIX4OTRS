# --
# Kernel/Modules/PopupSize.pm - set customized popup size
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

package Kernel::Modules::PopupSize;

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
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');
    my $UserObject    = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');

    # check needed stuff
    for my $Needed (qw(CallingAction)) {
        $Param{$Needed} = $ParamObject->GetParam( Param => $Needed ) || '';
        if ( !$Param{$Needed} ) {
            return $LayoutObject->ErrorScreen( Message => "Need $Needed!", );
        }
    }

    my $CallingAction = $ParamObject->GetParam( Param => 'CallingAction' );

    # get popup size
    if ( $Self->{Subaction} eq 'GetPopupSize' ) {

        # get user preferences
        my %UserPreferences = $UserObject->GetUserData(
            UserID => $Self->{UserID},
        );

        # get popup height
        $Param{PopupWidth}  = $UserPreferences{ $CallingAction . 'PopupWidth' }  || 0;
        $Param{PopupHeight} = $UserPreferences{ $CallingAction . 'PopupHeight' } || 0;

        # set stored size
        my @Data;
        push @Data, {
            Width  => $Param{PopupWidth},
            Height => $Param{PopupHeight},
        };

        # build JSON output
        my $JSON = $LayoutObject->JSONEncode(
            Data => \@Data,
        );

        # send JSON response
        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON || '',
            Type        => 'inline',
            NoCache     => 1,
        );

    }
    elsif ( $Self->{Subaction} eq 'UpdatePopupSize' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my $PopupWidth  = $ParamObject->GetParam( Param => 'Width' );
        my $PopupHeight = $ParamObject->GetParam( Param => 'Height' );

        # update ssession
        $SessionObject->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => $CallingAction . 'PopupWidth',
            Value     => $PopupWidth,
        );
        $SessionObject->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => $CallingAction . 'PopupHeight',
            Value     => $PopupHeight,
        );

        # update preferences
        if ( !$ConfigObject->Get('DemoSystem') ) {
            $UserObject->SetPreferences(
                UserID => $Self->{UserID},
                Key    => $CallingAction . 'PopupWidth',
                Value  => $PopupWidth,
            );
            $UserObject->SetPreferences(
                UserID => $Self->{UserID},
                Key    => $CallingAction . 'PopupHeight',
                Value  => $PopupHeight,
            );
        }

        # redirect
        return $LayoutObject->Attachment(
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => '',
        );
    }
}

1;
