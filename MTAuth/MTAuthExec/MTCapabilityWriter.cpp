// MTCompositeCapabilityWriter.cpp : Implementation of CMTCapabilityWriter
#include "StdAfx.h"
#include "MTAuthExec.h"
#include "MTCapabilityWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCapabilityWriter

STDMETHODIMP CMTCapabilityWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCapabilityWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


HRESULT CMTCapabilityWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 


BOOL CMTCapabilityWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCapabilityWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTCapabilityWriter::RemoveCompositeInstance(IMTCompositeCapability *apCap, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
  _variant_t vNull;
  vNull.ChangeType(VT_NULL);
	long numAtomics = 0;
	try
	{
		MTAUTHEXECLib::IMTCompositeCapabilityPtr capPtr = apCap;
    MTAUTHEXECLib::IMTPrincipalPolicyPtr polPtr = aPolicy;
		MTAUTHEXECLib::IMTAtomicCapabilityPtr atomicCapPtr;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

    numAtomics = capPtr->AtomicCapabilities->Count;

		for (int i=1; i <= numAtomics; ++i)
		{
			atomicCapPtr = capPtr->AtomicCapabilities->GetItem(i);
			ASSERT(atomicCapPtr != NULL);
			atomicCapPtr->Remove(polPtr);
		}
    
    //delete all composite instances of this type
		rowset->SetQueryTag("__DELETE_CAPABILITY_INSTANCE__");
		rowset->AddParam("%%ID%%", capPtr->ID);
    rowset->Execute();
		context.Complete();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTCapabilityWriter::RemoveAtomicInstance(IMTAtomicCapability* apCap, IMTPrincipalPolicy* aPolicy)
{
	HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	long numAtomics = 0;
	try
	{
		MTAUTHEXECLib::IMTAtomicCapabilityPtr atomicCapPtr = apCap;
    MTAUTHEXECLib::IMTPrincipalPolicyPtr polPtr = aPolicy;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("__DELETE_CAPABILITY_INSTANCE__");
		rowset->AddParam("%%ID%%", atomicCapPtr->ID);
    rowset->Execute();
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}
