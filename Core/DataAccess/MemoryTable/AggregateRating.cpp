#include <boost/format.hpp>
#include <boost/algorithm/string.hpp>

#include "PlanInterpreter.h"
#include "Scheduler.h"
#include "DatabaseSelect.h"
#include "HashAggregate.h"
#include "DesignTimeExpression.h"

#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"

#include <memory>


std::wstring AggregateRating::GetUsageIntervalIDsPredicate(const std::wstring& prefix)
{
  std::wstring intervalPredicate;
  for(std::vector<boost::int32_t>::const_iterator it = mRatedUsage.GetUsageIntervalIDs().begin();
      it != mRatedUsage.GetUsageIntervalIDs().end();
      ++it)
  {
    if (it != mRatedUsage.GetUsageIntervalIDs().begin())
      intervalPredicate += L" OR ";
    intervalPredicate += (boost::wformat(L"%1% = %2%") % prefix % *it).str();
  }
  return intervalPredicate;
}

DesignTimeSortMergeCollector * AggregateRating::CreateSortMergeCollector(const std::wstring& name)
{
  DesignTimeSortMergeCollector * ratedUsageColl = new DesignTimeSortMergeCollector();
  ratedUsageColl->SetName(name);
  ratedUsageColl->AddSortKey(new DesignTimeSortKey(L"c_BillingIntervalEnd",SortOrder::ASCENDING ));
  ratedUsageColl->AddSortKey(new DesignTimeSortKey(L"c_SessionDate",SortOrder::ASCENDING ));
  ratedUsageColl->AddSortKey(new DesignTimeSortKey(L"id_parent_sess",SortOrder::ASCENDING ));
  ratedUsageColl->AddSortKey(new DesignTimeSortKey(L"id_sess",SortOrder::ASCENDING ));
  return ratedUsageColl;
}

DesignTimeAssertSortOrder * AggregateRating::CreateAssertSortOrder(const std::wstring& name)
{
  DesignTimeAssertSortOrder * assertSortOrder = new DesignTimeAssertSortOrder();
  assertSortOrder->SetName(name);
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"c_BillingIntervalEnd",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"c_SessionDate",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"id_parent_sess",SortOrder::ASCENDING ));
  assertSortOrder->AddSortKey(DesignTimeSortKey(L"id_sess",SortOrder::ASCENDING ));
  return assertSortOrder;
}

std::wstring AggregateRating::GetRatedUsageSelectList(const std::wstring& ratedUsageTable)
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");  
  std::auto_ptr<COdbcConnection> conn(new COdbcConnection(netMeter));
  
	std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
  std::string cat = conn->GetConnectionInfo().GetCatalogPrefix();
  std::wstring wstrCat;
  ::ASCIIToWide(wstrCat, cat);
  std::auto_ptr<COdbcResultSet> rs(stmt->ExecuteQueryW(L"select * from " + wstrCat + ratedUsageTable + L" where 0=1"));

  std::wstring selectList;

  COdbcColumnMetadataVector meta = rs->GetMetadata();
  for(std::size_t i = 0; i < meta.size(); i++)
  {
    std::string colName = boost::to_lower_copy(meta[i]->GetColumnName());
    if (colName != "id_sess" && colName != "id_usage_interval")
    {
      std::wstring wstrColName;
      ::ASCIIToWide(wstrColName, colName);
      selectList += L", pv.";
      selectList += wstrColName;
    }
  }

  return selectList;
}

void AggregateRating::ReadRatedUsageAndCountables(boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> >& countableOutput)
{
  // For rated usage we need all of the product view properties.
  // If the rated usage is also a countable then we need to read
  // all of the usage independent of usage interval.  If the rated
  // usage is not also a countable then we only need to read from the
  // specified interval.
  std::wstring intervalPredicate(L"");
  if (!mIsRatedUsageCountable)
  {
    intervalPredicate = L"AND (";
    intervalPredicate += GetUsageIntervalIDsPredicate(L"au.id_usage_interval");
    intervalPredicate += L")";
  }

  std::wstring productViewJoin;
  std::wstring productViewColumns;
  if (!mReadAllRatedUsageColumns)
  {
    if (mIsRatedUsageCountable)
    {
      productViewJoin = (boost::wformat(L"INNER JOIN %1% pv ON au.id_sess=pv.id_sess AND au.id_usage_interval=pv.id_usage_interval\n") % mRatedUsage.GetTableName()).str();
      // Get the reference columns from the corresponding countable spec.
      for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
          it != mCountables.end();
          it++)
      {
        if (it->GetTableName() == mRatedUsage.GetTableName()) 
        {
          for(std::set<std::wstring>::const_iterator colIt = it->GetReferencedColumns().begin();
              colIt != it->GetReferencedColumns().end();
              colIt++)
          {
            productViewColumns += L", pv.";
            productViewColumns += *colIt;
          }
          break;
        }
      }
    }
    else
    {
      // Don't even join the product view
    }
  }
  else
  {
    productViewJoin = (boost::wformat(L"INNER JOIN %1% pv ON au.id_sess=pv.id_sess AND au.id_usage_interval=pv.id_usage_interval\n") % mRatedUsage.GetTableName()).str();
    productViewColumns  = GetRatedUsageSelectList(mRatedUsage.GetTableName());
  }


  // If we are doing estimates, we want to allow reguiding of intervals (CR9065).
  std::wstring intervalColumn;
  if (!mRatedUsage.IsEstimate())
  {
    intervalColumn = L",au.id_usage_interval AS c__IntervalID\n";
  }

  DesignTimeDatabaseSelect * ratedUsage = new DesignTimeDatabaseSelect();
  //////////////////////////////////////////////////////////////
  // PMNA Testing Hack
  // Save time by avoiding the join and order by.
  // I can work on other bugs :-)
//   std::wstring countableColumns;
//   std::wstring sourceTable;
//   switch(mRatedUsage.GetViewID())
//   {
//   case 3551:
//     countableColumns = L", c_QualifiedMinutes";
//     sourceTable = L"tmp_pv_confconn_temp";
//     break;
//   case 3552:
//     countableColumns = L"";
//     sourceTable = L"tmp_pv_conference_temp";
//     break;
//   case 3553:
//     countableColumns = L"";
//     sourceTable = L"tmp_pv_conffeature_temp";
//     break;
//   default:
//     throw std::exception("HACK IS BROKEN");
//   }
//   boost::wformat fmt (
//            L"SELECT \n"
//            L"id_sess\n"
//            L",id_parent_sess\n" 
//            L",id_usage_interval\n"
//            L",c_ViewId\n"
//            L",c__PayingAccount\n"
//            L",c__AccountID\n"
//            L",c__PriceableItemTemplateID\n" 
//            L",c__PriceableItemInstanceID\n"
//            L",c__ProductOfferingID\n"
//            L",c__FirstPassID\n"
//            L",c_CreationDate\n"
//            L",c_SessionDate\n"
//            L",c_BillingIntervalStart\n"
//            L",c_BillingIntervalEnd\n"
//            L",c_OriginalSessionTimestamp\n"
//            L"%1%\n"
//            L"FROM  %2%\n"
//            L"WHERE {fn MOD(id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n"
// //            L"AND isnull(id_parent_sess,id_sess) <= 1061201335\n"
//            L"ORDER BY c_BillingIntervalEnd, c_SessionDate, id_parent_sess, id_sess");
//   fmt % countableColumns % sourceTable;
  // End PMNA Hack
  //////////////////////////////////////////////////////////////
  boost::wformat fmt (
           L"SELECT\n"
           L"au.id_sess\n"
           L",au.id_parent_sess\n" 
           L",au.id_usage_interval\n"
           L",au.id_view AS c_ViewId\n"
           L",au.id_acc AS c__PayingAccount\n"
           L",au.id_payee AS c__AccountID\n"
           L",au.dt_crt AS c_CreationDate\n"
           L",au.dt_session AS c_SessionDate\n"
           L",au.id_pi_template AS c__PriceableItemTemplateID\n" 
           L",au.id_pi_instance AS c__PriceableItemInstanceID\n"
           L",au.id_prod AS c__ProductOfferingID\n"
           L",ui.dt_start AS c_BillingIntervalStart\n"
           L",ui.dt_end AS c_BillingIntervalEnd\n"
           L",au.dt_session AS c_OriginalSessionTimestamp\n"
           L",au.id_sess AS c__FirstPassID\n"
           L"%1% %2%\n"
           L"FROM t_acc_usage au\n"
           L"%3%"
           L"INNER JOIN t_usage_interval ui ON ui.id_interval = au.id_usage_interval\n"
           L"WHERE au.id_view=%4% AND au.id_pi_template=%5% %6%\n"
           L"AND {fn MOD(au.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n"
           L"ORDER BY ui.dt_end, au.dt_session, au.id_parent_sess, au.id_sess");
  fmt % intervalColumn % productViewColumns % productViewJoin %
    mRatedUsage.GetViewID() % mRatedUsage.GetPriceableItemTemplateID() % intervalPredicate;
  ratedUsage->SetBaseQuery(fmt.str());
  ratedUsage->SetName((boost::wformat(L"ratedUsage(%1%)") % mRatedUsage.GetTableName()).str());
  mPlan.push_back(ratedUsage);

//   DesignTimeAssertSortOrder * assertSortOrder = CreateAssertSortOrder((boost::wformat(L"assertSortOrder(%1%)") % mRatedUsage.GetTableName()).str());
//   mPlan.push_back(assertSortOrder);
//   mPlan.push_back(new DesignTimeChannel(ratedUsage->GetOutputPorts()[0], 
//                                         assertSortOrder->GetInputPorts()[0]));
  
  
  DesignTimeHashPartitioner * ratedUsagePart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> idPayeeHashKeys;
  idPayeeHashKeys.push_back(L"c__AccountID");
  ratedUsagePart->SetHashKeys(idPayeeHashKeys);
  ratedUsagePart->SetName((boost::wformat(L"ratedUsagePart(%1%)") % mRatedUsage.GetTableName()).str());
  mPlan.push_back(ratedUsagePart);
  mPlan.push_back(new DesignTimeChannel(ratedUsage->GetOutputPorts()[0], 
                                        ratedUsagePart->GetInputPorts()[0]));

  DesignTimeSortMergeCollector * ratedUsageColl = 
    CreateSortMergeCollector((boost::wformat(L"ratedUsageColl(%1%)") % mRatedUsage.GetTableName()).str());
  mPlan.push_back(ratedUsageColl);
  mPlan.push_back(new DesignTimeChannel(ratedUsagePart->GetOutputPorts()[0], 
                                        ratedUsageColl->GetInputPorts()[0]));

//   DesignTimeAssertSortOrder * assertSortOrder = CreateAssertSortOrder((boost::wformat(L"assertSortOrder(%1%)") % mRatedUsage.GetTableName()).str());
//   mPlan.push_back(assertSortOrder);
//   mPlan.push_back(new DesignTimeChannel(ratedUsageColl->GetOutputPorts()[0], 
//                                         assertSortOrder->GetInputPorts()[0]));

  // Annotate the rated usage with isCountable and isRated flags. 
  DesignTimeExpression * ratedUsageClassification = new DesignTimeExpression();
  ratedUsageClassification->SetName((boost::wformat(L"ratedUsageClassification(%1%)") % mRatedUsage.GetTableName()).str());
  mPlan.push_back(ratedUsageClassification);
  mPlan.push_back(new DesignTimeChannel(ratedUsageColl->GetOutputPorts()[0],
                                        ratedUsageClassification->GetInputPorts()[0]));

  /////////////////////////////////////////
  // PMNA Hack: id_sess, id_parent_sess are defined as INTEGER for testing on a 4.0
  // database.
  /////////////////////////////////////////  
  ratedUsageClassification->SetProgram(
    (boost::wformat(
      L"CREATE PROCEDURE ratedUsageClassification @id_usage_interval INTEGER\n"
      L"@id_sess BIGINT\n"
      L"@id_parent_sess BIGINT\n"
      L"@c__PriceableItemTemplateID INTEGER\n"
      L"@c__PriceableItemInstanceID INTEGER\n"
      L"@is_countable BOOLEAN OUTPUT\n"
      L"@is_rated BOOLEAN OUTPUT\n"
      L"@id_compound_sess BIGINT OUTPUT\n"
      L"@id_pi_template_instance INTEGER OUTPUT\n"
      L"AS\n"
      L"SET @id_compound_sess = CASE WHEN @id_parent_sess IS NULL THEN @id_sess ELSE @id_parent_sess END\n"
      L"SET @is_rated = CASE WHEN (%1%) THEN TRUE ELSE FALSE END\n"
      L"SET @is_countable = %2%\n"
      L"SET @id_pi_template_instance = CASE WHEN @c__PriceableItemInstanceID IS NULL THEN @c__PriceableItemTemplateID ELSE @c__PriceableItemInstanceID END\n") 
     % GetUsageIntervalIDsPredicate(L"@id_usage_interval") % (mIsRatedUsageCountable ? L"TRUE" : L"FALSE")).str());

  // Define our output interface
  ratedUsageOutput = ratedUsageClassification->GetOutputPorts()[0];

  for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() != mRatedUsage.GetTableName()) 
    {
      // Read countables from product views other than the rated usage table

      // Collect all of the referenced columns into a select list
      std::wstring pvSelectList;
      for(std::set<std::wstring>::const_iterator colIt = it->GetReferencedColumns().begin();
          colIt != it->GetReferencedColumns().end();
          colIt++)
      {
        pvSelectList += L", pv.";
        pvSelectList += *colIt;
      }

      boost::wformat query(
        L"SELECT\n"
        L"au.id_sess\n"
        L",au.id_parent_sess\n" 
        L",au.id_usage_interval\n"
        L",au.id_view AS c_ViewId\n"
        L",au.id_acc AS c__PayingAccount\n"
        L",au.id_payee AS c__AccountID\n"
        L",au.dt_crt AS c_CreationDate\n"
        L",au.dt_session AS c_SessionDate\n"
        L",au.id_pi_template AS c__PriceableItemTemplateID\n" 
        L",au.id_pi_instance AS c__PriceableItemInstanceID\n"
        L",au.id_prod AS c__ProductOfferingID\n"
        L",ui.dt_start AS c_BillingIntervalStart\n"
        L",ui.dt_end AS c_BillingIntervalEnd\n"
        L"%1% "
        L"FROM t_acc_usage au\n"
        L"INNER JOIN %2% pv ON au.id_sess=pv.id_sess\n"
        L"INNER JOIN t_usage_interval ui ON ui.id_interval = au.id_usage_interval\n"
        L"WHERE au.id_view=%3%\n"
        L"AND {fn MOD(au.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n"
        L"ORDER BY ui.dt_end, au.dt_session, au.id_parent_sess, au.id_sess");
      query % pvSelectList % it->GetTableName() % it->GetViewID();
    
    
      DesignTimeDatabaseSelect * countableUsage = new DesignTimeDatabaseSelect();
      countableUsage->SetBaseQuery(query.str());
      countableUsage->SetName((boost::wformat(L"countable(%1%)") % it->GetTableName()).str());
      mPlan.push_back(countableUsage);

      DesignTimeHashPartitioner * countableUsagePart = new DesignTimeHashPartitioner();
      countableUsagePart->SetHashKeys(idPayeeHashKeys);
      countableUsagePart->SetName((boost::wformat(L"countablePart(%1%)") % it->GetTableName()).str());
      mPlan.push_back(countableUsagePart);
      mPlan.push_back(new DesignTimeChannel(countableUsage->GetOutputPorts()[0], 
                                            countableUsagePart->GetInputPorts()[0]));

      DesignTimeSortMergeCollector * countableUsageColl = 
        CreateSortMergeCollector((boost::wformat(L"countableColl(%1%)") % it->GetTableName()).str());
      mPlan.push_back(countableUsageColl);
      mPlan.push_back(new DesignTimeChannel(countableUsagePart->GetOutputPorts()[0], 
                                            countableUsageColl->GetInputPorts()[0]));
      countableOutput.push_back(countableUsageColl->GetOutputPorts()[0]);
//       {
//         // Debugging print
//         DesignTimePrint * prnt = new DesignTimePrint();
//         mPlan.push_back(prnt);
//         mPlan.push_back(new DesignTimeChannel(countableOutput.back(), 
//                                               prnt->GetInputPorts()[0]));
//         countableOutput.pop_back();
//         countableOutput.push_back(prnt->GetOutputPorts()[0]);

//       }
    }
  }

  ASSERT(ratedUsageOutput != NULL);

  if (mRatedUsage.GetBillingGroupID() != -1)
  {
    boost::shared_ptr<Port> tmp;
    FilterRatedUsageOnBillingGroup(ratedUsageOutput, tmp);
    ratedUsageOutput = tmp;
  }

//    {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     mPlan.push_back(prnt);
//     mPlan.push_back(new DesignTimeChannel(ratedUsageOutput, 
//                                           prnt->GetInputPorts()[0]));
//     ratedUsageOutput = prnt->GetOutputPorts()[0];

//    }
}

