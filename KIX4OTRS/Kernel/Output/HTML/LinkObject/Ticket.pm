# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# KIX4OTRS-Extensions Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
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

package Kernel::Output::HTML::LinkObject::Ticket;

use strict;
use warnings;

use Kernel::Output::HTML::Layout;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Priority',
    'Kernel::System::State',
    'Kernel::System::Type',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::Output::HTML::LinkObject::Ticket - layout backend module

=head1 SYNOPSIS

All layout functions of link object (ticket).

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::LinkObject::Ticket->new(
        UserLanguage => 'en',
        UserID       => 1,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # check needed objects
    for my $Needed (qw(UserLanguage UserID)) {
        $Self->{$Needed} = $Param{$Needed} || die "Got no $Needed!";
    }

    # We need our own LayoutObject instance to avoid block data collisions
    #   with the main page.
    $Self->{LayoutObject} = Kernel::Output::HTML::Layout->new( %{$Self} );

    # define needed variables
    $Self->{ObjectData} = {
        Object   => 'Ticket',
        Realname => 'Ticket',
    };

    return $Self;
}

=item TableCreateComplex()

return an array with the block data

Return

    %BlockData = (
        {
            Object    => 'Ticket',
            Blockname => 'Ticket',
            Headline  => [
                {
                    Content => 'Number#',
                    Width   => 130,
                },
                {
                    Content => 'Title',
                },
                {
                    Content => 'Created',
                    Width   => 110,
                },
            ],
            ItemList => [
                [
                    {
                        Type     => 'Link',
                        Key      => $TicketID,
                        Content  => '123123123',
                        CssClass => 'StrikeThrough',
                    },
                    {
                        Type      => 'Text',
                        Content   => 'The title',
                        MaxLength => 50,
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2008-01-01 12:12:00',
                    },
                ],
                [
                    {
                        Type    => 'Link',
                        Key     => $TicketID,
                        Content => '434234',
                    },
                    {
                        Type      => 'Text',
                        Content   => 'The title of ticket 2',
                        MaxLength => 50,
                    },
                    {
                        Type    => 'TimeLong',
                        Content => '2008-01-01 12:12:00',
                    },
                ],
            ],
        },
    );

    @BlockData = $BackendObject->TableCreateComplex(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateComplex {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!',
        );
        return;
    }

    # KIX4OTRS-capeIT
    # get user object
    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    # get user preferences
    my %UserPreferences = $UserObject->GetPreferences( UserID => $Self->{UserID} );
    # EO KIX4OTRS-capeIT

    # convert the list
    my %LinkList;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            for my $TicketID ( sort keys %{$DirectionList} ) {

                # KIX4OTRS-capeIT
                # skip showing links to merged tickets
                next
                    if (
                    (
                           !defined $UserPreferences{UserShowMergedTicketsInLinkedObjects}
                        || !$UserPreferences{UserShowMergedTicketsInLinkedObjects}
                    )
                    && $Direction eq 'Target'
                    && $DirectionList->{$TicketID}->{State} eq 'merged'
                    );

                # EO KIX4OTRS-capeIT
                $LinkList{$TicketID}->{Data} = $DirectionList->{$TicketID};
            }
        }
    }

    # create the item list
    my @ItemList;

    # KIX4OTRS-capeIT
    # default enabled queues
    my @ColumnsEnabled = ( "TicketNumber", "Title", "Type", "Queue", "State", "Created" );

    if ( defined $Param{EnabledColumns}->{Ticket} && scalar @{ $Param{EnabledColumns}->{Ticket} } )
    {
        @ColumnsEnabled = ();
        for my $Column ( @{ $Param{EnabledColumns}->{Ticket} } ) {
            next if $Column eq 'LinkType';
            push @ColumnsEnabled, $Column;
        }
    }

    # EO KIX4OTRS-capeIT

    for my $TicketID (
        sort { $LinkList{$a}{Data}->{Age} <=> $LinkList{$b}{Data}->{Age} }
        keys %LinkList
        )
    {

        # extract ticket data
        my $Ticket = $LinkList{$TicketID}{Data};

        # set css
        # KIX4OTRS-capeIT
        # my $CssClass;
        my $CssStyle = '';

        # if ( $Ticket->{StateType} eq 'merged' ) {
        #     $CssClass = 'StrikeThrough';
        # }
        #
        # my @ItemColumns = (
        #     {
        #         Type     => 'Link',
        #         Key      => $TicketID,
        #         Content  => $Ticket->{TicketNumber},
        #         Link     => $LayoutObject->{Baselink}
        #            . 'Action=AgentTicketZoom;TicketID='
        #            . $TicketID,CssClass => $CssClass,
        #     },
        #     {
        #         Type      => 'Text',
        #         Content   => $Ticket->{Title},
        #         MaxLength => 50,
        #     },
        #     {
        #         Type    => 'Text',
        #         Content => $Ticket->{Queue},
        #     },
        #     {
        #         Type      => 'Text',
        #         Content   => $Ticket->{State},
        #         Translate => 1,
        #     },
        #     {
        #         Type    => 'TimeLong',
        #         Content => $Ticket->{Created},
        #     },
        # );

        my $StateHighlighting
            = $Kernel::OM->Get('Kernel::Config')->Get('KIX4OTRSTicketOverviewSmallHighlightMapping');

        if (
            $StateHighlighting
            && ref($StateHighlighting) eq 'HASH'
            && $StateHighlighting->{ $Ticket->{State} }
            )
        {

            # if ( $Ticket->{StateType} eq 'merged' ) {
            if ( $Ticket->{StateType} eq 'closed' || $Ticket->{StateType} eq 'merged' ) {
                $CssStyle = ' style="text-decoration: line-through; '
                    . $StateHighlighting->{ $Ticket->{State} } . '"';
            }
            else {
                $CssStyle = ' style="' . $StateHighlighting->{ $Ticket->{State} } . '"';
            }
        }

        my @ItemColumns;

        for my $Column (@ColumnsEnabled) {

            my %TmpHash;
            $TmpHash{Content}  = $Ticket->{$Column};
            $TmpHash{Key}      = $TicketID;
            $TmpHash{CssStyle} = $CssStyle;
            $TmpHash{Type}     = 'Text';

            if ( $TmpHash{Content} ) {

                if ( $Column eq 'Age' || $Column eq 'EscalationTime' ) {
                    $TmpHash{Content} = $LayoutObject->CustomerAge(
                        Age   => $Ticket->{Age},
                        Space => ' ',
                    );
                }
                elsif ( $Column eq 'EscalationSolutionTime' ) {
                    $TmpHash{Content} = $LayoutObject->CustomerAgeInHours(
                        Age => $Ticket->{SolutionTime} || 0,
                        Space => ' ',
                    );
                }
                elsif ( $Column eq 'EscalationResponseTime' ) {
                    $TmpHash{Content} = $LayoutObject->CustomerAgeInHours(
                        Age => $Ticket->{FirstResponseTime} || 0,
                        Space => ' ',
                    );
                }
                elsif ( $Column eq 'EscalationUpdateTime' ) {
                    $TmpHash{Content} = $LayoutObject->CustomerAgeInHours(
                        Age => $Ticket->{UpdateTime} || 0,
                        Space => ' ',
                    );
                }
                elsif ( $Column eq 'PendingTime' ) {

                    my %UserPreferences
                        = $UserObject->GetPreferences( UserID => $Self->{UserID} );
                    my $DisplayPendingTime = $UserPreferences{UserDisplayPendingTime} || '';

                    if ( $DisplayPendingTime && $DisplayPendingTime eq 'RemainingTime' ) {

                        $TmpHash{Content} = $LayoutObject->CustomerAge(
                            Age   => $Ticket->{'UntilTime'},
                            Space => ' ',
                        );
                    }
                    elsif ( defined $Ticket->{UntilTime} && $Ticket->{UntilTime} ) {
                        $TmpHash{Content} = $TimeObject->SystemTime2TimeStamp(
                            SystemTime => $Ticket->{RealTillTimeNotUsed},
                        );
                        $TmpHash{Content} = $LayoutObject->{LanguageObject}
                            ->FormatTimeString( $TmpHash{Content}, 'DateFormat' );
                    }
                    else {
                        $TmpHash{Content} = '';
                    }
                }

                # type
                if ( $Column eq 'TicketNumber' ) {
                    $TmpHash{Type} = 'Link';
                    $TmpHash{Link} = $LayoutObject->{Baselink}
                    . 'Action=AgentTicketZoom;TicketID='
                    . $TicketID;
                }
                elsif ( $Column =~ /(Created|Changed|Time)/ ) {
                    $TmpHash{Type} = 'TimeLong';
                }

                if ( $Column eq 'Title' ) {
                    $TmpHash{MaxLength} = 50;
                }

                if ( $Column eq 'State' ) {
                    $TmpHash{Translate} = 1;
                }
            }
            push( @ItemColumns, \%TmpHash );
        }

        # EO KIX4OTRS-capeIT

        push @ItemList, \@ItemColumns;
    }

    return if !@ItemList;

    # define the block data
    my $TicketHook = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook');

    # KIX4OTRS-capeIT
    my @Headlines;

    my %TranslationHash = (
        'EscalationResponseTime' => 'First Response Time',
        'EscalationSolutionTime' => 'Solution Time',
        'EscalationUpdateTime'   => 'Update Time',
        'PendingTime'            => 'Pending Time',
    );

    for my $Column (@ColumnsEnabled) {
        my %TmpHash;
        my $Content;
        if ( $Column eq 'TicketNumber' ) {
            $Content = $TicketHook;
        }
        else {
            $Content = $TranslationHash{$Column} || $Column;
        }

        $TmpHash{Content} = $Content;
        $TmpHash{Width}   = 130;

        push( @Headlines, \%TmpHash );
    }

    # EO KIX4OTRS-capeIT

    my %Block      = (
        Object    => $Self->{ObjectData}->{Object},
        Blockname => $Self->{ObjectData}->{Realname},

        # KIX4OTRS-capeIT
        # Headline  => [
        #     {
        #         Content => $TicketHook,
        #         Width   => 130,
        #     },
        #     {
        #         Content => 'Title',
        #     },
        #     {
        #         Content => 'Queue',
        #         Width   => 100,
        #     },
        #     {
        #         Content => 'State',
        #         Width   => 110,
        #     },
        #     {
        #         Content => 'Created',
        #         Width   => 130,
        #     },
        # ],
        Headline => \@Headlines,

        # EO KIX4OTRS-capeIT
        ItemList => \@ItemList,
    );

    return ( \%Block );
}

