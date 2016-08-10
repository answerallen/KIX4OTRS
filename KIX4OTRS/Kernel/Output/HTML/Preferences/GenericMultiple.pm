# --
# based upon PreferencesGeneric.pm
# original Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Preferences::GenericMultiple;

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

sub Param {
    my ( $Self, %Param ) = @_;

    my @Params;
    my $GetParam
        = $Kernel::OM->Get('Kernel::System::Web::Request')
        ->GetParam( Param => $Self->{ConfigItem}->{PrefKey} );
    if ( !defined $GetParam ) {
        $GetParam = defined( $Param{UserData}->{ $Self->{ConfigItem}->{PrefKey} } )
            ? $Param{UserData}->{ $Self->{ConfigItem}->{PrefKey} }
            : $Self->{ConfigItem}->{DataSelected};
    }
    my @SelectedArray = split( ',', $GetParam );

    push(
        @Params,
        {
            %Param,
            Name       => $Self->{ConfigItem}->{PrefKey},
            SelectedID => \@SelectedArray,
            Multiple   => 1,
        },
    );
    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Key ( sort keys %{ $Param{GetParam} } ) {
        my @Array = @{ $Param{GetParam}->{$Key} };

        # pref update db
        if ( !$Kernel::OM->Get('Kernel::Config')->Get('DemoSystem') ) {
            $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                UserID => $Param{UserData}->{UserID},
                Key    => $Key,
                Value  => join( ',', @Array ),
            );
        }
        if ( $Param{UserData}->{UserID} eq $Self->{UserID} ) {

            # update SessionID
            $Kernel::OM->Get('Kernel::System::AuthSession')->UpdateSessionID(
                SessionID => $Self->{SessionID},
                Key       => $Key,
                Value     => join( ',', @Array ),
            );
        }
    }
    $Self->{Message} = 'Preferences updated successfully!';
    return 1;
}

sub Error {
    my ( $Self, %Param ) = @_;

    return $Self->{Error} || '';
}

sub Message {
    my ( $Self, %Param ) = @_;

    return $Self->{Message} || '';
}

1;