void AggregateRating::FilterRatedUsageOnBillingGroup(boost::shared_ptr<Port> ratedUsage, boost::shared_ptr<Port> & outputRatedUsage)
{
  // Filter on billing group.
  // TODO: Optimize a bit by doing this prior to partitioning on payee,
  // so we can avoid a repartition.  Note that this isn't a huge win (or maybe none at all)
  // since in the common case in which rated is also countable we still
  // have to partition countable on payee.
  DesignTimeHashPartitioner * ratedUsagePayerRepartition = new DesignTimeHashPartitioner();
  std::vector<std::wstring> idAccHashKeys;
  idAccHashKeys.push_back(L"c__PayingAccount");
  ratedUsagePayerRepartition->SetHashKeys(idAccHashKeys);
  ratedUsagePayerRepartition->SetName(L"ratedUsagePayerRepartition");
  mPlan.push_back(ratedUsagePayerRepartition);
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        ratedUsagePayerRepartition->GetInputPorts()[0]));

  DesignTimeSortMergeCollector * ratedUsagePayerRepartitionColl = 
    CreateSortMergeCollector(L"ratedUsagePayerRepartitionColl");
  mPlan.push_back(ratedUsagePayerRepartitionColl);
  mPlan.push_back(new DesignTimeChannel(ratedUsagePayerRepartition->GetOutputPorts()[0], 
                                        ratedUsagePayerRepartitionColl->GetInputPorts()[0]));

  boost::wformat query(
    L"SELECT bgm.id_acc as bgm_id_acc "
    L"FROM t_billgroup_member bgm "
    L"WHERE bgm.id_billgroup=%1% "
    L"AND {fn MOD(bgm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%");
  query % mRatedUsage.GetBillingGroupID();
  DesignTimeDatabaseSelect * billGroupMember = new DesignTimeDatabaseSelect();
  billGroupMember->SetBaseQuery(query.str());
  billGroupMember->SetName(L"billGroupMember");
  mPlan.push_back(billGroupMember);

  DesignTimeHashPartitioner * billGroupMemberPart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> bgmHashKeys;
  bgmHashKeys.push_back(L"bgm_id_acc");
  billGroupMemberPart->SetHashKeys(bgmHashKeys);
  billGroupMemberPart->SetName(L"billGroupMemberPart");
  mPlan.push_back(billGroupMemberPart);
  mPlan.push_back(new DesignTimeChannel(billGroupMember->GetOutputPorts()[0], 
                                        billGroupMemberPart->GetInputPorts()[0]));

  DesignTimeNondeterministicCollector * billGroupMemberColl = new DesignTimeNondeterministicCollector();
  billGroupMemberColl->SetName(L"billGroupMemberColl");
  mPlan.push_back(billGroupMemberColl);
  mPlan.push_back(new DesignTimeChannel(billGroupMemberPart->GetOutputPorts()[0], 
                                        billGroupMemberColl->GetInputPorts()[0]));

  DesignTimeHashJoin * billGroupMemberJoin = new DesignTimeHashJoin();
  billGroupMemberJoin->SetName(L"billGroupMemberJoin");
  std::vector<std::wstring> idGroupMemberJoinKeys;
  idGroupMemberJoinKeys.push_back(L"bgm_id_acc");
  billGroupMemberJoin->SetTableEquiJoinKeys(idGroupMemberJoinKeys);
  DesignTimeHashJoinProbeSpecification billGroupMemberJoinSpec;
  std::vector<std::wstring> idPayerJoinKeys;
  idPayerJoinKeys.push_back(L"c__PayingAccount");
  billGroupMemberJoinSpec.SetEquiJoinKeys(idPayerJoinKeys);
  billGroupMemberJoinSpec.SetJoinType(mIsRatedUsageCountable ? DesignTimeHashJoinProbeSpecification::RIGHT_OUTER : DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  billGroupMemberJoin->AddProbeSpecification(billGroupMemberJoinSpec);
  mPlan.push_back(billGroupMemberJoin);
  mPlan.push_back(new DesignTimeChannel(billGroupMemberColl->GetOutputPorts()[0], 
                                        billGroupMemberJoin->GetInputPorts()[L"table"]));
  mPlan.push_back(new DesignTimeChannel(ratedUsagePayerRepartitionColl->GetOutputPorts()[0], 
                                        billGroupMemberJoin->GetInputPorts()[L"probe(0)"]));


  if (mIsRatedUsageCountable)
  {
    // If not on our current bill group unset the is_rated flag but leave it in the stream
    // (even if the record isn't to be rated we may have to count it).  
    DesignTimeExpression * billGroupIsRatedFlag = new DesignTimeExpression();
    billGroupIsRatedFlag->SetName(L"billGroupIsRatedFlag");
    billGroupIsRatedFlag->SetProgram(
      L"CREATE PROCEDURE billGroupIsRatedFlag @bgm_id_acc INTEGER\n"
      L"@is_rated BOOLEAN\n"
      L"AS\n"
      L"SET @is_rated = CASE WHEN (@bgm_id_acc IS NULL) THEN FALSE ELSE @is_rated END");
    mPlan.push_back(billGroupIsRatedFlag);
    mPlan.push_back(new DesignTimeChannel(billGroupMemberJoin->GetOutputPorts()[L"output(0)"],
                                          billGroupIsRatedFlag->GetInputPorts()[0]));

    // Don't worry about repartitioning here.  If this usage has no counters then
    // we'll be repartitioning on id_sess/id_parent_sess.  If there are counters then
    // downstream logic will handle reparititoning on payee.
    outputRatedUsage = billGroupIsRatedFlag->GetOutputPorts()[0];
  }
  else
  {
    outputRatedUsage = billGroupMemberJoin->GetOutputPorts()[L"output(0)"];
  }

//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     prnt->SetNumToPrint(100);
//     mPlan.push_back(prnt);
//     mPlan.push_back(new DesignTimeChannel(outputRatedUsage, 
//                                           prnt->GetInputPorts()[0]));
//     outputRatedUsage = prnt->GetOutputPorts()[0];
//   }

}

void AggregateRating::GuideRatedUsageToBillingCycleAndPriceableItem(boost::shared_ptr<Port> ratedUsage, boost::shared_ptr<Port> & outputRatedUsage)
{
  DesignTimeDatabaseSelect * aggregateSelect = new DesignTimeDatabaseSelect();
  aggregateSelect->SetBaseQuery(L"SELECT id_prop as ag_id_prop, id_usage_cycle as ag_id_cycle "
                                L"FROM t_aggregate");
  aggregateSelect->SetMode(DesignTimeOperator::SEQUENTIAL);
  aggregateSelect->SetName(L"aggregateSelect");
  mPlan.push_back(aggregateSelect);
  DesignTimeBroadcastPartitioner * aggregatePart = new DesignTimeBroadcastPartitioner();
  aggregatePart->SetMode(DesignTimeOperator::SEQUENTIAL);
  aggregatePart->SetName(L"aggregatePart");
  mPlan.push_back(aggregatePart);
  mPlan.push_back(new DesignTimeChannel(aggregateSelect->GetOutputPorts()[0], 
                                        aggregatePart->GetInputPorts()[0]));

  DesignTimeHashJoin * ratedUsageAggregateJoin = new DesignTimeHashJoin();
  ratedUsageAggregateJoin->SetName(L"ratedUsageAggregateJoin");
  std::vector<std::wstring> idAgIdPropJoinKeys;
  idAgIdPropJoinKeys.push_back(L"ag_id_prop");
  ratedUsageAggregateJoin->SetTableEquiJoinKeys(idAgIdPropJoinKeys);
  ratedUsageAggregateJoin->SetTableSize(1000);
  DesignTimeHashJoinProbeSpecification ratedUsageAggregateJoinSpec;
  std::vector<std::wstring> idTemplateInstanceJoinKeys;
  idTemplateInstanceJoinKeys.push_back(L"id_pi_template_instance");
  ratedUsageAggregateJoinSpec.SetEquiJoinKeys(idTemplateInstanceJoinKeys);
  ratedUsageAggregateJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  ratedUsageAggregateJoin->AddProbeSpecification(ratedUsageAggregateJoinSpec);
  mPlan.push_back(ratedUsageAggregateJoin);
  mPlan.push_back(new DesignTimeChannel(aggregatePart->GetOutputPorts()[0], 
                                        ratedUsageAggregateJoin->GetInputPorts()[L"table"]));
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        ratedUsageAggregateJoin->GetInputPorts()[L"probe(0)"]));


  // For individual usage, the BCR case requires the payer usage cycle.
  // We get that cycle from the usage interval of each usage record.
  DesignTimeDatabaseSelect * accUsageCycleSelect = new DesignTimeDatabaseSelect();
  accUsageCycleSelect->SetMode(DesignTimeOperator::SEQUENTIAL);
  accUsageCycleSelect->SetBaseQuery(L"SELECT ui.id_interval as auc_id_interval, ui.id_usage_cycle as auc_id_cycle\n"
                                    L"FROM t_usage_interval ui\n");
  accUsageCycleSelect->SetName(L"accUsageCycleSelect");
  mPlan.push_back(accUsageCycleSelect);
  DesignTimeBroadcastPartitioner * accUsageCyclePart = new DesignTimeBroadcastPartitioner();
  accUsageCyclePart->SetMode(DesignTimeOperator::SEQUENTIAL);
  mPlan.push_back(accUsageCyclePart);
  mPlan.push_back(new DesignTimeChannel(accUsageCycleSelect->GetOutputPorts()[0], 
                                        accUsageCyclePart->GetInputPorts()[0]));

  DesignTimeHashJoin * ratedUsageAccUsageCycleJoin = new DesignTimeHashJoin();
  ratedUsageAccUsageCycleJoin->SetName(L"ratedUsageAccUsageCycleJoin");
  std::vector<std::wstring> idAucIdAccJoinKeys;
  idAucIdAccJoinKeys.push_back(L"auc_id_interval");
  ratedUsageAccUsageCycleJoin->SetTableEquiJoinKeys(idAucIdAccJoinKeys);
  DesignTimeHashJoinProbeSpecification ratedUsageAccUsageCycleJoinSpec;
  std::vector<std::wstring> idPayeeJoinKeys;
  idPayeeJoinKeys.push_back(L"id_usage_interval");
  ratedUsageAccUsageCycleJoinSpec.SetEquiJoinKeys(idPayeeJoinKeys);
  ratedUsageAccUsageCycleJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  ratedUsageAccUsageCycleJoin->AddProbeSpecification(ratedUsageAccUsageCycleJoinSpec);
  mPlan.push_back(ratedUsageAccUsageCycleJoin);
  mPlan.push_back(new DesignTimeChannel(accUsageCyclePart->GetOutputPorts()[0], 
                                        ratedUsageAccUsageCycleJoin->GetInputPorts()[L"table"]));
  mPlan.push_back(new DesignTimeChannel(ratedUsageAggregateJoin->GetOutputPorts()[L"output(0)"], 
                                        ratedUsageAccUsageCycleJoin->GetInputPorts()[L"probe(0)"]));
    

  outputRatedUsage = ratedUsageAccUsageCycleJoin->GetOutputPorts()[L"output(0)"];
}

void AggregateRating::GuideToGroupSubscriptions(
  boost::int32_t id_pi_template,
  boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
  boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput)
{
  // Now guide the transactions to subscriptions to figure out the associated counter.
  // In the group subscription case, the group subscription product offering must contain
  // the rated record template.  In the individual case we don't require subscriptions at all.
  DesignTimeDatabaseSelect * gsubmemberSelect = new DesignTimeDatabaseSelect();
  wchar_t buf[1024];
  wsprintf(buf,
           L"SELECT gsm.id_acc as gsm_id_acc, plm.id_pi_instance as gsm_id_pi_instance, gsm.id_group as gsm_id_group, gs.b_supportgroupops gsm_shared_flag, ag.id_usage_cycle as gsm_ag_id_cycle, gs.id_usage_cycle as gsm_id_cycle, gsm.vt_start as gsm_vt_start, gsm.vt_end as gsm_vt_end "
           L"FROM t_gsubmember gsm "
           L"INNER JOIN t_group_sub gs ON gs.id_group=gsm.id_group "
           L"INNER JOIN t_sub s ON s.id_group=gs.id_group "
           L"INNER JOIN t_pl_map plm ON plm.id_po=s.id_po "
           L"INNER JOIN t_aggregate ag ON plm.id_pi_instance=ag.id_prop "
           L"WHERE plm.id_paramtable IS NULL AND plm.id_pi_template=%d "
           L"AND {fn MOD(gsm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%"
           , id_pi_template);
  gsubmemberSelect->SetBaseQuery(buf);
  gsubmemberSelect->SetName(L"gsubmemberSelect");
  mPlan.push_back(gsubmemberSelect);
  DesignTimeHashPartitioner * gsubmemberPart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> idAccHashKeys;
  idAccHashKeys.push_back(L"gsm_id_acc");
  gsubmemberPart->SetHashKeys(idAccHashKeys);
  gsubmemberPart->SetName(L"gsubmemberPart");
  mPlan.push_back(gsubmemberPart);
  mPlan.push_back(new DesignTimeChannel(gsubmemberSelect->GetOutputPorts()[0], 
                                       gsubmemberPart->GetInputPorts()[0]));

  DesignTimeNondeterministicCollector * gsubmemberColl = new DesignTimeNondeterministicCollector();
  gsubmemberColl->SetName(L"gsubmemberColl");
  mPlan.push_back(gsubmemberColl);
  mPlan.push_back(new DesignTimeChannel(gsubmemberPart->GetOutputPorts()[0], 
                                        gsubmemberColl->GetInputPorts()[0]));

  // A remaining open question is whether the pi_instance comparison
  // needs to be in the predicate for rated records (we have actually already filtered out on template
  // in the select and then date range gives a unique sub anyway I think).
  DesignTimeHashJoin * ratedUsageGsubmemberJoin = new DesignTimeHashJoin();
  mPlan.push_back(ratedUsageGsubmemberJoin);
  ratedUsageGsubmemberJoin->SetName(L"ratedUsageGsubmemberJoin");
  std::vector<std::wstring> idGsmAccJoinKeys;
  idGsmAccJoinKeys.push_back(L"gsm_id_acc");
  ratedUsageGsubmemberJoin->SetTableEquiJoinKeys(idGsmAccJoinKeys);
  mPlan.push_back(new DesignTimeChannel(gsubmemberColl->GetOutputPorts()[0], 
                                        ratedUsageGsubmemberJoin->GetInputPorts()[L"table"]));

  // Probe Specification for guiding rated usage to group sub.
  DesignTimeHashJoinProbeSpecification ratedUsageGsubmemberJoinSpec;
  std::vector<std::wstring> idPayeeInstanceJoinKeys;
  idPayeeInstanceJoinKeys.push_back(L"c__AccountID");
  ratedUsageGsubmemberJoinSpec.SetEquiJoinKeys(idPayeeInstanceJoinKeys);
  ratedUsageGsubmemberJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER);
  ratedUsageGsubmemberJoinSpec.SetResidual(
    L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_gsm_vt_start DATETIME @Table_gsm_vt_end DATETIME\n"
    L"@Probe_c__PriceableItemInstanceID INTEGER @Table_gsm_id_pi_instance INTEGER) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_c_SessionDate >= @Table_gsm_vt_start AND @Probe_c_SessionDate <= @Table_gsm_vt_end\n"
    L"AND @Table_gsm_id_pi_instance = @Probe_c__PriceableItemInstanceID");
  ratedUsageGsubmemberJoin->AddProbeSpecification(ratedUsageGsubmemberJoinSpec);
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        ratedUsageGsubmemberJoin->GetInputPorts()[L"probe(0)"]));

  DesignTimeExpression * ratedUsageGroupSubscriptionFlag = new DesignTimeExpression();
  ratedUsageGroupSubscriptionFlag->SetName(L"ratedUsageGroupSubscriptionFlag");
  ratedUsageGroupSubscriptionFlag->SetProgram(
    L"CREATE PROCEDURE ratedUsageGroupSubscriptionFlag @gsm_id_acc INTEGER\n"
    L"@gsm_shared_flag VARCHAR\n"
    L"@is_shared_counter BOOLEAN OUTPUT\n"
    L"AS\n"
    L"SET @is_shared_counter = CASE WHEN (NOT @gsm_id_acc IS NULL) AND @gsm_shared_flag = 'Y' THEN TRUE ELSE FALSE END");
  mPlan.push_back(ratedUsageGroupSubscriptionFlag);
  mPlan.push_back(new DesignTimeChannel(ratedUsageGsubmemberJoin->GetOutputPorts()[L"output(0)"],
                                        ratedUsageGroupSubscriptionFlag->GetInputPorts()[0]));
  ratedUsageOutput = ratedUsageGroupSubscriptionFlag->GetOutputPorts()[0];

  for(std::size_t i=0; i<countables.size(); i++)
  {
    wchar_t buf[64];
    wsprintf(buf, L"probe(%d)", i+1);
    // Probe Specification for guiding countable usage to group sub.
    DesignTimeHashJoinProbeSpecification countableGsubmemberJoinSpec;
    countableGsubmemberJoinSpec.SetEquiJoinKeys(idPayeeInstanceJoinKeys);
    countableGsubmemberJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER);
    countableGsubmemberJoinSpec.SetResidual(
      L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_gsm_vt_start DATETIME @Table_gsm_vt_end DATETIME)\n"
      L"RETURNS BOOLEAN\n"
      L"AS\n"
      L"RETURN @Probe_c_SessionDate >= @Table_gsm_vt_start AND @Probe_c_SessionDate <= @Table_gsm_vt_end");
    ratedUsageGsubmemberJoin->AddProbeSpecification(countableGsubmemberJoinSpec);
    mPlan.push_back(new DesignTimeChannel(countables[i], 
                                          ratedUsageGsubmemberJoin->GetInputPorts()[buf]));
    
    DesignTimeExpression * countableGroupSubscriptionFlag = new DesignTimeExpression();
    countableGroupSubscriptionFlag->SetName(
      (boost::wformat(L"countable(%1%)GroupSubscriptionFlag") % i).str());
    countableGroupSubscriptionFlag->SetProgram(
      L"CREATE PROCEDURE countableGroupSubscriptionFlag @gsm_id_acc INTEGER \n"
      L"@gsm_shared_flag VARCHAR\n"
      L"@is_shared_counter BOOLEAN OUTPUT\n"
      L"AS\n"
      L"SET @is_shared_counter = CASE WHEN (NOT @gsm_id_acc IS NULL) AND @gsm_shared_flag = 'Y' THEN TRUE ELSE FALSE END");
    mPlan.push_back(countableGroupSubscriptionFlag);
    wsprintf(buf, L"output(%d)", i+1);
    mPlan.push_back(new DesignTimeChannel(ratedUsageGsubmemberJoin->GetOutputPorts()[buf],
                                          countableGroupSubscriptionFlag->GetInputPorts()[0]));
    countablesOutput.push_back(countableGroupSubscriptionFlag->GetOutputPorts()[0]);
  }
}

