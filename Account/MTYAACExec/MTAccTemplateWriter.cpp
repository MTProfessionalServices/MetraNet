// MTAccTemplateWriter.cpp : Implementation of CMTAccTemplateWriter
#include "StdAfx.h"
#include "MTYAACExec.h"
#include "MTAccTemplateWriter.h"
#include "PCCache.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccTemplateWriter

STDMETHODIMP CMTAccTemplateWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccTemplateWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAccTemplateWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAccTemplateWriter::CanBePooled()
{
	return TRUE;
} 

void CMTAccTemplateWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTAccTemplateWriter::DeleteTemplate(long aTemplateID)
{
	MTAutoContext ctx(m_spObjectContext);
	try{
		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		rs->Init(ACC_HIERARCHIES_QUERIES);
		rs->InitializeForStoredProc("DeleteTemplate");
		rs->AddInputParameterToStoredProc("p_id_template", MTTYPE_INTEGER, INPUT_PARAM, aTemplateID);
		rs->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->ExecuteStoredProc();

		long status = rs->GetParameterFromStoredProc("p_status");
		if(status != 1) {
			MT_THROW_COM_ERROR(status);
		}
    
	}
	catch(_com_error& err)  {
		return ReturnComError(err);
	}
	
	ctx.Complete();
	return S_OK;
}

STDMETHODIMP CMTAccTemplateWriter::SaveTemplateProperties(long aTemplateID,IMTCollectionReadOnly *pCol)
{
	MTAutoContext ctx(m_spObjectContext);
	try {

		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		MTYAACEXECLib::IMTCollectionReadOnlyPtr col(pCol);

		rs->Init(ACC_HIERARCHIES_QUERIES);
		// clean up existing properties
		rs->SetQueryTag("__DELETE_ACCTEMPLATE_PROPS__");
		rs->AddParam("%%TEMPLATEID%%",aTemplateID);
		rs->Execute();

    for(int index = 1;index <= col->GetCount();index++) {
			MTYAACLib::IMTAccountTemplatePropertyPtr prop = col->GetItem(index);

			rs->Clear();
			rs->SetQueryTag("__ADD_ACCTEMPLATE_PROP__");
			rs->AddParam("%%IDTEMPLATE%%",aTemplateID);
			rs->AddParam("%%CLASS%%",prop->GetType());
			rs->AddParam("%%NAME%%",prop->GetName());
			rs->AddParam("%%VALUE%%",prop->GetInternalValue());
			rs->Execute();
    }

    rs->Clear();

    rs->InitializeForStoredProc("UpdatePrivateTempates");
		rs->AddInputParameterToStoredProc("id_template", MTTYPE_INTEGER, INPUT_PARAM, aTemplateID);
		rs->ExecuteStoredProc();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	ctx.Complete();
	return S_OK;
}

STDMETHODIMP CMTAccTemplateWriter::SaveSubscriptions(long aTemplateID, IMTAccountTemplateSubscriptions *pSubs)
{
	MTAutoContext ctx(m_spObjectContext);
	try {
		ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
		MTYAACLib::IMTCollectionReadOnlyPtr subCol(pSubs);

 		rs->Init(ACC_HIERARCHIES_QUERIES);
		rs->SetQueryTag("__REMOVE_EXISTING_TEMPLATE_SUBS__");
		rs->AddParam("%%TEMPLATEID%%",aTemplateID);
		rs->Execute();

		rs->Clear();
		for(int index = 1;index <= subCol->GetCount();index++) {
			MTYAACLib::IMTAccountTemplateSubscriptionPtr sub = subCol->GetItem(index);
			VARIANT_BOOL vbVal = sub->Save(aTemplateID);
			if(vbVal == VARIANT_FALSE) {
				MT_THROW_COM_ERROR("failed to save account template subscriptions");
			}
		}
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	ctx.Complete();
	return S_OK;
}

STDMETHODIMP CMTAccTemplateWriter::CopyTemplate(long aNewFolder, long aAccountTypeID, VARIANT aParentFolder)
{
	MTAutoContext ctx(m_spObjectContext);
	try {

		string sSameCorpEnforced = 
			(PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE) ? "1" : "0";

	  ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    rs->Init(ACC_HIERARCHIES_QUERIES);
    rs->InitializeForStoredProc("CopyTemplate");
		rs->AddInputParameterToStoredProc("p_id_folder", MTTYPE_INTEGER, INPUT_PARAM, aNewFolder);
    rs->AddInputParameterToStoredProc("p_id_accounttype", MTTYPE_INTEGER, INPUT_PARAM, aAccountTypeID);

    _variant_t vtParentFolder;
	  if(!OptionalVariantConversion(aParentFolder,VT_I4,vtParentFolder)) {
      vtParentFolder.vt = VT_NULL;
		}
    rs->AddInputParameterToStoredProc("p_parent_folder", MTTYPE_INTEGER, INPUT_PARAM, vtParentFolder);
		rs->AddInputParameterToStoredProc("p_systemdate", MTTYPE_DATE, INPUT_PARAM,GetMTOLETime());
		rs->AddInputParameterToStoredProc ("p_enforce_same_corporation", MTTYPE_VARCHAR, INPUT_PARAM, sSameCorpEnforced.c_str());
		rs->AddOutputParameterToStoredProc("p_status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rs->ExecuteStoredProc();
		long status = rs->GetParameterFromStoredProc("p_status");
    if(status != 1) {
      if(status == MT_PARENT_TEMPLATE_DOES_NOT_EXIST) {
        MT_THROW_COM_ERROR(status,aNewFolder);
      }
      MT_THROW_COM_ERROR(status);
    }

  }
  catch(_com_error& err) {
  	return ReturnComError(err);
	}

	ctx.Complete();
	return S_OK;
}
