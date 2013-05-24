// OdbcStatementGenerator.h: interface for the COdbcStatementGenerator class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ODBCSTATEMENTGENERATOR_H__C21806B3_A5EC_4ECC_8C45_D28A09DD0234__INCLUDED_)
#define AFX_ODBCSTATEMENTGENERATOR_H__C21806B3_A5EC_4ECC_8C45_D28A09DD0234__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <string> 
using namespace std;

#include "OdbcColumnMetadata.h"

class COdbcConnection;
class COdbcMetadata;

class COdbcStatementGenerator  
{
private:
	COdbcConnection* mConnection;
	COdbcMetadata* mMetadata;
	string mTableName;
public:
	string CreateInsertStatement(const COdbcColumnMetadataVector& aMetadata);
	void SetTable(const string& name);
	string GetInsertStatement();
	COdbcStatementGenerator(COdbcConnection* aConnection);
	virtual ~COdbcStatementGenerator();

	COdbcColumnMetadataVector GetColumns();
};

#endif // !defined(AFX_ODBCSTATEMENTGENERATOR_H__C21806B3_A5EC_4ECC_8C45_D28A09DD0234__INCLUDED_)