=item TableCreateSimple()

return a hash with the link output data

Return

    %LinkOutputData = (
        Normal::Source => {
            Ticket => [
                {
                    Type     => 'Link',
                    Content  => 'T:55555',
                    Title    => 'Ticket#555555: The ticket title',
                    CssClass => 'StrikeThrough',
                },
                {
                    Type    => 'Link',
                    Content => 'T:22222',
                    Title   => 'Ticket#22222: Title of ticket 22222',
                },
            ],
        },
        ParentChild::Target => {
            Ticket => [
                {
                    Type    => 'Link',
                    Content => 'T:77777',
                    Title   => 'Ticket#77777: Ticket title',
                },
            ],
        },
    );

    %LinkOutputData = $BackendObject->TableCreateSimple(
        ObjectLinkListWithData => $ObjectLinkListRef,
    );

=cut

sub TableCreateSimple {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ObjectLinkListWithData} || ref $Param{ObjectLinkListWithData} ne 'HASH' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ObjectLinkListWithData!'
        );
        return;
    }

    my $TicketHook = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook');
    my %LinkOutputData;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            my @ItemList;
            for my $TicketID ( sort { $a <=> $b } keys %{$DirectionList} ) {

                # extract ticket data
                my $Ticket = $DirectionList->{$TicketID};

                # set css
                my $CssClass;

                # KIX4OTRS-capeIT
                # if ( $Ticket->{StateType} eq 'merged' ) {
                if ( $Ticket->{StateType} eq 'closed' || $Ticket->{StateType} eq 'merged' ) {

                    # EO KIX4OTRS-capeIT

                    $CssClass = 'StrikeThrough';
                }

                # KIX4OTRS-capeIT
                $Ticket->{TitleFull} = $Ticket->{Title};
                if ( length( $Ticket->{Title} ) > 20 ) {
                    $Ticket->{Title} = substr( $Ticket->{Title}, 0, 15 ) . '[...]';
                }

                # EO KIX4OTRS-capeIT

                # define item data
                my %Item = (
                    Type    => 'Link',

                    # KIX4OTRS-capeIT
                    # Content => 'T:' . $Ticket->{TicketNumber},
                    Content => 'T:' . $Ticket->{TicketNumber} . ' - ' . $Ticket->{Title},

                    # EO KIX4OTRS-capeIT

                    Title    => "$TicketHook$Ticket->{TicketNumber}: $Ticket->{Title}",
                    Link    => $Self->{LayoutObject}->{Baselink}
                        . 'Action=AgentTicketZoom;TicketID='
                        . $TicketID,
                    CssClass => $CssClass,

                    # KIX4OTRS-capeIT
                    ID              => $TicketID,
                    LinkType        => $LinkType,
                    ObjectType      => 'Ticket',
                    TicketStateType => $Ticket->{StateType},

                    # EO KIX4OTRS-capeIT
                );

                push @ItemList, \%Item;
            }

            # add item list to link output data
            $LinkOutputData{ $LinkType . '::' . $Direction }->{Ticket} = \@ItemList;
        }
    }

    return %LinkOutputData;
}

