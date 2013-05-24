
# convert an untyped autosdk file to a typed autosdk file.  This conversion
# isn't perfect but it's a good first step.

my $autosdk = "";
while (<>)
{
    # integer
    s/<([^>]+)>(\d+)<\/\1>/<$1 ptype=\"INTEGER\">$2<\/$1>/;

    # datetime
    s/<([^>]+)>(\d+-\d+-\d+T\d+:\d+:\d+Z)<\/\1>/<$1 ptype=\"DATETIME\">$2<\/$1>/;

    # floating
    s/<([^>]+)>(.*\d+.*e.*\d+)<\/\1>/<$1 ptype=\"DOUBLE\">$2<\/$1>/;

    # boolean
    s/<([^>]+)>(TRUE|FALSE)<\/\1>/<$1 ptype=\"BOOLEAN\">$2<\/$1>/i;
    print;
}
