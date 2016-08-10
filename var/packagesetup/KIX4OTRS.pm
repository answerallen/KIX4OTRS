# --
# KIX4OTRS.pm - code run during package de-/installation
# Copyright (C) 2006-2016 c.a.p.e. IT GmbH, http://www.cape-it.de
#
# written/edited by:
# * Torsten(dot)Thau(at)cape(dash)it(dot)de
# * Martin(dot)Balzarek(at)cape(dash)it(dot)de
# * Stefan(dot)Mehlig(at)cape(dash)it(dot)de
# * Rene(dot)Boehm(at)cape(dash)it(dot)de
# * Dorothea(dot)Doerffel(at)cape(dash)it(dot)de
# * Ralf(dot)Boehm(at)cape(dash)it(dot)de
# --
# $Id$
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package var::packagesetup::KIX4OTRS;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::DB',
    'Kernel::System::DynamicField',
    'Kernel::System::Group',
    'Kernel::System::KIXUtils',
    'Kernel::System::Log',
    'Kernel::System::Package',
    'Kernel::System::Priority',
    'Kernel::System::State',
    'Kernel::System::SysConfig',
    'Kernel::System::Valid',
    'Kernel::System::User'
);

use Kernel::System::VariableCheck qw(:all);
use File::Path qw(mkpath);

=head1 NAME

KIX4OTRS.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject = $Kernel::OM->Get('var::packagesetup::KIX4OTRS');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # always discard the config object before package code is executed,
    # to make sure that the config object will be created newly, so that it
    # will use the recently written new config from the package
    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    # create needed sysconfig object...
    $Kernel::OM->Get('Kernel::System::SysConfig')->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            if ( !-f $File ) {
                next PREFIX
            }
            do $File;
            last PREFIX;
        }
    }
    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    # SwitchButton
    my $GroupIDs = $Self->_GroupAdd(
        Name        => 'SwitchButton',
        Description => 'created by SwitchButton installer',
    );

    # register this module as custom module...
    $Self->_RegisterCustomModule();

    # created custom ticket states...
    $Self->_CreateTicketStates();

    # run integrated migration from CiCS(-ITSM)...
    $Self->_MigrateFromCiCS();

    # update DocumentIDs in link_relation...
    $Self->_FixDocumentIDs();

    # created dynamicfields ...
    $Self->_DynamicFieldCreate();

    # create KIX4OTRS Skin folder
    $Self->_CreateSkinFolder();

    # create tab Acl actions for admin module
    $Self->_SetTabAclActions();

    # create linked person notification
    $Self->_CreateLinkedPersonNotification();

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    # SwitchButton
    my $GroupIDs = $Self->_GroupAdd(
        Name        => 'SwitchButton',
        Description => 'created by SwitchButton installer',
    );

    # register this module as custom module...
    $Self->_RegisterCustomModule();

    # created custom ticket states...
    $Self->_CreateTicketStates();

    # run integrated migration from CiCS(-ITSM)...
    $Self->_MigrateFromCiCS();

    # update DocumentIDs in link_relation...
    $Self->_FixDocumentIDs();

    # created dynamicfields ...
    $Self->_DynamicFieldCreate();

    # create KIX4OTRS Skin folder
    $Self->_CreateSkinFolder();

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    # register this module as custom module...
    $Self->_RegisterCustomModule();

    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIXDashboardExtensions',
    );

    # update DocumentIDs in link_relation...
    $Self->_FixDocumentIDs();

    # created dynamicfields ...
    $Self->_DynamicFieldCreate();

    # migrate old dashboard column settings
    $Self->_MigrateDashboardColumnSettings();

    # create KIX4OTRS Skin folder
    $Self->_CreateSkinFolder();

    # create tab Acl actions for admin module
    $Self->_SetTabAclActions();

    # create linked person notification
    $Self->_CreateLinkedPersonNotification();

    if (
        $Kernel::OM->Get('Kernel::System::Package')
        ->PackageIsInstalled( Name => 'ITSMConfigurationManagement' )
        )
    {

        # copy graph table data and drop old graph table
        $Self->_CopyGraphTableData();
    }

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    # disabled custom ticket states...
    $Self->_DeactivateTicketStates();

    # unregister this module as custom module...
    $Self->_RemoveCustomModule();
    return 1;

}

