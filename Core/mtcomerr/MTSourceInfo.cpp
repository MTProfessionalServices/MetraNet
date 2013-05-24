/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/


#include <mtcom.h>
#include <comutil.h>
#include <comdef.h>
#include <errobj.h>
#include <MTSourceInfo.h>


MTSourceInfo::MTSourceInfo(const char * apModule, int aLine)
{
	mpModule = apModule;
	mLine = aLine;
}

// return the source as one string "Module[Line]"
_bstr_t MTSourceInfo::GetSourceString()
{
	char buf[1024];
	int charsInBuff = sizeof(buf)/sizeof(buf[0]);
	int charsWritten = _snprintf( buf, charsInBuff, "%s[%d]", mpModule, mLine);

	return buf;
}

// ----------------------------------------------------------------
// Name:          CreateComError
// Arguments:     aIID - interface of com object that defined the error
//                       (if ommitted ID_NULL is used)
//                aErrorCode - error code
//                ...  - optional arguments
// Return Value:  _com_error object that can be thrown
// Errors Raised: none
// Description:   Create a _com_error for an IID, given a error code and optional arguments
//                Loads localized message for the error code and replaces
//                format strings with the supplied args.
// ----------------------------------------------------------------
_com_error MTSourceInfo::CreateComError(const IID& aIID, DWORD aErrorCode, ...)
{
	va_list argptr;
	va_start(argptr,aErrorCode);
	return CreateComErrorFromErrorCode(aIID, aErrorCode, argptr);
	va_end(argptr);
}

//overloade method without IID
_com_error MTSourceInfo::CreateComError(DWORD aErrorCode, ...)
{
	va_list argptr;
	va_start(argptr,aErrorCode);
	return CreateComErrorFromErrorCode(IID_NULL, aErrorCode, argptr);
	va_end(argptr);
}


// ----------------------------------------------------------------
// Name:          CreateComError
// Arguments:     aIID - interface of com object that defined the error 
//                aMsg - message or format string
//                ...  - optional arguments
// Return Value:  _com_error object that can be thrown
// Errors Raised: none
// Description:   Create a _com_error for an IID, given a message and optional arguments
//                aMsg can contain printf like format specifiers (%s, ...).
// ----------------------------------------------------------------

//overloaded function for char, with IID
_com_error MTSourceInfo::CreateComError(const IID& aIID, const char* aMsg, ... )
{
	va_list argptr;
	va_start(argptr,aMsg);
	return CreateComErrorFromString(aIID, aMsg, argptr);
	va_end(argptr);
}

//overloaded function for char, no IID
_com_error MTSourceInfo::CreateComError(const char* aMsg, ... )
{
	va_list argptr;
	va_start(argptr,aMsg);
	return CreateComErrorFromString(IID_NULL, aMsg, argptr);
	va_end(argptr);
}

//overloaded function for wchar_t, with IID
_com_error MTSourceInfo::CreateComError(const IID& aIID, const wchar_t* aMsg, ...)
{
	va_list argptr;
	va_start(argptr,aMsg);
	return CreateComErrorFromWString(aIID, aMsg, argptr);
	va_end(argptr);
}

//overloaded function for wchar_t, no IID
_com_error MTSourceInfo::CreateComError(const wchar_t* aMsg, ...)
{
	va_list argptr;
	va_start(argptr,aMsg);
	return CreateComErrorFromWString(IID_NULL, aMsg, argptr);
	va_end(argptr);
}


// helper function for CreateComError, creates the IErrorInfo object
_com_error MTSourceInfo::CreateErrorInfo(const IID& aIID, HRESULT aErrorCode, const _bstr_t aMsg)
{
	ICreateErrorInfo* createErrorInfo = NULL;
	IErrorInfo* errorInfo = NULL;;

	HRESULT hr = ::CreateErrorInfo(&createErrorInfo);
	if(SUCCEEDED(hr))
		hr = createErrorInfo->SetGUID(aIID);

	if(SUCCEEDED(hr))
		hr = createErrorInfo->SetDescription(aMsg);

	if(SUCCEEDED(hr))
		hr = createErrorInfo->SetSource(GetSourceString());

	if(SUCCEEDED(hr))
		hr = createErrorInfo->QueryInterface(IID_IErrorInfo, (void**)&errorInfo);

	if(FAILED(hr))
		errorInfo = NULL;

	return _com_error(aErrorCode, errorInfo);
}

// helper function for CreateComError by ErrorCode
_com_error MTSourceInfo::CreateComErrorFromErrorCode(const IID& aIID, DWORD aErrorCode, va_list aArglist)
{
	Message message(aErrorCode);
	string msgString;
	message.FormatErrorMessageArglist(msgString, TRUE, aArglist);

	return CreateErrorInfo(aIID, aErrorCode, msgString.c_str());
}

// helper function for CreateComError by char string
_com_error MTSourceInfo::CreateComErrorFromString(const IID& aIID, const char* aMsg, va_list aArglist)
{
	char buf[4096];
	int charsInBuff = sizeof(buf)/sizeof(buf[0]);
	int charsWritten = _vsnprintf( buf, charsInBuff, aMsg, aArglist);
	
	// if the number of bytes to write exceeds buffer, null terminate
	if(charsWritten < 0)
		buf[charsInBuff-1] = '\0';

	return CreateErrorInfo(aIID, E_FAIL, buf);
}

// local helper function for CreateComError by w_char string
_com_error MTSourceInfo::CreateComErrorFromWString(const IID& aIID, const wchar_t* aMsg, va_list aArglist)
{
	wchar_t buf[4096];
	int charsInBuff = sizeof(buf)/sizeof(buf[0]);
	int charsWritten = _vsnwprintf( buf, charsInBuff, aMsg, aArglist);
	
	// if the number of bytes to write exceeds buffer, null terminate
	if(charsWritten < 0)
		buf[charsInBuff-1] = L'\0';

	return CreateErrorInfo(aIID, E_FAIL, buf);
}


