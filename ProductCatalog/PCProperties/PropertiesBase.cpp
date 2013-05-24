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
* $Header: PropertiesBase.cpp, 20, 9/11/2002 9:41:29 AM, Alon Becker$
* 
***************************************************************************/

// PropertiesBase.cpp: implementation of the PropertiesBase class.
//
//////////////////////////////////////////////////////////////////////

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>


#include <atlbase.h>
#include <mtglobal_msg.h>
#include <PCCache.h>
#import "MTProductCatalogExec.tlb" rename ("EOF", "RowsetEOF")
#include "MTPCBase.h"
#include <PropertiesBase.h>


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

PropertiesBase::PropertiesBase()
{

}

PropertiesBase::~PropertiesBase()
{

}

STDMETHODIMP PropertiesBase::get_Properties(/*[out, retval]*/ IMTProperties  **pVal)
{
	if (!pVal)
		return E_POINTER;

	ASSERT(mPropertiesPtr != NULL); // propertiesPtr constructed in LoadPropertiesMetaData

	return mPropertiesPtr.CopyTo(pVal);
}

void PropertiesBase::LoadPropertiesMetaData (MTPCEntityType aEntityType)
{
	//load properties meta data
	HRESULT hr = mPropertiesPtr.CoCreateInstance(__uuidof(MTProperties));
	if (FAILED(hr))
		throw _com_error(hr);

	MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaDataSetPtr;
	metaDataSetPtr = PCCache::GetMetaData( aEntityType );

	long lCount = metaDataSetPtr->Count;
	
	// The collection indexes are 1-based
	for (long i = 1; i <= lCount; ++i)
	{
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr metaDataPtr;
		metaDataPtr = metaDataSetPtr->Item[i];

		IMTPropertyMetaData* metaData = reinterpret_cast<IMTPropertyMetaData*>(metaDataPtr.GetInterfacePtr());
		IMTProperty* prop = NULL;
		hr = mPropertiesPtr->Add (metaData, &prop);
		if (FAILED(hr))
			throw _com_error(hr);
		if (prop)
			prop->Release();
	}
}

