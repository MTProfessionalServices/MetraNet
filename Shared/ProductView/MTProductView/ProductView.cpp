/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#include "StdAfx.h"
#include "MTProductView.h"
#include "ProductView.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <errutils.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <stdutils.h>
#include <string>
#include <iostream>
using namespace std;

#import <NameID.tlb>
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

//////////////////////////////////////////////////////////////////////////////
// CProductView

CProductView::CProductView()
{
	m_pUnkMarshaler = NULL;
	mViewID = -1;
	mID = -1;
	mHasChildren = VARIANT_FALSE;
  mCanResubmitFrom = VARIANT_FALSE;
}

STDMETHODIMP CProductView::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IProductView
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



STDMETHODIMP CProductView::Init(BSTR aProductViewName, VARIANT_BOOL aHasChildren)
{
	try
	{
		HRESULT hr;
		
		mProductViewName = aProductViewName;
		mHasChildren = aHasChildren;

		// Create the .msixdef file name to speed up loading
		CProductViewCollection pvcoll;
		static const std::wstring::size_type npos = -1;
		std::wstring filename((const wchar_t *) mProductViewName);
		std::wstring::size_type last = filename.find_last_of(L"/");
		if(last == npos)
		{
			if (!pvcoll.Initialize())
			{
				return Error("Failed to locate product view definitions");
			}
		}
		else
		{
			if (!pvcoll.Initialize((filename.substr(last+1) + std::wstring(L".msixdef")).c_str()))
			{
				std::wstring err(L"Failed to locate product view definition for file: ");
				err += filename.substr(last+1) + std::wstring(L".msixdef");
				return Error(err.c_str());
			}
		}

		CMSIXDefinition* pPV;
		if(!pvcoll.FindProductView((const wchar_t *)mProductViewName, pPV))
		{
			const ErrorObject * errobj = pvcoll.GetLastError();
			if (NULL != errobj)
			{
				string buffer;
				StringFromError(buffer, "MTPRODUCTVIEWLib::ProductView", errobj);
				return Error(buffer.c_str());
			} 
			else
			{
				char buf [1024];
				sprintf(buf, "Product View with name %s not found", (const char *)mProductViewName);
				return Error(buf);
			}
		}

		// Copy properties from msixdef into product view
		ASSERT (pPV) ;
		mTableName = _bstr_t(pPV->GetTableName().c_str());
		mViewID = pPV->GetID();
    mCanResubmitFrom = pPV->GetCanResubmitFrom() ? VARIANT_TRUE : VARIANT_FALSE;

		// foreach msix property ...
		MSIXPropertiesList::iterator Iter;
		for (Iter = pPV->GetMSIXPropertiesList().begin();
				 Iter != pPV->GetMSIXPropertiesList().end();
				 ++Iter)
		{
			// get the product view property and copy the parameters into a COM object...
			CMSIXProperties *pPVProp = *Iter;
			if (FAILED(hr = AddMSIXProperty(pPVProp, false))) return hr;
		}

		// Add unique keys
		//
		UniqueKeyList& ukList = pPV->GetUniqueKeyList();

		// foreach unique key...
		int i = 1;
		UniqueKeyList::iterator uk;  
		for ( uk = ukList.begin(); uk != ukList.end(); uk++ )
		{
			UniqueKey *pUK = *uk;
			if (FAILED(hr = AddUniqueKey(pUK)))
				return hr;
		}
	
		// Add information about the core properties
		if (FAILED(hr = GetCoreProperties())) return hr;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

HRESULT CProductView::AddUniqueKey(UniqueKey * pUK)
{
	MTPRODUCTVIEWLib::IProductViewPtr thisPtr = this;

	MTPRODUCTVIEWLib::IProductViewUniqueKeyPtr pUniqueKey("Metratech.ProductViewUniqueKey.1");
	//MTPRODUCTVIEWLib::IProductViewUniqueKeyPtr pUniqueKey(__uuidof(MTPRODUCTVIEWLib::ProductViewUniqueKey));
	
	// set key's defined name
	std::wstring ukname = pUK->GetName();
	pUniqueKey->name = ukname.c_str();

	// set key's table name
	std::wstring tabname = L"t_uk_" + ukname;
	pUniqueKey->tablename = tabname.c_str();
	
	// set key's productview
	pUniqueKey->ProductView = thisPtr;

	// foreach column in the unique key, 
	//		find corresponding product view property ptr 
	//		save ptr in product view unique key collection
	//		preserve order
	vector<CMSIXProperties *> cols = pUK->GetColumnProperties();
	vector<CMSIXProperties *>::iterator col;
	std::wstring colname;
	for ( col = cols.begin(); col != cols.end(); col++ ) 
	{
		// find the product view property key...
		// 1. get name from msixdef unique key property collection
		colname = (*col)->GetDN();

		// 2. find the column in the (our) property list
		MTPRODUCTVIEWLib::IProductViewPropertyPtr pProp;

		pProp = thisPtr->GetPropertyByName(_bstr_t(colname.c_str()));
		pUniqueKey->AddProperty(pProp);
	}

	mUniqueKeys.Add(reinterpret_cast<IProductViewUniqueKey*>(pUniqueKey.GetInterfacePtr()));
	return S_OK;
}

MSIX_PROPERTY_TYPE CProductView::Convert(CMSIXProperties::PropertyType pt)
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

STDMETHODIMP CProductView::get_TableName(BSTR *pVal)
{
	try 
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = mTableName.copy();
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductView::put_TableName(BSTR newVal)
{
	try 
	{
		mTableName = newVal;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductView::get_Name(BSTR *pVal)
{
	try 
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = mProductViewName.copy();
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductView::put_Name(BSTR newVal)
{
	try 
	{
		mProductViewName = newVal;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductView::GetProperties(IMTCollection **pProperties)
{
	try
	{
		HRESULT hr(S_OK);
		MTPRODUCTVIEWLib::IProductViewPtr This(this);
		if (This->ID != -1)
		{
			long count;
			hr = mProperties.Count(&count);
			if (count == 0)
			{
				MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr reader(__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewReader));
				mProperties = reinterpret_cast<IMTCollection*>(reader->FindProperties(mSessionContextExec, This->ID).GetInterfacePtr());
			}
		}
		hr = mProperties.CopyTo(pProperties);
		return hr;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
}

STDMETHODIMP CProductView::GetUniqueKeys(IMTCollection **pKeys)
{
	return mUniqueKeys.CopyTo(pKeys);
}

STDMETHODIMP CProductView::get_ViewID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mViewID;

	return S_OK;
}

STDMETHODIMP CProductView::put_ViewID(long newVal)
{
	mViewID = newVal;
	return S_OK;
}


STDMETHODIMP CProductView::get_HasChildren(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mHasChildren;

	return S_OK;
}

STDMETHODIMP CProductView::get_CanResubmitFrom(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mCanResubmitFrom;

	return S_OK;
}

STDMETHODIMP CProductView::put_CanResubmitFrom(VARIANT_BOOL newVal)
{
  mCanResubmitFrom = newVal;
	return S_OK;
}

HRESULT CProductView::GetPropertyByName(BSTR aDN, IProductViewProperty* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		_bstr_t bstrDN(aDN);
		MTPRODUCTVIEWLib::IProductViewPtr This(this);
		MTPRODUCTVIEWLib::IMTCollectionPtr properties = This->GetProperties();

		// For the moment let's do linear search
		int count = properties->Count;

		// find index of particular child in the collection
		for(int i = 1; i <= count ; i++)
		{
			MTPRODUCTVIEWLib::IProductViewPropertyPtr ptrProperty = properties->GetItem(i);

			if (0 == _wcsicmp(bstrDN, ptrProperty->dn))
			{
				*pVal = reinterpret_cast<IProductViewProperty*> (ptrProperty.Detach());
				return S_OK;
			}
		}
	}
	catch(_com_error & e)
	{
		return returnProductViewError(e);
	}

	// Return OK even if we don't find the property.
	
	return S_OK;
}

HRESULT CProductView::GetPropertyByColumnName(BSTR aColumnName, IProductViewProperty* *pVal)
{
	if(!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	try
	{
		_bstr_t bstrColumnName(aColumnName);

		// For the moment let's do linear search
		MTPRODUCTVIEWLib::IProductViewPtr This(this);
		MTPRODUCTVIEWLib::IMTCollectionPtr properties = This->GetProperties();

		// For the moment let's do linear search
		int count = properties->Count;

		// find index of particular child in the collection
		for(int i = 1; i <= count ; i++)
		{
			MTPRODUCTVIEWLib::IProductViewPropertyPtr ptrProperty = properties->GetItem(i);

			if (0 == _wcsicmp(bstrColumnName, ptrProperty->ColumnName))
			{
				*pVal = reinterpret_cast<IProductViewProperty*> (ptrProperty.Detach());
				return S_OK;
			}
		}
	}
	catch(_com_error & e)
	{
		return returnProductViewError(e);
	}

	// Return OK even if we don't find the property.
	
	return S_OK;
}

HRESULT CProductView::AddMSIXProperty(CMSIXProperties * apPVProp, bool aIsCore)
{
	if (!apPVProp)
		return E_POINTER;
	try
	{
		NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);
		MTPRODUCTVIEWLib::IProductViewPtr This (this);
		MTPRODUCTVIEWLib::IProductViewPropertyPtr pProperty("Metratech.ProductViewProperty.1");
		
		// Every property needs a "parent" pointer.  Propagate session context.
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		// Fill in all of the properties
		pProperty->dn = _bstr_t(apPVProp->GetDN().c_str()) ;
		pProperty->ColumnName = _bstr_t(apPVProp->GetColumnName().c_str()) ;
		pProperty->DataType = _bstr_t(apPVProp->GetDataType().c_str()) ;
		pProperty->PropertyType = static_cast<MTPRODUCTVIEWLib::MSIX_PROPERTY_TYPE>(Convert(apPVProp->GetPropertyType()));
		pProperty->UserVisible = apPVProp->GetUserVisible() ;
		pProperty->Filterable = apPVProp->GetFilterable() ;
		pProperty->Exportable = apPVProp->GetExportable() ;
		pProperty->required = apPVProp->GetIsRequired();
		if (strcasecmp(apPVProp->GetDataType(), wstring(DB_ENUM_TYPE)) == 0)
		{
			// get the namespace and enumeration ...
			pProperty->EnumNamespace = _bstr_t(apPVProp->GetEnumNamespace().c_str()) ;
			pProperty->EnumEnumeration = _bstr_t(apPVProp->GetEnumEnumeration().c_str()) ;
		}
		// get the description id ... create the string then get it ...
		if (!aIsCore)
		{
			pProperty->DescriptionID = (long) aNameID->GetNameID(mProductViewName + _bstr_t(L"/") + pProperty->dn);
		}
		else
		{
			pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/") + pProperty->dn);
		}
		// Set the default value.  Note that this will be converted from string...
		pProperty->DefaultValue = _variant_t(apPVProp->GetDefault().c_str());
		pProperty->Core = aIsCore ? VARIANT_TRUE : VARIANT_FALSE;
		pProperty->Description = _bstr_t(apPVProp->GetDescription().c_str()) ;
		// Save the property in my collection.
		HRESULT hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr))
			return hr;


// 			// do a find to see id the property exists ...
// 			if (mPropColl.contains (wstrName))
// 			{
// 				mLogger->LogVarArgs (LOG_ERROR, 
// 														L"Found duplicate property with name = %s in product view with name = %s.", 
// 														wstrName.c_str(), mName.c_str()) ;
// 				bRetCode = FALSE ;
// 			}
// 			// add the element to the view collection ...
// 			mPropColl.insertKeyAndValue (pDBProperty->GetName(), pDBProperty) ;
	}
	catch(_com_error & e)
	{
		return returnProductViewError(e);
	}
	return S_OK;
}

HRESULT CProductView::GetCoreProperties()
{
	try
	{
		HRESULT hr;

		NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);

		// For the moment, hard code the properties.  Later should move these
		// into an XML file so that they can be changed if the core queries are
		// tweaked.

		MTPRODUCTVIEWLib::IProductViewPropertyPtr pProperty;
		MTPRODUCTVIEWLib::IProductViewPtr This(this);

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"ViewID") ;
		pProperty->ColumnName = _bstr_t(L"ViewID") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/ViewID"));
		pProperty->DataType = _bstr_t(L"int32") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_INT32;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"SessionID") ;
		pProperty->ColumnName = _bstr_t(L"SessionID") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/SessionID"));
		pProperty->DataType = _bstr_t(L"int32") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_INT32;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"Amount") ;
		pProperty->ColumnName = _bstr_t(L"Amount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/Amount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

    pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"DisplayAmount") ;
		pProperty->ColumnName = _bstr_t(L"DisplayAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/DisplayAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

    // Adjustment fields
    //  ,au.AtomicPrebillAdjustmentAmount
    //  ,au.AtomicPostbillAdjustmentAmount

    pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"PrebillAdjustmentAmount") ;
		pProperty->ColumnName = _bstr_t(L"AtomicPrebillAdjAmt") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/PrebillAdjustmentAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

    pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"PostbillAdjustmentAmount") ;
		pProperty->ColumnName = _bstr_t(L"AtomicPostbillAdjAmt") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/PostbillAdjustmentAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"TaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"TaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/TaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"FederalTaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"FederalTaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/FederalTaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"StateTaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"StateTaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/StateTaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"CountyTaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"CountyTaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/CountyTaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"LocalTaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"LocalTaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/LocalTaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"OtherTaxAmount") ;
		pProperty->ColumnName = _bstr_t(L"OtherTaxAmount") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/OtherTaxAmount"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_FALSE;
		pProperty->Exportable = VARIANT_FALSE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"AmountWithTax") ;
		pProperty->ColumnName = _bstr_t(L"AmountWithTax") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/AmountWithTax"));
		pProperty->DataType = _bstr_t(L"decimal") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"Currency") ;
		pProperty->ColumnName = _bstr_t(L"Currency") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/Currency"));
		pProperty->DataType = _bstr_t(L"string") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_STRING;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"AccountID") ;
		pProperty->ColumnName = _bstr_t(L"AccountID") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/AccountID"));
		pProperty->DataType = _bstr_t(L"int32") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_INT32;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"DisplayName") ;
		pProperty->ColumnName = _bstr_t(L"displayname") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/PayeeDisplayName"));
		pProperty->DataType = _bstr_t(L"string") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_STRING;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"Timestamp") ;
		pProperty->ColumnName = _bstr_t(L"Timestamp") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/Timestamp"));
		pProperty->DataType = _bstr_t(L"timestamp") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_TIMESTAMP;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;

		pProperty.CreateInstance("Metratech.ProductViewProperty.1");		
		pProperty->ProductView = This;
		pProperty->SessionContext = This->SessionContext;
		pProperty->dn = _bstr_t(L"SEDisplayName") ;
		pProperty->ColumnName = _bstr_t(L"nm_login") ;
		pProperty->DescriptionID = (long) aNameID->GetNameID(_bstr_t(L"metratech.com/SEDisplayName"));
		pProperty->DataType = _bstr_t(L"string") ;
		pProperty->PropertyType = MTPRODUCTVIEWLib::MSIX_TYPE_STRING;
		pProperty->UserVisible = VARIANT_TRUE;
		pProperty->Filterable = VARIANT_TRUE;
		pProperty->Exportable = VARIANT_TRUE;
		pProperty->required = VARIANT_TRUE;
		pProperty->Core = VARIANT_TRUE;
		hr = mProperties.Add(reinterpret_cast<IProductViewProperty*>(pProperty.GetInterfacePtr()));
		if (FAILED(hr)) return hr;
	} 
	catch (_com_error & e)
	{
		return returnProductViewError(e);
	}

	return S_OK;
}

