/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header: c:\development35\Core\DataAccess\Rowset\MTFilterItem.cpp, 18, 11/13/2002 3:10:25 PM, Derek Young$
* 
***************************************************************************/

#include "StdAfx.h"
#include "Rowset.h"
#include "MTFilterItemImpl.h"
#include <metra.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <formatdbvalue.h>



/////////////////////////////////////////////////////////////////////////////
// CMTFilterItem

STDMETHODIMP CMTFilterItem::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTFilterItem
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTFilterItem::FinalConstruct()
{
	mIsWhereClause = VARIANT_TRUE;
	// ESR-3281, default mEscapeString to FALSE, needs to be set to true when using IMTDataFilter
	mEscapeString = VARIANT_FALSE;

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CMTFilterItem::get_PropertyName(BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mPropName.copy();
	return S_OK;
}

STDMETHODIMP CMTFilterItem::put_PropertyName(BSTR newVal)
{
	mPropName = newVal;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::get_PropertyType(PropValType *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mPropType;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::put_PropertyType(PropValType newVal)
{
	mPropType = newVal;
	return S_OK;
}
STDMETHODIMP CMTFilterItem::get_Operator(MTOperatorType *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	*pVal = mOperator;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::put_Operator(MTOperatorType newVal)
{
	mOperator = newVal;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::put_OperatorAsString(BSTR pOperator)
{
	ASSERT(pOperator);
	if(!pOperator) return E_POINTER;

	// this in an inefficient method
	_bstr_t aOperator(pOperator);
	const char* pLength = aOperator;

	unsigned int intval = 0;
	for(int i=0;i<(int) aOperator.length();i++) {
		intval += pLength[i];
	}
	// the algorithm here is to simply add up the integer values of 
	// the character string and find the matching enumerated value.

	switch(intval) {
		case 421: // like
		case 293: // LIKE
			mOperator = OPERATOR_TYPE_LIKE; break;
		case 61: // =
			mOperator = OPERATOR_TYPE_EQUAL; break;
		case 122: // <>
			mOperator = OPERATOR_TYPE_NOT_EQUAL; break;
		case 62: // >
			mOperator = OPERATOR_TYPE_GREATER; break;
		case 123: // >=
			mOperator = OPERATOR_TYPE_GREATER_EQUAL; break;
		case 60: // <
			mOperator = OPERATOR_TYPE_LESS; break;
		case 121: // <=
			mOperator = OPERATOR_TYPE_LESS_EQUAL; break;
		default:
			return Error("Unknown operator");
	}
	return S_OK;
}


STDMETHODIMP CMTFilterItem::get_Value(VARIANT *pVal) 
{
  ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	VariantCopy(pVal, &mValue);

	return S_OK;
}

STDMETHODIMP CMTFilterItem::put_Value(VARIANT newVal)
{

	if(newVal.vt == (VT_VARIANT | VT_BYREF)) {
		mValue = newVal.pvarVal;
	}
	else {
		mValue = newVal;
	}
	return S_OK;
}

STDMETHODIMP CMTFilterItem::get_FilterString(BSTR* pFilterStr)
{
	ASSERT(pFilterStr);
	if(!pFilterStr) return E_POINTER;

	try {
    _bstr_t aFilterStr = mPropName;
		aFilterStr += " ";
    
    BSTR bstrTemp;
    HRESULT hr = get_FilterCondition(&bstrTemp);
    if(FAILED(hr))
      return hr;
    _bstr_t condition(bstrTemp, false);

    aFilterStr += condition;
    
    *pFilterStr = aFilterStr.copy();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}



STDMETHODIMP CMTFilterItem::get_FilterCondition(BSTR* pFilterCondition)
{
	ASSERT(pFilterCondition);
	if(!pFilterCondition) return E_POINTER;

	try {

		_bstr_t aFilterStr;
		_bstr_t aValueStr;
		std::wstring dateBuffer;
		// XXX make sure we handle all the cases
		switch(mValue.vt) {
			case VT_BOOL:
				aValueStr = ((bool)mValue) ? "'1'" : "'0'"; break;
			case VT_BSTR:
        PropValType dbProp;
        get_PropertyType(&dbProp);
        if (mIsWhereClause == VARIANT_TRUE)
		{  
		  // ESR-3281 and ESR-3315 (Revert CORE-1778) if using a data access method that supports UniCode, (i.e ADO.NET record sets) append in the "N" 
          if (mEscapeString == VARIANT_TRUE)
          {
					aValueStr = "N'"; 
          }
          else
          {       
				    aValueStr = "'";
		  }
        }
        else
        {
          // ADO Filter - no N before unicode string literal
           aValueStr = "'";
        }
				aValueStr += GetStringValueForSQL();
				aValueStr += "'";
				break;
			case VT_DECIMAL:
      case VT_R8:
				aValueStr = mValue;
				break;
			case VT_DATE:
			{
				if (mIsWhereClause == VARIANT_TRUE)
				{
					FormatValueForDB(mValue, FALSE, dateBuffer);
					aValueStr = dateBuffer.c_str();
				}
				else
				{
					wchar_t buffer[255];
					struct tm tmDest;
					// when used in an ADO filter, date literals
					// are formatted differently.  They're like VB dates
					DATE tdate = mValue.date;
					StructTmFromOleDate(&tmDest, tdate);
					wcsftime(buffer, 255, L"#%Y-%m-%d %H:%M:%S#", &tmDest);
					aValueStr = buffer;
				}
				break;
			}
			case VT_I2:
			case VT_I4:
			case VT_I8:
			case VT_UI2:
			case VT_UI4:
			case VT_INT:
			case VT_UINT:
				aValueStr = mValue; break;
      //that actually should be "IS" or "IS NOT"
      //fix it later. For now support DEFAULT operator with NULL value as "IS"
			case VT_NULL: 
				if( mOperator != OPERATOR_TYPE_NOT_EQUAL && 
            mOperator != OPERATOR_TYPE_EQUAL &&
            mOperator != OPERATOR_TYPE_IS_NULL &&
            mOperator != OPERATOR_TYPE_IS_NOT_NULL) {
					return Error("NULL values only support equal, not equal, IS NULL or IS NOT NULL comparison");
				}
				aValueStr = "NULL";
				break;
		  case VT_UI1|VT_ARRAY:
			{
				SAFEARRAY * sa = mValue.parray;

				long lbound;
				HRESULT hr = SafeArrayGetLBound(sa, 1, &lbound);
				if (FAILED(hr))
					return hr;

				long ubound;
				hr = SafeArrayGetUBound(sa, 1, &ubound);
				if (FAILED(hr))
					return hr;

				long len = (ubound - lbound) + 1;

				BYTE HUGEP * bytes;
				hr = SafeArrayAccessData(sa, (void HUGEP **) &bytes);
				if (FAILED(hr))
					return hr;

				std::wstring wstrString ;

				// convert the session id to a string ...
        // Oracle needs single quotes around binary values, without 0x prepended.
        // SQL Server needs 0x to be prepended and no single quotes.
        if (mIsOracle)
        {
          wstrString += L"'" ;
        }
        else
        {
	        wstrString += L"0x" ; 
        }
			
				for (int i=0 ; i < len; i++)
				{
					wchar_t buffer[10];
					swprintf(buffer, L"%02X", (int) bytes[i]) ;
					wstrString += buffer;
				}
        if (mIsOracle)
        {
          wstrString += L"'";
        }
				SafeArrayUnaccessData(sa);

				aValueStr = wstrString.c_str();
				break;
			}

			// we only support VT_DISPATCH if the user passes in nothing.  If the user passes
			// some random object, we through an error
			case VT_DISPATCH:
				if(mValue.pdispVal == NULL) {
					aValueStr = "NULL";
				}
				else {
					return Error("VT_DISPATCH only suported for NULL objects or 'nothing'");
				}
				break;
			default:
				return Error("Variant type not supported");
		}


    MTOperatorType oper;
    //resolve default operator based on value type
    if(mOperator == OPERATOR_TYPE_DEFAULT)
    {
      if(mValue.vt == VT_BSTR)
        oper = OPERATOR_TYPE_LIKE_W;
      else if(V_VT(&mValue) == VT_NULL)
        oper = OPERATOR_TYPE_EQUAL;
    }
    else
      oper = mOperator;

    PropValType dbProp;
		switch(oper) {
			case OPERATOR_TYPE_LIKE:
        
			get_PropertyType(&dbProp);
			// ESR-3281 and ESR-3315(Revert CORE-1778) if using a data access method that DOES supports UniCode, (i.e ADO.NET record sets) append in the "N" 
			if(mEscapeString == VARIANT_TRUE)
			{
				aFilterStr = "like N'";
			}
			else
			{
			aFilterStr = "like '";
			}
				// we have already added the ' prefix and suffix to aValueStr.  Unfortuanately,
				// we must use the raw string in this case
				if(mValue.vt == VT_BSTR) {
					aFilterStr += GetStringValueForSQL();
				}
				else {
					aFilterStr += aValueStr;
				}
        aFilterStr += "'";
				break;
			case OPERATOR_TYPE_LIKE_W:
				
				get_PropertyType(&dbProp);
				// ESR-3281 and ESR-3315(Revert CORE-1778) if using a data access method that DOES supports UniCode, (i.e ADO.NET record sets) append in the "N" 
				if(mEscapeString == VARIANT_TRUE)
				{
					aFilterStr = "like N'";
				}
				else
				{
					aFilterStr = "like '";
				}
				// we have already added the ' prefix and suffix to aValueStr.  Unfortuanately,
				// we must use the raw string in this case
				if(mValue.vt == VT_BSTR) {
					aFilterStr += GetStringValueForSQL();
				}
				else {
					aFilterStr += aValueStr;
				}
				aFilterStr += "%'"; 
				break;
			case OPERATOR_TYPE_EQUAL:
				aFilterStr += "= ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_NOT_EQUAL:
				aFilterStr += "<> ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_GREATER:
				aFilterStr += "> ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_GREATER_EQUAL:
				aFilterStr += ">= ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_LESS:
				aFilterStr += "< ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_LESS_EQUAL:
				aFilterStr += "<= ";
				aFilterStr += aValueStr;
				break;
			case OPERATOR_TYPE_IN:
        ASSERT(mValue.vt == VT_BSTR); //in only supported with string value
				aFilterStr += "IN (";
				aFilterStr += (_bstr_t)mValue;
				aFilterStr += ")";
				break;
      case OPERATOR_TYPE_IS_NULL:
        ASSERT(mValue.vt == VT_NULL); //in only supported with NULL value
				aFilterStr += " IS NULL ";
				break;
      case OPERATOR_TYPE_IS_NOT_NULL:
        ASSERT(mValue.vt == VT_NULL); //in only supported with NULL value
				aFilterStr += " IS NOT NULL ";
				break;
		}
		*pFilterCondition = aFilterStr.copy();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

//gets a string mValue to be used in a SQL query replacing ' with ''
_bstr_t CMTFilterItem::GetStringValueForSQL()
{
  ASSERT(mValue.vt == VT_BSTR);

  // replace ' with ''
  wstring strVal = (_bstr_t)mValue;
  for(unsigned int i=0; i < strVal.size(); i++)
  { if (strVal[i] == L'\'')
    { strVal.insert(i, L"'");
      i++;
    }
    // if we are going to use the string for sql, then need to convert * to %
    if ((mIsWhereClause == VARIANT_TRUE) && (strVal[i] == L'*'))
		{
      if (((i+1)<strVal.size()) && (strVal[i+1] == L']') && ((i-1)>=0) && (strVal[i-1] == L'['))
      {
        //When * is escaped as in [*], need to remove the wrapping [] for SQL
        strVal.erase(i+1,1);
        strVal.erase(i-1,1);
        i--;
      }
      else
      {
        strVal[i] = L'%';
      }
    }
  }

  return strVal.c_str();
}



STDMETHODIMP CMTFilterItem::put_IsWhereClause(/*[in]*/ VARIANT_BOOL isWhere)
{
	mIsWhereClause = isWhere;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::get_IsWhereClause(/*[out, retval]*/ VARIANT_BOOL *val)
{
	*val = mIsWhereClause;
	return S_OK;
}
STDMETHODIMP CMTFilterItem::put_IsOracle(/*[in]*/ VARIANT_BOOL newVal)
{
	mIsOracle = newVal;
	return S_OK;
}

STDMETHODIMP CMTFilterItem::get_IsOracle(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	*pVal = mIsOracle;
	return S_OK;
}
// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
STDMETHODIMP CMTFilterItem::put_EscapeString(/*[in]*/ VARIANT_BOOL newVal)
{
	mEscapeString = newVal;
	return S_OK;
}

// ESR-3281 and ESR-3315,(Revert CORE-1778) if using a data access method that supports UniCode,(i.e ADO.NET record sets) 
// then "Escape" the string with ("N"), (ADO disconnected record sets DO NOT support unicode)
STDMETHODIMP CMTFilterItem::get_EscapeString(/*[out, retval]*/ VARIANT_BOOL *pVal)
{
	*pVal = mEscapeString;
	return S_OK;
}