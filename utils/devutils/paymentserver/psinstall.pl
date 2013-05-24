#
# install the payment server tables
#

use strict;
use Win32::TieRegistry;
$Win32::TieRegistry::Registry->Delimiter("/");
my $extensionDir = $Win32::TieRegistry::Registry->{"LMachine/SOFTWARE/MetraTech/Install//InstallDir"} . "/extensions";

system("installutiltest.exe -InstExtDbTables $extensionDir\\paymentsvr\\config\\PaymentServer_dbinstall Payment_install.xml");

