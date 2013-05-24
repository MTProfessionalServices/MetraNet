#define NOMINMAX
#include "metra.h"
#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcPreparedBcpStatement.h"
#include "OdbcResultSet.h"
#include "OdbcSessionTypeConversion.h"
#include "OdbcResourceManager.h"

#include <iostream>

#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>
#include <boost/test/unit_test.hpp>
#include <boost/test/unit_test_monitor.hpp>

// struct RowArraySelectTest
// {
//   boost::shared_ptr<COdbcConnection> mConnection;

//   void CreateTestData()
//   {
//     mConnection = boost::shared_ptr<COdbcConnection>(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));

//     try
//     {
//       boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
//       stmt->ExecuteUpdate("DROP TABLE allTypesTable");
//     }
//     catch(...)
//     {
//     }
//     if (mConnection->GetConnectionInfo().IsOracle())
//     {
//       boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
//       stmt->ExecuteUpdate("CREATE TABLE allTypesTable (intValue NUMBER(10), bigintValue NUMBER(20), decValue " +
//                           METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR +
//                           ", doubleValue BINARY_DOUBLE, strValue VARCHAR2(10), wstrValue NVARCHAR2(10), datetimeValue DATE)");
//     }
//     else
//     {
//       boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
//       stmt->ExecuteUpdate("CREATE TABLE allTypesTable (intValue INTEGER, bigintValue BIGINT, decValue " +
//                           METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR +
//                           ", doubleValue DOUBLE PRECISION, strValue VARCHAR(10), wstrValue NVARCHAR(10), datetimeValue DATETIME)");
//     }

//     // Insert 1000 rows
//     boost::shared_ptr<COdbcPreparedArrayStatement> insert(mConnection->PrepareInsertStatement("allTypesTable", 1000));
//     for(int i=0; i<1000; i++)
//     {
//       insert->SetInteger(1, i);
//       insert->SetBigInteger(2, i);
//       DECIMAL decVal;
//       decVal.Hi32 = 0;
//       decVal.Lo64 = i;
//       decVal.sign = 0;
//       decVal.scale = 0;
//       insert->SetDecimal(3, &decVal);
//       insert->SetDouble(4, i);
//       insert->SetString(5, (boost::format("%1%") % i).str());
//       insert->SetWideString(6, (boost::wformat(L"%1%") % i).str());
//       DATE dt (i);
//       insert->SetDatetime(7, &dt);
//       insert->AddBatch();
//     }
//     insert->ExecuteBatch();
//     insert->Finalize();
//   }

//   RowArraySelectTest() 
//   { 
//   }
   
//   void TestRowArraySelect()
//   {
//     CreateTestData();

//     boost::shared_ptr<COdbcPreparedArrayStatement> stmt (mConnection->PrepareStatement(
//                                                            "SELECT intValue, bigintValue, decValue, doubleValue, "
//                                                            "strValue, wstrValue, datetimeValue "
//                                                            "FROM allTypesTable"));

//     const COdbcColumnMetadataVector& md(stmt->GetMetadata());
//     BOOST_REQUIRE_EQUAL(md[0]->GetDataType(), eInteger);
//     BOOST_REQUIRE_EQUAL(md[1]->GetDataType(), eBigInteger);
//     BOOST_REQUIRE_EQUAL(md[2]->GetDataType(), eDecimal);
//     BOOST_REQUIRE_EQUAL(md[3]->GetDataType(), eDouble);
//     BOOST_REQUIRE_EQUAL(md[4]->GetDataType(), eString);
//     BOOST_REQUIRE_EQUAL(md[5]->GetDataType(), eWideString);
//     BOOST_REQUIRE_EQUAL(md[6]->GetDataType(), eDatetime);

//     boost::shared_ptr<COdbcRowArrayResultSet> rs (stmt->ExecuteQueryRowBinding());

//     for(int i=0; i<1000; i++)
//     {
//       BOOST_REQUIRE(rs->Next());
//       BOOST_REQUIRE_EQUAL(rs->GetInteger(1), i);
//       BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), __int64 (i));
//       DECIMAL expectedDec;
//       expectedDec.Hi32 = 0;
//       expectedDec.Lo64 = i;
//       expectedDec.sign = 0;
//       expectedDec.scale = 0;
//       DECIMAL actualDec;
//       ::OdbcNumericToDecimal(rs->GetDecimal(3).GetBuffer(), &actualDec);
//       BOOST_REQUIRE_EQUAL(VARCMP_EQ, ::VarDecCmp(&actualDec, &expectedDec));
//       BOOST_REQUIRE_EQUAL(rs->GetDouble(4), double(i));    
//       BOOST_REQUIRE(0 == std::char_traits<char>::compare(rs->GetString(5).c_str(), (boost::format("%1%") % i).str().c_str(), (boost::format("%1%") % i).str().size()));
//       BOOST_REQUIRE(0 == std::char_traits<wchar_t>::compare(rs->GetWideString(6).c_str(), (boost::wformat(L"%1%") % i).str().c_str(), (boost::format("%1%") % i).str().size()));
// //       TIMESTAMP_STRUCT ts;
// //       ts.day = 1;
// //       ts.month = 1;
// //       ts.year = 2001;
// //       ts.hour = 5;
// //       ts.minute = 11;
// //       ts.second = 23;
// //       ts.fraction = 0;
// //       COdbcTimestamp odbcTimestamp(&ts, true);
// //       BOOST_REQUIRE(rs->GetTimestamp(7) == odbcTimestamp);
//     }
//     BOOST_REQUIRE_EQUAL(false, rs->Next());
//     try
//     {
//       boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
//       stmt->ExecuteUpdate("DROP TABLE allTypesTable");
//     }
//     catch(...)
//     {
//     }
//   }

//   ~RowArraySelectTest()
//   {
//   }

// };

struct VarcharTest
{
  VarcharTest() 
  { 
  }

  ~VarcharTest()
  {
  }

