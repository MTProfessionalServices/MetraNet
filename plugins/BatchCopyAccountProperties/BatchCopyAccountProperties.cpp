/**************************************************************************
 * Copyright 2004 by MetraTech Corporation
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
 ***************************************************************************/

/***************************************************************************
 * BatchCopyAccountProperties.cpp                                               *
 * Implementation of plugin for copying properties from one account or     *
 * template to another account.                                            *
 ***************************************************************************/
#include "BatchCopyAccountProperties.h"

// Imports.
#import <MTEnumConfig.tlb>

// Constanst used to identify columnd in temp table.
// Column ID's start with 1
const char* DEST_ACCT_ID_COL_NAME = "dest_acc_id";
const int DESTINATION_ACCOUNT_COLUMN_ID = 1;
const int PROPERTY_COLUMN_ID = DESTINATION_ACCOUNT_COLUMN_ID + 1;

/***************************************************************************
 * PlugInConfigure                                                         *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::BatchPlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																  MTPipelineLib::IMTNameIDPtr aNameID,
																  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	try
	{
		// Members
		mNameID = aNameID;
		mSysContext = aSysContext;
		
		// Get queries used to get/set audit id.
		mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		mQueryAdapter->Init("queries\\AccountCreation");

		// Is BCP enabled?
		if (aPropSet->NextMatches(L"usebcpflag", MTPipelineLib::PROP_TYPE_BOOLEAN))
			mUseBcpFlag = aPropSet->NextBoolWithName(L"usebcpflag") == VARIANT_TRUE;
		else
			mUseBcpFlag = true;

		if (IsOracle())
		{
			// Never use BCP with Oracle.
			mUseBcpFlag = false;
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (Oracle detected)");
		}
		else 
		{
			if (mUseBcpFlag)
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface enabled (usebcpflag is TRUE)");
			else
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "BCP interface disabled (usebcpflag is FALSE)");
		}

		// What is the batch size?
		// Allow the user to set size of batches/arrays.
		if (aPropSet->NextMatches(L"batch_size", MTPipelineLib::PROP_TYPE_INTEGER))
			mArraySize = aPropSet->NextLongWithName("batch_size");
		else
			mArraySize = DEFAULT_BCP_BATCH_SIZE;

		//-----
		// Get data destination account id. This could be in the destination file or can be set by
		// the Account Resolution plug-in. In either case the value is required for this plugin to work.
		//-----
		if (aPropSet->NextMatches(L"DestinationAccountID", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
			mlngDestinationPropID = aNameID->GetNameID(aPropSet->NextStringWithName(L"DestinationAccountID"));
		else
			return Error("Failed to get DestinationAccountID property id");

		char tmpBuf[128];
		sprintf(tmpBuf, "BatchCopyAccountProperties will use a batch size of %d", mArraySize);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, tmpBuf);

		// Now get the properties to copy
		MTPipelineLib::IMTConfigPropSetPtr spPropertiesSet = aPropSet->NextSetWithName(L"Properties");
		if (spPropertiesSet != NULL)
		{
			MTPipelineLib::IMTConfigPropSetPtr spPropertySet;
			MTPipelineLib::IMTConfigPropPtr spProp;
			MTExtensionNameMap::iterator iIterator;

			// Iterate through all the properties in this set.
			_bstr_t currentExtension;
			_bstr_t bstrTemp;
			spPropertySet = spPropertiesSet->NextSetWithName(L"Property");
			while (spPropertySet != NULL)
			{
				std::auto_ptr<MTCopyProperty> pCopyProp(new MTCopyProperty);

				// Get the type
				bstrTemp = spPropertySet->NextStringWithName(L"Type");

				if(stricmp(bstrTemp, "Session") == 0)
					pCopyProp->PropType = COPY_PROP_TYPE_SESSION;
				else
				{
					char buffer[1024];
					sprintf(buffer, "An unknown type [%s] was specified for a property.", (const char *) bstrTemp);
					return Error(buffer);
				}

				// Default property to be not required
				pCopyProp->Required = false;

				// If gettting session properties, check if the properties are required or not
				if (pCopyProp->PropType == COPY_PROP_TYPE_SESSION && 
					spPropertySet->NextMatches(L"Required", MTPipelineLib::PROP_TYPE_BOOLEAN) &&
					spPropertySet->NextBoolWithName(L"Required") == VARIANT_TRUE)
					pCopyProp->Required = true;

				// Get the source property name
				pCopyProp->SourceProperty = spPropertySet->NextStringWithName(L"SourceProperty");

				// If getting values from extension, get the source extension
				if (spPropertySet->NextMatches(L"DestinationProperty", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
					pCopyProp->DestinationProperty = spPropertySet->NextStringWithName(L"DestinationProperty");
				else
					return Error("The destination property is required when copying session or template properties.");

				if (spPropertySet->NextMatches(L"DestinationExtension", MTPipelineLib::PROP_TYPE_STRING) == VARIANT_TRUE)
					pCopyProp->DestinationExtension = spPropertySet->NextStringWithName(L"DestinationExtension");
				else
					return Error("The destination extension is required when copying session or template properties.");

				// Part of key
				if (spPropertySet->NextMatches(L"PartOfKey", MTPipelineLib::PROP_TYPE_BOOLEAN) == VARIANT_TRUE)
				{
					if (spPropertySet->NextBoolWithName(L"PartOfKey") == VARIANT_TRUE)
						pCopyProp->PartOfKey = true;
					else
						pCopyProp->PartOfKey = false;
				}
				else
					pCopyProp->PartOfKey = false;

				// See if the extension needs to be added to the map
				iIterator = mDestExtensions.find(pCopyProp->DestinationExtension);
				if (iIterator == mDestExtensions.end())
				{
					mDestExtensions.insert(MTExtensionNameMap::value_type(pCopyProp->DestinationExtension, pCopyProp->DestinationExtension));
				}

				char buffer[1024];
				sprintf(buffer, "Adding property to copy:  %s [%s] --> %s [%s]", 
						(const char *)pCopyProp->SourceProperty, (const char *)pCopyProp->SourceExtension,
						(const char *)pCopyProp->DestinationProperty, (const char *)pCopyProp->DestinationExtension);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

				// Add the property to the vector.
				// Note that the CopyProp is released.
				mCopyProperties.push_back(pCopyProp.release());

				// Get the next property set.
				spPropertySet = spPropertiesSet->NextSetWithName(L"Property");
			}
		}
		else
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "[BatchCopyAccountProperties] -- No properties specified for copying.");
		}

		// Build meta data maps.
		_bstr_t bstrExtension;
		MTExtensionNameMap::iterator iNameIterator;
		MTPropertyNameVector::iterator iPropertyIterator;
		MTACCOUNTLib::IMTAccountAdapterPtr spAccountAdapter(MTPROGID_MTACCOUNTSERVER);
		for (iNameIterator = mDestExtensions.begin(); iNameIterator != mDestExtensions.end(); ++iNameIterator)
		{
			bstrExtension = iNameIterator->second;

			// Initialize account adapter for current extension.
			spAccountAdapter->Initialize(bstrExtension);

			// Create a properties map for current extension.
			PropertyMetadataMap* pPropertyMetaData = new PropertyMetadataMap;
			mExtensionPropertiesMap[bstrExtension] = pPropertyMetaData;

			// Loop through all the properties for current extension.
			for (iPropertyIterator = mCopyProperties.begin(); iPropertyIterator != mCopyProperties.end(); ++iPropertyIterator)
			{
				MTCopyProperty* pCopyProp = *iPropertyIterator;

				if (bstrExtension == pCopyProp->DestinationExtension)
				{     
					// Get the property metadata and set in map.
					int nPropertyID = mNameID->GetNameID(pCopyProp->DestinationProperty);
					(*pPropertyMetaData)[nPropertyID] = spAccountAdapter->GetPropertyMetaData(pCopyProp->DestinationProperty);
				}
			}
		}

		// Create a unique name based on the stage name and plug-in name
		mTagName = GetTagName(aSysContext);
	}
	catch(_com_error & e)
	{
		char buffer[1024];
		sprintf(buffer, "An exception was thrown while parsing the config file: %x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
	}

	// Setup connections to databases.
	// NetMeter:
	COdbcConnectionInfo NetmeterDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");

	// NetMeterStage:
	COdbcConnectionInfo stageDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
	COdbcConnectionInfo tmpNetmeterDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
	tmpNetmeterDBInfo.SetCatalog(stageDBInfo.GetCatalog().c_str());

 	//-----
	// Dynamically generates queries. Queries used to create temp table and to
	// copy from temp table to destination tables.
	//-----
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Dynamicly generating queries...");
	HRESULT hr = GenerateQueries(NetmeterDBInfo, stageDBInfo);
	if (FAILED(hr))
		return hr;

	// Prepare temp table insert query.
  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;
	if (mUseBcpFlag)
	{
		//-----
		// use minimally logged inserts.
		// TODO: this may only matter if database recovery model settings are correct.
		//       however, it won't hurt if they're not
		//-----
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);

		// Get object to use for bulk copy.
		mBcpInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedBcpStatementCommand>(
      new COdbcPreparedBcpStatementCommand(mTmpTableName, hints));
    bcpStatements.push_back(mBcpInsertToTmpTableStmtCommand);
	} 
	else
	{
		// Get object to use for array insertion.
		if (IsOracle())
    {
			mOracleArrayInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedInsertStatementCommand>(
        new COdbcPreparedInsertStatementCommand(mTmpTableName, mArraySize, true));
      insertStatements.push_back(mOracleArrayInsertToTmpTableStmtCommand);
    }
		else
    {
			mSqlArrayInsertToTmpTableStmtCommand = boost::shared_ptr<COdbcPreparedArrayStatementCommand>(
        new COdbcPreparedArrayStatementCommand(mstrInsertIntoTempTableSQL, mArraySize, true));
      arrayStatements.push_back(mSqlArrayInsertToTmpTableStmtCommand);
    }
	}

	mNetMeterDbConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(NetmeterDBInfo,
                               COdbcConnectionCommand::TXN_AUTO,
                               false));
  mOdbcManager->RegisterResourceTree(mNetMeterDbConnectionCommand);
	mStageDbBcpConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(tmpNetmeterDBInfo,
                               COdbcConnectionCommand::TXN_AUTO,
                               bcpStatements.size() > 0,
                               bcpStatements,
                               arrayStatements,
                               insertStatements));
  mOdbcManager->RegisterResourceTree(mStageDbBcpConnectionCommand);

	return S_OK;
}

/***************************************************************************
 * BatchPlugInInitializeDatabase                                           *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::BatchPlugInInitializeDatabase()
{
	// This plug-in writes to the database so we should not allow retry.
	AllowRetryOnDatabaseFailure(FALSE);

	if (true)//!IsOracle())
	{
		// Make sure our "temporary" table exists and is empty.
    COdbcConnectionInfo stageDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
    COdbcConnectionInfo tmpNetmeterDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeter");
    tmpNetmeterDBInfo.SetCatalog(stageDBInfo.GetCatalog().c_str());
    COdbcConnectionPtr conn(new COdbcConnection(tmpNetmeterDBInfo));
		COdbcStatementPtr createTmpTableStmt = conn->CreateStatement();
		createTmpTableStmt->ExecuteUpdate(mstrCreateTempTableSQL);
    conn->CommitTransaction();
	}

	return S_OK;
}

/***************************************************************************
 * BatchPlugInShutdownDatabase                                             *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::BatchPlugInShutdownDatabase()
{
  mOdbcManager->Reinitialize(mNetMeterDbConnectionCommand);
  mOdbcManager->Reinitialize(mStageDbBcpConnectionCommand);
	return S_OK;
}

/***************************************************************************
 * BatchPlugInProcessSessions                                              *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::BatchPlugInProcessSessions(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr)
{
  COdbcConnectionHandle netMeterDbConnection(mOdbcManager, mNetMeterDbConnectionCommand);

	// Gte the session set iterator.
	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSessionSetPtr);
	if (FAILED(hr))
		return hr;

  mbSessionsFailed = false;

	// If there are any sessions, enter into a transaction.
	ITransactionPtr pITransaction;
	MTPipelineLib::IMTSessionPtr curSession = it.GetNext();
	if (curSession)
	{
		MTPipelineLib::IMTTransactionPtr pMTTransaction;

		// Get the txn from the first session in the set.
		pMTTransaction = GetTransaction(curSession);
		if (pMTTransaction != NULL)
		{
			pITransaction = pMTTransaction->GetTransaction();
			ASSERT(pITransaction != NULL);

			netMeterDbConnection->JoinTransaction(pITransaction);
		}
	}

	// Loop through all the sessions in set.
	// Process entire session set in chunck of size mArraySize.
	vector<MTPipelineLib::IMTSessionPtr> sessionArray;
	while (curSession != NULL)
	{
		sessionArray.push_back(curSession);

		// Resolves a chunk of sessions.
		if (sessionArray.size() >= (unsigned int) mArraySize)
		{
			ASSERT(sessionArray.size() == (unsigned int) mArraySize);

			hr = ResolveBatch(sessionArray, netMeterDbConnection);
			if (FAILED(hr))
				return hr;

			sessionArray.clear();
		}

		// Get the next session.
		curSession = it.GetNext();
	}

	// Resolves the last partial chunk if necessary
	if (sessionArray.size() > 0)
	{
		hr = ResolveBatch(sessionArray, netMeterDbConnection);
		if (FAILED(hr))
			return hr;
	}

	// Leave transaction.
	if (pITransaction != NULL)
		netMeterDbConnection->LeaveTransaction();

  if (mbSessionsFailed)
    return PIPE_ERR_SUBSET_OF_BATCH_FAILED;

	return S_OK;
}

/***************************************************************************
 * BatchPlugInShutdown                                                     *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::BatchPlugInShutdown()
{
	// Free property meta data maps.
	ExtensionPropertiesMap::iterator it;
	for (it = mExtensionPropertiesMap.begin(); it != mExtensionPropertiesMap.end(); ++it) 
	{
		PropertyMetadataMap* pMetadataMap = it->second;
		if (pMetadataMap)
			delete pMetadataMap;
	}

	// Delete the objects in the Copy Properties vector
	MTCopyProperty *pCopyProp;
	for (unsigned int i = 0; i < mCopyProperties.size(); ++i)
	{
		pCopyProp = mCopyProperties.at(i);
		delete pCopyProp;
		pCopyProp = NULL;
	}

  return S_OK;
}

/***************************************************************************
 * GenerateQueries						                                   *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::GenerateQueries(COdbcConnectionInfo& NetMeterDBInfo,
															 COdbcConnectionInfo& stageDBInfo)
{
  // Create temp table names.
  MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  string schemaDots = mQueryAdapter->GetSchemaDots();

  // Make unique name.
  mTmpTableName = nameHash->GetDBNameHash(("tmp_copy_acct_props_" + mTagName).c_str());
  // Fully qualified name.
  mTmpTableFullName = stageDBInfo.GetCatalog() + schemaDots + mTmpTableName;

  // Get temp table truncate query
	mQueryAdapter->ClearQuery();
	mQueryAdapter->SetQueryTag("__TRUNCATE_TEMP_TABLE__");
	mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableFullName.c_str());
	mstrTruncateTmpTableSQL = mQueryAdapter->GetQuery();


	// Fixed portion of insert into temp table query.
	string strValuesSQL = " VALUES (?";
	mstrInsertIntoTempTableSQL = "insert into " + mTmpTableFullName + " (";

	// Fixed portion of create table query.
  // Get temp table truncate query
	mQueryAdapter->ClearQuery();
	mQueryAdapter->SetQueryTag("__CREATE_BATCHCOPYPROPS_TEMP_TABLE__");
	mQueryAdapter->AddParam("%%TMP_TABLE_NAME%%", mTmpTableFullName.c_str());
  mstrCreateTempTableSQL = mQueryAdapter->GetQuery();

  // Fixed portion of the insert/update where clause.
  char szTmpBuffer[1024];

	string strFixedPartWhereClause;
	sprintf(szTmpBuffer, "WHERE src.%s IS NOT NULL", DEST_ACCT_ID_COL_NAME);
	strFixedPartWhereClause = szTmpBuffer;

	//-----
	// Dynamic portion of create table query.
	// NOTE: source and destination column ID must be in the following order.
	// Add destination account id column: DESTINATION_ACCOUNT_COLUMN_ID
	//-----
  if(!IsOracle())
  {
	  mstrCreateTempTableSQL += "([";
	  mstrCreateTempTableSQL += DEST_ACCT_ID_COL_NAME;
	  mstrCreateTempTableSQL += "] [int] NULL";
  }
  else
  {
    mstrCreateTempTableSQL += "(";
	  mstrCreateTempTableSQL += DEST_ACCT_ID_COL_NAME;
	  mstrCreateTempTableSQL += " NUMBER(10) NULL";
  }
	
	mstrInsertIntoTempTableSQL += DEST_ACCT_ID_COL_NAME;

	// Loop throught all extensions.
	MTPropertyNameVector::iterator iPropertyIterator;
	MTExtensionNameMap::iterator iNameIterator;
	int nColumnIndex = PROPERTY_COLUMN_ID;
	for (iNameIterator = mDestExtensions.begin(); iNameIterator != mDestExtensions.end(); ++iNameIterator)
	{
		// Get the property meta data map for current extension.
		_bstr_t bstrExtension = iNameIterator->second;
		PropertyMetadataMap* pPropertyMetaDataMap = mExtensionPropertiesMap[bstrExtension];

		// Collect this information to construct an insert or update query.
		_bstr_t bstrTargetTableName;
		string strSrcColumnList = DEST_ACCT_ID_COL_NAME;
		string strDestColumnList = "id_acc";
		string strUpdateColumnList;
		string strKeyPartWhereClause;
		string strSkipRecordsPartWhereClause;
    //For Oracle only, due to the fact that
    //we have to structure update clause differently
    string strSelectColumnList;

		// Loop through all the properties.
		char szProperty[512];
		for (iPropertyIterator = mCopyProperties.begin(); iPropertyIterator != mCopyProperties.end(); ++iPropertyIterator)
		{
			MTCopyProperty* pCopyProp = *iPropertyIterator;

			// Check if the property belongs to the current extension.
			if (bstrExtension != pCopyProp->DestinationExtension)
				continue; // process later.

			// Get the property meta data.
			long lDestPropID = mNameID->GetNameID(pCopyProp->DestinationProperty);
			PropertyMetadataMap::iterator itPropertyMetaData = pPropertyMetaDataMap->find(lDestPropID);
			MTACCOUNTLib::IMTPropertyMetaDataPtr pPropertyMetaData = itPropertyMetaData->second;

			// Get the table name for current extension.
			if (bstrTargetTableName.length() == 0)
				bstrTargetTableName = pPropertyMetaData->GetDBTableName();

			// Generate a unique temp table column name for current property.
			sprintf(szTmpBuffer, "%s%d", (const char *) bstrExtension, nColumnIndex++);
			string strTempTableColumnName = szTmpBuffer;

			// Get destination column name.
			_bstr_t bstrTargetColumnName = pPropertyMetaData->GetDBColumnName();

			// Add the property type to create table SQL.
			string strInsertEmptyStringCase;
			string strUpdateEmptyStringCase;
			switch (pPropertyMetaData->GetDataType())
			{
				case MTACCOUNTLib::PROP_TYPE_STRING:
				{
          if(!IsOracle())
          {
					  sprintf(szProperty, "[%s] [nvarchar] (%d) NULL",
							    strTempTableColumnName.c_str(),	255);
          }
          else
            sprintf(szProperty, "%s nvarchar2 (%d) NULL",
							    strTempTableColumnName.c_str(),	255);

					//----- Empty strings must be represented in our database as NULL.
					// Insert case:
          //BP: On Oracle '' is NULL, so those are redundant
          if(!IsOracle())
          {
					  strInsertEmptyStringCase = "CASE WHEN " + strTempTableColumnName;
					  strInsertEmptyStringCase +=	"='' THEN NULL ELSE " + strTempTableColumnName + " END";
  					// Update case:
	  				strUpdateEmptyStringCase = ("CASE WHEN src." + strTempTableColumnName);
		  			strUpdateEmptyStringCase += ("='' THEN NULL ELSE src." + strTempTableColumnName + " END");
          }
			  	break;
				}

				case MTACCOUNTLib::PROP_TYPE_DATETIME:
				{
          if(!IsOracle())
          {
					  sprintf(szProperty, "[%s] [datetime] NULL",	strTempTableColumnName.c_str());
          }
          else
            sprintf(szProperty, "%s date NULL",	strTempTableColumnName.c_str());
					break;
				}

				case MTACCOUNTLib::PROP_TYPE_ENUM:
				case MTACCOUNTLib::PROP_TYPE_TIME:
				case MTACCOUNTLib::PROP_TYPE_INTEGER:
				{
          if(!IsOracle())
          {
					  sprintf(szProperty, "[%s] [int] NULL", strTempTableColumnName.c_str());
          }
          else
            sprintf(szProperty, "%s number(10, 0) NULL", strTempTableColumnName.c_str());
					break;
				}

				case MTACCOUNTLib::PROP_TYPE_BIGINTEGER:
				{
          if(!IsOracle())
          {
  					sprintf(szProperty, "[%s] [bigint] NULL", strTempTableColumnName.c_str());
          }
          else
            sprintf(szProperty, "%s number(37) NULL", strTempTableColumnName.c_str());
					break;
				}

				case MTACCOUNTLib::PROP_TYPE_BOOLEAN:
				{
         if(!IsOracle())
         {
					sprintf(szProperty, "[%s] [varchar] (1) NULL", strTempTableColumnName.c_str());
         }
         else
           sprintf(szProperty, "%s varchar2(1) NULL", strTempTableColumnName.c_str());
					break;
				}

				case MTACCOUNTLib::PROP_TYPE_DOUBLE:
				case MTACCOUNTLib::PROP_TYPE_DECIMAL:
				{
          if(!IsOracle())
          {
					  sprintf(szProperty, "[%s] [numeric] (%s,%s) NULL",
                    strTempTableColumnName.c_str(), 
                    METRANET_PRECISION_MAX_STR,
                    METRANET_SCALE_MAX_STR);
          }
          else
          {
            sprintf(szProperty, "%s number(%s,%s) NULL",
                    strTempTableColumnName.c_str(),
                    METRANET_PRECISION_MAX_STR,
                    METRANET_SCALE_MAX_STR);
          }
					break;
				}

				default:
				{
					char buffer[1024];
					sprintf(buffer, "An unsupported or unknown proptype was found: %d.", pPropertyMetaData->GetDataType());
					return Error(buffer);
				}
			} // end switch

			// Add property to SQL that creates the temp table.
			mstrCreateTempTableSQL += ",";
			mstrCreateTempTableSQL += szProperty;

			// Insert into temp table SQL.
			mstrInsertIntoTempTableSQL += ",";
			mstrInsertIntoTempTableSQL += strTempTableColumnName;
			strValuesSQL += ",?";

			//-----
			// The following is used to construct insert and update SQL.
			//-----

			// Add to properties to source and destination lists.
			strSrcColumnList += ",";
			if (strInsertEmptyStringCase.length())
				strSrcColumnList += strInsertEmptyStringCase;
			else
				strSrcColumnList += strTempTableColumnName;

			strDestColumnList += ",";
			strDestColumnList += bstrTargetColumnName;
			
			if (strUpdateColumnList.length())
				strUpdateColumnList += ",";
			strUpdateColumnList += bstrTargetColumnName;
      if(!IsOracle())
      {
			  strUpdateColumnList += ("=CASE WHEN src." + strTempTableColumnName);
			  strUpdateColumnList += (" IS NULL THEN dest." + bstrTargetColumnName);
        // If we have the string exception string, then add it
			  if (strUpdateEmptyStringCase.length())
				  strUpdateColumnList += (" ELSE " + strUpdateEmptyStringCase + " END");
			  else
				  strUpdateColumnList += (" ELSE src." + strTempTableColumnName +  " END");
      }
      else
      {
        if (strSelectColumnList.length())
			  	strSelectColumnList += ",";
        strSelectColumnList += "NVL(src." + strTempTableColumnName + ", dest.";
        strSelectColumnList += bstrTargetColumnName + ")\n";
      }

			

			// Add to where clause if this property is part of key.
			if (pCopyProp->PartOfKey)
			{
				// Add to key where clause
				sprintf(szTmpBuffer, " AND dest.%s = src.%s", (const char *) bstrTargetColumnName, strTempTableColumnName.c_str());
				strKeyPartWhereClause += szTmpBuffer;

				sprintf(szTmpBuffer, " AND src.%s IS NOT NULL", strTempTableColumnName.c_str());
				strFixedPartWhereClause += szTmpBuffer;
			}
			else
			{
				if (strSkipRecordsPartWhereClause.length())
					sprintf(szTmpBuffer, " OR src.%s IS NOT NULL", strTempTableColumnName.c_str());
				else
					sprintf(szTmpBuffer, " AND (src.%s IS NOT NULL", strTempTableColumnName.c_str());

				strSkipRecordsPartWhereClause += szTmpBuffer;
			}
		}

		//
		strSkipRecordsPartWhereClause += ")";

		/******
		 * Prepare insert query; sample Insert query:
		 *		INSERT INTO NetMeter..testA(id_acc,col1,col2,col3)
	     *		SELECT dest_acct_id, CASE WHEN head1='' THEN NULL ELSE head1 END,
         *							 CASE WHEN head2='' THEN NULL ELSE head2 END,
		 *							 CASE WHEN headN='' THEN NULL ELSE headN END,
		 *		FROM NetMeterStage..tmpTable src
		 *		WHERE src.dest_acct_id IS NOT NULL AND
		 *		(src.1 IS NOT NULL OR src.2 IS NOT NULL OR src.N IS NOT NULL)
		 *		AND src.dest_acct_id IS NOT NULL AND NOT EXISTS
		 *		(SELECT 1 FROM NetMeter..testA dest
		 *		WHERE (dest.id_acc = src.dest_acct_id
		 *		AND dest.key2 = src.key2
		 *		AND dest.keyN = src.keyN))
		 *****/
		string strInsertFromTempTableSQL = "";
		mQueryAdapter->ClearQuery();
		mQueryAdapter->SetQueryTag("__INSERT_INTO_ACCVIEW_TABLE__");
		mQueryAdapter->AddParam("%%NETMETER%%", NetMeterDBInfo.GetCatalog().c_str());
		mQueryAdapter->AddParam("%%TARGET_TABLE%%", bstrTargetTableName);
		mQueryAdapter->AddParam("%%DESTCOLUMNLIST%%", strDestColumnList.c_str());
		mQueryAdapter->AddParam("%%SRCCOLUMNLIST%%", strSrcColumnList.c_str());
		mQueryAdapter->AddParam("%%STAGING%%", stageDBInfo.GetCatalog().c_str());
		mQueryAdapter->AddParam("%%TEMP_TABLE%%", mTmpTableName.c_str());
		mQueryAdapter->AddParam("%%FIXEDPARTWHERECLAUSE%%", strFixedPartWhereClause.c_str());
		mQueryAdapter->AddParam("%%SKIPRECORDSPARTWHERECLAUSE%%", strSkipRecordsPartWhereClause.c_str());
		mQueryAdapter->AddParam("%%DEST_ACCT_ID_COL_NAME%%", DEST_ACCT_ID_COL_NAME);
		mQueryAdapter->AddParam("%%KEYPARTWHERECLAUSE%%", strKeyPartWhereClause.c_str());
		strInsertFromTempTableSQL = mQueryAdapter->GetQuery();

		/******
		 * Prepare update query; sample Update query:
 		 *		UPDATE dest 
		 *		SET col1=CASE WHEN src.col1 IS NULL THEN dest.col1 ELSE CASE WHEN src.col1='' THEN NULL ELSE src.col1 END,
		 *													<this repeats for each string type>
		 *			col2=CASE WHEN src.col2 IS NULL THEN dest.col2 ELSE src.col2 END,
		 *			col3=CASE WHEN src.col3 IS NULL THEN dest.colN ELSE src.colN END, ...
	     *		FROM NetMeter..testA dest INNER JOIN
		 *			NetMeterStage..tmpTable src ON
		 *		dest.id_acc = src.dest_acct_id
		 *		AND dest.key2 = src.key2
		 *		AND dest.keyN = src.keyN
		 *		WHERE src.dest_acct_id IS NOT NULL
		 *		AND (src.1 IS NOT NULL OR src.2 IS NOT NULL OR src.N IS NOT NULL)
		 *****/
		string strUpdateFromTempTableSQL = "";
		mQueryAdapter->ClearQuery();
		mQueryAdapter->SetQueryTag("__UPDATE_ACCVIEW_TABLE__");
		mQueryAdapter->AddParam("%%UPDATECOLLIST%%", strUpdateColumnList.c_str());
    if(IsOracle() == TRUE)
    {
      mQueryAdapter->AddParam("%%SELECTCOLLIST%%", strSelectColumnList.c_str());
    }
		mQueryAdapter->AddParam("%%NETMETER%%", NetMeterDBInfo.GetCatalog().c_str());
		mQueryAdapter->AddParam("%%TARGET_TABLE%%", bstrTargetTableName);
		mQueryAdapter->AddParam("%%STAGING%%", stageDBInfo.GetCatalog().c_str());
		mQueryAdapter->AddParam("%%TEMP_TABLE%%", mTmpTableName.c_str());
		mQueryAdapter->AddParam("%%DEST_ACCT_ID_COL_NAME%%", DEST_ACCT_ID_COL_NAME);
		mQueryAdapter->AddParam("%%KEYPARTWHERECLAUSE%%", strKeyPartWhereClause.c_str());
    mQueryAdapter->AddParam("%%FIXEDPARTWHERECLAUSE%%", strFixedPartWhereClause.c_str());
		mQueryAdapter->AddParam("%%SKIPRECORDSPARTWHERECLAUSE%%", strSkipRecordsPartWhereClause.c_str());
		strUpdateFromTempTableSQL = mQueryAdapter->GetQuery();

		// This loop guarantees that items in the array are in a defined order.
		SQLQueryVector SqlQuery;
		for (int i = 0; i < QT_ARRAY_SIZE; i++)
		{
			if (i == QT_INSERT)
				SqlQuery.push_back(strInsertFromTempTableSQL);
			else if (i == QT_UPDATE)
				SqlQuery.push_back(strUpdateFromTempTableSQL);
			else
			{
				// Should never hit this.
				ASSERT(false);
			}
		}

		// Add query vector to extension map.
		mExtensionQueryMap[bstrExtension] = SqlQuery;

		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, strInsertFromTempTableSQL.c_str());
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, strUpdateFromTempTableSQL.c_str());
	}

	// Add the closing parenthesis.
  if(!IsOracle())
  {
	  mstrCreateTempTableSQL += ")";
  }
  else
  {
    mstrCreateTempTableSQL += ")'; END;";
  }
	mstrInsertIntoTempTableSQL += (")" + strValuesSQL +")");

	// Log the queries.
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, mstrCreateTempTableSQL.c_str());
	mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, mstrInsertIntoTempTableSQL.c_str());

	// Success.
	return S_OK;
}

