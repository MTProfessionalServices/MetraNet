// MTCounterParameterPredicate.cpp : Implementation of CMTCounterParameterPredicate
#include "StdAfx.h"
//#include "Counter.h"
#include "MTCounterParameterPredicate.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParameterPredicate

STDMETHODIMP CMTCounterParameterPredicate::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterParameterPredicate
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
STDMETHODIMP CMTCounterParameterPredicate::put_Operator(MTOperatorType aOp)
{
  mOperator = aOp;
 	return S_OK;
 
  //return PutPropertyValue("TypeID", newVal);
}

STDMETHODIMP CMTCounterParameterPredicate::get_Operator(MTOperatorType* apOp)
{
	HRESULT hr(S_OK);
  (*apOp) = mOperator;
	return hr;
}

STDMETHODIMP CMTCounterParameterPredicate::get_Value(VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	
	::VariantInit(pVal);
	::VariantCopy(pVal, &mValue);

	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::put_Value(VARIANT newVal)
{
  //convert value appropriately depending on the property type
  
  HRESULT hr(S_OK);
  try
  {
    _variant_t val = newVal;
    if(V_VT(&val) == VT_EMPTY || V_VT(&val) == VT_NULL)
    {
      MT_THROW_COM_ERROR("Property value is required!");
    }

    if(mPVProperty == NULL)
      MT_THROW_COM_ERROR(MTPC_COUNTER_PREDICATE_PROPERTY_MISSING);
    MSIX_PROPERTY_TYPE msixtype = (MSIX_PROPERTY_TYPE)mPVProperty->PropertyType;
  
    switch(msixtype)
    {
    case MSIX_TYPE_STRING:
    case MSIX_TYPE_WIDESTRING:
      {
        mValue = (_bstr_t)val;
        break;
      }
    case MSIX_TYPE_INT32:
      {
        mValue = (long)val;
        break;
      }
    case MSIX_TYPE_INT64:
      {
        mValue = (__int64)val;
        break;
      }
    case MSIX_TYPE_FLOAT:
    case MSIX_TYPE_DOUBLE:
      {
        mValue = (double)val;
        break;
      }
    case MSIX_TYPE_DECIMAL:
      {
        mValue = (DECIMAL)val;
        break;
      }
    case MSIX_TYPE_ENUM:
      {
        //accept both - enumerator, value
        //and possible localizsed description
        //ID if value is taken directly from DB table
        long id = 0;
        switch(V_VT(&val))
        {
          case VT_I4:
          case VT_I2:
          case VT_I8:
	        case VT_DECIMAL:
          {
            mValue = mEnumConfig->GetEnumeratorValueByID(val);
            break;
          }
          default:
          {
            id = mEnumConfig->GetID(mPVProperty->EnumNamespace, 
                 mPVProperty->EnumEnumeration, (_bstr_t)val);
            mValue = mEnumConfig->GetEnumeratorValueByID(id);
            break;
          }
        }
        break;
      }
    case MSIX_TYPE_BOOLEAN:
      {
        mValue = (VARIANT_BOOL)val;
        break;
      }
    case MSIX_TYPE_TIMESTAMP:
    case MSIX_TYPE_TIME:
    default:
      MT_THROW_COM_ERROR(MTPC_PARAM_PREDICATE_UNSUPPORTED_MSIX_TYPE);
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::get_ProductViewProperty(IProductViewProperty **pVal)
{
  if(mPVProperty == NULL)
  {
    (*pVal) = NULL;
  }
  else
  {
    (*pVal) = reinterpret_cast<IProductViewProperty*>(mPVProperty.GetInterfacePtr());
    (*pVal)->AddRef();
  }
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::put_ProductViewProperty(IProductViewProperty *newVal)
{
	try
  {
    if(newVal == NULL)
      return E_POINTER;
    //check if predicate product view actually matches the one
    //on parameter
    MTCOUNTERLib::IMTCounterParameterPredicatePtr thisPtr = this;
    mPVProperty = newVal;
    //BP: Reeanable below check after there is a way to fully initialize pv property
    /*
    if(wcsicmp((wchar_t*)mPVProperty->ProductView->name, thisPtr->ProductViewName))
    {
      mPVProperty = NULL;
      MT_THROW_COM_ERROR(MTPC_COUNTER_PARAM_PREDICATE_PRODUCT_VIEW_MISMATCH);
    }
    */

  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::get_ProductViewName(BSTR *pVal)
{
	(*pVal) = mPVName.copy();
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::put_ProductViewName(BSTR newVal)
{
	mPVName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::get_ID(long *pVal)
{
	(*pVal) = mID;
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::put_ID(long newVal)
{
	mID = newVal;
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::get_CounterParameter(IMTCounterParameter **pVal)
{
  (*pVal) = reinterpret_cast<IMTCounterParameter*>(mCounterParam.GetInterfacePtr());
  (*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CMTCounterParameterPredicate::put_CounterParameter(IMTCounterParameter *newVal)
{
	try
  {
    if(newVal == NULL)
      return E_POINTER;
    mCounterParam = newVal;
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
	return S_OK;
}


STDMETHODIMP CMTCounterParameterPredicate::ToString(BSTR *apVal)
{
	try
  {
    if(apVal == NULL)
      return E_POINTER;
    (*apVal) = NULL;
    _bstr_t out;
    MTCOUNTERLib::IMTCounterParameterPredicatePtr thisPtr = this;
    MTPRODUCTVIEWLib::IProductViewPropertyPtr pvpropPtr = thisPtr->ProductViewProperty;
    
    _variant_t val = thisPtr->Value;
    
    
    MTOperatorType op = (MTOperatorType)thisPtr->Operator;
    
    if(pvpropPtr == NULL || ((_bstr_t)val).length() == 0 || op == OPERATOR_TYPE_NONE)
    {
      (*apVal) = out.copy();
      return S_OK;
    }
    MSIX_PROPERTY_TYPE msixtype = (MSIX_PROPERTY_TYPE)pvpropPtr->PropertyType;

    char strBuf[1024];
    char outBuf[1024];
  
    switch(msixtype)
    {
    case MSIX_TYPE_STRING:
    case MSIX_TYPE_WIDESTRING:
      {
        sprintf(strBuf, "L'%s'", (char*)(_bstr_t)val);
        break;
      }
    case MSIX_TYPE_INT32:
      {
        sprintf(strBuf, "%d", (long)val);
        break;
      }
    case MSIX_TYPE_INT64:
      {
        sprintf(strBuf, "%I64d", (__int64)val);
        break;
      }
    case MSIX_TYPE_FLOAT:
    case MSIX_TYPE_DOUBLE:
      {
        sprintf(strBuf, "%f", (double)val);
        break;
      }
    case MSIX_TYPE_DECIMAL:
      {
        MTDecimal mtdec((DECIMAL)val);
        sprintf(strBuf, "%s", mtdec.Format().c_str());
        break;
      }
    case MSIX_TYPE_ENUM:
      {
        long id = mEnumConfig->GetID(mPVProperty->EnumNamespace, 
                 mPVProperty->EnumEnumeration, (_bstr_t)val);
        sprintf(strBuf, "%d", id);
        
      }
    case MSIX_TYPE_BOOLEAN:
      {
        _bstr_t boo = ((VARIANT_BOOL)val == VARIANT_TRUE) ? "T" : "F";
        sprintf(strBuf, "L'%s'", (char*)boo);
        break;
      }
    case MSIX_TYPE_TIMESTAMP:
    case MSIX_TYPE_TIME:
    default:
      MT_THROW_COM_ERROR(MTPC_PARAM_PREDICATE_UNSUPPORTED_MSIX_TYPE);
    }

    //format output buffer
    sprintf(outBuf, "%s %s %s", (char*)pvpropPtr->ColumnName, (char*)OpToString(op), strBuf);
    out = outBuf;
    (*apVal) = out.copy();

  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  
	return S_OK;
}