# Internal functions
sub _RegisterCustomModule {
    my ( $Self, %Param ) = @_;

    # setup multiple cutsom module folders...
    # register KIX4OTRS...
    $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
        PackageName => 'KIX4OTRS',
        Priority    => '0100',
    );

    # check for ITSMCore and register extensions...
    if ( $Kernel::OM->Get('Kernel::System::Package')->PackageIsInstalled( Name => 'ITSMCore' ) ) {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSITSMCore',
            Priority    => '0110',
        );
    }

    # check for ITSMConfigurationManagement and register extensions...
    if (
        $Kernel::OM->Get('Kernel::System::Package')
        ->PackageIsInstalled( Name => 'ITSMConfigurationManagement' )
        )
    {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSITSMConfigManagement',
            Priority    => '0120',
        );
    }

    # check for ITSMIncidentProblemManagement and register extensions...
    if (
        $Kernel::OM->Get('Kernel::System::Package')
        ->PackageIsInstalled( Name => 'ITSMIncidentProblemManagement' )
        )
    {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSITSMIncidentProblem',
            Priority    => '0130',
        );
    }

    # check for ITSMChangeManagement and register extensions...
    if (
        $Kernel::OM->Get('Kernel::System::Package')
        ->PackageIsInstalled( Name => 'ITSMChangeManagement' )
        )
    {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSITSMChangeManagement',
            Priority    => '0150',
        );
    }

    # check for GeneralCatalog and register extensions...
    if (
        $Kernel::OM->Get('Kernel::System::Package')->PackageIsInstalled( Name => 'GeneralCatalog' )
        )
    {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSGeneralCatalog',
            Priority    => '0160',
        );
    }

    # check for FAQ and register extensions...
    if ( $Kernel::OM->Get('Kernel::System::Package')->PackageIsInstalled( Name => 'FAQ' ) ) {
        $Kernel::OM->Get('Kernel::System::KIXUtils')->RegisterCustomPackage(
            PackageName => 'KIX4OTRSFAQ',
            Priority    => '0180',
        );
    }

    # reload configuration....
    $Kernel::OM->Get('Kernel::System::SysConfig')->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if ( !-f $File );
            do $File;
            last PREFIX;
        }
    }
    return 1;
}

sub _RemoveCustomModule {
    my ( $Self, %Param ) = @_;

    # delete all multiple cutsom module folders for KIX4OTRS...
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRS',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSITSMCore',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSITSMConfigurationManagement',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSITSMIncidentProblemManagement',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSITSMChangeManagement',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSGeneralCatalog',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSMasterSlave',
    );
    $Kernel::OM->Get('Kernel::System::KIXUtils')->UnRegisterCustomPackage(
        PackageName => 'KIX4OTRSFAQ',
    );

    # reload configuration....
    $Kernel::OM->Get('Kernel::System::SysConfig')->WriteDefault();
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {
        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if ( !-f $File );
            do $File;
            last PREFIX;
        }
    }
    return 1;
}

sub _CreateTicketStates {
    my ( $Self, %Param ) = @_;
    my %CustomTicketStates = (
        'pending auto reopen' => [ 'pending auto', 'Ticket is pending for automatic reopen' ],
    );

    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ReverseValidList = reverse(%ValidList);

    my %StateList = $Kernel::OM->Get('Kernel::System::State')->StateList( UserID => 1, );
    my %ReverseStateList = reverse(%StateList);
    my %StateListInvalid
        = $Kernel::OM->Get('Kernel::System::State')->StateList( UserID => 1, Valid => 0 );
    my %ReverseStateListInvalid = reverse(%StateListInvalid);

    my %StateTypeList = $Kernel::OM->Get('Kernel::System::State')->StateTypeList( UserID => 1, );
    my %ReverseStateTypeList = reverse(%StateTypeList);

    # create KIX-specific ticket states
    for my $CurrStateName ( keys %CustomTicketStates ) {

        # no action if state already exists...
        next if ( $ReverseStateList{$CurrStateName} );

        if ( $ReverseStateTypeList{ $CustomTicketStates{$CurrStateName}->[0] } ) {

            if ( $ReverseStateListInvalid{$CurrStateName} ) {
                my $UpdateStateID = $Kernel::OM->Get('Kernel::System::State')->StateUpdate(
                    ID      => $ReverseStateListInvalid{$CurrStateName},
                    Name    => $CurrStateName,
                    Comment => $CustomTicketStates{$CurrStateName}->[1],
                    ValidID => $ReverseValidList{valid},
                    TypeID  => $ReverseStateTypeList{ $CustomTicketStates{$CurrStateName}->[0] },
                    UserID  => 1,
                );
                if ($UpdateStateID) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'notice',
                        Message  => "Ticketstate <$CurrStateName> updated.",
                    );
                }
            }

            else {
                my $NewStateID = $Kernel::OM->Get('Kernel::System::State')->StateAdd(
                    Name    => $CurrStateName,
                    Comment => $CustomTicketStates{$CurrStateName}->[1],
                    ValidID => $ReverseValidList{valid},
                    TypeID  => $ReverseStateTypeList{ $CustomTicketStates{$CurrStateName}->[0] },
                    UserID  => 1,
                );
                if ($NewStateID) {
                    $Kernel::OM->Get('Kernel::System::Log')->Log(
                        Priority => 'notice',
                        Message  => "Ticketstate <$CurrStateName> created.",
                    );
                }
            }
        }
        else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Ticketstate <$CurrStateName> could not be created -"
                    . " assigned ticket state type"
                    . " <$CustomTicketStates{$CurrStateName}> does not exist."
            );
        }
    }
    return 1;
}

sub _DeactivateTicketStates {
    my ( $Self, %Param ) = @_;

    # set KIX-specific ticket states
    my @DeactivatedStates = (
        'pending auto reopen',
    );
    my %ValidList        = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();
    my %ReverseValidList = reverse(%ValidList);

    # deactivate KIX-specific ticket states
    for my $CurrStateName (@DeactivatedStates) {
        my %CurrState = $Kernel::OM->Get('Kernel::System::State')->StateGet(
            Name => $CurrStateName,
        );
        next if ( !%CurrState || $CurrState{ValidID} == 2 );
        $Kernel::OM->Get('Kernel::System::State')->StateUpdate(
            ID      => $CurrState{ID},
            Name    => $CurrStateName,
            Comment => 'Deactived by KIX4OTRS de-installation',
            ValidID => $ReverseValidList{invalid},
            TypeID  => $CurrState{TypeID},
            UserID  => 1,
        );
    }
    return 1;
}

