# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::LinkObject::Person;

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

Kernel::Output::HTML::LinkObjectPerson - layout backend module

=head1 SYNOPSIS

All layout functions of link object (Person)

=over 4

=cut

=item new()

create an object

    $BackendObject = Kernel::Output::HTML::LinkObjectPerson->new(
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

    # We need our own LayoutObject instance to avoid blockdata collisions
    #   with the main page.
    $Self->{LayoutObject} = Kernel::Output::HTML::Layout->new( %{$Self} );

    # define needed variables
    $Self->{ObjectData} = {
        Object   => 'Person',
        Realname => 'Person',
    };

    return $Self;
}

=item TableCreateComplex()

return an array with the block data

Return

    %BlockData = (
        {
            Object    => 'Person',
            Blockname => 'Person',
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
                        Type      => 'Text',
                        Content   => 'persons lastname',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons firstname',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons email',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons type',
                        MaxLength => 50,
                    },
                ],
                [
                    {
                        Type      => 'Text',
                        Content   => 'persons 2 lastname',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons  2firstname',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons 2 email',
                        MaxLength => 50,
                    },
                    {
                        Type      => 'Text',
                        Content   => 'persons 2 type',
                        MaxLength => 50,
                    },
                ],
            ],
        },
    );

    @BlockData = $LinkObject->TableCreateComplex(
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

    # convert the list
    my %LinkList;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            for my $PersonID ( keys %{$DirectionList} ) {

                $LinkList{$PersonID}->{Data} = $DirectionList->{$PersonID};
                if ( !defined $LinkList{$PersonID}{Data}->{UserLastname} ) {
                    $LinkList{$PersonID}{Data}->{UserLastname} = "<i>"
                        . $Self->{LayoutObject}->{LanguageObject}->Translate('Person not found') . ": "
                        . $PersonID . "</i>";
                    $LinkList{$PersonID}{Data}->{UserFirstname} = "<i>"
                        . $Self->{LayoutObject}->{LanguageObject}->Translate('Person not found') . ": "
                        . $PersonID . "</i>";
                }
            }
        }
    }

    # get default config
    my $ComplexConfig = $Kernel::OM->Get('Kernel::Config')->Get('LinkedPerson::ModeComplex');
    my %ComplexConfigColumns = %{ $ComplexConfig->{Columns} };
    my %ComplexConfigHeaders = %{ $ComplexConfig->{ColumnHeaders} };
    my %ComplexConfigReverse = reverse %ComplexConfigColumns;

    # create the column list
    my @EnabledColumns = ();
    if ( defined $Param{EnabledColumns}->{Person} && scalar @{ $Param{EnabledColumns}->{Person} } )
    {
        # create config from enabled columns
        @EnabledColumns = @{ $Param{EnabledColumns}->{Person} };
    }
    else {
        # get default config and create array with column name
        for my $Key ( sort keys %ComplexConfigColumns ) {
            push @EnabledColumns, $ComplexConfigColumns{$Key};
        }
    }

    # create the headline list
    my @HeadLine = ();
    for my $Key ( @EnabledColumns ) {

        next if $Key eq 'LinkType';

        my $Header = $Key;
        if ( defined $ComplexConfigReverse{$Key} ) {
            $Header = $ComplexConfigHeaders{ $ComplexConfigReverse{$Key} };
        }
        push @HeadLine, {
            Content => $Header,
        };
    }

    # create the item list
    my @ItemList;

    for my $PersonID (
        sort { $LinkList{$a}{Data}->{UserLastname} cmp $LinkList{$b}{Data}->{UserLastname} }
        keys %LinkList
        )
    {

        # extract persons data
        my %Person = %{ $LinkList{$PersonID}{Data} };
        $Person{Type} = $Self->{LayoutObject}->{LanguageObject}->Translate($Person{Type});

        # set css
        my $Css = '';
        my @ItemColumns;

        for my $Key ( @EnabledColumns ) {

            next if $Key eq 'LinkType';

            if ( !$Person{$Key} ) {
                $Person{$Key} = '';
            }

            push @ItemColumns, {
                Type       => 'Text',
                Key        => $PersonID,
                Content    => $Person{$Key},
                ID         => $PersonID,
                Css        => $Css,
                ObjectType => 'Person',
            };
        }

        push @ItemList, \@ItemColumns;
    }

    return if !@ItemList;

    # define the block data
    my %Block = (
        Object    => $Self->{ObjectData}->{Object},
        Blockname => $Self->{ObjectData}->{Realname},
        Headline  => \@HeadLine,
        ItemList  => \@ItemList,
    );

    return ( \%Block );
}

=item TableCreateSimple()

return a hash with the link output data

