/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTProgressExec.h"
#include "MTProgressReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProgressReader

HRESULT CMTProgressReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	
	if(SUCCEEDED(hr)) {
		try {
			IObjectContextPtr ctx = (IObjectContext*)(m_spObjectContext);
			IGetContextPropertiesPtr ctxProperties = ctx;
			VARIANT vt;
			VariantInit(&vt);
			hr = ctxProperties->GetProperty(_bstr_t("Response"),&vt);
			_variant_t vtDispatch(vt,false);
			if(SUCCEEDED(hr) && vtDispatch.vt == VT_DISPATCH) {
				mResponse = vtDispatch;
			}
			else {
				// no response object
				mResponse = NULL;
			}
			hr = S_OK;
		}
		catch(_com_error&) {
			// do nothing... we are not in COM+ or do
			// not have a response object
			mResponse = NULL;
		}
	}
	if(mResponse == NULL) {
		mLogger->LogThis(LOG_WARNING,"Failed to find Response object in COM+ property collection; are you running under IIS?");
	}

	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProgressReader::CanBePooled()
{
	return TRUE;
} 

void CMTProgressReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTProgressReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProgress
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


HRESULT CMTProgressReader::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


// ----------------------------------------------------------------
// Name:   SetProgress  
// Arguments: Current Position, Maximum position
// Return Value:  S_OK if we have a response object, S_FALSE if we do not.
// Description:   Sets the new progress for use by a web application
// ----------------------------------------------------------------


STDMETHODIMP CMTProgressReader::SetProgress(long aCurrentPos,long aMaxPos)
{
	// silently do nothing if we do not have a response object

	if(mResponse == NULL) {
		mFailureCount++;
		if(mFailureCount == 1) {
			mLogger->LogThis(LOG_WARNING,"Attempting to write progress information however response object is not available.  Are you running under IIS and COM+?");
		}
		return S_FALSE; // indicate we don't have a response object
	}
	try {
		char* buff = new char[mProgressString.length() + 100];
		buff[0] = '\0';
		sprintf(buff,(const char*)mProgressString,aCurrentPos,aMaxPos);
		_bstr_t output(buff);
		mResponse->Write(buff);
		delete[] buff;
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     put_ProgressString
// Arguments: a new string that is used to indicate progress.  The string
// must have at least 2 %d replacement strings suitable for format by
// sprintf.
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTProgressReader::put_ProgressString(BSTR newVal)
{
	mProgressString = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:   get_ProgressString  
// Description:  obtain the progress string
// ----------------------------------------------------------------


STDMETHODIMP CMTProgressReader::get_ProgressString(BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mProgressString.copy();
	return S_OK;
}

STDMETHODIMP CMTProgressReader::Reset()
{
  // reset the progress bar in GUI.  For now we will simply hard code the html snippet.
	try {
    mResponse->Write("<script language='JavaScript'>initialize();</script>");
  }
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}