// At the metadata level this performs:
//
// ratedUsage(@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR,  ...) 
// -------------> 
// ratedUsage(@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER,  ...) 
//
// countable (@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR,  ...) 
// -------------> 
// countable (@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER,  ...) 
//
void AggregateRating::ProcessGroupSubscriptions(boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
                                                boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput)
{
  // Countables and rated usage are handled the same with group subs.  Each usage record
  // contributes to exactly one counter stream: the one associated with the group sub in effect
  // at the time the usage record occurred.
  // There are two sub cases depending on whether shared counters are configured or not.  In the
  // case of shared counters, the group subscription id identifies the counter stream in the non-shared
  // counter case, the group subscription member (id_payee of the usage record) identifies the counter
  // stream.  In all cases, we need to take care to keep the different cases separate so we put in
  // a counter stream type.
  const wchar_t expr [] =     
    L"CREATE PROCEDURE expr "
    L"@is_shared_counter BOOLEAN\n"
    L"@gsm_ag_id_cycle INTEGER @gsm_id_cycle INTEGER @id_counter_stream_cycle INTEGER\n"
    L"@gsm_id_group INTEGER @c__AccountID INTEGER @gsm_shared_flag VARCHAR @id_counter_stream INTEGER\n"
    L"@counter_stream_type INTEGER "
    L"AS\n"
    L"IF @is_shared_counter\n"
    L"BEGIN\n"
    L"SET @id_counter_stream_cycle = CASE WHEN @gsm_ag_id_cycle IS NULL "
    L"THEN @gsm_id_cycle "
    L"ELSE @gsm_ag_id_cycle END "
    L"SET @id_counter_stream = CASE WHEN @gsm_shared_flag = 'Y' THEN @gsm_id_group ELSE @c__AccountID END\n "
    L"SET @counter_stream_type = CASE WHEN @gsm_shared_flag = 'Y' THEN 2 ELSE 3 END\n"
    L"END";
  DesignTimeExpression * aggCycleExpr = new DesignTimeExpression();
  aggCycleExpr->SetName(L"ratedUsageAggCycleExpr");
  aggCycleExpr->SetProgram(expr);
  mPlan.push_back(aggCycleExpr);
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        aggCycleExpr->GetInputPorts()[0]));
  ratedUsageOutput  = aggCycleExpr->GetOutputPorts()[0];

//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     mPlan.push_back(prnt);
//     prnt->SetNumToPrint(100);
//     mPlan.push_back(new DesignTimeChannel(ratedUsageOutput, 
//                                           prnt->GetInputPorts()[0]));
//     ratedUsageOutput = prnt->GetOutputPorts()[0];
//   }

  for(std::size_t i=0; i<countables.size(); i++)
  {
    aggCycleExpr = new DesignTimeExpression();
    wchar_t buf [64];
    wsprintf(buf, L"countable(%d)AggCycleExpr", i);
    aggCycleExpr->SetName(buf);
    aggCycleExpr->SetProgram(expr);
    mPlan.push_back(aggCycleExpr);
    mPlan.push_back(new DesignTimeChannel(countables[i], 
                                          aggCycleExpr->GetInputPorts()[0]));
    countablesOutput.push_back(aggCycleExpr->GetOutputPorts()[0]);
  }
}

// At the metadata level this performs:
//
// ratedUsage(c__AccountID INTEGER, ag_id_cycle INTEGER, auc_id_cycle INTEGER, ...) 
// -------------> 
// ratedUsage(c__AccountID INTEGER, ag_id_cycle INTEGER, 
//            auc_id_cycle INTEGER, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER, ...)
// countable[i](c__AccountID INTEGER, ...) 
// -------------> 
// countable[i](c__AccountID INTEGER, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER, ...)
//
void AggregateRating::ProcessIndividualSubscriptions(boost::int32_t id_pi_template, 
                                                     boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
                                                     boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput)
{
  // In the group subscription case, rated usage and countables are handled in a somewhat similar
  // fashion in the sense that each rated or countable record is associated with a unique group subscription
  // (containing the priceable item template we are rating) and the aggregate cycle derives from that subscription
  // (TODO: careful about BCR in the non-shared case...).
  // The non-group subscription case (which we may or may not want to assume is the individual subscription case
  // depending on whether we want to support the historical notion of non-subscription aggregate rating) is a bit
  // different in that rated usage is associated with a unique counter stream (determined by the payee and cycle 
  // determined by the pi template or
  // instance of the rated record in question or cycle of the payer of the record in the
  // BCR case).  On the other hand, it is possible for a countable that occurs off group subscription to be
  // counted multiple times (if there are multiple intervals in play due to non-subscription and individual 
  // subscription or multiple individual subscriptions).  These records are guided to counter streams based purely
  // on id_payee (possibly hitting multiple counter streams if there are multiple cycles)
  // and thence to a specific counter based on date range of the counters.
  DesignTimeDatabaseSelect * individualCounterSelect = new DesignTimeDatabaseSelect();
  // This grabs the individual counter streams from the database.
  // 1) Rated records guide to these using payee and aggregate/payer cycle (hence are guided to a exactly one).
  // 2) Countable records guide to these using only the payee (hence are guided to one or more).
  // TODO: Possible optimization here is to only pick countables that have
  // an associated usage event in the current interval.  That will allow us to
  // avoid calculating running totals that will never be used but will cause
  // us to scan the current interval an extra time.  Need to understand when this
  // optimization is worthwhile.
  wchar_t buf[1024];
  wsprintf(buf,
           L"select\n"
           L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
           L"auc.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
           L"s.id_acc as id_counter_stream \n"
           L"from t_pl_map plm\n"
           L"inner join t_aggregate a on a.id_prop=plm.id_pi_instance\n"
           L"inner join t_sub s on s.id_po=plm.id_po\n"
           L"inner join t_payment_redirection pay on pay.id_payee=s.id_acc\n"
           L"inner join t_acc_usage_cycle auc on pay.id_payer=auc.id_acc\n"
           L"where\n"
           L"plm.id_paramtable is null\n"
           L"and plm.id_pi_template = %d\n"
           L"and s.id_group is null\n"
           L"AND {fn MOD(s.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n"
           ,id_pi_template);
  individualCounterSelect->SetBaseQuery(buf);
  individualCounterSelect->SetName(L"individualCounterSelect");
  mPlan.push_back(individualCounterSelect);

  DesignTimeDatabaseSelect * nonSubscriptionCounterSelect = new DesignTimeDatabaseSelect();
  nonSubscriptionCounterSelect->SetBaseQuery(
    (boost::wformat(L"select\n"
                    L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
                 L"auc.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
                 L"acc.id_acc as id_counter_stream \n"
                 L"from t_account acc\n"
                 L"inner join t_payment_redirection pay on pay.id_payee=acc.id_acc\n"
                 L"inner join t_acc_usage_cycle auc on pay.id_payer=auc.id_acc\n"
                 L"cross join t_aggregate a\n"
                 L"where\n"
                 L"a.id_prop = %1%\n"
                 L"AND {fn MOD(acc.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n")
    % id_pi_template).str());
  nonSubscriptionCounterSelect->SetName(L"nonSubscriptionCounterSelect");
  mPlan.push_back(nonSubscriptionCounterSelect);

  DesignTimeDatabaseSelect * nonSharedGroupCounterSelect = new DesignTimeDatabaseSelect();
  nonSharedGroupCounterSelect->SetBaseQuery(
    (boost::wformat(L"SELECT\n"
                    L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
                    L"gs.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
                    L"gsm.id_acc as id_counter_stream \n"
                    L"FROM t_pl_map plm\n"
                    L"INNER JOIN t_sub s ON s.id_po=plm.id_po\n"
                    L"INNER JOIN t_group_sub gs ON s.id_group=gs.id_group\n"
                    L"INNER JOIN t_gsubmember gsm ON gsm.id_group=gs.id_group\n"
                    L"INNER JOIN t_aggregate a ON a.id_prop=plm.id_pi_instance\n"
                    L"WHERE\n"
                    L"plm.id_pi_template = %1%\n"
                    L"AND plm.id_paramtable is null\n"
                    L"AND gs.b_supportgroupops = 'N'\n"
                    L"AND {fn MOD(gsm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\n")
     % id_pi_template).str());
  nonSharedGroupCounterSelect->SetName(L"nonSharedGroupCounterSelect");
  mPlan.push_back(nonSharedGroupCounterSelect);

  DesignTimeUnionAll * indivSubNonSubCounterStreamUnion = new DesignTimeUnionAll(3);
  indivSubNonSubCounterStreamUnion->SetName(L"indivSubNonSubCounterStreamUnion");
  mPlan.push_back(indivSubNonSubCounterStreamUnion);
  mPlan.push_back(new DesignTimeChannel(individualCounterSelect->GetOutputPorts()[0], 
                                        indivSubNonSubCounterStreamUnion->GetInputPorts()[0]));
  mPlan.push_back(new DesignTimeChannel(nonSubscriptionCounterSelect->GetOutputPorts()[0], 
                                        indivSubNonSubCounterStreamUnion->GetInputPorts()[1]));
  mPlan.push_back(new DesignTimeChannel(nonSharedGroupCounterSelect->GetOutputPorts()[0], 
                                        indivSubNonSubCounterStreamUnion->GetInputPorts()[2]));

  DesignTimeExpression * individualCounterExpr = new DesignTimeExpression();
  individualCounterExpr->SetName(L"individualCounterExpr");
  individualCounterExpr->SetProgram(
    L"CREATE PROCEDURE individualCounterExpr @indiv_agg_id_usage_cycle INTEGER @indiv_auc_id_usage_cycle INTEGER @id_counter_stream_cycle INTEGER OUTPUT @counter_stream_type INTEGER OUTPUT @counter_stream_is_shared_counter BOOLEAN OUTPUT\n"
    L"AS\n"
    L"SET @id_counter_stream_cycle = CASE WHEN @indiv_agg_id_usage_cycle IS NULL THEN @indiv_auc_id_usage_cycle ELSE @indiv_agg_id_usage_cycle END\n"
    L"SET @counter_stream_type = 1\n"
    L"SET @counter_stream_is_shared_counter = FALSE\n"
    );
  mPlan.push_back(individualCounterExpr);
  mPlan.push_back(new DesignTimeChannel(indivSubNonSubCounterStreamUnion->GetOutputPorts()[0], 
                                        individualCounterExpr->GetInputPorts()[0]));
  
  DesignTimeHashGroupBy * groupBy = new DesignTimeHashGroupBy();
  mPlan.push_back(groupBy);
  groupBy->SetName(L"individualCounterDistinct");
  std::vector<std::wstring> groupByKeys;
  groupByKeys.push_back(L"id_counter_stream_cycle");
  groupByKeys.push_back(L"id_counter_stream");
  groupByKeys.push_back(L"counter_stream_type");
  groupByKeys.push_back(L"counter_stream_is_shared_counter");
  groupBy->SetGroupByKeys(groupByKeys);
  groupBy->SetInitializeProgram(
    L"CREATE PROCEDURE initializer @Table_individual_counter_stream_count INTEGER\n"
    L"AS\n"
    L"SET @Table_individual_counter_stream_count = 0\n"
    );
  groupBy->SetUpdateProgram(
    L"CREATE PROCEDURE updater @Table_individual_counter_stream_count INTEGER\n"
    L"AS\n"
    L"SET @Table_individual_counter_stream_count = @Table_individual_counter_stream_count + 1\n"
    );
  mPlan.push_back(new DesignTimeChannel(individualCounterExpr->GetOutputPorts()[0], 
                                        groupBy->GetInputPorts()[0]));
  DesignTimeHashPartitioner * individualCounterPart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> idIndividualCounterStreamHashKeys;
  idIndividualCounterStreamHashKeys.push_back(L"id_counter_stream");
  individualCounterPart->SetHashKeys(idIndividualCounterStreamHashKeys);
  individualCounterPart->SetName(L"individualCounterPart");
  mPlan.push_back(individualCounterPart);
  mPlan.push_back(new DesignTimeChannel(groupBy->GetOutputPorts()[0], 
                                        individualCounterPart->GetInputPorts()[0]));
  DesignTimeNondeterministicCollector * individualCounterColl = new DesignTimeNondeterministicCollector();
  individualCounterColl->SetName(L"individualCounterColl");
  mPlan.push_back(individualCounterColl);
  mPlan.push_back(new DesignTimeChannel(individualCounterPart->GetOutputPorts()[0], 
                                        individualCounterColl->GetInputPorts()[0]));

  DesignTimeHashJoin * usageIndividualCounterStreamJoin = new DesignTimeHashJoin();
  mPlan.push_back(usageIndividualCounterStreamJoin);
  usageIndividualCounterStreamJoin->SetName(L"usageIndividualCounterStreamJoin");
  std::vector<std::wstring> idIndividualCounterStreamJoinKeys;
  idIndividualCounterStreamJoinKeys.push_back(L"id_counter_stream");
  idIndividualCounterStreamJoinKeys.push_back(L"counter_stream_is_shared_counter");
  usageIndividualCounterStreamJoin->SetTableEquiJoinKeys(idIndividualCounterStreamJoinKeys);
  mPlan.push_back(new DesignTimeChannel(individualCounterColl->GetOutputPorts()[0], 
                                        usageIndividualCounterStreamJoin->GetInputPorts()[L"table"]));

  // Probe Specification for guiding rated usage to individual counter stream.
  DesignTimeHashJoinProbeSpecification ratedUsageIndividualCounterStreamJoinSpec;
  std::vector<std::wstring> idPayeeJoinKeys;
  idPayeeJoinKeys.push_back(L"c__AccountID");
  idPayeeJoinKeys.push_back(L"is_shared_counter");
  ratedUsageIndividualCounterStreamJoinSpec.SetEquiJoinKeys(idPayeeJoinKeys);
  if (!mIsRatedUsageCountable)
  {
    ratedUsageIndividualCounterStreamJoinSpec.SetResidual(
      L"CREATE FUNCTION residual (@Probe_ag_id_cycle INTEGER @Probe_gsm_id_cycle INTEGER @Probe_auc_id_cycle INTEGER @Table_id_counter_stream_cycle INTEGER)\n" 
      L"RETURNS BOOLEAN\n"
      L"AS\n"
      L"RETURN CASE WHEN @Probe_ag_id_cycle IS NULL THEN CASE WHEN @Probe_gsm_id_cycle IS NULL THEN @Probe_auc_id_cycle ELSE @Probe_gsm_id_cycle END ELSE @Probe_ag_id_cycle END "
      L"= "
      L"@Table_id_counter_stream_cycle");
  }
  ratedUsageIndividualCounterStreamJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER);
  usageIndividualCounterStreamJoin->AddProbeSpecification(ratedUsageIndividualCounterStreamJoinSpec);
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        usageIndividualCounterStreamJoin->GetInputPorts()[L"probe(0)"]));

  if(mIsRatedUsageCountable)
  {
    // In this case some of the records produced may not satisfy the predicate in the residual
    // above.  This means that they are countable records but not rated, but the records that don't satisfy the
    // predicate must have their is_rated flag cleared.
    DesignTimeExpression * clearRatedFlag = new DesignTimeExpression();
    clearRatedFlag->SetName(L"clearRatedFlag");
    clearRatedFlag->SetProgram(
      L"CREATE PROCEDURE clearRatedFlag @is_shared_counter BOOLEAN @ag_id_cycle INTEGER @gsm_id_cycle INTEGER @auc_id_cycle INTEGER @id_counter_stream_cycle INTEGER @is_rated BOOLEAN\n"
      L"AS\n"
      L"IF (NOT @is_shared_counter) AND @is_rated\n"
      L"SET @is_rated = \n"
      L"CASE WHEN \n"
      L"  CASE WHEN @ag_id_cycle IS NULL \n"
      L"  THEN \n"
      L"    CASE WHEN @gsm_id_cycle IS NULL \n"
      L"    THEN @auc_id_cycle \n"
      L"    ELSE @gsm_id_cycle END\n"
      L"  ELSE @ag_id_cycle END\n"
      L"  =\n"
      L"  @id_counter_stream_cycle \n"
      L"THEN TRUE \n"
      L"ELSE FALSE END");
    mPlan.push_back(clearRatedFlag);
    mPlan.push_back(new DesignTimeChannel(usageIndividualCounterStreamJoin->GetOutputPorts()[L"output(0)"],
                                          clearRatedFlag->GetInputPorts()[0]));
    ratedUsageOutput = clearRatedFlag->GetOutputPorts()[0];
  }
  else
  {
    ratedUsageOutput = usageIndividualCounterStreamJoin->GetOutputPorts()[L"output(0)"];
  }

  for (std::size_t i=0; i<countables.size(); i++)
  {
    wchar_t buf[64];
    wsprintf(buf, L"probe(%d)", i+1);
    // Probe Specification for guiding countable usage to individual counter stream.
    DesignTimeHashJoinProbeSpecification countableUsageIndividualCounterStreamJoinSpec;
    countableUsageIndividualCounterStreamJoinSpec.SetEquiJoinKeys(idPayeeJoinKeys);
    countableUsageIndividualCounterStreamJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::RIGHT_OUTER);
    usageIndividualCounterStreamJoin->AddProbeSpecification(countableUsageIndividualCounterStreamJoinSpec);
    mPlan.push_back(new DesignTimeChannel(countables[i], 
                                          usageIndividualCounterStreamJoin->GetInputPorts()[buf]));

    wsprintf(buf, L"output(%d)", i+1);
    countablesOutput.push_back(usageIndividualCounterStreamJoin->GetOutputPorts()[buf]);
  }

  // Next step is to attach each (usage,counter stream) pair to the appropriate aggregate interval.
