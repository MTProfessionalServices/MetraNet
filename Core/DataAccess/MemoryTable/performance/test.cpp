#define NOMINMAX
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
#include <DesignTimeExpression.h>
#include <PlanInterpreter.h>
#include <DatabaseMetering.h>
#include <boost/test/test_tools.hpp>


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

void TestLocalEndpoint()
{
  boost::shared_ptr<Channel> c(new Channel(NULL, NULL));
  Endpoint * ep = c->GetSource();
  
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

  boost::shared_ptr<BatchScheduler> scheduler(new BatchScheduler());
  BatchScheduler * sched = scheduler.get();

  // Go into a loop of 1000 pushes and pops.
  for(boost::int32_t i=0; i<1000000; i++)
  {
    for(boost::int32_t j=0; j<1000; j++)
    {
      sched->WriteChannel(ep, ptrs[j], false);
    }
    MessagePtr ptr;
    for(boost::int32_t j=0; j<1000; j++)
    {
      sched->ReadChannel(ep, ptr);
    }
  }
}

class DataflowPerformanceTestRun
{
private:
  Timer mTimer;
  std::ostream& mTestOutput;
public:
  DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, boost::int64_t numRecords);
  DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, boost::int64_t numRecords1, boost::int64_t numRecords2);
  DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, 
                             boost::int64_t numRecords1, boost::int64_t numRecords2, boost::int64_t numRecords3);
  ~DataflowPerformanceTestRun();
  void type_check(DesignTimePlan& plan);
  void code_generate(DesignTimePlan& plan, ParallelPlan& pplan);
  void start(ParallelPlan& pplan);

  void run(DesignTimePlan& plan, ParallelPlan& pplan);
};

DataflowPerformanceTestRun::DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, boost::int64_t numRecords)
  :
  mTestOutput(testOutput)
{
  mTestOutput << testName << "," << numPartitions << "," << numRecords << "," << 0;
}

DataflowPerformanceTestRun::DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, 
                                                       boost::int64_t numRecords1, boost::int64_t numRecords2)
  :
  mTestOutput(testOutput)
{
  mTestOutput << testName << "," << numPartitions << "," << numRecords1 << "," << numRecords2;
}

DataflowPerformanceTestRun::DataflowPerformanceTestRun(std::ostream& testOutput, const std::string& testName, boost::int32_t numPartitions, 
                                                       boost::int64_t numRecords1, boost::int64_t numRecords2, boost::int64_t numRecords3)
  :
  mTestOutput(testOutput)
{
  mTestOutput << testName << "," << numPartitions << "," << numRecords1 << "," << numRecords2 << "," << numRecords3;
}

DataflowPerformanceTestRun::~DataflowPerformanceTestRun()
{
  mTestOutput << std::endl;
}

void DataflowPerformanceTestRun::type_check(DesignTimePlan& plan)
{
  mTimer.Reset();
  {
    ScopeTimer sc(&mTimer);
    plan.type_check();
  }
  mTestOutput << "," << mTimer.GetMilliseconds();
}

void DataflowPerformanceTestRun::code_generate(DesignTimePlan& plan, ParallelPlan& pplan)
{
  mTimer.Reset();
  {
    ScopeTimer sc(&mTimer);
    plan.code_generate(pplan);
  }
  mTestOutput << "," << mTimer.GetMilliseconds();
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
}

void DataflowPerformanceTestRun::start(ParallelPlan& pplan)
{
  mTimer.Reset();
  {
    ScopeTimer sc(&mTimer);
    pplan.GetDomain(0)->Start();
  }
  mTestOutput << "," << mTimer.GetMilliseconds();
}

void DataflowPerformanceTestRun::run(DesignTimePlan& plan, ParallelPlan& pplan)
{
  type_check(plan);
  code_generate(plan, pplan);
  start(pplan);
}


