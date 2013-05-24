#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <stdlib.h>
#include <fstream>
#include <iostream>
#include <NTLogServer.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <Timer.h>
#include <Scheduler.h>
#include <ConstantPool.h>
#include <DatabaseSelect.h>
#include <DatabaseInsert.h>
#include <HashAggregate.h>
#include <PlanInterpreter.h>
#include <RecordParser.h>
#include <ImportFunction.h>
#include <DatabaseMetering.h>
#include <DesignTimeExpression.h>
#include <SerializationTest.h>
#include <boost/test/test_tools.hpp>
#include <SortMergeCollector.h>
#include <DatabaseCatalog.h>
#include <AggregateExpression.h>
#include <DesignTimeExternalSort.h>
#include <RecordSerialization.h>
#include <CallStack.h>
#include <SEHException.h>
// #include <MinHeap.h>

#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcStatement.h>
#include <OdbcResultSet.h>

class date_time_traits2
{
public:
  typedef date_time_traits::value value;

  static void from_string(const char * source, value * target)
  {
    _bstr_t bStr(source);
    HRESULT hr = ::VarDateFromStr(bStr, LOCALE_SYSTEM_DEFAULT, 0, target);
    if(FAILED(hr)) throw _com_error(hr);
  }
};


class AutoLogServer
{
private:
  NTLogServer * mLog;
public:
  AutoLogServer()
    :
    mLog(NULL)
  {
    mLog = NTLogServer::GetInstance();
  }
  ~AutoLogServer()
  {
    if (mLog != NULL)
      NTLogServer::ReleaseInstance();
  }
};


// #define BOOST_REQUIRE(x) ASSERT(x)

static std::wstring MTgetenv(const std::wstring& varname)
{
  const wchar_t * val = _wgetenv(varname.c_str());
  if (val)
  {
    return val;
  }
  throw std::runtime_error("Environment variable not set");
}

static void TestMappedFile()
{
  MappedFile mmaped(MTgetenv(L"METRATECHTESTDATABASE") + 
                    L"\\Development\\Core\\DataAccess\\MemoryTable\\input.txt");
  MappedBuffer buffer;
  mmaped.Map(0, 4096, &buffer);
  char buf [4];
  buffer.Read((unsigned char *)buf, 4);
  if (0 != memcmp("asld", buf, 4)) throw std::exception("test failed");
}

static void TestMappedStream()
{
  // Test small file
  {
    MappedFile mmaped(MTgetenv(L"METRATECHTESTDATABASE") +
                      L"\\Development\\Core\\DataAccess\\MemoryTable\\smallinput.txt");
    MappedInputStream buffer(&mmaped, 1);
    char buf [34];
    buffer.Read((unsigned char *)buf, 34);
    if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("small test failed");
    // Read the next 255 lines
    for(int i=0; i<255; i++)
    {
      buffer.Read((unsigned char *)buf, 34);
      if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("small test failed");
    }
    // This guy should throw
    bool thrown = true;
    try
    {
      buffer.Read((unsigned char *)buf, 1);
      thrown = false;
    }
    catch(std::exception & )
    {
    }
    if (!thrown) throw std::exception("small test failed");
  }
  // Test medium file
  {
    MappedFile mmaped(MTgetenv(L"METRATECHTESTDATABASE") +
                      L"\\Development\\Core\\DataAccess\\MemoryTable\\mediuminput.txt");
    MappedInputStream buffer(&mmaped, 1);
    char buf [34];
    for(int i=0; i<3584; i++)
    {
      buffer.Read((unsigned char *)buf, 34);
      if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("medium test failed");
    }
    // This guy should throw
    bool thrown = true;
    try
    {
      buffer.Read((unsigned char *)buf, 1);
      thrown = false;
    }
    catch(std::exception & )
    {
    }
    if (!thrown) throw std::exception("medium test failed");
  }  
  // Test large file with single page view
  {
    MappedFile mmaped(MTgetenv(L"METRATECHTESTDATABASE") +
                      L"\\Development\\Core\\DataAccess\\MemoryTable\\largeinput.txt");
    MappedInputStream buffer(&mmaped, 1);
    char buf [34];
    for(int i=0; i<182784; i++)
    {
      buffer.Read((unsigned char *)buf, 34);
      if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("large test failed");
    }
    // This guy should throw
    bool thrown = true;
    try
    {
      buffer.Read((unsigned char *)buf, 1);
      thrown = false;
    }
    catch(std::exception & )
    {
    }
    if (!thrown) throw std::exception("large test failed");
  }  
  // Test large file with multi-page view
  {
    MappedFile mmaped(MTgetenv(L"METRATECHTESTDATABASE") +
                      L"\\Development\\Core\\DataAccess\\MemoryTable\\largeinput.txt");
    MappedInputStream buffer(&mmaped, 1000000);
    char buf [34];
    for(int i=0; i<182784; i++)
    {
      buffer.Read((unsigned char *)buf, 34);
      if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("large test failed");
    }
    // This guy should throw
    bool thrown = true;
    try
    {
      buffer.Read((unsigned char *)buf, 1);
      thrown = false;
    }
    catch(std::exception & )
    {
    }
    if (!thrown) throw std::exception("large test failed");
  }  
  // Test large file with multi-page view
//   {
//     std::cout << "Very large test started..." << std::endl;
//     MappedFile mmaped(L"C:\\mainline\\development\\Source\\Core\\DataAccess\\MemoryTable\\test\\verylargeinput.txt");
//     MappedInputStream buffer(&mmaped, 1000000);
//     char buf [34];
//     for(int i=0; i<7311360; i++)
//     {
//       buffer.Read((unsigned char *)buf, 34);
//       if (0 != memcmp("asldfj;lasdkfj;lasdjf;lsdfjlskdf\r\n", buf, 34)) throw std::exception("very large test failed");
//     }
//     // This guy should throw
//     bool thrown = true;
//     try
//     {
//       buffer.Read((unsigned char *)buf, 1);
//       thrown = false;
//     }
//     catch(std::exception & )
//     {
//     }
//     std::cout << "Very large test ended..." << std::endl;
//     if (!thrown) throw std::exception("very large test failed");
//   }  
}

void TestRecordMetadataCopy()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  ASSERT(3 == recordA.GetNumColumns());
  ASSERT(1 == recordA.GetBitmapLength());
  ASSERT(20 == recordA.GetRecordLength());
  ASSERT(8 == recordA.GetDataOffset());
  RecordMetadata recordB(recordA);
  ASSERT(3 == recordB.GetNumColumns());
  ASSERT(1 == recordB.GetBitmapLength());
  ASSERT(20 == recordB.GetRecordLength());
  ASSERT(8 == recordB.GetDataOffset());

  RecordMetadata recordC;
  RecordMetadata recordD(recordC);
}

void TestSmallRecordMerge()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  ASSERT(3 == recordA.GetNumColumns());
  ASSERT(1 == recordA.GetBitmapLength());
  ASSERT(20 == recordA.GetRecordLength());
  ASSERT(8 == recordA.GetDataOffset());
  LogicalRecord logicalB;
  logicalB.push_back(L"d", LogicalFieldType::Integer(false));
  logicalB.push_back(L"e", LogicalFieldType::Integer(false));
  logicalB.push_back(L"f", LogicalFieldType::Binary(false));
  logicalB.push_back(L"g", LogicalFieldType::String(false));
  logicalB.push_back(L"h", LogicalFieldType::String(false));
  RecordMetadata recordB(logicalB);
 
  RecordMerge merge(&recordA, &recordB);
  ASSERT(8 == merge.GetRecordMetadata()->GetNumColumns());
  ASSERT(1 == merge.GetRecordMetadata()->GetBitmapLength());
  ASSERT(52 == merge.GetRecordMetadata()->GetRecordLength());
  ASSERT(8 == merge.GetRecordMetadata()->GetDataOffset());

  unsigned char * bufferA = new unsigned char[recordA.GetRecordLength()];
  unsigned char * bufferB = new unsigned char[recordB.GetRecordLength()];
  unsigned char * bufferMerge = new unsigned char[merge.GetRecordMetadata()->GetRecordLength()];
  memset(bufferA, 0, recordA.GetRecordLength());
  memset(bufferB, 0, recordB.GetRecordLength());
  memset(bufferMerge, 0, merge.GetRecordMetadata()->GetRecordLength());

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  recordB.GetColumn(L"d")->SetLongValue(bufferB, 332);
  recordB.GetColumn(L"e")->SetNull(bufferB);
  recordB.GetColumn(L"f")->SetNull(bufferB);
  recordB.GetColumn(L"g")->SetStringValue(bufferB, L"oo3w");
  recordB.GetColumn(L"h")->SetStringValue(bufferB, L"883");

  merge.Merge(bufferA, bufferB, bufferMerge);

  ASSERT(12==merge.GetRecordMetadata()->GetColumn(L"a")->GetLongValue(bufferMerge));
  ASSERT(23==merge.GetRecordMetadata()->GetColumn(L"b")->GetLongValue(bufferMerge));
  ASSERT(0==wcscmp(L"23", merge.GetRecordMetadata()->GetColumn(L"c")->GetStringValue(bufferMerge)));
  ASSERT(332==merge.GetRecordMetadata()->GetColumn(L"d")->GetLongValue(bufferMerge));
  ASSERT(true==merge.GetRecordMetadata()->GetColumn(L"e")->GetNull(bufferMerge));
  ASSERT(true==merge.GetRecordMetadata()->GetColumn(L"f")->GetNull(bufferMerge));
  ASSERT(0==wcscmp(L"oo3w", merge.GetRecordMetadata()->GetColumn(L"g")->GetStringValue(bufferMerge)));
  ASSERT(0==wcscmp(L"883", merge.GetRecordMetadata()->GetColumn(L"h")->GetStringValue(bufferMerge)));

  delete [] bufferA; 
  delete [] bufferB;
  delete [] bufferMerge;
}

void TestLargeRecordMerge()
{
  LogicalRecord logicalA;
  for(int i=0; i<100; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"a%d", i);
    logicalA.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordA(logicalA);
  ASSERT(100 == recordA.GetNumColumns());
  ASSERT(4 == recordA.GetBitmapLength());
  ASSERT(420 == recordA.GetRecordLength());
  ASSERT(20 == recordA.GetDataOffset());
  LogicalRecord logicalB;
  for(int i=0; i<200; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"b%d", i);
    logicalB.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordB(logicalB);
 
  RecordMerge merge(&recordA, &recordB);
  ASSERT(300 == merge.GetRecordMetadata()->GetNumColumns());
  ASSERT(10 == merge.GetRecordMetadata()->GetBitmapLength());
  ASSERT(1244 == merge.GetRecordMetadata()->GetRecordLength());
  ASSERT(44 == merge.GetRecordMetadata()->GetDataOffset());

  unsigned char * bufferA = new unsigned char[recordA.GetRecordLength()]; 
  unsigned char * bufferB = new unsigned char[recordB.GetRecordLength()]; 
  unsigned char * bufferMerge = new unsigned char[merge.GetRecordMetadata()->GetRecordLength()];
  memset(bufferA, 0, recordA.GetRecordLength());
  memset(bufferB, 0, recordB.GetRecordLength());
  memset(bufferMerge, 0, merge.GetRecordMetadata()->GetRecordLength());

  for(int i=0; i<100; i++)
  {
    if ((i % 11) == 5)
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetNull(bufferA);
    }
    else
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetLongValue(bufferA, i);
    }
  }
  for(int i=0; i<200; i++)
  {
    if ((i % 7) == 3)
    {
      recordB.GetColumn((boost::wformat(L"b%1%") % i).str())->SetNull(bufferB);
    }
    else
    {
      recordB.GetColumn((boost::wformat(L"b%1%") % i).str())->SetLongValue(bufferB, i+100);
    }
  }

  merge.Merge(bufferA, bufferB, bufferMerge);

  for(int i=0; i<300; i++)
  {
    std::wstring col(i < 100 ?  
                     (boost::wformat(L"a%1%") % i).str() : 
                     (boost::wformat(L"b%1%") % (i-100)).str());
    if ((i < 100 && (i % 11) == 5) ||
        (i >= 100 && ((i-100) % 7) == 3))
    {
      ASSERT(true == merge.GetRecordMetadata()->GetColumn(col)->GetNull(bufferMerge));
    }
    else
    {
      ASSERT(i == merge.GetRecordMetadata()->GetColumn(col)->GetLongValue(bufferMerge));
    }
  }

  delete [] bufferA; 
  delete [] bufferB;
  delete [] bufferMerge;
}

void TestLargeRecordMerge2()
{
  LogicalRecord logicalA;
  for(int i=0; i<95; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"a%d", i);
    logicalA.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordA(logicalA);
  ASSERT(95 == recordA.GetNumColumns());
  ASSERT(3 == recordA.GetBitmapLength());
  ASSERT(396 == recordA.GetRecordLength());
  ASSERT(16 == recordA.GetDataOffset());
  LogicalRecord logicalB;
  for(int i=0; i<100; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"b%d", i);
    logicalB.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordB(logicalB);
 
  RecordMerge merge(&recordA, &recordB);
  ASSERT(195 == merge.GetRecordMetadata()->GetNumColumns());
  ASSERT(7 == merge.GetRecordMetadata()->GetBitmapLength());
  ASSERT(812 == merge.GetRecordMetadata()->GetRecordLength());
  ASSERT(32 == merge.GetRecordMetadata()->GetDataOffset());

  unsigned char * bufferA = new unsigned char[recordA.GetRecordLength()]; 
  unsigned char * bufferB = new unsigned char[recordB.GetRecordLength()]; 
  unsigned char * bufferMerge = new unsigned char[merge.GetRecordMetadata()->GetRecordLength()];
  memset(bufferA, 0, recordA.GetRecordLength());
  memset(bufferB, 0, recordB.GetRecordLength());
  memset(bufferMerge, 0, merge.GetRecordMetadata()->GetRecordLength());

  for(int i=0; i<95; i++)
  {
    if ((i % 11) == 5)
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetNull(bufferA);
    }
    else
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetLongValue(bufferA, i);
    }
  }
  for(int i=0; i<100; i++)
  {
    if ((i % 7) == 3)
    {
      recordB.GetColumn((boost::wformat(L"b%1%") % i).str())->SetNull(bufferB);
    }
    else
    {
      recordB.GetColumn((boost::wformat(L"b%1%") % i).str())->SetLongValue(bufferB, i+95);
    }
  }

  merge.Merge(bufferA, bufferB, bufferMerge);

  for(int i=0; i<195; i++)
  {
    std::wstring col(i < 95 ?  
                     (boost::wformat(L"a%1%") % i).str() : 
                     (boost::wformat(L"b%1%") % (i-95)).str());
    if ((i < 95 && (i % 11) == 5) ||
        (i >= 95 && ((i-95) % 7) == 3))
    {
      ASSERT(true == merge.GetRecordMetadata()->GetColumn(col)->GetNull(bufferMerge));
    }
    else
    {
      ASSERT(i == merge.GetRecordMetadata()->GetColumn(col)->GetLongValue(bufferMerge));
    }
  }

  delete [] bufferA; 
  delete [] bufferB;
  delete [] bufferMerge;
}

void TestSmallRecordProjection1()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  ASSERT(5 == recordA.GetNumColumns());
  ASSERT(1 == recordA.GetBitmapLength());
  ASSERT(32 == recordA.GetRecordLength());
  ASSERT(8 == recordA.GetDataOffset());
  LogicalRecord logicalB;
  logicalB.push_back(L"a", LogicalFieldType::Integer(false));
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordB(logicalB);
 
  RecordProjection project(recordA, recordB);

  record_t bufferA = recordA.Allocate();
  record_t bufferB = recordB.Allocate();

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 882343323LL);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");

  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(12==recordB.GetColumn(L"a")->GetLongValue(bufferB));
  BOOST_REQUIRE(23==recordB.GetColumn(L"b")->GetLongValue(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"23", recordB.GetColumn(L"c")->GetStringValue(bufferB)));

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetNull(bufferA);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"8883234");
  recordA.GetColumn(L"d")->SetNull(bufferA);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");
  
  recordB.Free(bufferB);
  bufferB = recordB.Allocate();
  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(12==recordB.GetColumn(L"a")->GetLongValue(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"b")->GetNull(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"8883234", recordB.GetColumn(L"c")->GetStringValue(bufferB)));

  recordA.Free(bufferA);
  recordB.Free(bufferB);
}

void TestSmallRecordProjection2()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  ASSERT(5 == recordA.GetNumColumns());
  ASSERT(1 == recordA.GetBitmapLength());
  ASSERT(32 == recordA.GetRecordLength());
  ASSERT(8 == recordA.GetDataOffset());
  LogicalRecord logicalB;
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  logicalB.push_back(L"d", LogicalFieldType::BigInteger(false));
  RecordMetadata recordB(logicalB);
 
  RecordProjection project(recordA, recordB);

  record_t bufferA = recordA.Allocate();
  record_t bufferB = recordB.Allocate();

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 882343323LL);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");

  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(23==recordB.GetColumn(L"b")->GetLongValue(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"23", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(882343323LL==recordB.GetColumn(L"d")->GetBigIntegerValue(bufferB));

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetNull(bufferA);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"8883234");
  recordA.GetColumn(L"d")->SetNull(bufferA);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");
  
  recordB.Free(bufferB);
  bufferB = recordB.Allocate();
  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(recordB.GetColumn(L"b")->GetNull(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"8883234", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(recordB.GetColumn(L"d")->GetNull(bufferB));

  recordA.Free(bufferA);
  recordB.Free(bufferB);
}

void TestSmallRecordProjection3()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  LogicalRecord logicalB;
  logicalB.push_back(L"f", LogicalFieldType::Double(false));
  logicalB.push_back(L"g", LogicalFieldType::BigInteger(false));
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  logicalB.push_back(L"d", LogicalFieldType::BigInteger(false));
  RecordMetadata recordB(logicalB);
 
  RecordProjection project(recordA, recordB);

  record_t bufferA = recordA.Allocate();
  record_t bufferB = recordB.Allocate();

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 882343323LL);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");

  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(recordB.GetColumn(L"f")->GetNull(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"g")->GetNull(bufferB));
  BOOST_REQUIRE(23==recordB.GetColumn(L"b")->GetLongValue(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"23", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(882343323LL==recordB.GetColumn(L"d")->GetBigIntegerValue(bufferB));

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetNull(bufferA);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"8883234");
  recordA.GetColumn(L"d")->SetNull(bufferA);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");
  
  recordB.Free(bufferB);
  bufferB = recordB.Allocate();
  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(recordB.GetColumn(L"f")->GetNull(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"g")->GetNull(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"b")->GetNull(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"8883234", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(recordB.GetColumn(L"d")->GetNull(bufferB));

  recordA.Free(bufferA);
  recordB.Free(bufferB);
}

void TestSmallRecordProjection4()
{
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  LogicalRecord logicalB;
  logicalB.push_back(L"f", LogicalFieldType::Double(false));
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"g", LogicalFieldType::BigInteger(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  logicalB.push_back(L"h", LogicalFieldType::BigInteger(false));
  RecordMetadata recordB(logicalB);
 
  RecordProjection project(recordA, recordB);

  record_t bufferA = recordA.Allocate();
  record_t bufferB = recordB.Allocate();

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 882343323LL);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");

  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(recordB.GetColumn(L"f")->GetNull(bufferB));
  BOOST_REQUIRE(23==recordB.GetColumn(L"b")->GetLongValue(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"g")->GetNull(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"23", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(recordB.GetColumn(L"h")->GetNull(bufferB));

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  recordA.GetColumn(L"b")->SetNull(bufferA);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"8883234");
  recordA.GetColumn(L"d")->SetNull(bufferA);
  recordA.GetColumn(L"e")->SetStringValue(bufferA, L"9992333");
  
  recordB.Free(bufferB);
  bufferB = recordB.Allocate();
  project.Project(bufferA, bufferB);

  BOOST_REQUIRE(recordB.GetColumn(L"f")->GetNull(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"b")->GetNull(bufferB));
  BOOST_REQUIRE(recordB.GetColumn(L"g")->GetNull(bufferB));
  BOOST_REQUIRE(0 == wcscmp(L"8883234", recordB.GetColumn(L"c")->GetStringValue(bufferB)));
  BOOST_REQUIRE(recordB.GetColumn(L"h")->GetNull(bufferB));

  recordA.Free(bufferA);
  recordB.Free(bufferB);
}

void TestLargeRecordProjection()
{
  LogicalRecord logicalA;
  for(int i=0; i<100; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"a%d", i);
    logicalA.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordA(logicalA);
  LogicalRecord logicalB;
  for(int i=0; i<25; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"a%d", i+10);
    logicalB.push_back(buf, LogicalFieldType::Integer(false));
  }
  for(int i=25; i<50; i++)
  {
    wchar_t buf[100];
    wsprintf(buf, L"a%d", i+50);
    logicalB.push_back(buf, LogicalFieldType::Integer(false));
  }
  RecordMetadata recordB(logicalB);
 
  RecordProjection project(recordA, recordB);

  record_t bufferA = recordA.Allocate();
  record_t bufferB = recordB.Allocate();

  for(int i=0; i<100; i++)
  {
    if ((i % 11) == 5)
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetNull(bufferA);
    }
    else
    {
      recordA.GetColumn((boost::wformat(L"a%1%") % i).str())->SetLongValue(bufferA, i);
    }
  }

  project.Project(bufferA, bufferB);

  for(int i=0; i<25; i++)
  {
    if (((i+10) % 11) == 5)
    {
      BOOST_REQUIRE(recordB.GetColumn((boost::wformat(L"a%1%") % i).str())->GetNull(bufferB));
    }
    else
    {
      BOOST_REQUIRE(i+10 == recordB.GetColumn((boost::wformat(L"a%1%") % i).str())->GetLongValue(bufferB));
    }
  }
  for(int i=25; i<50; i++)
  {
    if (((i+50) % 11) == 5)
    {
      BOOST_REQUIRE(recordB.GetColumn((boost::wformat(L"a%1%") % i).str())->GetNull(bufferB));
    }
    else
    {
      BOOST_REQUIRE(i+50 == recordB.GetColumn((boost::wformat(L"a%1%") % i).str())->GetLongValue(bufferB));
    }
  }

  recordA.Free(bufferA);
  recordB.Free(bufferB);
}

/**
 * Eliminated this version of serializer.
 *
void TestRecordSerialization()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"b", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"f", LogicalFieldType::Double(false));
  RecordMetadata recordA(logicalA);
  record_t bufferA = recordA.Allocate();
  // 4 bytes
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  // 4 bytes
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  // 4 + 6 = 10 bytes
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  // 8 bytes
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 888223233LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"e")->SetBigIntegerValue(bufferA, 773234LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"f")->SetDoubleValue(bufferA, 23.2334);

  RecordSerializer serializeA(recordA);
  unsigned char * serializationBufferA = new unsigned char [128];
  unsigned char * buf = serializeA.Serialize(bufferA, serializationBufferA, serializationBufferA+128);
  BOOST_REQUIRE(recordA.GetDataOffset()+50 == (buf-serializationBufferA));

  RecordDeserializer deserializeA(recordA);
  record_t bufferB = recordA.Allocate();
  deserializeA.Deserialize(serializationBufferA, bufferB);
  BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
  recordA.Free(bufferA);
  recordA.Free(bufferB);
  delete [] serializationBufferA;

}

void TestRecordSerializationBug()
{
  // Here is bug that I found while testing discounts at one point.
  // It boils down to a bug in dealing with serialization of
  // nullable indirect columns (the column c_GroupSubscriptionName below).
  LogicalRecord logicalA;
  logicalA.push_back(L"c_AggregationID", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"c__SubscriptionID", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"c__PriceableItemInstanceID", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c_DiscountIntervalID", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c__AccountID", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c__PayingAccount", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c_BillingIntervalStart", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_BillingIntervalEnd", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c__PriceableItemTemplateID", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c__ProductOfferingID", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c_DiscountIntervalStart", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_DiscountIntervalEnd", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_SubscriptionStart", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_SubscriptionEnd", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_DiscountIntervalSubStart", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_DiscountIntervalSubEnd", LogicalFieldType::Datetime(false));
  logicalA.push_back(L"c_GroupDiscountPass", LogicalFieldType::Integer(true));
  logicalA.push_back(L"c_GroupSubscriptionID", LogicalFieldType::Integer(true));
  logicalA.push_back(L"c_GroupSubscriptionName", LogicalFieldType::String(true));
  logicalA.push_back(L"c_GroupDiscountAmount", LogicalFieldType::Decimal(true));
  logicalA.push_back(L"c_GroupDiscountPercent", LogicalFieldType::Decimal(true));
  logicalA.push_back(L"c_GroupDiscountIsShared", LogicalFieldType::Integer(true));
  logicalA.push_back(L"c_GroupDiscountIntervalID", LogicalFieldType::Integer(true));
  logicalA.push_back(L"c__IntervalID", LogicalFieldType::Integer(true));
  RecordMetadata recordA(logicalA);
  record_t bufferA = recordA.Allocate();
  // 6*4 = 24 bytes
  recordA.GetColumn(L"c_AggregationID")->SetLongValue(bufferA, 1033);
  recordA.GetColumn(L"c__SubscriptionID")->SetLongValue(bufferA, 1033);
  recordA.GetColumn(L"c__PriceableItemInstanceID")->SetLongValue(bufferA, 1190);
  recordA.GetColumn(L"c_DiscountIntervalID")->SetLongValue(bufferA, 912654355);
  recordA.GetColumn(L"c__AccountID")->SetLongValue(bufferA, 194);
  recordA.GetColumn(L"c__PayingAccount")->SetLongValue(bufferA, 194);
  // 2*8 = 16 bytes
  date_time_traits::value tmp;
  date_time_traits2::from_string("2/2/2008", &tmp);
  recordA.SetDatetimeValue(bufferA, 6, tmp);
  date_time_traits2::from_string("3/1/2008 11:59:59 PM", &tmp);
  recordA.SetDatetimeValue(bufferA, 7, tmp);
  // 2*4 = 8 bytes
  recordA.SetLongValue(bufferA, 8, 1181);
  recordA.SetLongValue(bufferA, 9, 1189);
  // 6*8 = 48 bytes
  date_time_traits2::from_string("1/18/2008", &tmp);
  recordA.SetDatetimeValue(bufferA, 10, tmp);
  date_time_traits2::from_string("2/17/2008 11:59:59 PM", &tmp);
  recordA.SetDatetimeValue(bufferA, 11, tmp);
  date_time_traits2::from_string("2/2/2008", &tmp);
  recordA.SetDatetimeValue(bufferA, 12, tmp);
  date_time_traits2::from_string("1/1/2038", &tmp);
  recordA.SetDatetimeValue(bufferA, 13, tmp);
  date_time_traits2::from_string("2/2/2008", &tmp);
  recordA.SetDatetimeValue(bufferA, 14, tmp);
  date_time_traits2::from_string("2/17/2008 11:59:59 PM", &tmp);
  recordA.SetDatetimeValue(bufferA, 15, tmp);
  // 2*4 = 8 bytes
  recordA.SetNull(bufferA, 16);
  recordA.SetNull(bufferA, 17);
  // 4  bytes
  recordA.SetNull(bufferA, 18);
  // 2*16 = 32 bytes
  recordA.SetNull(bufferA, 19);
  recordA.SetNull(bufferA, 20);
  // 3*4 = 12 bytes
  recordA.SetLongValue(bufferA, 21, 0);
  recordA.SetNull(bufferA, 22);
  recordA.SetLongValue(bufferA, 23, 913506307);

  RecordSerializer serializeA(recordA);
  unsigned char * serializationBufferA = new unsigned char [1024];
  unsigned char * buf = serializeA.Serialize(bufferA, serializationBufferA, serializationBufferA+1024);
  BOOST_REQUIRE(recordA.GetDataOffset()+152 == (buf-serializationBufferA));
  BOOST_REQUIRE(recordA.GetRecordLength() == (buf-serializationBufferA));

  // The correct serialized result is a memcpy of the source buffer execept
  // the string null becomes a -1.
  unsigned char * expected = new unsigned char [recordA.GetRecordLength()];
  memcpy(expected, bufferA, recordA.GetRecordLength());
  *((void **)recordA.GetColumn(18)->GetDirectBuffer(expected)) = (void *)(-1);
  BOOST_REQUIRE_EQUAL(0, memcmp(expected, serializationBufferA, recordA.GetRecordLength()));
  delete [] expected;
  
  RecordDeserializer deserializeA(recordA);
  record_t bufferB = recordA.Allocate();
  deserializeA.Deserialize(serializationBufferA, bufferB);
  BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
  recordA.Free(bufferA);
  recordA.Free(bufferB);
  delete [] serializationBufferA;
}
*/
void TestPrefixedUCS2Import()
{
  ParsePrefixedUCS2String stringParse;
  wchar_t nullTerminatedString [10] = L"123456789";
  wchar_t inputBuffer[10];
  *((short *)inputBuffer) = 9*sizeof(wchar_t);
  memcpy(inputBuffer+1, nullTerminatedString, sizeof(wchar_t)*9); 
  wchar_t outputBuffer[10];
  bool ret;
  int inputConsumed, outputConsumed;
  ret = stringParse.Import((const unsigned char *)inputBuffer, 6, inputConsumed,
                           (unsigned char *)outputBuffer, sizeof(wchar_t)*10, outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == sizeof(wchar_t)*10);
  ASSERT(outputConsumed == sizeof(wchar_t)*10);

  ret = stringParse.Import((const unsigned char *)inputBuffer, sizeof(wchar_t)*10, inputConsumed,
                           (unsigned char *)outputBuffer, 6, outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == sizeof(wchar_t)*10);
  ASSERT(outputConsumed == sizeof(wchar_t)*10);
  
  ret = stringParse.Import((const unsigned char *)inputBuffer, 1, inputConsumed,
                           (unsigned char *)outputBuffer, 6, outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == 2);
  ASSERT(outputConsumed == 0);
  
  ret = stringParse.Import((const unsigned char *)inputBuffer, sizeof(wchar_t)*10, inputConsumed,
                           (unsigned char *)outputBuffer, sizeof(wchar_t)*10, outputConsumed);
  ASSERT(ret == true);
  ASSERT(inputConsumed == sizeof(wchar_t)*10);
  ASSERT(outputConsumed == sizeof(wchar_t)*10);
  ASSERT(0 == memcmp(outputBuffer, nullTerminatedString, 10*sizeof(wchar_t)));
}

void TestPrefixedUCS2EnumImport()
{
  ParsePrefixedUCS2StringEnumeration enumParse(L"Global", L"CountryName");
  wchar_t nullTerminatedString [10] = L"Indonesia";
  wchar_t inputBuffer[10];
  *((short *)inputBuffer) = 9*sizeof(wchar_t);
  memcpy(inputBuffer+1, nullTerminatedString, sizeof(wchar_t)*9); 
  long outputBuffer;
  bool ret;
  int inputConsumed, outputConsumed;
  ret = enumParse.Import((const unsigned char *)inputBuffer, 6, inputConsumed,
                           (unsigned char *)&outputBuffer, sizeof(long), outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == sizeof(wchar_t)*10);
  ASSERT(outputConsumed == sizeof(long));

  ret = enumParse.Import((const unsigned char *)inputBuffer, sizeof(wchar_t)*10, inputConsumed,
                           (unsigned char *)&outputBuffer, 2, outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == 0);
  ASSERT(outputConsumed == sizeof(long));
  
  ret = enumParse.Import((const unsigned char *)inputBuffer, 1, inputConsumed,
                           (unsigned char *)&outputBuffer, sizeof(long), outputConsumed);
  ASSERT(ret == false);
  ASSERT(inputConsumed == 2);
  ASSERT(outputConsumed == sizeof(long));
  
  ret = enumParse.Import((const unsigned char *)inputBuffer, sizeof(wchar_t)*10, inputConsumed,
                           (unsigned char *)&outputBuffer, sizeof(long), outputConsumed);
  ASSERT(ret == true);
  ASSERT(inputConsumed == sizeof(wchar_t)*10);
  ASSERT(outputConsumed == sizeof(long));
  ASSERT(113 == outputBuffer);
}

class MessagePtrVector
{
private:
  std::vector<MessagePtr> mVector;
  RecordMetadata& mMetadata;
public:
  void push_back(MessagePtr m)
  {
    mVector.push_back(m);
  }
  MessagePtr back()
  {
    return mVector.back();
  }
  MessagePtr& operator[] (std::size_t i)
  {
    return mVector[i];
  }

  MessagePtrVector(RecordMetadata& m)
    :
    mMetadata(m)
  {
  }
  ~MessagePtrVector()
  {
    for(std::vector<MessagePtr>::iterator it = mVector.begin();
        it != mVector.end();
        ++it)
    {
      mMetadata.Free(*it);
    }  
  }
};

void TestMessagePtrQueue()
{
  MessagePtrQueue q;
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(0LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(0LL, q.GetNumRead());
  MessagePtr ptr;
  q.Pop(ptr);
  BOOST_REQUIRE(NULL == ptr);
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(0LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(0LL, q.GetNumRead());

  // Create a bunch of records for testing.
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  RecordMetadata recordA(logicalA);
  MessagePtrVector ptrs(recordA);
  for(boost::int32_t i=0; i<1000; i++)
  {
    ptrs.push_back(recordA.Allocate());
    recordA.GetColumn(L"a")->SetLongValue(ptrs.back(), i);
  }

  // Push and pop a single record.
  q.Push(ptrs[0]);
  BOOST_REQUIRE_EQUAL(1, q.GetSize());
  BOOST_REQUIRE_EQUAL(1LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(0LL, q.GetNumRead());
  q.Pop(ptr);
  BOOST_REQUIRE_EQUAL(ptr, ptrs[0]);
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(1LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1LL, q.GetNumRead());
  q.Pop(ptr);
  BOOST_REQUIRE(ptr==NULL);
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(1LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1LL, q.GetNumRead());

  // Push and pop all records; verify FIFO
  for(boost::int32_t i=0; i<1000; i++)
  {
    q.Push(ptrs[i]);
    BOOST_REQUIRE_EQUAL(i + 1, q.GetSize());
    BOOST_REQUIRE_EQUAL(1LL + i + 1, q.GetNumWritten());
    BOOST_REQUIRE_EQUAL(1LL, q.GetNumRead());
  }
  for(boost::int32_t i=0; i<1000; i++)
  {
    q.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
    BOOST_REQUIRE_EQUAL(999-i, q.GetSize());
    BOOST_REQUIRE_EQUAL(1001LL, q.GetNumWritten());
    BOOST_REQUIRE_EQUAL(2LL + i, q.GetNumRead());
  }
  q.Pop(ptr);
  BOOST_REQUIRE(ptr==NULL);
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(1001LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1001LL, q.GetNumRead());

  // Create a new queue and test queue copy.
  MessagePtrQueue q2;
  BOOST_REQUIRE_EQUAL(0, q2.GetSize());
  BOOST_REQUIRE_EQUAL(0LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(0LL, q2.GetNumRead());
  for(boost::int32_t i=0; i<500; i++)
  {
    q2.Push(ptrs[i]);
    BOOST_REQUIRE_EQUAL(i + 1, q2.GetSize());
    BOOST_REQUIRE_EQUAL(i + 1, q2.GetNumWritten());
    BOOST_REQUIRE_EQUAL(0LL, q2.GetNumRead());
  }
  // Push an empty queue and validate no change.
  q2.Push(q);
  BOOST_REQUIRE_EQUAL(500, q2.GetSize());
  BOOST_REQUIRE_EQUAL(500LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(0LL, q2.GetNumRead());
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(1001LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1001LL, q.GetNumRead());
  // Verify FIFO order is still good
  for(boost::int32_t i=0; i<500; i++)
  {
    q2.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
    BOOST_REQUIRE_EQUAL(499-i, q2.GetSize());
    BOOST_REQUIRE_EQUAL(500L, q2.GetNumWritten());
    BOOST_REQUIRE_EQUAL(1LL+i, q2.GetNumRead());
  }
  
  // Split data between the two queues and validate
  // copying one to the other.
  for(boost::int32_t i=0; i<500; i++)
  {
    q2.Push(ptrs[i]);
  }
  BOOST_REQUIRE_EQUAL(500, q2.GetSize());
  BOOST_REQUIRE_EQUAL(1000LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(500LL, q2.GetNumRead());
  for(boost::int32_t i=500; i<1000; i++)
  {
    q.Push(ptrs[i]);
  }
  BOOST_REQUIRE_EQUAL(500, q.GetSize());
  BOOST_REQUIRE_EQUAL(1501LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1001LL, q.GetNumRead());
  q2.Push(q);
  BOOST_REQUIRE_EQUAL(1000, q2.GetSize());
  BOOST_REQUIRE_EQUAL(1500LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(500LL, q2.GetNumRead());
  BOOST_REQUIRE_EQUAL(0, q.GetSize());
  BOOST_REQUIRE_EQUAL(1501LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1501LL, q.GetNumRead());
  // Verify FIFO order is still good
  for(boost::int32_t i=0; i<1000; i++)
  {
    q2.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
    BOOST_REQUIRE_EQUAL(999-i, q2.GetSize());
    BOOST_REQUIRE_EQUAL(1500L, q2.GetNumWritten());
    BOOST_REQUIRE_EQUAL(501LL+i, q2.GetNumRead());
  }

  // One last test.  Push a queue onto an empty queue.
  for(boost::int32_t i=0; i<500; i++)
  {
    q2.Push(ptrs[i]);
  }
  q.Push(q2);
  BOOST_REQUIRE_EQUAL(0, q2.GetSize());
  BOOST_REQUIRE_EQUAL(2000LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(2000LL, q2.GetNumRead());
  BOOST_REQUIRE_EQUAL(500, q.GetSize());
  BOOST_REQUIRE_EQUAL(2001LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(1501LL, q.GetNumRead());
  for(boost::int32_t i=0; i<500; i++)
  {
    q.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
  }

  // Test Push and Pop Some operation.
  // Split data between the two queues and validate
  // copying one to the other.
  for(boost::int32_t i=0; i<500; i++)
  {
    q2.Push(ptrs[i]);
  }
  BOOST_REQUIRE_EQUAL(500, q2.GetSize());
  BOOST_REQUIRE_EQUAL(2500LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(2000LL, q2.GetNumRead());
  for(boost::int32_t i=500; i<1000; i++)
  {
    q.Push(ptrs[i]);
  }
  BOOST_REQUIRE_EQUAL(500, q.GetSize());
  BOOST_REQUIRE_EQUAL(2501LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(2001LL, q.GetNumRead());
  q2.PushSome(q, 100);
  BOOST_REQUIRE_EQUAL(600, q2.GetSize());
  BOOST_REQUIRE_EQUAL(2600LL, q2.GetNumWritten());
  BOOST_REQUIRE_EQUAL(2000LL, q2.GetNumRead());
  BOOST_REQUIRE_EQUAL(400, q.GetSize());
  BOOST_REQUIRE_EQUAL(2501LL, q.GetNumWritten());
  BOOST_REQUIRE_EQUAL(2101LL, q.GetNumRead());
  // Verify FIFO order is still good
  for(boost::int32_t i=0; i<600; i++)
  {
    q2.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
    BOOST_REQUIRE_EQUAL(599-i, q2.GetSize());
    BOOST_REQUIRE_EQUAL(2600L, q2.GetNumWritten());
    BOOST_REQUIRE_EQUAL(2001LL+i, q2.GetNumRead());
  }
  for(boost::int32_t i=600; i<1000; i++)
  {
    q.Pop(ptr);
    BOOST_REQUIRE_EQUAL(ptr, ptrs[i]);
    BOOST_REQUIRE_EQUAL(999-i, q.GetSize());
    BOOST_REQUIRE_EQUAL(2501L, q.GetNumWritten());
    BOOST_REQUIRE_EQUAL(2102LL-600+i, q.GetNumRead());
  }

}

class ValueAddress
{
private:
  // Location of the null bit for this field. It is based on the order of the 
  // condition in the column metadata collection. 
  // Note that this is not the same
  // as that based on column position in the database because of
  // operator row columns.
  long mNullWord;
  unsigned int mNullFlag;
  // Byte offset relative to the start of the buffer to the const value.  For certain values (decimals & strings),
  // this is a pointer to where the value lives.  In the operator per rule case, this points to the operator.
  long mOffset;
  
public:
  ValueAddress()
    :
    mOffset(0),
    mNullWord(0),
    mNullFlag(0)
  {
  }

  ValueAddress(long position, long offset)
    :
    mOffset(offset)
  {
    mNullWord = position / (sizeof(unsigned long)*8);
    mNullFlag = 1UL << (position % (sizeof(unsigned long)*8));
  }

  void SetOffset(long value) 
  { 
    mOffset = value; 
  }
  void SetPosition(long value) 
  {
    mNullWord = value / (sizeof(unsigned long)*8);
    mNullFlag = 1UL << (value % (sizeof(unsigned long)*8));
  }

  void InternalSetLongValue(unsigned char * recordBuffer, const void * input)
  {
    ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
    *((long *)(recordBuffer + mOffset)) = *((const long *)input);
  }
  void InternalSetBoolValue(unsigned char * recordBuffer, const void * input)
  {
    ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
    *((bool *)(recordBuffer + mOffset)) = *((const bool *)input);
  }
  void InternalSetBigIntegerValue(unsigned char * recordBuffer, const void * input)
  {
    ((unsigned int *)recordBuffer)[mNullWord] &= ~mNullFlag;
    *((__int64 *)(recordBuffer + mOffset)) = *((const __int64 *)input);
  }
  virtual void SetValue(unsigned char * recordBuffer, const void * input) {}
};

typedef void (ValueAddress::*ValueSetter) (unsigned char *, const void *);



class LongValueAddress : public ValueAddress
{
public:
  LongValueAddress(long position, long offset)
    :
    ValueAddress(position, offset)
  {
  }
  void SetValue(unsigned char * recordBuffer, const void * input)
  {
    InternalSetLongValue(recordBuffer, input);
  }
};

class BoolValueAddress : public ValueAddress
{
public:
  BoolValueAddress(long position, long offset)
    :
    ValueAddress(position, offset)
  {
  }
  void SetValue(unsigned char * recordBuffer, const void * input)
  {
    InternalSetBoolValue(recordBuffer, input);
  }
};

class BigIntegerValueAddress : public ValueAddress
{
public:
  BigIntegerValueAddress(long position, long offset)
    :
    ValueAddress(position, offset)
  {
  }
  void SetValue(unsigned char * recordBuffer, const void * input)
  {
    InternalSetBigIntegerValue(recordBuffer, input);
  }
};

class ValueAddressSetter
{
public:
  enum Type { LONG, BOOL, BIGINT };
private:
  ValueAddress mValueAddress;
  ValueSetter mValueSetter;
  Type mType;
public:
  ValueAddressSetter(long position, long offset, Type type)
    :
    mValueAddress(position, offset),
    mValueSetter( type == LONG ? &ValueAddress::InternalSetLongValue : type == BOOL ? &ValueAddress::InternalSetBoolValue : &ValueAddress::InternalSetBigIntegerValue),
    mType(type)
  {
  }
  ValueAddressSetter()
    :
    mValueSetter(NULL)
  {
  }

  void SetOffset(long value) 
  { 
    mValueAddress.SetOffset(value);
  }
  void SetPosition(long value) 
  {
    mValueAddress.SetPosition(value);
  }
  void SetType(Type type)
  {
    mValueSetter = ( type == LONG ? &ValueAddress::InternalSetLongValue : type == BOOL ? &ValueAddress::InternalSetBoolValue : &ValueAddress::InternalSetBigIntegerValue);
    mType = type;
  }

  void SetValue(unsigned char * recordBuffer, const void * input)
  {
    (mValueAddress.*mValueSetter)(recordBuffer, input);
  }
  void SetValueInterpreter(unsigned char * recordBuffer, const void * input)
  {
    switch(mType)
    {
    case LONG:
      mValueAddress.InternalSetLongValue(recordBuffer, input);
      break;
    case BOOL:
      mValueAddress.InternalSetBoolValue(recordBuffer, input);
      break;
    case BIGINT:
      mValueAddress.InternalSetBigIntegerValue(recordBuffer, input);
      break;
    }
  }
};


// A test to understand the relative performance of a virtual function call
// versus a manually constructed vtable based on pointers to member functions.
void TestVirtualCall()
{
  std::vector<ValueAddress *> rec;
  for(int i=0; i<100; i++)
  {
    rec.push_back(new LongValueAddress(3*i, 40 + 16*i));
    rec.push_back(new BoolValueAddress(3*i + 1, 44 + 16*i));
    rec.push_back(new BigIntegerValueAddress(3*i + 2, 48 + 16*i));
  }
  std::vector<ValueAddressSetter *> rec2;
  for(int i=0; i<100; i++)
  {
    rec2.push_back(new ValueAddressSetter(3*i, 40 + 16*i, ValueAddressSetter::LONG));
    rec2.push_back(new ValueAddressSetter(3*i + 1, 44 + 16*i, ValueAddressSetter::BOOL));
    rec2.push_back(new ValueAddressSetter(3*i + 2, 48 + 16*i, ValueAddressSetter::BIGINT));
  }

  std::vector<ValueAddressSetter> rec3(300);
  for(int i=0; i<100; i++)
  {
    rec3[3*i].SetPosition(3*i);
    rec3[3*i].SetOffset(40 + 16*i);
    rec3[3*i].SetType(ValueAddressSetter::LONG);
    rec3[3*i+1].SetPosition(3*i + 1);
    rec3[3*i+1].SetOffset(44 + 16*i);
    rec3[3*i+1].SetType(ValueAddressSetter::BOOL);
    rec3[3*i+2].SetPosition(3*i + 2);
    rec3[3*i+2].SetOffset(48 + 16*i);
    rec3[3*i+2].SetType(ValueAddressSetter::BIGINT);
  }

  ValueAddressSetter * rec4 = new ValueAddressSetter[300];
  for(int i=0; i<100; i++)
  {
    rec4[3*i].SetPosition(3*i);
    rec4[3*i].SetOffset(40 + 16*i);
    rec4[3*i].SetType(ValueAddressSetter::LONG);
    rec4[3*i+1].SetPosition(3*i + 1);
    rec4[3*i+1].SetOffset(44 + 16*i);
    rec4[3*i+1].SetType(ValueAddressSetter::BOOL);
    rec4[3*i+2].SetPosition(3*i + 2);
    rec4[3*i+2].SetOffset(48 + 16*i);
    rec4[3*i+2].SetType(ValueAddressSetter::BIGINT);
  }
  

  long a = 2343;
  bool b = true;
  __int64 c = 19092342;
  unsigned char * buffer = new unsigned char [2048];
  for(int i=0; i<10000; i++)
  {
    for(int j=0; j<100; j++)
    {
      rec[3*j]->SetValue(buffer, &a);
      rec[3*j+1]->SetValue(buffer, &b);
      rec[3*j+2]->SetValue(buffer, &c);
    }
  }

  for(int i=0; i<10000; i++)
  {
    for(int j=0; j<100; j++)
    {
      rec[3*j]->InternalSetLongValue(buffer, &a);
      rec[3*j+1]->InternalSetBoolValue(buffer, &b);
      rec[3*j+2]->InternalSetBigIntegerValue(buffer, &c);
    }
  }

  for(int i=0; i<10000; i++)
  {
    for(int j=0; j<100; j++)
    {
      rec2[3*j]->SetValue(buffer, &a);
      rec2[3*j+1]->SetValue(buffer, &b);
      rec2[3*j+2]->SetValue(buffer, &c);
    }
  }

  for(int i=0; i<10000; i++)
  {
    for(std::vector<ValueAddressSetter>::iterator it = rec3.begin();
        it != rec3.end();
      )
    {
      (*it++).SetValue(buffer, &a);
      (*it++).SetValue(buffer, &b);
      (*it++).SetValue(buffer, &c);
    }
  }

  for(int i=0; i<10000; i++)
  {
    for(std::vector<ValueAddressSetter>::iterator it = rec3.begin();
        it != rec3.end();
      )
    {
      (*it++).SetValueInterpreter(buffer, &a);
      (*it++).SetValueInterpreter(buffer, &b);
      (*it++).SetValueInterpreter(buffer, &c);
    }
  }

  ValueAddressSetter * end = &rec4[300];
  for(int i=0; i<10000; i++)
  {
    for(ValueAddressSetter* it = rec4;
        it != end;
      )
    {
      (*it++).SetValue(buffer, &a);
      (*it++).SetValue(buffer, &b);
      (*it++).SetValue(buffer, &c);
    }
  }

  delete [] buffer;
  delete [] rec4;
}

void TestSequentialMemoryPerformance()
{
  Timer timer;
  // Test the impact of cache line misses on performance
  for(int bufferSize=4096; bufferSize <= 128*1024*1024; bufferSize <<= 1)
  {
    for(int stride = 4; stride <= 512; stride <<= 1)
    {
      unsigned char * unalignedBuf = new unsigned char [bufferSize + 255];
      memset(unalignedBuf, 0, bufferSize + 255);
      unsigned char * alignedBuf = reinterpret_cast<unsigned char *>(256*((reinterpret_cast<size_t>(unalignedBuf) + 255)/256));

      for(int j=0; j<bufferSize; j += stride)
      {
        *((unsigned char **)(alignedBuf + j)) = alignedBuf + (j + stride)%bufferSize;
      }

      // To disable speculative execution, get memory addresses from
      // the array
      unsigned char * addr = alignedBuf;
      int k=0;
      {
        ScopeTimer sc(&timer);
        for(k=0; k<10000000; k++)
        {
          addr = *((unsigned char **)addr);
        }
      }
      std::cout << stride << ", " << bufferSize << ", " << timer.GetMilliseconds() << ", " << (int) addr << std::endl;
      timer.Reset();
      delete [] unalignedBuf;
    }
  }
}

void TestCacheConsciousHashTableSingleEntry()
{
  GlobalConstantPoolFactory cpf;
  // Set up probe and table metadata.
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  
  LogicalRecord logicalB;
  logicalB.push_back(L"a", LogicalFieldType::Integer(false));
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordB(logicalB);
  
  std::vector<DataAccessor *> probe;
  probe.push_back(recordA.GetColumn(0));
  std::vector<DataAccessor *> table;
  table.push_back(recordB.GetColumn(1));
  
  CacheConsciousHashTable hashTable(table);
  CacheConsciousHashTableUniqueInsertIterator insertIt(hashTable);
  CacheConsciousHashTableIterator it(hashTable, probe);
  
  // Insert some records
  unsigned char * bufferA = new unsigned char[recordA.GetRecordLength()];
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 99);
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 9932);
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"99");
  unsigned char * bufferB = new unsigned char[recordB.GetRecordLength()];
  recordB.GetColumn(L"a")->SetLongValue(bufferB, 9932);
  recordB.GetColumn(L"b")->SetLongValue(bufferB, 99);
  recordB.GetColumn(L"c")->SetStringValue(bufferB, L"99");
  unsigned char * bufferC = new unsigned char[recordA.GetRecordLength()];
  recordA.GetColumn(L"a")->SetLongValue(bufferC, 9931);
  recordA.GetColumn(L"b")->SetLongValue(bufferC, 99);
  recordA.GetColumn(L"c")->SetStringValue(bufferC, L"99");
  unsigned char * bufferD = new unsigned char[recordA.GetRecordLength()];
  recordA.GetColumn(L"a")->SetLongValue(bufferD, 99);
  recordA.GetColumn(L"b")->SetLongValue(bufferD, 9933);
  recordA.GetColumn(L"c")->SetStringValue(bufferD, L"99");

  hashTable.Insert(bufferB, insertIt);
  hashTable.Find(bufferA, it);
  bool found = it.GetNext();
  ASSERT(found);
  found = it.GetNext();
  ASSERT(!found);
  hashTable.Find(bufferC, it);
  found = it.GetNext();
  ASSERT(!found);
  hashTable.Find(bufferD, it);
  found = it.GetNext();
  ASSERT(found);

  // Now try lookup with predicate
  std::wstring residual = 
    L"CREATE PROCEDURE residual @Probe_a INTEGER @Probe_b INTEGER @Table_a INTEGER @Table_b INTEGER\n"
    L"AS\n"
    L"RETURN @Probe_a = @Table_b AND @Probe_b <= @Table_a\n";
  CacheConsciousHashTablePredicateIterator pit(hashTable, probe, recordA, recordB, residual);

  hashTable.Find(bufferA, pit);
  found = pit.GetNext();
  ASSERT(found);
  found = pit.GetNext();
  ASSERT(!found);
  hashTable.Find(bufferC, pit);
  found = pit.GetNext();
  ASSERT(!found);
  hashTable.Find(bufferD, pit);
  found = pit.GetNext();
  ASSERT(!found);
  

  delete [] bufferA;
  delete [] bufferB;
  delete [] bufferC;
  delete [] bufferD;
}

void TestCacheConsciousHashTableWithCollision()
{
  GlobalConstantPoolFactory cpf;
  // Set up probe and table metadata.
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  
  LogicalRecord logicalB;
  logicalB.push_back(L"a", LogicalFieldType::Integer(false));
  logicalB.push_back(L"b", LogicalFieldType::Integer(false));
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordB(logicalB);
  
  std::vector<DataAccessor *> probe;
  probe.push_back(recordA.GetColumn(0));
  std::vector<DataAccessor *> table;
  table.push_back(recordB.GetColumn(1));
  
  CacheConsciousHashTable hashTable(table, 2);
  CacheConsciousHashTableIterator it(hashTable, probe);
  CacheConsciousHashTableUniqueInsertIterator insertIt(hashTable);

  std::wstring residual = 
    L"CREATE PROCEDURE residual @Probe_a INTEGER @Probe_b INTEGER @Table_a INTEGER @Table_b INTEGER\n"
    L"AS\n"
    L"RETURN @Probe_a = @Table_b AND @Probe_b <= @Table_a\n";
  CacheConsciousHashTablePredicateIterator pit(hashTable, probe, recordA, recordB, residual);

  std::vector<unsigned char *> toDelete;
  for(int i=0; i<1000; i++)
  {
    toDelete.push_back(new unsigned char[recordB.GetRecordLength()]);
    recordB.GetColumn(L"a")->SetLongValue(toDelete.back(), i*i);
    recordB.GetColumn(L"b")->SetLongValue(toDelete.back(), i);
    recordB.GetColumn(L"c")->SetStringValue(toDelete.back(), L"99");
    hashTable.Insert(toDelete.back(), insertIt);
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 9);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 8893);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, it);
    bool found = it.GetNext();
    ASSERT(found);
    found = it.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 900);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 8893);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, it);
    bool found = it.GetNext();
    ASSERT(found);
    found = it.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 9000);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 8893);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, it);
    bool found = it.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 9);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 8893);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, pit);
    bool found = pit.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 9);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 80);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, pit);
    bool found = pit.GetNext();
    ASSERT(found);
    found = it.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  {
    unsigned char * bufferA = new unsigned char [recordA.GetRecordLength()];
    recordA.GetColumn(L"a")->SetLongValue(bufferA, 9000);
    recordA.GetColumn(L"b")->SetLongValue(bufferA, 8893);
    recordA.GetColumn(L"c")->SetStringValue(bufferA, L"ppeer");
    hashTable.Find(bufferA, pit);
    bool found = pit.GetNext();
    ASSERT(!found);
    delete [] bufferA;
  }

  for (std::vector<unsigned char *>::iterator i=toDelete.begin();
       i != toDelete.end();
       i++)
  {
    delete [] *i;
  }
}