//    {
//      // Debugging print
//      DesignTimePrint * prnt = new DesignTimePrint();
//      prnt->SetNumToPrint(100);
//      mPlan.push_back(prnt);
//      mPlan.push_back(new DesignTimeChannel(ratedUsageOutput, 
//                                            prnt->GetInputPorts()[0]));
//      ratedUsageOutput = prnt->GetOutputPorts()[0];
//    }
}

void AggregateRating::CalculateRunningTotal(boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> >& countables,
                                            boost::shared_ptr<Port>& outputRatedUsage)
{
  ASSERT((!mIsRatedUsageCountable && countables.size() == mCountables.size()) ||
         (mIsRatedUsageCountable && countables.size() == mCountables.size()-1));
//   {
//     DesignTimePrint * ratedUsagePrint = new DesignTimePrint();
//     ratedUsagePrint->SetName(L"ratedUsagePrint");
//     mPlan.push_back(ratedUsagePrint);
//     mPlan.push_back(new DesignTimeChannel(ratedUsage, 
//                                           ratedUsagePrint->GetInputPorts()[0]));
//     ratedUsage = ratedUsagePrint->GetOutputPorts()[0];
//   }

  // Repartition and apply running total calculation.
  DesignTimeHashPartitioner * groupSharedCounterPart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> groupSharedCounterKeys;
  groupSharedCounterKeys.push_back(L"id_counter_stream");
  groupSharedCounterKeys.push_back(L"counter_stream_type");
  groupSharedCounterKeys.push_back(L"pc_id_interval");
  groupSharedCounterPart->SetHashKeys(groupSharedCounterKeys);
  groupSharedCounterPart->SetName(L"groupSharedCounterPart");
  mPlan.push_back(groupSharedCounterPart);
  mPlan.push_back(new DesignTimeChannel(ratedUsage, 
                                        groupSharedCounterPart->GetInputPorts()[0]));

  DesignTimeSortMergeCollector * groupSharedCounterColl = CreateSortMergeCollector(L"groupSharedCounterColl");
  mPlan.push_back(groupSharedCounterColl);
  mPlan.push_back(new DesignTimeChannel(groupSharedCounterPart->GetOutputPorts()[0], 
                                        groupSharedCounterColl->GetInputPorts()[0]));

  // Now we are assuming group sub shared counter.  A counter is specified by id_group, pc_id_interval.
  // All inputs have the same keys.
  std::vector<DesignTimeHashRunningAggregateInputSpec> runningTotalInputs; 
  // Rated usage goes as the first input.  If it is not countable, it has an empty updater,
  // else it gets the updater from its associated countable spec.
  if (mIsRatedUsageCountable)
  {
    for(std::vector<AggregateRatingCountableSpec>::iterator it =  mCountables.begin();
        it != mCountables.end();
        it++)
    {
      if (it->GetTableName() == mRatedUsage.GetTableName()) 
      {
        runningTotalInputs.push_back(DesignTimeHashRunningAggregateInputSpec(groupSharedCounterKeys, 
                                                                             it->GetUpdateProgram()));
        break;
      }
    }
    ASSERT(runningTotalInputs.size() == 1);
  }
  else
  {
    runningTotalInputs.push_back(DesignTimeHashRunningAggregateInputSpec(groupSharedCounterKeys, 
                                                                         L""));
  }
  // Non-rated usage countables go next.
  for(std::vector<AggregateRatingCountableSpec>::iterator it =  mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() != mRatedUsage.GetTableName()) 
    {
      runningTotalInputs.push_back(DesignTimeHashRunningAggregateInputSpec(groupSharedCounterKeys, 
                                                                           it->GetUpdateProgram()));
    }
  }
  DesignTimeHashRunningAggregate * groupSharedCounterRunningTotal = 
    new DesignTimeHashRunningAggregate(runningTotalInputs.size());
  groupSharedCounterRunningTotal->SetInitializeProgram(mRatedUsage.GetInitializeProgram());
  groupSharedCounterRunningTotal->SetInputSpecs(runningTotalInputs);
  groupSharedCounterRunningTotal->SetName(L"groupSharedCounterRunningTotal");
  groupSharedCounterRunningTotal->AddSortKey(DesignTimeSortKey(L"c_BillingIntervalEnd",SortOrder::ASCENDING));
  groupSharedCounterRunningTotal->AddSortKey(DesignTimeSortKey(L"c_SessionDate",SortOrder::ASCENDING));
  groupSharedCounterRunningTotal->AddSortKey(DesignTimeSortKey(L"id_parent_sess",SortOrder::ASCENDING));
  groupSharedCounterRunningTotal->AddSortKey(DesignTimeSortKey(L"id_sess",SortOrder::ASCENDING));
  mPlan.push_back(groupSharedCounterRunningTotal);
//   DesignTimePrint * ratedUsagePrint = new DesignTimePrint();
//   ratedUsagePrint->SetName(L"ratedUsagePrint");
//   mPlan.push_back(ratedUsagePrint);
//   mPlan.push_back(new DesignTimeChannel(groupSharedCounterColl->GetOutputPorts()[0], 
//                                         ratedUsagePrint->GetInputPorts()[0]));
//   mPlan.push_back(new DesignTimeChannel(ratedUsagePrint->GetOutputPorts()[0], 
//                                         groupSharedCounterRunningTotal->GetInputPorts()[0]));
  mPlan.push_back(new DesignTimeChannel(groupSharedCounterColl->GetOutputPorts()[0], 
                                        groupSharedCounterRunningTotal->GetInputPorts()[0]));

  // Feed in the countables.
  for(std::size_t i = 0; i<countables.size(); i++)
  {
    DesignTimeHashPartitioner * countableGroupSharedCounterPart = new DesignTimeHashPartitioner();
    countableGroupSharedCounterPart->SetHashKeys(groupSharedCounterKeys);
    countableGroupSharedCounterPart->SetName((boost::wformat(L"countable(%1%)groupSharedCounterPart") % i).str());
    mPlan.push_back(countableGroupSharedCounterPart);
    mPlan.push_back(new DesignTimeChannel(countables[i], 
                                          countableGroupSharedCounterPart->GetInputPorts()[0]));

    DesignTimeSortMergeCollector * countableGroupSharedCounterColl = 
      CreateSortMergeCollector((boost::wformat(L"countable(%1%)groupSharedCounterColl") % i).str());
    mPlan.push_back(countableGroupSharedCounterColl);
    mPlan.push_back(new DesignTimeChannel(countableGroupSharedCounterPart->GetOutputPorts()[0], 
                                          countableGroupSharedCounterColl->GetInputPorts()[0]));

//     DesignTimePrint * countableUsagePrint = new DesignTimePrint();
//     ratedUsagePrint->SetName(L"countableUsagePrint");
//     mPlan.push_back(countableUsagePrint);
//     mPlan.push_back(new DesignTimeChannel(countableGroupSharedCounterColl->GetOutputPorts()[0], 
//                                           countableUsagePrint->GetInputPorts()[0]));
//     mPlan.push_back(new DesignTimeChannel(countableUsagePrint->GetOutputPorts()[0], 
//                                           groupSharedCounterRunningTotal->GetInputPorts()[i+1]));
    mPlan.push_back(new DesignTimeChannel(countableGroupSharedCounterColl->GetOutputPorts()[0], 
                                          groupSharedCounterRunningTotal->GetInputPorts()[i+1]));
  }

  // Filter out non-rated usage.
  DesignTimeFilter * filterOutNonRatedUsage = new DesignTimeFilter();
  mPlan.push_back(filterOutNonRatedUsage);
  filterOutNonRatedUsage->SetName(L"filterOutNonRatedUsage");
  filterOutNonRatedUsage->SetProgram(
    L"CREATE FUNCTION filterOutNonRatedUsage (@is_rated BOOLEAN) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @is_rated");
//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     prnt->SetNumToPrint(200);
//     mPlan.push_back(prnt);
//     mPlan.push_back(new DesignTimeChannel(groupSharedCounterRunningTotal->GetOutputPorts()[0], 
//                                           prnt->GetInputPorts()[0]));
//     outputRatedUsage = prnt->GetOutputPorts()[0];
//     mPlan.push_back(new DesignTimeChannel(prnt->GetOutputPorts()[0],
//                                           filterOutNonRatedUsage->GetInputPorts()[0]));
//   }
  mPlan.push_back(new DesignTimeChannel(groupSharedCounterRunningTotal->GetOutputPorts()[0],
                                        filterOutNonRatedUsage->GetInputPorts()[0]));

  // This is either super ugly or super cool.  
  // We want to stich together the group and individual case.  So we remove the
  // fields they don't have in common.  Unfortunately some of the important common fields are
  // being dynamic passed in and aren't available until type check time (that is to say we don;t
  // know them right now).  On the other hand, we don't know the list of fields that they
  // don't have in common so we can remove them with a complementary projection (sure can't do this
  // with SQL eh!).
  DesignTimeProjection * projection = new DesignTimeProjection();
  projection->SetName(L"projectUnused");
  mPlan.push_back(projection);
  std::vector<std::wstring> exclusionList;
  exclusionList.push_back(L"pc_id_interval");
  exclusionList.push_back(L"pc_id_cycle");
  exclusionList.push_back(L"gsm_id_acc");
  exclusionList.push_back(L"gsm_id_pi_instance");
  exclusionList.push_back(L"gsm_id_group");
  exclusionList.push_back(L"gsm_shared_flag");
  exclusionList.push_back(L"gsm_ag_id_cycle");
  exclusionList.push_back(L"gsm_id_cycle");
  exclusionList.push_back(L"gsm_vt_start");
  exclusionList.push_back(L"gsm_vt_end");
  exclusionList.push_back(L"id_counter_stream_cycle");
  exclusionList.push_back(L"id_counter_stream");
  exclusionList.push_back(L"individual_counter_stream_count");
  exclusionList.push_back(L"counter_stream_type");
  exclusionList.push_back(L"id_counter_stream#");
  exclusionList.push_back(L"counter_stream_type#");
  exclusionList.push_back(L"pc_id_interval#");
  exclusionList.push_back(L"auc_id_interval");
  exclusionList.push_back(L"auc_id_cycle");
  exclusionList.push_back(L"ag_id_prop");
  exclusionList.push_back(L"ag_id_cycle");
  exclusionList.push_back(L"id_pi_template_instance");
  exclusionList.push_back(L"id_countable");
  exclusionList.push_back(L"id_rated");
  projection->SetProjection(exclusionList, true);
//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     prnt->SetNumToPrint(200);
//     mPlan.push_back(prnt);
//     mPlan.push_back(new DesignTimeChannel(filterOutNonRatedUsage->GetOutputPorts()[0], 
//                                           prnt->GetInputPorts()[0]));
//     outputRatedUsage = prnt->GetOutputPorts()[0];
//     mPlan.push_back(new DesignTimeChannel(prnt->GetOutputPorts()[0],
//                                           projection->GetInputPorts()[0]));
//   }
  mPlan.push_back(new DesignTimeChannel(filterOutNonRatedUsage->GetOutputPorts()[0], 
                                        projection->GetInputPorts()[0]));

  // One last repartition.  Technically this is only necessary for compounds.  The issue is that we
  // are going to meter and the different components of a compound may be partitioned on different
  // counters.  To bring everyone together for final metering means finding a compatible partitioning key.
  // Here we choose id_sess/id_parent_sess.  We also need to avoid
  // screwing with the sort order again since the metering code assumes sortedness (or at least groupedness)
  // on id_sess/id_parent_sess to put the compounds into messages.
  // Note also that one might think that payee is a reasonable partitioning key, but PMNA has
  // essentially invalidated the business rule that payee is constant over compounds; no matter,
  // partitioning compounds will almost certainly generate even distribution heading into metering.
  DesignTimeHashPartitioner * runningTotalPart = new DesignTimeHashPartitioner();
  std::vector<std::wstring> idPayeeHashKeys;
  idPayeeHashKeys.push_back(L"id_compound_sess");
  runningTotalPart->SetHashKeys(idPayeeHashKeys);
  runningTotalPart->SetName(L"runningTotalPart");
  mPlan.push_back(runningTotalPart);
  mPlan.push_back(new DesignTimeChannel(projection->GetOutputPorts()[0], 
                                        runningTotalPart->GetInputPorts()[0]));

  DesignTimeSortMergeCollector * runningTotalColl = CreateSortMergeCollector(L"runningTotalColl");
  mPlan.push_back(runningTotalColl);
  mPlan.push_back(new DesignTimeChannel(runningTotalPart->GetOutputPorts()[0], 
                                        runningTotalColl->GetInputPorts()[0]));

  outputRatedUsage = runningTotalColl->GetOutputPorts()[0];

//   DesignTimeAssertSortOrder * assertSortOrder = CreateAssertSortOrder((boost::wformat(L"finalSortOrder(%1%)") % mRatedUsage.GetTableName()).str());
//   mPlan.push_back(assertSortOrder);
//   mPlan.push_back(new DesignTimeChannel(outputRatedUsage, 
//                                         assertSortOrder->GetInputPorts()[0]));

//   // No output for the moment.
//   outputRatedUsage = assertSortOrder->GetOutputPorts()[0];

//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     mPlan.push_back(prnt);
//     mPlan.push_back(new DesignTimeChannel(outputRatedUsage, 
//                                           prnt->GetInputPorts()[0]));
//     outputRatedUsage = prnt->GetOutputPorts()[0];
//   }
}

