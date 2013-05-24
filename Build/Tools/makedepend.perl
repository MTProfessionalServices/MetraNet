
#
# Step 1: Check that the user has supplied the correct number of command line arguments
#

if($#ARGV < 1) {
  die "Usage: $ENV{PROG_NAME} output_dir src_dir [list of search directories]\nExample: $ENV{PROG_NAME} D:\\build D:\metratech\development\test ..\\..\\include ..\\include\n";
}

#
# Step 2: prepare the search path array and get a list of files to process
#

$RCDependList = "";

$OutDir = $ARGV[0];
$SrcDir = $ARGV[1];

# generate a base outdir & relative path
$RootDir = $ENV{ROOTDIR};

$RelDir = $SrcDir;
$RelDir =~ s/(?i)\Q$RootDir//g;

$OutBase = $OutDir;
$OutBase =~ s/(?i)\Q$RelDir//g;

# generate the directory "tag" for example:
# s:\Account\CreditCard is translated to Account_CreditCard
$DirTag = $RelDir;
$DirTag =~ s/^\\//;							# strip leading \
$DirTag =~ tr/\\/_/;						# translate \ to _ 

@FindList = ($SrcDir);

for (my $i = 2, my $j = 1; $i < @ARGV; $i++,$j++) {
  $FindList[$j] = $ARGV[$i];
}

opendir(DIR,$SrcDir) or die "failed to open current directory";

 

@FullList = grep {/(?i)\.cpp$/ + /(?i)\.h$/ + /(?i)\.c$/ + /(?i)\.hpp$/  + /(?i)\.idl$/ + /(?i)\.rc$/ & !/(?i)resource\.h$/} readdir(DIR);
closedir DIR;
#print "@FullList\n";


#
# step 4: Open or Create the dependency file
#
$file = "> $OutDir/.depend";

open(FILEHANDLE,$file) or die "Failed to open $OutDir/.depend";

$_ = $OutDir;
s/\///g;
s/://g;


#
# reads in a known list of system include files into a hash
#
open(INCLUDES, "$RootDir\\build\\tools\\systemincludes.txt")  or die "Failed to open systemincludes.txt";
my @sysIncludesArray = <INCLUDES>;
my %sysIncludes;
foreach (@sysIncludesArray) 
{
    chomp;
    # Replace all forward slashes in relative include directories
    # to back slashes.
    s/\//\\/g;
    $sysIncludes{$_} = 1;
}


$timestr = localtime(time());
$GenerationStr = "#############################################################\n#Generated on $timestr  Do Not Edit!\n#############################################################\n\n\n";
print FILEHANDLE $GenerationStr;

my $stdafx = "";
my $missingDeps = 0;

