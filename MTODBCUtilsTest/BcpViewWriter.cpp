// BcpViewWriter.cpp: implementation of the CBcpViewWriter class.
//
//////////////////////////////////////////////////////////////////////

//#include "StdAfx.h"
//#include "bcp.h"
#include <metra.h>
#include "BcpViewWriter.h"

#include "OdbcConnection.h"
#include "OdbcPreparedBcpStatement.h"

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

CBcpViewWriter::CBcpViewWriter()
{
	mStatement = NULL;
	numRows = 0;
}

CBcpViewWriter::~CBcpViewWriter()
{
	delete mStatement;
}

BOOL CBcpViewWriter::Initialize(COdbcConnection* pConnection)
{
	//mConnection = pConnection;

	mStatement = pConnection->PrepareBcpInsertStatement("t_test_bcp_view", COdbcBcpHints());

	return TRUE;
}

int CBcpViewWriter::Finalize()
{
	int batchNumRows = mStatement->Finalize();
	numRows += batchNumRows;
	return batchNumRows;
}

int CBcpViewWriter::WriteBatch(int begin, int end)
{
	for(int i=begin; i<end; i++)
	{
/*
		mStatement->SetInteger("a", i);
		mStatement->SetInteger("b", i+1);
		mStatement->SetString("c", "this is a string");
		TIMESTAMP_STRUCT ts;
		ts.day = 2;
		ts.month = 2;
		ts.year = 1999;
		ts.hour = 2;
		ts.minute = 2;
		ts.second = 2;
		ts.fraction = 0;
		mStatement->SetDatetime("d", ts);

		SQL_NUMERIC_STRUCT num;
		num.precision = 18;
		num.scale = 6;
		num.sign = 1;
		memset(num.val, 0, sizeof(num.val));
		memcpy(num.val, &i, sizeof(i));
		mStatement->SetDecimal("e", num);
		mStatement->SetDouble("f", i + 9.98);
		mStatement->AddBatch();

  ////////////////////////////////////////////


  /////////////////////////////////////////////
		*(mStatement->GetIntegerRef(1)) = i;
		*(mStatement->GetIntegerRef(2)) = i+1;
		strcpy(mStatement->GetStringRef(3), "this is a string");

		mStatement->GetDatetimeRef(4)->dtdays = 1000;
		mStatement->GetDatetimeRef(4)->dttime = 2;

		mStatement->GetDecimalRef(5)->precision = 18;
		mStatement->GetDecimalRef(5)->scale = 6;
		mStatement->GetDecimalRef(5)->sign = 1;
		memset(mStatement->GetDecimalRef(5)->val, 0, sizeof(mStatement->GetDecimalRef(5)->val));
		memcpy(mStatement->GetDecimalRef(5)->val, &i, sizeof(i));

		*(mStatement->GetDoubleRef(6)) = i + 9.98;
		mStatement->AddBatch();
*/	
		mStatement->SetInteger(1, i);
		mStatement->SetInteger(2, i+1);
		mStatement->SetString(3, "this is a string");
		TIMESTAMP_STRUCT ts;
		ts.day = 2;
		ts.month = 2;
		ts.year = 1999;
		ts.hour = 2;
		ts.minute = 2;
		ts.second = 2;
		ts.fraction = 0;
		mStatement->SetDatetime(4, ts);

		SQL_NUMERIC_STRUCT num;
		num.precision = 18;
		num.scale = 6;
		num.sign = 1;
		memset(num.val, 0, sizeof(num.val));
		memcpy(num.val, &i, sizeof(i));
		mStatement->SetDecimal(5, num);
		// Test null handling
		if (i%2) mStatement->SetDouble(6, i + 9.98);
		
		unsigned char foo[16];
		memcpy(foo, "ddddddddddddddd", 16);
		mStatement->SetBinary(7, foo, 16);
		
		wstring wstr(L"This is a long string");
		mStatement->SetWideString(8, wstr);

		mStatement->AddBatch();
	}

	// Done with the batch
	int batchNumRows = mStatement->ExecuteBatch();
	ASSERT(batchNumRows == (end-begin));
	numRows += batchNumRows;
	
	return batchNumRows;
}
