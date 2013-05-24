/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Boris Partensky
 * $Header$
 *
 ***************************************************************************/

#include "StdAfx.h"
//#include "MTCounter.h"
#include "MTCounterType.h"



/////////////////////////////////////////////////////////////////////////////
// CMTCounterType

HRESULT CMTCounterType::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);

		LoadPropertiesMetaData(PCENTITY_TYPE_COUNTER_META_DATA);
	}	
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return mPC.CreateInstance("Metratech.MTProductCatalog");
}

void CMTCounterType::FinalRelease()
{
	mUnkMarshalerPtr.Release();
	
	if(mpParams)
	{
		delete mpParams;
		mpParams = NULL;
	}
	if(mpCounters)
	{
		delete mpCounters;
		mpCounters = NULL;
	}
}

STDMETHODIMP CMTCounterType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterType
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCounterType::get_Description(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterType::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTCounterType::get_Name(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterType::put_Name(BSTR newVal)
{
	mName = newVal;
	return PutPropertyValue("Name", newVal);
}


STDMETHODIMP CMTCounterType::get_FormulaTemplate(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mFormulaTemplate.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterType::put_FormulaTemplate(BSTR newVal)
{
	mFormulaTemplate = newVal;
	return PutPropertyValue("FormulaTemplate", newVal);;
}


STDMETHODIMP CMTCounterType::CreateCounter(IMTCounter **aCounterInstance)
{
	//Create counter of this type
	HRESULT hr(S_OK);
	CComPtr<IMTCounter> obj;

	if(!mID)
		return MTPC_OBJECT_NO_STATE;
	
	hr = obj.CoCreateInstance(__uuidof(MTCounter));
	if(FAILED(hr)) return hr;
	obj->put_TypeID(mID);
	obj->put_Type(this);
	(*aCounterInstance) = obj.Detach();

	return S_OK;
}

STDMETHODIMP CMTCounterType::RemoveCounter(long aDBID)
{
	//Deletes the counter instance of this type
	//Returns error if
	//1. Counter with this DB id does not belong to this type
	//2. Counter with this DB id is used
	//TODO: Do we have any use case for this method?

	return E_NOTIMPL;
}

STDMETHODIMP CMTCounterType::GetCounter(long aDBID, IMTCounter **apVal)
{
	//look up counter based on instance id and return it
	//return error if this counter instance doesn't belong to this counter type
	//TODO: Do we have any use case for this method?
	if (!apVal)
		return E_POINTER;
  (*apVal) = NULL;
  try
  {
	  (*apVal) = reinterpret_cast<IMTCounter*>(mPC->GetCounter(aDBID).GetInterfacePtr());
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTCounterType::GetCounters(IMTCollection **apVal)
{
	if (!apVal)
		return E_POINTER;
  (*apVal) = NULL;
  try
  {
	  (*apVal) = reinterpret_cast<IMTCollection*>(mPC->GetCountersOfType(mID).GetInterfacePtr());
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTCounterType::get_ID(long *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mID;
	return S_OK;
}

STDMETHODIMP CMTCounterType::put_ID(long newVal)
{
	mID = newVal;
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCounterType::put_Parameters(IMTCollection* apParams)
{
	HRESULT hr(S_OK);

	if(mpParams)
	{
		delete mpParams;
		mpParams = NULL;
	}

	mpParams = new MTObjectCollection<IMTCounterParameter>;
	_ASSERTE(mpParams != NULL);

	(*mpParams) = apParams;

	return hr;
}


STDMETHODIMP CMTCounterType::get_Parameters(IMTCollection** apParams)
{
	try
	{
		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);

		//On demand load internal collection and return it out
		HRESULT hr(S_OK);
		MTPRODUCTCATALOGEXECLib::IMTCounterParamReaderPtr reader("Metratech.MTCounterParamReader");
    
		if(mpParams)
		{
			hr = mpParams->CopyTo(apParams);
			return hr;
		}

		mpParams = new MTObjectCollection<IMTCounterParameter>;
		_ASSERTE(mpParams != NULL);
	
		//read in counter parameters, return them and init mpParams
		//TODO: Do we need to invalidate mpParamas if DB changes??
    MTCOUNTERLib::IMTCollectionPtr params = NULL;
    MTCOUNTERLib::IMTCounterTypePtr thisPtr = this;
    MTCOUNTERLib::IMTCounterPtr CounterPtr = thisPtr->CreateCounter();
    params = reader->FindParameterTypes
      (reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()),
        reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounter*>(CounterPtr.GetInterfacePtr()));
    (*mpParams) = (IMTCollection*)params.GetInterfacePtr();
		mpParams->CopyTo(apParams);
		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

STDMETHODIMP CMTCounterType::Load(long aDBID)
{
	//load this state from database
	HRESULT hr(S_OK);
	return hr;
}

STDMETHODIMP CMTCounterType::LoadByName(BSTR aName)
{
	//load this state from database
	HRESULT hr(S_OK);
	return hr;
}

STDMETHODIMP CMTCounterType::Save(long* apDBID)
{
	try
	{
		HRESULT hr(S_OK);

		MTPRODUCTCATALOGEXECLib::IMTCounterTypeWriterPtr writer("Metratech.MTCounterTypeWriter");
    MTPRODUCTCATALOGEXECLib::IMTCounterTypePtr thisPtr = this;
	
		if ( HasID() )
		{
			//TODO:: support Update
			return hr;
		}

		// TODO: this is NOT the right way to construct the session context.
		// We should really retrieve the credentials and login as the user invoking the script
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
			context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);

    mID = writer->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(context.GetInterfacePtr()), 
                          reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterType*>(thisPtr.GetInterfacePtr()));
    
		(*apDBID) = mID;
		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

STDMETHODIMP CMTCounterType::get_ValidForDistribution(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ValidForDistribution", pVal);
}

STDMETHODIMP CMTCounterType::put_ValidForDistribution(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ValidForDistribution", newVal);
}

