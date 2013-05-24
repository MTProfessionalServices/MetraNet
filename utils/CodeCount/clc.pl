#!/usr/local/bin/perl
#
# clc -- C/C++ line-counter (actually - it counts statements too)
#
# Created 02/14/95 by Brad Appleton
#

$NAME = $0;
if ($NAME =~ m|^.*/([^/]+)$|o) {
   $NAME = $1;  ## get basename of program path
}

$SYNOPSIS = 
   "$NAME [-Help] [-counts SPEC] [-language LANG] [-sections SPEC] [FILE ...]";

$ARGUMENTS = "
   -Help  Print this help message and exit.
   -language LANG
          Assume we are reading LANG source files. LANG must be one
          of the following (the default is C++):
             \"C\", \"C++\", \"perl\"
   -counts SPEC
          Specify which counts/columns to display in the output. SPEC
          may contain any of the following (separated by '+'):
             \"Lines\" : print the total # of lines
             \"NCLOC\" : print the total # of non-comment source lines
             \"Stmts\" : print the total # of source statements
          The above keywords may be abbreviated to a unique prefix if
          desired. If the \"-counts\" option is NOT specified, then
          \"Lines+NCLOC+Stmts\" is implied.  Note that in the output,
          lines will always precede NCLOC, which always precedes stmts.
   -sections SPEC
          Specify the sections in the output. SPEC may contain any
          of the following (separated by '+'):
             \"Header\" : the column labels and separator bar
             \"Files\"  : the counts for each input file
             \"Totals\" : the totals for all files.
          The above keywords may be abbreviated to a unique prefix
          if desired. If the \"-sections\" option is NOT specified,
          then \"Header+Files+Totals\" is implied.
   FILE   Name of an input file.

   Option names are case insensitive and only a unique prefix is required.
";

$DESCRIPTION = "
   $NAME will count the number of lines, non-commented source lines
   (NCLOC), and source statements in the given input files (which
   are assumed to be free of syntax errors).
";

## Global "Constants"
$END_STMT = ';';
($BEGIN_BLOCK, $END_BLOCK) = ("{", "}");
($DQUOTE, $SQUOTE) = ('"', "'");

## Print an error message
sub error_msg {
   local($_) = @_;
   print STDERR "${NAME}: $_";
}

## Print an error message and die
sub fatal_msg {
   local($_) = @_;
   &error_msg($_);
   exit(2);
}

## Print a usage message and die
sub usage {
   local($_) = @_;
   print STDERR "Usage: ${SYNOPSIS}\n${ARGUMENTS}${DESCRIPTION}";
   exit($_);
}

## Match a string against a set of keywords (case insensitive and
## allowing unique prefixes). Return the list of matching elements.
sub kwd_match {
   local($str, @keywords) = @_;
   local($_, @matches);
   $str =~ s/\W/\\$&/g;
   @matches = grep( m/^${str}$/i, @keywords );
   @matches = grep( m/^${str}/i, @keywords ) if ( @matches == 0 );
   @matches;
}
   