// void TestWideStringConstantPool()
// {
//   WideStringConstantPool2 localPool(2);
//   WideStringConstantPool2 * pool = &localPool;

//   // Generate a string
//   std::vector<std::wstring>  arrayOfStrings;
//   arrayOfStrings.push_back(L"jdjje293432dwedw");
//   // Lookup once to insert
//   if (0 != wcscmp(arrayOfStrings[0].c_str(), pool->GetWideStringConstant(arrayOfStrings[0].c_str())))
//     throw std::exception("TestWideStringConstantPoolPerformance failed");
//   // Lookup twice to retrieve
//   if (0 != wcscmp(arrayOfStrings[0].c_str(), pool->GetWideStringConstant(arrayOfStrings[0].c_str())))
//     throw std::exception("TestWideStringConstantPoolPerformance failed");

//   // Enough to trigger the different code paths
//   int dbsize = 1024;
//   // Generate a million "random" srings by hashing.
//   for(int i=0; i<dbsize; i++)
//   {
//     wchar_t buffer [1024];
//     unsigned int h1 = __hash((unsigned char *) &i, sizeof(int), 0);
//     unsigned int h2 = __hash((unsigned char *) &i, sizeof(int), h1);
    
//     wsprintf(buffer, L"%d%d", h1, h2);
//     arrayOfStrings.push_back(buffer);
//   }

//   // Now perform a "random" number of reads and writes.
//   // First, outside the timing loop, create the sequence of
//   // accesses
//   int lookupRatio = 4;
//   std::vector<int> access(lookupRatio*dbsize);
//   for (int i=0; i<lookupRatio*dbsize; i++)
//   {
//     access[i] = __hash((unsigned char *) &i, sizeof(int), 0) % dbsize;
//   }

//   // OK. Now perform the sequence of accesses
//   for(std::vector<int>::const_iterator it = access.begin();
//       it != access.end();
//       it++)
//   {
//     if (0 != wcscmp(arrayOfStrings[*it].c_str(), pool->GetWideStringConstant(arrayOfStrings[*it].c_str())))
//         throw std::exception("TestWideStringConstantPoolPerformance failed");
//   }
// }

// void TestWideStringConstantPoolPerformance()
// {
//   WideStringConstantPool2 * pool = WideStringConstantPool2::GetInstance();

//   // Generate a string
//   std::vector<std::pair<std::wstring, int> >  arrayOfStrings;
// //   arrayOfStrings.push_back(std::pair<std::wstring, int>(L"jdjje293432dwedw", wcslen(L"jdjje293432dwedw")));
// //   // Lookup once to insert
// //   if (0 != wcscmp(arrayOfStrings[0].first.c_str(), pool->GetWideStringConstant(arrayOfStrings[0].first.c_str())))
// //     throw std::exception("TestWideStringConstantPoolPerformance failed");
// //   // Lookup twice to retrieve
// //   if (0 != wcscmp(arrayOfStrings[0].first.c_str(), pool->GetWideStringConstant(arrayOfStrings[0].first.c_str())))
// //     throw std::exception("TestWideStringConstantPoolPerformance failed");

//   int dbsize = 1024*1024;
//   // Generate a million "random" srings by hashing.
//   for(int i=0; i<dbsize; i++)
//   {
//     wchar_t buffer [1024];
//     unsigned int h1 = __hash((unsigned char *) &i, sizeof(int), 0);
//     unsigned int h2 = __hash((unsigned char *) &i, sizeof(int), h1);
    
//     wsprintf(buffer, L"%d%d", h1, h2);
//     int strLen = wcslen(buffer);
//     arrayOfStrings.push_back(std::pair<std::wstring, int>(buffer, strLen));
//   }

//   // Now perform a "random" number of reads and writes.
//   // First, outside the timing loop, create the sequence of
//   // accesses
//   int lookupRatio = 10;
//   std::vector<int> access(lookupRatio*dbsize);
//   for (int i=0; i<lookupRatio*dbsize; i++)
//   {
//     access[i] = __hash((unsigned char *) &i, sizeof(int), 0) % dbsize;
//   }

//   Timer timer;
//   {
//     ScopeTimer scope(&timer);
//     // OK. Now perform the sequence of accesses
//     for(std::vector<int>::const_iterator it = access.begin();
//         it != access.end();
//         it++)
//     {
//       pool->GetWideStringConstant(arrayOfStrings[*it].first.c_str(), arrayOfStrings[*it].second);
//     }
//   }

//   std::cout << "WideStringConstantPoolPerformance: " << lookupRatio*dbsize << " accesses took " << timer.GetMilliseconds() << " ms" <<std::endl;

//   timer.Reset();
//   WideStringConstantPool2::ReleaseInstance();
//   pool = NULL;

//   WideStringConstantPool * otherPool = WideStringConstantPool::GetInstance();
//   {
//     ScopeTimer scope(&timer);
//     // OK. Now perform the sequence of accesses
//     for(std::vector<int>::const_iterator it = access.begin();
//         it != access.end();
//         it++)
//     {
//       otherPool->GetWideStringConstant(arrayOfStrings[*it].first.c_str(), arrayOfStrings[*it].second);
//     }
//   }

//   std::cout << "WideStringConstantPoolPerformance: " << lookupRatio*dbsize << " accesses took " << timer.GetMilliseconds() << " ms" <<std::endl;

//   WideStringConstantPool::ReleaseInstance();
// }

static int IntegerSortKeyCompare(boost::int32_t a, bool aIsNull, boost::int32_t b, bool bIsNull, SortOrder::SortOrderEnum so)
{
  SortKeyBuffer aBuffer;
  SortKeyBuffer bBuffer;
  SortKeyBuffer::ExportIntegerSortKeyFunction(&a, aIsNull, so, aBuffer, sizeof(boost::int32_t));
  SortKeyBuffer::ExportIntegerSortKeyFunction(&b, bIsNull, so, bBuffer, sizeof(boost::int32_t));
  return SortKeyBuffer::Compare(aBuffer, bBuffer);
}

static void TestIntegerSortKey(SortOrder::SortOrderEnum so, int neg)
{
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(234, false, 0, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(234, false, 233, false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(234, false, 235, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(234, false, -234, false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(-234, false, 234, false, so));
  BOOST_REQUIRE(0 == neg*IntegerSortKeyCompare(-234, false, -234, false, so));
  BOOST_REQUIRE(0 == neg*IntegerSortKeyCompare(234, false, 234, false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(-235, false, -234, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(-235, false, -236, false, so));
  // A specific test I have seen during sorting
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(65536, false, 1027, false, so));
  // Some tests in which the numbers differ only in higher bytes.
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x0000ffaa, false, 0x0000feaa, false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(0x8000feaa, false, 0x8000ffaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x0000ffaa, false, 0x0000feaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x00ffbcaa, false, 0x00febcaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x80ffbcaa, false, 0x80febcaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x00ffbcaa, false, 0x00febcaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0x7f93bcaa, false, 0x7e93bcaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(0xff93bcaa, false, 0xfe93bcaa, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::max(), false, std::numeric_limits<boost::int32_t>::min(), false, so));
  BOOST_REQUIRE(0 == neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::max(), false, std::numeric_limits<boost::int32_t>::max(), false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::min(), false, std::numeric_limits<boost::int32_t>::max(), false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::min(), false, 0, false, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::max(), false, 0, false, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(234, false, 0, true, so));
  BOOST_REQUIRE(0 < neg*IntegerSortKeyCompare(234, true, 0, false, so));
  BOOST_REQUIRE(0 == neg*IntegerSortKeyCompare(234, true, 0, true, so));
  BOOST_REQUIRE(0 > neg*IntegerSortKeyCompare(std::numeric_limits<boost::int32_t>::max(), false, 0, true, so));
}

void TestIntegerSortKey()
{
  TestIntegerSortKey(SortOrder::ASCENDING, 1);
  TestIntegerSortKey(SortOrder::DESCENDING, -1);
}

static int BigIntegerSortKeyCompare(boost::int64_t a, bool aIsNull, boost::int64_t b, bool bIsNull, SortOrder::SortOrderEnum so)
{
  SortKeyBuffer aBuffer;
  SortKeyBuffer bBuffer;
  SortKeyBuffer::ExportBigIntegerSortKeyFunction(&a, aIsNull, so, aBuffer, sizeof(boost::int64_t));
  SortKeyBuffer::ExportBigIntegerSortKeyFunction(&b, bIsNull, so, bBuffer, sizeof(boost::int64_t));
  return SortKeyBuffer::Compare(aBuffer, bBuffer);
}

static void TestBigIntegerSortKey(SortOrder::SortOrderEnum so, int neg)
{
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(234, false, 0, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(234, false, 233, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(234, false, 235, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(234, false, -234, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(-234, false, 234, false, so));
  BOOST_REQUIRE(0 == neg*BigIntegerSortKeyCompare(-234, false, -234, false, so));
  BOOST_REQUIRE(0 == neg*BigIntegerSortKeyCompare(234, false, 234, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(-235, false, -234, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(-235, false, -236, false, so));
  // Some tests in which the numbers differ only in higher bytes.
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x000000000000ffaa, false, 0x000000000000feaa, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(0x800000000000feaa, false, 0x800000000000ffaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x000000000000ffaa, false, 0x000000000000feaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x0000000000ffbcaa, false, 0x0000000000febcaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x8000000000ffbcaa, false, 0x8000000000febcaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x0000000000ffbcaa, false, 0x0000000000febcaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0x700000000f93bcaa, false, 0x700000000e93bcaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(0xf00000000f93bcaa, false, 0xf00000000e93bcaa, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(0x702234234f93bcaa, false, 0x703234234f93bcaa, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(0xf02234234f93bcaa, false, 0xf03234234f93bcaa, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::max(), false, std::numeric_limits<boost::int64_t>::min(), false, so));
  BOOST_REQUIRE(0 == neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::max(), false, std::numeric_limits<boost::int64_t>::max(), false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::min(), false, std::numeric_limits<boost::int64_t>::max(), false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::min(), false, 0, false, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::max(), false, 0, false, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(234, false, 0, true, so));
  BOOST_REQUIRE(0 < neg*BigIntegerSortKeyCompare(234, true, 0, false, so));
  BOOST_REQUIRE(0 == neg*BigIntegerSortKeyCompare(234, true, 0, true, so));
  BOOST_REQUIRE(0 > neg*BigIntegerSortKeyCompare(std::numeric_limits<boost::int64_t>::max(), false, 0, true, so));
}

void TestBigIntegerSortKey()
{
  TestBigIntegerSortKey(SortOrder::ASCENDING, 1);
  TestBigIntegerSortKey(SortOrder::DESCENDING, -1);
}

static int DatetimeSortKeyCompare(DATE a, bool aIsNull, DATE b, bool bIsNull, SortOrder::SortOrderEnum so)
{
  SortKeyBuffer aBuffer;
  SortKeyBuffer bBuffer;
  SortKeyBuffer::ExportDatetimeSortKeyFunction(&a, aIsNull, so, aBuffer, sizeof(DATE));
  SortKeyBuffer::ExportDatetimeSortKeyFunction(&b, bIsNull, so, bBuffer, sizeof(DATE));
  return SortKeyBuffer::Compare(aBuffer, bBuffer);
}

static void TestDatetimeSortKey(SortOrder::SortOrderEnum so, int neg)
{
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(234.0, false, 0.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(234.0, false, 233.0, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(234.0, false, 235.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(234.0, false, -234.0, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(-234.0, false, 234, false, so));
  BOOST_REQUIRE(0 == neg*DatetimeSortKeyCompare(-234.0, false, -234.0, false, so));
  BOOST_REQUIRE(0 == neg*DatetimeSortKeyCompare(234.0, false, 234.0, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(-235, false, -234.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(-235.0, false, -236.0, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(-235000.0, false, -234000.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(-235000.0, false, -2350000.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(235000.0, false, 234000.0, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(235000.0, false, 2350000.0, false, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(235000.0, false, 0.0000235, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(-235000.0, false, -0.0000235, false, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(234.0, false, 0.0, true, so));
  BOOST_REQUIRE(0 < neg*DatetimeSortKeyCompare(234.0, true, 0.0, false, so));
  BOOST_REQUIRE(0 == neg*DatetimeSortKeyCompare(234.0, true, 0.0, true, so));
  BOOST_REQUIRE(0 > neg*DatetimeSortKeyCompare(std::numeric_limits<DATE>::max(), false, 0, true, so));
}

void TestDatetimeSortKey()
{
  TestDatetimeSortKey(SortOrder::ASCENDING, 1);
  TestDatetimeSortKey(SortOrder::DESCENDING, -1);
}

void TestReadPriority()
{
  BOOST_REQUIRE_EQUAL(0, LinuxProcessor::GetReadPriority(0));
  BOOST_REQUIRE_EQUAL(1, LinuxProcessor::GetReadPriority(1));
  BOOST_REQUIRE_EQUAL(2, LinuxProcessor::GetReadPriority(2));
  BOOST_REQUIRE_EQUAL(2, LinuxProcessor::GetReadPriority(3));
  BOOST_REQUIRE_EQUAL(3, LinuxProcessor::GetReadPriority(4));
  BOOST_REQUIRE_EQUAL(3, LinuxProcessor::GetReadPriority(5));
  BOOST_REQUIRE_EQUAL(6, LinuxProcessor::GetReadPriority(32));
  BOOST_REQUIRE_EQUAL(6, LinuxProcessor::GetReadPriority(33));
  BOOST_REQUIRE_EQUAL(6, LinuxProcessor::GetReadPriority(63));
  BOOST_REQUIRE_EQUAL(7, LinuxProcessor::GetReadPriority(64));
  BOOST_REQUIRE_EQUAL(7, LinuxProcessor::GetReadPriority(64));
  BOOST_REQUIRE_EQUAL(31, LinuxProcessor::GetReadPriority(std::numeric_limits<boost::int32_t>::max()));
}

void TestWritePriority()
{
  BOOST_REQUIRE_EQUAL(31, LinuxProcessor::GetWritePriority(0));
  BOOST_REQUIRE_EQUAL(30, LinuxProcessor::GetWritePriority(1));
  BOOST_REQUIRE_EQUAL(29, LinuxProcessor::GetWritePriority(2));
  BOOST_REQUIRE_EQUAL(29, LinuxProcessor::GetWritePriority(3));
  BOOST_REQUIRE_EQUAL(28, LinuxProcessor::GetWritePriority(4));
  BOOST_REQUIRE_EQUAL(28, LinuxProcessor::GetWritePriority(5));
  BOOST_REQUIRE_EQUAL(25, LinuxProcessor::GetWritePriority(32));
  BOOST_REQUIRE_EQUAL(25, LinuxProcessor::GetWritePriority(33));
  BOOST_REQUIRE_EQUAL(25, LinuxProcessor::GetWritePriority(63));
  BOOST_REQUIRE_EQUAL(24, LinuxProcessor::GetWritePriority(64));
  BOOST_REQUIRE_EQUAL(24, LinuxProcessor::GetWritePriority(64));
  BOOST_REQUIRE_EQUAL(0, LinuxProcessor::GetWritePriority(std::numeric_limits<boost::int32_t>::max()));
}

void TestDesignTimePlan()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_account_mapper_copy");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
}

void TestRunTimePlan()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeDevNull * insert = new DesignTimeDevNull();
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestDatabaseTableCopy()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_account_mapper_copy");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestDatabaseTableCopy(std::size_t blocks)
{
  {
    GlobalConstantPoolFactory cpf;
    DesignTimePlan plan;
    LogicalRecord logicalA;
    std::wstring paramList(L"CREATE PROCEDURE tbl ");
    std::wstring body;
    for(std::size_t i=0; i<blocks; i++)
    {
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i)).str(), LogicalFieldType::Integer(false));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+1)).str(), LogicalFieldType::BigInteger(false));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+2)).str(), LogicalFieldType::Decimal(false));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+3)).str(), LogicalFieldType::Integer(false));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+4)).str(), LogicalFieldType::Integer(true));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+5)).str(), LogicalFieldType::Datetime(false));
      logicalA.push_back((boost::wformat(L"col%1%")%(7*i+6)).str(), LogicalFieldType::String(false));

      paramList +=
        (boost::wformat(L"@col%1% INTEGER @col%2% BIGINT @col%3% DECIMAL @col%4% INTEGER @col%5% INTEGER @col%6% DATETIME @col%7% NVARCHAR\n")
         % (7*i) % (7*i+1) % (7*i+2) % (7*i+3) % (7*i+4) % (7*i+5) % (7*i+6)  ).str();
      body +=
        (boost::wformat(L"SET @col%1% = CAST(@@RECORDCOUNT AS INTEGER)\n"
                        L"SET @col%2% = CAST(@@RECORDCOUNT AS BIGINT)\n"
                        L"SET @col%3% = 0.001*CAST(@@RECORDCOUNT AS DECIMAL)\n"
                        L"SET @col%4% = 3*CAST(@@RECORDCOUNT AS INTEGER)\n"
                        L"SET @col%5% = CASE WHEN @@RECORDCOUNT %% 10LL = 1LL THEN NULL ELSE CAST(@@RECORDCOUNT AS INTEGER) END\n"
                        L"SET @col%6% = getutcdate()\n"
                        L"SET @col%7% = CAST(@@RECORDCOUNT AS NVARCHAR)\n")
         % (7*i) % (7*i+1) % (7*i+2) % (7*i+3) % (7*i+4) % (7*i+5) % (7*i+6)  ).str();
    }
    RecordMetadata recordA(logicalA);
    DesignTimeGenerator * table = new DesignTimeGenerator();
    table->SetName(L"TestDatabaseTableCopy_table");
    paramList += L"AS\n";
    table->SetProgram(paramList + body);
    table->SetNumRecords(1000LL);
    plan.push_back(table);
    DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
    insert->SetTableName((boost::wformat(L"test_copy_blocks_%1%") % blocks).str());
    insert->SetCreateTable(true);
    plan.push_back(insert);
    plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], insert->GetInputPorts()[0]));
    plan.type_check();
    ParallelPlan pplan(1);
    plan.code_generate(pplan);
    BOOST_REQUIRE(1 == pplan.GetNumDomains());
    pplan.GetDomain(0)->Start();
  }
  {
    DesignTimePlan plan;
    DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
    select->SetBaseQuery((boost::wformat(L"SELECT * FROM test_copy_blocks_%1%") % blocks).str());
    select->SetSchema(L"NetMeterStage");
    plan.push_back(select);
    DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
    insert->SetTableName((boost::wformat(L"test_copy_blocks_copy_%1%") % blocks).str());
    insert->SetCreateTable(true);
    plan.push_back(insert);
    plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], insert->GetInputPorts()[0]));
    plan.type_check();
    ParallelPlan pplan(1);
    plan.code_generate(pplan);
    BOOST_REQUIRE(1 == pplan.GetNumDomains());
    pplan.GetDomain(0)->Start();
  }
}

