#include <MSIXDefinition.h>
#include <OdbcStagingTable.h>
#include <OdbcConnMan.h>
#include <OdbcStatement.h>
#include <OdbcResultSet.h>
#include <propids.h>
#include <autoptr.h>
#include <vector>

typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef std::vector<COdbcColumnMetadata*> COdbcColumnMetadataVector;
#import <MetraTech.DataAccess.tlb>

COdbcStagingTable::COdbcStagingTable(COdbcConnection* aOdbcConnection,
                                     const string& aTableName,
                                     const string& aTableSuffix)
   :  mTargetTable(aTableName),
      mTableSuffix(aTableSuffix),
      mIsOracle(false),
      mQueryAdapter(MTPROGID_QUERYADAPTER)
{
  // Initialize the queryadapter ...
	mQueryAdapter->Init("\\Queries\\Database");

  //
  CreateCommands(aOdbcConnection);
}

COdbcStagingTable::COdbcStagingTable(
   COdbcConnection* aOdbcConnection,
   const COdbcConnectionInfo aOdbcConnectionInfo,
   const string& aProductViewTableName)
   :  mTargetTable(aProductViewTableName),
      mIsOracle(false)
{
	CreateCommands(aOdbcConnection);
}

COdbcStagingTable::~COdbcStagingTable()
{
	// Delete queries
	mInsertQueries.clear();
  mConstraintQueries.clear();
}

void COdbcStagingTable::CreateCommands(COdbcConnection* aOdbcConnection)
{
    // Is oracle?
    mIsOracle = (aOdbcConnection->GetConnectionInfo().GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);

    // Prepare a create table statement for the product view staging table
    string ddl(" (");
    string productViewSelectList;

    // Get column metadata for the product view, excluding core columns
    COdbcStatementPtr stmt = aOdbcConnection->CreateStatement();
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__SELECT_COLUMNS_ONLY_QUERY__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", mTargetTable.c_str());
    string query = mQueryAdapter->GetQuery();
    COdbcResultSetPtr rs = stmt->ExecuteQuery(query);

    COdbcColumnMetadataVector meta = rs->GetMetadata();
    COdbcColumnMetadataVector::iterator it = meta.begin();
    while (it != meta.end())
    {
      string columnName = (*it)->GetColumnName();

      if (it != meta.begin())
      {
          productViewSelectList += ", ";
          ddl += ", \n";
      }

      productViewSelectList += columnName;
      ddl += (*it)->GetSQLServerDDL();
      it ++;
    }
    rs->Close();

    mDDL = ddl += ")";

    // Insert into product view from product view stage
    InsertQueryPtr iq(new InsertQuery);
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__COPY_STAGE_TO_PV_QUERY__");
    mQueryAdapter->AddParam("%%DST_TABLE_NAME%%", mTargetTable.c_str());
    mQueryAdapter->AddParam("%%SRC_TABLE_NAME%%", GetName().c_str());
    mQueryAdapter->AddParam("%%COLUMN_LIST%%", productViewSelectList.c_str());
    iq->Query = mQueryAdapter->GetQuery();
    mInsertQueries.push_back(iq);

    // Unique key constraints
    AddUniqueKeyInsertQueries(aOdbcConnection);
}

typedef struct 
{
  string constraint_name;
  string nm_table_name;
} ConstraintInfo;

