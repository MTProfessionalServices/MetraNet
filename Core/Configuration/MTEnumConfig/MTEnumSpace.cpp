// MTEnumSpace.cpp : Implementation of CMTEnumSpace
#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "MTEnumSpace.h"
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

/////////////////////////////////////////////////////////////////////////////
// CMTEnumSpace

HRESULT CMTEnumSpace::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CMTEnumSpace::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] =	
	{
		&IID_IMTEnumSpace
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     			GetEnumTypes
// Arguments:     
// Return Value:  IMTEnumTypeCollection** val - enum type collection
// Raised Errors:
// Description:  Returns enum type collection defined in this enum space
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::GetEnumTypes(IMTEnumTypeCollection ** pEnumTypeColl)
{
	if (pEnumTypeColl == NULL)
	  return E_POINTER;
	mEnumTypeCollection->QueryInterface(IID_IMTEnumTypeCollection, 
			reinterpret_cast<void**>(pEnumTypeColl));
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			GetEnumType
// Arguments:     BSTR name					-	enum type name
// Return Value:  IMTEnumType** val - enum type
// Raised Errors:
// Description:  Returns enum type object given the enum type name
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::GetEnumType(BSTR name, IMTEnumType ** pType)
{
	try
	{
		HRESULT nRet = S_OK;
		_bstr_t bstrCrit = name;
		string crit = _strlwr((char*)bstrCrit);

		MTENUMCONFIGLib::IMTEnumTypePtr p;
	
		CComVariant varEnum;
		varEnum.vt = VT_DISPATCH;
	
		for(int i=0;i < mEnumTypeCollection->GetSize();)
		{
		
			nRet = mEnumTypeCollection->get_Item(++i, &varEnum);
			if(!SUCCEEDED(nRet))
				return nRet;
		
			nRet = varEnum.pdispVal->QueryInterface(IID_IMTEnumType, (void**)&p);
			varEnum.Clear();

			if(!SUCCEEDED(nRet))
				return nRet;
			_bstr_t name = p->GetEnumTypeName();
			string nm = _strlwr((char*)name);
			if(crit.compare(nm) == 0)
			{
				*pType = (IMTEnumType *) p.Detach();
				return nRet;
			}
		
			p.Release();
		}

		(*pType) = NULL;
		mLogger->LogVarArgs(LOG_ERROR, "Enum Type \"%s/%s\" not found in the collection!", 
												(const char*)mName, (const char*)bstrCrit);
		return nRet;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
}

// ----------------------------------------------------------------
// Name:     			Add
// Arguments:     IMTEnumType* val - enum type
// Return Value:  
// Raised Errors:
// Description:		Adds enum type object tho this enum space
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::Add(IMTEnumType *pEnumType)
{
	try
	{
		HRESULT nRet;
		MTENUMCONFIGLib::IMTEnumTypePtr enumPtr(pEnumType);
	
		/*
			Look at enum space location property.
			If this property exist, assume that I am adding enum type to already existing enum space
			and set status to "Added"
		*/
		if (mLocation.length() == 0)
			pEnumType->put_Status(ENUM_TYPE_STATUS_ADDED);
		nRet = mEnumTypeCollection->Add(enumPtr);
		return nRet;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
	
}

// ----------------------------------------------------------------
// Name:     			get_Name
// Arguments:     
// Return Value:  BSTR* val - enum space name
// Raised Errors:
// Description:		Returns name for this enum space
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::get_Name(BSTR *pVal)
{
	*pVal = mName.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_Name
// Arguments:     BSTR val - enumspace name
// Return Value:  
// Raised Errors:
// Description:		sets a name for this enumspace
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Description
// Arguments:     
// Return Value:  BSTR* val - enum space description
// Raised Errors:
// Description:		Returns description for this enum space
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::get_Description(BSTR *pVal)
{
	*pVal = mDescription.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_Description
// Arguments:     BSTR val - enumspace description
// Return Value:  
// Raised Errors:
// Description:		sets a description for this enumspace
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Location
// Arguments:     
// Return Value:  BSTR* val - file where this enum space is located
// Raised Errors:
// Description:		Returns location for this enum space
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::get_Location(BSTR *pVal)
{
	*pVal = mLocation.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			put_Location
// Arguments:     
// Return Value:  BSTR* val - file where this enum space is located
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::put_Location(BSTR newVal)
{
	mLocation = newVal;

	// set the extensionname from the location
	string aConfigDir;
	if(GetExtensionsDir(aConfigDir)) {
		aConfigDir += DIR_SEP;

		string aLocationTemp((const char*)mLocation + aConfigDir.length());
		size_t templen = aLocationTemp.find("\\");
		char* pTempStr = new char[templen+1];
		strncpy(pTempStr,aLocationTemp.c_str(),templen);
		pTempStr[templen] = '\0';
		mExtension = pTempStr;
		delete[] pTempStr;
		return S_OK;
	}
	else {
		return Error("Failed to get extension directory");
	}
}

// ----------------------------------------------------------------
// Name:     			WriteSet
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:		INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpace::WriteSet(IMTConfigPropSet *apPropSet)
{
	HRESULT hr = S_OK;
	try
	{
		//MTConfigLib::IMTConfigAttribSetPtr pAttrib;
		MTConfigLib::IMTConfigAttribSetPtr pAttrib(MTPROGID_CONFIG_ATTRIB_SET);
		pAttrib->Initialize();
		string procName = "CMTEnumSpace::WriteSet";
		if (apPropSet == NULL)
			return E_POINTER;
		
		MTConfigLib::IMTConfigPropSetPtr pSet(apPropSet);
		//create attribute pair
		hr = pAttrib->AddPair(ATTRIB_TAG_NAME, mName);
		
		if(!SUCCEEDED(hr)) return hr;
		MTConfigLib::IMTConfigPropSetPtr pEnumSpaceSet = pSet->InsertSet(ENUM_SPACE_TAG_NAME);
		hr = pEnumSpaceSet->put_AttribSet(pAttrib);
		if(!SUCCEEDED(hr)) return hr;
	 	
		
		
		if (pEnumSpaceSet == NULL)
		{
			hr = E_FAIL;
			return (hr);
		}
		//insert description tag
		//_variant_t desc;
		_variant_t desc;
		
		desc = mDescription;
		pEnumSpaceSet->InsertProp(DESC_TAG_NAME,  MTConfigLib::PROP_TYPE_STRING, desc);
		MTENUMCONFIGLib::IMTConfigPropSetPtr pEnumTypesSet = pEnumSpaceSet->InsertSet(ENUM_TYPES_TAG_NAME);
		for (int i=0;i < mEnumTypeCollection->GetSize() ;)
		{
			MTENUMCONFIGLib::IMTEnumTypePtr pEnumType = NULL;
		
			CComVariant varEnum;
			varEnum.vt = VT_DISPATCH;
		

			hr = mEnumTypeCollection->get_Item(++i, &varEnum);
			if(!SUCCEEDED(hr))
				return hr;
			
			hr = varEnum.pdispVal->QueryInterface(IID_IMTEnumType, (void**)&pEnumType);
			varEnum.Clear();

			if(!SUCCEEDED(hr))
				return hr;
			try
			{
				pEnumType->WriteSet(pEnumTypesSet);
			}
			catch(_com_error e)
			{
				return ReturnComError(e);
			}
		}
		
	}
	catch(_com_error err)
	{
		mLogger->LogVarArgs(LOG_ERROR, "CMTEnumSpace::WriteSet failed with error <%s>!",
				(const char*)err.Description());
		return ReturnComError(err);
	}
	return hr;
}

STDMETHODIMP CMTEnumSpace::get_Extension(BSTR* pExtensionName)
{
	ASSERT(pExtensionName);
	if(!pExtensionName) return E_POINTER;
	*pExtensionName = mExtension.copy();
	return S_OK;
}
