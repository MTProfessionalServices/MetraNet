#ifndef __RUNTIMEHASHAGGREGATE_H__
#define __RUNTIMEHASHAGGREGATE_H__

#include <boost/serialization/export.hpp>

BOOST_CLASS_EXPORT(RunTimeHashRunningAggregate);
BOOST_CLASS_EXPORT(RunTimeHashGroupBy);
BOOST_CLASS_EXPORT(RunTimeUnroll);
BOOST_CLASS_EXPORT(RunTimeSortMergeJoin);
BOOST_CLASS_EXPORT(RunTimeFilter);
BOOST_CLASS_EXPORT(RunTimeSwitch);
BOOST_CLASS_EXPORT(RunTimeProjection);
BOOST_CLASS_EXPORT(RunTimeSessionSetBuilder);
BOOST_CLASS_EXPORT(RunTimePrint);
BOOST_CLASS_EXPORT(RunTimeAssertSortOrder);
BOOST_CLASS_EXPORT(RunTimeSortGroupBy);

#endif
