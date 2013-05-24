/**************************************************************************
 * MTSESSIONERROR
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

// MTSessionError.cpp : Implementation of CMTSessionError
#include "StdAfx.h" //This is for the precompiled headers
#include <metra.h>

#include "PipelineControl.h"
#include "MTSessionError.h"
#include "MTSessionFailures.h"

#import <PipelineControl.tlb> rename("EOF", "RowsetEOF")

#include <comutil.h>
#include <MSIX.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CMTSessionError

STDMETHODIMP CMTSessionError::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionError,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

void CMTSessionError::FinalRelease()
{
	if (mTakeOwnership && mpError)
		delete mpError;
	mpError = NULL;
}

// ----------------------------------------------------------------
// Description: Return the line number of this error.
// Return Value: line number
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_LineNumber(int * pVal)
{
	if (!pVal)
		return E_POINTER;

	mLock.Lock();

	ASSERT(mpError);
	*pVal = mpError->GetLineNumber();

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the line number of this error.
// Arguments: newVal - the new line number
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_LineNumber(int newVal)
{
	mLock.Lock();

	ASSERT(mpError);
	mpError->SetLineNumber(newVal);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the error code.
// Return Value: the error code
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_ErrorCode(DWORD * pVal)
{
	if (!pVal)
		return E_POINTER;

	mLock.Lock();

	ASSERT(mpError);
	*pVal = mpError->GetErrorCode();

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the error code.
// Arguments: newVal - error code
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_ErrorCode(DWORD newVal)
{
	mLock.Lock();

	ASSERT(mpError);
	mpError->SetErrorCode((ErrorObject::ErrorCode) newVal);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the session ID, base64 encoded.  The ID returned is
//              the ID of the session within a compound that failed.
// Return Value: the session ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_SessionID(BSTR * pVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// get the UID
	const unsigned char * uidBytes = mpError->GetSessionID();

	// encode it to ASCII
	string asciiUID;
	MSIXUidGenerator::Encode(asciiUID, uidBytes);

	_bstr_t bstrVal(asciiUID.c_str());
	*pVal = bstrVal.copy();

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the session ID, base64 encoded.  The ID set is
//              the ID of the session within a compound that failed.
// Arguments: newVal - new session ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_SessionID(BSTR newVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// convert to a rogue wave string
	_bstr_t bstrVal(newVal);
	std::string stringVal(bstrVal);

	// decode the string
	// TODO: don't hardcode len
	unsigned char uidBytes[16];
	MSIXUidGenerator::Decode(uidBytes, stringVal.c_str());

	// set the value
	mpError->SetSessionID(uidBytes);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the session set ID, base64 encoded.
// Return Value: the session set ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_SessionSetID(BSTR * pVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// get the UID
	const unsigned char * uidBytes = mpError->GetSessionSetID();

	// encode it to ASCII
	string asciiUID;
	MSIXUidGenerator::Encode(asciiUID, uidBytes);

	_bstr_t bstrVal(asciiUID.c_str());
	*pVal = bstrVal.copy();

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the session set ID, base64 encoded.
// Arguments: newVal - new session set ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_SessionSetID(BSTR newVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// convert to a rogue wave string
	_bstr_t bstrVal(newVal);
	std::string stringVal(bstrVal);

	// decode the string
	// TODO: don't hardcode len
	unsigned char uidBytes[16];
	MSIXUidGenerator::Decode(uidBytes, stringVal.c_str());

	// set the value
	mpError->SetSessionSetID(uidBytes);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the ID of the root of the session if a compound session.
//              Otherwise, return the session ID of the failed session.
// Return Value: the root session ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_RootSessionID(BSTR * pVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// get the UID
	const unsigned char * uidBytes = mpError->GetRootID();

	// encode it to ASCII
	string asciiUID;
	MSIXUidGenerator::Encode(asciiUID, uidBytes);

	_bstr_t bstrVal(asciiUID.c_str());
	*pVal = bstrVal.copy();

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the ID of the root of the session if a compound session.
//              Otherwise, set the session ID of the failed session.
// Arguments: newVal - new session ID
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_RootSessionID(BSTR newVal)
{
	mLock.Lock();

	ASSERT(mpError);

	// convert to a rogue wave string
	_bstr_t bstrVal(newVal);
	std::string stringVal(bstrVal);

	// decode the string
	// TODO: don't hardcode len
	unsigned char uidBytes[16];
	MSIXUidGenerator::Decode(uidBytes, stringVal.c_str());

	// set the value
	mpError->SetRootID(uidBytes);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the time the session failed.
// Return Value: the failure date/time
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_FailureTime(DATE * pVal)
{
	if (!pVal)
		return E_POINTER;

	mLock.Lock();

	ASSERT(mpError);
	time_t failTime = mpError->GetFailureTime();
	OleDateFromTimet(pVal, failTime);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the time the session was metered.
// Return Value: the metered time
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_MeteredTime(DATE * pVal)
{
	if (!pVal)
		return E_POINTER;

	mLock.Lock();

	ASSERT(mpError);
	time_t meteredTime = mpError->GetMeteredTime();
	OleDateFromTimet(pVal, meteredTime);

	mLock.Unlock();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the IP address of the machine that metered the
//              failed session.
// Return Value: the IP address
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_IPAddress(BSTR * pVal)
{
	mLock.Lock();

	ASSERT(mpError);

	std::string ip;
	mpError->GetIPAddressAsString(ip);

	_bstr_t bstrVal(ip.c_str());
	*pVal = bstrVal.copy();

	mLock.Unlock();

	return S_OK;
}


// ----------------------------------------------------------------
// Description: Return the error message for the error that caused this
//              session to fail.  This is not the translation of the error code.
//              This error message provides additional error information.
// Return Value: the error message
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_ErrorMessage(BSTR * pVal)
{
	GetStringProperty(&SessionErrorObject::GetErrorMessage, pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the error message.  This is not the translation of the error code.
// This error message provides additional error information.
// Arguments: newVal - error message
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_ErrorMessage(BSTR newVal)
{
	SetStringProperty(&SessionErrorObject::SetErrorMessage, newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the name of the stage where the session failed.
// Return Value: the stage name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_StageName(BSTR * pVal)
{
	GetStringProperty(&SessionErrorObject::GetStageName, pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the name of the stage where the session failed.
// Arguments: newVal - stage name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_StageName(BSTR newVal)
{
	SetStringProperty(&SessionErrorObject::SetStageName, newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the name of the plug-in where the session failed.
// Arguments: pVal - on return, holds the plug-in name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_PlugInName(BSTR * pVal)
{
	GetStringProperty(&SessionErrorObject::GetPlugInName, pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the name of the plug-in where the session failed.
// Arguments: newVal - plug-in name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_PlugInName(BSTR newVal)
{
	SetStringProperty(&SessionErrorObject::SetPlugInName, newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the name of the module where the session failed.  The
//              module is usually the filename of the source file where
//              the error was generated.
// Return Value: the module name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_ModuleName(BSTR * pVal)
{
	GetStringProperty(&SessionErrorObject::GetModuleName, pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the name of the module where the session failed.  The
//              module is usually the filename of the source file where
//              the error was generated.
// Arguments: newVal - module name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_ModuleName(BSTR newVal)
{
	SetStringProperty(&SessionErrorObject::SetModuleName, newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the name of the procedure where the session failed.
// Return Value: the procedure name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_ProcedureName(BSTR * pVal)
{
	GetStringProperty(&SessionErrorObject::GetProcedureName, pVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the name of the procedure where the session failed.
// Arguments: newVal - procedure name
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_ProcedureName(BSTR newVal)
{
	SetStringProperty(&SessionErrorObject::SetProcedureName, newVal);
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the XML representation of the failed session
// Return Value: XML/MSIX repesentation of the session that failed.
//               If the session is part of a compound, all parts of
//               the compound are returned. Uses the saved XML message 
//               if it exists, otherwise the original XML is used.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_XMLMessage(BSTR * pVal)
{
	// TODO: this will fail if the message is binary
	std::wstring buffer;

	BSTR sessionID;
	HRESULT hr = get_RootSessionID(&sessionID);
	if (FAILED(hr))
		return hr;
	
	// in 4.0 HasSavedXMLMessage will always return true
	BOOL useSaved = CMTSessionFailures::HasSavedXMLMessage(sessionID, NULL);
	if (useSaved)
	{
		// a saved, partially edited message exists, so grab it
		std::string message;
		hr = CMTSessionFailures::LoadXMLMessage(sessionID, message, NULL);
		if (FAILED(hr))
			return hr;
		ASCIIToWide(buffer, message.c_str(), message.length());
	}
	else
	{
		// otherwise, get the xml from the error queue
		const char * message;
		int messageLen;
		mpError->GetMessage(&message, messageLen);
		ASCIIToWide(buffer, message, messageLen);
	}

	*pVal = ::SysAllocString(buffer.c_str());

	::SysFreeString(sessionID);

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the XML representation of the failed session.
// Arguments: newVal - message
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_XMLMessage(BSTR newVal)
{
	try
	{
		_bstr_t buffer(newVal);
		mpError->SetMessage(buffer, buffer.length());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
	
	return S_OK;
}

// ----------------------------------------------------------------
// Description: Return the original XML representation of the failed session
// Return Value: XML/MSIX repesentation of the session that failed.
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_OriginalXMLMessage(BSTR * pVal)
{
	// TODO: this will fail if the message is binary
	std::wstring buffer;

	// otherwise, get the xml from the error queue
	const char * message;
	int messageLen;
	mpError->GetMessage(&message, messageLen);
	ASCIIToWide(buffer, message, messageLen);

	*pVal = ::SysAllocString(buffer.c_str());

	return S_OK;
}

// ----------------------------------------------------------------
// Description: Set the original XML representation of the failed session.
// Arguments: newVal - message
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::put_OriginalXMLMessage(BSTR newVal)
{
	try
	{
		// TODO: this does the same thing as put_XMLMessage
		_bstr_t buffer(newVal);
		mpError->SetMessage(buffer, buffer.length());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
	
	return S_OK;
}

// ----------------------------------------------------------------
// Description: retrieve a parsed version of the session.
//              uses the saved XML message if it exists, otherwise the
//              original is used.
// Return Value: parsed version of the message returned in session
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_Session(/*[out, retval]*/ IMTSession * * session)
{
	try
	{
		PIPELINECONTROLLib::IMTPipelinePtr pipeline(MTPROGID_PIPELINE);

		BSTR xml;
		HRESULT hr = get_XMLMessage(&xml);
		if (FAILED(hr))
			return hr;

		PIPELINECONTROLLib::IMTSessionPtr parsedSession = pipeline->ExamineSession(xml);
		*session = (IMTSession *) parsedSession.Detach();
		::SysFreeString(xml);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}


// ----------------------------------------------------------------
// Description: saves an XML message representation to a file
// Return Value: n/a
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::SaveXMLMessage(/*[in]*/ BSTR xml, /*[in]*/ IMTCollection * apChildrenToDelete)
{
	try
	{
		BSTR rootSessionID;
		HRESULT hr = get_RootSessionID(&rootSessionID);
		if (FAILED(hr))
			return hr;

		GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete(apChildrenToDelete);
		
		// NOTE: this char cast is safe because the xml is already UTF8 encoded
		hr = CMTSessionFailures::SaveXMLMessage(rootSessionID,
																						(const char *) _bstr_t(xml),
																						childrenToDelete);
		
		::SysFreeString(rootSessionID);

		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}


// ----------------------------------------------------------------
// Description: determines if a saved XML message exists for this failure
// Return Value: returns TRUE if a saved XML message exists
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::get_HasSavedXMLMessage(/*[out, retval]*/ VARIANT_BOOL * saved)
{
	try
	{
		BSTR rootSessionID;
		HRESULT hr = get_RootSessionID(&rootSessionID);
		if (FAILED(hr))
			return hr;
		
		BOOL hasBeenSaved = CMTSessionFailures::HasSavedXMLMessage(rootSessionID, NULL);
		
		::SysFreeString(rootSessionID);
	
		*saved = hasBeenSaved ? VARIANT_TRUE : VARIANT_FALSE;

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}


// ----------------------------------------------------------------
// Description: permanently removes a saved XML message file from disk
// Return Value: n/a
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::DeleteSavedXMLMessage() 
{
	try
	{
		BSTR rootSessionID;
		HRESULT hr = get_RootSessionID(&rootSessionID);
		if (FAILED(hr))
			return hr;
		
		hr = CMTSessionFailures::DeleteSavedXMLMessage(rootSessionID, NULL);
		if (FAILED(hr))
			return hr;
		
		::SysFreeString(rootSessionID);

		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Description: Initialize the object from a byte stream.
// Return Value: n/a
// ----------------------------------------------------------------
STDMETHODIMP CMTSessionError::InitFromStream(SAFEARRAY * message)
{
	try
	{
		VARTYPE vt;
		HRESULT hr = SafeArrayGetVartype(message, &vt);
		if (FAILED(hr))
			return hr;

		// must be array of BYTE
		if (vt != VT_UI1)
			return E_INVALIDARG;

		long lbound;
		hr = SafeArrayGetLBound(message, 1, &lbound);
		if (FAILED(hr))
			return hr;

		long ubound;
		hr = SafeArrayGetUBound(message, 1, &ubound);
		if (FAILED(hr))
			return hr;

		long messageLen = (ubound - lbound) + 1;

		BYTE HUGEP * messageBytes;
		hr = SafeArrayAccessData(message, (void HUGEP **) &messageBytes);
		if (FAILED(hr))
			return hr;

		SessionErrorObject * errorObj = new SessionErrorObject;
		BOOL decodeSucceeded = errorObj->Decode(messageBytes, messageLen);

		SafeArrayUnaccessData(message);

		if (!decodeSucceeded)
		{
			hr = errorObj->GetLastError()->GetCode();
			return hr;
		}

		// true is take ownership
		SetSessionError(errorObj, TRUE);
		return S_OK;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}