sub _MigrateFromCiCS {
    my ( $Self, %Param ) = @_;
    if ( $Kernel::OM->Get('Kernel::System::Package')->PackageIsInstalled( Name => 'OTRS-CiCS' ) ) {

        # disable previous tsunami approach (Config.pm)...
        my @Input;
        my @Output;
        my $File = $Kernel::OM->Get('Kernel::Config')->Get('Home') . "/Kernel/Config.pm";

        # get DB config data
        $Self->{'DB::Type'} = '';
        $Kernel::OM->Get('Kernel::System::DSN} = $Self->{Config')->Get('DatabaseDSN');
        if ( $Self->{DSN} =~ /:(mssql|sybase)/i ) {
            $Self->{'DB::Type'} = 'mssql';
        }
        if ( $Kernel::OM->Get('Kernel::Config')->Get('Database::Type') ) {
            $Self->{'DB::Type'} = $Kernel::OM->Get('Kernel::Config')->Get('Database::Type');
        }
        open( my $IN, "<", $File );
        @Input = <$IN>;
        close($IN);
        my $BEGIN        = 'BEGIN required for CiCS-Tsunami';
        my $END          = 'END required for CiCS-Tsunami';
        my $ExcludedLine = 0;
        foreach my $Line (@Input) {

            if ( $Line =~ $BEGIN ) {
                $ExcludedLine = 1;
            }
            if ( $ExcludedLine == 0 ) {
                push @Output, $Line;
            }
            if ( $Line =~ $END ) {
                $ExcludedLine = 0;
            }
        }
        open( my $OUT, ">", $File );
        foreach my $Line (@Output) {
            print $OUT $Line;
        }
        close($OUT);

        # change user themes to standard
        my $SQL =
            "UPDATE user_preferences "
            . " SET preferences_value = 'Standard' "
            . " WHERE preferences_key = 'UserTheme' ";
        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

        # migrate linked persons...
        $SQL = "UPDATE linked_person SET type = '3rdParty' WHERE type = '3rd party'";
        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
        $SQL =
            "INSERT INTO link_relation (source_object_id, source_key, target_object_id, target_key, type_id, state_id, create_time, create_by) "
            . "SELECT "
            . " (SELECT lo1.id From link_object lo1 WHERE lo1.name = 'Person') as s_object_id, "
            . " lp.person_id, "
            . " (SELECT lo2.id From link_object lo2 WHERE lo2.name = 'Ticket') as t_object_id, "
            . " lp.ticket_id, "
            . " (SELECT lt.id From link_type lt WHERE lt.name = lp.type) as type_id, "
            . " 1, lp.create_time, lp.create_by "
            . " FROM linked_person lp";
        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

        # migrate ticket notes...
        $SQL =
            "INSERT INTO kix_ticket_notes (ticket_id, note, create_time, create_by, change_time, change_by) "
            . "SELECT id, notes, change_time, change_by, create_time, create_by "
            . "FROM ticket WHERE (notes IS NOT NULL) OR (notes != '')";
        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

        # TO DO:
        # => check if this works on postgres, mysql, mssql
        # ticket_notes.ticket_id
        # ticket_notes.note = ticket.ticket_note
        # ticket_notes.create_time = current_timestamp
        # ticket_notes.create_by = 1
        # ticket_notes.change_time = current_timestamp
        # ticket_notes.change_by = 1
        my @RepositoryList = $Kernel::OM->Get('Kernel::System::Package')->RepositoryList();

        # migrate text modules...
        for my $Package (@RepositoryList) {
            if ( $Package->{Name}->{Content} eq 'TextModules' ) {
                if ( $Self->{'DB::Type'} =~ /mssql/ ) {
                    my $SQL = " SET IDENTITY_INSERT dbo.kix_text_module ON ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                }
                if (
                    $Package->{Version}->{Content}    eq '1.2.4'
                    || $Package->{Version}->{Content} eq '1.2.5'
                    || $Package->{Version}->{Content} eq '1.2.6'
                    )
                {

                    # copy text-module-definitions to new structure...
                    $SQL =
                        "INSERT INTO kix_text_module (id, name, text, language, keywords, comment1, comment2, subject, f_agent, f_customer, "
                        . "f_public, valid_id, create_time, create_by, change_time, change_by) "
                        . "SELECT id, name, text, language, keywords, comment1, comment2, subject, f_agent, f_customer, "
                        . "f_public, valid_id, create_time, create_by, change_time, change_by "
                        . "FROM text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

                    # delete erroneous entries possible created in the past...
                    $SQL
                        = "DELETE FROM queue_text_module WHERE text_module_id NOT IN ( SELECT id FROM kix_text_module)";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

                    # delete erroneous entries possible created in the past...
                    $SQL
                        = "DELETE FROM ticket_type_text_module WHERE text_module_id NOT IN ( SELECT id FROM kix_text_module)";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

                    # copy text-module-queue-assignments to new structure...
                    $SQL =
                        "INSERT INTO kix_text_module_queue (queue_id, text_module_id, create_time, create_by, change_time, change_by) "
                        . "SELECT queue_id, text_module_id, create_time, create_by, change_time, change_by "
                        . "FROM queue_text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

                    # copy text-module-type-assignments to new structure...
                    $SQL =
                        "INSERT INTO kix_text_module_ticket_type (ticket_type_id, text_module_id, create_time, create_by, change_time, change_by)"
                        . "SELECT ticket_type_id, text_module_id, create_time, create_by, change_time, change_by "
                        . "FROM ticket_type_text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                }
                elsif (
                    $Package->{Version}->{Content} eq '1.2.2'
                    || $Package->{Version}->{Content} eq '1.2.3'
                    )
                {
                    $SQL =
                        "INSERT INTO kix_text_module (id, name, text, language, keywords, comment1, comment2, subject, f_agent, f_customer, "
                        . "f_public, valid_id, create_time, create_by, change_time, change_by) "
                        . "SELECT id, name, text, language, keywords, comment1, comment2, subject, 1, 0, "
                        . "0, valid_id, create_time, create_by, change_time, change_by "
                        . "FROM text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                    $SQL =
                        "INSERT INTO kix_text_module_queue (queue_id, text_module_id, create_time, create_by, change_time, change_by) "
                        . "SELECT queue_id, text_module_id, create_time, create_by, change_time, change_by "
                        . "FROM queue_text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                    $SQL =
                        "INSERT INTO kix_text_module_ticket_type (ticket_type_id, text_module_id, create_time, create_by, change_time, change_by)"
                        . "SELECT ticket_type_id, text_module_id, create_time, create_by, change_time, change_by "
                        . "FROM ticket_type_text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                }
                else {
                    $SQL =
                        "INSERT INTO kix_text_module (id, name, text, language, keywords, comment1, comment2, subject, f_agent, f_customer, "
                        . "f_public, valid_id, create_time, create_by, change_time, change_by) "
                        . "SELECT id, name, text, language, keywords, comment1, comment2, '', 1, 0, "
                        . "0, valid_id, create_time, create_by, change_time, change_by "
                        . "FROM text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                    $SQL =
                        "INSERT INTO kix_text_module_queue (queue_id, text_module_id, create_time, create_by, change_time, change_by) "
                        . "SELECT queue_id, text_module_id, create_time, create_by, change_time, change_by "
                        . "FROM queue_text_module ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );

                    if (
                        $Package->{Version}->{Content} eq '1.2.1'
                        || $Package->{Version}->{Content} eq '1.2.0'
                        )
                    {
                        $SQL =
                            "INSERT INTO kix_text_module_ticket_type (ticket_type_id, text_module_id, create_time, create_by, change_time, change_by)"
                            . "SELECT ticket_type_id, text_module_id, create_time, create_by, change_time, change_by "
                            . "FROM ticket_type_text_module ";
                        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                    }
                }
                if ( $Self->{'DB::Type'} =~ /mssql/ ) {
                    my $SQL = " SET IDENTITY_INSERT dbo.kix_text_module OFF ";
                    $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
                }
            }
        }
        if ( $Self->{'DB::Type'} =~ /mssql/ ) {
            my $SQL = " SET IDENTITY_INSERT dbo.kix_file_watcher ON ";
            $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
        }

        # copy content from file_watcher to kix_file_watcher..
        $SQL =
            "INSERT INTO kix_file_watcher (id, parent_id, fingerprint, path, name, first_found, last_found, mod_type, last_mod, path_lower, name_lower, outdated, size) "
            . "SELECT id, parent_id, fingerprint, path, name, first_found, last_found, mod_type, last_mod, path_lower, name_lower, outdated, size FROM file_watcher";
        $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
        if ( $Self->{'DB::Type'} =~ /mssql/ ) {
            my $SQL = " SET IDENTITY_INSERT dbo.kix_file_watcher OFF ";
            $Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL );
        }

        # TO DO:
        # => check if this works on postgres, mysql, mssql
        # uninstall Packages...
        my @ReversePackageList = reverse @RepositoryList;
        my @RemovePackages = ( "OTRS-CiCS-ITSM", "TextModules", "OTRS-CiCS" );
        for my $Package (@ReversePackageList) {
            for my $RemovePackage (@RemovePackages) {
                if ( $Package->{Name}->{Content} eq $RemovePackage ) {

                    # get package content from repository for uninstall
                    my $PackageContent = $Kernel::OM->Get('Kernel::System::Package')->RepositoryGet(
                        Name    => $Package->{Name}->{Content},
                        Version => $Package->{Version}->{Content},
                    );

                    # uninstall the package
                    $Kernel::OM->Get('Kernel::System::Package')->PackageUninstall(
                        String => $PackageContent,
                    );
                }
            }
        }
        return 0;
    }
}

sub _GroupAdd {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Argument (qw(Name Description)) {
        if ( !$Param{$Argument} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Argument!",
            );
            return;
        }
    }

    # get valid list
    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList(
        UserID => 1,
    );
    my %ValidListReverse = reverse %ValidList;

    # check if group already exists
    my %Groups        = $Kernel::OM->Get('Kernel::System::Group')->GroupList();
    my %GroupsReverse = reverse %Groups;
    my $GroupID       = $GroupsReverse{ $Param{Name} } || 0;

    # reactivate the group
    if ($GroupID) {

        # get current group data
        my %GroupData = $Kernel::OM->Get('Kernel::System::Group')->GroupGet(
            ID     => $GroupID,
            UserID => 1,
        );

        # reactivate group
        return $Kernel::OM->Get('Kernel::System::Group')->GroupUpdate(
            %GroupData,
            ValidID => $ValidListReverse{valid},
            UserID  => 1,
        );
    }

    # add the group
    else {
        $GroupID = $Kernel::OM->Get('Kernel::System::Group')->GroupAdd(
            Name    => $Param{Name},
            Comment => $Param{Description},
            ValidID => $ValidListReverse{valid},
            UserID  => 1,
        );
        if ( !$GroupID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Group <$Param{Name}> could not be created -"
                    . " please do it manually."
            );
            return;
        }

        # add user root to the new group
        $Kernel::OM->Get('Kernel::System::Group')->GroupMemberAdd(
            GID        => $GroupID,
            UID        => 1,
            Permission => {
                ro        => 1,
                move_into => 1,
                create    => 1,
                owner     => 1,
                priority  => 1,
                rw        => 1,
            },
            UserID => 1,
        );
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "Group <$Param{Name}> created and assigned to root user.",
        );
    }
    return 1;
}

