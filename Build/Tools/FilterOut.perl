
my $ROOTDIR=$ENV{ROOTDIR};
my $OUTDIR=$ENV{MTOUTDIR};

my $OutputLevel = 10;
my $html = 0;

sub CleanFilename
{
	my $filename = shift(@_);

	# forward to back
	$filename =~ s/\//\\/g;
	# double back to single back
	$filename =~ s/\\\\/\\/g;

	$filename =~ s/\Q$ROOTDIR\E[\/\\]//;
	$filename =~ s/\Q$OUTDIR\E[\/\\]//;
	$filename;
}

format STDOUT =
@<<<<<<<<<< ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$lefttag, $righttext
~~          ^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$righttext
.

sub GenOutput
{
	($level, $lefttag, $righttext) = @_;
    
	if (($OutputLevel < 0 && $level == -$OutputLevel)
			|| ($level <= $OutputLevel))
	{
		if ($html)
		{
	    print("<tr><td>$lefttag</td>\n<td>$righttext</td></tr>\n");
		}
		else
		{
	    write (STDOUT);
		}
	}
}

sub ProcessCommand
{
	my $command = shift(@_);
	my $iserror = 0;

	if ($command =~ /^cl .*[ \t]+(.+\.cpp)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "Compiling", $filename);
	}
	elsif ($command =~ /^csc.*[ \t]+(.+\*\.cs)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "C#", $filename);
	}
	elsif ($command =~ /^link .*\/out:(\S+)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "Linking", $filename);
	}
	elsif ($command =~ /^midl .*[ \t]+(.+\.idl)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "midl", $filename);
	}
	elsif ($command =~ /^rc .*[ \t]+(.+\.rc)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "Resource", $filename);
	}
	elsif ($command =~ /^make: (.+)/)
	{
		my $makeLine = $1;
		if (!($makeLine =~ /\(ignored\)/))
		{
	    if ($makeLine =~ /^\*\*\*/)
	    {
				GenOutput(0, "MAKE", $makeLine);
	    }
	    else
	    {
				GenOutput(2, "Make", $makeLine);
	    }
		}
	}
	elsif ($command =~ /^Compile Error in File \'(.+)\', Line ([\d]+)\s*: (.*)/)
	{
		my ($file, $line, $string) = ($1, $2, $3);
		$file = CleanFilename($file);
		GenOutput(0, "VB ERROR", "$file ($line): $string");
	}
	elsif ($command =~ /^Build of \'(.+)\' failed./)
	{
		$file = CleanFilename($1);
		GenOutput(0, "VB ERROR", "Build of $file failed.");
	}
	elsif ($command =~ /^INVALID VB REFERENCE: \'(.+)\': (.*)/)
	{
		my ($string) = ($2);
		$file = CleanFilename($1);
		GenOutput(0, "BAD VB REF", "$file: $string");
	}
	elsif ($command =~ /^(.*)(\((\d+)\))? : (warning|error|fatal error) ([^:]+): (.*)/)
	{
		my $ignore = 0;
		my ($source, $line, $typelcase, $code, $string) = ($1, $3, $4, $5, $6);

		#print "WARNINGSource  $source\n";
		#print "WARNINGLine    $line\n";
		#print "WARNINGTypelcase  $typelcase\n";
		#print "WARNINGCode  $code\n";
		#print "WARNINGString  $string\n";


		my $type;
		my $errorLevel;
		if ($typelcase =~ /fatal error/)
		{
	    $type = "FATAL";
	    $errorLevel = 0;
		}
		elsif ($typelcase =~ /error/)
		{
	    $type = "ERROR";
	    $errorLevel = 0;
		}
		else
		{
	    $type = "WARNING";
	    $errorLevel = 1;
		}

		$source = CleanFilename($source);

		if ($line)
		{
			$source .= "$source ($line)";
		}

		if ($string =~ /directive in .EXP differs from output filename/)
		{
	    $ignore = 1;
		}
		elsif ($string =~ /base key \".*\" not found - using default/)
		{
	    $ignore = 1;
		}
		elsif ($string =~ /locally defined symbol \"\"(.*)\".*\" imported/)
		{
	    GenOutput(1, $type, "localling defined symbol $1 imported");
	    $ignore = 1;
		}

		if (!$ignore)
		{
	    GenOutput($errorLevel, $type, "$source $code: $string");
	    #print "WARNINGSource  $source\n";
	    #print "WARNINGCode    $code\n";
	    #print "WARNINGString  $string\n";
		}
	}
	elsif ($command =~ /^(.*)\((\d+),(\d+)\): (error|warning) (......): (.+)/)
	{
		my $ignore = 0;
		my ($source, $line, $column, $typelcase, $code, $string) = ($1, $2, $3, $4, $5, $6);

#		print "WARNINGSource  $source\n";
#		print "WARNINGLine    $line\n";
#		print "WARNINGColumn    $column\n";
#		print "WARNINGTypelcase  $typelcase\n";
#		print "WARNINGCode  $code\n";
#		print "WARNINGString  $string\n";

		my $type;
		my $errorLevel;
		if ($typelcase =~ /fatal error/)
		{
	    $type = "FATAL";
	    $errorLevel = 0;
		}
		elsif ($typelcase =~ /error/)
		{
	    $type = "ERROR";
	    $errorLevel = 0;
		}
		else
		{
	    $type = "WARNING";
	    $errorLevel = 1;
		}

		$source = CleanFilename($source);

		if ($line)
		{
			$source .= " ($line)";
		}

		my $ignore = 0;
		if (!$ignore)
		{
	    GenOutput($errorLevel, $type, "$source $code: $string");
	    #print "WARNINGSource  $source\n";
	    #print "WARNINGCode    $code\n";
	    #print "WARNINGString  $string\n";
		}
	}
	elsif ($command =~ /^(error|warning|fatal error) (......): (.+)/)
	{
		my $ignore = 0;
		my $source = "";
		my $line = "";
		my $column = "";
		my ($typelcase, $code, $string) = ($1, $2, $3);

#		print "WARNINGSource  $source\n";
#		print "WARNINGLine    $line\n";
#		print "WARNINGColumn    $column\n";
#		print "WARNINGTypelcase  $typelcase\n";
#		print "WARNINGCode  $code\n";
#		print "WARNINGString  $string\n";

		my $type;
		my $errorLevel;
		if ($typelcase =~ /fatal error/)
		{
	    $type = "FATAL";
	    $errorLevel = 0;
		}
		elsif ($typelcase =~ /error/)
		{
	    $type = "ERROR";
	    $errorLevel = 0;
		}
		else
		{
	    $type = "WARNING";
	    $errorLevel = 1;
		}

		$source = CleanFilename($source);

		if ($line)
		{
			$source .= " ($line)";
		}

		my $ignore = 0;
		if (!$ignore)
		{
	    GenOutput($errorLevel, $type, "$source $code: $string");
	    #print "WARNINGSource  $source\n";
	    #print "WARNINGCode    $code\n";
	    #print "WARNINGString  $string\n";
		}
	}

	elsif ($command =~ /^regsvr32 .*\s(.*\.dll)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "Registering", $filename);
	}
	elsif ($command =~ /^vb6 .*\s(.*\.vbp)/)
	{
		my $filename = CleanFilename($1);
		GenOutput(2, "VB", $filename);
	}
	elsif ($command =~ /^CheckAsm \[(.+)\]: (.+)/)
	{
		my ($filename, $string) = ($1, $2);
		$file = CleanFilename($filename);
		GenOutput(1, "CHECKASM", "$file: $string");
	}
	else
	{
		#GenOutput("???", $command);
	}

#    print "=== command: $command\n";

}

if ($#ARGV >= 0)
{
	$OutputLevel = $ARGV[0];
}

if ($#ARGV >= 1)
{
	$html = 1;
}

my $currentcommand = "";
while (<STDIN>)
{
	my $newcommand = 0;


	if (/^ +Creating/)
	{
		$newcommand = 1;
	}
	elsif (/^\s+/)
	{
		$newcommand = 0;
	}
	else
	{
		$newcommand = 1;
	}

	if ($newcommand)
	{
		chomp($_);
		ProcessCommand($currentcommand);
		$currentcommand = $_;
	}
	else
	{
		# append to the current command text
		chomp($_);
		$currentcommand .= " ";
		$currentcommand .= $_;
	}
}

# process the last command being built up in the buffer
ProcessCommand($currentcommand);

