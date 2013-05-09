#include <metra.h>
#include "ColumnArrayWriter.h"
#include "OdbcConnection.h"
#include "OdbcPreparedArrayStatement.h"

CColumnArrayWriter::CColumnArrayWriter(int aArraySize)
: arraySize(aArraySize), mStatement(NULL)
{
}

CColumnArrayWriter::~CColumnArrayWriter()
{
	delete mStatement;
}

bool CColumnArrayWriter::Initialize(COdbcConnection * pConnection)
{
	mStatement = pConnection->PrepareInsertStatement("t_test_bcp_view", arraySize);
	return TRUE;
}

bool CColumnArrayWriter::WriteBatch(int begin, int end)
{
	for(int i=begin, j=0; i<end; i++, j++)
	{
/*
		mStatement->SetInteger("a", i);
		mStatement->SetInteger("b", i+1);
		string str("This is a string");
		mStatement->SetString("c", str);

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
		mStatement->SetDouble("f", 99.283);
		mStatement->AddBatch();
*/
		mStatement->SetInteger(1, i);
		mStatement->SetInteger(2, i+1);
		string str("This is a string");
		mStatement->SetString(3, str);

		SYSTEMTIME sysTime;
		::GetSystemTime(&sysTime);
		TIMESTAMP_STRUCT ts;

		ts.year = sysTime.wYear; 
		ts.month = sysTime.wMonth; 
		ts.day = sysTime.wDay; 
		ts.hour = sysTime.wHour; 
		ts.minute = sysTime.wMinute; 
		ts.second = sysTime.wSecond; 
		ts.fraction = 0; 

		mStatement->SetDatetime(4, ts);

		SQL_NUMERIC_STRUCT num;
		num.precision = 18;
		num.scale = 6;
		num.sign = 1;
		memset(num.val, 0, sizeof(num.val));
		memcpy(num.val, &i, sizeof(i));
		mStatement->SetDecimal(5, num);
		mStatement->SetDouble(6, 99.283);

		unsigned char foo[16];
		memcpy(foo, "ddddddddddddddd", 16);
		mStatement->SetBinary(7, foo, 16);

		wstring wstr(L"This is a long string");
		mStatement->SetWideString(8, wstr);

		mStatement->AddBatch();
	}

	return TRUE;
}

int CColumnArrayWriter::SubmitBatch()
{
	int numRows=0;
	numRows += mStatement->ExecuteBatch();
	return numRows;
}

int CColumnArrayWriter::Finalize()
{
	return 0;
}

