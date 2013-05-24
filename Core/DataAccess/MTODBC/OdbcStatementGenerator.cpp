// OdbcStatementGenerator.cpp: implementation of the COdbcStatementGenerator class.
//
//////////////////////////////////////////////////////////////////////
#pragma warning( disable : 4786 ) 

//#include "bcp.h"
#include <metra.h>
#include <MTUtil.h>
#include "OdbcStatementGenerator.h"
#include "OdbcMetadata.h"
#include "OdbcConnection.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"

/*
#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
*/

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

COdbcStatementGenerator::COdbcStatementGenerator(COdbcConnection* aConnection) : mConnection(aConnection)
{
	mMetadata = new COdbcMetadata(mConnection);
}

COdbcStatementGenerator::~COdbcStatementGenerator()
{
	delete mMetadata;
}

string COdbcStatementGenerator::GetInsertStatement()
{
#ifdef BUILD_SQL_SERVER
	return CreateInsertStatement(GetColumns());
#else

	COdbcStatement* stmt = mConnection->CreateStatement();
   string cat = mConnection->GetConnectionInfo().GetCatalogPrefix();
	COdbcResultSet* rs = stmt->ExecuteQuery("select * from " + cat + mTableName + " where 0=1");
	string insertQuery = CreateInsertStatement(rs->GetMetadata());
	delete rs;
	delete stmt;
	return insertQuery;
#endif
}

string COdbcStatementGenerator::CreateInsertStatement(const COdbcColumnMetadataVector& aMetadata)
{
	// Generate insert statement that inserts all columns
	string paramList;
	string valuesList;

	for(unsigned int i=0; i<aMetadata.size(); i++)
	{
		if(i>0)
		{
			paramList += ", ";
			valuesList += ", ";
		}
		paramList += aMetadata[i]->GetColumnName();
		valuesList += "?";
		// Either there is no table name (e.g. Oracle) or it should be the name of the table
		// whose insert statement we are generating.
		ASSERT (aMetadata[i]->GetTableName() == "" || stricmp(aMetadata[i]->GetTableName().c_str(), mTableName.c_str()));
	}
	return "insert into " + mConnection->GetConnectionInfo().GetCatalogPrefix() 
      + mTableName + " (" + paramList + ") values (" + valuesList + ")";
}

void COdbcStatementGenerator::SetTable(const string &name)
{
	mTableName = name;
}

COdbcColumnMetadataVector COdbcStatementGenerator::GetColumns()
{
	return mMetadata->GetColumnMetadata(mConnection->GetConnectionInfo().GetCatalog(), mTableName);
}
