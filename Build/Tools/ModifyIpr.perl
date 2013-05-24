
# we need two arguments: the IPR file to read and the output file name

if($#ARGV < 3) {
	print "Usage: $ENV{PROG_NAME} original_file.ipr output_file.ipr GUID Name\n";
	exit;
}

# step 1: open the original file

open(ORIGFILE,$ARGV[0]) or die "failed to open $ARGV[0]\n";
open(NEWFILE,"> $ARGV[1]") or die "failed to open $ARGV[1]\n";

while(<ORIGFILE>) {
	if(/INSTALLATIONGUID/) {
		print NEWFILE "INSTALLATIONGUID=$ARGV[2]\n";
	}
	elsif(/PRODUCTNAME/) {
		print NEWFILE "PRODUCTNAME=$ARGV[3]\n";
	}
	else {
		print NEWFILE $_;
	}
}

close(ORIGFILE);
close(NEWFILE);