MTPRODUCTCATALOGLib::IMTPropertyPtr PropertiesBase::GetPropertyPtr(char* apPropertyName)
{
	VARIANT varProperty;
  VariantInit(&varProperty);
   
	_variant_t varName(apPropertyName);

	HRESULT hr = mPropertiesPtr->get_Item( varName, &varProperty);
  if (FAILED(hr)) 
		MT_THROW_COM_ERROR("Cannot find property: %s", apPropertyName);

	MTPRODUCTCATALOGLib::IMTPropertyPtr propPtr;
	propPtr = _variant_t(varProperty, false);

	return propPtr;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, BSTR *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		_bstr_t str = GetPropertyPtr(apPropertyName)->Value;
		*apVal = str.copy();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, BSTR aNewVal)
{
	try
	{
		GetPropertyPtr(apPropertyName)->Value = aNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, VARIANT *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		_variant_t var = GetPropertyPtr(apPropertyName)->Value;
		*apVal = var.Detach();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, VARIANT aNewVal)
{
	try
	{
		GetPropertyPtr(apPropertyName)->Value = aNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, long *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		*apVal = GetPropertyPtr(apPropertyName)->Value;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, long aNewVal)
{
	try
	{
		GetPropertyPtr(apPropertyName)->Value = aNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, VARIANT_BOOL *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		*apVal = GetPropertyPtr(apPropertyName)->Value;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, VARIANT_BOOL aNewVal)
{
	try
	{
		GetPropertyPtr(apPropertyName)->Value = aNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, DATE *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		_variant_t varValue = GetPropertyPtr(apPropertyName)->Value;
		
		//change to VT_DATE before changing it to DATE(in case it was a bstr)
		varValue.ChangeType(VT_DATE);
		
		*apVal = varValue;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, DATE aNewVal)
{
	try
	{
		_variant_t varNewVal(aNewVal);
		varNewVal.ChangeType(VT_DATE);
		
		GetPropertyPtr(apPropertyName)->Value = varNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::GetPropertyValue(char* apPropertyName, DECIMAL *apVal)
{
	if (!apVal)
		return E_POINTER;

	try
	{
		_variant_t varValue = GetPropertyPtr(apPropertyName)->Value;
		
		//change to VT_DATE before changing it to DECIMAL (in case it was a bstr)
		varValue.ChangeType(VT_DECIMAL);
		
		*apVal = varValue;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyValue(char* apPropertyName, DECIMAL aNewVal)
{
	try
	{
		_variant_t varNewVal(aNewVal);
		varNewVal.ChangeType(VT_DECIMAL);
		
		GetPropertyPtr(apPropertyName)->Value = varNewVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

//use different name for objects to allow implicit casting to IDispatch*
HRESULT PropertiesBase::GetPropertyObject(char* apPropertyName, IDispatch**apObject)
{
	if (!apObject)
		return E_POINTER;

	try
	{
		IDispatch* obj = GetPropertyPtr(apPropertyName)->Value;
		*apObject = obj;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

HRESULT PropertiesBase::PutPropertyObject(char* apPropertyName, IDispatch* apObject)
{
	try
	{
		GetPropertyPtr(apPropertyName)->Value = apObject;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}		

	return S_OK;
}

//convenience method
long PropertiesBase::GetID()
{
	long ID = 0;
	GetPropertyValue("ID", &ID);
	return ID;
}

//returns true if object has a not null ID
bool PropertiesBase::HasID()
{
	long ID;
	HRESULT hr = GetPropertyValue("ID", &ID);
	if (SUCCEEDED(hr) && ID != PROPERTIES_BASE_NO_ID)
		return true;
	else
		return false;
}

// validate properties,
// checks that all required properties have been entered
// throws user error if invalid
void PropertiesBase::ValidateProperties()
{

	MTPRODUCTCATALOGLib::IMTPropertiesPtr props = (IMTProperties*)mPropertiesPtr;

	//for all properties
	long lCount = props->Count;

	// The collection indexes are 1-based
	for (long i = 1; i <= lCount; ++i)
	{
		MTPRODUCTCATALOGLib::IMTPropertyPtr prop = props->Item[i];
		MTPRODUCTCATALOGLib::PropValType dataType;
		prop->get_DataType(&dataType);

		//do not check 'ID'. since item might not have been created yet
		_bstr_t propName = prop->Name;
		if (strcmpi(propName, "ID") == 0)
			continue;
		
		_variant_t val = prop->Value;

		//check for null entry on required values
		if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty ))
		{
			if (prop->Required == VARIANT_TRUE &&
					(val.vt == VT_EMPTY || val.vt == VT_NULL))
			{
				MT_THROW_COM_ERROR(MTPCUSER_PROPERTY_REQUIRED, (char*)propName);
			}
		}

		//do type specific checks 
		switch (dataType)
		{
			case PROP_TYPE_STRING:
				{
					_bstr_t strVal;
					if (val.vt != VT_EMPTY && val.vt != VT_NULL)
						strVal = val;

					//if prop is required make sure we have a non-empty string
					if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty ))
					{
						if (prop->Required == VARIANT_TRUE &&
								strVal.length() == 0)
						{
							MT_THROW_COM_ERROR(MTPCUSER_PROPERTY_REQUIRED, (char*)prop->Name);
						}
					}

					//make sure length is not exceeded
					if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_All_CheckStringLength ))
					{
						if (strVal.length() > static_cast<unsigned long>(prop->Length))
						{
							MT_THROW_COM_ERROR(MTPCUSER_PROPERTY_LENGTH_EXCEEDED, (char*)prop->Name, prop->Length, strVal.length());
						}
					}
					break;
				}
      case PROP_TYPE_DATETIME:
        {
          if(prop->Required == VARIANT_TRUE) {
            DATE dateval = 0;
            if(val.vt == VT_DATE) {
              dateval = val;
            }
            if(dateval == 0) {
			        MT_THROW_COM_ERROR(MTPCUSER_PROPERTY_REQUIRED, (char*)prop->Name);
            }
          }
          break;
        }
			default:
				break;
		}
	}
}

//copy all extended props from this property collection to targetProps
void PropertiesBase::CopyExtendedProperties(IMTProperties* apTargetProps)
{
	MTPRODUCTCATALOGLib::IMTPropertiesPtr sourceProps = (IMTProperties*)mPropertiesPtr;
	MTPRODUCTCATALOGLib::IMTPropertiesPtr targetProps = apTargetProps;
	long count = sourceProps->Count;
	for(long i = 1; i <= count; i++) //1-based collection
	{
		MTPRODUCTCATALOGLib::IMTPropertyPtr sourceProp;
		sourceProp = sourceProps->GetItem(i);

		if(sourceProp->Extended == VARIANT_TRUE)
		{
			//look up target property by name and set it
			_bstr_t propName =  sourceProp->Name;
			
			MTPRODUCTCATALOGLib::IMTPropertyPtr targetProp;
			targetProp = targetProps->GetItem(propName);

			targetProp->Value = sourceProp->Value;
		}
	}
}

// virtual function that gets called when a client requests a IMTProperties pointer.
// A derived class can override this method to load up the full Properties collection
// (in case some properties are loaded on demand)
HRESULT PropertiesBase::OnGetProperties()
{
	return S_OK;
}
