/**************************************************************************
 * @doc MTDISCOUNTADAPTER
 *
 * Copyright 1998 - 2002 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: 
 *
 * $Date: 9/11/2002 9:34:17 AM$
 * $Author: Travis Gebhardt$
 * $Revision: 23$
 ***************************************************************************/

#include <metra.h>
#include <mtglobal_msg.h>
#include <formatdbvalue.h>
#include <MTDiscountAdapter.h>
#include <MSIX.h>
#include <MSIXDefinition.h>
#include <MSIXProperties.h>
#include <ProductViewCollection.h>

#include <vector>
#include <string>
#include <set>
#include <map>
#include <fstream>
#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/thread/thread.hpp>
#include <boost/bind.hpp>
#include <boost/function.hpp>
#include <PlanInterpreter.h>
#include <AggregateExpression.h>

#import <MTNameIDLib.tlb>

//
// A countable that contributes to an aggregate expression.  Contains the set of
// referenced properties.
//
class UsageCountable
{
private:
  std::wstring mTableName;
  std::wstring mAdjustmentTableName;
  int mViewID;
  int mIndex;
  std::set<std::pair<std::wstring, std::wstring> > mReferencedColumns;
  std::set<std::wstring> mReferencedColumnsNaked;
public:
  UsageCountable(const std::wstring& tableName, int viewID, int index)
    :
    mTableName(tableName),
    mViewID(viewID),
    mIndex(index)
  {
  }

  void AddReference(MTCOUNTERLib::IMTCounterParameterPtr param)
  {
    std::wstring column((const wchar_t *) param->ColumnName);

    if (0 != wcsicmp(L"amount", column.c_str()) &&
        mReferencedColumnsNaked.find(column) == mReferencedColumnsNaked.end())
    {
      long chargeID = param->ChargeID;
      mReferencedColumnsNaked.insert(column);
      mReferencedColumns.insert(std::make_pair(column, chargeID > 0 ? L"c_aj_" + column.substr(2) : L""));
      if (chargeID > 0)
      {
        // The counter actually doesn't know how to calculate the adjustment table name,
        // it just has a variable that others can use to store it.  Blech!
        mAdjustmentTableName = L"t_aj_" + mTableName.substr(5);
//         mAdjustmentTableName = param->AdjustmentTable;
        ASSERT(mAdjustmentTableName.size() > 0);
      }
    }
  }

  const std::set<std::pair<std::wstring, std::wstring> >& GetReferencedColumns() const
  {
    return mReferencedColumns;
  }

  const std::wstring& GetTableName() const
  {
    return mTableName;
  }

  const std::wstring& GetAdjustmentTableName() const
  {
    return mAdjustmentTableName;
  }

  bool HasAdjustedColumn() const
  {
    return mAdjustmentTableName.size() > 0;
  }

  int GetIndex() const
  {
    return mIndex;
  }

  int GetViewID() const
  {
    return mViewID;
  }
};

//
// A collection of aggregate expressions that may be calculated together.
//
class UsageCounters
{
private:
  std::wstring mInitializeProgram;
  std::map<boost::shared_ptr<UsageCountable>, std::wstring> mUpdateProgram;
  std::set<std::wstring> mCounters;
  std::wstring mDistributionCounter;
public:
  void AddOutput(const std::wstring& output)
  {
    mCounters.insert(output);
  }
  const std::set<std::wstring>& GetOutputs() const
  {
    return mCounters;
  }

  void SetInitializeProgram(const std::string& initializeProgram)
  {
    ::ASCIIToWide(mInitializeProgram, initializeProgram);
  }
  const std::wstring& GetInitializeProgram() const
  {
    return mInitializeProgram;
  }
  void AddUpdateProgram(boost::shared_ptr<UsageCountable> countable, const std::wstring& updateProgram)
  {
    mUpdateProgram[countable] = updateProgram;
  }

  const std::map<boost::shared_ptr<UsageCountable>, std::wstring>& GetCountables() const
  {
    return mUpdateProgram;
  }

  void SetDistributionCounter(const std::wstring& distributionCounter)
  {
    mDistributionCounter = distributionCounter;
  }

  std::wstring GetDistributionCounter() const
  {
    return mDistributionCounter;
  }
};

struct discount_less
{
  bool operator()(MTPRODUCTCATALOGLib::IMTDiscountPtr lhs, MTPRODUCTCATALOGLib::IMTDiscountPtr rhs) const 
  {
    return lhs.GetInterfacePtr() < rhs.GetInterfacePtr();
  }
};

struct pi_less
{
  bool operator()(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr lhs, MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr rhs) const
  {
    return lhs.GetInterfacePtr() < rhs.GetInterfacePtr();
  }
};

class CounterBuilder
{
public:
  typedef std::map<MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr, std::vector<MTPRODUCTCATALOGLib::IMTDiscountPtr>, pi_less> pi_types;
  typedef std::map<MTPRODUCTCATALOGLib::IMTDiscountPtr, boost::shared_ptr<UsageCounters>, discount_less> counters;
private:
  std::map<std::wstring, boost::shared_ptr<UsageCountable> > mCountables;
  counters mCounters;
  pi_types mPiTypes;
  NTLogger& mLogger;
  long mUsageIntervalID;
  bool mIsDiscount;
  bool mAllBcr;
  bool mRunParallel;

  CProductViewCollection mProductViews;
public:
  CounterBuilder(NTLogger & logger, long usageIntervalID, bool allBcr, bool runParallel, bool isDiscount=true);
  ~CounterBuilder();
  void Visit(MTPRODUCTCATALOGLib::IMTDiscountPtr piTemplate, MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType);

  std::wstring ReadUsage();
  std::wstring RouteUsage();
  std::wstring MeterUsage(const std::vector<unsigned char>& collectionID, long sessionSetSize);
};

CounterBuilder::CounterBuilder(NTLogger & logger, long usageIntervalID, bool allBcr, bool runParallel, bool isDiscount)
  :
  mLogger(logger),
  mUsageIntervalID(usageIntervalID),
  mIsDiscount(isDiscount),
  mAllBcr(allBcr),
  mRunParallel(runParallel)
{
  mProductViews.Initialize();
}

CounterBuilder::~CounterBuilder()
{
}

void CounterBuilder::Visit(MTPRODUCTCATALOGLib::IMTDiscountPtr piTemplate, 
                           MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType)
{
  // Track the pi types and templates since we meter to the type (more precisely its service def).
  if (mPiTypes.find(piType) == mPiTypes.end())
    mPiTypes[piType] = std::vector<MTPRODUCTCATALOGLib::IMTDiscountPtr>();

  mPiTypes[piType].push_back(piTemplate);

  //gets this aggregate charge's cpd collection
  MTPRODUCTCATALOGLib::IMTCollectionPtr cpdColl = piType->GetCounterPropertyDefinitions();
  //create a usage counter per discount template
  boost::shared_ptr<UsageCounters> counters = boost::shared_ptr<UsageCounters>(new UsageCounters());
  mCounters[piTemplate] = counters;
  // local tracking of countables referenced by this template
  std::set<boost::shared_ptr<UsageCountable> > referencedCountables;
  // lookup
  MTNAMEIDLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

  // For our incremental calculation we want to look at the counter set a bit 
  // differently from the old way.  The old ways is to say "given a counter, show
  // me the product view properies that contribute to it".  We want to say: "for a given
  // product view record (countable) give me the counters it contributes to and the expressions/program
  // by which to update those counters".
  // This is because we take the approach of our data flow framework which calculates counters
  // by feeding each countable product view into a shared aggregate operator:
  // 
  //                  ------------------------
  //  ratedUsage ---> |                      | ---> ratedUsageWithCounters
  //                  |                      |
  //  countable1 ---> |    Running Total     |
  //      .           |                      |
  //      .           |      Operator        |
  //      .           |                      |
  //  countableN ---> |                      |
  //                  ------------------------
  //
  // This operator reads each input stream (in timestamp order) and for countables it 
  // increments the value of the counters to which that particular stream contribute.  Got it?
  //
  // So we have to reorganize the counter configuration so that we group the underlying expressions
  // by contributing product view.
  // To do this we associate to each product view the counters to which it contributes and the
  // parameter to product view property bindings for that counter.
  std::vector<AggregateExpressionSpec> exprs;

  //iterates through the template's CPD collection 
  long nCPDCount =  cpdColl->Count;
  mLogger.LogVarArgs(LOG_DEBUG, "CPD count = %d", nCPDCount);
  long countableIndex = 0;
  for (int counterIndex = 1; counterIndex <= nCPDCount; counterIndex++) {
    MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdColl->GetItem(counterIndex);
    MTPRODUCTCATALOGLib::IMTCounterPtr counter = piTemplate->GetCounter(cpd->GetID());

    if(counter == NULL) {
      mLogger.LogVarArgs(LOG_ERROR, "CPD with ID %d does not have a counter associated with it!", cpd->GetID());
      throw _com_error(E_FAIL);
    }

    // Extract the counter formula and counter output property.  Save the counter
    // output property.  Parse.
    std::wstring formula = (const wchar_t *) counter->GetFormula(MTPRODUCTCATALOGLib::VIEW_NORMAL);
    // GAACK.  Turns out discounts and aggregate write service def properties differently (so
    // much for sharing code).
    std::wstring counterOutput = mIsDiscount ? L"" : L"c_";
    counterOutput += (const wchar_t*) cpd->ServiceDefProperty;
    counters->AddOutput(counterOutput);
    std::string utf8Formula;
    std::string utf8CounterOutput;
    ::WideStringToUTF8(formula, utf8Formula);
    ::WideStringToUTF8(counterOutput, utf8CounterOutput);
    exprs.push_back(AggregateExpressionSpec());
    exprs.back().Output = utf8CounterOutput;
    exprs.back().Expression = utf8Formula;

    if (mIsDiscount && piTemplate->GetDistributionCPDID() == cpd->GetID())
    {
      // More discount specific stuff.  We have to track if this is the distribution
      // counter.  If so, in the shared group subscription case we have to set the c_DistributionCounter
      // to the value of this guy.
      counters->SetDistributionCounter(counterOutput);
    }

    //gets the counter's parameter collection
    MTPRODUCTCATALOGLib::IMTCollectionPtr paramColl = counter->Parameters;
    long nParamCount = paramColl->Count;

    //
    // iterates through param collection for the current counter
    //
    for (int paramIndex = 1; paramIndex <= nParamCount; paramIndex++) 
    {
      MTCOUNTERLib::IMTCounterParameterPtr param = paramColl->GetItem(paramIndex);

      //if a parameter is just a constant, then don't do anything
      if (param->GetKind() == PARAM_CONST)
        continue;
				
      // Keep track of referenced product views, both across all templates and for this template alone.
      std::map<std::wstring, boost::shared_ptr<UsageCountable> >::const_iterator it = mCountables.find((const wchar_t *) param->ProductViewTable);
        
      if (it == mCountables.end())
      {
        boost::shared_ptr<UsageCountable> tmp =  boost::shared_ptr<UsageCountable>(new UsageCountable((const wchar_t *) param->ProductViewTable,
                                                                                                      nameid->GetNameID(param->ProductViewName),
                                                                                                      mCountables.size()));
        mCountables[(const wchar_t *) param->ProductViewTable] = tmp;
        referencedCountables.insert(tmp);
      }
      else
      {
        referencedCountables.insert(it->second);
      }

      //if the product view has not yet been added, then lookup info and add it
      std::string tableName = (const char *) param->ProductViewTable;
      if (exprs.back().Binding.find(tableName) == exprs.back().Binding.end()) 
      {
        exprs.back().Binding[tableName] = std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >();
      }

      std::string paramMarker = "%%";
      paramMarker += (const char *)param->Name;
      paramMarker += "%%";

      if (param->GetKind() == PARAM_PRODUCT_VIEW_PROPERTY)
      {
        CMSIXDefinition * pvDef;
        if (FALSE==mProductViews.FindProductView((const wchar_t *) param->ProductViewName, pvDef))
        {
          throw std::exception("Couldn't find product view for counter");
        }
        CMSIXProperties * pvPropDef;
        // If we don't find the property name then it belongs to t_acc_usage
        // and therefore must be decimal.
        MTPipelineLib::PropValType ty = MTPipelineLib::PROP_TYPE_DECIMAL;
        if(TRUE==pvDef->FindProperty((const wchar_t *) param->PropertyName, pvPropDef))
        {
          switch(pvPropDef->GetPropertyType())
          {
          case CMSIXProperties::TYPE_INT32:
            ty = MTPipelineLib::PROP_TYPE_INTEGER;
            break;
          case CMSIXProperties::TYPE_FLOAT:
          case CMSIXProperties::TYPE_DOUBLE:
          case CMSIXProperties::TYPE_NUMERIC:
          case CMSIXProperties::TYPE_DECIMAL:
            ty = MTPipelineLib::PROP_TYPE_DECIMAL;
            break;
          case CMSIXProperties::TYPE_INT64:
            ty = MTPipelineLib::PROP_TYPE_BIGINTEGER;
            break;
          case CMSIXProperties::TYPE_TIME:
          case CMSIXProperties::TYPE_ENUM:
          case CMSIXProperties::TYPE_BOOLEAN:
          case CMSIXProperties::TYPE_TIMESTAMP:
          case CMSIXProperties::TYPE_STRING:
          case CMSIXProperties::TYPE_WIDESTRING:
            throw std::exception("Product view property must be of numeric type to be used as a counter parameter");
          }
        }
        exprs.back().Binding[tableName][paramMarker] = std::make_pair((const char *) param->ColumnName,ty);
        mCountables[(const wchar_t *) param->ProductViewTable]->AddReference(param);
      }
      else
      {
        ASSERT(param->GetKind() == PARAM_PRODUCT_VIEW);
        exprs.back().Binding[tableName][paramMarker] = std::make_pair("*",MTPipelineLib::PROP_TYPE_INTEGER);          
      }
    }
  }

  // Generate the incremental program
  IncrementalAggregateExpression incrementalExpr(exprs);

  // Output the initialize program.
  counters->SetInitializeProgram(incrementalExpr.initialize());

  mLogger.LogThis(LOG_DEBUG,
                  (boost::wformat(L"Counter Initializer Program for Priceable Item Type '%1%': \n %2%") 
                   % (const wchar_t *)piType->Name % counters->GetInitializeProgram()).str().c_str());

  // All counters processed.  Put everything into our countable specs.
  for(std::set<boost::shared_ptr<UsageCountable> >::iterator it = referencedCountables.begin();
      it != referencedCountables.end();
      it++)
  {
    std::string utf8TableName;
    ::WideStringToUTF8((*it)->GetTableName(), utf8TableName);
    std::wstring wstrUpdateProgram;
    ::ASCIIToWide(wstrUpdateProgram, incrementalExpr.update(utf8TableName));
    mLogger.LogVarArgs(LOG_DEBUG,
                       (boost::wformat(L"Counter Update Program for Priceable Item Type='%1%', "
                                       L"Countable Product View='%2%', ViewID = %3%: \n %4%")
                        % (const wchar_t *)piType->Name % (*it)->GetTableName() % 
                        (*it)->GetViewID() % wstrUpdateProgram).str().c_str());
    counters->AddUpdateProgram(*it, wstrUpdateProgram);
  }
}

