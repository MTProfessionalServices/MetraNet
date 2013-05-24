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
#include "MTAuth.h"
#include "MTAtomicCapabilityBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityBase

STDMETHODIMP CMTAtomicCapabilityBase::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAtomicCapabilityBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAtomicCapabilityBase::get_ID(long *pVal)
{
	(*pVal) = mID;

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::put_ID(long newVal)
{
	mID = newVal;

	return S_OK;
}


STDMETHODIMP CMTAtomicCapabilityBase::get_ParentID(long *pVal)
{
	(*pVal) = mParentID;

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::put_ParentID(long newVal)
{
	mParentID = newVal;

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::GetCapabilityType(IMTAtomicCapability* aThisPtr, IMTAtomicCapabilityType** pVal)
{
	HRESULT hr(S_OK);
	try
	{
		if (mType == NULL)
		{
			//lazy load type
			//if it tiruns out to be expensive
			//another way to di it is by setting types during serialization/deserialization
			//of security context
			MTAUTHEXECLib::IMTAtomicCapabilityPtr thisPtr = aThisPtr;
			MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr reader
				(__uuidof(MTAUTHEXECLib::MTAtomicCapabilityTypeReader));
			mType = reader->GetByInstanceID(thisPtr->ID);
      ASSERT(mType != NULL);
		}
		MTAUTHLib::IMTAtomicCapabilityTypePtr outPtr = mType;
		(*pVal) = (IMTAtomicCapabilityType*)outPtr.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::SetCapabilityType(IMTAtomicCapabilityType* newVal)
{
	mType = newVal;

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::Save(IMTAtomicCapability *aThisPtr, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	bool bUpdate(FALSE);
	ROWSETLib::IMTSQLRowsetPtr rowset;
	try
	{
		MTAUTHLib::IMTAtomicCapabilityPtr thisPtr = aThisPtr;
		MTAUTHEXECLib::IMTPrincipalPolicyWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTPrincipalPolicyWriter));
		if (thisPtr->ID > -1)
			//we'll never get here, because we don't update instances
			return S_OK;
		else
			thisPtr->ID = writer->CreateAtomicInstance((MTAUTHEXECLib::IMTAtomicCapability*)aThisPtr, (MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityBase::Remove(IMTAtomicCapability *aThisPtr, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTAUTHEXECLib::IMTCapabilityWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTCapabilityWriter));
		//it also removes all the atomic instances attached to this composite
		writer->RemoveAtomicInstance
      ((MTAUTHEXECLib::IMTAtomicCapability*)aThisPtr, (MTAUTHEXECLib::IMTPrincipalPolicy*)aPolicy);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return hr;
}
