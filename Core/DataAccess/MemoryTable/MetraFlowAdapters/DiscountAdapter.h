#ifndef __METRAFLOWADAPTERS_H__
#define __METRAFLOWADAPTERS_H__

#include <map>
#include <string>
#include <vector>

#include <boost/shared_ptr.hpp>
#include <boost/cstdint.hpp>
#include <boost/config.hpp>

#if defined(BOOST_HAS_DECLSPEC)
#  if defined(METRAFLOWADAPTERS_DEF)
#    define METRAFLOWADAPTERS_DECL __declspec(dllexport)
#  else
#    define METRAFLOWADAPTERS_DECL __declspec(dllimport)
#  endif
#else
#  define METRAFLOWADAPTERS_DECL
#endif

#import <MTProductCatalog.tlb> rename( "EOF", "RowsetEOF" )

class NTLogger;
class UsageCounters;
class UsageCountable;
class CProductViewCollection;

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

  CProductViewCollection * mProductViews;
public:
  METRAFLOWADAPTERS_DECL CounterBuilder(NTLogger & logger, long usageIntervalID, bool allBcr, bool runParallel, bool isDiscount=true);
  METRAFLOWADAPTERS_DECL ~CounterBuilder();
  METRAFLOWADAPTERS_DECL void Visit(MTPRODUCTCATALOGLib::IMTDiscountPtr piTemplate, MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType);

  METRAFLOWADAPTERS_DECL std::wstring ReadUsage();
  METRAFLOWADAPTERS_DECL std::wstring RouteUsage();
  METRAFLOWADAPTERS_DECL std::wstring MeterUsage(const std::vector<unsigned char>& collectionID, long sessionSetSize);
  METRAFLOWADAPTERS_DECL std::wstring WriteUsage(const std::wstring& tempDir, std::map<std::wstring, std::wstring>& outputFiles);
};

class DiscountAggregationScriptBuilder
{
private:
  NTLogger * mLogger;
  CounterBuilder * mCounterBuilder;

  bool AllCountersAreSet(MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr& PIType,
                         MTPRODUCTCATALOGLib::IMTDiscountPtr& PI);
public:
  METRAFLOWADAPTERS_DECL DiscountAggregationScriptBuilder(NTLogger & logger, 
                                                          boost::int32_t usageIntervalID,
                                                          bool singleDiscountMode,
                                                          boost::int32_t singleTemplateID);
  METRAFLOWADAPTERS_DECL ~DiscountAggregationScriptBuilder();
  METRAFLOWADAPTERS_DECL std::wstring GetSubscriptionExtract(boost::int32_t usageIntervalID,
                                                             boost::int32_t billingGroupID,
                                                             boost::int32_t runID);
  METRAFLOWADAPTERS_DECL std::wstring GetSubscriptionExtract(DATE startDate, DATE endDate);
  METRAFLOWADAPTERS_DECL CounterBuilder& GetCounterBuilder();
};

#endif
