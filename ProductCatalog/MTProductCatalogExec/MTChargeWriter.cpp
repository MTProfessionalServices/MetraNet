// MTChargeWriter.cpp : Implementation of CMTChargeWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTChargeWriter.h"
#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTChargeWriter

CMTChargeWriter::CMTChargeWriter()
{
	mpObjectContext = NULL;
}

HRESULT CMTChargeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTChargeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTChargeWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTChargeWriter::Create(IMTSessionContext* apCtxt, IMTCharge* apCharge, /*[out, retval]*/ long* apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apCharge || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTChargePtr charge = apCharge;

		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long idProp = baseWriter->CreateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), PCENTITY_TYPE_CHARGE, charge->Name, "", charge->DisplayName);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//insert into t_charge
		rowset->SetQueryTag("__ADD_CHARGE__");

		rowset->AddParam("%%ID_CHARGE%%",idProp);
		rowset->AddParam("%%NAME%%", charge->Name);
		rowset->AddParam("%%ID_PI%%", charge->PITypeID);
		rowset->AddParam("%%ID_AMT_PROP%%", charge->AmountPropertyID);
		rowset->Execute();

		*apID = idProp;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTChargeWriter::Update(IMTSessionContext* apCtxt, IMTCharge *apCharge)
{
	MTAutoContext context(mpObjectContext);

	if (!apCharge)
		return E_POINTER;

	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTChargePtr charge = apCharge;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		// update base props
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->UpdateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																			 charge->Name, "",charge->DisplayName, charge->ID);
		//update t_charge
		rowset->SetQueryTag("__UPDATE_CHARGE_BY_ID__");

		rowset->AddParam("%%ID_CHARGE%%",charge->ID);
		rowset->AddParam("%%ID_PI%%", charge->PITypeID);
		rowset->AddParam("%%NAME%%", charge->Name);
		rowset->AddParam("%%ID_AMT_PROP%%", charge->AmountPropertyID);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTChargeWriter::Remove(IMTSessionContext* apCtxt, long aChargeID)
{
	MTAutoContext context(mpObjectContext);
	
	try
	{
		/////////////////////////////
		// find charge by aChargeID
		MTPRODUCTCATALOGEXECLib::IMTChargeReaderPtr chargeReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTChargeReader));
		MTPRODUCTCATALOGLib::IMTChargePtr Charge;
		Charge = chargeReader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aChargeID); 

		if (Charge == NULL)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		/////////////////////////////
		// delete charge properties
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr properties = Charge->GetChargeProperties();

		int iChargePropertyCount = properties->Count;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTChargeWriter::Remove(%d) removes %d Charge Properties", aChargeID, iChargePropertyCount);

		// now iterate through charges and delete them.
		for(int i = 1; i <= iChargePropertyCount; ++i)
		{
			// get Charge Property
			MTPRODUCTCATALOGLib::IMTChargePropertyPtr property = properties->GetItem(i);
			long lChargePropertyID = property->ID;
			Charge->RemoveChargeProperty(lChargePropertyID);
		}

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
	
		rowset->SetQueryTag("__DELETE_CHARGE__");
		rowset->AddParam("%%ID_CHARGE%%", aChargeID);
		rowset->Execute();

		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
											 aChargeID);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