  void TestSmallColumnSize()
  {
    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    boost::shared_ptr<COdbcStatement> stmt (conn->CreateStatement());
    try
    {
      stmt->ExecuteUpdate("DROP TABLE varcharTestTable");
    }
    catch(...)
    {
    }
    if (conn->GetConnectionInfo().IsOracle())
    {
      stmt->ExecuteUpdate("CREATE TABLE varcharTestTable (varcharCol VARCHAR2(8), nvarcharCol NVARCHAR2(4))");
    }
    else
    {
      stmt->ExecuteUpdate("CREATE TABLE varcharTestTable (varcharCol VARCHAR(8), nvarcharCol NVARCHAR(4))");
    }
    
    // Now for the test.  Try to insert different sized data into the table.
    boost::shared_ptr<COdbcPreparedArrayStatement> ins (conn->PrepareInsertStatement("varcharTestTable"));
    ins->SetString(1, "1");
    ins->SetWideString(2, L"1");
    ins->AddBatch();
    ins->ExecuteBatch();
    ins->SetString(1, "11111111");
    ins->SetWideString(2, L"1111");
    ins->AddBatch();
    ins->ExecuteBatch();
    try
    {
      ins->SetString(1, "111111111");
      BOOST_REQUIRE(false);
    }
    catch(COdbcBindingException& )
    {
    }
    try
    {
      ins->SetWideString(2, L"11111");
      BOOST_REQUIRE(false);
    }
    catch(COdbcBindingException& )
    {
    }
    boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT * FROM varcharTestTable ORDER BY varcharCol ASC"));
    BOOST_REQUIRE_EQUAL(true, rs->Next());
    BOOST_REQUIRE_EQUAL(0, strcmp(rs->GetString(1).c_str(), "1"));
    BOOST_REQUIRE_EQUAL(0, wcscmp(rs->GetWideString(2).c_str(), L"1"));
    BOOST_REQUIRE_EQUAL(true, rs->Next());
    BOOST_REQUIRE_EQUAL(0, strcmp(rs->GetString(1).c_str(), "11111111"));
    BOOST_REQUIRE_EQUAL(0, wcscmp(rs->GetWideString(2).c_str(), L"1111"));
    BOOST_REQUIRE_EQUAL(false, rs->Next());
  }
};

struct PrimitiveDataTypeTest
{
  boost::shared_ptr<COdbcConnection> mConnection;

  PrimitiveDataTypeTest() 
  { 
  }

  void ValidateMetadata(const COdbcColumnMetadataVector & md)
  {
    BOOST_REQUIRE_EQUAL(md.size(), 9);
    BOOST_REQUIRE_EQUAL(md[0]->GetDataType(), eInteger);
//     BOOST_REQUIRE_EQUAL(md[0]->GetColumnSize(), 0);
    BOOST_REQUIRE_EQUAL(md[0]->GetOrdinalPosition(), 1);
    BOOST_REQUIRE_EQUAL(md[0]->IsNullable(), false);
    BOOST_REQUIRE_EQUAL(md[1]->GetDataType(), eBigInteger);
//     BOOST_REQUIRE_EQUAL(md[1]->GetColumnSize(), 0);
    BOOST_REQUIRE_EQUAL(md[1]->GetOrdinalPosition(), 2);
    BOOST_REQUIRE_EQUAL(md[1]->IsNullable(), true);
    BOOST_REQUIRE_EQUAL(md[2]->GetDataType(), eDecimal);
//     BOOST_REQUIRE_EQUAL(md[2]->GetColumnSize(), 0);
    BOOST_REQUIRE_EQUAL(md[2]->GetPrecisionRadix(), 10);
    BOOST_REQUIRE_EQUAL(md[2]->GetPrecision(), METRANET_PRECISION_MAX);
    BOOST_REQUIRE_EQUAL(md[2]->GetDecimalDigits(), METRANET_SCALE_MAX);
    BOOST_REQUIRE_EQUAL(md[2]->GetOrdinalPosition(), 3);
    BOOST_REQUIRE_EQUAL(md[2]->IsNullable(), true);
    BOOST_REQUIRE_EQUAL(md[3]->GetDataType(), eDouble);
//     BOOST_REQUIRE_EQUAL(md[3]->GetColumnSize(), 0);
    BOOST_REQUIRE_EQUAL(md[3]->GetOrdinalPosition(), 4);
    BOOST_REQUIRE_EQUAL(md[3]->IsNullable(), false);
    BOOST_REQUIRE_EQUAL(md[4]->GetDataType(), eString);
    BOOST_REQUIRE_EQUAL(md[4]->GetColumnSize(), 10);
    BOOST_REQUIRE_EQUAL(md[4]->GetOrdinalPosition(), 5);
    BOOST_REQUIRE_EQUAL(md[4]->IsNullable(), true);
    BOOST_REQUIRE_EQUAL(md[5]->GetDataType(), eWideString);
    BOOST_REQUIRE_EQUAL(md[5]->GetColumnSize(), 43);
    BOOST_REQUIRE_EQUAL(md[5]->GetOrdinalPosition(), 6);
    BOOST_REQUIRE_EQUAL(md[5]->IsNullable(), true);
    BOOST_REQUIRE_EQUAL(md[6]->GetDataType(), eDatetime);
//     BOOST_REQUIRE_EQUAL(md[6]->GetColumnSize(), 0);
    BOOST_REQUIRE_EQUAL(md[6]->GetOrdinalPosition(), 7);
    BOOST_REQUIRE_EQUAL(md[6]->IsNullable(), false);
    BOOST_REQUIRE_EQUAL(md[7]->GetDataType(), eString);
    BOOST_REQUIRE_EQUAL(md[7]->GetColumnSize(), std::numeric_limits<int>::max());
    BOOST_REQUIRE_EQUAL(md[7]->GetOrdinalPosition(), 8);
    BOOST_REQUIRE_EQUAL(md[7]->IsNullable(), true);
    BOOST_REQUIRE_EQUAL(md[8]->GetDataType(), eWideString);
    if (mConnection->GetConnectionInfo().IsOracle())
      BOOST_REQUIRE_EQUAL(md[8]->GetColumnSize(), std::numeric_limits<int>::max());
    else
      BOOST_REQUIRE_EQUAL(md[8]->GetColumnSize(), std::numeric_limits<int>::max()/2);
    BOOST_REQUIRE_EQUAL(md[8]->GetOrdinalPosition(), 9);
    BOOST_REQUIRE_EQUAL(md[8]->IsNullable(), true);
  }

