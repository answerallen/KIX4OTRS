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

package Kernel::Modules::KIXSidebarChecklistAJAXHandler;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # create needed objects
    $Self->{Config}
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::KIXSidebarChecklist');

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $Result;

    # save new tasks or change tasks
    if ( $Self->{Subaction} eq 'UpdateTasks' ) {

        my $TicketTasks = $ParamObject->GetParam( Param => 'TaskString' ) || '';
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

        # update the task list
        my $NewTasks = $TicketObject->TicketChecklistUpdate(
            TaskString => $TicketTasks,
            TicketID   => $TicketID,
            State      => $Self->{Config}->{ItemStateDefault} || 'open',
        );

        # create task list
        my $Class = "";
        for my $Task ( sort { $a <=> $b } keys %{$NewTasks} ) {

            $LayoutObject->Block(
                Name => 'Task',
                Data => {
                    StateIcon  => $Self->{Config}->{ItemStateIcon}->{ $NewTasks->{$Task}->{State} },
                    StateStyle => $Self->{Config}->{ItemStateStyle}->{ $NewTasks->{$Task}->{State} },
                    ID         => $NewTasks->{$Task}->{ID},
                    Content    => $NewTasks->{$Task}->{Task},
                    Style      => $Class
                },
            );
            if ( !$Class ) {
                $Class = "background-color:#F0F0F0";
            }
            else {
                $Class = "";
            }
        }

        # create content for task list
        my $NewTableContent = $LayoutObject->Output(
            TemplateFile => 'AgentKIXSidebarChecklistTable',
            Data         => {},
        );

        # build JSON output
        my $JSON = $LayoutObject->JSONEncode(
            Data => $NewTableContent,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    # save state update
    elsif ( $Self->{Subaction} eq 'SaveTaskState' ) {

        my $TaskState = $ParamObject->GetParam( Param => 'State' ) || 'open';
        my $TaskID = $ParamObject->GetParam( Param => 'TaskID' );

        # task state update
        my $Result = $TicketObject->TicketChecklistTaskStateUpdate(
            TaskID => $TaskID,
            State  => $TaskState,
        );

        # build JSON output
        my $JSON = $LayoutObject->JSONEncode(
            Data => $Result,
        );

        return $LayoutObject->Attachment(
            ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
            Content     => $JSON,
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    return 1;
}

1;