void TestDatabaseTableStreamingInsert(boost::int64_t numRecords, int commitSize)
{
  // Create the target table first.
  LogicalRecord logicalA;
  logicalA.push_back(L"data", LogicalFieldType::Integer(false));
  DatabaseCommands cmds;
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  stmt->ExecuteUpdateW(cmds.CreateTable(logicalA, L"NetMeterStage", L"test_streaming_copy"));

  // Execute streaming into the table.
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestDatabaseTableStreamingCopy_table");
  table->SetProgram(
    (boost::wformat(
      L"CREATE PROCEDURE tbl @id_commit_unit INTEGER @data INTEGER\n"
      L"AS\n"
      L"SET @id_commit_unit = CAST(@@RECORDCOUNT AS INTEGER)/%1%\n"
      L"SET @data = CAST(@@RECORDCOUNT AS INTEGER)\n")
     % commitSize).str()
    );
  table->SetNumRecords(numRecords);
  plan.push_back(table);

  DesignTimeCopy * copy = new DesignTimeCopy(2);
  copy->SetName(L"copy");
  plan.push_back(copy);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], copy->GetInputPorts()[0]));
  

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetName(L"insert");
  insert->SetTableName(L"test_streaming_copy");
  insert->SetStreamingTransactionKey(L"id_commit_unit");
  std::map<std::wstring, std::wstring> sourceTargetMap;
  sourceTargetMap[L"data"] = L"data";
  insert->SetSourceTargetMap(sourceTargetMap);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], insert->GetInputPorts()[0]));

  DesignTimeSortGroupBy * groupBy = new DesignTimeSortGroupBy();
  groupBy->SetName(L"groupBy");
  groupBy->AddGroupByKey(DesignTimeSortKey(L"id_commit_unit", SortOrder::ASCENDING));
  groupBy->SetInitializeProgram(
    L"CREATE PROCEDURE initializer @Table_size_0 INTEGER\n"
    L"AS\n"
    L"SET @Table_size_0 = 0\n"
    );
  groupBy->SetUpdateProgram(
    L"CREATE PROCEDURE updater @Table_size_0 INTEGER\n"
    L"AS\n"
    L"SET @Table_size_0 = @Table_size_0 + 1\n"
    );
  plan.push_back(groupBy);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], groupBy->GetInputPorts()[0]));

  DesignTimeTransactionalInstall * install = new DesignTimeTransactionalInstall(1);
  install->SetName(L"install");
  install->SetPreTransactionQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>()));
  std::wstring insertQuery((boost::wformat(L"INSERT INTO %1%test_streaming_copy (data) SELECT data FROM %1%%2%") 
                            % cmds.GetSchemaPrefix(L"NetMeterStage") % L"%1%").str());
  install->SetQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>(1,insertQuery)));
  std::wstring dropQuery(cmds.DropTable(L"NetMeterStage", L"%1%"));
  install->SetPostTransactionQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>(1,dropQuery)));
  plan.push_back(install);
  // Turn off buffering on the channels going into the installer.
  plan.push_back(new DesignTimeChannel(groupBy->GetOutputPorts()[0], install->GetInputPorts()[L"control"], false));
  plan.push_back(new DesignTimeChannel(insert->GetOutputPorts()[0], install->GetInputPorts()[L"input(0)"], false));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();

  // Check results.
  stmt = boost::shared_ptr<COdbcStatement>(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQueryW(
                                         (boost::wformat(L"SELECT COUNT(*), MIN(data), MAX(data) FROM %1%test_streaming_copy") 
                                          % cmds.GetSchemaPrefix(L"NetMeterStage")).str()));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  BOOST_REQUIRE_EQUAL(boost::int32_t(numRecords), rs->GetInteger(1));
  BOOST_REQUIRE_EQUAL(0, rs->GetInteger(2));
  BOOST_REQUIRE_EQUAL(boost::int32_t(numRecords)-1, rs->GetInteger(3));
  BOOST_REQUIRE_EQUAL(false, rs->Next());
  rs = boost::shared_ptr<COdbcResultSet>();
  
  // Clean up
  stmt = boost::shared_ptr<COdbcStatement>(conn->CreateStatement());
  stmt->ExecuteUpdateW(cmds.DropTable(L"NetMeterStage", L"test_streaming_copy"));  
}


// void TestDatabaseTableStreamingInsertCompound()
// {
//   // Create the target table first.
//   GlobalConstantPoolFactory cpf;
//   DatabaseCommands cmds;
//   boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
//   boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
//   LogicalRecord logicalA;
//   logicalA.push_back(L"data_0", LogicalFieldType::Integer(false), 0, 0);
//   RecordMetadata recordA(logicalA);
//   stmt->ExecuteUpdateW(cmds.CreateTable(recordA, L"NetMeterStage", L"test_streaming_copy_0"));
//   LogicalRecord logicalB;
//   logicalB.push_back(L"data_0", LogicalFieldType::Integer(false), 0, 0);
//   logicalB.push_back(L"data_1", LogicalFieldType::Integer(false), 1, 1);
//   RecordMetadata recordB(logicalB);
//   stmt->ExecuteUpdateW(cmds.CreateTable(recordB, L"NetMeterStage", L"test_streaming_copy_1"));
//   LogicalRecord logicalC;
//   logicalC.push_back(L"data_0", LogicalFieldType::Integer(false), 0, 0);
//   logicalC.push_back(L"data_2", LogicalFieldType::Integer(false), 1, 1);
//   RecordMetadata recordC(logicalC);
//   stmt->ExecuteUpdateW(cmds.CreateTable(recordC, L"NetMeterStage", L"test_streaming_copy_2"));

//   // Execute streaming into the table.
//   DesignTimePlan plan;
//   DesignTimeGenerator * table = new DesignTimeGenerator();
//   table->SetName(L"TestDatabaseTableStreamingCopy_table");
//   table->SetProgram(
//     L"CREATE PROCEDURE driver @id_sess BIGINT @id_parent_sess BIGINT @numChildren1 INTEGER @numChildren2 INTEGER\n"
//     L"AS\n"
//     L"SET @id_sess = @@RECORDCOUNT\n"
//     L"SET @id_parent_sess = @@RECORDCOUNT\n"
//     L"SET @numChildren1 = CASE @@RECORDCOUNT % 3LL WHEN 0LL THEN 2 WHEN 1LL THEN 3 WHEN 2LL THEN 0 END\n"
//     L"SET @numChildren2 = CASE @@RECORDCOUNT % 4LL WHEN 0LL THEN 2 WHEN 1LL THEN 0 WHEN 2LL THEN 3 WHEN 3LL THEN 5 END");
//     L"CREATE PROCEDURE tbl @id_commit_unit INTEGER @data INTEGER\n"
//     L"AS\n"
//     L"SET @id_commit_unit = CAST(@@RECORDCOUNT AS INTEGER)/4\n"
//     L"SET @data = CAST(@@RECORDCOUNT AS INTEGER)\n"
//     );
//   table->SetNumRecords(10LL);
//   plan.push_back(table);

//   DesignTimeCopy * copy = new DesignTimeCopy(2);
//   plan.push_back(copy);
//   plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], copy->GetInputPorts()[0]));
  

//   DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
//   insert->SetTableName(L"test_streaming_copy");
//   insert->SetStreamingTransactionKey(L"id_commit_unit");
//   std::map<std::wstring, std::wstring> sourceTargetMap;
//   sourceTargetMap[L"data"] = L"data";
//   insert->SetSourceTargetMap(sourceTargetMap);
//   plan.push_back(insert);
//   plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], insert->GetInputPorts()[0]));

//   DesignTimeSortGroupBy * groupBy = new DesignTimeSortGroupBy();
//   groupBy->AddGroupByKey(DesignTimeSortKey(L"id_commit_unit", SortOrder::ASCENDING));
//   groupBy->SetInitializeProgram(
//     L"CREATE PROCEDURE initializer @Table_size_0 INTEGER\n"
//     L"AS\n"
//     L"SET @Table_size_0 = 0\n"
//     );
//   groupBy->SetUpdateProgram(
//     L"CREATE PROCEDURE updater @Table_size_0 INTEGER\n"
//     L"AS\n"
//     L"SET @Table_size_0 = @Table_size_0 + 1\n"
//     );
//   plan.push_back(groupBy);
//   plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], groupBy->GetInputPorts()[0]));

//   DesignTimeTransactionalInstall * install = new DesignTimeTransactionalInstall(1);
//   install->SetPreTransactionQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>()));
//   std::wstring insertQuery((boost::wformat(L"INSERT INTO %1%test_streaming_copy (data) SELECT data FROM %1%%2%") 
//                             % cmds.GetSchemaPrefix(L"NetMeterStage") % L"%1%").str());
//   install->SetQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>(1,insertQuery)));
//   std::wstring dropQuery(cmds.DropTable(L"NetMeterStage", L"%1%"));
//   install->SetPostTransactionQueries(std::vector<std::vector<std::wstring> >(1, std::vector<std::wstring>(1,dropQuery)));
//   plan.push_back(install);
//   plan.push_back(new DesignTimeChannel(groupBy->GetOutputPorts()[0], install->GetInputPorts()[L"control"]));
//   plan.push_back(new DesignTimeChannel(insert->GetOutputPorts()[0], install->GetInputPorts()[L"input(0)"]));

//   plan.type_check();
//   ParallelPlan pplan(1);
//   plan.code_generate(pplan);
//   BOOST_REQUIRE(1 == pplan.GetNumDomains());
//   pplan.GetDomain(0)->Start();

//   // Check results.
//   stmt = boost::shared_ptr<COdbcStatement>(conn->CreateStatement());
//   boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQueryW(
//                                          (boost::wformat(L"SELECT COUNT(*), MIN(data), MAX(data) FROM %1%test_streaming_copy") 
//                                           % cmds.GetSchemaPrefix(L"NetMeterStage")).str()));
//   BOOST_REQUIRE_EQUAL(true, rs->Next());
//   BOOST_REQUIRE_EQUAL(10, rs->GetInteger(1));
//   BOOST_REQUIRE_EQUAL(0, rs->GetInteger(2));
//   BOOST_REQUIRE_EQUAL(9, rs->GetInteger(3));
//   BOOST_REQUIRE_EQUAL(false, rs->Next());
//   rs = boost::shared_ptr<COdbcResultSet>();
  
//   // Clean up
//   stmt = boost::shared_ptr<COdbcStatement>(conn->CreateStatement());
//   stmt->ExecuteUpdateW(cmds.DropTable(L"NetMeterStage", L"test_streaming_copy"));  
// }


void TestHashJoin()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(probe);

  DesignTimeDatabaseSelect * table = new DesignTimeDatabaseSelect();
  table->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(table);

  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  std::vector<std::wstring> idAccJoinKeys;
  idAccJoinKeys.push_back(L"id_acc");
  join->SetTableEquiJoinKeys(idAccJoinKeys);
  DesignTimeHashJoinProbeSpecification probeSpec;
  std::vector<std::wstring> idAvAccJoinKeys;
  idAvAccJoinKeys.push_back(L"av_id_acc");
  probeSpec.SetEquiJoinKeys(idAvAccJoinKeys);
  probeSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  join->AddProbeSpecification(probeSpec);
  plan.push_back(join);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_join_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);

  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], join->GetInputPorts()[L"probe(0)"]));
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[L"output(0)"], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestLargeHashJoin()
{
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestLargeHashJoin_table");
  table->SetProgram(
    L"CREATE PROCEDURE tbl @tableKey INTEGER\n"
    L"AS\n"
    L"SET @tableKey = CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT\n"
    );
  table->SetNumRecords(1000000LL);
  plan.push_back(table);
  DesignTimeGenerator * probe = new DesignTimeGenerator();
  probe->SetName(L"TestLargeHashJoin_probe");
  probe->SetProgram(
    L"CREATE PROCEDURE probe @probeKey INTEGER\n"
    L"AS\n"
    L"SET @probeKey = CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT\n"
    );
  probe->SetNumRecords(1000000LL);
  plan.push_back(probe);

  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  join->SetName(L"TestLargeHashJoin_innerJoin");
  std::vector<std::wstring> tableKeys;
  tableKeys.push_back(L"tableKey");
  join->SetTableEquiJoinKeys(tableKeys);
  DesignTimeHashJoinProbeSpecification probeSpec;
  std::vector<std::wstring> probeKeys;
  probeKeys.push_back(L"probeKey");
  probeSpec.SetEquiJoinKeys(probeKeys);
  probeSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  join->AddProbeSpecification(probeSpec);
  plan.push_back(join);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], join->GetInputPorts()[L"probe(0)"]));

//   DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
//   insert->SetTableName(L"t_generator_test");
//   insert->SetCreateTable(true);
//   plan.push_back(insert);
//   plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestLargeHashJoin_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestRightOuterHashJoin()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * table = new DesignTimeDatabaseSelect();
  table->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(table);

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(probe);

  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  std::vector<std::wstring> idAvAccJoinKeys;
  idAvAccJoinKeys.push_back(L"av_id_acc");
  join->SetTableEquiJoinKeys(idAvAccJoinKeys);
  DesignTimeHashJoinProbeSpecification probeSpec;
  std::vector<std::wstring> idAccJoinKeys;
  idAccJoinKeys.push_back(L"id_acc");
  probeSpec.SetEquiJoinKeys(idAccJoinKeys);
  probeSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER_SPLIT);
  join->AddProbeSpecification(probeSpec);
  plan.push_back(join);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_match_right_hash_join_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);

  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_miss_right_hash_join_test");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);

  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], join->GetInputPorts()[L"probe(0)"]));
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[L"output(0)"], insert->GetInputPorts()[L"input"]));
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[L"right(0)"], insert2->GetInputPorts()[L"input"]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestHashPartitioner()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  probe->SetMode(DesignTimeOperator::SEQUENTIAL);
  plan.push_back(probe);

  DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
  std::vector<std::wstring> hashKeys;
  hashKeys.push_back(L"av_id_acc");
  part->SetMode(DesignTimeOperator::SEQUENTIAL);
  plan.push_back(part);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_partition_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], part->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestNondeterministicCollector()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(probe);

  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  coll->SetMode(DesignTimeOperator::SEQUENTIAL);
  plan.push_back(coll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_nondeterministic_coll_test");
  insert->SetCreateTable(true);
  insert->SetMode(DesignTimeOperator::SEQUENTIAL);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], coll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestHashRepartition()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(probe);

  DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
  std::vector<std::wstring> hashKeys;
  hashKeys.push_back(L"av_id_acc");
  part->SetHashKeys(hashKeys);
  plan.push_back(part);

  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  plan.push_back(coll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_repartition_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], part->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], coll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestUnionAll()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * left = new DesignTimeDatabaseSelect();
  left->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(left);
  DesignTimeDatabaseSelect * right = new DesignTimeDatabaseSelect();
  right->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(right);
  DesignTimeDatabaseSelect * three = new DesignTimeDatabaseSelect();
  three->SetBaseQuery(L"SELECT id_acc as av_id_acc, c_TaxExemptID, c_SecurityAnswer, c_InvoiceMethod, c_Currency FROM t_av_internal");
  plan.push_back(three);

  DesignTimeUnionAll * unionAll = new DesignTimeUnionAll();
  plan.push_back(unionAll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_union_all_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(left->GetOutputPorts()[0], unionAll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(right->GetOutputPorts()[0], unionAll->GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(three->GetOutputPorts()[0], unionAll->GetInputPorts()[2]));
  plan.push_back(new DesignTimeChannel(unionAll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestAccUsageRead()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * probe = new DesignTimeDatabaseSelect();
  probe->SetBaseQuery(L"SELECT au.* "
                      L"FROM t_acc_usage au ");
  plan.push_back(probe);

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(probe->GetOutputPorts()[0], devNull->GetInputPorts()[0]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestHashRunningAggregate()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_acc_usage");
  plan.push_back(source);

  DesignTimeHashRunningAggregate * agg = new DesignTimeHashRunningAggregate();
  std::vector<std::wstring> groupByKeys;
  groupByKeys.push_back(L"id_acc");
  groupByKeys.push_back(L"id_pi_instance");
  agg->SetGroupByKeys(groupByKeys);
  std::vector<NameMapping> sumNames;
  sumNames.push_back(NameMapping(L"amount", L"TotalAmount"));
  agg->SetSums(sumNames);
  agg->SetCountName(L"TotalRecords");
  plan.push_back(agg);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_running_aggregate_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], agg->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(agg->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestHashRunningAggregateMultiInput()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_acc_usage");
  plan.push_back(source);

  DesignTimeCopy * copy = new DesignTimeCopy(2);
  plan.push_back(copy);

  DesignTimeHashRunningAggregate * agg = new DesignTimeHashRunningAggregate(2);
  std::vector<std::wstring> groupByKeys;
  groupByKeys.push_back(L"id_acc");
  groupByKeys.push_back(L"id_pi_instance");

  std::vector<DesignTimeHashRunningAggregateInputSpec> inputSpecs;
  inputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec(groupByKeys, L""));
  inputSpecs.push_back(DesignTimeHashRunningAggregateInputSpec(groupByKeys, 
                                                               L"CREATE PROCEDURE updater @Table_TotalAmount DECIMAL @Probe_amount DECIMAL\n"
                                                               L"AS\n"
                                                               L"SET @Table_TotalAmount = @Table_TotalAmount + @Probe_amount"));  
  agg->SetInputSpecs(inputSpecs);
  agg->SetInitializeProgram(
    L"CREATE PROCEDURE initializer @Table_TotalAmount DECIMAL\n"
    L"AS\n"
    L"SET @Table_TotalAmount = 0.0");
  plan.push_back(agg);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_running_aggregate_multi_input_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], copy->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], agg->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], agg->GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(agg->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestHashGroupBy()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_account_mapper");
  plan.push_back(source);

  DesignTimeHashGroupBy * agg = new DesignTimeHashGroupBy();
  std::vector<std::wstring> groupByKeys;
  groupByKeys.push_back(L"nm_login");
  groupByKeys.push_back(L"nm_space");
  agg->SetGroupByKeys(groupByKeys);
  agg->SetInitializeProgram(
    L"CREATE PROCEDURE initializer @Table_sumIdAcc INTEGER @Table_countRecords INTEGER\n"
    L"AS\n"
    L"SET @Table_sumIdAcc = 0\n"
    L"SET @Table_countRecords = 0\n"
    );
  agg->SetUpdateProgram(
    L"CREATE PROCEDURE updater @Probe_id_acc INTEGER @Table_sumIdAcc INTEGER @Table_countRecords INTEGER\n"
    L"AS\n"
    L"SET @Table_sumIdAcc = @Table_sumIdAcc + @Probe_id_acc\n"
    L"SET @Table_countRecords = @Table_countRecords + 1\n"
    );
  plan.push_back(agg);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_hash_group_by_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], agg->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(agg->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestSortGroupBy()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_account_mapper ORDER BY id_acc");
  plan.push_back(source);

  DesignTimeSortGroupBy * agg = new DesignTimeSortGroupBy();
  std::vector<std::wstring> groupByKeys;
  groupByKeys.push_back(L"id_acc");
  agg->SetGroupByKeys(groupByKeys);
  agg->SetInitializeProgram(
    L"CREATE PROCEDURE initializer @Table_sumLenNmLogin INTEGER @Table_countRecords INTEGER\n"
    L"AS\n"
    L"SET @Table_sumLenNmLogin = 0\n"
    L"SET @Table_countRecords = 0\n"
    );
  agg->SetUpdateProgram(
    L"CREATE PROCEDURE updater @Probe_nm_login NVARCHAR @Table_sumLenNmLogin INTEGER @Table_countRecords INTEGER\n"
    L"AS\n"
    L"SET @Table_sumLenNmLogin = @Table_sumLenNmLogin + len(@Probe_nm_login)\n"
    L"SET @Table_countRecords = @Table_countRecords + 1\n"
    );
  plan.push_back(agg);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_sort_group_by_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], agg->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(agg->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestBroadcastPartition()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_account_mapper");
  plan.push_back(source);

  DesignTimeBroadcastPartitioner * part = new DesignTimeBroadcastPartitioner();
  plan.push_back(part);
  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  plan.push_back(coll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_broadcast_partition_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], part->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], coll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestRoundRobinPartition()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * source = new DesignTimeDatabaseSelect();
  source->SetBaseQuery(L"SELECT * FROM t_account_mapper");
  plan.push_back(source);

  DesignTimeRoundRobinPartitioner * part = new DesignTimeRoundRobinPartitioner();
  plan.push_back(part);
  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  plan.push_back(coll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_round_robin_partition_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(source->GetOutputPorts()[0], part->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], coll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestExpression()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeExpression * expr1 = new DesignTimeExpression();
  expr1->SetProgram(L"CREATE PROCEDURE expr1 @nm_login NVARCHAR @nm_space NVARCHAR @concat NVARCHAR OUTPUT "
                   L"AS SET @concat = @nm_space + N'/' + @nm_login");
  plan.push_back(expr1);
  DesignTimeExpression * expr2 = new DesignTimeExpression();
  expr2->SetProgram(L"CREATE PROCEDURE expr2 @nm_login NVARCHAR @nm_space NVARCHAR @id_acc INTEGER @concatall NVARCHAR OUTPUT "
                   L"AS SET @concatall = CAST(@id_acc AS NVARCHAR) + N'/' + @nm_space + N'/' + @nm_login");
  plan.push_back(expr2);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_expression_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], expr1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[0], expr2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr2->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestExpressionGenerator()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeExpressionGenerator * expr1 = new DesignTimeExpressionGenerator();
  expr1->SetProgram(
    L"CREATE PROCEDURE expr1 @nm_login NVARCHAR @nm_space NVARCHAR @concat NVARCHAR OUTPUT @recordNumber BIGINT OUTPUT\n"
    L"AS SET @concat = @nm_space + N'/' + @nm_login\n"
    L"SET @recordNumber = @@RECORDCOUNT*CAST(@@PARTITIONCOUNT AS BIGINT) + CAST(@@PARTITION AS BIGINT)\n");
  plan.push_back(expr1);
  DesignTimeExpression * expr2 = new DesignTimeExpression();
  expr2->SetProgram(L"CREATE PROCEDURE expr2 @nm_login NVARCHAR @nm_space NVARCHAR @id_acc INTEGER @concatall NVARCHAR OUTPUT "
                   L"AS SET @concatall = CAST(@id_acc AS NVARCHAR) + N'/' + @nm_space + N'/' + @nm_login");
  plan.push_back(expr2);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_expression_generator_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], expr1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[0], expr2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr2->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestGenerator()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @decVal DECIMAL @nvarcharVal NVARCHAR @varcharVal VARCHAR @intVal INTEGER\n"
    L"AS\n"
    L"SET @bigintVal = 9993234LL + @@RECORDCOUNT*CAST(2*(@@PARTITION+1) AS BIGINT) + CAST(@@PARTITIONCOUNT AS BIGINT)\n"
    L"SET @decVal = 993.33\n"
    L"SET @nvarcharVal = N'jjeffere'\n"
    L"SET @varcharVal = 'nnnennnen_' + CAST(@@RECORDCOUNT AS VARCHAR)\n"
    L"SET @intVal = 993882 + CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT\n"
    );
  gen->SetNumRecords(1000LL);
  plan.push_back(gen);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_generator_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestUnroll()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @decVal DECIMAL @nvarcharVal NVARCHAR @varcharVal VARCHAR @intVal INTEGER @doubleVal DOUBLE PRECISION\n"
    L"AS\n"
    L"SET @bigintVal = 9993234LL + @@RECORDCOUNT*CAST(2*(@@PARTITION+1) AS BIGINT) + CAST(@@PARTITIONCOUNT AS BIGINT)\n"
    L"SET @decVal = 993.33\n"
    L"SET @nvarcharVal = N'jjeffere'\n"
    L"SET @varcharVal = 'nnnennnen_' + CAST(@@RECORDCOUNT AS VARCHAR)\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @doubleVal = rand()\n"
    );
  gen->SetNumRecords(10LL);
  plan.push_back(gen);
  DesignTimeUnroll * unroll = new DesignTimeUnroll();
  unroll->SetCount(L"intVal");
  plan.push_back(unroll);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], unroll->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_unroll_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(unroll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestFilter()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeFilter * expr1 = new DesignTimeFilter();
  expr1->SetProgram(L"CREATE PROCEDURE expr1 @id_acc INTEGER @nm_space NVARCHAR "
                   L"AS RETURN @id_acc % 2 = 1 AND N'mt' = @nm_space");
  plan.push_back(expr1);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_filter_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], expr1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}


void TestSwitch()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeSwitch * expr1 = new DesignTimeSwitch(3);
  expr1->SetProgram(L"CREATE FUNCTION expr1 (@id_acc INTEGER) RETURNS INTEGER "
                   L"AS RETURN CASE WHEN @id_acc >= 0 THEN @id_acc ELSE -@id_acc END % 3");
  plan.push_back(expr1);
  DesignTimeDatabaseInsert * insert1 = new DesignTimeDatabaseInsert();
  insert1->SetTableName(L"t_switch_test_1");
  insert1->SetCreateTable(true);
  plan.push_back(insert1);
  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_switch_test_2");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);
  DesignTimeDatabaseInsert * insert3 = new DesignTimeDatabaseInsert();
  insert3->SetTableName(L"t_switch_test_3");
  insert3->SetCreateTable(true);
  plan.push_back(insert3);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], expr1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[L"output(0)"], insert1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[L"output(1)"], insert2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(expr1->GetOutputPorts()[L"output(2)"], insert3->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestProjection()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeProjection * proj = new DesignTimeProjection();
  std::vector<std::wstring> cols;
  cols.push_back(L"nm_login");
  cols.push_back(L"nm_space");
  proj->SetProjection(cols);
  plan.push_back(proj);
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_projection_test");
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], proj->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(proj->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

// select id_commit_unit, id_message, count(*) from
// NetMeterStage.dbo.t_single_input_session_set_builder
// group by id_commit_unit, id_message
// select * from
// NetMeterStage.dbo.t_single_input_session_set_builder_session_set_summary
// select * from
// NetMeterStage.dbo.t_single_input_session_set_builder_message_summary
// select * from
// NetMeterStage.dbo.t_single_input_session_set_builder_transaction_summary
void TestSingleInputSessionSetBuilder()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"SELECT id_acc as id_sess, nm_login, nm_space FROM t_account_mapper");
  plan.push_back(select);
  DesignTimeSessionSetBuilder * ss = new DesignTimeSessionSetBuilder(0, 7, 14);
  plan.push_back(ss);
  DesignTimeDatabaseInsert * insert1 = new DesignTimeDatabaseInsert();
  insert1->SetTableName(L"t_single_input_session_set_builder");
  insert1->SetCreateTable(true);
  plan.push_back(insert1);
  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_single_input_session_set_builder_session_set_summary");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);
  DesignTimeDatabaseInsert * insert3 = new DesignTimeDatabaseInsert();
  insert3->SetTableName(L"t_single_input_session_set_builder_message_summary");
  insert3->SetCreateTable(true);
  plan.push_back(insert3);
  DesignTimeDatabaseInsert * insert4 = new DesignTimeDatabaseInsert();
  insert4->SetTableName(L"t_single_input_session_set_builder_transaction_summary");
  insert4->SetCreateTable(true);
  plan.push_back(insert4);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], ss->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[0], insert1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[1], insert2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2], insert3->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[3], insert4->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

// select id_commit_unit, id_message, count(*) from
// NetMeterStage.dbo.t_multi_input_session_set_builder_0
// group by id_commit_unit, id_message
// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_summary_0

// select id_commit_unit, id_message, count(*) from
// NetMeterStage.dbo.t_multi_input_session_set_builder_1
// group by id_commit_unit, id_message
// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_summary_1

// select id_commit_unit, id_message, count(*) from
// NetMeterStage.dbo.t_multi_input_session_set_builder_2
// group by id_commit_unit, id_message
// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_summary_2

// select id_commit_unit, id_message, count(*) from
// NetMeterStage.dbo.t_multi_input_session_set_builder_3
// group by id_commit_unit, id_message
// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_summary_3

// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_message_summary
// select * from
// NetMeterStage.dbo.t_multi_input_session_set_builder_transaction_summary
void TestMultiInputSessionSetBuilder()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select1 = new DesignTimeDatabaseSelect();
  select1->SetBaseQuery(L"SELECT p.id_po as id_sess, bp.* FROM t_po p INNER JOIN t_base_props bp ON bp.id_prop=p.id_po ORDER BY p.id_po");
  plan.push_back(select1);
  DesignTimeDatabaseSelect * select2 = new DesignTimeDatabaseSelect();
  select2->SetBaseQuery(
    L"SELECT plm.id_po as id_parent_sess, bp.* FROM t_pl_map plm "
    L"INNER JOIN t_base_props bp ON plm.id_pi_instance=bp.id_prop "
    L"INNER JOIN t_aggregate agg ON agg.id_prop=bp.id_prop  "
    L"WHERE plm.id_paramtable IS NULL "
    L"ORDER BY plm.id_po");
  plan.push_back(select2);
  DesignTimeDatabaseSelect * select3 = new DesignTimeDatabaseSelect();
  select3->SetBaseQuery(
    L"SELECT plm.id_po as id_parent_sess, bp.* FROM t_pl_map plm "
    L"INNER JOIN t_base_props bp ON plm.id_pi_instance=bp.id_prop "
    L"INNER JOIN t_recur r ON r.id_prop=bp.id_prop  "
    L"WHERE plm.id_paramtable IS NULL "
    L"ORDER BY plm.id_po");
  plan.push_back(select3);
  DesignTimeDatabaseSelect * select4 = new DesignTimeDatabaseSelect();
  select4->SetBaseQuery(
    L"SELECT plm.id_po as id_parent_sess, bp.* FROM t_pl_map plm "
    L"INNER JOIN t_base_props bp ON plm.id_pi_instance=bp.id_prop "
    L"WHERE plm.id_paramtable IS NULL AND bp.n_kind = 10 "
    L"ORDER BY plm.id_po");
  plan.push_back(select4);
  DesignTimeSessionSetBuilder * ss = new DesignTimeSessionSetBuilder(3, 5);
  plan.push_back(ss);
  DesignTimeDatabaseInsert * insert1 = new DesignTimeDatabaseInsert();
  insert1->SetTableName(L"t_multi_input_session_set_builder_0");
  insert1->SetCreateTable(true);
  plan.push_back(insert1);
  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_multi_input_session_set_builder_1");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);
  DesignTimeDatabaseInsert * insert3 = new DesignTimeDatabaseInsert();
  insert3->SetTableName(L"t_multi_input_session_set_builder_2");
  insert3->SetCreateTable(true);
  plan.push_back(insert3);
  DesignTimeDatabaseInsert * insert4 = new DesignTimeDatabaseInsert();
  insert4->SetTableName(L"t_multi_input_session_set_builder_3");
  insert4->SetCreateTable(true);
  plan.push_back(insert4);
  DesignTimeDatabaseInsert * insert5 = new DesignTimeDatabaseInsert();
  insert5->SetTableName(L"t_multi_input_session_set_builder_summary_0");
  insert5->SetCreateTable(true);
  plan.push_back(insert5);
  DesignTimeDatabaseInsert * insert6 = new DesignTimeDatabaseInsert();
  insert6->SetTableName(L"t_multi_input_session_set_builder_summary_1");
  insert6->SetCreateTable(true);
  plan.push_back(insert6);
  DesignTimeDatabaseInsert * insert7 = new DesignTimeDatabaseInsert();
  insert7->SetTableName(L"t_multi_input_session_set_builder_summary_2");
  insert7->SetCreateTable(true);
  plan.push_back(insert7);
  DesignTimeDatabaseInsert * insert8 = new DesignTimeDatabaseInsert();
  insert8->SetTableName(L"t_multi_input_session_set_builder_summary_3");
  insert8->SetCreateTable(true);
  plan.push_back(insert8);
  DesignTimeDatabaseInsert * insert9 = new DesignTimeDatabaseInsert();
  insert9->SetTableName(L"t_multi_input_session_set_builder_message_summary");
  insert9->SetCreateTable(true);
  plan.push_back(insert9);
  DesignTimeDatabaseInsert * insert10 = new DesignTimeDatabaseInsert();
  insert10->SetTableName(L"t_multi_input_session_set_builder_transaction_summary");
  insert10->SetCreateTable(true);
  plan.push_back(insert10);
  plan.push_back(new DesignTimeChannel(select1->GetOutputPorts()[0], ss->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(select2->GetOutputPorts()[0], ss->GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(select3->GetOutputPorts()[0], ss->GetInputPorts()[2]));
  plan.push_back(new DesignTimeChannel(select4->GetOutputPorts()[0], ss->GetInputPorts()[3]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[0], insert1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[1], insert2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2], insert3->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[3], insert4->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[4], insert5->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[5], insert6->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[6], insert7->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[7], insert8->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[8], insert9->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[9], insert10->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestEmptyMultiInputSessionSetBuilder()
{
  DesignTimePlan plan;
  DesignTimeGenerator * select1 = new DesignTimeGenerator();
  select1->SetNumRecords(0LL);
  select1->SetProgram(
    L"CREATE PROCEDURE parent @id_sess BIGINT\n"
    L"AS\n"
    L"SET @id_sess = @@RECORDCOUNT");
  plan.push_back(select1);
  DesignTimeGenerator * select2 = new DesignTimeGenerator();
  plan.push_back(select2);
  select2->SetNumRecords(2LL);
  select2->SetProgram(
    L"CREATE PROCEDURE parent @id_parent_sess BIGINT\n"
    L"AS\n"
    L"SET @id_parent_sess = @@RECORDCOUNT");
  DesignTimeGenerator * select3 = new DesignTimeGenerator();
  plan.push_back(select3);
  select3->SetNumRecords(0LL);
  select3->SetProgram(
    L"CREATE PROCEDURE parent @id_parent_sess BIGINT\n"
    L"AS\n"
    L"SET @id_parent_sess = @@RECORDCOUNT");
  DesignTimeGenerator * select4 = new DesignTimeGenerator();
  plan.push_back(select4);
  select4->SetNumRecords(1LL);
  select4->SetProgram(
    L"CREATE PROCEDURE parent @id_parent_sess BIGINT\n"
    L"AS\n"
    L"SET @id_parent_sess = @@RECORDCOUNT");
  DesignTimeSessionSetBuilder * ss = new DesignTimeSessionSetBuilder(3, 5);
  plan.push_back(ss);
  DesignTimeDatabaseInsert * insert1 = new DesignTimeDatabaseInsert();
  insert1->SetTableName(L"t_empty_multi_input_session_set_builder_0");
  insert1->SetCreateTable(true);
  plan.push_back(insert1);
  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_empty_multi_input_session_set_builder_1");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);
  DesignTimeDatabaseInsert * insert3 = new DesignTimeDatabaseInsert();
  insert3->SetTableName(L"t_empty_multi_input_session_set_builder_2");
  insert3->SetCreateTable(true);
  plan.push_back(insert3);
  DesignTimeDatabaseInsert * insert4 = new DesignTimeDatabaseInsert();
  insert4->SetTableName(L"t_empty_multi_input_session_set_builder_3");
  insert4->SetCreateTable(true);
  plan.push_back(insert4);
  DesignTimeDatabaseInsert * insert5 = new DesignTimeDatabaseInsert();
  insert5->SetTableName(L"t_empty_multi_input_session_set_builder_summary_0");
  insert5->SetCreateTable(true);
  plan.push_back(insert5);
  DesignTimeDatabaseInsert * insert6 = new DesignTimeDatabaseInsert();
  insert6->SetTableName(L"t_empty_multi_input_session_set_builder_summary_1");
  insert6->SetCreateTable(true);
  plan.push_back(insert6);
  DesignTimeDatabaseInsert * insert7 = new DesignTimeDatabaseInsert();
  insert7->SetTableName(L"t_empty_multi_input_session_set_builder_summary_2");
  insert7->SetCreateTable(true);
  plan.push_back(insert7);
  DesignTimeDatabaseInsert * insert8 = new DesignTimeDatabaseInsert();
  insert8->SetTableName(L"t_empty_multi_input_session_set_builder_summary_3");
  insert8->SetCreateTable(true);
  plan.push_back(insert8);
  DesignTimeDatabaseInsert * insert9 = new DesignTimeDatabaseInsert();
  insert9->SetTableName(L"t_empty_multi_input_session_set_builder_message_summary");
  insert9->SetCreateTable(true);
  plan.push_back(insert9);
  DesignTimeDatabaseInsert * insert10 = new DesignTimeDatabaseInsert();
  insert10->SetTableName(L"t_empty_multi_input_session_set_builder_transaction_summary");
  insert10->SetCreateTable(true);
  plan.push_back(insert10);
  plan.push_back(new DesignTimeChannel(select1->GetOutputPorts()[0], ss->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(select2->GetOutputPorts()[0], ss->GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(select3->GetOutputPorts()[0], ss->GetInputPorts()[2]));
  plan.push_back(new DesignTimeChannel(select4->GetOutputPorts()[0], ss->GetInputPorts()[3]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[0], insert1->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[1], insert2->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2], insert3->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[3], insert4->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[4], insert5->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[5], insert6->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[6], insert7->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[7], insert8->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[8], insert9->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[9], insert10->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

// TODO: Check results with the following query.
// select p.id_sess, p.id_source_sess, p.numChildren1
// , sum(case when c1.id_source_sess is null then 0 else 1 end) as actualNumChildren1
// from NetMeterStage..t_multi_input_session_set_builder_with_empty_children_0 p
// left outer join NetMeterStage..t_multi_input_session_set_builder_with_empty_children_1 c1 on p.id_source_sess=c1.id_parent_source_sess
// group by p.id_sess, p.id_source_sess, p.numChildren1
// having 
// p.numChildren1 <> sum(case when c1.id_source_sess is null then 0 else 1 end)

// select p.id_sess, p.id_source_sess, p.numChildren2
// , sum(case when c2.id_source_sess is null then 0 else 1 end) as actualNumChildren2
// from NetMeterStage..t_multi_input_session_set_builder_with_empty_children_0 p
// left outer join NetMeterStage..t_multi_input_session_set_builder_with_empty_children_2 c2 on p.id_source_sess=c2.id_parent_source_sess
// group by p.id_sess, p.id_source_sess, p.numChildren2
// having 
// p.numChildren2 <> sum(case when c2.id_source_sess is null then 0 else 1 end)

// select 
// sum(p.numChildren1) as totalNumChildren1,
// sum(p.numChildren2) as totalNumChildren2
// from NetMeterStage..t_multi_input_session_set_builder_with_empty_children_0 p

// select count(*) actualTotalNumChildren1 from NetMeterStage..t_multi_input_session_set_builder_with_empty_children_1 c1
// select count(*) actualTotalNumChildren2 from NetMeterStage..t_multi_input_session_set_builder_with_empty_children_2 c2
void TestMultiInputSessionSetBuilderWithEmptyChildren()
{
  DesignTimePlan plan;
  DesignTimeGenerator * select1 = new DesignTimeGenerator();
  select1->SetNumRecords(1200LL);
  select1->SetProgram(
    L"CREATE PROCEDURE driver @id_sess BIGINT @id_parent_sess BIGINT @numChildren1 INTEGER @numChildren2 INTEGER\n"
    L"AS\n"
    L"SET @id_sess = @@RECORDCOUNT\n"
    L"SET @id_parent_sess = @@RECORDCOUNT\n"
    L"SET @numChildren1 = CASE @@RECORDCOUNT % 3LL WHEN 0LL THEN 2 WHEN 1LL THEN 3 WHEN 2LL THEN 0 END\n"
    L"SET @numChildren2 = CASE @@RECORDCOUNT % 4LL WHEN 0LL THEN 2 WHEN 1LL THEN 0 WHEN 2LL THEN 3 WHEN 3LL THEN 5 END");
  plan.push_back(select1);
  DesignTimeCopy * copy = new DesignTimeCopy(3);
  plan.push_back(copy);
  plan.push_back(new DesignTimeChannel(select1->GetOutputPorts()[0], copy->GetInputPorts()[0]));

  DesignTimeUnroll * unroll1 = new DesignTimeUnroll();
  unroll1->SetCount(L"numChildren1");
  plan.push_back(unroll1);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], unroll1->GetInputPorts()[0]));
  DesignTimeUnroll * unroll2 = new DesignTimeUnroll();
  unroll2->SetCount(L"numChildren2");
  plan.push_back(unroll2);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[2], unroll2->GetInputPorts()[0]));

  DesignTimeSessionSetBuilder * ss = new DesignTimeSessionSetBuilder(2, 1000, 2000);
  plan.push_back(ss);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], ss->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(unroll1->GetOutputPorts()[0], ss->GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(unroll2->GetOutputPorts()[0], ss->GetInputPorts()[2]));
  DesignTimeDatabaseInsert * insert1 = new DesignTimeDatabaseInsert();
  insert1->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_0");
  insert1->SetCreateTable(true);
  plan.push_back(insert1);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[0], insert1->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert2 = new DesignTimeDatabaseInsert();
  insert2->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_1");
  insert2->SetCreateTable(true);
  plan.push_back(insert2);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[1], insert2->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert3 = new DesignTimeDatabaseInsert();
  insert3->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_2");
  insert3->SetCreateTable(true);
  plan.push_back(insert3);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2], insert3->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert4 = new DesignTimeDatabaseInsert();
  insert4->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_summary_0");
  insert4->SetCreateTable(true);
  plan.push_back(insert4);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[3], insert4->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert5 = new DesignTimeDatabaseInsert();
  insert5->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_summary_1");
  insert5->SetCreateTable(true);
  plan.push_back(insert5);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[4], insert5->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert6 = new DesignTimeDatabaseInsert();
  insert6->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_summary_2");
  insert6->SetCreateTable(true);
  plan.push_back(insert6);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[5], insert6->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert7 = new DesignTimeDatabaseInsert();
  insert7->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_message_summary");
  insert7->SetCreateTable(true);
  plan.push_back(insert7);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[6], insert7->GetInputPorts()[0]));
  DesignTimeDatabaseInsert * insert8 = new DesignTimeDatabaseInsert();
  insert8->SetTableName(L"t_multi_input_session_set_builder_with_empty_children_transaction_summary");
  insert8->SetCreateTable(true);
  plan.push_back(insert8);
  plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[7], insert8->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestTransactionalInstallSingleInput()
{
  DesignTimePlan plan;
  DesignTimeGenerator * select1 = new DesignTimeGenerator();
  select1->SetNumRecords(12LL);
  select1->SetProgram(
    L"CREATE PROCEDURE driver @id_commit_unit INTEGER @size_0 INTEGER\n"
    L"AS\n"
    L"SET @id_commit_unit = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @size_0 = 1\n");
  plan.push_back(select1);

  DesignTimeGenerator * select2 = new DesignTimeGenerator();
  select2->SetNumRecords(12LL);
  select2->SetProgram(
    L"CREATE PROCEDURE driver @id_commit_unit INTEGER @table NVARCHAR @schema NVARCHAR\n"
    L"AS\n"
    L"SET @id_commit_unit = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @table = N't_svc_' + CAST(CAST(9.999999E+07*rand() AS BIGINT) AS NVARCHAR)\n"
    L"SET @schema = N'NetMeterStage'\n");
  plan.push_back(select2);

  DatabaseCommands cmds;
  DesignTimeTransactionalInstall * install = new DesignTimeTransactionalInstall(1);
  std::vector<std::vector<std::wstring> > queries;
  queries.push_back(std::vector<std::wstring>(1, cmds.CreateTableAsSelect(L"NetMeterStage", L"%1%", 
                                                                          L"NetMeter", L"t_svc_audioconfcall")));
  install->SetPreTransactionQueries(queries);
  queries.clear();
  queries.push_back(std::vector<std::wstring>(1, 
                                              L"INSERT INTO NetMeter..t_svc_audioconfcall SELECT * FROM NetMeterStage..%1%"));
  install->SetQueries(queries);
  queries.clear();
  queries.push_back(std::vector<std::wstring>(1, cmds.DropTable(L"NetMeterStage", L"%1%")));
  install->SetPostTransactionQueries(queries);
  plan.push_back(install);

  plan.push_back(new DesignTimeChannel(select1->GetOutputPorts()[0], install->GetInputPorts()[L"control"]));
  plan.push_back(new DesignTimeChannel(select2->GetOutputPorts()[0], install->GetInputPorts()[L"input(0)"]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

// The test data for the following was created by BCP'ing out from a SQL server table.
// The table and the data was created using the following program.
// create table bcptest (
// 	a int null, 
// 	b bigint null, 
// 	c nvarchar(255) null, 
// 	d decimal(18,6), 
// 	e int, 
// 	f nvarchar(255))
// truncate table bcptest
// insert into bcptest (a,b,c,d,e,f) 
// values 
// (1,
// 1+1000000000,
// N'1'+N'_nvarchar',
// 1+0.23,
// datediff(s, '1970-01-01', dateadd(s,1,'2006-01-01')),
// N'2')

// declare @i int
// declare @N int
// declare @rows int
// set @N = 5 -- The bcp2.out file was created with @N=17
// set @i = 0

// while @i < @N
// begin
// select @rows = max(a) from bcptest
// insert into bcptest(a,b,c,d,e,f) 
// select 
// @rows + a, 
// case when (@rows + a) % 13 = 0 then NULL else @rows + a + 1000000000 end, 
// cast(@rows + a as nvarchar(255)) + N'_nvarchar',
// @rows + a + 0.23,
// datediff(s, '1970-01-01', dateadd(s, @rows + a, '2006-01-01')),
// cast((@rows + a)%5 + 2 as nvarchar(255))
// from bcptest
// set @i = @i + 1
// end
// Then bcp out in native mode.
// bcp.exe "NetMeter..bcptest" out bcp.out -n -S localhost -Usa -P*****

/**
 * RecordParser is obsolete (replaced by Importer).
 *
void TestRecordParser()
{
  LogicalRecord logical;
  logical.push_back(L"a", LogicalFieldType::Integer(false));
  logical.push_back(L"b", LogicalFieldType::BigInteger(false));
  logical.push_back(L"c", LogicalFieldType::String(false));
  logical.push_back(L"d", LogicalFieldType::Decimal(false));
  logical.push_back(L"e", LogicalFieldType::Datetime(false));
  logical.push_back(L"f", L"Global", L"CountryName", true);
  RecordMetadata metadata(logical);
  {
    DesignTimePlan plan;
    DesignTimeRecordParser * parser = new DesignTimeRecordParser();
    plan.push_back(parser);
    parser->SetFilename(MTgetenv(L"METRATECHTESTDATABASE") + 
                        L"\\Development\\Core\\DataAccess\\MemoryTable\\bcp.out");
    parser->SetMetadata(metadata);
    parser->SetMode(DesignTimeOperator::SEQUENTIAL);
    DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
    insert->SetTableName(L"t_record_parser_test_1");
    insert->SetCreateTable(true);
    plan.push_back(insert);
    plan.push_back(new DesignTimeChannel(parser->GetOutputPorts()[0], insert->GetInputPorts()[0]));
    plan.type_check();
    ParallelPlan pplan(1);
    plan.code_generate(pplan);
    BOOST_REQUIRE(1 == pplan.GetNumDomains());
    pplan.GetDomain(0)->Start();
  }
//   Timer timer;
//   __int64 numRecords=0LL;
  {
    DesignTimePlan plan;
    DesignTimeRecordParser * parser = new DesignTimeRecordParser();
    plan.push_back(parser);
    parser->SetFilename(MTgetenv(L"METRATECHTESTDATABASE") + 
                        L"\\Development\\Core\\DataAccess\\MemoryTable\\bcp2.out");
    parser->SetMetadata(metadata);
    parser->SetMode(DesignTimeOperator::SEQUENTIAL);
    DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
    insert->SetTableName(L"t_record_parser_test_2");
    insert->SetCreateTable(true);
    plan.push_back(insert);
    plan.push_back(new DesignTimeChannel(parser->GetOutputPorts()[0], insert->GetInputPorts()[0]));
    plan.type_check();
    ParallelPlan pplan(1);
    plan.code_generate(pplan);
    BOOST_REQUIRE(1 == pplan.GetNumDomains());
    pplan.GetDomain(0)->Start();
  }
//   std::cout << "Read " << numRecords << " records in " << timer.GetMilliseconds() << "ms" << std::endl;
}
*/

void TestAssertSortOrder1()
{
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestAssertSortOrder_table");
  table->SetProgram(
    L"CREATE PROCEDURE tbl @SortKey INTEGER\n"
    L"AS\n"
    L"SET @SortKey = CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT\n"
    );
  table->SetNumRecords(10000LL);
  plan.push_back(table);

  DesignTimeAssertSortOrder * order = new DesignTimeAssertSortOrder();
  order->SetName(L"TestAssertSortOrder_order");
  order->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::ASCENDING));
  plan.push_back(order);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], order->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestAssertSortOrder_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(order->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestAssertSortOrder2()
{
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestAssertSortOrder_table");
  table->SetProgram(
    L"CREATE PROCEDURE tbl @SortKey INTEGER\n"
    L"AS\n"
    L"SET @SortKey = -(CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT)\n"
    );
  table->SetNumRecords(10000LL);
  plan.push_back(table);

  DesignTimeAssertSortOrder * order = new DesignTimeAssertSortOrder();
  order->SetName(L"TestAssertSortOrder_order");
  order->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::DESCENDING));
  plan.push_back(order);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], order->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestAssertSortOrder_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(order->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestAssertSortOrder3()
{
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestAssertSortOrder_table");
  table->SetProgram(
    L"CREATE PROCEDURE tbl @SortKey INTEGER\n"
    L"AS\n"
    L"SET @SortKey = CASE WHEN @@RECORDCOUNT = 1000LL THEN -1 ELSE CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT END\n"
    );
  table->SetNumRecords(10000LL);
  plan.push_back(table);

  DesignTimeAssertSortOrder * order = new DesignTimeAssertSortOrder();
  order->SetName(L"TestAssertSortOrder_order");
  order->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::ASCENDING));
  plan.push_back(order);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], order->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestAssertSortOrder_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(order->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  try
  {
    pplan.GetDomain(0)->Start();
    BOOST_REQUIRE(false);
  }
  catch(std::runtime_error&)
  {
  }
}