void TestGeneratorSmallRecord(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestGeneratorSmallRecord", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT\n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestGeneratorMediumRecord(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestGeneratorMediumRecord", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal DECIMAL @doubleVal DOUBLE @strVal VARCHAR @wstrVal NVARCHAR\n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    L"SET @strVal = CAST(@@RECORDCOUNT % 100000LL AS VARCHAR)\n"
    L"SET @wstrVal = CAST(@@RECORDCOUNT % 100000LL AS NVARCHAR)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestGeneratorMediumRecordNoString(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestGeneratorMediumRecordNoString", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL\n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal3 = @decVal1 * @decVal2\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestExpression(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestExpression", numPartitions, numRecords);
  DesignTimePlan plan;
  // To reduce the amount of time spent in the generator, we generate a bunch of 
  // test data and then unroll/copy it to get the target size of the test.
  // This gives us some randomness in the data without spending as much time in generator.
  boost::int32_t factorToUnroll(100);
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    (boost::wformat(
    L"CREATE PROCEDURE gen @unrollVal INTEGER @intVal1 INTEGER @intVal2 INTEGER @intVal3 INTEGER \n"
    L"@datetimeVal1 DATETIME  @datetimeVal2 DATETIME  @datetimeVal3 DATETIME @strVal VARCHAR\n"
    L"AS\n"
    L"SET @unrollVal = %1%\n"
    L"SET @intVal1 = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @intVal2 = @intVal1 + 3\n"
    L"SET @intVal3 = @intVal1 + 2\n"
    L"SET @datetimeVal1 = CAST(@@RECORDCOUNT AS DATETIME)\n"
    L"SET @datetimeVal2 = CAST(@@RECORDCOUNT AS DATETIME)\n"
    L"SET @datetimeVal3 = getutcdate()\n"
    L"SET @strVal = CASE WHEN @@RECORDCOUNT %% 2LL = 0LL THEN 'Y' ELSE 'N' END\n")
     % factorToUnroll).str()
    );
  gen->SetNumRecords(numRecords/factorToUnroll);
  plan.push_back(gen);

  DesignTimeUnroll * unroll = new DesignTimeUnroll();
  unroll->SetCount(L"unrollVal");
  plan.push_back(unroll);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], unroll->GetInputPorts()[0]));

  // Sample expressions such as those used in aggregate rating
  DesignTimeExpression * expr = new DesignTimeExpression();
  expr->SetProgram(
    L"CREATE PROCEDURE gen @intVal1 INTEGER @intVal2 INTEGER @intVal3 INTEGER \n"
    L"@datetimeVal1 DATETIME  @datetimeVal2 DATETIME  @datetimeVal3 DATETIME @strVal VARCHAR\n"
    L"@intValOut INTEGER OUTPUT @boolVal BOOLEAN OUTPUT @datetimeValOut DATETIME OUTPUT\n"
    L"@isNullValOut DATETIME OUTPUT @intCopyOut INTEGER OUTPUT @intLitOut INTEGER OUTPUT\n"
    L"AS\n"
    L"SET @intValOut = CASE WHEN @intVal2 >= @intVal1 AND @intVal2 <= @intVal3 THEN @intVal1 ELSE @intVal3 END\n"
    L"SET @boolVal = CASE WHEN 'Y' = @strVal THEN TRUE ELSE FALSE END\n"
    L"SET @datetimeValOut = CASE WHEN @datetimeVal2 >= @datetimeVal1 AND @datetimeVal2 <= @datetimeVal3 THEN @datetimeVal1 ELSE @datetimeVal3 END\n"
    L"SET @isNullValOut = CASE WHEN @datetimeVal2 IS NULL THEN @datetimeVal1 ELSE @datetimeVal3 END\n"
    L"SET @intCopyOut = @intVal3\n"
    L"SET @intLitOut = 233\n"
    );
  plan.push_back(expr);
  plan.push_back(new DesignTimeChannel(unroll->GetOutputPorts()[0], expr->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(expr->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestDatabaseInsert(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestDatabaseInsert", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal DECIMAL @doubleVal DOUBLE @strVal VARCHAR @wstrVal NVARCHAR\n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    L"SET @strVal = CAST(@@RECORDCOUNT % 100000LL AS VARCHAR)\n"
    L"SET @wstrVal = CAST(@@RECORDCOUNT % 100000LL AS NVARCHAR)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName((boost::wformat(L"perftest_%1%_%2%") % numPartitions % numRecords).str());
  insert->SetCreateTable(true);
  plan.push_back(insert);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestDatabaseSelect(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestDatabaseSelect", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(
    (boost::wformat(L"SELECT bigintVal, intVal, decVal, doubleVal, strVal, wstrVal\n"
                    L"FROM perftest_%1%_%2% WHERE {fn MOD(bigintVal, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%")
     % numPartitions % numRecords).str());
  select->SetSchema(L"NetMeterStage");
  plan.push_back(select);
  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestRoundRobinPartitionNonDeterministicCollect(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestRoundRobinPartitionNonDeterministicCollect", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL \n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal3 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeRoundRobinPartitioner * part = new DesignTimeRoundRobinPartitioner();
  plan.push_back(part);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], 
                                        part->GetInputPorts()[0]));

  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  plan.push_back(coll);
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], 
                                        coll->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], 
                                       devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestHashPartitionNonDeterministicCollect(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestHashPartitionNonDeterministicCollect", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL \n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal3 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
  std::vector<std::wstring> hashKeys;
  hashKeys.push_back(L"bigintVal");
  part->SetHashKeys(hashKeys);
  plan.push_back(part);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], 
                                        part->GetInputPorts()[0]));

  DesignTimeNondeterministicCollector * coll = new DesignTimeNondeterministicCollector();
  plan.push_back(coll);
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], 
                                        coll->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], 
                                       devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestHashPartitionSortMergeCollect(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestHashPartitionSortMergeCollect", numPartitions, numRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * gen = new DesignTimeGenerator();
  gen->SetProgram(
    L"CREATE PROCEDURE gen @bigintVal BIGINT @intVal INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL \n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal3 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    );
  gen->SetNumRecords(numRecords);
  plan.push_back(gen);
  DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
  std::vector<std::wstring> hashKeys;
  hashKeys.push_back(L"bigintVal");
  part->SetHashKeys(hashKeys);
  plan.push_back(part);
  plan.push_back(new DesignTimeChannel(gen->GetOutputPorts()[0], 
                                        part->GetInputPorts()[0]));

  DesignTimeSortMergeCollector * coll = new DesignTimeSortMergeCollector();
  coll->AddSortKey(new DesignTimeSortKey(L"bigintVal",SortOrder::ASCENDING ));
  coll->AddSortKey(new DesignTimeSortKey(L"intVal",SortOrder::ASCENDING ));
  plan.push_back(coll);
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], 
                                        coll->GetInputPorts()[0]));

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], 
                                       devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

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

