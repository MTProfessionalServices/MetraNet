#ifndef _BATCHQUERY_H_
#define _BATCHQUERY_H_

#include "metralite.h"
#include "MTSQLConfig.h"

#include <string>
#include <vector>
#include <boost/shared_ptr.hpp>

#ifndef WIN32
// Forward declaration
class ITransaction;
#endif

#include "Symbol.h"
#include "OdbcConnection.h"
#include "OdbcException.h"
#include "OdbcStatement.h"
#include "OdbcPreparedBcpStatement.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcResultSet.h"
#include "OdbcConnMan.h"
#include "OdbcSessionTypeConversion.h"
#include "OdbcResourceManager.h"
typedef boost::shared_ptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef boost::shared_ptr<COdbcResultSet> COdbcResultSetPtr;
typedef boost::shared_ptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef boost::shared_ptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef boost::shared_ptr<COdbcConnection> COdbcConnectionPtr;
typedef boost::shared_ptr<COdbcStatement> COdbcStatementPtr;

class BatchQuery
{
private:
  std::string mDdl;
  std::wstring mDml;
  std::string mInsert;
  std::string mTable;
  std::vector<VarEntryPtr> mParameterBindings;
  std::vector<VarEntryPtr> mResultBindings;

  MTAutoSingleton<COdbcResourceManager> mOdbcManager;
  boost::shared_ptr<COdbcConnectionCommand> mConnectionCommand;
  //stage connection  - needed only for Oracle
  boost::shared_ptr<COdbcConnectionCommand> mStageConnectionCommand;
  boost::shared_ptr<COdbcPreparedBcpStatementCommand> mInsertStatementCommand;
  boost::shared_ptr<COdbcPreparedInsertStatementCommand> mOracleInsertStatementCommand;

  bool Match(const COdbcColumnMetadata * metadata, int mtsqlType);
  std::string ToString(const COdbcColumnMetadata * metadata);
  std::string ToString(int mtsqlType);
  bool mIsOracle;
  int mArraySize;
  
public:
  MTSQL_DECL BatchQuery(const string& create, const string& insert, const wstring& dml, const string& table, const vector<VarEntryPtr>& params, const vector<VarEntryPtr>& outputs);

  MTSQL_DECL ~BatchQuery();
  // Binds the parameters of the query to the activation record (i.e. sets
  // parameters of the query from the activation record).
  // Creates and returns the request identifier for the query.
  MTSQL_DECL void BindParameters(ActivationRecord * record, int i);
  template <class T>
	void BindParameters(T arStatement, ActivationRecord * record, int i);

//  COdbcResultSet* ExecuteQueryInternal();

  // Bind parameters to inputs and set outputs.
  // TODO: What is proper behavior if multiple records retrieve for some request?
  MTSQL_DECL void ExecuteQuery(std::vector<ActivationRecord *>& activations, ITransaction * pTrans = NULL);

  // Execute the query for all requests simultaneously.
  // Results are returned with the "requestid" column identifying
  // the request to which a row belongs.
//   IMTRowSet* ExecuteQuery();
};

#endif