sub _FixDocumentIDs {
    my ( $Self, %Param ) = @_;
    my @LinkRelationArr = qw{};

    # NOTE: in PostgreSQL following two statements would do the work as well...
    # UPDATE link_relation
    # SET source_key = regexp_replace ( source_key, '::', ':', 'g')
    # WHERE source_key LIKE '%::%'
    #
    # UPDATE link_relation
    # SET target_key = regexp_replace ( target_key, '::', ':', 'g')
    # WHERE target_key LIKE '%::%'

    return if !$Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL => "SELECT source_object_id, source_key, "
            . " target_object_id, target_key, type_id, state_id"
            . " FROM link_relation, link_type "
            . " WHERE source_key LIKE '%::%' AND name = 'DocumentLink'",
        Bind  => [],
        Limit => undef,
    );

    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        my %CurrRow = ();
        $CurrRow{source_object_id} = $Row[0];
        $CurrRow{source_key}       = $Row[1];
        $CurrRow{target_object_id} = $Row[2];
        $CurrRow{target_key}       = $Row[3];
        $CurrRow{type_id}          = $Row[4];
        $CurrRow{state_id}         = $Row[5];
        $CurrRow{create_time}      = $Row[6];
        $CurrRow{create_by}        = $Row[7];
        push( @LinkRelationArr, \%CurrRow );
    }

    my $CountOK = 0;
    for my $CurrLine (@LinkRelationArr) {
        my %NewData = %{$CurrLine};

        # replace double colons by single colons...
        $NewData{source_key} =~ s/\:\:/\:/g;
        $NewData{target_key} =~ s/\:\:/\:/g;

        my $UpdateOK = $Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL => 'UPDATE link_relation '
                . 'SET '
                . 'source_key = ?, '
                . 'target_key = ? '
                . 'WHERE '
                . 'source_object_id = ? '
                . 'AND source_key = ? '
                . 'AND target_object_id = ? '
                . 'AND target_key = ? '
                . 'AND type_id = ? '
                . 'AND state_id = ?',
            Bind => [
                \$NewData{source_key},
                \$NewData{target_key},
                \$CurrLine->{source_object_id},
                \$CurrLine->{source_key},
                \$CurrLine->{target_object_id},
                \$CurrLine->{target_key},
                \$CurrLine->{type_id},
                \$CurrLine->{state_id}
            ],
        );

        if ( !$UpdateOK ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Link Relation could not be updated -"
                    . "(SrcKey: $CurrLine->{source_key}, "
                    . "TargetKey: $CurrLine->{target_key}).",
            );
        }
        else {
            $CountOK++;
        }
    }    #EO for my $CurrLine ( @LinkRelationArr )

    $Kernel::OM->Get('Kernel::System::Log')->Log(
        Priority => 'notice',
        Message  => "Link relation for document links updated "
            . "($CountOK of "
            . ( scalar(@LinkRelationArr) || 0 )
            . "entries).",
    );

    return 1;
}

