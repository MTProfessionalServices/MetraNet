/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <comutil.h>
#include <mtcomerr.h>
#include <HookSkeleton.h>
#include <mtprogids.h>
#include <NTLogger.h>
#include <ConfigDir.h>
#include <stdutils.h>
#include <SetIterate.h>

// Figure out if we need these guys
#include <DBAccess.h>
#include <DBConstants.h>

#define AuditHook_STR "AuditHook"
#define AuditHook_TAG "[AuditHook]"
#define DB_CONFIG_PATH	"\\Queries\\Audit"

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
#import <MTConfigLib.tlb>
#import <MTNameIDLib.tlb>

// Note that RcdHelper MUST come after the RCD tlb import!!!
#import <RCD.tlb>
#include <RcdHelper.h>

const char* gModuleName = "AuditHook";

// generate using uuidgen
CLSID CLSID_AuditHook = { // 53f24152-725b-4104-9261-75de2f6aec97
    0x53f24152,
    0x725b,
    0x4104,
    {0x92,0x61,0x75,0xde,0x2f,0x6a,0xec,0x97}
  };

class ATL_NO_VTABLE AuditHook :
  public MTHookSkeleton<AuditHook,&CLSID_AuditHook> ,public DBAccess
{
public:
	virtual HRESULT ExecuteHook(VARIANT var, long* pVal);

private:
	// simple counters
	int nUpdateTotal; 
	int nInsertTotal;
	// Function that gets a propset and does the logic to insert or update records in the table
	virtual HRESULT AuditHook::PutPropsetInDB(MTConfigLib::IMTConfigPropSetPtr mPropset,
																						QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter, 
																						NTLogger* logger);
};

HOOK_INFO(CLSID_AuditHook, 
		  AuditHook,
		  "MetraHook.AuditHook.1", 
		  "MetraHook.AuditHook", 
		  "free")


