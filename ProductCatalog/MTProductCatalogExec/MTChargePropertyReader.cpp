// MTChargePropertyReader.cpp : Implementation of CMTChargePropertyReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTChargePropertyReader.h"
#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargePropertyReader

CMTChargePropertyReader::CMTChargePropertyReader()
{
	mpObjectContext = NULL;
}

HRESULT CMTChargePropertyReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTChargePropertyReader::CanBePooled()
{
	return FALSE;
} 

void CMTChargePropertyReader::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTChargePropertyReader::Load(IMTSessionContext* apCtxt, IMTSQLRowset* apRowset, IMTChargeProperty** apChargeProperty)
{
	if (!apChargeProperty) 
		return E_POINTER;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTChargePropertyPtr ChargeProperty(__uuidof(MTPRODUCTCATALOGLib::MTChargeProperty));
		ROWSETLib::IMTSQLRowsetPtr Rowset(apRowset);
		ChargeProperty->ID = long(Rowset->GetValue(L"id_charge_prop"));
		ChargeProperty->ChargeID = long(Rowset->GetValue(L"id_charge"));
		ChargeProperty->ProductViewPropertyID = long(Rowset->GetValue(L"id_prod_view_prop"));

		*apChargeProperty = reinterpret_cast<IMTChargeProperty *>(ChargeProperty.Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTChargePropertyReader::Find(IMTSessionContext* apCtxt, long aChargePropertyID, IMTChargeProperty** apChargeProperty)
{
	HRESULT hr (S_OK);

	if (!apChargeProperty)
		return E_POINTER;
	
	MTAutoContext context(mpObjectContext);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init(CONFIG_DIR);
		Rowset->SetQueryTag("__GET_CHARGE_PROPERTY_BY_ID__");
		Rowset->AddParam(L"%%ID_CHARGE_PROPERTY%%", aChargePropertyID);
		Rowset->Execute();
		hr = Load(apCtxt, reinterpret_cast<IMTSQLRowset*> (Rowset.GetInterfacePtr()), apChargeProperty);
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return hr;
}


