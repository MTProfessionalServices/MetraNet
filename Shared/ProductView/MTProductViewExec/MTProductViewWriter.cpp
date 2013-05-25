// MTProductViewWriter.cpp : Implementation of CMTProductViewWriter
#include "StdAfx.h"
#include "MTProductViewExec.h"
#include "MTProductViewWriter.h"
#include <mtx.h>

#include <comutil.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtautocontext.h>
#include <mttime.h>
#include <RowsetDefs.h>
#include <iostream>
using namespace std;

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductView.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewWriter

CMTProductViewWriter::CMTProductViewWriter()
{
}

HRESULT CMTProductViewWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductViewWriter::CanBePooled()
{
	return FALSE;
} 

void CMTProductViewWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTProductViewWriter::Create(IMTSessionContext* apCtxt, IProductView* apPV, long* apID)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPV || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		MTPRODUCTVIEWEXECLib::IProductViewPtr PV = apPV;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
		rowset->InitializeForStoredProc("InsertProductView");

		rowset->AddInputParameterToStoredProc ("a_id_view", MTTYPE_INTEGER, INPUT_PARAM, PV->ViewID);
		rowset->AddInputParameterToStoredProc ("a_nm_name", MTTYPE_VARCHAR, INPUT_PARAM, PV->Name);
		rowset->AddInputParameterToStoredProc ("a_dt_modified", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rowset->AddInputParameterToStoredProc ("a_nm_table_name", MTTYPE_VARCHAR, INPUT_PARAM, PV->TableName);
		rowset->AddInputParameterToStoredProc ("a_b_can_resubmit_from", MTTYPE_VARCHAR, INPUT_PARAM, PV->CanResubmitFrom == VARIANT_TRUE ? L"Y" : L"N");
		rowset->AddOutputParameterToStoredProc ("a_id_prod_view", MTTYPE_INTEGER, OUTPUT_PARAM);

		rowset->ExecuteStoredProc();

		//Get PK from newly created entry
		_variant_t val = rowset->GetParameterFromStoredProc("a_id_prod_view");
		*apID = (long) val;
		PV->ID = *apID;

		// Insert all of the properties with the prod view id
		//
		MTPRODUCTVIEWEXECLib::IMTCollectionPtr properties;
		properties = PV->GetProperties();
			
		int count = properties->Count;
		for(int i=1; i<=count; i++)
		{
			MTPRODUCTVIEWEXECLib::IProductViewPropertyPtr property = properties->GetItem(i);
			MTPRODUCTVIEWEXECLib::IMTProductViewPropertyWriterPtr writer(__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewPropertyWriter));
			property->ProductViewID = PV->ID;
			writer->Create(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext *>(apCtxt), property);
		}

		// Insert all the unique keys with this prod view's id
		//
		MTPRODUCTVIEWEXECLib::IMTCollectionPtr uniquekeys;
		uniquekeys = PV->GetUniqueKeys();

		int ukcount = uniquekeys->Count;
		for(int i=1; i<=ukcount; i++)
		{
			MTPRODUCTVIEWLib::IProductViewUniqueKeyPtr puk = uniquekeys->GetItem(i);

			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init("Queries\\ProductView");
			rowset->InitializeForStoredProc("InsertProductViewUniqueKey");
			rowset->AddInputParameterToStoredProc("id_prod_view", MTTYPE_INTEGER, INPUT_PARAM, PV->ID);
			rowset->AddInputParameterToStoredProc("constraint_name", MTTYPE_VARCHAR, INPUT_PARAM, puk->name);
			rowset->AddInputParameterToStoredProc("nm_table_name", MTTYPE_VARCHAR, INPUT_PARAM, puk->tablename);
			rowset->AddOutputParameterToStoredProc("id_unique_cons", MTTYPE_INTEGER, OUTPUT_PARAM);
			rowset->ExecuteStoredProc();

			// Get new uniquekey id from database
			puk->ID = (long)rowset->GetParameterFromStoredProc("id_unique_cons");

			// Insert all unique key columns, setting the unique key id (owner)
			//
			MTPRODUCTVIEWEXECLib::IMTCollectionPtr keycols;
			keycols = puk->GetProperties();

			int keycolcnt = keycols->Count;
			for(int j=1; j<=keycolcnt; j++)
			{
				MTPRODUCTVIEWLib::IProductViewPropertyPtr col = keycols->GetItem(j);

				ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
				rowset->Init("Queries\\ProductView");
				rowset->InitializeForStoredProc("InsertProductViewUniqueKeyCol");
				rowset->AddInputParameterToStoredProc("id_unique_cons", MTTYPE_INTEGER, INPUT_PARAM, puk->ID);
				rowset->AddInputParameterToStoredProc("id_prod_view_prop", MTTYPE_INTEGER, INPUT_PARAM, col->ID);
				rowset->AddInputParameterToStoredProc("position", MTTYPE_INTEGER, INPUT_PARAM, j);
				rowset->ExecuteStoredProc();
			}
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewWriter::Update(IMTSessionContext* apCtxt, IProductView* apPV)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPV)
		return E_POINTER;

	try
	{
		MTPRODUCTVIEWEXECLib::IProductViewPtr PV = apPV;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
		
		//update t_prod_view
		rowset->SetQueryTag("__UPDATE_PRODUCT_VIEW_BY_ID__");

		rowset->AddParam("%%ID_PROD_VIEW%%",PV->ID);
		rowset->AddParam("%%ID_VIEW%%",PV->ViewID);
		rowset->AddParam("%%NM_NAME%%", PV->Name);
		rowset->AddParam("%%NM_TABLE%%", PV->TableName);
    rowset->AddParam("%%B_CAN_RESUBMIT_FROM", PV->CanResubmitFrom == VARIANT_TRUE ? "Y" : "N");
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewWriter::RecursiveUpdate(IMTSessionContext* apCtxt, IProductView* apPV)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPV)
		return E_POINTER;

	try
	{
		MTPRODUCTVIEWEXECLib::IProductViewPtr PV = apPV;

		MTPRODUCTVIEWEXECLib::IMTProductViewWriterPtr pvwriter (__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewWriter));
		pvwriter->Update(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext *>(apCtxt), PV);

		// Create all of the kiddies and let them know what my id is
		MTPRODUCTVIEWEXECLib::IMTCollectionPtr properties;
		properties = PV->GetProperties();
			
		int count = properties->Count;
		for(int i=1; i<=count; i++)
		{
			MTPRODUCTVIEWEXECLib::IProductViewPropertyPtr property = properties->GetItem(i);
			MTPRODUCTVIEWEXECLib::IMTProductViewPropertyWriterPtr writer(__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewPropertyWriter));
			property->ProductViewID = PV->ID;
			writer->Update(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext *>(apCtxt), property);
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(m_spObjectContext);
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
	
		// remove uniquekey columns first
		rowset->SetQueryTag("__DELETE_PRODUCT_VIEW_UNIQUEKEY_COLUMNS__");
		rowset->AddParam("%%ID_PROD_VIEW%%", aID);
		rowset->Execute();

		// uniquekey next
		rowset->SetQueryTag("__DELETE_PRODUCT_VIEW_UNIQUEKEY__");
		rowset->AddParam("%%ID_PROD_VIEW%%", aID);
		rowset->Execute();

		// remove the properties
		rowset->SetQueryTag("__DELETE_CHILD_PRODUCT_VIEW_PROPERTY__");
		rowset->AddParam("%%ID_PROD_VIEW%%", aID);
		rowset->Execute();

		// finally the productview itself
		rowset->SetQueryTag("__DELETE_PRODUCT_VIEW__");
		rowset->AddParam("%%ID_PROD_VIEW%%", aID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
