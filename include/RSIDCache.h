/**************************************************************************
 * @doc RSIDCACHE
 *
 * @module |
 *
 *
 * Copyright 2003 by MetraTech Corporation
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
 * @index | RSIDCACHE
 ***************************************************************************/

#ifndef _RSIDCACHE_H
#define _RSIDCACHE_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <map>
#include <vector>
using std::map;
using std::vector;

#include <RateLookup.h>
#include <NTThreadLock.h>
#include <autocritical.h>
#import <MTPipelineLib.tlb>
using MTPipelineLib::IMTTransactionPtr;

#include <txdtc.h>  // distributed transaction support
_COM_SMARTPTR_TYPEDEF(ITransaction, IID_ITransaction);

class CompoundPICache;
class CompoundPI;
class SubPI;

class RSIDLookup;


class RSIDCacheKey
{
public:
	RSIDCacheKey(int accountID, unsigned long timestamp,
							 int cycleID,
							 int defaultPL, int rootTemplateID,
							 int subID = -1)
		: mAccountID(accountID),
			mTimestamp(timestamp),
			mSubID(subID),
			mCycleID(cycleID),
			mDefaultPL(defaultPL),
			mRootTemplateID(rootTemplateID)
	{ }

	bool operator == (const RSIDCacheKey & other) const
	{
		return mAccountID == other.mAccountID
			&& mTimestamp == other.mTimestamp
			&& mSubID == other.mSubID
			&& mCycleID == other.mCycleID
			&& mDefaultPL == other.mDefaultPL
			&& mRootTemplateID == other.mRootTemplateID;
	}

	bool operator < (const RSIDCacheKey & other) const
	{
		if (mAccountID < other.mAccountID)
			return true;

		if (mAccountID > other.mAccountID)
			return false;

		if (mTimestamp < other.mTimestamp)
			return true;

		if (mTimestamp > other.mTimestamp)
			return false;

		if (mSubID < other.mSubID)
			return true;

		if (mSubID > other.mSubID)
			return false;

		if (mCycleID < other.mCycleID)
			return true;

		if (mCycleID > other.mCycleID)
			return false;

		if (mDefaultPL < other.mDefaultPL)
			return true;

		if (mDefaultPL > other.mDefaultPL)
			return false;

		return (mRootTemplateID < other.mRootTemplateID);
	}

	int GetAccountID() const
	{ return mAccountID; }
	unsigned long GetTimestamp() const
	{ return mTimestamp; }
	int GetSubID() const
	{ return mSubID; }
	int GetCycleID() const
	{ return mCycleID; }
	int GetDefaultPL() const
	{ return mDefaultPL; }
	int GetRootTemplateID() const
	{ return mRootTemplateID; }

private:
	int mAccountID;
	unsigned long mTimestamp;
	int mSubID;
	int mCycleID;
	int mDefaultPL;
	int mRootTemplateID;
};

class ResultKey
{
public:
	ResultKey(int piTemplateID, int paramTableID, int requestID,
						const RSIDCacheKey * params)
		: mPITemplate(piTemplateID),
			mTable(paramTableID),
			mRequestID(requestID)
	{ }

	void SetParameterTableID(int paramTableID)
	{
		mTable = paramTableID;
	}

	bool operator ==(const ResultKey & other) const
	{
		return mPITemplate == other.mPITemplate
			&& mTable == other.mTable
			&& mRequestID == other.mRequestID;
	}

	bool operator < (const ResultKey & other) const
	{
		if (mPITemplate < other.mPITemplate)
			return true;
		if (mPITemplate > other.mPITemplate)
			return false;
		
		if (mTable < other.mTable)
			return true;
		if (mTable > other.mTable)
			return false;
		
		return mRequestID < other.mRequestID;
	}

private:
	int mPITemplate;
	int mTable;
	int mRequestID;
};


class SubPI
{
public:
	SubPI(int templateID, CompoundPI * compound, int piType, bool isChild)
		: mCompound(compound),
			mPIType(piType),
			mIsChild(isChild),
			mTemplate(templateID)
	{ }

	const CompoundPI * GetCompound() const
	{ return mCompound; }

	int GetTypeID() const
	{ return mPIType; }

	bool IsChild() const
	{ return mIsChild; }

	int GetTemplateID() const
	{ return mTemplate; }

	const _bstr_t & GetName() const;

private:
	CompoundPI * mCompound;
	int mPIType;
	bool mIsChild;
	int mTemplate;
	mutable _bstr_t mCachedName;
};

class CompoundPI
{
public:
	const vector<SubPI> & GetDescendants() const
	{ return mAllDescendants; }

	void AddDescendant(const SubPI & desc)
	{ mAllDescendants.push_back(desc); }

	int GetRootTemplateID() const;
private:
	// a list of all child priceable items, including the root
	vector<SubPI> mAllDescendants;
};

class CompoundPICache
{
public:
	~CompoundPICache();

	// lookup a priceable item template by ID
	const SubPI * FindPITemplate(int piTemplate);

	// lookup a priceable item template by name
	const SubPI * FindPITemplate(const wchar_t * piTemplate);

private:
	// priceable item to compound
	map<int, const SubPI *> mPIsByID;
	map<wstring, const SubPI *> mPIsByName;
	vector<CompoundPI *> mCompounds;
};

// this class implements IUnknown only so it's easy to reference from
// the pipeline's objects
class RSIDCache : public IUnknown
{
public:
	RSIDCache();

	virtual HRESULT STDMETHODCALLTYPE QueryInterface( 
		/* [in] */ REFIID riid,
		/* [iid_is][out] */ void **ppvObject)
	{ return E_NOINTERFACE; }
            
	virtual ULONG STDMETHODCALLTYPE AddRef( void)
	{
    InterlockedIncrement(&mRefCount);
    return mRefCount;
	}

	virtual ULONG STDMETHODCALLTYPE Release( void)
	{
    // Decrement the object's internal counter
    ULONG refCount = InterlockedDecrement(&mRefCount);

    if (0 == mRefCount)
			delete this;

    return refCount;
	}

public:
	int AddRequest(CompoundPICache * piCache,
								 int piTemplateID,
								 int accountID, int cycleID,
								 int defaultPL, unsigned long timestamp, int subID = - 1);

	// lookup all requests
	void Lookup(CompoundPICache * piCache, RSIDLookup * lookup,
							ITransactionPtr tran);

	// clear previously retrieved values
	void Clear();

	const RateInputs * GetResults(int requestID, int piTemplateID, int paramTableID);


private:
//	RSIDLookup * mLookup;

	long mRefCount;

	int mLastLookup;

	map<RSIDCacheKey, int> mRequestIDs;
	vector<const RSIDCacheKey *> mNewRequests;
	map<ResultKey, ScoredRateInputs> mResults;

	NTThreadLock mCacheLock;
	NTThreadLock mLookupLock;
};


#endif /* _RSIDCACHE_H */
