
# we need two arguments: the IPR file to read and the output file name

if($#ARGV < 2) {
	print "Usage: $ENV{PROG_NAME} original_file.ini output_file.ini Name\n";
	exit;
}

# step 1: open the original file

open(ORIGFILE,$ARGV[0]) or die "failed to open $ARGV[0]\n";
open(NEWFILE,"> $ARGV[1]") or die "failed to open $ARGV[1]\n";

while(<ORIGFILE>) {
	if(/AppName/) {
		print NEWFILE "AppName=$ARGV[2]\n";
	}
	else {
		print NEWFILE $_;
	}
}

close(ORIGFILE);
close(NEWFILE);