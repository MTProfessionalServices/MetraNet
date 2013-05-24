/*  SETRANS.CPP 
 */

#include <stdio.h>
#include <windows.h>
#include <eh.h>
#include <string>

void trans_func( unsigned int, EXCEPTION_POINTERS* );

class SEH_Exception
{
private:
    unsigned int nSE;
		char* mMsg;
		EXCEPTION_RECORD* mER;
public:
    SEH_Exception() {}
    SEH_Exception(EXCEPTION_RECORD* aER) : mER( aER ) {}
    ~SEH_Exception() {}
    const char* what();
		
};
