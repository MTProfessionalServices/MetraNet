/**************************************************************************
 * DBSESSIONFAILURES
 *
 * Copyright 1997-2004 by MetraTech Corporation
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
 * Created by: Travis Gebhardt
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "StdAfx.h"

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::IMTSQLRowsetPtr;") \
     inject_statement("using ROWSETLib::IMTSQLRowset;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaData;")

#import <MetraTech.Pipeline.ReRun.tlb> \
     inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::MTOperatorType;") \
     inject_statement("using namespace MTAUTHLib;")

#import <MTServerAccess.tlb>

#include "PipelineControl.h"
#include "MTSessionFailures.h"

#include <MTUtil.h>
#include <pipelineconfig.h>
#include <mtglobal_msg.h>
#include <sessionerr.h>
#include <MTSessionError.h>
#include <pipeconfigutils.h>
#include <loggerconfig.h>
#include <controlutils.h>
#include <mtcomerr.h>
#include <ConfigDir.h>
#include <mtparamnames.h>
#include <MSIX.h>
#include <formatdbvalue.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

using namespace ROWSETLib;

using COMMeterLib::ISessionPtr;
using COMMeterLib::ISessionSetPtr;
using COMMeterLib::IBatchPtr;

typedef pair <vector<unsigned char>, int> My_Pair;


template <class _InsertStmt>
DBSessionFailures<_InsertStmt>::DBSessionFailures(BOOL aIsOracle) : mGenerateMSIXInitialized(false)
{
	mIsOracle = aIsOracle;
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[DBSessionFailures]");

	std::string configDir;
	if (!GetMTConfigDir(configDir))
		MT_THROW_COM_ERROR("Configuration directory not set in registry");

	PipelineInfoReader pipelineReader;
	PipelineInfo pipelineInfo;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		MT_THROW_COM_ERROR(HRESULT_FROM_WIN32(pipelineReader.GetLastError()->GetCode()));

	
}


template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::Refresh(ErrorObjectList& failures)
{
  COdbcConnectionPtr conn;
	conn = new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter"));

	GetErrorObjectsFromDB(conn, failures);

	return S_OK;
}


template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::ResubmitSuspendedMessage(BSTR messageID)
{
	MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed(__uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions));
	bulkFailed->ResubmitSuspendedMessage(messageID);
	return S_OK;
}


template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::DeleteSuspendedMessage(BSTR messageID)
{
	MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed(__uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions));
	bulkFailed->DeleteSuspendedMessage(messageID);
	return S_OK;
}

template <class _InsertStmt>
SessionErrorObject * DBSessionFailures<_InsertStmt>::FindError(const wchar_t * apLabel)
{ 
	// TODO: transactionality!!!
  COdbcConnectionPtr conn;
	conn = new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter"));

  SessionErrorObject * errObj = GetErrorObjectFromDB(conn, apLabel);
  ASSERT(errObj);

  const unsigned char * parentSessionUID;
  parentSessionUID = errObj->GetRootID();
  int id_ss = errObj->GetScheduleSessionSetID();

  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);  //using OLEDB
	rowset->Init("\\Queries\\Pipeline");
	rowset->SetQueryTag("__FIND_ALL_SESSIONSETS_FROM_MESSAGE__");
	rowset->AddParam(L"%%SESSION_SET%%", id_ss);
 	rowset->Execute();

  //find the parent service
  //map of ServiceDefinitionID and ServiceDefinitionTableName
  typedef map<int, string> INT2STRING;
  INT2STRING aServiceDefList;
  _variant_t serviceDefvalue;
  while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
	{
    serviceDefvalue = rowset->GetValue("nm_table_name");
    string strServiceDefTable = string(_bstr_t(serviceDefvalue));
    serviceDefvalue = rowset->GetValue("id_enum_data");
    int serviceDefID = int(serviceDefvalue);
 		aServiceDefList.insert(INT2STRING::value_type (serviceDefID, strServiceDefTable));
		rowset->MoveNext();
	}

  rowset->ClearQuery();

  INT2STRING::iterator it;
  int parentServiceDefID;
  std::string parentServiceDefTable;

  for (it = aServiceDefList.begin(); it != aServiceDefList.end(); it++)
  {
      rowset->SetQueryTag("__FIND_PARENT_SERVICE__");
      rowset->AddParam(L"%%ID_SOURCE_SESS%%", (ConvertBinaryUIDToHexLiteral(parentSessionUID, mIsOracle)).c_str(),VARIANT_TRUE);
    	rowset->AddParam(L"%%SERVICEDEF_TABLENAME%%", (*it).second.c_str());
      rowset->Execute();
      if (rowset->RecordCount > 0)
      {
        //we found the parent service definition
        parentServiceDefID = int((*it).first);
        parentServiceDefTable = string((*it).second);
        //remove this one from the list
        aServiceDefList.erase(it);
        rowset->ClearQuery();
        break;
      }
      rowset->ClearQuery();
  }

  //children is a map with id_source_sess as the key and having service def id as value
  std::map<vector<unsigned char>, int> children;

  //now  find the child service defintions, only if the failed transaction is a compound
  if (errObj->GetIsCompound())
  {
    std::string selectQuery;
    std::string tableName;
    std::vector<unsigned char> childUID; 

    COdbcStatementPtr stmt = conn->CreateStatement();
	  COdbcResultSetPtr resultSet;
	  


    INT2STRING::iterator anotherIt;
    for (anotherIt = aServiceDefList.begin(); anotherIt != aServiceDefList.end(); anotherIt++)
    {
       selectQuery =	"select id_source_sess from "
                               + (*anotherIt).second 
                               + " where id_parent_source_sess = "
							   + UseHexToRawPrefix(mIsOracle)
                               + ConvertBinaryUIDToHexLiteral(parentSessionUID, mIsOracle)
							   + UseHexToRawSuffix(mIsOracle);
     
       resultSet = stmt->ExecuteQuery(selectQuery.c_str());
       while (resultSet->Next())
       {
          childUID = resultSet->GetBinary(1);
          children.insert (My_Pair( childUID, (*anotherIt).first ));
       }
       resultSet->Close();
    }
  }
  //at this point if the session is a part of a compound we have the list of children in the
  //map children
 
  bool ret = GenerateMSIXFromDB(conn, errObj, parentServiceDefID, children);
  //TODO: add error handling.
  
  return errObj;
}


// saves an edited MSIX failed transaction by updating t_svc tables directly
template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::SaveXMLMessage(BSTR sessionID,
																					const char * msixStream,
																					GENERICCOLLECTIONLib::IMTCollectionPtr childrenToDelete)
{
	try
	{
		PipelineMSIXParser<DBSessionUpdateBuilder<_InsertStmt> > mParser;
		
		// initializes the parser for validation
		// validation mode is used here so that all errors can be found during the initial parse.
		// for now there is no way to communicate the specifics of failures to the UI 
		// but they will be logged
		mParser.SetValidateOnly(TRUE);
		if (!mParser.InitForValidate())
			MT_THROW_COM_ERROR("Could not initialize parser: %s", mParser.GetLastError()->GetProgrammerDetail().c_str());
		
		if (!mParser.SetupParser())
			MT_THROW_COM_ERROR("Could not setup parser: %s", mParser.GetLastError()->GetProgrammerDetail().c_str());
		
		// parses the MSIX and builds up an update query
		DBSessionUpdateProduct<_InsertStmt>* results;
		ValidationData validationData;
		if (!mParser.Validate(msixStream, strlen(msixStream), (ISessionProduct**) &results, validationData))
			MT_THROW_COM_ERROR("Parsing failure: %s", mParser.GetLastError()->GetProgrammerDetail().c_str());

		// generates inserts statements to populate the children UID table
		std::string insertQuery;
		if (childrenToDelete != NULL)
		{
			unsigned char binaryChildUID[UID_LENGTH];
			for (int i = 1; i <= childrenToDelete->Count; i++)
			{
				_bstr_t encodedChildUID = childrenToDelete->GetItem(i);
				if (!MSIXUidGenerator::Decode(binaryChildUID, (const char *) encodedChildUID))
					MT_THROW_COM_ERROR("Could not decode UID of child to be deleted!");
				
				// inserts both the UID as binary and the UID as a binary literal
				if (mIsOracle)
				{
					insertQuery += "INSERT INTO tmp_children VALUES (";
				}
				else
				{
					insertQuery += "INSERT INTO #children VALUES (";
				}

				insertQuery += ConvertBinaryUIDToHexLiteral(binaryChildUID, mIsOracle);
				insertQuery += "); ";  
			}
		}

		//
		// updates the t_svc tables
		//
		LoggerConfigReader configReader;
		NTLogger logger;
		logger.Init(configReader.ReadConfiguration("logging"), "[SessionFailures]");
		logger.LogVarArgs(LOG_DEBUG, L"Save failed transaction update query: %s", results->GetUpdateQuery().c_str());

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init("Queries\\Pipeline");
		rowset->SetQueryTag("__SAVE_EDITED_FAILED_TRANSACTION__");
		rowset->AddParam("%%SVC_UPDATE_STATEMENTS%%", results->GetUpdateQuery().c_str(), VARIANT_TRUE);
		rowset->AddParam("%%INSERT_CHILDREN_TO_DELETE%%", insertQuery.c_str(), VARIANT_TRUE);
		rowset->Execute();
	}
 	catch (std::exception & e)
	{
		MT_THROW_COM_ERROR("Exception caught: %s", e.what());
	}

	return S_OK;
}


template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::LoadXMLMessage(BSTR aSessionID,
																					std::string & arMessage,
																					PIPELINECONTROLLib::IMTTransactionPtr txn)
{
	// TODO: transactionallity!

	_bstr_t sessionID(aSessionID);

	SessionErrorObject * errObj = FindError((const wchar_t *) sessionID);

	int len;
	const char * buffer;
	errObj->GetMessage(&buffer, len);
	arMessage = std::string(buffer, len);

	return S_OK;
}


template <class _InsertStmt>
HRESULT DBSessionFailures<_InsertStmt>::GetErrorObjectsFromDB(COdbcConnectionPtr conn, 
																								 const std::wstring & filterClause,
																								 ErrorObjectList & failures)
{
  //TODO: move the query to query file.. also use queryadapter.  we don't need to get binary values
  // as we can decode them from the encoded string.
  wstring selectQuery =	L"select tx_FailureID_Encoded, tx_FailureCompoundID_encoded, tx_FailureID, "
                        L"tx_FailureCompoundID, tx_FailureServiceName, n_Code, n_Line, tx_ErrorMessage, "
                        L"tx_StageName, tx_Plugin, tx_Module, tx_Method, tx_Batch, tx_Batch_Encoded, "
                        L"b_compound, dt_FailureTime, dt_MeteredTime, id_PossiblePayeeID, id_PossiblePayerID, id_sch_ss, ed.id_enum_data, "
                        L"tx_Sender "
                        L"from t_failed_transaction ft "
                        L"inner join t_enum_data ed "
                        L"on upper(ft.tx_failureServiceName) = upper(ed.nm_enum_data) "
                        L"where ft.state in ('N', 'I', 'C', 'P') ";
 
  wstring finalQuery = selectQuery + filterClause;

  COdbcStatementPtr stmt = conn->CreateStatement();
	COdbcResultSetPtr resultSet;
	resultSet = stmt->ExecuteQueryW(finalQuery.c_str());

  std::vector<unsigned char> parentSessionUID;
	while (resultSet->Next())
  {
		SessionErrorObject * errObj = new SessionErrorObject;
		failures.push_back(errObj);

    std::wstring childSessionIDEncoded = resultSet->GetWideString(1);
    std::wstring parentSessionIDEncoded = resultSet->GetWideString(2);

    std::vector<unsigned char> sessionUID = resultSet->GetBinary(3);
    ASSERT(sessionUID.size() == UID_LENGTH);
    errObj->SetSessionID(&sessionUID[0]);

    parentSessionUID = resultSet->GetBinary(4);
    ASSERT(parentSessionUID.size() == (resultSet->WasNull() ? 0 : UID_LENGTH));
    errObj->SetRootID(&parentSessionUID[0]);

    ErrorObject::ErrorCode errCode;
    errCode = resultSet->GetInteger(6);
    errObj->SetErrorCode(errCode);

    errObj->SetLineNumber(resultSet->GetInteger(7));
    errObj->SetErrorMessage(resultSet->GetString(8).c_str());
    errObj->SetStageName(resultSet->GetString(9).c_str());
    errObj->SetPlugInName(resultSet->GetString(10).c_str());
    errObj->SetModuleName(resultSet->GetString(11).c_str());
    errObj->SetProcedureName(resultSet->GetString(12).c_str());

    std::vector<unsigned char> batchID = resultSet->GetBinary(13);
    ASSERT (batchID.size() == (resultSet->WasNull() ? 0 : UID_LENGTH));
	if (batchID.size() != 0)
		errObj->SetBatchID(&batchID[0]);
	else
		errObj->SetBatchID(NULL);
    //14 is tx_batch_encoded, we don't need it?
    if ("Y" == resultSet->GetString(15) )
      errObj->SetIsCompound(true);
    else
      errObj->SetIsCompound(false);

    COdbcTimestamp FailureTime_odbc = resultSet->GetTimestamp(16);
		time_t FailureTime_timet;
		OdbcTimestampToTimet(FailureTime_odbc.GetBuffer(), &FailureTime_timet);
    errObj->SetFailureTime(FailureTime_timet);

    COdbcTimestamp MeteredTime_odbc = resultSet->GetTimestamp(17);
		time_t MeteredTime_timet;
		OdbcTimestampToTimet(MeteredTime_odbc.GetBuffer(), &MeteredTime_timet);
    errObj->SetMeteredTime(MeteredTime_timet);

    errObj->SetPayeeID(resultSet->GetInteger(18));
    errObj->SetPayerID(resultSet->GetInteger(19));

    errObj->SetScheduleSessionSetID(resultSet->GetInteger(20));
    errObj->SetServiceID(resultSet->GetInteger(21));

    errObj->SetIPAddressAsString(resultSet->GetString(22).c_str());

  } 
  resultSet->Close();

  // TODO: missing SessionSetID
  // TODO: shouldn't ScheduleSessionID go away?

  return S_OK;
}


template <class _InsertStmt>
SessionErrorObject * DBSessionFailures<_InsertStmt>::GetErrorObjectFromDB(COdbcConnectionPtr conn,
																														 const wchar_t * apLabel)
{
	// builds up a filter to only select back the one error we're interested in
	std::wstring filter = L"AND ft.tx_FailureCompoundID = ";
	unsigned char binaryUID[UID_LENGTH];
	if (!MSIXUidGenerator::Decode(binaryUID, (const char *) _bstr_t(apLabel)))
		MT_THROW_COM_ERROR("Could not decode UID of error to be looked up!");
	filter += (const wchar_t *) _bstr_t(ConvertBinaryUIDToHexLiteral(binaryUID, mIsOracle).c_str());

	// retrieves the error object
	ErrorObjectList failures;
	HRESULT hr = GetErrorObjectsFromDB(conn, filter, failures);
	if (failures.size() == 0)
		MT_THROW_COM_ERROR(L"No error object could be found in DB for failure '%s'!", apLabel);
	if (failures.size() > 1)
		MT_THROW_COM_ERROR(L"Too many error objects were found in DB for failure '%s'!", apLabel);

	SessionErrorObject * errObj = failures[0];

	return errObj;
}


template <class _InsertStmt>
bool DBSessionFailures<_InsertStmt>::GenerateMSIXFromDB(COdbcConnectionPtr conn,
																					 SessionErrorObject * apErrObj,
																					 int parentServiceDefID,
																					 std::map<vector<unsigned char>, int> &children)
{
  //TODO: better error handling


	// the following init is very heavy so only do it when we need to (CR12342)
	if (!mGenerateMSIXInitialized)
	{
		if (!mServices.Initialize())
			MT_THROW_COM_ERROR("Could not initialize sevice definition collection");

		int result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", TRUE, "pipeline");
		if (result != 0)
			MT_THROW_COM_ERROR("Could not initialize crypto!");
  
		HRESULT hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);	
		if(FAILED(hr))
			MT_THROW_COM_ERROR(hr);
	
		hr = mNameID.CreateInstance(MTPROGID_NAMEID);
		if(FAILED(hr))
			MT_THROW_COM_ERROR(hr);

		hr = mMeter.CreateInstance("MetraTechSDK.Meter.1");
		if (FAILED(hr))
			MT_THROW_COM_ERROR(hr);
		
		mMeter->Startup();
		
		MTSERVERACCESSLib::IMTServerAccessDataSetPtr serverAccess(MTPROGID_SERVERACCESS);
		serverAccess->Initialize();
		MTSERVERACCESSLib::IMTServerAccessDataPtr accessSet =	
			serverAccess->FindAndReturnObject("FailedTransactions");
		
		mMeter->AddServer(0,  //priority
											accessSet->GetServerName(), 
											(COMMeterLib::PortNumber) accessSet->GetPortNumber(), 
											accessSet->GetSecure() ? TRUE : FALSE, 
											accessSet->GetUserName(),	
											accessSet->GetPassword()); 
		
		mGenerateMSIXInitialized = true;
	}

  
  HRESULT hr = S_OK;
  ISessionSetPtr sessionSet;
  std::string selectQuery;

  CMSIXDefinition *apDef;
  std::wstring wideParentServiceDef;
  std::string parentServiceDef;
  
  parentServiceDef = mNameID->GetName(parentServiceDefID);
  ASCIIToWide(wideParentServiceDef, parentServiceDef.c_str());
  

  if (!	mServices.FindDefinition(wideParentServiceDef, apDef))
  {
   	return false; // log proper error
  }
 
  DBParserService<SDKSessionWrapper, std::string> parserServiceDef;
	parserServiceDef.Init(apDef, mEnumConfig, mCrypto, false);

	sessionSet = mMeter->CreateSessionSet();
  
  const string columnnames = parserServiceDef.GetColumnNames();
  const unsigned char * binaryParentUID;
  std::string encodedParentUID;

  binaryParentUID = apErrObj->GetRootID();
  MSIXUidGenerator::Encode(encodedParentUID, binaryParentUID);

  //create the parent session
  ISessionPtr parentSession = sessionSet->CreateSession(parentServiceDef.c_str());

  //read the parent session

  COdbcStatementPtr stmt = conn->CreateStatement();
  COdbcResultSetPtr resultSet;
  
  selectQuery =	"select id_source_sess, id_parent_source_sess, " +
                  columnnames + " from "
                 + parserServiceDef.GetTableName()
                 + " where id_source_sess = "
				 + UseHexToRawPrefix(mIsOracle)
                 + ConvertBinaryUIDToHexLiteral(binaryParentUID, mIsOracle)
				 + UseHexToRawSuffix(mIsOracle);
     
  resultSet = stmt->ExecuteQuery(selectQuery.c_str());
  while (resultSet->Next())
	{
    SDKSessionWrapper *parentWrapper = new SDKSessionWrapper(parentSession, mEnumConfig, mCrypto);
    //the first 2 columns are id_source_sess and id_parent_source_sess
    try
    {
      parserServiceDef.Read(resultSet, parentWrapper, 3);
    }
    catch(COdbcException& ex)
	  {
		  mLogger.LogVarArgs(LOG_FATAL, "Error while reading error: %s", ex.what());
	    return false;
	  }
  }

  resultSet->Close();

  //set the original uid on the session
  BSTR BSTRUID = _bstr_t(encodedParentUID.c_str()).GetBSTR();
  parentSession->put__ID(BSTRUID);

  unsigned char * binaryChildUID;
  std::string encodedChildUID;
  std::wstring wideChildServiceDefName;
  std::string childServiceDefName;

  if (apErrObj->GetIsCompound())
  {
    //deal with children of each type. input is a map of binaryuids to servicedef ids
    std::map<vector<unsigned char>, int>::iterator childIt;
    for (childIt = children.begin(); childIt != children.end(); childIt++)
    {
      std::vector<unsigned char> temp = childIt->first;
      binaryChildUID = &temp[0];
      MSIXUidGenerator::Encode(encodedChildUID, binaryChildUID);
      int childServiceDefID = childIt->second;
      childServiceDefName = mNameID->GetName(childServiceDefID);
      ASCIIToWide(wideChildServiceDefName, childServiceDefName.c_str());

      if (!	mServices.FindDefinition(wideChildServiceDefName, apDef))
      {
   	    return false; // log proper error
      }
      DBParserService<SDKSessionWrapper, std::string> ChildparserServiceDef;
      ChildparserServiceDef.Init(apDef, mEnumConfig, mCrypto, false);
      ISessionPtr childSession = parentSession->CreateChildSession(childServiceDefName.c_str());
      
      const string childcolumnNames = ChildparserServiceDef.GetColumnNames();

      selectQuery =	"select id_source_sess, id_parent_source_sess, "
                  + childcolumnNames + " from "
                 + ChildparserServiceDef.GetTableName()
                 + " where id_source_sess = "
			     + UseHexToRawPrefix(mIsOracle)
                 + ConvertBinaryUIDToHexLiteral(binaryChildUID, mIsOracle)
				 + UseHexToRawSuffix(mIsOracle);

      resultSet = stmt->ExecuteQuery(selectQuery.c_str());
      while (resultSet->Next())
	    {
        SDKSessionWrapper *childWrapper = new SDKSessionWrapper(childSession, mEnumConfig, mCrypto);
        //the first 2 columns are id_source_sess and id_parent_source_sess
        try
        {
          ChildparserServiceDef.Read(resultSet, childWrapper, 3);
        }
        catch(COdbcException& ex)
	      {	
		      mLogger.LogVarArgs(LOG_FATAL, "Error while reading error: %s", ex.what());
	        return false;
	      }
      }
      resultSet->Close();
      BSTRUID = _bstr_t(encodedChildUID.c_str()).GetBSTR();
      childSession->put__ID(BSTRUID);
    }

  }
  _bstr_t bstrMsg = sessionSet->ToXML();
  std::string msg(bstrMsg);

	// don't log the MSIX since it may contain plaintext of encrypted properties (CR12698)
	// std::string buffer = "MSIX generated from DB queue:\n" + msg;
  // mLogger.LogThis(LOG_DEBUG, buffer.c_str());

  apErrObj->SetMessage(msg.c_str(), bstrMsg.length()); 

  return true;
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class DBSessionFailures<COdbcPreparedBcpStatement>;
template class DBSessionFailures<COdbcPreparedArrayStatement>;