  void TestConnection()
  {
    mConnection = boost::shared_ptr<COdbcConnection>(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  }
  void TestCreateTable()
  {
    boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
    string arg;
    try
    {
      stmt->ExecuteUpdate("DROP TABLE allTypesTable");
    }
    catch(...)
    {
    }
    if (mConnection->GetConnectionInfo().IsOracle())
    {
      arg =  "CREATE TABLE allTypesTable (intValue NUMBER(10) NOT NULL, bigintValue NUMBER(20), decValue ";
	    arg += METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR;
      arg += ", doubleValue BINARY_DOUBLE NOT NULL, strValue VARCHAR2(10), wstrValue NVARCHAR2(43), datetimeValue DATE NOT NULL, clobValue CLOB, nclobValue NCLOB)";
      stmt->ExecuteUpdate(arg);
    }
    else
    {
      arg =  "CREATE TABLE allTypesTable (intValue INTEGER NOT NULL, bigintValue BIGINT, decValue ";
	    arg += METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR;
      arg += ", doubleValue DOUBLE PRECISION NOT NULL, strValue VARCHAR(10), wstrValue NVARCHAR(43), datetimeValue DATETIME NOT NULL, clobValue TEXT, nclobValue NTEXT)";
      stmt->ExecuteUpdate(arg);
    }

    // Validate the metadata
    ValidateMetadata(mConnection->GetMetadata()->GetColumnMetadata(
                       mConnection->GetConnectionInfo().GetCatalog(), 
                       "allTypesTable"));
  }
  void TestInsertTable()
  {
    boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
    int numRecords = stmt->ExecuteUpdate("INSERT INTO allTypesTable (intValue, bigintValue, decValue, doubleValue, "
                                         "strValue, wstrValue, datetimeValue, clobValue, nclobValue) "
                                         "VALUES (1, 99999999999, 1.0, 1.0, '1.0', N'1.0', {ts '2001-01-01 05:11:23'}, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',N'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')");
    BOOST_REQUIRE_EQUAL(numRecords, 1);
  }

  void TestBulkInsertTableSqlServer()
  {
    COdbcBcpHints hints;
    boost::shared_ptr<COdbcPreparedBcpStatement> stmt (mConnection->PrepareBcpInsertStatement("allTypesTable", hints));
    // Test different batch sizes
    int idx=1;
    for(int batchSize=1; batchSize<=1000; batchSize *= 10)
    {
      for(int i=1; i<=batchSize; i++, idx++)
      {
        stmt->SetInteger(1, idx);
        stmt->SetBigInteger(2, idx);
        DECIMAL dec;
        dec.sign = 0;
        dec.scale = 2;
        dec.Lo64 = idx;
        dec.Hi32 = 0;
        stmt->SetDecimal(3, &dec);
        stmt->SetDouble(4, idx);
        stmt->SetString(5, (boost::format("str_%1%") % idx).str());
        stmt->SetWideString(6, (boost::wformat(L"str_%1%") % idx).str());
        DATE dt;
        VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
        stmt->SetDatetime(7, &dt);
        stmt->SetString(8, std::string(idx,'f'));
        stmt->SetWideString(9, std::wstring(idx,'g'));
        stmt->AddBatch();
      }
      stmt->ExecuteBatch();
    }
    stmt->Finalize();

  }

  void TestBulkInsertTableSqlServerDecimalOutOfRange()
  {
    COdbcBcpHints hints;
    hints.SetMinimallyLogged(true);
    boost::shared_ptr<COdbcPreparedBcpStatement> stmt (mConnection->PrepareBcpInsertStatement("allTypesTable", hints));
    int idx=1;
    for(int i=1; i<=5; i++, idx++)
    {
      stmt->SetInteger(1, idx);
      stmt->SetBigInteger(2, idx);
      DECIMAL dec;
      dec.sign = 0;
      dec.scale = 2;
      dec.Lo64 = idx;
      dec.Hi32 = 0;
      stmt->SetDecimal(3, &dec);
      stmt->SetDouble(4, idx);
      stmt->SetString(5, (boost::format("str_%1%") % idx).str());
      stmt->SetWideString(6, (boost::wformat(L"str_%1%") % idx).str());
      DATE dt;
      VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
      stmt->SetDatetime(7, &dt);
      stmt->SetString(8, std::string(idx,'f'));
      stmt->SetWideString(9, std::wstring(idx,'g'));
      stmt->AddBatch();
    }
    stmt->SetInteger(1, std::numeric_limits<int>::max());
    stmt->SetBigInteger(2, std::numeric_limits<__int64>::max());
    DECIMAL dec;
    dec.sign = 0;
    dec.scale = METRANET_SCALE_MAX;
    // OUT OF RANGE!
    dec.Lo64 = 1000000000000000000LL;
    dec.Hi32 = 0;
    stmt->SetDecimal(3, &dec);
    stmt->SetDouble(4, std::numeric_limits<double>::max());
    stmt->SetString(5, "str_bounds");
    stmt->SetWideString(6, L"str_bounds");
    DATE dt;
    VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
    stmt->SetDatetime(7, &dt);
    stmt->SetString(8, std::string(11,'f'));
    stmt->SetWideString(9, std::wstring(11,'g'));
    for(int i=1; i<=5; i++, idx++)
    {
      stmt->SetInteger(1, idx);
      stmt->SetBigInteger(2, idx);
      DECIMAL dec;
      dec.sign = 0;
      dec.scale = 2;
      dec.Lo64 = idx;
      dec.Hi32 = 0;
      stmt->SetDecimal(3, &dec);
      stmt->SetDouble(4, idx);
      stmt->SetString(5, (boost::format("str_%1%") % idx).str());
      stmt->SetWideString(6, (boost::wformat(L"str_%1%") % idx).str());
      DATE dt;
      VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
      stmt->SetDatetime(7, &dt);
      stmt->SetString(8, std::string(idx,'f'));
      stmt->SetWideString(9, std::wstring(idx,'g'));
      stmt->AddBatch();
    }
    try
    {
      stmt->AddBatch();
      stmt->ExecuteBatch();
      BOOST_REQUIRE(false);
    }
    catch(COdbcException& )
    {
    }
    stmt->Finalize();
  }

  void TestBulkInsertTableOracle()
  {
    COdbcBcpHints hints;
    boost::shared_ptr<COdbcPreparedArrayStatement> stmt (mConnection->PrepareInsertStatement("allTypesTable", 1000));
    mConnection->SetAutoCommit(false);
    // Test different batch sizes
    int idx=1;
    for(int batchSize=1; batchSize<=1000; batchSize *= 10)
    {
      for(int i=1; i<=batchSize; i++, idx++)
      {
        stmt->SetInteger(1, idx);
        stmt->SetBigInteger(2, idx);
        DECIMAL dec;
        dec.sign = 0;
        dec.scale = 2;
        dec.Lo64 = idx;
        dec.Hi32 = 0;
        stmt->SetDecimal(3, &dec);
        stmt->SetDouble(4, idx);
        stmt->SetString(5, (boost::format("str_%1%") % idx).str());
        stmt->SetWideString(6, (boost::wformat(L"str_%1%") % idx).str());
        DATE dt;
        VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
        stmt->SetDatetime(7, &dt);
        stmt->SetString(8, std::string(idx,'f'));
        stmt->SetWideString(9, std::wstring(idx,'g'));
        stmt->AddBatch();
      }
      stmt->ExecuteBatch();
    }
    stmt->Finalize();
    mConnection->CommitTransaction();
    mConnection->SetAutoCommit(true);
  }

  void TestBulkInsertTableOracleWithMarkers()
  {
    COdbcBcpHints hints;
    boost::shared_ptr<COdbcPreparedArrayStatement> stmt (
      mConnection->PrepareStatement(
        "INSERT INTO allTypesTable(intValue, bigintValue, decValue, doubleValue, "
        "strValue, wstrValue, datetimeValue, clobValue, nclobValue) "
        "VALUES (?,?,?,?,?,?,?,?,?)", 1000));
    mConnection->SetAutoCommit(false);
    // Test different batch sizes
    int idx=1;
    for(int batchSize=1; batchSize<=1000; batchSize *= 10)
    {
      for(int i=1; i<=batchSize; i++, idx++)
      {
        stmt->SetInteger(1, idx);
        stmt->SetBigInteger(2, idx);
        DECIMAL dec;
        dec.sign = 0;
        dec.scale = 2;
        dec.Lo64 = idx;
        dec.Hi32 = 0;
        stmt->SetDecimal(3, &dec);
        stmt->SetDouble(4, idx);
        stmt->SetString(5, (boost::format("str_%1%") % idx).str());
        stmt->SetWideString(6, (boost::wformat(L"str_%1%") % idx).str());
        DATE dt;
        VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
        stmt->SetDatetime(7, &dt);
        stmt->SetString(8, std::string(idx,'f'));
        stmt->SetWideString(9, std::wstring(idx,'g'));
        stmt->AddBatch();
      }
      stmt->ExecuteBatch();
    }
    stmt->Finalize();
    mConnection->CommitTransaction();
    mConnection->SetAutoCommit(true);
  }

  void TestBulkInsertTableOracleStringBufferResize()
  {
    COdbcBcpHints hints;
    boost::shared_ptr<COdbcPreparedArrayStatement> stmt (mConnection->PrepareInsertStatement("allTypesTable", 1000));
    mConnection->SetAutoCommit(false);
    // Test different sizes for NVARCHAR column: 1 to 43.
    for(int i=1; i<=43; i++)
    {      
      stmt->SetInteger(1, i);
      stmt->SetBigInteger(2, i);
      DECIMAL dec;
      dec.sign = 0;
      dec.scale = 2;
      dec.Lo64 = i;
      dec.Hi32 = 0;
      stmt->SetDecimal(3, &dec);
      stmt->SetDouble(4, i);
      stmt->SetString(5, std::string(10,'a'));
      std::wstring wstr(20,'b');
      stmt->SetWideString(6, wstr.c_str(), wstr.size());
      DATE dt;
      VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
      stmt->SetDatetime(7, &dt);
      stmt->SetString(8, std::string(i,'f'));
      stmt->SetWideString(9, std::wstring(i,'g'));
      stmt->AddBatch();
    }
    stmt->ExecuteBatch();
    stmt->Finalize();
    mConnection->CommitTransaction();
    mConnection->SetAutoCommit(true);
  }

  void TestBulkInsertTable()
  {
    // Test both BCP and Array Insert on SQL Server, only array insert on Oracle.
    for(int testNum=0; testNum<(mConnection->GetConnectionInfo().IsOracle()?1:2); testNum++)
    {
      boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
      stmt->ExecuteUpdate("TRUNCATE TABLE allTypesTable");
      if (testNum==0)
      {
        TestBulkInsertTableOracle();
      }
      else
      {
        TestBulkInsertTableSqlServer();
        TestBulkInsertTableSqlServerDecimalOutOfRange();
      }
      // Check results
      boost::shared_ptr<COdbcPreparedArrayStatement> rdr (mConnection->PrepareStatement(
                                                            "SELECT intValue, bigintValue, decValue, doubleValue, "
                                                            "strValue, wstrValue, datetimeValue, clobValue, nclobValue "
                                                            "FROM allTypesTable ORDER BY intValue ASC"));
      boost::shared_ptr<COdbcPreparedResultSet> rs (rdr->ExecuteQuery());
      // Should be 1111 records
      for(int i=1; i<=1111; i++)
      {
        BOOST_REQUIRE(rs->Next());
        BOOST_REQUIRE_EQUAL(rs->GetInteger(1), i);
        BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), i);
        DECIMAL expected;
        expected.sign = 0;
        expected.scale = 2;
        expected.Lo64 = i;
        expected.Hi32 = 0;
        DECIMAL actual;
        ::OdbcNumericToDecimal(rs->GetDecimalBuffer(3), &actual);
        BOOST_REQUIRE_EQUAL(VARCMP_EQ, ::VarDecCmp(&expected, &actual));
        BOOST_REQUIRE_EQUAL(rs->GetDouble(4), i);
        BOOST_REQUIRE_EQUAL(0, strcmp(rs->GetString(5).c_str(), (boost::format("str_%1%") % i).str().c_str()));
        BOOST_REQUIRE_EQUAL(0, wcscmp(rs->GetWideString(6).c_str(), (boost::wformat(L"str_%1%") % i).str().c_str()));
        DATE dt;
        VarDateFromStr(L"2007-01-01", LOCALE_SYSTEM_DEFAULT, 0, &dt);
        BOOST_REQUIRE_EQUAL(rs->GetOLEDate(7), dt);
        BOOST_REQUIRE_EQUAL(0, strcmp(rs->GetString(8).c_str(), std::string(i,'f').c_str()));
        BOOST_REQUIRE_EQUAL(0, wcscmp(rs->GetWideString(9).c_str(), std::wstring(i,'g').c_str()));
      }
      BOOST_REQUIRE(!rs->Next());
    }
    {
      boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
      stmt->ExecuteUpdate("TRUNCATE TABLE allTypesTable");
      TestBulkInsertTableOracleStringBufferResize();
    }
    {
      boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
      stmt->ExecuteUpdate("TRUNCATE TABLE allTypesTable");
      TestBulkInsertTableOracleWithMarkers();
    }
  }

  void TestSelectTable()
  {
    boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
    boost::shared_ptr<COdbcResultSet> rs (stmt->ExecuteQuery("SELECT intValue, bigintValue, decValue, doubleValue, "
                                                             "strValue, wstrValue, datetimeValue, clobValue, nclobValue "
                                                             "FROM allTypesTable"));

    // Check the metadata
    ValidateMetadata(rs->GetMetadata());

    BOOST_REQUIRE(rs->Next());
    BOOST_REQUIRE_EQUAL(rs->GetInteger(1), 1);
    BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), 99999999999LL);
