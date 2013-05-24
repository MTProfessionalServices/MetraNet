/**************************************************************************
 * @doc BATCHACCOUNTRESOLUTION
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
 * Created by: Derek Young
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

#include "SessServer.h"
#include <MTObjectOwnerBaseDef.h>
#include <MTSessionServerBaseDef.h>
#include <MTVariantSessionEnumBase.h>
#include <MTSessionSetDef.h>
#include <MTSessionDef.h>


#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcResultSet.h>
#include <OdbcConnMan.h>
#include <OdbcSessionTypeConversion.h>
#include <reservedproperties.h>


#include <autoptr.h>
#include <errutils.h>
#include <perfshare.h>
#include <perflog.h>

#include "OdbcResourceManager.h"

#include <map>

#import <MTAccount.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <RCD.tlb>
#import <MTConfigLib.tlb>
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <MetraTech.DataAccess.tlb>

typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;


// generate using uuidgen
CLSID CLSID_BATCHACCOUNTRESOLUTION = { /* ccbf090d-7c32-4006-b065-940317c08d43 */
    0xccbf090d,
    0x7c32,
    0x4006,
    {0xb0, 0x65, 0x94, 0x03, 0x17, 0xc0, 0x8d, 0x43}
  };



typedef enum {
  ByAccountID = 0,        //Resolve account with AccountID
  ByAccountLogin = 1,     //Resolve account with Login/Namespace
  ByEndpoint = 2          //Resolve account with service endpoint
} ResolutionMethod;


class ATL_NO_VTABLE BatchAccountResolution
	: public MTBatchPipelinePlugIn<BatchAccountResolution, &CLSID_BATCHACCOUNTRESOLUTION>
{

protected:

	// a performant, non-COM version of CMTPropertyMetadata class that has
	// just enough functionallity required by account resolution
	class NativePropertyMetadata
	{
	public:

		// mutators
		void SetName(const wchar_t* name)
		{ mName = name; }

		void SetDataType(PropValType dataType)
		{ mDataType = dataType; }

		void SetRequired(bool required)
		{ mRequired = required; }

		void SetDBTableName(const char* dbTableName)
		{ mDBTableName = dbTableName; }

		void SetDBColumnName(const char* dbColumnName)
		{ mDBColumnName = dbColumnName; }

		void SetDBDataType(const char* dbDataType)
		{ mDBDataType = dbDataType; }


		// accessors
		const wchar_t * GetName()
		{ return mName.c_str(); }

		PropValType GetDataType()
		{ return mDataType; }

		bool GetRequired()
		{ return mRequired; }

		const char* GetDBTableName()
		{ return mDBTableName.c_str(); }

		const char* GetDBColumnName()
		{ return mDBColumnName.c_str(); }

		const char* GetDBDataType()
		{ return mDBDataType.c_str(); }


		// converter
		static NativePropertyMetadata* ConvertToNative(MTACCOUNTLib::IMTPropertyMetaDataPtr comProp)
		{
			NativePropertyMetadata* nativeProp = new NativePropertyMetadata();

			nativeProp->SetName(comProp->GetName());
			nativeProp->SetDataType((PropValType) comProp->GetDataType());
			nativeProp->SetRequired(comProp->GetRequired() == VARIANT_TRUE);

			nativeProp->SetDBTableName(comProp->GetDBTableName());
			nativeProp->SetDBColumnName(comProp->GetDBColumnName());
			nativeProp->SetDBDataType(comProp->GetDBDataType());

			return nativeProp;
		}

	private:

		wstring mName;
		PropValType mDataType;
		bool mRequired;
		string mDBTableName;
		string mDBColumnName;
		string mDBDataType;
	};

protected:
	virtual HRESULT BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																			MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																			MTPipelineLib::IMTNameIDPtr aNameID,
																			MTPipelineLib::IMTSystemContextPtr aSysContext);
	virtual HRESULT BatchPlugInInitializeDatabase();
	virtual HRESULT BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSet);
	virtual HRESULT BatchPlugInShutdownDatabase();
	virtual HRESULT BatchPlugInShutdown();

private:
	typedef std::map<int, NativePropertyMetadata*> PropertyMetadataMap;

	PropertyMetadataMap mKeyMetadata;
	PropertyMetadataMap mRetrievalMetadata;

private:

	template <class T>
	void InsertIntoTempTable(vector<MTautoptr<CMTSessionBase> >& aSessionArray,
													 COdbcConnectionHandle & connection,
                           T arStatement);
	void TruncateTempTable(COdbcConnectionHandle & connection);
	void CopyData(COdbcConnectionHandle & connection);
	void ResolveBatch(vector<MTautoptr<CMTSessionBase> >& aSessions, COdbcConnectionHandle & connection);

	// configuration helper methods
	HRESULT ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet);
	HRESULT GetPropertyMetadataCollection(MTPipelineLib::IMTConfigPropSetPtr& arPropSet,
 																				PropertyMetadataMap& arMap);
	HRESULT CreateAccountAdapter(const std::string& arExtension,
															 const std::string& arAccountView,
															 MTACCOUNTLib::IMTAccountAdapterPtr& arAdapter);
	HRESULT GetVirtualPropertyMetaData(const std::string& arPropertyName,
																		 MTACCOUNTLib::IMTPropertyMetaDataPtr& arMetadata);
	HRESULT GenerateQueries();

	BOOL mIsOkayToLogDebug;
	BOOL mIsOkayToLogPerf;
		
private:
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTLogPtr mPerfLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
	MTPipelineLib::IMTSystemContextPtr mSysContext;
	RCDLib::IMTRcdPtr mRCD;
	QUERYADAPTERLib::IMTQueryAdapterPtr       mQueryAdapter;

  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
  boost::shared_ptr<COdbcPreparedBcpStatementCommand> mBcpInsertToTempTableCommand;
  boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleArrayInsertCommand;
  boost::shared_ptr<COdbcPreparedArrayStatementCommand> mSqlArrayInsertCommand;
  boost::shared_ptr<COdbcPreparedArrayStatementCommand> mResolutionQueryCommand;
  boost::shared_ptr<COdbcConnectionCommand> mConnectionCommand;

	int mArraySize;

	ITransactionPtr mTransaction;

	std::string mCreateTempTableQuery;
	std::string mInsertTempTableQuery;
	std::string mResolutionQuery; 
	std::string mTempTableName;
	std::string mTagName;

	BOOL mUseBcpFlag;         //TRUE by default, uses BCP for inserts into temp table 
	BOOL mFailIfNotResolved;  //TRUE by default, if a request does not have a match, then fail the session
	BOOL mCopyData;				    //If TRUE, copy data from the temp table into a real table for debugging
  BOOL mResolveByEndpoint;  //Resolve accounts based on service endpoint

  ResolutionMethod meResolutionMethod;    //Default:  Resolve by Account Name/Namespace

	long mNamespacePropID;
	long mLoginPropID;
	long mAccountIDPropID;
	long mTimestampID;

	// virtual property name id's
	long mAccountIDOutputPropID;
	long mPriceListIDPropID;
	long mUsageCycleIDPropID;
  long mAccountStatePropID;
	long mPayingAccountIDPropID;
	long mAccountResolvedPropID;
  long mServiceEndpointPropID;
  long mCurrencyPropID;
  
	BOOL mBatchFailed;

	__int64 mTotalRecords;
	double mTotalMillis;
	__int64 mTotalFetchTicks;
	__int64 mInsertTempTableTicks;
	__int64 mTruncateTableTicks;

	__int64 mResultSetNextTicks;
	__int64 mCorePropertyDBTicks;
	__int64 mCorePropertySessionTicks;
	__int64 mCustomPropertyTicks;

private:
	// perfmon instrumentation
	PerfShare mPerfShare;
	SharedStats * mpStats;


  virtual MTPipelineLib::IMTTransactionPtr BatchAccountResolution::GetTransaction(CMTSessionBase* aSession);



};

