#ifndef __PLANINTERPRETER_H__
#define __PLANINTERPRETER_H__

#include <set>
#include <boost/shared_ptr.hpp>
#include <boost/cstdint.hpp>
#include "MetraFlowConfig.h"

class DesignTimeSortMergeCollector;
class DesignTimeAssertSortOrder;
class Port;
class DesignTimePlan;


class MPIPlanInterpreter
{
public:
  METRAFLOW_DECL static void Start(int argc, char **argv);
};

class AggregateRatingUsageSpec
{
private:
  std::wstring mTableName;
  boost::int32_t mViewID;
  std::vector<boost::int32_t> mUsageIntervalIDs;
  boost::int32_t mBillingGroupID;
  bool mIsEstimate;
  std::set<std::wstring> mCounters;
  std::wstring mInitializeProgram;
  boost::int32_t mPriceableItemTemplateID;
public:
  AggregateRatingUsageSpec(const std::wstring& tableName,
                           boost::int32_t viewID,
                           boost::int32_t usageIntervalID,
                           boost::int32_t billingGroupID,
                           bool isEstimate,
                           const std::set<std::wstring>& counters,
                           const std::wstring& initializeProgram,
                           boost::int32_t priceableItemTemplateID)
    :
    mTableName(tableName),
    mViewID(viewID),
    mUsageIntervalIDs(1,usageIntervalID),
    mBillingGroupID(billingGroupID),
    mIsEstimate(isEstimate),
    mCounters(counters),
    mInitializeProgram(initializeProgram),
    mPriceableItemTemplateID(priceableItemTemplateID)
  {
  }
  AggregateRatingUsageSpec(const std::wstring& tableName,
                           boost::int32_t viewID,
                           const std::vector<boost::int32_t>& usageIntervalIDs,
                           boost::int32_t billingGroupID,
                           bool isEstimate,
                           const std::set<std::wstring>& counters,
                           const std::wstring& initializeProgram,
                           boost::int32_t priceableItemTemplateID)
    :
    mTableName(tableName),
    mViewID(viewID),
    mUsageIntervalIDs(usageIntervalIDs),
    mBillingGroupID(billingGroupID),
    mIsEstimate(isEstimate),
    mCounters(counters),
    mInitializeProgram(initializeProgram),
    mPriceableItemTemplateID(priceableItemTemplateID)
  {
  }

  const std::wstring& GetTableName() const { return mTableName; }
  boost::int32_t GetViewID() const { return mViewID; }
  const std::vector<boost::int32_t>& GetUsageIntervalIDs() const { return mUsageIntervalIDs; }
  boost::int32_t GetBillingGroupID() const { return mBillingGroupID; }
  boost::int32_t IsEstimate() const { return mIsEstimate; }
  const std::set<std::wstring>& GetCounters() const { return mCounters; }
  const std::wstring& GetInitializeProgram() const { return mInitializeProgram; }
  boost::int32_t GetPriceableItemTemplateID() const { return mPriceableItemTemplateID; }
};

class AggregateRatingCountableSpec
{
private:
  std::wstring mTableName;
  boost::int32_t mViewID;
  std::set<std::wstring> mReferencedColumns;
  std::wstring mUpdateProgram;
public:
  AggregateRatingCountableSpec()
    :
    mViewID(0)
  {
  }

  AggregateRatingCountableSpec(const std::wstring& tableName,
                               boost::int32_t viewID,
                               const std::set<std::wstring>& referencedColumns,
                               const std::wstring& updateProgram)
    :
    mTableName(tableName),
    mViewID(viewID),
    mReferencedColumns(referencedColumns),
    mUpdateProgram(updateProgram)
  {
  }

  ~AggregateRatingCountableSpec()
  {
  }

  const std::wstring& GetTableName() const { return mTableName; }
  boost::int32_t GetViewID() const { return mViewID; }
  const std::set<std::wstring>& GetReferencedColumns() const { return mReferencedColumns; }
  const std::wstring& GetUpdateProgram() const { return mUpdateProgram; }
};

class AggregateRating
{
private:
  AggregateRatingUsageSpec mRatedUsage;
  std::vector<AggregateRatingCountableSpec> mCountables;
  DesignTimePlan & mPlan;
  bool mIsRatedUsageCountable;
  bool mReadAllRatedUsageColumns;
  boost::shared_ptr<Port> mOutputPort;

  std::wstring GetRatedUsageSelectList(const std::wstring& ratedUsageTable);

