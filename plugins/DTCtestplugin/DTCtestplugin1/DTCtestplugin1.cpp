/**************************************************************************
 * @doc DTCtestplugin1
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
 * Created by: Jiang Chen, Alan Blount
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <PlugInSkeleton.h>
#include <base64.h>

#include <mtprogids.h>
#include <ConfigDir.h>

#include <MTUtil.h>
#include "reservedproperties.h"
#include <string>

// import the row set tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

using namespace ROWSETLib ;

CLSID CLSID_DTCtestPlugIn1 = 
       { 0xcfee3c80, 
				 0x622a, 
				 0x11d4, 
				 { 0x9a, 0x15, 0x0, 0xc0, 0x4f, 0x6d, 0xc4, 0x82 } 
};


class ATL_NO_VTABLE MTDTCtestPlugIn1
	: public MTPipelinePlugIn<MTDTCtestPlugIn1, &CLSID_DTCtestPlugIn1>
{
public:
  MTDTCtestPlugIn1(){};

protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

	virtual HRESULT InsertRow(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn, long aTestID, _bstr_t aComment);
	virtual HRESULT UpdateRows(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn, long aTestID, _bstr_t aComment);
	virtual HRESULT SelectRows(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn);

	virtual HRESULT ExportTransaction(MTPipelineLib::IMTSessionPtr aSession);

	string mPluginID;
	long mDescriptionID;
	long mStageNum;
	long mRemeterProcessSessionID;
	string mRemoteWhereabouts;

private:

	MTPipelineLib::IMTLogPtr mLogger;
	_bstr_t mConfigPath;
	
};


PLUGIN_INFO(CLSID_DTCtestPlugIn1, MTDTCtestPlugIn1,
						"MetraPipeline.DTCtestPlugIn1.1", "MetraPipeline.DTCtestPlugIn1", "Free")


HRESULT MTDTCtestPlugIn1::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																					MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																					MTPipelineLib::IMTNameIDPtr aNameID,
																					MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	const char *procName = "DTCtestplugin1::PlugInConfigure";
	
	mLogger = aLogger;

  std::string extDir;
	GetExtensionsDir(extDir);
	extDir += "\\";
	extDir += aSysContext->GetExtensionName();
	extDir += "\\config\\queries";

	mConfigPath = extDir.c_str();


	MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);
	mPluginID = aPropSet->NextStringWithName("pluginID");

	DECLARE_PROPNAME_MAP(inputs)
	  DECLARE_PROPNAME("description", &mDescriptionID)
	  DECLARE_PROPNAME("RemeterProcessSession", &mRemeterProcessSessionID)
 	END_PROPNAME_MAP

	HRESULT hr = ProcessProperties(inputs, aPropSet, aNameID, aLogger, procName);

	mRemoteWhereabouts = aPropSet->NextStringWithName("RemoteWhereabouts");

	return hr;
}


//
// This code inserts into t_dtctest:
//    create table t_dtctest (c_testid int, c_comment varchar(50))
//
// To test the various cases, meter one of the following strings as
// "Description" (see readme_dtctest.txt int the DTCTest extension for full info)
//
//    "success" -- insert a row and return success
//    "fail" -- insert a row and return fail
//    "failinner" -- insert a row and return fail if this is plugin 1
//    "failouter" -- insert a row and return fail if this is plugin 2-2
//    "notran" -- insert a row outside transaction and return success
//
HRESULT MTDTCtestPlugIn1::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr;

	_bstr_t desc = aSession->GetStringProperty(mDescriptionID);

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("DTCtestplugin1 PlugInProcessSession starting"));

	char buf[1024];
	sprintf(buf,"Plugin: %s, TestCase: '%s'", mPluginID.c_str() , (const char*)desc);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);


	//plugin 2-1 always prepares remeter and inserts a row
	if (mPluginID == "2-1")
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("Preparing remeter, inserting row within txn, and succeed"));
		  
		// Remeter needs this flag set to 1 to really remeter
		aSession->SetLongProperty(mRemeterProcessSessionID, 1);
			
		hr = InsertRow(aSession, true, (long) time(NULL), "plugin 2-1 success");
		return hr;
	}

	//plugin 2-2 fails for "failouter", otherwise tries to succeed
	if (mPluginID == "2-2")
	{
		if (desc == _bstr_t("failouter"))
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("inserting row within txn, and fail"));
			InsertRow(aSession, true, (long) time(NULL), "plugin 2-2 fail");
			return E_FAIL;
		}
		else
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("inserting row within txn, and succeed"));
			hr = InsertRow(aSession, true, (long) time(NULL), "plugin 2-2 success");
			return hr;
		}
	}

	// all other plugins:
  // succeed on "success" or "failouter"
	// fail on "fail" or "failinner"
	// succeed witout transaction on "notran"

	if (desc == _bstr_t("success") ||
		  desc == _bstr_t("failouter"))
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("inserting row within txn, and succeed"));
		string comment = "plugin " + mPluginID + " success";
		hr = InsertRow(aSession, true, (long) time(NULL), comment.c_str());
		return S_OK;
	}
	
	if (desc == _bstr_t("fail") ||
		  desc == _bstr_t("failinner"))
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("inserting row within txn, and fail"));
		string comment = "plugin " + mPluginID + " fail";
		hr = InsertRow(aSession, true, (long) time(NULL), comment.c_str());
		return E_FAIL;
	}

	if (desc == _bstr_t("notran"))
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t("inserting row without txn, and succeed'"));
		string comment = "plugin " + mPluginID + " notran";
		return InsertRow(aSession, false, (long) time(NULL), comment.c_str());
	}

	_bstr_t msg = "invalid description: " + desc;
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, msg);
	return E_FAIL;
}


//NOTE: function is not currently used, since remeter plugin now supports transaction
HRESULT MTDTCtestPlugIn1::ExportTransaction(MTPipelineLib::IMTSessionPtr aSession)
{

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "In MTDTCtestPlugIn1::ExportTransaction()");

	MTPipelineLib::IMTTransactionPtr xaction = aSession->GetTransaction(VARIANT_TRUE);

  // Remeter needs this flag set to 1 to really remeter
  aSession->SetLongProperty(mRemeterProcessSessionID, 1);


	// Get Whereabouts of server to export transaction to.
	// If mRemoteWhereabouts specified use that servers whereabouts,
	// otherwise use local where abouts
	_bstr_t whereabouts;
	MTPipelineLib::IMTWhereaboutsManagerPtr whereaboutsMgr(MTPROGID_WHEREABOUTS_MANAGER);
	if(mRemoteWhereabouts.size())
	{
		_bstr_t msg = "Getting Whereabouts for server: " + _bstr_t(mRemoteWhereabouts.c_str());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);
		
		whereabouts = whereaboutsMgr->GetWhereaboutsForServer(mRemoteWhereabouts.c_str());
	}
	else
	{	
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Getting local whereabouts");
		whereabouts= whereaboutsMgr->GetLocalWhereabouts();
	}
	
	_bstr_t msg = "Whereabouts= " + whereabouts;
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);


	//export the txn based on the whereabouts
	_bstr_t cookie = xaction->Export(whereabouts);

	msg = "Exported transaction. Cookie: " + cookie;
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, msg);

	MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);
	long transactionCookieID = nameid->GetNameID(MT_TRANSACTIONCOOKIE_PROP_A);
	aSession->SetStringProperty(transactionCookieID, cookie);

	return S_OK;
}


// insert a row into t_dtctest, with or without txn
HRESULT MTDTCtestPlugIn1::InsertRow(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn, long aTestID, _bstr_t aComment)
{
	HRESULT hr;

	ROWSETLib::IMTSQLRowsetPtr pRowset;
	
	if(withinTxn)
	{	//inside txn use sessions rowset
	  pRowset = aSession->GetRowset(mConfigPath);
	}
	else
	{ //outside txn, create own rowset
		pRowset = ROWSETLib::IMTSQLRowsetPtr(MTPROGID_SQLROWSET);
		pRowset->Init(mConfigPath);
	}

	if (pRowset == NULL) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "MTDTCtestPlugIn1::testNoTransaction(): Failed to get Rowset");
		return E_FAIL;
	}

	char buf[1024];
	sprintf(buf, "Inserting testID %d into t_pv_dtctest...", aTestID);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
	
	_bstr_t queryTag = "__INSERT_DTC_TEST__";
	pRowset->SetQueryTag(queryTag);

	pRowset->AddParam(L"%%TEST_ID%%", aTestID);
	pRowset->AddParam(L"%%COMMENT%%", aComment);

	hr = pRowset->Execute();

	if (FAILED(hr)) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Query execution failed");
		return hr;
	}

	sprintf(buf, "Inserted testID %d into t_pv_dtctest", aTestID);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);

	return S_OK;
}

HRESULT MTDTCtestPlugIn1::UpdateRows(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn, long aTestID, _bstr_t aComment)
{
	HRESULT hr;

	ROWSETLib::IMTSQLRowsetPtr pRowset;
	
	if(withinTxn)
	{	//inside txn use sessions rowset
	  pRowset = aSession->GetRowset(mConfigPath);
	}
	else
	{ //outside txn, create own rowset
		pRowset = ROWSETLib::IMTSQLRowsetPtr(MTPROGID_SQLROWSET);
		pRowset->Init(mConfigPath);
	}

	if (pRowset == NULL) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "MTDTCtestPlugIn1::testNoTransaction(): Failed to get Rowset");
		return E_FAIL;
	}

	char buf[1024];
	sprintf(buf, "updating testID %d for all rows in t_dtctest...", aTestID);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
	
	_bstr_t queryTag = "__UPDATE_DTC_TEST__";
	pRowset->SetQueryTag(queryTag);

	pRowset->AddParam(L"%%TEST_ID%%", aTestID);
	pRowset->AddParam(L"%%COMMENT%%", aComment);

	hr = pRowset->Execute();

	if (FAILED(hr)) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Query execution failed");
		return hr;
	}

	sprintf(buf, "Updated testID %d in t_dtctest", aTestID);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);

	return S_OK;
}

HRESULT MTDTCtestPlugIn1::SelectRows(MTPipelineLib::IMTSessionPtr aSession, bool withinTxn)
{
	HRESULT hr;

	ROWSETLib::IMTSQLRowsetPtr pRowset;
	
	if(withinTxn)
	{	//inside txn use sessions rowset
	  pRowset = aSession->GetRowset(mConfigPath);
	}
	else
	{ //outside txn, create own rowset
		pRowset = ROWSETLib::IMTSQLRowsetPtr(MTPROGID_SQLROWSET);
		pRowset->Init(mConfigPath);
	}

	if (pRowset == NULL) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "MTDTCtestPlugIn1::testNoTransaction(): Failed to get Rowset");
		return E_FAIL;
	}

	char buf[1024];
	sprintf(buf, "Selecting from t_dtctest...");
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
	
	_bstr_t queryTag = "__SELECT_DTC_TEST__";
	pRowset->SetQueryTag(queryTag);
	hr = pRowset->Execute();

	if (FAILED(hr)) {
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Query execution failed");
		return hr;
	}

	int NumRecords = pRowset->GetRecordCount();

	sprintf(buf, "select returned %d records", NumRecords);
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);

	int i = 0;
	while(pRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
	{
		long testid = pRowset->GetValue("c_testid");
		_bstr_t comment = pRowset->GetValue("c_comment");

		sprintf(buf, "%d: %d '%s'", i, testid, (const char*)comment);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);

		i++;
		pRowset->MoveNext();
	}

	return S_OK;
}


HRESULT MTDTCtestPlugIn1::PlugInShutdown()
{
	return S_OK;
}