void TestInMemorySort()
{
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestInMemorySort_table");
  table->SetProgram(
    L"CREATE PROCEDURE tbl @SortKey INTEGER\n"
    L"AS\n"
    L"SET @SortKey = (CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT)\n"
    );
  table->SetNumRecords(10LL);
  plan.push_back(table);

  DesignTimeExternalSort * srt = new DesignTimeExternalSort();
  srt->SetName(L"TestInMemorySort_sort");
  srt->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::DESCENDING));
  plan.push_back(srt);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], srt->GetInputPorts()[0]));
  
  DesignTimeAssertSortOrder * order = new DesignTimeAssertSortOrder();
  order->SetName(L"TestInMemorySort_order");
  order->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::DESCENDING));
  plan.push_back(order);
  plan.push_back(new DesignTimeChannel(srt->GetOutputPorts()[0], order->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestInMemorySort_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(order->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestDiskSort(boost::int64_t numRecords,
                  std::size_t allowedMemory,
                  Timer& t)
{
  ScopeTimer sc(&t);
  DesignTimePlan plan;
  DesignTimeGenerator * table = new DesignTimeGenerator();
  table->SetName(L"TestDiskSort_table");
  table->SetProgram(
    (boost::wformat(
      L"CREATE PROCEDURE tbl @SortKey INTEGER\n"
      L"AS\n"
      L"SET @SortKey = %1% - (CAST(@@RECORDCOUNT AS INTEGER)*(@@PARTITION+1) + @@PARTITIONCOUNT)\n")
      % numRecords).str());
  table->SetNumRecords(numRecords);
  plan.push_back(table);

  DesignTimeExternalSort * srt = new DesignTimeExternalSort();
  srt->SetName(L"TestDiskSort_sort");
  srt->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::ASCENDING));
  srt->SetAllowedMemory(allowedMemory);
  plan.push_back(srt);
  plan.push_back(new DesignTimeChannel(table->GetOutputPorts()[0], srt->GetInputPorts()[0]));
  
  DesignTimeAssertSortOrder * order = new DesignTimeAssertSortOrder();
  order->SetName(L"TestDiskSort_order");
  order->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::ASCENDING));
  plan.push_back(order);
  plan.push_back(new DesignTimeChannel(srt->GetOutputPorts()[0], order->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  devNull->SetName(L"TestDiskSort_devNull");
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(order->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

void TestDiskSort()
{
  Timer t;
//   TestDiskSort(10000LL, 32*1024, t);
//   std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
//   t.Reset();
//   TestDiskSort(100000LL, 32*1024, t);
//   std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
//   t.Reset();
//   TestDiskSort(100000LL, 320*1024, t);
//   std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
//   t.Reset();
//   TestDiskSort(1000000LL, 320*1024, t);
//   std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
//   t.Reset();
  TestDiskSort(10000000LL, 3*1024*1024, t);
  std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
  t.Reset();
  TestDiskSort(10000000LL, 30*1024*1024, t);
  std::cout << "TestDiskSort took " << t.GetMilliseconds() << " ms" << std::endl;
  t.Reset();
}

void TestDirectedCycle()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator ();
  plan.push_back(gen);
  gen->SetName(L"gen");
  gen->SetProgram(
    L"CREATE PROCEDURE gen "
    L"@RecordCount BIGINT\n"
    L"@SortKey BIGINT\n"
    L"AS\n"
    L"SET @RecordCount = @@RECORDCOUNT\n"
    L"SET @SortKey = CASE WHEN @@RECORDCOUNT % 4LL = 0LL THEN @@RECORDCOUNT/2LL ELSE @@RECORDCOUNT + 2LL*(@@RECORDCOUNT/4LL) + (@@RECORDCOUNT % 4LL - 1LL) END\n");
  gen->SetNumRecords(100000);
  DesignTimeSwitch * swch = new DesignTimeSwitch(2);
  plan.push_back(swch);
  swch->SetProgram(
    L"CREATE FUNCTION switch (@RecordCount BIGINT) RETURNS INTEGER\n"
    L"AS\n"
    L"RETURN CASE WHEN @RecordCount % 4LL > 0LL THEN 1 ELSE 0 END\n");
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0],
                                       swch->GetInputPorts()[0]));

  DesignTimeSortMerge * sortMerge = new DesignTimeSortMerge(2);
  plan.push_back(sortMerge);
  sortMerge->AddSortKey(DesignTimeSortKey(L"SortKey", SortOrder::ASCENDING));
  plan.push_back(new DesignTimeChannel(swch->GetOutputPorts()[0], 
                                       sortMerge->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(swch->GetOutputPorts()[1], 
                                       sortMerge->GetInputPorts()[1]));
  
  DesignTimeDatabaseInsert * directedCycle = new DesignTimeDatabaseInsert();
  directedCycle->SetTableName(L"t_directed_cycle_test");
  directedCycle->SetCreateTable(true);
  directedCycle->SetName(L"directedCycle");
  plan.push_back(directedCycle);
  plan.push_back(new DesignTimeChannel(sortMerge->GetOutputPorts()[0], 
                                       directedCycle->GetInputPorts()[0]));

//   DesignTimeDatabaseInsert * insertLeft = new DesignTimeDatabaseInsert();
//   insertLeft->SetTableName(L"t_insert_left_test");
//   insertLeft->SetCreateTable(false);
//   insertLeft->SetName(L"insertLeft");
//   plan.push_back(insertLeft);
//   plan.push_back(new DesignTimeChannel(swch->GetOutputPorts()[0], 
//                                        insertLeft->GetInputPorts()[0]));
//   DesignTimeDatabaseInsert * insertRight = new DesignTimeDatabaseInsert();
//   insertRight->SetTableName(L"t_insert_right_test");
//   insertRight->SetCreateTable(false);
//   insertRight->SetName(L"insertRight");
//   plan.push_back(insertRight);
//   plan.push_back(new DesignTimeChannel(swch->GetOutputPorts()[1], 
//                                        insertRight->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}

static void emptyFunction()
{
}

void TestMeteringStagingDatabaseAtomic()
{
  std::vector<std::wstring> services;
  services.push_back(L"metratech.com/testpi");
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::SHARED);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(4, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::PRIVATE);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(4, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::STREAMING);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(0, recordCount.size());
  }
}

void TestMeteringStagingDatabaseCompound()
{
  std::vector<std::wstring> services;
  services.push_back(L"metratech.com/audioconfcall");
  services.push_back(L"metratech.com/audioconfconnection");
  services.push_back(L"metratech.com/audioconffeature");
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::SHARED);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(6, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::PRIVATE);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(8, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, DatabaseMeteringStagingDatabase::STREAMING);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(0, recordCount.size());
  }
}

void TestMeteringStagingDatabaseAtomicAggregate()
{
  std::vector<std::wstring> services;
  services.push_back(L"metratech.com/songdownloads_temp");
  std::vector<std::wstring> productViews;
  productViews.push_back(L"metratech.com/songdownloads_temp");
  std::vector<std::set<std::wstring> > counters;
  std::set<std::wstring> c;
  c.insert(L"c_TotalSongs");  c.insert(L"c_TotalBytes");
  counters.push_back(c);
  {
    DatabaseMeteringStagingDatabase staging(services, productViews, counters, DatabaseMeteringStagingDatabase::PRIVATE);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(4, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, productViews, counters, DatabaseMeteringStagingDatabase::STREAMING);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(0, recordCount.size());
  }
}

void TestMeteringStagingDatabaseCompoundAggregate()
{
  std::vector<std::wstring> services;
  services.push_back(L"metratech.com/songsession_temp");
  services.push_back(L"metratech.com/songsessionchild_temp");
  std::vector<std::wstring> productViews;
  productViews.push_back(L"metratech.com/songsession_temp");
  productViews.push_back(L"metratech.com/songsessionchild_temp");
  std::vector<std::set<std::wstring> > counters;
  counters.push_back(std::set<std::wstring>());
  std::set<std::wstring> c;
  c.insert(L"c_TotalSongs");  c.insert(L"c_TotalBytes");
  counters.push_back(c);
  {
    DatabaseMeteringStagingDatabase staging(services, productViews, counters, DatabaseMeteringStagingDatabase::PRIVATE);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(6, recordCount.size());
    for(std::vector<boost::int32_t>::iterator it = recordCount.begin();
        it != recordCount.end();
        it++)
    {
      BOOST_REQUIRE_EQUAL(0, *it);
    }
  }
  {
    DatabaseMeteringStagingDatabase staging(services, productViews, counters, DatabaseMeteringStagingDatabase::STREAMING);
    std::vector<boost::int32_t> recordCount;
    staging.Start(emptyFunction, recordCount);
    BOOST_REQUIRE_EQUAL(0, recordCount.size());
  }
}

void TestMeteringTestPI(DatabaseMeteringStagingDatabase::StagingMethod stagingMethod, 
                        boost::int32_t numRecords, 
                        boost::int32_t numRecordsPerMessage,
                        boost::int32_t numRecordsPerCommit)
{
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT max(id_message) FROM t_message"));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  boost::int32_t maxMessage = rs->GetInteger(1);
  rs = boost::shared_ptr<COdbcResultSet>();

  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator ();
  plan.push_back(gen);
  gen->SetName(L"gen");
  gen->SetProgram(
    L"CREATE PROCEDURE gen "
    L"@c_description NVARCHAR\n"
    L"@c_time DATETIME\n"
    L"@c_duration INTEGER\n"
    L"@c_units DECIMAL\n"
    L"@c_accountname NVARCHAR\n"
    L"@c_DecProp1 DECIMAL\n"
    L"@c_DecProp2 DECIMAL\n"
    L"@c_DecProp3 DECIMAL\n"
    L"AS\n"
    L"SET @c_description=N'TestMetering unit test'\n"
    L"SET @c_time=getutcdate()\n"
    L"SET @c_duration=100\n"
    L"SET @c_units=0.89\n"
    L"SET @c_accountname=N'demo'\n"
    L"SET @c_DecProp1=1.0\n"
    L"SET @c_DecProp2=2.0\n"
    L"SET @c_DecProp3=3.0\n");
  gen->SetNumRecords(numRecords);

  std::vector<std::wstring> services(1, L"metratech.com/testpi");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(services, 
                                                                                                     stagingMethod));

  Metering meter;
  meter.SetParent(L"metratech.com/testpi");
  meter.SetTargetMessageSize(numRecordsPerMessage);
  meter.SetTargetCommitSize(numRecordsPerCommit);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 1);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], meter.GetInputPorts()[0]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  stagingArea->Start(pplan);    

  // This is generally true of atomics (all but the last should have exactly the right number).
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("SELECT COUNT(*) FROM t_message WHERE id_message > %1%") % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  BOOST_REQUIRE_EQUAL((numRecords + numRecordsPerMessage - 1)/numRecordsPerMessage, rs->GetInteger(1));
  rs = boost::shared_ptr<COdbcResultSet>();
  // General materialization fact about metering database.
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("select ss.id_message, ss.session_count, count(*) as actual_count\n"
                                                        "from t_session_set ss \n"
                                                        "inner join t_session s ON s.id_ss=ss.id_ss\n"
                                                        "where ss.id_message >= %1% \n"
                                                        "group by ss.id_message, ss.session_count\n"
                                                        "having count(*) <> ss.session_count\n") % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(false, rs->Next());
  rs = boost::shared_ptr<COdbcResultSet>();  
  // This is generally true of atomics (all but the last should have exactly the right number).
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("SELECT COUNT(*) FROM t_session_set ss\n"
                                                        "WHERE ss.id_message > %1% AND ss.session_count = %2%") 
                                          % maxMessage % numRecordsPerMessage).str()));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  BOOST_REQUIRE_EQUAL(numRecords/numRecordsPerMessage, rs->GetInteger(1));
  rs = boost::shared_ptr<COdbcResultSet>();
  // True for all cases.
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("SELECT COUNT(*) FROM t_session_set ss\n"
                                                        "INNER JOIN t_session s ON s.id_ss=ss.id_ss\n"
                                                        "WHERE id_message > %1%") % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  BOOST_REQUIRE_EQUAL(numRecords, rs->GetInteger(1));
  rs = boost::shared_ptr<COdbcResultSet>();

}

void TestMeteringSongDownloads()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator ();
  plan.push_back(gen);
  gen->SetName(L"gen");
  gen->SetProgram(
    L"CREATE PROCEDURE gen "
    L"@c_description NVARCHAR\n"
    L"@c_songs DECIMAL\n"
    L"@c_mp3bytes DECIMAL\n"
    L"@c_wavbytes DECIMAL\n"
    L"@c_accountname NVARCHAR\n"
    L"AS\n"
    L"SET @c_description=N'TestMeteringSongDownloads unit test'\n"
    L"SET @c_songs=10.0\n"
    L"SET @c_mp3bytes=1000.0\n"
    L"SET @c_wavbytes=500.0\n"
    L"SET @c_accountname=N'demo'\n");
  gen->SetNumRecords(1000);

  std::vector<std::wstring> services(1, L"metratech.com/songdownloads");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(services, 
                                                                                                 DatabaseMeteringStagingDatabase::PRIVATE));

  Metering meter;
  meter.SetParent(L"metratech.com/songdownloads");
  meter.SetTargetMessageSize(100);
  std::vector<boost::uint8_t> collID(16, 0xff);
  meter.SetCollectionID(collID);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 1);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], meter.GetInputPorts()[0]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  stagingArea->Start(pplan);    
}

void TestMeteringCompound()
{
  DesignTimePlan plan;
  DesignTimeGenerator * genCall = new DesignTimeGenerator ();
  plan.push_back(genCall);
  genCall->SetName(L"genCall");
  genCall->SetProgram(
    L"CREATE PROCEDURE genCall "
    L"@id_sess NVARCHAR\n"
    L"@c_ConferenceID NVARCHAR\n"
    L"@c_Payer NVARCHAR\n"
    L"@c_AccountingCode NVARCHAR\n"
    L"@c_ConferenceName NVARCHAR\n"
    L"@c_ConferenceSubject NVARCHAR\n"
    L"@c_OrganizationName NVARCHAR\n"
    L"@c_SpecialInfo NVARCHAR\n"
    L"@c_SchedulerComments NVARCHAR\n"
    L"@c_ScheduledConnections INTEGER\n"
    L"@c_ScheduledStartTime DATETIME\n"
    L"@c_ScheduledTimeGMTOffset DECIMAL\n"
    L"@c_ScheduledDuration INTEGER\n"
    L"@c_CancelledFlag NVARCHAR\n"
    L"@c_CancellationTime DATETIME\n"
    L"@c_ServiceLevel ENUM\n"
    L"@c_TerminationReason NVARCHAR\n"
    L"@c_SystemName NVARCHAR\n"
    L"@c_SalesPersonID NVARCHAR\n"
    L"@c_OperatorID NVARCHAR\n"
    L"AS\n"
    L"SET @id_sess = N'8888888'\n"
    L"SET @c_ConferenceID = N'8888888'\n"
    L"SET @c_Payer = N'demo'\n"
    L"SET @c_AccountingCode = N'123'\n"
    L"SET @c_ConferenceName = N'TradeShow'\n"
    L"SET @c_ConferenceSubject = N'TradeShow'\n"
    L"SET @c_OrganizationName = N'MetraTech'\n"
    L"SET @c_SpecialInfo = N''\n"
    L"SET @c_SchedulerComments = N''\n"
    L"SET @c_ScheduledConnections = 10\n"
    L"SET @c_ScheduledStartTime = getutcdate()\n"
    L"SET @c_ScheduledTimeGMTOffset = 0.0\n"
    L"SET @c_ScheduledDuration = 100\n"
    L"SET @c_CancelledFlag = N'N'\n"
    L"SET @c_CancellationTime = getutcdate()\n"
    L"SET @c_ServiceLevel = #metratech.com/audioconfcommon/ServiceLevel/Basic#\n"
    L"SET @c_TerminationReason = N'Normal'\n"
    L"SET @c_SystemName = N'Bridge1'\n"
    L"SET @c_SalesPersonID = N'Amy'\n"
    L"SET @c_OperatorID = N'Mark'\n");
  genCall->SetNumRecords(1);
  DesignTimeGenerator * genConn = new DesignTimeGenerator ();
  plan.push_back(genConn);
  genConn->SetName(L"genConn");
  genConn->SetProgram(
    L"CREATE PROCEDURE genConn "
    L"@id_parent_sess NVARCHAR\n"
    L"@c_ConferenceID NVARCHAR\n"
    L"@c_Payer NVARCHAR\n"
    L"@c_UserBilled NVARCHAR\n"
    L"@c_UserName NVARCHAR\n"
    L"@c_UserRole ENUM\n"
    L"@c_OrganizationName NVARCHAR\n"
    L"@c_userphonenumber NVARCHAR\n"
    L"@c_specialinfo NVARCHAR\n"
    L"@c_CallType ENUM\n"
    L"@c_transport ENUM\n"
    L"@c_Mode ENUM\n"
    L"@c_ConnectTime DATETIME\n"
    L"@c_EnteredConferenceTime DATETIME\n"
    L"@c_ExitedConferenceTime DATETIME\n"
    L"@c_DisconnectTime DATETIME\n"
    L"@c_Transferred NVARCHAR\n"
    L"@c_TerminationReason NVARCHAR\n"
    L"@c_ISDNDisconnectCause INTEGER\n"
    L"@c_TrunkNumber INTEGER\n"
    L"@c_LineNumber INTEGER\n"
    L"@c_DNISDigits NVARCHAR\n"
    L"@c_ANIDigits NVARCHAR\n"
    L"AS\n"
    L"DECLARE @now DATETIME \n"
    L"SET @now = getutcdate()\n"
    L"SET @id_parent_sess = N'8888888'\n"
    L"SET @c_ConferenceID = N'8888888'\n"
    L"SET @c_Payer = N'demo'\n"
    L"SET @c_UserBilled = N'N'\n"
    L"SET @c_UserName = N'Max'\n"
    L"SET @c_UserRole = #metratech.com/audioconfconnection/UserRole/CSR#\n"
    L"SET @c_OrganizationName = N'MetraTech'\n"
    L"SET @c_userphonenumber = N'781 839 8300'\n"
    L"SET @c_specialinfo = N''\n"
    L"SET @c_CallType = #metratech.com/audioconfconnection/CallType/Dial-In#\n"
    L"SET @c_transport = #metratech.com/audioconfconnection/transport/Toll#\n"
    L"SET @c_Mode = #metratech.com/audioconfconnection/Mode/Direct-Dialed#\n"
    L"SET @c_ConnectTime = @now\n"
    L"SET @c_EnteredConferenceTime = @now\n"
    L"SET @c_ExitedConferenceTime = dateadd('mi', 34.0, @now)\n"
    L"SET @c_DisconnectTime = dateadd('mi', 34.0, @now)\n"
    L"SET @c_Transferred = N'N'\n"
    L"SET @c_TerminationReason = N'Normal'\n"
    L"SET @c_ISDNDisconnectCause = 0\n"
    L"SET @c_TrunkNumber = 10\n"
    L"SET @c_LineNumber = 35\n"
    L"SET @c_DNISDigits = N'781 398 2000'\n"
    L"SET @c_ANIDigits = N'781 398 2242'\n");
  genConn->SetNumRecords(10);

  std::vector<std::wstring> services(1, L"metratech.com/audioconfcall");
  services.push_back(L"metratech.com/audioconfconnection");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(services, DatabaseMeteringStagingDatabase::PRIVATE));

  Metering meter;
  meter.SetParent(L"metratech.com/audioconfcall");
  std::vector<std::wstring> kiddos;
  kiddos.push_back(L"metratech.com/audioconfconnection");
  meter.SetChildren(kiddos);
  meter.SetTargetMessageSize(100);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 2);
  plan.push_back(new DesignTimeChannel(genCall->GetOutputPorts()[0], meter.GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(genConn->GetOutputPorts()[0], meter.GetInputPorts()[1]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  stagingArea->Start(pplan);    
}

void TestMeteringRandomAudioConference(DatabaseMeteringStagingDatabase::StagingMethod stagingMethod)
{
  boost::int32_t numParents(10000);

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT max(id_message) FROM t_message"));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  boost::int32_t maxMessage = rs->GetInteger(1);
  rs = boost::shared_ptr<COdbcResultSet>();

  DesignTimePlan plan;
  DesignTimeGenerator * genCall = new DesignTimeGenerator ();
  plan.push_back(genCall);
  genCall->SetName(L"genCall");
  genCall->SetProgram(
    L"CREATE PROCEDURE genCall "
    L"@id_sess NVARCHAR\n"
    L"@c_ConferenceID NVARCHAR\n"
    L"@c_Payer NVARCHAR\n"
    L"@baseDatetime DATETIME\n"
    L"@numConnections INTEGER\n"
    L"@numFeatures INTEGER\n"
    L"AS\n"
    L"SET @id_sess = CAST(@@RECORDCOUNT AS NVARCHAR)\n"
    L"SET @c_ConferenceID = CAST(@@RECORDCOUNT AS NVARCHAR)\n"
    L"SET @c_Payer = N'demo'\n"
    L"SET @baseDatetime = getutcdate()\n"
    L"SET @numConnections = CAST(rand() * CAST(11 AS DOUBLE PRECISION) AS INTEGER)\n"
    L"SET @numFeatures = CAST(rand() * CAST(4 AS DOUBLE PRECISION) AS INTEGER)\n"
    );
  genCall->SetNumRecords(numParents);

  // Split out into drivers for each of call, connection and feature.
  DesignTimeCopy * copy = new DesignTimeCopy(3);
  plan.push_back(copy);
  plan.push_back(new DesignTimeChannel(genCall->GetOutputPorts()[0], copy->GetInputPorts()[0]));
  // Unroll connection and feature
  DesignTimeUnroll * unrollConnection = new DesignTimeUnroll();
  unrollConnection->SetCount(L"numConnections");
  plan.push_back(unrollConnection);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], unrollConnection->GetInputPorts()[0]));
  DesignTimeUnroll * unrollFeature = new DesignTimeUnroll();
  unrollFeature->SetCount(L"numFeatures");
  plan.push_back(unrollFeature);
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[2], unrollFeature->GetInputPorts()[0]));

  DesignTimeExpression * callExpression = new DesignTimeExpression();
  plan.push_back(callExpression);
  callExpression->SetName(L"callExpression");
  callExpression->SetProgram(
    L"CREATE PROCEDURE genCall "
    L"@baseDatetime DATETIME\n"
    L"@c_AccountingCode NVARCHAR OUTPUT \n"
    L"@c_ConferenceName NVARCHAR OUTPUT \n"
    L"@c_ConferenceSubject NVARCHAR OUTPUT \n"
    L"@c_OrganizationName NVARCHAR OUTPUT \n"
    L"@c_SpecialInfo NVARCHAR OUTPUT \n"
    L"@c_SchedulerComments NVARCHAR OUTPUT \n"
    L"@c_ScheduledConnections INTEGER OUTPUT \n"
    L"@c_ScheduledStartTime DATETIME OUTPUT \n"
    L"@c_ScheduledTimeGMTOffset DECIMAL OUTPUT \n"
    L"@c_ScheduledDuration INTEGER OUTPUT \n"
    L"@c_CancelledFlag NVARCHAR OUTPUT \n"
    L"@c_CancellationTime DATETIME OUTPUT \n"
    L"@c_ServiceLevel ENUM OUTPUT \n"
    L"@c_TerminationReason NVARCHAR OUTPUT \n"
    L"@c_SystemName NVARCHAR OUTPUT \n"
    L"@c_SalesPersonID NVARCHAR OUTPUT \n"
    L"@c_OperatorID NVARCHAR OUTPUT \n"
    L"AS\n"
    L"SET @c_AccountingCode = N'123'\n"
    L"SET @c_ConferenceName = N'TradeShow'\n"
    L"SET @c_ConferenceSubject = N'TradeShow'\n"
    L"SET @c_OrganizationName = N'MetraTech'\n"
    L"SET @c_SpecialInfo = N''\n"
    L"SET @c_SchedulerComments = N''\n"
    L"SET @c_ScheduledConnections = 10\n"
    L"SET @c_ScheduledStartTime = @baseDatetime\n"
    L"SET @c_ScheduledTimeGMTOffset = 0.0\n"
    L"SET @c_ScheduledDuration = 100\n"
    L"SET @c_CancelledFlag = N'N'\n"
    L"SET @c_CancellationTime = @baseDatetime\n"
    L"SET @c_ServiceLevel = #metratech.com/audioconfcommon/ServiceLevel/Basic#\n"
    L"SET @c_TerminationReason = N'Normal'\n"
    L"SET @c_SystemName = N'Bridge1'\n"
    L"SET @c_SalesPersonID = N'Amy'\n"
    L"SET @c_OperatorID = N'Mark'\n");
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], callExpression->GetInputPorts()[0]));

  DesignTimeExpression * connExpression = new DesignTimeExpression ();
  plan.push_back(connExpression);
  connExpression->SetName(L"connExpression");
  connExpression->SetProgram(
    L"CREATE PROCEDURE connExpression "
    L"@c_UserBilled NVARCHAR OUTPUT\n"
    L"@c_UserName NVARCHAR OUTPUT\n"
    L"@c_UserRole ENUM OUTPUT\n"
    L"@c_OrganizationName NVARCHAR OUTPUT\n"
    L"@c_userphonenumber NVARCHAR OUTPUT\n"
    L"@c_specialinfo NVARCHAR OUTPUT\n"
    L"@c_CallType ENUM OUTPUT\n"
    L"@c_transport ENUM OUTPUT\n"
    L"@c_Mode ENUM OUTPUT\n"
    L"@c_ConnectTime DATETIME OUTPUT\n"
    L"@c_EnteredConferenceTime DATETIME OUTPUT\n"
    L"@c_ExitedConferenceTime DATETIME OUTPUT\n"
    L"@c_DisconnectTime DATETIME OUTPUT\n"
    L"@c_Transferred NVARCHAR OUTPUT\n"
    L"@c_TerminationReason NVARCHAR OUTPUT\n"
    L"@c_ISDNDisconnectCause INTEGER OUTPUT\n"
    L"@c_TrunkNumber INTEGER OUTPUT\n"
    L"@c_LineNumber INTEGER OUTPUT\n"
    L"@c_DNISDigits NVARCHAR OUTPUT\n"
    L"@c_ANIDigits NVARCHAR OUTPUT\n"
    L"AS\n"
    L"DECLARE @now DATETIME \n"
    L"SET @now = getutcdate()\n"
    L"SET @c_UserBilled = N'N'\n"
    L"SET @c_UserName = N'Max'\n"
    L"SET @c_UserRole = #metratech.com/audioconfconnection/UserRole/CSR#\n"
    L"SET @c_OrganizationName = N'MetraTech'\n"
    L"SET @c_userphonenumber = N'781 839 8300'\n"
    L"SET @c_specialinfo = N''\n"
    L"SET @c_CallType = #metratech.com/audioconfconnection/CallType/Dial-In#\n"
    L"SET @c_transport = #metratech.com/audioconfconnection/transport/Toll#\n"
    L"SET @c_Mode = #metratech.com/audioconfconnection/Mode/Direct-Dialed#\n"
    L"SET @c_ConnectTime = @now\n"
    L"SET @c_EnteredConferenceTime = @now\n"
    L"SET @c_ExitedConferenceTime = dateadd('mi', 34.0, @now)\n"
    L"SET @c_DisconnectTime = dateadd('mi', 34.0, @now)\n"
    L"SET @c_Transferred = N'N'\n"
    L"SET @c_TerminationReason = N'Normal'\n"
    L"SET @c_ISDNDisconnectCause = 0\n"
    L"SET @c_TrunkNumber = 10\n"
    L"SET @c_LineNumber = 35\n"
    L"SET @c_DNISDigits = N'781 398 2000'\n"
    L"SET @c_ANIDigits = N'781 398 2242'\n");
  plan.push_back(new DesignTimeChannel(unrollConnection->GetOutputPorts()[0], connExpression->GetInputPorts()[0]));

  DesignTimeExpression * featureExpression = new DesignTimeExpression ();
  plan.push_back(featureExpression);
  featureExpression->SetName(L"featureExpression");
  featureExpression->SetProgram(
    L"CREATE PROCEDURE featureExpression "
    L"@c_FeatureType ENUM OUTPUT\n"
    L"@c_Metric DECIMAL OUTPUT\n"
    L"AS\n"
    L"SET @c_FeatureType = #metratech.com/audioconffeature/FeatureType/TapesCopies#\n"
    L"SET @c_Metric = 2.0\n");
  plan.push_back(new DesignTimeChannel(unrollFeature->GetOutputPorts()[0], featureExpression->GetInputPorts()[0]));

  // Do our metering using a private staging area for just audioconf services
  std::vector<std::wstring> audioConfServices;
  audioConfServices.push_back(L"metratech.com/audioconfcall");
  audioConfServices.push_back(L"metratech.com/audioconfconnection");
  audioConfServices.push_back(L"metratech.com/audioconffeature");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(audioConfServices, 
                                                                                                     stagingMethod));
  
  Metering meter;
  meter.SetParent(L"metratech.com/audioconfcall");
  meter.SetParentKey(L"c_ConferenceID");
  std::vector<std::wstring> kiddos;
  std::vector<std::wstring> kiddoKeys;
  kiddos.push_back(L"metratech.com/audioconfconnection");
  kiddos.push_back(L"metratech.com/audioconffeature");
  meter.SetChildren(kiddos);
  kiddoKeys.push_back(L"c_ConferenceID");
  kiddoKeys.push_back(L"c_ConferenceID");
  meter.SetChildKeys(kiddoKeys);
  meter.SetTargetMessageSize(1000);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 3);
  plan.push_back(new DesignTimeChannel(callExpression->GetOutputPorts()[0], meter.GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(connExpression->GetOutputPorts()[0], meter.GetInputPorts()[1]));
  plan.push_back(new DesignTimeChannel(featureExpression->GetOutputPorts()[0], meter.GetInputPorts()[2]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());

  stagingArea->Start(pplan);

  // General materialization fact about metering database.
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("select ss.id_message, ss.session_count, count(*) as actual_count\n"
                                                        "from t_session_set ss \n"
                                                        "inner join t_session s ON s.id_ss=ss.id_ss\n"
                                                        "where ss.id_message >= %1% \n"
                                                        "group by ss.id_message, ss.session_count\n"
                                                        "having count(*) <> ss.session_count\n") % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(false, rs->Next());
  rs = boost::shared_ptr<COdbcResultSet>();  
  // Count metered conferences.
  rs=boost::shared_ptr<COdbcResultSet>(stmt->ExecuteQuery(
                                         (boost::format("SELECT COUNT(*) FROM t_session_set ss\n"
                                                        "INNER JOIN t_session s ON s.id_ss=ss.id_ss\n"
                                                        "INNER JOIN t_svc_audioconfcall svc ON s.id_source_sess=svc.id_source_sess\n"
                                                        "WHERE id_message > %1%") % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(true, rs->Next());
  BOOST_REQUIRE_EQUAL(numParents, rs->GetInteger(1));
  rs = boost::shared_ptr<COdbcResultSet>();
  // verify child counts are all between configured parameters
  rs=boost::shared_ptr<COdbcResultSet>(
    stmt->ExecuteQuery(
      (boost::format(
        "SELECT svc.id_parent_source_sess, COUNT(*) FROM t_session_set ss\n"
        "INNER JOIN t_session s ON ss.id_ss=s.id_ss\n"
        "INNER JOIN t_svc_audioconfconnection svc ON svc.id_source_sess=s.id_source_sess\n"
        "WHERE ss.id_message > %1%\n"
        "GROUP BY svc.id_parent_source_sess\n"
        "HAVING COUNT(*) > 10\n")
        % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(false, rs->Next());
  rs = boost::shared_ptr<COdbcResultSet>();
  // verify child counts are all between configured parameters
  rs=boost::shared_ptr<COdbcResultSet>(
    stmt->ExecuteQuery(
      (boost::format(
        "SELECT svc.id_parent_source_sess, COUNT(*) FROM t_session_set ss\n"
        "INNER JOIN t_session s ON ss.id_ss=s.id_ss\n"
        "INNER JOIN t_svc_audioconffeature svc ON svc.id_source_sess=s.id_source_sess\n"
        "WHERE ss.id_message > %1%\n"
        "GROUP BY svc.id_parent_source_sess\n"
        "HAVING COUNT(*) > 4\n")
        % maxMessage).str()));
  BOOST_REQUIRE_EQUAL(false, rs->Next());
  rs = boost::shared_ptr<COdbcResultSet>();
}

void TestMeteringSongSession()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator ();
  plan.push_back(gen);
  gen->SetName(L"gen");
  gen->SetProgram(
    L"CREATE PROCEDURE gen "
    L"@c_description NVARCHAR\n"
    L"@c_duration DECIMAL\n"
    L"@c_AccountName NVARCHAR\n"
    L"AS\n"
    L"SET @c_description=N'MTapster song download'\n"
    L"SET @c_duration = 30.00\n"
    L"SET @c_AccountName = N'demo'\n");
  gen->SetNumRecords(1);

  // Do our metering using a private staging area.
  std::vector<std::wstring> audioConfServices;
  audioConfServices.push_back(L"metratech.com/songsession");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(audioConfServices, DatabaseMeteringStagingDatabase::PRIVATE));

  Metering meter;
  meter.SetParent(L"metratech.com/songsession");
  meter.SetTargetMessageSize(100);
  std::vector<boost::uint8_t> collID(16, 0xff);
  meter.SetCollectionID(collID);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 1);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], meter.GetInputPorts()[0]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();    
}

void TestMeteringSongSessionTemp()
{
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator ();
  plan.push_back(gen);
  gen->SetName(L"gen");
  gen->SetProgram(
    L"CREATE PROCEDURE gen "
    L"@c_description NVARCHAR\n"
    L"@c_duration DECIMAL\n"
    L"@c__AccountID INTEGER\n"
    L"@c__PriceableItemInstanceID INTEGER\n"
    L"@c__PriceableItemTemplateID INTEGER\n"
    L"@c__ProductOfferingID INTEGER\n"
    L"@c_OriginalSessionTimestamp DATETIME\n"
    L"@c__FirstPassID BIGINT\n"
    L"AS\n"
    L"SET @c_description=N'MTapster song download'\n"
    L"SET @c_duration = 30.00\n"
    L"SET @c__AccountID = 123\n"
    L"SET @c__PriceableItemInstanceID = 223\n"
    L"SET @c__PriceableItemTemplateID = 334\n"
    L"SET @c__ProductOfferingID = 440\n"
    L"SET @c_OriginalSessionTimestamp = getutcdate()\n"
    L"SET @c__FirstPassID = 999342LL\n");
  gen->SetNumRecords(1);

  // Do our metering using a private staging area.
  std::vector<std::wstring> audioConfServices;
  audioConfServices.push_back(L"metratech.com/songsession_temp");
  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(new DatabaseMeteringStagingDatabase(audioConfServices, DatabaseMeteringStagingDatabase::PRIVATE));
  Metering meter;
  meter.SetParent(L"metratech.com/songsession_temp");
  meter.SetTargetMessageSize(100);
  std::vector<boost::uint8_t> collID(16, 0xff);
  meter.SetCollectionID(collID);
  meter.Generate(plan, stagingArea);

  BOOST_REQUIRE(meter.GetInputPorts().size() == 1);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], meter.GetInputPorts()[0]));

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();    
}