sub _CreateSkinFolder {
    my ( $Self, %Param ) = @_;

    my $Home             = $Kernel::OM->Get('Kernel::Config')->Get('Home');
    my $KIXSkinDirectory = $Home . '/var/httpd/htdocs/skins/Agent/KIX4OTRS';

    if ( !-e $KIXSkinDirectory ) {
        if ( !mkpath( $KIXSkinDirectory, 0, 0755 ) ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Can't create directory '$KIXSkinDirectory': $!",
            );
            return;
        }
    }
    return 1;
}

sub _DynamicFieldCreate {
    my ( $Self, %Param ) = @_;

    my @NewDynamicFields = (
        {
            Name       => 'KIXFAQEntry',
            Label      => 'Suggest as FAQ-Entry',
            FieldType  => 'Dropdown',
            ObjectType => 'Article',
            Config     => {
                DefaultValue   => 'No',
                PossibleValues => {
                    Yes => 'Yes',
                    No  => 'No'
                },
                TranslatableValues => 1
                }
        }
    );

    my $List           = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldListGet();
    my @FieldOrderList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList();
    my $Count          = scalar @FieldOrderList;

    for my $NewField (@NewDynamicFields) {
        next if !IsHashRefWithData($NewField);

        # check if dynamic field exists
        my $FieldExists = 0;
        for my $DynamicFieldConfig ( @{$List} ) {
            next if !IsHashRefWithData($DynamicFieldConfig);
            if ( $NewField->{Name} eq $DynamicFieldConfig->{Name} ) {
                $FieldExists = 1;
            }
        }
        next if $FieldExists;

        # add dynamic field
        my $ID = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldAdd(
            %{$NewField},
            FieldOrder => $Count++,
            Reorder    => 1,
            ValidID    => 1,
            UserID     => 1,
        );

        if ( !$ID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "DynamicField " . $NewField->{Name} . " not added.",
            );
        }
        else {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'notice',
                Message  => "DynamicField " . $NewField->{Name} . " added.",
            );
        }
    }
    return 1;
}