## "Default" the language based on the filename and/or the first input line
sub default_lang {
   local($filename, $_) = @_;
   local($lang);
   if ($filename =~ /\.(c|h|cc)$/io) {
      $lang = "C++";
   } elsif ($filename =~ /\.(perl|pl)$/io) {
      $lang = "perl";
   } elsif (m/^\s*#\s*(include|if|ifdef|define)\b/o) {
      $lang = "C++";
   } elsif (m|^\s*/[/*]|o) {
      $lang = "C++";
   } elsif (m|^\s*#\s*\!\s*/\S+/perl\b|o) {
      $lang = "perl";
   } else {
      $lang = "C++";  ## the last resort!
   }
   $lang;
}

## Validate -language option
sub validate_lang {
   local($lang) = @_;
   local($_);
   local(@matches) = &kwd_match($lang, "C", "C++", "perl");
   if (@matches == 1) {
      $LANG = $matches[0];
      ++$Cmts{$LANG};
      ++$Cmts{"C"} if ($LANG eq "C++");
   } elsif (@matches == 0) {
      &error_msg("invalid language specifier \"$lang\"\n");
      ++$errors;
   } else {
      &error_msg("ambiguous language specifier \"$lang\"\n");
      ++$errors;
   }
}

## Validate -sections option
sub validate_sections {
   local($sections) = @_;
   local($_);
   local(@secspecs) = split(/\W/, $opt_sections);
   if (0 == @secspecs) {
      &error_msg("invalid sections specifier \"$opt_sections\"\n");
      ++$errors;
   } else {
      local(@matches) = ();
      for (@secspecs) {
         @matches = &kwd_match($_, "header", "files", "totals");
         if (@matches == 1) {
            eval "++\$opt_$matches[0]";
         } elsif (@matches == 0) {
            &error_msg("invalid sections specifier \"$_\"\n");
            ++$errors;
         } else {
            &error_msg("ambiguous sections specifier \"$_\"\n");
            ++$errors;
         }
      }
   }
}

## Validate -counts option
sub validate_counts {
   local($counts) = @_;
   local($_);
   local(@cntspecs) = split(/\W/, $opt_counts);
   if (0 == @cntspecs) {
      &error_msg("invalid counts specifier \"$opt_counts\"\n");
      ++$errors;
   } else {
      local(@matches) = ();
      for (@cntspecs) {
         @matches = &kwd_match($_, "lines", "ncloc", "stmts");
         if (@matches == 1) {
            eval "++\$opt_$matches[0]";
         } elsif (@matches == 0) {
            &error_msg("invalid counts specifier \"$_\"\n");
            ++$errors;
         } else {
            &error_msg("ambiguous counts specifier \"$_\"\n");
            ++$errors;
         }
      }
   }
}

## clc -- count the lines/ nc-loc, and statements in the given file
##        (a filename of '-' means use STDIN).
##
## returns the array (#lines, #nc-loc, #stmts).
## If the file can't be opened, then returns (-1, -1, -1)
##
sub clc {
   local($filename) = @_;
   local($filehandle);
   local($language) = $opt_language;
   local($_);
   local($LineCount, $NonCmtLineCount, $StmtCount, $BlockCount);
   local($BlockLevel, $InComment, $InQuote);
   local($Style, $ContinuedQuote);
   local($isNonCmtLine, $isPpDirective, $lineStmts);

   ## Initialize
   $LineCount = $NonCmtLineCount = $StmtCount = $BlockCount = 0;
   $BlockLevel = $InComment = $InQuote = 0;

   ## Open input
   if ($filename eq "-") {
      $filehandle = STDIN;
   } else {
      $filehandle = INPUT;
      unless (open(INPUT, $filename)) {
         &error_msg("Can't open $filename for reading: $!\n");
         return (-1, -1, -1);
      }
   }
      
   ## Loop over input lines
   ##
   ##   Note: If I actually look at every character on a line, it takes
   ##   far too much time, so what I instead do is remove all "uninteresting"
   ##   characters from a line (like alphanumerics) before I iterate over
   ##   each of its characters. This proved to be a tremendous speed-up.
   ##
   while (<$filehandle>) {
      ++$LineCount;

      ## See if we need to "figure out" the language
      if (! $language) {
         $language = &default_lang($filename, $_);
         &validate_lang($language);
      }

      if ($Cmts{"C"}) {
         ## try not to get confused by "uninteresting" stuff between
         ## a '*' and a '/', or a '/' and a '*'
         s|/([\\\w\t ]+)\*|/\~$2\~$3*|go;
         s|\*([\\\w\t ]+)/|*\~$2\~$3/|go;
      }

      ## remove anything "uninteresting"
      s/\\.//go;       ## escaped characters
      s/\s+//go;       ## whitespace
      s/\w+/A/go;      ## alphanumerics (compressed to a single letter)

      ## watchout for some special perl constructs
      s/\$#//go if ($Cmts{"perl"});

      ## skip blank lines
      next if (m/^\s*$/o);

      ## Have to figure out (eventually) whether to include this line
      ## in our count of non-comment source-lines.
      $isNonCmtLine = 0;

      ## Keep track of number of statements on this line
      $lineStmts = 0;

      ## See if this is a preprocessor directive
      $isPpDirective = ( /^\s*#/o ? 1 : 0 );

      @str = split ("");   ## split on empty string to get a character array
      for ($i = 0; $i <= $#str ; $i++) {
         if ($InComment) {
            if (($Style eq "C") && ($str[$i] eq "*") && ($str[$i+1] eq "/")) {
               ++$i;
               $InComment = 0;
               $Style = "";
            }
         } elsif ($InQuote) {
            ++$isNonCmtLine;
            $ContinuedQuote = 0;
            if (($str[$i] eq "\\") && ($str[$i+1] eq "\n")) {
               $ContinuedQuote = 1 if ($Style eq $DQUOTE);            
               last;
            } elsif ($str[$i] eq $Style) {
               $InQuote = 0;
               $Style = "";
            }
         } else {
            if ($Cmts{"C++"} && ($str[$i] eq "/") && ($str[$i+1] eq "/")) {
               last;
            } elsif ($Cmts{"perl"} && ($str[$i] eq "#")) {
               last;
            } elsif ($Cmts{"C"} && ($str[$i] eq "/") && ($str[$i+1] eq "*")) {
               ++$InComment;
               ++$i;
               $Style = "C";
            } else {
               ++$isNonCmtLine unless ($str[$i] =~ /\s/o);
               if ($str[$i] eq $DQUOTE) {
                  ++$InQuote;
                  $Style = $DQUOTE
               } elsif ($str[$i] eq $SQUOTE) {
                  ++$InQuote;
                  $Style = $SQUOTE
               } elsif ($str[$i] eq $BEGIN_BLOCK) {
                  ++$BlockLevel;
               } elsif ($str[$i] eq $END_BLOCK) {
                  --$BlockLevel;
                  ++$BlockCount;
               } elsif ($str[$i] eq $END_STMT) {
                  ++$lineStmts;
               }
            }
         }
      }

      ## Now add up what we found
      ++$NonCmtLineCount if ($isNonCmtLine || $isPpDirective);
      if ($lineStmts) {
         $StmtCount += $lineStmts;
      } else {
         ++$StmtCount if ($isPpDirective);
      }
   }
   close($filehandle) unless ($filename eq '-');

   ## Lets say that each block represents another (compound) statement
   $StmtCount += $BlockCount;

   ($LineCount, $NonCmtLineCount, $StmtCount);
}

## print a report line or header. We know it is a header if
## the first argument is a string and not a number.
sub report_line {
   local($lines, $ncloc, $stmts, $fname) = @_;
   local($_, $fwidth, $nums);
   local($ll) = 78;
   local($nwidth) = 8;
   local($ntype, $nfmt);
   if ($lines =~ /^\d+$/o) {
      $ntype = 'd';
      $nfmt = "%${nwidth}${ntype}  ";
   } else {
      $ntype = 's';
      $nfmt = "%-${nwidth}${ntype}  ";
   }
   $fwidth = $ll;
   for ("lines", "ncloc", "stmts") {
      local($set) = eval "\$opt_$_";
      next unless ($set);
      local($val) = eval "\$$_";
      printf($nfmt, $val);
      $fwidth -= ($nwidth + 2);
      ++$nums;
   }
   print "${fname}\n";
   if ($ntype eq 's') {
      ## need to print a header-bar
      local($nbar) = '-' x $nwidth;
      local($fbar) = '-' x $fwidth;
      local($i);
      for ($i = 0; $i < $nums; $i++) {
         printf($nfmt, $nbar);
      }
      print "${fbar}\n";
   }
}

## Parse options
$opt_sections="header+files+totals"; ## default
$opt_counts="lines+ncloc+stmts"; ## default
require "newgetopt.pl";
$rc = &NGetOpt("help", "counts=s", "sections=s", "language=s");
&usage(1) if ($opt_help);
&usage(2) unless ($rc);

## Check for syntax errors
&validate_lang($opt_language) if ($opt_language);
&validate_sections($opt_sections) if ($opt_sections);
&validate_counts($opt_counts) if ($opt_counts);
&usage(2) if ($errors);

@ARGV = ('-') if (0 == @ARGV);
foreach (@ARGV) {
   ($Lines, $NCLines, $Stmts) = &clc($_);
   next if ($Lines < 0);
   unless ((++$numFiles > 1) || (! $opt_header)) {
      &report_line("  Lines", "  NCLOC", "  Stmts", "Filename");
   }
   $TotalLines   += $Lines;
   $TotalNCLines += $NCLines;
   $TotalStmts   += $Stmts;
   &report_line($Lines, $NCLines, $Stmts, $_) if ($opt_files);
}
&report_line($TotalLines, $TotalNCLines, $TotalStmts, "===total===")
   if ($opt_totals && ((! $opt_files) || ($numFiles > 1)));
#
