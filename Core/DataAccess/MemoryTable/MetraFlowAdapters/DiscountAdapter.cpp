#include <metra.h>
#include <mtglobal_msg.h>
#include <formatdbvalue.h>
#include <DiscountAdapter.h>
#include <MSIX.h>
#include <MSIXDefinition.h>
#include <MSIXProperties.h>
#include <DataAccessDefs.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>

#include <vector>
#include <string>
#include <set>
#include <map>
#include <fstream>
#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bind.hpp>
#include <PlanInterpreter.h>
#include <AggregateExpression.h>

#import <MTNameIDLib.tlb>
#import <Counter.tlb> rename( "EOF", "RowsetEOF" )
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )

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


CounterBuilder::CounterBuilder(NTLogger & logger, long usageIntervalID, bool allBcr, bool runParallel, bool isDiscount)
  :
  mLogger(logger),
  mUsageIntervalID(usageIntervalID),
  mIsDiscount(isDiscount),
  mAllBcr(allBcr),
  mRunParallel(runParallel),
  mProductViews(NULL)
{
  mProductViews = new CProductViewCollection();
  mProductViews->Initialize();
}

CounterBuilder::~CounterBuilder()
{
  delete mProductViews;
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
      if (param->GetKind() == MTCOUNTERLib::PARAM_CONST)
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

      if (param->GetKind() == MTCOUNTERLib::PARAM_PRODUCT_VIEW_PROPERTY)
      {
        CMSIXDefinition * pvDef;
        if (FALSE==mProductViews->FindProductView((const wchar_t *) param->ProductViewName, pvDef))
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
        ASSERT(param->GetKind() == MTCOUNTERLib::PARAM_PRODUCT_VIEW);
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

std::wstring CounterBuilder::WriteUsage(const std::wstring& tempDir, std::map<std::wstring, std::wstring>& outputFiles)
{
  // For all discounts that support proportional shared group, store the
  // contributions of each account.
  std::wstring proportionalUnionAll(L"contributorUnionAll:union_all[];\n");
  boost::wformat proportionalUnionAllArrowFmt(L"contributorProj%1% -> contributorUnionAll(%2%);\n");
  std::wstring unionAll;
  boost::wformat unionAllFmt(L"u%1%:union_all[];\n");
  boost::wformat aggUnionAllArrowFmt(L"projectForMetering%1% -> u%2%(%3%);\n");

  // Index over all templates regardless of pi type.
  int j=0;
  // Metering
  boost::wformat fileFmt(L"%2%\\discount_adapter_%1%_%3%.mfd");
  boost::wformat meterFmt(
    L"file_write%1%:sequential_file_write[filename=\"%2%\\discount_adapter_%1%_%3%.mfd\"];\n"
    L"u%1% -> file_write%1%;\n");

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
    unionAll += (meterFmt % it->first->ID % tempDir % L"%1%").str();
    outputFiles[(const wchar_t *) it->first->Name] = (fileFmt % it->first->ID % tempDir % L"%1%").str();
  }

  proportionalUnionAll += 
    L"contributorInsert:insert[table=\"tmp_grp_disc_contrib\", createTable=true, schema=\"NetMeter\"];\n"
    L"contributorUnionAll->contributorInsert;\n";

  return unionAll + proportionalUnionAll;
}

bool DiscountAggregationScriptBuilder::AllCountersAreSet(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr& PIType,
                                                         MTPRODUCTCATALOGLib::IMTDiscountPtr& PI)
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
        return false;
			}

		}
    return true;
	}
	catch(_com_error&)
	{
        return false;
	}
}

DiscountAggregationScriptBuilder::DiscountAggregationScriptBuilder(NTLogger & logger, boost::int32_t usageIntervalID,
                                                                   bool singleDiscountMode,
                                                                   boost::int32_t singleTemplateID)
  :
  mCounterBuilder(NULL)
{
  // First figure out whether all instances are BCR.  This enables
  // important optimizations (primarily reading from a single DB partition).
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init("queries\\ProductCatalog");
  rowset->SetQueryTag(L"__DISCOUNT_INSTANCE_CYCLE_TYPE_SUMMARY__");
  rowset->Execute();
  if (0 == (long) rowset->GetValue(L"NumDiscountInstances")) 
    return;
  bool allBCR = (rowset->GetValue(L"NumDiscountInstances") == rowset->GetValue(L"NumBcrDiscountInstances"));
  rowset->Clear();

  bool hasInstances = false;
  // 
  // Generate the MetraFlowShell program for calculating discounts and metering.
  //
  mCounterBuilder = new CounterBuilder(logger, usageIntervalID, allBCR, true);
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
      bool bConfigurationComplete = AllCountersAreSet(PIType, PI);
      if(!bConfigurationComplete)
      {
        _bstr_t msg = 
          (boost::wformat(L"The discount template %1% is missing counters and is included in a product offering.  "
                          L"Skipping discount generation.") % PI->ID).str().c_str();
// 						mRunContext->RecordWarning(msg);
        logger.LogThis(LOG_WARNING, (const char *) msg);
// 						Error((const char *) msg);
// 						return MTPC_MISSING_COUNTER;
        continue;
      }

      if ((singleDiscountMode && (singleTemplateID == PI->ID) || !singleDiscountMode))
      {
        hasInstances = true;
        mCounterBuilder->Visit(PI, PIType);
      }
    }
  }
}

DiscountAggregationScriptBuilder::~DiscountAggregationScriptBuilder()
{
  delete mCounterBuilder;
}

CounterBuilder& DiscountAggregationScriptBuilder::GetCounterBuilder()
{
  return *mCounterBuilder;
}

std::wstring DiscountAggregationScriptBuilder::GetSubscriptionExtract(boost::int32_t usageIntervalID,
                                                                      boost::int32_t billingGroupID,
                                                                      boost::int32_t runID)
{
  QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
  mQueryAdapter->Init("queries\\ProductCatalog");
  mQueryAdapter->SetQueryTag(L"__METRAFLOW_SIMPLE_DISCOUNT_1__");
  mQueryAdapter->AddParam("%%ID_USAGE_INTERVAL%%", usageIntervalID);
  mQueryAdapter->AddParam("%%ID_BILLGROUP%%", billingGroupID);
  mQueryAdapter->AddParam("%%ID_RUN%%", runID);
  return (const wchar_t *) mQueryAdapter->GetRawSQLQuery(VARIANT_TRUE); 
}

std::wstring DiscountAggregationScriptBuilder::GetSubscriptionExtract(DATE startDate, DATE endDate)
{
  QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter(__uuidof(QUERYADAPTERLib::MTQueryAdapter));
  mQueryAdapter->SetQueryTag(L"__METRAFLOW_SCHEDULED_DISCOUNT_ADAPTER_1__");
  mQueryAdapter->AddParam("%%VT_START%%", _variant_t(startDate, VT_DATE));
  mQueryAdapter->AddParam("%%VT_END%%", _variant_t(endDate, VT_DATE));
  return (const wchar_t *) mQueryAdapter->GetRawSQLQuery(VARIANT_TRUE);
}