void COdbcStagingTable::AddUniqueKeyInsertQueries(COdbcConnection* aOdbcConnection)
{
	COdbcStatementPtr stmt = aOdbcConnection->CreateStatement();
	COdbcResultSetPtr rs;
  bool bPartitioningEnabled = false;

	// Unique key insert queries aren't used if partitioning isn't enabled
	try 
	{
		rs = stmt->ExecuteQuery("select b_partitioning_enabled from t_usage_server");

		if (!rs->Next())
			throw COdbcException("Unable to retrieve partitioning status from t_usage_server.");

		string enabled = rs->GetString(1);
		rs->Close();

		if (enabled == "N" || enabled == "n")
			bPartitioningEnabled = false;
    else 
      bPartitioningEnabled = true;
	}
	catch(...) 
	{
		rs->Close();
		throw;
	}

	try
	{
		// Get the product view's unique keys
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__GET_PV_UNIQUE_KEYS_QUERY__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", mTargetTable.c_str());
    string query = mQueryAdapter->GetQuery();
    rs = stmt->ExecuteQuery(query);

		vector<ConstraintInfo> uknames;
		int i = 0;
		while(rs->Next())
		{
      ConstraintInfo ci;
			ci.constraint_name = rs->GetString(1);
      ci.nm_table_name = rs->GetString(2);
      uknames.push_back(ci);
			i++;
		}
		rs->Close();

		// If there aren't any unique keys defined, return early
		if (i < 1)
			return;

		// Get a list of the key's columns
		vector<ConstraintInfo>::const_iterator iter;
		for (iter = uknames.begin(); iter != uknames.end(); ++iter)	
		{
      const ConstraintInfo& ci = *iter;

			// Select the unique key's columns
      mQueryAdapter->ClearQuery();
      mQueryAdapter->SetQueryTag("__SELECT_UK_COLUMNS_QUERY__");
      mQueryAdapter->AddParam("%%TABLE_NAME%%", ci.nm_table_name.c_str());
      string query = mQueryAdapter->GetQuery();
      rs = stmt->ExecuteQuery(query);

			// Build a csv of the unique key's columns and construct the insert statment
			int Count = 0;
			string ukSelectList;
      string GroupByList;
      string WhereClause;
      string key;
			while(rs->Next())
			{
        string column = rs->GetString(1);
				ukSelectList += column + ", ";
        GroupByList += "b." + column + ", ";
        WhereClause += "a." + column + "= b." + column + " and ";
        if (mIsOracle)
          key += "CAST(a." + column + " AS varchar2(200))||','||";
        else
          key += "CAST(a." + column + " AS varchar(200))+','+";

        Count++;
			}
			rs->Close();

			// chop trailing comma off the csv
			ukSelectList.resize(ukSelectList.size()-2);
      GroupByList.resize(GroupByList.size()-2);

      // chop trailing "+','+"    for mssql
      //            or "||','||"  for oracle
      key.resize(key.size() - (mIsOracle ? 7 : 5));

      // chop trailing "and"
      WhereClause.resize(WhereClause.size()-5);

			// couldn't find columns for this unique constraint.  this is an 
			// internal inconsistency.
			if (Count < 1)
				throw COdbcException("No columns found for unique key constraint [" + ci.nm_table_name + "]" );

      string strTableName;
      if (bPartitioningEnabled && !mIsOracle)
      {
          strTableName = ci.nm_table_name;

 			    // Construct the query and place in the query list
          InsertQueryPtr iq(new InsertQuery);
          mQueryAdapter->ClearQuery();
          mQueryAdapter->SetQueryTag("__INSERT_INTO_UK_TABLE_QUERY__");
          mQueryAdapter->AddParam("%%DST_TABLE_NAME%%", strTableName.c_str());
          mQueryAdapter->AddParam("%%SRC_TABLE_NAME%%", GetName().c_str());
          mQueryAdapter->AddParam("%%COLUMN_LIST%%", ukSelectList.c_str());
          iq->Query = mQueryAdapter->GetQuery();

          iq->ConstraintName = ci.constraint_name;
          mInsertQueries.push_back(iq);
      }
      else
          strTableName = mTargetTable;

      // Prepare the query to check for duplicate constraints.
      // Query will return a set of session id that are duplicate.
      ConstarintQueryPtr cq(new ConstarintQuery);
      cq->ConstraintName = ci.constraint_name;
     
      mQueryAdapter->ClearQuery();
      mQueryAdapter->SetQueryTag("__FIND_DUPLICATES_QUERY__");
      mQueryAdapter->AddParam("%%DST_TABLE_NAME%%", strTableName.c_str());
      mQueryAdapter->AddParam("%%SRC_TABLE_NAME%%", GetName().c_str());
      mQueryAdapter->AddParam("%%WHERE_CLAUSE%%", WhereClause.c_str());
      mQueryAdapter->AddParam("%%KEY_COLUMNS%%", key.c_str(), true);  // dont double quotes
      mQueryAdapter->AddParam("%%SELECT_COLUMNS%%", ukSelectList.c_str());
      mQueryAdapter->AddParam("%%GROUP_BY_LIST%%", GroupByList.c_str());
      cq->FindQuery = mQueryAdapter->GetQuery();

      // Query to get the duplicate session id's.
      mQueryAdapter->ClearQuery();
      mQueryAdapter->SetQueryTag("__GET_SESS_ID_QUERY__");
      cq->GetSessIdQuery = mQueryAdapter->GetQuery();

      // Prepare error code.
      MTautoptr<char> error = new char[ci.constraint_name.size()+ukSelectList.size()+strTableName.size()+1024];
      sprintf(error, "Violation of UNIQUE KEY constraint '%s', columns(%s), values(%%s). Cannot insert duplicate key in object '%s'. %%s",
              ci.constraint_name.c_str(), ukSelectList.c_str(), strTableName.c_str());
      cq->ErrorText = error;

      // Insert the summary about this query.
      mConstraintQueries.push_back(cq);

      // For Oracle we need to create a global temporary table.
      if (mIsOracle)
      {
        mQueryAdapter->ClearQuery();
        mQueryAdapter->SetQueryTag("__CREATE_TMP_DUPLICATES_TABLE__");
        string query = mQueryAdapter->GetQuery();
        stmt->ExecuteQuery(query);
      }
		} // for
	} // try
	catch(...)
	{
		rs->Close();
		throw;
	}
}

const vector<InsertQueryPtr>& COdbcStagingTable::GetInsertQueries() const
{
	return mInsertQueries;
}

const vector<ConstarintQueryPtr>& COdbcStagingTable::GetConstraintQueries() const
{
  return mConstraintQueries;
}

string COdbcStagingTable::GetSQLServerDDL()
{
  return "CREATE TABLE " + GetName() + mDDL;
}

string COdbcStagingTable::GetTruncateQuery()
{
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__TRUNCATE_STAGE_TABLE_QUERY__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", GetName().c_str());
    return (const char *) mQueryAdapter->GetQuery();
}

string COdbcStagingTable::GetCreateStageTableQuery()
{
    string ddl = "CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%" + GetName() + mDDL;
    mQueryAdapter->ClearQuery();
    mQueryAdapter->SetQueryTag("__CREATE_STAGE_TABLE_QUERY__");
    mQueryAdapter->AddParam("%%TABLE_NAME%%", GetName().c_str());
    mQueryAdapter->AddParam("%%CREATE_DDL%%", ddl.c_str());
    return (const char *) mQueryAdapter->GetQuery();
}

string COdbcStagingTable::GetName() const
{
  string Name(mTargetTable + mTableSuffix);
 	MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
  string hashed(nameHash->GetDBNameHash(Name.c_str()));
	return hashed;
}

// EOF
