/**************************************************************************
 * RSIDCACHE
 *
 * Copyright 1997-2003 by MetraTech Corp.
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
 ***************************************************************************/

#include <metra.h>
#include <MTSessionBaseDef.h>
#include <RSIDCache.h>
#include <RSIDLookup.h>
#include <SetIterate.h>
#include <mtcomerr.h>

#import <MTProductCatalogInterfacesLib.tlb> rename("EOF", "EOFX")

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemPtr;
using MTPRODUCTCATALOGLib::IMTCollectionPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr;


RSIDCache::RSIDCache()
{
	mRefCount = 0;
}

int RSIDCache::AddRequest(CompoundPICache * piCache,
													int piTemplateID,
													int accountID, int cycleID,
													int defaultPL, unsigned long timestamp,
													int subID /* = - 1 */)
{
	AutoCriticalSection autolock(&mCacheLock);

	const SubPI * piInfo = 0;
	piInfo = piCache->FindPITemplate(piTemplateID);
	ASSERT(piInfo);

	int rootTemplateID = piInfo->GetCompound()->GetRootTemplateID();

	RSIDCacheKey key(accountID, timestamp, cycleID, defaultPL, rootTemplateID,
									 subID);
	map<RSIDCacheKey, int>::iterator it;

	int request;
	pair<map<RSIDCacheKey, int>::iterator, bool> insertResults =
		mRequestIDs.insert(map<RSIDCacheKey, int>::value_type(key, -1));
	if (insertResults.second)
	{
		// insertion was made - new request
		request = mRequestIDs.size();
		
		// update the value (request ID)
		ASSERT(insertResults.first->second == -1);
		insertResults.first->second = request;

		// insert a pointer to the key
		mNewRequests.push_back(&insertResults.first->first);
	}
	else
	{
		// no insertion made - previous request returned
		ASSERT(insertResults.first->second != -1);
		request = insertResults.first->second;
	}
	return request;
}

const RateInputs * RSIDCache::GetResults(int requestID, int piTemplateID, int paramTableID)
{
	AutoCriticalSection autolock(&mCacheLock);

	ResultKey key(piTemplateID, paramTableID, requestID, 0);

	map<ResultKey, ScoredRateInputs>::iterator it;
	it = mResults.find(key);
	if (it == mResults.end())
	{
		// no results found
		return 0;
	}
	else
	{
		ScoredRateInputs & inputs = it->second;
		return &inputs;
	}
}

void RSIDCache::Lookup(CompoundPICache * piCache,
											 RSIDLookup * lookup, ITransactionPtr tran)
{
	AutoCriticalSection autolock(&mCacheLock);
	if (mNewRequests.size() == 0)
		return;

	lookup->TruncateTempTable();

	// retrieve results for every request not cached
	vector<ResultKey> rows;
	vector<const RSIDCacheKey *>::iterator it;
	int row = 0;
	for (it = mNewRequests.begin(); it != mNewRequests.end(); ++it)
	{
		const RSIDCacheKey * key = *it;

		// for each priceable item that's part of the compound
		const SubPI * piInfo = 0;
		piInfo = piCache->FindPITemplate(key->GetRootTemplateID());
		ASSERT(piInfo);

		// insert requests for the rest of the compound as well
		const CompoundPI & compound = *piInfo->GetCompound();

		const vector<SubPI> & descendants = compound.GetDescendants();
		vector<SubPI>::const_iterator descit;
		for (descit = descendants.begin(); descit != descendants.end(); ++descit)
		{
			const SubPI & desc = *descit;

			int pi = desc.GetTemplateID();

			// param table is not yet known
			// TODO: don't do lookup
			int requestID = mRequestIDs[*key];
			ResultKey resKey(pi, -1, requestID, key);
			rows.push_back(resKey);

			lookup->InsertRequest(row++, key->GetAccountID(), key->GetCycleID(),
														key->GetDefaultPL(), key->GetTimestamp(),
														pi, key->GetSubID());
		}
	}
	lookup->ExecuteBatch();

	// walk the results, pushing them into the cache
	if (tran != NULL)
		lookup->JoinTransaction(tran);

	lookup->ExecuteQuery();

	ScoredRateInputs results;
	int resultRow;

	while (lookup->RetrieveResultRow(results, resultRow))
	{
		ResultKey resKey = rows[resultRow];
		// now we know the parameter table ID
		resKey.SetParameterTableID(results.mParamTableID);

		// TODO: this copies the results by value when doing an update
		pair<map<ResultKey, ScoredRateInputs>::iterator, bool> insertResults =
			mResults.insert(map<ResultKey, ScoredRateInputs>::value_type(resKey,
																																	 results));
		if (insertResults.second)
		{
			// first time we've seen these results
			// the key was copied in so there's nothing to do
		}
		else
		{
			// there were previous results.  update them.
			// TODO: make sure the previous results weren't from a different
			// run of the query.
			insertResults.first->second.Update(results);
		}
	}

	// results are cached
	mNewRequests.clear();

	if (tran != NULL)
		lookup->LeaveTransaction();

	lookup->ClearResults();
}


