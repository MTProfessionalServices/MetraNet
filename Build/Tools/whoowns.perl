
my $ROOTDIR=$ENV{ROOTDIR};
my $OUTDIR=$ENV{MTOUTDIR};

if ($#ARGV >= 0)
{
    $fullpath = $ARGV[0];
}
else
{
    die "filename must be specified as command line argument";
}

#print "full path: $fullpath\n";

my $file = $fullpath;
# todo: this is case sensitive
$file =~ s/\Q$ROOTDIR\E[\/\\]//;

#print "file: $file\n";

$file =~ /(.*)\\(.+)/;
my $base = $1;
my $extension = $2;

# back to forward slashes
$base =~ s/\\/\//g;

#print "base: $base\n";
#print "extension: $extension\n";

my $commandline = "stcmd.exe";
$commandline .= " hist -p \"dyoung:password\@Oblivion:1024/Metratech/Development/";
$commandline .= "$base\" ";
$commandline .= $extension;

#print "command: $commandline\n";

my $out = `$commandline`;

#print "=============================";
#print "$out";

$out =~ /Revision: ([0-9]+)/;
my $revision = $1;
$out =~ /Author: (.*) Date: (.*)/;
my $author = $1;
my $date = $2;

print "revision: $revision\n";
print "author: $author\n";
print "date: $date\n";

#my $before = $revision - 1;
#print "before: $before";

#$commandline = "stcmd.exe";
#$commandline .= " diff -p \"dyoung:password\@Oblivion:1024/Metratech/Development/";
#$commandline .= "$base\" ";
#$commandline .= "/vn $before $extension";

#my $diff = `$commandline`;
#printf $diff;
#stcmd diff /p "JMarsh:password@Orion:1024/StarDraw/StarDraw/SourceCode" /w /vl "Beta1" /vl "Beta2" *.cpp
