#include "DatabaseMetering.h"
#include "DatabaseSelect.h"
#include "DatabaseInsert.h"
#include "HashAggregate.h"
#include "RecordParser.h"
#include "DesignTimeExpression.h"
#include "DatabaseCatalog.h"
#include "OperatorArg.h"

#include "MSIXDefinition.h"
#include "MSIXProperties.h"
#include "ServicesCollection.h"
#include "ProductViewCollection.h"

#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcPreparedBcpStatement.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"
#include "OdbcSessionTypeConversion.h"
#include "OdbcMetadata.h"
#include "OdbcColumnMetadata.h"
#include "OdbcStatement.h"

#include <set>
#include <ctime>
#include <stdexcept>
#include <boost/bind.hpp>
#include <boost/format.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/algorithm/string/trim.hpp>
#include <boost/algorithm/string/find.hpp>

#include "asio/ip/host_name.hpp"

#include "propids.h"
#import <MTEnumConfig.tlb>

static void GetAggregateServiceRecordMetadata(LogicalRecord& stagingMetadata, const std::set<std::wstring>& counters)
{
  stagingMetadata.push_back(L"id_source_sess", LogicalFieldType::Binary(false));
  stagingMetadata.push_back(L"id_parent_source_sess", LogicalFieldType::Binary(true));
  stagingMetadata.push_back(L"id_external", LogicalFieldType::Binary(true));
  stagingMetadata.push_back(L"c_ViewId", LogicalFieldType::Integer(true));
  stagingMetadata.push_back(L"c__PayingAccount", LogicalFieldType::Integer(false));
  stagingMetadata.push_back(L"c__AccountID", LogicalFieldType::Integer(false));
  stagingMetadata.push_back(L"c_CreationDate", LogicalFieldType::Datetime(false));
  stagingMetadata.push_back(L"c_SessionDate", LogicalFieldType::Datetime(false));
  stagingMetadata.push_back(L"c__PriceableItemTemplateID", LogicalFieldType::Integer(false));
  stagingMetadata.push_back(L"c__PriceableItemInstanceID", LogicalFieldType::Integer(true));
  stagingMetadata.push_back(L"c__ProductOfferingID", LogicalFieldType::Integer(true));
  stagingMetadata.push_back(L"c_BillingIntervalStart", LogicalFieldType::Datetime(false));
  stagingMetadata.push_back(L"c_BillingIntervalEnd", LogicalFieldType::Datetime(false));
  stagingMetadata.push_back(L"c_OriginalSessionTimestamp", LogicalFieldType::Datetime(false));

  /// TODO: Remove this is a hack to use a 4.0 database.
//   stagingMetadata.push_back(L"c__FirstPassID", LogicalFieldType::Integer(true));
  stagingMetadata.push_back(L"c__FirstPassID", LogicalFieldType::BigInteger(false));
  stagingMetadata.push_back(L"c__IntervalID", LogicalFieldType::Integer(true));
  stagingMetadata.push_back(L"c__TransactionCookie", LogicalFieldType::String(true));
  stagingMetadata.push_back(L"c__Resubmit", LogicalFieldType::Boolean(true));
  stagingMetadata.push_back(L"c__CollectionID", LogicalFieldType::Binary(true));

  for(std::set<std::wstring>::const_iterator it = counters.begin();
      it != counters.end();
      it++)
  {
    // TODO: Are counters always decimal????
    stagingMetadata.push_back(*it, LogicalFieldType::Decimal(true));
  }
}

Metering::Metering()
  :
  mStageOnly(false),
  mTargetMessageSize(5000),
  mTargetCommitSize(100000),
  mGenerateSummaryTable(true),
  mIsOutputPortNeeded(false),
  mIsAuthNeeded(false),
  mAreEnumsBeingUsed(true)
{
}

Metering::~Metering()
{
}

void Metering::SetIsOutputPortNeeded(bool isOutputPortNeeded)
{
  mIsOutputPortNeeded = isOutputPortNeeded;
}

void Metering::SetIsAuthNeeded(bool isNeeded)
{
  mIsAuthNeeded = isNeeded;
}

void Metering::handleArg(const OperatorArg& arg)
{
  // This method is never invoked.
  // Where as most operators in dataflow_generate.g
  // simply save their arguments for later processing
  // (through handleArg()), the Meter operator 
  // immediately processes its arguments.
  //
  handleCommonArg(arg);
}

Metering* Metering::clone(
                          const std::wstring& name,
                          std::vector<OperatorArg *>& args, 
                          int nInputs, int nOutputs) const
{
  // Metering is not really support for use inside composites.
  Metering* result = new Metering();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  ASSERT(0);

  return result;
}

bool Metering::GetStageOnly() const
{
  return mStageOnly;
}

void Metering::SetStageOnly(bool stageOnly)
{
  mStageOnly = stageOnly;
}

void Metering::SetParent(const std::wstring& parent)
{
  mParentService = parent;
}

void Metering::SetChildren(const std::vector<std::wstring>& children)
{
  mChildService = children;
}

void Metering::SetServices(const std::vector<std::wstring>& services)
{
  if (services.size() > 0)
  {
    mParentService = services[0];
    if (services.size() > 1)
      mChildService.assign(services.begin()+1,services.end());
  }
}

void Metering::SetParentKey(const std::wstring& parentKey)
{
  mParentKey = parentKey;
}

void Metering::SetChildKeys(const std::vector<std::wstring>& childKeys)
{
  mChildKeys = childKeys;
}

void Metering::SetKeys(const std::vector<std::wstring>& keys)
{
  if(keys.size() > 0)
  {
    mParentKey = keys[0];
    if (keys.size() > 1)
      mChildKeys.assign(keys.begin()+1,keys.end());
  }
}

void Metering::SetTargetMessageSize(boost::int32_t targetMessageSize)
{
  mTargetMessageSize = targetMessageSize;
}

void Metering::SetTargetCommitSize(boost::int32_t targetCommitSize)
{
  mTargetCommitSize = targetCommitSize;
}

void Metering::SetCollectionID(const std::vector<boost::uint8_t>& collectionID)
{
  mCollectionID = collectionID;
}

void Metering::SetGenerateSummaryTable(bool generateSummaryTable)
{
  mGenerateSummaryTable = generateSummaryTable;
}

void Metering::SetAreEnumsBeingUsed(bool areEnumsBeingUsed)
{
  mAreEnumsBeingUsed = areEnumsBeingUsed;
}

void Metering::GetSourceTargetMap(CMSIXDefinition* def,
                                  std::map<std::wstring,std::wstring>& sourceTargetMap)
{
  // Standard properies 1)
  sourceTargetMap[L"id_source_sess"] = L"id_source_sess";
  sourceTargetMap[L"id_parent_source_sess"] = L"id_parent_source_sess";
  sourceTargetMap[L"id_external"] = L"id_external";

  // Service Def specific properties
  MSIXPropertiesList::iterator Iter;
  for (Iter = def->GetMSIXPropertiesList().begin();
       Iter != def->GetMSIXPropertiesList().end();
       ++Iter)
  {
    CMSIXProperties *pProp = *Iter;
    sourceTargetMap[pProp->GetColumnName()] = pProp->GetColumnName();
  }
  
  // Standard properties 2)
  sourceTargetMap[L"c__IntervalID"] = L"c__IntervalID";
  sourceTargetMap[L"c__TransactionCookie"] = L"c__TransactionCookie";
  sourceTargetMap[L"c__Resubmit"] = L"c__Resubmit";
  sourceTargetMap[L"c__CollectionID"] = L"c__CollectionID";
}