/***************************************************************************
 * ResolveBatch				                                               *
 ***************************************************************************/
HRESULT CMTBatchCopyAccountPropertiesPlugin::ResolveBatch(vector<MTPipelineLib::IMTSessionPtr>& sessionArray, COdbcConnectionHandle & netMeterDbConnection)
{
  COdbcConnectionHandle stageDbBcpConnection(mOdbcManager, mStageDbBcpConnectionCommand);

	// Truncate the temporary table.
	COdbcStatementPtr truncateStmtPtr = stageDbBcpConnection->CreateStatement();
	truncateStmtPtr->ExecuteUpdate(mstrTruncateTmpTableSQL);

	// Insert sessions' arguments into the temp table.
	HRESULT hr;
	if(mUseBcpFlag)
		hr = InsertIntoTempTable(sessionArray, stageDbBcpConnection[mBcpInsertToTmpTableStmtCommand]);
	else if (IsOracle())
		hr = InsertIntoTempTable(sessionArray, stageDbBcpConnection[mOracleArrayInsertToTmpTableStmtCommand]);
  else
		hr = InsertIntoTempTable(sessionArray, stageDbBcpConnection[mSqlArrayInsertToTmpTableStmtCommand]);

	// If insert into temp table in is successfull...
	if (SUCCEEDED(hr))
	{
		// Loop through all the update SQL statements and execute them.
		COdbcStatementPtr UpdateStmt = netMeterDbConnection->CreateStatement();
		MTExtensionNameMap::iterator iNameIterator;
		for (iNameIterator = mDestExtensions.begin(); iNameIterator != mDestExtensions.end() && SUCCEEDED(hr); ++iNameIterator)
		{
			// Get the SQL query vector.
			SQLQueryVector SqlQuery = mExtensionQueryMap[iNameIterator->second];

			//-----
      // Execute Update SQL statement.
			// We should execute update statement 1st, incase there is an insert with
			// same session keys.  Doing an insert first, we could endup
			// with an extra update operation.
      //-----
			UpdateStmt->ExecuteUpdate(SqlQuery[QT_UPDATE]);
			UpdateStmt->ExecuteUpdate(SqlQuery[QT_INSERT]);
		}
	}
	return hr;
}