PLUGIN_INFO(CLSID_BATCHACCOUNTRESOLUTION, BatchAccountResolution,
						"MetraPipeline.AccountResolution.1", "MetraPipeline.AccountResolution", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT BatchAccountResolution::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																										MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																										MTPipelineLib::IMTNameIDPtr aNameID,
																										MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	HRESULT hr;
	PipelinePropIDs::Init();

	mTotalRecords = 0;
	mTotalMillis = 0.0;
	mTotalFetchTicks = 0;
	mAccountIDOutputPropID = 0;
	mUsageCycleIDPropID = 0;
	mPriceListIDPropID = 0;
	mPayingAccountIDPropID = 0;
	mAccountStatePropID = 0;
	mTimestampID = 0;
	mAccountResolvedPropID = 0;
	mServiceEndpointPropID = 0;
	mCurrencyPropID = 0;

	mNameID = aNameID;
	mLogger = aLogger;
	mPerfLogger = MTPipelineLib::IMTLogPtr(MTPROGID_LOG);
	mPerfLogger->Init("logging\\perflog", "[AccountResolution]");
	mSysContext = aSysContext;

 	mIsOkayToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);
	mIsOkayToLogPerf  = mPerfLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

	mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
	mQueryAdapter->Init(L"\\Queries\\AccHierarchies");

	// default values for optional config properties
	mUseBcpFlag = TRUE;
	mFailIfNotResolved = TRUE;

	mResolveByEndpoint = FALSE;
	meResolutionMethod = ByAccountLogin;

	mArraySize = 1000;
  
	hr = mRCD.CreateInstance(MTPROGID_RCD);
	if(FAILED(hr)) 
		return hr;

	// initialize the perfmon integration library
	if (!mPerfShare.Init())
	{
		std::string buffer;
		StringFromError(buffer, "Unable to initialize perfmon counters",
										mPerfShare.GetLastError());
		return Error(buffer.c_str());
	}
	mpStats = &mPerfShare.GetWriteableStats();

	// reads in the config file
	hr = ParseConfigFile(aPropSet);
	if (FAILED(hr))
		return hr;

	// create a unique name based on the stage name and plug-in name
	mTagName = GetTagName(aSysContext);

 	// dynamically generates queries
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Dynamicly generating queries...");
	hr = GenerateQueries();
	if (FAILED(hr))
		return hr;
  
  // Create create commands for database resources we want to use.
  COdbcBcpHints hints;
  hints.SetMinimallyLogged(true);
  mBcpInsertToTempTableCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(new COdbcPreparedBcpStatementCommand(mTempTableName, hints));
  mOracleArrayInsertCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(new COdbcPreparedInsertStatementCommand(mTempTableName, mArraySize, true));
  mSqlArrayInsertCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(new COdbcPreparedArrayStatementCommand(mInsertTempTableQuery, mArraySize, true));
  mResolutionQueryCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(new COdbcPreparedArrayStatementCommand(mResolutionQuery, 1, true));


  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;

	if (mUseBcpFlag)
	{
    bcpStatements.push_back(mBcpInsertToTempTableCommand);
	}
	else
	{
		if (IsOracle())
      insertStatements.push_back(mOracleArrayInsertCommand);
		else
      arrayStatements.push_back(mSqlArrayInsertCommand);
	}
  arrayStatements.push_back(mResolutionQueryCommand);

  mConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"), 
                                                                                            COdbcConnectionCommand::TXN_AUTO,
                                                                                            FALSE == IsOracle(),
                                                                                            bcpStatements,
                                                                                            arrayStatements,
                                                                                            insertStatements));

  mOdbcManager->RegisterResourceTree(mConnectionCommand);

	return S_OK;
}


