/**************************************************************************
 * @doc ERRORTEST
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <errobj.h>

#ifdef WIN32
#include <mtglobal_msg.h>
#endif
#ifdef UNIX
#include <sdk_msg.h>
#endif

#include <iostream>

using std::cout;
using std::endl;

int main(int argc, char **argv)
{
	Message::AddModule("mtglobal_msgd.dll");
	Message message(0xE1200010L);
	std::string msg;
	message.GetErrorMessage(msg, TRUE);
	cout << "Formatted message: " << msg.c_str() << endl;
	return 0;

#if 0
#ifdef WIN32
	if (!ErrorObject::AddModule("e:\\dev\\Common\\debug\\bin\\Common_msg.dll"))
	{
		cerr << "Unable to load module." << endl;
		return -1;
	}

	ErrorObject errorobj(NTEVT_ERROR_MSG, ERROR_MODULE, ERROR_LINE, "main");

	errorobj.GetProgrammerDetail() = "This is a test";

#endif

#ifdef UNIX
	ErrorObject errorobj(MT_ERR_NO_PROPERTY, ERROR_MODULE, ERROR_LINE, "main");

	errorobj.GetProgrammerDetail() = "This is a test";

  // return 0;

#endif

	// get the unicode string
	wstring unicode;

	if (!errorobj.GetErrorMessage(unicode))
	{
		cerr << "Unable to get unicode string." << endl;
		return -1;
	}

	// try converting to ascii
	string asciiConversion;
	if (!ErrorObject::ToAscii(asciiConversion, unicode))
	{
		cerr << "Unable to convert to ASCII." << endl;
		return -1;
	}
	cout << "ASCII converted from Unicode: " << asciiConversion.c_str() << endl;

	// get the ascii string directly
	string ascii;
	if (!errorobj.GetErrorMessage(ascii))
	{
		cerr << "Unable to get ASCII string." << endl;
		return -1;
	}
	cout << "ASCII read directly: " << ascii.c_str() << endl;
	
	if (0 == ascii.compare(asciiConversion))
		cout << "ASCII and converted ASCII strings are equal." << endl;
	else
		cout << "ASCII and converted ASCII strings are not equal." << endl;

	// severity
	cout << "Severity: ";
	switch (errorobj.GetSeverity())
	{
	case ErrorObject::SUCCESS:
		cout << "Success.";
		break;
	case ErrorObject::INFO:
		cout << "Info.";
		break;
	case ErrorObject::WARNING:
		cout << "Warning.";
		break;
	case ErrorObject::ERROR_SEVERITY:
		cout << "Error.";
		break;
	}
	cout << endl;

	// system error?
	cout << "Is system error? " << ((errorobj.IsSystemError()) ? "yes" : "no") << endl;

	// programmer detail
	cout << "Programmer detail: " << errorobj.GetProgrammerDetail().c_str() << endl;

	// module
	cout << "Module: " << errorobj.GetModuleName() << endl;

	// line number
	cout << "Line number: " << errorobj.GetLineNumber() << endl;

	// function name
	cout << "Function: " << errorobj.GetFunctionName() << endl;

	// time
	cout << "Time: " << ctime(errorobj.GetErrorTime()) << endl;

#endif
	return 0;
}


