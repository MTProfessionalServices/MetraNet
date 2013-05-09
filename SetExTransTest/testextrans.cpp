// testextrans.cpp : Defines the entry point for the console application.
//

#include <StdAfx.h>
#include "..\SetExTrans.h"

#include <crtdbg.h>
#include <string>

#define CUSTOM_HANDLER

void SEFunc()
{
	int x, y=0;
  x = 5 / y;
}


void main( void )
{
  _se_translator_function hdlr;
	try
  {
#ifdef CUSTOM_HANDLER
		//hdlr will point to the previously installed
		//exception handler, or NULL if none (common case)
		hdlr = _set_se_translator( trans_func );
#endif
     SEFunc();
  }
  catch( SEH_Exception& e )
  {
		printf( "Caught SEH_Exception (custom exception handler).\n" );
		printf( e.what() );
  }
	catch(std::exception& e)
	{
		printf( "Caught std::exception.\n" );
		printf( e.what() );
	}
	catch(...)
	{
		printf( "Caught ... .\n" );
	}
	//set the old handler back
	_set_se_translator( hdlr);
}
