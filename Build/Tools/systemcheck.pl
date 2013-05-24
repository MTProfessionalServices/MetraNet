#!perl
use strict;
use Config;

# returns a clean version of a path based variable
# with all non-existent directories removed
sub getPathVar
{
  my $path_var = shift or die "Need a path variable name";
  my $path;
  my $cleanPath;
  if ( $path = $ENV{$path_var} ) {
    my $errors = 0;
    foreach (split /;/, $path) {
      if ( !-d $_ ) {
        print "invalid directories found:\n" unless $errors++;
        print "==> $_\n";
      }
      $cleanPath = "$cleanPath;$_"
    }
  }
  return $cleanPath;
}


#Microsoft (R) 32-bit C/C++ Optimizing Compiler Version 13.10.3077 for 80x86
my $CL_VERSION = "15.00.30729.01";
#Microsoft (R) Incremental Linker Version 7.10.3077
my $LINK_VERSION = "9.00.30729.01";
#Microsoft (R) 32b/64b MIDL Compiler Version 6.00.0361
my $MIDL_VERSION = "7.00.0500";
my $MTPERL_ARCH = "MSWin32-x86-multi-thread";
my $MTPERL_VERSION1 = 5.006;
my $MTPERL_VERSION2 = 5.006001;
my $MTPERL_VERSION3 = 5.008003;
my $MTPERL_VERSION4 = 5.008007;
my $MTBASH_VERSION = "2.04.7";
my $ASP_NET_VERSION = "2.0.50727.0";
my $CSC_VERSION = "3.5.30729.1";
my $REGASM_VERSION = "2.0.50727.42";
my $REGASM_VERSION2 = "2.0.50727.1378";
my $REGASM_VERSION3 = "2.0.50727.1433";
my $REGASM_VERSION4 = "2.0.50727.3053";

my $failures = 0;


#
# perl
#
print "Verifying perl...";
my $arch = $Config{archname};
my $version = $];

if ($arch ne $MTPERL_ARCH)
{
  print "ERROR: perl architecture not $MTPERL_ARCH\n";
}
elsif ($version != $MTPERL_VERSION1 and $version != $MTPERL_VERSION2 and $version != $MTPERL_VERSION3 and $version != $MTPERL_VERSION4)
{
  print "ERROR: incorrect version $version (Expected $MTPERL_VERSION1 or $MTPERL_VERSION2 or $MTPERL_VERSION3 or $MTPERL_VERSION4)\n";
}
else
{
  print "$version\n";
}


#
# path
#
print "Verifying PATH...";
$_ = getPathVar("PATH");

if ((not /\\Common7\\IDE/i)
    or (not /\\VC\\BIN/i)
    or (not /\\Common7\\Tools/i)
    or (not /\\SDK\\v3.5\\bin/i)
    or (not /Microsoft.NET\\Framework\\v3.5/i)
    or (not /Microsoft.NET\\Framework\\v2.0.50727/i)
    or (not /VB98/i)
    or /VC8/i or /Microsoft Platform SDK/i)
{
  print "ERROR: path is invalid.\n";
  print "    PATH should contain at least the following components in this order:\n";
  print "       1. *\\Common7\\IDE\n";
  print "       2. *\\VC\\BIN\n";
  print "       3. *\\Common7\\Tools\n";
  print "       4. *\\SDK\\v3.5\\bin\n";
  print "       5. WINDOWS\\Microsoft.NET\\Framework\\v3.5\n";
  print "       6. WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727\n";
  print "       7. Microsoft Visual Studio\\VB98\n";
  print "    PATH should NOT contain the following components:\n";
  print "       8. *\\VC8\n";
  print "       9. *\\Microsoft Platform SDK\n";
  print "    Current PATH order:\n";
  my @vals = split(";", $_);
  foreach (@vals)
  {
    print "      $_\n";
  }

  print "\n*** Please correct the PATH and try again. ***\n";
  exit -1;
}
else
{
  print "OK\n";
}


#
# CL
#
print "Verifying version of cl...";
$_ = `cl 2>&1`;

if (not /Microsoft \(R\) 32-bit C\/C\+\+ Optimizing Compiler Version (\S+) for 80x86/)
{
  print "ERROR: Unable to verify version of cl\n";
  $failures++;
}