sub _MigrateDashboardColumnSettings {
    my ( $Self, %Param ) = @_;

    # get all users
    my %UserList        = $Kernel::OM->Get('Kernel::System::User')->UserList();
    my %PreferencesHash = ();

    USER:
    for my $UserID ( keys %UserList ) {

        # get user preferences
        my %UserPreferences = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            UserID => $UserID,
        );
        next USER if !( scalar keys %UserPreferences );

        # look up preferences
        PREFERENCE:
        for my $PreferencesKey ( keys %UserPreferences ) {
            next PREFERENCE if $PreferencesKey !~ m/^UserDashboardPref(.*?)-Columns$/;

            # if already migrated
            next PREFERENCE if $UserPreferences{$PreferencesKey} =~ m/^\{.*\}$/;
            $PreferencesHash{$UserID}->{$1}->{Columns} = $UserPreferences{$PreferencesKey};
        }
    }

    # create preferences string
    for my $UserID ( keys %PreferencesHash ) {
        for my $PreferencesKey ( keys %{ $PreferencesHash{$UserID} } ) {

            next
                if !defined $PreferencesHash{$UserID}->{$PreferencesKey}->{Columns}
                    || !$PreferencesHash{$UserID}->{$PreferencesKey}->{Columns};

            my @ColumnArray
                = split( /\;/, $PreferencesHash{$UserID}->{$PreferencesKey}->{Columns} );
            my $ColumnString = '{"Columns":{';
            my $OrderString  = '},"Order":[';
            my $Count        = 0;
            for my $Item (@ColumnArray) {
                if ($Count) {
                    $ColumnString .= ",";
                    $OrderString  .= ",";
                }
                $ColumnString .= '"' . $Item . '":1';
                $OrderString  .= '"' . $Item . '"';
                $Count++;
            }
            my $String = $ColumnString . $OrderString . ']}';

            # write new preferences
            $Kernel::OM->Get('Kernel::System::User')->SetPreferences(
                UserID => $UserID,
                Key    => 'UserDashboardPref' . $PreferencesKey . '-Columns',
                Value  => $String,
            );
        }
    }
}

sub _SetTabAclActions {
    my ( $Self, %Param ) = @_;

    # get defined tab keys
    my %TabConfig;

    $TabConfig{AgentTicketZoom} = $Kernel::OM->Get('Kernel::Config')->Get('AgentTicketZoomBackend');

# $TabConfig{AgentITSMConfigItemZoom}
#     = $Kernel::OM->Get('Kernel::Config')->Get('AgentITSMConfigItemZoomBackend');
# $TabConfig{AgentITSMChangeZoom} = $Kernel::OM->Get('Kernel::Config')->Get('AgentITSMChangeZoomBackend');
# $TabConfig{AgentITSMWorkOrderZoom}
#     = $Kernel::OM->Get('Kernel::Config')->Get('AgentITSMWorkOrderZoomBackend');

    # get all level 3 actions from sysconfig
    my %ItemHash = $Kernel::OM->Get('Kernel::System::SysConfig')
        ->ConfigItemGet( Name => 'ACLKeysLevel3::Actions###100-Default' );

    # create array from old values
    my @Content;
    for my $Item ( @{ $ItemHash{Setting}->[1]->{Array}->[1]->{Item} } ) {
        next if !defined $Item->{Content};
        next if !( $Item->{Content} );
        push( @Content, $Item->{Content} );
    }

    # insert tab identifiers
    for my $TabsBackend ( keys %TabConfig ) {
        for my $Tab ( keys %{ $TabConfig{$TabsBackend} } ) {
            my $Key = $TabsBackend . '###' . $Tab;
            next if grep( /$Key/, @Content );
            push( @Content, $Key );
        }
    }

    # write new config
    $Kernel::OM->Get('Kernel::System::SysConfig')->ConfigItemUpdate(
        Key   => 'ACLKeysLevel3::Actions###100-Default',
        Value => \@Content,
        Valid => 1,
    );
}