//     BOOST_REQUIRE_EQUAL(rs->GetDecimal(3));    
    BOOST_REQUIRE_EQUAL(rs->GetDouble(4), 1.0);    
    BOOST_REQUIRE(0 == std::char_traits<char>::compare(rs->GetString(5).c_str(), "1.0", 3));
    BOOST_REQUIRE(0 == std::char_traits<wchar_t>::compare(rs->GetWideString(6).c_str(), L"1.0", 3));
    TIMESTAMP_STRUCT ts;
		ts.day = 1;
		ts.month = 1;
		ts.year = 2001;
		ts.hour = 5;
		ts.minute = 11;
		ts.second = 23;
		ts.fraction = 0;
    COdbcTimestamp odbcTimestamp(&ts, true);
    BOOST_REQUIRE(rs->GetTimestamp(7) == odbcTimestamp);
    BOOST_REQUIRE(0==strcmp(rs->GetString(8).c_str(), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
    BOOST_REQUIRE(0==wcscmp(rs->GetWideString(9).c_str(), L"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"));
  }
  void TestSelectPreparedTable()
  {
    boost::shared_ptr<COdbcPreparedArrayStatement> stmt (mConnection->PrepareStatement(
                                                           "SELECT intValue, bigintValue, decValue, doubleValue, "
                                                           "strValue, wstrValue, datetimeValue, clobValue, nclobValue "
                                                           "FROM allTypesTable"));

    ValidateMetadata(stmt->GetMetadata());

    boost::shared_ptr<COdbcPreparedResultSet> rs (stmt->ExecuteQuery());

    BOOST_REQUIRE(rs->Next());
    BOOST_REQUIRE_EQUAL(rs->GetInteger(1), 1);
    BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), 99999999999LL);