  DesignTimeSortMergeCollector * CreateSortMergeCollector(const std::wstring& name);
  DesignTimeAssertSortOrder * CreateAssertSortOrder(const std::wstring& name);

  void ReadRatedUsageAndCountables(boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> >& countableOutput);
  void FilterRatedUsageOnBillingGroup(boost::shared_ptr<Port> ratedUsage, boost::shared_ptr<Port> & outputRatedUsage);
  void GuideRatedUsageToBillingCycleAndPriceableItem(boost::shared_ptr<Port> ratedUsage, boost::shared_ptr<Port> & outputRatedUsage);
  void GuideToGroupSubscriptions(
    boost::int32_t id_pi_template, 
    boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
    boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput);
  void ProcessGroupSubscriptions(boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
                                 boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput);
  void ProcessIndividualSubscriptions(boost::int32_t id_pi_template, 
                                      boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> > & countables,
                                      boost::shared_ptr<Port>& ratedUsageOutput, std::vector<boost::shared_ptr<Port> > & countablesOutput);
  void CalculateRunningTotal(boost::shared_ptr<Port> ratedUsage, const std::vector<boost::shared_ptr<Port> >& countables,
                             boost::shared_ptr<Port>& outputRatedUsage);
  std::wstring GetUsageIntervalIDsPredicate(const std::wstring& prefix);
public:
  METRAFLOW_DECL AggregateRating(DesignTimePlan & plan,
                            const AggregateRatingUsageSpec & ratedUsage,
                            const std::vector<AggregateRatingCountableSpec>& countables,
                            bool readAllRatedUsageColumns=true);
  METRAFLOW_DECL ~AggregateRating();

  METRAFLOW_DECL boost::shared_ptr<Port> GetOutputPort();
};

class AggregateRatingScript
{
private:
  std::wstring& mProgram;
  AggregateRatingUsageSpec mRatedUsage;
  std::vector<AggregateRatingCountableSpec> mCountables;
  bool mIsRatedUsageCountable;
  bool mReadAllRatedUsageColumns;
  std::wstring mOutputPort;
  std::wstring mSortDir;

  void GetProductViewColumns(const std::wstring& ratedUsageTable, std::vector<std::wstring>& allPvColumns);
  void SplitCountables(const std::wstring& ratedUsageTable, 
                       const std::vector<std::wstring>& pvColumns, 
                       std::vector<std::wstring>& countableColumns,
                       std::vector<std::wstring>& nonCountableColumns);
  std::wstring GetRatedUsageSelectList(const std::vector<std::wstring>& pvColumns);

  std::wstring CreateSortMergeCollector(const std::wstring& name);

  void ReadRatedUsageAndCountables(std::wstring& ratedUsageOutput, std::vector<std::wstring >& countableOutput);
  void FilterRatedUsageOnBillingGroup(const std::wstring& ratedUsage, std::wstring & outputRatedUsage);
  void GuideRatedUsageToBillingCycleAndPriceableItem(const std::wstring& ratedUsage, std::wstring & outputRatedUsage);
  void GuideToGroupSubscriptions(
    boost::int32_t id_pi_template, 
    const std::wstring& ratedUsage, const std::vector<std::wstring > & countables,
    std::wstring& ratedUsageOutput, std::vector<std::wstring > & countablesOutput);
  void ProcessGroupSubscriptions(const std::wstring& ratedUsage, const std::vector<std::wstring > & countables,
                                 std::wstring& ratedUsageOutput, std::vector<std::wstring > & countablesOutput);
  void ProcessIndividualSubscriptions(boost::int32_t id_pi_template, 
                                      const std::wstring& ratedUsage, const std::vector<std::wstring > & countables,
                                      std::wstring& ratedUsageOutput, std::vector<std::wstring > & countablesOutput);
  void CalculateRunningTotal(const std::wstring& ratedUsage, const std::vector<std::wstring >& countables,
                             std::wstring& outputRatedUsage);
  std::wstring GetUsageIntervalIDsPredicate(const std::wstring& prefix);
public:
  METRAFLOW_DECL AggregateRatingScript(std::wstring & program,
                                       const AggregateRatingUsageSpec & ratedUsage,
                                       const std::vector<AggregateRatingCountableSpec>& countables,
                                       bool readAllRatedUsageColumns=true);
  METRAFLOW_DECL ~AggregateRatingScript();

  METRAFLOW_DECL std::wstring GetOutputPort();
};

#endif
