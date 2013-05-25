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
#include "ProductViewProperty.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <xmlconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <DBLocale.h>
#include <autoinstance.h>
#include <MTDecimalVal.h>

#import <MTEnumConfigLib.tlb>
#import <NameID.tlb>

/////////////////////////////////////////////////////////////////////////////
// CProductViewProperty

CProductViewProperty::CProductViewProperty()
{
	m_pUnkMarshaler = NULL;
	mRequired = VARIANT_FALSE;
	mDescriptionID = -1;
	mCompositeIndex = VARIANT_FALSE;
	mSingleIndex = VARIANT_FALSE;
	mPartOfKey = VARIANT_FALSE;
	mExportable = VARIANT_FALSE;
	mFilterable = VARIANT_FALSE;
	mUserVisible = VARIANT_FALSE;
	mDefaultValue = _variant_t(L"");
	mPropertyType = MSIX_TYPE_STRING;
	mCore = VARIANT_FALSE;
	mID = -1;
	mProductViewID = -1;
	mDescription = L"";
}

STDMETHODIMP CProductViewProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IProductViewProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CProductViewProperty::get_UserVisible(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mUserVisible;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_UserVisible(VARIANT_BOOL newVal)
{
	mUserVisible = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_Filterable(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mFilterable;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_Filterable(VARIANT_BOOL newVal)
{
	mFilterable = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_Exportable(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mExportable;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_Exportable(VARIANT_BOOL newVal)
{
	mExportable = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_PartOfKey(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mPartOfKey;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_PartOfKey(VARIANT_BOOL newVal)
{
	mPartOfKey = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_SingleIndex(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mSingleIndex;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_SingleIndex(VARIANT_BOOL newVal)
{
	mSingleIndex = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_CompositeIndex(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mCompositeIndex;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_CompositeIndex(VARIANT_BOOL newVal)
{
	mCompositeIndex = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_DescriptionID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
  {
    if(mDescriptionID < 0)
    {
      MTPRODUCTVIEWLib::IProductViewPropertyPtr ThisPtr = this;
      MTPRODUCTVIEWLib::IProductViewPtr PVPtr = ThisPtr->ProductView;
      ASSERT(PVPtr != NULL);
    	NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);
      mDescriptionID = (long) aNameID->GetNameID(PVPtr->name + _bstr_t(L"/") + mDN);
	  }
		*pVal = mDescriptionID;
  }

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_DescriptionID(long newVal)
{
	mDescriptionID = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_Required(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mRequired;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_Required(VARIANT_BOOL newVal)
{
	mRequired = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_DN(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mDN.copy();

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_DN(BSTR newVal)
{
	mDN = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_ColumnName(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mColumnName.copy();

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_ColumnName(BSTR newVal)
{
	mColumnName = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_DataType(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mDataType.copy();

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_DataType(BSTR newVal)
{
	mDataType = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_DefaultValue(VARIANT *pVal)
{
  try
  {
    if (!pVal)
      return E_POINTER;
    else
      *pVal = mDefaultValue;
  }
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

// TODO: Fix this method so that it accepts not only string but a
// variant of any type compatible with the relevant MSIX type.
STDMETHODIMP CProductViewProperty::put_DefaultValue(VARIANT newVal)
{
	try
	{
		_bstr_t bstrVal = (_bstr_t)newVal;

		//if we fail anywhere, the default value variant will be empty
		//and correspond to a NULL in the database

		mDefaultValue.ChangeType(VT_EMPTY);
	
		//if no default is provided then leave the variant's type as VT_EMPTY
		if (bstrVal == _bstr_t(L""))
			return S_OK;
	
		switch (mPropertyType) 
		{
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_INT32: 
    {
      int intVal;
      if (!XMLConfigNameVal::ConvertToInteger((const wchar_t *)bstrVal, &intVal))
        return Error("Failure converting string to integer");
      mDefaultValue = (long) intVal;
      break;
    }
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_INT64: 
    {
      __int64 int64Val;
      if (!XMLConfigNameVal::ConvertToBigInteger((const wchar_t *)bstrVal, &int64Val))
        return Error("Failure converting string to integer");
      mDefaultValue = int64Val;
      break;
    }
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_FLOAT:
		case MTPRODUCTVIEWLib::MSIX_TYPE_DOUBLE: 
    {
      double doubleVal;		
      if (!XMLConfigNameVal::ConvertToDouble((const wchar_t *)bstrVal, &doubleVal)) 
        return Error("Failure converting string to floating point number");
      mDefaultValue = doubleVal;
      break;
    }
		case MTPRODUCTVIEWLib::MSIX_TYPE_DECIMAL: 
    {
      MTDecimalVal decimalVal;		
      if (!XMLConfigNameVal::ConvertToDecimal((const wchar_t *)bstrVal, &decimalVal)) 
        return Error("Failure converting string to decimal number");
      mDefaultValue = DECIMAL(MTDecimal(decimalVal));
      break;
    }
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_TIMESTAMP: 
    {
      DATE dateVal;
      time_t dateValAnsi;
      
      if (!XMLConfigNameVal::ConvertToDateTime((const wchar_t *)bstrVal, &dateValAnsi))
        return FALSE;
      
      //converts from time_t to OLE DATE object
      OleDateFromTimet(&dateVal, dateValAnsi);
      {
        _variant_t temp(dateVal, VT_DATE);
        mDefaultValue = temp;
      }
      break;		
    }
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_BOOLEAN: 
    {
      BOOL boolVal;
      if (!XMLConfigNameVal::ConvertToBoolean((const wchar_t *)bstrVal, &boolVal))
        return FALSE;
      if (boolVal)
        bstrVal = DB_BOOLEAN_TRUE;  
      else
        bstrVal = DB_BOOLEAN_FALSE;   
    }
    
    //CAUTION !!!!
    //case TYPE_BOOLEAN is meant to fall through to the TYPE_STRING case below
    //CAUTION !!!!
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_STRING:
		case MTPRODUCTVIEWLib::MSIX_TYPE_WIDESTRING: 
    {
      // TODO: can this be done more efficiently?
      mDefaultValue = bstrVal;      
      
      break;
    }
    
    
		case MTPRODUCTVIEWLib::MSIX_TYPE_ENUM: 
    {
      _bstr_t enumVal, FQN;
			NAMEIDLib::IMTNameIDPtr aNameID(MTPROGID_NAMEID);
			MTENUMCONFIGLib::IEnumConfigPtr aEnumConfig(MTPROGID_ENUM_CONFIG);
      
      enumVal = (const wchar_t *)bstrVal;
      FQN = aEnumConfig->GetFQN(mEnumNamespace, mEnumEnumeration, enumVal);
      
      if(FQN.length() == 0) {
        char buf [1024];
				sprintf(buf, "Enumeration %s/%s/%s not found in enum collection.",
								(const char*)mEnumNamespace, (const char*)mEnumEnumeration, (const char*)enumVal);
        return Error(buf);
      }
      mDefaultValue = (long) aNameID->GetNameID((const wchar_t *)FQN);
      break;
    }
    
		default: 
			return Error("Unsupported MSIX type for default value");
		}	
	}
	catch(_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_EnumNamespace(BSTR *pVal)
{
	try 
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = mEnumNamespace.copy();
	}
	catch(_com_error & e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_EnumNamespace(BSTR newVal)
{
	mEnumNamespace = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_EnumEnumeration(BSTR *pVal)
{
	try 
	{
		if (!pVal)
			return E_POINTER;
		else
			*pVal = mEnumEnumeration.copy();
	}
	catch(_com_error & e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_EnumEnumeration(BSTR newVal)
{
	mEnumEnumeration = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_PropertyType(MSIX_PROPERTY_TYPE *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mPropertyType;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_PropertyType(MSIX_PROPERTY_TYPE newVal)
{
	mPropertyType = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_Core(VARIANT_BOOL *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mCore;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_Core(VARIANT_BOOL newVal)
{
	mCore = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_DisplayName(ICOMLocaleTranslator *apLocale, BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
	{
		try
		{
			MTPRODUCTVIEWLib::ICOMLocaleTranslatorPtr pLocale(reinterpret_cast<MTPRODUCTVIEWLib::ICOMLocaleTranslator *>(apLocale));
			*pVal = pLocale->GetLocalizedDescription(mDescriptionID).copy();
		}
		catch(_com_error & err)
		{
			return returnProductViewError(err);
		}
	}

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_ID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mID;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_ID(long newVal)
{
	mID = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::putref_SessionContext(IMTSessionContext* newVal)
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

STDMETHODIMP CProductViewProperty::get_SessionContext(IMTSessionContext* *pVal)
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

STDMETHODIMP CProductViewProperty::putref_ProductView(IProductView* newVal)
{
	try
	{
		mProductView = newVal;
		MTPRODUCTVIEWLib::IProductViewPtr Ptr(newVal);
		mProductViewID = Ptr->ID;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_ProductView(IProductView* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
		// First check whether we already have a non-null product
		// view.  If so, just return it.  If not check whether we
		// have a valid database ID for a product view.  If we do,
		// then go fetch the product view.
		if(NULL == mProductView && -1 != mProductViewID)
		{
			MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr reader(__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewReader));
			mProductView = reader->Find(mSessionContextExec, mProductViewID);
		}
    MTPRODUCTVIEWLib::IProductViewPtr ptr = mProductView;

    *pVal = reinterpret_cast<IProductView*> (ptr.Detach());
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

HRESULT CProductViewProperty::Save(long* apID)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewPropertyWriterPtr writer( __uuidof(MTPRODUCTVIEWEXECLib::MTProductViewPropertyWriter));
		MTPRODUCTVIEWEXECLib::IProductViewPropertyPtr This(this);

		if(-1 != This->ID)
		{
			writer->Update(This->SessionContext,  This);
		}
		else
		{
			//check for incomplete info
			if(This->ProductView->ID < 0)
				return Error("Incomplete product view property");
			
			long lID = writer->Create(This->SessionContext, This);
			
			// The writer has the responsibility for putting the id into me.
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

STDMETHODIMP CProductViewProperty::get_ProductViewID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mProductViewID;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_ProductViewID(long newVal)
{
	mProductViewID = newVal;

	return S_OK;
}

STDMETHODIMP CProductViewProperty::get_Description(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mDescription.copy();

	return S_OK;
}

STDMETHODIMP CProductViewProperty::put_Description(BSTR newVal)
{
	mDescription = newVal;

	return S_OK;
}

