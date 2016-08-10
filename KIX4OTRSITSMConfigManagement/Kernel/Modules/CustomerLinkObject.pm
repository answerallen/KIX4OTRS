# --
# Kernel/Modules/CustomerLinkObject.pm - to link objects in CustomerFrontend
# based upon AgentLinkObject
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Frank(dot)Oberender(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::CustomerLinkObject;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::Log',
    'Kernel::System::User',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # create needed objects
    $Self->{LinkObject}            = $Kernel::OM->Get('Kernel::System::LinkObject');
    $Self->{UserObject}           = $Kernel::OM->Get('Kernel::System::User');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # ------------------------------------------------------------ #
    # close
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Close' ) {
        return $Self->{LayoutObject}->PopupClose(
            Reload => 1,
        );
    }

    # KIX4OTRS-capeIT
    $Self->{Subaction} = $Self->{ParamObject}->GetParam( Param => 'SubAction' )
        if ( !$Self->{Subaction} );

    # EO KIX4OTRS-capeIT

    # get params
    my %Form;
    $Form{SourceObject} = $Self->{ParamObject}->GetParam( Param => 'SourceObject' );
    $Form{SourceKey}    = $Self->{ParamObject}->GetParam( Param => 'SourceKey' );
    $Form{Mode}         = $Self->{ParamObject}->GetParam( Param => 'Mode' ) || 'Normal';

    # check needed stuff
    if ( !$Form{SourceObject} || !$Form{SourceKey} ) {
        return $Self->{LayoutObject}->ErrorScreen(
            Message => "Need SourceObject and SourceKey!",
            Comment => 'Please contact the admin.',
        );
    }

    # get form params
    $Form{TargetIdentifier} = $Self->{ParamObject}->GetParam( Param => 'TargetIdentifier' )
        || $Form{SourceObject};

    # investigate the target object
    if ( $Form{TargetIdentifier} =~ m{ \A ( .+? ) :: ( .+ ) \z }xms ) {
        $Form{TargetObject}    = $1;
        $Form{TargetSubObject} = $2;
    }
    else {
        $Form{TargetObject} = $Form{TargetIdentifier};
    }

    # get possible objects list
    my %PossibleObjectsList = $Self->{LinkObject}->PossibleObjectsList(
        Object => $Form{SourceObject},
        UserID => $Self->{UserID},
    );

    # check if target object is a possible object to link with the source object
    if ( !$PossibleObjectsList{ $Form{TargetObject} } ) {
        my @PossibleObjects = sort { lc $a cmp lc $b } keys %PossibleObjectsList;
        $Form{TargetObject} = $PossibleObjects[0];
    }

    # set mode params
    if ( $Form{Mode} eq 'Temporary' ) {
        $Form{State} = 'Temporary';
    }
    else {
        $Form{Mode}  = 'Normal';
        $Form{State} = 'Valid';
    }

    # get source object description
    my %SourceObjectDescription = $Self->{LinkObject}->ObjectDescriptionGet(
        Object => $Form{SourceObject},
        Key    => $Form{SourceKey},
        Mode   => $Form{Mode},
        UserID => $Self->{UserID},
    );

    # KIX4OTRS-capeIT

    # ------------------------------------------------------------ #
    # delete one single link
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'SingleLinkDelete' ) {

        # delete all temporary links older than one day
        $Self->{LinkObject}->LinkCleanup(
            State  => 'Temporary',
            Age    => ( 60 * 60 * 24 ),
            UserID => $Self->{UserID},
        );

        my $DelResult = 0;

        # Ticket comes as target
        if (
            $Self->{ParamObject}->GetParam( Param => 'TargetKey' )
            &&
            $Self->{ParamObject}->GetParam( Param => 'TargetObject' )
            )
        {

            my $LinkListWithData = $Self->{LinkObject}->LinkListWithData(
                Object => 'Ticket',
                Key    => $Self->{ParamObject}->GetParam( Param => 'TargetKey' ),
                State  => $Form{State},
                UserID => 1,                                                       #$Self->{UserID},
            );
            for my $LinkObject ( keys %{$LinkListWithData} ) {
                next if $LinkObject ne "ITSMConfigItem";
                for my $LinkType ( keys %{ $LinkListWithData->{$LinkObject} } ) {
                    for my $LinkDirection (
                        keys %{ $LinkListWithData->{$LinkObject}->{$LinkType} }
                        )
                    {
                        for my $LinkItem (
                            keys
                            %{ $LinkListWithData->{$LinkObject}->{$LinkType}->{$LinkDirection} }
                            )
                        {
                            my $DelKey1    = $Form{SourceKey};
                            my $DelObject1 = $Form{SourceObject};
                            my $DelKey2    = $Self->{ParamObject}->GetParam( Param => 'TargetKey' );
                            my $DelObject2 =
                                $Self->{ParamObject}->GetParam( Param => 'Targetobject' );
                            if ( $LinkDirection eq "Source" ) {
                                $DelKey1 = $Self->{ParamObject}->GetParam( Param => 'TargetKey' );
                                $DelObject1 =
                                    $Self->{ParamObject}->GetParam( Param => 'Targetobject' );
                                $DelKey2    = $Form{SourceKey};
                                $DelObject2 = $Form{SourceObject};
                            }

                            # delete link from database
                            $DelResult = $Self->{LinkObject}->LinkDelete(
                                Object1 => $Form{SourceObject},
                                Key1    => $Form{SourceKey},
                                Object2 =>
                                    $Self->{ParamObject}->GetParam( Param => 'TargetObject' ),
                                Key2 => $Self->{ParamObject}->GetParam( Param => 'TargetKey' ),
                                Type => $LinkType,
                                UserID => $Self->{UserID},
                            );
                        }
                    }
                }
            }
        }
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/plain; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $DelResult,
            Type        => 'inline',
            NoCache     => 1,
        );

        return 1;
    }

    # ------------------------------------------------------------ #
    # add one single link
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'SingleLinkAdd' ) {

        my $LinkType = $Self->{ConfigObject}->Get('KIXSidebarConfigItemLink::LinkType')
            || 'Normal';

        my $AddResult = 0;

        # Ticket comes as target
        if (
            $Self->{ParamObject}->GetParam( Param => 'TargetKey' )
            &&
            $Self->{ParamObject}->GetParam( Param => 'TargetObject' )
            )
        {

            $AddResult = $Self->{LinkObject}->LinkAdd(
                SourceObject => $Form{SourceObject},
                SourceKey    => $Form{SourceKey},
                TargetObject => $Self->{ParamObject}->GetParam( Param => 'TargetObject' ),
                TargetKey    => $Self->{ParamObject}->GetParam( Param => 'TargetKey' ),
                Type         => $LinkType,
                State        => $Form{State},
                UserID       => $Self->{ConfigObject}->Get('CustomerPanelUserID'),
            );
        }
        return $Self->{LayoutObject}->Attachment(
            ContentType => 'text/plain; charset=' . $Self->{LayoutObject}->{Charset},
            Content     => $AddResult,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # EO KIX4OTRS-capeIT

}

1;