STDMETHODIMP CProductView::putref_SessionContext(IMTSessionContext* newVal)
{
	try
	{
		mSessionContext = newVal;
		mSessionContextExec = newVal;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

STDMETHODIMP CProductView::get_SessionContext(IMTSessionContext* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
    MTPRODUCTVIEWLib::IMTSessionContextPtr ptr = mSessionContext;

    *pVal = reinterpret_cast<IMTSessionContext*> (ptr.Detach());
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

HRESULT CProductView::Save(long* apID)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewWriterPtr writer( __uuidof(MTPRODUCTVIEWEXECLib::MTProductViewWriter));
		MTPRODUCTVIEWEXECLib::IProductViewPtr This(this);

		if(-1 != This->ID)
		{
			writer->RecursiveUpdate(This->SessionContext,  This);
		}
		else
		{
			//check for incomplete info
			if(This->ViewID < 0)
				return Error("Incomplete product view");
			
			long lID = writer->Create(This->SessionContext, This );
			
			// The write has the responsibility for storing the id in me.
			ASSERT(This->ID == lID);
		}
		*apID = This->ID;
	}
	catch(_com_error& e)
	{
		return returnProductViewError(e);
	}
	return hr;
}

STDMETHODIMP CProductView::get_ID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mID;

	return S_OK;
}

STDMETHODIMP CProductView::put_ID(long newVal)
{
	mID = newVal;

	return S_OK;
}

