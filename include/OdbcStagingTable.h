/**************************************************************************
* Copyright 1997-2006 by MetraTech
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

#ifndef _ODBCSTAGINGTABLE_H_
#define _ODBCSTAGINGTABLE_H_

#include <string>
using namespace std;

// Get rid of STL export Warning from compiler.
#pragma warning (disable : 4251)

// TODO: remove undefs
#if defined(MTODBCUTILS_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcConnection;
class CMSIXDefinition;
class COdbcConnectionInfo;

typedef struct
{
  string Query;            // Query to move data into pv table and/or pv uk table from stage table 
  string ConstraintName;    // Only if query is insert into pv uk table.
} InsertQuery;
typedef MTautoptr<InsertQuery> InsertQueryPtr;

typedef struct
{
  string FindQuery;         // Query to detect duplicate constraint violation
  string ConstraintName;    // Name of Constraint.
  string GetSessIdQuery;    // Return duplicate session id's
  string ErrorText;         // Error text to display when violation if encoundered
} ConstarintQuery;
typedef MTautoptr<ConstarintQuery> ConstarintQueryPtr;

#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

///////////////////////////////////////////////////
// COdbcStagingTable
// Represents a staging table base class
//////////////////////////////////////////////////
class DllExport COdbcStagingTable
{
  private:
	  string mTargetTable;
	  string mDDL;
	  string mTableSuffix;
    bool mIsOracle;
    IMTQueryAdapterPtr mQueryAdapter;


    // An ordered list of insert stmts for a session set.
    vector<InsertQueryPtr> mInsertQueries;
    vector<ConstarintQueryPtr> mConstraintQueries;

	  void CreateCommands(COdbcConnection* aOdbcConnection);
 	  void AddUniqueKeyInsertQueries(COdbcConnection* aOdbcConnection);

  public:
	  COdbcStagingTable(COdbcConnection* aOdbcConnection,
										  const string& aTableName,
										  const string& aTableSuffix);
	  COdbcStagingTable(COdbcConnection* aOdbcConnection,
										  const COdbcConnectionInfo aOdbcConnectionInfo,
										  const string& aTableName);
	  ~COdbcStagingTable();

	  const vector<InsertQueryPtr>& GetInsertQueries() const;
    const vector<ConstarintQueryPtr>& GetConstraintQueries() const;
    string GetTruncateQuery();
    string GetSQLServerDDL();
    string GetCreateStageTableQuery();
	  string GetName() const;
};

#endif