
my $ROOTDIR=$ENV{ROOTDIR};
my $OUTDIR=$ENV{MTOUTDIR};
my $COMPUTERNAME=$ENV{COMPUTERNAME};

use OLE;

sub StatusRow
{
    my ($desc, $stat) = @_;

    my $class;
    if ($stat =~ /FAILED/) {
      print "failed: $stat\n";
      $class = "clsFailure";
    }
    else {
      $class = "clsSuccess";
    }

    "<tr><td>$desc</td><td class=$class>$stat</td></tr>\n";
}

################################################################################
# message header
################################################################################


my $body = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML//EN\">";
$body .= "<html><body>";

$body .= "<style> TD { background:#EEEEE6; color:midnightblue; font-family : Arial;";
$body .= "  font-size : 8pt;}";
$body .= "TH {background:#2F4F4F; color:#FFFFFF;font-family:Arial;font-size:8pt;}";
$body .= ".clsSuccess {background:green; color:#FFFFFF;font-family:Arial;font-size:8pt;}";
$body .= ".clsFailure {background:red; color:#FFFFFF;font-family:Arial;font-size:8pt;}";
$body .= "</STYLE>";

################################################################################
# build status
################################################################################

my $failure = 0;  # set to true if we detect any failures
my $urlBase = "";
my $debugStatus = "";
my $releaseStatus = "";
my $debugttStatus = "";
my $releasettStatus = "";
my $debugtcStatus = "";
my $releasetcStatus = "";
my $installDebugStatus = "";
my $installReleaseStatus = "";
my $copyStatus = "";
my $destBase = "";

open(SUMMARYFILE,"$ROOTDIR\\..\\summary.log");
while(<SUMMARYFILE>)
{
    if (/^Debug OK/) {
      $debugStatus = "OK";
    }
    elsif (/^Debug FAILED!/) {
      $debugStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Debug TrueTime OK/) {
      $debugttStatus = "OK";
    }
    elsif (/^Debug TrueTime FAILED!/) {
      $debugttStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Release TrueTime OK/) {
      $releasettStatus = "OK";
    }
    elsif (/^Release TrueTime FAILED!/) {
      $releasettStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Debug TrueCoverage OK/) {
      $debugtcStatus = "OK";
    }
    elsif (/^Debug TrueCoverage FAILED!/) {
      $debugtcStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Release TrueCoverage OK/) {
      $releasetcStatus = "OK";
    }
    elsif (/^Release TrueCoverage FAILED!/) {
      $releasetcStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Release FAILED!/) {
      $releaseStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Release OK./) {
      $releaseStatus = "OK";
    }
    elsif (/^Release Install OK./) {
      $installReleaseStatus = "OK";
    }
    elsif (/^Release Install FAILED!/) {
      $installReleaseStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Debug Install FAILED!/) {
      $installDebugStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Debug Install OK./) {
      $installDebugStatus = "OK";
    }
    elsif (/^Copy FAILED!/) {
      $copyStatus = "FAILED";
      $failure = 1;
    }
    elsif (/^Copy OK./) {
      $copyStatus = "OK";
    }
    elsif (/^Click here: (http.+) for details/) {
      $urlBase = $1;
    }
    elsif (/^Copying current build from: .+ to: (\\\\.+)$/) {
      $destBase = $1;
    }
}

$body .= "<TABLE BORDER=\"0\" CELLSPACING=\"1\" CELLPADDING=\"4\" bgcolor=\"Black\">";


# first debug status
if ($debugStatus) {
    $body .= StatusRow("Debug build", $debugStatus);
}
if ($installDebugStatus) {
    $body .= StatusRow("Debug install", $installDebugStatus);
}

# now release
if ($releaseStatus) {
    $body .= StatusRow("Release build", $releaseStatus);
}
if ($installReleaseStatus) {
    $body .= StatusRow("Release install", $installReleaseStatus);
}

# now debug truetime
if ($debugttStatus) {
    $body .= StatusRow("Debug TrueTime build", $debugttStatus);
}

# now release truetime
if ($releasettStatus) {
    $body .= StatusRow("Release TrueTime build", $releasettStatus);
}

# now debug truecoverage
if ($debugtcStatus) {
    $body .= StatusRow("Debug TrueCoverage build", $debugtcStatus);
}

# now release truecoverage
if ($releasetcStatus) {
    $body .= StatusRow("Release TrueCoverage build", $releasetcStatus);
}


# now copy status
if ($copyStatus) {
    $body .= StatusRow("Copy", $copyStatus);
}

$body .= "</table>\n";
$body .= "<br>\n";

if ($urlBase)
{
    $body .= "<a href=\"$urlBase/Build.log\">Full build log</a><br>\n";
    $body .= "<a href=\"$urlBase/Summary.log\">Summary log</a><br>\n";
}
if ($destBase)
{
    $body .= "<a href=\"$destBase\">Build copied here</a><br>\n";
}
$body .= "<p>\n";

################################################################################
# build error summary
################################################################################

$results = `perl $ROOTDIR\\build\\tools\\filterout.perl 0 1 < $ROOTDIR\\..\\build.log`;

if ($results)
{
    $body .= "<TABLE BORDER=\"0\" CELLSPACING=\"1\" CELLPADDING=\"4\" bgcolor=\"Black\">";
    $body .= "<TR><TH>  Type</TH><TH>Message</TH></TR>\n";

    $body .= $results;

    $body .= "</body></html>";

    $body .= "</table>\n";
}

################################################################################
# check case information
################################################################################

my $chkcasefile ="$OUTDIR\\checkcase.txt"; 
if ( -r $chkcasefile ) {
  open(CHKCASEFILE,$chkcasefile);
  while(<CHKCASEFILE>) {
    $body .= $_;
  }
}

################################################################################
# mail message
################################################################################

my $subject;
if ($failure) {
    $subject = "Build FAILED: V3.5 $COMPUTERNAME";
}
else
{
    $subject = "Build successful: V3.5 $COMPUTERNAME";
}

my $mailer = CreateObject OLE "CDONTS.NewMail" || die "Createoject: $!";

#print $results;
$mailer->{BodyFormat} = 0;
$mailer->{Body} = $body;
$mailer->{MailFormat} = 0;
$mailer->{Subject} = $subject;
$mailer->{To} = "builds\@metratech.com";
$mailer->{From} = "builds\@metratech.com";

$mailer->Send();

exit;