HRESULT BatchAccountResolution::ParseConfigFile(MTPipelineLib::IMTConfigPropSetPtr& arPropSet) 
{
	HRESULT hr;
	
	try {

		// retrieves the BCP flag
		if (arPropSet->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
			mUseBcpFlag = arPropSet->NextBoolWithName(L"usebcpflag");
		if (IsOracle())
		{
			// never use BCP with Oracle
			mUseBcpFlag = FALSE; 
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (Oracle detected)");
		}
		else 
		{
			if (mUseBcpFlag)
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface enabled (usebcpflag is TRUE)");
			else
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (usebcpflag is FALSE)");
		}

		// debugging hook
		if (arPropSet->NextMatches(L"copydata", MTPipelineLib::PROP_TYPE_BOOLEAN))
			mCopyData = arPropSet->NextBoolWithName(L"copydata") == VARIANT_TRUE;
		else
			mCopyData = FALSE;

		// allow the user to set size of batches/arrays.  default is 1000.
		if (VARIANT_TRUE == arPropSet->NextMatches("batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
		{
			mArraySize = arPropSet->NextLongWithName("batch_size");
		}
		else
		{
			mArraySize = 1000;
		}

    char buf[512];
    sprintf(buf,  "Batch array size will be '%d'", mArraySize);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
		//
		// parses the resolution set
		//
		MTPipelineLib::IMTConfigPropSetPtr resolutionSet;
		try
		{
			resolutionSet = arPropSet->NextSetWithName(L"Resolution");
		}
		catch (_com_error&) 
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
												 "The <Resolution> block must be a non-empty set!");
			throw;
		}
		if (resolutionSet == NULL)
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
												 "The required <Resolution> block is missing from the configuration file!");
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_WARNING,
												 "Perhaps the configuration file is for an older version of AccountResolution?");
			return PIPE_ERR_CONFIGURATION_ERROR;
		}

    //Check the endpoint resolution setting
    if(resolutionSet->NextMatches(L"EndpointID", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
    {
      mResolveByEndpoint = TRUE;
      meResolutionMethod = ByEndpoint;
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
				  "Account Resolution by Service Endpoint Login/Namespace has been deprecated.");
			return PIPE_ERR_CONFIGURATION_ERROR;
    }
    //Resolve by account login or ID
    else
    {
  		bool loginPropFound = false;
	  	if (resolutionSet->NextMatches(L"Login", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
		  {
  			mLoginPropID = mNameID->GetNameID(resolutionSet->NextStringWithName(L"Login"));
	  		loginPropFound = true;
		  }
		  // supports the old style login property (deprecated)
		  if (!loginPropFound && resolutionSet->NextMatches(L"Payer", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
		  { 
			  mLoginPropID = mNameID->GetNameID(resolutionSet->NextStringWithName(L"Payer"));
			  loginPropFound = true;
		  }

		  if (loginPropFound)
		  {
			  mNamespacePropID = mNameID->GetNameID(resolutionSet->NextStringWithName(L"Namespace"));
        meResolutionMethod = ByAccountLogin;
			  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Resolving by login/namespace");
		  }
		  else 
		  {
			  mAccountIDPropID = mNameID->GetNameID(resolutionSet->NextStringWithName(L"AccountID"));
        meResolutionMethod = ByAccountID;
			  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Resolving by account ID");
		  }
    }

		if(resolutionSet->NextMatches(L"Timestamp", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
		{
			_bstr_t timestampName = resolutionSet->NextStringWithName(L"Timestamp");
			_bstr_t logMsg = "Resolving timestamp by ";
			logMsg += timestampName;
			logMsg += " property";
			mTimestampID = mNameID->GetNameID(timestampName);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,logMsg);
		}
		else 
		{
			mTimestampID = PipelinePropIDs::TimestampCode();
		}

		// if a request does not have a match, fail it
		if (resolutionSet->NextMatches(L"FailIfNotResolved", MTPipelineLib::PROP_TYPE_BOOLEAN))
			mFailIfNotResolved = resolutionSet->NextBoolWithName(L"FailIfNotResolved");
		if (mFailIfNotResolved)
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Sessions will fail if not resolved (FailIfNotResolved is TRUE)");
		else
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Sessions will not fail if not resolved (FailIfNotResolved is FALSE)");


		// reads in additional keys (optional)
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Loading additional keys...");
		MTPipelineLib::IMTConfigPropSetPtr keySet;
		try
		{
			keySet = resolutionSet->NextSetWithName(L"AdditionalKeys");
		}
		catch (_com_error&) 
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
												 "The <AdditionalKeys> block must be a non-empty set!");
			throw;
		}
		hr = GetPropertyMetadataCollection(keySet, mKeyMetadata);
		if (FAILED(hr))
			return hr;


		//
		// parses the retrieval set
		//
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Loading retrieval properties...");
		MTPipelineLib::IMTConfigPropSetPtr retrievalSet;
		try
		{
			retrievalSet = arPropSet->NextSetWithName(L"Retrieval");
		}
		catch (_com_error&) 
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
												 "The <Retrieval> block must be a non-empty set!");
			throw;
		}
		hr = GetPropertyMetadataCollection(retrievalSet, mRetrievalMetadata);
		if (FAILED(hr))
			return hr;
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

HRESULT BatchAccountResolution::GetPropertyMetadataCollection(MTPipelineLib::IMTConfigPropSetPtr& arPropSet,
																															PropertyMetadataMap& arMap)
{
	HRESULT hr;
	
	if (arPropSet)
	{
		MTPipelineLib::IMTConfigPropSetPtr propertySet = arPropSet->NextSetWithName(L"Property");
		while (propertySet)
		{
			// gets the extension name (optional)
			std::string extension;
			BOOL extensionOmitted = FALSE;
			if (propertySet->NextMatches(L"Extension", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
				extension = propertySet->NextStringWithName(L"Extension");
			}
			else
			{
				// otherwise, assumes the current extension from syscontext
				extension = (const char *) _bstr_t(mSysContext->ExtensionName);
				extensionOmitted = TRUE;
			}

			// gets the adapter name (optional)
			std::string accountAdapterName;
			if (propertySet->NextMatches(L"AccountAdapter", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
				accountAdapterName = propertySet->NextStringWithName(L"AccountAdapter");
			}
			else
			{
				if (extensionOmitted) 
				{
					// otherwise, defaults to the plugin's virtual adapter
					accountAdapterName = "virtual";
					extension = "core";
				}
				else 
					return Error("AccountAdapter tag is required if Extension is specified!");
			}

			// gets the account view property's name
			std::string propertyName = propertySet->NextStringWithName(L"Name");
			
			// gets the session property's name (optional)
			long inSessionID;
			if (propertySet->NextMatches(L"InSession", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			{
				inSessionID = mNameID->GetNameID(propertySet->NextStringWithName(L"InSession"));
			}
			else
			{
				// otherwise, assumes the property name will also be the name of the 
				// session property
				inSessionID = mNameID->GetNameID(_bstr_t(propertyName.c_str()));
			}

      // currency is being treated differently.  Since 5.0 onwards, we need to get the payer's currency, rather
      // than the payee's currency.  Currency is a part of the internal adapter.  But for this
      // plugin we will treat it like a core property, such as pricelist etc.
      if (stricmp(propertyName.c_str() ,"Currency") == 0)
      {
        //set the account adapter to virtual and extension to core and let user know
					accountAdapterName = "virtual";
					extension = "core";
			    std::string currencyBuffer;
          currencyBuffer = "Please Note: After resolution, the session will contain the currency of the PAYER";
			    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, currencyBuffer.c_str());
      }
			// determines if this is the special virtual (hard coded, *cough*) account adapter?
			BOOL virtualAdapter;
			if ((stricmp(extension.c_str(), "core") == 0) && 
					(stricmp(accountAdapterName.c_str(), "virtual") == 0))
				virtualAdapter = TRUE;
			else
				virtualAdapter = FALSE;
			
			// logs property info
			std::string buffer;
			buffer = "acount view property metadata: extension = '" + extension 
				+ "'; account adapter = '" + accountAdapterName + "'; property name = '" + propertyName + "'";
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer.c_str());
			
			MTACCOUNTLib::IMTPropertyMetaDataPtr comPropertyMetadata;
			if (!virtualAdapter)
			{
				
				// creates the account adapter
				MTACCOUNTLib::IMTAccountAdapterPtr accountAdapter;
				hr = CreateAccountAdapter(extension, accountAdapterName, accountAdapter);
				if (FAILED(hr))
					return hr;

				// gets the property metadata
				comPropertyMetadata = accountAdapter->GetPropertyMetaData(_bstr_t(propertyName.c_str()));
			}
			else
			{
				// emulates an account adapter
				hr = GetVirtualPropertyMetaData(propertyName, comPropertyMetadata);
				if (FAILED(hr))
					return hr;
			}


			// caches retrieval properties built into the base resolution query
			// for improved fetch performance
			if ((stricmp(extension.c_str(), "core") == 0) && 
					(stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
					(stricmp(propertyName.c_str(), "AccountID") == 0))
			{
				mAccountIDOutputPropID = inSessionID;
			}
			else if ((stricmp(extension.c_str(), "core") == 0) && 
							 (stricmp(accountAdapterName.c_str(), "internal") == 0) &&
							 (stricmp(propertyName.c_str(), "PriceList") == 0))
			{
				mPriceListIDPropID = inSessionID;
			}
			else if ((stricmp(extension.c_str(), "core") == 0) && 
							 (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
							 (stricmp(propertyName.c_str(), "UsageCycleID") == 0))
			{
				mUsageCycleIDPropID = inSessionID;
			}
      else if ((stricmp(extension.c_str(), "core") == 0) && 
               (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
               (stricmp(propertyName.c_str(), "Currency") == 0))
      {
        mCurrencyPropID = inSessionID;
      }
			else if ((stricmp(extension.c_str(), "core") == 0) && 
							 (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
							 (stricmp(propertyName.c_str(), "AccountState") == 0))
			{
				mAccountStatePropID = inSessionID;
			}
			else if ((stricmp(extension.c_str(), "core") == 0) && 
							 (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
							 (stricmp(propertyName.c_str(), "PayingAccount") == 0))
			{
				mPayingAccountIDPropID = inSessionID;
			}
			else if ((stricmp(extension.c_str(), "core") == 0) && 
							 (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
							 (stricmp(propertyName.c_str(), "AccountResolved") == 0))
			{
				mAccountResolvedPropID = inSessionID;
			}
      else if((stricmp(extension.c_str(), "core") == 0) &&
              (stricmp(accountAdapterName.c_str(), "virtual") == 0) &&
              (stricmp(propertyName.c_str(), "ServiceEndpointID") == 0))
      {
        //mServiceEndpointPropID = inSessionID;
        //ignore, do nothing.
      }
      else
			{
        // adds all other properties to the map
        NativePropertyMetadata* propertyMetadata = NativePropertyMetadata::ConvertToNative(comPropertyMetadata);
        arMap[inSessionID] = propertyMetadata;
			}

			propertySet = arPropSet->NextSetWithName(L"Property");
		}
	}
	
	return S_OK;
}

//TODO: replace this with a real account adapter
//      which supports properties that live in other tables
HRESULT BatchAccountResolution::GetVirtualPropertyMetaData(const std::string& arPropertyName,
																													 MTACCOUNTLib::IMTPropertyMetaDataPtr& arMetadata)
{
	arMetadata.CreateInstance("Metratech.MTPropertyMetaData.1");

	if ((stricmp(arPropertyName.c_str(), "AccountID") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());
		
		// this property will be retrieved from the view, so leave these blank 
		arMetadata->PutDBTableName("");   
		arMetadata->PutDBColumnName("");

		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_INTEGER);
	} 
	else if ((stricmp(arPropertyName.c_str(), "UsageCycleID") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());
		
		// this property will be retrieved from the view, so leave these blank 
		arMetadata->PutDBTableName("");   
		arMetadata->PutDBColumnName("");
		
		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_INTEGER);
	}
	else if ((stricmp(arPropertyName.c_str(), "AccountStartDate") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());
		arMetadata->PutDBTableName("t_account");   
		arMetadata->PutDBColumnName("dt_start");
		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_DATETIME);
	}
	else if ((stricmp(arPropertyName.c_str(), "AccountEndDate") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());
		arMetadata->PutDBTableName("t_account");   
		arMetadata->PutDBColumnName("dt_end");
		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_DATETIME);
	}
	else if ((stricmp(arPropertyName.c_str(), "AccountState") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());

		// this property will be retrieved from the view, so leave these blank 
		arMetadata->PutDBTableName("");   
		arMetadata->PutDBColumnName("");

		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_ENUM);
	}
	else if ((stricmp(arPropertyName.c_str(), "PayingAccount") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());

		// this property will be retrieved from the view, so leave these blank 
		arMetadata->PutDBTableName("");   
		arMetadata->PutDBColumnName("");

		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_ENUM);
	}
  else if((stricmp(arPropertyName.c_str(), "Currency") == 0))
  {
    arMetadata->PutName(arPropertyName.c_str());

    //this property will be retrieved from the view, so leave these blank
    arMetadata->PutDBTableName("");
    arMetadata->PutDBColumnName("");

    arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_STRING);
  }
	else if ((stricmp(arPropertyName.c_str(), "AccountResolved") == 0))
	{
		arMetadata->PutName(arPropertyName.c_str());

		// this property will be retrieved from the view, so leave these blank 
		arMetadata->PutDBTableName("");   
		arMetadata->PutDBColumnName("");

		arMetadata->PutDataType(MTACCOUNTLib::PROP_TYPE_BOOLEAN);
	}
  else
		return Error("Special virtual property not found!");
	
	return S_OK;
}

HRESULT BatchAccountResolution::CreateAccountAdapter(const std::string& arExtension,
																										 const std::string& arAdapterName,
																										 MTACCOUNTLib::IMTAccountAdapterPtr& arAdapter)
{
	HRESULT hr;
  bool bDone = false;
  VARIANT_BOOL aCheckSumMatch;
  _bstr_t name;
	_bstr_t progID;
	_bstr_t configFile;
  bool found = false;

	try 
	{
		arAdapter = NULL;
		
		// builds up the config file's path and name
		//_bstr_t extensionDir = mRCD->GetExtensionDir();
		//configFile = (const char*) extensionDir;
		//configFile += "\\";
		//configFile += arExtension;
		//configFile += "\\config\\account\\AccountAdapters.xml";

    mRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = mRCD->RunQuery("config\\AccountType\\*.xml",VARIANT_TRUE);

    SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		it.Init(aFileList);
    MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

		while(!bDone)
    {

			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0)
      {
				bDone = true;
				break;
			}

			MTConfigLib::IMTConfigPropSetPtr aPropSet = aConfig->ReadConfiguration(afile,&aCheckSumMatch);
      MTConfigLib::IMTConfigPropSetPtr aTypeSet = aPropSet->NextSetWithName("AccountType");
      MTConfigLib::IMTConfigPropSetPtr aViewSet = aTypeSet->NextSetWithName("AccountViews");
      MTConfigLib::IMTConfigPropSetPtr aAdapterSet = aViewSet->NextSetWithName("AdapterSet");

			while (aAdapterSet != NULL)
			{
				name = aAdapterSet->NextStringWithName("Name");
				
				if (0 == _stricmp((const char *)name, arAdapterName.c_str()))
				{
					name = name;
          progID = aAdapterSet->NextStringWithName("ProgID");
					configFile = aAdapterSet->NextStringWithName("ConfigFile");
					found = true;
          bDone = true;
					break;
				}

				aAdapterSet = aViewSet->NextSetWithName("AdapterSet");
      }
    }
	
		// the adapter wasn't found in this extension
		if (!found)
		{
			char buffer[2048];
			sprintf(buffer, "The account adapter named '%s' was not found in any of the account type files.",
							arAdapterName.c_str());
			return Error(buffer);
		}
			
	}
	catch(_com_error& e) 
	{
		char buffer[2048];
		sprintf(buffer, "There was a problem reading configuration information for the account"
						"adapter named '%s'", arAdapterName.c_str());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
		return ReturnComError(e);
	}

	// creates the account adapter object
	try
	{
		hr = arAdapter.CreateInstance((const char *)progID);
		if (FAILED(hr))
		{
			char buffer[1024];
			sprintf(buffer, "Unable to create instance of account adapter named '%s' with progID of '%s'!",
							arAdapterName.c_str(), progID);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
			return hr;
		}

		// initializes the adapter with the accountview.
		arAdapter->Initialize(configFile);

	}
	catch (_com_error& e)
	{
		char buffer[1024];
		sprintf(buffer, "Unable to initialize account adapter named '%s' with account view '%s'!",
						arAdapterName.c_str(), configFile);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
		return ReturnComError(e);
	}

	return S_OK;
}

HRESULT BatchAccountResolution::GenerateQueries()
{
	MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
	mTempTableName = nameHash->GetDBNameHash(("tmp_acctres_" + mTagName).c_str());

	if (IsOracle())
	{
		mUseBcpFlag = FALSE;
	}
	else
	{
		mUseBcpFlag = TRUE;
	}

	mInsertTempTableQuery = "insert into " + mTempTableName + " (id_request, nm_login, nm_space, id_acc, restime";
	std::string insertParams;
	std::string additionalKeys = "";

	// if there are additional keys add them to the create and insert queries
	if (!mKeyMetadata.empty())
	{
		PropertyMetadataMap::iterator it;
		int i = 0;
		for (it = mKeyMetadata.begin(); it != mKeyMetadata.end(); it++, i++) 
		{
			NativePropertyMetadata* keyMetadata;
			keyMetadata = it->second;
			
			// checks to make sure the key is really a key
			if (!keyMetadata->GetRequired())
				return Error("Additional key property is not marked as PartOfKey in the account view definition!");

			char keyBuffer[256];
			sprintf(keyBuffer, ", extraKey%d", i); 
			additionalKeys += keyBuffer + std::string(" ") + keyMetadata->GetDBDataType();
			mInsertTempTableQuery += keyBuffer;
			insertParams += ", ?";
		}
	}
	mInsertTempTableQuery += ") values (?, ?, ?, ?, ?" + insertParams;
		
	// terminates queries
	mInsertTempTableQuery += ")";

	mQueryAdapter->ClearQuery();
	mQueryAdapter->SetQueryTag("__CREATE_BATCH_ACC_RESOLUTION_TEMP_TABLE__");
	mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTempTableName.c_str());
	mQueryAdapter->AddParam("%%ADDITIONAL_KEYS%%", additionalKeys.c_str());
	mCreateTempTableQuery = mQueryAdapter->GetQuery();

	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, mCreateTempTableQuery.c_str());
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, mInsertTempTableQuery.c_str());


	std::string paramRetrievalProperties;
	std::string paramPropertyTables;
	std::string paramPropertyJoins;
	std::string accountJoinTable;
	std::map<std::string, bool> uniqueTables;

	accountJoinTable = "res";

	//AR: If we stop indexing the view T_VW_I_ACCTRES, then uncomment the following line.  No point in joining t_av_internal again to
	//get another property for the payee from the table.
	//uniqueTables["t_av_internal"] = true;

	PropertyMetadataMap::iterator it;
	for (it = mRetrievalMetadata.begin(); it != mRetrievalMetadata.end(); it++) 
	{
		NativePropertyMetadata* retrievalMetadata;
		retrievalMetadata = it->second;

		std::string table = retrievalMetadata->GetDBTableName();
		std::string column = retrievalMetadata->GetDBColumnName();

		// if we haven't visited this table before add it to the FROM and WHERE clauses
		if (uniqueTables[table] == false)
		{
			paramPropertyTables += ", " + table;
			paramPropertyJoins  += " AND " + accountJoinTable + ".id_acc = " + table + ".id_acc";

			// mark it visited
			uniqueTables[table] =	true;				
		}

		// builds up the select list
		paramRetrievalProperties += ", " + table + std::string(".") + column;
	}

	// adds in the extra keys to the join clause 
	int i = 0;
	for (it = mKeyMetadata.begin(); it != mKeyMetadata.end(); it++, i++) 
	{
		NativePropertyMetadata* keyMetadata;
		keyMetadata = it->second;

		std::string table = keyMetadata->GetDBTableName();
		std::string column = keyMetadata->GetDBColumnName();

		// if the table hasn't already been added to the FROM clause then add it
		if (uniqueTables[table] == false)
		{
			paramPropertyTables += ", " + table;
			uniqueTables[table] =	true; // mark it visited

		}

		char keyJoinBuffer[2048];
		sprintf(keyJoinBuffer, " AND arg.extraKey%d = %s.%s",
						i,
						table.c_str(),
						column.c_str()); 

		paramPropertyJoins  += keyJoinBuffer;
	}

	
	// TODO: move these queries to query file, ODBC QueryAdapter does not yet
	// support string substitution for parameters
 
	if (meResolutionMethod == ByAccountID)
	{
  	mResolutionQuery = 
			"SELECT arg.id_request,"
			"       arg.id_acc,"
			"       res.payer_id_usage_cycle,"
			"       res.c_pricelist,"
			"				res.id_payer, "
      "				res.status, "
      "       res.currency " +
			paramRetrievalProperties +        //  %%ACCOUNTVIEW_PROPERTIES%%
			" FROM  " + 
      mTempTableName + " arg ";
			
			if (!IsOracle())
				mResolutionQuery += "with(READCOMMITTED) ";

			mResolutionQuery +=   "      , t_vw_acctres_byid res  ";

      if (!IsOracle())
			  mResolutionQuery += "with(READCOMMITTED) ";

      mResolutionQuery += paramPropertyTables + //  %%ACCOUNTVIEW_TABLES%%
      " WHERE " +
      " res.id_acc = arg.id_acc AND " +
      " arg.restime between payer_start AND payer_end AND " +
      " arg.restime between state_start AND state_end "
      +	paramPropertyJoins;               //  %%ACCOUNTVIEW_JOIN_CRITERIA%%

	}
  else if (meResolutionMethod == ByAccountLogin)
	{
		mResolutionQuery = 
			"SELECT arg.id_request,"
			" res.id_acc,"
			" res.payer_id_usage_cycle,"
			" res.c_pricelist,"
			"	res.id_payer, "
      "	res.status, "
      " res.currency " +
			paramRetrievalProperties +        //  %%ACCOUNTVIEW_PROPERTIES%%
			" FROM  " + 
      mTempTableName + " arg ";
			

// TODO: add no expand hint back in
#if 0
		if (!IsOracle())
			mResolutionQuery += "with (noexpand) ";
#endif

		//BP: only add READCOMMITTED hint in SQL server case
		if (!IsOracle())
			mResolutionQuery += "with(READCOMMITTED) ";
		mResolutionQuery += ",       t_vw_acctres res ";
    if (!IsOracle())
			mResolutionQuery += "with(READCOMMITTED) ";
		
		// since sql server is case insensitive, lets just do normal compare
		if (!IsOracle())
		{
			mResolutionQuery +=
				paramPropertyTables +             //  %%ACCOUNTVIEW_TABLES%%
		  " WHERE res.nm_login = arg.nm_login AND"
			"       res.nm_space = arg.nm_space AND"
			" arg.restime between payer_start AND payer_end AND"
      " arg.restime between state_start AND state_end " +
			paramPropertyJoins;               //  %%ACCOUNTVIEW_JOIN_CRITERIA%%
		}
		else
		{
			mResolutionQuery +=
				paramPropertyTables +             //  %%ACCOUNTVIEW_TABLES%%
			" WHERE upper(res.nm_login) = upper(arg.nm_login) AND"
			"       upper(res.nm_space) = upper(arg.nm_space) AND"
			" arg.restime between payer_start AND payer_end AND"
      " arg.restime between state_start AND state_end " +
			paramPropertyJoins;               //  %%ACCOUNTVIEW_JOIN_CRITERIA%%
		}
	}


	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, mResolutionQuery.c_str());
	return S_OK;
}

