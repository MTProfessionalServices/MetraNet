// MTChargeReader.cpp : Implementation of CMTChargeReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTChargeReader.h"
#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargeReader

CMTChargeReader::CMTChargeReader()
{
	mpObjectContext = NULL;
}

HRESULT CMTChargeReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTChargeReader::CanBePooled()
{
	return FALSE;
} 

void CMTChargeReader::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTChargeReader::Load(IMTSessionContext* apCtxt, IMTSQLRowset* apRowset, IMTCharge** apCharge)
{
	if (!apCharge) 
		return E_POINTER;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTChargePtr Charge(__uuidof(MTPRODUCTCATALOGLib::MTCharge));
		ROWSETLib::IMTSQLRowsetPtr Rowset(apRowset);
		Charge->ID = long(Rowset->GetValue(L"id_charge"));
		Charge->Name = _bstr_t(Rowset->GetValue(L"nm_name"));
		_variant_t displayName = Rowset->GetValue(L"nm_display_name");
		if (V_VT(&displayName) == VT_NULL)
		{
			Charge->DisplayName = _bstr_t(Rowset->GetValue(L"nm_name"));
		}
		else
		{
			Charge->DisplayName = _bstr_t(displayName);
		}
		Charge->PITypeID = long(Rowset->GetValue(L"id_pi"));
		Charge->AmountPropertyID = long(Rowset->GetValue(L"id_amt_prop"));

		*apCharge = reinterpret_cast<IMTCharge *>(Charge.Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTChargeReader::Find(IMTSessionContext* apCtxt, long aChargeID, IMTCharge** apCharge)
{
	HRESULT hr (S_OK);

	if (!apCharge)
		return E_POINTER;
	
	MTAutoContext context(mpObjectContext);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init(CONFIG_DIR);
		Rowset->SetQueryTag("__GET_CHARGE_BY_ID__");
		Rowset->AddParam(L"%%ID_CHARGE%%", aChargeID);
		Rowset->Execute();
		hr = Load(apCtxt, reinterpret_cast<IMTSQLRowset*> (Rowset.GetInterfacePtr()), apCharge);
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return hr;
}


STDMETHODIMP CMTChargeReader::FindChargeProperties(IMTSessionContext *apCtxt, long aChargeID, IMTCollection **apColl)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);

	if (!apColl)
		return E_POINTER;

	try
	{
		MTObjectCollection<IMTChargeProperty> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CHILD_CHARGE_PROPERTIES__");
		rowset->AddParam("%%ID_CHARGE%%", aChargeID);
		rowset->Execute();

		MTPRODUCTCATALOGEXECLib::IMTChargePropertyReaderPtr 
			reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTChargePropertyReader));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			MTPRODUCTCATALOGEXECLib::IMTChargePropertyPtr ChargeProperty = 
				reader->Load(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
										 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(rowset.GetInterfacePtr()));
			coll.Add( reinterpret_cast<IMTChargeProperty*>( ChargeProperty.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apColl);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
