/**************************************************************************
 * @doc ERROBJ
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <errobj.h>

#include <stdlib.h>
#include <time.h>

#ifdef UNIX
#include <sdk_msg.h>
#endif

using namespace std;

/******************************************************** Message ***/

// @mfunc Constructor, given message ID
Message::Message(ErrorCode aCode)
{
	// store the code
	mCode = aCode;
}

#ifdef WIN32

list<HMODULE> Message::sModules;
DWORD Message::sLanguageId = 0;
BOOL Message::sIgnoreDefaultModules = FALSE;
BOOL Message::sDefaultsAdded = FALSE;

// adds default modules if needed
// if a default module cannot be found, sets arErrMsg and returns FALSE
// returns TRUE otherwise
BOOL Message::AddDefaultModules(string& arErrMsg)
{
 	if (!sDefaultsAdded && !sIgnoreDefaultModules)
	{
		// this module contains all metratech error codes
		BOOL success = Message::AddModule("mtglobal_msg.dll");
		if (!success)
		{	arErrMsg = "Cannot find mtglobal_msg.dll";
			return FALSE;
		}

		sDefaultsAdded = TRUE;
	}
	return TRUE;
}

// @mfunc Add a module (DLL) name that the error object will
// use to read the error message.
// @parm module (DLL) name.  Loaded from PATH if not an absolute name.
// @rdesc true/false indicating success.
BOOL Message::AddModule(const char * apModule)
{
  HMODULE module = ::LoadLibraryA(apModule);

	if (module)
		sModules.push_back(module);

	return (module != NULL);
}

// @cmember Free the module loaded by SetModule
// @rdesc true/false indicating success.
BOOL Message::FreeMessageModules()
{
	BOOL err = FALSE;

	list<HMODULE>::iterator it;
	for (it = sModules.begin(); it != sModules.end(); it++)
	{
		HMODULE module = *it;
		err = err || !::FreeLibrary(module);
	}

	sModules.clear();
	return err;
}

void Message::IgnoreDefaultModules()
{
	sIgnoreDefaultModules = TRUE;

}

// @mfunc Set the language ID.  See win32 documentation for more info.
// @parm language ID.
// @rdesc true/false indicating success.
void Message::SetLanguageId(DWORD aLangId)
{
	sLanguageId = aLangId;
}

#endif // WIN32

// @mfunc return a Unicode string describing the error code.
// @parm Unicode string to hold the error message
// @rdesc true/false indicating success
BOOL Message::GetErrorMessage(wstring & arUnicode,BOOL abStripCRLF) const
{
	BOOL res = TRUE;
#ifdef WIN32
	LPWSTR message;

	string errMsg;
	BOOL success = AddDefaultModules(errMsg);
	if (!success)
	{
	  const int numChars = 256;
		wchar_t* buff = new wchar_t[numChars];
		_snwprintf(buff, numChars, L"Unretrievable error with code %X (%S)", mCode, errMsg.c_str());
		buff[numChars-1] = 0; //assure NULL termination (if buffer too small)
		arUnicode = buff;
		delete [] buff;
		//keep going, so that arUnicode will be overidden if the string can be retrieved from the system
	}

	if (sModules.size() == 0)
	{
		// no modules to search, so try to get the string from the system
		DWORD len = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM |
															 FORMAT_MESSAGE_ALLOCATE_BUFFER,
															 NULL,
															 mCode,
															 sLanguageId,
															 (LPWSTR) &message,
															 0,	// size
															 NULL); // arguments
		if (len > 0)
		{
			if(abStripCRLF) message[len - (sizeof(message[0])*CRLF_SIZE)] = '\0';
			arUnicode = message;
			LocalFree(message);
			return TRUE;
		}
		return FALSE;
	}

	list<HMODULE>::iterator it;
	for (it = sModules.begin(); it != sModules.end(); it++)
	{
		HMODULE module = *it;

		DWORD len = FormatMessageW(FORMAT_MESSAGE_FROM_HMODULE |
															 FORMAT_MESSAGE_FROM_SYSTEM |
															 FORMAT_MESSAGE_ALLOCATE_BUFFER,
															 module,
															 mCode,
															 sLanguageId,
															 (LPWSTR) &message,
															 0,	// size
															 NULL); // arguments
		if (len > 0)
		{
			if(abStripCRLF) message[len - (sizeof(message[0])*CRLF_SIZE)] = '\0';
			arUnicode = message;
			LocalFree(message);
			return TRUE;
		}
		else {
			DWORD err = ::GetLastError();
			res = (err == 0);
		}
	}
