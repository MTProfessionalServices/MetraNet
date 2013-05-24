#ifndef __DATABASE_METERING_H__
#define __DATABASE_METERING_H__

#include "Scheduler.h"
#include <set>
#include <boost/shared_ptr.hpp>
#include <boost/format.hpp>

class CMSIXDefinition;
class CServicesCollection;
class CProductViewCollection;
class DatabaseCommands;

// A process that meters by inserting into a set of
// staging tables and then does inserts into the 
// NetMeter database in a local transaction.
// There are two modes for how to do this.  In one
// mode the tables are created for this metering instance.
// In the second mode, shared tables are used (and truncated
// prior to use).  Note that the first mode is more useful
// outside the listener as there is no general mechanism for
// acquiring exclusive access to the shared tables.
class DatabaseMeteringStagingDatabase
{
public:
  enum StagingMethod { SHARED, PRIVATE, STREAMING };
private:
  StagingMethod mStagingMethod;

  std::map<std::wstring, std::wstring> mServiceDefToStagingTable;
  std::map<std::wstring, std::wstring> mNetMeterTableToStagingTable;
  std::map<std::wstring, std::wstring> mServiceDefTableToSessionStagingTable;

  std::vector<std::wstring> mInstallQueries;
  std::vector<std::wstring> mTruncateQueries;
  std::vector<std::wstring> mCreateQueries;
  std::vector<std::wstring> mDropQueries;
  std::vector<std::wstring> mParameterizedInstallQueries;
  void GenerateTableNames(CServicesCollection& coll, const std::vector<std::wstring>& serviceDefs);
  void Initialize(CServicesCollection& coll, const std::vector<std::wstring>& serviceDefs, DatabaseCommands& cmds);
  void CreateServiceTables(CServicesCollection& coll,
                           const std::vector<std::wstring>& serviceDefs,
                           DatabaseCommands& cmds);
  void CreateServiceTables(CServicesCollection& coll,
                           CProductViewCollection& pvColl,
                           const std::vector<std::wstring>& serviceDefs,
                           const std::vector<std::wstring>& firstPassProductViews,
                           const std::vector<std::set<std::wstring> >& counters,
                           DatabaseCommands& cmds);
  void Create();
public:
  METRAFLOW_DECL DatabaseMeteringStagingDatabase(const std::vector<std::wstring>& serviceDefs,
                                            StagingMethod stagingMethod);
  METRAFLOW_DECL DatabaseMeteringStagingDatabase(CServicesCollection& coll,
                                            const std::vector<std::wstring>& serviceDefs,
                                            StagingMethod stagingMethod);
  METRAFLOW_DECL DatabaseMeteringStagingDatabase(CServicesCollection& coll,
                                            CProductViewCollection& pvColl,
                                            const std::vector<std::wstring>& serviceDefs,
                                            const std::vector<std::wstring>& firstPassProductViews,
                                            const std::vector<std::set<std::wstring> >& counters,
                                            StagingMethod stagingMethod);
  METRAFLOW_DECL DatabaseMeteringStagingDatabase(const std::vector<std::wstring>& serviceDefs,
                                            const std::vector<std::wstring>& firstPassProductViews,
                                            const std::vector<std::set<std::wstring> >& counters,
                                            StagingMethod stagingMethod);
  METRAFLOW_DECL ~DatabaseMeteringStagingDatabase();
  METRAFLOW_DECL StagingMethod GetStagingMethod() const;
  METRAFLOW_DECL const std::map<std::wstring, std::wstring>& GetTableMap() const;
  METRAFLOW_DECL const std::map<std::wstring, std::wstring>& GetSessionTableMap() const;
  METRAFLOW_DECL const std::wstring& GetTable(const std::wstring& table) const;
  METRAFLOW_DECL const std::wstring& GetSessionTable(const std::wstring& table) const;
  METRAFLOW_DECL const std::vector<std::wstring>& GetParameterizedInstallQueries() const;
  METRAFLOW_DECL void Start(ParallelPlan& plan);
  METRAFLOW_DECL void Start(ParallelPlan& plan, std::vector<boost::int32_t>& recordCount);
  METRAFLOW_DECL void Start(const boost::function0<void>& functor, std::vector<boost::int32_t>& recordCount);
};

// A "meta-operator" for doing database metering.
class Metering : public DesignTimeOperator
{
private:
  bool mStageOnly;
  std::wstring mParentKey;
  std::vector<std::wstring> mChildKeys;
  boost::int32_t mTargetMessageSize;
  boost::int32_t mTargetCommitSize;
  std::vector<boost::uint8_t> mCollectionID;
  bool mGenerateSummaryTable;

  // If false, this means enums are arriving to the metering
  // operator as integer (happens when input is from a queue).
  bool mAreEnumsBeingUsed;

  /** 
   * The meter operator can optionally have output port containing
   * the values that were written to the t_message table.
   */
  bool mIsOutputPortNeeded;

  /**
   * The meter operator can optionally write username/namespace/password/
   * serialized authorization values to the t_message table.  
   * These values come from an additional input port.
   */
  bool mIsAuthNeeded;