void Metering::ApplyDefaults(DesignTimePlan& plan,
                             CMSIXDefinition* def,
                             boost::shared_ptr<Port> inputPort,
                             boost::shared_ptr<Port>& outputPort)
{
  // Apply any default properties that are configured
  std::wstring defaultDecls;
  std::wstring defaultStmts;
  MSIXPropertiesList::iterator Iter;
  for (Iter = def->GetMSIXPropertiesList().begin();
       Iter != def->GetMSIXPropertiesList().end();
       ++Iter)
  {
    CMSIXProperties *pProp = *Iter;
    if (pProp->GetDefault().size() > 0)
    {
      switch(pProp->GetPropertyType())
      {
      case CMSIXProperties::TYPE_WIDESTRING:
      case CMSIXProperties::TYPE_STRING:
        defaultDecls += (boost::wformat(L" @%1% NVARCHAR") % pProp->GetColumnName()).str();
        defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = N'%2%'\n") % pProp->GetColumnName() % pProp->GetDefault()).str();
        break;
      case CMSIXProperties::TYPE_INT32:
        defaultDecls += (boost::wformat(L" @%1% INTEGER") % pProp->GetColumnName()).str();
        defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = %2%\n") % pProp->GetColumnName() % pProp->GetDefault()).str();
        break;
      case CMSIXProperties::TYPE_INT64:
        defaultDecls += (boost::wformat(L" @%1% BIGINT") % pProp->GetColumnName()).str();
        defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = %2%LL\n") % pProp->GetColumnName() % pProp->GetDefault()).str();
        break;
      case CMSIXProperties::TYPE_TIMESTAMP:
      {
        // MSIXDEF and MTSQL use different date formats (ISO and OLE Variant).  Convert here.
        time_t iso;
        std::string ascDefault;
        ::WideStringToUTF8(pProp->GetDefault(), ascDefault);
        if (!::MTParseISOTime(ascDefault.c_str(), &iso))
          throw std::logic_error((boost::format("Invalid format for DATE default value: %1%") % ascDefault).str());
        DATE oleDate;
        ::OleDateFromTimet(&oleDate, iso);
        BSTR bstrVal;
        HRESULT hr = ::VarBstrFromDate(oleDate, LOCALE_SYSTEM_DEFAULT, 0, &bstrVal);
        if(FAILED(hr)) 
          throw std::logic_error((boost::format("COM Error: HRESULT = 0x%x;") % hr).str());
        // Use a _bstr_t to delete the BSTR
        _bstr_t bstrtVal(bstrVal);

        defaultDecls += (boost::wformat(L" @%1% DATETIME") % pProp->GetColumnName()).str();
        defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = CAST('%2%' AS DATETIME)\n") % pProp->GetColumnName() % bstrVal).str();
        break;
      }
      case CMSIXProperties::TYPE_FLOAT:
      case CMSIXProperties::TYPE_DOUBLE:
      case CMSIXProperties::TYPE_NUMERIC:
      case CMSIXProperties::TYPE_DECIMAL:
      {
        std::wstring trimmed(boost::algorithm::trim_left_copy(boost::algorithm::trim_right_copy(pProp->GetDefault())));
        // Get around lack of casting in MTSQL by appending a trailing decimal point if we have been given an integer.
        if (!boost::algorithm::find_first(trimmed, "."))
          trimmed += L".0";

        defaultDecls += (boost::wformat(L" @%1% DECIMAL") % pProp->GetColumnName()).str();
        defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = %2%\n") % pProp->GetColumnName() % trimmed).str();
        break;
      }
      case CMSIXProperties::TYPE_ENUM:
      {
        MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);

        // enum ID must be calculated
        long enumId = enumConfig->GetID(pProp->GetEnumNamespace().c_str(), 
                                        pProp->GetEnumEnumeration().c_str(), 
                                        pProp->GetDefault().c_str());

        // Sometimes, enum properties will be arrive into MetraFlow as datatype integer
        // rather than datatype enum. In this case, the meter operator argument
        // areEnumsBeingUsed should be set to false. This case occurs when import_queue
        // is being used to receive the data.  Import_queue uses DataSets which support
        // the base datatype integer but not the datatype enum.  The PipelineMeterHelper
        // C# class uses this approach.
        if (mAreEnumsBeingUsed)
        {
          defaultDecls += (boost::wformat(L" @%1% ENUM") % pProp->GetColumnName()).str();
          defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = CAST(%2% AS ENUM)\n") % pProp->GetColumnName() % enumId).str();
        }
        else
        {
          defaultDecls += (boost::wformat(L" @%1% INTEGER") % pProp->GetColumnName()).str();
          defaultStmts += (boost::wformat(
                           L"IF @%1% IS NULL\n"
                           L"SET @%1% = %2%\n") % pProp->GetColumnName() % enumId).str();
        }

        break;
      }
      case CMSIXProperties::TYPE_BOOLEAN:
      {
        std::wstring strDefault = pProp->GetDefault();
        
        // Add some flexibility on what the default may be.
        if (boost::algorithm::iequals(strDefault.c_str(), L"true"))
        {
            strDefault = L"T";
        }

        if (boost::algorithm::iequals(strDefault.c_str(), L"false"))
        {
            strDefault = L"F";
        }

        if (strDefault.size() !=  1)
        {
          std::string ascDefault;
          ::WideStringToUTF8(pProp->GetDefault(), ascDefault);
          throw std::logic_error((boost::format("Invalid format for BOOLEAN default value: %1%") % ascDefault).str());
        }

        // conforms strictly to the MSIX specification [tTfF]
        defaultDecls += (boost::wformat(L" @%1% BOOLEAN") % pProp->GetColumnName()).str();
        switch(strDefault[0]) 
        {
        case L'T': case L't':
          defaultStmts += (boost::wformat(
                             L"IF @%1% IS NULL\n"
                             L"SET @%1% = TRUE\n") % pProp->GetColumnName()).str();
          break;
        case L'F':	case L'f':
          defaultStmts += (boost::wformat(
                             L"IF @%1% IS NULL\n"
                             L"SET @%1% = FALSE\n") % pProp->GetColumnName()).str();
          break;
        default:
        {
          std::string ascDefault;
          ::WideStringToUTF8(pProp->GetDefault(), ascDefault);
          throw std::logic_error((boost::format("Invalid format for BOOLEAN default value: %1%") % ascDefault).str());
        }
        }
        break;
      }
      case CMSIXProperties::TYPE_TIME:
      default:
      {
        throw std::runtime_error((boost::format("Default value unsupported on type %1%") % pProp->GetPropertyType()).str());
      }
      }
    }
  }

  if (defaultDecls.size() > 0)
  {
    ASSERT(defaultStmts.size() > 0);

    // applyDefaultsExpr: expr[];
    DesignTimeExpression * applyDefaultsExpr = new DesignTimeExpression();
    plan.push_back(applyDefaultsExpr);
    applyDefaultsExpr->SetName((boost::wformat(L"applyDefaultsExpr(%1%)") % def->GetTableName()).str());
    std::wstring p = (boost::wformat(L"CREATE PROCEDURE applyDefaults %1%\n"
                                     L"AS\n%2%") % defaultDecls % defaultStmts).str();
    
    std::string programStr;
    ::WideStringToUTF8(p, programStr);
    MetraFlowLoggerManager::GetLogger("Meter")->logDebug(p);

    applyDefaultsExpr->SetProgram(p);

    // meteringSessionSetBuilder(i) -> applyDefaultExpr;
    plan.push_back(new DesignTimeChannel(inputPort, 
                                         applyDefaultsExpr->GetInputPorts()[0]));
    outputPort = applyDefaultsExpr->GetOutputPorts()[0];
  }
  else
  {
    outputPort = inputPort;
  }
}

