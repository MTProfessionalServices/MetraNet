
#define WINNT
#include <metra.h>
#include <stdlib.h>
#include <domainname.h>


BOOL GetNTDomainName(std::wstring& aStr)
{
	const wchar_t * name = _wgetenv(L"USERDOMAIN");
	if (!name)
		return FALSE;

	aStr = name;
	return TRUE;
}