#endif
#ifdef UNIX
  const char *temp_message = mt_message_lookup((METRATECH_MESSAGE_TYPE)mCode);

  if (temp_message == NULL)
    return FALSE;

  int len = mbstowcs(NULL, temp_message, 0);
	wchar_t * out = new wchar_t[len + 1];
  mbstowcs(out, temp_message, len);

  out[len] = 0;

  //  arUnicode.assign(out);
  arUnicode.append(out);
  
  delete [] out;
    
  return TRUE;
#endif

	return FALSE;
}

// @mfunc return an ASCII string describing the error code.
// @parm ASCII string to hold the error message
// @rdesc true/false indicating success
BOOL Message::GetErrorMessage(string & arAscii,BOOL abStripCRLF) const
{
	BOOL res = TRUE;
#ifdef WIN32
	LPSTR message;
	
	string errMsg;
	BOOL success = AddDefaultModules(errMsg);
	if (!success)
	{
	  const int numChars = 256;
		char* buff = new char[numChars];
		_snprintf(buff, numChars, "Unretrievable error with code %X (%s)", mCode, errMsg.c_str());
		buff[numChars-1] = 0; //assure NULL termination (if buffer too small)
		arAscii = buff;
		delete [] buff;
		//keep going, so that arAscii will be overidden if the string can be retrieved from the system
	}

	if (sModules.size() == 0)
	{
		// no modules to search, so try to get the string from the system
		DWORD len = FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM |
															 FORMAT_MESSAGE_ALLOCATE_BUFFER,
															 NULL,
															 mCode,
															 sLanguageId,
															 (LPSTR) &message,
															 0,	// size
															 NULL); // arguments
		if (len > 0)
		{
			if(abStripCRLF) message[len - (sizeof(message[0])*CRLF_SIZE)] = '\0';
			arAscii = message;
			LocalFree(message);
			return TRUE;
		}
		return FALSE;
	}


	list<HMODULE>::iterator it;
	for (it = sModules.begin(); it != sModules.end(); it++)
	{
		HMODULE module = *it;

		DWORD len = FormatMessageA(FORMAT_MESSAGE_FROM_HMODULE |
															 FORMAT_MESSAGE_FROM_SYSTEM |
															 FORMAT_MESSAGE_ALLOCATE_BUFFER,
															 module,
															 mCode,
															 sLanguageId,
															 (LPSTR) &message,
															 0,	// size
															 NULL); // arguments
		if (len > 0)
		{
			if(abStripCRLF) message[len - (sizeof(message[0])*CRLF_SIZE)] = '\0';
			arAscii = message;
			LocalFree(message);
			return TRUE;
		}
		else {
			DWORD err = ::GetLastError();
			res = (err == 0);
		}
	}
#endif

#ifdef UNIX
  const char *temp_message = mt_message_lookup((METRATECH_MESSAGE_TYPE)mCode);

  if (temp_message == NULL)
    return FALSE;

  //  arAscii.assign(temp_message);
  arAscii.append(temp_message);
    
#endif
	return res;
}

BOOL Message::FormatErrorMessage(string& arAscii,BOOL abStripCRLF,...) const
{
	va_list argptr;
  
	va_start(argptr,abStripCRLF);

	return FormatErrorMessageArglist(arAscii, abStripCRLF, argptr);
	va_end(argptr);
}