AggregateRating::AggregateRating(DesignTimePlan & plan,
                                 const AggregateRatingUsageSpec & ratedUsage,
                                 const std::vector<AggregateRatingCountableSpec>& countables,
                                 bool readAllRatedUsageColumns)
  :
  mRatedUsage(ratedUsage),
  mCountables(countables),
  mPlan(plan),
  mIsRatedUsageCountable(false),
  mReadAllRatedUsageColumns(readAllRatedUsageColumns)
{
  boost::int32_t id_pi_template=mRatedUsage.GetPriceableItemTemplateID();
  boost::int32_t id_view = mRatedUsage.GetViewID();

  for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() == mRatedUsage.GetTableName()) 
    {
      mIsRatedUsageCountable = true;
      break;
    }
  }
  
  ////////////////////
  // Note that in the BCR case, we get to restrict reading to an interval.
  // In the non-BCR case we really have to scan everything because we don't
  // a-priori know which intervals will contain usage in the aggregate interval.
  // This really increases the performance requirement.  On the other hand,
  // this calculation could be done with a single group by rather than a running total
  // calculation.  It also might be meaningful to
  // store the results of this group by on a per interval basis during soft close (a 
  // new kind of adapter).
  
  boost::shared_ptr<Port> readRatedUsage;
  std::vector<boost::shared_ptr<Port> > readCountables;
  ReadRatedUsageAndCountables(readRatedUsage, readCountables);

  if (countables.size() == 0)
  {
    ASSERT(readCountables.size() == 0);
    
    // There are no countables (i.e. this is a non-aggregate rated PI within
    // an aggregate rated compound PI).  Our contract is to partition on id_compound_sess
    // and we are repartitioned either on payee (no billing groups) or payer (with billing groups).
    DesignTimeHashPartitioner * finalRatedUsagePart = new DesignTimeHashPartitioner();
    std::vector<std::wstring> idPayerHashKeys;
    idPayerHashKeys.push_back(L"id_compound_sess");
    finalRatedUsagePart->SetHashKeys(idPayerHashKeys);
    finalRatedUsagePart->SetName((boost::wformat(L"finalRatedUsagePart(%1%)") % mRatedUsage.GetTableName()).str());
    mPlan.push_back(finalRatedUsagePart);
    mPlan.push_back(new DesignTimeChannel(readRatedUsage, 
                                          finalRatedUsagePart->GetInputPorts()[0]));
    DesignTimeSortMergeCollector * finalRatedUsageColl = 
      CreateSortMergeCollector((boost::wformat(L"finalRatedUsageColl(%1%)") % mRatedUsage.GetTableName()).str());
    mPlan.push_back(finalRatedUsageColl);
    mPlan.push_back(new DesignTimeChannel(finalRatedUsagePart->GetOutputPorts()[0], 
                                          finalRatedUsageColl->GetInputPorts()[0]));
    mOutputPort = finalRatedUsageColl->GetOutputPorts()[0];
//     {
//       // Debugging print
//       DesignTimePrint * prnt = new DesignTimePrint();
//       mPlan.push_back(prnt);
//       mPlan.push_back(new DesignTimeChannel(mOutputPort, 
//                                             prnt->GetInputPorts()[0]));
//       mOutputPort = prnt->GetOutputPorts()[0];
//     }
    return;
  }

  if (mRatedUsage.GetBillingGroupID() != -1)
  {
    // If billing groups then must repartition on payee.
    DesignTimeHashPartitioner * ratedUsagePayeeRepartition = new DesignTimeHashPartitioner();
    std::vector<std::wstring> idPayeeHashKeys;
    idPayeeHashKeys.push_back(L"c__AccountID");
    ratedUsagePayeeRepartition->SetHashKeys(idPayeeHashKeys);
    ratedUsagePayeeRepartition->SetName(L"ratedUsagePayeeRepartition");
    mPlan.push_back(ratedUsagePayeeRepartition);
    mPlan.push_back(new DesignTimeChannel(readRatedUsage, 
                                          ratedUsagePayeeRepartition->GetInputPorts()[0]));

    DesignTimeSortMergeCollector * ratedUsagePayeeRepartitionColl = 
      CreateSortMergeCollector(L"ratedUsagePayeeRepartitionColl");
    mPlan.push_back(ratedUsagePayeeRepartitionColl);
    mPlan.push_back(new DesignTimeChannel(ratedUsagePayeeRepartition->GetOutputPorts()[0], 
                                          ratedUsagePayeeRepartitionColl->GetInputPorts()[0]));

    readRatedUsage = ratedUsagePayeeRepartitionColl->GetOutputPorts()[0];
  }
  
  //
  // Figure out subscription guiding rules.
  //
  boost::shared_ptr<Port> groupSubGuidedRatedUsage;
  std::vector<boost::shared_ptr<Port> > groupSubGuidedCountableUsage;
  GuideToGroupSubscriptions(id_pi_template,
                            readRatedUsage, readCountables,
                            groupSubGuidedRatedUsage, groupSubGuidedCountableUsage);

  //
  // At this point we know individual subscription versus group subscription.
  // Apply different rules to figure out counter stream that applies to rated
  // usage and countable usage.
  //
  boost::shared_ptr<Port> cyclePiGuidedRatedUsage;
  GuideRatedUsageToBillingCycleAndPriceableItem(groupSubGuidedRatedUsage, cyclePiGuidedRatedUsage);
  // Individual subscription counter stream rules.
  boost::shared_ptr<Port> individualCounterStreamRatedUsage;
  std::vector<boost::shared_ptr<Port> > individualCounterStreamCountable;
  ProcessIndividualSubscriptions(id_pi_template, 
                                 cyclePiGuidedRatedUsage,   
                                 groupSubGuidedCountableUsage,
                                 individualCounterStreamRatedUsage,
                                 individualCounterStreamCountable);
  // Group subscription counter stream rules.
  boost::shared_ptr<Port> counterStreamRatedUsage;
  std::vector<boost::shared_ptr<Port> > counterStreamCountable;
  ProcessGroupSubscriptions(individualCounterStreamRatedUsage,
                            individualCounterStreamCountable,
                            counterStreamRatedUsage,
                            counterStreamCountable);

  //
  // Now the counter stream is identified.  Use effective dates
  // to guide to the appropriate counter (i.e. the interval) within the stream.
  //
  boost::shared_ptr<Port> counterRatedUsage;
  std::vector<boost::shared_ptr<Port> > counterCountable;
//   LookupCounterInterval(counterStreamRatedUsageGroupSubscription,
//                         counterStreamCountableGroupSubscription,
//                         counterStreamRatedUsageIndividualSubscription,
//                         counterStreamCountableIndividualSubscription,
//                         counterRatedUsageGroupSubscription,
//                         counterCountableGroupSubscription,
//                         counterRatedUsageIndividualSubscription,
//                         counterCountableIndividualSubscription);

  /////////////////////////////////////////////////////////
  // PMNA Performance Testing hack: just want to see what performance is if I improve this
  /////////////////////////////////////////////////////////
  DesignTimeDatabaseSelect * pcIntervalSelect = new DesignTimeDatabaseSelect();
  pcIntervalSelect->SetBaseQuery(
    L"SELECT id_interval as pc_id_interval, id_cycle as pc_id_cycle, dt_start as c_AggregateIntervalStart, dt_end as c_AggregateIntervalEnd "
    L"FROM t_pc_interval");
  pcIntervalSelect->SetMode(DesignTimeOperator::SEQUENTIAL);
  pcIntervalSelect->SetName(L"pcIntervalSelect");
  mPlan.push_back(pcIntervalSelect);
  DesignTimeBroadcastPartitioner * pcIntervalPart = new DesignTimeBroadcastPartitioner();
  pcIntervalPart->SetMode(DesignTimeOperator::SEQUENTIAL);
  pcIntervalPart->SetName(L"pcIntervalPart");
  mPlan.push_back(pcIntervalPart);
  mPlan.push_back(new DesignTimeChannel(pcIntervalSelect->GetOutputPorts()[0], 
                                       pcIntervalPart->GetInputPorts()[0]));

  DesignTimeHashJoin * ratedUsagePcIntervalJoin = new DesignTimeHashJoin();
  ratedUsagePcIntervalJoin->SetName(L"ratedUsagePcIntervalJoin");
  std::vector<std::wstring> idPcCycleJoinKeys;
  idPcCycleJoinKeys.push_back(L"pc_id_cycle");
  ratedUsagePcIntervalJoin->SetTableEquiJoinKeys(idPcCycleJoinKeys);
  DesignTimeHashJoinProbeSpecification ratedUsagePcIntervalJoinSpec;
  std::vector<std::wstring> idActualCycleJoinKeys;
  idActualCycleJoinKeys.push_back(L"id_counter_stream_cycle");
  ratedUsagePcIntervalJoinSpec.SetEquiJoinKeys(idActualCycleJoinKeys);
  ratedUsagePcIntervalJoinSpec.SetJoinType(DesignTimeHashJoinProbeSpecification::INNER_JOIN);
  ratedUsagePcIntervalJoinSpec.SetResidual(
    L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_c_AggregateIntervalStart DATETIME @Table_c_AggregateIntervalEnd DATETIME)\n"
    L"RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_c_SessionDate >= @Table_c_AggregateIntervalStart AND @Probe_c_SessionDate <= @Table_c_AggregateIntervalEnd");
  mPlan.push_back(ratedUsagePcIntervalJoin);
  mPlan.push_back(new DesignTimeChannel(pcIntervalPart->GetOutputPorts()[0], 
                                        ratedUsagePcIntervalJoin->GetInputPorts()[L"table"]));

  // Use the same probe spec for every input.
  ratedUsagePcIntervalJoin->AddProbeSpecification(ratedUsagePcIntervalJoinSpec);
  mPlan.push_back(new DesignTimeChannel(counterStreamRatedUsage, 
                                        ratedUsagePcIntervalJoin->GetInputPorts()[L"probe(0)"]));
  counterRatedUsage = ratedUsagePcIntervalJoin->GetOutputPorts()[L"output(0)"];

  for(std::size_t i = 0; i< counterStreamCountable.size(); i++)
  {
    wchar_t buf [64];
    wsprintf(buf, L"probe(%d)", i+1);
    ratedUsagePcIntervalJoin->AddProbeSpecification(ratedUsagePcIntervalJoinSpec);
    mPlan.push_back(new DesignTimeChannel(counterStreamCountable[i], 
                                          ratedUsagePcIntervalJoin->GetInputPorts()[buf]));
    wsprintf(buf, L"output(%d)", i+1);
    counterCountable.push_back(ratedUsagePcIntervalJoin->GetOutputPorts()[buf]);
  }

//   {
//     // Debugging print
//     DesignTimePrint * prnt = new DesignTimePrint();
//     mPlan.push_back(prnt);
//     prnt->SetNumToPrint(200);
//     mPlan.push_back(new DesignTimeChannel(counterRatedUsage, 
//                                           prnt->GetInputPorts()[0]));
//     counterRatedUsage = prnt->GetOutputPorts()[0];
//   }

  // Last step is to calculate the running totals themselves.
  CalculateRunningTotal(counterRatedUsage, 
                        counterCountable, 
                        mOutputPort);

}

AggregateRating::~AggregateRating()
{
}

boost::shared_ptr<Port> AggregateRating::GetOutputPort()
{
  return mOutputPort;
}


std::wstring AggregateRatingScript::GetUsageIntervalIDsPredicate(const std::wstring& prefix)
{
  std::wstring intervalPredicate;
  for(std::vector<boost::int32_t>::const_iterator it = mRatedUsage.GetUsageIntervalIDs().begin();
      it != mRatedUsage.GetUsageIntervalIDs().end();
      ++it)
  {
    if (it != mRatedUsage.GetUsageIntervalIDs().begin())
      intervalPredicate += L" OR ";
    intervalPredicate += (boost::wformat(L"%1% = %2%") % prefix % *it).str();
  }
  return intervalPredicate;
}

std::wstring AggregateRatingScript::CreateSortMergeCollector(const std::wstring& name)
{
  boost::wformat sortMergeCollectorFmt (L"%1%:coll[];\n");
  return (sortMergeCollectorFmt % name).str();
}

void AggregateRatingScript::GetProductViewColumns(const std::wstring& ratedUsageTable, std::vector<std::wstring>& allPvColumns)
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter");  
  std::auto_ptr<COdbcConnection> conn(new COdbcConnection(netMeter));
  
	std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
  std::string cat = conn->GetConnectionInfo().GetCatalogPrefix();
  std::wstring wstrCat;
  ::ASCIIToWide(wstrCat, cat);
  std::auto_ptr<COdbcResultSet> rs(stmt->ExecuteQueryW(L"select * from " + wstrCat + ratedUsageTable + L" where 0=1"));

  COdbcColumnMetadataVector meta = rs->GetMetadata();
  for(std::size_t i = 0; i < meta.size(); i++)
  {
    std::string colName = boost::to_lower_copy(meta[i]->GetColumnName());
    if (colName != "id_sess" && colName != "id_usage_interval")
    {
      std::wstring wstrColName;
      ::ASCIIToWide(wstrColName, colName);
      allPvColumns.push_back(wstrColName);
    }
  }
}

void AggregateRatingScript::SplitCountables(const std::wstring& ratedUsageTable, 
                                            const std::vector<std::wstring>& pvColumns, 
                                            std::vector<std::wstring>& countableColumns,
                                            std::vector<std::wstring>& nonCountableColumns)
{
  // Get the reference columns from the corresponding countable spec.
  for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() == ratedUsageTable) 
    {
      // We want a case insensitive comparison when matching table columns
      // to countable definition.  pvColumns collection has already been converted
      // to lower case, so we do same with the countables on the rated table.
      std::set<std::wstring> lowerRatedCountables;
      for(std::set<std::wstring>::const_iterator ratedCountablesIt = it->GetReferencedColumns().begin();
          ratedCountablesIt != it->GetReferencedColumns().end();
          ratedCountablesIt++)
      {
        lowerRatedCountables.insert(boost::to_lower_copy(*ratedCountablesIt));
      }

      // iterate and classify
      for(std::vector<std::wstring>::const_iterator colIt=pvColumns.begin();
          colIt != pvColumns.end();
          ++colIt)
      {
        if (lowerRatedCountables.end() != lowerRatedCountables.find(*colIt))
        {
          countableColumns.push_back(*colIt);
        }
        else
        {
          nonCountableColumns.push_back(*colIt);
        }
      }
      return;
    }
  }
  
  // Rated table has no countables.
  nonCountableColumns = pvColumns;
}

std::wstring AggregateRatingScript::GetRatedUsageSelectList(const std::vector<std::wstring>& allPvColumns)
{
  std::wstring selectList;

  for(std::vector<std::wstring>::const_iterator it = allPvColumns.begin();
      it != allPvColumns.end();
      ++it)
  {
      selectList += L", pv.";
      selectList += *it;
  }

  return selectList;
}