std::wstring CounterBuilder::ReadUsage()
{
  std::wstring program;

  boost::wformat usageFmt (
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Read Usage, apply approved prebill adjustments then branch on viewid\n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"u:select[baseQuery=\"\n"
    L"SELECT\n" 
    L"id_sess,\n" 
    L"id_usage_interval,\n" 
    L"id_payee,\n" 
    L"id_view,\n"
    L"dt_session, \n"
    L"amount from\n"
    L"t_acc_usage\n"
    L"WHERE id_view in (%1%) \n"
    L"%3%"
    L"%4%"
    L"%5%\"];\n"
    L"-- Prebill Adjustments \n"
    L"a:select[baseQuery=\"\n"
    L"select \n"
    L"t_acc_usage.id_sess as adj_id_sess, \n"
    L"t_acc_usage.id_parent_sess as adj_id_parent_sess, \n"
    L"AdjustmentAmount as adj_prebill_amt \n"
    L"from \n"
    L"t_adjustment_transaction\n"
    L"inner join t_acc_usage on t_adjustment_transaction.id_sess=t_acc_usage.id_sess \n"
    L"where \n"
    L"c_Status='A' \n"
    L"AND n_adjustmenttype=0 \n"
    L"AND {fn mod(t_adjustment_transaction.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"-- Create two copies of child adjustments \n"
    L"-- One will aggregate up to the parent one bill aggregate at the child\n"
    L"ae1:expr[program=\"\n"
    L"CREATE PROCEDURE ae1 @adj_id_parent_sess BIGINT @adj_num_copies INTEGER OUTPUT\n"
    L"AS\n"
    L"SET @adj_num_copies = CASE WHEN @adj_id_parent_sess IS NULL THEN 1 ELSE 2 END\"];\n"
    L"unrollAdj:unroll[count=\"adj_num_copies\"];\n"
    L"-- Aggregate adjustments at child and parent levels \n"
    L"ae2:expr[program=\"\n"
    L"CREATE PROCEDURE ae2 @adj_num_copies INTEGER @adj_id_sess BIGINT @adj_id_parent_sess BIGINT @adj_total_id_sess BIGINT OUTPUT\n"
    L"AS\n"
    L"SET @adj_total_id_sess = CASE WHEN @adj_num_copies = 0 THEN @adj_id_sess ELSE @adj_id_parent_sess END\"];\n"
    L"ag:hash_group_by[key=\"adj_total_id_sess\",\n"
    L"initialize=\"\n"
    L"CREATE PROCEDURE i @adj_total_prebill_amt DECIMAL\n"
    L"AS\n"
    L"SET @adj_total_prebill_amt = 0.0\",\n"
    L"update=\"\n"
    L"CREATE PROCEDURE u @adj_total_prebill_amt DECIMAL @adj_prebill_amt DECIMAL\n"
    L"AS\n"
    L"SET @adj_total_prebill_amt = @adj_total_prebill_amt + @adj_prebill_amt\"];\n"
    L"adjPart:hash_part[key=\"adj_total_id_sess\"];\n"
    L"adjColl:coll[];\n"
    L"adjJoin:right_outer_hash_join[tableKey=\"adj_total_id_sess\", probeKey=\"id_sess\"];\n"
    L"adjApply:expr[program=\"\n"
    L"CREATE PROCEDURE adjApply @adj_total_prebill_amt DECIMAL @amount DECIMAL\n"
    L"AS\n"
    L"SET @amount = @amount + CASE WHEN @adj_total_prebill_amt IS NULL THEN 0.0 ELSE @adj_total_prebill_amt END\"];\n"
    L"%2%"
    L"u -> adjJoin(\"probe(0)\");\n"
    L"a -> ae1 -> unrollAdj -> ae2 -> adjPart -> adjColl -> ag -> adjJoin(\"table\");\n"
    L"adjJoin -> adjApply -> us;\n"
    );

  boost::wformat intervalPredicateFmt(L"AND %1%.id_usage_interval=%2%\n");

  boost::wformat usageSwitchFmt (
    L"us:switch[program=\"\n"
    L"CREATE FUNCTION us (@id_view INTEGER) RETURNS INTEGER\n"
    L"AS\n"
    L"RETURN CASE\n%1%ELSE -1 END\"];\n");

  boost::wformat usageSwitchClauseFmt (
    L"WHEN @id_view = %1% THEN %2%\n");
  
  boost::wformat pvFmt (
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Read Product View with ID = %1%\n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"pv%1%:select[baseQuery=\"\n"
    L"SELECT\n" 
    L"id_sess AS pv_id_sess%2%\n"
    L"FROM %3%\n"
    L"WHERE 1=1\n"
    L"%5%"
    L"%4%"
    L"ORDER BY id_sess ASC\"];\n");

  boost::wformat pvAdjFmt(
    L"adj%1%:select[baseQuery=\"\n"
    L"SELECT\n"
    L"id_sess AS adj_id_sess%2%\n"
    L"FROM t_adjustment_transaction \n"
    L"INNER JOIN %3% adj ON t_adjustment_transaction.id_adj_trx=adj.id_adjustment\n"
    L"WHERE \n"
    L"c_Status='A'\n" 
    L"AND n_adjustmenttype=0 \n"
    L"AND {fn mod(t_adjustment_transaction.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n");
  boost::wformat bcrPvAdjFmt(
    L"adj%1%:select[baseQuery=\"\n"
    L"SELECT\n"
    L"id_sess AS adj_id_sess%2%\n"
    L"FROM t_adjustment_transaction \n"
    L"INNER JOIN %3% ON t_adjustment_transaction.id_adj_trx=adj.id_adjustment\n"
    L"WHERE \n"
    L"c_Status='A'\n" 
    L"AND n_adjustmenttype=0 \n"
    L"AND {fn mod(t_adjustment_transaction.id_sess, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%"
    L"AND t_adjustment_transaction.id_usage_interval=%4%\"];\n");
  
  boost::wformat usagePvJoinFmt (
    L"upvJoin%1%:inner_merge_join[leftKey=\"id_sess\", rightKey=\"pv_id_sess\"];\n");
  boost::wformat usageSwitchJoinArrowFmt (
    L"us(%1%) -> upvJoin%2%(\"left\");\n");
  boost::wformat pvJoinArrowFmt (
    L"pv%1% -> upvJoin%1%(\"right\");\n");

  // Join of optional adjustment table to usage
  boost::wformat pvAdjJoinFmt(
    L"pvAdjJoin%1%:right_outer_hash_join[tableKey=\"adj_id_sess\", probeKey=\"pv_id_sess\"];\n"
    L"applyAdjustment%1%:expr[program=\"CREATE PROCEDURE applyAdjustment %2%"
    L"AS\n%3%\"];\n");
  boost::wformat pvAdjJoinArrowFmt(
    L"upvJoin%1% -> pvAdjJoin%1%(\"probe(0)\");\n"
    L"adj%1% -> pvAdjJoin%1%(\"table\");\n"
    L"pvAdjJoin%1% -> applyAdjustment%1%;\n");

  // Final repartitioning and naming stuff (can we assume that 1-1 copies are removed at runtime)
  boost::wformat pvJoinRenameFmt(
    L"usagePayeePart%1%:hash_part[key=\"id_payee\"];\n"
    L"usagePayeeColl%1%:coll[];\n"
    L"usage%1%:copy[];\n"
    L"%2%%1% -> usagePayeePart%1% -> usagePayeeColl%1% -> usage%1%;\n");
  boost::wformat switchRenameFmt(
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- No Product View properties with ID = %1% are referenced \n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"usagePayeePart%1%:hash_part[key=\"id_payee\"];\n"
    L"usagePayeeColl%1%:coll[];\n"
    L"usage%1%:copy[];\n"
    L"us(%2%) -> usagePayeePart%1% -> usagePayeeColl%1% -> usage%1%;\n");
  
  // Keep track of whether we are referencing any PV properties.
  bool joinPvs(false);
 
  std::wstring id_view_list;
  std::wstring switchClauses;
  std::wstring pvUsageJoinArrows; 

  // Nothing to be done if no countables
  if (mCountables.size() == 0) return L"";

  for(std::map<std::wstring, boost::shared_ptr<UsageCountable> >::const_iterator it =  mCountables.begin();
      it != mCountables.end();
      ++it)
  {
    // Build id_view list
    if (id_view_list.size() > 0)
      id_view_list += L", ";
    id_view_list += boost::lexical_cast<std::wstring>(it->second->GetViewID());

    // Build the switch clauses.
    switchClauses += (usageSwitchClauseFmt % it->second->GetViewID() % it->second->GetIndex()).str();

    if(it->second->GetReferencedColumns().size() > 0)
    {
      // Remember that we are referencing at least 1 pv.  We need to 
      // ORDER BY t_acc_usage in this case.
      joinPvs = true;

      // Select list for reading the product view table
      std::wstring referencedColumnsList;
      boost::wformat referencedColumnsListFmt(L"\n, %1%");
      // Select list for reading the adjustment table
      std::wstring referencedChargesList;
      boost::wformat referencedChargesListFmt(L"\n, %1%");
      // Adjustment application procedure decl
      std::wstring adjustmentApplicationDecl;
      boost::wformat adjustmentApplicationDeclFmt(L" @%1% DECIMAL @%2% DECIMAL\n");
      // Adjustment application procedure body
      std::wstring adjustmentApplicationBody;
      boost::wformat adjustmentApplicationBodyFmt(L"SET @%1% = CASE WHEN @%1% IS NULL THEN 0.0 ELSE @%1% END + "
                                                  L"CASE WHEN @%2% IS NULL THEN 0.0 ELSE @%2% END\n");

      // If countable has referenced columns we must read them
      // from pv table (and adjust if they are charges).
      for(std::set<std::pair<std::wstring, std::wstring> >::const_iterator sit=it->second->GetReferencedColumns().begin();
          sit != it->second->GetReferencedColumns().end();
          ++sit)
      {
        referencedColumnsList += (referencedColumnsListFmt % sit->first).str();
        if (sit->second.size() > 0)
        {
          referencedChargesList += (referencedChargesListFmt % sit->second).str();
          adjustmentApplicationDecl += (adjustmentApplicationDeclFmt % sit->first % sit->second).str();
          adjustmentApplicationBody += (adjustmentApplicationBodyFmt % sit->first % sit->second).str();
        }
      }

      // Apply all BCR optimization
      std::wstring intervalPredicate;
      if (mAllBcr)
      {
        intervalPredicate = (intervalPredicateFmt % it->first % mUsageIntervalID).str();
      }
      // Omit partitioning predicate if running sequentially to avoid optimizer stupidity.
      std::wstring pvPartitioningPredicate(mRunParallel ?
                                           L"AND {fn mod(id_sess,%%NUMPARTITIONS%%)} = %%PARTITION%%\n" :
                                           L"");
      // Output the pv reading code.
      program += (pvFmt % it->second->GetViewID() % referencedColumnsList % it->first % intervalPredicate % pvPartitioningPredicate).str(); 

      if (referencedChargesList.size() > 0)
      {
        if (mAllBcr)
        {
          program += (bcrPvAdjFmt % it->second->GetViewID() % referencedChargesList % it->second->GetAdjustmentTableName() % mUsageIntervalID).str();
        }
        else
        {
          program += (pvAdjFmt % it->second->GetViewID() % referencedChargesList % it->second->GetAdjustmentTableName()).str();
        }
      }

      // Create the join between the pv and t_acc_usage and rename
      program += (usagePvJoinFmt % it->second->GetViewID()).str();
      program += (usageSwitchJoinArrowFmt % it->second->GetIndex() % it->second->GetViewID()).str();
      program += (pvJoinArrowFmt % it->second->GetViewID()).str();
      if (referencedChargesList.size() > 0)
      {
        program += (pvAdjJoinFmt % it->second->GetViewID() % adjustmentApplicationDecl % adjustmentApplicationBody).str();
        program += (pvAdjJoinArrowFmt % it->second->GetViewID()).str();
        program += (pvJoinRenameFmt % it->second->GetViewID() % L"applyAdjustment").str();
      }
      else
      {
        program += (pvJoinRenameFmt % it->second->GetViewID() % L"upvJoin").str();
      }
    }
    else
    {
      program += (switchRenameFmt % it->second->GetViewID() % it->second->GetIndex()).str();
    }
  }

  std::wstring usageIntervalPredicate;
  if (mAllBcr)
  {
    usageIntervalPredicate = (intervalPredicateFmt % L"t_acc_usage" % mUsageIntervalID).str();
  }
  // Omit partitioning predicate if running sequentially to avoid optimizer stupidity.
  std::wstring usagePartitioningPredicate(mRunParallel ? 
                                          L"AND {fn mod(id_sess,%%NUMPARTITIONS%%)} = %%PARTITION%%\n" : 
                                          L"");
  // Omit ORDER BY if not joining with any prodocut view
  std::wstring usageOrderBy(joinPvs ? L"ORDER BY id_sess ASC" : L"");
  program = (usageFmt % id_view_list % (usageSwitchFmt % switchClauses).str() % usageIntervalPredicate % usagePartitioningPredicate % usageOrderBy).str() + program;
  program += pvUsageJoinArrows;

  return program;
}

