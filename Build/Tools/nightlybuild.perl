use OLE;

my $fortune = `fortune`;
#$fortune =~ s/ /&nbsp\;/g;
$fortune =~ s/\n/<br>/g;

my $mailer = CreateObject OLE "CDONTS.NewMail" || die "Createoject: $!";

my $body = "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML//EN\">";
$body .= "<html><body>";

$results = `perl e:\\dev\\development\\build\\tools\\filterout.perl 0 1 < d:\\scratch\\build.log`;

$body .= "<style> TD { background:#EEEEE6; color:midnightblue; font-family : Arial;";
$body .= "  font-size : 8pt;}";
$body .= "TH {background:#2F4F4F; color:#FFFFFF;font-family:Arial;font-size:8pt;}";
$body .= "</STYLE>";


$body .= "<TABLE BORDER=\"0\" CELLSPACING=\"1\" CELLPADDING=\"4\" bgcolor=\"Black\">";
$body .= "<TR><TH>  Type</TH><TH>Message</TH></TR>\n";

$body .= $results;

$body .= "</body></html>";

$body .= "</table>\n";

$body .= "<i><font size=-1>$fortune</font></i>";
#print $results;
$mailer->{BodyFormat} = 0;
$mailer->{Body} = $body;
$mailer->{MailFormat} = 0;
$mailer->Send("dyoung\@metratech.com", "dyoung\@metratech.com","Testing");
