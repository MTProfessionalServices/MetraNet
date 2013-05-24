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
#include "MTCompositeCapabilityType.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityType

STDMETHODIMP CMTCompositeCapabilityType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapabilityType
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCompositeCapabilityType::get_ID(long *aVal)
{
	(*aVal) = mID;
	return S_OK;
}


STDMETHODIMP CMTCompositeCapabilityType::put_ID(long newVal)
{
	mID = newVal;
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::Save()
{
	HRESULT hr(S_OK);
	bool bUpdate(FALSE);
	ROWSETLib::IMTSQLRowsetPtr rowset;
	try
	{
		MTAUTHLib::IMTCompositeCapabilityTypePtr thisPtr = this;
		
		MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr reader
			(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeReader));
		MTAUTHEXECLib::IMTCompositeCapabilityTypeWriterPtr writer
			(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeWriter));
		
		//1. See if the record with this name already exists
		rowset = reader->FindRecordsByNameAsRowset(thisPtr->Name);
		
		if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			if(rowset->GetRecordCount() > 1)
			{
				MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_TYPE_NAME_NOT_UNIQUE, (char*)thisPtr->Name);
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
				char buf[1024];
        sprintf(buf, "Capability Type <%s> will not be updated because it has instances.", (char*)name);
        LogAuthDebug(buf);
        return S_OK;
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
			writer->Update((MTAUTHEXECLib::IMTCompositeCapabilityType *)thisPtr.GetInterfacePtr());
		else
			thisPtr->ID = writer->Create((MTAUTHEXECLib::IMTCompositeCapabilityType *)thisPtr.GetInterfacePtr());
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}

	return S_OK;
}


