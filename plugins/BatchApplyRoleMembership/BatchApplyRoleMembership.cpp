/**************************************************************************
 * @doc BatchApplyRoleMembership
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <BatchPlugInSkeleton.h>
#include <mtcomerr.h>

#include <MSIX.h>

#include <NTThreader.h>
#include <NTThreadLock.h>

#include <propids.h>
#include <mtglobal_msg.h>
#include <mtprogids.h>
#include <ConfigDir.h>

#include <OdbcTableWriter.h>

#include <autoptr.h>
#include <errutils.h>
#include <perfshare.h>
#include <perflog.h>

#import <MTEnumConfigLib.tlb> 
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <MTConfigLib.tlb>
#import <MTServerAccess.tlb>
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <MetraTech.DataAccess.tlb>

// generate using uuidgen
CLSID CLSID_BatchApplyRoleMembership = { /* aa041ada-f13a-4e1c-ba17-88f7794c2baa */
    0xaa041ada,
    0xf13a,
    0x4e1c,
    {0xba, 0x17, 0x88, 0xf7, 0x79, 0x4c, 0x2b, 0xaa}
  };


class ATL_NO_VTABLE BatchApplyRoleMembership
	: public MTBatchPipelinePlugIn<BatchApplyRoleMembership, &CLSID_BatchApplyRoleMembership>
{
protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			MTPipelineLib::IMTNameIDPtr aNameID,
																			MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();

private:
	HRESULT ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet);
	HRESULT GenerateQueries(const char* stagingDBName);
	
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTLogPtr mPerfLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
	MTPipelineLib::IMTSystemContextPtr mSysContext;
	QUERYADAPTERLib::IMTQueryAdapterPtr       mQueryAdapter;
	int mArraySize;
	COdbcTableWriter* mTableWriter;
	std::string mCreateTempTableQuery;
	std::string mTempTableName;
	std::string mTmpTableFullName;
	std::string mTagName;
	BOOL mbOKLogDebug;

	long mOperationPropID;
	long m_AccountIDPropID;
	long mAccountStartDatePropID;
	long mAncestorAccountIDPropID;
	long mOldAncestorAccountIDPropID;

	long mAccountTypePropID;
	long mUserNamePropID;
	long mNameSpacePropID;

	vector<MTAUTHLib::IMTRolePtr> mRoles;
  
};

PLUGIN_INFO(CLSID_BatchApplyRoleMembership, BatchApplyRoleMembership,
						"MetraPipeline.ApplyRoleMembership.1", "MetraPipeline.ApplyRoleMembership", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchApplyRoleMembership::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																										MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																										MTPipelineLib::IMTNameIDPtr aNameID,
																										MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	HRESULT hr;
	mNameID = aNameID;
	mLogger = aLogger;
    mTableWriter = NULL;

    mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	mQueryAdapter->Init(L"\\Queries\\AccountCreation");

	mEnumConfig = aSysContext->GetEnumConfig();
	mbOKLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[BatchApplyRoleMembership]");
	mSysContext = aSysContext;

  
	// reads in the config file
	hr = ParseConfigFile(aPropSet);
	if (FAILED(hr))
		return hr;

	// create a unique name based on the stage name and plug-in name
	COdbcConnectionInfo stageDBEntry = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	string stageDBName = stageDBEntry.GetCatalog();
	mTagName = GetTagName(aSysContext);
	hr = GenerateQueries(stageDBName.c_str());
	if (FAILED(hr))
		return hr;
  
	return S_OK;
}

HRESULT BatchApplyRoleMembership::ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet) 
{
	HRESULT hr = S_OK;
	
	try 
  {
    MTSERVERACCESSLib::IMTServerAccessDataSetPtr ServerAccessPtr(MTPROGID_SERVERACCESS);
  	ServerAccessPtr->Initialize();
	MTSERVERACCESSLib::IMTServerAccessDataPtr AccessSetPtr = ServerAccessPtr->FindAndReturnObject("SuperUser");
	_bstr_t suname = AccessSetPtr->GetUserName();
	_bstr_t supw = AccessSetPtr->GetPassword();

    MTAUTHLib::IMTLoginContextPtr LoginContextPtr(__uuidof(MTAUTHLib::MTLoginContext));
    MTAUTHLib::IMTSessionContextPtr ctx = LoginContextPtr->Login(suname, "system_user", supw);
    MTAUTHLib::IMTSecurityPtr SecurityPtr(__uuidof(MTAUTHLib::MTSecurity));

    MTPipelineLib::IMTConfigPropSetPtr roles;
    m_AccountIDPropID = mNameID->GetNameID(arPropSet->NextStringWithName("AccountID"));
    mAccountTypePropID = mNameID->GetNameID(arPropSet->NextStringWithName("AccountType"));
    mUserNamePropID = mNameID->GetNameID(arPropSet->NextStringWithName("username"));
    mNameSpacePropID = mNameID->GetNameID(arPropSet->NextStringWithName("Namespace"));
    try
	{
		roles = arPropSet->NextSetWithName(L"Roles");
	}
	catch (_com_error&) 
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "The <Roles> block must be a non-empty set!");
		throw;
	}
	if (roles == NULL)
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
											 "The required <Roles> block is missing from the configuration file!");
		return PIPE_ERR_CONFIGURATION_ERROR;
	}

    _bstr_t rolename;
    while(roles->NextMatches("Role", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      rolename = roles->NextStringWithName("Role");
      MTAUTHLib::IMTRolePtr RolePtr = SecurityPtr->GetRoleByName(ctx, rolename);
      if (RolePtr->SubscriberAssignable == VARIANT_FALSE)
      {
        char buf[1024];
        sprintf(buf, "Role '%s' can not be assigned to subscriber accounts.", (const char*)RolePtr->Name);
        mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING, buf);
	  }
      if (RolePtr->CSRAssignable == VARIANT_FALSE)
      {
        if(mbOKLogDebug)
        {
          char buf[1024];
          sprintf(buf, "Role '%s' can be assigned only to subscriber accounts.", (const char*)RolePtr->Name);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
        }
	  }
      mRoles.push_back(RolePtr);
    }

		//BP TODO read from config.
		mArraySize = 1000;

	}
	catch (_com_error& e) 
	{
		char buffer[1024];
		sprintf(buffer, "An exception was thrown while parsing the config file: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
	}

	return S_OK;
}


