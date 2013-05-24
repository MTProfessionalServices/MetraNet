/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 * $Header: MTCounterParameter.cpp, 41, 7/30/2002 12:37:31 PM, Boris$
 *
 ***************************************************************************/

#include "StdAfx.h"
//#include "Counter.h"
#include "MTCounterParameter.h"
#include "MTCounter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParameter

HRESULT CMTCounterParameter::FinalConstruct()
{
	try
	{
		mCounterID = -1;
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);
    meKind = PARAM_PRODUCT_VIEW_PROPERTY;
		LoadPropertiesMetaData(PCENTITY_TYPE_COUNTER_PARAM);
	}	
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

void CMTCounterParameter::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}


STDMETHODIMP CMTCounterParameter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterParameter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCounterParameter::get_Name(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_Name(BSTR newVal)
{
	mName = newVal;
	return PutPropertyValue("Name", mName);
}

STDMETHODIMP CMTCounterParameter::get_Value(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = mValue.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_Value(BSTR newVal)
{
	try
	{
    MTCOUNTERLib::IMTCounterParameterPtr thisPtr = this;
    mValue = newVal;
		HRESULT hr = SetPVNameAndPropertyNameFromValue();
		if(FAILED(hr))
			MT_THROW_COM_ERROR(hr);
		hr = SetProductViewTableAndColumn();
		if(FAILED(hr))
			MT_THROW_COM_ERROR(hr);

		return PutPropertyValue("Value", mValue);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

STDMETHODIMP CMTCounterParameter::get_Kind(MTCounterParamKind *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = meKind;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_Kind(BSTR pVal)
{
	_bstr_t sVal = pVal;

	if(!_wcsicmp((const wchar_t*)pVal, L"ProductViewProperty"))
	{
    meKind = PARAM_PRODUCT_VIEW_PROPERTY;
		return PutPropertyValue("Kind", (long)meKind);
	}
	if(!_wcsicmp((const wchar_t*)pVal, L"ProductView"))
	{
		meKind = PARAM_PRODUCT_VIEW;
		return PutPropertyValue("Kind", (long)meKind);
	}
	if(!_wcsicmp((const wchar_t*)pVal, L"Const"))
	{
		meKind = PARAM_CONST;
		return PutPropertyValue("Kind", (long)meKind);
	}
	return MTPC_INVALID_COUNTER_PARAM_KIND;
}

STDMETHODIMP CMTCounterParameter::get_DBType(MTCounterParamDBType *pVal)
{
	if(!pVal)
		return E_POINTER;
	(*pVal) = meDBType;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_DBType(BSTR pVal)
{
	if(!pVal)
		return E_POINTER;

	_bstr_t sVal = pVal;

	if(!_wcsicmp((const wchar_t*)pVal, L"Numeric"))
	{
		meDBType = PARAM_NUMERIC;
	}
	else if(!_wcsicmp((const wchar_t*)pVal, L"String"))
	{
		meDBType = PARAM_STRING;
	}
	else if(sVal.length() == 0)
	{
		meDBType = PARAM_STRING;
	}
	else
		return MTPC_INVALID_COUNTER_PARAM_DBTYPE;
	//Handle empty DB types for ProductView or CONST parameter kinds
	
	return PutPropertyValue("DBType", (long)meDBType);
}


STDMETHODIMP CMTCounterParameter::get_Alias(BSTR *pVal)
{
	(*pVal) = mAlias.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_Alias(BSTR newVal)
{
	mAlias = newVal;
	return PutPropertyValue("Alias", newVal);
}

//TODO: Have CProductViewCollection initialized as instance variable
STDMETHODIMP CMTCounterParameter::get_ProductViewTable(BSTR *pVal)
{
	HRESULT hr(S_OK);

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;

	if(meKind == PARAM_CONST)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;

	return GetPropertyValue("ProductViewTableName", pVal);
}



STDMETHODIMP CMTCounterParameter::get_ProductViewName(BSTR *pVal)
{
	// If Parameter Kind is ProductViewProperty then parse out product view name and pv property
	// If Parameter Kind is ProductView then just return value
	// If Parameter Kind is CONST then return custom Error
	// If Parameter Value is not set, return custom error

	HRESULT hr(S_OK);

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;

	if(meKind == PARAM_CONST)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;
	
	return GetPropertyValue("ProductViewName", pVal);
}


STDMETHODIMP CMTCounterParameter::get_PropertyName(BSTR *pVal)
{
	// If Parameter Kind is ProductViewProperty then parse out product view name and pv property
	// If Parameter Kind is ProductView then return custom Error
	// If Parameter Kind is CONST then return custom Error
	// If Parameter Value is not set, return custom error
	HRESULT hr(S_OK);

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;
	if(meKind == PARAM_CONST || meKind == PARAM_PRODUCT_VIEW)
		return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;

	return GetPropertyValue("ProductViewPropertyName", pVal);
}

STDMETHODIMP CMTCounterParameter::get_TypeID(long *pVal)
{
	(*pVal) = mlTypeID;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_TypeID(long newVal)
{
	mlTypeID = newVal;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::get_ID(long *pVal)
{
	(*pVal) = mlID;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_ID(long newVal)
{
	mlID = newVal;
	return PutPropertyValue("ID", newVal);
}

HRESULT CMTCounterParameter::SetPVNameAndPropertyNameFromValue()
{
	HRESULT hr(S_OK);
	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;

	//AutoCriticalSection alock(&mLock);
	
	wchar_t chars[] = L"/\\.";
	wstring wsValue = (const wchar_t*) mValue;
	
	switch(meKind)
	{
		case PARAM_PRODUCT_VIEW:
			{
				mPVName = mValue;
				hr = PutPropertyValue("ProductViewName", mPVName);
				if(FAILED(hr))
					return hr;
				break;
			}
		case PARAM_PRODUCT_VIEW_PROPERTY:
			{
				int nPos = wsValue.find_last_of(chars);
				if (nPos ==  (int) basic_string<wchar_t>::npos)
				{
					return MTPC_UNABLE_TO_PARSE_COUNTER_FORMULA;
				}
				else
				{
					
					mPVName = wsValue.substr(0, nPos).c_str();
					hr = PutPropertyValue("ProductViewName", mPVName);
					if(FAILED(hr))
						return hr;
					mPropertyName =  wsValue.substr( (nPos+1), wsValue.length()).c_str();
					hr = PutPropertyValue("ProductViewPropertyName", mPropertyName);
					if(FAILED(hr))
						return hr;
				}
				break;
				
			}
		case PARAM_CONST:
		default: 
		{
			ASSERT(!"Invalid Counter Parameter Kind");
			MT_THROW_COM_ERROR("Invalid Parameter Kind");
		}
	}
	
	return hr;
}

void CMTCounterParameter::SetFinalValueFromValue()
{
	if ( !mValue.length() )
		return;

	switch (meKind)
	{
		case PARAM_CONST:
			{
				mFinalValue = mValue;
				break;
			}
		case PARAM_PRODUCT_VIEW:
			{
				mFinalValue = mTableName;
				mFinalValue += ".id_sess";
				break;
			}
		case PARAM_PRODUCT_VIEW_PROPERTY:
			{
				mFinalValue = mTableName;
				mFinalValue += ".";
				mFinalValue += mColumnName;
				break;
			}
		default: _ASSERTE(0);
	}
	return;
}

STDMETHODIMP CMTCounterParameter::get_TableName(BSTR *pVal)
{
	HRESULT hr(S_OK);

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;
	if(meKind == PARAM_CONST)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;
	return  GetPropertyValue("ProductViewTableName", pVal);
}


STDMETHODIMP CMTCounterParameter::get_ColumnName(BSTR *pVal)
{
	HRESULT hr(S_OK);

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;
	
	if(meKind == PARAM_CONST || meKind == PARAM_PRODUCT_VIEW)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;

	return GetPropertyValue("ProductViewColumnName", pVal);

}


STDMETHODIMP CMTCounterParameter::get_FinalValue(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;

	if(!mFinalValue.length())
		//construct the value the way it will be executed
		SetFinalValueFromValue();
	
	(*pVal) = mFinalValue.copy();
	return S_OK;
}

_bstr_t CMTCounterParameter::GetMSIXFileFromPVName(const _bstr_t& aPVName)
{
	if(!aPVName.length())
		return ""; // TODO: does this make sense?

	wchar_t chars[] = L"/\\";
	wstring wsPVName = (const wchar_t*) aPVName;
	int nPos = wsPVName.find_last_of(chars);
	if (nPos ==  (int) basic_string<wchar_t>::npos)
	{
		return _bstr_t(wsPVName.c_str()) + _bstr_t(".msixdef");
	}

	return _bstr_t(wsPVName.substr((nPos+1), wsPVName.length() ).c_str()) + _bstr_t(".msixdef");
	
}


STDMETHODIMP CMTCounterParameter::get_ReadOnly(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ReadOnly", pVal);
	
}

STDMETHODIMP CMTCounterParameter::put_ReadOnly(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ReadOnly", newVal);
}

STDMETHODIMP CMTCounterParameter::get_ViewName(BSTR *pVal)
{
  HRESULT hr(S_OK); 	
  /*
  
	BSTR struView;

	if( !mValue.length() )
		return MTPC_PARAMETER_VALUE_NOT_SET;
	
	if(meKind == PARAM_CONST)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;

	if(mViewName.length() == 0)
	{
		
		CMTCounterView view;
		_bstr_t bstrView;

#ifdef DYNAMICALLY_GENERATE_VIEWS	
		
		hr = view.Create(mPVName, &struView);
		
		if(FAILED(hr))
					return hr;
		
		bstrView = _bstr_t(struView, false);
#else
		bstrView = view.GetViewName(mPVName);
#endif

	}
  */
	(*pVal) = mViewName.copy();

	return hr;
}


HRESULT CMTCounterParameter::SetProductViewTableAndColumn()
{
	HRESULT hr(S_OK);

	CProductViewCollection PVColl ;
	CMSIXDefinition *pProductView ;
	CMSIXProperties *pPVProp ;
	BOOL bIsUsageTable = FALSE;
  
	
	if(meKind == PARAM_CONST)
			return MTPC_PROPERTY_IRRELEVANT_FOR_THIS_PARAM_KIND;

	//the below method will log a bunch of error messages if product view
	//was not found. Since in case of t_vw_acc_usage this is the normal situation
	//(it's not in MSIX collection), we need to identify it and NOT call below method
	if(	!_wcsicmp((wchar_t*)mPVName, L"t_vw_acc_usage") || 
			!_wcsicmp((wchar_t*)mPVName, L"t_acc_usage") )
		bIsUsageTable = TRUE;
	if(!bIsUsageTable)
	{
		if(!PVColl.Initialize( (const wchar_t*) GetMSIXFileFromPVName(mPVName) ))
		{
			return MTPC_INVALID_PRODUCT_VIEW_NAME;
		}
			
		wstring rwwPVName = (const wchar_t*) mPVName;
			
		if(PVColl.FindProductView(rwwPVName, pProductView))
		{
			mPVTableName = pProductView->GetTableName().c_str();
		}
		else
			return MTPC_INVALID_PRODUCT_VIEW_NAME;
		
		wstring rwwPVPropertyName = (const wchar_t*) mPropertyName;

		if(meKind == PARAM_PRODUCT_VIEW_PROPERTY)
		{
			if(pProductView->FindProperty(rwwPVPropertyName, pPVProp))
			{
				mColumnName = pPVProp->GetColumnName().c_str();
				mTableName = mPVTableName;
			}
			else
			{
				mbPropertyOfUsageTable = TRUE;
				mColumnName = mPropertyName;
				//since this property lives on the usage table, set
				//table name 'to t_acc_usage'
				mTableName = USAGE_TABLE;
			}
		}
	}
	else
	{
		mPVTableName = mPVName;
		mTableName = USAGE_TABLE;
		if(meKind == PARAM_PRODUCT_VIEW_PROPERTY)
			mColumnName = mPropertyName;
	}

  
	hr = PutPropertyValue("ProductViewTableName", mPVTableName);

	if(FAILED(hr))
		return hr;

	return PutPropertyValue("ProductViewColumnName", mColumnName);
}


STDMETHODIMP CMTCounterParameter::get_Predicates(IMTCollection **apVal)
{
	HRESULT hr(S_OK);
  try
  {
    mPredicates.CopyTo(apVal);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::CreatePredicate(IMTCounterParameterPredicate **apPredicate)
{
	HRESULT hr(S_OK);
  try
  {
    MTCOUNTERLib::IMTCounterParameterPtr thisPtr = this;
    MTCOUNTERLib::IMTCounterParameterPredicatePtr 
      newPredicatePtr(__uuidof(MTCOUNTERLib::MTCounterParameterPredicate));
    
    //enforce parameter value to be specified before predicate is created
    if(thisPtr->Value.length() == 0)
      MT_THROW_COM_ERROR(MTPC_UNABLE_CREATE_COUNTER_PARAM_PREDICATE);
    newPredicatePtr->ProductViewName = thisPtr->ProductViewName;
    newPredicatePtr->CounterParameter = thisPtr;
    //add it to collection and return it (predicate is owned by parameter)
    mPredicates.Add((IMTCounterParameterPredicate*)newPredicatePtr.GetInterfacePtr());
    (*apPredicate) = reinterpret_cast<IMTCounterParameterPredicate*>(newPredicatePtr.GetInterfacePtr());
    (*apPredicate)->AddRef();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return hr;
}

STDMETHODIMP CMTCounterParameter::get_Counter(IMTCounter **pVal)
{
	try
	{
		if (mCounterID == -1)
		{
			*pVal = NULL;
			return S_OK;
		}

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr prodcat("Metratech.MTProductCatalog.1");
    // TODO: this is NOT the right way to construct the session context.
  	// We should really retrieve the credentials and login as the user invoking the script
	  MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
		context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);
    context->LanguageID = 840;

		//prodcat->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr()));
		prodcat->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(context.GetInterfacePtr()));
		MTPRODUCTCATALOGLib::IMTCounterPtr counter = prodcat->GetCounter(mCounterID);

		(*pVal) = reinterpret_cast<IMTCounter*>(counter.Detach());
		return S_OK;
	}
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
}

STDMETHODIMP CMTCounterParameter::put_Counter(IMTCounter *newVal)
{
	try
  {
    if(newVal == NULL)
      return E_POINTER;
		mbIsShared = false;
		return newVal->get_ID(&mCounterID);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTCounterParameter::get_DisplayName(BSTR *pVal)
{
	if(!pVal)
		return E_POINTER;
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTCounterParameter::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTCounterParameter::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTCounterParameter::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}


STDMETHODIMP CMTCounterParameter::Save(long *apDBID)
{
	HRESULT hr(S_OK);
	
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCounterParamWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterParamWriter));
		MTPRODUCTCATALOGLib::IMTCounterParameterPtr thisPtr = this;

		if(HasID())
		{
			hr = writer->Update(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(this) );
			if (FAILED(hr))
				return hr;
			return GetPropertyValue("ID", apDBID);
		}

		long lID = writer->Create(GetSessionContextPtr(), -1, reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(this) );
		
		(*apDBID) = lID;

		PutPropertyValue("ID", lID);
	 }
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}
	return hr;
}

STDMETHODIMP CMTCounterParameter::get_ChargeID(long *pVal)
{
  //assume that mColumnName was initialized. Now look up all charges
  //associated with pi type and try to match their columns
  //with mColumnName. If a match is found ,then
  //counter parameter is considered to be "charge based"
  //and adjustment JOIN will be generated against T_AJ* table
  //as opposed to t_adjustment_transaction
  try
  {
    MTCOUNTERLib::IMTCounterParameterPtr ThisPtr = this;
    
    // TODO: this is NOT the right way to construct the session context.
  	// We should really retrieve the credentials and login as the user invoking the script
	  MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr
		context(MTPROGID_MTSESSIONCONTEXT);
		context->PutAccountID(0);
    context->LanguageID = 840;
    
    if( mpCharge == NULL && 
        ThisPtr->Counter != NULL && 
        mColumnName.length()
        )
      /*if Counter property IS NULL, then it's a shared parameter and we can't really do anything*/
    {
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr pireader
        (__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
      MTPRODUCTCATALOGEXECLib::IMTDataFilterPtr filter("MTSQLRowset.MTDataFilter");
      filter->Add("nm_productview", MTPRODUCTCATALOGEXECLib::OPERATOR_TYPE_EQUAL, ThisPtr->ProductViewName);
      IDispatchPtr disp = filter;
      _variant_t varFilter = disp.GetInterfacePtr();
      //varFilter.ChangeType(VT_DISPATCH);
      //varFilter = filter;

      //TODO:
      //initialize PITypeID in a better place
      MTPRODUCTCATALOGLib::IMTCollectionPtr typecol = 
          pireader->FindByFilter
          (
            context, 
            varFilter
           );
      if(typecol->GetCount() < 1)
      {
        //CR 8955 fix:
        //Counters don't have to be based on PI types. They can be based on pre prodcat product views 
        //If hit that condition, than don't throw an error, just set charge id to -1
        //char buf[255];
        //sprintf(buf, "Priceable Item Type using %s product view not found", (char*)ThisPtr->ProductViewName);
        //MT_THROW_COM_ERROR(buf);
        (*pVal) = -1;
        return S_OK;
      }
      //TODO: is this safe to assume that
      //this is an erroneous case?
      if(typecol->GetCount() > 1)
      {
        char buf[255];
        sprintf(buf, "More than one Priceable Item Type associated with '%s' product view is found", (char*)ThisPtr->ProductViewName);
        MT_THROW_COM_ERROR(buf);
      }
      MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piTypePtr = 
        typecol->GetItem(1);

      ASSERT(piTypePtr != NULL);
      mPITypeID = piTypePtr->ID;

      MTPRODUCTCATALOGLib::IMTCollectionPtr pChargeColl = piTypePtr->GetCharges();
      long lNumCharges = pChargeColl->Count;

	    for (int i=1; i <= lNumCharges; ++i)
	    {
		    MTPRODUCTCATALOGLib::IMTChargePtr pChargePtr = pChargeColl->GetItem(i);
        wchar_t* chargeAmountColumn = _wcslwr((wchar_t*)pChargePtr->AmountName);
        wchar_t* paramColumn = _wcslwr((wchar_t*)mColumnName);
        if(_wcsicmp(chargeAmountColumn, mColumnName) == 0)
        {
          mpCharge = pChargePtr;
          break;
        }
      }

    }
    (*pVal) = (mpCharge == NULL) ? -1 : mpCharge->ID;
  }
  catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::get_AdjustmentTable(BSTR *pVal)
{
  (*pVal) = mAdjustmentTable.copy();
  return S_OK;
}
STDMETHODIMP CMTCounterParameter::put_AdjustmentTable(BSTR newVal)
{
	mAdjustmentTable = newVal;
  return S_OK;
}

STDMETHODIMP CMTCounterParameter::get_PriceableItemTypeID(long *pVal)
{
	(*pVal) = mPITypeID;
  return S_OK;
}

STDMETHODIMP CMTCounterParameter::put_PriceableItemTypeID(long newVal)
{
	mPITypeID = newVal;
	return S_OK;
}

STDMETHODIMP CMTCounterParameter::get_Shared(VARIANT_BOOL *pVal)
{
	(*pVal) = (mbIsShared == true) ? VARIANT_TRUE : VARIANT_FALSE;
  return S_OK;
}