HRESULT BatchAccountResolution::BatchPlugInInitializeDatabase()
{
	// this is a read-only plugin, so retry is safe
	AllowRetryOnDatabaseFailure(TRUE);

  // Create the temp table in advance of being able to create
  // the resource tree since it prepares queries that reference
  // the table.
  MTautoptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
	COdbcStatementPtr createTempTable = conn->CreateStatement();
	createTempTable->ExecuteUpdate(mCreateTempTableQuery);
	conn->CommitTransaction();

	return S_OK;
}


HRESULT BatchAccountResolution::BatchPlugInShutdownDatabase()
{
  mOdbcManager->Reinitialize(mConnectionCommand);

	return S_OK;
}

HRESULT BatchAccountResolution::BatchPlugInShutdown()
{
	PropertyMetadataMap::iterator it;
	for (it = mRetrievalMetadata.begin(); it != mRetrievalMetadata.end(); it++)
		delete it->second;
	for (it = mKeyMetadata.begin(); it != mKeyMetadata.end(); it++)
		delete it->second;

	return S_OK;
}


void BatchAccountResolution::TruncateTempTable(COdbcConnectionHandle& connection)
{
	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);
	COdbcStatementPtr truncate = connection->CreateStatement();
	int numRows = truncate->ExecuteUpdate("truncate table " + mTempTableName);
	//ASSERT(numRows == 0 || numRows == mArraySize);
	connection->CommitTransaction();
	::QueryPerformanceCounter(&tock);
	mTruncateTableTicks += (tock.QuadPart - tick.QuadPart);
}