void TestAggregateRating()
{
  boost::int32_t id_pi_template=363;
  boost::int32_t id_view = 2066;
  boost::int32_t id_usage_interval = 871563294;
  boost::int32_t id_billgroup = -1;
  bool is_estimate = true;
  std::wstring initializeProgram(
    L"CREATE PROCEDURE initializer \n"
    L"@Table_c_TotalOptionMinutes DECIMAL @Table_TotalCountables INTEGER\n"
    L"AS\n"
    L"SET @Table_c_TotalOptionMinutes = 0.0\n"
    L"SET @Table_TotalCountables = 0\n");
  std::set<std::wstring> counters;
  counters.insert(L"TotalCountables");
  AggregateRatingUsageSpec usg (L"t_pv_gsm_temp", 
                                id_view, 
                                id_usage_interval, 
                                id_billgroup, 
                                is_estimate,
                                counters,
                                initializeProgram, 
                                id_pi_template);
  std::vector<AggregateRatingCountableSpec> countables;
  std::set<std::wstring> countableColumns;
  countableColumns.insert(L"c_OptionMinutes");
  std::wstring updateProgram(
    L"CREATE PROCEDURE updater @Probe_c_OptionMinutes DECIMAL\n"
    L"@Table_c_TotalOptionMinutes DECIMAL @Table_TotalCountables INTEGER\n"
    L"AS\n"
    L"SET @Table_c_TotalOptionMinutes = @Table_c_TotalOptionMinutes + @Probe_c_OptionMinutes\n"
    L"SET @Table_TotalCountables = @Table_TotalCountables + 1\n");
  countables.push_back(AggregateRatingCountableSpec(L"t_pv_gsm_temp", id_view, countableColumns, 
                                                    updateProgram));

  DesignTimePlan plan;
  AggregateRating agg(plan, usg, countables);

  DesignTimeDatabaseInsert * individualInsert = new DesignTimeDatabaseInsert();
  individualInsert->SetTableName(L"t_individual_aggregate_rating_test");
  individualInsert->SetCreateTable(true);
  individualInsert->SetName(L"individualInsert");
  plan.push_back(individualInsert);
  plan.push_back(new DesignTimeChannel(agg.GetOutputPort(), 
                                       individualInsert->GetInputPorts()[0]));
//   // serialize the plan 
//   { 
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     // write class instance to archive
//     oa << BOOST_SERIALIZATION_NVP(plan);
//     // archive and stream closed when destructors are called
//   }

  plan.type_check();
  ParallelPlan pplan(1);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  Timer t;
  {
    ScopeTimer sc(&t);
    pplan.GetDomain(0)->Start();  
  }
  std::cout << "TestAggregateRating took " << t.GetMilliseconds() << " ms" << std::endl;
}

static DesignTimeAssertSortOrder * GetAssertSortOrder(const std::wstring& name)
{
  // Assert sort order 
  DesignTimeAssertSortOrder * assertSortOrder = new DesignTimeAssertSortOrder();
  assertSortOrder->SetName(name);
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"c_BillingIntervalEnd",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"c_SessionDate",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"id_parent_sess",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"id_sess",SortOrder::ASCENDING ));
  return assertSortOrder;
}

// Not so much a test as a debugging tool that
// executes just the metering of aggregate usage
// from debugging tables.
// Here everything is hardcoded to PMNA.
void TestAggregateMetering()
{
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * selectConference = new DesignTimeDatabaseSelect();
  selectConference->SetName(L"selectConference");
  selectConference->SetBaseQuery(
           L"SELECT\n"
           L"id_sess\n"
           L",id_parent_sess\n" 
           L",id_usage_interval\n"
           L",c_ViewId\n"
           L",c__PayingAccount\n"
           L",c__AccountID\n"
           L",c_CreationDate\n"
           L",c_SessionDate\n"
           L",c__PriceableItemTemplateID\n" 
           L",c__PriceableItemInstanceID\n"
           L",c__ProductOfferingID\n"
           L",c_BillingIntervalStart\n"
           L",c_BillingIntervalEnd\n"
           L",c_OriginalSessionTimestamp\n"
           L",c__FirstPassID\n"
           L"FROM  NetMeter_PERF1..dbg_aggregate_running_total_0\n"
           L"WHERE {fn MOD(RecordID, %%NUMPARTITIONS%%)} = %%PARTITION%%\n"
           L"ORDER BY RecordID");
  plan.push_back(selectConference);
  DesignTimeDatabaseSelect * selectFeature = new DesignTimeDatabaseSelect();
  selectFeature->SetName(L"selectFeature");
  selectFeature->SetBaseQuery(
           L"SELECT\n"
           L"id_sess\n"
           L",id_parent_sess\n" 
           L",id_usage_interval\n"
           L",c_ViewId\n"
           L",c__PayingAccount\n"
           L",c__AccountID\n"
           L",c_CreationDate\n"
           L",c_SessionDate\n"
           L",c__PriceableItemTemplateID\n" 
           L",c__PriceableItemInstanceID\n"
           L",c__ProductOfferingID\n"
           L",c_BillingIntervalStart\n"
           L",c_BillingIntervalEnd\n"
           L",c_OriginalSessionTimestamp\n"
           L",c__FirstPassID\n"
           L"FROM  NetMeter_PERF1..dbg_aggregate_running_total_1\n"
           L"WHERE {fn MOD(RecordID, %%NUMPARTITIONS%%)} = %%PARTITION%%\n"
           L"ORDER BY RecordID");
  plan.push_back(selectFeature);
  DesignTimeDatabaseSelect * selectConnection = new DesignTimeDatabaseSelect();
  selectConnection->SetName(L"selectConnection");
  selectConnection->SetBaseQuery(
           L"SELECT\n"
           L"id_sess\n"
           L",id_parent_sess\n" 
           L",id_usage_interval\n"
           L",c_ViewId\n"
           L",c__PayingAccount\n"
           L",c__AccountID\n"
           L",c_CreationDate\n"
           L",c_SessionDate\n"
           L",c__PriceableItemTemplateID\n" 
           L",c__PriceableItemInstanceID\n"
           L",c__ProductOfferingID\n"
           L",c_BillingIntervalStart\n"
           L",c_BillingIntervalEnd\n"
           L",c_OriginalSessionTimestamp\n"
           L",c__FirstPassID\n"
           L",c_TotalQualifiedMinutes\n"
           L"FROM  NetMeter_PERF1..dbg_aggregate_running_total_2\n"
           L"WHERE {fn MOD(RecordID, %%NUMPARTITIONS%%)} = %%PARTITION%%\n"
           L"ORDER BY RecordID");
  plan.push_back(selectConnection);

  // Assert sort order 
  DesignTimeAssertSortOrder * assertConferenceSortOrder = GetAssertSortOrder(L"assertConferenceSortOrder");
  plan.push_back(assertConferenceSortOrder);
  plan.push_back(new DesignTimeChannel(selectConference->GetOutputPorts()[0], 
                                       assertConferenceSortOrder->GetInputPorts()[0]));  
  DesignTimeAssertSortOrder * assertFeatureSortOrder = GetAssertSortOrder(L"assertFeatureSortOrder");
  plan.push_back(assertFeatureSortOrder);
  plan.push_back(new DesignTimeChannel(selectFeature->GetOutputPorts()[0], 
                                       assertFeatureSortOrder->GetInputPorts()[0]));  
  DesignTimeAssertSortOrder * assertConnectionSortOrder = GetAssertSortOrder(L"assertConnectionSortOrder");
  plan.push_back(assertConnectionSortOrder);
  plan.push_back(new DesignTimeChannel(selectConnection->GetOutputPorts()[0], 
                                       assertConnectionSortOrder->GetInputPorts()[0]));  
  

  std::vector<std::wstring> aggregateServices;
  aggregateServices.push_back(L"premconf.com/Conference_temp");
  aggregateServices.push_back(L"premconf.com/ConfFeature_temp");
  aggregateServices.push_back(L"premconf.com/ConfConn_temp");
  std::vector<std::wstring> firstPassProductViews;
  firstPassProductViews.push_back(L"premconf.com/Conference_temp");
  firstPassProductViews.push_back(L"premconf.com/ConfFeature_temp");
  firstPassProductViews.push_back(L"premconf.com/ConfConn_temp");
  std::vector<std::set<std::wstring> > counters;
  counters.push_back(std::set<std::wstring> ());
  counters.push_back(std::set<std::wstring> ());
  std::set<std::wstring> connCounters;
  connCounters.insert(L"c_TotalQualifiedMinutes");
  counters.push_back(connCounters);

  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingArea(
    new DatabaseMeteringStagingDatabase(aggregateServices, firstPassProductViews, counters, DatabaseMeteringStagingDatabase::STREAMING));
  boost::shared_ptr<Metering> meter(
    new AggregateMetering(counters));
  std::vector<boost::uint8_t> uid(16, 0xff);
  meter->SetCollectionID(uid);
  meter->SetServices(aggregateServices);
  meter->SetTargetMessageSize(1000);
  meter->Generate(plan, stagingArea);
  ASSERT(3 == meter->GetInputPorts().size());
  plan.push_back(new DesignTimeChannel(assertConferenceSortOrder->GetOutputPorts()[0], meter->GetInputPorts()[0]));  
  plan.push_back(new DesignTimeChannel(assertFeatureSortOrder->GetOutputPorts()[0], meter->GetInputPorts()[1]));  
  plan.push_back(new DesignTimeChannel(assertConnectionSortOrder->GetOutputPorts()[0], meter->GetInputPorts()[2]));  

  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  Timer t;
  {
    ScopeTimer sc(&t);
    pplan.GetDomain(0)->Start();  
  }
  std::cout << "TestAggregateMetering took " << t.GetMilliseconds() << " ms" << std::endl;
}

void TestRemoteExecution(int argc, char* argv[])
{
  Timer t;
  {
    ScopeTimer sc(&t);
    MPIPlanInterpreter::Start(argc, argv);
  }
  std::cout << "TestRemoteExecution took " << t.GetMilliseconds() << " ms" << std::endl;
}


// void TestSortMergeCollector()
// {
//   DesignTimePlan plan;

//   DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
//   select->SetBaseQuery(L"select top 100 id_sess, dt_session, id_acc, id_view from t_acc_usage");
//   plan.push_back(select);

//   DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
//   std::vector<std::wstring> hashKeys;
//   hashKeys.push_back(L"id_acc");
//   part->SetHashKeys(hashKeys);
//   plan.push_back(part);


//   DesignTimeSortKey * sortKey1 = new DesignTimeSortKey(L"id_sess");
//   DesignTimeSortKey * sortKey2 = new DesignTimeSortKey(L"dt_session");
 
//   DesignTimeSortMergeCollector * coll = new DesignTimeSortMergeCollector();
//   coll->SetMode(DesignTimeOperator::SEQUENTIAL);
//   coll->SetSortOrder(DesignTimeSortMergeCollector::ASCENDING);
//   coll->AddSortKey(sortKey1);
//   coll->AddSortKey(sortKey2);

//   plan.push_back(coll);

//   DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
//   insert->SetTableName(L"t_sortmerge_coll_test");
//   insert->SetCreateTable(true);
//   insert->SetMode(DesignTimeOperator::SEQUENTIAL);
//   plan.push_back(insert);
  
//   plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], part->GetInputPorts()[0]));
//   plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], coll->GetInputPorts()[0]));
//   plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
//   plan.type_check();
//   ParallelPlan pplan(2);
//   plan.code_generate(pplan);
//   BOOST_REQUIRE(1 == pplan.GetNumDomains());
//  // pplan.GetDomain(0)->Start();
// }

void TestBPlusTreePageFixedLengthKeyNoPrefix()
{
  BPlusTreePage page;
  page.Init();
  BOOST_REQUIRE(1008 == page.GetFreeBytes());
  BOOST_REQUIRE(16 == page.GetFreeStart());
  BOOST_REQUIRE(0 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  BPlusTreePage::SearchState search;
  std::vector<boost::uint8_t> key1;
  key1.push_back(0x01);key1.push_back(0x01);key1.push_back(0x02);
  key1.push_back(0x03);key1.push_back(0x04);key1.push_back(0x05);
  std::vector<boost::uint8_t> key2;
  key2.push_back(0x01);key2.push_back(0x01);key2.push_back(0x02);
  key2.push_back(0x03);key2.push_back(0x04);key2.push_back(0x07);
  std::vector<boost::uint8_t> key3;
  key3.push_back(0x01);key3.push_back(0x01);key3.push_back(0x02);
  key3.push_back(0x03);key3.push_back(0x04);key3.push_back(0x06);
  std::vector<boost::uint8_t> key4;
  key4.push_back(0x01);key4.push_back(0x01);key4.push_back(0x02);
  key4.push_back(0x02);key4.push_back(0x04);key4.push_back(0x06);

  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());

  // Insert key1
  bool result = page.Insert(&key1[0], key1.size(), &key1[0], key1.size());
  BOOST_REQUIRE(result);
  // 6 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(994 == page.GetFreeBytes());
  // 6 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(28 == page.GetFreeStart());
  BOOST_REQUIRE(1 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key2 (after key 1)
  result = page.Insert(&key2[0], key2.size(), &key2[0], key2.size());
  BOOST_REQUIRE(result);
  // 6 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(980 == page.GetFreeBytes());
  // 6 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(40 == page.GetFreeStart());
  BOOST_REQUIRE(2 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key3 (between key1 and key2
  result = page.Insert(&key3[0], key3.size(), &key3[0], key3.size());
  BOOST_REQUIRE(result);
  // 6 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(966 == page.GetFreeBytes());
  // 6 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(52 == page.GetFreeStart());
  BOOST_REQUIRE(3 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key4 (before key1)
  result = page.Insert(&key4[0], key4.size(), &key4[0], key4.size());
  BOOST_REQUIRE(result);
  // 6 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(952 == page.GetFreeBytes());
  // 6 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(64 == page.GetFreeStart());
  BOOST_REQUIRE(4 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+3);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);

  // 14 bytes per record.  952 bytes available.  We should
  // be able to insert 68 more records. Failure on the 69th.
  for(boost::uint8_t i=0; i<68; i++)
  {
    std::vector<boost::uint8_t> vec(6, i);
    vec[0] = 0x01;
    vec[1] = 0x01;
    vec[2] = 0x02;
    result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
    BOOST_REQUIRE(result);
  }
  BOOST_REQUIRE(0 == page.GetFreeBytes());
  BOOST_REQUIRE(880 == page.GetFreeStart());
  BOOST_REQUIRE(72 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  std::vector<boost::uint8_t> vec(6, 0xff);
  vec[0] = 0x01;
  vec[1] = 0x01;
  vec[2] = 0x02;
  result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
  BOOST_REQUIRE(!result);
}

void TestBPlusTreePageFixedLengthKeyWithPrefix()
{
  BPlusTreePage page;
  std::vector<boost::uint8_t> loKey;
  loKey.push_back(0x01);loKey.push_back(0x01);loKey.push_back(0x02);
  loKey.push_back(0x00);loKey.push_back(0x00);loKey.push_back(0x00);
  std::vector<boost::uint8_t> hiKey;
  hiKey.push_back(0x01);hiKey.push_back(0x01);hiKey.push_back(0x02);
  hiKey.push_back(0xff);hiKey.push_back(0xff);hiKey.push_back(0xff);
  
  // Constant key length initializer
  page.Init(&loKey[0], &hiKey[0], hiKey.size());
  BOOST_REQUIRE(1005 == page.GetFreeBytes());
  BOOST_REQUIRE(19 == page.GetFreeStart());
  BOOST_REQUIRE(0 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  BPlusTreePage::SearchState search;
  std::vector<boost::uint8_t> key1;
  key1.push_back(0x01);key1.push_back(0x01);key1.push_back(0x02);
  key1.push_back(0x03);key1.push_back(0x04);key1.push_back(0x05);
  std::vector<boost::uint8_t> key2;
  key2.push_back(0x01);key2.push_back(0x01);key2.push_back(0x02);
  key2.push_back(0x03);key2.push_back(0x04);key2.push_back(0x07);
  std::vector<boost::uint8_t> key3;
  key3.push_back(0x01);key3.push_back(0x01);key3.push_back(0x02);
  key3.push_back(0x03);key3.push_back(0x04);key3.push_back(0x06);
  std::vector<boost::uint8_t> key4;
  key4.push_back(0x01);key4.push_back(0x01);key4.push_back(0x02);
  key4.push_back(0x02);key4.push_back(0x04);key4.push_back(0x06);

  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());

  // Insert key1
  bool result = page.Insert(&key1[0], key1.size(), &key1[0], key1.size());
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(994 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(28 == page.GetFreeStart());
  BOOST_REQUIRE(1 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key2 (after key 1)
  result = page.Insert(&key2[0], key2.size(), &key2[0], key2.size());
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(983 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(37 == page.GetFreeStart());
  BOOST_REQUIRE(2 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key3 (between key1 and key2
  result = page.Insert(&key3[0], key3.size(), &key3[0], key3.size());
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(972 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(46 == page.GetFreeStart());
  BOOST_REQUIRE(3 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key4 (before key1)
  result = page.Insert(&key4[0], key4.size(), &key4[0], key4.size());
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(961 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(55 == page.GetFreeStart());
  BOOST_REQUIRE(4 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+3);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 0);

  // 11 bytes per record.  971 bytes available.  We should
  // be able to insert 87 more records. Failure on the 88th.
  for(boost::uint8_t i=1; i<=87; i++)
  {
    std::vector<boost::uint8_t> vec(6, i);
    vec[0] = 0x01;
    vec[1] = 0x01;
    vec[2] = 0x02;
    result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
    BOOST_REQUIRE(result);
  }
  BOOST_REQUIRE(4 == page.GetFreeBytes());
  BOOST_REQUIRE(838 == page.GetFreeStart());
  BOOST_REQUIRE(91 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  std::vector<boost::uint8_t> vec(6, 0xff);
  vec[0] = 0x01;
  vec[1] = 0x01;
  vec[2] = 0x02;
  result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
  BOOST_REQUIRE(!result);

  // For the remaining tests, we want to be sure of the 
  // "middle" of the page.  Since there all of key1-key4 are
  // less than the "middle" of the keys 1-88 above, we can
  // assert that key 0x010102282828 is at position 43.
  vec[3]=0x28; vec[4]=0x28, vec[5]=0x28;
  page.Search(&vec[0], vec.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin() + 43);

  // Try some page splits.
  {
    // Page split at the front
    // There will be 92 records to share, the current
    // algorithm leaves the extra record on the left, so
    // the new high key is position 45 of the old record,
    // that should have key from the iteration corresponding to 42 (=0x2a).
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x00);vec.push_back(0x00);vec.push_back(0x00);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin());
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == copy.begin());
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2A);
    BOOST_REQUIRE(newHiKey[4] == 0x2A);
    BOOST_REQUIRE(newHiKey[5] == 0x2A);
    BOOST_REQUIRE(copy.GetNumRecords() == 45);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 46);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split with insert on the left side.
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x10);vec.push_back(0x10);vec.push_back(0x10);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin()+19);
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == copy.begin()+19);
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2A);
    BOOST_REQUIRE(newHiKey[4] == 0x2A);
    BOOST_REQUIRE(newHiKey[5] == 0x2A);
    BOOST_REQUIRE(copy.GetNumRecords() == 45);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 46);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split at the back
    // There will be 92 records to share, the current
    // algorithm leaves the extra record on the left, so
    // the new high key is position 46 of the old record,
    // that should have key from the iteration corresponding to 43 (=0x2b).
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0xff);vec.push_back(0xff);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.end());
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == right.end());
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2B);
    BOOST_REQUIRE(newHiKey[4] == 0x2B);
    BOOST_REQUIRE(newHiKey[5] == 0x2B);
    BOOST_REQUIRE(copy.GetNumRecords() == 46);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 45);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 91 records, the middle is defined at
    // positions 46 (values 43/0x2B).
    // Here we insert at (just before) position 45.
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x29);vec.push_back(0x29);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 45);
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == copy.end());
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2A);
    BOOST_REQUIRE(newHiKey[4] == 0x2A);
    BOOST_REQUIRE(newHiKey[5] == 0x2A);
    BOOST_REQUIRE(copy.GetNumRecords() == 45);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 46);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 92 records, the middle is defined between
    // positions 45 and 46 (values 42 and 43/0x2A and 0x2B).
    // Here we insert at (just before) position 46.
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x2A);vec.push_back(0x2A);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 46);
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == right.begin());
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2A);
    BOOST_REQUIRE(newHiKey[4] == 0x2A);
    BOOST_REQUIRE(newHiKey[5] == 0xFF);
    BOOST_REQUIRE(copy.GetNumRecords() == 46);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 45);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 92 records, the middle is defined between
    // positions 45 and 46 (values 42 and 43/0x2A and 0x2B).
    // Here we insert at (just before) position 47.
    BPlusTreePage copy(page);
    BPlusTreePage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x2B);vec.push_back(0x2B);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 47);
    copy.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight);
    BOOST_REQUIRE(search.Iterator == right.begin()+1);
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x2B);
    BOOST_REQUIRE(newHiKey[4] == 0x2B);
    BOOST_REQUIRE(newHiKey[5] == 0x2B);
    BOOST_REQUIRE(copy.GetNumRecords() == 46);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 45);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
}

void TestBPlusTreePageFixedLengthKeyWithPrefixCompress()
{
  // Here we trigger compress by splitting a page
  // with out of order entries.
  BPlusTreePage page;
  std::vector<boost::uint8_t> loKey;
  loKey.push_back(0x01);loKey.push_back(0x01);loKey.push_back(0x02);
  loKey.push_back(0x00);loKey.push_back(0x00);loKey.push_back(0x00);
  std::vector<boost::uint8_t> hiKey;
  hiKey.push_back(0x01);hiKey.push_back(0x01);hiKey.push_back(0x02);
  hiKey.push_back(0xff);hiKey.push_back(0xff);hiKey.push_back(0xff);
  
  // Constant key length initializer
  page.Init(&loKey[0], &hiKey[0], hiKey.size());
  BOOST_REQUIRE(1005 == page.GetFreeBytes());
  BOOST_REQUIRE(19 == page.GetFreeStart());
  BOOST_REQUIRE(0 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  BPlusTreePage::SearchState search;
  // Previous calculations -> this can take 91 keys. 
  // We insert in interleaved order.
  std::vector<boost::uint8_t> vec(6);
  bool result;
  for(boost::uint8_t i = 1; i<=45; i++)
  {
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(i);vec.push_back(i);vec.push_back(i);
    result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
    BOOST_REQUIRE(result);
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(i+46);vec.push_back(i+46);vec.push_back(i+46);
    result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
    BOOST_REQUIRE(result);
  }
  vec.clear();
  vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
  vec.push_back(46);vec.push_back(46);vec.push_back(46);
  result = page.Insert(&vec[0], vec.size(), &vec[0], vec.size());
  BOOST_REQUIRE(result);
  
  bool insertOnRight;
  std::vector<boost::uint8_t> newHiKey(6);
  vec.clear();
  vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
  vec.push_back(0x2B);vec.push_back(0x2B);vec.push_back(0xff);  
  page.Search(&vec[0], vec.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin() + 43);
  BPlusTreePage right;
  page.SplitLeafRight(right, &vec[0], vec.size(), vec.size(),
                      &loKey[0], &hiKey[0], 
                      &newHiKey[0], search.Iterator, insertOnRight);
  BOOST_REQUIRE(search.Iterator == page.begin() + 43);
  BOOST_REQUIRE(!insertOnRight);
  BOOST_REQUIRE(newHiKey[0] == 0x01);
  BOOST_REQUIRE(newHiKey[1] == 0x01);
  BOOST_REQUIRE(newHiKey[2] == 0x02);
  BOOST_REQUIRE(newHiKey[3] == 0x2E);
  BOOST_REQUIRE(newHiKey[4] == 0x2E);
  BOOST_REQUIRE(newHiKey[5] == 0x2E);
  BOOST_REQUIRE(page.GetNumRecords() == 45);
  BOOST_REQUIRE(page.GetPrefixLength() == 3);
  // We are compressed header/prefix/data/<free space>/slots
  BOOST_REQUIRE(page.GetFreeBytes() == (1024-19-9*45-2*45));
  BOOST_REQUIRE(page.GetFreeStart() == 19 + 9*45);
  BOOST_REQUIRE(right.GetNumRecords() == 46);
  BOOST_REQUIRE(right.GetPrefixLength() == 3);
  BOOST_REQUIRE(right.GetFreeBytes() == (1024-19-(9+2)*46));
  BOOST_REQUIRE(right.GetFreeStart() == 19 + 9*46);
}

void TestBPlusTreeNonLeafPageFixedLengthKeyWithPrefix()
{
  BPlusTreeNonLeafPage page;
  std::vector<boost::uint8_t> loKey;
  loKey.push_back(0x01);loKey.push_back(0x01);loKey.push_back(0x02);
  loKey.push_back(0x00);loKey.push_back(0x00);loKey.push_back(0x00);
  std::vector<boost::uint8_t> hiKey;
  hiKey.push_back(0x01);hiKey.push_back(0x01);hiKey.push_back(0x02);
  hiKey.push_back(0xff);hiKey.push_back(0xff);hiKey.push_back(0xff);
  
  // Constant key length initializer
  page.Init(&loKey[0], &hiKey[0], hiKey.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(0));
  BOOST_REQUIRE(1009 == page.GetFreeBytes());
  BOOST_REQUIRE(15 == page.GetFreeStart());
  BOOST_REQUIRE(0 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  BOOST_REQUIRE(!page.IsEmpty());
  BPlusTreeNonLeafPage::SearchState search;
  std::vector<boost::uint8_t> key1;
  key1.push_back(0x01);key1.push_back(0x01);key1.push_back(0x02);
  key1.push_back(0x03);key1.push_back(0x04);key1.push_back(0x05);
  std::vector<boost::uint8_t> key2;
  key2.push_back(0x01);key2.push_back(0x01);key2.push_back(0x02);
  key2.push_back(0x03);key2.push_back(0x04);key2.push_back(0x07);
  std::vector<boost::uint8_t> key3;
  key3.push_back(0x01);key3.push_back(0x01);key3.push_back(0x02);
  key3.push_back(0x03);key3.push_back(0x04);key3.push_back(0x06);
  std::vector<boost::uint8_t> key4;
  key4.push_back(0x01);key4.push_back(0x01);key4.push_back(0x02);
  key4.push_back(0x02);key4.push_back(0x04);key4.push_back(0x06);

  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());

  // Insert key1
  bool result = page.Insert(&key1[0], key1.size(), &key1[0]);
  BOOST_REQUIRE(result);
  // No key and first pointer preallocated.
  BOOST_REQUIRE(1000 == page.GetFreeBytes());
  BOOST_REQUIRE(22 == page.GetFreeStart());
  BOOST_REQUIRE(1 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  BOOST_REQUIRE(!page.IsEmpty());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == -1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key2 (after key 1)
  result = page.Insert(&key2[0], key2.size(), &key2[0]);
  BOOST_REQUIRE(result);
  // 3 bytes for key, 4 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(991 == page.GetFreeBytes());
  // 3 bytes for key, 4 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(29 == page.GetFreeStart());
  BOOST_REQUIRE(2 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key3 (between key1 and key2)
  result = page.Insert(&key3[0], key3.size(), &key3[0]);
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(982 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(36 == page.GetFreeStart());
  BOOST_REQUIRE(3 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin());
  BOOST_REQUIRE(search.Comparison == 1);

  // Insert key4 (before key1)
  result = page.Insert(&key4[0], key4.size(), &key4[0]);
  BOOST_REQUIRE(result);
  // 3 bytes for key, 6 bytes for value, 2 bytes for slot
  BOOST_REQUIRE(973 == page.GetFreeBytes());
  // 3 bytes for key, 6 bytes for value.  Slot is at the end so doesn't count here.
  BOOST_REQUIRE(43 == page.GetFreeStart());
  BOOST_REQUIRE(4 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  // Check contents
  page.Search(&key1[0], key1.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+2);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key2[0], key2.size(), search);
  BOOST_REQUIRE(search.Iterator == page.end());
  BOOST_REQUIRE(search.Comparison == 0);
  page.Search(&key3[0], key3.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+3);
  BOOST_REQUIRE(search.Comparison == 1);
  page.Search(&key4[0], key4.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin()+1);
  BOOST_REQUIRE(search.Comparison == 1);

  // 9 bytes per record.  973 bytes available.  We should
  // be able to insert 108 more records. Failure on the 109th.
  for(boost::uint8_t i=1; i<=108; i++)
  {
    std::vector<boost::uint8_t> vec(6, i);
    vec[0] = 0x01;
    vec[1] = 0x01;
    vec[2] = 0x02;
    result = page.Insert(&vec[0], vec.size(), &vec[0]);
    BOOST_REQUIRE(result);
  }
  BOOST_REQUIRE(1 == page.GetFreeBytes());
  BOOST_REQUIRE(799 == page.GetFreeStart());
  BOOST_REQUIRE(112 == page.GetNumRecords());
  BOOST_REQUIRE(3 == page.GetPrefixLength());
  std::vector<boost::uint8_t> vec(6, 0xff);
  vec[0] = 0x01;
  vec[1] = 0x01;
  vec[2] = 0x02;
  result = page.Insert(&vec[0], vec.size(), &vec[0]);
  BOOST_REQUIRE(!result);

  // For the remaining tests, we want to be sure of the 
  // "middle" of the page.  Since there all of key1-key4 are
  // less than the "middle" of the keys 1-109 above, we can
  // assert that key 0x010102282828 is at position 43.  Search
  // on a non leaf points to key strictly greater than the search
  // key so we check position 44.
  vec[3]=0x28; vec[4]=0x28, vec[5]=0x28;
  page.Search(&vec[0], vec.size(), search);
  BOOST_REQUIRE(search.Iterator == page.begin() + 44);

  // Try some page splits.
  {
    // Page split at the front
    // There will be 112 keys (113 ptrs) + insert to share, the current
    // algorithm leaves the extra record on the left, so
    // positions 56 and higher are moved to the new page.  The new high
    // key for page is therefore position 55 which is value 52/0x34.
    // GetNumRecords reports key count, so after splitting there are
    // two "last ptrs" hence only 111 keys and 113 ptrs spread between
    // the two pages.  Since we leave behind 56 ptrs (one of which loses
    // its key), there are 55 records on the left and 56 on the right.
    // The lost key is essentially the new high key.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x00);vec.push_back(0x00);vec.push_back(0x00);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin());
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(search.Iterator == copy.begin());
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x34);
    BOOST_REQUIRE(newHiKey[4] == 0x34);
    BOOST_REQUIRE(newHiKey[5] == 0x34);
    BOOST_REQUIRE(copy.GetNumRecords() == 55);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 56);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split with insert on the left side.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x10);vec.push_back(0x10);vec.push_back(0x10);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin()+20);
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(search.Iterator == copy.begin()+20);
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x34);
    BOOST_REQUIRE(newHiKey[4] == 0x34);
    BOOST_REQUIRE(newHiKey[5] == 0x34);
    BOOST_REQUIRE(copy.GetNumRecords() == 55);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 56);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split at the back
    // There will be 112 keys (113 ptrs) + insert to share, the current
    // algorithm leaves the extra record on the left, so
    // the new high key is position 47 of the old record,
    // that should have key from the iteration corresponding to 44 (=0x2c).
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0xff);vec.push_back(0xff);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.end());
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(search.Iterator == right.end());
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x35);
    BOOST_REQUIRE(newHiKey[4] == 0x35);
    BOOST_REQUIRE(newHiKey[5] == 0x35);
    BOOST_REQUIRE(copy.GetNumRecords() == 56);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 55);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 112 keys, the middle is defined between
    // positions 55 and 56 (values 52 and 53/0x34 and 0x35).
    // Here we insert at (just before) position 55.
    // We position by searching on key value 51. Left page gets
    // the extra entry(left side of the child split), so the new
    // high key is the split key/new key.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x33);vec.push_back(0x33);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 55);
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    // What was position 55 has become last page.  So our iterator
    // is now pointing at the end of the page.  
    BOOST_REQUIRE(search.Iterator == copy.end());
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x34);
    BOOST_REQUIRE(newHiKey[4] == 0x34);
    BOOST_REQUIRE(newHiKey[5] == 0x34);
    BOOST_REQUIRE(copy.GetNumRecords() == 55);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 56);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 112 keys, the middle is defined between
    // positions 55 and 56 (values 52 and 53/0x34 and 0x35).
    // Here we split position 56.
    // We position by searching on key value 52. Left page gets
    // the extra entry(left side of the child split), so the new
    // high key is the split key/new key.
    // Pictorially we have:
    // [<p_0 k_0>, ..., <p_{111}, k_{111}>, p_{112}]
    // having a page split (to the right) at position 56:
    // [<p_0 k_0>, ..., <p_{55},k_{55}>, <p_{right},k_{right}>, <p_{56},k_{56}>, ..., <p_{111}, k_{111}>, p_{112}]
    // being split at the right key:
    // [<p_0 k_0>, ..., <p_{55},k_{55}>, <p_{56},k_{right}>, <p_{right},k_{56}>, ..., <p_{111}, k_{111}>, p_{112}]
    // becomes after split and insert
    // [<p_0 k_0>, ..., <p_{55},k_{55}>, <p_{56}>]  (N.B. new high key of the split child is k_{right})
    // and
    // [<p_{right},k_{56}>, ..., <p_{111}, k_{111}>, p_{112}]
    // After split and before insert:
    // [<p_0 k_0>, ..., <p_{55},k_{55}>, <p_{56}>]
    // and
    // [<p_{right},k_{56}>, ..., <p_{111}, k_{111}>, p_{112}]
    //
    // HACK:  Note that the difference between the "after split and before insert"
    // pages and the "after split and insert" pages is not accounted for by the
    // result of an BPlusTreeNonLeafPage::Insert operation but rather an
    // BPlusTreeNonLeafPage::InsertWithNewKey operation.  I have some basic problem
    // with how I have designed my interfaces so this is true.  I must return to this
    // and figure where I have botched things up.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x34);vec.push_back(0x34);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 56);
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    // What was position 55 has become last page.  So our iterator
    // is now pointing at the end of the page.  On the other hand,
    // for the purpose of calculating the new high key we are pretending
    // that the new key has been inserted.
    BOOST_REQUIRE(search.Iterator == right.begin());
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x34);
    BOOST_REQUIRE(newHiKey[4] == 0x34);
    BOOST_REQUIRE(newHiKey[5] == 0xff);
    BOOST_REQUIRE(copy.GetNumRecords() == 56);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 55);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
    BOOST_REQUIRE(vec[0] == 0x01);
    BOOST_REQUIRE(vec[1] == 0x01);
    BOOST_REQUIRE(vec[2] == 0x02);
    BOOST_REQUIRE(vec[3] == 0x35);
    BOOST_REQUIRE(vec[4] == 0x35);
    BOOST_REQUIRE(vec[5] == 0x35);
  }
  {
    // Page split near the insertion point.
    // Given the current 112 keys, the middle is defined between
    // positions 55 and 56 (values 52 and 53/0x34 and 0x35).
    // Here we insert at (just before) position 57.
    // We position by searching on key value 53.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x35);vec.push_back(0x35);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 57);
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(search.Iterator == right.begin());
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x35);
    BOOST_REQUIRE(newHiKey[4] == 0x35);
    BOOST_REQUIRE(newHiKey[5] == 0x35);
    BOOST_REQUIRE(copy.GetNumRecords() == 56);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 55);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
  {
    // Page split near the insertion point.
    // Given the current 112 keys, the middle is defined between
    // positions 55 and 56 (values 52 and 53/0x34 and 0x35).
    // Here we insert at (just before) position 58.
    // We position by searching on key value 54.
    BPlusTreeNonLeafPage copy(page);
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(6);
    bool insertOnRight;
    bool insertWithNewKey;
    vec.clear();
    vec.push_back(0x01);vec.push_back(0x01);vec.push_back(0x02);
    vec.push_back(0x36);vec.push_back(0x36);vec.push_back(0xff);  
    copy.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.Iterator == copy.begin() + 58);
    copy.SplitRight(right, &vec[0], vec.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                        &loKey[0], &hiKey[0], 
                        &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(search.Iterator == right.begin()+1);
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(newHiKey[0] == 0x01);
    BOOST_REQUIRE(newHiKey[1] == 0x01);
    BOOST_REQUIRE(newHiKey[2] == 0x02);
    BOOST_REQUIRE(newHiKey[3] == 0x35);
    BOOST_REQUIRE(newHiKey[4] == 0x35);
    BOOST_REQUIRE(newHiKey[5] == 0x35);
    BOOST_REQUIRE(copy.GetNumRecords() == 56);
    BOOST_REQUIRE(copy.GetPrefixLength() == 3);
    BOOST_REQUIRE(right.GetNumRecords() == 55);
    BOOST_REQUIRE(right.GetPrefixLength() == 3);
  }
}

