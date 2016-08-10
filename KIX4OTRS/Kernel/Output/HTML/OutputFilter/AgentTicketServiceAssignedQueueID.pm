# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
#
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilter::AgentTicketServiceAssignedQueueID;

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

    # check data
    return if !$Param{Data};
    return if ref $Param{Data} ne 'SCALAR';
    return if !${ $Param{Data} };

    # create search pattern if change event already defined for ServiceID
    my $SearchPattern
        = '(FormUpdate\(.*?\'AJAXUpdate\'\,\s\'ServiceID\'.*?\])(\)\;)';
    my $ReplacementString = ',function(){ Core.KIX4OTRS.ServiceAssignedQueue(); }';
    if ( ${ $Param{Data} } =~ m{ $SearchPattern }ixms )
    {
        # do replace
        ${ $Param{Data} }
            =~ s{ $SearchPattern }{ $1$ReplacementString$2 }ixms;
    }
    else {
        # create another replacement string
        $ReplacementString = '[% WRAPPER JSOnDocumentComplete %]'
            . '<script type="text/javascript">//<![CDATA['
            . '    $(\'#ServiceID\').bind(\'change\', function (Event) {'
            . '        Core.KIX4OTRS.ServiceAssignedQueue();'
            . '    });'
            . '//]]></script>'
            . '[% END %]';

        # append replace string
        ${ $Param{Data} } .= $ReplacementString;
    }

    return 1;
}

1;
