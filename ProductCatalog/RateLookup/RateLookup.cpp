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

#pragma warning( disable : 4786 ) 

#include <metra.h>
#include <MTSessionBaseDef.h>
#include <RateLookup.h>

void ScoredRateInputs::Update(int sub, int po, int sched, time_t modifiedTimet, __int64 score)
{
	if (sub == -1 && po == -1)
	{
		if (score > mDefaultAccountScheduleScore)
		{
			mDefaultAccountScheduleID = sched;
			mDefaultAccountScheduleModified = modifiedTimet;
			mDefaultAccountScheduleScore = score;
		}
	}
	else if (sub == -1 && po != -1)
	{
		if (score > mPOScheduleScore)
		{
			mPOScheduleID = sched;
			mPOScheduleModified = modifiedTimet;
			mPOScheduleScore = score;
		}
	}
	else // sub != -1 && po == -1
	{
		if (score > mICBScheduleScore)
		{
			mICBScheduleID = sched;
			mICBScheduleModified = modifiedTimet;
			mICBScheduleScore = score;
		}
	}
}

void ScoredRateInputs::Clear()
{
	mPI = -1;
	mParamTableID = -1;
	mICBScheduleID = -1;
	mICBScheduleModified = 0;
	mPOScheduleID = -1;
	mPOScheduleModified = 0;
	mDefaultAccountScheduleID = -1;
	mDefaultAccountScheduleModified = 0;

	mICBScheduleScore = _I64_MIN;
	mPOScheduleScore = _I64_MIN;
	mDefaultAccountScheduleScore = _I64_MIN;
}

void ScoredRateInputs::Update(const ScoredRateInputs & other)
{
	ASSERT(mParamTableID == other.mParamTableID);
	if (other.mDefaultAccountScheduleID != -1
			&& other.mDefaultAccountScheduleScore > mDefaultAccountScheduleScore)
	{
		mDefaultAccountScheduleID = other.mDefaultAccountScheduleID;
		mDefaultAccountScheduleModified = other.mDefaultAccountScheduleModified;
		mDefaultAccountScheduleScore = other.mDefaultAccountScheduleScore;
	}

	if (other.mPOScheduleID != -1
			&& other.mPOScheduleScore > mPOScheduleScore)
	{
		mPOScheduleID = other.mPOScheduleID;
		mPOScheduleModified = other.mPOScheduleModified;
		mPOScheduleScore = other.mPOScheduleScore;
	}

	if (other.mICBScheduleID != -1
			&& other.mICBScheduleScore > mICBScheduleScore)
	{
		mICBScheduleID = other.mICBScheduleID;
		mICBScheduleModified = other.mICBScheduleModified;
		mICBScheduleScore = other.mICBScheduleScore;
	}
}

void ScoredRateInputs::ToString(MTPipelineLib::IMTLogPtr aLogger) const
{
	wchar_t buffer[256];


	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, L"Rate schedule resolution:");

	swprintf(buffer, L"ICB rate schedule: %d", mICBScheduleID);
	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

	swprintf(buffer, L"Product offering rate schedule: %d", mPOScheduleID);
	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

	swprintf(buffer, L"Default account rate schedule: %d",
					 mDefaultAccountScheduleID);
	aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);

	if (mPOScheduleModified != -1)
	{
		wchar_t * timeStr = _wctime(&mPOScheduleModified);
		std::wstring modified(timeStr, wcslen(timeStr) - 2);
		swprintf(buffer, L"Product offering rate schedule modified on: %s", modified.c_str());
		aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buffer);
	}
}

// Information specifiying a parameter table whose rates
// we are to process.
NTThreadLock ParameterTable::mThreadLock;

ParameterTable::ParameterTable(const _bstr_t& aParamTableName, 
															 long aWeightOnKeyID, 
															 long aStartAtID, 
															 long aInSessionID) 
	:
	mParamTableName(aParamTableName),
	mWeightOnKeyID(aWeightOnKeyID),
	mStartAtID(aStartAtID),
	mInSessionID(aInSessionID)
{
	mParamTableID = ReadParameterTableID(mParamTableName);
}

ParameterTable::ParameterTable(const _bstr_t& aParamTableName)
	:
	mParamTableName(aParamTableName),
	mWeightOnKeyID(-1),
	mStartAtID(-1),
	mInSessionID(-1)
{
	mParamTableID = ReadParameterTableID(mParamTableName);
}