Return

    %LinkOutputData = (
        Normal::Source => {
            Person => [
                {
                    Type    => 'Link',
                    Content => 'T:55555',
                    Title   => 'Person#555555: The person title',
                    Css     => 'style="text-decoration: line-through"',
                },
                {
                    Type    => 'Link',
                    Content => 'T:22222',
                    Title   => 'Person#22222: Title of person 22222',
                },
            ],
        },
        ParentChild::Target => {
            Person => [
                {
                    Type    => 'Link',
                    Content => 'T:77777',
                    Title   => 'Person#77777: person title',
                },
            ],
        },
    );

    %LinkOutputData = $LinkObject->TableCreateSimple(
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

    my %LinkOutputData;
    for my $LinkType ( sort keys %{ $Param{ObjectLinkListWithData} } ) {

        # extract link type List
        my $LinkTypeList = $Param{ObjectLinkListWithData}->{$LinkType};

        for my $Direction ( sort keys %{$LinkTypeList} ) {

            # extract direction list
            my $DirectionList = $Param{ObjectLinkListWithData}->{$LinkType}->{$Direction};

            my @ItemList;
            for my $PersonID ( sort { $a cmp $b } keys %{$DirectionList} ) {

                # extract persons data
                my $Person = $DirectionList->{$PersonID};
                my $Type = ( $Person->{Type} =~ /Agent/ ) ? 'Agent' : 'Customer';

                # define item data
                my %Item = (
                    Type    => 'Text',
                    Content => $Person->{UserFirstname} . " " . $Person->{UserLastname},

                    # Link       => $Self->{LayoutObject}->{Baselink} . 'Action=AdminCustomerUser&;Subaction=Change;ID=' . $Person->{UserLogin},,
                    LinkInfo   => $LinkType,
                    ID         => $PersonID,
                    LinkType   => $LinkType,
                    ObjectType => 'Person',
                );
                push @ItemList, \%Item;
            }

            # add item list to link output data
            $LinkOutputData{ $LinkType . '::' . $Direction }->{Person} = \@ItemList;
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

    if (
        ref( $Param{ContentData} ) eq "HASH"
        && $Param{ContentData}->{ObjectType}
        && $Param{ContentData}->{ObjectType} eq 'Person'
        )
    {
        my %CData = %{ $Param{ContentData} };
        my $Css   = '';
        if ( $CData{LinkInfo} && $CData{LinkInfo} eq "NoLink" ) {
            $Css = 'text-decoration: line-through';
        }

        if ( $CData{Link} ) {
            return "<a href='$CData{Link}' style='$Css'>$CData{Content}</a>";
        }
        else {
            return "<span style='$Css'>$CData{Content}</span>";
        }
    }

    return;
}

=item SelectableObjectList()

return an array hash with selectable objects

Return

    @SelectableObjectList = (
        {
            Key   => 'Person',
            Value => 'Person',
        },
    );

    @SelectableObjectList = $LinkObject->SelectableObjectList(
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
            Key       => 'PersonNumber',
            Name      => 'Person#',
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

    @SearchOptionList = $LinkObject->SearchOptionList(
        SubObject => 'Bla',  # (optional)
    );

=cut

sub SearchOptionList {
    my ( $Self, %Param ) = @_;

    # search option list
    my @SearchOptionList = (

        #{
        #    Key  => 'PersonSource',
        #    Name => 'Source',
        #    Type => 'List',
        #},
        #{
        #    Key  => 'PersonLogin',
        #    Name => 'Persons login',
        #    Type => 'Text',
        #},
        {
            Key        => 'PersonAttributes',
            Name       => 'Persons attributes',
            Type       => 'Text',
            Class      => 'Validate_Required Modernize',
            ClassLabel => 'Mandatory',
        },
        {
            Key        => 'PersonType',
            Name       => 'Person Type',
            Type       => 'List',
            Class      => 'Validate_Required Modernize',
            ClassLabel => 'Mandatory',
        },
        {
            Key        => 'Limit',
            Name       => 'Limit',
            Type       => 'List',
            Class      => 'Modernize',
            PossibleNone => 1,
        },
    );

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
                    Class => $Row->{Class} || '',
                },
            );

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->Output(
                TemplateFile => 'LinkObject',
            );

            next ROW;
        }

        # prepare list boxes
        elsif ( $Row->{Type} eq 'List' ) {

            # get form data
            my @FormData = $Kernel::OM->Get('Kernel::System::Web::Request')->GetArray( Param => $Row->{FormKey} );
            $Row->{FormData} = \@FormData;

            my %ListData;

            if ( $Row->{Key} eq 'PersonType' ) {

                # get limit options
                %ListData = (
                    Agent    => 'Agent',
                    Customer => 'Customer',
                );
            }
            elsif ( $Row->{Key} eq 'Limit' ) {

                # get limit options
                %ListData = (
                    10  => 10,
                    25  => 25,
                    50  => 50,
                    100 => 100,
                    150 => 150,
                    200 => 200,
                );
            }

            # add the input string
            $Row->{InputStrg} = $Self->{LayoutObject}->BuildSelection(
                Data       => \%ListData,
                Name       => $Row->{FormKey},
                SelectedID => $Row->{FormData},
                Size       => 3,
                Multiple   => $Row->{Multiple} || 0,
                Class      => $Row->{Class} || '',
                PossibleNone => $Row->{PossibleNone} || 0,
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
