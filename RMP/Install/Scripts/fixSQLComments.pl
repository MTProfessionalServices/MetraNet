#!perl -w
use strict;
use File::Find;

my $dir = (shift or ".");

my $count = 0;

find (\&replaceText, $dir);

print "\n$count file(s) modified\n";

exit;

sub replaceText
{
  return unless /\.xml$/;
	
  my $file_name = $_;
  my $file_path = $File::Find::name;
	# we are already CD'ed to the directory

  open IN, $file_name or die "Unable to open $file_path for reading";
  my @lines = <IN> or die "Error reading from $file_path";
  close IN;

  my $matches = 0;
	my $i = 0;

  my $in_query_tag = 0;
  foreach (@lines) {
	  if ( /\<query_string\>/i ) {
		  $in_query_tag = 1;
    }
    if ( $in_query_tag and !/\/\*.*\*\// ) {
			my ($code, $comment);
		  if ( /^--(.*)$/ ) {  # special case for leading comment
				$code    = "";
			  $comment = $1;
      } elsif ( /^(.*?[^<!\-])-- ?([^>].*|)$/i ) {
		    $code    = $1;
		    $comment = $2;
      }
			if ( defined $comment ) {
		    chomp $comment;
		    chomp $code;
		    $lines[$i] = "$code/* $comment */\n";
		    $matches++;
		  }
		}
	  if ( /\<\/query_string\>/i ) {
		  $in_query_tag = 0;
    }
    $i++;
  }

	if ( $matches > 0 ) {
    print "$file_path: $matches line(s) modified\n";

    open OUT, ">$file_name" or die "Unable to open $file_path for writing";
	  foreach (@lines) {
	    print OUT $_; 
    }
    close OUT;
		$count++;
	}
}