MTPRODUCTCATALOGLib::IMTProductCatalogPtr ParameterTable::GetCatalog()
{
	AutoCriticalSection guard(&mThreadLock);
	static MTPRODUCTCATALOGLib::IMTProductCatalogPtr catalog;
	if(NULL == catalog)
	{
		HRESULT hr = catalog.CreateInstance("MetraTech.MTProductCatalog");
		if (FAILED(hr)) throw std::exception("Unable to create product catalog object");
	}
	return catalog;
}

int ParameterTable::ReadParameterTableID(const _bstr_t& aParamTableName)
{
	MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr paramTable;
	paramTable = GetCatalog()->GetParamTableDefinitionByName(aParamTableName);
	if (paramTable == NULL)
	{
		throw std::exception((std::string("Parameter table ")
													+ (const char *) aParamTableName
													+ " not found").c_str());
	}
	return paramTable->GetID();
}

ScoredRateInputSet::ScoredRateInputSet(const vector<ParameterTable>& aParameterTables)
	:
	mNumRequests(0)
{
	// For each parameter table, create an empty list of requests
	for(vector<ParameterTable>::const_iterator it = aParameterTables.begin(); it != aParameterTables.end(); it++)
	{
		mScoredSet[(*it).GetParamTableID()] = new vector<ScoredRateInputs>();
	}
}

ScoredRateInputSet::~ScoredRateInputSet()
{
	for(map<int, vector<ScoredRateInputs>* >::iterator it = mScoredSet.begin(); it != mScoredSet.end(); it++)
	{
		ASSERT((*it).second->size()==mNumRequests);
		vector<ScoredRateInputs>* save = (*it).second;
		mScoredSet[(*it).first] = NULL;
		delete save;
	}		
}

int ScoredRateInputSet::MakeRequest(MTPipelineLib::IMTSessionPtr aSession)
{
	// For every parameter table, make a slot for the 
	// request.  Initialize the slot with the parameter table id.
		
	for(map<int, vector<ScoredRateInputs>* >::iterator it = mScoredSet.begin(); it != mScoredSet.end(); it++)
	{
		ASSERT((*it).second->size()==mNumRequests);
		ScoredRateInputs inputs;
		inputs.mParamTableID = (*it).first;
		(*it).second->push_back(inputs);
	}

	mRequests[aSession->GetSessionID()] = mNumRequests;

	return mNumRequests++;
}

ScoredRateInputs& ScoredRateInputSet::GetRateInputs(int aParamTableID, int aRequestID)
{
	return mScoredSet[aParamTableID]->at(aRequestID);
}

ScoredRateInputs& ScoredRateInputSet::GetRateInputs(const ParameterTable& aParamTable, MTPipelineLib::IMTSessionPtr aSession)
{
	return mScoredSet[aParamTable.GetParamTableID()]->at(mRequests[aSession->GetSessionID()]);
}
	
bool ScoredRateInputSet::HasValidRateSchedule(int aParamTableID, int aRequestID)
{
	ScoredRateInputs & inputs = GetRateInputs(aParamTableID, aRequestID);
	return (inputs.mICBScheduleScore > _I64_MIN
					|| inputs.mPOScheduleScore > _I64_MIN
					|| inputs.mDefaultAccountScheduleScore > _I64_MIN);
}


bool ScoredRateInputSet::HasParamTable(int aParamTableID) const
{
	return mScoredSet.find(aParamTableID) != mScoredSet.end();
}

bool ScoredRateInputSet::UpdateRequest(int pt, int requestId, int sub, int po, int sched, time_t modifiedTimet, __int64 score)
{
	if (HasParamTable(pt))
	{
		ScoredRateInputs & rateInputs = GetRateInputs(pt, requestId);
		// this is our parameter table!
		// we compare the score of the rate schedule with the score of the
		// schedule we already have (if any).  We want the schedule with the
		// minimum score.  The score is initially the max score, so any rate schedule
		// will beat it.
		rateInputs.Update(sub, po, sched, modifiedTimet, score);
		return true;
	}
	else
	{
		return false;
	}
}

void ScoredRateInputSet::ToString(MTPipelineLib::IMTLogPtr aLogger) const
{
	for(map<int, vector<ScoredRateInputs>* >::const_iterator it = mScoredSet.begin(); it != mScoredSet.end(); it++)
	{
		for(vector<ScoredRateInputs>::const_iterator it2 = (*it).second->begin(); it2 != (*it).second->end(); it2++)
		{
			(*it2).ToString(aLogger);
		}
	}
}





