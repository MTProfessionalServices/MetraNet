/**************************************************************************
 * @doc
 * 
 * Copyright 2002 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Carl Shimer
 * $Header$
 *
 ***************************************************************************/

#include <autoinstance.h>
#include <autoptr.h>
#include <map>
#include <vector>
#include <OdbcConnection.h>
#include <comutil.h>
#include <comip.h>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <OdbcType.h>

using namespace std;

class MTHierarchyMember;

typedef  MTautoptr<MTHierarchyMember> ManagedHierarchyMember;
typedef vector<ManagedHierarchyMember> ManagedChildList;
typedef vector<ManagedHierarchyMember>::iterator ManagedChildIter;

typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcTableInsertStatement> COdbcTableInsertStatementPtr;
typedef MTAutoCreatePtr<ManagedChildList> MemberChildList;
typedef map<long,ManagedHierarchyMember> HierarchyMap;
typedef MTAutoCreatePtr<vector<pair<long,long> > > ParentList;
typedef vector<pair<long,long> >::iterator ParentListIter;
class MTHierarchyMember {

public:
	MTHierarchyMember() : mAncestor(-1), mDescendent(-1), bFound(false) {}
	virtual ~MTHierarchyMember() {}
	long mAncestor;
	long mDescendent;
	COdbcTimestamp StartTime;
	COdbcTimestamp EndTime;

	void SetFound() { bFound = true; }
	bool Found() { return bFound; }
	void AddChild(ManagedHierarchyMember);
	bool HasChildren();
	ManagedChildIter ChildrenIter();
	ManagedChildIter End();

protected:
	bool bFound;
	MemberChildList mChildList;

};

	const long BATCH_SIZE = 100;

class MTBatchHierarchyLoaderAbstract;
typedef MTautoptr<MTBatchHierarchyLoaderAbstract> MTBatchHierarchyLoaderAbstractPtr;


class MTBatchHierarchyLoaderAbstract {

private:

public:
		virtual ~MTBatchHierarchyLoaderAbstract() {}


	virtual void LoadFromTable() = 0;
	virtual void SortAndCommitToTempTable() = 0;
	virtual void InsertIntoHierarchy() = 0;
};

class BatchCreateMgr {

public:
	static MTBatchHierarchyLoaderAbstractPtr 
		CreateInstance(
		string sourceTable,string outputTable,
		COdbcConnectionPtr aConnection,MTPipelineLib::IMTTransactionPtr transaction);
};