=item ContentStringCreate()

return a output string

    my $String = $LayoutObject->ContentStringCreate(
        ContentData => $HashRef,
    );

=cut

sub ContentStringCreate {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !$Param{ContentData} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Need ContentData!'
        );
        return;
    }

    return;
}

=item SelectableObjectList()

return an array hash with selectable objects

Return

    @SelectableObjectList = (
        {
            Key   => 'Ticket',
            Value => 'Ticket',
        },
    );

    @SelectableObjectList = $BackendObject->SelectableObjectList(
        Selected => $Identifier,  # (optional)
    );

=cut

sub SelectableObjectList {
    my ( $Self, %Param ) = @_;

    my $Selected;
    if ( $Param{Selected} && $Param{Selected} eq $Self->{ObjectData}->{Object} ) {
        $Selected = 1;
    }

    # object select list
    my @ObjectSelectList = (
        {
            Key      => $Self->{ObjectData}->{Object},
            Value    => $Self->{ObjectData}->{Realname},
            Selected => $Selected,
        },
    );

    return @ObjectSelectList;
}

=item SearchOptionList()

return an array hash with search options

Return

    @SearchOptionList = (
        {
            Key       => 'TicketNumber',
            Name      => 'Ticket#',
            InputStrg => $FormString,
            FormData  => '1234',
        },
        {
            Key       => 'Title',
            Name      => 'Title',
            InputStrg => $FormString,
            FormData  => 'BlaBla',
        },
    );

    @SearchOptionList = $BackendObject->SearchOptionList(
        SubObject => 'Bla',  # (optional)
    );

