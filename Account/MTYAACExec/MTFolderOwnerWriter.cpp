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
#include "MTYAACExec.h"
#include "MTFolderOwnerWriter.h"
#include "metralite.h"
#include "PCCache.h"

/////////////////////////////////////////////////////////////////////////////

class MTBatchFolderHelper : public MTAccountBatchHelper<MTYAACEXECLib::IMTFolderOwnerWriterPtr>
{
public:
  HRESULT PerformSingleOp(long aIndex,long &aFailedAccount);
  long mOwner;
};

HRESULT MTBatchFolderHelper::PerformSingleOp(long aIndex,long &aFailedAccount)
{
  // get the descendent
  long folderID = mColPtr->GetItem(aIndex);
  long existingOwner;
  HRESULT hr =  mControllerClass->raw_AddOwnedFolder(folderID,mOwner,&existingOwner);
  aFailedAccount = folderID;
  hr = (hr == S_FALSE) ? MT_EXISTING_FOLDER_OWNER : hr;
  if(FAILED(hr))
    MT_THROW_COM_ERROR(hr);
  return hr;
}

/////////////////////////////////////////////////////////////////////////////
// CMTFolderOwnerWriter
STDMETHODIMP CMTFolderOwnerWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTFolderOwnerWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTFolderOwnerWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTFolderOwnerWriter::CanBePooled()
{
	return TRUE;
} 

void CMTFolderOwnerWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTFolderOwnerWriter::AddOwnedFolder(long aFolder, long aOwner,long* pCurrentOwner)
{
	ASSERT(pCurrentOwner);
	if(!pCurrentOwner) return E_POINTER;

	MTAutoContext ctx(m_spObjectContext);
	long status = 0;
	HRESULT hr = S_OK;

	*pCurrentOwner = 0;

	try {
		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init(DATABASE_CONFIGDIR);

		rs->InitializeForStoredProc("AddOwnedFolder");
		rs->AddInputParameterToStoredProc("owner", MTTYPE_INTEGER, INPUT_PARAM, aOwner);
		rs->AddInputParameterToStoredProc("folder", MTTYPE_INTEGER, INPUT_PARAM, aFolder);
		rs->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());
		rs->AddInputParameterToStoredProc ("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());
		rs->AddOutputParameterToStoredProc("existing_owner", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->AddOutputParameterToStoredProc("status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->ExecuteStoredProc();
		status = rs->GetParameterFromStoredProc("status");

		// the folder may already have an owner; get the value from the output parameter
		if(status == MT_EXISTING_FOLDER_OWNER) {
			*pCurrentOwner = rs->GetParameterFromStoredProc("existing_owner");
			hr = S_FALSE;
		}
		else {
			if(status != 1) {
				MT_THROW_COM_ERROR(status);
			}	
		}
		
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	
	ctx.Complete();
	return hr;
}

STDMETHODIMP CMTFolderOwnerWriter::AddOwnedFoldersBatch(long aOwner,
                                                        IMTCollection *pCol, 
                                                        IMTProgress *pProgress, 
                                                        IMTRowSet **ppErrors)
{
	try {
    MTBatchFolderHelper aBatchHelper;
    aBatchHelper.Init(m_spObjectContext,MTYAACEXECLib::IMTFolderOwnerWriterPtr(this));
    aBatchHelper.mOwner = aOwner;
    *ppErrors = reinterpret_cast<IMTRowSet*>(aBatchHelper.PerformBatchOperation(pCol,pProgress).Detach());
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTFolderOwnerWriter::UpdateFolderOwner(long aFolder, long aNewOwner)
{
	try {
    MTYAACEXECLib::IMTFolderOwnerWriterPtr writer = this;
    ROWSETLib::IMTSQLRowsetPtr rs(__uuidof(ROWSETLib::MTSQLRowset));
    rs->Init(ACC_HIERARCHIES_QUERIES);
    rs->SetQueryTag("__REMOVE_FOLDER_OWNER__");
    rs->AddParam("%%ID_FOLDER%%",aFolder);
    rs->Execute();
    writer->AddOwnedFolder(aFolder,aNewOwner);
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}
