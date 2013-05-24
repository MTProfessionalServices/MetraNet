#include "DatabaseInsert.h"
#include "RunTimeExpression.h"
#include "DataFile.h"
#include "ExternalSort.h"
#include "LongestPrefixMatch.h"
#include "IdGeneratorOperator.h"
#include "Normalization.h"
#include "DataflowTreeGenerator.hpp"

#include <boost/serialization/export.hpp>

BOOST_CLASS_EXPORT(RunTimeExpression);
BOOST_CLASS_EXPORT(RunTimeExpressionGenerator);
BOOST_CLASS_EXPORT(RunTimeGenerator);
BOOST_CLASS_EXPORT(CapacityChangeHandler);
BOOST_CLASS_EXPORT(Reactor);
BOOST_CLASS_EXPORT(BipartiteChannelSpec2);
BOOST_CLASS_EXPORT(StraightLineChannelSpec2);
BOOST_CLASS_EXPORT(ParallelPlan);
BOOST_CLASS_EXPORT(RunTimeOperator);
BOOST_CLASS_EXPORT(RunTimeDataFileScan<PagedParseBuffer<mapped_file> >);
BOOST_CLASS_EXPORT(RunTimeDataFileScan<StdioReadBuffer<StdioFile> >);
BOOST_CLASS_EXPORT(RunTimeDataFileScan<StdioReadBuffer<Win32File> >);
BOOST_CLASS_EXPORT(RunTimeDataFileExport<StdioWriteBuffer<StdioFile> >);
BOOST_CLASS_EXPORT(RunTimeDataFileDelete);
BOOST_CLASS_EXPORT(RunTimeDataFileRename);
BOOST_CLASS_EXPORT(RunTimeDatabaseInsert<COdbcPreparedBcpStatement>);
BOOST_CLASS_EXPORT(RunTimeDatabaseInsert<COdbcPreparedArrayStatement>);
BOOST_CLASS_EXPORT(RunTimeTransactionalInstall);
BOOST_CLASS_EXPORT(RunTimeTransactionalInstall2);
BOOST_CLASS_EXPORT(RunTimeExternalSort);
BOOST_CLASS_EXPORT(RunTimeRecordImporter<PagedParseBuffer<mapped_file> >);
BOOST_CLASS_EXPORT(RunTimeRecordImporter<StdioReadBuffer<StdioFile> >);
BOOST_CLASS_EXPORT(RunTimeRecordImporter<StdioReadBuffer<ZLIBFile> >);
BOOST_CLASS_EXPORT(RunTimeRecordExporter<StdioWriteBuffer<StdioFile> >);
BOOST_CLASS_EXPORT(RunTimeRecordExporter<StdioWriteBuffer<ZLIBFile> >);
BOOST_CLASS_EXPORT(RunTimeSortKey);
BOOST_CLASS_EXPORT(RunTimeSortMergeCollector);
BOOST_CLASS_EXPORT(RunTimeLongestPrefixMatch);
BOOST_CLASS_EXPORT(RunTimeIdGenerator);
BOOST_CLASS_EXPORT(RunTimeSortNest);
BOOST_CLASS_EXPORT(RunTimeUnnest);
BOOST_CLASS_EXPORT(DesignTimeTaxwareBinding);
BOOST_CLASS_EXPORT(RunTimeTaxware);
BOOST_CLASS_EXPORT(RunTimeMD5Hash);
BOOST_CLASS_EXPORT(RunTimeSortRunningAggregate);