STDMETHODIMP CMTCompositeCapabilityType::get_Name(BSTR *pVal)
{
	(*pVal) = mName.copy();

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_Description(BSTR *pVal)
{
	(*pVal) = mDesc.copy();

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_Description(BSTR newVal)
{
	mDesc = newVal;
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_ProgID(BSTR *pVal)
{
	(*pVal) = mProgID.copy();

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_ProgID(BSTR newVal)
{
	mProgID = newVal;
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_GUID(BSTR *pVal)
{
	(*pVal) = mGUID.copy();

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_GUID(BSTR newVal)
{
	mGUID = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::CreateInstance(IMTCompositeCapability **apNewInstance)
{
	HRESULT hr(S_OK);
	MTAUTHLib::IMTCompositeCapabilityPtr newInstance;
	
	try
	{
		MTAUTHLib::IMTCompositeCapabilityTypePtr thisPtr = this;
		hr = newInstance.CreateInstance((char*)thisPtr->ProgID);
		if(FAILED(hr))
		{
			MT_THROW_COM_ERROR(MTAUTH_COMPOSITE_CAPABILITY_CREATION_FAILED, (char*)thisPtr->ProgID, hr);
		}
		newInstance->CapabilityType = reinterpret_cast<MTAUTHLib::IMTCompositeCapabilityType*>(this);
		long numAtomics = 0;
		mAtomicTypes.Count(&numAtomics);
		for (int i=1; i <= numAtomics; ++i)
		{
			MTAUTHLib::IMTAtomicCapabilityTypePtr atomicType;
			hr = mAtomicTypes.Item(i, (IMTAtomicCapabilityType**)&atomicType);
			newInstance->AddAtomicCapability(atomicType->CreateInstance());
		}

		(*apNewInstance) = reinterpret_cast<IMTCompositeCapability*>(newInstance.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnAuthError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_CSRAssignable(VARIANT_BOOL *pVal)
{
	(*pVal) = mCSRAssignable;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_CSRAssignable(VARIANT_BOOL newVal)
{
	mCSRAssignable = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_SubscriberAssignable(VARIANT_BOOL *pVal)
{
	(*pVal) = mSubscriberAssignable;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_SubscriberAssignable(VARIANT_BOOL newVal)
{
	mSubscriberAssignable = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_NumAtomic(long *pVal)
{
	mAtomicTypes.Count(pVal);

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_AllowMultipleInstances(VARIANT_BOOL *pVal)
{
	(*pVal) = mAllowMultipleInstances;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_AllowMultipleInstances(VARIANT_BOOL newVal)
{
	mAllowMultipleInstances = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_Editor(BSTR *pVal)
{
	(*pVal) = mEditor.copy();

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_Editor(BSTR newVal)
{
	mEditor = newVal;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::Init(IMTSessionContext* aCtx, long aTypeID)
{
	HRESULT hr(S_OK);
	bool bFirstRow(TRUE);
	try
	{
		MTAUTHLib::IMTCompositeCapabilityTypePtr thisPtr = this;
		
		MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr reader
			(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeReader));
		ROWSETLib::IMTSQLRowsetPtr rowset = reader->GetAsRowset(aTypeID);
		
		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			if (bFirstRow)
			{
				thisPtr->ID = rowset->GetValue("id_cap_type");
				thisPtr->GUID = MTMiscUtil::GetString(rowset->GetValue("tx_guid"));
				thisPtr->Name = MTMiscUtil::GetString(rowset->GetValue("tx_name"));
				thisPtr->Description = MTMiscUtil::GetString(rowset->GetValue("tx_desc"));
				thisPtr->ProgID = MTMiscUtil::GetString(rowset->GetValue("tx_progid"));
				thisPtr->Editor = MTMiscUtil::GetString(rowset->GetValue("tx_editor"));
				thisPtr->CSRAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("csr_assignable")));
				thisPtr->SubscriberAssignable = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("subscriber_assignable")));
				thisPtr->AllowMultipleInstances = MTTypeConvert::StringToBool(MTMiscUtil::GetString(rowset->GetValue("multiple_instances")));
			}
			MTAUTHLib::IMTAtomicCapabilityTypePtr actPtr;
			//if next value is null, then this composite has 0 atomics, just return
			_variant_t atomicProgID = (_bstr_t)rowset->GetValue("atomic_tx_progid");
      _bstr_t bstrAtomicProgID = (_bstr_t)atomicProgID;
			if(V_VT(&atomicProgID) == VT_NULL)
			{
				return S_OK;
			}
			
			//attempt to create the instacnce of atomic type
			hr = actPtr.CreateInstance((char*)bstrAtomicProgID);
			if(FAILED(hr)){
				MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_CREATION_FAILED, (char*)bstrAtomicProgID, hr);
			}
			actPtr->ProgID = (char*)bstrAtomicProgID;
			actPtr->ID = rowset->GetValue("atomic_id_cap_type");
			actPtr->CompositionDescription = MTMiscUtil::GetString(rowset->GetValue("CompositionDescription"));
			actPtr->Name = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_name"));
			actPtr->Description = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_desc"));
			actPtr->Editor = MTMiscUtil::GetString(rowset->GetValue("atomic_tx_editor"));
			thisPtr->AddAtomicCapabilityType(actPtr);

			bFirstRow = FALSE;
			rowset->MoveNext();
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::InitByInstanceID(IMTSessionContext* aCtx, long aInstanceID)
{
	HRESULT hr(S_OK);
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityTypePtr thisPtr = this;
		
		MTAUTHEXECLib::IMTCompositeCapabilityTypeReaderPtr reader
			(__uuidof(MTAUTHEXECLib::MTCompositeCapabilityTypeReader));
		long lTypeID = reader->GetTypeIDByInstanceID(aInstanceID);
		return Init(aCtx, lTypeID);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::AddAtomicCapabilityType(IMTAtomicCapabilityType *apAtomicType)
{
	if(apAtomicType == NULL)
		return E_POINTER;
	return mAtomicTypes.Add(apAtomicType);
}

STDMETHODIMP CMTCompositeCapabilityType::GetAtomicCapabilityTypes(IMTCollection** apAtomicTypes)
{
	if(apAtomicTypes == NULL)
		return E_POINTER;
	(*apAtomicTypes) = NULL;
	mAtomicTypes.CopyTo(apAtomicTypes);
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::Equals(IMTCompositeCapabilityType *aType, VARIANT_BOOL *apRes)
{
	HRESULT hr(S_OK);
  
  if(apRes == NULL)
    return E_POINTER;

	try
	{
		MTAUTHLib::IMTCompositeCapabilityTypePtr thisPtr = this;
    MTAUTHLib::IMTCompositeCapabilityTypePtr thatPtr = aType;
    (*apRes) = (thisPtr->ID == thatPtr->ID) ? VARIANT_TRUE : VARIANT_FALSE;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::get_UmbrellaSensitive(VARIANT_BOOL *pVal)
{
	(*pVal) = mUmbrellaSensitive;

	return S_OK;
}

STDMETHODIMP CMTCompositeCapabilityType::put_UmbrellaSensitive(VARIANT_BOOL newVal)
{
	mUmbrellaSensitive = newVal;

	return S_OK;
}