//     BOOST_REQUIRE_EQUAL(rs->GetDecimal(3));    
    BOOST_REQUIRE_EQUAL(rs->GetDouble(4), 1.0);    
    BOOST_REQUIRE(0 == std::char_traits<char>::compare(rs->GetString(5).c_str(), "1.0", 3));
    BOOST_REQUIRE(0 == std::char_traits<wchar_t>::compare(rs->GetWideString(6).c_str(), L"1.0", 3));
    TIMESTAMP_STRUCT ts;
		ts.day = 1;
		ts.month = 1;
		ts.year = 2001;
		ts.hour = 5;
		ts.minute = 11;
		ts.second = 23;
		ts.fraction = 0;
    COdbcTimestamp odbcTimestamp(&ts, true);
    BOOST_REQUIRE(rs->GetTimestamp(7) == odbcTimestamp);
  }
//   void TestSelectRowArrayTable()
//   {
//     boost::shared_ptr<COdbcPreparedArrayStatement> stmt (mConnection->PrepareStatement(
//                                                            "SELECT intValue, bigintValue, decValue, doubleValue, "
//                                                            "strValue, wstrValue, datetimeValue "
//                                                            "FROM allTypesTable"));

//     const COdbcColumnMetadataVector& md(stmt->GetMetadata());
//     BOOST_REQUIRE_EQUAL(md[0]->GetDataType(), eInteger);
//     BOOST_REQUIRE_EQUAL(md[1]->GetDataType(), eBigInteger);
//     BOOST_REQUIRE_EQUAL(md[2]->GetDataType(), eDecimal);
//     BOOST_REQUIRE_EQUAL(md[3]->GetDataType(), eDouble);
//     BOOST_REQUIRE_EQUAL(md[4]->GetDataType(), eString);
//     BOOST_REQUIRE_EQUAL(md[5]->GetDataType(), eWideString);
//     BOOST_REQUIRE_EQUAL(md[6]->GetDataType(), eDatetime);

