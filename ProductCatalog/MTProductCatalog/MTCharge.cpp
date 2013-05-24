// MTCharge.cpp : Implementation of CMTCharge
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include "MTProductCatalog.h"
#include "MTCharge.h"

#import <MTProductView.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CMTCharge

CMTCharge::CMTCharge()
{
	m_pUnkMarshaler = NULL;
}

STDMETHODIMP CMTCharge::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCharge
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// FinalConstruct - besides the usual, we will initialize IDs
HRESULT CMTCharge::FinalConstruct()
{

	HRESULT hr = S_OK;

	try
	{

		hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			return hr;
	
		LoadPropertiesMetaData(PCENTITY_TYPE_CHARGE);

		PutPropertyValue("PITypeID", -1L);
		PutPropertyValue("ID", -1L);
		PutPropertyValue("AmountPropertyID", -1L);
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return hr;
}

STDMETHODIMP CMTCharge::get_SessionName(BSTR *pVal)
{
	return get_Name(pVal);
}

STDMETHODIMP CMTCharge::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTCharge::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTCharge::get_AmountName(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		MTPRODUCTCATALOGLib::IMTChargePtr This(this);
		_bstr_t amt(L"c_");
		amt += This->Name;
		*pVal = amt.copy();
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTCharge::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTCharge::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCharge::get_PITypeID(long *pVal)
{
	return GetPropertyValue("PITypeID", pVal);
}

STDMETHODIMP CMTCharge::put_PITypeID(long newVal)
{
	return PutPropertyValue("PITypeID", newVal);
}

STDMETHODIMP CMTCharge::get_DisplayName(BSTR *pVal)
{
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTCharge::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

HRESULT CMTCharge::Save(long* apID)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTChargeWriter));
		MTPRODUCTCATALOGLib::IMTChargePtr This(this);

		if(HasID())
		{
			hr = writer->Update(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCharge*>(this) );
			if (FAILED(hr))
				return hr;
			return GetPropertyValue("ID", apID);
		}

		//check for incomplete info
		if(This->PITypeID < 0)
			MT_THROW_COM_ERROR(MTPC_ITEM_CANNOT_BE_SAVED);
		
		long lID = writer->Create(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCharge*>(this) );
		
		(*apID) = lID;
		PutPropertyValue("ID", lID);
	 }
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
		}
	return hr;
}

STDMETHODIMP CMTCharge::get_AmountPropertyID(long *pVal)
{
	return GetPropertyValue("AmountPropertyID", pVal); 
}

STDMETHODIMP CMTCharge::put_AmountPropertyID(long newVal)
{
	return PutPropertyValue("AmountPropertyID", newVal);
}

STDMETHODIMP CMTCharge::CreateChargeProperty(IMTChargeProperty** apChargeProperty)
{
	HRESULT hr(S_OK);
	
	try
	{

		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTCharge, MTPC_OBJECT_NO_STATE);
		}

		MTPRODUCTCATALOGLib::IMTChargePropertyPtr ChargeProperty(__uuidof(MTPRODUCTCATALOGLib::MTChargeProperty));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTChargePtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		ChargeProperty->SetSessionContext(ctxt);
		
		ChargeProperty->ChargeID = GetID();
		(*apChargeProperty) = reinterpret_cast<IMTChargeProperty*>(ChargeProperty.Detach());

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTCharge::RemoveChargeProperty(long aChargePropertyID)
{
	try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTCharge, MTPC_OBJECT_NO_STATE);
		}
		
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTChargePropertyWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTChargePropertyWriter));
		
		writer->Remove(GetSessionContextPtr(), aChargePropertyID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTCharge::GetChargeProperties(IMTCollection** apChargeProperties)
{
	if (!apChargeProperties)
		return E_POINTER;
	else
		*apChargeProperties = NULL;

  try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTCharge, MTPC_OBJECT_NO_STATE);
		}

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTChargeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTChargeReader));
		
		// call it
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr coll;
		coll = reader->FindChargeProperties(GetSessionContextPtr(), GetID());
		
		*apChargeProperties = reinterpret_cast<IMTCollection*>(coll.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTCharge::GetAmountProperty(IProductViewProperty** apPVProp)
{
	if (!apPVProp)
		return E_POINTER;
	else
		*apPVProp = NULL;

  try {
		MTPRODUCTCATALOGLib::IMTChargePtr This(this);
		if (-1 != This->AmountPropertyID)
		{
			MTPRODUCTVIEWLib::IProductViewCatalogPtr PVcatalog(__uuidof(MTPRODUCTVIEWLib::ProductViewCatalog));
			PVcatalog->SessionContext = reinterpret_cast<MTPRODUCTVIEWLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr());
			*apPVProp = reinterpret_cast<IProductViewProperty*> (PVcatalog->GetProductViewProperty(This->AmountPropertyID).Detach());
		}
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}