void TestHashJoinUniqueKeyNoPredicate(std::ostream& testOutput, boost::int32_t numPartitions, boost::int64_t numTableRecords, boost::int64_t numProbeRecords)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestHashJoinUniqueKeyNoPredicate", numPartitions, numTableRecords, numProbeRecords);
  DesignTimePlan plan;
  DesignTimeGenerator * genTable = new DesignTimeGenerator();
  genTable->SetProgram(
    L"CREATE PROCEDURE genTable @bigintVal BIGINT @intVal INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL \n"
    L"AS\n"
    L"SET @bigintVal = @@RECORDCOUNT\n"
    L"SET @intVal = CAST(@@RECORDCOUNT AS INTEGER)\n"
    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
    L"SET @decVal3 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
//     L"SET @doubleVal = CAST(@@RECORDCOUNT AS DOUBLE)\n"
    );
  genTable->SetNumRecords(numTableRecords);
  plan.push_back(genTable);
  
  DesignTimeGenerator * genProbe = new DesignTimeGenerator();
  genProbe->SetNumRecords(numProbeRecords);
  plan.push_back(genProbe);
  genProbe->SetProgram(
    (boost::wformat(L"CREATE PROCEDURE genProbe @bigintVal_p BIGINT @intVal_p INTEGER @decVal_p DECIMAL\n"
                    L"AS\n"
                    L"SET @bigintVal_p = @@RECORDCOUNT %% %1%LL\n"
                    L"SET @intVal_p = CAST(@@RECORDCOUNT AS INTEGER)\n"
                    L"SET @decVal_p = CAST(@@RECORDCOUNT AS DECIMAL)\n") % numTableRecords).str());

  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  std::vector<std::wstring> tableJoinKeys;
  tableJoinKeys.push_back(L"bigintVal");
  join->SetTableEquiJoinKeys(tableJoinKeys);
  DesignTimeHashJoinProbeSpecification joinSpec;
  std::vector<std::wstring> probeJoinKeys;
  probeJoinKeys.push_back(L"bigintVal_p");
  joinSpec.SetEquiJoinKeys(probeJoinKeys);
  joinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  join->AddProbeSpecification(joinSpec);
  plan.push_back(join);
  plan.push_back(new DesignTimeChannel(genTable->GetOutputPorts()[0], 
                                        join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(genProbe->GetOutputPorts()[0], 
                                        join->GetInputPorts()[L"probe(0)"]));


  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestHashJoinNonUniqueKeyWithPredicate(std::ostream& testOutput, 
                                           boost::int32_t numPartitions, 
                                           boost::int64_t numTableRecords, 
                                           boost::int64_t numProbeRecords,
                                           boost::int64_t tableRecordsPerKey)
{
  // This test simulates a range query predicate.  The idea is we assume a number of records
  // with a given key value.  Each of these records is associated with a range within the interval [0,1000)
  // For example, if we assume 4 entries per key value, then the entries for key = 100LL are:
  // 100LL, 0, 249
  // 100LL, 250, 499
  // 100LL, 500, 749
  // 100LL, 750, 999
  // The generator program below creates this data.
  DataflowPerformanceTestRun testRun(testOutput, "TestHashJoinNonUniqueKeyWithPredicate", numPartitions, numTableRecords, numProbeRecords, tableRecordsPerKey);
  DesignTimePlan plan;
  DesignTimeGenerator * genTable = new DesignTimeGenerator();
  genTable->SetProgram(
    (boost::wformat(L"CREATE PROCEDURE genTable @bigintVal BIGINT @intValLeft INTEGER @intValRight\n"
                    L"INTEGER @decVal1 DECIMAL @doubleVal DOUBLE @decVal2 DECIMAL @decVal3 DECIMAL \n"
                    L"AS\n"
                    L"DECLARE @intervalSize INTEGER\n"
                    L"DECLARE @intervalIndex INTEGER\n"
                    L"SET @intervalSize = CAST(1000LL/%1%LL AS INTEGER)\n"
                    L"SET @intervalIndex = CAST(@@RECORDCOUNT %% %1%LL AS INTEGER)\n"
                    L"SET @bigintVal = (@@RECORDCOUNT/%1%LL)\n"
                    L"SET @intValLeft = @intervalIndex * @intervalSize\n"
                    L"SET @intValRight = (@intervalIndex + 1) * @intervalSize - 1\n"
                    L"SET @decVal1 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
                    L"SET @decVal2 = CAST(@@RECORDCOUNT AS DECIMAL)\n"
                    L"SET @decVal3 = CAST(@@RECORDCOUNT AS DECIMAL)\n") % tableRecordsPerKey).str());
  genTable->SetNumRecords(numTableRecords);
  plan.push_back(genTable);
  
  DesignTimeGenerator * genProbe = new DesignTimeGenerator();
  genProbe->SetNumRecords(numProbeRecords);
  plan.push_back(genProbe);
  genProbe->SetProgram(
    (boost::wformat(L"CREATE PROCEDURE genProbe @bigintVal_p BIGINT @intVal_p INTEGER @decVal_p DECIMAL\n"
                    L"AS\n"
                    L"SET @bigintVal_p = @@RECORDCOUNT %% %1%LL\n"
                    L"SET @intVal_p = CAST(@@RECORDCOUNT AS INTEGER) %% 1000\n"
                    L"SET @decVal_p = CAST(@@RECORDCOUNT AS DECIMAL)\n") % (numTableRecords/tableRecordsPerKey)).str());

  DesignTimeHashJoin * join = new DesignTimeHashJoin();
  std::vector<std::wstring> tableJoinKeys;
  tableJoinKeys.push_back(L"bigintVal");
  join->SetTableEquiJoinKeys(tableJoinKeys);
  DesignTimeHashJoinProbeSpecification joinSpec;
  std::vector<std::wstring> probeJoinKeys;
  probeJoinKeys.push_back(L"bigintVal_p");
  joinSpec.SetEquiJoinKeys(probeJoinKeys);
  joinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  joinSpec.SetResidual(
    L"CREATE FUNCTION residual (@Probe_intVal_p INTEGER @Table_intValLeft INTEGER @Table_intValRight INTEGER) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_intVal_p >= @Table_intValLeft AND @Probe_intVal_p <= @Table_intValRight\n");
  join->AddProbeSpecification(joinSpec);
  plan.push_back(join);
//   DesignTimePrint * print = new DesignTimePrint();
//   print->SetNumToPrint(100000);
//   plan.push_back(print);
//   plan.push_back(new DesignTimeChannel(genProbe->GetOutputPorts()[0], print->GetInputPorts()[0]));  

  plan.push_back(new DesignTimeChannel(genTable->GetOutputPorts()[0], 
                                        join->GetInputPorts()[L"table"]));
  plan.push_back(new DesignTimeChannel(genProbe->GetOutputPorts()[0], 
                                        join->GetInputPorts()[L"probe(0)"]));


  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(join->GetOutputPorts()[0], devNull->GetInputPorts()[0]));
  
  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

void TestHashRunningTotal(std::ostream& testOutput, 
                          boost::int32_t numPartitions, 
                          boost::int64_t numTableRecords, 
                          boost::int64_t numProbeRecords,
                          boost::int64_t numInputs)
{
  DataflowPerformanceTestRun testRun(testOutput, "TestHashRunningTotal", numPartitions, numTableRecords, numProbeRecords, numInputs);
  DesignTimePlan plan;
  // This running total calculation is the same as songdownloads.  It is expressed suboptimally but
  // this is the current (3/1/2007) state of the aggregate dataflow generator.
  std::wstring initializeProgram(L"CREATE PROCEDURE initializer  @Table_SUM_201088624 DECIMAL "
                                 L"@Table_SUM_208825624 DECIMAL @Table_SUM_209193568 DECIMAL\n"
                                 L"@Table_c_TotalSongs DECIMAL @Table_c_TotalBytes DECIMAL\n"
                                 L"AS\n"
                                 L"SET @Table_SUM_201088624 = 0.0\n"
                                 L"SET @Table_SUM_208825624 = 0.0\n"
                                 L"SET @Table_SUM_209193568 = 0.0\n"
                                 L"SET @Table_c_TotalSongs = 0.0\n"
                                 L"SET @Table_c_TotalBytes = 0.0\n");

  std::wstring updateProgram(L"CREATE PROCEDURE updater  @Probe_c_songs DECIMAL @Probe_c_mp3bytes DECIMAL\n"
                             L"@Probe_c_wavbytes DECIMAL @Table_SUM_201088624\n"
                             L"DECIMAL @Table_SUM_208825624 DECIMAL @Table_SUM_209193568 DECIMAL\n"
                             L"@Table_c_TotalSongs DECIMAL @Table_c_TotalBytes DECIMAL\n"
                             L"AS\n"
                             L"SET @Table_SUM_201088624 = @Table_SUM_201088624 + @Probe_c_songs\n"
                             L"SET @Table_SUM_208825624 = @Table_SUM_208825624 + @Probe_c_mp3bytes\n"
                             L"SET @Table_SUM_209193568 = @Table_SUM_209193568 + @Probe_c_wavbytes\n"
                             L"SET @Table_c_TotalSongs =  @Table_SUM_201088624 \n"
                             L"SET @Table_c_TotalBytes =  @Table_SUM_208825624  +  @Table_SUM_209193568 \n");
  
  std::vector<DesignTimeGenerator*> generators;
  for(boost::int64_t i=0; i<numInputs; i++)
  {
    DesignTimeGenerator * genProbe = new DesignTimeGenerator();
    genProbe->SetNumRecords(numProbeRecords);
    plan.push_back(genProbe);
    generators.push_back(genProbe);
    genProbe->SetProgram(
      (boost::wformat(L"CREATE PROCEDURE genProbe @groupKey BIGINT @sortKey BIGINT\n"
                      L"@c_songs DECIMAL @c_mp3bytes DECIMAL @c_wavbytes DECIMAL\n"
                      L"AS\n"
                      L"SET @groupKey = @@RECORDCOUNT %% %1%LL\n"
                      L"SET @sortKey = @@RECORDCOUNT\n"
                      L"SET @c_songs = 2.0\n"
                      L"SET @c_mp3bytes = 20000.0\n"
                      L"SET @c_wavbytes = 18000.0\n") % numTableRecords).str());
  }

  // All inputs have same schema and update program.
  std::vector<std::wstring> keys(1, L"groupKey");
  std::vector<DesignTimeHashRunningAggregateInputSpec> runningTotalInputs(
    generators.size(),
    DesignTimeHashRunningAggregateInputSpec(keys, updateProgram));
  DesignTimeHashRunningAggregate * runningTotal = 
    new DesignTimeHashRunningAggregate(runningTotalInputs.size());
  runningTotal->SetInitializeProgram(initializeProgram);
  runningTotal->SetInputSpecs(runningTotalInputs);
  runningTotal->SetName(L"runningTotal");
  runningTotal->AddSortKey(DesignTimeSortKey(L"sortKey", SortOrder::ASCENDING));
  plan.push_back(runningTotal);
  for(std::size_t i = 0; i<generators.size(); i++)
  {
    plan.push_back(new DesignTimeChannel(generators[i]->GetOutputPorts()[0], 
                                         runningTotal->GetInputPorts()[i]));
  }

  DesignTimeDevNull * devNull = new DesignTimeDevNull();
  plan.push_back(devNull);
  plan.push_back(new DesignTimeChannel(runningTotal->GetOutputPorts()[0], devNull->GetInputPorts()[0]));

  ParallelPlan pplan(numPartitions);
  testRun.run(plan, pplan);
}

int test_main( int argc, char * argv[] )
{
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  // Prevent logger creation from perturbing results.
  AutoLogServer performanceHack;

  SYSTEM_INFO si;
  ::GetSystemInfo(&si);

//   TestLocalEndpoint();

//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestGeneratorSmallRecord(std::cout, i, 10000);
//     TestGeneratorSmallRecord(std::cout, i, 100000);
//     TestGeneratorSmallRecord(std::cout, i, 1000000);
//   }
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestGeneratorMediumRecord(std::cout, i, 10000);
//     TestGeneratorMediumRecord(std::cout, i, 100000);
//     TestGeneratorMediumRecord(std::cout, i, 1000000);
//   }
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestGeneratorMediumRecordNoString(std::cout, i, 10000);
//     TestGeneratorMediumRecordNoString(std::cout, i, 100000);
//     TestGeneratorMediumRecordNoString(std::cout, i, 1000000);
//   }
// //     TestGeneratorMediumRecordNoString(std::cout, 1, 4000000);
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestExpression(std::cout, i, 10000);
//     TestExpression(std::cout, i, 100000);
//     TestExpression(std::cout, i, 1000000);
//     TestExpression(std::cout, i, 5000000);
//   }
//     TestExpression(std::cout, 4, 5000000);
  for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
  {
    TestRoundRobinPartitionNonDeterministicCollect(std::cout, i, 10000);
    TestRoundRobinPartitionNonDeterministicCollect(std::cout, i, 100000);
    TestRoundRobinPartitionNonDeterministicCollect(std::cout, i, 1000000);
    TestRoundRobinPartitionNonDeterministicCollect(std::cout, i, 5000000);
  }
//     TestRoundRobinPartitionNonDeterministicCollect(std::cout, 8, 5000000);
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestHashPartitionNonDeterministicCollect(std::cout, i, 10000);
//     TestHashPartitionNonDeterministicCollect(std::cout, i, 100000);
//     TestHashPartitionNonDeterministicCollect(std::cout, i, 1000000);
//     TestHashPartitionNonDeterministicCollect(std::cout, i, 5000000);
//   }
//     TestHashPartitionNonDeterministicCollect(std::cout, 2, 5000000);
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestHashPartitionSortMergeCollect(std::cout, i, 10000);
//     TestHashPartitionSortMergeCollect(std::cout, i, 100000);
//     TestHashPartitionSortMergeCollect(std::cout, i, 1000000);
//   }
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestDatabaseInsert(std::cout, i, 10000);
//     TestDatabaseSelect(std::cout, i, 10000);
//     TestDatabaseInsert(std::cout, i, 100000);
//     TestDatabaseSelect(std::cout, i, 100000);
//     TestDatabaseInsert(std::cout, i, 1000000);
//     TestDatabaseSelect(std::cout, i, 1000000);
//   }
//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i*=2)
//   {
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 10000, 1);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 10000, 10000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 10000, 100000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 10000, 1000000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 100000, 1);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 100000, 10000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 100000, 100000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 100000, 1000000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 1000000, 1);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 1000000, 10000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 1000000, 100000);
//     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 1000000, 1000000);
// //     TestHashJoinUniqueKeyNoPredicate(std::cout, i, 1000000, 10000000);
//   }

