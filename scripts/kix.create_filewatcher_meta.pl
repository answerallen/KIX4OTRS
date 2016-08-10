#!/usr/bin/perl -w
# --
# scripts/kix.create_filewatcher_meta.pl - create meta data for FileWatcher
#
# written/edited by:
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
#
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
use Getopt::Std;
use File::Find;
use Digest::MD5;

sub _CalcMD5 {
    my %Param = @_;

    open( my $FH, "<", $Param{Filename} );

    my $ctx = Digest::MD5->new;
    $ctx->addfile(*$FH);
    my $HexDigest = $ctx->hexdigest;

    close $FH;

    return $HexDigest;
}

sub _FindSub {
    if ( -f $_ ) {
        my $File       = $File::Find::name;
        my $FileMod    = ( stat($File) )[9];
        my $FileSize   = ( stat($File) )[7];
        my $FileFinger = _CalcMD5( Filename => $File );

        print STDOUT "{$FileFinger}::{$File}::{$FileSize}::{$FileMod}\n";
    }

    return;
}

File::Find::find( \&_FindSub, @ARGV );

exit(0);
