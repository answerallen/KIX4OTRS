# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Output::HTML::OutputFilter::AgentTicketMergeLink;

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

    # get Template
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    # create HMTL
    my $SearchPattern
        = '&lt;\!\-\-\sKIX4OTRS\sMergeTargetLinkStart\s::(.*?)::(.*?)&gt;(.*?)&lt;(.*?)KIX4OTRS\sMergeTargetLinkEnd\s*(.*?)&gt;';
    if ( ${ $Param{Data} } =~ m{ $SearchPattern }ixms )
    {
        if ( $Self->{UserType} eq 'User' ) {
            ${ $Param{Data} }
                =~ s{ $SearchPattern }{ <a  href="index.pl?Action=AgentTicketZoom;TicketID=$1" target="new">$3</a> }ixms;
        }
        elsif ( $Self->{UserType} eq 'Customer' ) {
            ${ $Param{Data} }
                =~ s{ $SearchPattern }{ <a  href="customer.pl?Action=CustomerTicketZoom;TicketID=$1" target="new">$3</a> }ixms;
        }
    }

    # return
    return 1;
}
1;
