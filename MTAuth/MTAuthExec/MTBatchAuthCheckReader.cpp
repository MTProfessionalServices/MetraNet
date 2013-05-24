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
#include "MTAuthExec.h"
#include "MTBatchAuthCheckReader.h"
#include "corecapabilities.h"



/////////////////////////////////////////////////////////////////////////////
// CMTBatchAuthCheckReader

STDMETHODIMP CMTBatchAuthCheckReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTBatchAuthCheckReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTBatchAuthCheckReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTBatchAuthCheckReader::CanBePooled()
{
	return TRUE;
} 

void CMTBatchAuthCheckReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTBatchAuthCheckReader::BatchUmbrellaCheck(IMTSessionContext *apCtx,
																												 IMTCollectionEx *pCol,
																												 DATE RefDate,
																												 IMTRowSet **ppRowset)
{
	MTAutoContext context(m_spObjectContext);
	HRESULT hr;
	try {
		MTAUTHLib::IMTSecurityContextPtr secCtx = MTAUTHLib::IMTSessionContextPtr(apCtx)->GetSecurityContext();
		MTAUTHLib::IMTCollectionExPtr colPtr(pCol);
		ROWSETLib::IMTSQLRowsetPtr errorRS(__uuidof(ROWSETLib::MTSQLRowset));
		ROWSETLib::IMTRowSetPtr outputRS = errorRS; // QI

		// build the output rowset
		errorRS->InitDisconnected();
		errorRS->AddColumnDefinition("id_acc","int32",4);
		errorRS->AddColumnDefinition("error_code","int32",4);
		errorRS->OpenDisconnected();

    // toString returns a comma seperate list of the values in the collection
    _bstr_t inclause = colPtr->ToString();

		// build query that resolves the path
		ROWSETLib::IMTSQLRowsetPtr rs(__uuidof(ROWSETLib::MTSQLRowset));
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__RESOLVE_PATHS_BATCH__");
		rs->AddParam("%%DESC_LIST%%",inclause);

		wstring buf;
    _variant_t CheckDate(RefDate,VT_DATE);
		FormatValueForDB(CheckDate,FALSE,buf);
		rs->AddParam("%%REFDATE%%",buf.c_str(),VARIANT_TRUE);
		rs->ExecuteDisconnected();

		MTAUTHLib::IMTSecurityPtr secPtr(__uuidof(MTAUTHLib::MTSecurity));
		
		MTAUTHLib::IMTCompositeCapabilityTypePtr typePtr = secPtr->GetCapabilityTypeByName(MANAGE_HIERARCHY_CAP);
		MTAUTHLib::IMTCompositeCapabilityPtr capPtr = typePtr->CreateInstance();
		MTAUTHLib::IMTPathCapabilityPtr pathPtr = capPtr->GetAtomicPathCapability();

		for(int i=0;i<rs->GetRecordCount();i++) {
      _variant_t vtpath = rs->GetValue(0l);
      if(vtpath.vt != VT_BSTR) {
        // oops.... doesn't look like the account exists
        long accountID = rs->GetValue(1l);
        _bstr_t checkDateStr(CheckDate);
        const char* pDateStr = checkDateStr;

        MT_THROW_COM_ERROR(MT_YAAC_ACCOUNT_NOT_FOUND,accountID,pDateStr);
      }

			pathPtr->SetParameter(_bstr_t(vtpath),MTAUTHLib::SINGLE);

			hr = secCtx->raw_CheckAccess(
				capPtr);
			if(FAILED(hr)) {
				errorRS->AddRow();
				errorRS->AddColumnData("id_acc",rs->GetValue(1l));
				errorRS->AddColumnData("error_code",hr);
			}
			rs->MoveNext();
		}

		*ppRowset = reinterpret_cast<IMTRowSet*>(outputRS.Detach());
		context.Complete();
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}
	return S_OK;
}