//     TestHashJoinUniqueKeyNoPredicate(std::cout, 1, 1000000, 1000000);

//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i *= 2)
//   {
//     for(boost::int64_t numTableRecords=10000LL; numTableRecords<=1000000LL; numTableRecords *= 10LL)
//     {
//       for(boost::int64_t numProbeRecords=10000LL; numProbeRecords<=1000000LL; numProbeRecords *= 10LL)
//       {
//         for(boost::int64_t numRecordsPerKey=1LL; numRecordsPerKey<=100LL; numRecordsPerKey *= 10)
//         {
//           TestHashJoinNonUniqueKeyWithPredicate(std::cout, i, numTableRecords, numProbeRecords, numRecordsPerKey);
//         }
//       }
//     }
//   }

//   for(boost::uint32_t i=1; i<=si.dwNumberOfProcessors; i *= 2)
//   {
//     for(boost::int64_t numTableRecords=10000LL; numTableRecords<=100000LL; numTableRecords *= 10LL)
//     {
//       for(boost::int64_t numProbeRecords=1LL; numProbeRecords<=10LL; numProbeRecords *= 10LL)
//       {
//         for(boost::int64_t numGenerators=1LL; numGenerators<=4LL; numGenerators *= 2)
//         {
//           TestHashRunningTotal(std::cout, i, numTableRecords, numTableRecords*numProbeRecords, numGenerators);
//         }
//       }
//     }
//   }
  return 0;
}
