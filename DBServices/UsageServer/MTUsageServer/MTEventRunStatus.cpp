// MTEventRunStatus.cpp : Implementation of CMTEventRunStatus
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "MTEventRunStatus.h"

#include <comdef.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mttime.h>

#include <MTUtil.h>

#include <UsageServerConstants.h>

#include <RowsetDefs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTEventRunStatus

STDMETHODIMP CMTEventRunStatus::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEventRunStatus
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTEventRunStatus::Start(long aIntervalId, BSTR aName, BSTR aProgId, BSTR aConfigFile, long *apRunId)
{

	_variant_t vtParam;

  try
  {
    // create the rowset ....
	ROWSETLib::IMTSQLRowsetPtr rowset (MTPROGID_SQLROWSET);

    // intialize the rowset ...
    rowset->Init(USAGE_SERVER_QUERY_DIR);

    // initialize the stored procedure ...
    rowset->InitializeForStoredProc ("InsertRecurringEventRun");
  
    // add the parameters ...
    vtParam = aIntervalId;
    rowset->AddInputParameterToStoredProc("id_interval", MTTYPE_INTEGER, INPUT_PARAM, vtParam);
    vtParam = aName;
    rowset->AddInputParameterToStoredProc("tx_adapter_name", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
    vtParam = aProgId;
    rowset->AddInputParameterToStoredProc("tx_adapter_method", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
    vtParam = aConfigFile;
    rowset->AddInputParameterToStoredProc("tx_config_file", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);
		vtParam = GetMTOLETime();
		rowset->AddInputParameterToStoredProc("system_date", MTTYPE_DATE, INPUT_PARAM, vtParam);
    rowset->AddOutputParameterToStoredProc("id_run", MTTYPE_INTEGER, OUTPUT_PARAM);
  
    rowset->ExecuteStoredProc();
  
    // get the recurring event run id ...
    _variant_t vtValue = rowset->GetParameterFromStoredProc ("id_run");
    *apRunId = vtValue.lVal;

  }
  catch (_com_error e)
  {
    return e.Error();
  }

	return S_OK;
}


STDMETHODIMP CMTEventRunStatus::End(long aRunId, long aStatus, BSTR aStatusMessage)
{

  _variant_t vtParam;
  
  try
  {
    // create the rowset ....
	  ROWSETLib::IMTSQLRowsetPtr rowset (MTPROGID_SQLROWSET);

    // intialize the rowset ...
    rowset->Init(USAGE_SERVER_QUERY_DIR);

    // update the entry in the recurring event run log ...
	  rowset->SetQueryTag ("__UPDATE_RECURRING_EVENT_LOG__");
	  
	  vtParam = aRunId;
	  rowset->AddParam ("%%RUN_ID%%", vtParam);
	  
	  rowset->Execute();
  }
  catch (_com_error e)
  {
    return e.Error();
  }

	return S_OK;
}
