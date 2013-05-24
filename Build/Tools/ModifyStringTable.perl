
# we need two arguments: the string table  file to read and the output file name

if($#ARGV < 2) {
	print "Usage: $ENV{PROG_NAME} original_file.shl output_file.shl Name\n";
	exit;
}

# step 1: open the original file

open(ORIGFILE,$ARGV[0]) or die "failed to open $ARGV[0]\n";
open(NEWFILE,"> $ARGV[1]") or die "failed to open $ARGV[1]\n";

while(<ORIGFILE>) {
	if(/TITLE_MAIN/) {
		print NEWFILE "TITLE_MAIN=$ARGV[2]\n";
	}
	elsif(/PRODUCT_NAME/) {
		print NEWFILE "PRODUCT_NAME=$ARGV[2]\n";
	}
	else {
		print NEWFILE $_;
	}
}

close(ORIGFILE);
close(NEWFILE);