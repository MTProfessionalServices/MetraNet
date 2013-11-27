#include <metra.h>
#include <iostream>

#include "OdbcConnection.h"
#include "OdbcPreparedBcpStatement.h"
#include "BcpViewWriter.h"
#include "ColumnArrayWriter.h"
#include "DistributedTransaction.h"
#include "OdbcException.h"
#include "OdbcIdGenerator.h"

#include "OdbcConnMan.h"
#include <OdbcStagingTable.h>

#include "OdbcPreparedArrayStatement.h"
#include "OdbcResultSet.h"

#include "AsyncTask.h"

#include <autoptr.h>

using namespace std;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;
typedef MTautoptr<COdbcIdGenerator> COdbcIdGeneratorPtr;

#if 0

static int SimpleRandomize(int seed)
{
	return (16807*seed) % 2147483647;
}

static void TestIdGenerator()
{
	try {
		COdbcConnectionInfo info("TEMPQA4", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);
		int id = gen.GetNext();
		cout << "Next Id = " << id << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	} catch (std::exception& stlException) {
		cerr << stlException.what() << endl;
	}
}

static void TestBcp()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 1000000;
		int m_dwCommitInterval = 1000;
	
		COdbcConnectionInfo info("AMAZON", "NetMeter", "sa", "");
		COdbcConnection odbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		odbcConnection.SetAutoCommit(false);

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(&odbcConnection);
		CBcpViewWriter writer;
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		writer.Initialize(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			numRows += writer.WriteBatch(i, i+m_dwCommitInterval);
			txStream.EndTransaction();
			txStream.BeginTransaction();
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		numRows += writer.Finalize();
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: BCP done took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestBcpNonLogged()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 5000;
	
		COdbcConnectionInfo info("TEMPQA4", "NetMeterStage", "sa", "");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);
		COdbcPreparedBcpStatementPtr bcpStatement = odbcConnection->PrepareBcpInsertStatement("t_test_bcp_full", hints);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				bcpStatement->SetInteger(1, i);
				bcpStatement->SetInteger(2, i+1);
				bcpStatement->SetString(3, "this is a string");
				TIMESTAMP_STRUCT ts;
				ts.day = 2;
				ts.month = 2;
				ts.year = 1999;
				ts.hour = 2;
				ts.minute = 2;
				ts.second = 2;
				ts.fraction = 0;
				bcpStatement->SetDatetime(4, ts);

				SQL_NUMERIC_STRUCT num;
				num.precision = 18;
				num.scale = 6;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &i, sizeof(i));
				bcpStatement->SetDecimal(5, num);
				// Test null handling
				if (i%2) bcpStatement->SetDouble(6, i + 9.98);
		
				unsigned char foo[16];
				memcpy(foo, "ddddddddddddddd", 16);
				bcpStatement->SetBinary(7, foo, 16);
		
				wstring wstr(L"This is a long string");
				bcpStatement->SetWideString(8, wstr);

				bcpStatement->AddBatch();
			}
			numRows += bcpStatement->ExecuteBatch();

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		numRows += bcpStatement->Finalize();
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: BCP done took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));

		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestBcpToTempTable()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 10000;
		int m_dwCommitInterval = 500;
	
		COdbcConnectionInfo info("TEMPQA4", "NetMeter", "sa", "");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		COdbcStatementPtr createTempTable = odbcConnection->CreateStatement();
		createTempTable->ExecuteUpdate("create table #t_arg_getrateschedules ("
																 "id_request int, "
																 "id_acc int, "
																 "acc_cycle_id int, "
																 "default_pl int, "
																 "id_pi_template int)");
		//odbcConnection->CommitTransaction();


		COdbcStatementPtr truncateTempTable = odbcConnection->CreateStatement();
		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedBcpStatementPtr bcpStatement = odbcConnection->PrepareBcpInsertStatement("#t_arg_getrateschedules", COdbcBcpHints());
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				bcpStatement->SetInteger(1, i+j);
				bcpStatement->SetInteger(2, i+j);
				bcpStatement->SetInteger(3, i+j);
				bcpStatement->SetInteger(4, i+j);
				bcpStatement->SetInteger(5, i+j);
				bcpStatement->AddBatch();
			}
			numRows += bcpStatement->ExecuteBatch();

			// The bcp activity occurs in the context of a local transaction
			//odbcConnection->CommitTransaction();

			// Verify that we can join a distributed transaction while the
			// bcp session is still active.
			txStream.EndTransaction();
			txStream.BeginTransaction();
			// Testing to see if I can truncate the table between a call to bcp_batch and bcp_sendrow
			truncateTempTable->ExecuteUpdate("insert into NetMeter.dbo.t_target select * from #t_arg_getrateschedules");
			truncateTempTable->ExecuteUpdate("truncate table #t_arg_getrateschedules");
			txStream.EndTransaction();
			txStream.BeginTransaction();
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		numRows += bcpStatement->Finalize();
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: BCP done took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestBcpToTwoTables()
{
	// Note there seems to be a restriction on use of DTC with BCP; it looks as though
	// there can only be one BCP batch open at a time.  
	
	try {
		bool m_bUseDTC = true;
		int m_dwNumRows = 10000;
		int m_dwCommitInterval = 500;
	
		COdbcConnectionInfo info("TEMPQA4", "NetMeter", "sa", "");
		COdbcConnectionPtr odbcConnectionA = new COdbcConnection(info);
		COdbcConnectionPtr odbcConnectionB = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		COdbcStatementPtr createTempTableA = odbcConnectionA->CreateStatement();
		createTempTableA->ExecuteUpdate("create table #t_temp_table_a ("
																 "id_request int)");

		COdbcStatementPtr createTempTableB = odbcConnectionB->CreateStatement();
		createTempTableB->ExecuteUpdate("create table #t_temp_table_b ("
																 "id_request int)");


		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnectionA);
		txStream.Subscribe(odbcConnectionB);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedBcpStatementPtr bcpStatementA = odbcConnectionA->PrepareBcpInsertStatement("#t_temp_table_a", COdbcBcpHints());
		COdbcPreparedBcpStatementPtr bcpStatementB = odbcConnectionB->PrepareBcpInsertStatement("#t_temp_table_b", COdbcBcpHints());
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			int j;
/*
			for (j=0; j<m_dwCommitInterval; j++)
			{
				bcpStatementA->SetInteger(1, i+j);
				bcpStatementA->AddBatch();
			}
			numRows += bcpStatementA->ExecuteBatch();

			for (j=0; j<m_dwCommitInterval; j++)
			{
				bcpStatementB->SetInteger(1, i+j);
				bcpStatementB->AddBatch();
			}
			numRows += bcpStatementB->ExecuteBatch();
*/
			for (j=0; j<m_dwCommitInterval; j++)
			{
				bcpStatementA->SetInteger(1, i+j);
				bcpStatementA->AddBatch();
				bcpStatementB->SetInteger(1, i+j);
				bcpStatementB->AddBatch();
			}
			numRows += bcpStatementA->ExecuteBatch();
			numRows += bcpStatementB->ExecuteBatch();
			// The bcp activity occurs in the context of a local transaction
			//odbcConnection->CommitTransaction();

			// Verify that we can join a distributed transaction while the
			// bcp session is still active.
			txStream.EndTransaction();
			txStream.BeginTransaction();
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		numRows += bcpStatementA->Finalize();
		numRows += bcpStatementB->Finalize();
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnectionA);
		txStream.Unsubscribe(&odbcConnectionB);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: BCP done took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsage()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 2500000;
		int m_dwCommitInterval = 1000;
	
		COdbcConnectionInfo info("LONDON", "NetMeterStage", "sa", "");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		COdbcConnectionInfo netMeterInfo("LONDON", "NetMeter", "sa", "");
		COdbcIdGenerator gen(netMeterInfo);
		COdbcConnectionPtr netMeterConnection = new COdbcConnection(netMeterInfo);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = netMeterConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		// Close up the result set.
		rs->Close();
		rs = COdbcResultSetPtr(NULL);


		COdbcStatementPtr truncateStmt = odbcConnection->CreateStatement();

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);
		COdbcPreparedBcpStatementPtr bcpStatement = odbcConnection->PrepareBcpInsertStatement("t_acc_usage", hints);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				bcpStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				bcpStatement->SetBinary(2, tx_UID, 16);
				bcpStatement->SetInteger(3, 123);
				bcpStatement->SetInteger(4, id_view);
				bcpStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//bcpStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//bcpStatement->SetInteger(7, 0);
				// id_svc same as id_view
				bcpStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				bcpStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				bcpStatement->SetDecimal(10, amount);

				string am_currency("USD");
				bcpStatement->SetString(11, am_currency);
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				bcpStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//bcpStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//bcpStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//bcpStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//bcpStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//bcpStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//bcpStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//bcpStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//bcpStatement->SetInteger(20, 0);

				bcpStatement->AddBatch();
			}
			numRows += bcpStatement->ExecuteBatch();
			getNameID->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_acc_usage SELECT * FROM NetMeterStage.dbo.t_acc_usage");
			truncateStmt->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo.t_acc_usage");
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		numRows += bcpStatement->Finalize();
		getNameID->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_acc_usage SELECT * FROM NetMeterStage.dbo.t_acc_usage");
		truncateStmt->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo.t_acc_usage");
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: BCP done took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));

		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestArrayToAccUsageHostedExchange()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 100;
	
		COdbcConnectionInfo info("LONDON", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		odbcConnection->SetAutoCommit(false);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("t_acc_usage", m_dwCommitInterval);
		COdbcPreparedArrayStatementPtr hostedExchangeStatement = odbcConnection->PrepareInsertStatement("t_pv_hostedexchange1", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

				// Now write to t_pv_hostedexchange1
				hostedExchangeStatement->SetInteger(1, id);
				hostedExchangeStatement->SetString(2, "c_CompanyName...................");
				hostedExchangeStatement->SetString(3, "c_AccountName...................");
				int planId = 4444;
				hostedExchangeStatement->SetInteger(4, planId);
				int channelId = 5555;
				hostedExchangeStatement->SetInteger(5, channelId);
				hostedExchangeStatement->SetString(6, "namespace.......................");
				hostedExchangeStatement->SetString(7, "batchid.........");
				SQL_NUMERIC_STRUCT currentUsage;
				currentUsage.precision = 18;
				currentUsage.scale = 6;
				currentUsage.sign = 1;
				memset(currentUsage.val, 0, sizeof(currentUsage.val));
				memcpy(currentUsage.val, &i, sizeof(i));
				hostedExchangeStatement->SetDecimal(8, currentUsage);

				hostedExchangeStatement->AddBatch();
			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			int hostedExchangeRows = hostedExchangeStatement->ExecuteBatch();
			ASSERT(accUsageRows == hostedExchangeRows);
			numRows += accUsageRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestArrayToAccUsageHostedExchangeView()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 500000;
		int m_dwCommitInterval = 100;
	
		COdbcConnectionInfo info("LONDON", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		odbcConnection->SetAutoCommit(false);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		odbcConnection->SetTransactionIsolation(COdbcConnection::READ_UNCOMMITTED);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("t_vw_hostedexchange1", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				// Now write to t_pv_hostedexchange1
				accUsageStatement->SetString(21, "c_CompanyName...................");
				accUsageStatement->SetString(22, "c_AccountName...................");
				int planId = 4444;
				accUsageStatement->SetInteger(23, planId);
				int channelId = 5555;
				accUsageStatement->SetInteger(24, channelId);
				accUsageStatement->SetString(25, "namespace.......................");
				accUsageStatement->SetString(26, "batchid.........");
				SQL_NUMERIC_STRUCT currentUsage;
				currentUsage.precision = 18;
				currentUsage.scale = 6;
				currentUsage.sign = 1;
				memset(currentUsage.val, 0, sizeof(currentUsage.val));
				memcpy(currentUsage.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(27, currentUsage);

				accUsageStatement->AddBatch();
			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			numRows += accUsageRows;
			odbcConnection->CommitTransaction();
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		odbcConnection->CommitTransaction();
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsageHostedExchange()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 1000000;
		int m_dwCommitInterval = 1000;
	
		COdbcConnectionInfo info("LONDON", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		COdbcConnectionPtr odbcConnection2 = new COdbcConnection(info);

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		txStream.Subscribe(odbcConnection2);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedBcpStatementPtr accUsageStatement = odbcConnection->PrepareBcpInsertStatement("t_acc_usage", COdbcBcpHints());
		COdbcPreparedBcpStatementPtr hostedExchangeStatement = odbcConnection2->PrepareBcpInsertStatement("t_pv_hostedexchange1", COdbcBcpHints());
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

				// Now write to t_pv_hostedexchange1
				hostedExchangeStatement->SetInteger(1, id);
				hostedExchangeStatement->SetString(2, "c_CompanyName...................");
				hostedExchangeStatement->SetString(3, "c_AccountName...................");
				int planId = 4444;
				hostedExchangeStatement->SetInteger(4, planId);
				int channelId = 5555;
				hostedExchangeStatement->SetInteger(5, channelId);
				hostedExchangeStatement->SetString(6, "namespace.......................");
				hostedExchangeStatement->SetString(7, "batchid.........");
				SQL_NUMERIC_STRUCT currentUsage;
				currentUsage.precision = 18;
				currentUsage.scale = 6;
				currentUsage.sign = 1;
				memset(currentUsage.val, 0, sizeof(currentUsage.val));
				memcpy(currentUsage.val, &i, sizeof(i));
				hostedExchangeStatement->SetDecimal(8, currentUsage);

				hostedExchangeStatement->AddBatch();
			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			int hostedExchangeRows = hostedExchangeStatement->ExecuteBatch();
			ASSERT(accUsageRows == hostedExchangeRows);
			numRows += accUsageRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		txStream.Unsubscribe(&odbcConnection2);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestArrayToAccUsageTestService()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 100;

		LARGE_INTEGER subtick, subtock;
		__int64 sendRowTicks=0;
		__int64 batchTicks=0;
		__int64 ticksPerSecond;

		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		odbcConnection->SetAutoCommit(false);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);

		ticksPerSecond = freq.QuadPart;
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("t_acc_usage", m_dwCommitInterval);
		COdbcPreparedArrayStatementPtr testServiceStatement = odbcConnection->PrepareInsertStatement("t_pv_testservice", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array Prepare took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			::QueryPerformanceCounter(&subtick);
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

				// Now write to t_pv_testservice
				testServiceStatement->SetBigInteger(1, id);
				testServiceStatement->SetString(2, "c_description...................");
				testServiceStatement->SetDatetime(3, dt_crt);
				testServiceStatement->SetDecimal(4, amount);
				testServiceStatement->SetDecimal(5, amount);
				testServiceStatement->SetDecimal(6, amount);
				testServiceStatement->SetDecimal(7, amount);

				testServiceStatement->AddBatch();
			}
			::QueryPerformanceCounter(&subtock);
			sendRowTicks += (subtock.QuadPart - subtick.QuadPart);
			::QueryPerformanceCounter(&subtick);
			int accUsageRows = accUsageStatement->ExecuteBatch();
			int testServiceRows = testServiceStatement->ExecuteBatch();
			txStream.EndTransaction();
			ASSERT(accUsageRows == testServiceRows);
			numRows += accUsageRows;
			::QueryPerformanceCounter(&subtock);
			batchTicks += (subtock.QuadPart - subtick.QuadPart);

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Array Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Array Write Rows %d rows in %d milliseconds", (long) numRows, (long) ((1000*sendRowTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Array Execute %d rows in %d milliseconds", (long) numRows, (long) ((1000*batchTicks)/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Array Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsageTestService()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 1000000;
		int m_dwCommitInterval = 1000;

		LARGE_INTEGER subtick, subtock;
		__int64 sendRowTicks=0;
		__int64 batchTicks=0;
		__int64 ticksPerSecond;

		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		COdbcConnectionPtr odbcConnection2 = new COdbcConnection(info);

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		txStream.Subscribe(odbcConnection2);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);

		ticksPerSecond = freq.QuadPart;
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedBcpStatementPtr accUsageStatement = odbcConnection->PrepareBcpInsertStatement("t_acc_usage", COdbcBcpHints());
		COdbcPreparedBcpStatementPtr testServiceStatement = odbcConnection2->PrepareBcpInsertStatement("t_pv_testservice", COdbcBcpHints());
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			::QueryPerformanceCounter(&subtick);
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

				// Now write to t_pv_testservice
				testServiceStatement->SetBigInteger(1, id);
				testServiceStatement->SetString(2, "c_description...................");
				testServiceStatement->SetDatetime(3, dt_crt);
				testServiceStatement->SetDecimal(4, amount);
				testServiceStatement->SetDecimal(5, amount);
				testServiceStatement->SetDecimal(6, amount);
				testServiceStatement->SetDecimal(7, amount);

				testServiceStatement->AddBatch();
			}
			::QueryPerformanceCounter(&subtock);
			sendRowTicks += (subtock.QuadPart - subtick.QuadPart);
			::QueryPerformanceCounter(&subtick);
			int accUsageRows = accUsageStatement->ExecuteBatch();
			int testServiceRows = testServiceStatement->ExecuteBatch();
			ASSERT(accUsageRows == testServiceRows);
			numRows += accUsageRows;
			::QueryPerformanceCounter(&subtock);
			batchTicks += (subtock.QuadPart - subtick.QuadPart);

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Send Rows %d rows in %d milliseconds", (long) numRows, (long) ((1000*sendRowTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Batch %d rows in %d milliseconds", (long) numRows, (long) ((1000*batchTicks)/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		txStream.Unsubscribe(&odbcConnection2);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsageTestServiceStage()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 400000;
		int m_dwCommitInterval = 1000;
	
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		// The rest of the stuff goes against the staging database
		odbcConnection->SetSchema("NetMeterStage");

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);
		hints.AddOrder("id_sess");
		COdbcPreparedBcpStatementPtr testServiceStatement = odbcConnection->PrepareBcpInsertStatement("t_pv_testservice_stage", hints);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				testServiceStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				testServiceStatement->SetBinary(2, tx_UID, 16);
				testServiceStatement->SetInteger(3, 123);
				testServiceStatement->SetInteger(4, id_view);
				testServiceStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//testServiceStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//testServiceStatement->SetInteger(7, 0);
				// id_svc same as id_view
				testServiceStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				testServiceStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				testServiceStatement->SetDecimal(10, amount);

				string am_currency("USD");
				testServiceStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				testServiceStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//testServiceStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//testServiceStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//testServiceStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//testServiceStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//testServiceStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//testServiceStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//testServiceStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//testServiceStatement->SetInteger(20, 0);

				// Now write to t_pv_testservice
				testServiceStatement->SetString(21, "c_description...................");
				testServiceStatement->SetDatetime(22, dt_crt);
				testServiceStatement->SetDecimal(23, amount);
				testServiceStatement->SetDecimal(24, amount);
				testServiceStatement->SetDecimal(25, amount);
				testServiceStatement->SetDecimal(26, amount);

				testServiceStatement->AddBatch();
			}
			int testServiceRows = testServiceStatement->ExecuteBatch();
			numRows += testServiceRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		testServiceStatement->Finalize();
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsageTestServiceStageMoveToNetMeter()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 500000;
		int m_dwCommitInterval = 1000;
	
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcIdGenerator gen(info);

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		COdbcConnectionPtr odbcConnection2 = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		COdbcStatementPtr bcpConnectionStmt = odbcConnection->CreateStatement();
		COdbcStatementPtr connectionStmt = odbcConnection2->CreateStatement();

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		// The rest of the stuff goes against the staging database
		odbcConnection->SetSchema("NetMeterStage");

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceFrequency(&freq);
	
		__int64 sendRowTicks=0;
		__int64 batchTicks=0;
		__int64 accUsageTicks=0;
		__int64 testServiceTicks=0;
		__int64 truncateTicks=0;

		::QueryPerformanceCounter(&tick);
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);
		hints.AddOrder("id_sess");
		COdbcPreparedBcpStatementPtr testServiceStatement = odbcConnection->PrepareBcpInsertStatement("t_pv_testservice_stage", hints);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			::QueryPerformanceCounter(&subtick);
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen.GetNext();
				testServiceStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				testServiceStatement->SetBinary(2, tx_UID, 16);
				testServiceStatement->SetInteger(3, 123);
				testServiceStatement->SetInteger(4, id_view);
				testServiceStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//testServiceStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//testServiceStatement->SetInteger(7, 0);
				// id_svc same as id_view
				testServiceStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				testServiceStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				testServiceStatement->SetDecimal(10, amount);

				string am_currency("USD");
				testServiceStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				testServiceStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//testServiceStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//testServiceStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//testServiceStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//testServiceStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//testServiceStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//testServiceStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//testServiceStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//testServiceStatement->SetInteger(20, 0);

				// Now write to t_pv_testservice
				testServiceStatement->SetString(21, "c_description...................");
				testServiceStatement->SetDatetime(22, dt_crt);
				testServiceStatement->SetDecimal(23, amount);
				testServiceStatement->SetDecimal(24, amount);
				testServiceStatement->SetDecimal(25, amount);
				testServiceStatement->SetDecimal(26, amount);

				testServiceStatement->AddBatch();
			}
			::QueryPerformanceCounter(&subtock);
			sendRowTicks += (subtock.QuadPart - subtick.QuadPart);
			::QueryPerformanceCounter(&subtick);
			int testServiceRows = testServiceStatement->ExecuteBatch();
			::QueryPerformanceCounter(&subtock);
			numRows += testServiceRows;
			batchTicks += (subtock.QuadPart - subtick.QuadPart);
			// Move rows to t_acc_usage and truncate
			::QueryPerformanceCounter(&subtick);
			connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_acc_usage SELECT id_sess, tx_UID, id_acc, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template FROM NetMeterStage.dbo.t_pv_testservice_stage");
			::QueryPerformanceCounter(&subtock);
			accUsageTicks += (subtock.QuadPart - subtick.QuadPart);
			::QueryPerformanceCounter(&subtick);
			connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_pv_testservice SELECT id_sess, c_description, c_time, c_units, c_DecProp1, c_DecProp2, c_DecProp3 FROM NetMeterStage.dbo.t_pv_testservice_stage");
			::QueryPerformanceCounter(&subtock);
			testServiceTicks += (subtock.QuadPart - subtick.QuadPart);
			// Do this piece within the bcp transaction
			::QueryPerformanceCounter(&subtick);
			bcpConnectionStmt->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo.t_pv_testservice_stage");
			::QueryPerformanceCounter(&subtock);
			truncateTicks += (subtock.QuadPart - subtick.QuadPart);
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Send Rows %d rows in %d milliseconds", (long) numRows, (long) ((1000*sendRowTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Batch %d rows in %d milliseconds", (long) numRows, (long) ((1000*batchTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_acc_usage %d rows in %d milliseconds", (long) numRows, (long) ((1000*accUsageTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_pv_testservice %d rows in %d milliseconds", (long) numRows, (long) ((1000*testServiceTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: TRUNCATE %d rows in %d milliseconds", (long) numRows, (long) ((1000*truncateTicks)/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		testServiceStatement->Finalize();
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Finalize took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

class BcpStageWrite
{
public:
	int numRecords;
	int recordsWritten;
	__int64 sendRowTicks;
	__int64 batchTicks;
};

class CAsyncBcpStageWriter : public CAsyncTask<BcpStageWrite>
{
private:
	COdbcPreparedBcpStatementPtr testServiceStatement;
	COdbcConnectionPtr mConnection;
	COdbcIdGeneratorPtr gen;
	int id_view;
	string mTable;
protected:

	virtual void ProcessRequest(BcpStageWrite* aRequest)
	{
		ProcessRequest(aRequest->numRecords, 
									 aRequest->recordsWritten, 
									 aRequest->sendRowTicks, 
									 aRequest->batchTicks);
	}

public:
	CAsyncBcpStageWriter(MTPipelineLib::IMTLogPtr aLogger, 
											 const string& aTable, 
											 COdbcConnectionPtr aOdbcConnection,
											 int a_id_view)
		:
		CAsyncTask<BcpStageWrite>(aLogger),
		id_view(a_id_view),
		mConnection(aOdbcConnection),
		mTable(aTable)
	{
		COdbcBcpHints hints;
		hints.SetMinimallyLogged(true);
		hints.AddOrder("id_sess");
		testServiceStatement = aOdbcConnection->PrepareBcpInsertStatement(aTable, hints);

		gen = new COdbcIdGenerator(aOdbcConnection->GetConnectionInfo());
	}

	void ProcessRequest(int numRecords, int& recordsWritten, __int64& sendRowTicks, __int64& batchTicks)
	{
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
			::QueryPerformanceCounter(&subtick);
			for (int j=0; j<numRecords; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = gen->GetNext();
				testServiceStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				testServiceStatement->SetBinary(2, tx_UID, 16);
				testServiceStatement->SetInteger(3, 123);
				testServiceStatement->SetInteger(4, id_view);
				testServiceStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//testServiceStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//testServiceStatement->SetInteger(7, 0);
				// id_svc same as id_view
				testServiceStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				testServiceStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &j, sizeof(j));
				testServiceStatement->SetDecimal(10, amount);

				string am_currency("USD");
				testServiceStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				testServiceStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//testServiceStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//testServiceStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//testServiceStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//testServiceStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//testServiceStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//testServiceStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//testServiceStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//testServiceStatement->SetInteger(20, 0);

				// Now write to t_pv_testservice
				testServiceStatement->SetString(21, "c_description...................");
				testServiceStatement->SetDatetime(22, dt_crt);
				testServiceStatement->SetDecimal(23, amount);
				testServiceStatement->SetDecimal(24, amount);
				testServiceStatement->SetDecimal(25, amount);
				testServiceStatement->SetDecimal(26, amount);

				testServiceStatement->AddBatch();
			}
			::QueryPerformanceCounter(&subtock);
			sendRowTicks = (subtock.QuadPart - subtick.QuadPart);
			::QueryPerformanceCounter(&subtick);
			recordsWritten = testServiceStatement->ExecuteBatch();
			::QueryPerformanceCounter(&subtock);
			batchTicks = (subtock.QuadPart - subtick.QuadPart);
	}

	void Finalize()
	{
		testServiceStatement->Finalize();
	}
};

// Request to move data between staging table and 
class MoveRequest
{
public:
	// Output parameter
	int rowsMoved;
	__int64 accUsageTicks;
	__int64 testServiceTicks;
};

class CAsyncBcpStageMover : public CAsyncTask<MoveRequest>
{
private:
	COdbcStatementPtr connectionStmt;
	COdbcConnectionPtr mConnection;
	string mTable;
protected:

	virtual void ProcessRequest(MoveRequest* aRequest)
	{
		ProcessRequest(aRequest->rowsMoved,
									 aRequest->accUsageTicks,
									 aRequest->testServiceTicks);
	}
public:
	CAsyncBcpStageMover(MTPipelineLib::IMTLogPtr aLogger,
											const string& aTable,
											COdbcConnectionPtr aOdbcConnection)
		:
		CAsyncTask<MoveRequest>(aLogger),
		mConnection(aOdbcConnection),
		mTable(aTable)
	{
		connectionStmt = aOdbcConnection->CreateStatement();
	}


	void ProcessRequest(int& rowsMoved, __int64& accUsageTicks, __int64& testServiceTicks)
	{
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceCounter(&subtick);
		rowsMoved = connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_acc_usage SELECT id_sess, tx_UID, id_acc, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template FROM NetMeterStage.dbo." + mTable);
		::QueryPerformanceCounter(&subtock);
		accUsageTicks = (subtock.QuadPart - subtick.QuadPart);
		::QueryPerformanceCounter(&subtick);
		connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_pv_testservice SELECT id_sess, c_description, c_time, c_units, c_DecProp1, c_DecProp2, c_DecProp3 FROM NetMeterStage.dbo." + mTable);
		::QueryPerformanceCounter(&subtock);
		testServiceTicks = (subtock.QuadPart - subtick.QuadPart);
	}

};

class CAsyncBcpStageToAccUsageMover : public CAsyncTask<MoveRequest>
{
private:
	COdbcStatementPtr connectionStmt;
	COdbcConnectionPtr mConnection;
	string mTable;
protected:

	virtual void ProcessRequest(MoveRequest* aRequest)
	{
		ProcessRequest(aRequest->rowsMoved,
									 aRequest->accUsageTicks,
									 aRequest->testServiceTicks);
	}
public:
	CAsyncBcpStageToAccUsageMover(MTPipelineLib::IMTLogPtr aLogger,
																const string& aTable,
																COdbcConnectionPtr aOdbcConnection)
		:
		CAsyncTask<MoveRequest>(aLogger),
		mConnection(aOdbcConnection),
		mTable(aTable)
	{
		connectionStmt = aOdbcConnection->CreateStatement();
	}


	void ProcessRequest(int& rowsMoved, __int64& accUsageTicks, __int64& testServiceTicks)
	{
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceCounter(&subtick);
		rowsMoved = connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_acc_usage SELECT id_sess, tx_UID, id_acc, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template FROM NetMeterStage.dbo." + mTable);
		::QueryPerformanceCounter(&subtock);
		accUsageTicks = (subtock.QuadPart - subtick.QuadPart);
	}

};

class CAsyncBcpStageToTestServiceMover : public CAsyncTask<MoveRequest>
{
private:
	COdbcConnectionPtr mConnection;
	COdbcStatementPtr connectionStmt;
	string mTable;
protected:

	virtual void ProcessRequest(MoveRequest* aRequest)
	{
		ProcessRequest(aRequest->rowsMoved,
									 aRequest->accUsageTicks,
									 aRequest->testServiceTicks);
	}
public:
	CAsyncBcpStageToTestServiceMover(MTPipelineLib::IMTLogPtr aLogger,
																	 const string& aTable,
																	 COdbcConnectionPtr aOdbcConnection)
		:
		CAsyncTask<MoveRequest>(aLogger),
		mConnection(aOdbcConnection),
		mTable(aTable)
	{
		connectionStmt = aOdbcConnection->CreateStatement();
	}


	void ProcessRequest(int& rowsMoved, __int64& accUsageTicks, __int64& testServiceTicks)
	{
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceCounter(&subtick);
		connectionStmt->ExecuteUpdate("INSERT INTO NetMeter.dbo.t_pv_testservice SELECT id_sess, c_description, c_time, c_units, c_DecProp1, c_DecProp2, c_DecProp3 FROM NetMeterStage.dbo." + mTable);
		::QueryPerformanceCounter(&subtock);
		testServiceTicks = (subtock.QuadPart - subtick.QuadPart);
	}

};

class BcpWriteRequest
{
public:
	int numRecords;
	int recordsWritten;
	__int64 sendRowTicks;
	__int64 batchTicks;
	__int64 accUsageTicks;
	__int64 testServiceTicks;
	__int64 truncateTicks;
};

class CAsyncBcpWriter : public CAsyncTask<BcpWriteRequest>
{
private:
	CAsyncBcpStageWriter mBcpStageWriter;
	CAsyncBcpStageToAccUsageMover mAccUsageMover;
	CAsyncBcpStageToTestServiceMover mTestServiceMover;
	string mTable;
	COdbcConnectionPtr mConnection;
protected:

	virtual void ProcessRequest(BcpWriteRequest* aRequest)
	{
		int sleep = rand();
		::Sleep(sleep % 1000);
		// Do the BCP to staging table, wait for completion then fire off the movers concurrently
		BcpStageWrite bcpStageRequest;
		bcpStageRequest.numRecords = aRequest->numRecords;
		mBcpStageWriter.SubmitTask(&bcpStageRequest);
		mBcpStageWriter.GetCompletedRequest();
		aRequest->recordsWritten = bcpStageRequest.recordsWritten;
		aRequest->sendRowTicks = bcpStageRequest.sendRowTicks;
		aRequest->batchTicks = bcpStageRequest.batchTicks;

		// The acc usage taks is likely to take longer, submit it first then wait for it last!
		MoveRequest accUsageRequest;
		MoveRequest testServiceRequest;
		mAccUsageMover.SubmitTask(&accUsageRequest);
		mTestServiceMover.SubmitTask(&testServiceRequest);
		mTestServiceMover.GetCompletedRequest();
		mAccUsageMover.GetCompletedRequest();

		aRequest->accUsageTicks = accUsageRequest.accUsageTicks;
		aRequest->testServiceTicks = testServiceRequest.testServiceTicks;

		// Truncate the staging table
		LARGE_INTEGER tick, tock;
		::QueryPerformanceCounter(&tick);
		COdbcStatementPtr stmt = mConnection->CreateStatement();
		stmt->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo." + mTable);
		::QueryPerformanceCounter(&tock);
		aRequest->truncateTicks = tock.QuadPart - tick.QuadPart;
	}
		
public:
	CAsyncBcpWriter(MTPipelineLib::IMTLogPtr aLogger,
									const string& aTable,
									COdbcConnectionPtr aOdbcBcpConnection,
									COdbcConnectionPtr aOdbcAccUsageMoverConnection,
									COdbcConnectionPtr aOdbcTestServiceMoverConnection,
									COdbcConnectionPtr aOdbcTruncateConnection,
									int a_id_view)
		:
		CAsyncTask<BcpWriteRequest>(aLogger),
		mBcpStageWriter(aLogger, aTable, aOdbcBcpConnection, a_id_view),
		mAccUsageMover(aLogger, aTable, aOdbcAccUsageMoverConnection),
		mTestServiceMover(aLogger, aTable, aOdbcTestServiceMoverConnection),
		mTable(aTable),
		mConnection(aOdbcTruncateConnection)
	{
	}

	void StartProcessing()
	{
		// Start children first
		mBcpStageWriter.StartProcessing();
		mAccUsageMover.StartProcessing();
		mTestServiceMover.StartProcessing();
		CAsyncTask<BcpWriteRequest>::StartProcessing();
	}

	void FinishProcessing()
	{
		// What order should we use here????
		CAsyncTask<BcpWriteRequest>::FinishProcessing();
		mBcpStageWriter.FinishProcessing();
		mAccUsageMover.FinishProcessing();
		mTestServiceMover.FinishProcessing();
	}
};

void TestBcpToAccUsageTestServiceStageMoveToNetMeterAsync()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows =10000;
		int m_dwCommitInterval = 250;
	
		MTPipelineLib::IMTLogPtr logger("MetraPipeline.MTLog.1");
		logger->Init("logging", "MTODBC");

		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		COdbcConnectionPtr odbcConnection3 = new COdbcConnection(info);
		COdbcConnectionPtr odbcConnection2 = new COdbcConnection(info);
		COdbcConnectionPtr odbcConnection4 = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.

		COdbcStatementPtr bcpConnectionStmt0 = odbcConnection->CreateStatement();
		COdbcStatementPtr bcpConnectionStmt1 = odbcConnection3->CreateStatement();

		CAsyncBcpStageMover mover0(logger, "t_pv_testservice_stage", odbcConnection2);
		CAsyncBcpStageMover mover1(logger, "t_pv_testservice_stage_1", odbcConnection2);
		CAsyncBcpStageToAccUsageMover accUsageMover0(logger, "t_pv_testservice_stage", odbcConnection2);
		CAsyncBcpStageToAccUsageMover accUsageMover1(logger, "t_pv_testservice_stage_1", odbcConnection2);
		CAsyncBcpStageToTestServiceMover testServiceMover0(logger, "t_pv_testservice_stage", odbcConnection4);
		CAsyncBcpStageToTestServiceMover testServiceMover1(logger, "t_pv_testservice_stage_1", odbcConnection4);

		CAsyncBcpStageMover* mover[2];
		mover[0] = &mover0;
		mover[1] = &mover1;

		CAsyncBcpStageToAccUsageMover* accUsageMover[2];
		accUsageMover[0] = &accUsageMover0;
		accUsageMover[1] = &accUsageMover1;

		CAsyncBcpStageToTestServiceMover* testServiceMover[2];
		testServiceMover[0] = &testServiceMover0;
		testServiceMover[1] = &testServiceMover1;

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		// The rest of the stuff goes against the staging database
		odbcConnection->SetSchema("NetMeterStage");
		odbcConnection3->SetSchema("NetMeterStage");

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceFrequency(&freq);
	
		__int64 sendRowTicks=0;
		__int64 batchTicks=0;
		__int64 accUsageTicks=0;
		__int64 testServiceTicks=0;
		__int64 truncateTicks=0;

		::QueryPerformanceCounter(&tick);
		CAsyncBcpStageWriter writer0(logger, "t_pv_testservice_stage", odbcConnection, id_view);
		CAsyncBcpStageWriter writer1(logger, "t_pv_testservice_stage_1", odbcConnection3, id_view);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: BCP setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		CAsyncBcpStageWriter* writer[2];
		writer[0] = &writer0;
		writer[1] = &writer1;

		writer[0]->StartProcessing();
		writer[1]->StartProcessing();
		mover[0]->StartProcessing();
		mover[1]->StartProcessing();
		accUsageMover[0]->StartProcessing();
		accUsageMover[1]->StartProcessing();
		testServiceMover[0]->StartProcessing();
		testServiceMover[1]->StartProcessing();

		BcpStageWrite writeRequest;
		MoveRequest moveRequest;

		// We allocate two writers and two movers.  At equillibrium there are
		// two states.  In state 1, writer 0 is writing and mover 1 is moving.
		// In state 2, writer 1 is writing and mover 0 is moving.  The goal of
		// the main loop is to transition between these two states.
		int state=1;
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<m_dwNumRows+2*m_dwCommitInterval; i+=m_dwCommitInterval)
		{
			// Wait for current processing to complete so that we can make
			// the state transition.  For the first iteration, there is no
			// request to be reaped.  For the last iteration there is no request
			// to be reaped.
			if (i > 0 && i < m_dwNumRows+m_dwCommitInterval)
			{
				writer[state]->GetCompletedRequest();
				numRows += writeRequest.recordsWritten;
				// Update timing
				sendRowTicks += writeRequest.sendRowTicks;
				batchTicks += writeRequest.batchTicks;
			}

			// Move rows to t_acc_usage and t_pv_testservice.  For the first two
			// iterations there is nothing to be reaped
			if (i > m_dwCommitInterval)
			{
#ifndef NEVER
				mover[(state+1)%2]->GetCompletedRequest();
				// Update timing
				testServiceTicks += moveRequest.testServiceTicks;
				accUsageTicks += moveRequest.accUsageTicks;
#else
				testServiceMover[(state+1)%2]->GetCompletedRequest();
				accUsageMover[(state+1)%2]->GetCompletedRequest();
				// Update timing
				testServiceTicks += moveRequest.testServiceTicks;
				accUsageTicks += moveRequest.accUsageTicks;
#endif
			}

			// State transition 0->1, 1->0
			state = (state+1)%2;

			// Submit next round of requests.  For the first iteration and
			// the last iteration don't do anything.
			if (i > 0 && i < m_dwNumRows+m_dwCommitInterval)
			{
#ifndef NEVER
				mover[(state+1)%2]->SubmitTask(&moveRequest);
#else
				accUsageMover[(state+1)%2]->SubmitTask(&moveRequest);
				testServiceMover[(state+1)%2]->SubmitTask(&moveRequest);
#endif
			}
			// For the last two iterations don't submit any new batches
			if (i < m_dwNumRows)
			{
				// Do this piece within the bcp transaction
				::QueryPerformanceCounter(&subtick);
				if(state==0)
				{
					bcpConnectionStmt0->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo.t_pv_testservice_stage");
				}
				else
				{
					bcpConnectionStmt1->ExecuteUpdate("TRUNCATE TABLE NetMeterStage.dbo.t_pv_testservice_stage_1");
				}
				::QueryPerformanceCounter(&subtock);
				truncateTicks += (subtock.QuadPart - subtick.QuadPart);

				writeRequest.numRecords = m_dwCommitInterval;
				writer[state]->SubmitTask(&writeRequest);
			}
		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Send Rows %d rows in %d milliseconds", (long) numRows, (long) ((1000*sendRowTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Batch %d rows in %d milliseconds", (long) numRows, (long) ((1000*batchTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_acc_usage %d rows in %d milliseconds", (long) numRows, (long) ((1000*accUsageTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_pv_testservice %d rows in %d milliseconds", (long) numRows, (long) ((1000*testServiceTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: TRUNCATE %d rows in %d milliseconds", (long) numRows, (long) ((1000*truncateTicks)/freq.QuadPart));
		cout << buf << endl;

		writer[0]->FinishProcessing();
		writer[1]->FinishProcessing();
		mover[0]->FinishProcessing();
		mover[1]->FinishProcessing();
		accUsageMover[0]->FinishProcessing();
		accUsageMover[1]->FinishProcessing();
		testServiceMover[0]->FinishProcessing();
		testServiceMover[1]->FinishProcessing();

		::QueryPerformanceCounter(&tick);
		writer[0]->Finalize();
		writer[1]->Finalize();
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Finalize took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestBcpToAccUsageTestServiceStageMoveToNetMeterAsync2()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 10000;
		int m_dwCommitInterval = 250;
		int numThreads = 2;
	
		MTPipelineLib::IMTLogPtr logger("MetraPipeline.MTLog.1");
		logger->Init("logging", "MTODBC");

		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());

		odbcConnection->CommitTransaction();

		vector<CAsyncBcpWriter* > writers;
		for (int i=0; i<numThreads; i++)
		{
			// Create all the stinkin' connections; leave in autocommit for now...
			COdbcConnectionPtr bcpConnection = new COdbcConnection(info);
			COdbcConnectionPtr accUsageConnection = new COdbcConnection(info);
			COdbcConnectionPtr testServiceConnection = new COdbcConnection(info);
			COdbcConnectionPtr truncateConnection = new COdbcConnection(info);

			// BCP will go against staging database
			bcpConnection->SetSchema("NetMeterStage");

			// Cons up the staging table name
			char buf[256];
			if(i==0)
			{
				strcpy(buf,"t_pv_testservice_stage"); 
			}
			else
			{
				sprintf(buf, "t_pv_testservice_stage_%d", i);
			}
			CAsyncBcpWriter* writer0 = new CAsyncBcpWriter(logger, 
																										 buf, 
																										 bcpConnection, 
																										 accUsageConnection, 
																										 testServiceConnection, 
																										 truncateConnection, 
																										 id_view);

			writers.push_back(writer0);
		}

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER subtick;
		LARGE_INTEGER subtock;
		::QueryPerformanceFrequency(&freq);
	
		__int64 sendRowTicks=0;
		__int64 batchTicks=0;
		__int64 accUsageTicks=0;
		__int64 testServiceTicks=0;
		__int64 truncateTicks=0;

		int numRows = 0;

		for (i=0; i<numThreads; i++)
		{
			writers[i]->StartProcessing();
		}

		// We have a pool of threads.  Keep track of which writers are active
		// and which are free.  Use LIFO scheduling and initialize so that everyone
		// is in the free pool.
		list<CAsyncBcpWriter*> freePool;
		list<CAsyncBcpWriter*> busyPool;
		
		for(i=0; i<numThreads; i++)
		{
			freePool.push_back(writers[i]);
		}

		::QueryPerformanceCounter(&tick);
		for(i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			// We will delete when the request is done
			BcpWriteRequest* request = new BcpWriteRequest();
			request->numRecords = m_dwCommitInterval;
			CAsyncBcpWriter* writer=NULL;
			if (freePool.size() > 0)
			{
				writer = freePool.back();
				freePool.pop_back();
			}
			else
			{
				BcpWriteRequest* completed = busyPool.front()->GetCompletedRequest();
				writer = busyPool.front();
				busyPool.pop_front();
				numRows += completed->recordsWritten;
				sendRowTicks += completed->sendRowTicks;
				batchTicks += completed->batchTicks;
				accUsageTicks += completed->accUsageTicks;
				testServiceTicks += completed->testServiceTicks;
				truncateTicks += completed->truncateTicks;
				delete completed;
			}
			ASSERT(writer != NULL);
			writer->SubmitTask(request);
			busyPool.push_back(writer);
		}
		
		// Wait for outstanding requests to complete
		while (busyPool.size() > 0)
		{
			BcpWriteRequest* completed = busyPool.front()->GetCompletedRequest();
			CAsyncBcpWriter* writer = busyPool.front();
			busyPool.pop_front();
			numRows += completed->recordsWritten;
			sendRowTicks += completed->sendRowTicks;
			batchTicks += completed->batchTicks;
			accUsageTicks += completed->accUsageTicks;
			testServiceTicks += completed->testServiceTicks;
			truncateTicks += completed->truncateTicks;
			delete completed;
		}
		
		char buf[1024];

		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Bcp Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Send Rows %d rows in %d milliseconds", (long) numRows, (long) ((1000*sendRowTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: Bcp Batch %d rows in %d milliseconds", (long) numRows, (long) ((1000*batchTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_acc_usage %d rows in %d milliseconds", (long) numRows, (long) ((1000*accUsageTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: INSERT INTO t_pv_testservice %d rows in %d milliseconds", (long) numRows, (long) ((1000*testServiceTicks)/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "\tInsert Time: TRUNCATE %d rows in %d milliseconds", (long) numRows, (long) ((1000*truncateTicks)/freq.QuadPart));
		cout << buf << endl;

		for(i=0; i<numThreads; i++)
		{
			writers[i]->FinishProcessing();
		}

		::QueryPerformanceCounter(&tick);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Bcp Finalize took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestColumnArray()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 1000000;
		int m_dwCommitInterval = 100;
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);

		COdbcConnectionInfo info("LONDON", "NetMeter", "sa", "");
		COdbcConnection odbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		bool bResult;
		odbcConnection.SetAutoCommit(false);

		CColumnArrayWriter writer(m_dwCommitInterval);

		bResult = writer.Initialize(&odbcConnection);
		ASSERT(bResult);

		// Do the data
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Column Array Insert setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		// Transaction coordinator (use local transactions)
		CDistributedTransaction txStream(FALSE);
		txStream.Subscribe(&odbcConnection);

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			bResult = writer.WriteBatch(i, i+m_dwCommitInterval<m_dwNumRows ? i+m_dwCommitInterval : m_dwNumRows);
			ASSERT(bResult);
			numRows += writer.SubmitBatch();
			txStream.EndTransaction();
			txStream.BeginTransaction();
		}


		writer.Finalize();
		txStream.EndTransaction();
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		txStream.Unsubscribe(&odbcConnection);
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}

}

void TestAccUsage()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 100;
	
		COdbcConnectionInfo info("LONDON", "NetMeter", "sa", "");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");
		//COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='metratech.com/testservice'");

		ASSERT(rs->Next());
		int id_view = rs->GetInteger(1);
		ASSERT(!rs->WasNull());


		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("t_acc_usage", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				// Just to keep us out of danger with unique ids, start id_sess at 5 million
				int id = 5000000 + i + j;
				accUsageStatement->SetBigInteger(1, id);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				accUsageStatement->SetInteger(3, 123);
				accUsageStatement->SetInteger(4, id_view);
				accUsageStatement->SetInteger(5, 1000);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			numRows += accUsageRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestPreparedArraySelectStatement()
{
	int arraySize = 100;
	int numRows = 10000;
	try {
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcConnection* odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatement* stmt = odbcConnection->PrepareStatement("SELECT u.id_sess FROM t_acc_usage u INNER JOIN t_pv_testservice p ON u.id_sess=p.id_sess INNER JOIN t_pv_audioconfcall c ON u.id_sess=c.id_sess WHERE id_view = ? AND dt_session BETWEEN ? AND ? AND tx_UID=? AND amount=? AND am_currency=? AND c_DecProp1 = ? AND c_SystemName=?", 100, true);

/*
		COdbcPreparedArrayStatement* accountStmt = 
			new COdbcPreparedArrayStatement(odbcConnection, 
																			arraySize, 
																			"SELECT ed.nm_enum_data, a.id_acc FROM t_account a "
																			"INNER JOIN t_enum_data ed ON a.id_status=ed.id_enum_data "
																			"INNER JOIN t_account_mapper m ON m.id_acc=a.id_acc "
																			"WHERE nm_login=? AND nm_space=?",
																			true);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<numRows; i+=arraySize)
		{
			int j=0;
			for(j=0; j<arraySize; j+= 4)
			{
				accountStmt->SetWideString(1, L"demo");
				accountStmt->SetWideString(2, L"mt");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"csr1");
				accountStmt->SetWideString(2, L"csr");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"mcm1");
				accountStmt->SetWideString(2, L"mcm");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"ops");
				accountStmt->SetWideString(2, L"ops");
				accountStmt->AddBatch();
			}

			COdbcPreparedResultSet* accountResultSet = accountStmt->ExecuteQuery();
			bool hasNext;
			for(j=0; j<arraySize; j+=4)
			{
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT("metratech.com/accountcreation/AccountStatus/Active" == accountResultSet->GetString(1));
				ASSERT(123 == accountResultSet->GetInteger(2));
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT("metratech.com/accountcreation/AccountStatus/Active" == accountResultSet->GetString(1));
				ASSERT(125 == accountResultSet->GetInteger(2));
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT("metratech.com/accountcreation/AccountStatus/Active" == accountResultSet->GetString(1));
				ASSERT(126 == accountResultSet->GetInteger(2));
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT("metratech.com/accountcreation/AccountStatus/Active" == accountResultSet->GetString(1));
				ASSERT(127 == accountResultSet->GetInteger(2));
			}
			hasNext = accountResultSet->Next();
			ASSERT(!hasNext);
			hasNext = accountResultSet->NextResultSet();
			ASSERT(!hasNext);
		}
		::QueryPerformanceCounter(&tock);

*/

		COdbcPreparedArrayStatement* accountStmt = 
			odbcConnection->PrepareStatement(
																			 "SELECT avint.id_acc, avint.c_PaymentMethod FROM NetMeter.dbo.t_account acc "
																			 "INNER JOIN NetMeter.dbo.t_av_internal avint ON acc.id_acc=avint.id_acc "
																			 "INNER JOIN NetMeter.dbo.t_account_mapper map ON map.id_acc=acc.id_acc "
																			 "WHERE map.nm_login=? AND map.nm_space=?",
																			 arraySize);

		int rowsRead = 0;

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<numRows; i+=arraySize)
		{
			int j=0;
			for(j=0; j<arraySize; j+= 4)
			{
				accountStmt->SetWideString(1, L"demo");
				accountStmt->SetWideString(2, L"mt");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"csr1");
				accountStmt->SetWideString(2, L"csr");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"mcm1");
				accountStmt->SetWideString(2, L"mcm");
				accountStmt->AddBatch();
				accountStmt->SetWideString(1, L"ops");
				accountStmt->SetWideString(2, L"ops");
				accountStmt->AddBatch();
			}

			COdbcPreparedResultSet* accountResultSet = accountStmt->ExecuteQuery();
			bool hasNext=true;
			for(j=0; j<arraySize; j+=4)
			{
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT(123 == accountResultSet->GetInteger(1));
				rowsRead++;
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT(125 == accountResultSet->GetInteger(1));
				rowsRead++;
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT(126 == accountResultSet->GetInteger(1));
				rowsRead++;
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
				ASSERT(hasNext);
				hasNext = accountResultSet->Next();
				ASSERT(hasNext);
				ASSERT(127 == accountResultSet->GetInteger(1));
				rowsRead++;
				hasNext = accountResultSet->Next();
				ASSERT(!hasNext);
				hasNext = accountResultSet->NextResultSet();
			}
			ASSERT(!hasNext);
		}
		::QueryPerformanceCounter(&tock);

		char buf[256];
		sprintf(buf, 
						"Select Time: Read %d rows in %d milliseconds", 
						(long) rowsRead, 
						(long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

	 
		sprintf(buf, 
						"Select Time: Read %d rows spent %g milliseconds in SQLExecute", 
						(long) rowsRead, 
						accountStmt->GetTotalExecuteMillis());
		cout << buf << endl;
		
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestPreparedArraySelectStatement2()
{
	int arraySize = 100;
	int numRows = 1000;
	try {
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcConnection* odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		bool bResult;
		odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatement* accountStmt = 
			odbcConnection->PrepareStatement(
																			 "SELECT acc.id_acc, avint.c_PaymentMethod FROM NetMeter.dbo.t_account acc "
																			 "INNER JOIN NetMeter.dbo.t_av_internal avint ON acc.id_acc=avint.id_acc "
																			 "INNER JOIN NetMeter.dbo.t_account_mapper map ON map.id_acc=acc.id_acc "
																			 "WHERE map.nm_login=? AND map.nm_space=?",
																			 arraySize);
/*
			odbcConnection->PrepareStatement(
																			 "SELECT acc.id_acc, avint.c_PaymentMethod FROM NetMeter.dbo.t_account acc "
																			 "INNER JOIN NetMeter.dbo.t_av_internal avint ON acc.id_acc=avint.id_acc "
																			 "INNER JOIN NetMeter.dbo.t_account_mapper map ON map.id_acc=acc.id_acc "
																			 "WHERE map.nm_login=? AND map.nm_space=?",
																			 arraySize);
*/
/*
			odbcConnection->PrepareStatement("SELECT acc.id_acc FROM t_account acc "
																			 "INNER JOIN t_account_mapper map ON map.id_acc=acc.id_acc "
																			 "INNER JOIN t_av_internal avint ON avint.id_acc = acc.id_acc "
																			 "WHERE map.nm_login=? AND map.nm_space=?", 
																			 arraySize);
*/
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER cursorTick;
		LARGE_INTEGER cursorTock;
		__int64 cursorTotalTicks=0;
		LARGE_INTEGER accessorTick;
		LARGE_INTEGER accessorTock;
		__int64 accessorTotalTicks=0;
		LARGE_INTEGER resultCursorTick;
		LARGE_INTEGER resultCursorTock;
		__int64 resultCursorTotalTicks=0;

		int readRows=0;
		
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<numRows; i+=arraySize)
		{
			int j=0;
			for(j=0; j<arraySize; j++)
			{
				accountStmt->SetWideString(1, L"demo");
				accountStmt->SetWideString(2, L"mt");
				accountStmt->AddBatch();
			}

			bool bNextResultSet = true;
			COdbcPreparedResultSet* accountResultSet = accountStmt->ExecuteQuery();
			do
			{
				::QueryPerformanceCounter(&cursorTick);
				bool bNext = accountResultSet->Next();
				::QueryPerformanceCounter(&cursorTock);
				cursorTotalTicks += (cursorTock.QuadPart - cursorTick.QuadPart);
				// TODO: Handle failure to resolve account
				ASSERT(bNext);
				::QueryPerformanceCounter(&accessorTick);
				ASSERT(123 == accountResultSet->GetInteger(1));
				::QueryPerformanceCounter(&accessorTock);
				accessorTotalTicks += (accessorTock.QuadPart - accessorTick.QuadPart);

				readRows++;

				bNext = accountResultSet->Next();
				// Shouldn't ever get more than one account 
				ASSERT(!bNext);

				::QueryPerformanceCounter(&resultCursorTick);
				bNextResultSet = accountResultSet->NextResultSet();
				::QueryPerformanceCounter(&resultCursorTock);
				resultCursorTotalTicks += (resultCursorTock.QuadPart - resultCursorTick.QuadPart);
				if (100 < (resultCursorTock.QuadPart - resultCursorTick.QuadPart))
				{
					cout << "Result Set Ticks: " << (resultCursorTock.QuadPart - resultCursorTick.QuadPart) << " for row: " << readRows << endl;
				}
			} while(bNextResultSet);
				
		}
		::QueryPerformanceCounter(&tock);

		char buf[256];
		sprintf(buf, 
						"Select Time: Read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*cursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Accessor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*accessorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Result Set cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*resultCursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

	 
		sprintf(buf, 
						"Select Time: Read %d rows spent %g milliseconds in SQLExecute", 
						(long) numRows, 
						accountStmt->GetTotalExecuteMillis());
		cout << buf << endl;
		
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestPreparedArraySelectStatement3()
{
	int arraySize = 100;
	int numRows = 1000;
	try {
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcConnection* odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		bool bResult;
		odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatement* accountStmt = 
			odbcConnection->PrepareStatement("{ CALL TestAccountResolution(?,?) }", arraySize);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER cursorTick;
		LARGE_INTEGER cursorTock;
		__int64 cursorTotalTicks=0;
		LARGE_INTEGER accessorTick;
		LARGE_INTEGER accessorTock;
		__int64 accessorTotalTicks=0;
		LARGE_INTEGER resultCursorTick;
		LARGE_INTEGER resultCursorTock;
		__int64 resultCursorTotalTicks=0;

		int readRows=0;
		
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<numRows; i+=arraySize)
		{
			int j=0;
			for(j=0; j<arraySize; j++)
			{
				accountStmt->SetWideString(1, L"demo");
				accountStmt->SetWideString(2, L"mt");
				accountStmt->AddBatch();
			}

			bool bNextResultSet = true;
			COdbcPreparedResultSet* accountResultSet = accountStmt->ExecuteQuery();
			do
			{
				::QueryPerformanceCounter(&cursorTick);
				bool bNext = accountResultSet->Next();
				::QueryPerformanceCounter(&cursorTock);
				cursorTotalTicks += (cursorTock.QuadPart - cursorTick.QuadPart);
				// TODO: Handle failure to resolve account
				ASSERT(bNext);
				::QueryPerformanceCounter(&accessorTick);
				ASSERT(123 == accountResultSet->GetInteger(1));
				::QueryPerformanceCounter(&accessorTock);
				accessorTotalTicks += (accessorTock.QuadPart - accessorTick.QuadPart);

				readRows++;

				bNext = accountResultSet->Next();
				// Shouldn't ever get more than one account 
				ASSERT(!bNext);

				::QueryPerformanceCounter(&resultCursorTick);
				bNextResultSet = accountResultSet->NextResultSet();
				::QueryPerformanceCounter(&resultCursorTock);
				resultCursorTotalTicks += (resultCursorTock.QuadPart - resultCursorTick.QuadPart);
				if (1000 < (resultCursorTock.QuadPart - resultCursorTick.QuadPart))
				{
					cout << "Result Set Ticks: " << (resultCursorTock.QuadPart - resultCursorTick.QuadPart) << " for row: " << readRows << endl;
				}
			} while(bNextResultSet);
				
		}
		::QueryPerformanceCounter(&tock);

		char buf[256];
		sprintf(buf, 
						"Select Time: Read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*cursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Accessor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*accessorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Result Set cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*resultCursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

	 
		sprintf(buf, 
						"Select Time: Read %d rows spent %g milliseconds in SQLExecute", 
						(long) numRows, 
						accountStmt->GetTotalExecuteMillis());
		cout << buf << endl;
		
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

void TestPreparedArraySelectStatement4()
{
	int arraySize = 100;
	int numRows = 10000;
	try {
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcConnection* odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		bool bResult;
		odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatement* accountStmt = 
			odbcConnection->PrepareStatement(
																			 "SELECT acc.id_acc, avint.c_PaymentMethod FROM NetMeter.dbo.t_account acc "
																			 "INNER JOIN NetMeter.dbo.t_av_internal avint ON acc.id_acc=avint.id_acc "
																			 "INNER JOIN NetMeter.dbo.t_account_mapper map ON map.id_acc=acc.id_acc "
																			 "WHERE map.nm_login=? AND map.nm_space=?",
																			 arraySize);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		LARGE_INTEGER cursorTick;
		LARGE_INTEGER cursorTock;
		__int64 cursorTotalTicks=0;
		LARGE_INTEGER accessorTick;
		LARGE_INTEGER accessorTock;
		__int64 accessorTotalTicks=0;
		LARGE_INTEGER resultCursorTick;
		LARGE_INTEGER resultCursorTock;
		__int64 resultCursorTotalTicks=0;

		int readRows=0;
		
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		for(int i=0; i<numRows; i+=arraySize)
		{
			int j=0;
			for(j=0; j<arraySize; j++)
			{
				wchar_t buf[256];
				wsprintf(buf, L"gentest%d", i+2000+j);
				accountStmt->SetWideString(1, buf);
				accountStmt->SetWideString(2, L"mt");
				accountStmt->AddBatch();
			}

			bool bNextResultSet = true;
			COdbcPreparedResultSet* accountResultSet = accountStmt->ExecuteQuery();
			int currentInBatch=0;
			do
			{
				::QueryPerformanceCounter(&cursorTick);
				bool bNext = accountResultSet->Next();
				::QueryPerformanceCounter(&cursorTock);
				cursorTotalTicks += (cursorTock.QuadPart - cursorTick.QuadPart);
				// TODO: Handle failure to resolve account
				ASSERT(bNext);
				::QueryPerformanceCounter(&accessorTick);
				ASSERT(2000+i+(currentInBatch++) == accountResultSet->GetInteger(1));
				::QueryPerformanceCounter(&accessorTock);
				accessorTotalTicks += (accessorTock.QuadPart - accessorTick.QuadPart);

				readRows++;

				bNext = accountResultSet->Next();
				// Shouldn't ever get more than one account 
				ASSERT(!bNext);

				::QueryPerformanceCounter(&resultCursorTick);
				bNextResultSet = accountResultSet->NextResultSet();
				::QueryPerformanceCounter(&resultCursorTock);
				resultCursorTotalTicks += (resultCursorTock.QuadPart - resultCursorTick.QuadPart);
				if (1000 < (resultCursorTock.QuadPart - resultCursorTick.QuadPart))
				{
					cout << "Result Set Ticks: " << (resultCursorTock.QuadPart - resultCursorTick.QuadPart) << " for row: " << readRows << endl;
				}
			} while(bNextResultSet);
				
		}
		::QueryPerformanceCounter(&tock);

		char buf[256];
		sprintf(buf, 
						"Select Time: Read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*cursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Accessor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*accessorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

		sprintf(buf, 
						"Select Time: Result Set cursor read %d rows in %d milliseconds", 
						(long) numRows, 
						(long) ((1000*resultCursorTotalTicks)/freq.QuadPart));
		cout << buf << endl;

	 
		sprintf(buf, 
						"Select Time: Read %d rows spent %g milliseconds in SQLExecute", 
						(long) numRows, 
						accountStmt->GetTotalExecuteMillis());
		cout << buf << endl;
		
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

/********* Test Script *************************************

create table t_test_odbc_read(a integer, b nvarchar(64), c varchar(64), 
	d decimal(18,6), e varbinary(4), f datetime, g double precision)

insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', 'varchar', 98.33, 0xaaaa, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (null, 'nvarchar', 'varchar', 98.33, 0xaaaa, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, null, 'varchar', 98.33, 0xaaaa, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', null, 98.33, 0xaaaa, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', 'varchar', null, 0xaaaa, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', 'varchar', 98.33, null, '2001-06-25 19:39:49.870', 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', 'varchar', 98.33, 0xaaaa, null, 998.3)
insert into t_test_odbc_read(a,b,c,d,e,f,g)
values (12, 'nvarchar', 'varchar', 98.33, 0xaaaa, '2001-06-25 19:39:49.870', null)

****************************************************************/

void TestReadOdbc()
{
	try {
		COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "");
		COdbcConnection* odbcConnection = new COdbcConnection(info);

		odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatement* stmt = 
			odbcConnection->PrepareStatement("SELECT a,b,c,d,e,f,g FROM t_test_odbc_read", 1);

		int readRows=0;

		COdbcDecimal expectedDec;
		SQLCHAR decBuf[SQL_MAX_NUMERIC_LEN];
		int scaledVal = 98330000;
		memset(&decBuf[0], 0, SQL_MAX_NUMERIC_LEN);
		memcpy(&decBuf[0], &scaledVal, sizeof(scaledVal));
		expectedDec.SetPrecision(18);
		expectedDec.SetScale(6);
		expectedDec.SetSign(1);
		expectedDec.SetVal(&decBuf[0]);

		COdbcTimestamp expectedTs;
		expectedTs.SetYear(2001);
		expectedTs.SetMonth(6);
		expectedTs.SetDay(25);
		expectedTs.SetHour(19);
		expectedTs.SetMinute(39);
		expectedTs.SetSecond(49);
		expectedTs.SetFraction(870);

		vector<unsigned char> expectedBin;
		expectedBin.push_back(0xaa);
		expectedBin.push_back(0xaa);
		
		COdbcPreparedResultSet* resultSet = stmt->ExecuteQuery();
		
		while(resultSet->Next())
		{
			int intVal = resultSet->GetInteger(1);
			ASSERT((!resultSet->WasNull() && intVal == 12) || (resultSet->WasNull() && intVal == 0));
			wstring wstrVal = resultSet->GetWideString(2);
			ASSERT((!resultSet->WasNull() && wstrVal == L"nvarchar") || (resultSet->WasNull() && wstrVal == L""));
			string strVal = resultSet->GetString(3);
			ASSERT((!resultSet->WasNull() && strVal == "varchar") || (resultSet->WasNull() && strVal == ""));
			COdbcDecimal decVal = resultSet->GetDecimal(4);
			ASSERT((!resultSet->WasNull() && decVal == expectedDec) || (resultSet->WasNull() && decVal == COdbcDecimal()));
			vector<unsigned char> binVal = resultSet->GetBinary(5);
			ASSERT((!resultSet->WasNull() && binVal == expectedBin) || (resultSet->WasNull() && binVal.size() == 0));
			COdbcTimestamp tsVal = resultSet->GetTimestamp(6);
			ASSERT((!resultSet->WasNull() && tsVal == expectedTs) || (resultSet->WasNull() && tsVal == COdbcTimestamp()));
			double dblVal = resultSet->GetDouble(7);
			ASSERT((!resultSet->WasNull() && dblVal == 998.3) || (resultSet->WasNull() && dblVal == 0.0));
		}		

		ASSERT(!resultSet->NextResultSet());

		odbcConnection->CommitTransaction();

		delete resultSet;
		delete stmt;
		delete odbcConnection;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

#endif
void TestMetadata()
{
	try {
		//COdbcConnectionInfo info("LocalServer", "NetMeter", "sa", "MetraTech1");
		COdbcConnectionInfo info("NetMeter");
		COdbcConnection* odbcConnection = new COdbcConnection(info);

		odbcConnection->SetAutoCommit(false);
		COdbcStatementPtr stmt = odbcConnection->CreateStatement();

      COdbcResultSetPtr rs = stmt->ExecuteQuery(
         "SET FMTONLY ON "
         "SELECT * FROM t_acc_usage "
         "SET FMTONLY OFF");

		COdbcColumnMetadataVector meta = rs->GetMetadata();

		COdbcColumnMetadataVector::iterator it = meta.begin();
		while (it != meta.end())
		{
			cout << (*it++)->GetSQLServerDDL().c_str() << endl;
		}

		rs->Close();

		COdbcStagingTable stagingTable(odbcConnection, info, "t_pv_testservice");
		//COdbcStagingTable stagingTable(odbcConnection, info, "t_pv_testpi");

      const vector<InsertQueryPtr>& iq = stagingTable.GetInsertQueries();
      vector<InsertQueryPtr>::const_iterator iter;

	   // execute all the sql insert statements
      for ( iter = iq.begin(); iter != iq.end(); ++iter )
      {
         cout << (*iter)->Query << endl;
      }
   
		cout << stagingTable.GetCreateStageTableQuery() << endl;

		//cout << stagingTable.GetAccUsageInsertQuery() << endl;
		//cout << stagingTable.GetProductViewInsertQuery() << endl;
		
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

#if 0
static void TestOracle()
{
	try {
#ifdef NEVER
		SQLRETURN sqlReturn;
		HENV hEnv;
		HDBC hConn;
		sqlReturn = ::SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &hEnv);
		sqlReturn = ::SQLSetEnvAttr(hEnv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0); 

		sqlReturn = ::SQLAllocHandle(SQL_HANDLE_DBC, hEnv, &hConn); 

		::SQLSetConnectAttrA(hConn, SQL_ATTR_CURRENT_CATALOG, 
												 (SQLPOINTER) "nmdbo", SQL_NTS);

		sqlReturn = ::SQLConnectA(hConn, (SQLCHAR*) "Ora2000", SQL_NTS,
														 (SQLCHAR*) "nmdbo", SQL_NTS,
														 (SQLCHAR*) "nmdbo", SQL_NTS);

		::SQLDisconnect(hConn);
		::SQLFreeHandle(SQL_HANDLE_DBC, hConn);
		::SQLFreeHandle(SQL_HANDLE_ENV, hEnv);
#endif

		int arraySize = 100;
		int numRows = 100000;
		COdbcConnectionInfo info("Ora2000", "nmdbo", "nmdbo", "nmdbo");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		//odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatementPtr stmt = odbcConnection->PrepareInsertStatement("SIMPLE", arraySize);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);

		for (int i=0; i<numRows; i+=arraySize)
		{
			for (int j=0; j<arraySize; j++)
			{
				int id = i+j;

				if (j % 7)
				{
					stmt->SetString(1, "kkkelleeee");
				}

				SQL_NUMERIC_STRUCT num;
				num.precision = 38;
				num.scale = 0;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &id, sizeof(id));
				stmt->SetDecimal(2, num);

				unsigned char foo[16];
				memcpy(foo, "dddddddddddddddd", 16);
				stmt->SetBinary(3, foo, 16);

				if (j % 11)
				{
					SYSTEMTIME sysTime;
					::GetSystemTime(&sysTime);
					TIMESTAMP_STRUCT dt_crt;

					dt_crt.year = sysTime.wYear; 
					dt_crt.month = sysTime.wMonth; 
					dt_crt.day = sysTime.wDay; 
					dt_crt.hour = sysTime.wHour; 
					dt_crt.minute = sysTime.wMinute; 
					dt_crt.second = sysTime.wSecond; 
					dt_crt.fraction = 0; 
					stmt->SetDatetime(4, dt_crt);
				}

				SQL_NUMERIC_STRUCT num2;
				num2.precision = 18;
				num2.scale = 6;
				num2.sign = 1;
				memset(num2.val, 0, sizeof(num2.val));
				memcpy(num2.val, &id, sizeof(id));
				stmt->SetDecimal(5, num2);

/*
				stmt->SetString(1, "kkkelleeee");
				stmt->SetString(2, "kkkelle");
				// integer in Oracle is actually a DECIMAL(38,0)
				SQL_NUMERIC_STRUCT num;
				num.precision = 18;
				num.scale = 6;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &id, sizeof(id));
				stmt->SetDecimal(3, num);

				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				stmt->SetDatetime(4, dt_crt);
*/
				stmt->AddBatch();
			}
			stmt->ExecuteBatch();
			odbcConnection->CommitTransaction();
		}

		stmt->ExecuteBatch();
		odbcConnection->CommitTransaction();


		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Oracle array insert for %d rows took %d milliseconds", numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;


		// Figure out the id_view 
/*
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='METRATECH.COM/TESTSERVICE'");

		ASSERT(rs->Next());
		COdbcDecimal id_view = rs->GetDecimal(1);
		ASSERT(!rs->WasNull());

		// Close up the result set.
		rs->Close();
		rs = COdbcResultSetPtr(NULL);
*/

		COdbcPreparedArrayStatementPtr getNameID = odbcConnection->PrepareStatement("select id_enum_data from t_enum_data where nm_enum_data='METRATECH.COM/TESTSERVICE'", 1);

		COdbcPreparedResultSetPtr rs = getNameID->ExecuteQuery();

		ASSERT(rs->Next());
		COdbcDecimal id_view = rs->GetDecimal(1);
		ASSERT(!rs->WasNull());

		// Close up the result set.
		rs->Close();
		rs = COdbcPreparedResultSetPtr(NULL);
		getNameID = COdbcPreparedArrayStatementPtr(NULL);
		

	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestOracleTimesTwo()
{
	try {
		int arraySize = 100;
		int numRows = 100000;
		COdbcConnectionInfo info("Ora2000", "nmdbo", "nmdbo", "nmdbo");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		//odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatementPtr stmt = odbcConnection->PrepareInsertStatement("SIMPLE2", arraySize);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);

		for (int i=0; i<numRows; i+=arraySize)
		{
			for (int j=0; j<arraySize; j++)
			{
				int id = i+j;

				if (j % 7)
				{
					stmt->SetString(1, "kkkelleeee");
				}
				stmt->SetString(1+5, "kkkelleeee");

				SQL_NUMERIC_STRUCT num;
				num.precision = 38;
				num.scale = 0;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &id, sizeof(id));
				stmt->SetDecimal(2, num);
				stmt->SetDecimal(2+5, num);

				unsigned char foo[16];
				memcpy(foo, "dddddddddddddddd", 16);
				stmt->SetBinary(3, foo, 16);
				stmt->SetBinary(3+5, foo, 16);

				TIMESTAMP_STRUCT dt_crt;
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				if (j % 11)
				{
					stmt->SetDatetime(4, dt_crt);
				}
				stmt->SetDatetime(4+5, dt_crt);

				SQL_NUMERIC_STRUCT num2;
				num2.precision = 18;
				num2.scale = 6;
				num2.sign = 1;
				memset(num2.val, 0, sizeof(num2.val));
				memcpy(num2.val, &id, sizeof(id));
				stmt->SetDecimal(5, num2);
				stmt->SetDecimal(5+5, num2);

				stmt->AddBatch();
			}
			stmt->ExecuteBatch();
			odbcConnection->CommitTransaction();
		}

		stmt->ExecuteBatch();
		odbcConnection->CommitTransaction();


		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Oracle array insert for %d rows took %d milliseconds", numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;


	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestOracleTimesThree()
{
	try {
		int arraySize = 100;
		int numRows = 100000;
		COdbcConnectionInfo info("Ora2000", "nmdbo", "nmdbo", "nmdbo");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		static const int BASE(5);

		//odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatementPtr stmt = odbcConnection->PrepareInsertStatement("SIMPLE3", arraySize);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);

		for (int i=0; i<numRows; i+=arraySize)
		{
			for (int j=0; j<arraySize; j++)
			{
				int id = i+j;

				if (j % 7)
				{
					stmt->SetString(1, "kkkelleeee");
				}
				stmt->SetString(1+BASE, "kkkelleeee");
				stmt->SetString(1+2*BASE, "kkkelleeee");

				SQL_NUMERIC_STRUCT num;
				num.precision = 38;
				num.scale = 0;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &id, sizeof(id));
				stmt->SetDecimal(2, num);
				stmt->SetDecimal(2+BASE, num);
				stmt->SetDecimal(2+2*BASE, num);

				unsigned char foo[16];
				memcpy(foo, "dddddddddddddddd", 16);
				stmt->SetBinary(3, foo, 16);
				stmt->SetBinary(3+BASE, foo, 16);
				stmt->SetBinary(3+2*BASE, foo, 16);

				TIMESTAMP_STRUCT dt_crt;
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				if (j % 11)
				{
					stmt->SetDatetime(4, dt_crt);
				}
				stmt->SetDatetime(4+BASE, dt_crt);
				stmt->SetDatetime(4+2*BASE, dt_crt);

				SQL_NUMERIC_STRUCT num2;
				num2.precision = 18;
				num2.scale = 6;
				num2.sign = 1;
				memset(num2.val, 0, sizeof(num2.val));
				memcpy(num2.val, &id, sizeof(id));
				stmt->SetDecimal(5, num2);
				stmt->SetDecimal(5+BASE, num2);
				stmt->SetDecimal(5+2*BASE, num2);

				stmt->AddBatch();
			}
			stmt->ExecuteBatch();
			odbcConnection->CommitTransaction();
		}

		stmt->ExecuteBatch();
		odbcConnection->CommitTransaction();


		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Oracle array insert for %d rows took %d milliseconds", numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;


	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void ConvertIntegerToOracleNumber(const int* intVal, SQL_NUMERIC_STRUCT* decVal)
{
	int sign = *intVal<0 ? 0 : 1;
	int absVal = *intVal<0 ? -*intVal : *intVal;

	decVal->precision = 38;
	decVal->scale = 0;
	decVal->sign = sign;
	memset(decVal->val, 0, sizeof(decVal->val));
	memcpy(decVal->val, &absVal, sizeof(absVal));
}

static void ConvertOracleNumberToInteger(const SQL_NUMERIC_STRUCT * in, int * out)
{
	ASSERT(in->scale == 0);
	memcpy(out, in->val, 4);
}


// T_NVARCHARTEST
// STRVAL NVARCHAR2


static void TestNVarcharOracle()
{
	try {
		int arraySize = 1000;

		COdbcConnectionInfo info =
			COdbcConnectionManager::GetConnectionInfo("NetMeter");

		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		COdbcPreparedArrayStatementPtr arrayInsertToTempTable =
			odbcConnection->PrepareInsertStatement(
			"T_NVARCHARTEST", arraySize);

		std::wstring strval;

#if 0
		strval = L"ASCII Test";
		arrayInsertToTempTable->SetWideString(1, strval);
		arrayInsertToTempTable->AddBatch();

		strval = L"Another ASCII test";
		arrayInsertToTempTable->SetWideString(1, strval);
		arrayInsertToTempTable->AddBatch();
#endif

		char rawstr[] = "\xe4\xbb\x98\xe6\xac\xbe\xe4\xba\xba\xe5\xa7\x93\xe5\x90\x8d";

		wchar_t buffer[300];
		int postLen = MultiByteToWideChar(
			CP_UTF8,										// code page
			0,													// character-type options
			rawstr,											// address of string to map
			sizeof(rawstr) / sizeof(rawstr[0]), // number of bytes in string
			buffer,									  // address of wide-character buffer
			300);									    // size of buffer


		unsigned char * raw;
		int i;

		buffer[postLen] = L'\0';
		strval = buffer;

		raw = (unsigned char *) buffer;
		for (i = 0; i < postLen * 2; i++)
			printf("%02x", raw[i]);
		printf("\n");

		arrayInsertToTempTable->SetWideString(1, strval);
		arrayInsertToTempTable->AddBatch();


		char rawstr2[] = "\xe6\xa8\x99\xe6\xba\x96";

		postLen = MultiByteToWideChar(
			CP_UTF8,										// code page
			0,													// character-type options
			rawstr2,											// address of string to map
			sizeof(rawstr2) / sizeof(rawstr2[0]), // number of bytes in string
			buffer,									  // address of wide-character buffer
			300);									    // size of buffer

		buffer[postLen] = L'\0';
		strval = buffer;

		raw = (unsigned char *) buffer;
		for (i = 0; i < postLen * 2; i++)
			printf("%02x", raw[i]);
		printf("\n");

		arrayInsertToTempTable->SetWideString(1, strval);
		arrayInsertToTempTable->AddBatch();


		arrayInsertToTempTable->ExecuteBatch();

		::cout << "Inserted data successfully" << endl;



		::cout << "Reading data" << endl;
		COdbcStatementPtr getData = odbcConnection->CreateStatement();
		COdbcResultSetPtr rs = getData->ExecuteQuery("select strval from t_nvarchartest");

		while (rs->Next())
		{
			wstring str = rs->GetWideString(1);
			ASSERT(!rs->WasNull());

			raw = (unsigned char *) str.c_str();
			for (i = 0; i < (int) str.length() * 2; i++)
				printf("%02x", raw[i]);
			printf("\n");
		}

		// Close up the result set.
		rs->Close();

	} catch (COdbcException& ex) {
		::cerr << ex.toString().c_str() << endl;
	}

}

static void TestAccUsageOracle()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 100;
	
		COdbcConnectionInfo info("tempqa4", "NetMeter", "dy", "dy");
		info.SetDatabaseType(COdbcConnectionInfo::DBTYPE_ORACLE);
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		COdbcIdGenerator gen(info);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		//COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='METRATECH.COM/TESTSERVICE'");

		ASSERT(rs->Next());
		COdbcDecimal id_view_dec = rs->GetDecimal(1);
		ASSERT(!rs->WasNull());
		// Hmmm... Looks like Oracle won't close the cursor properly unless
		// we read to the end of the result set.
		ASSERT(!rs->Next());

		rs->Close();
		rs = COdbcResultSetPtr(NULL);
		getNameID = COdbcStatementPtr(NULL);

		int id_view_temp;
		::ConvertOracleNumberToInteger(id_view_dec.GetBuffer(), &id_view_temp);
		SQL_NUMERIC_STRUCT id_view;
		::ConvertIntegerToOracleNumber(&id_view_temp, &id_view);

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("T_ACC_USAGE", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		int id = 123456;
		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				id++;
				//int id = //gen.GetNext();

				//int id = i+j;
				// Convert to Oracle INTEGER (i.e. NUMBER(38))
				SQL_NUMERIC_STRUCT id_sess;
				::ConvertIntegerToOracleNumber(&id, &id_sess);
				accUsageStatement->SetBigInteger(1, id);
				///accUsageStatement->SetDecimal(1, id_sess);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				int id_acc_temp = 123;
				SQL_NUMERIC_STRUCT id_acc;
				::ConvertIntegerToOracleNumber(&id_acc_temp, &id_acc);
				accUsageStatement->SetInteger(3, id_acc_temp);
				//accUsageStatement->SetDecimal(3, id_acc);
				///accUsageStatement->SetDecimal(4, id_view);
				accUsageStatement->SetInteger(4, id_view_temp);
				int id_usage_interval_temp = 1000;
				SQL_NUMERIC_STRUCT id_usage_interval;
				::ConvertIntegerToOracleNumber(&id_usage_interval_temp, &id_usage_interval);
				///accUsageStatement->SetDecimal(5, id_usage_interval);
				accUsageStatement->SetInteger(5, id_usage_interval_temp);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetInteger(8, id_view_temp);
				///accUsageStatement->SetDecimal(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				accUsageStatement->AddBatch();

			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			numRows += accUsageRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;
		sprintf(buf, "%d rows/second", (long) ((double)numRows / (double) (((tock.QuadPart-tick.QuadPart))/freq.QuadPart)));

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestAccUsageTestServiceStageOracle()
{
	try {
		bool m_bUseDTC = false;
		int m_dwNumRows = 100000;
		int m_dwCommitInterval = 100;
	
		COdbcConnectionInfo info("Ora2000", "NetMeter", "nmdbo", "nmdbo");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);
		// Create a manager for the stream of transactions
		// and subscribe the connection to the transactions.
		//odbcConnection->SetAutoCommit(false);

		COdbcIdGenerator gen(info);

		//COdbcStatementPtr dbOptionsStmt = odbcConnection->CreateStatement();
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'true'");

		// Figure out the id_view 
		COdbcStatementPtr getNameID = odbcConnection->CreateStatement();
		//COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='SAndPDemo/HostedExchange1'");
		COdbcResultSetPtr rs = getNameID->ExecuteQuery("select id_enum_data from t_enum_data where nm_enum_data='METRATECH.COM/TESTSERVICE'");

		ASSERT(rs->Next());
		COdbcDecimal id_view_dec = rs->GetDecimal(1);
		ASSERT(!rs->WasNull());
		// Hmmm... Looks like Oracle won't close the cursor properly unless
		// we read to the end of the result set.
		ASSERT(!rs->Next());

		rs->Close();
		rs = COdbcResultSetPtr(NULL);
		getNameID = COdbcStatementPtr(NULL);

		int id_view_temp;
		::ConvertOracleNumberToInteger(id_view_dec.GetBuffer(), &id_view_temp);
		SQL_NUMERIC_STRUCT id_view;
		::ConvertIntegerToOracleNumber(&id_view_temp, &id_view);

		CDistributedTransaction txStream(m_bUseDTC);
		txStream.Subscribe(odbcConnection);
		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);
		COdbcPreparedArrayStatementPtr accUsageStatement = odbcConnection->PrepareInsertStatement("T_PV_TESTSERVICE_STAGE", m_dwCommitInterval);
		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Array setup took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		int numRows = 0;

		::QueryPerformanceCounter(&tick);
		txStream.BeginTransaction();
		for(int i=0; i<m_dwNumRows; i+=m_dwCommitInterval)
		{
			for (int j=0; j<m_dwCommitInterval; j++)
			{
				int id = gen.GetNext();
				//int id = i+j;
				// Convert to Oracle INTEGER (i.e. NUMBER(38))
				SQL_NUMERIC_STRUCT id_sess;
				::ConvertIntegerToOracleNumber(&id, &id_sess);
				accUsageStatement->SetDecimal(1, id_sess);
				unsigned char tx_UID[16];
				memcpy(tx_UID, "ddddddddddddddd", 16);
				memcpy(tx_UID, &id, 4);
				accUsageStatement->SetBinary(2, tx_UID, 16);
				int id_acc_temp = 123;
				SQL_NUMERIC_STRUCT id_acc;
				::ConvertIntegerToOracleNumber(&id_acc_temp, &id_acc);
				accUsageStatement->SetDecimal(3, id_acc);
				accUsageStatement->SetDecimal(4, id_view);
				int id_usage_interval_temp = 1000;
				SQL_NUMERIC_STRUCT id_usage_interval;
				::ConvertIntegerToOracleNumber(&id_usage_interval_temp, &id_usage_interval);
				accUsageStatement->SetDecimal(5, id_usage_interval);
				// Make id_parent_sess NULL
				//accUsageStatement->SetInteger(6, 0);
				// Make id_prod NULL
				//accUsageStatement->SetInteger(7, 0);
				// id_svc same as id_view
				accUsageStatement->SetDecimal(8, id_view);
				TIMESTAMP_STRUCT dt_session;
				dt_session.day = 2;
				dt_session.month = 2;
				dt_session.year = 1999;
				dt_session.hour = 2;
				dt_session.minute = 2;
				dt_session.second = 2;
				dt_session.fraction = 0;
				accUsageStatement->SetDatetime(9, dt_session);
				SQL_NUMERIC_STRUCT amount;
				amount.precision = 18;
				amount.scale = 6;
				amount.sign = 1;
				memset(amount.val, 0, sizeof(amount.val));
				memcpy(amount.val, &i, sizeof(i));
				accUsageStatement->SetDecimal(10, amount);

				string am_currency("USD");
				accUsageStatement->SetString(11, am_currency);
				
				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				accUsageStatement->SetDatetime(12, dt_crt);
				// Make tx_batch NULL
				//accUsageStatement->SetBinary(13, 0);
				// Make tax_federal NULL
				//accUsageStatement->SetBinary(14, 0);
				// Make tax_state NULL
				//accUsageStatement->SetBinary(15, 0);
				// Make tax_county NULL
				//accUsageStatement->SetBinary(16, 0);
				// Make tax_local NULL
				//accUsageStatement->SetBinary(17, 0);
				// Make tax_other NULL
				//accUsageStatement->SetBinary(18, 0);
				// Make id_pi_instance NULL
				//accUsageStatement->SetInteger(19, 0);
				// Make id_pi_template NULL
				//accUsageStatement->SetInteger(20, 0);

				// Now write to t_pv_testservice
				accUsageStatement->SetString(21, "c_description...................");
				accUsageStatement->SetDatetime(22, dt_crt);
				accUsageStatement->SetDecimal(23, amount);
				accUsageStatement->SetDecimal(24, amount);
				accUsageStatement->SetDecimal(25, amount);
				accUsageStatement->SetDecimal(26, amount);

				accUsageStatement->AddBatch();

			}
			int accUsageRows = accUsageStatement->ExecuteBatch();
			numRows += accUsageRows;

		}
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Insert Time: Inserted %d rows in %d milliseconds", (long) numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

		::QueryPerformanceCounter(&tick);
		txStream.EndTransaction();
		txStream.Unsubscribe(&odbcConnection);
		::QueryPerformanceCounter(&tock);
		sprintf(buf, "Done Time: Commit took %d milliseconds", (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		//dbOptionsStmt->ExecuteUpdate("sp_dboption 'NetMeterStage', 'select into/bulkcopy', 'false'");

		cout << buf << endl;
	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

static void TestOracleOnSQL()
{
	try {
		int arraySize = 100;
		int numRows = 100000;
		COdbcConnectionInfo info("AMAZON", "NetMeterStage", "sa", "");
		COdbcConnectionPtr odbcConnection = new COdbcConnection(info);

		//odbcConnection->SetAutoCommit(false);
		COdbcPreparedArrayStatementPtr stmt = odbcConnection->PrepareInsertStatement("SIMPLE", arraySize);

		LARGE_INTEGER freq;
		LARGE_INTEGER tick;
		LARGE_INTEGER tock;
		::QueryPerformanceFrequency(&freq);
	
		::QueryPerformanceCounter(&tick);

		for (int i=0; i<numRows; i+=arraySize)
		{
			for (int j=0; j<arraySize; j++)
			{
				int id = i+j;
				stmt->SetString(1, "kkkelleeee");
				stmt->SetString(2, "kkkelle");
				// integer in Oracle is actually a DECIMAL(38,0)
				SQL_NUMERIC_STRUCT num;
				num.precision = 18;
				num.scale = 6;
				num.sign = 1;
				memset(num.val, 0, sizeof(num.val));
				memcpy(num.val, &id, sizeof(id));
				stmt->SetDecimal(3, num);

				SYSTEMTIME sysTime;
				::GetSystemTime(&sysTime);
				TIMESTAMP_STRUCT dt_crt;

				dt_crt.year = sysTime.wYear; 
				dt_crt.month = sysTime.wMonth; 
				dt_crt.day = sysTime.wDay; 
				dt_crt.hour = sysTime.wHour; 
				dt_crt.minute = sysTime.wMinute; 
				dt_crt.second = sysTime.wSecond; 
				dt_crt.fraction = 0; 
				stmt->SetDatetime(4, dt_crt);

				stmt->AddBatch();
			}
			stmt->ExecuteBatch();
			odbcConnection->CommitTransaction();
		}

		stmt->ExecuteBatch();
		odbcConnection->CommitTransaction();

		::QueryPerformanceCounter(&tock);
		char buf[256];
		sprintf(buf, "Setup Time: Oracle array insert for %d rows took %d milliseconds", numRows, (long) ((1000*(tock.QuadPart-tick.QuadPart))/freq.QuadPart));
		cout << buf << endl;

	} catch (COdbcException& ex) {
		cerr << ex.toString() << endl;
	}
}

class AddRequest
{
public:
	int a;
	int b;
	int c;
};

class CAsyncAdder : public CAsyncTask<AddRequest>
{
protected:
	virtual void ProcessRequest(AddRequest* aRequest)
	{
		aRequest->c = aRequest->a + aRequest->b;
	}
public:
	CAsyncAdder(MTPipelineLib::IMTLogPtr aLogger)
		:
		CAsyncTask<AddRequest>(aLogger)
	{
	}
};

void TestAsyncAdder()
{
	try {
		MTPipelineLib::IMTLogPtr logger("MetraPipeline.MTLog.1");
		logger->Init("logging", "MTODBC");
		CAsyncAdder adder(logger);

		AddRequest addRequest;
 		adder.StartProcessing();
		addRequest.a = 122;
		addRequest.b = 900;
		adder.SubmitTask(&addRequest);
		AddRequest* response = adder.GetCompletedRequest();
		ASSERT(response == &addRequest);
		ASSERT(addRequest.c = 122 + 900);
		adder.FinishProcessing();
	}
	catch(_com_error& err) {
	}
}

#endif

int main(int argc, char* argv[])
{
	::CoInitialize(NULL);
	//TestAccUsage();
	//TestBcp();
	//TestBcpToAccUsage();
	//TestBcpNonLogged();
	//TestBcpToTempTable();
	//TestBcpToTwoTables();
	//TestColumnArray();
	//TestBcpToAccUsageHostedExchange();
	//TestArrayToAccUsageTestService();
	//TestBcpToAccUsageTestService();
	//TestBcpToAccUsageTestServiceStage();
	//TestBcpToAccUsageTestServiceStageMoveToNetMeterAsync();
	//TestBcpToAccUsageTestServiceStageMoveToNetMeterAsync2();
	//TestBcpToAccUsageTestServiceStageMoveToNetMeter();
	//TestArrayToAccUsageHostedExchange();
	//TestArrayToAccUsageHostedExchangeView();
  //TestIdGenerator();
	//TestPreparedArraySelectStatement();
	//TestPreparedArraySelectStatement3();
	//TestReadOdbc();
   TestMetadata();
//  	TestOracle();
//  	TestOracleTimesTwo();
//  	TestOracleTimesThree();

//	TestAccUsageOracle();
//	TestNVarcharOracle();

	//TestAccUsageTestServiceStageOracle();
	//TestOracleOnSQL();
	//TestAsyncAdder();
	return 0;
}







