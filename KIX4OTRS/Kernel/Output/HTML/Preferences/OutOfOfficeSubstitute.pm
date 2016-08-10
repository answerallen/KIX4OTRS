# --
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

package Kernel::Output::HTML::Preferences::OutOfOfficeSubstitute;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    if ( !$Self->{UserID} ) {
        die "Got no UserID!";
    }

    return $Self;
}

sub Param {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');

    my @Params;
    if ( $Param{UserData}->{OutOfOffice} ) {
        my %ShownUsers = $UserObject->UserList(
            Type  => 'Long',
            Valid => 1,
        );
        delete( $ShownUsers{ $Param{UserData}->{UserID} } );
        $ShownUsers{''} = '-';

        $Param{OptionSubstitute} = $LayoutObject->BuildSelection(
            Data       => \%ShownUsers,
            SelectedID => $Param{UserData}->{OutOfOfficeSubstitute} || '',
            Name       => 'OutOfOfficeSubstitute',
            Multiple   => 0,
            Size       => 0,
            Class => 'Modernize'
        );
        $Param{OptionSubstituteNote} = $Param{UserData}->{OutOfOfficeSubstituteNote} || '';

        push(
            @Params,
            {
                %Param,
                Block => 'OutOfOfficeSubstitute',
            },
        );
    }

    return @Params;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $UserObject    = $Kernel::OM->Get('Kernel::System::User');
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Key (qw(OutOfOfficeSubstitute OutOfOfficeSubstituteNote)) {

        $Param{$Key} = $ParamObject->GetParam( Param => $Key );

        if ( defined( $Param{$Key} ) ) {
            $Param{$Key} =~ s/^\s+//g;
            $Param{$Key} =~ s/\s+$//g;

            # pref update db
            if ( !$ConfigObject->Get('DemoSystem') ) {
                $UserObject->SetPreferences(
                    UserID => $Param{UserData}->{UserID},
                    Key    => $Key,
                    Value  => $Param{$Key},
                );
            }

            # update SessionID
            if ( $Param{UserData}->{UserID} eq $Self->{UserID} ) {
                $SessionObject->UpdateSessionID(
                    SessionID => $Self->{SessionID},
                    Key       => $Key,
                    Value     => $Param{$Key},
                );
            }
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