sub _CopyGraphTableData {
    my ( $Self, %Param ) = @_;

    # if "new" graph table has got data (HighestID > 0) the previous KIX version must be >= 6.1.0,
    # so copying data is not necessary
    $Kernel::OM->Get('Kernel::System::DB')->Prepare(
        SQL   => 'SELECT id FROM kix_link_graph ORDER BY id DESC',
        Limit => 1
    );
    my $HighestID = 0;
    while ( my @Row = $Kernel::OM->Get('Kernel::System::DB')->FetchrowArray() ) {
        $HighestID = $Row[0];
    }
    return 1 if ( $HighestID > 0 );

    # only if table kix_ci_graph exists
    if ( !$Kernel::OM->Get('Kernel::System::DB')->Do( SQL => 'SELECT id FROM kix_ci_graph' ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'notice',
            Message  => "Don't worry about this message. To copy the data from kix_ci_graph is only necessary if you are upgrading from KIX4OTRS 6.0.x.",
        );
        print STDERR "Don't worry about this message. To copy the data from kix_ci_graph is only necessary if you are upgrading from KIX4OTRS 6.0.x.\n";
        return 1;
    }

    my $SQL
        = 'INSERT INTO kix_link_graph ( id, name, object_id, object_type, layout, config, create_time, create_by, change_time, change_by ) '
        . 'SELECT ci_graph.id, ci_graph.name, ci_graph.ci_id, 0, '
        . 'ci_graph.layout, ci_graph.config, ci_graph.create_time, ci_graph.create_by, '
        . 'ci_graph.change_time, ci_graph.change_by '
        . 'FROM kix_ci_graph ci_graph';
    if ( !$Kernel::OM->Get('Kernel::System::DB')->Do( SQL => $SQL ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "KIX4OTRS: copying link graph data failed!",
        );
    }

    if (
        !$Kernel::OM->Get('Kernel::System::DB')->Do(
            SQL =>
                "UPDATE kix_link_graph SET object_type = 'ITSMConfigItem' WHERE object_type = '0'"
        )
        )
    {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "KIX4OTRS: could not set object_type in link graph table!",
        );
    }

    if ( !$Kernel::OM->Get('Kernel::System::DB')->Do( SQL => 'DROP TABLE kix_ci_graph' ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "KIX4OTRS: could not drop table kix_ci_graph!",
        );
    }
}