/******************************************* CompoundPICache ***/

int CompoundPI::GetRootTemplateID() const
{
	ASSERT(mAllDescendants.size() > 0);
	const SubPI & root = mAllDescendants.front();
	ASSERT(!root.IsChild());
	return root.GetTemplateID();
}

const _bstr_t & SubPI::GetName() const
{
	if (mCachedName.length() > 0)
		return mCachedName;

	// do the lookup
	IMTProductCatalogPtr pc("MetraTech.MTProductCatalog");

	IMTPriceableItemPtr pi = pc->GetPriceableItem(mTemplate);
	mCachedName = pi->GetName();

	return mCachedName;
}

CompoundPICache::~CompoundPICache()
{
	vector<CompoundPI *>::iterator it;
	for (it = mCompounds.begin(); it != mCompounds.end(); ++it)
		delete *it;
}

static void FindChildren(CompoundPI & compound,
												 IMTPriceableItemPtr pi)
{
	SubPI subPI(pi->ID, &compound, pi->PriceableItemType->ID, pi->ParentID != -1);
	compound.AddDescendant(subPI);

	MTPRODUCTCATALOGLib::IMTCollectionPtr children = pi->GetChildren();

	SetIterator<MTPRODUCTCATALOGLib::IMTCollectionPtr, IMTPriceableItemPtr> it;
	HRESULT hr = it.Init(children);
	if (FAILED(hr))
		MT_THROW_COM_ERROR(hr);
	while (true)
	{
		IMTPriceableItemPtr child = it.GetNext();
		if (child == NULL)
			break;
		FindChildren(compound, child);
	}
}

const SubPI * CompoundPICache::FindPITemplate(int piTemplate)
{
	map<int, const SubPI *>::iterator findit = mPIsByID.find(piTemplate);
	if (findit != mPIsByID.end())
	{
		// cached
		return findit->second;
	}

	// do the lookup
	IMTProductCatalogPtr pc("MetraTech.MTProductCatalog");

	// find the root
	IMTPriceableItemPtr pi = pc->GetPriceableItem(piTemplate);
	IMTPriceableItemPtr parent = pi->GetParent();
	while (parent != 0)
	{
		pi = parent;
		parent = pi->GetParent();
	}

	CompoundPI * compound = new CompoundPI();
	mCompounds.push_back(compound);

	// recursively find all children
	FindChildren(*compound, pi);

	// add all the descendants to the cache
	const vector<SubPI> & descendants = compound->GetDescendants();
	vector<SubPI>::const_iterator it;
	for (it = descendants.begin(); it != descendants.end(); ++it)
	{
		const SubPI & desc = *it;
		mPIsByID[desc.GetTemplateID()] = &desc;
	}

	// try again (hopefully it works this time)
	findit = mPIsByID.find(piTemplate);
	if (findit != mPIsByID.end())
		return findit->second;
	else
	{
		// probably caused by a bug.
		ASSERT(0);
		return 0;
	}
}

const SubPI * CompoundPICache::FindPITemplate(const wchar_t * piTemplate)
{
	map<wstring, const SubPI *>::iterator findit = mPIsByName.find(piTemplate);
	if (findit != mPIsByName.end())
	{
		// cached
		return findit->second;
	}

	// look up the priceable item by name
	// do the lookup
	IMTProductCatalogPtr pc("MetraTech.MTProductCatalog");

	// find the root
	IMTPriceableItemPtr pi = pc->GetPriceableItemByName(piTemplate);
	if (pi == 0)
		// priceable item not found
		return 0;

	const SubPI * subPI = FindPITemplate(pi->ID);
	if (!subPI)
	{
		ASSERT(0);
		return 0;
	}
	mPIsByName[piTemplate] = subPI;
	ASSERT(mPIsByName.find(piTemplate) != mPIsByName.end());
	return subPI;
}