//     boost::shared_ptr<COdbcRowArrayResultSet> rs (stmt->ExecuteQueryRowBinding());

//     BOOST_REQUIRE(rs->Next());
//     BOOST_REQUIRE_EQUAL(rs->GetInteger(1), 1);
//     BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), 99999999999LL);
//     DECIMAL expectedDec;
//     expectedDec.Hi32 = 0;
//     expectedDec.Lo64 = 1LL;
//     expectedDec.sign = 0;
//     expectedDec.scale = 0;
//     DECIMAL actualDec;
//     ::OdbcNumericToDecimal(rs->GetDecimal(3).GetBuffer(), &actualDec);
//     BOOST_REQUIRE_EQUAL(VARCMP_EQ, ::VarDecCmp(&actualDec, &expectedDec));
//     BOOST_REQUIRE_EQUAL(rs->GetDouble(4), 1.0);    
//     BOOST_REQUIRE(0 == std::char_traits<char>::compare(rs->GetString(5).c_str(), "1.0", 3));
//     BOOST_REQUIRE(0 == std::char_traits<wchar_t>::compare(rs->GetWideString(6).c_str(), L"1.0", 3));
//     TIMESTAMP_STRUCT ts;
// 		ts.day = 1;
// 		ts.month = 1;
// 		ts.year = 2001;
// 		ts.hour = 5;
// 		ts.minute = 11;
// 		ts.second = 23;
// 		ts.fraction = 0;
//     COdbcTimestamp odbcTimestamp(&ts, true);
//     BOOST_REQUIRE(rs->GetTimestamp(7) == odbcTimestamp);
//   }
  void TestSelectWithComputeTable()
  {
    boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
    boost::shared_ptr<COdbcResultSet> rs (stmt->ExecuteQuery("SELECT intValue + intValue, bigintValue + bigintValue, "
                                                             "decValue + decValue, doubleValue + doubleValue, "
                                                             "strValue, wstrValue, datetimeValue "
                                                             "FROM allTypesTable"));

    const COdbcColumnMetadataVector& md(rs->GetMetadata());
    // Oracle metadata is very bad for computed columns.  Basically,
    // everything comes back as NUMBER(38)
    if(!mConnection->GetConnectionInfo().IsOracle())
    {
      BOOST_REQUIRE_EQUAL(md[0]->GetDataType(), eInteger);
      BOOST_REQUIRE_EQUAL(md[1]->GetDataType(), eBigInteger);
      BOOST_REQUIRE_EQUAL(md[2]->GetDataType(), eDecimal);
      BOOST_REQUIRE_EQUAL(md[3]->GetDataType(), eDouble);
      BOOST_REQUIRE_EQUAL(md[4]->GetDataType(), eString);
      BOOST_REQUIRE_EQUAL(md[5]->GetDataType(), eWideString);
      BOOST_REQUIRE_EQUAL(md[6]->GetDataType(), eDatetime);
    }

    BOOST_REQUIRE(rs->Next());
    BOOST_REQUIRE_EQUAL(rs->GetInteger(1), 2);
    BOOST_REQUIRE_EQUAL(rs->GetBigInteger(2), 199999999998LL);
//     BOOST_REQUIRE_EQUAL(rs->GetDecimal(3));    
    BOOST_REQUIRE_EQUAL(rs->GetDouble(4), 2.0);    
    BOOST_REQUIRE(0 == std::char_traits<char>::compare(rs->GetString(5).c_str(), "1.0", 3));
    BOOST_REQUIRE(0 == std::char_traits<wchar_t>::compare(rs->GetWideString(6).c_str(), L"1.0", 3));
    TIMESTAMP_STRUCT ts;
		ts.day = 1;
		ts.month = 1;
		ts.year = 2001;
		ts.hour = 5;
		ts.minute = 11;
		ts.second = 23;
		ts.fraction = 0;
    COdbcTimestamp odbcTimestamp(&ts, true);
    BOOST_REQUIRE(rs->GetTimestamp(7) == odbcTimestamp);
  }
  void TestDeleteTable()
  {
    boost::shared_ptr<COdbcStatement> stmt (mConnection->CreateStatement());
    stmt->ExecuteUpdate("DROP TABLE allTypesTable");
  }
};

class AutoTable
{
private:
  std::string mDatabaseName;
  std::string mTableName;

public:
  AutoTable(const std::string& databaseName, const std::string& tableName)
    :
    mDatabaseName(databaseName),
    mTableName(tableName)
  {
    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    std::string ddl((boost::format("CREATE TABLE %1%%2%(a %3% NOT NULL PRIMARY KEY)") % 
                    COdbcConnectionManager::GetConnectionInfo(mDatabaseName.c_str()).GetCatalogPrefix() % 
                    tableName %
                    (TRUE == COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle() ? "NUMBER(10)" : "INTEGER")).str());

    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    stmt->ExecuteUpdate(ddl);
  }
  ~AutoTable()
  {
    boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    std::string ddl((boost::format("DROP TABLE %1%%2%") % 
                    COdbcConnectionManager::GetConnectionInfo(mDatabaseName.c_str()).GetCatalogPrefix() % 
                    mTableName).str());

    boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
    stmt->ExecuteUpdate(ddl);
  }
};