BOOL Message::FormatErrorMessageArglist(string & arAscii,BOOL abStripCRLF, va_list aArglist) const
{
#ifdef WIN32
	LPSTR message;

	string errMsg;
	BOOL success = AddDefaultModules(errMsg);
	if (!success)
	{
	  const int numChars = 256;
		char* buff = new char[numChars];
		_snprintf(buff, numChars, "Unretrievable error with code %X (%s)", mCode, errMsg.c_str());
		buff[numChars-1] = 0; //assure NULL termination (if buffer too small)
		arAscii = buff;
		delete [] buff;
	}

	list<HMODULE>::iterator it;
	for (it = sModules.begin(); it != sModules.end(); it++)
	{
		HMODULE module = *it;

		DWORD len = 0;
		try
		{
			len = FormatMessageA(FORMAT_MESSAGE_FROM_HMODULE |
													 FORMAT_MESSAGE_FROM_SYSTEM |
													 FORMAT_MESSAGE_ALLOCATE_BUFFER,
													 module,
													 mCode,
													 sLanguageId,
													 (LPSTR) &message,
													 0,	// size
													 &aArglist); // arguments
		}
		catch(...) //mismatch in arguments (e.g. passing an int arg for a "%1!s!" format) can blow up
		{
			ASSERT(0);
			char buff[128];
			sprintf(buff, "Unretrievable error with code %X (possible argument mismatch)", mCode);
			arAscii = buff;
		}
		
		if (len > 0)
		{
			if(abStripCRLF) message[len - (sizeof(char)*CRLF_SIZE)] = '\0';
			arAscii = message;
			LocalFree(message);
			return TRUE;
		}
	}
#else
//#error Unix FormatErrorMessage not implemented.
	ASSERT(0);
#endif // WIN32
	return FALSE;
}


// @mfunc Return the severity of this error
// @rdesc one of the severity constants.
Message::Severity Message::GetSeverity()
{
	int code = SeverityCode();
	// NOTE: make sure you don't use the constant "ERROR" here
	ASSERT(code <= ERROR_SEVERITY);
	return (Severity) code;
}

// @mfunc convert the error message to ASCII if possible, replacing
// non-ASCII Unicode characters with the default character given.
// @parm string to hold converted ASCII string
// @parm Unicode string to convert
// @parm default character to use for non ASCII Unicode characters
// @rdesc
//  @flag non-zero | all characters were ASCII
//  @flag zero | at least one character was non-ASCII
BOOL Message::ToAscii(string & arAscii, const wstring & arUnicode,
											char aDefaultChar /* = '?' */)
{
	BOOL usedDefaultChar;
  int len;
  int	newLen;

#ifdef WIN32

	len = WideCharToMultiByte(
		CP_ACP,											// ANSI code page
		0,													// flags (none)
		arUnicode.c_str(),					// wide string
		arUnicode.length(),					// size of wide string
		NULL,												// multibyte string (NULL = return count)
		0,													// buffer size (0 = return count)
		&aDefaultChar,							// pointer to default character
		&usedDefaultChar);					// set to true if default char used.

	if (len > 0)
	{
		char * buffer = new char[len];
		newLen = WideCharToMultiByte(
			CP_ACP,										// ANSI code page
			0,												// flags (none)
			arUnicode.c_str(),				// wide string
			arUnicode.length(),				// size of wide string
			buffer,										// multibyte string (NULL = return count)
			len,											// size of buffer
			&aDefaultChar,						// pointer to default character
			&usedDefaultChar);				// set to true if default char used.

		// TODO: what happens if this length and the old length don't match
		if (newLen != len)
		{
			delete [] buffer;
			return FALSE;
		}

		// string is not null terminated
		// TODO: better way of doing this?
		string temp(buffer, len);
		arAscii = temp;
		delete [] buffer;

		return !usedDefaultChar;
	}
	else
	{
		arAscii.resize(0);
		return FALSE;
	}
#else
	len = wcstombs(NULL, arUnicode.c_str(), 0);

	if (len > 0)
	{
		char * buffer = (char *)malloc(len+1);
		newLen = wcstombs(buffer, arUnicode.c_str(), len);

		// TODO: what happens if this length and the old length don't match
		if (newLen != len)
		{
			free(buffer);
			return FALSE;
		}

		// string is not null terminated
		string temp(buffer, len);
		arAscii = temp;
		free(buffer);

		return TRUE;
	}
	else
	{
		arAscii.resize(0);
		return FALSE;
	}

#endif
}


/**************************************************** ErrorObject ***/

// @mfunc Constructor, given error information.
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
ErrorObject::ErrorObject(ErrorCode aCode,
						 const char * apModule, int aLine,
						 const char * apProcedure) : Message(aCode)
{
	Init(aCode, apModule, aLine, apProcedure);
}

// @mfunc empty constructor
ErrorObject::ErrorObject() : Message(0)
{
	mModule = "";
	mLine = -1;
	mProcedure = "";
	mTime = 0;
  //mDetail.resize(0); // BUG in rw STL
}

