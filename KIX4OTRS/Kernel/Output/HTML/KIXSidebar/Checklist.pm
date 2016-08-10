# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::KIXSidebar::Checklist;

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
    my $Content;

    # create needed objects
    my $StateObject  = $Kernel::OM->Get('Kernel::System::State');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    $Self->{Config}
        = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Frontend::KIXSidebarChecklist');

    # get checklist
    my $Checklist = $TicketObject->TicketChecklistGet(
        TicketID => $Param{TicketID},
        Result   => 'Position',
    );

    # get ticket data
    my %Ticket = $TicketObject->TicketGet(
        TicketID => $Param{TicketID},
    );

    my $EditAccess = 0;
    if (   !$Self->{Config}->{NonEditableTicketStateTypes}->{ $Ticket{StateType} }
        && !$Self->{Config}->{NonEditableTicketStates}->{ $Ticket{State} }
        && ( $Ticket{OwnerID} == $Self->{UserID} || $Ticket{ResponsibleID} == $Self->{UserID} ) )
    {
        $EditAccess = 1;
    }

    # create table content
    if ( ref( $Checklist->{Data} ) ne 'HASH' || !%{ $Checklist->{Data} } ) {

        # no task existing
        $LayoutObject->Block(
            Name => 'NoTasks',
            Data => {}
        );
    }
    else {

        # create task list
        my $Class = "";
        for my $Task ( sort { $a <=> $b } keys %{ $Checklist->{Data} } ) {

            $LayoutObject->Block(
                Name => 'Task',
                Data => {
                    StateIcon =>
                        $Self->{Config}->{ItemStateIcon}->{ $Checklist->{Data}->{$Task}->{State} },
                    StateStyle =>
                        $Self->{Config}->{ItemStateStyle}->{ $Checklist->{Data}->{$Task}->{State} },
                    ID      => $Checklist->{Data}->{$Task}->{ID},
                    Content => $Checklist->{Data}->{$Task}->{Task},
                    Class   => $Class
                },
            );
            if ( !$Class ) {
                $Class = "Even";
            }
            else {
                $Class = "";
            }
        }
    }

    my $TableContent = $LayoutObject->Output(
        TemplateFile => 'AgentKIXSidebarChecklistTable',
        Data         => {},
    );

    # create edit icon
    if ($EditAccess) {
        $LayoutObject->Block(
            Name => 'Edit',
            Data => {}
        );
    }

    my $JSONStates = $LayoutObject->JSONEncode( Data => $Self->{Config}->{ItemStateIcon} );
    my $JSONStateStyles
        = $LayoutObject->JSONEncode( Data => $Self->{Config}->{ItemStateStyle} );

    $Content = $LayoutObject->Output(
        TemplateFile => 'AgentKIXSidebarChecklist',
        Data         => {
            %{ $Self->{Config} },
            %Param,
            TaskString           => $Checklist->{String},
            TableContent         => $TableContent,
            AvailableStates      => $JSONStates,
            AvailableStateStyles => $JSONStateStyles,
            Access               => $EditAccess
        },
        KeepScriptTags => $Param{AJAX},
    );

    return $Content;
}

1;