void Metering::InsertIntoSvcTable(DesignTimePlan& plan,
                                  CServicesCollection& coll,
                                  const std::wstring& svc,
                                  boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase,
                                  bool isRoot,
                                  boost::shared_ptr<Port> inputPort,
                                  boost::shared_ptr<Port>& svcOutputPort,
                                  boost::shared_ptr<Port>& sessionOutputPort)
{
  CMSIXDefinition * def;
  if (FALSE==coll.FindService(svc, def))
  {
    throw std::exception("Couldn't find service definition");
  }
  def->CalculateTableName(L"t_svc_");

  // Set default values if needed.
  ApplyDefaults(plan, def, inputPort, inputPort);
  
  // copy: copy[]
  DesignTimeCopy * copy = new DesignTimeCopy(2);
  plan.push_back(copy);
  copy->SetName((boost::wformat(L"copy(%1%)") % def->GetTableName()).str());

  // meteringSessionSetBuilder(i) -> copy;
  plan.push_back(new DesignTimeChannel(inputPort, 
                                       copy->GetInputPorts()[0]));

  // Now process each stream into t_svc_*
  std::map<std::wstring,std::wstring> sourceTargetMap;
  GetSourceTargetMap(def, sourceTargetMap);

  // insert: insert[];
  DesignTimeDatabaseInsert * insert = new DesignTimeDatabaseInsert();
  plan.push_back(insert);
  insert->SetName((boost::wformat(L"insert(%1%)") % def->GetTableName()).str());
  insert->SetSourceTargetMap(sourceTargetMap);
  std::map<std::wstring,std::wstring>::const_iterator it=stagingDatabase->GetTableMap().find(def->GetTableName());
  insert->SetTableName(it == stagingDatabase->GetTableMap().end() ? def->GetTableName() : it->second);
  insert->SetBatchSize(COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle() ? 1000 : 10000);
  insert->SetSortHint(L"id_source_sess");
  if (!mStageOnly)
  {
    insert->SetStreamingTransactionKey(L"id_commit_unit");
  }

  // copy(0) -> insert;
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0], 
                                       insert->GetInputPorts()[0]));
  
  if (mStageOnly)
  {
    svcOutputPort = boost::shared_ptr<Port>();
  }
  else
  {
    svcOutputPort = insert->GetOutputPorts()[0];
  }

  // insertSession: insert[];
  DesignTimeDatabaseInsert * insertSession = new DesignTimeDatabaseInsert();
  plan.push_back(insertSession);
  insertSession->SetName((boost::wformat(L"insertSession(%1%)") % def->GetTableName()).str());
  std::map<std::wstring, std::wstring> insertSessionSourceTargetMap;
  insertSessionSourceTargetMap[L"id_source_sess"]  = L"id_source_sess";
  insertSessionSourceTargetMap[L"id_ss"]  = L"id_ss";
  insertSession->SetSourceTargetMap(insertSessionSourceTargetMap);
  it=stagingDatabase->GetSessionTableMap().find(def->GetTableName());
  insertSession->SetTableName(it == stagingDatabase->GetSessionTableMap().end() ? L"t_session" : it->second);
  insertSession->SetBatchSize(COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle() ? 1000 : 10000);
  insertSession->SetSortHint(L"id_source_sess");
  if (!mStageOnly)
  {
    insertSession->SetStreamingTransactionKey(L"id_commit_unit");
  }

  // copy(1) -> insertSession;
  plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], 
                                       insertSession->GetInputPorts()[0]));

  if (mStageOnly)
  {
    sessionOutputPort = boost::shared_ptr<Port>();
  }
  else
  {
    sessionOutputPort = insertSession->GetOutputPorts()[0];
  }
//   outputPort = project->GetOutputPorts()[0];
}

void Metering::Generate(DesignTimePlan & plan, 
                        boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase)
{
  CServicesCollection coll;
  coll.Initialize();
  Generate(coll, plan, stagingDatabase);
}

