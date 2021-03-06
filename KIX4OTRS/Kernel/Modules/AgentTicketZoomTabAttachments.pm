# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketZoomTabAttachments;

use strict;
use warnings;

our $ObjectManagerDisabled = 1;

use URI::Escape;
use File::Temp qw( tempfile tempdir );
use IO::Compress::Zip qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # create needed objects
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');
    $Self->{CallingAction}    = $ParamObject->GetParam( Param => 'CallingAction' )    || '';
    $Self->{DirectLinkAnchor} = $ParamObject->GetParam( Param => 'DirectLinkAnchor' ) || '';

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');
    my $DBObject      = $Kernel::OM->Get('Kernel::System::DB');
    my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');
    my $MainObject    = $Kernel::OM->Get('Kernel::System::Main');
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ParamObject   = $Kernel::OM->Get('Kernel::System::Web::Request');

    my %GetParam = ();
    my %Error    = ();
    my $Output;
    my $AttachmentCount = 0;

    # get some params...
    for (qw(TicketID AclAction)) {
        $GetParam{$_} = $ParamObject->GetParam( Param => $_ );
    }

    if ( !$Param{TicketID} && $Self->{TicketID} ) {
        $Param{TicketID} = $Self->{TicketID};
    }

    # check required params...
    if ( !$GetParam{TicketID} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'AgentTicketZoomTabAttachment - No TicketID given.'
        );
    }

    # get article attachment modules
    my $ArtAttachModuleRef = $ConfigObject->Get(
        'Ticket::Frontend::ArticleAttachmentModule'
    );

    # create block around entire tab content to prevent IE loading error
    $LayoutObject->Block(
        Name => 'TabContent',
        Data => {},
    );

    # get article list
    my @ArticleList = $TicketObject->ArticleContentIndex(
        TicketID                   => $GetParam{TicketID},
        StripPlainBodyAsAttachment => 1,
        UserID                     => $Self->{UserID},
    );

    # check if the browser sends the session id cookie
    # if not, add the session id to the url
    my $Session = '';
    if ( $Self->{SessionID} && !$Self->{SessionIDCookie} ) {
        $Session = ';' . $Self->{SessionName} . '=' . $Self->{SessionID};
    }

    # get all attachments
    my $ArticleIdx = 0;
    foreach my $Article (@ArticleList) {
        $ArticleIdx++;
        my %AtmIndex = %{ $Article->{Atms} };

        foreach my $FileID ( sort keys %AtmIndex ) {
            my %File = %{ $AtmIndex{$FileID} };

            if ( !$AttachmentCount ) {

                # create outer block
                $LayoutObject->Block(
                    Name => 'AttachmentList',
                );
            }
            $AttachmentCount++;

            # get article attachment modules
            if ( ref($ArtAttachModuleRef) eq 'HASH' ) {
                my %Jobs = %{$ArtAttachModuleRef};
                for my $Job ( sort keys %Jobs ) {
                    if ( $MainObject->Require( $Jobs{$Job}->{Module} ) ) {
                        my $Object = $Jobs{$Job}->{Module}->new(
                            %{$Self},
                            TicketID  => $Self->{TicketID},
                            ArticleID => $Article->{ArticleID},
                        );
                        my %Data = $Object->Run(
                            File => { %File, FileID => $FileID, },
                            Article => $Article,
                        );
                        if (%Data) {
                            $LayoutObject->Block(
                                Name => 'Attachment',
                                Data => {
                                    %Data,
                                    %{$Article},
                                    ArticleIdx => $ArticleIdx,
                                    Session    => $Session,
                                },
                            );
                        }
                    }
                    else {
                        $LogObject->Log(
                            Priority => 'error',
                            Message  => "AgentTicketZoomTabAttachment - could not load "
                                . " <$Jobs{$Job}->{Module}>!",
                        );
                    }
                }
            }
        }
    }

    # nothing to show
    if ( !$AttachmentCount ) {
        $Param{NothingAvailableMsg}
            = $LayoutObject->{LanguageObject}->Translate('No attachments available');
        $LayoutObject->Block(
            Name => 'AttachmentMsg',
            Data => {
                %Param
                }
        );
    }

    # delete all selected attachments
    if ( $Self->{Subaction} eq 'Delete' || $Self->{Subaction} eq 'Download' ) {

        my @AttachmentIDs = $ParamObject->GetArray( Param => 'AttachmentID' );
        my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );
        my @ArticleIdxs = $ParamObject->GetArray( Param => 'ArticleIdx' );
        my $Access = 0;

        my %Ticket = $TicketObject->TicketGet( TicketID => $TicketID );

        # check responsible permissions
        if ( $Ticket{Responsible} || $Ticket{ResponsibleID} ) {
            my $Access = $TicketObject->TicketPermission(
                Type     => 'responsible',
                TicketID => $TicketID,
                UserID   => $Self->{UserID},
            );
            if ( !$Access ) {
                return {
                    ErrorCode => 'TicketAttachmentDelete.AccessDenied',
                    ErrorMessage =>
                        "TicketAttachmentDelete: Does not have permissions to update responsibe!",
                };
            }
        }

        # if any attachment selected
        if ( ref \@AttachmentIDs eq 'ARRAY' && scalar @AttachmentIDs ) {

            if ( $Self->{Subaction} eq 'Delete' ) {
                $Self->_ArticleDeleteChangedAttachment(
                    AttachmentIDs => \@AttachmentIDs,
                );
            }
            else {
                return $Self->_ArticleDownloadAttachments(
                    AttachmentIDs => \@AttachmentIDs,
                    TicketNumber  => $Ticket{TicketNumber},
                    ArticleIdxs   => \@ArticleIdxs,
                );
            }

        }

        # reload tab
        my $URL = "Action=AgentTicketZoom;TicketID=$Self->{TicketID};SelectedTab=1";
        if ( $Self->{Config}->{RedirectURL} ) {
            $URL =
                $Self->{Config}->{RedirectURL} . ";TicketID=$Self->{TicketID};SelectedTab=1";
        }

        return $LayoutObject->Redirect( OP => $URL );

    }

    # store last screen...
    if ( $Self->{CallingAction} ) {

        $Self->{RequestedURL} =~ s/DirectLinkAnchor=.+?(;|$)//;
        $Self->{RequestedURL} =~ s/CallingAction=.+?(;|$)//;
        $Self->{RequestedURL} =~ s/(^|;|&)Action=.+?(;|$)//;
        $Self->{RequestedURL} =
            "Action="
            . $Self->{CallingAction} . ";"
            . $Self->{RequestedURL} . "#"
            . $Self->{DirectLinkAnchor};

        $SessionObject->UpdateSessionID(
            SessionID => $Self->{SessionID},
            Key       => 'LastScreenView',
            Value     => $Self->{RequestedURL},
        );
    }

    $Output = $LayoutObject->Output(
        TemplateFile => 'AgentTicketZoomTabAttachments',
        Data         => {%Param},
    );

    $Output .= $LayoutObject->Footer( Type => 'TicketZoomTab' );

    return $Output;
}

