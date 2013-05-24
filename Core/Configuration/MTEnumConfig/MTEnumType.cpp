// MTEnumType.cpp : Implementation of CMTEnumType
/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "MTEnumType.h"
#include "EnumConfig.h"

//#import <MTConfigLib.tlb>


/////////////////////////////////////////////////////////////////////////////
// CMTEnumType

// ----------------------------------------------------------------
// Description:  INTERNAL USE USE
// ----------------------------------------------------------------

HRESULT CMTEnumType::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


CMTEnumType::~CMTEnumType()
{
	if (mpValueColl)
	{
		delete mpValueColl;
		mpValueColl = NULL;
	}
}

// ----------------------------------------------------------------
// Description:  AUTO GENERATED
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumType
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     			get_Enumspace
// Arguments:     
// Return Value:  BSTR* val - enum space name
// Raised Errors:
// Description:		Returns name for enum space this enum type belongs to
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::get_Enumspace(BSTR *pVal)
{
	*pVal = mEnumSpace.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_Enumspace
// Arguments:     BSTR val - enum space name
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::put_Enumspace(BSTR newVal)
{
	mEnumSpace = newVal;
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			get_Status
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:		CURRENTLY NOT USED
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::get_Status(BSTR *pVal)
{
	*pVal = mStatus.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_Status
// Arguments:  
// Return Value:  
// Raised Errors:
// Description:  CURRENTLY NOT USED
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::put_Status(BSTR newVal)
{
	mStatus = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_EnumTypeName
// Arguments:			
// Return Value:  BSTR*		-	enum type name     
// Raised Errors:
// Description:		Returns name for this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::get_EnumTypeName(BSTR *pVal)
{
	*pVal = mEnumType.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_EnumTypeName
// Arguments:			BSTR		-	enum type name     
// Return Value:  
// Raised Errors:
// Description:		Sets name for this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::put_EnumTypeName(BSTR newVal)
{
	mEnumType = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_EnumTypeDescription
// Arguments:			
// Return Value:  BSTR*		-	enum type description
// Raised Errors:
// Description:		Returns description for this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::get_EnumTypeDescription(BSTR *pVal)
{
	*pVal = mEnumTypeDescription.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_EnumTypeDescription
// Arguments:			BSTR		-		enum type description
// Return Value:  
// Raised Errors:
// Description:		Sets description for this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::put_EnumTypeDescription(BSTR newVal)
{
	mEnumTypeDescription = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_EnumSpaceDescription
// Arguments:			
// Return Value:  BSTR*		-		enum space description
// Raised Errors:
// Description:		Returns description for enum space this enum type belongs to
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::get_EnumSpaceDescription(BSTR *pVal)
{
	*pVal = mEnumSpaceDescription.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_EnumSpaceDescription
// Arguments:			BSTR		-		enum space description
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::put_EnumSpaceDescription(BSTR newVal)
{
	mEnumSpaceDescription = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			Add
// Arguments:			IMTEnumerator		-		enum space description
// Return Value:  
// Raised Errors:
// Description:		Adds enumerator to this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::Add(::IMTEnumerator *pEnumerator)
{
  HRESULT nRet;
  _bstr_t enum_space, enum_type, name, val, lwrVal;
  try
  {
    MTENUMCONFIGLib::IMTEnumTypePtr EnumTypePtr(this);
    MTENUMCONFIGLib::IMTEnumeratorPtr enumPtr(pEnumerator);
    //TODO: Check for value collisions with other enumerators of
    // this enum type
    
    //get the name for enum space and enum type
    enum_space = EnumTypePtr->GetEnumspace();
    enum_type = EnumTypePtr->GetEnumTypeName();
    
    //get the name for the enumerator
    name = enumPtr->Getname();
    
    if(name.length() == 0)
    {
      char buf[255];
      sprintf(buf, "Enumerator must have a name!");
      return Error(buf, IID_IMTEnumType, E_FAIL);
    }
    
    
    //if enumerator names collide
    for(mValueCollIterator=mpValueColl->begin(); mValueCollIterator != mpValueColl->end() ;)
    {
      _bstr_t temp = (*mValueCollIterator++).second;
      
      if (_wcsicmp((wchar_t*) temp, (wchar_t*) name) == 0)
      {
        char buf[255];
        sprintf(buf, "Enumerator %s/%s/%s already exists!", (char*)enum_space,(char*)enum_type,(char*)name);
        mLogger->LogThis(LOG_ERROR, buf);
        MT_THROW_COM_ERROR(MTENUMCONFIG_DUPLICATE_ENUMERATOR, buf);
      }
    }
    
    
    //1. Iterate through all the values in this enumerator
    for (int i=0; i < enumPtr->NumValues(); i++)
    {
      val = enumPtr->ElementAt(i);
      lwrVal = _wcslwr((wchar_t*)val);
      
      //2. Look up this value in the map
      ASSERT(mpValueColl != NULL);
      
      
      mValueCollIterator = mpValueColl->find(lwrVal);
      
      
      //3. If found - raise an error (duplicate value)...
      if (mValueCollIterator != mpValueColl->end())
      {
        char buf[1024];
        _bstr_t nm = (*mValueCollIterator).second;
        sprintf(buf, "Value '%s' is already associated with '%s'",
          (char*)val,
          (char*)enum_space,
          (char*)enum_type,
          (char*)name,
          (char*)nm );
        mLogger->LogThis(LOG_ERROR, buf);
        MT_THROW_COM_ERROR(MTENUMCONFIG_DUPLICATE_ENUMERATION_VALUE, buf);
      }
      else
      {
        //... if not - add to collection
        mpValueColl->insert(EnumTypeValueColl::value_type(lwrVal, name));
      }
      
    }
    
    nRet = mEnumeratorCollection->Add(enumPtr);
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return nRet;
}

// ----------------------------------------------------------------
// Name:     			WriteSet
// Arguments:			
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::WriteSet(IMTConfigPropSet *apPropSet)
{
	HRESULT hr = S_OK;
	MTENUMCONFIGLib::IMTEnumTypePtr enumPtr(this);
	try
	{
		mLogger->LogVarArgs(	LOG_DEBUG, "Writing configuration for enum type %s (%s)",
												(char*)mEnumType, (char*)mEnumTypeDescription);
		MTConfigLib::IMTConfigAttribSetPtr pAttrib(MTPROGID_CONFIG_ATTRIB_SET);
		pAttrib->Initialize();
		string procName = "CMTEnumType::WriteSet";
		if (apPropSet == NULL)
		{
			mLogger->LogThis(LOG_ERROR, "PropSet NULL!");
			return E_POINTER;
		}
		
		MTConfigLib::IMTConfigPropSetPtr pSet(apPropSet);
		//create attribute pair
		hr = pAttrib->AddPair(ATTRIB_TAG_NAME, mEnumType);
		
		/*
		if (mStatus != _bstr_t(L""))
			hr = pAttrib->AddPair(ATTRIB_TAG_STATUS, mStatus);
		*/
		if(!SUCCEEDED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "Failed Creating attrib set!");
			return hr;
		}
		MTConfigLib::IMTConfigPropSetPtr pEnumTypeSet = pSet->InsertSet(ENUM_TAG_NAME);
		hr = pEnumTypeSet->put_AttribSet(pAttrib);
		
		if(!SUCCEEDED(hr))
		{
			mLogger->LogThis(LOG_ERROR, "Failed adding attrib set to configuration set");
			return hr;
		}	
		
		if (pEnumTypeSet == NULL)
		{
			hr = E_FAIL;
			return (hr);
		}
		//insert description tag
		//_variant_t desc;
		_variant_t desc;
		
		mLogger->LogThis(LOG_DEBUG, "Setting description string");
		desc = mEnumTypeDescription;
		pEnumTypeSet->InsertProp(DESC_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, desc);
		MTENUMCONFIGLib::IMTConfigPropSetPtr pEntriesSet = pEnumTypeSet->InsertSet(ENUM_ENTRIES_TAG_NAME);
		int size = mEnumeratorCollection->GetSize();
		if (size > 0)
			mLogger->LogVarArgs(LOG_DEBUG, "Adding %i enumerators", size);
		else
		{
			char buffer[256];
			_bstr_t enumName = enumPtr->GetEnumTypeName();
			sprintf(	buffer, "%s: At least one enumerator has to be set for an enum type",
								(const char*) enumName);
			mLogger->LogThis(LOG_ERROR, buffer);
			return Error (buffer, IID_IMTEnumType, E_FAIL);
		}

		for (int i=0;i < size;)
		{
			MTENUMCONFIGLib::IMTEnumeratorPtr pEnum = NULL;
			// create a variant

			CComVariant varEnum;
			varEnum.vt = VT_DISPATCH;


			hr = mEnumeratorCollection->get_Item(++i, &varEnum);
			if(!SUCCEEDED(hr))
				return hr;
			
			hr = varEnum.pdispVal->QueryInterface(IID_IMTEnumerator, (void**)&pEnum);
			varEnum.Clear();

			if(!SUCCEEDED(hr))
				return hr;
			pEnum->WriteSet(pEntriesSet);
		}
		
	}
	catch(_com_error err)
	{
		mLogger->LogVarArgs(LOG_ERROR, "CMTEnumType::WriteSet failed with error <%s>!",
				err.Description());
		return ReturnComError(err);
	}
	return hr;
}

// ----------------------------------------------------------------
// Name:     			GetEnumerators
// Arguments:			
// Return Value:  IMTEnumeratorCollection** - enumerator collection
// Raised Errors:
// Description:		Returns enuemrators defined in this enum type
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumType::GetEnumerators(IMTEnumeratorCollection **pEnumColl)
{
	if (pEnumColl == NULL)
	  return E_POINTER;
	mEnumeratorCollection->QueryInterface(IID_IMTEnumeratorCollection, 
			reinterpret_cast<void**>(pEnumColl));
	return S_OK;
}
