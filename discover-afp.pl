#!/usr/bin/env perl

use strict;
use warnings;

use Net::Bonjour;
use Net::AFP::TCP;
use Data::Dumper;
use Carp;
use Getopt::Long;
use Pod::Usage;

# Define default fields to display
my @default_fields = qw(ServerName UTF8ServerName MachineType AFPVersions UAMs NetworkAddresses);
my @fields_to_display;
my $help = 0;

# Parse command-line options
GetOptions(
    'fields|f=s@{1,}' => \@fields_to_display,  # Allow multiple values for --fields or -f
    'help|h'          => \$help,               # Display help
) or pod2usage(2);

# Display help if requested
if ($help) {
    pod2usage({
        -verbose => 2,  # Show full help
        -exitval => 0,  # Exit with status 0 after displaying help
    });
}

# If no fields are specified, use the default fields
@fields_to_display = @default_fields unless @fields_to_display;

# Check for AppleTalk support
my $has_atalk = 0;
eval {
    require Net::Atalk::NBP;
    require Net::AFP::Atalk;
} and do {
    Net::Atalk::NBP->import();
    Net::AFP::Atalk->import();
    $has_atalk = 1;
};

# Discover AFP services over TCP (mDNS)
my $mdns = new Net::Bonjour('afpovertcp', 'tcp');
$mdns->discover();

foreach my $entry ($mdns->entries()) {
    print "For host ", $entry->name(), ":\n";
    my $srvInfo;
    my $rc = Net::AFP::TCP->GetStatus($entry->address(), $entry->port(), \$srvInfo);
    display_fields($srvInfo);
}

# Exit if AppleTalk is not available
exit(0) unless $has_atalk;

# Discover AFP services over AppleTalk
my @results;
eval {
    @results = NBPLookup(undef, 'AFPServer');
} or carp('AppleTalk stack probably out of order');

foreach my $entry (@results) {
    print "For host ", $entry->[3], ":\n";
    my $srvInfo;
    my $rc = Net::AFP::Atalk->GetStatus($entry->[0], $entry->[1], \$srvInfo);
    display_fields($srvInfo);
}

# Helper function to display selected fields
sub display_fields {
    my ($srvInfo) = @_;
    foreach my $field (@fields_to_display) {
        if (exists $srvInfo->{$field}) {
            print "$field: ";
            if (ref($srvInfo->{$field}) eq 'ARRAY') {
                print join(", ", @{$srvInfo->{$field}}), "\n";
            } elsif (ref($srvInfo->{$field}) eq 'HASH') {
                print Dumper($srvInfo->{$field});
            } else {
                print $srvInfo->{$field}, "\n";
            }
        } else {
            print "$field: (Not available)\n";
        }
    }
    print "\n";
}

=pod

=head1 NAME

discover-afp.pl - Discover and display AFP (Apple Filing Protocol) service information.

=head1 SYNOPSIS

discover-afp.pl [options]

Options:
  -f, --fields <field1,field2,...>  Specify fields to display (comma-separated).
  -h, --help                        Display this help message.

=head1 DESCRIPTION

This script discovers AFP services over TCP (mDNS) and optionally over AppleTalk (if supported).
It displays information about the discovered services based on the specified fields.

=head1 FIELDS

The following fields can be displayed:
  - ServerName: The name of the AFP server.
  - UTF8ServerName: The UTF-8 encoded name of the AFP server.
  - MachineType: The type of machine running the AFP server.
  - AFPVersions: The supported AFP versions.
  - UAMs: The User Authentication Methods supported by the server.
  - NetworkAddresses: The network addresses of the server.
  - VolumeIcon: The icon associated with the server (if available).

=head1 EXAMPLES

1. Display default fields for all discovered AFP services:
   discover-afp.pl

2. Display specific fields (ServerName, MachineType, AFPVersions):
   discover-afp.pl --fields ServerName,MachineType,AFPVersions

3. Display help message:
   discover-afp.pl --help

=cut