void Metering::Generate(CServicesCollection& coll, DesignTimePlan & plan, 
                        boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase)
{
  // Sanity check.  Current we don't require this as we have default key assumptions (id_sess, id_parent_sess).
  //   if (mChildService.size() > 0 && mChildKeys.size() != mChildService.size())
  //     throw std::logic_error("when metering compound sessions, keys for each service must be specified");

  // Are we staging only with external install or are we streaming install?
  mStageOnly = stagingDatabase->GetStagingMethod() != DatabaseMeteringStagingDatabase::STREAMING;

  // meteringSessionSetBuilder: sessionSetBuilder[]
  //
  // The first operator is the id generator. Place all of inputs into our port collection.
  DesignTimeSessionSetBuilder * ss = new DesignTimeSessionSetBuilder(mChildService.size(),       
                                                                     mTargetMessageSize, mTargetCommitSize);
  ss->SetName(L"meteringSessionSetBuilder");
  ss->SetCollectionID(mCollectionID);

  if (mParentKey.size() > 0)
    ss->SetParentKey(mParentKey);

  if (mChildKeys.size() > 0)
    ss->SetChildKeys(mChildKeys);

  plan.push_back(ss);

  ASSERT(ss->GetInputPorts().size() == 1+mChildService.size());
  ASSERT(ss->GetOutputPorts().size() == 2*(1+mChildService.size()) + 2);

  // Here we are adding input ports to the meter operator.
  // But the input ports are really the input ports of
  // the meteringSessionSetBuilder.  The meter operator isn't
  // every going to part of the plan.  By sticking these input port
  // references into meter, the arrow statements will be wired
  // up to meteringSessionSetBuilder instead.
  for(PortCollection::iterator ssit = ss->GetInputPorts().begin();
      ssit != ss->GetInputPorts().end();
      ++ssit)
  {
    mInputPorts.push_back(*ssit);
  }
  
  // Handle the parent
  std::vector<boost::shared_ptr<Port> > svcOutputPorts(1+mChildService.size());
  std::vector<boost::shared_ptr<Port> > sessionOutputPorts(1+mChildService.size());
  InsertIntoSvcTable(plan, 
                     coll,
                     mParentService,
                     stagingDatabase,
                     true,
                     ss->GetOutputPorts()[0],  // meteringSessionSetBuilder(0) ->
                     svcOutputPorts[0],
                     sessionOutputPorts[0]);

  // Handle the children, if any
  //
  // For each output of the session set builder, insert into t_svc_*
  // and t_session.
  for(std::size_t i = 1; i < ss->GetInputPorts().size(); i++)
  { 
    InsertIntoSvcTable(plan,
                       coll,
                       mChildService[i-1],
                       stagingDatabase,
                       false,
                       ss->GetOutputPorts()[i],  // meteringSessionSetBuilder(i) ->
                       svcOutputPorts[i],
                       sessionOutputPorts[i]);
  }

  // sessionSetSortMerge: SortMerge[key="id_message"];
  //
  // Process session set summaries off the sesssion set builder.
  DesignTimeSortMerge * sessionSetUnionAll = new DesignTimeSortMerge(mChildService.size() + 1);
  plan.push_back(sessionSetUnionAll);
  sessionSetUnionAll->SetName(L"sessionSetSortMerge");
  sessionSetUnionAll->AddSortKey(DesignTimeSortKey(L"id_message", SortOrder::ASCENDING));

  for(std::size_t i = 0; i < ss->GetInputPorts().size(); i++)
  { 
    // Stick in id_svc and b_root properties.
    CMSIXDefinition * def;
    if (FALSE==coll.FindService(i==0 ? mParentService : mChildService[i-1], def))
    {
      throw std::exception("Couldn't find service definition");
    }

    int id_svc = def->GetID();
    std::wstring b_root = i==0 ? L"TRUE" : L"FALSE";

    // setServiceAndRoot<i>: expr[];
    DesignTimeExpression * expr = new DesignTimeExpression();
    plan.push_back(expr);
    expr->SetName((boost::wformat(L"setServiceAndRoot(%1%)") % def->GetTableName()).str());
    expr->SetProgram(
      (boost::wformat(L"CREATE PROCEDURE expr @id_svc INTEGER OUTPUT @b_root BOOLEAN OUTPUT\n"
                      L"AS\n"
                      L"SET @id_svc = %1%\n"
                      L"SET @b_root = %2%\n")
       % id_svc % b_root).str());

    // meteringSessionSetBuilder(#) -> setServiceAndRoot<i>
    plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[ss->GetInputPorts().size() + i], 
                                         expr->GetInputPorts()[0]));

    // setServiceAndRoot<i> -> sessionSetSortMerge
    plan.push_back(new DesignTimeChannel(expr->GetOutputPorts()[0], 
                                         sessionSetUnionAll->GetInputPorts()[i]));
  }
      
  // filterEmptySessionSet: filter[]
  //
  // Filter out empty session sets.
  DesignTimeFilter * filter = new DesignTimeFilter();
  filter->SetName(L"filterEmptySessionSet");
  filter->SetProgram(
    L"CREATE FUNCTION filter (@size INTEGER) RETURNS BOOLEAN\n"
    L"AS\n"
    L"RETURN @size > 0");
  plan.push_back(filter);

  // sessionSetSortMerge -> filterEmptySessionSet
  plan.push_back(new DesignTimeChannel(sessionSetUnionAll->GetOutputPorts()[0], 
                                       filter->GetInputPorts()[0]));

  // insertSessionSet: insert[] 
  DesignTimeDatabaseInsert * insertSessionSet = new DesignTimeDatabaseInsert();
  plan.push_back(insertSessionSet);
  insertSessionSet->SetName(L"insertSessionSet");
  std::map<std::wstring, std::wstring> insertSessionSetSourceTargetMap;
  insertSessionSetSourceTargetMap[L"id_message"]  = L"id_message";
  insertSessionSetSourceTargetMap[L"id_ss"]  = L"id_ss";
  insertSessionSetSourceTargetMap[L"id_svc"]  = L"id_svc";
  insertSessionSetSourceTargetMap[L"b_root"]  = L"b_root";
  insertSessionSetSourceTargetMap[L"size"]  = L"session_count";
  insertSessionSet->SetSourceTargetMap(insertSessionSetSourceTargetMap);
  std::map<std::wstring, std::wstring>::const_iterator it=stagingDatabase->GetTableMap().find(L"t_session_set");
  insertSessionSet->SetTableName(it == stagingDatabase->GetTableMap().end() ? L"t_session_set" : it->second);
  insertSessionSet->SetBatchSize(1000);
  if (!mStageOnly)
  {
    insertSessionSet->SetStreamingTransactionKey(L"id_commit_unit");
  }

  // filterEmptySessionSet -> insertSessionSet
  plan.push_back(new DesignTimeChannel(filter->GetOutputPorts()[0], 
                                       insertSessionSet->GetInputPorts()[0]));

  // messageExpr: expr[];
  DesignTimeExpression * messageExpr = new DesignTimeExpression();
  plan.push_back(messageExpr);
  messageExpr->SetName(L"messageExpr");
  messageExpr->SetProgram(
    L"CREATE PROCEDURE expr @dt_crt DATETIME OUTPUT @dt_metered DATETIME OUTPUT\n"
    L"@tx_ip_address VARCHAR OUTPUT\n"
    L"AS\n"
    L"DECLARE @now DATETIME\n"
    L"SET @now = getutcdate()\n"
    L"SET @dt_crt = @now\n"
    L"SET @dt_metered = @now\n"
    L"SET @tx_ip_address = '127.0.0.1'\n"
    );

  // If the metering operator DOES NOT need to write authorization data
  // then we simply flow from insertSessionSet("messageSummary") to
  // messageExpr:
  //
  //     insertSessionSet -> messageExpr -> insert
  //
  // If the metering operator DOES need to write authorization data
  // to the t_message table, then there will be an additional input
  // port. We will take this authorization input which is a single row,
  // and join it will all rows coming from insertSessionSet("messageSummary").
  //
  //     authorization input -> authJoinIdExpr -> 
  //                                            join -> messageExpr -> insert
  //     insertSessionSet -> insertJoinIdExpr  ->
  //
  // To accomplish the join, we add a join id column to both tables.
  // We also need to correct the type and names of the authorization
  // variables (values coming from inputQueues are NVARCHAR and we need VARCHAR).
  
  if (mIsAuthNeeded)
  {
    // authJoinIdExpr: expr[];

    // We are going to take the authorization input
    // and add a join id column to it.  This will
    // help us to join the authorization data
    // to the t_message columns. We are also correcting
    // variable names and types.
    
    DesignTimeExpression *authJoinIdExpr;
    authJoinIdExpr = new DesignTimeExpression();
    authJoinIdExpr->SetName(L"authJoinIdExpr");
    if (mIsAuthNeeded)
    {
      authJoinIdExpr->SetProgram(
        L"CREATE PROCEDURE addJoinID "
        L"@username         NVARCHAR\n"
        L"@namespace        NVARCHAR\n"
        L"@password         NVARCHAR\n"
        L"@serialized       NVARCHAR\n"
        L"@auth_join_id     INTEGER OUTPUT\n"
        L"@tx_sc_username   VARCHAR OUTPUT\n"
        L"@tx_sc_namespace  VARCHAR OUTPUT\n"
        L"@tx_sc_password   VARCHAR OUTPUT\n"
        L"@tx_sc_serialized VARCHAR OUTPUT\n"
        L"AS\n"
        L"SET @auth_join_id = 1\n"
        L"SET @tx_sc_username  = CAST(@username AS VARCHAR)\n"
        L"SET @tx_sc_namespace = CAST(@namespace AS VARCHAR)\n"
        L"SET @tx_sc_password  = CAST(@password AS VARCHAR)\n"
        L"SET @tx_sc_serialized= CAST(@serialized AS VARCHAR)\n"
      );
    }

    plan.push_back(authJoinIdExpr);

    // We need to add an input port to the meter operator for this
    // authorization information.  Notice that this port comes after all other
    // ports (the parent service definition, followed by
    // any children definitions).  The input port is really the input
    // port of the authJoinIdExpr operator.
    for(PortCollection::iterator exprIt = authJoinIdExpr->GetInputPorts().begin();
        exprIt != authJoinIdExpr->GetInputPorts().end(); ++exprIt)
    {
      mInputPorts.push_back(*exprIt);
    }

    // insertJoinIdExpr: expr[];

    // We are going and add a join id column to insertSessionSet output
    // to help us to join the authorization data
    // to the t_message columns.
    DesignTimeExpression *insertJoinIdExpr;
    insertJoinIdExpr = new DesignTimeExpression();
    insertJoinIdExpr->SetName(L"insertJoinIdExpr");
    insertJoinIdExpr->SetProgram(
      L"CREATE PROCEDURE addJoinID "
      L"@insert_join_id  INTEGER OUTPUT\n"
      L"AS\n"
      L"SET @insert_join_id = 1\n"
    );
    plan.push_back(insertJoinIdExpr);

    // insertSessionSet("messageSummary") -> insertJoinIdExpr
    plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2*ss->GetInputPorts().size()], 
                                         insertJoinIdExpr->GetInputPorts()[0]));

    // authJoin: inner_merge_join[];
    DesignTimeSortMergeJoin *authJoin = new DesignTimeSortMergeJoin();
    authJoin->AddLeftEquiJoinKey(DesignTimeSortKey(L"auth_join_id", SortOrder::ASCENDING));
    authJoin->AddRightEquiJoinKey(DesignTimeSortKey(L"insert_join_id", SortOrder::ASCENDING));
    plan.push_back(authJoin);

    // authJoinIdExpr -> authJoin(left)
    plan.push_back(new DesignTimeChannel(authJoinIdExpr->GetOutputPorts()[0], 
                                         authJoin->GetInputPorts()[0]));
    
    // insertJoinIdExpr -> authJoin(right)
    plan.push_back(new DesignTimeChannel(insertJoinIdExpr->GetOutputPorts()[0], 
                                         authJoin->GetInputPorts()[1]));

    // authJoin -> messageExpr
    plan.push_back(new DesignTimeChannel(authJoin->GetOutputPorts()[0], 
                                         messageExpr->GetInputPorts()[0]));
  }
  else
  {
    // insertSessionSet("messageSummary") -> messageExpr
    plan.push_back(new DesignTimeChannel(ss->GetOutputPorts()[2*ss->GetInputPorts().size()], 
                                         messageExpr->GetInputPorts()[0]));
  }

  // insertMessage operator
  DesignTimeDatabaseInsert * insertMessage = new DesignTimeDatabaseInsert();
  insertMessage->SetName(L"insertMessage");
  plan.push_back(insertMessage);
  std::map<std::wstring, std::wstring> insertMessageSourceTargetMap;
  insertMessageSourceTargetMap[L"id_message"]  = L"id_message";
  insertMessageSourceTargetMap[L"dt_crt"] = L"dt_crt";
  insertMessageSourceTargetMap[L"dt_metered"] = L"dt_metered";
  insertMessageSourceTargetMap[L"tx_ip_address"] = L"tx_ip_address";
  insertMessageSourceTargetMap[L"tx_sc_username"] = L"tx_sc_username";
  insertMessageSourceTargetMap[L"tx_sc_namespace"] = L"tx_sc_namespace";
  insertMessageSourceTargetMap[L"tx_sc_password"] = L"tx_sc_password";
  insertMessageSourceTargetMap[L"tx_sc_serialized"] = L"tx_sc_serialized";
  insertMessage->SetSourceTargetMap(insertMessageSourceTargetMap);
  it=stagingDatabase->GetTableMap().find(L"t_message");
  insertMessage->SetTableName(it == stagingDatabase->GetTableMap().end() ? L"t_message" : it->second);
  insertMessage->SetBatchSize(1000);
  if (!mStageOnly)
  {
    insertMessage->SetStreamingTransactionKey(L"id_commit_unit");
  }

  if (!mIsOutputPortNeeded)
  {
    // expr -> insertMessage
    plan.push_back(new DesignTimeChannel(messageExpr->GetOutputPorts()[0], 
                                         insertMessage->GetInputPorts()[0]));
  }
  else
  {
    // copy operator - we are branching so that meter can have an output port
    DesignTimeCopy * copyBeforeInsert= new DesignTimeCopy(2);
    copyBeforeInsert->SetName(L"copyBeforeInsert");
    plan.push_back(copyBeforeInsert);

    // expr -> copy
    plan.push_back(new DesignTimeChannel(messageExpr->GetOutputPorts()[0], 
                                         copyBeforeInsert->GetInputPorts()[0]));

    // copy -> insert
    plan.push_back(new DesignTimeChannel(copyBeforeInsert->GetOutputPorts()[0], 
                                         insertMessage->GetInputPorts()[0]));

    // give the meter operator an output port (that is the copy's output port)
    mOutputPorts.push_back(copyBeforeInsert->GetOutputPorts()[1]);

  }

  // If we are not doing streamed commits then cap off the summary output
  // of the session set builder, otherwise feed this transaction summary
  // into the control port of the installer.
  if (mStageOnly)
  {
    DesignTimeDevNull * sessionSetSummaryDevNull = new DesignTimeDevNull();
    sessionSetSummaryDevNull->SetName(L"sessionSetSummaryDevNull");
    plan.push_back(sessionSetSummaryDevNull);
    plan.push_back(new DesignTimeChannel(ss->GetOutputPorts().back(),
                                         sessionSetSummaryDevNull->GetInputPorts()[0]));
  }
  else
  {
    // Feed into the transactional installer.  We feed the installer in the
    // order: parent svc, child svcs, parent session, child sessions, session set, message.
    // Both the control record and the inputs to the installer need to be in sync with
    // respect to this ordering.

    // We also have to solve the problem of communicating the number of records written
    // in the case of aggregate rating.  For the moment, I write transaction summaries into a table.
    // The aggregate rating code can summarize to get the info.
    // For all of these channels, we turn off buffering to maximize pipelining.
    DesignTimeCopy * copy = new DesignTimeCopy(2);
    copy->SetName(L"transactionSummaryCopy");
    plan.push_back(copy);
    plan.push_back(new DesignTimeChannel(ss->GetOutputPorts().back(),    
                                         copy->GetInputPorts()[0],
                                         false));

    DesignTimeNondeterministicCollector * transactionSummaryColl = new DesignTimeNondeterministicCollector();
    transactionSummaryColl->SetName(L"transactionSummaryColl");
    transactionSummaryColl->SetMode(DesignTimeOperator::SEQUENTIAL);
    plan.push_back(transactionSummaryColl);
    plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[1], 
                                         transactionSummaryColl->GetInputPorts()[0]));


    if (mGenerateSummaryTable)
    {
      DesignTimeDatabaseInsert * transactionSummaryLog = new DesignTimeDatabaseInsert();
      transactionSummaryLog->SetName(L"transactionSummaryLog");
      transactionSummaryLog->SetTableName(L"tmp_meter_summary_log");
      transactionSummaryLog->SetCreateTable(true);
      transactionSummaryLog->SetBatchSize(1);
      transactionSummaryLog->SetMode(DesignTimeOperator::SEQUENTIAL);
      plan.push_back(transactionSummaryLog);
      plan.push_back(new DesignTimeChannel(transactionSummaryColl->GetOutputPorts()[0],
                                           transactionSummaryLog->GetInputPorts()[0],
                                           false));
    }
    else
    {
      DesignTimeDevNull * transactionSummaryDevNull = new DesignTimeDevNull();
      transactionSummaryDevNull->SetName(L"transactionSummaryDevNull");
      transactionSummaryDevNull->SetMode(DesignTimeOperator::SEQUENTIAL);
      plan.push_back(transactionSummaryDevNull);
      plan.push_back(new DesignTimeChannel(transactionSummaryColl->GetOutputPorts()[0],
                                           transactionSummaryDevNull->GetInputPorts()[0],
                                           false));
    }

    // The transaction summary only contains sizes for the svc tables (refered to as parent svc and child svc above).
    // Create the rest.  The code depends on the number of children so we dynamically generate
    // the MTSQL that performs it.  For example with 1 parent and 2 children we have:
    // CREATE PROCEDURE blah @size_0 INTEGER @size_1 INTEGER @size_2 INTEGER @size_3 INTEGER OUTPUT @size_4 INTEGER OUTPUT
    // @size_5 INTEGER OUTPUT @size_6 INTEGER OUTPUT  @size_7 INTEGER OUTPUT
    // AS
    // /* Copy the service entries to session entries */
    // SET @size_3 = @size_0
    // SET @size_4 = @size_1
    // SET @size_5 = @size_2
    // /* Calculate the number of session sets */
    // SET @size_6 = CASE WHEN @size_0 > 0 THEN 1 ELSE 0 END + 
    // CASE WHEN @size_1 > 0 THEN 1 ELSE 0 END + 
    // CASE WHEN @size_2 > 0 THEN 1 ELSE 0 END 
    // /* TODO: have the builder actually calculate the number of messages (applies to the session set calc to!).
    // SET @size_7 = 1
    DesignTimeExpression * calculateSessionSize = new DesignTimeExpression();
    calculateSessionSize->SetName(L"calculateSessionSize");
    boost::wformat inputDecl(L"@size_%1% INTEGER\n");
    boost::wformat outputDecl(L"@size_%1% INTEGER OUTPUT\n");
    boost::wformat setStatement(L"SET @size_%1% = @size_%2%\n");
    std::wstring program(L"CREATE PROCEDURE calculateSessionSize ");
    for(std::size_t i=0; i<1+mChildService.size(); i++)
    {
      program += (inputDecl % i).str();
    }
    for(std::size_t i=0; i<3+mChildService.size(); i++)
    {
      program += (outputDecl % (i+mChildService.size()+1)).str();
    }
    program += L"AS\n";
    for(std::size_t i=0; i<1+mChildService.size(); i++)
    {
      program += (setStatement % (i+mChildService.size()+1) % i).str();
    }
    program += (boost::wformat(L"SET @size_%1% = CASE WHEN @size_0 > 0 THEN 1 ELSE 0 END\n") % (2*mChildService.size() + 2)).str();
    for(std::size_t i=1; i<1+mChildService.size(); i++)
    {
      program += (boost::wformat(L" + CASE WHEN @size_%1% > 0 THEN 1 ELSE 0 END\n") % i).str();
    }
    program += (boost::wformat(L"SET @size_%1% = 1\n") % (2*mChildService.size() + 3)).str();
    calculateSessionSize->SetProgram(program);
    plan.push_back(calculateSessionSize);
    plan.push_back(new DesignTimeChannel(copy->GetOutputPorts()[0],
                                         calculateSessionSize->GetInputPorts()[0],
                                         false));
    
    DesignTimeTransactionalInstall * install = new DesignTimeTransactionalInstall(2*mChildService.size() + 4);
    // We have no pretransaction work.
    std::vector<std::vector<std::wstring> > preTransactionQueries(2*mChildService.size() + 4, 
                                                                  std::vector<std::wstring>());
    // We install from staging during the transaction.
    std::vector<std::vector<std::wstring> > queries;
    ASSERT(stagingDatabase->GetParameterizedInstallQueries().size() == 2*(1+mChildService.size()) + 2);
    for(std::vector<std::wstring>::const_iterator it = stagingDatabase->GetParameterizedInstallQueries().begin();
        it != stagingDatabase->GetParameterizedInstallQueries().end();
        ++it)
    {
      queries.push_back(std::vector<std::wstring> (1, *it));
    }
    // After the transaction we drop from staging.
    DatabaseCommands cmds;
    std::wstring dropFromStaging(cmds.DropStagingTable(L"%1%"));
    std::vector<std::vector<std::wstring> > postTransactionQueries(2*mChildService.size() + 4, 
                                                                   std::vector<std::wstring>(1, dropFromStaging));
    
    install->SetPreTransactionQueries(preTransactionQueries);
    install->SetQueries(queries);
    install->SetPostTransactionQueries(postTransactionQueries);
    plan.push_back(install);
    plan.push_back(new DesignTimeChannel(calculateSessionSize->GetOutputPorts()[0],
                                         install->GetInputPorts()[L"control"],
                                         false));

    boost::wformat inputFormat(L"input(%1%)");
    for(std::size_t i=0; i<1+mChildService.size(); i++)
    {
      plan.push_back(new DesignTimeChannel(svcOutputPorts[i],
                                           install->GetInputPorts()[(inputFormat % i).str()],
                                           false));      
    }
    for(std::size_t i=0; i<1+mChildService.size(); i++)
    {
      plan.push_back(new DesignTimeChannel(sessionOutputPorts[i],
                                           install->GetInputPorts()[(inputFormat % (i+1+mChildService.size())).str()],
                                           false));      
    }
    plan.push_back(new DesignTimeChannel(insertSessionSet->GetOutputPorts()[0],
                                         install->GetInputPorts()[(inputFormat % (2*mChildService.size()+2)).str()],
                                         false));      
    plan.push_back(new DesignTimeChannel(insertMessage->GetOutputPorts()[0],
                                         install->GetInputPorts()[(inputFormat % (2*mChildService.size()+3)).str()], 
                                         false));      
  }
}

