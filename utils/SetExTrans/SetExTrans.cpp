#include "SetExTrans.h"
void trans_func( unsigned int u, EXCEPTION_POINTERS* pExp )
{
  throw SEH_Exception(pExp->ExceptionRecord);
}
const char* SEH_Exception::what() 
{ 
	char msg[1024];
	DWORD exCode = mER->ExceptionCode;
	DWORD numParams = mER->NumberParameters;
	sprintf(msg, "Caught SEH_exception, WIN32 exception code is <%x>, ReadWrite Flag: <%s>, Exception Address: <%x>,  Data Address: <%x>",  \
				exCode, mER->ExceptionInformation[0] == 0? "Read" : "Write", (int)mER->ExceptionAddress, mER->ExceptionInformation[1]);
	mMsg = msg;
	return mMsg; 
}