HRESULT BatchApplyRoleMembership::GenerateQueries(const char* stagingDBName)
{
  // Build the name of our "temporary" table.
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  mTempTableName = nameHash->GetDBNameHash(("tmp_accrole_memship" + mTagName).c_str());
  string schemaDots = mQueryAdapter->GetSchemaDots();

  mTmpTableFullName = stagingDBName + schemaDots + mTempTableName.c_str();

  // the base temp table create and insert queries
  //username and namespace properties are there only for debugging
  
  mQueryAdapter->ClearQuery();
  mQueryAdapter->SetQueryTag("__CREATE_APPLYROLEMEMBERSHIP_TEMP_TABLE__");
  mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTempTableName.c_str());
  mCreateTempTableQuery = mQueryAdapter->GetQuery();

  return S_OK;
}

HRESULT BatchApplyRoleMembership::BatchPlugInInitializeDatabase()
{
	// this is a read-only plugin, so retry is safe
  AllowRetryOnDatabaseFailure(FALSE);
  if (mTableWriter != NULL)
  {
    delete mTableWriter;
    mTableWriter = NULL;
  }

  mTableWriter = new COdbcTableWriter(mLogger, mNameID);
  mTableWriter->InitializeDatabase(	mTempTableName, 
									mTmpTableFullName,
									mCreateTempTableQuery, 
									mArraySize);

  // Set up temp table mappings, start with offset of 2
  // because offset 1 is reserved for requestid and is
  // implicitely set by OdbcTableWriter
  mTableWriter->AddTempTableColumnMapping(2, MTPipelineLib::SESS_PROP_TYPE_LONG,  m_AccountIDPropID, true);
  mTableWriter->AddTempTableColumnMapping(3, MTPipelineLib::SESS_PROP_TYPE_STRING, mAccountTypePropID, true);

  return S_OK;
}


HRESULT BatchApplyRoleMembership::BatchPlugInShutdownDatabase()
{
  delete mTableWriter;
  mTableWriter = NULL;
  return S_OK;
}


HRESULT BatchApplyRoleMembership::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
  //get service def id from first session and initialize service definition object
  SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
  HRESULT hr = it.Init(aSet);
  if (FAILED(hr)) return hr;

  MTPipelineLib::IMTSessionPtr session = it.GetNext();
  ASSERT(session != NULL);

//pipeline transaction will be extracted in TableWriter and stored until we need to execute SELECT statement
  mTableWriter->InitializeFromSessionSet(aSet);

  try
  {
    mTableWriter->InsertIntoTempTable();
  }
  catch (_com_error& err)
  {
    if (err.Error() == PIPE_ERR_SUBSET_OF_BATCH_FAILED)
      return PIPE_ERR_SUBSET_OF_BATCH_FAILED;
    else
      throw;
  }

  //do one insert per role
  for (unsigned int i = 0; i < mRoles.size(); i++)
  {
    MTAUTHLib::IMTRolePtr roleptr = mRoles[i];
    long roleid = roleptr->ID;
    int subassignable = (roleptr->SubscriberAssignable == VARIANT_TRUE) ? 1 : 0;
    int csrassignable = (roleptr->CSRAssignable == VARIANT_TRUE) ? 1 : 0;

	mQueryAdapter->ClearQuery();
	mQueryAdapter->SetQueryTag("__INSERT_ROLE_MEMBERSHIP_RECORD__");
	mQueryAdapter->AddParam("%%TEMPTABLE%%", mTmpTableFullName.c_str());
	mQueryAdapter->AddParam("%%ID_ROLE%%", roleid);
    mQueryAdapter->AddParam("%%SUB_ASSIGNABLE%%", subassignable);
    mQueryAdapter->AddParam("%%CSR_ASSIGNABLE%%", csrassignable);
	_bstr_t query = mQueryAdapter->GetQuery();

    if(mbOKLogDebug)
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,
												 (const char*)query);
    }
    
    mTableWriter->ExecuteInsertInDistributedTransaction((const char*)query);
  }

  //hacky - we need to clear sessionarray, we need to come up with better way to do this
  mTableWriter->Clear();
  return S_OK;
}