struct ResourceManagerTest
{
  void TestHashCode()
  {
    COdbcBcpHints hints1;
    COdbcBcpHints hints2;
    hints2.SetMinimallyLogged(true);
    COdbcBcpHints hints3;
    hints3.SetFireTriggers(true);
    COdbcBcpHints hints4;
    hints4.AddOrder("a");

    COdbcPreparedBcpStatementCommand a("table1", hints1);
    BOOST_REQUIRE(a.GetHashCode() == a.GetHashCode());
    COdbcPreparedBcpStatementCommand b("table1", hints2);
    BOOST_REQUIRE(a.GetHashCode() != b.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() == b.GetHashCode());
    COdbcPreparedBcpStatementCommand c("table1", hints3);
    BOOST_REQUIRE(a.GetHashCode() != c.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != c.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() == c.GetHashCode());
    COdbcPreparedBcpStatementCommand d("table1", hints4);
    BOOST_REQUIRE(a.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(d.GetHashCode() == d.GetHashCode());
    COdbcPreparedBcpStatementCommand e("table1", hints3);
    BOOST_REQUIRE(a.GetHashCode() != e.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != e.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() == e.GetHashCode());
    BOOST_REQUIRE(d.GetHashCode() != e.GetHashCode());
    BOOST_REQUIRE(e.GetHashCode() == e.GetHashCode());
    COdbcPreparedBcpStatementCommand f("table2", hints1);
    BOOST_REQUIRE(a.GetHashCode() != f.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != f.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() != f.GetHashCode());
    BOOST_REQUIRE(d.GetHashCode() != f.GetHashCode());
    BOOST_REQUIRE(e.GetHashCode() != f.GetHashCode());
    BOOST_REQUIRE(f.GetHashCode() == f.GetHashCode());
  }

  void TestHashCodeConnectionCommand()
  {
    COdbcConnectionCommand a(COdbcConnectionManager::GetConnectionInfo("NetMeter"), COdbcConnectionCommand::TXN_AUTO, true);
    BOOST_REQUIRE(a.GetHashCode() == a.GetHashCode());
    COdbcConnectionCommand b(COdbcConnectionManager::GetConnectionInfo("NetMeter"), COdbcConnectionCommand::TXN_AUTO, false);
    BOOST_REQUIRE(a.GetHashCode() != b.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() == b.GetHashCode());
    COdbcConnectionCommand c(COdbcConnectionManager::GetConnectionInfo("NetMeterStage"), COdbcConnectionCommand::TXN_AUTO, true);
    BOOST_REQUIRE(a.GetHashCode() != c.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != c.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() == c.GetHashCode());
    COdbcConnectionCommand d(COdbcConnectionManager::GetConnectionInfo("NetMeterStage"), COdbcConnectionCommand::TXN_AUTO, false);
    BOOST_REQUIRE(a.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(b.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(c.GetHashCode() != d.GetHashCode());
    BOOST_REQUIRE(d.GetHashCode() == d.GetHashCode());
  }

  void TestBcpStatements()
  {
    if (COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle())
    {
      std::cout << "Oracle installation, skipping TestBcpStatements" << std::endl;
      return;
    }
    AutoTable t1("NetMeter", "RM_TestBcpStatements1");
    AutoTable t2("NetMeter", "RM_TestBcpStatements2");

    COdbcBcpHints hints;
    hints.SetMinimallyLogged(true);
    hints.AddOrder("a");
    boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcp1(new COdbcPreparedBcpStatementCommand("RM_TestBcpStatements1", hints));
    boost::shared_ptr<COdbcPreparedBcpStatementCommand> bcp2(new COdbcPreparedBcpStatementCommand("RM_TestBcpStatements2", hints));

    std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpCommands;
    std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayCommands;
    std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertCommands;


    bcpCommands.push_back(bcp1);
    boost::shared_ptr<COdbcConnectionCommand> command1(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));
    bcpCommands.clear();

    bcpCommands.push_back(bcp2);
    boost::shared_ptr<COdbcConnectionCommand> command2(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));    
    bcpCommands.clear();

    try
    {
      bcpCommands.push_back(bcp1);
      bcpCommands.push_back(bcp2);
      boost::shared_ptr<COdbcConnectionCommand> command3(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));
      BOOST_REQUIRE(false);
    }
    catch(std::logic_error& )
    {
    }

    // Now register so we can create connections.
    MTAutoSingleton<COdbcResourceManager> resourceManager;
    resourceManager->RegisterResourceTree(command1);
    resourceManager->RegisterResourceTree(command2);

    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command1);
      COdbcPreparedBcpStatement * stmt = handle[bcp1];

      try
      {
        handle[bcp2];
        BOOST_REQUIRE(false);
      }
      catch(std::exception&)
      {
      }