std::wstring CounterBuilder::RouteUsage()
{
  /* Discount subscription/interval info */
  std::wstring program;

  boost::wformat discountReadAndSwitchFmt (
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Read the discount subscription contributions temporary table, split in \n"
    L"-- on template. \n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"contributionsRaw:select[baseQuery=\"select * from tmp_all_disc_contrib WHERE {fn mod(sub_id_acc, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"contributionsPart:hashpart[key=\"sub_id_acc\"];\n"
    L"contributionsColl:coll[];\n"
    L"contributions:switch[program=\"\n"
    L"CREATE FUNCTION ds (@plm_id_pi_template INTEGER) RETURNS INTEGER\n"
    L"AS\n"
    L"RETURN CASE\n%1%ELSE -1 END\"];\n"
    L"contributionsRaw -> contributionsPart -> contributionsColl -> contributions;\n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Read the discount descriptor temporary table, split in \n"
    L"-- on template. \n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"discountsRaw:select[baseQuery=\"select * from tmp_all_disc_desc WHERE {fn mod(c_AggregationID, %%%%NUMPARTITIONS%%%%)} = %%%%PARTITION%%%%\"];\n"
    L"discountsPart:hashpart[key=\"c_AggregationID\", key=\"c_DiscountIntervalID\"];\n"
    L"discountsColl:coll[];\n"
    L"discounts:switch[program=\"\n"
    L"CREATE FUNCTION ds (@c__PriceableItemTemplateID INTEGER) RETURNS INTEGER\n"
    L"AS\n"
    L"RETURN CASE\n%2%ELSE -1 END\"];\n"
    L"discountsRaw -> discountsPart -> discountsColl -> discounts;\n"
    );

  std::wstring discountReadAndSwitchClause;
  boost::wformat discountReadAndSwitchClauseFmt (
    L"WHEN @plm_id_pi_template = %1% THEN %2%\n");
  std::wstring discountDescriptorReadAndSwitchClause;
  boost::wformat discountDescriptorReadAndSwitchClauseFmt (
    L"WHEN @c__PriceableItemTemplateID = %1% THEN %2%\n");


  // TODO: Should probably replace all references to pci_vt_start/pci_vt_end
  // with sub_pci_vt_start and sub_pci_vt_end (intersection of subscription and
  // discount intervals).  
  boost::wformat joinUsageDiscountFmt (
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Join usage for each countable product view to the discount for templateID=%1%.\n"
    L"-- Usage is always required to have occured during the subscription/subscription membership interval.\n"
    L"-- In BCR case, we require we're on the interval being processed, non-BCR requires inside a date range.\n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"\n"
    
    L"-----------------------------------------------------------\n"
    L"-- Join each countable PV stream to subscription.  Do this with a single join operator. \n"
    L"-----------------------------------------------------------\n"
    L"guideUsageToDiscount%1%:inner_hash_join[\n"
    L"tableKey=\"sub_id_acc\", \n"
    L"probeKey=\"id_payee\",\n"
    L"residual=\"CREATE FUNCTION r (@dt_session DATETIME, @id_usage_interval INTEGER, @sub_vt_start DATETIME, @sub_vt_end DATETIME, @plm_id_usage_cycle INTEGER, @pci_vt_start DATETIME, @pci_vt_end DATETIME)\n"
    L"RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @dt_session >= @sub_vt_start AND @dt_session <= @sub_vt_end AND \n"
    L"((@plm_id_usage_cycle IS NULL AND @id_usage_interval=%2%) OR ((NOT @plm_id_usage_cycle IS NULL) AND @dt_session >= @pci_vt_start AND @dt_session <= @pci_vt_end))\"];\n"
    L"contributions(%3%) -> guideUsageToDiscount%1%(\"table\");\n"
    );

  boost::wformat usageDiscountJoinArrowFmt(
    L"usage%1%(%2%) -> guideUsageToDiscount%3%(\"probe(%4%)\");\n");

  boost::wformat groupByFmt(
    L"sPart%1%_%2%:hashpart[key=\"sub_id_aggregation\", key=\"pci_id_usage_interval\"];\n"
    L"sColl%1%_%2%:coll[];\n"
    L"copyUsage%1%_%2%:copy[];\n"
    L"guideUsageToDiscount%1%(\"output(%3%)\") -> sPart%1%_%2% -> sColl%1%_%2% -> copyUsage%1%_%2%;\n");

  // Group by has one update per contributing countable PV.
  // A single initialize sets up the counters.
  boost::wformat groupByOperatorFmt (
    L"-----------------------------------------------------------\n"
    L"-- Aggregate counters for discount itself.  Again if multiple PV streams use a single operator. \n"
    L"-----------------------------------------------------------\n"
    L"agg%1%:hash_group_by[\n"
    L"key=\"sub_id_aggregation\",\n"
    L"key=\"pci_id_usage_interval\",\n"
    L"key=\"sub_id_sub\",\n"
    L"key=\"plm_id_pi_instance\",\n"
    L"initialize=\"\n%2%\"%3%];\n"
    L"%4%"
    L"-----------------------------------------------------------\n"
    L"-- Aggregate counters at the group sub member for proportional distribution \n"
    L"-----------------------------------------------------------\n"
    L"contributorAgg%1%:hash_group_by[\n"
    L"key=\"sub_id_aggregation\",\n"
    L"key=\"pci_id_usage_interval\",\n"
    L"key=\"sub_id_acc\",\n"
    L"key=\"gs_id_group\",\n"
    L"key=\"plm_id_pi_instance\",\n"
    L"initialize=\"\n"
    L"%2%\"%3%];\n"
    L"%5%"
    L"-----------------------------------------------------------\n"
    L"-- Join the counters with discount descriptors \n"
    L"-----------------------------------------------------------\n"
    L"tmpTablePostAggJoin%1%:inner_hash_join[\n"
    L"probeKey=\"sub_id_aggregation\",\n"
    L"probeKey=\"pci_id_usage_interval\",\n"
    L"probeKey=\"sub_id_sub\",\n"
    L"probeKey=\"plm_id_pi_instance\",\n"
    L"tableKey=\"c_AggregationID\",\n"
    L"tableKey=\"c_DiscountIntervalID\",\n"
    L"tableKey=\"c__SubscriptionID\",\n"
    L"tableKey=\"c__PriceableItemInstanceID\"];\n");

  boost::wformat groupByUpdateFmt (
    L",\n"
    L"update=\"\n"
    L"%1%\"");

  // To handle the shared proportional case we want to calculate group by
  // not only at the level of the subscription (as is required for pass 1 metering)
  // but also the counters for each contributor as these are need to derive the
  // proportions.  This is the code to do that.
  boost::wformat contributorGroupByFmt(
    L"proportionalFilter%1%_%2%:filter[\n"
    L"program=\"\n"
    L"CREATE FUNCTION f (@gs_b_supportgroupops VARCHAR @gs_b_proportional VARCHAR) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN (NOT @gs_b_supportgroupops IS NULL) AND @gs_b_supportgroupops='Y' AND @gs_b_proportional='Y'\"];\n"
    L"copyUsage%1%_%2%(1) -> proportionalFilter%1%_%2% -> contributorAgg%1%(%3%);\n"
    );

  // Having calculated contributor counters for the proportional
  // case, identify the distribution counter and project for
  // insert to database.
  boost::wformat contributorProjectDistributionCounterFmt(
    L"contributorRenameDistributionCounter%1%:rename[\n"
    L"from=\"%2%\", to=\"c_DistributionCounter\"];\n"
    L"contributorProj%1%:proj[\n"
    L"column=\"sub_id_aggregation\",\n"
    L"column=\"pci_id_usage_interval\",\n"
    L"column=\"sub_id_acc\",\n"
    L"column=\"gs_id_group\",\n"
    L"column=\"plm_id_pi_instance\",\n"
    L"column=\"c_DistributionCounter\"];\n");
  // For cases in which there is no configured distribution counter
  // just create one and set it to NULL.  This makes streams all share
  // the same format.
  boost::wformat contributorProjectFakeDistributionCounterFmt(
    L"contributorRenameDistributionCounter%1%:expr[program=\"\n"
    L"CREATE PROCEDURE fakeDistributionCounter @c_DistributionCounter DECIMAL OUTPUT\n"
    L"AS\n"
    L"SET @c_DistributionCounter = NULL\"];\n"
    L"contributorProj%1%:proj[\n"
    L"column=\"sub_id_aggregation\",\n"
    L"column=\"pci_id_usage_interval\",\n"
    L"column=\"sub_id_acc\",\n"
    L"column=\"gs_id_group\",\n"
    L"column=\"plm_id_pi_instance\",\n"
    L"column=\"c_DistributionCounter\"];\n");

  boost::wformat groupByArrowFmt(
    L"guideUsageToDiscount%1%(\"output(%2%)\") -> sPart%1%_%3% -> sColl%1%_%3% -> agg%1%(%2%);\n");

  boost::wformat groupByPostJoinArrowFmt(
    L"agg%1% -> tmpTablePostAggJoin%1%(\"probe(0)\");\n");

  boost::wformat groupByAndContributorGroupByArrowFmt(
    L"copyUsage%1%_%3%(0) -> agg%1%(%2%);\n");

  boost::wformat groupByPostJoinAndContributorRenameArrowFmt(
    L"agg%1% -> tmpTablePostAggJoin%1%(\"probe(0)\");\n"
    L"contributorAgg%1% -> contributorRenameDistributionCounter%1% -> contributorProj%1%;\n");

  boost::wformat unqualifiedFakeContributorFmt(
    L"contributorProj%1%:generate[\n"
    L"program=\"\n"
    L"CREATE PROCEDURE g @sub_id_aggregation INTEGER @pci_id_usage_interval INTEGER @sub_id_acc INTEGER @gs_id_group INTEGER @plm_id_pi_instance INTEGER @c_DistributionCounter DECIMAL\n"
    L"AS\n"
    L"SET @sub_id_aggregation=0\n"
    L"SET @pci_id_usage_interval=0\n"
    L"SET @sub_id_acc=0\n"
    L"SET @gs_id_group=0\n"
    L"SET @plm_id_pi_instance=0\n"
    L"SET @c_DistributionCounter=0.0\",\n"
    L"numRecords=0];\n");

  std::wstring switchDiscountJoinArrow;
  boost::wformat switchDiscountJoinArrowFmt(
    L"discounts(%2%) -> tmpTablePostAggJoin%1%(\"table\");\n");

// // These columns are needed for the aggregation
// sub_id_acc, 
// sub_id_aggregation,
// sub_id_sub,
// sub_vt_start,
// sub_vt_end,
// plm_id_usage_cycle,
// plm_id_template,
// pci_id_usage_interval,
// pci_vt_start,
// pci_vt_end

// // These are the aggregation keys
// sub_id_aggregation,
// sub_id_sub,
// pci_id_usage_interval,


// // These columns are needed for metering
//     L"@sub_id_acc INTEGER\n"
//     L"@pay_id_payer INTEGER\n"
//     L"@bill_vt_start DATETIME\n"
//     L"@bill_vt_end DATETIME\n"
//     L"@plm_id_pi_instance INTEGER\n"
//     L"@plm_id_pi_template INTEGER\n"
//     L"@plm_id_po INTEGER\n"
//     L"@pci_vt_start DATETIME\n"
//     L"@pci_vt_end DATETIME\n"
//     L"@sub_vt_start DATETIME\n"
//     L"@sub_vt_end DATETIME\n"
//     L"@sub_pci_vt_start DATETIME\n"
//     L"@sub_pci_vt_end DATETIME\n"

  boost::wformat distributionCounterArgsFmt(
    L" @c_GroupDiscountIsShared INTEGER @%1% DECIMAL");
  boost::wformat distributionCounterExprFmt(
    L"CASE WHEN @c_GroupDiscountIsShared = 1 THEN @%1% ELSE NULL END");
  boost::wformat setDistributionCounterFmt(
    L"setDistributionCounter%1%:expr[\n"
    L"program=\"CREATE PROCEDURE sdc @c_DistributionCounter DECIMAL OUTPUT%2%\n"
    L"AS\n"
    L"SET @c_DistributionCounter = %3%\"];\n");

  boost::wformat counterListFmt(L",column=\"%1%\"\n");
  boost::wformat projListFmt(  
    L"projectForMetering%1%:proj[\n"
    L"column=\"c__AccountID\"\n"
    L",column=\"c__PayingAccount\"\n"
    L",column=\"c_BillingIntervalStart\"\n"
    L",column=\"c_BillingIntervalEnd\"\n"
    L",column=\"c__PriceableItemInstanceID\"\n"
    L",column=\"c__PriceableItemTemplateID\"\n"
    L",column=\"c__ProductOfferingID\"\n"
    L",column=\"c_DiscountIntervalStart\"\n"
    L",column=\"c_DiscountIntervalEnd\"\n"
    L",column=\"c_SubscriptionStart\"\n"
    L",column=\"c_SubscriptionEnd\"\n"
    L",column=\"c_DiscountIntervalSubStart\"\n"
    L",column=\"c_DiscountIntervalSubEnd\"\n"
    L"%2%"
    L",column=\"c_GroupDiscountPass\"\n"
    L",column=\"c_GroupSubscriptionID\"\n"
    L",column=\"c_GroupSubscriptionName\"\n"
    L",column=\"c_GroupDiscountAmount\"\n"
    L",column=\"c_GroupDiscountPercent\"\n"
    L",column=\"c_DistributionCounter\"\n"
    L",column=\"c_GroupDiscountIntervalID\"\n"
    L",column=\"c__IntervalID\"\n"
//     L",c__TransactionCookie\n"
//     L",c__Resubmit\n"
//     L",c__CollectionID"
    L"];\n"
    L"tmpTablePostAggJoin%1% -> setDistributionCounter%1% -> projectForMetering%1%;\n");

  boost::wformat unqualifiedDiscountRenameFmt(
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"-- Template %1% has no counters so route directly to metering.\n"
    L"-----------------------------------------------------------\n"
    L"-----------------------------------------------------------\n"
    L"tmpTablePostAggJoin%1%:copy[];\n"
    L"cdn%1%:devNull[];\n"
    L"contributions(%2%) -> cdn%1%;\n"
    L"discounts(%2%) -> tmpTablePostAggJoin%1%;\n");

  // Keep track of how many references there are to each pv.
  std::map<int, int> mCountableRefCount;


  int i=0;
  for(counters::iterator it=mCounters.begin();
      it != mCounters.end();
      ++it)
  {
    bool hasDistributionCounter(it->second->GetDistributionCounter().size() > 0);

    std::wstring counterList;
    discountReadAndSwitchClause += (discountReadAndSwitchClauseFmt % it->first->ID % i).str();
    discountDescriptorReadAndSwitchClause += (discountDescriptorReadAndSwitchClauseFmt % it->first->ID % i).str();
    for(std::set<std::wstring>::const_iterator counterIt = it->second->GetOutputs().begin();
        counterIt != it->second->GetOutputs().end();
        ++counterIt)
    {
      counterList += (counterListFmt % *counterIt).str();
    }

    if(it->second->GetCountables().size() > 0)
    {
      // Feed countables to join, aggregate and join to metered properties.
      int j=0;
      std::wstring joinUsageDiscountInputArrows;
      std::wstring joinUsageDiscountOutputArrows;
      std::wstring aggregateUpdates;
      std::wstring aggInputArrows;
      std::wstring contributorAggInputArrows;
      for(std::map<boost::shared_ptr<UsageCountable>, std::wstring>::const_iterator cit = it->second->GetCountables().begin();
          cit != it->second->GetCountables().end();
          ++cit)
      {
        aggregateUpdates += (groupByUpdateFmt % cit->second).str();
        // Read and aggregate the countable.
        if(mCountableRefCount.find(cit->first->GetViewID()) == mCountableRefCount.end())
          mCountableRefCount[cit->first->GetViewID()] = 0;
        joinUsageDiscountInputArrows += (usageDiscountJoinArrowFmt % cit->first->GetViewID() % mCountableRefCount[cit->first->GetViewID()] % it->first->ID % j).str();
        mCountableRefCount[cit->first->GetViewID()] += 1;
        joinUsageDiscountOutputArrows += (groupByFmt % it->first->ID % cit->first->GetViewID() % j).str();
        contributorAggInputArrows += (contributorGroupByFmt % it->first->ID % cit->first->GetViewID() % j).str();
        aggInputArrows += (groupByAndContributorGroupByArrowFmt % it->first->ID % j % cit->first->GetViewID()).str();
  
        j++;
      }

      // Operator to join countables to the discounts
      program += (joinUsageDiscountFmt % it->first->ID % mUsageIntervalID % i).str();
      program += joinUsageDiscountInputArrows;
      program += joinUsageDiscountOutputArrows;
      // Operators to compute group by of countables (one for the shared proportional case and one for all others).
      program += (groupByOperatorFmt % it->first->ID % it->second->GetInitializeProgram() % aggregateUpdates % aggInputArrows % contributorAggInputArrows).str();
      // Set up table inputs to joins.
      program += (switchDiscountJoinArrowFmt % it->first->ID % i).str();

      if (hasDistributionCounter)
      {
        program += (contributorProjectDistributionCounterFmt % it->first->ID % it->second->GetDistributionCounter()).str();
      }
      else
      {
        program += (contributorProjectFakeDistributionCounterFmt % it->first->ID).str();
      }
      program += (groupByPostJoinAndContributorRenameArrowFmt % it->first->ID).str();
    }
    else
    {
      // For unqualified discount there can't be a distribution counter so we
      // make a fake empty stream to make things uniform.
      program += (unqualifiedFakeContributorFmt % it->first->ID).str();
      // For unqualified flat discounts (no counters) the discount driver table
      // goes straight to metering.
      program += (unqualifiedDiscountRenameFmt % it->first->ID % i).str();
    }

    // Set distribution counter.  Either NULL or equal to the specified counter
    // in the group sub case.
    if (hasDistributionCounter)
    {
      program += (setDistributionCounterFmt % 
                  it->first->ID % 
                  (distributionCounterArgsFmt % it->second->GetDistributionCounter()).str() %
                  (distributionCounterExprFmt % it->second->GetDistributionCounter()).str()).str();
    }
    else
    {
      program += (setDistributionCounterFmt % 
                  it->first->ID % 
                  L"" %
                  L"NULL").str();
    }

    // Project on to metered properties
    program += (projListFmt % it->first->ID % counterList).str();
    
    i++;
  }
  
  program = (discountReadAndSwitchFmt % discountReadAndSwitchClause % discountDescriptorReadAndSwitchClause).str() + program;

  return program;
}

std::wstring CounterBuilder::MeterUsage(const std::vector<unsigned char>& collectionID, long sessionSetSize)
{
  // For all discounts that support proportional shared group, store the
  // contributions of each account.
  std::wstring proportionalUnionAll(L"contributorUnionAll:union_all[];\n");
  boost::wformat proportionalUnionAllArrowFmt(L"contributorProj%1% -> contributorUnionAll(%2%);\n");
  std::wstring unionAll;
  boost::wformat unionAllFmt(L"u%1%:union_all[];\n");
  boost::wformat aggUnionAllArrowFmt(L"projectForMetering%1% -> u%2%(%3%);\n");
  // write collection id in hex
  std::wstring hexFormat(L"0123456789ABCDEF");
  wchar_t uid[35];
  uid[0] = L'0';
  uid[1] = L'x';
  for(int i=0; i<16; i++)
  {
    uid[2*i + 2] = hexFormat[(collectionID[i] & 0xF0) >> 4];
    uid[2*i + 3] = hexFormat[(collectionID[i] & 0x0F)];
  }
  uid[34] = 0;

  // Index over all templates regardless of pi type.
  int j=0;
  // Metering
  boost::wformat meterFmt(
    L"meter%1%:meter[service=\"%2%\", collectionID=%3%, targetMessageSize=%4%];\n"
    L"u%1% -> meter%1%;\n");

  for(pi_types::iterator it = mPiTypes.begin();
      it != mPiTypes.end();
      ++it)
  {
    unionAll += (unionAllFmt % it->first->ID).str();
    // Take the union of all templates with this type.
    for(size_t i=0; i<it->second.size(); i++)
    {
      unionAll += (aggUnionAllArrowFmt % it->second[i]->ID % it->first->ID % i).str();
      proportionalUnionAll += (proportionalUnionAllArrowFmt % it->second[i]->ID % j).str();
      j += 1;
    }
    // Meter the union to the type's service definition.
    unionAll += (meterFmt % it->first->ID % it->first->ServiceDefinition % uid % sessionSetSize).str();
  }

  proportionalUnionAll += 
    L"contributorInsert:insert[table=\"tmp_grp_disc_contrib\", createTable=true, schema=\"NetMeter\"];\n"
    L"contributorUnionAll->contributorInsert;\n";

  return unionAll + proportionalUnionAll;
}

MTDiscountAdapter::MTDiscountAdapter() : mbUseMaterializedViews(false)
{
	LoggerConfigReader cfgRdr;
	mLogger.Init(cfgRdr.ReadConfiguration("DiscountAdapter"), "[DiscountAdapter]");
  mCtx = NULL;
}

STDMETHODIMP MTDiscountAdapter::Initialize(BSTR aEventName,
																					 BSTR aConfigFile, 
																					 IMTSessionContext* apContext, 
																					 VARIANT_BOOL aLimitedInit)
{
	try 
	{
		mEventName = aEventName;

		// determines the database vendor
		mQueryAdapter.CreateInstance(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
		mQueryAdapter->Init("queries\\ProductCatalog");
		mIsOracle = (mtwcscasecmp(mQueryAdapter->GetDBType(), ORACLE_DATABASE_TYPE) == 0);
    mCtx = apContext;

		// reads in the config file
		_bstr_t configFile(aConfigFile);
		HRESULT hr = ParseConfigFile(configFile);
		if (FAILED(hr)) 
		{
			mLogger.LogThis(LOG_ERROR, "Error occurred while reading configuration file!");
			return hr;
		}
	}
	catch(_com_error & e)
	{
		mLogger.LogThis(LOG_ERROR, "Error occurred while reading configuration file!");
		return ReturnComError(e);
	}

	try
	{
		mMaterializedViewMgr = new MetraTech_DataAccess_MaterializedViews::IManagerPtr(__uuidof(MetraTech_DataAccess_MaterializedViews::Manager));
		ASSERT(mMaterializedViewMgr != NULL);
    mMaterializedViewMgr->Initialize();
		mbUseMaterializedViews = (mMaterializedViewMgr->GetIsMetraViewSupportEnabled() == VARIANT_TRUE);
	}
	catch(_com_error & e)
	{
		return ReturnComError(e);
	}


	
	return S_OK;
}

HRESULT MTDiscountAdapter::ParseConfigFile(_bstr_t & arConfigFile)
{
	mLogger.LogVarArgs(LOG_DEBUG, "Reading configuration file: %s",
										 (char *) arConfigFile);

	VARIANT_BOOL checksumMatch;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	MTConfigLib::IMTConfigPropSetPtr propSet = config->ReadConfiguration(arConfigFile, &checksumMatch);
	if (propSet == NULL)
		return Error("Could not get initial propset!");
	
	// used to support backward compatibility
	_bstr_t configVersion = propSet->NextStringWithName(L"Version");
	
	// the size of the session sets metered to the discount stages
	// NOTE: this element is deprecated, use \Metering\SessionSetSize instead
	long sessionSetSize = 1000;
	if (propSet->NextMatches(L"SessionSetSize", MTConfigLib::PROP_TYPE_STRING))
		long sessionSetSize = propSet->NextLongWithName(L"SessionSetSize");
	
	mProcessSimpleDiscounts = propSet->NextBoolWithName(L"ProcessSimpleDiscounts");
	mProcessGroupDiscounts = propSet->NextBoolWithName(L"ProcessGroupDiscounts");

	if (!mProcessSimpleDiscounts && !mProcessGroupDiscounts)
	{
		return Error("Either <ProcessSimpleDiscounts> or <ProcessGroupDiscounts> must be true!");
	}
	
	// restricts processing of discounts to only one discount
	// with the specified template ID
	if (propSet->NextMatches(L"OnlyProcessTemplateID", MTConfigLib::PROP_TYPE_INTEGER))
	{
		mSingleDiscountMode = TRUE;
		mSingleTemplateID = propSet->NextLongWithName(L"OnlyProcessTemplateID");
	}
	else
		mSingleDiscountMode = FALSE;

	
	// enables debugging of temp tables. this has two effects:
	//   - "temp" tables are never truncated after processing
	//   - for SQL Server, temp tables are made permanent (the # prefix is dropped)
	// NOTE: to inspect temp tables in Oracle, the tables must be manually
	// dropped and re-created as normal tables
	if (propSet->NextMatches(L"DebugTempTables", MTConfigLib::PROP_TYPE_BOOLEAN))
	{
		mDebugTempTables = propSet->NextBoolWithName(L"DebugTempTables");
		if (!mSingleDiscountMode && mDebugTempTables)
			return Error("<DebugTempTables> must be FALSE when <OnlyProcessTemplateID> is not specified!");

		if (mDebugTempTables && mProcessSimpleDiscounts && mProcessGroupDiscounts && !mIsOracle)
			return Error("<ProcessSimpleDiscounts> and <ProcessGroupDiscounts> cannot both be TRUE when "
									 "<DebugTempTables> is TRUE and the database is SQL Server!");
		
		if (mDebugTempTables)
			mLogger.LogThis(LOG_WARNING, "Debugging of temporary tables has been enabled!");
	}
	else
		mDebugTempTables = FALSE;

	//
	// loads standard metering settings
	//
	mMeteringConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MeteringConfig));
	mMeteringConfig->Load(arConfigFile, sessionSetSize, PCCache::GetBatchSubmitTimeout(), false);

	//
	// loads MetraFlow settings
	//
	mMetraFlowConfig.CreateInstance(__uuidof(MetraTech_UsageServer::MetraFlowConfig));
	mMetraFlowConfig->Load(arConfigFile);

	return S_OK;
}

class MetraFlowShellWrapper
{
private:
  static void PumpStdio(HANDLE handle, NTLogger& logger, MTLogLevel logLevel)
  {
    char buffer[1025];
    std::ostringstream ostr;
    static const char cr(0x0d);
    static const char lf(0x0a);

    char * output_start = new char [4];
    char * output_end = output_start + 4;
    char * output_it = output_start;

    DWORD bytesRead;
    while(true)
    {
      if(FALSE==::ReadFile(handle, &buffer[0], 1024, &bytesRead, 0) || bytesRead == 0)
      {
        DWORD dwErr = ::GetLastError();
        if (dwErr != ERROR_BROKEN_PIPE)
        {
        }
        // Log anything left over in the buffer.
        if (output_it != output_start)
        {
          // Check if we need to double the output buffer.
          if (output_it == output_end)
          {
            std::size_t old_sz = output_end - output_start;
            char * new_output_start = new char [2*old_sz];
            memcpy(new_output_start, output_start, old_sz);
            output_it = new_output_start + old_sz;
            output_end = new_output_start + 2*old_sz;
            delete [] output_start;
            output_start = new_output_start;
          }
          *output_it++ = 0;
          logger.LogThis(logLevel, output_start);
        }
        delete [] output_start;
        return;
      }

      // Scan and look for CRLF.  Log each line separately.
      for(DWORD i=0; i<bytesRead; i++)
      {
        // Check if we need to double the output buffer.
        if (output_it == output_end)
        {
          std::size_t old_sz = output_end - output_start;
          char * new_output_start = new char [2*old_sz];
          memcpy(new_output_start, output_start, old_sz);
          output_it = new_output_start + old_sz;
          output_end = new_output_start + 2*old_sz;
          delete [] output_start;
          output_start = new_output_start;
        }
        
        // Buffer up the output and check if we've hit CRLF
        *output_it++ = buffer[i];

        if (output_it >= output_start+2 && output_it[-2] == cr && output_it[-1]==lf)
        {
          // Backup over CRLF, Null terminate, log and clear output buffer
          output_it[-2] = 0;
          logger.LogThis(logLevel, output_start);
          output_it = output_start;
        }
      }
    }
  }
public:
  static int Run(const std::wstring& program, NTLogger & logger)
  {
    TCHAR pathBuffer[MAX_PATH-14];
    TCHAR fileBuffer[MAX_PATH];
    DWORD dwRet = ::GetTempPath(MAX_PATH-14, pathBuffer);
    if (dwRet == 0 || dwRet + 14 > MAX_PATH)
    {
      logger.LogThis(LOG_ERROR, "Failed to create temporary path");
      return -1;
    }
    UINT uRet = ::GetTempFileName(pathBuffer, _T("MFS_"), 0, fileBuffer);
    if (uRet == 0)
    {
      logger.LogThis(LOG_ERROR, "Failed to create temporary file name");
      return -1;
    }

    std::string utf8Program;
    ::WideStringToUTF8(program, utf8Program);
    std::ofstream tmpFile(fileBuffer);
    if (tmpFile.bad())
    {
      logger.LogThis(LOG_ERROR, (boost::format("Failed to create temporary file: %1%") % fileBuffer).str().c_str());
      return -1;
    }
    tmpFile << utf8Program;
    tmpFile.close();

    // Standard MSDN code for redirecting STDIO between parent and child process.
    // The basic trick is to create an anonymous pipe with one end inheritable (for the child)
    // on the other not.  The other fun piece is that anonymous pipes only support blocking I/O
    // so we spin up a thread for each of stdout and stderr.
    SECURITY_ATTRIBUTES saAttr; 
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
    saAttr.bInheritHandle = TRUE; 
    saAttr.lpSecurityDescriptor = NULL; 
    HANDLE hChildStderrRead;
    HANDLE hChildStderrWrite;
    if (! ::CreatePipe(&hChildStderrRead, &hChildStderrWrite, &saAttr, 0)) 
    {
      return -1;
    }
    // Make the read end non-inheritable
    ::SetHandleInformation( hChildStderrRead, HANDLE_FLAG_INHERIT, 0);
    HANDLE hChildStdoutRead;
    HANDLE hChildStdoutWrite;
    if (! ::CreatePipe(&hChildStdoutRead, &hChildStdoutWrite, &saAttr, 0)) 
    {
      return -1;
    }
    // Make the read end non-inheritable
    ::SetHandleInformation( hChildStdoutRead, HANDLE_FLAG_INHERIT, 0);

    STARTUPINFO si;
    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);
    si.hStdOutput = hChildStdoutWrite;
    si.hStdError = hChildStderrWrite;
    si.dwFlags |= STARTF_USESTDHANDLES;
    PROCESS_INFORMATION pi;
    memset(&pi, 0, sizeof(pi));
    std::wstring cmdline((boost::wformat(L"MetraFlowShell.exe --partitions 1 --input-file \"%1%\"") % fileBuffer).str());
    BOOL bSuccess = ::CreateProcess(NULL,
                                    const_cast<wchar_t *>(cmdline.c_str()),
                                    NULL,
                                    NULL,
                                    TRUE,
                                    0,
                                    NULL,
                                    NULL,
                                    &si,
                                    &pi);

    if (FALSE == bSuccess)
    {
      DWORD dwErr = ::GetLastError();
      // Log and return.
      return dwErr;
    }

    // Close write ends of stdout and stderr pipes.
    ::CloseHandle(hChildStdoutWrite);
    ::CloseHandle(hChildStderrWrite);

    // Start threads that read the pipe and write output to our logger with appropriate error level.
    boost::function0<void> threadFuncStdout = boost::bind(&PumpStdio, hChildStdoutRead, boost::ref(logger), LOG_INFO);   
    boost::thread stdoutThread(threadFuncStdout);
    boost::function0<void> threadFuncStderr = boost::bind(&PumpStdio, hChildStderrRead, boost::ref(logger), LOG_ERROR);   
    boost::thread stderrThread(threadFuncStderr);

    // Wait for process to finish
    ::WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD lpExit;
    ::GetExitCodeProcess(pi.hProcess, &lpExit);

    // Wait for logger threads to finish
    stdoutThread.join();
    stderrThread.join();

    // Clean up shop
    ::CloseHandle(pi.hThread);
    ::CloseHandle(pi.hProcess);
    ::CloseHandle(hChildStdoutRead);
    ::CloseHandle(hChildStderrRead);

    return lpExit;
  }
};


STDMETHODIMP MTDiscountAdapter::Execute(IRecurringEventRunContext* apContext, BSTR* apDetails)
{
	HRESULT hr = S_OK;
	mRunContext = apContext;
	mTotalDiscounts = 0;

	mIsEndOfPeriod = (mRunContext->EventType == MetraTech_UsageServer::RecurringEventType_EndOfPeriod) ? true : false;

  if (true)
  {
    try
    {
      // First figure out whether all instances are BCR.  This enables
      // important optimizations (primarily reading from a single DB partition).
      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->Init("queries\\ProductCatalog");
      rowset->SetQueryTag(L"__DISCOUNT_INSTANCE_CYCLE_TYPE_SUMMARY__");
      rowset->Execute();
      if (0 == (long) rowset->GetValue(L"NumDiscountInstances")) 
        return S_OK;
      bool allBCR = (rowset->GetValue(L"NumDiscountInstances") == rowset->GetValue(L"NumBcrDiscountInstances"));
      rowset->Clear();

      bool hasInstances = false;
      // 
      // Generate the MetraFlowShell program for calculating discounts and metering.
      //
      CounterBuilder b(mLogger, mRunContext->UsageIntervalID, allBCR, true);
      MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
      MTPRODUCTCATALOGLib::IMTCollectionPtr PITypeColl = pc->GetPriceableItemTypes();
      for (int i=1; i <= PITypeColl->Count; ++i)
      {
        MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr PIType = PITypeColl->GetItem(i);
        // if kind is not discount then disregard
        if (PIType->GetKind() != MTPRODUCTCATALOGLib::PCENTITY_TYPE_DISCOUNT)
          continue;

        MTPRODUCTCATALOGLib::IMTCollectionPtr PITemplateColl = PIType->GetTemplates();			
        long lNumTemplates = PITemplateColl->Count;
        for (int j=1; j <= lNumTemplates; ++j)
        {
          MTPRODUCTCATALOGLib::IMTDiscountPtr PI = 
            reinterpret_cast<MTPRODUCTCATALOGLib::IMTDiscount*>(PITemplateColl->GetItem(j).pdispVal);

          // only process discounts that are part of a PO (CR11288)
          if (PI->GetInstances()->Count == 0)
            continue;

          //CR 5661: Check that all the CPDs have counter instances
          BOOL bConfigurationComplete = FALSE;
          AllCountersAreSet(PIType, PI, &bConfigurationComplete);
          if(!bConfigurationComplete)
          {
						_bstr_t msg = 
              (boost::wformat(L"The discount template %1% is missing counters and is included in a product offering.  "
                              L"Skipping discount generation.") % PI->ID).str().c_str();
						mRunContext->RecordWarning(msg);
						mLogger.LogThis(LOG_WARNING, (const char *) msg);
// 						Error((const char *) msg);
// 						return MTPC_MISSING_COUNTER;
            continue;
          }

          if ((mSingleDiscountMode && (mSingleTemplateID == PI->ID) || !mSingleDiscountMode))
          {
            hasInstances = true;
            b.Visit(PI, PIType);
          }
        }
      }

      //
      // If there were no discount instances return.
      //
      if (!hasInstances)
        return S_OK;

      // On to the show...
      // creates the temp tables
      mLogger.LogThis(LOG_DEBUG, "Creating/truncating discount temp tables");
      TruncateTempTable(rowset, mDebugTempTables, mIsOracle);

      mQueryAdapter->ClearQuery();
      if(mIsEndOfPeriod)
      {
        mQueryAdapter->SetQueryTag(L"__METRAFLOW_SIMPLE_DISCOUNT_1__");
        mQueryAdapter->AddParam("%%ID_USAGE_INTERVAL%%", mRunContext->UsageIntervalID);
        mQueryAdapter->AddParam("%%ID_BILLGROUP%%", mRunContext->BillingGroupID);
        mQueryAdapter->AddParam("%%ID_RUN%%", mRunContext->RunID);
      }
      else
      {
        mQueryAdapter->SetQueryTag(L"__METRAFLOW_SCHEDULED_DISCOUNT_ADAPTER_1__");
        mQueryAdapter->AddParam("%%VT_START%%", _variant_t((DATE)mRunContext->StartDate, VT_DATE));
        mQueryAdapter->AddParam("%%VT_END%%", _variant_t((DATE)mRunContext->EndDate, VT_DATE));
      }

      _bstr_t simpleDiscount1 = mQueryAdapter->GetRawSQLQuery(VARIANT_TRUE); 
      mLogger.LogThis(LOG_DEBUG, (const wchar_t *) simpleDiscount1);

      MetraTech_UsageServer::IMetraFlowRunPtr mf(__uuidof(MetraTech_UsageServer::MetraFlowRun));
//       int ret = MetraFlowShellWrapper::Run((const wchar_t *) simpleDiscount1, mLogger);
      int ret = mf->Run(simpleDiscount1, 
                        L"[DiscountAdapter]", 
                        reinterpret_cast<MetraTech_UsageServer::IMetraFlowConfig *>(mMetraFlowConfig.GetInterfacePtr()));
      if (ret != 0)
      {
        mRunContext->RecordWarning("MetraFlow failed while pre-processing discount subscriptions");
        mLogger.LogThis(LOG_ERROR, "MetraFlow failed while pre-processing discount subscriptions");
        return E_FAIL;
      }

      //
      // Set up the batch.  We use meter rowset for some of the batch stuff even
      // though we meter with the dataflow framework.
      //
      METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset");
      meterRowset->InitSDK("AggregateRatingServer");
  
      _bstr_t batchID = "";
      if (apContext)
      {
        METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(mRunContext->RunID,
                                                                          mEventName,
                                                                          L"All Simple Discounts");
        batchID = batch->GetUID();
      }
      else
      {
        batchID = meterRowset->GenerateBatchID();
      }
      std::vector<unsigned char> uid(16);
      MSIXUidGenerator::Decode(&uid[0], (const char *) (batchID));
      std::wstring counterCalculationProgram = (b.ReadUsage() + b.RouteUsage() + b.MeterUsage(uid, mMeteringConfig->SessionSetSize));
      ret = mf->Run(counterCalculationProgram.c_str(), 
                    L"[DiscountAdapter]",
                    reinterpret_cast<MetraTech_UsageServer::IMetraFlowConfig *>(mMetraFlowConfig.GetInterfacePtr()));
//       ret = MetraFlowShellWrapper::Run(b.ReadUsage() + b.RouteUsage() + b.MeterUsage(uid, mMeteringConfig->SessionSetSize), mLogger);
      if (ret != 0)
      {
        mRunContext->RecordWarning("MetraFlow failed while calculating discount counters");
        mLogger.LogThis(LOG_ERROR, "MetraFlow failed while calculating discount counters");
        return E_FAIL;
      }

      // Wait for first pass usage to complete before executing second pass
      long meteredRecords;
      long errorRecords = 0;
      rowset->SetQueryTag(L"__GET_AGGREGATE_METERING_COUNT__");
      rowset->Execute();
      _variant_t nullVariant;
      nullVariant.ChangeType(VT_NULL);
      _variant_t val = rowset->GetValue(L"cnt");
      if (nullVariant == val)
        meteredRecords = 0;
      else
        meteredRecords = (long) val;

      //
      // waits until all sessions commit
      //
      _bstr_t msg = "Waiting for sessions to commit (timeout = ";
      msg += _bstr_t(mMeteringConfig->CommitTimeout);
      msg += " seconds)";
      mRunContext->RecordInfo(msg);
      meterRowset->WaitForCommit(meteredRecords, mMeteringConfig->CommitTimeout);

      mRunContext->RecordInfo("All pass 1 discounts have been committed");
      if (meterRowset->CommittedErrorCount > 0)
      {
        _bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
        msg += " sessions failed during pipeline processing!";
        MT_THROW_COM_ERROR((const char *) msg);
      }

      // Time for PASS 2 processing of group discounts.
      GroupDiscountSecondPassMetraFlow(rowset);
      // TODO: Improve this with a MetraFlow based metering program.  Right now this has the overhead
      // of hitting the listener + we are iterating over pi types.  To do this with MF means that we
      // can't use temp tables anymore.
      for (int i=1; i <= PITypeColl->Count; ++i)
      {
        MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr PIType = PITypeColl->GetItem(i);
        // if kind is not discount then disregard
        if (PIType->GetKind() != MTPRODUCTCATALOGLib::PCENTITY_TYPE_DISCOUNT)
          continue;

        GroupDiscountMeterSecondPassMetraFlow(rowset, 
                                              mRunContext->UsageIntervalID, 
                                              PIType);
      }
    }
    catch(_com_error& e)
    {
      return ReturnComError(e);
    }
    catch(std::exception& e)
    {
      mLogger.LogThis(LOG_ERROR, e.what());
      return E_FAIL;
    }
    catch(...)
    {
      mLogger.LogThis(LOG_ERROR, "Unknown exception");
      return E_FAIL;
    }
    return S_OK;
  }

	// used only in SingleDiscount mode
	bool singleDiscountProcessed = false;

	try
	{
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTCollectionPtr PITypeColl = pc->GetPriceableItemTypes();

		// iterates over all priceable item types
		// TODO: apply filter to GetPriceableItemTypes method
		_com_error * firstError = NULL;
		for (int i=1; i <= PITypeColl->Count; ++i)
		{
			MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr PIType = PITypeColl->GetItem(i);

			// if kind is not discount then disregard
			if (PIType->GetKind() != MTPRODUCTCATALOGLib::PCENTITY_TYPE_DISCOUNT)
				continue;

			_bstr_t bstrServiceName = PIType->GetServiceDefinition();
			long lTypeID = PIType->ID;

			// gets all templates for this type
			MTPRODUCTCATALOGLib::IMTCollectionPtr PITemplateColl = PIType->GetTemplates();
			
			// for all the templates execute query and meter the rowset to pipeline
			long lNumTemplates = PITemplateColl->Count;
			for (int j=1; j <= lNumTemplates; ++j)
			{
				MTPRODUCTCATALOGLib::IMTDiscountPtr PI = 
					reinterpret_cast<MTPRODUCTCATALOGLib::IMTDiscount*>(PITemplateColl->GetItem(j).pdispVal);

				// only process discounts that are part of a PO (CR11288)
				if (PI->GetInstances()->Count == 0)
					continue;

				// records a nice message
				if ((mSingleDiscountMode && (mSingleTemplateID == PI->ID) || !mSingleDiscountMode))
				{
					_bstr_t msg = "Processing discount '";
					msg += PI->DisplayName;
					msg += "' with template ID ";
					msg += _bstr_t(PI->ID);
					msg += " of type '";
					msg += PIType->Name;
					msg += "'";
					mRunContext->RecordInfo(msg);
					if (mIsEndOfPeriod)
						mLogger.LogVarArgs(LOG_INFO, "Processing discount '%s' (template ID %d) for interval %d, billing group %d",
															 (char *) _bstr_t(PI->DisplayName), PI->ID, mRunContext->UsageIntervalID, mRunContext->BillingGroupID);
					else
					{
						BSTR startDate;
						VarBstrFromDate(mRunContext->StartDate, LOCALE_SYSTEM_DEFAULT, 0, &startDate);
						_bstr_t displayStartDate(startDate, false);
						
						BSTR endDate;
						VarBstrFromDate(mRunContext->EndDate, LOCALE_SYSTEM_DEFAULT, 0, &endDate);
						_bstr_t displayEndDate(endDate, false);
						
						mLogger.LogVarArgs(LOG_INFO, "Processing discount '%s' (template ID %d) for the timespan between '%s' and '%s'",
															 (char *) _bstr_t(PI->DisplayName), PI->ID, (const char *) displayStartDate, (const char *) displayEndDate);
					}
				}

				//CR 5661: Check that all the CPDs have counter instances
				BOOL bConfigurationComplete = FALSE;
				AllCountersAreSet(PIType, PI, &bConfigurationComplete);
				if(!bConfigurationComplete)
				{
						_bstr_t msg = "The discount template is missing counters and is included in a product offering!";
						mRunContext->RecordWarning(msg);
						mLogger.LogThis(LOG_ERROR, (const char *) msg);
						Error((const char *) msg);
						return MTPC_MISSING_COUNTER;
				}

				try
				{

					if (mSingleDiscountMode && (mSingleTemplateID == PI->ID))
					{
						CalculateDiscounts(PI, PIType);
						break;
					}

					if (!mSingleDiscountMode)
						CalculateDiscounts(PI, PIType);
				}
				catch (_com_error & e)
				{
					if (mMeteringConfig->FailImmediately)
						throw;
					else
					{
						string msg;
						StringFromComError(msg, "A failure occurred while processing a discount template", e);
						mLogger.LogThis(LOG_ERROR, msg.c_str());
						mRunContext->RecordWarning(_bstr_t(msg.c_str()));

						// makes a copy of the first exception to save for later
						if (firstError == NULL)
							firstError = new _com_error(e);
					}
				}
					
			}
		}

		// delayed failure
		if (firstError)
		{
			_com_error err(*firstError);
			delete firstError;
			throw err;
		}

		_bstr_t details;
		details += _bstr_t(mTotalDiscounts);
		details += " discounts generated";
		*apDetails = details.copy();

	}
	catch(_com_error & e)
	{
		return ReturnComError(e);
	}

	return hr;
}

STDMETHODIMP MTDiscountAdapter::Reverse(IRecurringEventRunContext* context, 
																				BSTR* detail)
{
	// we're "auto reverse" so we don't have to implement this
	return E_NOTIMPL;
}

STDMETHODIMP MTDiscountAdapter::CreateBillingGroupConstraints(long intervalID, 
                                                              long materializationID)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("queries\\ProductCatalog");
	rowset->SetQueryTag("__CREATE_DISCOUNT_ADAPTER_BILLING_GROUP_CONSTRAINTS__");
	rowset->AddParam("%%ID_USAGE_INTERVAL%%", intervalID);
	rowset->AddParam("%%ID_MATERIALIZATION%%", materializationID);

	rowset->Execute();

	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::SplitReverseState(long parentRunID,
																									long parentBillingGroupID,
																									long childRunID,
																									long childBillingGroupID)
{
	// we're "auto reverse" so we don't have to implement this
	return E_NOTIMPL;
}


STDMETHODIMP MTDiscountAdapter::Shutdown()
{
	// nothing to do
	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_SupportsScheduledEvents(VARIANT_BOOL* pRetVal)
{
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_SupportsEndOfPeriodEvents(VARIANT_BOOL* pRetVal)
{
	// end of period only
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_Reversibility(ReverseMode* pRetVal)
{
	// all we do is meter batches - that can be reversed automatically
	*pRetVal = ReverseMode_Auto;
	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_AllowMultipleInstances(VARIANT_BOOL* pRetVal)
{
	// TODO: uniquify the use of t_pv_groupdiscount_temp so that we can return true

	// because of the exclusive use t_pv_groupdiscount_temp this adapter
	// can not run concurrently with other Discount adapter instances
	*pRetVal = VARIANT_FALSE;
	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_BillingGroupSupport(BillingGroupSupportType* pRetVal)
{
  if (pRetVal == NULL)
		return E_POINTER;

  *pRetVal = BillingGroupSupportType_Account;

	return S_OK;
}

STDMETHODIMP MTDiscountAdapter::get_HasBillingGroupConstraints(VARIANT_BOOL* pRetVal)
{
	*pRetVal = VARIANT_TRUE;
	return S_OK;
}


HRESULT MTDiscountAdapter::AllCountersAreSet(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr& PIType,
																						 MTPRODUCTCATALOGLib::IMTDiscountPtr& PI,
																						 BOOL* aRet)
{
	try
	{
		//CR 5661: Check that all the CPDs have counter instances
		MTPRODUCTCATALOGLib::IMTCollectionPtr cpds  = PIType->GetCounterPropertyDefinitions();

		for (int i=1; i <= cpds->Count; ++i)
		{
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = 
					reinterpret_cast<MTPRODUCTCATALOGLib::IMTCounterPropertyDefinition*>(cpds->GetItem(i).pdispVal);
			if(PI->GetCounter(cpd->ID) == NULL)
			{
				(*aRet) = FALSE;
				return S_OK;
			}

		}
		(*aRet) = TRUE;
		return S_OK;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
}


void MTDiscountAdapter::CalculateDiscounts(MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
																					 MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType)
{
	QueryParameters queryParams;
	queryParams.interval = mRunContext->UsageIntervalID;
	
	// looks at the counters and derives query parameters 
	mLogger.LogThis(LOG_DEBUG, "Processing counters...");
	ProcessCounters(aDiscount, queryParams);
	
	_com_error * firstError = NULL;

	bool isBillingCycleRelative = (aDiscount->Cycle->Relative == VARIANT_TRUE) ? true : false;

	// process "simple" discounts
	try
	{
		if (false && mProcessSimpleDiscounts && mIsEndOfPeriod)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Calculating simple discount...");
			CalculateSimpleDiscount(mRunContext->UsageIntervalID, queryParams, aDiscount, aDiscountType);
		}
    else
    {
      mLogger.LogThis(LOG_DEBUG, (boost::format("Skipping simple discounts.  ProcessSimpleDiscount=%1%; IsEndOfPeriod=%2%") % mProcessSimpleDiscounts % mIsEndOfPeriod).str().c_str());
    }
	}
	catch (_com_error & e)
	{
		if (mMeteringConfig->FailImmediately)
			throw;
		
		// makes a copy of the first exception to save for later
		firstError = new _com_error(e);
	}

	// process group discounts
	try
	{
    // Process group discounts whether EOP or scheduled.  Queries will
    // pick out discount instances as appropriate based on BCR/fixed cycle criteria.
		if (mProcessGroupDiscounts)
		{
			mLogger.LogVarArgs(LOG_DEBUG, "Calculating group discount...");
			CalculateGroupDiscount(mRunContext->UsageIntervalID, queryParams, aDiscount, aDiscountType);
		}
    else
    {
      mLogger.LogThis(LOG_DEBUG, (boost::format("Skipping group discount.  ProcessSimpleDiscount=%1%; IsBillingCycleRelative=%2%; IsEndOfPeriod=%3%") % mProcessGroupDiscounts % isBillingCycleRelative % mIsEndOfPeriod).str().c_str());
    }
	}
	catch (_com_error &)
	{
		// reports the earliest error if there was one
		if (!firstError)
			throw;
	}

	if (firstError)
	{
		_com_error err(*firstError);
		delete firstError;
		throw err;
	}
}

// A simple discount is a transaction generated for each subscriber to a particular
// product offering. How the simple discount transaction is rated depends on two major
// factors:
//   1) the total of the cumulative tiered counter(s) for the discount period
//   2) whether the subscriber is part of a group subscription with shared rates
//
// The first part is calculated in the adapter (in the form of queries) and metered in to 
// the discount stages. The second part is completely determined in the rating plugin. 
// From the point of view of generation, they are exactly the same.
void MTDiscountAdapter::CalculateSimpleDiscount(long aIntervalID,
																								QueryParameters & queryParams,
																								MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
																								MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("queries\\ProductCatalog");
	AutoTruncate autoTrunc(rowset, mDebugTempTables, mIsOracle);

	// prepares the temp tables
	mLogger.LogThis(LOG_DEBUG, "Preparing discount temp tables");
	PrepareTempTable(aIntervalID, aDiscount->ID, FALSE, rowset);

	mLogger.LogThis(LOG_DEBUG, "Executing simple discount summary query");
	mRunContext->RecordInfo("Executing simple discount summary query");
	ExecuteSummaryQuery(queryParams, rowset);
	mRunContext->RecordInfo("Simple discount summary query completed");

 	if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
	{
		_bstr_t msg = "No simple discounts need to be generated, not metering";
		mRunContext->RecordInfo(msg);
		mLogger.LogThis(LOG_DEBUG, (const char *) msg);
		return;
	}

	// meters the rowset
	long successfulSessions;
	MeterRowset(aDiscountType, aIntervalID, rowset, successfulSessions, aDiscount->Name + " - Simple"); 
	mTotalDiscounts += successfulSessions;

	mLogger.LogVarArgs(LOG_INFO, "%d simple discounts were successfully generated by '%s'"
										 " (template ID %d) for interval %d.",
										 successfulSessions,
										 (char *) _bstr_t(aDiscount->GetDisplayName()),
										 aDiscount->ID,
										 aIntervalID);
}

void MTDiscountAdapter::GroupDiscountSecondPassMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	//
	// PASS 2: calculates the members' share of the group discount
	//

	// calculates proportional distributions
  mRunContext->RecordInfo("Executing proportional distribution query");
  mLogger.LogThis(LOG_DEBUG, "Executing proportional distribution query");
  ExecuteProportionalDistributionQueryMetraFlow(aRowset);
  mRunContext->RecordInfo("Proportional distribution query completed");

	// adds in single-account distributions
	mRunContext->RecordInfo("Executing single-account distribution query");
	mLogger.LogThis(LOG_DEBUG, "Executing single-account distribution query");
  ExecuteSingleAccountDistributionQuery(aRowset);
	mRunContext->RecordInfo("Single-account distribution query completed");

}

void MTDiscountAdapter::GroupDiscountMeterSecondPassMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset, 
                                                              long aIntervalID, 
                                                              MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType)
{
	// returns the final results
	mRunContext->RecordInfo("Executing final group discount query");
	mLogger.LogThis(LOG_DEBUG, "Executing final group discount query...");
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__PROCESS_GROUP_DISCOUNT_FINAL_METRA_FLOW__");
  aRowset->AddParam(L"%%ID_PI%%", aDiscountType->ID);
	OverrideTempTablePrefix(aRowset);
	aRowset->ExecuteConnected();
	mRunContext->RecordInfo("Final group discount query completed");

 	if (aRowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
	{
		_bstr_t msg = "No group discounts need to be generated, not metering";
		mRunContext->RecordInfo(msg);
		mLogger.LogThis(LOG_DEBUG, (const char *) msg);
		return;
	}

	// meters with _IntervalID only if the adapter is running as end-of-period event.
	long intervalID;
	if (mIsEndOfPeriod)
		intervalID = mRunContext->UsageIntervalID;
	else
		// puts intervalresolution into a special soft close override mode (CR10750)
		intervalID = -1;
  
	// meters the rowset
  long successfulSessions;
	MeterRowset(aDiscountType, aIntervalID, aRowset, successfulSessions, aDiscountType->Name + " - Group"); 
	mTotalDiscounts += successfulSessions;

	mLogger.LogVarArgs(LOG_INFO, "%d group discounts were successfully generated by discount type '%s'"
										 " (type ID %d) for interval %d.",
										 successfulSessions,
										 (char *) aDiscountType->Name,
										 aDiscountType->ID,
										 aIntervalID);
}

void MTDiscountAdapter::CalculateGroupDiscount(long aIntervalID, 
																							 QueryParameters & queryParams,
																							 MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
																							 MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType)
{
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init("queries\\ProductCatalog");
	AutoTruncate autoTrunc(rowset, mDebugTempTables, mIsOracle);

	// prepares the temp tables
	mLogger.LogThis(LOG_DEBUG, "Preparing discount temp tables...");
	PrepareTempTable(aIntervalID, aDiscount->ID, TRUE, rowset);


	//
	// PASS 1: group discount rate retrieval
	//

	// executes the group rating query which returns a row 
	// for each group discount containing counters with
	// all member contributions included.
	mRunContext->RecordInfo("Executing group discount summary query");
	mLogger.LogThis(LOG_DEBUG, "Executing group discount summary query...");
	ExecuteGroupSummaryQuery(queryParams, rowset);
	mRunContext->RecordInfo("Group discount summary query completed");

	if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
	{
		_bstr_t msg = "No group discounts need to be generated, not metering";
		mRunContext->RecordInfo(msg);
		mLogger.LogThis(LOG_DEBUG, (const char *) msg);
		return;
	}

	// meters the rowset, results are stored in t_pv_groupdiscount_temp
	long successfulSessions;
	MeterRowset(aDiscountType, aIntervalID, rowset, successfulSessions, aDiscount->Name + " - Group (temp)"); 


	//
	// PASS 2: calculates the members' share of the group discount
	//

	// calculates proportional distributions
	if (queryParams.distributionCounter.length() > 0)
	{
		mRunContext->RecordInfo("Executing proportional distribution query");
		mLogger.LogThis(LOG_DEBUG, "Executing proportional distribution query");
		ExecuteProportionalDistributionQuery(queryParams, rowset);
		mRunContext->RecordInfo("Proportional distribution query completed");
	}

	// adds in single-account distributions
	mRunContext->RecordInfo("Executing single-account distribution query");
	mLogger.LogThis(LOG_DEBUG, "Executing single-account distribution query");
  ExecuteSingleAccountDistributionQuery(rowset);
	mRunContext->RecordInfo("Single-account distribution query completed");

	// returns the final results
	mRunContext->RecordInfo("Executing final group discount query");
	mLogger.LogThis(LOG_DEBUG, "Executing final group discount query...");
  ExecuteFinalGroupDiscountQuery(rowset);
	mRunContext->RecordInfo("Final group discount query completed");

 	if (rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
	{
		_bstr_t msg = "No group discounts need to be generated, not metering";
		mRunContext->RecordInfo(msg);
		mLogger.LogThis(LOG_DEBUG, (const char *) msg);
		return;
	}

	// meters with _IntervalID only if the adapter is running as end-of-period event.
	long intervalID;
	if (mIsEndOfPeriod)
		intervalID = mRunContext->UsageIntervalID;
	else
		// puts intervalresolution into a special soft close override mode (CR10750)
		intervalID = -1;

	// meters the rowset
	MeterRowset(aDiscountType, intervalID, rowset, successfulSessions, aDiscount->Name + " - Group"); 
	mTotalDiscounts += successfulSessions;


	mLogger.LogVarArgs(LOG_INFO, "%d group discounts were successfully generated by '%s'"
										 " (template ID %d) for interval %d.",
										 successfulSessions,
										 (char *) _bstr_t(aDiscount->GetDisplayName()),
										 aDiscount->ID,
										 aIntervalID);
}


void MTDiscountAdapter::ProcessCounters(MTPRODUCTCATALOGLib::IMTDiscountPtr aDiscount,
																				QueryParameters & queryParams)
{
	std::set<_bstr_t> countableTableNames;
  std::map<long, AdjustmentParam> adjustmentParams;
	std::set<_bstr_t> distributionCountableTableNames;
  std::map<long, AdjustmentParam> distributionAdjustmentParams;
	std::set<_bstr_t>::iterator it;
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
  MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr pitypePtr;

	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr pPIType = aDiscount->PriceableItemType;
	MTPRODUCTCATALOGLib::IMTCollectionPtr pCPDColl = pPIType->GetCounterPropertyDefinitions();

	queryParams.cpdCount =  pCPDColl->Count;

	bool isBillingCycleRelative = (aDiscount->Cycle->Relative == VARIANT_TRUE) ? true : false;
	bool isDistributionCounter;

	//2. Iterate through CPD collection, 
	//		for every CPD id call discount->GetCounter 
	for (int i=1; i <= queryParams.cpdCount; ++i)
	{
		MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr pCPD = pCPDColl->GetItem(i);
		MTCOUNTERLib::IMTCounterPtr pCounter = aDiscount->GetCounter( pCPD->GetID() );

		if (pCounter == NULL) /*counter not set*/
			continue;

    isDistributionCounter = (aDiscount->GetDistributionCPDID() == pCPD->GetID());
			
		//3. Set Alias as this counters' CPD's name. It will be returned as "AS .." on SQL formula
		pCounter->Alias = " ";
		queryParams.counters += ", " + 	pCounter->GetFormula(MTCOUNTERLib::VIEW_DISCOUNTS);
		queryParams.counters += pCPD->ServiceDefProperty;

		if (isDistributionCounter)
		{
			// HACK: strip off the "AS  " from the end of the formula
			std::string str = (char *) pCounter->GetFormula(MTCOUNTERLib::VIEW_DISCOUNTS);
			queryParams.distributionCounter = str.substr(0, str.length() - 4).c_str();
		}

		// exposes the counters from a sub-select
		if (mIsOracle)
			queryParams.groupExposeCounters += "NVL(";
		else
			queryParams.groupExposeCounters += "ISNULL(";
		queryParams.groupExposeCounters += "counters.";
		queryParams.groupExposeCounters += pCPD->ServiceDefProperty;
		queryParams.groupExposeCounters += ", 0) ";
		queryParams.groupExposeCounters += pCPD->ServiceDefProperty;
		queryParams.groupExposeCounters += ", ";

		if (isDistributionCounter)
		{
			if (mIsOracle)
				queryParams.groupExposeCounters += "NVL(";
			else
				queryParams.groupExposeCounters += "ISNULL(";
			queryParams.groupExposeCounters += "counters.";
			queryParams.groupExposeCounters += pCPD->ServiceDefProperty;
			queryParams.groupExposeCounters += ", 0) c_DistributionCounter,";
		}

		//4. Get parameter collection
		MTPRODUCTCATALOGLib::IMTCollectionPtr pParamColl = pCounter->Parameters;
		long lParamCount = pParamColl->Count;
			
		//5. Iterate through param collection
		for (int j=1; j <= lParamCount; ++j)
		{
				
			MTCOUNTERLib::IMTCounterParameterPtr pParam = pParamColl->GetItem(j);
			//if a parameter is just a constant, then don't do anything
			if (pParam->GetKind() == PARAM_CONST)
				continue;
				
			_bstr_t bstrPVTableName = pParam->ProductViewTable;
			_bstr_t bstrTableName = pParam->TableName;
				
			countableTableNames.insert(bstrTableName);
			countableTableNames.insert(bstrPVTableName);

			if (isDistributionCounter)
			{
				distributionCountableTableNames.insert(bstrTableName);
				distributionCountableTableNames.insert(bstrPVTableName);
			}

      //insert adjustment tables into collection
      //if the parameter is not charge based, then adjustment table
      //is t_adjustment_transaction and table name needs to be aliased
      AdjustmentParam ajparam;
      long lChargeID = pParam->ChargeID;
      ajparam.ChargeBased = (lChargeID > 0);
      ajparam.ProductViewTableName = bstrPVTableName;
      ajparam.AdjustmentTableName = pParam->AdjustmentTable;

      
      long pitypeid = pParam->PriceableItemTypeID;
      long lViewID;
      //we still support product views that are not based on PI types
      //in this case get product view object directly
      if(pitypeid < 0)
      {
        // TODO: this is NOT the right way to construct the session context.
		    // We should really retrieve the credentials and login as the user invoking the script
		    MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr pvreader("Metratech.MTProductViewReader");
        MTPRODUCTVIEWEXECLib::IProductViewPtr pvPtr = pvreader->FindByName
          (
          reinterpret_cast<MTPRODUCTVIEWEXECLib::IMTSessionContext*>(mCtx.GetInterfacePtr()), 
          pParam->ProductViewName
          );
        lViewID = pvPtr->ViewID;
      }
      else
      {
        pitypePtr = pc->GetPriceableItemType(pitypeid);
        lViewID = pitypePtr->GetProductViewObject()->ViewID;
      }

      ajparam.ViewID = lViewID;

      //key is constructed as a sum of view id and ChargeBased flag
      //if there are parameters attached to the same product view, but 
      //one is charge based and the other one isn't, then we want both of them in the map
      adjustmentParams.insert
        (std::map<long, AdjustmentParam>::value_type(ajparam.ViewID + (long)ajparam.ChargeBased, ajparam));

			if (isDistributionCounter)
				distributionAdjustmentParams.insert
					(std::map<long, AdjustmentParam>::value_type(ajparam.ViewID + (long)ajparam.ChargeBased, ajparam));


		}
	}

	// builds up the left outer joins (these are all against t_acc_usage) 
	for (it = countableTableNames.begin(); it != countableTableNames.end(); it++)
	{
		_bstr_t table = *it;
			
		// only creates the outer join if the param table not t_acc_usage
		if(_wcsicmp((wchar_t*) table, L"t_acc_usage") != 0)
		{
			queryParams.outerJoins += " LEFT OUTER JOIN ";
			queryParams.outerJoins += table;
			queryParams.outerJoins += " ON ";
			queryParams.outerJoins += table;
			queryParams.outerJoins += ".id_sess = t_acc_usage.id_sess\n";
			queryParams.outerJoins += " AND ";
			queryParams.outerJoins += table;
			queryParams.outerJoins += ".id_usage_interval = t_acc_usage.id_usage_interval\n";
		}
	}
	
	// builds up the left outer joins for the distribution counter
	for (it = distributionCountableTableNames.begin();
			 it != distributionCountableTableNames.end();
			 it++)
	{
		_bstr_t table = *it;
			
		// only creates the outer join if the param table not t_acc_usage
		if(_wcsicmp((wchar_t*) table, L"t_acc_usage") != 0)
		{
			queryParams.distributionOuterJoins += "  LEFT OUTER JOIN ";
			queryParams.distributionOuterJoins += table;
			queryParams.distributionOuterJoins += " ON ";
			queryParams.distributionOuterJoins += table;
			queryParams.distributionOuterJoins += ".id_sess = t_acc_usage.id_sess\n";
			queryParams.distributionOuterJoins += " AND ";
			queryParams.distributionOuterJoins += table;
			queryParams.distributionOuterJoins += ".id_usage_interval = t_acc_usage.id_usage_interval\n";
		}
	}

  // builds up the left outer joins for adjustments
	queryParams.adjustmentOuterJoins = GenerateAdjustmnetJoins(adjustmentParams);
	queryParams.distributionAdjustmentOuterJoins = GenerateAdjustmnetJoins(distributionAdjustmentParams);

	// if the discount has counters (is not flat unqualified)
	if(!countableTableNames.empty())
	{
		mQueryAdapter->ClearQuery();
		if (isBillingCycleRelative)
		{
			// CR7065: BCR discounts should count usage that falls into the discount interval
			//         not based on dt_session, but rather on id_interval
			mQueryAdapter->SetQueryTag("__SIMPLE_DISCOUNT_OPTIONAL_ACC_USAGE_INNER_JOIN_BCR__");
			mQueryAdapter->AddParam("%%ID_INTERVAL%%", mRunContext->UsageIntervalID);
			mQueryAdapter->AddParam("%%ID_BILLGROUP%%", mRunContext->BillingGroupID);
			queryParams.accUsageJoin += mQueryAdapter->GetQuery();

			mQueryAdapter->ClearQuery();
			mQueryAdapter->SetQueryTag("__GROUP_DISCOUNT_COUNTER_ACC_USAGE_FILTER_BCR__");
			mQueryAdapter->AddParam("%%ID_INTERVAL%%", mRunContext->UsageIntervalID);
			queryParams.groupAccUsageFilter = mQueryAdapter->GetQuery();
		}
		else
		{
			// adds the t_acc_usage inner join, filtering on payee and time
			mQueryAdapter->SetQueryTag("__SIMPLE_DISCOUNT_OPTIONAL_ACC_USAGE_INNER_JOIN__");
			queryParams.accUsageJoin += mQueryAdapter->GetQuery();

			mQueryAdapter->ClearQuery();
			mQueryAdapter->SetQueryTag("__GROUP_DISCOUNT_COUNTER_ACC_USAGE_FILTER__");
			queryParams.groupAccUsageFilter = mQueryAdapter->GetQuery();
		}

		mQueryAdapter->ClearQuery();
		mQueryAdapter->SetQueryTag("__GROUP_DISCOUNT_TOTALS_SUBSELECT__");
		mQueryAdapter->AddParam("%%COUNTERS%%", queryParams.counters);
		mQueryAdapter->AddParam("%%COUNTER_USAGE_OUTER_JOINS%%", queryParams.outerJoins);
		mQueryAdapter->AddParam("%%ADJUSTMENTS_OUTER_JOINS%%", queryParams.adjustmentOuterJoins, VARIANT_TRUE);
		mQueryAdapter->AddParam("%%ACC_USAGE_FILTER%%", queryParams.groupAccUsageFilter);
		OverrideTempTablePrefix(mQueryAdapter);

		queryParams.groupSubSelect += mQueryAdapter->GetQuery();
	}

	queryParams.infoLabel = ConstructInfoLabel(aDiscount->Name,
																						 aDiscount->DisplayName,
																						 aDiscount->ID,
																						 queryParams.cpdCount);
}


_bstr_t MTDiscountAdapter::GenerateAdjustmnetJoins(std::map<long, AdjustmentParam> & adjustmentParams)
{
  std::map<long, AdjustmentParam>::const_iterator ajit;

	_bstr_t joins = "";
  int idx = 0;
	for (ajit = adjustmentParams.begin(); ajit != adjustmentParams.end(); ajit++)
	{
    AdjustmentParam ajparam = (*ajit).second;
    _bstr_t ajtable = ajparam.AdjustmentTableName;
    _bstr_t pvtable = ajparam.ProductViewTableName;
    long viewID = ajparam.ViewID;
    char ajviewaliased[256];
    sprintf(ajviewaliased, "vw_aj_info_%d", viewID);

    char szItervalId[128];
    sprintf(szItervalId, "%d", mRunContext->UsageIntervalID);

		_bstr_t bstrViewAliased  = ajviewaliased;
		if(mbUseMaterializedViews == true)
		{
			ajtable = "(\n\t";
			ajtable += "SELECT au.id_sess, au.id_usage_interval,CompoundPrebillAdjAmt FROM t_acc_usage au ";
			ajtable += "\n\t";
			ajtable += "\n\t";
			ajtable += "INNER JOIN t_mv_adjustments_usagedetail mvaud on mvaud.id_sess = au.id_sess\n";
			ajtable += "WHERE au.id_usage_interval = ";
			ajtable += szItervalId;
			ajtable += ")";
		}
    if(ajparam.ChargeBased)
    {
      //if adjustment parameter is charge based then we need to
      //add another join from T_AJ* table to the regular adjustment table
      //as such:
      //LEFT OUTER JOIN t_adjustment_transaction xxx
      //ON t_pv_audioconfconnection.id_sess = t_adjustment_transaction.id_sess 

      //generate alias for t_adjustment_transaction
      //make sure it's unique in the query
      char alias[256];
      sprintf(alias, "t_adjustment_transaction_%d_%d", viewID, idx++);
      _bstr_t bstrAlias = alias;
      joins += " LEFT OUTER JOIN t_adjustment_transaction ";
      joins += bstrAlias;
      joins += " ON (";
      joins += bstrAlias;
      joins += ".id_sess = ";
      joins += pvtable;
      joins += ".id_sess\n";
      joins += " AND \n";
      joins += bstrAlias;
      joins += ".id_usage_interval = t_acc_usage.id_usage_interval\n";

      //only take Approved Prebill adjustments into consideration
      joins += " AND \n";
      joins += bstrAlias;
      joins += ".c_Status = 'A' AND ";
      joins += bstrAlias;
      joins += ".n_adjustmenttype = 0)\n";

      joins += " LEFT OUTER JOIN ";
      joins += ajtable;
      joins += " ON ";
      joins += ajtable;
      joins += ".id_adjustment = ";
      joins += bstrAlias;
      joins += ".id_adj_trx\n";
    }
    else
    {
      joins += " LEFT OUTER JOIN ";
      joins += ajtable;
      joins += " ";
      joins += bstrViewAliased;
      joins += " ON ";
      joins += bstrViewAliased;
      joins += ".id_sess = ";
      joins += pvtable;
      joins += ".id_sess\n";
      joins += " AND ";
      joins += bstrViewAliased;
      joins += ".id_usage_interval = ";
      joins += pvtable;
      joins += ".id_usage_interval\n";
    }
	}

	return joins;
}


// abstracts away the different mechanisms of inserting into temp tables
// supposedly for SQL Server, the most efficient method is a SELECT ... INTO ...
// for Oracle, the method used is INSERT INTO ...
void MTDiscountAdapter::AddTempTableInsertionParams(ROWSETLib::IMTSQLRowsetPtr aRowset,
																										const char * apTableName)
{

	_bstr_t insertIntoClause;
	_bstr_t intoClause;
	mQueryAdapter->SetQueryTag("__INSERT_STATEMENT_ABSTRACTION__");
	mQueryAdapter->AddParam("%%TABLE_NAME%%", apTableName);
	OverrideTempTablePrefix(mQueryAdapter);
	
	if (mIsOracle)
	{
		// for Oracle use INSERT INTO
		insertIntoClause = mQueryAdapter->GetQuery();
		intoClause = "";
	}
	else
	{
		// for SQL Server, use SELECT ... INTO
		insertIntoClause = ""; 
		intoClause = mQueryAdapter->GetQuery();
	}

	aRowset->AddParam("%%INSERT_INTO_CLAUSE%%", insertIntoClause);
	aRowset->AddParam("%%INTO_CLAUSE%%", intoClause);

	mQueryAdapter->SetQueryTag("__INSERT_STATEMENT_ABSTRACTION2__");
	mQueryAdapter->AddParam("%%TABLE_NAME%%", apTableName);
	OverrideTempTablePrefix(mQueryAdapter);
	aRowset->AddParam("%%INSERT_INTO_CLAUSE2%%", mQueryAdapter->GetQuery());
}


void MTDiscountAdapter::PrepareTempTable(long aIntervalID,
																				 long aTemplateID,
																				 bool aIsGroupDiscount,
																				 ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	TruncateTempTable(aRowset, mDebugTempTables, mIsOracle);

	if (aIsGroupDiscount)
	{
		// inserts group subscription records into temp table 2
		aRowset->ClearQuery();
		aRowset->SetQueryTag("__INSERT_GROUP_DISCOUNT_2__");
		aRowset->AddParam("%%ID_PI%%", _variant_t(aTemplateID));

		_bstr_t discountIntervalFilter;
		_bstr_t billingGroupFilter;
		mQueryAdapter->ClearQuery();
		if (mIsEndOfPeriod)
		{
			mQueryAdapter->SetQueryTag("__INSERT_GROUP_DISCOUNT_2_DISCOUNT_INTERVAL_FILTER_EOP__");
			mQueryAdapter->AddParam("%%ID_USAGE_INTERVAL%%", mRunContext->UsageIntervalID);
			discountIntervalFilter = mQueryAdapter->GetQuery();

			// inserts billing group filter for EOP query
			// only group subs with a payer "associated" with the current billing group will be processed
			// see query for more details
			mQueryAdapter->ClearQuery();
			mQueryAdapter->SetQueryTag("__INSERT_GROUP_DISCOUNT_2_BILLING_GROUP_FILTER__");
			mQueryAdapter->AddParam("%%ID_BILLGROUP%%", mRunContext->BillingGroupID);
			billingGroupFilter += mQueryAdapter->GetQuery();
		}
		else
		{
			mQueryAdapter->SetQueryTag("__INSERT_GROUP_DISCOUNT_2_DISCOUNT_INTERVAL_FILTER_SCH__");
			mQueryAdapter->AddParam("%%DT_ARG_START%%", _variant_t((DATE)mRunContext->StartDate, VT_DATE));
			mQueryAdapter->AddParam("%%DT_ARG_END%%", _variant_t((DATE)mRunContext->EndDate, VT_DATE));
			discountIntervalFilter = mQueryAdapter->GetQuery();
		}
		aRowset->AddParam("%%DISCOUNT_INTERVAL_FILTER%%", discountIntervalFilter, TRUE);
		aRowset->AddParam("%%BILLING_GROUP_FILTER%%", billingGroupFilter, TRUE);

		AddTempTableInsertionParams(aRowset, "tmp_discount_2");
		aRowset->Execute();
	}
	else
	{
		// stores non-acc usage related information in temp table 1
		aRowset->ClearQuery();
		aRowset->SetQueryTag("__INSERT_SIMPLE_DISCOUNT_1__");
		aRowset->AddParam("%%ID_INTERVAL%%", _variant_t(aIntervalID));
		aRowset->AddParam("%%ID_PI%%", _variant_t(aTemplateID));
		aRowset->AddParam("%%ID_BILLGROUP%%", mRunContext->BillingGroupID);
		AddTempTableInsertionParams(aRowset, "tmp_discount_1");
		aRowset->Execute();
		
		// adds indexes to tmp_discount_1 table
		aRowset->ClearQuery();
		aRowset->SetQueryTag("__CREATE_SIMPLE_DISCOUNT_1_INDEXES__");
		OverrideTempTablePrefix(aRowset);
		aRowset->Execute();
		
		// stores the product interval dates in temp table 2
		aRowset->ClearQuery();
		aRowset->SetQueryTag("__INSERT_SIMPLE_DISCOUNT_2__");
		AddTempTableInsertionParams(aRowset, "tmp_discount_2");
		OverrideTempTablePrefix(aRowset);
		aRowset->Execute();
		
		// adds indexes to tmp_discount_2
		aRowset->ClearQuery();
		aRowset->SetQueryTag("__CREATE_SIMPLE_DISCOUNT_2_INDEXES__");
		OverrideTempTablePrefix(aRowset);
		aRowset->Execute();
	}
}

// throws
void MTDiscountAdapter::MeterRowset(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr aDiscountType,
																		long aIntervalID,
																		ROWSETLib::IMTSQLRowsetPtr aRowset,
																		long & aSuccessfulSessions,
																		_bstr_t aSequence)
{
	_bstr_t msg = "Metering results to service definition '";
	msg += aDiscountType->GetServiceDefinition();
	msg += "'";
	mRunContext->RecordInfo(msg);

	METERROWSETLib::IMeterRowsetPtr meterRowset("MetraTech.MeterRowset.1");
	meterRowset->InitSDK("DiscountServer");
	meterRowset->InitForService(aDiscountType->GetServiceDefinition());
	meterRowset->SessionSetSize = mMeteringConfig->SessionSetSize;
	
	// the sequence "number" is usually the discount template's name
	// this should always be unique for a given run ID
	METERROWSETLib::IBatchPtr batch = meterRowset->CreateAdapterBatch(mRunContext->RunID, mEventName, aSequence);


	if (aIntervalID == NULL) 
		// picks up _IntervalID from the group discount query
		meterRowset->AddColumnMapping("c__IntervalId", METERROWSETLib::MTC_DT_INT, "_IntervalId", VARIANT_FALSE);
	else
		// uses the interval ID that the adapter was invoked on
		meterRowset->AddCommonProperty("_IntervalId", METERROWSETLib::MTC_DT_INT, aIntervalID);

	meterRowset->MeterRowset((METERROWSETLib::IMTSQLRowsetPtr) aRowset);

	msg = _bstr_t(meterRowset->MeteredCount);
	msg += " sessions were metered";
	mRunContext->RecordInfo(msg);

	if (meterRowset->MeterErrorCount > 0)
	{
		msg = _bstr_t(meterRowset->MeterErrorCount);
		msg += " sessions failed to meter (client side)! The adapter will need to be run again.";
		MT_THROW_COM_ERROR((const char *) msg);
	}

	msg = "Waiting for sessions to commit (timeout = ";
	msg += _bstr_t(mMeteringConfig->CommitTimeout);
	msg += " seconds)";
	mRunContext->RecordInfo(msg);

	meterRowset->WaitForCommit(meterRowset->MeteredCount, mMeteringConfig->CommitTimeout);

	mRunContext->RecordInfo("All sessions have been committed");

	if (meterRowset->CommittedErrorCount > 0)
	{
		_bstr_t msg = _bstr_t(meterRowset->CommittedErrorCount);
		msg += " sessions failed during pipeline processing!";
		MT_THROW_COM_ERROR((const char *) msg);
	}

	aSuccessfulSessions = meterRowset->CommittedSuccessCount;
}


void MTDiscountAdapter::ExecuteSummaryQuery(const QueryParameters & aParams,
																						ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__PROCESS_SIMPLE_DISCOUNT_FINAL__");
	aRowset->AddParam("%%COUNTERS%%", aParams.counters);
	aRowset->AddParam("%%COUNTER_USAGE_OUTER_JOINS%%", aParams.outerJoins);
  aRowset->AddParam("%%ADJUSTMENTS_OUTER_JOINS%%", aParams.adjustmentOuterJoins, VARIANT_TRUE);
	aRowset->AddParam("%%OPTIONAL_ACC_USAGE_JOIN%%", aParams.accUsageJoin);
	aRowset->AddParam("%%INFO_LABEL%%", aParams.infoLabel);
	OverrideTempTablePrefix(aRowset);

	aRowset->ExecuteConnected();
}

void MTDiscountAdapter::ExecuteGroupSummaryQuery(const QueryParameters & aParams,
																								 ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CALCULATE_GROUP_DISCOUNT_TOTALS__");
	aRowset->AddParam("%%EXPOSE_COUNTERS%%", aParams.groupExposeCounters);
	aRowset->AddParam("%%COUNTERS_SUBSELECT%%", aParams.groupSubSelect, VARIANT_TRUE);
	aRowset->AddParam("%%INFO_LABEL%%", aParams.infoLabel);
	OverrideTempTablePrefix(aRowset);

	aRowset->ExecuteConnected();
}


void MTDiscountAdapter::ExecuteProportionalDistributionQueryMetraFlow(ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
  aRowset->SetQueryTag("__INSERT_GROUP_DISCOUNT_PROPORTIONS_METRA_FLOW__");
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CALCULATE_PROPORTIONAL_GROUP_DISCOUNT__");
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CALCULATE_PROPORTIONAL_GROUP_DISCOUNT_ADJUSTMENT__");
	OverrideTempTablePrefix(aRowset);
	AddTempTableInsertionParams(aRowset, "tmp_discount_5");
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__ADJUST_PROPORTIONAL_GROUP_DISCOUNT__");
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();
}

void MTDiscountAdapter::ExecuteProportionalDistributionQuery(const QueryParameters & aParams,
																														 ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CAST_GROUP_DISCOUNT_PROPORTION__");
	aRowset->AddParam("%%DISTRIBUTION_COUNTER%%", aParams.distributionCounter);
	_bstr_t proportionCast = aRowset->GetQueryString();
	
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__INSERT_GROUP_DISCOUNT_PROPORTIONS__");
	aRowset->AddParam("%%PROPORTION_CAST%%", proportionCast);
	aRowset->AddParam("%%DISTRIBUTION_COUNTER%%", aParams.distributionCounter);
	aRowset->AddParam("%%DISTRIBUTION_USAGE_OUTER_JOINS%%", aParams.distributionOuterJoins);
  aRowset->AddParam("%%ADJUSTMENTS_OUTER_JOINS%%", aParams.distributionAdjustmentOuterJoins, VARIANT_TRUE);
  aRowset->AddParam("%%ACC_USAGE_FILTER%%", aParams.groupAccUsageFilter);
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CALCULATE_PROPORTIONAL_GROUP_DISCOUNT__");
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__CALCULATE_PROPORTIONAL_GROUP_DISCOUNT_ADJUSTMENT__");
	OverrideTempTablePrefix(aRowset);
	AddTempTableInsertionParams(aRowset, "tmp_discount_5");
	aRowset->Execute();

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__ADJUST_PROPORTIONAL_GROUP_DISCOUNT__");
	OverrideTempTablePrefix(aRowset);
	aRowset->Execute();
}

void MTDiscountAdapter::ExecuteSingleAccountDistributionQuery(ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__INSERT_GROUP_DISCOUNT_SINGLE_ACCOUNT_DISTRIBUTION__");
	OverrideTempTablePrefix(aRowset);

	aRowset->Execute();
}

void MTDiscountAdapter::ExecuteFinalGroupDiscountQuery(ROWSETLib::IMTSQLRowsetPtr aRowset)
{
	aRowset->ClearQuery();
	aRowset->SetQueryTag("__PROCESS_GROUP_DISCOUNT_FINAL__");
	OverrideTempTablePrefix(aRowset);

	aRowset->ExecuteConnected();
}



_bstr_t MTDiscountAdapter::ConstructInfoLabel(_bstr_t aDiscountName,
																							_bstr_t aDiscountDisplayName,
																							long aDiscountID,
																							long aNumCPDs)
{
	_bstr_t bstrReturn = L"\n/* Discount Name: ";
	bstrReturn += aDiscountName;
	bstrReturn += L"*/\n/* Discount Display Name: ";
	bstrReturn += aDiscountDisplayName;
	bstrReturn += L"*/\n/* Discount Template ID: ";
	bstrReturn += _bstr_t(aDiscountID);
	bstrReturn += L"*/\n/* Expected Number of Counters: ";
	bstrReturn += _bstr_t(aNumCPDs);
	bstrReturn += L"*/";

	return bstrReturn;
}

void TruncateTempTable(ROWSETLib::IMTSQLRowsetPtr aRowset, BOOL aDebugMode, BOOL aIsOracle)
{
	BOOL isOracle = (mtwcscasecmp(aRowset->GetDBType(), ORACLE_DATABASE_TYPE) == 0);

	aRowset->ClearQuery();
	aRowset->SetQueryTag("__TRUNCATE_DISCOUNT_TEMP_TABLES__");

	// OverrideTempTablePrefix(aRowset);
	if (aDebugMode && !aIsOracle)
		aRowset->AddParam("%%%TEMP_TABLE_PREFIX%%%", "");

	aRowset->Execute();
}

