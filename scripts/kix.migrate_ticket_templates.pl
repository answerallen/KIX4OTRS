#!/usr/bin/perl -w
# --
# scripts/migrate_ticket_templates.pl - migrate existing ticket templates from config to database
# --
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
# --
# $Id$
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# --

use strict;
use warnings;

# use ../ as lib location
use File::Basename;
use FindBin qw($Bin);
use lib dirname($Bin);
use lib dirname($Bin) . "/Kernel/cpan-lib";

use Getopt::Std;
use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::DB;
use Kernel::System::Ticket;
use Kernel::System::Type;
use Kernel::System::Queue;
use Kernel::System::Priority;
use Kernel::System::SLA;
use Kernel::System::Service;
use Kernel::System::State;
use Kernel::System::CustomerUser;

my $Self = {};
$Self->{ConfigObject} = Kernel::Config->new();
$Self->{LogObject}    = Kernel::System::Log->new(
    LogPrefix => 'migrate_ticket_template',
    %{$Self},
);
$Self->{MainObject}         = Kernel::System::Main->new( %{$Self} );
$Self->{EncodeObject}       = Kernel::System::Encode->new( %{$Self} );
$Self->{TimeObject}         = Kernel::System::Time->new( %{$Self} );
$Self->{DBObject}           = Kernel::System::DB->new( %{$Self} );
$Self->{TicketObject}       = Kernel::System::Ticket->new( %{$Self} );
$Self->{TypeObject}         = Kernel::System::Type->new( %{$Self} );
$Self->{QueueObject}        = Kernel::System::Queue->new( %{$Self} );
$Self->{PriorityObject}     = Kernel::System::Priority->new( %{$Self} );
$Self->{SLAObject}          = Kernel::System::SLA->new( %{$Self} );
$Self->{ServiceObject}      = Kernel::System::Service->new( %{$Self} );
$Self->{StateObject}        = Kernel::System::State->new( %{$Self} );
$Self->{CustomerUserObject} = Kernel::System::CustomerUser->new( %{$Self} );

#--------------------------------------------------------------------#
# Run
#--------------------------------------------------------------------#

$Self->{TicketObject}->_MigrateTemplateData();

exit(0);
