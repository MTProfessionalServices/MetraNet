// MTAtomicCapabilityTypeReader.cpp : Implementation of CMTAtomicCapabilityTypeReader
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTAtomicCapabilityTypeReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityTypeReader

STDMETHODIMP CMTAtomicCapabilityTypeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAtomicCapabilityTypeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAtomicCapabilityTypeReader::Activate()
{
  HRESULT hr = GetObjectContext(&m_spObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTAtomicCapabilityTypeReader::CanBePooled()
{
  return FALSE;
} 

void CMTAtomicCapabilityTypeReader::Deactivate()
{
  m_spObjectContext.Release();
} 


STDMETHODIMP CMTAtomicCapabilityTypeReader::Get(long aTypeID, IMTAtomicCapabilityType **apNewType)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apNewType)
    return E_POINTER;
  
  *apNewType = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset = thisPtr->GetAsRowset(aTypeID);
    MTAUTHLib::IMTAtomicCapabilityTypePtr actPtr(__uuidof(MTAUTHLib::MTAtomicCapabilityType));
    
    if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      actPtr->ID = rowset->GetValue("id_cap_type");
      actPtr->GUID = MTMiscUtil::GetString(rowset->GetValue("tx_guid"));
      actPtr->Name = MTMiscUtil::GetString(rowset->GetValue("tx_name"));
      actPtr->Description = MTMiscUtil::GetString(rowset->GetValue("tx_desc"));
      actPtr->ProgID = MTMiscUtil::GetString(rowset->GetValue("tx_progid"));
      actPtr->Editor = MTMiscUtil::GetString(rowset->GetValue("tx_editor"));
    }
    (*apNewType) = reinterpret_cast<IMTAtomicCapabilityType*>(actPtr.Detach());
		context.Complete();
    return S_OK;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::GetAsRowset(long aTypeID, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  if (!apRowset)
    return E_POINTER;
  
  *apRowset = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__INIT_ACT__");
    rowset->AddParam("%%ACT_ID%%", aTypeID);
    rowset->Execute();
    context.Complete();
    (*apRowset) = (IMTSQLRowset*)rowset.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  
  return S_OK;
}
STDMETHODIMP CMTAtomicCapabilityTypeReader::GetByInstanceID(long aInstanceID, IMTAtomicCapabilityType **apNewType)
{
  HRESULT hr(S_OK);
  long lTypeID;
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apNewType)
    return E_POINTER;
  
  *apNewType = NULL;
  
  try
  {
    lTypeID = thisPtr->GetTypeIDByInstanceID(aInstanceID);
    (*apNewType) = (IMTAtomicCapabilityType*)thisPtr->Get(lTypeID).Detach();
    context.Complete();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}
STDMETHODIMP CMTAtomicCapabilityTypeReader::GetByInstanceIDAsRowset(long aInstanceID, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
  long lTypeID;
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apRowset)
    return E_POINTER;
  
  *apRowset = NULL;
  
  try
  {
    lTypeID = thisPtr->GetTypeIDByInstanceID(aInstanceID);
    (*apRowset) = (IMTSQLRowset*)thisPtr->GetAsRowset(lTypeID).Detach();
    context.Complete();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::GetTypeIDByInstanceID(long aInstanceID, long *apTypeID)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apTypeID)
    return E_POINTER;
  
  *apTypeID = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_ACT_ID_BY_INSTANCE_ID__");
    rowset->AddParam("%%INSTANCE_ID%%", aInstanceID);
    rowset->Execute();
    
    if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
    {
      MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_NOT_FOUND_BY_INSTANCE, aInstanceID);
    }
    
    (*apTypeID) = (long)rowset->GetValue("id_cap_type");
    context.Complete();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::GetTypeIDByName(BSTR aTypeName, long *apTypeID)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apTypeID)
    return E_POINTER;
  
  *apTypeID = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_ACT_ID_BY_NAME__");
    rowset->AddParam("%%NAME%%", aTypeName);
    rowset->Execute();
    
    if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
    {
      MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_NOT_FOUND, (char*)_bstr_t(aTypeName));
    }
    if (rowset->GetRecordCount() > 1)
    {
      MT_THROW_COM_ERROR(MTAUTH_ATOMIC_CAPABILITY_TYPE_MORE_THEN_ONE_FOUND, (char*)_bstr_t(aTypeName));
    }
    
    (*apTypeID) = (long)rowset->GetValue("id_cap_type");
    context.Complete();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::GetByName(BSTR aTypeName, IMTAtomicCapabilityType **apNewType)
{
  HRESULT hr(S_OK);
  long lTypeID;
  MTAutoContext context(m_spObjectContext);
  MTAUTHEXECLib::IMTAtomicCapabilityTypeReaderPtr thisPtr = this;
  
  if (!apNewType)
    return E_POINTER;
  
  *apNewType = NULL;
  
  try
  {
    lTypeID = thisPtr->GetTypeIDByName(aTypeName);
    (*apNewType) = (IMTAtomicCapabilityType*)thisPtr->Get(lTypeID).Detach();
    context.Complete();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::FindRecordsByNameAsRowset(BSTR aTypeName, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  if (!apRowset)
    return E_POINTER;
  
  *apRowset = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_ACTS_BY_NAME__");
    rowset->AddParam("%%NAME%%", aTypeName);
    rowset->Execute();
    context.Complete();
    (*apRowset) = (IMTSQLRowset*)rowset.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::FindNameByProgIDAsRowset(BSTR aProgID, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  if (!apRowset)
    return E_POINTER;
  
  *apRowset = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_ACT_NAME_BY_PROGID__");
    rowset->AddParam("%%PROGID%%", aProgID);
    rowset->Execute();
    context.Complete();
    (*apRowset) = (IMTSQLRowset*)rowset.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  
  return S_OK;
}

STDMETHODIMP CMTAtomicCapabilityTypeReader::FindInstancesByNameAsRowset(BSTR aTypeName, IMTSQLRowset **apRowset)
{
  HRESULT hr(S_OK);
  MTAutoContext context(m_spObjectContext);
  if (!apRowset)
    return E_POINTER;
  
  *apRowset = NULL;
  
  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_ACT_INSTANCES_BY_NAME__");
    rowset->AddParam("%%NAME%%", aTypeName);
    rowset->Execute();
    context.Complete();
    (*apRowset) = (IMTSQLRowset*)rowset.Detach();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  return S_OK;
}