=cut

sub SearchOptionList {
    my ( $Self, %Param ) = @_;

    my $ParamHook = $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Hook') || 'Ticket#';

    # search option list
    my @SearchOptionList = (
        {
            Key  => 'TicketNumber',
            Name => $ParamHook,
            Type => 'Text',
        },
        {
            Key  => 'Title',
            Name => 'Title',
            Type => 'Text',
        },
        {
            Key  => 'TicketFulltext',
            Name => 'Fulltext',
            Type => 'Text',
        },

        # KIX4OTRS-capeIT
        # {
        #     Key  => 'StateIDs',
        #     Name => 'State',
        #     Type => 'List',
        # },
        # EO KIX4OTRS-capeIT
        {
            Key  => 'PriorityIDs',
            Name => 'Priority',
            Type => 'List',
        },
    );

    # KIX4OTRS-capeIT
    # set further search criteria according to configuration
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $SearchOptionsRef = $ConfigObject->Get('Ticket::Link::SearchOptions::Order');
    my $SearchNamesRef   = $ConfigObject->Get('Ticket::Link::SearchOptions::Name');
    my $SearchMethodsRef = $ConfigObject->Get('Ticket::Link::SearchOptions::CallMethod');
    if (
        $SearchOptionsRef && ref($SearchOptionsRef) eq 'ARRAY' &&
        $SearchNamesRef   && ref($SearchNamesRef)   eq 'HASH' &&
        $SearchMethodsRef && ref($SearchMethodsRef) eq 'HASH'
        )
    {
        for my $Key ( @{$SearchOptionsRef} ) {
            push(
                @SearchOptionList,
                {
                    Key     => $Key,
                    Name    => $SearchNamesRef->{$Key} || $Key,
                    Methods => $SearchMethodsRef->{$Key},
                    Type    => 'List',
                },
            );
        }
    }

    # EO KIX4OTRS-capeIT

    if ( $Kernel::OM->Get('Kernel::Config')->Get('Ticket::Type') ) {
        push @SearchOptionList,
            {
            Key  => 'TypeIDs',
            Name => 'Type',
            Type => 'List',
            };
    }

    # add formkey
    for my $Row (@SearchOptionList) {
        $Row->{FormKey} = 'SEARCH::' . $Row->{Key};
    }

    # add form data and input string
    ROW:
    for my $Row (@SearchOptionList) {

        # prepare text input fields
        if ( $Row->{Type} eq 'Text' ) {

            # get form data
            $Row->{FormData} = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => $Row->{FormKey} );

            # parse the input text block
            $Self->{LayoutObject}->Block(
                Name => 'InputText',
                Data => {
                    Key   => $Row->{FormKey},
                    Value => $Row->{FormData} || '',
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }

        # prepare list boxes
        if ( $Row->{Type} eq 'List' ) {

            # get form data
            my @FormData = $Kernel::OM->Get('Kernel::System::Web::Request')->GetArray( Param => $Row->{FormKey} );
            $Row->{FormData} = \@FormData;

            my %ListData;

            # KIX4OTRS-capeIT
            # get data according to current CallMethod
            #if ( $Row->{Key} eq 'StateIDs' ) {
            #
            #    # get state list
            #    %ListData = $Kernel::OM->Get('Kernel::System::State')->StateList(
            #        UserID => $Self->{UserID},
            #    );
            #}
            if ( $Row->{Methods} && $Row->{Methods} =~ /(\w+)Object::(\w+)/ ) {
                my $Object;
                my $ObjectType = $1;
                my $Method = $2;
                eval {
                    $Object =  $Kernel::OM->Get('Kernel::System::'.$ObjectType);
                    %ListData = $Object->$Method(
                        UserID => $Self->{UserID},
                    );
                };
                if ($@) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'error',
                        Message  => "LinkObjectTicket - "
                            . " invalid CallMethod ($Object->$Method) configured "
                            . "(" . $@ . ")!",
                    );
                }
            }

            # EO KIX4OTRS-capeIT
            elsif ( $Row->{Key} eq 'PriorityIDs' ) {
                %ListData = $Kernel::OM->Get('Kernel::System::Priority')->PriorityList(
                    UserID => $Self->{UserID},
                );
            }
            elsif ( $Row->{Key} eq 'TypeIDs' ) {
                %ListData = $Kernel::OM->Get('Kernel::System::Type')->TypeList(
                    UserID => $Self->{UserID},
                );
            }

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->BuildSelection(
                Data       => \%ListData,
                Name       => $Row->{FormKey},
                SelectedID => $Row->{FormData},
                Size       => 3,
                Multiple   => 1,
                Class      => 'Modernize',
            );

            next ROW;
        }
    }

    return @SearchOptionList;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