/////////////////////////////////////////////////////////////////////////////
// Function name	: AuditHook::PutPropsetInDB
// Description	  : Helper function - takes a Propset, inserts tuples in the DB
// Return type		: HRESULT 
// Argument       : 
/////////////////////////////////////////////////////////////////////////////
HRESULT AuditHook::PutPropsetInDB(MTConfigLib::IMTConfigPropSetPtr mPropset,
																	QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter, // We assume the query adapter is already configured with the insert query
																	NTLogger* logger)
{
	HRESULT hr = S_OK;
	const char* procName = "AuditHook::PutPropsetInDB";
	
	// Pointer that is used to iterate through each <auditevent> propset 
	MTConfigLib::IMTConfigPropSetPtr mEventSet;
	
	// Props that hold <id> and <name> from propset above
	MTConfigLib::IMTConfigPropPtr mPropEventID;
	MTConfigLib::IMTConfigPropPtr mPropFQN;

	// _bstr_t's to hold the properties values
	_bstr_t aEventID;
	_bstr_t aFqn;
	_bstr_t resQueryString;
	long aDescID;

	//Rowset & Query string
	DBSQLRowset rowset;
	wstring wstrQueryCmd;

	// string to hold error message. we are doing a lot of stuff inside the try-catch statement below,
	// so we want give out a usefull message if something goes wrong.
	_bstr_t errmsg = _bstr_t("no specific error");

	// Algorithm to insert propset:

	// For each <auditevent> subset in the propset do:
	//		Get <id> and <name> values
	//		Use <name> (FQN) to get localized id_desc for that audit event
	//		If <id> value is already on t_audit_events:
	//				update description id with id_desc
	//		Else - <id> value is not in table
	//				insert <id> and id_desc into table as a new record
	//		End If
	//	End Loop

	// Start the loop that retrieves id/name tuples and inserts them into the database
	while (TRUE)
	{
		try
		{
			// Trying to get the next auditevent propset
			errmsg = _bstr_t("trying to get next <auditevent> propset");
			
			mEventSet = mPropset->NextSetWithName(L"auditevent");
			
			// Check if there are any tuples left in the propset
			if (mEventSet == NULL)
				break;

			// get the <id> and <name> values
			errmsg = _bstr_t("trying to get name-id pair from propset");
			mPropEventID = mEventSet->NextWithName(L"id");
			mPropFQN = mEventSet->NextWithName(L"name");
			
			// Put the values into _bstr_t's
			aEventID = mPropEventID->GetPropValue();
			aFqn = mPropFQN->GetPropValue();

			// Retrieve description id using FQN from xml file
			errmsg = _bstr_t("trying to get localized id from t_description");
			mQueryAdapter->ClearQuery();
			mQueryAdapter->SetQueryTag("__AUDIT_SELECT_FROM_ENUM_DATA__");
			mQueryAdapter->AddParam(_bstr_t("%%AUDIT_EVENT_FQN%%"), _variant_t(aFqn));
			resQueryString = mQueryAdapter->GetQuery();
			wstrQueryCmd = (wchar_t*) resQueryString;
			try 
			{ 
				hr = DBAccess::Execute(wstrQueryCmd, rowset);
			}
			catch (_com_error err)	// For some reason insertion on the database failed. Log problem and return error.
			{
				wchar_t buffer[256];
				swprintf(buffer, L"Could not execute select statement on table t_enum_data.");
				logger->LogThis(LOG_ERROR, buffer);
				return Error(buffer);
			}
				
			if (rowset.GetRecordCount() == 0)
			{
				logger->LogVarArgs(LOG_WARNING, "Could not retrieve localized id for FQN = %s, this audit event will have no localized description.", (const char*) aFqn);
				aDescID = 0;
			}
			else
			{
				rowset.GetLongValue(_variant_t("id_enum_data"), aDescID);					
			}

			// Query to see if event is in database already
			mQueryAdapter->ClearQuery();
			mQueryAdapter->SetQueryTag("__SELECT_AUDIT_EVENT_TYPE__");
			mQueryAdapter->AddParam(_bstr_t("%%AUDIT_EVENT_ID%%"), _variant_t(aEventID));
			resQueryString = mQueryAdapter->GetQuery();
			wstrQueryCmd = (wchar_t*) resQueryString;
			
			try // Put the actuall code that inserts the row in a try-catch statement
					// I hate to nest try-catch statements, but it seems like the best thing to do here
			{ 
				hr = DBAccess::Execute(wstrQueryCmd, rowset);
			}
			catch (_com_error err)
					// For some reason insertion on the database failed. Log problem and return error.
			{
				wchar_t buffer[256];
				swprintf(buffer, L"Could not execute select statement on table t_audit_events.");
				logger->LogThis(LOG_ERROR, buffer);
				return Error(buffer);
			}

			// Start to prepare the proper query (insert or update)
			mQueryAdapter->ClearQuery();

			// Now let's see if we should update or insert the eventid - descid pair
			if (rowset.GetRecordCount() >	0) 				// Ok, let's just update the description id, since the event number is already present on the database
			{
				errmsg = _bstr_t("trying to setup up update query tag and parameters");
				mQueryAdapter->SetQueryTag("__UPDATE_AUDIT_EVENT_TYPE__");
				nUpdateTotal++;
			}
			else // Record is not present on database, let's insert it
			{
				errmsg = _bstr_t("trying to setup up insert query tag and parameters");
				mQueryAdapter->SetQueryTag("__INSERT_AUDIT_EVENT_TYPE__");
				nInsertTotal++;
			}
			
			// This part is the same, regardless of if we are inserting or updating that record
			mQueryAdapter->AddParam(_bstr_t("%%AUDIT_EVENT_ID%%"), _variant_t(aEventID));
			mQueryAdapter->AddParam(_bstr_t("%%AUDIT_DESC_ID%%"), _variant_t(aDescID));
			resQueryString = mQueryAdapter->GetQuery();
			wstrQueryCmd = (wchar_t*) resQueryString;
			
			try // Put the actuall code that inserts the row in a try-catch statement
					// I hate to nest try-catch statements, but it seems like the best thing to do here
			{ 
				hr = DBAccess::Execute(wstrQueryCmd, rowset);
			}
			catch (_com_error err) // For some reason insertion/update on the database failed. Log problem and return error.
			{
				wchar_t buffer[256];
				swprintf(buffer, L"Could not insert or update values (audit event id = %s, localized description id = %d) into t_audit_events", aEventID, aDescID);
				logger->LogThis(LOG_ERROR, buffer);
				return Error(buffer);
			}
		}
		catch (_com_error err)
		{
			_bstr_t logmsg = "Error while processing audit events file: " + errmsg;
			logger->LogThis(LOG_ERROR, (const char*) logmsg);
			return Error((const char*) logmsg);		
		}
	}
	return hr;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: AuditHook::ExecuteHook
// Description	  : 
// Return type		: HRESULT 
// Argument       : 
/////////////////////////////////////////////////////////////////////////////

HRESULT AuditHook::ExecuteHook(VARIANT var, long* pVal)
{
	HRESULT hr = S_OK;
	const char* procName = "AuditHook::ExecuteHook";

	// Initialize counter vars
	nUpdateTotal = 0;
	nInsertTotal = 0;

	// Variables to manipulate the Propset after we get the XML into it
	MTConfigLib::IMTConfigPtr mConfig(MTPROGID_CONFIG);
	MTConfigLib::IMTConfigPropSetPtr mPropset;

	// QueryAdapter
	QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter(MTPROGID_QUERYADAPTER);
	//mQueryAdapter = queryAdapter.Detach();
	
	VARIANT_BOOL checksumMatch;	

	NTLogger logger;
	LoggerConfigReader cfgRdr;
	logger.Init(cfgRdr.ReadConfiguration(AuditHook_STR), AuditHook_TAG);
  
	// read the xml Audit message file list
	// read the collection of messages
	// drop and create the table
	// for each message
	//		look up description id based on full qualified name
	//		insert message
	// done

	// use the RCD to find a list of audit events xml files in all extensions
	RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
	aRCD->Init();

	// First, see if the core file is present on the system. If not, just exit with Error
	RCDLib::IMTRcdFileListPtr aFileList;
	_bstr_t strCoreExt = aRCD->GetInstallDir() + _bstr_t("\\extensions\\core"); 
	aFileList = aRCD->RunQueryInAlternateFolder("config\\auditevents\\auditevents.xml", VARIANT_TRUE, (const char*) strCoreExt);
	if (aFileList->GetCount() == 0) 
	{
		const char* szLogMsg = "Can't find core audit event file in core extension. \\extensions\\core\\config\\auditevents\\auditevents.xml must exist.";
		logger.LogThis(LOG_ERROR, szLogMsg);
		hr = Error (szLogMsg);
		return hr;
	}

	// Now use correct query to grab all audit files from all extensions
	aFileList = aRCD->RunQuery("config\\auditevents\\*.xml", VARIANT_TRUE);

	logger.LogVarArgs(LOG_DEBUG, "Number of audit event files: %d", aFileList->GetCount());

	// Create iterator to access files
	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> rcd_it;
	// Initialize it with the file list to be read
	if (FAILED(rcd_it.Init(aFileList))) return FALSE;
	
	// initialize the database context
	if (!DBAccess::Init((wchar_t*)_bstr_t(DB_CONFIG_PATH)))
	{
		SetError(DBAccess::GetLastError());
		logger.LogThis(LOG_ERROR, "Database initialization failed for User Config");
		return (E_FAIL);
	}
	
	// Configure query here.
	mQueryAdapter->Init(DB_CONFIG_PATH);

	// We have at least one file, so let's iterate and grab the key-value pairs
	while (TRUE)
	{
		_variant_t aVariant = rcd_it.GetNext();
		_bstr_t afile = _bstr_t(aVariant);

		// If there are no more files, we exit the loop
		if (afile.length() == 0) break;
		
		logger.LogVarArgs(LOG_DEBUG, "Processing file: %s", (const char*) afile);
		
		// Grab whatever is in the file, put it in the propset		
		try
		{
			mPropset = mConfig->ReadConfiguration(afile, &checksumMatch);
			
			// We have the propset with id/name tuples. Call the method that will iterate through it and insert entries on the database.
			hr = AuditHook::PutPropsetInDB(mPropset, mQueryAdapter, &logger);

			if FAILED(hr)
				return hr;
			logger.LogThis(LOG_DEBUG, "Finished processing file.");
		}
		catch (_com_error err)
		{
			logger.LogThis(LOG_ERROR, "Could not load configuration from file!");
			return (E_FAIL);
		}
	}

	// Close the database connection
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		logger.LogThis(LOG_ERROR, "Database disconnect failed");
		return (E_FAIL);
	}
	
	logger.LogVarArgs(LOG_DEBUG, "Inserted %d new audit events, verified %d current audit events localized descriptions", nInsertTotal, nUpdateTotal);

	return hr;
}