static PhysicalFieldType Convert(const CMSIXProperties * pt)
{
	switch(pt->GetPropertyType())
	{
	case CMSIXProperties::TYPE_WIDESTRING:
	case CMSIXProperties::TYPE_STRING:
		return PhysicalFieldType::StringDomain();
	case CMSIXProperties::TYPE_INT32:
		return PhysicalFieldType::Integer();
	case CMSIXProperties::TYPE_INT64:
		return PhysicalFieldType::BigInteger();
	case CMSIXProperties::TYPE_TIMESTAMP:
		return PhysicalFieldType::Datetime();
	case CMSIXProperties::TYPE_FLOAT:
	case CMSIXProperties::TYPE_DOUBLE:
	case CMSIXProperties::TYPE_NUMERIC:
	case CMSIXProperties::TYPE_DECIMAL:
		return PhysicalFieldType::Decimal();
	case CMSIXProperties::TYPE_ENUM:
		return PhysicalFieldType::Enum();
	case CMSIXProperties::TYPE_BOOLEAN:
		return PhysicalFieldType::Boolean();
	case CMSIXProperties::TYPE_TIME:
		return PhysicalFieldType::Datetime();
	default:
	{
    ASSERT(FALSE);
		return PhysicalFieldType::StringDomain();
  }
	}
}

