# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ToolBar::TicketSearchProfile;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Output::HTML::Layout',
    'Kernel::Config',
    'Kernel::System::SearchProfile',
    'Kernel::System::User',

    # KIX4OTRS-capeIT
    'Kernel::System::GeneralCatalog',

    # EO KIX4OTRS-capeIT
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get UserID param
    $Self->{UserID} = $Param{UserID} || die "Got no UserID!";

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject        = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject        = $Kernel::OM->Get('Kernel::Config');
    my $SearchProfileObject = $Kernel::OM->Get('Kernel::System::SearchProfile');
    my $UserObject         = $Kernel::OM->Get('Kernel::System::User');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    # get user data
    my %User = $UserObject->GetUserData(
        UserID => $Self->{UserID},
    );

    # KIX4OTRS-capeIT
    # get all possible search profiles
    my $Config = $ConfigObject->Get('ToolbarSearchProfile');
    my @Bases = $SearchProfileObject->SearchProfilesBasesGet();
    my %SearchProfiles;
    for my $Base (@Bases) {

        next if $Base =~ /(.*?)Search(.*)/ && !defined $Config->{$1};

        my %Profiles = $SearchProfileObject->SearchProfileList(
            Base             => $Base,
            UserLogin        => $User{UserLogin},
            WithSubscription => 1
        );

        my $DisplayBase = $Base;
        my $Extended    = '';
        if ( $Base =~ /(.*?)Search(.*)/ ) {
            if ( $2 && $1 eq 'ConfigItem' ) {
                my $Classes
                    = $GeneralCatalogObject->ItemList(
                    Class => 'ITSM::ConfigItem::Class'
                    );
                $DisplayBase = $1;
                if ( defined $Classes->{$2} && $Classes->{$2} ) {
                    $DisplayBase
                        .= "::" . $LayoutObject->{LanguageObject}->Get( $Classes->{$2} );
                }
                elsif ( $2 eq 'All' ) {
                    $DisplayBase .= "::" . $LayoutObject->{LanguageObject}->Get('All');
                }
            }
            else {
                $DisplayBase = $1;
            }
        }

        for my $Profile ( keys %Profiles ) {
            if ( $Profile =~ /(.*?)::(.*)/ ) {
                $SearchProfiles{ $Base . '::' . $Profile } = $DisplayBase . '::' . $LayoutObject->{LanguageObject}->Get($1) . $Extended;
            }
        }
    }

    # EO KIX4OTRS-capeIT

    # create search profiles string
    my $ProfilesStrg = $LayoutObject->BuildSelection(
        Data => {
            # KIX4OTRS-capeIT
            # '', '-',
            # $SearchProfileObject->SearchProfileList(
            #     Base      => 'TicketSearch',
            #     UserLogin => $User{UserLogin},
            # ),
            %SearchProfiles

            # EO KIX4OTRS-capeIT
        },

        # KIX4OTRS-capeIT
        # Name       => 'Profile',
        # ID         => 'ToolBarSearchProfile',
        Name => 'SearchProfile',
        ID   => 'ToolBarSearchProfiles',

        # EO KIX4OTRS-capeIT
        Title      => $LayoutObject->{LanguageObject}->Translate('Search template'),
        SelectedID   => '',
        Max          => $Param{Config}->{MaxWidth},
        TreeView     => 1,
        Class      => 'Modernize',
        Sort         => 'TreeView',
        PossibleNone => 1
    );

    my $Priority = $Param{Config}->{'Priority'};
    my %Return   = ();
    $Return{ $Priority++ } = {
        Block       => $Param{Config}->{Block},
        Description => $Param{Config}->{Description},
        Name        => $Param{Config}->{Name},
        Image       => '',
        Link        => $ProfilesStrg,
        AccessKey   => '',
    };
    return %Return;
}

1;