sub _CreateLinkedPersonNotification {
    my ( $Self, %Param ) = @_;
    my %Notification;
    my %Data;

    # check and update existing linked person notification
    %Notification = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationGet(
        Name => 'Linked Person Notification',
    );
    if ( %Notification ) {
        $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationUpdate(
            %Notification,
            Name => 'Linked Person Notification (Agent)',
            'Recipients' => [
                'LinkedPersonAgent'
            ],
            UserID => 1,
        );
    }

    # Agent Notification
    %Notification = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationGet(
        Name => 'Linked Person Notification (Agent)',
    );

    %Data = (
        'ArticleTypeID'       => '1',
        'Events'              => 'ArticleCreate',
        'Transports'          => 'Email',
        'Name'                => 'Linked Person Notification (Agent)',
        'ArticleSenderTypeID' => '1',
        'Message'             => {
            'de' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hallo,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" hat folgende Notiz an Ticket &lt;OTRS_TICKET_TicketNumber&gt; angehangen.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />Diese Benachrichtigung wurde Ihnen im Auftrag von "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" zugesendet.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'BENACHRICHTIGUNG! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                },
            'en' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hello,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" has added following notice to ticket &lt;OTRS_TICKET_TicketNumber&gt;.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />This notification was sent to you, because "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" wants to inform you about this process.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'NOTIFICATION! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                }
        },
        'ValidID' => '1',
        'Data'    => {
            'ArticleTypeID' => [
                '1',
                '2',
                '3',
                '4',
                '5',
                '9',
                '10'
            ],
            'ArticleSenderTypeID' => [
                '1',
                '3'
            ],
            'Transports' => [
                'Email'
            ],
            'Events' => [
                'ArticleCreate'
            ],
            'ArticleAttachmentInclude' => [
                '0'
            ],
            'Recipients' => [
                'LinkedPerson'
            ],
            'NotificationArticleTypeID' => [
                '3'
            ],
            'TransportEmailTemplate' => [
                'Default'
            ],
            'VisibleForAgent' => [
                '0'
            ],
            'AgentEnabledByDefault' => [
                'Email'
            ],
        }
    );
    if ( !%Notification ) {
        my $ID = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationAdd(
            %Data,
            UserID => 1,
        );
    } else {
        
        # createtime == changetime ? update
        if ($Notification{CreateTime} eq $Notification{ChangeTime}) {
            $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationUpdate(
                ID      => $Notification{ID},
                Name    => $Notification{Name},
                Data    => $Notification{Data},
                Message => {
                    en => {
                        Subject     => $Data{Message}->{en}->{Subject},
                        Body        => $Data{Message}->{en}->{Body},
                        ContentType => $Data{Message}->{en}->{ContentType},
                    },
                    de => {
                        Subject     => $Data{Message}->{de}->{Subject},
                        Body        => $Data{Message}->{de}->{Body},
                        ContentType => $Data{Message}->{de}->{ContentType},
                    },
                },
                ValidID => $Notification{ValidID},
                UserID  => $Notification{ChangeBy},
                Comment => $Notification{Comment},
            );
        }
    }

    # Customer Notification
    %Notification = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationGet(
        Name => 'Linked Person Notification (Customer)',
    );

    %Data = (
        'ArticleTypeID'       => '1',
        'Events'              => 'ArticleCreate',
        'Transports'          => 'Email',
        'Name'                => 'Linked Person Notification (Customer)',
        'ArticleSenderTypeID' => '1',
        'Message'             => {
            'de' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hallo,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" hat folgende Notiz an Ticket &lt;OTRS_TICKET_TicketNumber&gt; angehangen.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />Diese Benachrichtigung wurde Ihnen im Auftrag von "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" zugesendet.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'BENACHRICHTIGUNG! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                },
            'en' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hello,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" has added following notice to ticket &lt;OTRS_TICKET_TicketNumber&gt;.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />This notification was sent to you, because "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" wants to inform you about this process.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'NOTIFICATION! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                }
        },
        'ValidID' => '1',
        'Data'    => {
            'ArticleTypeID' => [
                '1',
                '3',
                '5',
                '10'
            ],
            'ArticleSenderTypeID' => [
                '1',
                '3'
            ],
            'Transports' => [
                'Email'
            ],
            'Events' => [
                'ArticleCreate'
            ],
            'ArticleAttachmentInclude' => [
                '0'
            ],
            'Recipients' => [
                'LinkedPersonCustomer'
            ],
            'NotificationArticleTypeID' => [
                '3'
            ],
            'TransportEmailTemplate' => [
                'Default'
            ],
            'VisibleForAgent' => [
                '0'
            ],
            'AgentEnabledByDefault' => [
                'Email'
            ],
        }
    );
    if ( !%Notification ) {
        my $ID = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationAdd(
            %Data,
            UserID => 1,
        );
    } else {
        
        # createtime == changetime ? update
        if ($Notification{CreateTime} eq $Notification{ChangeTime}) {
            $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationUpdate(
                ID      => $Notification{ID},
                Name    => $Notification{Name},
                Data    => $Notification{Data},
                Message => {
                    en => {
                        Subject     => $Data{Message}->{en}->{Subject},
                        Body        => $Data{Message}->{en}->{Body},
                        ContentType => $Data{Message}->{en}->{ContentType},
                    },
                    de => {
                        Subject     => $Data{Message}->{de}->{Subject},
                        Body        => $Data{Message}->{de}->{Body},
                        ContentType => $Data{Message}->{de}->{ContentType},
                    },
                },
                ValidID => $Notification{ValidID},
                UserID  => $Notification{ChangeBy},
                Comment => $Notification{Comment},
            );
        }
    }

    # 3rd Person Notification
    %Notification = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationGet(
        Name => 'Linked Person Notification (3rd Person)',
    );

    %Data = (
        'ArticleTypeID'       => '1',
        'Events'              => 'ArticleCreate',
        'Transports'          => 'Email',
        'Name'                => 'Linked Person Notification (3rd Person)',
        'ArticleSenderTypeID' => '1',
        'Message'             => {
            'de' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hallo,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" hat folgende Notiz an Ticket &lt;OTRS_TICKET_TicketNumber&gt; angehangen.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />Diese Benachrichtigung wurde Ihnen im Auftrag von "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" zugesendet.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'BENACHRICHTIGUNG! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                },
            'en' => {
                'ContentType' => 'text/html',
                'Body' =>
                    'Hello,<br /><br />"&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" has added following notice to ticket &lt;OTRS_TICKET_TicketNumber&gt;.<br /><br />----------------------<br />&lt;OTRS_CUSTOMER_BODY&gt;<br />----------------------<br /><br />This notification was sent to you, because "&lt;OTRS_CURRENT_UserFirstname&gt; &lt;OTRS_CURRENT_UserLastname&gt;" wants to inform you about this process.<br /><br />&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/&lt;OTRS_CONFIG_ScriptAlias&gt;index.pl?Action=AgentZoom&TicketID=&lt;OTRS_TICKET_TicketID&gt;',
                'Subject' =>
                    'NOTIFICATION! <OTRS_CUSTOMER_SUBJECT[24]> [<OTRS_CONFIG_Ticket::Hook><OTRS_TICKET_TicketNumber>]'
                }
        },
        'ValidID' => '1',
        'Data'    => {
            'ArticleTypeID' => [
                '1',
                '3',
                '5',
                '10'
            ],
            'ArticleSenderTypeID' => [
                '1',
                '3'
            ],
            'Transports' => [
                'Email'
            ],
            'Events' => [
                'ArticleCreate'
            ],
           'ArticleAttachmentInclude' => [
                '0'
            ],
            'Recipients' => [
                'LinkedPerson3rdPerson'
            ],
            'NotificationArticleTypeID' => [
                '3'
            ],
            'TransportEmailTemplate' => [
                'Default'
            ],
            'VisibleForAgent' => [
                '0'
            ],
            'AgentEnabledByDefault' => [
                'Email'
            ],
        }
    );
    if ( !%Notification ) {
        my $ID = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationAdd(
            %Data,
            UserID => 1,
        );
    } else {
        
        # createtime == changetime ? update
        if ($Notification{CreateTime} eq $Notification{ChangeTime}) {
            $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationUpdate(
               ID      => $Notification{ID},
                Name    => $Notification{Name},
                Data    => $Notification{Data},
                Message => {
                    en => {
                        Subject     => $Data{Message}->{en}->{Subject},
                        Body        => $Data{Message}->{en}->{Body},
                        ContentType => $Data{Message}->{en}->{ContentType},
                    },
                    de => {
                        Subject     => $Data{Message}->{de}->{Subject},
                        Body        => $Data{Message}->{de}->{Body},
                        ContentType => $Data{Message}->{de}->{ContentType},
                    },
                },
                ValidID => $Notification{ValidID},
                UserID  => $Notification{ChangeBy},
                Comment => $Notification{Comment},
            );
        }
    }
}

# EO Internal functions
1;

=back

=head1 TERMS AND CONDITIONS

This Software is part of the OTRS project (http://otrs.org/).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

=cut

=head1 VERSION
$Revision$ $Date$
=cut
