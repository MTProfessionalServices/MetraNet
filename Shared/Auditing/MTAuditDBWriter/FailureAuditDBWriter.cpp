// FailureAuditDBWriter.cpp : Implementation of CFailureAuditDBWriter
#include "StdAfx.h"
#include "MTAuditDBWriter.h"
#include "FailureAuditDBWriter.h"

#include <comdef.h>
#include <mtprogids.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mttime.h>
#include <RowsetDefs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")
#import <AuditEventsLib.tlb>
#include <mtautocontext.h>
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")

#include <AuditIdGenerator.h>

STDMETHODIMP CFailureAuditDBWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IFailureAuditDBWriter,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/****************************************** IObjectControl ***/
CFailureAuditDBWriter::CFailureAuditDBWriter()
{
	mpObjectContext = NULL;
}


HRESULT CFailureAuditDBWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CFailureAuditDBWriter::CanBePooled()
{
	return FALSE;
} 

void CFailureAuditDBWriter::Deactivate()
{
 	mpObjectContext.Release();
} 

/////////////////////////////////////////////////////////////////////////////
// CFailureAuditDBWriter

STDMETHODIMP CFailureAuditDBWriter::Write(IAuditEvent * apAuditEvent)
{
	MTAutoContext context(mpObjectContext);
	if (!apAuditEvent)
		return E_POINTER;

	try
	{
		_variant_t vtParam;
		AuditEventsLib::IAuditEventPtr AuditEvent = apAuditEvent; //use comptr for convenience

		ROWSETLib::IMTSQLRowsetPtr rs;
		HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(_T("queries\\audit")); // TO DO: Move this to the Init... call only once.
		rs->InitializeForStoredProc("InsertAuditEvent");

		vtParam = AuditEvent->UserId;
		rs->AddInputParameterToStoredProc("id_userid", MTTYPE_INTEGER, INPUT_PARAM, vtParam);

		vtParam = AuditEvent->EventId;
		rs->AddInputParameterToStoredProc("id_event", MTTYPE_INTEGER, INPUT_PARAM, vtParam);

		vtParam = AuditEvent->EntityTypeId;
		rs->AddInputParameterToStoredProc("id_entity_type", MTTYPE_INTEGER, INPUT_PARAM, vtParam);

		vtParam = AuditEvent->EntityId;
		rs->AddInputParameterToStoredProc("id_entity", MTTYPE_INTEGER, INPUT_PARAM, vtParam);

		rs->AddInputParameterToStoredProc("dt_timestamp", MTTYPE_DATE, INPUT_PARAM, GetMTOLETime());

		// Generate audit id.
		MetraTech_DataAccess::IIdGenerator2Ptr idGen = AuditIdGenerator::Get();
		AuditEvent->AuditId = idGen->NextId;
		rs->AddInputParameterToStoredProc("id_audit", MTTYPE_VARCHAR, INPUT_PARAM, AuditEvent->AuditId);

		_variant_t vtNULL;
		vtNULL.vt =  VT_NULL;

		_bstr_t details = AuditEvent->Details;
		vtParam = (details.length() > 0) ? details : vtNULL;
		rs->AddInputParameterToStoredProc ("tx_details", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);

		_bstr_t loggedAs = AuditEvent->LoggedInAs;;
		vtParam = (loggedAs.length() > 0) ? loggedAs : vtNULL;	
		rs->AddInputParameterToStoredProc("tx_logged_in_as", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);		
		
		_bstr_t applicationName = AuditEvent->ApplicationName;
		vtParam = (applicationName.length() > 0) ? applicationName : vtNULL;		
		rs->AddInputParameterToStoredProc("tx_application_name", MTTYPE_VARCHAR, INPUT_PARAM, vtParam);

		rs->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
