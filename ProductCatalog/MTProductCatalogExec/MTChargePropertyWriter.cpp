// MTChargePropertyWriter.cpp : Implementation of CMTChargePropertyWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTChargePropertyWriter.h"
#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargePropertyWriter

CMTChargePropertyWriter::CMTChargePropertyWriter()
{
	mpObjectContext = NULL;
}

HRESULT CMTChargePropertyWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTChargePropertyWriter::CanBePooled()
{
	return FALSE;
} 

void CMTChargePropertyWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTChargePropertyWriter::Create(IMTSessionContext* apCtxt, IMTChargeProperty* apChargeProperty, /*[out, retval]*/ long* apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apChargeProperty || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTChargePropertyPtr Charge = apChargeProperty;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->InitializeForStoredProc("InsertChargeProperty");

		rowset->AddInputParameterToStoredProc (	"a_id_charge", MTTYPE_INTEGER, INPUT_PARAM, Charge->ChargeID);
		rowset->AddInputParameterToStoredProc (	"a_id_prod_view_prop", MTTYPE_INTEGER, INPUT_PARAM, Charge->ProductViewPropertyID);
		rowset->AddOutputParameterToStoredProc ("a_id_charge_prop", MTTYPE_INTEGER, OUTPUT_PARAM);

		rowset->ExecuteStoredProc();

		//Get PK from newly created entry
		_variant_t val = rowset->GetParameterFromStoredProc("a_id_charge_prop");
		*apID = (long) val;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTChargePropertyWriter::Update(IMTSessionContext* apCtxt, IMTChargeProperty *apChargeProperty)
{
	MTAutoContext context(mpObjectContext);

	if (!apChargeProperty)
		return E_POINTER;

	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTChargePropertyPtr property = apChargeProperty;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//update t_charge_prop
		rowset->SetQueryTag("__UPDATE_CHARGE_PROPERTY_BY_ID__");

		rowset->AddParam("%%ID_CHARGE_PROPERTY%%",property->ID);
		rowset->AddParam("%%ID_CHARGE%%", property->ChargeID);
		rowset->AddParam("%%ID_PROD_VIEW_PROP%%", property->ProductViewPropertyID);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTChargePropertyWriter::Remove(IMTSessionContext* apCtxt, long aChargePropertyID)
{
	MTAutoContext context(mpObjectContext);
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
	
		rowset->SetQueryTag("__DELETE_CHARGE_PROPERTY__");
		rowset->AddParam("%%ID_CHARGE_PROPERTY%%", aChargePropertyID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

