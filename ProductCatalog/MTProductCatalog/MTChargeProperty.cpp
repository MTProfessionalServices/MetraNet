// MTChargeProperty.cpp : Implementation of CMTChargeProperty
#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include "MTProductCatalog.h"
#include "MTChargeProperty.h"

#import <MTProductView.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CMTChargeProperty

CMTChargeProperty::CMTChargeProperty()
{
	m_pUnkMarshaler = NULL;
}

STDMETHODIMP CMTChargeProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTChargeProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// FinalConstruct - besides the usual, we will initialize IDs
HRESULT CMTChargeProperty::FinalConstruct()
{

	HRESULT hr = S_OK;

	try
	{

		hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			return hr;
	
		LoadPropertiesMetaData(PCENTITY_TYPE_CHARGEPROPERTY);

		PutPropertyValue("ProductViewPropertyID", -1L);
		PutPropertyValue("ID", -1L);
		PutPropertyValue("ChargeID", -1L);
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return hr;
}

HRESULT CMTChargeProperty::Save(long* apID)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTChargePropertyWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTChargePropertyWriter));
		MTPRODUCTCATALOGLib::IMTChargePropertyPtr This(this);

		if(HasID())
		{
			hr = writer->Update(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTChargeProperty*>(this) );
			if (FAILED(hr))
				return hr;
			return GetPropertyValue("ID", apID);
		}

		//check for incomplete info
		if(This->ChargeID < 0)
			MT_THROW_COM_ERROR(MTPC_ITEM_CANNOT_BE_SAVED);
		
		long lID = writer->Create(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTChargeProperty*>(this) );
		
		(*apID) = lID;
		PutPropertyValue("ID", lID);
	 }
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
		}
	return hr;
}

STDMETHODIMP CMTChargeProperty::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTChargeProperty::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal); 
}

STDMETHODIMP CMTChargeProperty::put_ProductViewPropertyID(long newVal)
{
	return PutPropertyValue("ProductViewPropertyID", newVal);
}

STDMETHODIMP CMTChargeProperty::get_ProductViewPropertyID(long *pVal)
{
	return GetPropertyValue("ProductViewPropertyID", pVal); 
}

STDMETHODIMP CMTChargeProperty::put_ChargeID(long newVal)
{
	return PutPropertyValue("ChargeID", newVal);
}

STDMETHODIMP CMTChargeProperty::get_ChargeID(long *pVal)
{
	return GetPropertyValue("ChargeID", pVal); 
}

STDMETHODIMP CMTChargeProperty::GetProductViewProperty(IProductViewProperty** apPVProp)
{
	if (!apPVProp)
		return E_POINTER;
	else
		*apPVProp = NULL;

  try {
		MTPRODUCTCATALOGLib::IMTChargePropertyPtr This(this);
		if (-1 != This->ProductViewPropertyID)
		{
			MTPRODUCTVIEWLib::IProductViewCatalogPtr PVcatalog(__uuidof(MTPRODUCTVIEWLib::ProductViewCatalog));
			PVcatalog->SessionContext = reinterpret_cast<MTPRODUCTVIEWLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr());
			*apPVProp = reinterpret_cast<IProductViewProperty*> (PVcatalog->GetProductViewProperty(This->ProductViewPropertyID).Detach());
		}
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