void TestBPlusTreeNonLeafPageFixedLengthKeyNoPrefixPageSplit()
{
  BPlusTreeNonLeafPage page;
  std::size_t sz(247);
  std::vector<boost::uint8_t> loKey(sz, std::numeric_limits<boost::uint8_t>::min());
  std::vector<boost::uint8_t> hiKey(sz, std::numeric_limits<boost::uint8_t>::max());
  page.Init(&loKey[0], &hiKey[0], hiKey.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(std::numeric_limits<boost::uint32_t>::min()));
  BOOST_REQUIRE(1012 == page.GetFreeBytes());
  BOOST_REQUIRE(12 == page.GetFreeStart());
  BOOST_REQUIRE(0 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  BOOST_REQUIRE(!page.IsEmpty());

  boost::uint32_t numKeys = page.GetFreeBytes()/(sz + sizeof(BPlusTreeNonLeafPage::pageid_t) + sizeof(boost::uint16_t));
  BOOST_REQUIRE(numKeys == 4);
  // The page starts out looking like [ 0 ].
  // Since we split to the right, existing page move left and the result of inserting
  // these 4 <ptr,key> pairs is:
  // [0 4 4 8 8 12 12 16 16]
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x04*i);
    bool result = page.Insert(&vec[0], vec.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(4*i));
    BOOST_REQUIRE(result);
  }
  BOOST_REQUIRE(0 == page.GetFreeBytes());
  BOOST_REQUIRE(1016 == page.GetFreeStart());
  BOOST_REQUIRE(4 == page.GetNumRecords());
  BOOST_REQUIRE(0 == page.GetPrefixLength());
  BOOST_REQUIRE(!page.IsEmpty());

  for(BPlusTreeNonLeafPage::Keys::iterator it = page.GetKeys().begin();
      it != page.GetKeys().end();
      it++)
  {
    std::vector<boost::uint8_t> key(sz, boost::uint8_t(4*(it - page.GetKeys().begin() + 1)));
    BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
  }

  BPlusTreeNonLeafPage::Values values(page.GetValues(sz));
  for(BPlusTreeNonLeafPage::Values::iterator it = values.begin();
      it != values.end();
      it++)
  {
    BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(4*(it - values.begin())));
    BOOST_REQUIRE(*it == expected);
  }
  BOOST_REQUIRE (page.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));

  // Split this thing at the four possible positions
  // and validate the split looks correct.
  {
    // Split page 0 with hi key 4.  New page is 2.  New high key is 2.
    // Result:
    // [0 2 2 4 4] [8 12 12 16 16]
    // After split and prior to insert this looks like:
    // [0 4 4] [8 12 12 16 16]
    BPlusTreeNonLeafPage copy(page);
    std::vector<boost::uint8_t> split_key(sz, 0x02);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    bool result = copy.Insert(&split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(2));
    BOOST_REQUIRE(!result);
    BPlusTreeNonLeafPage::SearchState search;
    copy.Search(&split_key[0], split_key.size(), search);    
    bool insertOnRight;
    bool insertWithNewKey;
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(sz);    
    std::vector<boost::uint8_t> expectedNewHiKey(sz, 0x08);    
    copy.SplitRight(right, &split_key[0], split_key.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                    &loKey[0], &hiKey[0], 
                    &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(0 == memcmp(&newHiKey[0], &expectedNewHiKey[0], sz));
    BOOST_REQUIRE(search.Iterator == copy.begin());
    BOOST_REQUIRE(copy.GetNumRecords() == 1);
    BOOST_REQUIRE(right.GetNumRecords() == 2);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(4));
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    result = copy.Insert(search.Iterator, &split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(2));
    BOOST_REQUIRE(result);
    BOOST_REQUIRE(copy.GetNumRecords() == 2);
    for(BPlusTreeNonLeafPage::Keys::iterator it = copy.GetKeys().begin();
        it != copy.GetKeys().end();
        it++)
    {
      std::vector<boost::uint8_t> key(sz, boost::uint8_t(2*(it - copy.GetKeys().begin() + 1)));
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = copy.GetValues(sz).begin();
        it != copy.GetValues(sz).end();
        it++)
    {
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(2*(it - copy.GetValues(sz).begin())));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(4));
    for(BPlusTreeNonLeafPage::Keys::iterator it = right.GetKeys().begin();
        it != right.GetKeys().end();
        it++)
    {
      std::vector<boost::uint8_t> key(sz, 0x08 + boost::uint8_t(4*(it - right.GetKeys().begin() + 1)));
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = right.GetValues(sz).begin();
        it != right.GetValues(sz).end();
        it++)
    {
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(0x08 + 4*(it - right.GetValues(sz).begin())));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
  }
  {
    // Split page 4 with hi key 8.  New page is 6.  New high key is 8.
    // Result:
    // [0 4 4 6 6] [8 12 12 16 16]
    BPlusTreeNonLeafPage copy(page);
    std::vector<boost::uint8_t> split_key(sz, 0x06);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    bool result = copy.Insert(&split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(2));
    BOOST_REQUIRE(!result);
    BPlusTreeNonLeafPage::SearchState search;
    copy.Search(&split_key[0], split_key.size(), search);    
    bool insertOnRight;
    bool insertWithNewKey;
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(sz);    
    std::vector<boost::uint8_t> expectedNewHiKey(sz, 0x08);    
    copy.SplitRight(right, &split_key[0], split_key.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                    &loKey[0], &hiKey[0], 
                    &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(!insertOnRight);
    BOOST_REQUIRE(!insertWithNewKey);
    BOOST_REQUIRE(0 == memcmp(&newHiKey[0], &expectedNewHiKey[0], sz));
    BOOST_REQUIRE(search.Iterator == copy.end());
    BOOST_REQUIRE(search.Iterator == copy.begin()+1);
    BOOST_REQUIRE(copy.GetNumRecords() == 1);
    BOOST_REQUIRE(right.GetNumRecords() == 2);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(4));
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    result = copy.Insert(search.Iterator, &split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(6));
    BOOST_REQUIRE(result);
    BOOST_REQUIRE(copy.GetNumRecords() == 2);
    for(BPlusTreeNonLeafPage::Keys::iterator it = copy.GetKeys().begin();
        it != copy.GetKeys().end();
        it++)
    {
      std::vector<boost::uint8_t> key(sz, 0x04 + boost::uint8_t(2*(it - copy.GetKeys().begin())));
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = copy.GetValues(sz).begin();
        it != copy.GetValues(sz).end();
        it++)
    {
      boost::uint8_t expectedValues[] = {0,4,6};
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(expectedValues[it - copy.GetValues(sz).begin()]));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(6));
    for(BPlusTreeNonLeafPage::Keys::iterator it = right.GetKeys().begin();
        it != right.GetKeys().end();
        it++)
    {
      std::vector<boost::uint8_t> key(sz, 0x08 + boost::uint8_t(4*(it - right.GetKeys().begin() + 1)));
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = right.GetValues(sz).begin();
        it != right.GetValues(sz).end();
        it++)
    {
      boost::uint8_t expectedValues[] = {8,12,16};
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(expectedValues[it - right.GetValues(sz).begin()]));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
  }
  {
    // Split page 8 with hi key 12.  New page is 10.  New high key for page 8 is 10.
    // High key for page 10 is 12.
    // Result:
    // [0 4 4 8 8 ] [10 12 12 16 16] Num Rec = 2, Num Rec = 2
    // this means that prior to the insert of <10,10> we look like:
    // [0 4 4 8 8 ](10) [12 16 16]
    // This also means that we are invoking that wierd code that modifies
    // the split_key during SplitRight.  
    BPlusTreeNonLeafPage copy(page);
    std::vector<boost::uint8_t> split_key(sz, 0x0a);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    bool result = copy.Insert(&split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(2));
    BOOST_REQUIRE(!result);
    BPlusTreeNonLeafPage::SearchState search;
    copy.Search(&split_key[0], split_key.size(), search);    
    bool insertOnRight;
    bool insertWithNewKey;
    BPlusTreeNonLeafPage right;
    std::vector<boost::uint8_t> newHiKey(sz);    
    std::vector<boost::uint8_t> expectedNewHiKey(sz, 0x0a);    
    std::vector<boost::uint8_t> expectedSplitKey(sz, 0x0c);    
    copy.SplitRight(right, &split_key[0], split_key.size(), sizeof(BPlusTreeNonLeafPage::pageid_t),
                    &loKey[0], &hiKey[0], 
                    &newHiKey[0], search.Iterator, insertOnRight, insertWithNewKey);
    BOOST_REQUIRE(insertOnRight);
    BOOST_REQUIRE(insertWithNewKey);
    BOOST_REQUIRE(0 == memcmp(&newHiKey[0], &expectedNewHiKey[0], sz));
    BOOST_REQUIRE(0 == memcmp(&split_key[0], &expectedSplitKey[0], sz));
    BOOST_REQUIRE(search.Iterator == right.begin());
    BOOST_REQUIRE(copy.GetNumRecords() == 2);
    BOOST_REQUIRE(right.GetNumRecords() == 1);
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(8));
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
    result = right.InsertWithNewKey(search.Iterator, &split_key[0], split_key.size(), reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(10));
    BOOST_REQUIRE(result);
    BOOST_REQUIRE(right.GetNumRecords() == 2);
    for(BPlusTreeNonLeafPage::Keys::iterator it = copy.GetKeys().begin();
        it != copy.GetKeys().end();
        it++)
    {
      boost::uint8_t expectedKeys[] = {4, 8};
      std::vector<boost::uint8_t> key(sz, expectedKeys[it - copy.GetKeys().begin()]);
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = copy.GetValues(sz).begin();
        it != copy.GetValues(sz).end();
        it++)
    {
      boost::uint8_t expectedValues[] = {0,4,8};
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(expectedValues[it - copy.GetValues(sz).begin()]));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(copy.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(8));
    for(BPlusTreeNonLeafPage::Keys::iterator it = right.GetKeys().begin();
        it != right.GetKeys().end();
        it++)
    {
      boost::uint8_t expectedKeys[] = {12, 16};
      std::vector<boost::uint8_t> key(sz, expectedKeys[it - right.GetKeys().begin()]);
      BOOST_REQUIRE(0 == memcmp(&*it, &key[0], sz));
    }
    for(BPlusTreeNonLeafPage::Values::iterator it = right.GetValues(sz).begin();
        it != right.GetValues(sz).end();
        it++)
    {
      boost::uint8_t expectedValues[] = {10,12,16};
      BPlusTreeNonLeafPage::pageid_t expected(reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(expectedValues[it - right.GetValues(sz).begin()]));
      BOOST_REQUIRE(*it == expected);
    }
    BOOST_REQUIRE(right.GetLastPage() == reinterpret_cast<BPlusTreeNonLeafPage::pageid_t>(16));
  }
}

void TestBPlusTreeSplitRoot()
{
  std::size_t sz(239);
  BPlusTree tree(sz);

  boost::uint32_t numKeys = 5;
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x04*i);
    tree.Insert(&vec[0], vec.size(), &vec[0], 4);
  }
  
  // Search to make sure everything is there.
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x04*i);
    BPlusTree::SearchState search;
    tree.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.GetComparison() == 0);
    BOOST_REQUIRE(0 == memcmp(&vec[0], tree.GetKey(search), vec.size()));
    BOOST_REQUIRE(0 == memcmp(&vec[0], tree.GetValue(search), 4));
  }
  // Search to make sure things that aren't there detected.
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x04*i-1);
    std::vector<boost::uint8_t> expected(sz, 0x04*i);
    BPlusTree::SearchState search;
    tree.Search(&vec[0], vec.size(), search);
    if (i != 4)
    {
      BOOST_REQUIRE(search.GetComparison() == 1);
      BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetKey(search), expected.size()));
      BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetValue(search), 4));
    }
    else
    {
      // Hi key for left page is 16, so search goes left and 
      // hits EOF on the page.
      BOOST_REQUIRE(search.GetComparison() == -1);
    }
  }
  // Search to make sure things that aren't there detected.
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x04*i-1);
    std::vector<boost::uint8_t> expected(sz, 0x04*i);
    BPlusTree::SearchState search;
    tree.SearchNext(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.GetComparison() == 1);
    BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetKey(search), expected.size()));
    BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetValue(search), 4));
  }
}

void TestBPlusTreeGrowTreeEvenNumberOfKeys()
{
  std::size_t sz(239);
  BPlusTree tree(sz);

  // Key size = 239
  // Value size = 4
  // Ptr size = 4 
  // => 5 pages per non-leaf
  // => 4 <key,values> per leaf
  // 
  // This means we grow the first time at the 5th insert
  // and we grow the second time by the 21st insert
  // and we grow the third time by the 101st insert.
  boost::uint32_t numKeys = 102;
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x02*i);
    tree.Insert(&vec[0], vec.size(), &vec[0], 4);
  }
  
//   tree.Dump(std::cout, 4);
  // Search to make sure everything is there.
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x02*i);
    BPlusTree::SearchState search;
    tree.Search(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.GetComparison() == 0);
    BOOST_REQUIRE(0 == memcmp(&vec[0], tree.GetKey(search), vec.size()));
    BOOST_REQUIRE(0 == memcmp(&vec[0], tree.GetValue(search), 4));
  }
  // Search to make sure things that aren't there detected.
  for(boost::uint8_t i=1; i<=numKeys; i++)
  {
    std::vector<boost::uint8_t> vec(sz, 0x02*i-1);
    std::vector<boost::uint8_t> expected(sz, 0x02*i);
    BPlusTree::SearchState search;
    tree.SearchNext(&vec[0], vec.size(), search);
    BOOST_REQUIRE(search.GetComparison() == 1);
    BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetKey(search), expected.size()));
    BOOST_REQUIRE(0 == memcmp(&expected[0], tree.GetValue(search), 4));
  }
}

void TestAggregateExpressionParser()
{
  AggregateExpressionParser agg;
  boost::spirit::classic::tree_parse_info<> info = boost::spirit::classic::ast_parse("SUM(%%A%%)", 
                                                                   agg, 
                                                                   boost::spirit::classic::space_p);
  
  // Provide the variables to bind to.
  std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> > paramToProperty;
  paramToProperty["%%A%%"] = std::make_pair("input", MTPipelineLib::PROP_TYPE_DECIMAL);
  IncrementalInitializeAlgorithm initializer;
  initializer.generate(info, paramToProperty, "output");
  IncrementalUpdateAlgorithm updater;
  updater.generate(info, paramToProperty, "output");  
  std::cout << initializer.initialize() << std::endl;
  std::cout << updater.update() << std::endl;
}

void TestAggregateExpressionParserMultipleCountersMultipleProductViews()
{
  std::vector<AggregateExpressionSpec> exprs;
  exprs.push_back(AggregateExpressionSpec());
  exprs.back().Output = "output_1";
  exprs.back().Expression = "SUM(%%A%%)+SUM(%%B%%)";
  exprs.back().Binding["a"] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
  exprs.back().Binding["a"]["%%A%%"] = std::make_pair("a_A", MTPipelineLib::PROP_TYPE_DECIMAL);
  exprs.back().Binding["b"] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
  exprs.back().Binding["b"]["%%B%%"] = std::make_pair("b_A", MTPipelineLib::PROP_TYPE_BIGINTEGER);
  exprs.push_back(AggregateExpressionSpec());
  exprs.back().Output = "output_2";
  exprs.back().Expression = "SUM(%%C%%)+SUM(%%D%%)";
  exprs.back().Binding["a"] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
  exprs.back().Binding["a"]["%%C%%"] = std::make_pair("a_B", MTPipelineLib::PROP_TYPE_INTEGER);
  exprs.back().Binding["b"] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
  exprs.back().Binding["b"]["%%D%%"] = std::make_pair("b_B", MTPipelineLib::PROP_TYPE_DECIMAL);

  IncrementalAggregateExpression incremental(exprs);
  std::string i = incremental.initialize();
  std::string u1 = incremental.update("a");
  std::string u2 = incremental.update("b");

  std::cout << i << std::endl;
  std::cout << u1 << std::endl;
  std::cout << u2 << std::endl;
}

void TestLongHash()
{
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  RecordMetadata recordA(logicalA);
  record_t bufferA = recordA.Allocate();

  recordA.GetColumn(L"a")->SetLongValue(bufferA, 1053);
  unsigned int aHash = recordA.GetColumn(L"a")->Hash(bufferA, 0);
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 1054);
  unsigned int bHash = recordA.GetColumn(L"a")->Hash(bufferA, 0);
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 1055);
  unsigned int cHash = recordA.GetColumn(L"a")->Hash(bufferA, 0);
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 1056);
  unsigned int dHash = recordA.GetColumn(L"a")->Hash(bufferA, 0);

  recordA.Free(bufferA);
}

