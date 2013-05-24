/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#ifndef _ODBCTABLEWRITER_H_
#define _ODBCTABLEWRITER_H_

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF")
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

#include <mtcomerr.h>
#include <string>
#include <map>
#include <vector>
#include <mtglobal_msg.h>

#include <OdbcResultSet.h>
#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <OdbcResourceManager.h>
#include <autoptr.h>
#include <transact.h>
#include <SetIterate.h>

// TODO: remove undefs
#if defined(MTODBCUTILS_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif


typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;

class COdbcTempTableMapping;
typedef vector<COdbcTempTableMapping*> ColumnMappings;
typedef ColumnMappings::const_iterator Iterator;

using namespace std;
using MTPipelineLib::IMTTransactionPtr;

_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

class COdbcTempTableMapping
{
private:
	int mOffset;
	long mPipelinePropID;
	MTPipelineLib::MTSessionPropType mPipelineproptype;
	bool mRequired;
	COdbcTempTableMapping(){};
public:
	DllExport COdbcTempTableMapping(int offset,
                                  MTPipelineLib::MTSessionPropType proptype,
                                  long pipepropid, 
                                  bool required)
    : mOffset(offset), 
      mPipelineproptype(proptype),
      mPipelinePropID(pipepropid), 
      mRequired(required){};
	DllExport int GetOffset(){return mOffset;}
	DllExport long GetPipelinePropID(){return mPipelinePropID;}
	DllExport MTPipelineLib::MTSessionPropType GetPipelinePropType(){return mPipelineproptype;}
	DllExport bool GetRequired(){return mRequired;}


};

class COdbcTableWriter
{
private:
	bool mIsOracle;
	string mTempTableName;
	string mTempTableFullName;
	int mArraySize;
	bool mUseBcpFlag;
	ColumnMappings mColumnMappings;
	ITransactionPtr mTransaction;
	MTPipelineLib::IMTTransactionPtr mMTTransaction;
	void TruncateTempTable(COdbcConnectionHandle & nonTrxConnection);
	vector<MTPipelineLib::IMTSessionPtr> mSessionArray;
	
	template <class T> void InsertInternal(T arStatement, COdbcConnectionHandle & nonTrxConnection);
	template <class T> void SetPipelineProperty(MTPipelineLib::IMTSessionPtr session, COdbcTempTableMapping* mapping, T & arStatement);

protected:
  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
  // connection will join pipeline transaction
	boost::shared_ptr<COdbcConnectionCommand> mTrxConnectionCommand;  
  // connection used for temp table BCP/array inserts and executes outside of pipeline transaction
	boost::shared_ptr<COdbcConnectionCommand> mNonTrxConnectionCommand;  
	//statement used for SQL server
	boost::shared_ptr<COdbcPreparedBcpStatementCommand> mBcpInsertToTmpTableStmtCommand;
	//statement used for Oracle
	boost::shared_ptr<COdbcPreparedInsertStatementCommand> mArrayInsertToTmpTableStmtCommand;
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
									

	bool IsOracle(){return mIsOracle;}
	MTPipelineLib::IMTTransactionPtr COdbcTableWriter::GetTransaction(MTPipelineLib::IMTSessionPtr aSession);

public:
	DllExport virtual ~COdbcTableWriter();

	DllExport vector<MTPipelineLib::IMTSessionPtr>& GetSessionVector() {return mSessionArray;}
	DllExport void Clear() {mSessionArray.clear();}

	DllExport COdbcTableWriter(
    MTPipelineLib::IMTLogPtr aLogger,
    MTPipelineLib::IMTNameIDPtr aNameID
    );

  //Performs database initialization:
	//1. Create Stage and Netmeter connections
	//2. Run DDL which is passed in for temp table creation. This DDL is run
	//	only for SQL server. For Oracle we expect this table to exist as global temporary table
	//3. Initialize BCP or array insert statement (depending on database type)
	//4. ???
	DllExport void InitializeDatabase(
									const string& aTempTableName, 
									const string& aTempTableFullName,
									const string& aTempTableReCreateDDL, 
									const int& aArraySize);


	//Sets up statically known mappings of temp table column name to pipeline property
	//It is possible that some properties can be determined dynamically during PluginProcessSessions
	//In this case this method should be called then with appropriate column offset.
	//If required flag is set, then exception is thrown if the property is not found in session
	//otherwise it will attempt to insert NULL into temp table
	DllExport void AddTempTableColumnMapping(	int aColumnOffset, 
																	MTPipelineLib::MTSessionPropType aSessionPropertyType, 
																	string& aSessionPropertyName,
																	bool aRequired);
	//overload, takes property idf instead of name
	DllExport void AddTempTableColumnMapping(	int aColumnOffset, 
																	MTPipelineLib::MTSessionPropType aSessionPropertyType, 
																	long aSessionPropertyID,
																	bool aRequired);


	//Create vector out of session set
	//Retrieve pipeline transaction and store it
	DllExport void InitializeFromSessionSet(MTPipelineLib::IMTSessionSetPtr aSessionSetPtr);

	//Call this method once after all the mappings were set up
	//1. Truncate temp table
	//2. Retrieve properties from sessions according to mappings and insert them
	//3. Throws a PIPE_ERR_SUBSET_OF_BATCH_FAILED COM error if one or more required
	//     properties are not found in thier session contexts.
	DllExport void InsertIntoTempTable();

	DllExport void ExecuteRowsetSelectInDistributedTransaction(ROWSETLib::IMTSQLRowsetPtr& aRs);
	DllExport ROWSETLib::IMTSQLRowset* ExecuteRowsetSelectInDistributedTransaction(const char* qstring);
	DllExport COdbcPreparedResultSetPtr COdbcTableWriter::ExecuteOdbcSelectInDistributedTransaction(const char* qstring);

	DllExport void ExecuteInsertInDistributedTransaction(string query);
  

};


#endif