foreach my $i (@FullList) {
	my $old_i = $i;
	$i = "$SrcDir\\$i";
	my @DependList;
	my $DependListIter = 0;
	my $NeedTouching = 0;
	my $NeedsHeaderTouching = 0;
	my $NeedsHeaderTouchingFile;
	my $DependsFile;
	my $CurrentFileisRcFile = 0;

	$_ = $i;
	if(/(?i)\.rc$/) {
		$CurrentFileisRcFile = 1;
	}

	if(/\.cpp$/ || /\.c$/) {
		s/\.cpp$/\.obj/g;
		s/(?i)\Q$RootDir//g;
		$_ = "$OutBase$_";

		my $counter = 0;
		$old = $_;
		while() {
			$let = chop;
			if($let eq "\\") {
				last;
			}
			$counter++;
		}
		my $end = substr($old,length($old)-$counter,$counter);
		$_ = "$_/$end";
		$DependList[$DependListIter++] = "$_:";
		$DependList[$DependListIter++] = "$i";
	}
	else {
		my $temp = $_;
		s/\.hpp/\.d/g;
		s/\.H/\.d/g;
		s/\.h/\.d/g;
		s/\.idl/\.d/g;
		s/(?i)\Q$RootDir//g;
		$_ = "$OutBase$_";
		$DependsFile = $_;
		$DependList[$DependListIter++] = "$_:";
		$DependList[$DependListIter++] = "$i";
		$NeedTouching = 1;

		$_ = $temp;
		if(/(?i)\.idl/) {
			my $FullIdl = $_;
			$_ = "$SrcDir/$old_i";
			s/(?i)\Q$RootDir//g;
			my $TempIdlFile = $_;
			s/(?i)\.idl/\.h/g;
			$NeedsHeaderTouchingFile = "$OutBase$_";

			my $TlbFile = $TempIdlFile;
			$TlbFile =~ s/(?i)\.idl/\.tlb/g;
			$TlbFile = $OutBase . $TlbFile;
			my $TempDependFile = $TlbFile;
			$TempDependFile =~ s/\/(.*?)(?i)\.tlb/\\$1\.d/g;

			# transform the IDL to have the / at end..

			# add rules for tlb
			$FullIdl =~ s/\Q$SrcDir//g;
			$FullIdl =~ s/\\//g;
			$FullIdl = $SrcDir . "/" . $FullIdl;
			print FILEHANDLE "$TlbFile: $FullIdl $TempDependFile\n\n";
	
			my $IdlHeader = $TlbFile;
			$IdlHeader =~ s/(?i)\.tlb/\.h/g;
	
		}
	}


	open(GREPFILE,$i);
	if($CurrentFileisRcFile == 0) {
		while(<GREPFILE>) {
		         if ( /^(#import|#include|import)\s+["<]?(\S*?)[\s">]/ ) 
			 {
				$_ = $2;

				# Replace all forward slashes in relative include directories
				# to back slashes.
				s/\//\\/g;

				my $FileName = $_;				

				my $realDependency;

				# to ignore msg file dependencies
				# & !/(?i)mtglobal_msg\.h/ & !/(?i)sdk_msg\.h/

				if(!/""/ &  !/(?i)resource\.h$/ & !/(?i)rw\// & !/(?i)rw\\/ & !/(?i)\.tlb/ & !/(?i)_i\.c/ & !/(?i)\.idl/) {
					my $Found = 0;
					foreach $k (@FindList) {
						my $tempstr = "$k\\$FileName";
						$_ = $tempstr;
						s/\\\\/\\/g;
						if(stat($_)) {
							$realDependency = $_;
							$tempstr = $_;

							if(/(?i)\.h$/ || /(?i)\.hpp$/) {
								if (/StdAfx.h$/i) {
									$stdafx = $_;
#									s/\.h/\.pch/i;
								}
								# Replace dependency on a .{h,H,hpp,HPP} by the .d file.
								s/(?i)\.hpp/\.d/;
								s/(?i)\.h/\.d/;

								s/(?i)\Q$RootDir//g;
								if(!/(?i)\Q$OutBase/) {
									$_ = "$OutBase$_";
								}

								if (/(StdAfx)/i)
								{
									$stdafx = $_;
									$_ = "$OutDir" . "\\$1.pch";
								}

								$tempstr = $_;
							}

							$DependList[$DependListIter++] =  "$tempstr";
							$Found = 1;
							last;
						}
					}

					if($Found == 0) {
						# the _msg files are created with the message compiler so
						# we need special rules
						if ($FileName =~ /_msg.h$/)
						{
							my $tempstr = "$OutBase\\include\\$FileName";
							$DependList[$DependListIter++] =  "$tempstr";
							$Found = 1;
						}
					}

					if($Found == 0) {
						# Ok... header file wasn't found in... it could be derived from a an IDL
						$_ = $FileName;
						s/(?i)\.h/\.idl/g;
						chomp;
						my $TempFileName = $_;

						foreach my $k (@FindList) {
							my $tempstr = "$k/$TempFileName";
							$_ = $tempstr;
							s/\\\\/\\/g;
							$tempstr = $_;

							if(stat($tempstr)) {
								$realDependency = $tempstr;
								s/(?i)\.idl/\.tlb/;
								s/(?i)\Q$RootDir//g;
								my $FullFile = "$OutBase$_";
								$DependList[$DependListIter++] =  "$FullFile";
								last;
							}
						}
					}

					# if still not found it is either a system include or an error
					if($Found == 0) {

					    # is it a known system include?
					    if ($sysIncludes {$FileName})
					    {
						$Found = 1;
					    }
					    else
					    {
						# dependency wasn't found in the include path so fail
						# this is safer than omitting a dependency due to a misconfigured make.inc
						#print "WARNING: Dependency '$FileName' included by '$i' not found in " .
						#    "include path of project '$DirTag'!\n";
						$missingDeps++;
					    }
					}

				}

				elsif(/\.tlb$/ || /_i\.c$/ || /(?i)\.idl/) {
					$_ = $FileName;
					if (/(?i)$MetraTech\..+\.tlb/)
					{
						# this is a TLB generated from a .NET DLL
						$DependList[$DependListIter++] = "$OutBase\\include/$_";
						$realDependency = "$OutBase\\include/$_";
					}
					else
					{
						s/(?i)\.tlb/\.idl/;
						s/(?i)_i\.c/\.idl/;
						s/(?i)\.idl/\.idl/;

						$FileName = $_;

						foreach my $k (@FindList) {
							my $tempstr = "$k/$FileName";
							$_ = $tempstr;
							s/\\\\/\\/g;

							if(stat($_)) {
								$realDependency = $_;
								s/(?i)\Q$RootDir//g;
								s/(?i)\.idl/\.tlb/;
								$DependList[$DependListIter++] =  "$OutBase$_";
								last;
							}
						}
					}
				}

					if ($realDependency)
					{
						print FILEHANDLE "# $i: $realDependency\n";
					}

			}
		}
	}
	else {
		while(<GREPFILE>) {
		if(/^1 TYPELIB/) {
				$TlbFile = $_;
				$TlbFile =~ s/^1 TYPELIB//g;
				$TlbFile =~ s/\"//g;
				$TlbFile =~ s/ //g;
				chomp $TlbFile;

				$IdlFile = $TlbFile;
				$IdlFile =~ s/(?i)\.tlb/\.idl/g;


				foreach my $k (@FindList) {
						my $tempstr = "$k/$IdlFile";
						$_ = $tempstr;
						s/\\\\/\\/g;

						if(stat($_)) {
							$realDependency = $_;
							s/(?i)\Q$RootDir//g;
							s/(?i)\.idl/\.tlb/;
							$_ = $OutBase . $_;
							$RCDependList = "$tempstr $_";
							last;
						}
					}

				print FILEHANDLE "RESTARGET_DEPENDENCIES := $RCDependList\n\n";
				#printf ("TLB dependency: $RCDependList\n");
			}
		}
	}


# We've garnished all the dependencies, now dump them to the file.
#
	print FILEHANDLE "@DependList";
	if($NeedsHeaderTouching) {
		print FILEHANDLE "\n\t\@touch $NeedsHeaderTouchingFile";
	}
	if($NeedTouching) {
		print FILEHANDLE "\n\t\@touch $DependsFile\n";
	}

	close(GREPFILE);
  print FILEHANDLE "\n\n";
}

if ($stdafx)
{
	my $stdafxd = $stdafx;
	$stdafxd =~ s/\.h$/.d/;
	print FILEHANDLE $DirTag . "_PCH_FLAGS := /YuStdAfx.h /Fp$OutDir" . "\\StdAfx.pch\n\n";

	print FILEHANDLE "ifneq (\$(strip \$(MANAGED)),)\n";
	# managed C++
	print FILEHANDLE $OutDir . "\\StdAfx.pch: $stdafx\n";
	print FILEHANDLE "\t\$(CPP)";
	foreach my $k (@FindList)
	{
		print FILEHANDLE " /I $k";
	}
	print FILEHANDLE " /Fo$OutDir\\ /YcStdAfx.h /Fp\$@ \$(MAN_CPP_FLAGS) \$($DirTag" . "_CPP_FLAGS) \$(ROOTDIR)\\build\\stdafx.cpp /Fd$OutDir\\vc100.pdb\n";

	print FILEHANDLE "else\n";

	print FILEHANDLE $DirTag . "_PCH_FLAGS := /YuStdAfx.h /Zm200 /Fp$OutDir" . "\\StdAfx.pch\n\n";

	print FILEHANDLE $OutDir . "\\StdAfx.pch: $stdafx\n";
	print FILEHANDLE "\t\$(CPP)";
	foreach my $k (@FindList)
	{
		print FILEHANDLE " /I $k";
	}
	print FILEHANDLE " /Fo$OutDir\\ /YcStdAfx.h /Fp\$@ \$(CPP_FLAGS) /Zm200 \$($DirTag" . "_CPP_FLAGS) \$(ROOTDIR)\\build\\stdafx.cpp /Fd$OutDir\\vc100.pdb\n";


	print FILEHANDLE "endif\n";
}
close(FILEHANDLE);

#if ($missingDeps > 0)
#{    
#    print "WARNING: $missingDeps dependencies could not be found for project '$DirTag'. This could likely cause build issues!\n";
    # TODO: after initial build warnings are cleaned up this should die
#}


