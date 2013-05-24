
#include <tchar.h>
#include <comdef.h>
#include <malloc.h>
#include <crtdbg.h>
#include <string>


void testBug2();

unsigned char& MyRefcnt(const wchar_t *_U)
{
	return (((unsigned char *)_U)[-1]); 
}


void 
main (int argc, char* argv[])
{
	testBug2();
}


void
testBug2()
{


	std::wstring* str2;
	std::wstring* str3;

	// Note that the relative sizes of foo and bar are important.
	// It appears that the bug occurs on the re-use of the memory
	// used to hold the contents of str2. If foo and bar are the same
	// size or bar is smaller than foo, the bug does not manifest itself.
	const wchar_t *foo = L"(GMT+04:30) Kabul";
	const wchar_t *bar = L"(GMT+04:30) Kabullllllllllllloooooojjjjjjjjjjjjjjjjjjjjjjjjjjjjj)";

	str3 = new std::wstring;
	str2 = new std::wstring;

	//
	int tmpFlag = _CrtSetDbgFlag( _CRTDBG_REPORT_FLAG );
	tmpFlag |= _CRTDBG_CHECK_ALWAYS_DF;
	tmpFlag |= _CRTDBG_DELAY_FREE_MEM_DF;
	_CrtSetDbgFlag(tmpFlag);

	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("STR3: Ptr = %x, Reference count = %d\r\n", str3->c_str(), MyRefcnt(str3->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	printf("****************************\r\n");

	*str2 = bar;

	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("STR3: Ptr = %x, Reference count = %d\r\n", str3->c_str(), MyRefcnt(str3->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	// Hi There....
	printf("****************************\r\n");


	*str3 = *str2;

	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("STR3: Ptr = %x, Reference count = %d\r\n", str3->c_str(), MyRefcnt(str3->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	printf("****************************\r\n");

	*str2 = foo;

	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("STR3: Ptr = %x, Reference count = %d\r\n", str3->c_str(), MyRefcnt(str3->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	printf("****************************\r\n");

	//*str3 = *str2;

	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("STR3: Ptr = %x, Reference count = %d\r\n", str3->c_str(), MyRefcnt(str3->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	printf("****************************\r\n");


	//delete str3;
	
	printf("****************************\r\n");
	printf("STR2: Ptr = %x, Reference count = %d\r\n", str2->c_str(), MyRefcnt(str2->c_str()));
	printf("Memory check returned %d\r\n", _CrtCheckMemory());
	printf("****************************\r\n");

	//delete str2;

}