void Test_UTF8_String_Literal_UTF8_Null_Terminated()
{
  UTF8_String_Literal_UTF8_Null_Terminated importer("abc");

  char inputBuffer [] = "abc";
  std::size_t inputConsumed=0;
  char outputBuffer [3];
  std::size_t outputConsumed=0;
  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(3, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('b', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('c', outputBuffer[2]);

  // Two calls with short input
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(1, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('f', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('f', outputBuffer[2]);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 2, inputConsumed,
                      (boost::uint8_t *)(outputBuffer+1), 2, outputConsumed);

  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(2, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('b', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('c', outputBuffer[2]);

  // Two calls with short output
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 1, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_TARGET_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(1, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('f', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('f', outputBuffer[2]);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 2, inputConsumed,
                      (boost::uint8_t *)(outputBuffer+1), 2, outputConsumed);

  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(2, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('b', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('c', outputBuffer[2]);

  // Failure on third value
  inputBuffer[2] = 'z';
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  // Check that internal state is reset so we can import 
  inputBuffer[2] = 'c';
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(3, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('b', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('c', outputBuffer[2]);
  // Failure on third value short input
  inputBuffer[2] = 'z';
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 2, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(2, outputConsumed);
  BOOST_REQUIRE_EQUAL('a', outputBuffer[0]);
  BOOST_REQUIRE_EQUAL('b', outputBuffer[1]);
  BOOST_REQUIRE_EQUAL('f', outputBuffer[2]);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+2), 1, inputConsumed,
                      (boost::uint8_t *) (outputBuffer+2), 1, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, r);
  // Check that internal state is reset so we can import 
  inputBuffer[2] = 'c';
  outputBuffer[0] = outputBuffer[1] = outputBuffer[2] = 'f';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
}

void Test_UTF8_Base10_Signed_Integer_Int32_Negative_Input()
{
  UTF8_Base10_Signed_Integer_Int32 importer;

  char inputBuffer [] = "-1992;";
  boost::int32_t value;
  boost::uint8_t * outputBuffer = (boost::uint8_t *) &value;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;

  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(-1992, value);
  // Two calls: short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+3), 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(-1992, value);
  // Two calls: short output
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(6, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(-1992, value);
  // Three calls: short output & short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+5), 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(-1992, value);
  // Two calls: short input just negative sign
  r = importer.Import((const boost::uint8_t *) inputBuffer, 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(4, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(-1992, value);
}

void Test_UTF8_Base10_Signed_Integer_Int32_Plus_Sign()
{
  UTF8_Base10_Signed_Integer_Int32 importer;

  char inputBuffer [] = "+1992;";
  boost::int32_t value;
  boost::uint8_t * outputBuffer = (boost::uint8_t *) &value;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;

  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(1992, value);
  // Two calls: short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+3), 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(1992, value);
  // Two calls: short output
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(6, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(1992, value);
  // Three calls: short output & short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+5), 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(1992, value);
  // Two calls: short input just negative sign
  r = importer.Import((const boost::uint8_t *) inputBuffer, 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(4, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(1992, value);
}

void Test_UTF8_Base10_Signed_Integer_Int32_Positive_Input()
{
  UTF8_Base10_Signed_Integer_Int32 importer;

  char inputBuffer [] = "19926;";
  boost::int32_t value;
  boost::uint8_t * outputBuffer = (boost::uint8_t *) &value;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;

  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926, value);
  // Two calls: short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+3), 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926, value);
  // Two calls: short output
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(6, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926, value);
  // Three calls: short output & short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+5), 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926, value);
}

void Test_UTF8_Base10_Signed_Integer_Int32_Parse_Errors()
{
  UTF8_Base10_Signed_Integer_Int32 importer;

  char inputBuffer [] = ";9923;";
  boost::int32_t value;
  boost::uint8_t * outputBuffer = (boost::uint8_t *) &value;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(4, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(9923, value);

  inputBuffer[0] = '-';
  inputBuffer[1] = ';';
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+2), 4, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(4, outputConsumed);
  BOOST_REQUIRE_EQUAL(923, value);

  // Failure on continuation
  r = importer.Import((const boost::uint8_t *) inputBuffer, 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(1, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+1), 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 4, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
}

void Test_UTF8_Base10_Signed_Integer_Int64_Positive_Input()
{
  UTF8_Base10_Signed_Integer_Int64 importer;

  char inputBuffer [] = "19926;";
  boost::int64_t value;
  boost::uint8_t * outputBuffer = (boost::uint8_t *) &value;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;

  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926LL, value);
  // Two calls: short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+3), 3, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(2, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926LL, value);
  // Two calls: short output
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(6, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 6, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926LL, value);
  // Three calls: short output & short input
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 3, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(0, outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+5), 1, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 8, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(8, outputConsumed);
  BOOST_REQUIRE_EQUAL(19926LL, value);
}

void Test_UTF8_Terminated_UTF16_Null_Terminated()
{
  // TODO: Use ICU
  UTF8_Terminated_UTF16_Null_Terminated importer(std::string(1,'|'));
  char inputBuffer [] = "I am a UTF8 String|I am also a UTF8 String";
  wchar_t outputBuffer[255];
  wchar_t expected [] = L"I am a UTF8 String";
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 20, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, 255*sizeof(wchar_t), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(18, inputConsumed);
  BOOST_REQUIRE_EQUAL(19*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(0, memcmp(outputBuffer, expected, wcslen(expected)));

  // Two invocations: short input
  memset(outputBuffer, 0, 255*sizeof(wchar_t));
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 255*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(5, inputConsumed);
  BOOST_REQUIRE_EQUAL(5*sizeof(wchar_t), outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+5), 15, inputConsumed,
                      (boost::uint8_t *) (outputBuffer+5), 250*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(13, inputConsumed);
  BOOST_REQUIRE_EQUAL(14*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(0, memcmp(outputBuffer, expected, wcslen(expected)));

  // Two invocations: short output
  memset(outputBuffer, 0, 255*sizeof(wchar_t));
  r = importer.Import((const boost::uint8_t *) inputBuffer, 20, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 15*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_TARGET_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(15, inputConsumed);
  BOOST_REQUIRE_EQUAL(15*sizeof(wchar_t), outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+15), 5, inputConsumed,
                      (boost::uint8_t *) (outputBuffer+15), 240*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(3, inputConsumed);
  BOOST_REQUIRE_EQUAL(4*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(0, memcmp(outputBuffer, expected, wcslen(expected)));

  // Two invocations: short output exactly on null terminator
  memset(outputBuffer, 0, 255*sizeof(wchar_t));
  r = importer.Import((const boost::uint8_t *) inputBuffer, 20, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 18*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_TARGET_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(18, inputConsumed);
  BOOST_REQUIRE_EQUAL(18*sizeof(wchar_t), outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer+18), 1, inputConsumed,
                      (boost::uint8_t *) (outputBuffer+18), 237*sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(0, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(wchar_t), outputConsumed);
  BOOST_REQUIRE_EQUAL(0, memcmp(outputBuffer, expected, wcslen(expected)));
}

void Test_ISO8601_DateTime_AM()
{
  ISO8601_DateTime importer;
  char inputBuffer [] = "2007-01-31 10:32:55 AM";
  date_time_traits::value output;
  boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 22, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, sizeof(date_time_traits::value), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);

#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDate(output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  std::string expected("1/31/2007 10:32:55 AM");
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, expected.c_str()));
#endif

  // Two invocations: short input
  memset(outputBuffer, 0, sizeof(date_time_traits::value));
  r = importer.Import((const boost::uint8_t *) inputBuffer, 5, inputConsumed,
                      (boost::uint8_t *)outputBuffer, sizeof(date_time_traits::value), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer), 22, inputConsumed,
                      (boost::uint8_t *) (outputBuffer), sizeof(date_time_traits::value), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);

  // Two invocations: short output
  memset(outputBuffer, 0, sizeof(date_time_traits::value));
  r = importer.Import((const boost::uint8_t *) inputBuffer, 22, inputConsumed,
                      (boost::uint8_t *)outputBuffer, 1, outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_BUFFER_OPEN, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);
  r = importer.Import((const boost::uint8_t *) (inputBuffer), 22, inputConsumed,
                      (boost::uint8_t *) (outputBuffer), sizeof(date_time_traits::value), outputConsumed);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);
}

void Test_ISO8601_DateTime_PM()
{
  ISO8601_DateTime importer;
  char inputBuffer [] = "2007-01-31 10:32:55 PM";
  date_time_traits::value output;
  boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 22, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, sizeof(date_time_traits::value), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), outputConsumed);

#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDate(output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  std::string expected("1/31/2007 10:32:55 PM");
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, expected.c_str()));
#endif
}

void Test_UTF8_Base10_Decimal_DECIMAL_9_Digits()
{
  UTF8_Base10_Decimal_DECIMAL importer;
  char inputBuffer [] = "9993.23432;";
  decimal_traits::value output;
  boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 11, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, sizeof(decimal_traits::value), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(10, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(decimal_traits::value), outputConsumed);
#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDec(&output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, "9993.23432"));
#else
  std::string val;
  decimal_traits::to_string(&output, val);
  BOOST_REQUIRE_EQUAL(0, strcmp("9993.23432", val.c_str()));
#endif
}

void Test_UTF8_Base10_Decimal_DECIMAL_16_Digits()
{
  UTF8_Base10_Decimal_DECIMAL importer;
  char inputBuffer [] = "999398.2343283642;";
  decimal_traits::value output;
  boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 18, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, sizeof(decimal_traits::value), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(17, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(decimal_traits::value), outputConsumed);
#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDec(&output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, "999398.2343283642"));
#else
  std::string val;
  decimal_traits::to_string(&output, val);
  BOOST_REQUIRE_EQUAL(0, strcmp("999398.2343283642", val.c_str()));
#endif
}

void Test_UTF8_Base10_Decimal_DECIMAL_24_Digits()
{
  UTF8_Base10_Decimal_DECIMAL importer;
  char inputBuffer [] = "9243199398.23431234283642;";
  decimal_traits::value output;
  boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
  std::size_t inputConsumed=0;
  std::size_t outputConsumed=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 26, inputConsumed,
                                              (boost::uint8_t *)outputBuffer, sizeof(decimal_traits::value), outputConsumed);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(25, inputConsumed);
  BOOST_REQUIRE_EQUAL(sizeof(decimal_traits::value), outputConsumed);
#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDec(&output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, "9243199398.23431234283642"));
#else
  std::string val;
  decimal_traits::to_string(&output, val);
  BOOST_REQUIRE_EQUAL(0, strcmp("9243199398.23431234283642", val.c_str()));
#endif
}

// void Test_UTF8_Base10_Decimal_DECIMAL_32_Digits()
// {
//   UTF8_Base10_Decimal_DECIMAL importer;
//   char inputBuffer [] = "92431993912338.234312342836123342;";
//   decimal_traits::value output;
//   boost::uint8_t * outputBuffer = (boost::uint8_t *)&output;
//   std::size_t inputConsumed=0;
//   std::size_t outputConsumed=0;
//   // Simple cases: one call with complete buffers.
//   ParseDescriptor::Result r = importer.Import((const boost::uint8_t *) inputBuffer, 34, inputConsumed,
//                                               (boost::uint8_t *)outputBuffer, sizeof(decimal_traits::value), outputConsumed);
  
//   BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
//   BOOST_REQUIRE_EQUAL(33, inputConsumed);
//   BOOST_REQUIRE_EQUAL(sizeof(decimal_traits::value), outputConsumed);
// #ifdef WIN32
//   BSTR bstrVal;
//   ::VarBstrFromDec(&output, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
//   // Use a _bstr_t to delete the BSTR
//   _bstr_t bstrtVal(bstrVal, false);
//   BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, "92431993912338.234312342836123342"));
// #else
//   std::string val;
//   decimal_traits::to_string(&output, val);
//   BOOST_REQUIRE_EQUAL(0, strcmp("92431993912338.234312342836123342", val.c_str()));
// #endif
// }

void Test_Direct_Field_Importer_Int32()
{
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  RecordMetadata recordA(logicalA);
  Direct_Field_Importer<UTF8_Base10_Signed_Integer_Int32> importer(UTF8_Base10_Signed_Integer_Int32(),
                                                                   *recordA.GetColumn(0));

  record_t recordBuffer = recordA.Allocate();
  char sourceBuffer [] = "19926;";
  const boost::uint8_t * inputBuffer = (const boost::uint8_t *) sourceBuffer;
  std::size_t inputRequired=0;

  // Simple case: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import(inputBuffer, inputBuffer+6, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  BOOST_REQUIRE_EQUAL(19926, recordA.GetColumn(L"a")->GetLongValue(recordBuffer));

  // Two calls with short read

  // Reinit
  inputBuffer = (const boost::uint8_t *) sourceBuffer;
  recordA.GetColumn(L"a")->SetNull(recordBuffer);

  r = importer.Import(inputBuffer, inputBuffer+3, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  r = importer.Import((const boost::uint8_t *) (inputBuffer), inputBuffer+3, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(5, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  BOOST_REQUIRE_EQUAL(19926, recordA.GetColumn(L"a")->GetLongValue(recordBuffer));

  recordA.Free(recordBuffer);
}

void Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated()
{
  // TODO: Use ICU
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  UTF8_Terminated_UTF16_Null_Terminated baseImporter(std::string(1,'|'));

  Field_Action_Importer<UTF8_Terminated_UTF16_Null_Terminated, Set_Value_Action_Type> importer(baseImporter,
                                                                                               *recordA.GetColumn(0));

  record_t recordBuffer = recordA.Allocate();

  char sourceBuffer [] = "I am a UTF8 String|I am also a UTF8 String";
  const boost::uint8_t * inputBuffer = (const boost::uint8_t *) sourceBuffer;
  wchar_t expected [] = L"I am a UTF8 String";
  std::size_t inputRequired=0;
  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import(inputBuffer, inputBuffer+20, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(18, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  BOOST_REQUIRE_EQUAL(0, wcscmp(expected, recordA.GetColumn(L"a")->GetStringValue(recordBuffer)));

  // Two calls with short read

  // Reinit
  inputBuffer = (const boost::uint8_t *) sourceBuffer;
  recordA.GetColumn(L"a")->SetNull(recordBuffer);

  r = importer.Import(inputBuffer, inputBuffer+3, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_SOURCE_EXHAUSTED, r);
  BOOST_REQUIRE_EQUAL(3, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  r = importer.Import((const boost::uint8_t *) (inputBuffer), inputBuffer+17, inputRequired, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(18, inputBuffer - (const boost::uint8_t *)sourceBuffer);
  BOOST_REQUIRE_EQUAL(0, wcscmp(expected, recordA.GetColumn(L"a")->GetStringValue(recordBuffer)));

  recordA.Free(recordBuffer);
}

void TestInt32RangePartitioner()
{
  std::vector<boost::int32_t> ranges;
  ranges.push_back(10343);
  ranges.push_back(77234);
  ranges.push_back(0);

  std::sort(ranges.begin(), ranges.end());

  std::vector<boost::int32_t>::iterator where = std::lower_bound(ranges.begin(), ranges.end(), 11000);
  BOOST_REQUIRE_EQUAL(2, where-ranges.begin());
  where = std::lower_bound(ranges.begin(), ranges.end(), -1);
  BOOST_REQUIRE_EQUAL(0, where-ranges.begin());
  where = std::lower_bound(ranges.begin(), ranges.end(), 10);
  BOOST_REQUIRE_EQUAL(1, where-ranges.begin());
  where = std::lower_bound(ranges.begin(), ranges.end(), 10343);
  BOOST_REQUIRE_EQUAL(1, where-ranges.begin());
  where = std::upper_bound(ranges.begin(), ranges.end(), 10343);
  BOOST_REQUIRE_EQUAL(2, where-ranges.begin());
}

void TestImporterSpecification()
{
  UTF8StringBufferImporter myRec(L"myRec "
                                L"VARCHAR = text_delimited_varchar(null_value=' ', delimiter='|') "
                                L"NVARCHAR = text_delimited_nvarchar(null_value=' ', delimiter='|') "
                                L"INTEGER = text_delimited_base10_int32(delimiter='|') "
                                L"(a INTEGER, b VARCHAR, c NVARCHAR)");

  BOOST_REQUIRE_EQUAL(3, myRec.GetMetadata().GetNumColumns());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"a", myRec.GetMetadata().GetColumnName(0).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Integer()==*myRec.GetMetadata().GetColumn(0)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(0)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"b", myRec.GetMetadata().GetColumnName(1).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::UTF8StringDomain()==*myRec.GetMetadata().GetColumn(1)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(1)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"c", myRec.GetMetadata().GetColumnName(2).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::StringDomain()==*myRec.GetMetadata().GetColumn(2)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(2)->IsRequired());

  // TODO: Test importing NULL values.
  
  UTF8StringBufferImporter myRec2(L"myRec ("
                                 L"a text_delimited_base10_int32(delimiter='|'), "
                                 L"b text_delimited_varchar(null_value=' ', delimiter='|'), "
                                 L"c text_delimited_nvarchar(null_value=' ', delimiter='|'))");
}

void TestImportFromSpecificationNonNullable()
{
  std::string errMessage;
  
  UTF8StringBufferImporter myRec(L"myRec ("
                                                 L"a text_delimited_base10_int32(delimiter='|'),\n"
                                                 L"b text_delimited_base10_int64(delimiter='|'),\n"
                                                 L"c text_delimited_base10_decimal(delimiter='|'),\n"
                                                 L"d text_delimited_varchar(delimiter='|'),\n"
                                                 L"e text_delimited_nvarchar(delimiter='|'),\n"
                                                 L"f iso8601_datetime(delimiter='|'),\n"
                                                 L"g text_delimited_enum(enum_space='Global', enum_type='CountryName', delimiter='\n')"
                                                 L")");
  BOOST_REQUIRE_EQUAL(7, myRec.GetMetadata().GetNumColumns());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"a", myRec.GetMetadata().GetColumnName(0).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Integer()==*myRec.GetMetadata().GetColumn(0)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(0)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"b", myRec.GetMetadata().GetColumnName(1).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::BigInteger()==*myRec.GetMetadata().GetColumn(1)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(1)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"c", myRec.GetMetadata().GetColumnName(2).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Decimal()==*myRec.GetMetadata().GetColumn(2)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(2)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"d", myRec.GetMetadata().GetColumnName(3).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::UTF8StringDomain()==*myRec.GetMetadata().GetColumn(3)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(3)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"e", myRec.GetMetadata().GetColumnName(4).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::StringDomain()==*myRec.GetMetadata().GetColumn(4)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(4)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"f", myRec.GetMetadata().GetColumnName(5).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Datetime()==*myRec.GetMetadata().GetColumn(5)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(5)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"g", myRec.GetMetadata().GetColumnName(6).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Enum()==*myRec.GetMetadata().GetColumn(6)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(6)->IsRequired());

  // Countries: Afghanistan, Burkina Faso, Guatemala, Kenya
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Afghanistan'"));
  rs->Next();
  boost::int32_t afghanistan=rs->GetInteger(1);
  rs->Close();
  rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Burkina Faso'"));
  rs->Next();
  boost::int32_t burkinaFaso=rs->GetInteger(1);

  // Run the test with a variety of windows and granularities.
  for(std::size_t granularity=1; granularity<=100; granularity++)
  {
    for(std::size_t view=1; view<=100; view++)
    {

      PagedBuffer sourceBuffer( 
        "1111111|-199288234234234|88223.2343|utf8 string to varchar1|utf8 string to nvarchar1|2007-01-01 12:59:59 PM|2\n"
        "1111112|-199388234234234|88223.2343|utf8 string to varchar2|utf8 string to nvarchar2|2007-01-02 12:59:59 AM|34\n"
        "1111113|-199488234234234|88223.2343|utf8 string to varchar3|utf8 string to nvarchar3|2007-01-03 12:59:59 PM|87\n"
        "1111114|-199588234234234|88223.2343|utf8 string to varchar4|utf8 string to nvarchar4|2007-01-04 12:59:50 AM|107\n", granularity);
      PagedParseBuffer<PagedBuffer> buffer(sourceBuffer, view);
      // TODO: Test importing NULL values.
  
      record_t recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE(recordBuffer != NULL);
      BOOST_REQUIRE_EQUAL(1111111, myRec.GetMetadata().GetColumn(L"a")->GetLongValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(-199288234234234LL, myRec.GetMetadata().GetColumn(L"b")->GetBigIntegerValue(recordBuffer));

      BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar1", myRec.GetMetadata().GetColumn(L"d")->GetUTF8StringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar1", myRec.GetMetadata().GetColumn(L"e")->GetStringValue(recordBuffer)));
      {
#ifdef WIN32
      DATE dt1;
      ::VarDateFromStr(L"1/1/2007 12:59:59 PM", LOCALE_SYSTEM_DEFAULT, 0, &dt1);
      BOOST_REQUIRE_EQUAL(dt1, myRec.GetMetadata().GetColumn(L"f")->GetDatetimeValue(recordBuffer));
#else
      datetime_traits::value dt1;
      datetime_traits::from_string("1/1/2007 12:59:59 PM", &dt1);
      BOOST_REQUIRE_EQUAL(dt1, myRec.GetMetadata().GetColumn(L"f")->GetDatetimeValue(recordBuffer));
#endif
      }
      BOOST_REQUIRE_EQUAL(afghanistan, myRec.GetMetadata().GetColumn(L"g")->GetEnumValue(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);

      recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE_EQUAL(1111112, myRec.GetMetadata().GetColumn(L"a")->GetLongValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(-199388234234234LL, myRec.GetMetadata().GetColumn(L"b")->GetBigIntegerValue(recordBuffer));

      BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar2", myRec.GetMetadata().GetColumn(L"d")->GetUTF8StringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar2", myRec.GetMetadata().GetColumn(L"e")->GetStringValue(recordBuffer)));
      {
#ifdef WIN32
      DATE dt1;
      ::VarDateFromStr(L"1/2/2007 12:59:59 AM", LOCALE_SYSTEM_DEFAULT, 0, &dt1);
      BOOST_REQUIRE_EQUAL(dt1, myRec.GetMetadata().GetColumn(L"f")->GetDatetimeValue(recordBuffer));
#else
      datetime_traits::value dt1;
      datetime_traits::from_string("1/2/2007 12:59:59 AM", &dt1);
      BOOST_REQUIRE_EQUAL(dt1, myRec.GetMetadata().GetColumn(L"f")->GetDatetimeValue(recordBuffer));
#endif
      }
      BOOST_REQUIRE_EQUAL(burkinaFaso, myRec.GetMetadata().GetColumn(L"g")->GetEnumValue(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);
    }
  }
}

void TestImportFromSpecificationNullable()
{
  std::string errMessage;
  
  UTF8StringBufferImporter myRec(L"myRec ("
                                 L"a text_delimited_base10_int32(delimiter='|', null_value='-'),\n"
                                 L"b text_delimited_base10_int64(delimiter='|', null_value='-'),\n"
                                 L"c text_delimited_base10_decimal(delimiter='|', null_value='-'),\n"
                                 L"d text_delimited_varchar(delimiter='|', null_value='-'),\n"
                                 L"e text_delimited_nvarchar(delimiter='|', null_value='-'),\n"
                                 L"f iso8601_datetime(delimiter='|', null_value='-'),\n"
                                 L"g text_delimited_enum(enum_space='Global', enum_type='CountryName', delimiter='\n', null_value='-')"
                                 L")");
  BOOST_REQUIRE_EQUAL(7, myRec.GetMetadata().GetNumColumns());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"a", myRec.GetMetadata().GetColumnName(0).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Integer()==*myRec.GetMetadata().GetColumn(0)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(0)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"b", myRec.GetMetadata().GetColumnName(1).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::BigInteger()==*myRec.GetMetadata().GetColumn(1)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(1)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"c", myRec.GetMetadata().GetColumnName(2).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Decimal()==*myRec.GetMetadata().GetColumn(2)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(2)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"d", myRec.GetMetadata().GetColumnName(3).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::UTF8StringDomain()==*myRec.GetMetadata().GetColumn(3)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(3)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"e", myRec.GetMetadata().GetColumnName(4).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::StringDomain()==*myRec.GetMetadata().GetColumn(4)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(4)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"f", myRec.GetMetadata().GetColumnName(5).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Datetime()==*myRec.GetMetadata().GetColumn(5)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(5)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"g", myRec.GetMetadata().GetColumnName(6).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Enum()==*myRec.GetMetadata().GetColumn(6)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(6)->IsRequired());

  // Countries: Afghanistan, Burkina Faso, Guatemala, Kenya
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Afghanistan'"));
  rs->Next();
  boost::int32_t afghanistan=rs->GetInteger(1);
  rs->Close();
  rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Burkina Faso'"));
  rs->Next();
  boost::int32_t burkinaFaso=rs->GetInteger(1);

  // Run the test with a variety of windows and granularities.
  for(std::size_t granularity=1; granularity<=100; granularity++)
  {
    for(std::size_t view=1; view<=100; view++)
    {

      PagedBuffer sourceBuffer( 
        "-|-199288234234234|-|utf8 string to varchar1|-|2007-01-01 12:59:59 PM|-\n"
        "1111112|-|88223.2343|-|utf8 string to nvarchar2|-|34\n"
        "1111113|-199488234234234|88223.2343|utf8 string to varchar3|utf8 string to nvarchar3|2007-01-03 12:59:59 PM|87\n"
        "1111114|-199588234234234|88223.2343|utf8 string to varchar4|utf8 string to nvarchar4|-|107\n", granularity);
      PagedParseBuffer<PagedBuffer> buffer(sourceBuffer, view);
  
      record_t recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE(recordBuffer != NULL);
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"a")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(-199288234234234LL, myRec.GetMetadata().GetColumn(L"b")->GetBigIntegerValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"c")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar1", myRec.GetMetadata().GetColumn(L"d")->GetUTF8StringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"e")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(L"f")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"g")->GetNull(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);

      recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE_EQUAL(1111112, myRec.GetMetadata().GetColumn(L"a")->GetLongValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"b")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(false, myRec.GetMetadata().GetColumn(L"c")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"d")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar2", myRec.GetMetadata().GetColumn(L"e")->GetStringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(L"f")->GetNull(recordBuffer));
      BOOST_REQUIRE_EQUAL(burkinaFaso, myRec.GetMetadata().GetColumn(L"g")->GetEnumValue(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);
    }
  }
}

void TestImportFromSpecificationNonNullableMultiCharTerminator()
{
  std::string errMessage;
  
  UTF8StringBufferImporter myRec(L"myRec ("
                                                 L"a text_delimited_base10_int32(delimiter='|'),\n"
                                                 L"b text_delimited_base10_int64(delimiter='|'),\n"
                                                 L"c text_delimited_base10_decimal(delimiter='|'),\n"
                                                 L"d text_delimited_varchar(delimiter='|'),\n"
                                                 L"e text_delimited_nvarchar(delimiter='|,@'),\n"
                                                 L"f iso8601_datetime(delimiter='|'),\n"
                                                 L"g text_delimited_enum(enum_space='Global', enum_type='CountryName', delimiter=crlf)"
                                                 L")");
  BOOST_REQUIRE_EQUAL(7, myRec.GetMetadata().GetNumColumns());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"a", myRec.GetMetadata().GetColumnName(0).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Integer()==*myRec.GetMetadata().GetColumn(0)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(0)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"b", myRec.GetMetadata().GetColumnName(1).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::BigInteger()==*myRec.GetMetadata().GetColumn(1)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(1)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"c", myRec.GetMetadata().GetColumnName(2).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Decimal()==*myRec.GetMetadata().GetColumn(2)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(2)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"d", myRec.GetMetadata().GetColumnName(3).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::UTF8StringDomain()==*myRec.GetMetadata().GetColumn(3)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(3)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"e", myRec.GetMetadata().GetColumnName(4).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::StringDomain()==*myRec.GetMetadata().GetColumn(4)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(4)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"f", myRec.GetMetadata().GetColumnName(5).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Datetime()==*myRec.GetMetadata().GetColumn(5)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(5)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"g", myRec.GetMetadata().GetColumnName(6).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Enum()==*myRec.GetMetadata().GetColumn(6)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(6)->IsRequired());

  // Countries: Afghanistan, Burkina Faso, Guatemala, Kenya
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Afghanistan'"));
  rs->Next();
  boost::int32_t afghanistan=rs->GetInteger(1);
  rs->Close();
  rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Burkina Faso'"));
  rs->Next();
  boost::int32_t burkinaFaso=rs->GetInteger(1);

  // Run the test with a variety of windows and granularities.
  for(std::size_t granularity=1; granularity<=100; granularity++)
  {
    for(std::size_t view=1; view<=100; view++)
    {

      PagedBuffer sourceBuffer( 
        "1111111|-199288234234234|88223.2343|utf8 string to varchar1|utf8 string to nvarchar1|,@2007-01-01 12:59:59 PM|2\r\n"
        "1111112|-199388234234234|88223.2343|utf8 string to varchar2|utf8 string to nvarchar2|,@2007-01-02 12:59:59 PM|34\r\n"
        "1111113|-199488234234234|88223.2343|utf8 string to varchar3|utf8 string to nvarchar3|,@2007-01-03 12:59:59 PM|87\r\n"
        "1111114|-199588234234234|88223.2343|utf8 string to varchar4|utf8 string to nvarchar4|,@2007-01-04 12:59:50 PM|107\r\n", granularity);
      PagedParseBuffer<PagedBuffer> buffer(sourceBuffer, view);
      // TODO: Test importing NULL values.
  
      record_t recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE(recordBuffer != NULL);
      BOOST_REQUIRE_EQUAL(1111111, myRec.GetMetadata().GetColumn(L"a")->GetLongValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(-199288234234234LL, myRec.GetMetadata().GetColumn(L"b")->GetBigIntegerValue(recordBuffer));

      BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar1", myRec.GetMetadata().GetColumn(L"d")->GetUTF8StringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar1", myRec.GetMetadata().GetColumn(L"e")->GetStringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(afghanistan, myRec.GetMetadata().GetColumn(L"g")->GetEnumValue(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);

      recordBuffer = myRec.Import(buffer, errMessage);
      BOOST_REQUIRE_EQUAL(1111112, myRec.GetMetadata().GetColumn(L"a")->GetLongValue(recordBuffer));
      BOOST_REQUIRE_EQUAL(-199388234234234LL, myRec.GetMetadata().GetColumn(L"b")->GetBigIntegerValue(recordBuffer));

      BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar2", myRec.GetMetadata().GetColumn(L"d")->GetUTF8StringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar2", myRec.GetMetadata().GetColumn(L"e")->GetStringValue(recordBuffer)));
      BOOST_REQUIRE_EQUAL(burkinaFaso, myRec.GetMetadata().GetColumn(L"g")->GetEnumValue(recordBuffer));
      myRec.GetMetadata().Free(recordBuffer);
    }
  }
}

void TestDynamicArrayParseBuffer()
{
  DynamicArrayParseBuffer buffer(8);
  BOOST_REQUIRE_EQUAL(0, buffer.size());
  BOOST_REQUIRE_EQUAL(8, buffer.capacity());
  boost::uint8_t expected [] = {0x99, 0x98, 0x98, 0x98, 0x98, 0x97, 0x97, 0x97, 0x97, 0x97, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96, 0x96 }; 
  buffer.put(0x99);
  expected[0] = 0x99;
  BOOST_REQUIRE_EQUAL(1, buffer.size());
  BOOST_REQUIRE_EQUAL(8, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 1));
  boost::uint8_t * ptr;
  // Test open without double buffer.
  BOOST_REQUIRE_EQUAL(true, buffer.open(4, ptr));
  BOOST_REQUIRE_EQUAL(buffer.buffer() + 1, ptr);
  BOOST_REQUIRE_EQUAL(1, buffer.size());
  BOOST_REQUIRE_EQUAL(8, buffer.capacity());
  ptr[0] = ptr[1] = ptr[2] = ptr[3] = 0x98;
  buffer.consume(4);
  BOOST_REQUIRE_EQUAL(5, buffer.size());
  BOOST_REQUIRE_EQUAL(8, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 5));
  // Test open with double buffer.
  BOOST_REQUIRE_EQUAL(true, buffer.open(5, ptr));
  BOOST_REQUIRE_EQUAL(buffer.buffer() + 5, ptr);
  BOOST_REQUIRE_EQUAL(5, buffer.size());
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  ptr[0] = ptr[1] = ptr[2] = ptr[3] = ptr[4] = 0x97;
  buffer.consume(5);
  BOOST_REQUIRE_EQUAL(10, buffer.size());
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 10));
  // Test open with mark/rewind without double buffer
  buffer.mark();
  BOOST_REQUIRE_EQUAL(true, buffer.open(5, ptr));
  BOOST_REQUIRE_EQUAL(buffer.buffer() + 10, ptr);
  BOOST_REQUIRE_EQUAL(10, buffer.size());
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  ptr[0] = ptr[1] = ptr[2] = ptr[3] = ptr[4] = 0x96;
  buffer.consume(5);
  BOOST_REQUIRE_EQUAL(15, buffer.size());
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 15));
  buffer.rewind();
  BOOST_REQUIRE_EQUAL(10, buffer.size());
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 10));
  // Test open with mark/rewind with double buffer
  buffer.mark();
  BOOST_REQUIRE_EQUAL(true, buffer.open(7, ptr));
  BOOST_REQUIRE_EQUAL(buffer.buffer() + 10, ptr);
  BOOST_REQUIRE_EQUAL(10, buffer.size());
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  ptr[0] = ptr[1] = ptr[2] = ptr[3] = ptr[4] = ptr[5] = ptr[6] = 0x96;
  buffer.consume(7);
  BOOST_REQUIRE_EQUAL(17, buffer.size());
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 17));
  buffer.rewind();
  BOOST_REQUIRE_EQUAL(10, buffer.size());
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, memcmp(&expected[0], buffer.buffer(), 10));
  
}

void Test_Export_UTF8_Base10_Signed_Integer_Int32_Positive_Input_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
//   for(std::size_t granularity=1; granularity<=10; granularity++)
//   {
//     for(std::size_t view=1; view<=10; view++)
//     {
//       boost::int32_t value=1882323;
//       FixedArrayParseBuffer input((boost::uint8_t *) &value, ((boost::uint8_t *)&value) + sizeof(boost::int32_t));
//       PagedBuffer pagedFile("aaaaaaaaaaaaaaaaaaaaaa", granularity);
//       PagedParseBuffer<PagedBuffer> pagedOutput(pagedFile, view);
//       UTF8_Base10_Signed_Integer_2<boost::int32_t, FixedArrayParseBuffer, PagedParseBuffer<PagedBuffer> > pagedExporter;
//       BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Export(input, pagedOutput));
//       BOOST_REQUIRE_EQUAL(1882323, value);
//       BOOST_REQUIRE_EQUAL(4, output.size());  
//     }
//   }

  std::string outputBuffer("aaaaaaaaaaaaaaaaa");
  boost::int32_t value=19926;
  UTF8_Base10_Signed_Integer_2<boost::int32_t, FixedArrayParseBuffer, FixedArrayParseBuffer> importer;
  FixedArrayParseBuffer input((boost::uint8_t *) &value, ((boost::uint8_t *)&value) + sizeof(boost::int32_t));
  FixedArrayParseBuffer output(outputBuffer);

  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
  BOOST_REQUIRE_EQUAL(5, output.size());
  BOOST_REQUIRE_EQUAL(0, memcmp("19926", &outputBuffer[0], 5));
  BOOST_REQUIRE_EQUAL(4, input.size());

  input.clear();
  output.clear();

  value = -12933423;
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
  BOOST_REQUIRE_EQUAL(9, output.size());
  BOOST_REQUIRE_EQUAL(0, memcmp("-12933423", &outputBuffer[0], 9));
  BOOST_REQUIRE_EQUAL(4, input.size());
}

void Test_Export_ISO8601_DateTime_AM_2()
{
#ifdef WIN32
  date_time_traits::value inputBuffer;
  FixedArrayParseBuffer input((boost::uint8_t *) &inputBuffer, (boost::uint8_t *) (&inputBuffer+1));
  _bstr_t bstrtVal(L"1/31/2007 10:32:55 AM");
  HRESULT hr = VarDateFromStr(bstrtVal, LOCALE_SYSTEM_DEFAULT, 0, &inputBuffer);

  std::string outputBuffer("aaaaaaaaaaaaaaaaaaaaaaaa");
  FixedArrayParseBuffer output(outputBuffer);
  ISO8601_DateTime_2<FixedArrayParseBuffer, FixedArrayParseBuffer> importer;

  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Export(input, output);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, output.size());
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), input.size());

  BOOST_REQUIRE_EQUAL(0, memcmp(&outputBuffer[0], "2007-01-31 10:32:55 AM", 22));
#endif
}

void Test_Export_UTF8_Terminated_UTF16_Null_Terminated_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
//   for(std::size_t granularity=1; granularity<=10; granularity++)
//   {
//     for(std::size_t view=1; view<=10; view++)
//     {
//       DynamicArrayParseBuffer output(32);
//       PagedBuffer pagedFile("I am a UTF8 String|I am also a UTF8 String", granularity);
//       PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
//       UTF8_Terminated_UTF16_Null_Terminated_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter(std::string(1,'|'));
//       BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
//       BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
//       BOOST_REQUIRE_EQUAL(64, output.capacity());
//       BOOST_REQUIRE_EQUAL(38, output.size());
//     }
//   }

  // TODO: Exporting should escape delimiters appropriately.
  UTF8_Terminated_UTF16_Null_Terminated_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer(std::string(1,'|'));
  std::wstring inputBuffer(L"I am a UTF8 String-I am also a UTF8 String");
  FixedArrayParseBuffer input(inputBuffer);
  DynamicArrayParseBuffer output(32);

  // Simple cases: one call with complete buffers.
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
  BOOST_REQUIRE_EQUAL(inputBuffer.size(), output.size());
  BOOST_REQUIRE_EQUAL(0, memcmp("I am a UTF8 String-I am also a UTF8 String", output.buffer(), inputBuffer.size()));
  
}

void Test_Export_UTF8_Base10_Decimal_DECIMAL_9_Digits_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
//   for(std::size_t granularity=1; granularity<=10; granularity++)
//   {
//     for(std::size_t view=1; view<=10; view++)
//     {
//       DynamicArrayParseBuffer output(32);
//       PagedBuffer pagedFile("I am a UTF8 String|I am also a UTF8 String", granularity);
//       PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
//       UTF8_Terminated_UTF16_Null_Terminated_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter(std::string(1,'|'));
//       BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
//       BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
//       BOOST_REQUIRE_EQUAL(64, output.capacity());
//       BOOST_REQUIRE_EQUAL(38, output.size());
//     }
//   }

  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"9993.23432", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("9993.23432", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(10, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("9993.23432", output.buffer(), 10));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"9.23432", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("9.23432", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(7, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("9.23432", output.buffer(), 7));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"9993.2", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("9993.2", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(6, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("9993.2", output.buffer(), 6));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"0.00001", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("0.00001", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(7, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("0.00001", output.buffer(), 7));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"1234567", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("1234567", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(7, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("1234567", output.buffer(), 7));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"0", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("0", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(1, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("0", output.buffer(), 1));
  }
  {
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"-9993.23432", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("-9993.23432", decVal);
#endif

    UTF8_Base10_Decimal_DECIMAL_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer;
    FixedArrayParseBuffer input((boost::uint8_t *) &decVal, (boost::uint8_t *) (&decVal+1));
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Export(input, output));
    BOOST_REQUIRE_EQUAL(11, output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp("-9993.23432", output.buffer(), 11));
  }
}

void TestExportFromSpecificationNonNullable()
{
  UTF8StringBufferExporter myRec(L"myRec ("
                                                 L"a text_delimited_base10_int32(delimiter='|'),\n"
                                                 L"b text_delimited_base10_int64(delimiter='|'),\n"
                                                 L"c text_delimited_base10_decimal(delimiter='|'),\n"
                                                 L"d text_delimited_varchar(delimiter='|'),\n"
                                                 L"e text_delimited_nvarchar(delimiter='|'),\n"
                                                 L"f iso8601_datetime(delimiter='|'),\n"
                                                 L"g text_delimited_enum(enum_space='Global', enum_type='CountryName', delimiter='\n')"
                                                 L")");
  BOOST_REQUIRE_EQUAL(7, myRec.GetMetadata().GetNumColumns());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"a", myRec.GetMetadata().GetColumnName(0).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Integer()==*myRec.GetMetadata().GetColumn(0)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(0)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"b", myRec.GetMetadata().GetColumnName(1).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::BigInteger()==*myRec.GetMetadata().GetColumn(1)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(1)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"c", myRec.GetMetadata().GetColumnName(2).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Decimal()==*myRec.GetMetadata().GetColumn(2)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(2)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"d", myRec.GetMetadata().GetColumnName(3).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::UTF8StringDomain()==*myRec.GetMetadata().GetColumn(3)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(3)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"e", myRec.GetMetadata().GetColumnName(4).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::StringDomain()==*myRec.GetMetadata().GetColumn(4)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(4)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"f", myRec.GetMetadata().GetColumnName(5).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Datetime()==*myRec.GetMetadata().GetColumn(5)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(5)->IsRequired());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"g", myRec.GetMetadata().GetColumnName(6).c_str()));
  BOOST_REQUIRE(PhysicalFieldType::Enum()==*myRec.GetMetadata().GetColumn(6)->GetPhysicalFieldType());
  BOOST_REQUIRE_EQUAL(true, myRec.GetMetadata().GetColumn(6)->IsRequired());

  // Countries: Afghanistan, Burkina Faso, Guatemala, Kenya
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());
  boost::shared_ptr<COdbcResultSet> rs(stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Afghanistan'"));
  rs->Next();
  boost::int32_t afghanistan=rs->GetInteger(1);
  rs->Close();
  rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQuery("SELECT id_enum_data FROM t_enum_data WHERE nm_enum_data='Global/CountryName/Burkina Faso'"));
  rs->Next();
  boost::int32_t burkinaFaso=rs->GetInteger(1);

  {
    DynamicArrayParseBuffer output(16);
    record_t recordBuffer = myRec.GetMetadata().Allocate();
    myRec.GetMetadata().GetColumn(L"a")->SetLongValue(recordBuffer, 1111111);
    myRec.GetMetadata().GetColumn(L"b")->SetBigIntegerValue(recordBuffer, -199288234234234);
#ifdef WIN32
    DECIMAL decVal;
    ::VarDecFromStr(L"88223.2343", LOCALE_SYSTEM_DEFAULT, 0, &decVal);
    myRec.GetMetadata().GetColumn(L"c")->SetDecimalValue(recordBuffer, &decVal);
#else
    decimal_traits::value decVal;
    decimal_traits::from_string("88223.2343", decVal);
    myRec.GetMetadata().GetColumn(L"c")->SetBigIntegerValue(recordBuffer, &decVal);
#endif
    myRec.GetMetadata().GetColumn(L"d")->SetUTF8StringValue(recordBuffer, "utf8 string to varchar1");
    myRec.GetMetadata().GetColumn(L"e")->SetStringValue(recordBuffer, L"utf8 string to nvarchar1");
#ifdef WIN32
    DATE dateVal;
    ::VarDateFromStr(L"1/1/2007 12:59:59 PM", LOCALE_SYSTEM_DEFAULT, 0, &dateVal);
    myRec.GetMetadata().GetColumn(L"f")->SetDatetimeValue(recordBuffer, dateVal);
#else
    datetime_traits::value dateVal;
    datetime_traits::from_string("1/1/2007 12:59:59 PM", dateVal);
    myRec.GetMetadata().GetColumn(L"f")->SetDatetimeValue(recordBuffer, dateVal);
#endif
    myRec.GetMetadata().GetColumn(L"g")->SetEnumValue(recordBuffer, afghanistan); 

    myRec.Export(recordBuffer, output);

    std::string expected("1111111|-199288234234234|88223.2343|utf8 string to varchar1|utf8 string to nvarchar1|2007-01-01 12:59:59 PM|Not yet implemented\n");
    BOOST_REQUIRE_EQUAL(expected.size(), output.size());
    BOOST_REQUIRE_EQUAL(0, memcmp(expected.c_str(), output.buffer(), output.size()));
  }

  // Run the test with a variety of windows and granularities.
//   for(std::size_t granularity=1; granularity<=100; granularity++)
//   {
//     for(std::size_t view=1; view<=100; view++)
//     {

//       PagedBuffer sourceBuffer( 
//         "1111111|-199288234234234|88223.2343|utf8 string to varchar1|utf8 string to nvarchar1|2007-01-01 12:59:59 PM|2\n"
//         "1111112|-199388234234234|88223.2343|utf8 string to varchar2|utf8 string to nvarchar2|2007-01-02 12:59:59 PM|34\n"
//         "1111113|-199488234234234|88223.2343|utf8 string to varchar3|utf8 string to nvarchar3|2007-01-03 12:59:59 PM|87\n"
//         "1111114|-199588234234234|88223.2343|utf8 string to varchar4|utf8 string to nvarchar4|2007-01-04 12:59:50 PM|107\n", granularity);
//       PagedParseBuffer<PagedBuffer> buffer(sourceBuffer, view);
//       // TODO: Test importing NULL values.
  
//       record_t recordBuffer = myRec.Import(buffer);
//       BOOST_REQUIRE(recordBuffer != NULL);
//       BOOST_REQUIRE_EQUAL(1111111, myRec.GetMetadata().GetLongValue(recordBuffer, 0));
//       BOOST_REQUIRE_EQUAL(-199288234234234LL, myRec.GetMetadata().GetBigIntegerValue(recordBuffer, 1));

//       BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar1", myRec.GetMetadata().GetUTF8StringValue(recordBuffer, 3)));
//       BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar1", myRec.GetMetadata().GetStringValue(recordBuffer, 4)));
//       BOOST_REQUIRE_EQUAL(afghanistan, myRec.GetMetadata().GetEnumValue(recordBuffer, 6));
//       myRec.GetMetadata().Free(recordBuffer);

//       recordBuffer = myRec.Import(buffer);
//       BOOST_REQUIRE_EQUAL(1111112, myRec.GetMetadata().GetLongValue(recordBuffer, 0));
//       BOOST_REQUIRE_EQUAL(-199388234234234LL, myRec.GetMetadata().GetBigIntegerValue(recordBuffer, 1));

//       BOOST_REQUIRE_EQUAL(0, strcmp("utf8 string to varchar2", myRec.GetMetadata().GetUTF8StringValue(recordBuffer, 3)));
//       BOOST_REQUIRE_EQUAL(0, wcscmp(L"utf8 string to nvarchar2", myRec.GetMetadata().GetStringValue(recordBuffer, 4)));
//       BOOST_REQUIRE_EQUAL(burkinaFaso, myRec.GetMetadata().GetEnumValue(recordBuffer, 6));
//       myRec.GetMetadata().Free(recordBuffer);
//     }
//   }
}

void TestStdioWriteBuffer()
{
  StdioFile file(L"C:\\Temp\\foo.txt", true);
  StdioWriteBuffer<StdioFile> buffer(file, 16);

  boost::uint8_t * outputBuffer;
  bool result = buffer.open(3, outputBuffer);
  BOOST_REQUIRE_EQUAL(true, result);
  memcpy(outputBuffer, "abc", 3);
  buffer.consume(3);
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(3, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "abc", 3));

  // Now open enough to fill
  BOOST_REQUIRE_EQUAL(true, buffer.open(13, outputBuffer));
  memcpy(outputBuffer, "defghijklmnop", 13);
  buffer.consume(13);
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(16, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "abcdefghijklmnop", 16));

  // Now open and this should flush.
  BOOST_REQUIRE_EQUAL(true, buffer.open(1, outputBuffer));
  memcpy(outputBuffer, "q", 1);
  buffer.consume(1);
  BOOST_REQUIRE_EQUAL(16, buffer.capacity());
  BOOST_REQUIRE_EQUAL(1, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "q", 1));

  // Now open so that we flush and double buffer
  BOOST_REQUIRE_EQUAL(true, buffer.open(20, outputBuffer));
  memcpy(outputBuffer, "aaaaaaaaaaaaaaaaaaaa", 20);
  buffer.consume(20);
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(20, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "aaaaaaaaaaaaaaaaaaaa", 20));

  // Set a mark and write
  buffer.mark();
  BOOST_REQUIRE_EQUAL(true, buffer.open(10, outputBuffer));
  memcpy(outputBuffer, "bbbbbbbbbb", 10);
  buffer.consume(10);
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(30, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "aaaaaaaaaaaaaaaaaaaabbbbbbbbbb", 30));
  
  // Trigger a flush and validate that we flush up to the mark.
  BOOST_REQUIRE_EQUAL(true, buffer.open(5, outputBuffer));
  memcpy(outputBuffer, "ccccc", 5);
  buffer.consume(5);
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(15, buffer.size());
  BOOST_REQUIRE_EQUAL(0, memcmp(buffer.buffer(), "bbbbbbbbbbccccc", 15));

  // Reset the mark and verify where we are at
  buffer.rewind();
  BOOST_REQUIRE_EQUAL(32, buffer.capacity());
  BOOST_REQUIRE_EQUAL(0, buffer.size());
  
}

void Test_UTF8_Base10_Signed_Integer_Int32_Positive_Input_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
  for(std::size_t granularity=1; granularity<=10; granularity++)
  {
    for(std::size_t view=1; view<=10; view++)
    {
      boost::int32_t value;
      FixedArrayParseBuffer output((boost::uint8_t *) &value, ((boost::uint8_t *)&value) + sizeof(boost::int32_t));
      PagedBuffer pagedFile("1882323;", granularity);
      PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
      UTF8_Base10_Signed_Integer_2<boost::int32_t, PagedParseBuffer<PagedBuffer>, FixedArrayParseBuffer> pagedImporter;
      BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
      BOOST_REQUIRE_EQUAL(1882323, value);
      BOOST_REQUIRE_EQUAL(4, output.size());  
    }
  }

  std::string inputBuffer("19926;");
  boost::int32_t value;
  UTF8_Base10_Signed_Integer_2<boost::int32_t, FixedArrayParseBuffer, FixedArrayParseBuffer> importer;
  FixedArrayParseBuffer input(inputBuffer);
  FixedArrayParseBuffer output((boost::uint8_t *) &value, ((boost::uint8_t *)&value) + sizeof(boost::int32_t));

  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
  BOOST_REQUIRE_EQUAL(19926, value);
  BOOST_REQUIRE_EQUAL(5, input.size());
  BOOST_REQUIRE_EQUAL(4, output.size());
  output.clear();

}

void Test_UTF8_Terminated_UTF16_Null_Terminated_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
  for(std::size_t granularity=1; granularity<=10; granularity++)
  {
    for(std::size_t view=1; view<=10; view++)
    {
      DynamicArrayParseBuffer output(32);
      PagedBuffer pagedFile("I am a UTF8 String|I am also a UTF8 String", granularity);
      PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
      UTF8_Terminated_UTF16_Null_Terminated_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter(std::string(1,'|'));
      BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
      BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
      BOOST_REQUIRE_EQUAL(64, output.capacity());
      BOOST_REQUIRE_EQUAL(38, output.size());
    }
  }

  UTF8_Terminated_UTF16_Null_Terminated_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer(std::string(1,'|'));
  std::string inputBuffer("I am a UTF8 String|I am also a UTF8 String");
  FixedArrayParseBuffer input(inputBuffer);
  DynamicArrayParseBuffer output(32);

  // Simple cases: one call with complete buffers.
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
  
}

void Test_UTF8_Terminated_UTF16_Null_Terminated_Multi_Char_Terminator()
{
  UTF8_Terminated_UTF16_Null_Terminated_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> importer("!!");
  {
    std::string inputBuffer("I am a UTF8 String!!I am also a UTF8 String");
    FixedArrayParseBuffer input(inputBuffer);
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
    BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
  }
  
  // String with terminator prefix.
  {
    std::string inputBuffer("I am a UTF8 String! !!I am also a UTF8 String");
    FixedArrayParseBuffer input(inputBuffer);
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
    BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String! ", (const wchar_t *)output.buffer()));
  }

  // String ending without terminator.
  {
    std::string inputBuffer("I am a UTF8 String");
    FixedArrayParseBuffer input(inputBuffer);
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
    BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", (const wchar_t *)output.buffer()));
  }

  // String ending with terminator prefix.
  {
    std::string inputBuffer("I am a UTF8 String!");
    FixedArrayParseBuffer input(inputBuffer);
    DynamicArrayParseBuffer output(32);

    // Simple cases: one call with complete buffers.
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, output));
    BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String!", (const wchar_t *)output.buffer()));
  }
}

