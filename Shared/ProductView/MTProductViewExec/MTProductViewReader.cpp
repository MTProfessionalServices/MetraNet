// MTProductViewReader.cpp : Implementation of CMTProductViewReader
#include "StdAfx.h"
#include "MTProductViewExec.h"
#include "MTProductViewReader.h"

#include <comutil.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtautocontext.h>
#include <MTObjectCollection.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductView.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewReader

HRESULT CMTProductViewReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductViewReader::CanBePooled()
{
	return FALSE;
} 

void CMTProductViewReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTProductViewReader::Load(IMTSessionContext* apCtxt, IMTSQLRowset* apRowset, IProductView** apPV)
{
	if (!apPV) 
		return E_POINTER;
	
	try
	{
		MTPRODUCTVIEWLib::IProductViewPtr PV(__uuidof(MTPRODUCTVIEWLib::ProductView));
		ROWSETLib::IMTSQLRowsetPtr Rowset(apRowset);
		MTPRODUCTVIEWLib::IMTSessionContextPtr Context(apCtxt);

		PV->ID = long(Rowset->GetValue(L"id_prod_view"));
    PV->ViewID = long(Rowset->GetValue(L"id_view"));
		PV->name = _bstr_t(Rowset->GetValue(L"nm_name"));
		PV->tablename = _bstr_t(Rowset->GetValue(L"nm_table_name"));
    PV->CanResubmitFrom = _bstr_t(Rowset->GetValue(L"b_can_resubmit_from")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PV->SessionContext = Context;

		*apPV = reinterpret_cast<IProductView *>(PV.Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductViewReader::Find(IMTSessionContext* apCtxt, long aPVID, IProductView** apPV)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPV) 
		return E_POINTER;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr This(this);
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init("Queries\\ProductView");
		Rowset->SetQueryTag("__SELECT_PRODUCT_VIEW_BY_ID__");
		Rowset->AddParam(L"%%ID_PROD_VIEW%%", aPVID);
		Rowset->Execute();
		*apPV = reinterpret_cast<IProductView*>(This->Load(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(apCtxt), reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSQLRowset*> (Rowset.GetInterfacePtr())).Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewReader::FindProperties(IMTSessionContext* apCtxt, long aPVID, IMTCollection** apColl)
{
	if (!apColl) 
		return E_POINTER;

	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);

	if (!apColl)
		return E_POINTER;


	try
	{
		MTObjectCollection<IProductViewProperty> coll;
		
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init("Queries\\ProductView");
		Rowset->SetQueryTag("__SELECT_PRODUCT_VIEW_PROPERTY_CHILDREN__");
		Rowset->AddParam(L"%%ID_PROD_VIEW%%", aPVID);
		Rowset->Execute();

		while(Rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			MTPRODUCTVIEWEXECLib::IMTProductViewPropertyReaderPtr 
				reader(__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewPropertyReader));

			MTPRODUCTVIEWEXECLib::IProductViewPropertyPtr Property = 
				reader->Load(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(apCtxt), 
										 reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSQLRowset*>(Rowset.GetInterfacePtr()));
			coll.Add( reinterpret_cast<IProductViewProperty*>( Property.GetInterfacePtr() ) );
			Rowset->MoveNext();
		}

		coll.CopyTo(apColl);
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return hr;
}

STDMETHODIMP CMTProductViewReader::FindByName(IMTSessionContext* apCtxt, BSTR aPVName, IProductView** apPV)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPV) 
		return E_POINTER;

	*apPV = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr This(this);
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init("Queries\\ProductView");
		Rowset->SetQueryTag("__SELECT_PRODUCT_VIEW_BY_NAME__");
		Rowset->AddParam(L"%%NM_NAME%%", _bstr_t(aPVName));
		Rowset->Execute();
		if (Rowset->GetRecordCount() > 0)
		{
		*apPV = reinterpret_cast<IProductView*>(This->Load(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(apCtxt), reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSQLRowset*> (Rowset.GetInterfacePtr())).Detach());
		}
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