void AggregateRatingScript::ReadRatedUsageAndCountables(std::wstring& ratedUsageOutput, std::vector<std::wstring >& countableOutput)
{
  // For rated usage we need all of the product view properties (for metering purposes).
  // If the rated usage is also a countable then we need to read
  // all of the usage independent of usage interval.  If the rated
  // usage is not also a countable then we only need to read from the
  // specified interval.
  // For rated usage that is also countable we really don't need all of the columns
  // for the counter calculation.  There is overhead to carrying those extra columns around,
  // so we split them off and rejoin just before metering.
  std::vector<std::wstring> allPvColumns;
  GetProductViewColumns(mRatedUsage.GetTableName(), allPvColumns);
  std::vector<std::wstring> countablePvColumns;
  std::vector<std::wstring> nonCountablePvColumns;
  SplitCountables(mRatedUsage.GetTableName(), allPvColumns, countablePvColumns, nonCountablePvColumns);

  std::wstring intervalPredicate(L"");
  if (!mIsRatedUsageCountable)
  {
    intervalPredicate = L"AND (";
    intervalPredicate += GetUsageIntervalIDsPredicate(L"au.id_usage_interval");
    intervalPredicate += L")";
  }

  std::wstring productViewJoin;
  std::wstring productViewColumns;
  if (!mReadAllRatedUsageColumns)
  {
    if (mIsRatedUsageCountable)
    {
      productViewJoin = (boost::wformat(L"INNER JOIN %1% pv ON au.id_sess=pv.id_sess AND au.id_usage_interval=pv.id_usage_interval\n") % mRatedUsage.GetTableName()).str();
      // Get the reference columns from the corresponding countable spec.
      for(std::vector<std::wstring>::const_iterator colIt = countablePvColumns.begin();
          colIt != countablePvColumns.end();
          colIt++)
      {
        productViewColumns += L", pv.";
        productViewColumns += *colIt;
      }
    }
    else
    {
      // Don't even join the product view
    }
  }
  else
  {
    productViewJoin = (boost::wformat(L"INNER JOIN %1% pv ON au.id_sess=pv.id_sess AND au.id_usage_interval=pv.id_usage_interval\n") % mRatedUsage.GetTableName()).str();
    productViewColumns  = GetRatedUsageSelectList(allPvColumns);
  }


  // If we are doing estimates, we want to allow reguiding of intervals (CR9065).
  std::wstring intervalColumn;
  std::wstring intervalColumnCopy;
  if (!mRatedUsage.IsEstimate())
  {
    intervalColumn = L",au.id_usage_interval AS c__IntervalID\n";
    intervalColumnCopy = L"\n, column=\"c__IntervalID\"";
  }

  boost::wformat ratedUsageFmt(
    L"ratedUsageSelect_%1%:select[baseQuery=\"\n"
    L"SELECT\n"
    L"au.id_sess\n"
    L",au.id_parent_sess\n" 
    L",au.id_usage_interval\n"
    L",au.id_view AS c_ViewId\n"
    L",au.id_acc AS c__PayingAccount\n"
    L",au.id_payee AS c__AccountID\n"
    L",au.dt_crt AS c_CreationDate\n"
    L",au.dt_session AS c_SessionDate\n"
    L",au.id_pi_template AS c__PriceableItemTemplateID\n" 
    L",au.id_pi_instance AS c__PriceableItemInstanceID\n"
    L",au.id_prod AS c__ProductOfferingID\n"
    L",ui.dt_start AS c_BillingIntervalStart\n"
    L",ui.dt_end AS c_BillingIntervalEnd\n"
    L",au.dt_session AS c_OriginalSessionTimestamp\n"
    L",au.id_sess AS c__FirstPassID\n"
    L"%2% %3%\n"
    L"FROM t_acc_usage au\n"
    L"%4%"
    L"INNER JOIN t_usage_interval ui ON ui.id_interval = au.id_usage_interval\n"
    L"WHERE au.id_view=%5% AND au.id_pi_template=%6% %7%\n"
    L"AND {fn MOD(au.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"ratedUsageClassification_%1%:expr[program=\"\n"
    L"CREATE PROCEDURE ratedUsageClassification @id_usage_interval INTEGER\n"
    L"@id_sess BIGINT\n"
    L"@id_parent_sess BIGINT\n"
    L"@c__PriceableItemTemplateID INTEGER\n"
    L"@c__PriceableItemInstanceID INTEGER\n"
    L"@is_countable BOOLEAN OUTPUT\n"
    L"@is_rated BOOLEAN OUTPUT\n"
    L"@id_compound_sess BIGINT OUTPUT\n"
    L"@id_pi_template_instance INTEGER OUTPUT\n"
    L"AS\n"
    L"SET @id_compound_sess = CASE WHEN @id_parent_sess IS NULL THEN @id_sess ELSE @id_parent_sess END\n"
    L"SET @is_rated = CASE WHEN (%8%) THEN TRUE ELSE FALSE END\n"
    L"SET @is_countable = %9%\n"
    L"SET @id_pi_template_instance = CASE WHEN @c__PriceableItemInstanceID IS NULL THEN @c__PriceableItemTemplateID ELSE @c__PriceableItemInstanceID END\n" 
    L"\"];\n"
    L"ratedUsageSelect_%1% -> ratedUsageClassification_%1%;\n"
    L"%10%"
    L"ratedUsagePart_%1%:hashpart[key=\"c__AccountID\"];\n"
    L"ratedUsageColl_%1%:coll[];\n"
    L"ratedUsage_%1%(0) -> ratedUsagePart_%1% -> ratedUsageColl_%1%;\n"
    );

  // If our rated usage has associated counters then we must pass it through
  // a running total calculation.  There is overhead to keeping all of the 
  // columns of the product view together with the usage record during this process
  // when in reality a very small subset are referenced during the running total.
  // On the other hand, we have to have all of the pv properties so that we can meter
  // everything to 2nd pass.
  // What we do to improve performance is separate out the PV columns that aren't needed for
  // running total into a separate stream that is rejoined just prior to metering.
  // If our PI has no associated counters (i.e. is a non-aggregate part of an aggregate rated
  // compound PI) then we can just send the entire record directly to metering.
  boost::wformat ratedUsageCopyFmt(
    L"ratedUsage_%1%:copy[columnlist=[\n"
    L"column=\"id_sess\",\n"
    L"column=\"id_parent_sess\",\n"
    L"column=\"id_usage_interval\",\n"
    L"column=\"c__PayingAccount\",\n"
    L"column=\"c__AccountID\",\n"
    L"column=\"c_SessionDate\",\n"
    L"column=\"c__PriceableItemTemplateID\",\n"
    L"column=\"c__PriceableItemInstanceID\",\n"
    L"column=\"c_BillingIntervalEnd\",\n"
    L"column=\"is_countable\",\n"
    L"column=\"is_rated\",\n"
    L"column=\"id_compound_sess\",\n"
    L"column=\"id_pi_template_instance\"%2%],\n"
    L"columnlist=[\n"
    L"column=\"id_sess\",\n"
    L"column=\"id_compound_sess\",\n"
    L"column=\"is_rated\",\n"
    L"column=\"c_ViewId\",\n"
    L"column=\"c_CreationDate\",\n"
    L"column=\"c__ProductOfferingID\",\n"
    L"column=\"c_BillingIntervalStart\",\n"
    L"column=\"c_OriginalSessionTimestamp\",\n"
    L"column=\"c__FirstPassID\"%3%%5%\n"
    L"]];\n"
    L"-- The columns on this branch of the usage are not used for the aggregate running total calculation but are only\n"
    L"-- for the 2nd pass metering.  They are sorted and partitioned for a subsequent merge join with the running total.\n"
    L"ratedUsageClassification_%1% -> ratedUsage_%1%;\n"
    L"ratedUsageForMetering_%1%:filter[program=\"CREATE FUNCTION f (@is_rated BOOLEAN) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @is_rated\"];\n"
    L"ratedUsageForMeteringPart_%1%:hashpart[key=\"id_compound_sess\"];\n"
    L"ratedUsageForMeteringColl_%1%:coll[];\n"
    L"ratedUsageForMeteringSort_%1%:sort[key=\"id_compound_sess\", key=\"id_sess\", allowedMemory=50000000, temp_dir=\"%4%\"];\n"
    L"ratedUsage_%1%(1) -> ratedUsageForMetering_%1% -> ratedUsageForMeteringPart_%1% -> ratedUsageForMeteringColl_%1% -> ratedUsageForMeteringSort_%1%;\n"
    L"-- The columns on this branch of the usage are required for the running total calculaiton.\n"
    L"-- They will be remerged with the other usage columns prior to metering.\n");
  
  boost::wformat dummyUsageCopyFmt(
    L"ratedUsage_%1%:copy[];\n"
    L"ratedUsageClassification_%1% -> ratedUsage_%1%;\n"
    );

  std::wstring countableColumns;
  std::wstring nonCountableColumns;

  for(std::vector<std::wstring>::const_iterator it = countablePvColumns.begin();
      it != countablePvColumns.end(); 
      ++it)
  {
    countableColumns += L"\n, column=\"" + *it + L"\"";
  }
  for(std::vector<std::wstring>::const_iterator it = nonCountablePvColumns.begin();
      it != nonCountablePvColumns.end(); 
      ++it)
  {
    nonCountableColumns += L"\n, column=\"" + *it  + L"\"";
  }

  std::wstring copyUsage = mCountables.size() > 0 ?
    (ratedUsageCopyFmt % mRatedUsage.GetViewID() % countableColumns % nonCountableColumns % mSortDir % intervalColumnCopy).str() :
    (dummyUsageCopyFmt % mRatedUsage.GetViewID()).str();

  mProgram +=
  (ratedUsageFmt % mRatedUsage.GetViewID() % intervalColumn % productViewColumns % productViewJoin %
    mRatedUsage.GetViewID() % mRatedUsage.GetPriceableItemTemplateID() % intervalPredicate
    % GetUsageIntervalIDsPredicate(L"@id_usage_interval") % (mIsRatedUsageCountable ? L"TRUE" : L"FALSE") %
    copyUsage).str();

  // Define our output interface
  ratedUsageOutput = (boost::wformat(L"ratedUsageColl_%1%") % mRatedUsage.GetViewID()).str(); 

  for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() != mRatedUsage.GetTableName()) 
    {
      // Read countables from product views other than the rated usage table

      // Collect all of the referenced columns into a select list
      std::wstring pvSelectList;
      for(std::set<std::wstring>::const_iterator colIt = it->GetReferencedColumns().begin();
          colIt != it->GetReferencedColumns().end();
          colIt++)
      {
        pvSelectList += L", pv.";
        pvSelectList += *colIt;
      }

      boost::wformat countableFmt (
        L"countable_%1%_%2%:select[baseQuery=\"\n"
        L"SELECT\n"
        L"au.id_sess\n"
        L",au.id_parent_sess\n" 
        L",au.id_usage_interval\n"
        L",au.id_view AS c_ViewId\n"
        L",au.id_acc AS c__PayingAccount\n"
        L",au.id_payee AS c__AccountID\n"
        L",au.dt_crt AS c_CreationDate\n"
        L",au.dt_session AS c_SessionDate\n"
        L",au.id_pi_template AS c__PriceableItemTemplateID\n" 
        L",au.id_pi_instance AS c__PriceableItemInstanceID\n"
        L",au.id_prod AS c__ProductOfferingID\n"
        L",ui.dt_start AS c_BillingIntervalStart\n"
        L",ui.dt_end AS c_BillingIntervalEnd\n"
        L"%4% "
        L"FROM t_acc_usage au\n"
        L"INNER JOIN %3% pv ON au.id_sess=pv.id_sess\n"
        L"INNER JOIN t_usage_interval ui ON ui.id_interval = au.id_usage_interval\n"
        L"WHERE au.id_view=%2%\n"
        L"AND {fn MOD(au.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
        L"countablePart_%1%_%2%:hashpart[key=\"c__AccountID\"];\n"
        L"countableColl_%1%_%2%:coll[];\n"
        L"countable_%1%_%2% -> countablePart_%1%_%2% -> countableColl_%1%_%2%;\n"
        );
      
      mProgram += (countableFmt % mRatedUsage.GetViewID() % it->GetViewID() % it->GetTableName() % pvSelectList).str();

      countableOutput.push_back((boost::wformat(L"countableColl_%1%_%2%") % mRatedUsage.GetViewID() % it->GetViewID()).str());
    }
  }

  ASSERT(ratedUsageOutput.size() > 0);

  if (mRatedUsage.GetBillingGroupID() != -1)
  {
    std::wstring tmp;
    FilterRatedUsageOnBillingGroup(ratedUsageOutput, tmp);
    ratedUsageOutput = tmp;
  }
}

