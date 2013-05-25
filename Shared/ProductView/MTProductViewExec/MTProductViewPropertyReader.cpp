// MTProductViewPropertyReader.cpp : Implementation of CMTProductViewPropertyReader
#include "StdAfx.h"
#include "MTProductViewExec.h"
#include "MTProductViewPropertyReader.h"

#include <comutil.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtautocontext.h>
#include <MSIXProperties.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTProductView.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductViewExec.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewPropertyReader

HRESULT CMTProductViewPropertyReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductViewPropertyReader::CanBePooled()
{
	return FALSE;
} 

void CMTProductViewPropertyReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTProductViewPropertyReader::LoadInternal(IMTSessionContext* apCtxt, IMTSQLRowset* apRowset, IProductViewProperty** apPVProp)
{
	if (!apPVProp) 
		return E_POINTER;
	
	try
	{
		MTPRODUCTVIEWLib::IProductViewPropertyPtr PVProp(__uuidof(MTPRODUCTVIEWLib::ProductViewProperty));
		ROWSETLib::IMTSQLRowsetPtr Rowset(apRowset);
		MTPRODUCTVIEWLib::IMTSessionContextPtr Context(apCtxt);

		PVProp->ID = long(Rowset->GetValue(L"id_prod_view_prop"));
		PVProp->ProductViewID = long(Rowset->GetValue(L"id_prod_view"));
		PVProp->dn = _bstr_t(Rowset->GetValue(L"nm_name"));
		PVProp->DataType = _bstr_t(Rowset->GetValue(L"nm_data_type"));
		PVProp->ColumnName = _bstr_t(Rowset->GetValue(L"nm_column_name"));
		PVProp->required = _bstr_t(Rowset->GetValue(L"b_required")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->CompositeIndex = _bstr_t(Rowset->GetValue(L"b_composite_idx")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->SingleIndex = _bstr_t(Rowset->GetValue(L"b_single_idx")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->PartOfKey = _bstr_t(Rowset->GetValue(L"b_part_of_key")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->Exportable = _bstr_t(Rowset->GetValue(L"b_exportable")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->Filterable = _bstr_t(Rowset->GetValue(L"b_filterable")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		PVProp->UserVisible = _bstr_t(Rowset->GetValue(L"b_user_visible")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;
		if (Rowset->GetValue(L"nm_default_value").vt != VT_NULL)
		{
			PVProp->DefaultValue = Rowset->GetValue(L"nm_default_value");
		}
		if (Rowset->GetValue(L"nm_space").vt != VT_NULL)
		{
		PVProp->EnumNamespace = _bstr_t(Rowset->GetValue(L"nm_space"));
		}
		else
			PVProp->EnumNamespace = _bstr_t("");

		if (Rowset->GetValue(L"nm_enum").vt != VT_NULL)
		{
		PVProp->EnumEnumeration = _bstr_t(Rowset->GetValue(L"nm_enum"));
		}
		else
			PVProp->EnumEnumeration = _bstr_t("");
		
		PVProp->Core = _bstr_t(Rowset->GetValue(L"b_core")) == _bstr_t(L"Y") ? VARIANT_TRUE : VARIANT_FALSE;

		if (Rowset->GetValue(L"description").vt != VT_NULL)
		{
			PVProp->Description = _bstr_t(Rowset->GetValue(L"description"));
		}

		PVProp->PropertyType = static_cast<MTPRODUCTVIEWLib::MSIX_PROPERTY_TYPE>(Convert(long(Rowset->GetValue(L"n_prop_type"))));

		PVProp->SessionContext = Context;

		*apPVProp = reinterpret_cast<IProductViewProperty *>(PVProp.Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductViewPropertyReader::Load(IMTSessionContext* apCtxt, IMTSQLRowset* apRowset, IProductViewProperty** apPVProp)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPVProp)
		return E_POINTER;
	else
		*apPVProp = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewPropertyReaderPtr This(this);
		*apPVProp = reinterpret_cast<IProductViewProperty*>(This->LoadInternal(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(apCtxt), reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSQLRowset*> (apRowset)).Detach());
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}
	
	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductViewPropertyReader::Find(IMTSessionContext* apCtxt, long aPVPropID, IProductViewProperty** apPVProp)
{
	MTAutoContext context(m_spObjectContext);

	if (!apPVProp)
		return E_POINTER;
	else
		*apPVProp = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewPropertyReaderPtr This(this);
		MTPRODUCTVIEWEXECLib::IMTSessionContextPtr Context(apCtxt);
		ROWSETLib::IMTSQLRowsetPtr Rowset(MTPROGID_SQLROWSET);
		Rowset->Init("Queries\\ProductView");
		Rowset->SetQueryTag("__SELECT_PRODUCT_VIEW_PROPERTY_BY_ID__");
		Rowset->AddParam(L"%%ID_PROD_VIEW_PROP%%", aPVPropID);
		Rowset->Execute();
		if (Rowset->GetRecordCount() > 0)
		{
			*apPVProp = reinterpret_cast<IProductViewProperty*>(This->LoadInternal(reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(apCtxt), reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSQLRowset*> (Rowset.GetInterfacePtr())).Detach());
		}
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

MSIX_PROPERTY_TYPE CMTProductViewPropertyReader::Convert(long pt)
{
	switch(pt)
	{
	case CMSIXProperties::TYPE_STRING:
		return MSIX_TYPE_STRING;
	case CMSIXProperties::TYPE_WIDESTRING:
		return MSIX_TYPE_WIDESTRING;
	case CMSIXProperties::TYPE_INT32:
		return MSIX_TYPE_INT32;
	case CMSIXProperties::TYPE_INT64:
		return MSIX_TYPE_INT64;
	case CMSIXProperties::TYPE_TIMESTAMP:
		return MSIX_TYPE_TIMESTAMP;
	case CMSIXProperties::TYPE_FLOAT:
		return MSIX_TYPE_FLOAT;
	case CMSIXProperties::TYPE_DOUBLE:
		return MSIX_TYPE_DOUBLE;
	case CMSIXProperties::TYPE_NUMERIC:
		return MSIX_TYPE_NUMERIC;
	case CMSIXProperties::TYPE_DECIMAL:
		return MSIX_TYPE_DECIMAL;
	case CMSIXProperties::TYPE_ENUM:
		return MSIX_TYPE_ENUM;
	case CMSIXProperties::TYPE_BOOLEAN:
		return MSIX_TYPE_BOOLEAN;
	case CMSIXProperties::TYPE_TIME:
		return MSIX_TYPE_TIME;
	default:
		// TODO: throw error here
		return MSIX_TYPE_STRING;
	}
}