/***************************************************************************
 * InsertIntoTempTable		                                               *
 ***************************************************************************/
template<class T> HRESULT
CMTBatchCopyAccountPropertiesPlugin::InsertIntoTempTable(vector<MTPipelineLib::IMTSessionPtr>& aSessionArray,
											             T insertStmtPtr)
{
  bool bSkipSession;

	try
	{
		// Insert all sessions from input array.
		for (unsigned int i = 0; i < aSessionArray.size(); i++)
		{
      bSkipSession = false;

			MTPipelineLib::IMTSessionPtr aSession = aSessionArray[i];

			// Iterate over all the extensions.
			_bstr_t bstrExtension;
			long lngDestAccountID = aSession->GetLongProperty(mlngDestinationPropID);
			
			// Loop throught all extensions.
      long nColumnIndex = PROPERTY_COLUMN_ID;
			MTPropertyNameVector::iterator iPropertyIterator;
			MTExtensionNameMap::iterator iNameIterator;
			for (iNameIterator = mDestExtensions.begin();
           (iNameIterator != mDestExtensions.end()) && !bSkipSession;
           ++iNameIterator)
			{
				// Get extension name.
				bstrExtension = iNameIterator->second;

				// Get the property meta data for current extension.
				PropertyMetadataMap* pPropertyMetaDataMap = mExtensionPropertiesMap[bstrExtension];

				// Log extension.
				char buffer[1024];
				sprintf(buffer, "Preparing to update extension [%s].", (const char *) bstrExtension);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

				// Flag used to determine if session should be processed.
				bool bNonKeyPropertyFound = false;
        bool bAllKeyPropertiesFound = true;

				// Loop through all the copy properties.
				long lSrcPropID, lDestPropID;
				for (iPropertyIterator = mCopyProperties.begin();
             (iPropertyIterator != mCopyProperties.end()) && !bSkipSession;
             ++iPropertyIterator)
				{
					MTCopyProperty* pCopyProp = *iPropertyIterator;

					// Check if the destination extension is the one to be modified this time around.
					if (bstrExtension == pCopyProp->DestinationExtension)
					{
						if (pCopyProp->PropType == COPY_PROP_TYPE_SESSION)
						{
							// Get the source property ID.
							lSrcPropID = mNameID->GetNameID(pCopyProp->SourceProperty);

							// Get the destination property ID.
							lDestPropID = mNameID->GetNameID(pCopyProp->DestinationProperty);

							// Check to see if property type is in map.
							PropertyMetadataMap::iterator itPropertyMetaData = pPropertyMetaDataMap->find(lDestPropID);
							if (itPropertyMetaData == pPropertyMetaDataMap->end())
							{
								// If property is required then we must return an error.
								if (pCopyProp->Required)
								{
									char buffer[1024];
									sprintf(buffer, "Unable to find property [%s] in the session.",
										    (const char *) pCopyProp->SourceProperty);
                  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
                  aSession->MarkAsFailed(buffer, PIPE_ERR_MISSING_PROP_NAME);
                  mbSessionsFailed = true;
                  bSkipSession = true;
								}
							}
							else // Property is not configured.
							{
								// Get property meta data.
								MTACCOUNTLib::IMTPropertyMetaDataPtr pPropertyMetaData = itPropertyMetaData->second;

								// Get the property's value and set into temp table.
                bool bPropertyExists = true;
								switch (pPropertyMetaData->GetDataType())
								{
									case MTACCOUNTLib::PROP_TYPE_STRING:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
										{
											_variant_t var = aSession->GetStringProperty(lSrcPropID);

											// Do not insert NULL vars or empty strings, NULL will be created in db automatically.
											_bstr_t value = var;
											if (var.vt != VT_NULL && var.vt != VT_EMPTY)
                      {
                        // Validate length of string.
                        if (value.length() > (unsigned int) pPropertyMetaData->GetLength())
                        {
         									char buffer[1024];
								          sprintf(buffer, "String property [%s] value length [%d] exceeds configuration length [%d].",
									                (const char *) pCopyProp->SourceProperty,
                                  value.length(),
                                  (unsigned int) pPropertyMetaData->GetLength());
                          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
                          aSession->MarkAsFailed(buffer, PIPE_ERR_MISSING_PROP_NAME);
                          mbSessionsFailed = true;
                          bSkipSession = true;
                          break;
                        }

                        // Set string value.
												insertStmtPtr->SetWideString(nColumnIndex, (const wchar_t*) value);
                      }
										}
                    else // Property does not exist.
                      bPropertyExists = false;
                    
										break;
									}

									case MTACCOUNTLib::PROP_TYPE_TIME:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_TIME) == VARIANT_TRUE)
										{
											long value = aSession->GetTimeProperty(lSrcPropID);
											insertStmtPtr->SetInteger(nColumnIndex, value);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_DATETIME:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_TRUE)
										{
											DATE value = aSession->GetOLEDateProperty(lSrcPropID);

											TIMESTAMP_STRUCT dateODBC;
											OLEDateToOdbcTimestamp(&value, &dateODBC);
											insertStmtPtr->SetDatetime(nColumnIndex, dateODBC);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_INTEGER:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_TRUE)
										{
											long value = aSession->GetLongProperty(lSrcPropID);
											insertStmtPtr->SetInteger(nColumnIndex, value);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_BIGINTEGER:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_LONGLONG) == VARIANT_TRUE)
										{
											__int64 value = aSession->GetLongLongProperty(lSrcPropID);
											insertStmtPtr->SetBigInteger(nColumnIndex, value);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_DOUBLE:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_TRUE)
										{
											double value = aSession->GetDoubleProperty(lSrcPropID);
											insertStmtPtr->SetDouble(nColumnIndex, value);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_BOOLEAN:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_TRUE)
										{
											VARIANT_BOOL value = aSession->GetBoolProperty(lSrcPropID);
											insertStmtPtr->SetString(nColumnIndex, (value == VARIANT_TRUE) ? "1" : "0");
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_ENUM:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_TRUE)
										{
											int value = aSession->GetEnumProperty(lSrcPropID);
											insertStmtPtr->SetInteger(nColumnIndex, value);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									case MTACCOUNTLib::PROP_TYPE_DECIMAL:
									{
										if (aSession->PropertyExists(lSrcPropID, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_TRUE)
										{
											DECIMAL value = aSession->GetDecimalProperty(lSrcPropID);
											SQL_NUMERIC_STRUCT sqlValue;
											DecimalToOdbcNumeric(&value, &sqlValue);
											insertStmtPtr->SetDecimal(nColumnIndex, sqlValue);
										}
                    else // Property does not exist.
                      bPropertyExists = false;

                    break;
									}

									default:
									{
										char buffer[1024];
										sprintf(buffer, "An unsupported or unknown proptype was found: %d.", pPropertyMetaData->GetDataType());
                    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
                    aSession->MarkAsFailed(buffer, PIPE_ERR_MISSING_PROP_NAME);
                    mbSessionsFailed = true;
                    bSkipSession = true;
                    break;
									}
								}

                // If property is part of key and does not exist then not all key properties found.
                if (!bPropertyExists && pCopyProp->PartOfKey)
                {
                  bAllKeyPropertiesFound = false;

					        char buffer[1024];
                  sprintf(buffer, "Key property [%s] not specified.", (const char*) pCopyProp->SourceProperty);
                  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
                }

 								//-----
								// Check if this property is not part of the key, this is needed so that 
								// we don't insert a row into temp table that does not have any other data
								// than key.  Essentially an empty record.
								//-----
								if (bPropertyExists && !pCopyProp->PartOfKey)
									bNonKeyPropertyFound = true;
							}
						}
						else
						{
							char buffer[1024];
							sprintf(buffer, "An unknown type was specified for a property.");
              mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
              aSession->MarkAsFailed(buffer, PIPE_ERR_MISSING_PROP_NAME);
              mbSessionsFailed = true;
              bSkipSession = true;
						}

            // Increment column index.
            nColumnIndex++;

					} // if extension matches 
				} // next property

        // If at least one non-key property is found,
        // and not all key properties are found then mark session failed.
        if (bNonKeyPropertyFound == true &&
            bAllKeyPropertiesFound == false)
        {
	        char buffer[1024];
          sprintf(buffer, "Key property not specified for extension [%s].", (const char*) bstrExtension);
          mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
          aSession->MarkAsFailed(buffer, PIPE_ERR_MISSING_PROP_NAME);
          mbSessionsFailed = true;
          bSkipSession = true;
        }

        // Skip session
        if (bSkipSession)
        {
          if (bAllKeyPropertiesFound)
  				  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
									           "An error ocurred accessing the properties for this session.");
          else
            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
						  			         "Not updating properties for this session because a Key property was not found.");
        }

				// If no non-key properties have been found
				if (bNonKeyPropertyFound == false)
        {
						char buffer[1024];
            sprintf(buffer, "Not updating properties for this extension [%s] because no NonKey properties were found.",
                            (const char *) bstrExtension);
            mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
        }

        // Add the account ID property.
				else insertStmtPtr->SetInteger(DESTINATION_ACCOUNT_COLUMN_ID, lngDestAccountID);

 			} // next extension

      if (bSkipSession == false)
  			// Add to batch.
	  		insertStmtPtr->AddBatch();

		} // next session

		// Insert the records to the temp table.
		insertStmtPtr->ExecuteBatch();
	}
	catch(_com_error & e)
	{
 		insertStmtPtr->ExecuteBatch();

		char buffer[1024];
		sprintf(buffer, "An exception was thrown while inserting session into temp table: 0x%x, %s", 
						e.Error(), (const char*) _bstr_t(e.Description()));
		return Error(buffer);
	}
	catch(...)
	{
 		insertStmtPtr->ExecuteBatch();
		throw;
	}

	return S_OK;
}

//-- EOF --

