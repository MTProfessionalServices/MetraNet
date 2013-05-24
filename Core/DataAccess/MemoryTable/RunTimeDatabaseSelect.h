#ifndef __RUNTIMEDATABASESELECT_H__
#define  __RUNTIMEDATABASESELECT_H__

#include <boost/serialization/export.hpp>

BOOST_CLASS_EXPORT(RunTimeDevNull);
BOOST_CLASS_EXPORT(RunTimeDatabaseSelect);
BOOST_CLASS_EXPORT(RunTimeHashJoin);
BOOST_CLASS_EXPORT(RunTimeHashPartitioner);
BOOST_CLASS_EXPORT(RunTimeBroadcastPartitioner);
BOOST_CLASS_EXPORT(RunTimeNondeterministicCollector);
BOOST_CLASS_EXPORT(RunTimeUnionAll);
BOOST_CLASS_EXPORT(RunTimeCopy);
BOOST_CLASS_EXPORT(RunTimeCopy2);
BOOST_CLASS_EXPORT(RunTimeRangePartitioner<boost::int32_t>);
BOOST_CLASS_EXPORT(RunTimeRangePartitioner<boost::int64_t>);

#endif
