
# we need two arguments: the IPR file to read and the output file name

if($#ARGV < 3) {
	print "Usage: $ENV{PROG_NAME} original_file.mda output_file.mda GUID Name\n";
	exit;
}

# step 1: open the original file

open(ORIGFILE,$ARGV[0]) or die "failed to open $ARGV[0]\n";
open(NEWFILE,"> $ARGV[1]") or die "failed to open $ARGV[1]\n";

while(<ORIGFILE>) {
	if(/APPLICATIONNAME/) {
		print NEWFILE "APPLICATIONNAME=$ARGV[3]\n";
	}
	elsif(/GUID/) {
		print NEWFILE "GUID=$ARGV[2]\n";
	}
	else {
		print NEWFILE $_;
	}
}

close(ORIGFILE);
close(NEWFILE);