  void InsertIntoSvcTable(DesignTimePlan& plan,
                          CServicesCollection& coll,
                          const std::wstring& svc,
                          boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase,
                          bool isRoot,
                          boost::shared_ptr<Port> inputPort,
                          boost::shared_ptr<Port>& svcOutputPort,
                          boost::shared_ptr<Port>& sessionOutputPort);
protected:
  virtual void GetSourceTargetMap(CMSIXDefinition* def,
                                  std::map<std::wstring,std::wstring>& sourceTargetMap);
  virtual void ApplyDefaults(DesignTimePlan& plan,
                             CMSIXDefinition* def,
                             boost::shared_ptr<Port> inputPort,
                             boost::shared_ptr<Port>& outputPort);
  std::wstring mParentService;
  std::vector<std::wstring> mChildService;

public:
  METRAFLOW_DECL Metering();
  METRAFLOW_DECL virtual ~Metering();

  // Should we only write to the staging database or should
  // we stream commits.
  METRAFLOW_DECL bool GetStageOnly() const;
  METRAFLOW_DECL void SetStageOnly(bool stageOnly);

  METRAFLOW_DECL void SetParent(const std::wstring& parent);
  METRAFLOW_DECL void SetChildren(const std::vector<std::wstring>& children);
  // This allows one to set all of the services at once by assuming that the
  // parent is the first entry in the vector.  So a call to SetServices(v)
  // is equivalent to 
  // SetParent(v[0]);
  // if(v.size() > 1) SetChildren(std::vector<std::wstring>(v.begin()+1,v.end()));
  METRAFLOW_DECL void SetServices(const std::vector<std::wstring>& services);
  METRAFLOW_DECL const std::vector<std::wstring>& GetServices() const;
  METRAFLOW_DECL void SetParentKey(const std::wstring& parentKey);
  METRAFLOW_DECL void SetChildKeys(const std::vector<std::wstring>& childKeys);
  // This allows one to set all of the keys at once by assuming that the
  // parent key is the first entry in the vector.  So a call to SetKeys(v)
  // is equivalent to 
  // SetParentKey(v[0]);
  // if(v.size() > 1) SetChildKeys(std::vector<std::wstring>(v.begin()+1,v.end()));
  METRAFLOW_DECL void SetKeys(const std::vector<std::wstring>& keys);
  METRAFLOW_DECL const std::vector<std::wstring>& GetKeys() const;
  METRAFLOW_DECL void SetTargetMessageSize(boost::int32_t targetMessageSize);
  METRAFLOW_DECL void SetTargetCommitSize(boost::int32_t targetCommitSize);
  METRAFLOW_DECL void SetCollectionID(const std::vector<boost::uint8_t>& collectionID);

  // Are Enums being used? Or are Enums arriving as integers
  METRAFLOW_DECL void SetAreEnumsBeingUsed(bool areEnumsBeingUsed);

  // Should we generate a summary table of metered records?
  METRAFLOW_DECL void SetGenerateSummaryTable(bool generateSummaryTable);

  // Should the metering operator have an input port
  // supplying the authorization value: serialized?
  // This value will be written to t_message
  METRAFLOW_DECL void SetIsOutputPortNeeded(bool isOutputPortNeeded);

  // Should the metering operator have an input port
  // that is supplying the authorization values:
  // username, password, namespace, and serialized?  These values
  // will be written to t_message.
  METRAFLOW_DECL void SetIsAuthNeeded(bool isAuthNeeded);

  METRAFLOW_DECL void Generate(CServicesCollection& coll, 
                          DesignTimePlan & plan, 
                          boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase);
  METRAFLOW_DECL void Generate(DesignTimePlan & plan, 
                          boost::shared_ptr<DatabaseMeteringStagingDatabase> stagingDatabase);

  /**
   * TODO: This notion of composite operator isn't yet baked!
   */
  METRAFLOW_DECL void type_check()
  {
  }

  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t)
  {
    return NULL;
  }

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual Metering* clone(
                          const std::wstring& name,
                          std::vector<OperatorArg*>& args, 
                          int nInputs, int nOutputs) const;
};

class AggregateMetering : public Metering
{
private:
  std::set<std::wstring> mParentCounters;
  std::vector<std::set<std::wstring> > mChildCounters;
protected:
  virtual void GetSourceTargetMap(CMSIXDefinition* def,
                                  std::map<std::wstring,std::wstring>& sourceTargetMap);
  virtual void ApplyDefaults(DesignTimePlan& plan,
                             CMSIXDefinition* def,
                             boost::shared_ptr<Port> inputPort,
                             boost::shared_ptr<Port>& outputPort);
  const std::set<std::wstring>& FindCounters(CMSIXDefinition* def);
public:
  METRAFLOW_DECL AggregateMetering(const std::vector<std::set<std::wstring> >& counters);
  METRAFLOW_DECL AggregateMetering();
  METRAFLOW_DECL ~AggregateMetering();
  METRAFLOW_DECL void SetParentCounters(const std::set<std::wstring>& parentCounter);
  METRAFLOW_DECL void SetChildCounters(const std::vector<std::set<std::wstring> >& childCounters);
  // This allows one to set all of the counters at once by assuming that the
  // parent counters are the first entry in the vector.  So a call to SetCounters(v)
  // is equivalent to 
  // SetParentCounters(v[0]);
  // if(v.size() > 1) SetCounters(std::vector<std::set<std::wstring> >(v.begin()+1,v.end()));
  METRAFLOW_DECL void SetCounters(const std::vector<std::set<std::wstring> >& counters);
};
  
#endif 
