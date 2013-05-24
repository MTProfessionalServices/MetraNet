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
#include "MTAuth.h"
#include "MTAtomicCapabilityType.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityType

STDMETHODIMP CMTAtomicCapabilityType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAtomicCapabilityType,
    &IID_IMTCapability
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAtomicCapabilityType::get_ID(long *aVal)
{
	(*aVal) = mID;
	return S_OK;
}


STDMETHODIMP CMTAtomicCapabilityType::put_ID(long newVal)
{
	mID = newVal;
	return S_OK;
}


STDMETHODIMP CMTAtomicCapabilityType::get_Name(BSTR *pVal)
{
	(*pVal) = mName.copy();

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::get_Description(BSTR *pVal)
{
	(*pVal) = mDesc.copy();

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_Description(BSTR newVal)
{
	mDesc = newVal;
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::get_ProgID(BSTR *pVal)
{
	(*pVal) = mProgID.copy();

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_ProgID(BSTR newVal)
{
	mProgID = newVal;
	return S_OK;
}


STDMETHODIMP CMTAtomicCapabilityType::get_Editor(BSTR *pVal)
{
	(*pVal) = mEditor.copy();

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_Editor(BSTR newVal)
{
	mEditor = newVal;

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::CreateInstance(IMTAtomicCapability **apNewInstance)
{
	HRESULT hr(S_OK);
	MTAUTHLib::IMTAtomicCapabilityPtr newInstance;
	
	try
	{
		MTAUTHLib::IMTAtomicCapabilityTypePtr thisPtr = this;
		hr = newInstance.CreateInstance((char*)thisPtr->ProgID);
		if(FAILED(hr))
		{
			MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_CREATION_FAILED, (char*)thisPtr->ProgID, hr);
		}
		newInstance->CapabilityType = reinterpret_cast<MTAUTHLib::IMTAtomicCapabilityType*>(this);
		(*apNewInstance) = reinterpret_cast<IMTAtomicCapability*>(newInstance.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}

	return hr;

}

STDMETHODIMP CMTAtomicCapabilityType::Save()
{
	HRESULT hr(S_OK);
	bool bUpdate(FALSE);
	ROWSETLib::IMTSQLRowsetPtr rowset;
	try
	{
		MTAUTHLib::IMTAtomicCapabilityTypePtr thisPtr = this;
		
		MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr reader
			(__uuidof(MTAUTHEXECLib::MTAtomicCapabilityTypeReader));
		MTAUTHEXECLib::IMTAtomicCapabilityTypeWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTAtomicCapabilityTypeWriter));
		
		//1. See if the record with this name already exists
		rowset = reader->FindRecordsByNameAsRowset(thisPtr->Name);
		
		if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			if(rowset->GetRecordCount() > 1)
			{
				MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_NAME_NOT_UNIQUE, (char*)thisPtr->Name);
			}
			
			bUpdate = TRUE;
			_bstr_t name = rowset->GetValue("tx_name"); 
			_bstr_t progid = rowset->GetValue("tx_progid"); 
			thisPtr->ID = rowset->GetValue("id_cap_type"); 
			
			//if there are already instances of this type, check if progid changed
			//and not allow updates if it did
			rowset = reader->FindInstancesByNameAsRowset(thisPtr->Name);
			
			if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				if(_wcsicmp((wchar_t*)progid, (wchar_t*)thisPtr->ProgID))
				{	
					MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_UPDATE_FAILED, (char*)thisPtr->Name, (char*)progid, (char*)thisPtr->ProgID);
				}
			}
		}
		//see if progid already exists for different name
		rowset = reader->FindNameByProgIDAsRowset(thisPtr->ProgID);
		if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_bstr_t name = rowset->GetValue("tx_name");
			if(_wcsicmp((wchar_t*)name, (wchar_t*)thisPtr->Name))
			{
				MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_PROGID_COLLISION, (char*)thisPtr->Name, (char*)thisPtr->ProgID);
			}
		}
			
		//do create or update:
		if (thisPtr->ID > -1)
			writer->Update((MTAUTHEXECLib::IMTAtomicCapabilityType *)thisPtr.GetInterfacePtr());
		else
			thisPtr->ID = writer->Create((MTAUTHEXECLib::IMTAtomicCapabilityType *)thisPtr.GetInterfacePtr());
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::get_CompositionDescription(BSTR *pVal)
{
	(*pVal) = mCompDesc.copy();
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_CompositionDescription(BSTR newVal)
{
	mCompDesc = newVal;
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::get_ParameterName(BSTR *pVal)
{
	(*pVal) = mParamName.copy();
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_ParameterName(BSTR newVal)
{
	mParamName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::get_GUID(BSTR *pVal)
{
	(*pVal) = mGUID.copy();

	return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityType::put_GUID(BSTR newVal)
{
	mGUID = newVal;

	return S_OK;
}