AggregateMetering::AggregateMetering()
{
}

AggregateMetering::AggregateMetering(const std::vector<std::set<std::wstring> >& v)
{
  SetCounters(v);
}

AggregateMetering::~AggregateMetering()
{
}

void AggregateMetering::SetParentCounters(const std::set<std::wstring>& parentCounters)
{
  mParentCounters=parentCounters;
}

void AggregateMetering::SetChildCounters(const std::vector<std::set<std::wstring> >& childCounters)
{
  mChildCounters=childCounters;
}

void AggregateMetering::SetCounters(const std::vector<std::set<std::wstring> >& v)
{
  mParentCounters = v[0];
  if(v.size() > 1) mChildCounters.assign(v.begin()+1,v.end());
}

const std::set<std::wstring>& AggregateMetering::FindCounters(CMSIXDefinition* def)
{
  if (0 == _wcsicmp(mParentService.c_str(), def->GetName().c_str()))
    return mParentCounters;

  for(std::vector<std::wstring>::const_iterator it = mChildService.begin();
      it != mChildService.end();
      it++)
  {
    if (0 == _wcsicmp(it->c_str(), def->GetName().c_str()))
      return mChildCounters[it - mChildService.begin()];
  }

  throw std::exception("Counters for service definition not found");
}

void AggregateMetering::GetSourceTargetMap(CMSIXDefinition* def,
                                           std::map<std::wstring,std::wstring>& sourceTargetMap)
{
  // Get the counters for this service definition and use the
  // standard aggregate properties + counters.
  const std::set<std::wstring> & counters = FindCounters(def);
  LogicalRecord stagingMetadata;
  GetAggregateServiceRecordMetadata(stagingMetadata, counters);

  for(LogicalRecord::const_iterator it = stagingMetadata.begin();
      it != stagingMetadata.end();
      ++it)
  {
    sourceTargetMap[it->GetName()] = it->GetName();
  }
}

void AggregateMetering::ApplyDefaults(DesignTimePlan& plan,
                                      CMSIXDefinition* def,
                                      boost::shared_ptr<Port> inputPort,
                                      boost::shared_ptr<Port>& outputPort)
{
  // For this case we don't have any of the PV properties, so nothing to apply
  outputPort = inputPort;
}

DatabaseMeteringStagingDatabase::DatabaseMeteringStagingDatabase(const std::vector<std::wstring>& serviceDefs,
                                                                 DatabaseMeteringStagingDatabase::StagingMethod stagingMethod)
  :
  mStagingMethod(stagingMethod)
{
  CServicesCollection coll;
  coll.Initialize();
  DatabaseCommands cmds;
  GenerateTableNames(coll, serviceDefs);
  CreateServiceTables(coll, serviceDefs, cmds);
  Initialize(coll, serviceDefs, cmds);
  Create();
}

DatabaseMeteringStagingDatabase::DatabaseMeteringStagingDatabase(CServicesCollection& coll,
                                                                 const std::vector<std::wstring>& serviceDefs,
                                                                 DatabaseMeteringStagingDatabase::StagingMethod stagingMethod)
  :
  mStagingMethod(stagingMethod)
{
  DatabaseCommands cmds;
  GenerateTableNames(coll, serviceDefs);
  CreateServiceTables(coll, serviceDefs, cmds);
  Initialize(coll, serviceDefs, cmds);
  Create();
}

DatabaseMeteringStagingDatabase::DatabaseMeteringStagingDatabase(const std::vector<std::wstring>& serviceDefs,
                                                                 const std::vector<std::wstring>& firstPassProductViews,
                                                                 const std::vector<std::set<std::wstring> >& counters,
                                                                 DatabaseMeteringStagingDatabase::StagingMethod stagingMethod)
  :
  mStagingMethod(stagingMethod)
{
  CServicesCollection coll;
  coll.Initialize();
  CProductViewCollection pvColl;
  pvColl.Initialize();
  DatabaseCommands cmds;
  GenerateTableNames(coll, serviceDefs);
  CreateServiceTables(coll, pvColl, serviceDefs, firstPassProductViews, counters, cmds);
  Initialize(coll, serviceDefs, cmds);
  Create();
}

DatabaseMeteringStagingDatabase::DatabaseMeteringStagingDatabase(CServicesCollection& coll,
                                                                 CProductViewCollection& pvColl,
                                                                 const std::vector<std::wstring>& serviceDefs,
                                                                 const std::vector<std::wstring>& firstPassProductViews,
                                                                 const std::vector<std::set<std::wstring> >& counters,
                                                                 DatabaseMeteringStagingDatabase::StagingMethod stagingMethod)
  :
  mStagingMethod(stagingMethod)
{
  DatabaseCommands cmds;
  GenerateTableNames(coll, serviceDefs);
  CreateServiceTables(coll, pvColl, serviceDefs, firstPassProductViews, counters, cmds);
  Initialize(coll, serviceDefs, cmds);
  Create();
}

DatabaseMeteringStagingDatabase::~DatabaseMeteringStagingDatabase()
{
  if (PRIVATE == mStagingMethod)
  {
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(true);
    for(std::vector<std::wstring>::const_iterator it=mDropQueries.begin();
        it != mDropQueries.end();
        it++)
    {
      try
      {
        std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
        stmt->ExecuteUpdateW(*it);
      }
      catch(...)
      {
      }
    }
    mDropQueries.clear();
  }
}

DatabaseMeteringStagingDatabase::StagingMethod DatabaseMeteringStagingDatabase::GetStagingMethod() const
{
  return mStagingMethod;
}