void BatchAccountResolution::CopyData(COdbcConnectionHandle& connection)
{
	COdbcStatementPtr truncate = connection->CreateStatement();

  int numRows = truncate->ExecuteUpdate("insert into t_arg_acctres select * from " + mTempTableName);
	// TODO: is it bad to commit here?
	connection->CommitTransaction();
}


void BatchAccountResolution::ResolveBatch(vector<MTautoptr<CMTSessionBase> >& aSessionArray, COdbcConnectionHandle& connection)
{
	MarkRegion region("ResolveBatch");

	vector<bool> resolutionArray;
	resolutionArray.resize(aSessionArray.size(), false);

	TruncateTempTable(connection);

	// use either a BCP or array insert
	if (mUseBcpFlag)
		InsertIntoTempTable(aSessionArray, connection, connection[mBcpInsertToTempTableCommand]);
	else if(TRUE == IsOracle())
		InsertIntoTempTable(aSessionArray, connection, connection[mOracleArrayInsertCommand]);
  else
		InsertIntoTempTable(aSessionArray, connection, connection[mSqlArrayInsertCommand]);
    
	// enter transaction
	if (mTransaction != NULL)
		connection->JoinTransaction(mTransaction);

	// executes the resolution query
	COdbcPreparedResultSetPtr resultSet;
	MarkEnterRegion("ExecuteQuery");
	resultSet = connection[mResolutionQueryCommand]->ExecuteQuery();
	MarkExitRegion("ExecuteQuery");
	
	
	LARGE_INTEGER tick, tock;
	::QueryPerformanceCounter(&tick);

	LARGE_INTEGER resultSetNextTick, resultSetNextTock;
	LARGE_INTEGER corePropertySessionTick, corePropertySessionTock;
	LARGE_INTEGER corePropertyDBTick, corePropertyDBTock;
	LARGE_INTEGER customPropertyTick, customPropertyTock;



	long numResults = 0;

	MarkEnterRegion("RetrieveRows");
	// iterates over each row of results
	while(true)
	{
		long requestID;
		long accountID;
		long usageCycleID;
		long priceListID;
		long payerAccountID;
		wstring strCurrency;

		priceListID = -1;

		// NOTE: this is only used to make the debug message look pretty
		if (mIsOkayToLogDebug) 
		{
			accountID = -1;
			payerAccountID = -1;
			usageCycleID = -1;
		}


		//
    // DATABASE OPERATIONS
    //
		::QueryPerformanceCounter(&resultSetNextTick);
		if (!resultSet->Next())
			break;
		::QueryPerformanceCounter(&resultSetNextTock);
		mResultSetNextTicks += (resultSetNextTock.QuadPart - resultSetNextTick.QuadPart);


		::QueryPerformanceCounter(&corePropertyDBTick);
		// gets the session object indexed by the request id
		requestID = resultSet->GetInteger(1);
		ASSERT(!resultSet->WasNull());

		// gets the account ID property
		if (mAccountIDOutputPropID)
		{
			accountID = resultSet->GetInteger(2);
			ASSERT(!resultSet->WasNull());
		}

		// gets the usage cycle ID property.  This is now the payer's usage cyle
		if (mUsageCycleIDPropID)
		{
			usageCycleID = resultSet->GetInteger(3);
			if(resultSet->WasNull())
      {
        //found no payer, bad. Make account resolution fail for this account
        mBatchFailed = true;
        char buffer[256];
				sprintf(buffer, "Unable to find payer usagecycle for accountID %d (request #%d), perhaps account does not have a valid payer",
										accountID, requestID);
	
				aSessionArray[requestID]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_ACCOUNT_RESOLUTION);
      }
		}

		// sets the price list property
		if (mPriceListIDPropID)
		{
			priceListID = resultSet->GetInteger(4);
			if (resultSet->WasNull())
				priceListID = -1;
		}

		if (mPayingAccountIDPropID)
		{
			payerAccountID = resultSet->GetInteger(5);
			ASSERT(!resultSet->WasNull());
      if (payerAccountID == -1)
      {
        //found a disconnected account, cannot recieve usage, make account resolution fail for this account
        mBatchFailed = true;
        char buffer[256];
				sprintf(buffer, "Unable to resolve paying account for ID %d (request #%d)",
										accountID, requestID);
	
				aSessionArray[requestID]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_ACCOUNT_RESOLUTION);
      }
		}

		if (mAccountStatePropID)
		{
			// TODO: get rid of this copy!
			string strAccountState = resultSet->GetString(6);
			ASSERT(!resultSet->WasNull() && strAccountState.length() > 0);
		}

    if(mCurrencyPropID)
    {
      strCurrency = resultSet->GetWideString(7);
      if(resultSet->WasNull())
      {
        //found a payer with null currency, bad. Make account resolution fail for this account
        mBatchFailed = true;
        char buffer[256];
				sprintf(buffer, "Unable to find payer currency for accountID %d (request #%d), perhaps account does not have a valid payer",
										accountID, requestID);
	
				aSessionArray[requestID]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_ACCOUNT_RESOLUTION);
      }
    }

		::QueryPerformanceCounter(&corePropertyDBTock);
		mCorePropertyDBTicks += (corePropertyDBTock.QuadPart - corePropertyDBTick.QuadPart);



		//
    // SESSION OPERATIONS
    //
		::QueryPerformanceCounter(&corePropertySessionTick);

		CMTSessionBase* session = &aSessionArray[requestID];

		// mark this session as being properly resolved
		resolutionArray[requestID] = true;


		// sets the account ID property
		if (mAccountIDOutputPropID)
			session->SetLongProperty(mAccountIDOutputPropID, accountID);

		// sets the usage cycle ID property
		if (mUsageCycleIDPropID)
			session->SetLongProperty(mUsageCycleIDPropID, usageCycleID);

		// sets the price list property
		if (mPriceListIDPropID)
			session->SetLongProperty(mPriceListIDPropID, priceListID);

		if (mPayingAccountIDPropID)
			session->SetLongProperty(mPayingAccountIDPropID, payerAccountID);

		if (mAccountStatePropID)
		{
			// NOTE: not called out for DB vs session server timing
      // to avoid the extra string construction in the common case
			string strAccountState = resultSet->GetString(6);
			ASSERT(!resultSet->WasNull() && strAccountState.length() > 0);
			session->SetStringProperty(mAccountStatePropID, (wchar_t*)_bstr_t(strAccountState.c_str()));
		}

    if (mCurrencyPropID)
			session->SetStringProperty(mCurrencyPropID, (wchar_t*)_bstr_t(strCurrency.c_str()));

		// since we have a row, then we know this account has been successfully resolved
		if (mAccountResolvedPropID)
			session->SetBoolProperty(mAccountResolvedPropID, true);

		::QueryPerformanceCounter(&corePropertySessionTock);
		mCorePropertySessionTicks += (corePropertySessionTock.QuadPart - corePropertySessionTick.QuadPart);



		//
    // CUSTOM PROPERTY OPERATIONS (DB+SESSION MIX)
    //
		::QueryPerformanceCounter(&customPropertyTick);

		// loops over retrieval properties setting them in session
		PropertyMetadataMap::iterator it;

		// TODO: Remove this hardcoded offset
		int i = 8;
		for (it = mRetrievalMetadata.begin(); it != mRetrievalMetadata.end(); it++, i++) 
		{
			NativePropertyMetadata* retrievalMetadata;
			retrievalMetadata = it->second;

			// NOTE: if the returned column is null, then the property will
			// not be set in session
			switch(retrievalMetadata->GetDataType())
			{
			case PROP_TYPE_STRING:
			{
				const wchar_t* value = resultSet->GetWideStringBuffer(i);
				if (!resultSet->WasNull())
					session->SetStringProperty(it->first, value);
				break;
			}

			case PROP_TYPE_INTEGER:
			{
				int value = resultSet->GetInteger(i);
				if (!resultSet->WasNull())
					session->SetLongProperty(it->first, value);
				break;
			}

			case PROP_TYPE_BIGINTEGER:
			{
				__int64 value = resultSet->GetBigInteger(i);
				if (!resultSet->WasNull())
					session->SetLongLongProperty(it->first, value);
				break;
			}

			case PROP_TYPE_ENUM:
			{
				int value = resultSet->GetInteger(i);
				if (!resultSet->WasNull())
					session->SetEnumProperty(it->first, value);
				break;
			}
				
			case PROP_TYPE_DOUBLE:
			{
				double value = resultSet->GetDouble(i);
				if (!resultSet->WasNull())
					session->SetDoubleProperty(it->first, value);
				break;
			}

			case PROP_TYPE_DECIMAL:
			{
				COdbcDecimal odbcDev = resultSet->GetDecimal(i);

				if (!resultSet->WasNull())
				{
					MTDecimal dec;
					OdbcDecimalToDecimal(odbcDev, &dec);
					session->SetDecimalProperty(it->first, _variant_t(dec));
				}
				break;
			}

			case PROP_TYPE_BOOLEAN:
			{
				std::string str = resultSet->GetString(i);

				if (!resultSet->WasNull())
				{
					bool value;
					if (stricmp(str.c_str(), "1") == 0)
						value = true;
					else
						value = false;
					session->SetBoolProperty(it->first, value);
				}
				break;
			}

			case PROP_TYPE_DATETIME:
			{
				COdbcTimestamp dateOdbc = resultSet->GetTimestamp(i);

				if (!resultSet->WasNull()) 
				{
					DATE value;
					OdbcTimestampToOLEDate(dateOdbc.GetBuffer(), &value);
					session->SetOLEDateProperty(it->first, value);
				}
				break;
			}

			default:
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unknown property data type!");
				ASSERT(0);
				break;
			}
		}


		::QueryPerformanceCounter(&customPropertyTock);
		mCustomPropertyTicks += (customPropertyTock.QuadPart - customPropertyTick.QuadPart);

		if (mIsOkayToLogDebug)
		{
			char buffer[1024];
			sprintf(buffer, "Resolved account: accountID=%d; payingAccountID=%d;  "
							"usageCycleID=%d; priceListID=%d; request_id = %d",
							accountID, payerAccountID, usageCycleID, priceListID,
						  requestID);
			
			//TODO: log account state w/o impacting performance!
			
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
		}

		numResults++;
	}
	MarkExitRegion("RetrieveRows");

	// leave the transaction now that we've read the results
	ASSERT(!resultSet->NextResultSet());
	if (mTransaction != NULL)
		connection->LeaveTransaction();

	// guards against a retrieval property coming from
	// an account view with additional selection criteria
	// that was not correctly setup in the config file
	// TODO: figure out how to do this at init time
	if (numResults > (int) aSessionArray.size())
		MT_THROW_COM_ERROR("More results were resolved than there were requests! Perhaps an AdditionalKey is missing?");

	// enforces that each request has a result (it was resolved)
 	if (numResults < (int) aSessionArray.size())
	{
		for (int i = 0; i < (int) resolutionArray.size(); i++)
		{
			if (!resolutionArray[i])
			{
				// sets the property saying that this account was not resolved
				if (mAccountResolvedPropID)
					aSessionArray[i]->SetBoolProperty(mAccountResolvedPropID, VARIANT_FALSE);

				if (mFailIfNotResolved)
				{
					if (meResolutionMethod == ByAccountID)
					{
						long accountID = aSessionArray[i]->GetLongProperty(mAccountIDPropID);
						
						char buffer[256];
						sprintf(buffer, "Unable to resolve account ID %d (request #%d)",
										accountID, i);
						
						// NOTE: we don't log the string here because the pipeline will do it.  this reduces
						// the amount of duplicate log messages

						aSessionArray[i]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_ACCOUNT_RESOLUTION);
					}
					else if(meResolutionMethod == ByAccountLogin)
					{
						_bstr_t name(aSessionArray[i]->GetStringProperty(mLoginPropID), false);
						_bstr_t space(aSessionArray[i]->GetStringProperty(mNamespacePropID), false);
						
						char buffer[1024];
						sprintf(buffer, "Unable to resolve accountname: %s, namespace: %s (request #%d)",
										(const char *) name, (const char *) space, i);
						
						// NOTE: we don't log the string here because the pipeline will do it.  this reduces
						// the amount of duplicate log messages

						aSessionArray[i]->MarkAsFailed(_bstr_t(buffer), PIPE_ERR_ACCOUNT_RESOLUTION);
					}
  
				}
			}
		}

		if (mFailIfNotResolved)
			MT_THROW_COM_ERROR(PIPE_ERR_SUBSET_OF_BATCH_FAILED,
												 "An account could not be resolved!");
	}
	

	::QueryPerformanceCounter(&tock);
	mTotalFetchTicks += (tock.QuadPart - tick.QuadPart);

	aSessionArray.clear();
}

