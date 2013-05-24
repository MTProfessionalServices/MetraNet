#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <stdlib.h>
#include <fstream>
#include <iostream>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <ConstantPool.h>
#include <Scheduler.h>
#include <DatabaseSelect.h>
#include <DatabaseInsert.h>
#include <PlanInterpreter.h>
#include <SortMergeCollector.h>
#include <boost/test/test_tools.hpp>
#include <boost/lexical_cast.hpp>


   

void TestSortMergeCollector()
{
  DesignTimePlan plan;

  DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
  select->SetBaseQuery(L"select id_sess, dt_session, id_acc, id_view from t_acc_usage order by id_sess, dt_session desc");
  plan.push_back(select);

  DesignTimeHashPartitioner * part = new DesignTimeHashPartitioner();
  std::vector<std::wstring> hashKeys;
  hashKeys.push_back(L"id_acc");
  part->SetHashKeys(hashKeys);
  plan.push_back(part);
 
  DesignTimeSortKey * sortKey1 = new DesignTimeSortKey(L"id_sess",SortOrder::ASCENDING );
  DesignTimeSortKey * sortKey2 = new DesignTimeSortKey(L"dt_session", SortOrder::DESCENDING );
 
  DesignTimeSortMergeCollector * coll = new DesignTimeSortMergeCollector();
  coll->SetMode(DesignTimeOperator::SEQUENTIAL);
  coll->AddSortKey(sortKey1);
  coll->AddSortKey(sortKey2);
 
  plan.push_back(coll);

  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  insert->SetTableName(L"t_sortmerge_coll_test");
  insert->SetCreateTable(true);
  insert->SetMode(DesignTimeOperator::SEQUENTIAL);
  plan.push_back(insert);
  
  plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], part->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(part->GetOutputPorts()[0], coll->GetInputPorts()[0]));
  plan.push_back(new DesignTimeChannel(coll->GetOutputPorts()[0], insert->GetInputPorts()[0]));
  plan.type_check();
  ParallelPlan pplan(2);
  plan.code_generate(pplan);
  BOOST_REQUIRE(1 == pplan.GetNumDomains());
  pplan.GetDomain(0)->Start();
}



int test_main( int argc, char * argv[] )
{
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);

    TestSortMergeCollector();
    //TestDatabaseTableCopy();
   
    std::cout << "All tests succeeded" << std::endl;
    return 0;
}
