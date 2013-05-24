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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <stdutils.h>

#include "MTProductCatalog.h"
#include "MTProperties.h"


using namespace MTPropertiesNamespace;

/////////////////////////////////////////////////////////////////////////////
// CMTProperties

/******************************************* error interface ***/
STDMETHODIMP CMTProperties::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProperties
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTProperties::CMTProperties()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTProperties::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTProperties::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTProperties***/
STDMETHODIMP CMTProperties::get_Item(VARIANT aKey, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	try
	{

		HRESULT hr = S_OK;
		CComVariant varKey;

		if (aKey.vt != VT_BSTR)
		{
			// If the index isn't a string, but can be converted to a long value interpret as string

			hr = varKey.ChangeType(VT_I4, &aKey);
			if (SUCCEEDED(hr))
			{
				unsigned long idx = varKey.lVal;
				//COM collections are 1-based collection
				if (idx < 1 || idx > m_coll.size())
					MT_THROW_COM_ERROR( MTPC_INDEX_OUT_OF_RANGE, idx);
				
				return CollImpl::get_Item(idx, pVal);
			}
		}

		// Otherwise, we assume index is a string key into the map
		hr = varKey.ChangeType(VT_BSTR, &aKey);

		// If we can't convert to a string, just return
		if (FAILED(hr))
			return hr;

		mtwstring wName(varKey.bstrVal);
		wName.toupper();

		PropMap::iterator it = m_coll.find(CComBSTR(wName));

		// item not found
		if (it == m_coll.end())
		{ _bstr_t name = varKey.bstrVal;
			MT_THROW_COM_ERROR( MTPC_PROPERTY_NOT_FOUND, (const char*)name);
		}
				
		// If item was found, copy the variant to the out param
		return (CComVariant(it->second).Detach(pVal));
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}


STDMETHODIMP CMTProperties::Add(/*[in]*/ IMTPropertyMetaData* apMetaData,
																/*[out, retval]*/ IMTProperty** apProp)
{
	HRESULT hr = S_OK;

	if (apMetaData == NULL)
		return E_POINTER;

	if (apProp == NULL)
		return E_POINTER;
	else
		*apProp = NULL;

	try
	{
		//create a new MTProperty based on this meta data
		CComPtr<IMTProperty> propPtr;
		propPtr.CoCreateInstance(__uuidof(MTProperty));

		HRESULT hr = propPtr->SetMetaData(apMetaData);
		if (FAILED(hr))
			return hr;

		//set value of property to default value of meta data
		VARIANT var;
		VariantInit(&var);
		hr = apMetaData->get_DefaultValue(&var);
		if (FAILED(hr))
			return hr;
		
		_variant_t defValue(var, false); //make sure we variant gets cleared 

		hr = propPtr->put_Value(defValue);
		if (FAILED(hr))
			return hr;
		
		// add MTProperty to collection
		BSTR bstrName;
		apMetaData->get_Name(&bstrName);
		_bstr_t strName(bstrName, false); //make sure we release it

		// make name uppercase, so case won't matter
		mtwstring wName(strName);
		wName.toupper();

		m_coll[CComBSTR(wName)] = propPtr;
		*apProp = propPtr.Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}		

	return S_OK;
}

STDMETHODIMP CMTProperties::Exist(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT_BOOL* apExist)
{
	if (apExist == NULL)
		return E_POINTER;

	*apExist = VARIANT_FALSE; //init

	HRESULT hr = S_OK;
	CComVariant varKey;

	if (aKey.vt != VT_BSTR)
	{
		// If the index isn't a string, but can be converted to a long value interpret as string

		hr = varKey.ChangeType(VT_I4, &aKey);
		if (SUCCEEDED(hr))
		{
			unsigned long idx = varKey.ulVal;
			if (idx >= 1 && idx <= m_coll.size())
			{  //idx is within bounds
				*apExist = VARIANT_TRUE;
			}
			return S_OK;
		}
	}

	// Otherwise, we assume index is a string key into the map
	hr = varKey.ChangeType(VT_BSTR, &aKey);

	// If we can't convert to a string, just return
	if (FAILED(hr))
		return hr;

	mtwstring wName(varKey.bstrVal);
	wName.toupper();

	PropMap::iterator it = m_coll.find(CComBSTR(wName));

	if (it != m_coll.end())
	{	// item found
		*apExist = VARIANT_TRUE;
	}
		
	return S_OK;
}


STDMETHODIMP CMTProperties::ToString(/*[out, retval]*/ BSTR* pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{	_bstr_t str;

		MTPRODUCTCATALOGLib::IMTPropertyPtr prop;
		MTPRODUCTCATALOGLib::IMTPropertiesPtr props = this;

		long count = props->Count;
	
		for(long i = 1; i <= count; i++)
		{
			prop = props->Item[i];
			
			str += PropertyToString( reinterpret_cast<IMTProperty*>(prop.GetInterfacePtr()), "");
		}

		*pVal = str.copy();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	
	return S_OK;
}

//helper adds one property to string
_bstr_t CMTProperties::PropertyToString(IMTProperty* apProp, _bstr_t aIndent)
{
	MTPRODUCTCATALOGLib::IMTPropertyPtr prop = apProp;
	_bstr_t str = aIndent;

	//property Name and Value
	str += prop->Name + "=";
	_variant_t aPropVal = prop->GetValue();
  
  
		
	if(aPropVal.vt == VT_BOOL) 
  {
		str += (bool)aPropVal ? "true" : "false";
	}
	else if(V_VT(&aPropVal) == VT_DISPATCH)
  {
    //if vt is VT_DISPATCH, then ChangeType(), which is called
    //by _bstr_t constructor will get the property marked as DISPVAL in IDL.
    //For all objects that we support as a part of MTProperties it is a database ID.
    //The problem is that my property is MTCollection, this approach will not work (DISPVAL is Item property on ComEnum).
    //We need to special case IMTCollection objects when exporting them to string

    //first Examine if this object implements CollectionEx, which already has a ToString method
    GENERICCOLLECTIONLib::IMTCollectionExPtr qiex = aPropVal;
    GENERICCOLLECTIONLib::IMTCollectionPtr qi = aPropVal;
    if(qiex != NULL)
    {
      str += qiex->ToString();
    }
    else if(qi == NULL)
    {
      str += _bstr_t(aPropVal);
    }
    else
    {
      bool first = true;
      for(int i = 1; i <= qi->Count; i++)
      {
        if(first == false)
        {
          str += ", ";
        }
        else
          first = false;
        _variant_t item = qi->GetItem(i);
        str += (_bstr_t)item;
      }
      
    }

	}
  else
  {
    str += _bstr_t(aPropVal);
  }
	
	// data type
	str = str + " - " + prop->DataTypeAsString + "[";
	
	//use variant_t to convert from long to bstr
	_variant_t varLength = prop->Length;
	str += static_cast<_bstr_t>(varLength);
	str += "]";

	PropValType dataType;
	apProp->get_DataType(&dataType); 

	if (dataType == PROP_TYPE_ENUM)
		str = str + " enumspc=" + prop->EnumSpace + ", enumtp=" + prop->EnumType;
	
	//extended, required, displayname
	if (prop->Extended == VARIANT_TRUE)
		str = str + ", ext";
	else
		str = str + ", core";

	if (prop->Required == VARIANT_TRUE)
		str = str + ", req";
	else
		str = str + ", notreq";

	str = str + ", dsplnm=" + prop->DisplayName;

	str = str + " -";

	//append all attributes
	MTPRODUCTCATALOGLib::IMTAttributesPtr attribs;
	attribs = prop->Attributes;
	long count = attribs->Count;
	for(long i = 1; i <= count; i++)
	{
		MTPRODUCTCATALOGLib::IMTAttributePtr attr = attribs->Item[i];
		str = str + " " + attr->Name + "=" + static_cast<_bstr_t>(attr->Value);
	}
	str += "\r\n";

	// recursively add nested objects
	if (dataType == PROP_TYPE_SET && prop->Value.vt != VT_NULL && prop->Value.vt != VT_EMPTY)
	{
		_variant_t varValue = prop->Value;

		IDispatchPtr disp = varValue;
		
		//Invoke the "Properties property on the IDispatch interface
		OLECHAR* propName = L"Properties";
		DISPID dispid;
		HRESULT hr = disp->GetIDsOfNames(IID_NULL, &propName, 1, LOCALE_USER_DEFAULT, &dispid);
    if (SUCCEEDED(hr))
    { 

      DISPPARAMS dispparamsNoArgs = {NULL, NULL, 0, 0};
      VARIANT result;
      VariantInit(&result);
      hr = disp->Invoke(dispid, IID_NULL, LOCALE_USER_DEFAULT, DISPATCH_PROPERTYGET,
        &dispparamsNoArgs, &result, NULL, NULL);
      if (FAILED(hr))
      { str += "ERROR: getting Properties";
      return str;
      }

      _variant_t varProperties(result, false);

      MTPRODUCTCATALOGLib::IMTPropertiesPtr props = varProperties;

      MTPRODUCTCATALOGLib::IMTPropertyPtr prop;
      count = props->Count;

      for(long i = 1; i <= count; i++)
      {
        prop = props->Item[i];
        str += PropertyToString( reinterpret_cast<IMTProperty*>(prop.GetInterfacePtr()), "    ");
      }
    }
	}
	return str;
}