void AggregateRatingScript::FilterRatedUsageOnBillingGroup(const std::wstring& ratedUsage, std::wstring & outputRatedUsage)
{
  // Filter on billing group.
  // TODO: Optimize a bit by doing this prior to partitioning on payee,
  // so we can avoid a repartition.  Note that this isn't a huge win (or maybe none at all)
  // since in the common case in which rated is also countable we still
  // have to partition countable on payee.
  boost::wformat filterRatedUsageOnBillingGroupFmt(
    L"ratedUsagePayerRepartition_%3%:hashpart[key=\"c__PayingAccount\"];\n"
    L"ratedUsagePayerRepartitionColl_%3%:coll[];\n"
    L"billGroupMember_%3%:select[baseQuery=\"\n"
    L"SELECT bgm.id_acc as bgm_id_acc "
    L"FROM t_billgroup_member bgm "
    L"WHERE bgm.id_billgroup=%1% "
    L"AND {fn MOD(bgm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"billGroupMemberPart_%3%:hashpart[key=\"bgm_id_acc\"];\n"
    L"billGroupMemberColl_%3%:coll[];\n"
    L"billGroupMemberJoin_%3%:%4%[tableKey=\"bgm_id_acc\", probeKey=\"c__PayingAccount\"];\n"
    L"%2% -> ratedUsagePayerRepartition_%3% -> ratedUsagePayerRepartitionColl_%3% -> billGroupMemberJoin_%3%(\"probe(0)\");\n"
    L"billGroupMember_%3% -> billGroupMemberPart_%3% -> billGroupMemberColl_%3% -> billGroupMemberJoin_%3%(\"table\");\n"
    );
  
  mProgram += (filterRatedUsageOnBillingGroupFmt % 
               mRatedUsage.GetBillingGroupID() % 
               ratedUsage % 
               mRatedUsage.GetViewID() %
               (mIsRatedUsageCountable ? L"right_outer_hash_join" : L"inner_hash_join")).str();

  if (mIsRatedUsageCountable)
  {
    boost::wformat billGroupIsRatedFlagFmt (
      L"billGroupIsRatedFlag_%1%:expr[program=\"\n"
      L"CREATE PROCEDURE billGroupIsRatedFlag @bgm_id_acc INTEGER\n"
      L"@is_rated BOOLEAN\n"
      L"AS\n"
      L"SET @is_rated = CASE WHEN (@bgm_id_acc IS NULL) THEN FALSE ELSE @is_rated END\"];\n"
      L"billGroupMemberJoin_%1% -> billGroupIsRatedFlag_%1%;\n");

    mProgram += (billGroupIsRatedFlagFmt % mRatedUsage.GetViewID()).str();
    // Don't worry about repartitioning here.  If this usage has no counters then
    // we'll be repartitioning on id_sess/id_parent_sess.  If there are counters then
    // downstream logic will handle reparititoning on payee.
    outputRatedUsage = (boost::wformat(L"billGroupIsRatedFlag_%1%") % mRatedUsage.GetViewID()).str();

  }
  else
  {
    outputRatedUsage = (boost::wformat(L"billGroupMemberJoin_%1%") % mRatedUsage.GetViewID()).str();
  }
}

void AggregateRatingScript::GuideRatedUsageToBillingCycleAndPriceableItem(const std::wstring& ratedUsage, std::wstring & outputRatedUsage)
{

  boost::wformat guideRatedUsageToBillingCycleAndPriceableItem (
    L"aggregateSelect_%2%:select[baseQuery=\"\n"
    L"SELECT id_prop as ag_id_prop, id_usage_cycle as ag_id_cycle "
    L"FROM t_aggregate\", mode=\"sequential\"];\n"
    L"aggregatePart_%2%:broadcast[mode=\"sequential\"];\n"
    L"ratedUsageAggregateJoin_%2%:inner_hash_join[tableKey=\"ag_id_prop\", probeKey=\"id_pi_template_instance\"];\n"
    L"aggregateSelect_%2% -> aggregatePart_%2% -> ratedUsageAggregateJoin_%2%(\"table\");\n"
    L"%1% -> ratedUsageAggregateJoin_%2%(\"probe(0)\");\n"
    L"accUsageCycleSelect_%2%:select[baseQuery=\"\n"
    L"SELECT ui.id_interval as auc_id_interval, ui.id_usage_cycle as auc_id_cycle\n"
    L"FROM t_usage_interval ui\", mode=\"sequential\"];\n"
    L"accUsageCyclePart_%2%:broadcast[mode=\"sequential\"];\n"
    L"ratedUsageAccUsageCycleJoin_%2%:inner_hash_join[tableKey=\"auc_id_interval\", probeKey=\"id_usage_interval\"];\n"
    L"accUsageCycleSelect_%2% -> accUsageCyclePart_%2% -> ratedUsageAccUsageCycleJoin_%2%(\"table\");\n"
    L"ratedUsageAggregateJoin_%2% -> ratedUsageAccUsageCycleJoin_%2%(\"probe(0)\");\n"
    );

  mProgram += (guideRatedUsageToBillingCycleAndPriceableItem % ratedUsage % mRatedUsage.GetViewID()).str();
  outputRatedUsage = (boost::wformat(L"ratedUsageAccUsageCycleJoin_%1%") % mRatedUsage.GetViewID()).str();
}

void AggregateRatingScript::GuideToGroupSubscriptions(
  boost::int32_t id_pi_template,
  const std::wstring& ratedUsage, const std::vector<std::wstring > & countables,
  std::wstring& ratedUsageOutput, std::vector<std::wstring > & countablesOutput)
{
  // Now guide the transactions to subscriptions to figure out the associated counter.
  // In the group subscription case, the group subscription product offering must contain
  // the rated record template.  In the individual case we don't require subscriptions at all.
  // A remaining open question is whether the pi_instance comparison
  // needs to be in the predicate for rated records (we have actually already filtered out on template
  // in the select and then date range gives a unique sub anyway I think).
  std::wstring countableJoinSpecs;
  std::wstring countableGsubmemberJoinSpecFmt(
    L",\n"
    L"probe=\"right outer\", probeKey=\"c__AccountID\", residual=\"\n"
    L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_gsm_vt_start DATETIME @Table_gsm_vt_end DATETIME)\n"
    L"RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_c_SessionDate >= @Table_gsm_vt_start AND @Probe_c_SessionDate <= @Table_gsm_vt_end\"");
  std::wstring joinArrows;
  boost::wformat countableGroupSubscriptionFmt (
    L"countableGroupSubscriptionFlag_%4%_%1%:expr[program=\"\n"
    L"CREATE PROCEDURE countableGroupSubscriptionFlag @gsm_id_acc INTEGER \n"
    L"@gsm_shared_flag VARCHAR\n"
    L"@is_shared_counter BOOLEAN OUTPUT\n"
    L"AS\n"
    L"SET @is_shared_counter = CASE WHEN (NOT @gsm_id_acc IS NULL) AND @gsm_shared_flag = 'Y' THEN TRUE ELSE FALSE END\"];\n"
    L"%3% -> ratedUsageGsubmemberJoin_%4%(\"probe(%2%)\");\n"
    L"ratedUsageGsubmemberJoin_%4%(\"output(%2%)\") -> countableGroupSubscriptionFlag_%4%_%1%;\n"
    );

  for(std::size_t i=0; i<countables.size(); i++)
  {
    countableJoinSpecs += countableGsubmemberJoinSpecFmt;
    joinArrows += (countableGroupSubscriptionFmt % i % (i+1) % countables[i] % mRatedUsage.GetViewID()).str();
    countablesOutput.push_back((boost::wformat(L"countableGroupSubscriptionFlag_%1%_%2%") % mRatedUsage.GetViewID() % i).str());
  }


  boost::wformat guideToGroupSubscriptionsFmt (
    L"gsubmemberSelect_%4%:select[baseQuery=\"\n"
    L"SELECT gsm.id_acc as gsm_id_acc, plm.id_pi_instance as gsm_id_pi_instance, gsm.id_group as gsm_id_group, gs.b_supportgroupops gsm_shared_flag, ag.id_usage_cycle as gsm_ag_id_cycle, gs.id_usage_cycle as gsm_id_cycle, gsm.vt_start as gsm_vt_start, gsm.vt_end as gsm_vt_end "
    L"FROM t_gsubmember gsm "
    L"INNER JOIN t_group_sub gs ON gs.id_group=gsm.id_group "
    L"INNER JOIN t_sub s ON s.id_group=gs.id_group "
    L"INNER JOIN t_pl_map plm ON plm.id_po=s.id_po "
    L"INNER JOIN t_aggregate ag ON plm.id_pi_instance=ag.id_prop "
    L"WHERE plm.id_paramtable IS NULL AND plm.id_pi_template=%1% "
    L"AND {fn MOD(gsm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"gsubmemberPart_%4%:hashpart[key=\"gsm_id_acc\"];\n"
    L"gsubmemberColl_%4%:coll[];\n"
    L"gsubmemberSelect_%4% -> gsubmemberPart_%4% -> gsubmemberColl_%4%;\n"
    L"ratedUsageGsubmemberJoin_%4%:multi_hash_join[tableKey=\"gsm_id_acc\", \n"
    L"probe=\"right outer\", probeKey=\"c__AccountID\", residual=\"\n"
    L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_gsm_vt_start DATETIME @Table_gsm_vt_end DATETIME\n"
    L"@Probe_c__PriceableItemInstanceID INTEGER @Table_gsm_id_pi_instance INTEGER) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_c_SessionDate >= @Table_gsm_vt_start AND @Probe_c_SessionDate <= @Table_gsm_vt_end\n"
    L"AND @Table_gsm_id_pi_instance = @Probe_c__PriceableItemInstanceID\"%2%];\n"
    L"gsubmemberColl_%4% -> ratedUsageGsubmemberJoin_%4%(\"table\");\n"
    L"%3% -> ratedUsageGsubmemberJoin_%4%(\"probe(0)\");\n"
    L"ratedUsageGroupSubscriptionFlag_%4%:expr[program=\"\n"
    L"CREATE PROCEDURE ratedUsageGroupSubscriptionFlag @gsm_id_acc INTEGER\n"
    L"@gsm_shared_flag VARCHAR\n"
    L"@is_shared_counter BOOLEAN OUTPUT\n"
    L"AS\n"
    L"SET @is_shared_counter = CASE WHEN (NOT @gsm_id_acc IS NULL) AND @gsm_shared_flag = 'Y' THEN TRUE ELSE FALSE END\"];\n"
    L"ratedUsageGsubmemberJoin_%4%(\"output(0)\") -> ratedUsageGroupSubscriptionFlag_%4%;\n"
    );

  mProgram += (guideToGroupSubscriptionsFmt %  id_pi_template % countableJoinSpecs % ratedUsage % mRatedUsage.GetViewID()).str();
  mProgram += joinArrows;
  ratedUsageOutput = (boost::wformat(L"ratedUsageGroupSubscriptionFlag_%1%") % mRatedUsage.GetViewID()).str(); 
}

// At the metadata level this performs:
//
// ratedUsage(@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR,  ...) 
// -------------> 
// ratedUsage(@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER,  ...) 
//
// countable (@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR,  ...) 
// -------------> 
// countable (@gsm_ag_id_cycle INTEGER, @gsm_id_cycle INTEGER, 
//            @gsm_id_group INTEGER, @c__AccountID INTEGER, 
//            @gsm_shared_flag VARCHAR, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER,  ...) 
//
void AggregateRatingScript::ProcessGroupSubscriptions(const std::wstring& ratedUsage, 
                                                      const std::vector<std::wstring > & countables,
                                                      std::wstring& ratedUsageOutput, 
                                                      std::vector<std::wstring > & countablesOutput)
{
  // Countables and rated usage are handled the same with group subs.  Each usage record
  // contributes to exactly one counter stream: the one associated with the group sub in effect
  // at the time the usage record occurred.
  // There are two sub cases depending on whether shared counters are configured or not.  In the
  // case of shared counters, the group subscription id identifies the counter stream in the non-shared
  // counter case, the group subscription member (id_payee of the usage record) identifies the counter
  // stream.  In all cases, we need to take care to keep the different cases separate so we put in
  // a counter stream type.

  boost::wformat ratedUsageAggCycleExprFmt (
    L"ratedUsageAggCycleExpr_%1%:expr[program=\"\n"
    L"CREATE PROCEDURE expr "
    L"@is_shared_counter BOOLEAN\n"
    L"@gsm_ag_id_cycle INTEGER @gsm_id_cycle INTEGER @id_counter_stream_cycle INTEGER\n"
    L"@gsm_id_group INTEGER @c__AccountID INTEGER @gsm_shared_flag VARCHAR @id_counter_stream INTEGER\n"
    L"@counter_stream_type INTEGER "
    L"AS\n"
    L"IF @is_shared_counter\n"
    L"BEGIN\n"
    L"SET @id_counter_stream_cycle = CASE WHEN @gsm_ag_id_cycle IS NULL "
    L"THEN @gsm_id_cycle "
    L"ELSE @gsm_ag_id_cycle END "
    L"SET @id_counter_stream = CASE WHEN @gsm_shared_flag = 'Y' THEN @gsm_id_group ELSE @c__AccountID END\n "
    L"SET @counter_stream_type = CASE WHEN @gsm_shared_flag = 'Y' THEN 2 ELSE 3 END\n"
    L"END\"];\n"
    L"%2% -> ratedUsageAggCycleExpr_%1%;\n");
  mProgram += (ratedUsageAggCycleExprFmt % mRatedUsage.GetViewID() % ratedUsage).str();
  ratedUsageOutput  = (boost::wformat(L"ratedUsageAggCycleExpr_%1%") % mRatedUsage.GetViewID()).str();

  for(std::size_t i=0; i<countables.size(); i++)
  {
    boost::wformat ratedUsageAggCycleExprFmt (
      L"countableAggCycleExpr_%3%_%1%:expr[program=\"\n"
      L"CREATE PROCEDURE expr "
      L"@is_shared_counter BOOLEAN\n"
      L"@gsm_ag_id_cycle INTEGER @gsm_id_cycle INTEGER @id_counter_stream_cycle INTEGER\n"
      L"@gsm_id_group INTEGER @c__AccountID INTEGER @gsm_shared_flag VARCHAR @id_counter_stream INTEGER\n"
      L"@counter_stream_type INTEGER "
      L"AS\n"
      L"IF @is_shared_counter\n"
      L"BEGIN\n"
      L"SET @id_counter_stream_cycle = CASE WHEN @gsm_ag_id_cycle IS NULL "
      L"THEN @gsm_id_cycle "
      L"ELSE @gsm_ag_id_cycle END "
      L"SET @id_counter_stream = CASE WHEN @gsm_shared_flag = 'Y' THEN @gsm_id_group ELSE @c__AccountID END\n "
      L"SET @counter_stream_type = CASE WHEN @gsm_shared_flag = 'Y' THEN 2 ELSE 3 END\n"
      L"END\"];\n"
      L"%2% -> countableAggCycleExpr_%3%_%1%;\n");
    mProgram += (ratedUsageAggCycleExprFmt % i % countables[i] % mRatedUsage.GetViewID()).str();
    countablesOutput.push_back((boost::wformat(L"countableAggCycleExpr_%1%_%2%") % mRatedUsage.GetViewID() % i).str());
  }
}

// At the metadata level this performs:
//
// ratedUsage(c__AccountID INTEGER, ag_id_cycle INTEGER, auc_id_cycle INTEGER, ...) 
// -------------> 
// ratedUsage(c__AccountID INTEGER, ag_id_cycle INTEGER, 
//            auc_id_cycle INTEGER, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER, ...)
// countable[i](c__AccountID INTEGER, ...) 
// -------------> 
// countable[i](c__AccountID INTEGER, id_counter_stream_cycle INTEGER, 
//            id_counter_stream INTEGER, counter_stream_type INTEGER, ...)
//
void AggregateRatingScript::ProcessIndividualSubscriptions(boost::int32_t id_pi_template, 
                                                           const std::wstring& ratedUsage, 
                                                           const std::vector<std::wstring > & countables,
                                                           std::wstring& ratedUsageOutput, 
                                                           std::vector<std::wstring > & countablesOutput)
{
  // In the group subscription case, rated usage and countables are handled in a somewhat similar
  // fashion in the sense that each rated or countable record is associated with a unique group subscription
  // (containing the priceable item template we are rating) and the aggregate cycle derives from that subscription
  // (TODO: careful about BCR in the non-shared case...).
  // The non-group subscription case (which we may or may not want to assume is the individual subscription case
  // depending on whether we want to support the historical notion of non-subscription aggregate rating) is a bit
  // different in that rated usage is associated with a unique counter stream (determined by the payee and cycle 
  // determined by the pi template or
  // instance of the rated record in question or cycle of the payer of the record in the
  // BCR case).  On the other hand, it is possible for a countable that occurs off group subscription to be
  // counted multiple times (if there are multiple intervals in play due to non-subscription and individual 
  // subscription or multiple individual subscriptions).  These records are guided to counter streams based purely
  // on id_payee (possibly hitting multiple counter streams if there are multiple cycles)
  // and thence to a specific counter based on date range of the counters.
  // This grabs the individual counter streams from the database.
  // 1) Rated records guide to these using payee and aggregate/payer cycle (hence are guided to a exactly one).
  // 2) Countable records guide to these using only the payee (hence are guided to one or more).
  // TODO: Possible optimization here is to only pick countables that have
  // an associated usage event in the current interval.  That will allow us to
  // avoid calculating running totals that will never be used but will cause
  // us to scan the current interval an extra time.  Need to understand when this
  // optimization is worthwhile.

  std::wstring multiJoinProbeSpecifications;
  std::wstring multiJoinInputArrows;

  boost::wformat ratedUsageInidividualCounterJoinSpec(
    L", probe=\"right outer\", probeKey=\"c__AccountID\", probeKey=\"is_shared_counter\"%1%\n");
  
  boost::wformat countableMultiJoinArrowFmt(
    L"%2% -> usageIndividualCounterStreamJoin_%3%(\"probe(%1%)\");\n");

  multiJoinProbeSpecifications += (
    ratedUsageInidividualCounterJoinSpec % (
      !mIsRatedUsageCountable ?
      L", residual=\"\n"
      L"CREATE FUNCTION residual (@Probe_ag_id_cycle INTEGER @Probe_gsm_id_cycle INTEGER @Probe_auc_id_cycle INTEGER @Table_id_counter_stream_cycle INTEGER)\n" 
      L"RETURNS BOOLEAN\n"
      L"AS\n"
      L"RETURN CASE WHEN @Probe_ag_id_cycle IS NULL THEN CASE WHEN @Probe_gsm_id_cycle IS NULL THEN @Probe_auc_id_cycle ELSE @Probe_gsm_id_cycle END ELSE @Probe_ag_id_cycle END "
      L"= "
      L"@Table_id_counter_stream_cycle\"" :
      L"")).str();

  multiJoinInputArrows += (boost::wformat(L"%1% -> usageIndividualCounterStreamJoin_%2%(\"probe(0)\");\n") % ratedUsage % mRatedUsage.GetViewID()).str();

  if(mIsRatedUsageCountable)
  {
    // In this case some of the records produced may not satisfy the predicate in the residual
    // above.  This means that they are countable records but not rated, but the records that don't satisfy the
    // predicate must have their is_rated flag cleared.
    boost::wformat clearRatedFlagFmt(
      L"clearRatedFlag_%1%:expr[program=\"\n"
      L"CREATE PROCEDURE clearRatedFlag @is_shared_counter BOOLEAN @ag_id_cycle INTEGER @gsm_id_cycle INTEGER @auc_id_cycle INTEGER @id_counter_stream_cycle INTEGER @is_rated BOOLEAN\n"
      L"AS\n"
      L"IF (NOT @is_shared_counter) AND @is_rated\n"
      L"SET @is_rated = \n"
      L"CASE WHEN \n"
      L"  CASE WHEN @ag_id_cycle IS NULL \n"
      L"  THEN \n"
      L"    CASE WHEN @gsm_id_cycle IS NULL \n"
      L"    THEN @auc_id_cycle \n"
      L"    ELSE @gsm_id_cycle END\n"
      L"  ELSE @ag_id_cycle END\n"
      L"  =\n"
      L"  @id_counter_stream_cycle \n"
      L"THEN TRUE \n"
      L"ELSE FALSE END\"];\n"
      L"usageIndividualCounterStreamJoin_%1%(\"output(0)\") -> clearRatedFlag_%1%;\n");
    
    multiJoinInputArrows += (clearRatedFlagFmt % mRatedUsage.GetViewID()).str();
    ratedUsageOutput = (boost::wformat(L"clearRatedFlag_%1%(0)") % mRatedUsage.GetViewID()).str();
  }
  else
  {
    ratedUsageOutput = (boost::wformat(L"usageIndividualCounterStreamJoin_%1%(\"output(0)\")") % mRatedUsage.GetViewID()).str();
  }

  for (std::size_t i=0; i<countables.size(); i++)
  {
    multiJoinProbeSpecifications += (ratedUsageInidividualCounterJoinSpec % L"").str();
    multiJoinInputArrows += (countableMultiJoinArrowFmt % (i+1) % countables[i] % mRatedUsage.GetViewID()).str();
    countablesOutput.push_back((boost::wformat(L"usageIndividualCounterStreamJoin_%2%(\"output(%1%)\")") % (i+1) % mRatedUsage.GetViewID()).str());
  }

  boost::wformat processIndividualSubscriptionFmt(
    L"individualCounterSelect_%4%:select[baseQuery=\"\n"
    L"select\n"
    L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
    L"ui.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
    L"s.id_acc as id_counter_stream \n"
    L"from t_pl_map plm\n"
    L"inner join t_aggregate a on a.id_prop=plm.id_pi_instance\n"
    L"inner join t_sub s on s.id_po=plm.id_po\n"
    L"inner join t_payment_redirection pay on pay.id_payee=s.id_acc\n"
    L"inner join t_acc_usage_interval aui on pay.id_payer=aui.id_acc\n"
    L"inner join t_usage_interval ui on ui.id_interval=aui.id_usage_interval\n"
    L"where\n"
    L"plm.id_paramtable is null\n"
    L"and plm.id_pi_template = %1%\n"
    L"and s.id_group is null\n"
    L"AND {fn MOD(s.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"nonSubscriptionCounterSelect_%4%:select[baseQuery=\"\n"
    L"select\n"
    L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
    L"ui.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
    L"acc.id_acc as id_counter_stream \n"
    L"from t_account acc\n"
    L"inner join t_payment_redirection pay on pay.id_payee=acc.id_acc\n"
    L"inner join t_acc_usage_interval aui on pay.id_payer=aui.id_acc\n"
    L"inner join t_usage_interval ui on ui.id_interval=aui.id_usage_interval\n"
    L"cross join t_aggregate a\n"
    L"where\n"
    L"a.id_prop = %1%\n"
    L"AND {fn MOD(acc.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"nonSharedGroupCounterSelect_%4%:select[baseQuery=\"\n"
    L"SELECT\n"
    L"a.id_usage_cycle as indiv_agg_id_usage_cycle,\n"
    L"gs.id_usage_cycle as indiv_auc_id_usage_cycle,\n"
    L"gsm.id_acc as id_counter_stream \n"
    L"FROM t_pl_map plm\n"
    L"INNER JOIN t_sub s ON s.id_po=plm.id_po\n"
    L"INNER JOIN t_group_sub gs ON s.id_group=gs.id_group\n"
    L"INNER JOIN t_gsubmember gsm ON gsm.id_group=gs.id_group\n"
    L"INNER JOIN t_aggregate a ON a.id_prop=plm.id_pi_instance\n"
    L"WHERE\n"
    L"plm.id_pi_template = %1%\n"
    L"AND plm.id_paramtable is null\n"
    L"AND gs.b_supportgroupops = 'N'\n"
    L"AND {fn MOD(gsm.id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"indivSubNonSubCounterStreamUnion_%4%:union_all[];\n"
    L"individualCounterSelect_%4% -> indivSubNonSubCounterStreamUnion_%4%(0);\n"
    L"nonSubscriptionCounterSelect_%4%-> indivSubNonSubCounterStreamUnion_%4%(1);\n"
    L"nonSharedGroupCounterSelect_%4% -> indivSubNonSubCounterStreamUnion_%4%(2);\n"
    L"individualCounterExpr_%4%:expr[program=\"\n"
    L"CREATE PROCEDURE individualCounterExpr @indiv_agg_id_usage_cycle INTEGER @indiv_auc_id_usage_cycle INTEGER @id_counter_stream_cycle INTEGER OUTPUT @counter_stream_type INTEGER OUTPUT @counter_stream_is_shared_counter BOOLEAN OUTPUT\n"
    L"AS\n"
    L"SET @id_counter_stream_cycle = CASE WHEN @indiv_agg_id_usage_cycle IS NULL THEN @indiv_auc_id_usage_cycle ELSE @indiv_agg_id_usage_cycle END\n"
    L"SET @counter_stream_type = 1\n"
    L"SET @counter_stream_is_shared_counter = FALSE\"];\n"
    L"individualCounterDistinct_%4%:hash_group_by[key=\"id_counter_stream_cycle\", key=\"id_counter_stream\", key = \"counter_stream_type\", key = \"counter_stream_is_shared_counter\", \n"
    L"initialize=\"\n"
    L"CREATE PROCEDURE initializer @Table_individual_counter_stream_count INTEGER\n"
    L"AS\n"
    L"SET @Table_individual_counter_stream_count = 0\",\n"
    L"update=\"\n"
    L"CREATE PROCEDURE updater @Table_individual_counter_stream_count INTEGER\n"
    L"AS\n"
    L"SET @Table_individual_counter_stream_count = @Table_individual_counter_stream_count + 1\"];\n"
    L"individualCounterPart_%4%:hashpart[key=\"id_counter_stream\"];\n"
    L"individualCounterColl_%4%:coll[];\n"
    L"indivSubNonSubCounterStreamUnion_%4% -> individualCounterExpr_%4% -> individualCounterDistinct_%4%;\n"
    L"usageIndividualCounterStreamJoin_%4%:multi_hash_join[tableKey=\"id_counter_stream\", tableKey=\"counter_stream_is_shared_counter\"%2%];\n"
    L"individualCounterDistinct_%4% -> individualCounterPart_%4% -> individualCounterColl_%4% -> usageIndividualCounterStreamJoin_%4%(\"table\");\n"
    L"%3%"
);

  mProgram += (processIndividualSubscriptionFmt % id_pi_template % multiJoinProbeSpecifications % multiJoinInputArrows % mRatedUsage.GetViewID()).str();
 
}

void AggregateRatingScript::CalculateRunningTotal(const std::wstring& ratedUsage, 
                                                  const std::vector<std::wstring >& countables,
                                                  std::wstring& outputRatedUsage)
{
  ASSERT((!mIsRatedUsageCountable && countables.size() == mCountables.size()) ||
         (mIsRatedUsageCountable && countables.size() == mCountables.size()-1));

  std::wstring updaters;

  boost::wformat updateCounterFmt(
    L",\n"
    L"update = \"%1%\"");

  std::wstring inputArrows;

  boost::wformat inputArrowsFmt(
    L"countablegroupSharedCounterPart_%4%_%1%:hashpart[key=\"id_counter_stream\", key=\"counter_stream_type\", key=\"pc_id_interval\"];\n"
    L"countablegroupSharedCounterColl_%4%_%1%:coll[];\n"
    L"countablegroupSharedCounterSort_%4%_%1%:sort[key=\"c_BillingIntervalEnd\", key=\"c_SessionDate\", key=\"id_parent_sess\", key=\"id_sess\", allowedMemory=100000000, temp_dir=\"%5%\"];\n"
    L"%3% -> countablegroupSharedCounterPart_%4%_%1% -> countablegroupSharedCounterColl_%4%_%1% -> countablegroupSharedCounterSort_%4%_%1% -> groupSharedCounterRunningTotal_%4%(%2%);\n");

  // Now we are assuming group sub shared counter.  A counter is specified by id_group, pc_id_interval.
  // All inputs have the same keys.
  // Rated usage goes as the first input.  If it is not countable, it has an empty updater,
  // else it gets the updater from its associated countable spec.
  if (mIsRatedUsageCountable)
  {
    for(std::vector<AggregateRatingCountableSpec>::iterator it =  mCountables.begin();
        it != mCountables.end();
        it++)
    {
      if (it->GetTableName() == mRatedUsage.GetTableName()) 
      {
        updaters += (updateCounterFmt % it->GetUpdateProgram()).str();
        break;
      }
    }
  }
  else
  {
    updaters += (updateCounterFmt % L"").str();
  }
  // Non-rated usage countables go next.
  for(std::vector<AggregateRatingCountableSpec>::iterator it =  mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() != mRatedUsage.GetTableName()) 
    {
      updaters += (updateCounterFmt % it->GetUpdateProgram()).str();
    }
  }
  // Feed in the countables.
  for(std::size_t i = 0; i<countables.size(); i++)
  {
    inputArrows += (inputArrowsFmt % i % (i+1) % countables[i] % mRatedUsage.GetViewID() % mSortDir).str();
  }

//   // This is either super ugly or super cool.  
//   // We want to stich together the group and individual case.  So we remove the
//   // fields they don't have in common.  Unfortunately some of the important common fields are
//   // being dynamic passed in and aren't available until type check time (that is to say we don;t
//   // know them right now).  On the other hand, we don't know the list of fields that they
//   // don't have in common so we can remove them with a complementary projection (sure can't do this
//   // with SQL eh!).
//   DesignTimeProjection * projection = new DesignTimeProjection();
//   projection->SetName(L"projectUnused");
//   mPlan.push_back(projection);
//   std::vector<std::wstring> exclusionList;
//   exclusionList.push_back(L"pc_id_interval");
//   exclusionList.push_back(L"pc_id_cycle");
//   exclusionList.push_back(L"gsm_id_acc");
//   exclusionList.push_back(L"gsm_id_pi_instance");
//   exclusionList.push_back(L"gsm_id_group");
//   exclusionList.push_back(L"gsm_shared_flag");
//   exclusionList.push_back(L"gsm_ag_id_cycle");
//   exclusionList.push_back(L"gsm_id_cycle");
//   exclusionList.push_back(L"gsm_vt_start");
//   exclusionList.push_back(L"gsm_vt_end");
//   exclusionList.push_back(L"id_counter_stream_cycle");
//   exclusionList.push_back(L"id_counter_stream");
//   exclusionList.push_back(L"individual_counter_stream_count");
//   exclusionList.push_back(L"counter_stream_type");
//   exclusionList.push_back(L"id_counter_stream#");
//   exclusionList.push_back(L"counter_stream_type#");
//   exclusionList.push_back(L"pc_id_interval#");
//   exclusionList.push_back(L"auc_id_interval");
//   exclusionList.push_back(L"auc_id_cycle");
//   exclusionList.push_back(L"ag_id_prop");
//   exclusionList.push_back(L"ag_id_cycle");
//   exclusionList.push_back(L"id_pi_template_instance");
//   exclusionList.push_back(L"id_countable");
//   exclusionList.push_back(L"id_rated");
//   projection->SetProjection(exclusionList, true);
//   mPlan.push_back(new DesignTimeChannel(filterOutNonRatedUsage->GetOutputPorts()[0], 
//                                         projection->GetInputPorts()[0]));



  boost::wformat calculateRunningTotalFmt(
    L"groupSharedCounterPart_%5%:hashpart[key=\"id_counter_stream\", key=\"counter_stream_type\", key=\"pc_id_interval\"];\n"
    L"groupSharedCounterColl_%5%:coll[];\n"
    L"groupSharedCounterSort_%5%:sort[key=\"c_BillingIntervalEnd\", key=\"c_SessionDate\", key=\"id_parent_sess\", key=\"id_sess\", allowedMemory=100000000, temp_dir=\"%6%\"];\n"
    L"groupSharedCounterRunningTotal_%5%:hash_running_total[sortKey=\"c_BillingIntervalEnd\", sortKey=\"c_SessionDate\", sortKey=\"id_parent_sess\", sortKey=\"id_sess\", key=\"id_counter_stream\", key=\"counter_stream_type\", key=\"pc_id_interval\",\n"
    L"initialize=\"\n"
    L"%1%\"%2%];\n"
    L"%3% -> groupSharedCounterPart_%5% -> groupSharedCounterColl_%5% -> groupSharedCounterSort_%5% -> groupSharedCounterRunningTotal_%5%(0);\n"
    L"%4%"
    L"filterOutNonRatedUsage_%5%:filter[program=\"\n"
    L"CREATE FUNCTION filterOutNonRatedUsage (@is_rated BOOLEAN) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @is_rated\"];\n"
    L"runningTotalPart_%5%:hashpart[key=\"id_compound_sess\"];\n"
    L"runningTotalColl_%5%:coll[];\n"
    L"groupSharedCounterRunningTotal_%5% -> filterOutNonRatedUsage_%5% -> runningTotalPart_%5% -> runningTotalColl_%5%;\n"
    L"runningTotalSort_%5%:sort[key=\"id_compound_sess\", key=\"id_sess\", allowedMemory=50000000, temp_dir=\"%6%\"];\n"
    L"runningTotalColl_%5% -> runningTotalSort_%5%;\n"
    L"runningTotalForMeteringRename_%5%:rename[\n"
    L"from=\"id_sess\", to=\"hide_id_sess\",\n"
    L"from=\"id_compound_sess\", to=\"hide_id_compound_sess\",\n"
    L"from=\"is_rated\", to=\"hide_is_rated\"];\n"
    L"ratedUsageForMeteringSort_%5% -> runningTotalForMeteringRename_%5%;\n"
    L"runningTotalForMeteringJoin_%5%:inner_merge_join[rightKey=\"hide_id_compound_sess\", rightKey=\"hide_id_sess\", leftKey=\"id_compound_sess\", leftKey=\"id_sess\"];\n"
    L"runningTotalSort_%5% -> runningTotalForMeteringJoin_%5%(\"left\");\n"
    L"runningTotalForMeteringRename_%5% -> runningTotalForMeteringJoin_%5%(\"right\");\n"
    );

  mProgram += (calculateRunningTotalFmt % mRatedUsage.GetInitializeProgram() % updaters % ratedUsage % inputArrows % mRatedUsage.GetViewID() % mSortDir).str();

  // One last repartition.  Technically this is only necessary for compounds.  The issue is that we
  // are going to meter and the different components of a compound may be partitioned on different
  // counters.  To bring everyone together for final metering means finding a compatible partitioning key.
  // Here we choose id_sess/id_parent_sess.  
  // We also rejoin the non-countable part of the rated usage to the countable part with a merge join.
  // Note also that one might think that payee is a reasonable partitioning key, but PMNA has
  // essentially invalidated the business rule that payee is constant over compounds; no matter,
  // partitioning compounds will almost certainly generate even distribution heading into metering.
  outputRatedUsage = (boost::wformat(L"runningTotalForMeteringJoin_%1%") % mRatedUsage.GetViewID()).str();
}

AggregateRatingScript::AggregateRatingScript(std::wstring & program,
                                 const AggregateRatingUsageSpec & ratedUsage,
                                 const std::vector<AggregateRatingCountableSpec>& countables,
                                 bool readAllRatedUsageColumns)
  :
  mProgram(program),
  mRatedUsage(ratedUsage),
  mCountables(countables),
  mIsRatedUsageCountable(false),
  mReadAllRatedUsageColumns(readAllRatedUsageColumns)
{
  // Figure out if there is a sort directory specified.
  // In the future we should add an argument so that this can
  // be passed in from the adapter configuration but since we are
  // patching with this change we keep the API the same and use
  // environment variables to configure this.
  if (getenv("METRAFLOW_TEMP") != NULL)
  {
    ::ASCIIToWide(mSortDir, getenv("METRAFLOW_TEMP"));
  }
  else if (getenv("TEMP") != NULL)
  {
    ::ASCIIToWide(mSortDir, getenv("TEMP"));
  }
  else if (getenv("TMP") != NULL)
  {
    ::ASCIIToWide(mSortDir, getenv("TMP"));
  }  
  else
  {
    mSortDir = L"C:\\";
  }

  boost::int32_t id_pi_template=mRatedUsage.GetPriceableItemTemplateID();
  boost::int32_t id_view = mRatedUsage.GetViewID();

  for(std::vector<AggregateRatingCountableSpec>::iterator it = mCountables.begin();
      it != mCountables.end();
      it++)
  {
    if (it->GetTableName() == mRatedUsage.GetTableName()) 
    {
      mIsRatedUsageCountable = true;
      break;
    }
  }
  
  ////////////////////
  // Note that in the BCR case, we get to restrict reading to an interval.
  // In the non-BCR case we really have to scan everything because we don't
  // a-priori know which intervals will contain usage in the aggregate interval.
  // This really increases the performance requirement.  On the other hand,
  // this calculation could be done with a single group by rather than a running total
  // calculation.  It also might be meaningful to
  // store the results of this group by on a per interval basis during soft close (a 
  // new kind of adapter).
  
  std::wstring readRatedUsage;
  std::vector<std::wstring > readCountables;
  ReadRatedUsageAndCountables(readRatedUsage, readCountables);

  if (countables.size() == 0)
  {
    ASSERT(readCountables.size() == 0);
    
    // There are no countables (i.e. this is a non-aggregate rated PI within
    // an aggregate rated compound PI).  Our contract is to partition on id_compound_sess
    // and we are repartitioned either on payee (no billing groups) or payer (with billing groups).
    boost::wformat finalRatedUsageFmt(
      L"finalRatedUsagePart_%1%:hashpart[key=\"id_compound_sess\"];\n"
      L"finalRatedUsageColl_%1%:coll[];\n"
      L"%2% -> finalRatedUsagePart_%1% -> finalRatedUsageColl_%1%;\n"
      L"finalRatedUsageSort_%1%:sort[key=\"id_compound_sess\", allowedMemory=50000000, temp_dir=\"%3%\"];\n"
      L"finalRatedUsageColl_%1% -> finalRatedUsageSort_%1%;\n"
      );
    mProgram += (finalRatedUsageFmt % mRatedUsage.GetViewID() % readRatedUsage % mSortDir).str();
    mOutputPort = (boost::wformat(L"finalRatedUsageSort_%1%") % mRatedUsage.GetViewID()).str();
    return;
  }

  if (mRatedUsage.GetBillingGroupID() != -1)
  {
    // If billing groups then must repartition on payee.
    boost::wformat ratedUsagePayeeRepartitionFmt(
      L"ratedUsagePayeeRepartition_%1%:hashpart[key=\"c__AccountID\"];\n"
      L"ratedUsagePayeeRepartitionColl_%1%:coll[];\n"
      L"%2% -> ratedUsagePayeeRepartition_%1% -> ratedUsagePayeeRepartitionColl_%1%;\n"
      );
    mProgram += (ratedUsagePayeeRepartitionFmt % mRatedUsage.GetViewID() % readRatedUsage).str();
    readRatedUsage = (boost::wformat(L"ratedUsagePayeeRepartitionColl_%1%") % mRatedUsage.GetViewID()).str();
  }
  
  //
  // Figure out subscription guiding rules.
  //
  std::wstring groupSubGuidedRatedUsage;
  std::vector<std::wstring > groupSubGuidedCountableUsage;
  GuideToGroupSubscriptions(id_pi_template,
                            readRatedUsage, readCountables,
                            groupSubGuidedRatedUsage, groupSubGuidedCountableUsage);

  //
  // At this point we know individual subscription versus group subscription.
  // Apply different rules to figure out counter stream that applies to rated
  // usage and countable usage.
  //
  std::wstring cyclePiGuidedRatedUsage;
  GuideRatedUsageToBillingCycleAndPriceableItem(groupSubGuidedRatedUsage, cyclePiGuidedRatedUsage);
  // Individual subscription counter stream rules.
  std::wstring individualCounterStreamRatedUsage;
  std::vector<std::wstring > individualCounterStreamCountable;
  ProcessIndividualSubscriptions(id_pi_template, 
                                 cyclePiGuidedRatedUsage,   
                                 groupSubGuidedCountableUsage,
                                 individualCounterStreamRatedUsage,
                                 individualCounterStreamCountable);
  // Group subscription counter stream rules.
  std::wstring counterStreamRatedUsage;
  std::vector<std::wstring > counterStreamCountable;
  ProcessGroupSubscriptions(individualCounterStreamRatedUsage,
                            individualCounterStreamCountable,
                            counterStreamRatedUsage,
                            counterStreamCountable);

  //
  // Now the counter stream is identified.  Use effective dates
  // to guide to the appropriate counter (i.e. the interval) within the stream.
  //
  std::wstring counterRatedUsage;
  std::vector<std::wstring > counterCountable;
//   LookupCounterInterval(counterStreamRatedUsageGroupSubscription,
//                         counterStreamCountableGroupSubscription,
//                         counterStreamRatedUsageIndividualSubscription,
//                         counterStreamCountableIndividualSubscription,
//                         counterRatedUsageGroupSubscription,
//                         counterCountableGroupSubscription,
//                         counterRatedUsageIndividualSubscription,
//                         counterCountableIndividualSubscription);

  std::wstring ratedUsagePcIntervalJoinSpecs;
  std::wstring ratedUsagePcIntervalJoinSpecFmt(
    L", \n"
    L"probe=\"inner\",\n"
    L"probeKey=\"id_counter_stream_cycle\",\n"
    L"residual=\"\n"
    L"CREATE FUNCTION residual (@Probe_c_SessionDate DATETIME @Table_c_AggregateIntervalStart DATETIME @Table_c_AggregateIntervalEnd DATETIME)\n"
    L"RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @Probe_c_SessionDate >= @Table_c_AggregateIntervalStart AND @Probe_c_SessionDate <= @Table_c_AggregateIntervalEnd\""
    );

  std::wstring ratedUsagePcIntervalJoinArrows;
  boost::wformat ratedUsagePcIntervalJoinArrowsFmt (L"%1% -> ratedUsagePcIntervalJoin_%2%(\"probe(%3%)\");\n");
  // Use the same probe spec for every input.
  ratedUsagePcIntervalJoinSpecs += ratedUsagePcIntervalJoinSpecFmt;
  ratedUsagePcIntervalJoinArrows += (ratedUsagePcIntervalJoinArrowsFmt % counterStreamRatedUsage % mRatedUsage.GetViewID() % 0).str();
  counterRatedUsage = (boost::wformat(L"ratedUsagePcIntervalJoin_%1%(\"output(0)\")") % mRatedUsage.GetViewID()).str();
    
  for(std::size_t i = 0; i< counterStreamCountable.size(); i++)
  {
    ratedUsagePcIntervalJoinSpecs += ratedUsagePcIntervalJoinSpecFmt;
    ratedUsagePcIntervalJoinArrows += (ratedUsagePcIntervalJoinArrowsFmt % counterStreamCountable[i] % mRatedUsage.GetViewID() % (i+1)).str();
    counterCountable.push_back((boost::wformat(L"ratedUsagePcIntervalJoin_%1%(\"output(%2%)\")") % mRatedUsage.GetViewID() % (i+1)).str());
  }

  boost::wformat ratedUsagePcIntervalJoinFmt (
    L"pcIntervalSelect_%3%:select[baseQuery=\"\n"
    L"SELECT id_interval as pc_id_interval, id_cycle as pc_id_cycle, dt_start as c_AggregateIntervalStart, dt_end as c_AggregateIntervalEnd "
    L"FROM t_pc_interval\",\n"
    L"mode=\"sequential\"];\n"
    L"pcIntervalPart_%3%:broadcast[mode=\"sequential\"];\n"
    L"ratedUsagePcIntervalJoin_%3%:multi_hash_join[tableKey=\"pc_id_cycle\""
    L"%1%];\n"
    L"pcIntervalSelect_%3% -> pcIntervalPart_%3% -> ratedUsagePcIntervalJoin_%3%(\"table\");\n"
    L"%2%"
    );
    
  mProgram += (ratedUsagePcIntervalJoinFmt % ratedUsagePcIntervalJoinSpecs % ratedUsagePcIntervalJoinArrows % mRatedUsage.GetViewID()).str();
  
  // Last step is to calculate the running totals themselves.
  CalculateRunningTotal(counterRatedUsage, 
                        counterCountable, 
                        mOutputPort);

}

AggregateRatingScript::~AggregateRatingScript()
{
}

std::wstring AggregateRatingScript::GetOutputPort()
{
  return mOutputPort;
}