void Test_UTF8_String_Literal_UTF8_Null_Terminated_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
  for(std::size_t granularity=1; granularity<=3; granularity++)
  {
    for(std::size_t view=1; view<=3; view++)
    {
      DynamicArrayParseBuffer output(32);
      PagedBuffer pagedFile("abc", granularity);
      PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
      UTF8_String_Literal_UTF8_Null_Terminated_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter("abc");
      BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
      BOOST_REQUIRE_EQUAL(32, output.capacity());
      BOOST_REQUIRE_EQUAL(3, output.size());
      BOOST_REQUIRE_EQUAL(0, memcmp("abc", output.buffer(), output.size()));
    }
  }
  // Failure on 3rd character.
  for(std::size_t granularity=1; granularity<=3; granularity++)
  {
    for(std::size_t view=1; view<=3; view++)
    {
      DynamicArrayParseBuffer output(32);
      PagedBuffer pagedFile("abf", granularity);
      PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
      UTF8_String_Literal_UTF8_Null_Terminated_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter("abc");
      BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_ERROR, pagedImporter.Import(pagedInput, output));
      BOOST_REQUIRE_EQUAL(32, output.capacity());
      BOOST_REQUIRE_EQUAL(0, output.size());
    }
  }
}

void Test_ISO8601_DateTime_AM_2()
{
  std::string inputBuffer("2007-01-31 10:32:55 AM");
  FixedArrayParseBuffer input(inputBuffer);
  date_time_traits::value outputBuffer;
  FixedArrayParseBuffer output((boost::uint8_t *) &outputBuffer, (boost::uint8_t *) (&outputBuffer+1));
  ISO8601_DateTime_2<FixedArrayParseBuffer, FixedArrayParseBuffer> importer;

  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import(input, output);
  
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(22, input.size());
  BOOST_REQUIRE_EQUAL(sizeof(date_time_traits::value), output.size());

#ifdef WIN32
  BSTR bstrVal;
  ::VarBstrFromDate(outputBuffer, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
  // Use a _bstr_t to delete the BSTR
  _bstr_t bstrtVal(bstrVal, false);
  std::string expected("1/31/2007 10:32:55 AM");
  BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, expected.c_str()));
#endif
}

void Test_UTF8_Base10_Decimal_DECIMAL_9_Digits_2()
{
  // Test a bunch of different combinations of granularity and minimum view size.
  for(std::size_t granularity=1; granularity<=10; granularity++)
  {
    for(std::size_t view=1; view<=10; view++)
    {
      DynamicArrayParseBuffer output(5);
      PagedBuffer pagedFile("9993.23432;", granularity);
      PagedParseBuffer<PagedBuffer> pagedInput(pagedFile, view);
      UTF8_Base10_Decimal_DECIMAL_2<PagedParseBuffer<PagedBuffer>, DynamicArrayParseBuffer> pagedImporter;
      BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, pagedImporter.Import(pagedInput, output));
      BOOST_REQUIRE_EQUAL(16, output.capacity());
      BOOST_REQUIRE_EQUAL(16, output.size());
#ifdef WIN32
      BSTR bstrVal;
      ::VarBstrFromDec((DECIMAL *)output.buffer(), LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
      // Use a _bstr_t to delete the BSTR
      _bstr_t bstrtVal(bstrVal, false);
      BOOST_REQUIRE_EQUAL(0, strcmp((const char *)bstrtVal, "9993.23432"));
#else
      std::string val;
      decimal_traits::to_string((decimal_traits::pointer)output.buffer(), val);
      BOOST_REQUIRE_EQUAL(0, strcmp("9993.23432", val.c_str()));
#endif
    }
  }
}

void Test_UTF8_Base10_Signed_Integer_Direct_Field_Importer_2()
{

  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  RecordMetadata recordA(logicalA);

  // The input
  std::string inputBuffer("19926;");
  FixedArrayParseBuffer input(inputBuffer);

  // The importer
  Direct_Field_Importer_2<UTF8_Base10_Signed_Integer_Int32_2, FixedArrayParseBuffer> importer(UTF8_Base10_Signed_Integer_Int32_2<FixedArrayParseBuffer, FixedArrayParseBuffer>(), *recordA.GetColumn(0));

  // The test.
  record_t recordBuffer = recordA.Allocate();
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, importer.Import(input, recordBuffer));
  BOOST_REQUIRE_EQUAL(false, recordA.GetColumn(L"a")->GetNull(recordBuffer));
  BOOST_REQUIRE_EQUAL(19926, recordA.GetColumn(L"a")->GetLongValue(recordBuffer));
  BOOST_REQUIRE_EQUAL(5, input.size());
  recordA.Free(recordBuffer);
}

void Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated_2()
{
  // TODO: Use ICU
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);

  std::string sourceBuffer("I am a UTF8 String|I am also a UTF8 String");
  FixedArrayParseBuffer input(sourceBuffer);

  UTF8_Terminated_UTF16_Null_Terminated_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> baseImporter(std::string(1,'|'));

  Field_Action_Importer_2<UTF8_Terminated_UTF16_Null_Terminated_2, FixedArrayParseBuffer, Set_Value_Action_Type> importer(baseImporter,
                                                                                                                        *recordA.GetColumn(L"a"));

  record_t recordBuffer = recordA.Allocate();

  // Simple cases: one call with complete buffers.
  ParseDescriptor::Result r = importer.Import(input, recordBuffer);
  BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
  BOOST_REQUIRE_EQUAL(18, input.size());
  BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", recordA.GetColumn(L"a")->GetStringValue(recordBuffer)));

  recordA.Free(recordBuffer);
}

void Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated_Nullable_2()
{
  // TODO: Use ICU
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);

  UTF8_Terminated_UTF16_Null_Terminated_2<FixedArrayParseBuffer, DynamicArrayParseBuffer> baseImporter(std::string(1,'|'));

  Field_Action_Importer_2<UTF8_Terminated_UTF16_Null_Terminated_2, FixedArrayParseBuffer, Set_Value_Action_Type> importer(baseImporter,
                                                                                                                          *recordA.GetColumn(L"a"));

  UTF8_Nullable_Terminated_Field_Importer_2<Field_Action_Importer_2<UTF8_Terminated_UTF16_Null_Terminated_2, FixedArrayParseBuffer, Set_Value_Action_Type> > nullableImporter("-", "|", *recordA.GetColumn(L"a"), importer);

  {
    // Simple cases: one call with complete buffers.
    record_t recordBuffer = recordA.Allocate();

    std::string sourceBuffer("I am a UTF8 String|I am also a UTF8 String");
    FixedArrayParseBuffer input(sourceBuffer);
    ParseDescriptor::Result r = nullableImporter.Import(input, recordBuffer);
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
    BOOST_REQUIRE_EQUAL(18, input.size());
    BOOST_REQUIRE_EQUAL(false, recordA.GetColumn(L"a")->GetNull(recordBuffer));
    BOOST_REQUIRE_EQUAL(0, wcscmp(L"I am a UTF8 String", recordA.GetColumn(L"a")->GetStringValue(recordBuffer)));
    recordA.Free(recordBuffer);
  }
  {
    // Simple cases: one call with complete buffers.
    record_t recordBuffer = recordA.Allocate();

    std::string sourceBuffer("-|I am also a UTF8 String");
    FixedArrayParseBuffer input(sourceBuffer);
    ParseDescriptor::Result r = nullableImporter.Import(input, recordBuffer);
    BOOST_REQUIRE_EQUAL(ParseDescriptor::PARSE_OK, r);
    BOOST_REQUIRE_EQUAL(1, input.size());
    BOOST_REQUIRE_EQUAL(true, recordA.GetColumn(L"a")->GetNull(recordBuffer));
    recordA.Free(recordBuffer);
  }
}

void TestFormat()
{
  std::cout << (boost::format("COM Error: HRESULT = 0x%x;") % 0xbaadf00d).str() << std::endl;
  std::cout << (boost::format("File:%s Line:%d COM Error: HRESULT = 0x%x") % __FILE__ % __LINE__ % 0xbaadf00d).str() << std::endl;
}

// void TestZLibArchive()
// {
//   GlobalConstantPoolFactory cpf;
//   RecordMetadata recordA;
//   logicalA.push_back(L"a", LogicalFieldType::Integer(false)); 
//   logicalA.push_back(L"b", LogicalFieldType::Integer(false)); 
//   logicalA.push_back(L"c", LogicalFieldType::String(false));
//   logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
//   logicalA.push_back(L"e", LogicalFieldType::BigInteger(false));
//   logicalA.push_back(L"f", LogicalFieldType::Double(false));
//   record_t bufferA = recordA.Allocate();
//   // 4 bytes
//   recordA.SetLongValue(bufferA, 0, 12);
//   // 4 bytes
//   recordA.SetLongValue(bufferA, 1, 23);
//   // 4 + 6 = 10 bytes
//   recordA.SetStringValue(bufferA, 2, L"23");
//   // 8 bytes
//   recordA.SetBigIntegerValue(bufferA, 3, 888223233LL);
//   // 4 + 8 = 12 bytes
//   recordA.SetBigIntegerValue(bufferA, 4, 773234LL);
//   // 4 + 8 = 12 bytes
//   recordA.SetDoubleValue(bufferA, 5, 23.2334);

//   {
//     ZLibBufferArchive archive(recordA);
//     unsigned char * serializationBufferA = new unsigned char [128];
//     archive.Bind(serializationBufferA, serializationBufferA + 128);
//     unsigned char * buf = archive.Serialize(bufferA);
//     buf = archive.Unbind();
//     // What is the length of output?
//     std::size_t len = buf - serializationBufferA;

//     ZLibBufferDearchive dearchive(recordA);
//     dearchive.Bind(serializationBufferA, buf);
//     record_t bufferB = recordA.Allocate();
//     int result = dearchive.Deserialize(bufferB);
//     dearchive.Unbind();
//     BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
//     recordA.Free(bufferB);
//     delete [] serializationBufferA;
//   }
//   {
//     std::size_t bufLen=8;
//     ZLibBufferArchive archive(recordA);
//     unsigned char ** serializationBufferA = new unsigned char * [128];
//     for(int j=0; j<128; j++)
//     {
//       serializationBufferA[j] = NULL;
//     }
//     bool recordWritten = false;
//     for(int j=0; j<128; j++)
//     {
//       serializationBufferA[j] = new unsigned char [12];
//       archive.Bind(serializationBufferA[j], serializationBufferA[j] + 12);
//       unsigned char * buf = NULL;
//       if (!recordWritten)
//         buf = archive.Serialize(bufferA);
//       if (buf != NULL)
//         recordWritten = true;
//       buf = archive.Unbind();
//       if (buf != serializationBufferA[j]+12)
//         break;
//     }

//     // Test deserialization with small buffers.
//     ZLibBufferDearchive dearchive(recordA);
//     record_t bufferB = recordA.Allocate();
//     // Deserialize one buffer at a time
//     for(int j=0; j<128; j++)
//     {
//       if (serializationBufferA[j] == NULL) break;
//       dearchive.Bind(serializationBufferA[j], serializationBufferA[j] + 12);
//       int result = dearchive.Deserialize(bufferB);
//       dearchive.Unbind();
// //       if (result == 0) break;
//     }
//     BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
//     recordA.Free(bufferB);
//     delete [] serializationBufferA;
//   }
//   recordA.Free(bufferA);
// }

void TestCallStack()
{
  CallStack callStack;
  std::string textCallStack;
  callStack.ToString(textCallStack);
  std::cout << textCallStack << std::endl;

  _se_translator_function save = _set_se_translator(&SEHException::TranslateStructuredExceptionHandlingException);
  try
  {
    char * foo = NULL;
    std::cout << foo[1] << std::endl;
  }
  catch (SEHException& ex)
  {
    std::cout << ex.callStack() << std::endl;
  }
  _set_se_translator(save);
}

// void TestMinHeap()
// {
//   min_heap<boost::int32_t> myHeap(100);
//   for(boost::int32_t i=0; i < 100; i++)
//   {
//     myHeap[i] = 200-i;
//   }

//   BOOST_REQUIRE_EQUAL(200, myHeap.top());
//   myHeap.init();
//   BOOST_REQUIRE_EQUAL(101, myHeap.top());
//   myHeap.top() = 99;
//   BOOST_REQUIRE_EQUAL(99, myHeap.top());
//   myHeap.heapify();
//   BOOST_REQUIRE_EQUAL(99, myHeap.top());
//   myHeap.top() = 102;
//   myHeap.heapify();
//   BOOST_REQUIRE_EQUAL(102, myHeap.top());
//   myHeap.top() = 1000;
//   myHeap.heapify();
//   BOOST_REQUIRE_EQUAL(102, myHeap.top());  
//   myHeap.top() = 1001;
//   myHeap.heapify();
//   BOOST_REQUIRE_EQUAL(103, myHeap.top());  
// }
class SortKeyPrefixExporter : public FieldAddress
{
public:
  typedef void (SortKeyPrefixExporter::*PrefixExporter)(const_record_t buffer, boost::uint8_t ** prefix, boost::uint8_t * prefixIt) const;
private:
  PrefixExporter mPrefixExporter;

  void InteralExportIntegerPrefixAscending(const_record_t buffer, boost::uint8_t ** prefixIt, boost::uint8_t * prefixEnd) const
  {
    if (!GetNull(buffer))
    {
      boost::uint32_t value = *reinterpret_cast<const boost::uint32_t *>(GetDirectBuffer(buffer));
      std::ptrdiff_t tmp = *prefixIt - prefixEnd;
      tmp = tmp  < 5 ? tmp : 5;

      switch(tmp)
      {
      case 5:
      // Sort NULLs high, then take the leading 7 bits of the value.
      **prefixIt = 0x00;
      **prefixIt |= (value >> 25);
      // Flip sign bit (bit number 2)
      **prefixIt ^= 0x40;
      *prefixIt -= 1;
      // Shift out the 7 bits that we just stored and then
      // store the remain 1 byte at a time.
      value <<= 7;
      **prefixIt = static_cast<boost::uint8_t>((value & 0xff000000) >> 24);
      *prefixIt -= 1;
      **prefixIt = static_cast<boost::uint8_t>((value & 0x00ff0000) >> 16);
      *prefixIt -= 1;
      **prefixIt = static_cast<boost::uint8_t>((value & 0x0000ff00) >> 8);
      *prefixIt -= 1;
      **prefixIt = static_cast<boost::uint8_t>((value & 0x000000ff));
      *prefixIt -= 1;
      break;
      case 4:
        *reinterpret_cast<boost::uint32_t*>(*prefixIt-3) = value;
        *reinterpret_cast<boost::uint32_t*>(*prefixIt-3) >>= 1;
        **prefixIt ^= 0x40;
        *prefixIt -= 4;
//       // Sort NULLs high, then take the leading 7 bits of the value.
//       **prefixIt = 0x00;
//       **prefixIt |= (value >> 25);
//       // Flip sign bit (bit number 2)
//       **prefixIt ^= 0x40;
//       *prefixIt -= 1;
//       // Shift out the 7 bits that we just stored and then
//       // store the remain 1 byte at a time.
//       value <<= 7;
//       **prefixIt = static_cast<boost::uint8_t>((value & 0xff000000) >> 24);
//       *prefixIt -= 1;
//       **prefixIt = static_cast<boost::uint8_t>((value & 0x00ff0000) >> 16);
//       *prefixIt -= 1;
//       **prefixIt = static_cast<boost::uint8_t>((value & 0x0000ff00) >> 8);
//       *prefixIt -= 1;
      break;
      case 3:
      // Sort NULLs high, then take the leading 7 bits of the value.
      **prefixIt = 0x00;
      **prefixIt |= (value >> 25);
      // Flip sign bit (bit number 2)
      **prefixIt ^= 0x40;
      *prefixIt -= 1;
      // Shift out the 7 bits that we just stored and then
      // store the remain 1 byte at a time.
      value <<= 7;
      **prefixIt = static_cast<boost::uint8_t>((value & 0xff000000) >> 24);
      *prefixIt -= 1;
      **prefixIt = static_cast<boost::uint8_t>((value & 0x00ff0000) >> 16);
      *prefixIt -= 1;
      break;
      case 2:
      // Sort NULLs high, then take the leading 7 bits of the value.
      **prefixIt = 0x00;
      **prefixIt |= (value >> 25);
      // Flip sign bit (bit number 2)
      **prefixIt ^= 0x40;
      *prefixIt -= 1;
      // Shift out the 7 bits that we just stored and then
      // store the remain 1 byte at a time.
      value <<= 7;
      **prefixIt = static_cast<boost::uint8_t>((value & 0xff000000) >> 24);
      *prefixIt -= 1;
      break;
      case 1:
      // Sort NULLs high, then take the leading 7 bits.
      **prefixIt = 0x00;
      **prefixIt |= (value >> 25);
      // Flip sign bit (bit number 2)
      **prefixIt ^= 0x40;
      *prefixIt -= 1;
      default:
        throw std::runtime_error("Invalid prefix buffer");
      }
    }
    else
    {
      // Sort NULLs high
      **prefixIt = 0x80;
      *prefixIt -= 1;
    }
  }

public:
  SortKeyPrefixExporter(const FieldAddress& fa)
    :
    FieldAddress(fa),
    mPrefixExporter(NULL)
  {
    mPrefixExporter = &SortKeyPrefixExporter::InteralExportIntegerPrefixAscending;
  }

  void operator() (const_record_t buffer, boost::uint8_t ** prefix, boost::uint8_t * prefixIt) const
  {
    (this->*mPrefixExporter)(buffer, prefix, prefixIt);
  }
};

void TestSortKeyPrefixExporter()
{
  // Test integer prefix export
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"b", LogicalFieldType::Integer(false)); 
  RecordMetadata recordA(logicalA);
  
  SortKeyPrefixExporter prefixExporter(*recordA.GetColumn(0));
  record_t bufferA = recordA.Allocate();
  recordA.GetColumn(0)->SetLongValue(bufferA, 7234134);
  boost::uint32_t prefixA;
  boost::uint8_t * prefixAit = reinterpret_cast<boost::uint8_t *>(&prefixA) + 3;
  prefixExporter(bufferA, 
                 &prefixAit, 
                 reinterpret_cast<boost::uint8_t *>(&prefixA) - 1); 
  BOOST_REQUIRE_EQUAL(prefixAit, reinterpret_cast<boost::uint8_t *>(&prefixA) - 1); 
  record_t bufferB = recordA.Allocate();
  recordA.GetColumn(0)->SetLongValue(bufferB, -7234134);
  boost::uint32_t prefixB;
  boost::uint8_t * prefixBit = reinterpret_cast<boost::uint8_t *>(&prefixB) + 3;
  prefixExporter(bufferB, 
                 &prefixBit, 
                 reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE_EQUAL(prefixBit, reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE(prefixB < prefixA);
  // This case, A & B differ only in the first bit which isn't in the prefix
  recordA.GetColumn(0)->SetLongValue(bufferB, 7234135);
  prefixBit = reinterpret_cast<boost::uint8_t *>(&prefixB) + 3;
  prefixExporter(bufferB, 
                 &prefixBit, 
                 reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE_EQUAL(prefixBit, reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE(prefixB == prefixA);

  recordA.GetColumn(0)->SetLongValue(bufferB, 7234136);
  prefixBit = reinterpret_cast<boost::uint8_t *>(&prefixB) + 3;
  prefixExporter(bufferB, 
                 &prefixBit, 
                 reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE_EQUAL(prefixBit, reinterpret_cast<boost::uint8_t *>(&prefixB) - 1); 
  BOOST_REQUIRE(prefixB > prefixA);
}

void TestRawArchive()
{
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"b", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"f", LogicalFieldType::Double(false));
  RecordMetadata recordA(logicalA);
  record_t bufferA = recordA.Allocate();
  // 4 bytes
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  // 4 bytes
  recordA.GetColumn(L"b")->SetLongValue(bufferA, 23);
  // 4 + 6 = 10 bytes
  recordA.GetColumn(L"c")->SetStringValue(bufferA, L"23");
  // 8 bytes
  recordA.GetColumn(L"d")->SetBigIntegerValue(bufferA, 888223233LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"e")->SetBigIntegerValue(bufferA, 773234LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"f")->SetDoubleValue(bufferA, 23.2334);

  {
    RawBufferArchive archive(recordA);
    unsigned char * serializationBufferA = new unsigned char [128];
    archive.Bind(serializationBufferA, serializationBufferA + 128);
    unsigned char * buf = archive.Serialize(bufferA, false);
    buf = archive.Unbind();
    // What is the length of output?
    std::size_t len = buf - serializationBufferA;

    RawBufferDearchive dearchive(recordA);
    dearchive.Bind(serializationBufferA, buf);
    record_t bufferB = recordA.Allocate();
    int result = dearchive.Deserialize(bufferB);
    dearchive.Unbind();
    BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
    recordA.Free(bufferB);
    delete [] serializationBufferA;
  }
  for (std::size_t bufSz=4; bufSz <=64; bufSz += 1)
  {
    // The total serialized output is 58 bytes
    std::size_t expectedBuffers = (58+bufSz-1)/bufSz;
    RawBufferArchive archive(recordA);
    unsigned char ** serializationBufferA = new unsigned char * [128];
    for(int j=0; j<128; j++)
    {
      serializationBufferA[j] = NULL;
    }
    bool recordWritten = false;
    for(int j=0; j<128; j++)
    {
      serializationBufferA[j] = new unsigned char [4+bufSz];
      archive.Bind(serializationBufferA[j], serializationBufferA[j] + 4 + bufSz);
      unsigned char * buf = NULL;
      if (!recordWritten)
        buf = archive.Serialize(bufferA, false);
      if (buf != NULL)
      {
        BOOST_REQUIRE_EQUAL(expectedBuffers, j+1);
        recordWritten = true;
      }
      buf = archive.Unbind();
      if (recordWritten)
      {
        break;
      }
    }

    // Test deserialization with small buffers.
    RawBufferDearchive dearchive(recordA);
    record_t bufferB = recordA.Allocate();
    // Deserialize one buffer at a time
    for(std::size_t j=0; j<expectedBuffers; j++)
    {
      if (serializationBufferA[j] == NULL) break;
      dearchive.Bind(serializationBufferA[j], serializationBufferA[j] + 4 + bufSz);
      int result = dearchive.Deserialize(bufferB);
      dearchive.Unbind();
//       if (result == 0) break;
      delete [] serializationBufferA[j];
      serializationBufferA[j] = NULL;
    }
    BOOST_REQUIRE(0 == memcmp(bufferA, bufferB, recordA.GetRecordLength()));
    recordA.Free(bufferB);
    delete [] serializationBufferA;
  }
  recordA.Free(bufferA);

  // Multi-record tests
  for(std::size_t numRecords=2; numRecords<100; numRecords++)
  {
    std::vector<record_t> buffers;
    for(std::size_t i=0; i<numRecords; i++)
    {
      buffers.push_back(recordA.Allocate());
      // 4 bytes
      recordA.GetColumn(L"a")->SetLongValue(buffers.back(), i);
      // 4 bytes
      recordA.GetColumn(L"b")->SetLongValue(buffers.back(), i);
      // 4 + 6 = 10 bytes
      recordA.GetColumn(L"c")->SetStringValue(buffers.back(), L"23");
      // 8 bytes
      recordA.GetColumn(L"d")->SetBigIntegerValue(buffers.back(), i);
      // 4 + 8 = 12 bytes
      recordA.GetColumn(L"e")->SetBigIntegerValue(buffers.back(), i+1);
      // 4 + 8 = 12 bytes
      recordA.GetColumn(L"f")->SetDoubleValue(buffers.back(), 23.2334*i);
    }

    const std::size_t bufSzs [] = {4, 7, 25, 58, 116, 777, 5800, 6400};
    for(std::size_t bufSzIdx=0; bufSzIdx<sizeof(bufSzs)/sizeof(bufSzs[0]); bufSzIdx++)
    {
      std::size_t bufSz = bufSzs[bufSzIdx];
      // The total serialized output of each record is 58 bytes
      std::size_t expectedBuffers = (numRecords*58+bufSz-1)/bufSz;
      RawBufferArchive archive(recordA);
      unsigned char ** serializationBufferA = new unsigned char * [expectedBuffers];
      for(std::size_t j=0; j<expectedBuffers; j++)
      {
        serializationBufferA[j] = NULL;
      }
      bool recordWritten = false;
      unsigned char * buf = NULL;
      std::size_t currentRecord = 0;
      for(std::size_t j=0; j<expectedBuffers; j++)
      {
        serializationBufferA[j] = new unsigned char [4+bufSz];
        archive.Bind(serializationBufferA[j], serializationBufferA[j] + 4 + bufSz);

        // Write records to fill the buffer
        while(currentRecord != buffers.size())
        {
          buf = archive.Serialize(buffers[currentRecord], false);
          if (buf != NULL)
          {
            currentRecord += 1;
          }
          else
          {
            // Need another buffer to fill
            break;
          }
        }
        buf = archive.Unbind();
      }

      BOOST_REQUIRE_EQUAL(currentRecord, buffers.size());

      // Test deserialization with small buffers.
      RawBufferDearchive dearchive(recordA);
      record_t bufferB = recordA.Allocate();
      std::size_t currentBuffer=0;
      // Deserialize one buffer at a time
      for(std::size_t j=0; j<expectedBuffers; j++)
      {
        if (serializationBufferA[j] == NULL) break;
        dearchive.Bind(serializationBufferA[j], j+1==expectedBuffers ? buf : serializationBufferA[j] + 4 + bufSz);
        while(true)
        {
          int result = dearchive.Deserialize(bufferB);
          if (result == 0) 
          {
            BOOST_REQUIRE(0 == memcmp(buffers[currentBuffer++], bufferB, recordA.GetRecordLength()));
            recordA.Free(bufferB);
            bufferB = recordA.Allocate();
            BOOST_REQUIRE(currentBuffer <= buffers.size());
          }
          else
          {
            BOOST_REQUIRE_EQUAL(result, -1);
            break;
          }
        }
        dearchive.Unbind();
        delete [] serializationBufferA[j];
        serializationBufferA[j] = NULL;
      }
      // Make sure we have account for all input records
      BOOST_REQUIRE_EQUAL(currentBuffer, buffers.size());
      recordA.Free(bufferB);
      delete [] serializationBufferA;
    }

    for(std::size_t i=0; i<buffers.size(); i++)
      recordA.Free(buffers[i]);
  }
}

void TestNestedRawArchive()
{
  GlobalConstantPoolFactory cpf;
  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"b", LogicalFieldType::Integer(false)); 
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  logicalA.push_back(L"d", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"e", LogicalFieldType::BigInteger(false));
  logicalA.push_back(L"f", LogicalFieldType::Double(false));
  RecordMetadata recordA(logicalA);

  LogicalRecord logicalB;
  logicalB.push_back(L"a", LogicalFieldType::Integer(false)); 
  logicalB.push_back(L"b", LogicalFieldType::Record(logicalA, true, true)); 
  logicalB.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordB(logicalB);

  record_t bufferA = recordA.Allocate();
  // 4 bytes
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 12);
  // 4 bytes
  recordA.GetColumn(L"a")->SetLongValue(bufferA, 23);
  // 4 + 6 = 10 bytes
  recordA.GetColumn(L"a")->SetStringValue(bufferA, L"23");
  // 8 bytes
  recordA.GetColumn(L"a")->SetBigIntegerValue(bufferA, 888223233LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"a")->SetBigIntegerValue(bufferA, 773234LL);
  // 4 + 8 = 12 bytes
  recordA.GetColumn(L"a")->SetDoubleValue(bufferA, 23.2334);

  record_t bufferB = recordB.Allocate();
  recordB.GetColumn(L"a")->SetLongValue(bufferB, 34234);
  recordB.GetColumn(L"b")->SetValue(bufferB, bufferA);
  recordB.GetColumn(L"c")->SetStringValue(bufferB, L"9923434");

  {
    RawBufferArchive archive(recordB);
    unsigned char * serializationBufferB = new unsigned char [1024];
    archive.Bind(serializationBufferB, serializationBufferB + 1024);
    unsigned char * buf = archive.Serialize(bufferB, false);
    buf = archive.Unbind();
    // What is the length of output?
    std::size_t len = buf - serializationBufferB;

    RawBufferDearchive dearchive(recordB);
    dearchive.Bind(serializationBufferB, buf);
    record_t bufferB2 = recordB.Allocate();
    int result = dearchive.Deserialize(bufferB2);
    dearchive.Unbind();
    recordB.PrintMessage(bufferB2);
    recordB.Free(bufferB2);
    delete [] serializationBufferB;
  }
  recordB.Free(bufferB);
}

void GenerateWPV()
{
  std::vector<boost::int32_t> rangeMap;
  rangeMap.push_back(0);
  rangeMap.push_back(10);
  rangeMap.push_back(20);
  std::vector<boost::int32_t>::iterator where = std::lower_bound(rangeMap.begin(), rangeMap.end(), -10);
  boost::uint32_t rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 0);
  rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 1);
  rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 10);
  rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 11);
  rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 19);
  rangeValue = (where-rangeMap.begin());  
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 20);
  rangeValue = (where-rangeMap.begin());
  where = std::lower_bound(rangeMap.begin(), rangeMap.end(), 21);
  rangeValue = (where-rangeMap.begin());

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N'"));

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt("switchInterval:switch[program=\"\n"
                            "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
                            "AS\n"
                            "RETURN CASE\n%1%END\"];\n");

  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");
//   boost::format mfsFmt(
//     "-- %2% %3%\n"
//     "g%1%:generate[program=\"\n"
//     "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
//     "AS\n"
//     "SET @id_commit_unit = CAST(@@RECORDCOUNT / 50000LL AS INTEGER)\"];\n"
//     "c%1%:copy[];\n"
//     "switchInterval(%1%) -> g%1% -> c%1%;\n"
//     "au%1%:insert[table=\"t_acc_usage\", batchSize=50000, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
//     "c%1%(0) -> au%1%;\n"
//     "pv%1%:insert[table=\"t_pv_testpi\", batchSize=50000, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
//     "c%1%(1) -> pv%1%;\n"
//     "audn%1%:devNull[];\n"
//     "pvdn%1%:devNull[];\n"
//     "au%1% -> audn%1%;\n"
//     "pv%1% -> pvdn%1%;\n"
//     );
  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / 50000LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", batchSize=50000, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"t_pv_testpi\", batchSize=50000, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\n"
    "SET @size_1 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\n"
    "SET @size_1 = @size_1 + 1\"];\n"
    "c%1%(2) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..t_acc_usage SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"],\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..t_pv_testpi SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "au%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "pv%1% ->[buffered=false] install%1%(\"input(1)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );
  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % "%1%").str();
    i += 1;
  }
  program = (switchOpFmt % switchClause).str() + program;
  std::cout << program << std::endl;
}

int test_main( int argc, char * argv[] )
// int main( int argc, char * argv[] )
{
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  AutoLogServer boundsCheckerHack;

    // canary
//     char * foo = new char [100];
  GenerateWPV();
  return 0;

  TestNestedRawArchive();
  TestRawArchive();
  TestSortKeyPrefixExporter();
//   TestMinHeap();
  TestCallStack();
  return 0;
//   TestZLibArchive();
  TestDynamicArrayParseBuffer();

  // Export function tests
  Test_Export_UTF8_Base10_Signed_Integer_Int32_Positive_Input_2();
  Test_Export_ISO8601_DateTime_AM_2();
  Test_Export_UTF8_Terminated_UTF16_Null_Terminated_2();
  Test_Export_UTF8_Base10_Decimal_DECIMAL_9_Digits_2();
  TestExportFromSpecificationNonNullable();
  TestStdioWriteBuffer();
  // Import function tests
  Test_UTF8_Base10_Signed_Integer_Int32_Positive_Input_2();
  Test_UTF8_Base10_Signed_Integer_Direct_Field_Importer_2();
  Test_UTF8_Terminated_UTF16_Null_Terminated_2();
  Test_UTF8_Terminated_UTF16_Null_Terminated_Multi_Char_Terminator();
  Test_UTF8_String_Literal_UTF8_Null_Terminated_2();
  Test_ISO8601_DateTime_AM_2();
  Test_UTF8_Base10_Decimal_DECIMAL_9_Digits_2();
  Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated_2();
  Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated_Nullable_2();

  Test_UTF8_String_Literal_UTF8_Null_Terminated();
  Test_UTF8_Base10_Signed_Integer_Int32_Negative_Input();
  Test_UTF8_Base10_Signed_Integer_Int32_Positive_Input();
  Test_UTF8_Base10_Signed_Integer_Int32_Plus_Sign();
  Test_UTF8_Base10_Signed_Integer_Int32_Parse_Errors();
  Test_UTF8_Base10_Signed_Integer_Int64_Positive_Input();
  Test_UTF8_Terminated_UTF16_Null_Terminated();
  Test_ISO8601_DateTime_AM();
  Test_ISO8601_DateTime_PM();
  Test_UTF8_Base10_Decimal_DECIMAL_9_Digits();
  Test_UTF8_Base10_Decimal_DECIMAL_16_Digits();
  Test_UTF8_Base10_Decimal_DECIMAL_24_Digits();
//   Test_UTF8_Base10_Decimal_DECIMAL_32_Digits();
  Test_Direct_Field_Importer_Int32();
  Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated();
  Test_Indirect_Field_Importer_UTF8_Terminated_UTF16_Null_Terminated();
  TestImporterSpecification();
  TestImportFromSpecificationNonNullable();
  TestImportFromSpecificationNullable();
  TestImportFromSpecificationNonNullableMultiCharTerminator();

//   TestBPlusTreeGrowTreeEvenNumberOfKeys();
//   TestBPlusTreeNonLeafPageFixedLengthKeyNoPrefixPageSplit();
//   TestBPlusTreePageFixedLengthKeyNoPrefix();
//   TestBPlusTreePageFixedLengthKeyWithPrefix();
//   TestBPlusTreePageFixedLengthKeyWithPrefixCompress();
//   TestBPlusTreeNonLeafPageFixedLengthKeyWithPrefix();
// TestSortMergeCollector();
//     TestRecordSerialization();
    // TestRecordSerializationBug();
//     TestRemoteExecution(argc, argv);
//     SerializationTest::TestPortSerialization();
//     SerializationTest::TestPortCollectionSerialization();
//     SerializationTest::TestOperatorSerialization();
//     SerializationTest::TestMetadataSerialization();
//     SerializationTest::TestRunTimePlanSerialization();

  TestMessagePtrQueue();
//   TestReadPriority();
//   TestWritePriority();
  TestLongHash();
  TestIntegerSortKey();
//   TestBigIntegerSortKey();
//   TestDatetimeSortKey();
//     TestDesignTimePlan();
//     TestRunTimePlan();
//   TestDatabaseTableStreamingInsert(10, 4);
//   TestDatabaseTableStreamingInsert(10,5);
//   TestDatabaseTableStreamingInsert(1000,100);
//   TestDatabaseTableCopy();
//   TestDatabaseTableCopy(1);
//   TestDatabaseTableCopy(5);
//     TestHashJoin();
//   TestLargeHashJoin();
//     TestRightOuterHashJoin();
//     TestHashPartitioner();
//     TestNondeterministicCollector();
//     TestHashRepartition();
//     TestUnionAll();
//     TestHashRunningAggregate();
//     TestHashRunningAggregateMultiInput();
//     TestHashGroupBy();
//     TestSortGroupBy();
//     TestExpression();
//     TestExpressionGenerator();
//     TestUnroll();
//     TestFilter();
//     TestSwitch();
//     TestProjection();
//     TestGenerator();
//   TestAssertSortOrder1();
//   TestAssertSortOrder2();
//   TestAssertSortOrder3();
//   TestInMemorySort();
//   TestDiskSort();
//     TestDirectedCycle();
//     TestSingleInputSessionSetBuilder();
//     TestMultiInputSessionSetBuilder();
//     TestEmptyMultiInputSessionSetBuilder();
//   TestMultiInputSessionSetBuilderWithEmptyChildren();
//   TestTransactionalInstallSingleInput();
//     TestBroadcastPartition();
//     TestRoundRobinPartition();
//     TestRecordParser();
//     TestMeteringStagingDatabaseAtomic();
//     TestMeteringStagingDatabaseCompound();
//     TestMeteringStagingDatabaseAtomicAggregate();
//     TestMeteringStagingDatabaseCompoundAggregate();
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 100, 10000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::PRIVATE, 1000, 100, 10000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 101, 10000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::PRIVATE, 1000, 101, 10000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 100, 1000, 10000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::PRIVATE, 100, 1000, 10000);

//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 100, 1000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 101, 1000);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 100, 1000, 1000);

//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 100, 500);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 101, 500);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 100, 1000, 500);

//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 100, 103);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 1000, 101, 78);
//     TestMeteringTestPI(DatabaseMeteringStagingDatabase::STREAMING, 100, 1000, 5);

//     TestMeteringSongDownloads();
//     TestMeteringSongSessionTemp();
//     TestMeteringSongSession();
//     TestMeteringCompound();
//     TestMeteringRandomAudioConference(DatabaseMeteringStagingDatabase::STREAMING);
//     TestMeteringRandomAudioConference(DatabaseMeteringStagingDatabase::PRIVATE);
//   TestAggregateMetering();
//     TestAggregateRating();
//     TestAccUsageRead();
//     TestSequentialMemoryPerformance();
//     TestWideStringConstantPool();
//     TestWideStringConstantPoolPerformance();
//     TestCacheConsciousHashTableLoadPerformance();
//     TestCacheConsciousHashTableSingleEntry();
//     TestCacheConsciousHashTableWithCollision();
//     TestVirtualCall();
//     TestMappedFile();
//     TestMappedStream();
//     TestRecordMetadataCopy();
//     TestSmallRecordMerge();
//     TestLargeRecordMerge();
//     TestLargeRecordMerge2();
//     TestSmallRecordProjection1();
//     TestSmallRecordProjection2();
//     TestSmallRecordProjection3();
//     TestSmallRecordProjection4();
//     TestLargeRecordProjection();
//     TestPrefixedUCS2Import();
//     TestPrefixedUCS2EnumImport();
    // DB - These are tests for the old iterator based model that I used
    // in Boeblingen.
//     TestDatabaseInsertAllTypes();
//     TestDatabaseInsertAllTypesMapNames();
//     TestDatabaseInsert();
//     TestDatabaseMetering();
//     TestRunningHashAggregate();
//     TestIdGenerator();
  TestAggregateExpressionParser();
  TestAggregateExpressionParserMultipleCountersMultipleProductViews();
    std::cout << "All tests succeeded" << std::endl;
    return 0;
}
