/**************************************************************************
 * @doc ODBCBATCHIDWRITER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | ODBCBATCHIDWRITER
 ***************************************************************************/

#ifndef _ODBCBATCHIDWRITER_H
#define _ODBCBATCHIDWRITER_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

// TODO: remove undefs
#if defined(MTODBCUTILS_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

class COdbcConnectionInfo;
class COdbcConnection;
class COdbcPreparedArrayStatement;
class COdbcStatement;

#import <MTPipelineLib.tlb> rename("EOF", "PipelineEOF")

/////////////////////////////////////////////////////
// COdbcBatchIDWriter - an object that can write rows of
// batch IDs into the database
/////////////////////////////////////////////////////
#define USE_BATCH_SUMMARY_TEMP_TABLE

class COdbcBatchIDWriter
{
public:
	DllExport COdbcBatchIDWriter(const COdbcConnectionInfo & info);
	DllExport virtual ~COdbcBatchIDWriter();

#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 
	DllExport void CreateTempTable();
	DllExport void CreateBatchSummaryInsertStatement(
		int aMaxArraySize = 100);
#endif

	DllExport void WriteBatchIDs(const std::map<std::wstring, int> & arBatchCountMap);

    /**
     * Create a single t_batch record if it doesn't already exist.
     *
     * @param batchUidStr  the base64 encoded 16-bit batchID.  This
     *                     encoded string is used for the batch name, tx_name.
     *                     The 16-bit batch ID is used for tx_batch.
     */
	DllExport void WriteBatchID(const std::wstring batchUidStr);

	DllExport void UpdateErrorCounts(const std::map<std::wstring, int> & arFailureCountMap, MTPipelineLib::IMTTransactionPtr apTran);

	// release all handles
	DllExport void Clear();

private:
#ifdef USE_BATCH_SUMMARY_TEMP_TABLE 
	void InsertCounts(const std::map<std::wstring, int> & arCounts);

  COdbcConnection * mpConnection;
	COdbcPreparedArrayStatement * mBatchInsertStatement;
	COdbcStatement * mpStatement;
	int mBatchInsertMaxArraySize;

	std::string mBatchSummaryTable;
  std::string mStagingDBName;
	BOOL mIsOracle;
#endif

};


#endif /* _ODBCBATCHIDWRITER_H */