HRESULT BatchAccountResolution::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	mBatchFailed = FALSE;

  CMTSessionSetBase* pSsBase;
  CMTSessionSet* pSs;
  HRESULT hr;


	hr = aSet->QueryInterface(IID_NULL,(void**)&pSs);
	if(FAILED(hr)) 
  {
    ASSERT(false);
	}
  pSs->GetSessionSet(&pSsBase);
  ASSERT(pSsBase != NULL);

	
	__int64 currentFetchTicks = mTotalFetchTicks;
	LARGE_INTEGER freq, tick, tock;
	::QueryPerformanceFrequency(&freq);
	
	::QueryPerformanceCounter(&tick);
	int totalRecords = 0;

	mResultSetNextTicks = 0;
	mCorePropertySessionTicks = 0;
	mCorePropertyDBTicks = 0;
	mCustomPropertyTicks = 0;

  // Get the ODBC resources from the command
  COdbcConnectionHandle connection(mOdbcManager, mConnectionCommand);
	
	// get the DTC txn to be joined
	// The DTC txn is owned by the MTObjectOwner and shared among all sessions in the session set.
	// if null, no transaction has been started yet.
	MTPipelineLib::IMTTransactionPtr transaction;
	mTransaction = NULL;
	bool first = true;

  vector<MTautoptr<CMTSessionBase> > sessionArray;
  long pos = 0;
  //SetIterator<CMTSessionSetBase*, CMTSession*> it;
  std::auto_ptr<CMTVariantSessionEnumBase> it(pSsBase->get__NewEnum());

  CMTSessionBase* session = NULL;
  //seems like First() is needed
  bool more = true;
  CMTSessionBase* raw = NULL;

  while (more == true)
	{
  	MTautoptr<CMTSessionBase> session;
		if (first)
		{
			first = false;
      CMTSessionBase* raw = NULL;
  
      more = it->First(pos, &raw);
      if (more)
      {
        session = raw;
        // Save the session so we can pass around sets for processing
	      sessionArray.push_back(session);
      }
      else
        break;

      first = false;


			// Get the txn from the first session in the set.
			// don't begin a new transaction unless 
			transaction = GetTransaction(&session);

			if (transaction != NULL)
			{
				ITransactionPtr itrans = transaction->GetTransaction();
				ASSERT(itrans != NULL);
				mTransaction = itrans;
			}
		}
    else
    {
      //BP TODO: if we fail in Next() after addref was done - we leak shared session
      more = it->Next(pos, &raw);
      if(more)
      {
      session = raw;
      // Save the session so we can pass around sets for processing
	    sessionArray.push_back(session);
      }
    }
		totalRecords++;
		if (sessionArray.size() >= (unsigned int) mArraySize)
		{
			ASSERT(sessionArray.size() == (unsigned int) mArraySize);
			ResolveBatch(sessionArray, connection);
		}

	}
	
	// Process any stragglers
	if(sessionArray.size() > 0) 
	{
		ResolveBatch(sessionArray, connection);
	}

	connection->CommitTransaction();
	mTransaction = NULL;

	::QueryPerformanceCounter(&tock);
	
	if (mIsOkayToLogPerf)
	{
		char buf[256];
		long ms = (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution::PlugInProcessSessions for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
		mpStats->SetTiming(SharedStats::ACCT_RES_PROCESS_SESSIONS, ms);
	
		ms = (long) (connection[mResolutionQueryCommand]->GetTotalExecuteMillis() - mTotalMillis);
		mTotalMillis = connection[mResolutionQueryCommand]->GetTotalExecuteMillis();
		sprintf(buf, "BatchAccountResolution::SQLExecute for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
		mpStats->SetTiming(SharedStats::ACCT_RES_SQL_EXECUTE, ms);
	
		ms = (long) ((1000*(mTotalFetchTicks - currentFetchTicks))/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution fetch for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
		mpStats->SetTiming(SharedStats::ACCT_RES_FETCH, ms);



		ms = (long) ((1000*mResultSetNextTicks)/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution ResultSetNext for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));

		ms = (long) ((1000*mCorePropertyDBTicks)/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution CorePropertyDB retrieval for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));

		ms = (long) ((1000*mCorePropertySessionTicks)/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution CorePropertySession setting for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));

		ms = (long) ((1000*mCustomPropertyTicks)/freq.QuadPart);
		sprintf(buf, "BatchAccountResolution CustomProperty retrieval and setting for %d records took %d ms", totalRecords, ms);
		mPerfLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,_bstr_t(buf));
	}


	if (mBatchFailed)
		return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	return S_OK;
}


