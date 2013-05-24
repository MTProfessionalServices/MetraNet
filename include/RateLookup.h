/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 2002 by MetraTech Corporation
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
 * Created by: David Blair
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __RATELOOKUP_H__
#define __RATELOOKUP_H__
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") \
  rename ("IMTCollection", "IMTCollectionPipe") \
  no_function_mapping
#include <RSCache.h>
#include <autocritical.h>

#import <MTProductCatalog.tlb> rename("EOF", "EOFX")

#include <vector>
#include <map>
using namespace std;

struct ScoredRateInputs : public RateInputs
{
	__int64 mICBScheduleScore;
	__int64 mPOScheduleScore;
	__int64 mDefaultAccountScheduleScore;

	ScoredRateInputs()
		: mICBScheduleScore(_I64_MIN),
			mPOScheduleScore(_I64_MIN),
			mDefaultAccountScheduleScore(_I64_MIN)
	{ }

	void Update(int sub, int po, int sched, time_t modifiedTimet, __int64 score);
	void Update(const ScoredRateInputs & other);

	void Clear();

  void ToString(MTPipelineLib::IMTLogPtr aLogger) const;
};

/**
 * ParameterTable - Represents a parameter table that is configured for 
 * rating within the context of a pipeline (specifically a plugin instance).
 * In addition to the information in the parameter table definition itself,
 * this object also contains an optional specification of a weighting key
 * for use in "weighted-rate-plugin" scenarios that are required for proper
 * tapered rating.
 */
class ParameterTable
{
private:
	static MTPRODUCTCATALOGLib::IMTProductCatalogPtr GetCatalog();
	static int ReadParameterTableID(const _bstr_t& aParamTableName);
	static NTThreadLock mThreadLock;

	_bstr_t mParamTableName;
	int mParamTableID;
	long mWeightOnKeyID;
	long mStartAtID;
	long mInSessionID;

public:
	_bstr_t GetParamTableName() const { return mParamTableName; }
	int GetParamTableID() const { return mParamTableID; }
	long GetWeightOnKeyID() const { return mWeightOnKeyID; }
	long GetStartAtID() const { return mStartAtID; }
	long GetInSessionID() const { return mInSessionID; }

  /**
   * Is this configured for weighted rated (tapered rating)
   */
	bool IsWeightedRate() const { return mWeightOnKeyID != -1; }

  /**
   * Create a weighted parameter table specification
	 * Requires that aParamTableName exists in the product catalog
   * @throws std::exception 
	 */
	ParameterTable(const _bstr_t& aParamTableName, 
								 long aWeightOnKeyID, 
								 long aStartAtID, 
								 long aInSessionID);

  /**
   * Create a non-weighted parameter table specification
	 * Requires that aParamTableName exists in the product catalog
   * @throws std::exception 
	 */
	ParameterTable(const _bstr_t& aParamTableName);
};

/**
 * Manages the results of rate schedule resolution for a list of
 * parameter tables and a list of sessions that are used to lookup
 * into the parameter tables.
 */
class ScoredRateInputSet
{
private:
	// Map of parameter table ID to vector of scored inputs
  map<int, vector<ScoredRateInputs>* > mScoredSet;
	// Map session ID to index in the request vector
	map<int, int> mRequests;
	unsigned int mNumRequests;

public:
  /**
   * Set up for rate schedule resolution of a list of parameter tables.
   */
	ScoredRateInputSet(const vector<ParameterTable>& aParameterTables);

	~ScoredRateInputSet();

	/**
	 * Create a request for selection of the rate schedules for parameter tables associated
	 * with the given session.
	 */
	int MakeRequest(MTPipelineLib::IMTSessionPtr aSession);

	/**
	 * Get the RateInputs that were computed for a given parameter table and request.
	 * Requires that the request argument was returned for some session via a call to
	 * MakeRequest().
	 */
	ScoredRateInputs& GetRateInputs(int aParamTableID, int aRequestID);

	ScoredRateInputs& GetRateInputs(const ParameterTable& aParamTable, MTPipelineLib::IMTSessionPtr aSession);

	/**
	 * Check to see if a rate schedule has been resolved for the given
	 * request and parameter table.
	 */
	bool HasValidRateSchedule(int aParamTableID, int aRequestID);

  /**
   * Is rate schedule for specified parameter table being managed by this object?
	 */
	bool HasParamTable(int aParamTableID) const;


  /** 
	 * Update the rate inputs with the result of a request.
	 */
	bool UpdateRequest(int pt, int requestId, int sub, int po, int sched, time_t modifiedTimet, __int64 score=_I64_MIN);

  void ToString(MTPipelineLib::IMTLogPtr aLogger) const;
};

#endif