void DatabaseMeteringStagingDatabase::GenerateTableNames(CServicesCollection& coll, const std::vector<std::wstring>& serviceDefs)
{
  DatabaseCommands cmds;
    
  for(unsigned int j = 0; j<serviceDefs.size(); j++)
  {
    CMSIXDefinition * def;
    
    try
    {
      if (FALSE==coll.FindService(serviceDefs[j], def))
      {
        throw std::exception("Couldn't find service definition");
      }
      def->CalculateTableName(L"t_svc_");
    }
    catch(_com_error & e)
    {
      throw std::logic_error((boost::format("COM Error: HRESULT = 0x%x;") % e.Error()).str());
    }

    // Should we generate a name or should we use installed table or just set up parameterized statements?
    switch(mStagingMethod)
    {
    case PRIVATE:
    {
      mNetMeterTableToStagingTable[def->GetTableName()] = cmds.GetTempTableName(L"t");
      mServiceDefTableToSessionStagingTable[def->GetTableName()] = cmds.GetTempTableName(L"t");
      break;
    }
    case STREAMING:
    case SHARED:
    {
      mNetMeterTableToStagingTable[def->GetTableName()] = def->GetTableName();
      mServiceDefTableToSessionStagingTable[def->GetTableName()] = L"t_session";
      break;
    }
    }
  }
  switch(mStagingMethod)
  {
  case PRIVATE:
  {
    mNetMeterTableToStagingTable[L"t_session_set"] = cmds.GetTempTableName(L"t");
    mNetMeterTableToStagingTable[L"t_message"] = cmds.GetTempTableName(L"t");
    break;
  }
  case STREAMING:
  case SHARED:
  {
    mNetMeterTableToStagingTable[L"t_session_set"] = L"t_session_set";
    mNetMeterTableToStagingTable[L"t_message"] = L"t_message";
    break;
  }
  }
}

void DatabaseMeteringStagingDatabase::Initialize(CServicesCollection& coll, 
                                                 const std::vector<std::wstring>& serviceDefs,
                                                 DatabaseCommands& cmds)
{
  std::wstring netMeterInfo;
  ::ASCIIToWide(netMeterInfo, COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalogPrefix());
  std::wstring netMeterStageInfo;
  ::ASCIIToWide(netMeterStageInfo, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix());

  // t_session is handled a bit differently than in listener metering.  We use
  // one session table per service def to avoid some sort merge problems in the dataflow.
  if (PRIVATE == mStagingMethod)
  {
    for(unsigned int j = 0; j<serviceDefs.size(); j++)
    {
      CMSIXDefinition * def;
      try
      {
        if (FALSE==coll.FindService(serviceDefs[j], def))
        {
          throw std::exception("Couldn't find service definition");
        }
        def->CalculateTableName(L"t_svc_");
        mInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_session (id_ss, id_source_sess) SELECT id_ss, id_source_sess FROM ") + netMeterStageInfo + GetSessionTable(def->GetTableName()));
        mCreateQueries.push_back(cmds.CreateTableAsSelect(L"NetMeterStage", GetSessionTable(def->GetTableName()), 
                                                          L"NetMeterStage", L"t_session"));
        mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", GetSessionTable(def->GetTableName())));
        mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", GetSessionTable(def->GetTableName())));
        mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_session (id_ss, id_source_sess) SELECT id_ss, id_source_sess FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
      }
      catch(_com_error & e)
      {
        throw std::logic_error((boost::format("File:%s Line:%d COM Error: HRESULT = 0x%x") % __FILE__ % __LINE__ % e.Error()).str());
      }
    }
  }
  else if (STREAMING == mStagingMethod)
  {
    // Streaming mode doesn't need anything but parameterized inserts
    for(unsigned int j = 0; j<serviceDefs.size(); j++)
    {
      mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_session (id_ss, id_source_sess) SELECT id_ss, id_source_sess FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
    }
  }
  else
  {
    mInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_session (id_ss, id_source_sess) SELECT id_ss, id_source_sess FROM ") + netMeterStageInfo + L"t_session");
    mCreateQueries.push_back(cmds.CreateTableAsSelect(L"NetMeterStage", L"t_session", L"NetMeterStage", L"t_session"));
    mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", L"t_session"));
    mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", L"t_session"));
    mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_session (id_ss, id_source_sess) SELECT id_ss, id_source_sess FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
  }

  mInstallQueries.push_back(std::wstring(L"INSERT INTO ") +  netMeterInfo + std::wstring(L"t_session_set (id_message, id_ss, id_svc, b_root, session_count) SELECT id_message, id_ss, id_svc, b_root, session_count FROM ") + netMeterStageInfo + GetTable(L"t_session_set"));
  mInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_message (id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_transactionid, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address) SELECT id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_transactionid, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address FROM ") + netMeterStageInfo + GetTable(L"t_message"));
  mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") +  netMeterInfo + std::wstring(L"t_session_set (id_message, id_ss, id_svc, b_root, session_count) SELECT id_message, id_ss, id_svc, b_root, session_count FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
  mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + std::wstring(L"t_message (id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_transactionid, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address) SELECT id_message, id_route, dt_crt, dt_metered, dt_assigned, id_listener, id_pipeline, dt_completed, id_feedback, tx_transactionid, tx_sc_username, tx_sc_password, tx_sc_namespace, tx_sc_serialized, tx_ip_address FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
 
  mCreateQueries.push_back(cmds.CreateTableAsSelect(L"NetMeterStage", GetTable(L"t_session_set"), L"NetMeterStage", L"t_session_set"));
  mCreateQueries.push_back(cmds.CreateTableAsSelect(L"NetMeterStage", GetTable(L"t_message"), L"NetMeterStage", L"t_message"));
  mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", GetTable(L"t_session_set")));
  mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", GetTable(L"t_message")));
  mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", GetTable(L"t_session_set")));
  mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", GetTable(L"t_message")));
}

void DatabaseMeteringStagingDatabase::Create()
{
  if (PRIVATE == mStagingMethod)
  {
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(true);
    for(std::vector<std::wstring>::const_iterator it=mCreateQueries.begin();
        it != mCreateQueries.end();
        it++)
    {
      std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
      stmt->ExecuteUpdateW(*it);
    }
  }
}

const std::map<std::wstring, std::wstring>& DatabaseMeteringStagingDatabase::GetTableMap() const
{
  return mNetMeterTableToStagingTable;
}

const std::map<std::wstring, std::wstring>& DatabaseMeteringStagingDatabase::GetSessionTableMap() const
{
  return mServiceDefTableToSessionStagingTable;
}

const std::wstring& DatabaseMeteringStagingDatabase::GetTable(const std::wstring& tab) const
{
  return mNetMeterTableToStagingTable.find(tab)->second;
}

const std::wstring& DatabaseMeteringStagingDatabase::GetSessionTable(const std::wstring& serviceTab) const
{
  return mServiceDefTableToSessionStagingTable.find(serviceTab)->second;
}

const std::vector<std::wstring>& DatabaseMeteringStagingDatabase::GetParameterizedInstallQueries() const
{
  return mParameterizedInstallQueries;
}

void DatabaseMeteringStagingDatabase::Start(ParallelPlan& plan)
{
  std::vector<boost::int32_t> recordCount;
  Start(plan, recordCount);
}

void DatabaseMeteringStagingDatabase::Start(const boost::function0<void>& functor, std::vector<boost::int32_t>& recordCount)
{
  if (SHARED == mStagingMethod)
  {
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(true);
    for(std::vector<std::wstring>::const_iterator it=mTruncateQueries.begin();
        it != mTruncateQueries.end();
        it++)
    {
      std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
      stmt->ExecuteUpdateW(*it);
    }
  }

  functor();
  
  if (STREAMING != mStagingMethod)
  {
    recordCount.clear();
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(false);
    for(std::vector<std::wstring>::iterator it = mInstallQueries.begin();
        it != mInstallQueries.end();
        it++)
    {
      std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
      recordCount.push_back(stmt->ExecuteUpdateW(*it));
    }
    conn->CommitTransaction();
  }
  
  if (PRIVATE == mStagingMethod)
  {
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(true);
    for(std::vector<std::wstring>::const_iterator it=mDropQueries.begin();
        it != mDropQueries.end();
        it++)
    {
      std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
      stmt->ExecuteUpdateW(*it);
    }
    mDropQueries.clear();
  }
  else if (SHARED == mStagingMethod)
  {
    std::auto_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
    conn->SetAutoCommit(true);
    for(std::vector<std::wstring>::const_iterator it=mTruncateQueries.begin();
        it != mTruncateQueries.end();
        it++)
    {
      std::auto_ptr<COdbcStatement> stmt(conn->CreateStatement());
      stmt->ExecuteUpdateW(*it);
    }
  }  
}

void DatabaseMeteringStagingDatabase::Start(ParallelPlan& plan, std::vector<boost::int32_t>& recordCount)
{
  boost::shared_ptr<ParallelDomain> mydomain = plan.GetDomain(0);
  Start(boost::bind(&ParallelDomain::Start, mydomain.get()), recordCount);
}

void DatabaseMeteringStagingDatabase::CreateServiceTables(CServicesCollection& coll,
                                                          const std::vector<std::wstring>& serviceDefs,
                                                          DatabaseCommands& cmds)
{
  std::wstring netMeterInfo;
  ::ASCIIToWide(netMeterInfo, COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalogPrefix());
  std::wstring netMeterStageInfo;
  ::ASCIIToWide(netMeterStageInfo, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix());

  for(unsigned int j = 0; j<serviceDefs.size(); j++)
  {
    CMSIXDefinition * def;
    if (FALSE==coll.FindService(serviceDefs[j], def))
    {
      throw std::exception("Couldn't find service definition");
    }
    def->CalculateTableName(L"t_svc_");

    std::map<std::wstring, std::wstring> propertyColumnMap;
    propertyColumnMap[L"id_source_sess"] = L"id_source_sess";
    propertyColumnMap[L"id_parent_source_sess"] = L"id_parent_source_sess";
    propertyColumnMap[L"id_external"] = L"id_external";

    // Add mappings from property to column
    MSIXPropertiesList::iterator Iter;
    for (Iter = def->GetMSIXPropertiesList().begin();
         Iter != def->GetMSIXPropertiesList().end();
         ++Iter)
    {
      CMSIXProperties *pProp = *Iter;
      propertyColumnMap[pProp->GetColumnName()] = pProp->GetColumnName();
    }

    // Standard properties 2)
    propertyColumnMap[L"c__IntervalID"] = L"c__IntervalID";
    propertyColumnMap[L"c__TransactionCookie"] = L"c__TransactionCookie";
    propertyColumnMap[L"c__Resubmit"] = L"c__Resubmit";
    propertyColumnMap[L"c__CollectionID"] = L"c__CollectionID";

    // Collect raw materials for installation queries.
    std::wstring columnList;
    for (std::map<std::wstring,std::wstring>::const_iterator it = propertyColumnMap.begin();
         it != propertyColumnMap.end();
         it++)
    {
      if (columnList.size() > 0) columnList += L", ";
      columnList += it->second;
    }

    mCreateQueries.push_back(cmds.CreateTableAsSelect(L"NetMeterStage", GetTable(def->GetTableName()), L"NetMeterStage", def->GetTableName()));
    mInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + def->GetTableName() + std::wstring(L"(") + columnList + std::wstring(L")\nSELECT ") + columnList + std::wstring(L" FROM ") + netMeterStageInfo + GetTable(def->GetTableName()));
    mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", GetTable(def->GetTableName())));
    mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", GetTable(def->GetTableName())));

    mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + def->GetTableName() + std::wstring(L"(") + columnList + std::wstring(L")\nSELECT ") + columnList + std::wstring(L" FROM %%%NETMETERSTAGE_PREFIX%%%%1%"));
  }
}