template<class T>
void BatchAccountResolution::InsertIntoTempTable(vector<MTautoptr<CMTSessionBase> >& aSessionArray,
                                                 COdbcConnectionHandle& connection,
																								 T arStatement)
{
	MarkRegion region("InsertIntoTempTable");

	LARGE_INTEGER tick,tock;
	::QueryPerformanceCounter(&tick);
	unsigned int i;
	
	std::wstring login;
	std::wstring acctNamespace;
  std::wstring EndpointID;
  std::wstring EndpointNamespace;
  std::wstring CorporateID;
  std::wstring CorporateNamespace;

	int accountID;

  vector<MTautoptr<CMTSessionBase> >::const_iterator sessionIt;
  for (sessionIt = aSessionArray.begin(), i=0;

			 sessionIt != aSessionArray.end();
			 sessionIt++, i++)
	{
    CMTSessionBase* session = (CMTSessionBase*)&(*sessionIt);

		// request ID (internal ID used to match up responses)
		arStatement->SetInteger(1, (long) i);

		// always set the timestamp; this value is used regardless of 
		// whether we are resolving by ID or by name
		TIMESTAMP_STRUCT refTimeStamp;
		_variant_t sessionTimestamp;
		try
		{
			sessionTimestamp = session->GetOLEDateProperty(mTimestampID);
			DATE pDate = sessionTimestamp;
			OLEDateToOdbcTimestamp(&pDate,&refTimeStamp);

		}
		catch(_com_error& e) {
			_bstr_t buffer = "The Timestamp property is required!";
			mBatchFailed = TRUE;
			session->MarkAsFailed(buffer, e.Error());
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
			continue;
		}
    catch(MTException& e) 
    {
			_bstr_t buffer = "The Timestamp property is required!";
			mBatchFailed = TRUE;
			session->MarkAsFailed(buffer, (HRESULT)e);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
			continue;
		}
		arStatement->SetDatetime(5,refTimeStamp);


		if(meResolutionMethod == ByAccountID)
		{
			// gets the account ID property
			try
			{
				accountID = session->GetLongProperty(mAccountIDPropID);
			}
			catch(_com_error& e)
			{
				_bstr_t buffer = "The AccountID property is required when resolving by account ID!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, e.Error());
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
				continue;
			}
      catch(MTException& e) 
      {
			  _bstr_t buffer = "The AccountID property is required when resolving by account ID!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, (HRESULT)e);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
				continue;
		  }
		

			arStatement->SetInteger(4, accountID);
		}
		else if(meResolutionMethod == ByAccountLogin)
		{

			// gets the login name property
			try
			{
        _bstr_t tmp(session->GetStringProperty(mLoginPropID), false);
				login = (const WCHAR *) tmp;
			}
			catch(_com_error& e)
			{
				_bstr_t buffer = "The Login property is required when resolving by account login!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, e.Error());
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const WCHAR *) buffer);
				continue;
			}
      catch(MTException& e) 
      {
			  _bstr_t buffer = "The Login property is required when resolving by account login!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, (HRESULT)e);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const WCHAR *) buffer);
				continue;
		  }

			// gets the namespace property
			try
			{
        _bstr_t tmp(session->GetStringProperty(mNamespacePropID), false);
				acctNamespace = (const WCHAR *) tmp;
			}
			catch(_com_error& e)
			{
				_bstr_t buffer = "The Namespace property is required when resolving by account login!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, e.Error());
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
				continue;
			}
      catch(MTException& e) 
      {
			  _bstr_t buffer = "The Namespace property is required when resolving by account login!";
				mBatchFailed = TRUE;
				session->MarkAsFailed(buffer, (HRESULT)e);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, (const char*) buffer);
				continue;
		  }

			arStatement->SetWideString(2, login);
			arStatement->SetWideString(3, acctNamespace);

		}
 
    

		// loops over additional key properties and adds them to the temp table
		PropertyMetadataMap::iterator it;
		// TODO: remove this hardcoded offset
		int column = 6;
		wstring keyDebugInfo;
		for (it = mKeyMetadata.begin(); it != mKeyMetadata.end(); it++, column++) 
		{
			NativePropertyMetadata* keyMetadata;
			keyMetadata = it->second;

			if (mIsOkayToLogDebug)
				keyDebugInfo += L"; ";
				
			switch(keyMetadata->GetDataType())
			{
			case PROP_TYPE_STRING:
			{
				_bstr_t value(session->GetStringProperty(it->first), false);
				arStatement->SetString(column, (const char*) value);

				if (mIsOkayToLogDebug)
					keyDebugInfo += keyMetadata->GetName() + wstring(L" = ") + (const wchar_t*) value;

				break;
			}

			case PROP_TYPE_INTEGER:
			{
				int value = session->GetLongProperty(it->first);
				arStatement->SetInteger(column, value);
				if (mIsOkayToLogDebug)
				{
					wchar_t buffer[256];
					swprintf(buffer, L"%s = %d", keyMetadata->GetName(), value);
					keyDebugInfo += buffer;
				}
				break;
			}

			case PROP_TYPE_BIGINTEGER:
			{
				__int64 value = session->GetLongLongProperty(it->first);
				arStatement->SetBigInteger(column, value);
				if (mIsOkayToLogDebug)
				{
					wchar_t buffer[256];
					swprintf(buffer, L"%s = %I64d", keyMetadata->GetName(), value);
					keyDebugInfo += buffer;
				}
				break;
			}

			case PROP_TYPE_ENUM:
			{
				int value = session->GetEnumProperty(it->first);
				arStatement->SetInteger(column, value);
				if (mIsOkayToLogDebug)
				{
					wchar_t buffer[256];
					swprintf(buffer, L"%s = %d", keyMetadata->GetName(), value);
					keyDebugInfo += buffer;
				}
				break;
			}
				
			case PROP_TYPE_DOUBLE:
			{
				double value = session->GetDoubleProperty(it->first);
				arStatement->SetDouble(column, value);
				if (mIsOkayToLogDebug)
				{
					wchar_t buffer[256];
					swprintf(buffer, L"%s = %f", keyMetadata->GetName(), value);
					keyDebugInfo += buffer;
				}
				break;
			}

			case PROP_TYPE_DECIMAL:
			{
				//TODO: implement me 
				ASSERT(0);
				break;
			}

			case PROP_TYPE_BOOLEAN:
			{
				VARIANT_BOOL value;
				value = session->GetBoolProperty(it->first);

				_bstr_t str;
				if (value == VARIANT_TRUE)
					str = "1";
				else
					str = "0";
				arStatement->SetString(column, (const char *) str);

				if (mIsOkayToLogDebug)
					keyDebugInfo += keyMetadata->GetName() + wstring(L" = ") + (const wchar_t *) str;

				break;
			}

			case PROP_TYPE_DATETIME:
			{
				DATE value;
				value = session->GetOLEDateProperty(it->first);

				TIMESTAMP_STRUCT dateODBC;
				OLEDateToOdbcTimestamp(&value, &dateODBC);

				arStatement->SetDatetime(column, dateODBC);

				if (mIsOkayToLogDebug)
				{
					// formats the timestamp
					BSTR bstrVal;
					HRESULT hr = VarBstrFromDate(value, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
					_bstr_t timeBuffer(bstrVal);
					
					keyDebugInfo += keyMetadata->GetName() + wstring(L" = ") + (const wchar_t *) timeBuffer;
				}

				break;
			}

			default:
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unknown property data type!");
				ASSERT(0);
				break;
			}
		}


		if (mIsOkayToLogDebug)
		{
			wchar_t buffer[1024];
			_variant_t timestampVar((double) sessionTimestamp, VT_DATE);
      if(meResolutionMethod == ByAccountID)
				swprintf(buffer, L"Resolving account based on: account_id = %d; request_id = %d, timestamp = %s", 
								accountID, i, (const wchar_t *) (_bstr_t) timestampVar);
			
      else if(meResolutionMethod == ByAccountLogin)
				swprintf(buffer, L"Resolving account based on: account name = '%s'; namespace = '%s'; request_id = %d, timestamp = %s",
								login.c_str(), acctNamespace.c_str(), i, (const wchar_t *) (_bstr_t) timestampVar);

			wstring message = buffer + keyDebugInfo;
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, message.c_str());
		}

		arStatement->AddBatch();
	}

	// Insert the records to the temp table
	arStatement->ExecuteBatch();

	connection->CommitTransaction();

	::QueryPerformanceCounter(&tock);
	mInsertTempTableTicks += (tock.QuadPart - tick.QuadPart);
}
MTPipelineLib::IMTTransactionPtr BatchAccountResolution::GetTransaction(CMTSessionBase* aSession)
{
	// has a transaction already been started?
  // Take care not AddRef when attaching to raw COM pointer.
	MTPipelineLib::IMTTransactionPtr tran(aSession->GetTransaction(false), false);

	if (tran != NULL)
	{
		// yes
		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// is the transaction ID set in the session?  If so we're working on
	// an external transaction
	_bstr_t txnID = aSession->GetTransactionID();
	if (txnID.length() > 0)
	{
		// join the transaction
		tran = aSession->GetTransaction(true);

		ITransactionPtr itrans = tran->GetTransaction();
		if (itrans != NULL)
			return tran;
		else
			return NULL;
	}

	// no transaction
	return NULL;
}
