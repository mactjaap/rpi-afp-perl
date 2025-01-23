#!/usr/bin/bash

set -e  # Exit on any error

echo "Starting installation process for AFP Client..."

# Install system dependencies
echo "Installing system dependencies..."
apt update
apt install -y libkrb5-dev libfuse-dev libreadline-dev build-essential git perl-doc

# Clone and build afp-perl
echo "Cloning and building afp-perl..."
git clone https://github.com/demonfoo/afp-perl.git
cd afp-perl
cpan Class::InsideOut Fuse Fuse::Class Log::Dispatch Log::Log4perl Readonly String::Escape Text::Glob Net::Bonjour
perl Makefile.PL
make
make install

# Clone and build atalk-perl
echo "Cloning and building atalk-perl..."
cd ..
git clone https://github.com/demonfoo/atalk-perl.git
cd atalk-perl
perl Makefile.PL
make
make install

# Install additional Perl modules
echo "Installing additional Perl modules..."
cpan Crypt::Mode::CBC Modern::Perl GSSAPI Params::Validate Term::ReadPassword Term::ReadLine::Gnu

# Verify Perl modules
echo "Verifying Perl modules..."
perl -MGSSAPI -e 'print "GSSAPI module is available\n"'
perl -MTerm::ReadPassword -e 'print "Term::ReadPassword module is available\n"'
perl -MTerm::ReadLine -e 'print "Term::ReadLine backend: ", Term::ReadLine->ReadLine, "\n"'

# Set environment variable for Term::ReadLine::Gnu
export PERL_RL=Gnu

# Install example scripts to /usr/local/bin
echo "Copying AFP example scripts to /usr/local/bin..."
cp ../afp-perl/examples/* /usr/local/bin/

echo "Making afp_acl.pl executable..."
chmod +x /usr/local/bin/afp_acl.pl

echo "Making afp_chpass.pl executable..."
chmod +x /usr/local/bin/afp_chpass.pl

echo "Making afpclient.pl executable..."
chmod +x /usr/local/bin/afpclient.pl

echo "Making afp-mdns-test.pl executable..."
chmod +x /usr/local/bin/afp-mdns-test.pl

echo "Making afpmount.pl executable..."
chmod +x /usr/local/bin/afpmount.pl

echo "All example scripts are copied and made executable."

# Test AFP Client
echo "Installation complete! Example scripts are installed in /usr/local/bin and ready to use."
echo ""
echo "Testing AFP Client..."
/usr/local/bin/afpclient.pl --help