ErrorObject::~ErrorObject(void)
{
  //mDetail.erase(); // BUG in rw STL
}


// @mfunc initialize with given values
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void ErrorObject::Init(ErrorCode aCode,
								 const char * apModule, int aLine, const char * apProcedure)
{
	// copy the code
	mCode = aCode;

	// retrieve the current time
	time(&mTime);

	// store module and procedure names
	mModule = apModule;
	mLine = aLine;
	mProcedure = apProcedure;
}

// @mfunc assignment operator
// @parm object to copy from
// @rdesc this
ErrorObject & ErrorObject::operator =(const ErrorObject & arError)
{
	mCode = arError.GetCode();
	mDetail = arError.GetProgrammerDetail();
	mTime = *arError.GetErrorTime();
	mModule = arError.GetModuleName();
	mLine = arError.GetLineNumber();
	mProcedure = arError.GetFunctionName();
	return *this;
}

/************************************************ ObjectWithError ***/

// @mfunc constructor
ObjectWithError::ObjectWithError()
{
	mpLastError = NULL;
}

// @mfunc destructor
ObjectWithError::~ObjectWithError()
{
	ClearError();
}

// @mfunc
// Return an object holding the last error.
// @rdesc error object if a function has just caused an error,
//  otherwise NULL.
const ErrorObject * ObjectWithError::GetLastError() const
{
	// could be NULL
	return mpLastError;
}

// @mfunc Clear error status
// @devnote it is optional to call this function.
// objects are not required to clear errors after successful calls.
void ObjectWithError::ClearError()
{
	if (mpLastError)
		delete mpLastError;
	mpLastError = NULL;
}


// @mfunc An error is pending with the given information
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void ObjectWithError::SetError(
	ErrorObject::ErrorCode aCode, const char * apModule,
	int aLine, const char * apProcedure)
{
	if (mpLastError)
		// already have one
		mpLastError->Init(aCode, apModule, aLine, apProcedure);
	else
		// make one
		mpLastError = new ErrorObject(aCode, apModule, aLine, apProcedure);
}

// @mfunc An error is pending with the given information
// @parm error code
// @parm module/filename
// @parm line number
// @parm procedure name
void ObjectWithError::SetError(
	ErrorObject::ErrorCode aCode, const char * apModule,
	int aLine, const char * apProcedure, const char *apDetail)
{
	if (mpLastError)
		// already have one
		mpLastError->Init(aCode, apModule, aLine, apProcedure);
	else
		// make one
		mpLastError = new ErrorObject(aCode, apModule, aLine, apProcedure);

  // set the programmer detail in the error object ...
  const char* pDetail = (apDetail != NULL) ? apDetail :  "No detail given.";
  mpLastError->GetProgrammerDetail() = pDetail ;
}

// @mfunc Convenience function to set the error from another error
//  object.  Also sets the error pending flag.
// @parm set from this object
void ObjectWithError::SetError(const ErrorObject * apError)
{
#ifndef UNIX
	ASSERT(apError != NULL);
#else
	if (!apError)
		return;
#endif

	if (mpLastError)
		// already have one
		*mpLastError = *apError;
	else
		// make one
		mpLastError = new ErrorObject(*apError);
}

// @mfunc Convenience function to set the error from another error
//  object.  Also sets the error pending flag.
// @parm set from this object
void ObjectWithError::SetError(const ObjectWithError & arObject)
{
	const ErrorObject * err = arObject.GetLastError();

#ifndef UNIX
	ASSERT(err != NULL);
#else
	if (!err)
		return;
#endif

	if (mpLastError)
		// already have one
		*mpLastError = *err;
	else
		// make one
		mpLastError = new ErrorObject(*err);
}

// @mfunc Convenience function to set the error from another error
//  object.  Also sets the error pending flag.
// @parm set from this object
void ObjectWithError::SetError(const ErrorObject * apError, const char *apDetail)
{
#ifndef UNIX
	ASSERT(apError != NULL);
#else
	if (!apError)
		return;
#endif

	if (mpLastError)
		// already have one
		*mpLastError = *apError;
	else
		// make one
		mpLastError = new ErrorObject(*apError);

  // set the programmer detail in the error object ...
  mpLastError->GetProgrammerDetail() = apDetail ;
}

