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
#include "MTYAAC.h"
#include "MTAccountTemplateProperties.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateProperties

STDMETHODIMP CMTAccountTemplateProperties::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTAccountTemplateProperties,
    &IID_IMTCollectionEx,
    &IID_IMTCollection,
    &IID_IMTCollectionReadOnly
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTAccountTemplateProperties::Add(BSTR aName, BSTR aValue, VARIANT aType, IMTAccountTemplateProperty **ppProp)
{
	try {
		MTYAACLib::IMTAccountTemplatePropertyPtr prop(__uuidof(MTYAACLib::MTAccountTemplateProperty));
		MTYAACLib::IMTCollectionExPtr coll((IMTCollectionEx*)this);
    PropValType type = PROP_TYPE_UNICODE_STRING;
    _variant_t vType;
    /*
    Convert from VB land data typish string into PropValType
    
    Public Const MSIXDEF_TYPE_UNISTRING = "UNISTRING"
    Public Const MSIXDEF_TYPE_STRING = "STRING"
    Public Const MSIXDEF_TYPE_BOOLEAN = "BOOLEAN"
    Public Const MSIXDEF_TYPE_FLOAT = "FLOAT"
    Public Const MSIXDEF_TYPE_DOUBLE = "DOUBLE"
    Public Const MSIXDEF_TYPE_DECIMAL = "DECIMAL"
    Public Const MSIXDEF_TYPE_INT32 = "INT32"
    Public Const MSIXDEF_TYPE_TIMESTAMP = "TIMESTAMP"
    Public Const MSIXDEF_TYPE_ENUM = "ENUM"
    Public Const MSIXDEF_TYPE_OBJECT = "OBJECT"

    */
    if(OptionalVariantConversion(aType, VT_I4, vType)) 
    {
      type = (PropValType)(long)vType;
    }
    else if(OptionalVariantConversion(aType, VT_BSTR, vType)) 
    {
      if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"STRING") == 0)
      {
        type = PROP_TYPE_UNICODE_STRING;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"UNISTRING") == 0)
      {
        type = PROP_TYPE_UNICODE_STRING;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"BOOLEAN") == 0)
      {
        type = PROP_TYPE_BOOLEAN;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"FLOAT") == 0)
      {
        type = PROP_TYPE_DECIMAL;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"DOUBLE") == 0)
      {
        type = PROP_TYPE_DOUBLE;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"DECIMAL") == 0)
      {
        type = PROP_TYPE_DECIMAL;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"INT32") == 0)
      {
        type = PROP_TYPE_INTEGER;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"TIMESTAMP") == 0)
      {
        type = PROP_TYPE_TIME;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"ENUM") == 0)
      {
        type = PROP_TYPE_ENUM;
      }
      else if(_wcsicmp((wchar_t*)(_bstr_t)vType, L"OBJECT") == 0)
      {
        type = PROP_TYPE_OPAQUE;
      }
      
    }

		//if(coll->GetExists(aName) == VARIANT_TRUE) {
		//	ASSERT(!"Remove not implemented");
		//	//coll->Remove(aName);
		//}
		prop->PutName(aName);
		prop->PutInternalValue(aValue);
    if(type == PROP_TYPE_ENUM)
    {
      //For MAM's sake we need to special case some
      //usage cycle related enums and return enumerator name as opposed to value
      //Real way to fix this would be to make it consistent in VB on UI side, but
      //it is really messy and will take a lot of time.
      bool enumerator = false;
      if( (_wcsicmp(prop->Name, L"UsageCycleType") == 0) ||
          (_wcsicmp(prop->Name, L"DayOfWeek") == 0) ||
          (_wcsicmp(prop->Name, L"StartMonth") == 0) )
      {
        enumerator = true;
      }
      _bstr_t val = "";
      if(enumerator == true)
        val = mEnumConfig->GetEnumeratorByID((long)_variant_t(aValue));
      else
        val = mEnumConfig->GetEnumeratorValueByID((long)_variant_t(aValue));
      prop->PutValue(val);
    }
    else
      prop->PutValue(aValue);
    prop->PutType((MTYAACLib::PropValType)type);
		
		IDispatchPtr pdisp = prop;
		coll->Add(_variant_t(pdisp.GetInterfacePtr()));
		*ppProp = reinterpret_cast<IMTAccountTemplateProperty*>(prop.Detach());
	}
	catch(_com_error& err) {
		return returnYAACError(err,"Failed to add account template property",LOG_ERROR);
	}
	return S_OK;
}