      stmt->SetInteger(1,1);
      stmt->AddBatch();
      stmt->SetInteger(1,2);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command2);
      try
      {
        handle[bcp1];
        BOOST_REQUIRE(false);
      }
      catch(std::exception&)
      {
      }

      COdbcPreparedBcpStatement * stmt = handle[bcp2];

      stmt->SetInteger(1,1);
      stmt->AddBatch();
      stmt->SetInteger(1,2);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command2);
      try
      {
        handle[bcp1];
        BOOST_REQUIRE(false);
      }
      catch(std::exception&)
      {
      }

      COdbcPreparedBcpStatement * stmt = handle[bcp2];

      stmt->SetInteger(1,3);
      stmt->AddBatch();
      stmt->SetInteger(1,4);
      stmt->AddBatch();
      stmt->ExecuteBatch();

      COdbcConnectionHandle handle2(resourceManager, command2);
      try
      {
        handle2[bcp1];
        BOOST_REQUIRE(false);
      }
      catch(std::exception&)
      {
      }

      stmt = handle2[bcp2];

      stmt->SetInteger(1,5);
      stmt->AddBatch();
      stmt->SetInteger(1,6);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
  }
  void TestArrayStatements()
  {
    AutoTable t1("NetMeter", "RM_TestArrayStatements1");
    AutoTable t2("NetMeter", "RM_TestArrayStatements2");

    boost::shared_ptr<COdbcPreparedArrayStatementCommand> bcp1(new COdbcPreparedArrayStatementCommand("insert into RM_TestArrayStatements1(a) values (?)", 1000, true));
    boost::shared_ptr<COdbcPreparedArrayStatementCommand> bcp2(new COdbcPreparedArrayStatementCommand("insert into RM_TestArrayStatements2(a) values (?)", 1000, true));

    std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpCommands;
    std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayCommands;
    std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertCommands;


    arrayCommands.push_back(bcp1);
    boost::shared_ptr<COdbcConnectionCommand> command1(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));
    arrayCommands.clear();

    arrayCommands.push_back(bcp2);
    boost::shared_ptr<COdbcConnectionCommand> command2(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));    
    arrayCommands.clear();

    arrayCommands.push_back(bcp1);
    arrayCommands.push_back(bcp2);
    boost::shared_ptr<COdbcConnectionCommand> command3(new COdbcConnectionCommand(COdbcConnectionManager::GetConnectionInfo("NetMeter"),
                                                                                  COdbcConnectionCommand::TXN_AUTO,
                                                                                  true,
                                                                                  bcpCommands,
                                                                                  arrayCommands,
                                                                                  insertCommands));
    // Now register so we can create connections.
    MTAutoSingleton<COdbcResourceManager> resourceManager;
    resourceManager->RegisterResourceTree(command1);
    resourceManager->RegisterResourceTree(command2);

    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command1);
      COdbcPreparedArrayStatement * stmt = handle[bcp1];
      BOOST_REQUIRE(handle[bcp2] != NULL);

      stmt->SetInteger(1,1);
      stmt->AddBatch();
      stmt->SetInteger(1,2);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command2);
      COdbcPreparedArrayStatement * stmt = handle[bcp2];
      BOOST_REQUIRE(handle[bcp1] != NULL);

      stmt->SetInteger(1,1);
      stmt->AddBatch();
      stmt->SetInteger(1,2);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
    {
      // BCP in a couple of records
      COdbcConnectionHandle handle(resourceManager, command2);
      COdbcPreparedArrayStatement * stmt = handle[bcp2];
      BOOST_REQUIRE(handle[bcp1] != NULL);

      stmt->SetInteger(1,3);
      stmt->AddBatch();
      stmt->SetInteger(1,4);
      stmt->AddBatch();
      stmt->ExecuteBatch();

      COdbcConnectionHandle handle2(resourceManager, command2);
      stmt = handle2[bcp2];
      BOOST_REQUIRE(handle[bcp1] != NULL);

      stmt->SetInteger(1,5);
      stmt->AddBatch();
      stmt->SetInteger(1,6);
      stmt->AddBatch();
      stmt->ExecuteBatch();
    }
  }
};

struct MTODBCTestSuite : public boost::unit_test::test_suite 
{
  MTODBCTestSuite() 
    : 
    boost::unit_test::test_suite("MTODBCTestSuite") 
  {
    boost::shared_ptr<PrimitiveDataTypeTest> instance( new PrimitiveDataTypeTest );
    boost::unit_test::test_case* connectionTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestConnection, instance );
    boost::unit_test::test_case* createTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestCreateTable, instance );
    boost::unit_test::test_case* insertTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestInsertTable, instance );
    boost::unit_test::test_case* selectTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestSelectTable, instance );
    boost::unit_test::test_case* selectPreparedTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestSelectPreparedTable, instance );
//     boost::unit_test::test_case* selectRowArrayTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestSelectRowArrayTable, instance );
    boost::unit_test::test_case* selectWithComputeTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestSelectWithComputeTable, instance );
    boost::unit_test::test_case* insertBulkTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestBulkInsertTable, instance );
    boost::unit_test::test_case* deleteTableTest = BOOST_CLASS_TEST_CASE( &PrimitiveDataTypeTest::TestDeleteTable, instance );
    createTableTest->depends_on(connectionTest);
    insertTableTest->depends_on(createTableTest);
    selectTableTest->depends_on(insertTableTest);
    selectWithComputeTableTest->depends_on(insertTableTest);
    selectPreparedTableTest->depends_on(insertTableTest);
//     selectRowArrayTableTest->depends_on(insertTableTest);
    insertBulkTest->depends_on(selectTableTest);
//     insertBulkTest->depends_on(selectRowArrayTableTest);
    insertBulkTest->depends_on(selectPreparedTableTest);
    insertBulkTest->depends_on(selectWithComputeTableTest);
    deleteTableTest->depends_on(insertBulkTest);
    add(connectionTest);
    add(createTableTest);
    add(insertTableTest);
    add(selectTableTest);
    add(selectWithComputeTableTest);
    add(selectPreparedTableTest);
//     add(selectRowArrayTableTest);
    add(insertBulkTest);
    add(deleteTableTest);

    boost::shared_ptr<VarcharTest> varcharTestInstance( new VarcharTest );
    add(BOOST_CLASS_TEST_CASE( &VarcharTest::TestSmallColumnSize, 
                               varcharTestInstance ));
//     boost::shared_ptr<RowArraySelectTest> rowArraySelectTestInstance( new RowArraySelectTest );
//     add(BOOST_CLASS_TEST_CASE( &RowArraySelectTest::TestRowArraySelect, 
//                                rowArraySelectTestInstance ));
    boost::shared_ptr<ResourceManagerTest> resourceManagerTestInstance(new ResourceManagerTest );
    add(BOOST_CLASS_TEST_CASE( &ResourceManagerTest::TestHashCode, 
                               resourceManagerTestInstance ));    
    add(BOOST_CLASS_TEST_CASE( &ResourceManagerTest::TestHashCodeConnectionCommand, 
                               resourceManagerTestInstance ));    
    add(BOOST_CLASS_TEST_CASE( &ResourceManagerTest::TestBcpStatements, 
                               resourceManagerTestInstance ));    
    add(BOOST_CLASS_TEST_CASE( &ResourceManagerTest::TestArrayStatements, 
                               resourceManagerTestInstance ));    
  }
};

void _com_error_translator(_com_error err)
{
  BOOST_MESSAGE(err.Description());
}

boost::unit_test::test_suite* init_unit_test_suite( int, char* [] ) 
{
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  boost::unit_test::test_suite* test= BOOST_TEST_SUITE( "MTODBC Test" );

  boost::unit_test::unit_test_monitor.register_exception_translator<_com_error>( &_com_error_translator );
  test->add( new MTODBCTestSuite() );

  return test;
}

