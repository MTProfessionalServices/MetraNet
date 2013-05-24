
use Win32::API;
use Win32;
use Win32::OLE;

sub RegisterDLL($)
{
	my ($dll) = @_;
	my $register = new Win32::API($dll, "DllRegisterServer", [], I);
	if (not $register)
	{
		return 1;										# could not load DLL or entry point not found
	}
	my $result = $register->Call();
	if ($result != 0)
	{
		return 2;										# DLLRegisterServer failed
	}

	return 0;
}

Win32::OLE->Initialize();

opendir(DIR_HANDLE, ".") || die "can't opendir: $!";

ENTRY: foreach (readdir(DIR_HANDLE))
{
	next ENTRY if ($_ eq "." || $_ eq "..");

	if (/\.dll$/)
	{

		my $result = RegisterDLL($_);
		if ($result == 0)
		{
			print "$_ registered\n";
		}
		elsif ($result == 1)
		{
			#print "$_ not a COM object.\n";
		}
		elsif ($result == 2)
		{
			print "$_: FAILED TO REGISTER.\n";
		}
		else
		{
			print "$_: UNKNOWN ERROR.\n";
		}

#		my $result = Win32::RegisterServer($_);
#		if (not $result)
#		{
#			print "...can't register ($result) $!\n";
#		}
#		else
#		{
#			print ".\n";
#		}
	}
}

closedir(DIR_HANDLE);

Win32::OLE->Uninitialize();
