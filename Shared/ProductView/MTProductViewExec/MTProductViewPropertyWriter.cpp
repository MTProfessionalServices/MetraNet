// MTProductViewPropertyWriter.cpp : Implementation of CMTProductViewPropertyWriter
#include "StdAfx.h"
#include "MTProductViewExec.h"
#include "MTProductViewPropertyWriter.h"

#include <comutil.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtautocontext.h>
#include <RowsetDefs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductView.tlb>  rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewPropertyWriter

HRESULT CMTProductViewPropertyWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductViewPropertyWriter::CanBePooled()
{
	return FALSE;
} 

void CMTProductViewPropertyWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTProductViewPropertyWriter::Create(IMTSessionContext* apCtxt, IProductViewProperty* apPVProp, long* apID)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPVProp || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		MTPRODUCTVIEWLib::IProductViewPropertyPtr PVProp = apPVProp;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
		
		rowset->InitializeForStoredProc("InsertProductViewProperty");

		_variant_t vtNULL = "NULL";
		vtNULL.vt = VT_NULL;
		_variant_t val;

		rowset->AddInputParameterToStoredProc (	"a_id_prod_view", MTTYPE_INTEGER, INPUT_PARAM, PVProp->ProductViewID);
		rowset->AddInputParameterToStoredProc (	"a_nm_name", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->dn);
		rowset->AddInputParameterToStoredProc (	"a_nm_data_type", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->DataType);
		rowset->AddInputParameterToStoredProc (	"a_nm_column_name", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->ColumnName);
		rowset->AddInputParameterToStoredProc (	"a_b_required", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->required == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_composite_idx", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->CompositeIndex == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_single_idx", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->SingleIndex == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_part_of_key", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->PartOfKey == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_exportable", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->Exportable == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_filterable", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->Filterable == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_user_visible", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->UserVisible == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		val = PVProp->DefaultValue;
		if (VT_EMPTY == val.vt)
		{
			rowset->AddInputParameterToStoredProc (	"a_nm_default_value", MTTYPE_VARCHAR, INPUT_PARAM, vtNULL);
		}
		else
		{
			rowset->AddInputParameterToStoredProc (	"a_nm_default_value", MTTYPE_VARCHAR, INPUT_PARAM, val);
		}
		rowset->AddInputParameterToStoredProc (	"a_n_prop_type", MTTYPE_INTEGER, INPUT_PARAM, (long)PVProp->PropertyType);
		rowset->AddInputParameterToStoredProc (	"a_nm_space", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->EnumNamespace);
		rowset->AddInputParameterToStoredProc (	"a_nm_enum", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->EnumEnumeration);
		rowset->AddInputParameterToStoredProc (	"a_b_core", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->Core == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_description", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->Description);
		
		rowset->AddOutputParameterToStoredProc ("a_id_prod_view_prop", MTTYPE_INTEGER, OUTPUT_PARAM);

		rowset->ExecuteStoredProc();

		//Get PK from newly created entry
		val = rowset->GetParameterFromStoredProc("a_id_prod_view_prop");
		*apID = (long) val;

		// Let the object know its ID
		PVProp->ID = *apID;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewPropertyWriter::Update(IMTSessionContext* apCtxt, IProductViewProperty* apPVProp)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPVProp)
		return E_POINTER;
	
	try
	{
		MTPRODUCTVIEWLib::IProductViewPropertyPtr PVProp = apPVProp;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
		
		rowset->InitializeForStoredProc("UpdateProductViewProperty");

		_variant_t vtNULL = "NULL";
		vtNULL.vt = VT_NULL;
		_variant_t val;

		rowset->AddInputParameterToStoredProc ( "a_id_prod_view_prop", MTTYPE_INTEGER, INPUT_PARAM, PVProp->ID);
		rowset->AddInputParameterToStoredProc (	"a_id_prod_view", MTTYPE_INTEGER, INPUT_PARAM, PVProp->ProductViewID);
		rowset->AddInputParameterToStoredProc (	"a_nm_name", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->dn);
		rowset->AddInputParameterToStoredProc (	"a_nm_data_type", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->DataType);
		rowset->AddInputParameterToStoredProc (	"a_nm_column_name", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->ColumnName);
		rowset->AddInputParameterToStoredProc (	"a_b_required", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->required == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_composite_idx", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->CompositeIndex == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_single_idx", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->SingleIndex == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_part_of_key", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->PartOfKey == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_exportable", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->Exportable == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_filterable", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->Filterable == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		rowset->AddInputParameterToStoredProc (	"a_b_user_visible", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->UserVisible == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		val = PVProp->DefaultValue;
		if (VT_EMPTY == val.vt)
		{
			rowset->AddInputParameterToStoredProc (	"a_nm_default_value", MTTYPE_VARCHAR, INPUT_PARAM, vtNULL);
		}
		else
		{
			rowset->AddInputParameterToStoredProc (	"a_nm_default_value", MTTYPE_VARCHAR, INPUT_PARAM, val);
		}
		rowset->AddInputParameterToStoredProc (	"a_n_prop_type", MTTYPE_INTEGER, INPUT_PARAM, (long)PVProp->PropertyType);
		rowset->AddInputParameterToStoredProc (	"a_nm_space", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->EnumNamespace);
		rowset->AddInputParameterToStoredProc (	"a_nm_enum", MTTYPE_VARCHAR, INPUT_PARAM, PVProp->EnumEnumeration);
		rowset->AddInputParameterToStoredProc (	"a_b_core", MTTYPE_VARCHAR, INPUT_PARAM, 
																						PVProp->Core == VARIANT_TRUE ? _bstr_t(L"Y") : _bstr_t(L"N"));
		
		rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewPropertyWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(m_spObjectContext);
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\ProductView");
	
		rowset->SetQueryTag("__DELETE_PRODUCT_VIEW_PROPERTY__");
		rowset->AddParam("%%ID_PROD_VIEW_PROP%%", aID);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