if ($1 ne $CL_VERSION)
{
  print "ERROR: incorrect version $1 (Expected $CL_VERSION)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
#GNU bash, version 2.04.7(2)-release (i686-pc-cygwin)
#
print "Verifying version of bash...";
$_ = `bash --version 2>&1`;

if (not /GNU bash, version (\S+)\(2\)-release \(i686-pc-cygwin\)/)
{
    print "ERROR: Unable to verify version of bash\n";
    print "Perhaps the Cygwin tools aren't in your path?\n\n";
    $failures++;
}
else
{
    if ($1 ne $MTBASH_VERSION)
    {
	print "ERROR: incorrect version $1 (Expected $MTBASH_VERSION)\n";
	$failures++;
    }
    else
    {
	print "$1\n";
    }
}

#
#Microsoft (R) Incremental Linker Version 7.00.9466
#
print "Verifying version of link...";
$_ = `link 2>&1`;

if (not /Microsoft \(R\) Incremental Linker Version (\S+)/)
{
  print "ERROR: Unable to verify version of link\n";
  $failures++;
}

if ($1 ne $LINK_VERSION)
{
  print "ERROR: incorrect version $1 (Expected $LINK_VERSION)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
#Microsoft (R) 32b/64b MIDL Compiler Version 6.00.0347
#
print "Verifying version of midl...";
$_ = `midl 2>&1`;

if (not /Microsoft \(R\) 32b\/64b MIDL Compiler Version (\S+)/)
{
  print "ERROR: Unable to verify version of midl\n";
  $failures++;
}

if ($1 ne $MIDL_VERSION)
{
  print "ERROR: incorrect version $1 (Expected $MIDL_VERSION)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
# csc
#
print "Verifying version of csc...";
$_ = `csc 2>&1`;

if (not /Microsoft \(R\) Visual C\# 2008 Compiler version (\S+)/)
{
  print "ERROR: Unable to verify version of csc\n";
  $failures++;
}

if ($1 ne $CSC_VERSION)
{
  print "ERROR: incorrect version $1 (Expected $CSC_VERSION)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
# regasm
#
print "Verifying version of regasm...";
$_ = `regasm 2>&1`;

if (not /Microsoft \(R\) \.NET Framework Assembly Registration Utility (\S+)/)
{
  print "ERROR: Unable to verify version of regasm\n";
  $failures++;
}

if ($1 ne $REGASM_VERSION and $1 ne $REGASM_VERSION2 and $1 ne  $REGASM_VERSION3 and $1 ne  $REGASM_VERSION4)
{
  print "ERROR: incorrect version $1 (Expected $REGASM_VERSION or $REGASM_VERSION2 or $REGASM_VERSION3)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
# regtlib
#
print "Verifying presence of regtlib...";
$_ = `regtlib 2>&1`;

if ( !/^$/ ) {
  print "ERROR: Unable to verify presence of regtlib\n";
  $failures++;

} else {
  print "OK\n";
}


#
# ASP.NET
#
print "Verifying version of ASP.NET...";
$_ = `aspnet_regiis -lv 2>&1`;

if (not /(\S+)\s+Valid \(Root\)/)
{
  print "ERROR: Unable to verify version of ASP.NET\n";
  $failures++;
}

if ($1 ne $ASP_NET_VERSION)
{
  print "ERROR: incorrect version $1 (Expected $ASP_NET_VERSION)\n";
  $failures++;
}
else
{
  print "$1\n";
}


#
# INCLUDE
#
print "Verifying INCLUDE path...";
$_ = getPathVar("INCLUDE");
if ((not /\\VC\\ATLMFC\\INCLUDE/i)
     or (not /\\VC\\INCLUDE/i)
     or (not /\\Microsoft SDKs\\Windows\\v6.0A\\include/i)
     or /sxl/i or /Microsoft Platform SDK/i or /VC98/i)
{
  print "ERROR: include path is invalid or in the wrong order.\n";
  print "    INCLUDE should contain the following components in this order:\n";
  print "       1. *\\SDK\\v2.0\\include\n";
  print "       2. *\\VC\\ATLMFC\\INCLUDE\n";
  print "       3. *\\VC\\INCLUDE\n";
  print "       4. *\\Microsoft SDKs\\Windows\\v6.0A\\include\n";
  print "    INCLUDE should NOT contain the following components:\n";
  print "       5. *\\sxl\n";
  print "       6. *\\Microsoft Platform SDK\n";
  print "       7. *\\VC98\n";
  print "    Current INCLUDE path order:\n";
  my @vals = split(";", $_);
  foreach (@vals)
  {
    print "      $_\n";
  }
  $failures++;
}
else
{
  print "OK\n";
}

#
# LIB
#
print "Verifying LIB path...";
$_ = getPathVar("LIB");
if ((not /\\VC\\ATLMFC\\LIB/i)
    or (not /\\VC\\LIB/i)
    or (not /\\Microsoft SDKs\\Windows\\v6.0A\\lib/i)
    or /sxl/i or /Microsoft Platform SDK/i or /VC98/i)
{
  print "ERROR: lib path is invalid or in the wrong order.\n";
  print "    LIB should contain the following components in this order:\n";
  print "       1. *\\VC\\ATLMFC\\LIB\n";
  print "       2. *\\VC\\LIB\n";
  print "       3. *\\Microsoft SDKs\\Windows\\v6.0A\\lib\n";
  print "    LIB should NOT contain the following components:\n";
  print "       5. *\\sxl\n";
  print "       6. *\\Microsoft Platform SDK\n";
  print "       7. *\\VC98\n";
  print "    Current LIB order:\n";
  my @vals = split(";", $_);
  foreach (@vals)
  {
    print "      $_\n";
  }
  $failures++;
}
else
{
  print "OK\n";
}


#
# ROOTDIR
#
print "Verifying rootdir...";
my $rootdir = $ENV{ROOTDIR};
if (not $rootdir)
{
  print "ROOTDIR must be set in the environment\n";
  $failures++;
}
elsif ($rootdir =~ /\\$/)
{
  print "ERROR: ROOTDIR should not end in \\\n";
  $failures++;
}
else
{
  print "OK\n";
}

#
# OUTDIR
#
print "Verifying outdir...";
my $outdir = $ENV{MTOUTDIR};
if (not $outdir)
{
  print "MTOUTDIR must be set in the environment\n";
  $failures++;
}
elsif ($outdir =~ /\\$/)
{
  print "ERROR: MTOUTDIR should not end in \\\n";
  $failures++;
}
else
{
  print "OK\n";
}

#
# DOTNET_3_0_BINDIR
#
print "Verifying DOTNET_3_0_BINDIR...";
my $dotNet30BinDir = $ENV{DOTNET_3_0_BINDIR};
if (not $dotNet30BinDir)
{
  print "DOTNET_3_0_BINDIR must be set in the environment for example: C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.0 \n";
  $failures++;
}
elsif ($dotNet30BinDir =~ /\\$/)
{
  print "ERROR: DOTNET_3_0_BINDIR should not end in \\\n";
  $failures++;
}
else
{
  print "OK\n";
}

#
# DOTNET_3_5_BINDIR
#
print "Verifying DOTNET_3_5_BINDIR...";
my $dotNet35BinDir = $ENV{DOTNET_3_5_BINDIR};
if (not $dotNet35BinDir)
{
  print "DOTNET_3_5_BINDIR must be set in the environment for example: C:\Program Files\Reference Assemblies\Microsoft\Framework\v3.5 \n";
  $failures++;
}
elsif ($dotNet35BinDir =~ /\\$/)
{
  print "ERROR: DOTNET_3_5_BINDIR should not end in \\\n";
  $failures++;
}
else
{
  print "OK\n";
}



#
# RMPDIR=r:
#
print "Verifying RMPDIR...";
my $RMPDIR = $ENV{RMPDIR};
if (not $RMPDIR)
{
  print "RMPDIR must be set in the environment for example: R: \n";
  $failures++;
}
elsif ($RMPDIR =~ /\\$/)
{
  print "ERROR: RMPDIR should not end in \\\n";
  $failures++;
}
else
{
  print "OK\n";
}

#
# VERSION=debug
#
print "Verifying VERSION...";
my $envVERSION = $ENV{VERSION};
if (not $envVERSION )
{
  print "VERSION must be set in the environment for example: debug or release \n";
  $failures++;
}
elsif ((lc($envVERSION) ne "release") and (lc($envVERSION) ne "debug"))
{
  print "Warning: Most likely VERSION should be 'debug' or 'release' in order to complete apath like O:\\debug\\bin. Currently VERSION is '$envVERSION' \n";
}
else
{
  print "OK\n";
}

#
# MAKEMODE
#
print "Verifying MAKE_MODE...";
my $makemode = $ENV{MAKE_MODE};
if (not $makemode)
{
  print "ERROR: MAKE_MODE is not set in the environment! Set it to MAKE_MODE=win32\n";
  $failures++;
}
elsif (not $makemode =~ /win32/i)
{
  print "ERROR: MAKE_MODE must be set to 'win32'\n";
  $failures++;
}
else
{
  print "OK\n";
}



$failures && die "\n\n!!! Errors were found. Please correct them before building. !!!\n";

print "\n\nAll systems are go!\n";