sub _ArticleDeleteChangedAttachment {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $DBObject     = $Kernel::OM->Get('Kernel::System::DB');
    my $MainObject   = $Kernel::OM->Get('Kernel::System::Main');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    for my $AttachmentID ( @{ $Param{AttachmentIDs} } ) {
        my ( $ArticleID, $Filename ) = split( /::/, $AttachmentID );

        # replace HTML quotations
        $Filename = uri_unescape($Filename);

        # delete attachments
        return if !$DBObject->Do(
            SQL => 'DELETE FROM article_attachment WHERE article_id = ? AND filename = ?',
            Bind => [ \$ArticleID, \$Filename ],
        );

        # ArticleDataDir
        $Self->{ArticleDataDir} = $ConfigObject->Get('ArticleDir')
            || die 'Got no ArticleDir!';

        # delete from fs
        my $ContentPath =
            $TicketObject->ArticleGetContentPath( ArticleID => $ArticleID );

        my $Path = "$Self->{ArticleDataDir}/$ContentPath/$ArticleID";
        if ( -e $Path ) {
            my @List = $MainObject->DirectoryRead(
                Directory => $Path,
                Filter    => "*",
            );
            for my $File (@List) {
                next if ( $File =~ /(\/|\\)plain.txt$/ );
                next if ( $File !~ /(\/|\\)$Filename$/ );

                if ( !unlink $File ) {
                    $LogObject->Log(
                        Priority => 'error',
                        Message  => "Can't remove: $File: $!!",
                    );
                }
                if ( !unlink $File.'.content_type' ) {
                    $LogObject->Log(
                        Priority => 'error',
                        Message  => "Can't remove: $File.content_type: $!!",
                    );
                }
                if ( !unlink $File.'.disposition' ) {
                    $LogObject->Log(
                        Priority => 'error',
                        Message  => "Can't remove: $File.disposition: $!!",
                    );
                }
            }
        }
    }
    return 1;
}

sub _ArticleDownloadAttachments {
    my ( $Self, %Param ) = @_;

    # get needed objects
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    my @Articles;
    my @Attachments;
    my $Idx        = 0;
    my $ArticleIdx = $Param{ArticleIdxs};

    # create zip object
    my $ZipResult;
    my $ZipFilename = "Ticket_" . $Param{TicketNumber} . ".zip";
    my $ZipObject   = new IO::Compress::Zip \$ZipResult,
        BinModeIn => 1;

    if ( !$ZipObject ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "Unable to create Zip object.",
        );
        return;
    }

    for my $AttachmentID ( @{ $Param{AttachmentIDs} } ) {
        my ( $ArticleID, $Filename ) = split( /::/, $AttachmentID );

        # get all attachments from article
        my %ArticleAttachments = $TicketObject->ArticleAttachmentIndex(
            ArticleID => $ArticleID,
            UserID    => 1,
        );
        if ( !%ArticleAttachments ) {
            $LogObject->Log(
                Message  => "No such attacment ($Self->{FileID})! May be an attack!!!",
                Priority => 'error',
            );
            return $LayoutObject->ErrorScreen();
        }

        #search attachments
        for my $AttachmentNr ( keys %ArticleAttachments ) {
            my %Attachment = $TicketObject->ArticleAttachment(
                ArticleID => $ArticleID,
                FileID    => $AttachmentNr,
                UserID    => $Self->{UserID},
            );

            next if ( $Attachment{Filename} eq 'file-2' );

            foreach my $IDNum ( @{ $Param{ArticleIdxs} } ) {
                my @Array = split( /::/, $IDNum );
                if ( $Array[0] == $ArticleID ) {
                    $Idx = $Array[1];
                }
            }

            if ( $Attachment{Filename} eq $Filename ) {
                $ZipObject->newStream( Name => $Attachment{Filename} );
                $ZipObject->print( $Attachment{Content} );
                $ZipObject->flush();
            }
        }
    }
    $ZipObject->close();

    # output all attachmentfiles
    return $LayoutObject->Attachment(
        Filename    => $ZipFilename,
        ContentType => 'application/unknown',
        Content     => $ZipResult,
        Type        => 'attachment',

    );
}

1;
