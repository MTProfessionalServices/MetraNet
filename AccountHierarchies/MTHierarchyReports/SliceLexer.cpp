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
#include "MTHierarchyReports.h"
#include "SliceLexer.h"

#include <comdef.h>
#include <mtcomerr.h>

/////////////////////////////////////////////////////////////////////////////
// CSliceLexer

CSliceLexer::CSliceLexer() :
	mBuffer(""),
	NPOS(-1),
	mLastFound(0),
	mNextFound(0),
	mFoundStr("")
{
	m_pUnkMarshaler = NULL;
}

STDMETHODIMP CSliceLexer::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ISliceLexer
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CSliceLexer::GetNextToken(BSTR *apToken)
{
	if (!apToken)
		return E_POINTER;
	else
		*apToken = NULL;

	try
	{
		*apToken = _bstr_t(mFoundStr.c_str()).copy();
		Advance();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CSliceLexer::LookAhead(BSTR *apToken)
{
	if (!apToken)
		return E_POINTER;
	else
		*apToken = NULL;

	try
	{
		*apToken = _bstr_t(mFoundStr.c_str()).copy();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

STDMETHODIMP CSliceLexer::Init(BSTR aStr)
{
	if (!aStr)
		return E_POINTER;
	try
	{
		mLastFound = 0;
		mNextFound = 0;
		_bstr_t bstrBuffer(aStr);
		mBuffer = std::string((const char *) bstrBuffer);
		Advance();
	}
	catch(_com_error & e)
	{
		return returnHierarchyReportError(e);
	}
	
	return S_OK;
}

void CSliceLexer::Advance()
{
	if (mLastFound != NPOS)
	{
		do
		{
			mNextFound = mBuffer.find_first_of("/", mLastFound);
			if(mNextFound == mLastFound && mNextFound != NPOS)
			{
				mLastFound += 1;
			}
			else
			{
				mFoundStr = mBuffer.substr(mLastFound, mNextFound != NPOS ? mNextFound-mLastFound : NPOS);
				mLastFound = mNextFound;
				break;
			}
		} while(true);
	}
	else
	{
		mFoundStr = "";
	}
}