void DatabaseMeteringStagingDatabase::CreateServiceTables(CServicesCollection& coll,
                                                          CProductViewCollection& pvColl,
                                                          const std::vector<std::wstring>& serviceDefs,
                                                          const std::vector<std::wstring>& firstPassProductViews,
                                                          const std::vector<std::set<std::wstring> >& counters,
                                                          DatabaseCommands& cmds)
{
  std::wstring netMeterInfo;
  ::ASCIIToWide(netMeterInfo, COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalogPrefix());
  std::wstring netMeterStageInfo;
  ::ASCIIToWide(netMeterStageInfo, COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalogPrefix());

  ASSERT(serviceDefs.size() == firstPassProductViews.size());
  ASSERT(serviceDefs.size() == counters.size());

  for(unsigned int j = 0; j<serviceDefs.size(); j++)
  {
    CMSIXDefinition * def;
    if (FALSE==coll.FindService(serviceDefs[j], def))
    {
      throw std::exception("Couldn't find service definition");
    }
    def->CalculateTableName(L"t_svc_");
    CMSIXDefinition * pvDef;
    if (FALSE==pvColl.FindProductView(firstPassProductViews[j], pvDef))
    {
      throw std::exception("Couldn't find first pass product view");
    }
    pvDef->CalculateTableName(L"t_pv_");

    // Staging has fixed schema + counters
    // Describe the staging table as RecordMetadata and then use
    // utilities to get the create statement.
    LogicalRecord stagingMetadata;
    GetAggregateServiceRecordMetadata(stagingMetadata, counters[j]);
    mCreateQueries.push_back(cmds.CreateTable(stagingMetadata, 
                                              L"NetMeterStage", 
                                              GetTable(def->GetTableName()),
                                              std::map<std::wstring,std::wstring>()));

    // Standard properties 1) always come from staging.
    std::map<std::wstring, std::wstring> propertyColumnMap;
    propertyColumnMap[L"stg.id_source_sess"] = L"id_source_sess";
    propertyColumnMap[L"stg.id_parent_source_sess"] = L"id_parent_source_sess";
    propertyColumnMap[L"stg.id_external"] = L"id_external";

    // Add mappings from property to column.  Some may come from staging,
    // some may come from first pass pv.
    MSIXPropertiesList::iterator Iter;
    for (Iter = def->GetMSIXPropertiesList().begin();
         Iter != def->GetMSIXPropertiesList().end();
         ++Iter)
    {
      CMSIXProperties *pProp = *Iter;
      if (stagingMetadata.HasColumn(pProp->GetColumnName()))
      {
        propertyColumnMap[L"stg."+pProp->GetColumnName()] = pProp->GetColumnName();
      }
      else
      {
        propertyColumnMap[L"pv."+pProp->GetColumnName()] = pProp->GetColumnName();
      }
    }

    // Standard properties 2) always come from staging.
    propertyColumnMap[L"stg.c__IntervalID"] = L"c__IntervalID";
    propertyColumnMap[L"stg.c__TransactionCookie"] = L"c__TransactionCookie";
    propertyColumnMap[L"stg.c__Resubmit"] = L"c__Resubmit";
    propertyColumnMap[L"stg.c__CollectionID"] = L"c__CollectionID";

    // Collect raw materials for installation queries.
    std::wstring sourceColumnList;
    std::wstring targetColumnList;
    for (std::map<std::wstring,std::wstring>::const_iterator it = propertyColumnMap.begin();
         it != propertyColumnMap.end();
         it++)
    {
      if (sourceColumnList.size() > 0) sourceColumnList += L", ";
      sourceColumnList += it->first;
      if (targetColumnList.size() > 0) targetColumnList += L", ";
      targetColumnList += it->second;
    }

    mInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + def->GetTableName() + std::wstring(L"(") + targetColumnList + std::wstring(L")\nSELECT ") + sourceColumnList + std::wstring(L"\nFROM\n") + netMeterStageInfo + GetTable(def->GetTableName()) + L" stg\nINNER JOIN " + netMeterInfo + pvDef->GetTableName() + L" pv ON stg.c__FirstPassID=pv.id_sess");
    mTruncateQueries.push_back(cmds.TruncateTable(L"NetMeterStage", GetTable(def->GetTableName())));
    mDropQueries.push_back(cmds.DropTable(L"NetMeterStage", GetTable(def->GetTableName())));

    mParameterizedInstallQueries.push_back(std::wstring(L"INSERT INTO ") + netMeterInfo + def->GetTableName() + std::wstring(L"(") + targetColumnList + std::wstring(L")\nSELECT ") + sourceColumnList + std::wstring(L"\nFROM\n%%%NETMETERSTAGE_PREFIX%%%%1% stg\nINNER JOIN " + netMeterInfo + pvDef->GetTableName() + L" pv ON stg.c__FirstPassID=pv.id_sess"));
  }
}

