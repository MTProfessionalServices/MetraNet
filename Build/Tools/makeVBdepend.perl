#!perl

# list of system folders -- we will ignore
# references to files that live in one of these 
my @sys_dirs = (
  "$ENV{SystemRoot}\\system32",
  "$ENV{SystemRoot}\\syswow64",
  "$ENV{SystemRoot}\\system32\\inetsrv",
  "$ENV{SystemDrive}\\Program Files\\Common Files\\System\\ado" # msado15.dll
);

opendir(DIR,$ARGV[0]) or die "failed to open current directory";
@FileNameList = grep {/(?i)\.vbp$/} readdir(DIR);

if($FileNameList[0] eq "") { die "VB project not found\n"; }

$FileName = $ARGV[0] . "\\" . $ARGV[1];

$DebugStr = $ARGV[2];

my $OutDir = $ENV{MTOUTDIR} . "\\" . $DebugStr;

@FindList = ();

for (my $i = 3, my $j = 0; $i < @ARGV; $i++,$j++) {
  $FindList[$j] = $ARGV[$i];
}

$ExeName;

$ShortFileName = substr($FileName,rindex($FileName,"\\")+1);

$RelativePath = $FileName;
$RelativePath =~ s/(?i)\Q$ENV{ROOTDIR}//g;
$RelativePath =~ s/(?i)\Q$ShortFileName//g;
$RelativePath =~ s/^\\//g;

chop $RelativePath;



  open(FILENAME,$FileName) or die "Failed to open $FileName\n";
  @RefList;
  $RefCounter=0;

  while(<FILENAME>) {
    if(/^(?i)Reference/) {
      $_ =~ s/^.*?#//g;
      $_ =~ s/^.*?#//g;
      $_ =~ s/^.*?#//g;
      $_ =~ s/#.*$//g;
      chomp;
      $Shortlen = rindex($_,"\\");
      $forwardLen = rindex($_,"/");
      if ($forwardLen > $Shortlen)
      {
        $Shortlen = $forwardLen;
      }
      $ShortName = substr($_,$Shortlen+1);
      #printf("shortname = $ShortName\n");

      $_ = $fullname;

      # if the file exists in a system folder, ignore it
      my $found = 0;
      foreach (@sys_dirs) {
        if ( stat("$_\\$ShortName") ) {
          $found = 1;
		  #printf("$_\\$ShortName found\n");
          last;
        }
      }
      if ( !$found ) {
        $_ = $ShortName;
        if(/sqldmo.dll/) {
          print "skipping SQLDMO.\n\n";
        }
        else {
          $extension = $_;
          $extension =~ s/^.*?\.//g;
          if( /\.dll$/i ) {
            $RefList[$RefCounter++] = "\$(BINDIR)/$ShortName"; 
          }
          elsif ( /\.tlb$/i ) {
            # we have to go through a couple of extra steps here....
            # if we find an IDL file for the IDL in the include path we can put a dependency on it
          
            if (/(?i)$MetraTech\..+\.tlb/)
            {
              # this is a TLB generated from a .NET DLL
              $RefList[$RefCounter++] = "$OutDir\\include/$_";
            }
            else
            {
              for(my $i=0;$i < @FindList; $i++) {
                $Temp = $FindList[$i];
                $Temp .= "\\";
                $Temp .= $ShortName;
                $Temp =~ s/\.tlb/\.idl/g;

#                print "testing for $Temp\n";

                if(stat($Temp)) {
                  $Temp = $FindList[$i];
                  $Temp .= "/";
                  $Temp .= $ShortName;
                  $Temp =~ s/\Q$ENV{ROOTDIR}//g;
                  $Temp = $ENV{MTOUTDIR} . "\\" . $DebugStr . $Temp;
                  $RefList[$RefCounter++] = "$Temp"; 
                }
              }
            }
          }
        }
      }
    }
    elsif(/^(?i)Form=/) {
      s/^.*?=//g;
      chop;
      $RefList[$RefCounter++] = $ARGV[0] . "\\" . $_;
    }
    elsif(/^(?i)Module=/ || /^(?i)Class=/) {
      # eat everything to the ;
      s/^.*?; //g;
      $_ = $ARGV[0] . "\\" . $_;
      chop;
      $RefList[$RefCounter++] = $_;
    }
    elsif(/^(?i)ExeName32/) {
      s/^.*?\"//g;
      chop; chop;
      $ExeName = $_;

    }
  }
  close FILENAME;

  # find out if we need any extra flags
  $FileName = $ARGV[0] . "/" . "make.inc";
  open (MAKEFILE,$FileName) or die "Failed to open makefile";
  $Flags = "";
  while(<MAKEFILE>) {
    if(/EXTRA_VB_FLAGS/) {
      $_ =~ s/^.*(?i)EXTRA_VB_FLAGS.*?\=//g;
      $Flags = $_;
      chomp $Flags;
    }
  }
  close MAKEFILE;

  if($ExeName eq "") {
    $ExeName = $ShortFileName;
    $ExeName =~ s/(?i)\.vbp/\.exe/g;
  }

  # generate make file

  $timestr = localtime(time());
  $GenerationStr = "############################################################\n#Generated on $timestr\n#############################################################\n\n\n";


  #if($ENV{DEBUG} eq "1") {
  #  $DebugStr = "debug";
  #}
  #else {
  #  $DebugStr = "release";
  #}


  $DependFile = "> $ENV{MTOUTDIR}\\$DebugStr\\$RelativePath\\.depend";
  open(DEPENDFILE,$DependFile) or die "Failed to open $DependFile\n";


  print DEPENDFILE $GenerationStr;

  print DEPENDFILE "\$(BINDIR)/$ExeName: $ARGV[0]\\$FileNameList[0] ";

  for( my $i=0;$i<$RefCounter;$i++) {
    print DEPENDFILE "$RefList[$i] ";
  }

  #-----------------------------------------------------------
  # The following line added 06/12/00 - Used for VB Versioning
  #-----------------------------------------------------------
  print DEPENDFILE "\n\t \@copy $ARGV[0]\\$ShortFileName $ARGV[0]\\$ShortFileName.tmp";
  print DEPENDFILE "\n\t \@perl $ENV{ROOTDIR}\\Build\\Tools\\SetVBVersions.perl $ARGV[0]\\$ShortFileName";

  print DEPENDFILE "\n\t \$(VERIFYREFERENCES) -q $ARGV[0]\\$ShortFileName";
  print DEPENDFILE "\n\t-\$(VB6) /make $ARGV[0]\\$ShortFileName /outdir \$(BINDIR) /out $ENV{ROOTDIR}\\VBBuild.txt $Flags";
  print DEPENDFILE "\n\t \@copy $ARGV[0]\\$ShortFileName.tmp $ARGV[0]\\$ShortFileName";
  print DEPENDFILE "\n\t \@rm $ARGV[0]\\$ShortFileName.tmp";
  print DEPENDFILE "\n\t -\@type $ENV{ROOTDIR}\\VBBuild.txt";
  print DEPENDFILE "\n\t -\@rm $ENV{ROOTDIR}\\VBBuild.txt";



close DEPENDFILE;
