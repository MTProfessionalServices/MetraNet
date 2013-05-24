
my $msix = "";
while (<>)
{
    chomp();
    $msix .= $_;
}

$_ = $msix;

# convert header
s/<msix>.*<beginsession>\s*<dn>([^<]+)<\/dn>.*<properties>/<xmlconfig>\n  <session>\n    <ServiceName>$1<\/ServiceName>\n    <inputs>\n/;

# convert dn/value section to autosdk format
s/<property>\s*<dn>([^<]*)<\/dn>\s*<value>([^<]*)<\/value>\s*<\/property>/<$1>$2<\/$1>\n/g;

# convert footer
s/<\/properties>.*$/    <\/inputs>\n  <\/session>\n<\/xmlconfig>/;

print;
