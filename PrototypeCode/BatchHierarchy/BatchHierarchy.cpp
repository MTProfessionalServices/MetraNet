/**************************************************************************
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
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include <BatchHierarchy.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcResultSet.h>

//////////////////////////////////////////////////////////////////////////
// implementation class
//////////////////////////////////////////////////////////////////////////

class MTBatchHierarchyLoader : public MTBatchHierarchyLoaderAbstract {

public:
	MTBatchHierarchyLoader(string sourceTable,string outputTable,
		COdbcConnectionPtr aConnection,MTPipelineLib::IMTTransactionPtr transaction);
		virtual ~MTBatchHierarchyLoader() {}


	void LoadFromTable();
	void SortAndCommitToTempTable();
	void InsertIntoHierarchy();


protected: // methods
	void RecurseSortedNodes(ManagedHierarchyMember aMember,ParentList& aParentList);
	void InsertRow(long mAncestor,long mDescendent,long numGenerations,bool children,
		COdbcTimestamp& start,COdbcTimestamp& end);
	void CommitOutstanding();


protected: //data

	string mSourceTable;
	string mOutputTable;
	HierarchyMap mProcessMap;
	MTPipelineLib::IMTTransactionPtr mCurrentTransaction;
	COdbcConnectionPtr mConnection;
	COdbcPreparedArrayStatementPtr mFetchStatement;
	COdbcTableInsertStatementPtr mInsertStatement;
	long mRowCount;

};


//////////////////////////////////////////////////////////////////////////


typedef pair<long,long> LevelPair;
typedef MTautoptr<COdbcPreparedResultSet> COdbcPreparedResultSetPtr;

void MTHierarchyMember::AddChild(ManagedHierarchyMember aChild)
{
	mChildList->push_back(aChild);
}

bool MTHierarchyMember::HasChildren()
{
	return mChildList; // evaluates wether we have any children
}

ManagedChildIter MTHierarchyMember::ChildrenIter()
{
	if(HasChildren()) {
		return mChildList->begin();
	}
	else {
		// XXX fix error code
		ErrorObject aError(-1,ERROR_MODULE,ERROR_LINE,"MTHierarchyMember::ChildrenIter()");
		throw aError;
	}
}

ManagedChildIter MTHierarchyMember::End()
{
	if(HasChildren()) {
		return mChildList->end();
	}
	else {
		// XXX fix error code
		ErrorObject aError(-1,ERROR_MODULE,ERROR_LINE,"MTHierarchyMember::End");
		throw aError;
	}
}

 MTBatchHierarchyLoaderAbstractPtr 
		BatchCreateMgr::CreateInstance(
		string sourceTable,string outputTable,
		COdbcConnectionPtr aConnection,MTPipelineLib::IMTTransactionPtr transaction)
{
	return new MTBatchHierarchyLoader(sourceTable,outputTable,
		aConnection,transaction);

}



	MTBatchHierarchyLoader::MTBatchHierarchyLoader(string sourceTable,string outputTable,
		COdbcConnectionPtr aConnection,MTPipelineLib::IMTTransactionPtr transaction)
{
	mSourceTable = sourceTable;
	mOutputTable = outputTable;
	mConnection = aConnection;
	mCurrentTransaction = transaction;

	mFetchStatement = 
		mConnection->PrepareStatementFromFile("queries\\AccHierarchies", "__GET_NEWHIERACHYENTRIES__");
			
	mInsertStatement = mConnection->PrepareInsertStatement(outputTable,100);

	mRowCount = 0;

}


void MTBatchHierarchyLoader::LoadFromTable()
{

	COdbcPreparedResultSetPtr resultSet = mFetchStatement->ExecuteQuery();
	
	while(resultSet->Next()) {
		ManagedHierarchyMember newMember = new MTHierarchyMember();
		newMember->mAncestor = resultSet->GetInteger(1);
		newMember->mDescendent = resultSet->GetInteger(2);
		newMember->StartTime = resultSet->GetTimestamp(3);
		newMember->EndTime = resultSet->GetTimestamp(4);
		mProcessMap[newMember->mDescendent] = newMember;
	}
}


void MTBatchHierarchyLoader::SortAndCommitToTempTable()
{
	// iterate through the map
	HierarchyMap::iterator mapIter = mProcessMap.begin();
	while(mapIter != mProcessMap.end()) {

		// see if our parent exists
		HierarchyMap::iterator findIter = mProcessMap.find(mapIter->second->mAncestor);
		if(findIter != mProcessMap.end()) {
			// we found our parent.  Mark it found and add to childlist of parent
			mapIter->second->SetFound();
			findIter->second->AddChild(mapIter->second);
		}
		mapIter++;
	}


	// time for a little bit of recursion.  It wouldn't 
	// be a tree processing algorithm if we didn't have recursion, right?
	//
	// We may want to consider replacing this stack based recursive
	// approach with iteration; however, most hierarchy implementations
	// will never be more than 10 levels deep so I don't think it is 
	// much of a problem.

	ParentList mEmptyList;


	mapIter = mProcessMap.begin();
	while(mapIter != mProcessMap.end()) {
		// we only want the nodes that were not found
		if(!mapIter->second->Found()) {
			RecurseSortedNodes(mapIter->second,mEmptyList);
		}
		mapIter++;
	}

	// commit outstanding records
	CommitOutstanding();
}

void MTBatchHierarchyLoader::RecurseSortedNodes(ManagedHierarchyMember aMember,
																								ParentList& aParentList)
{
	// add self pointer
	InsertRow(aMember->mDescendent,aMember->mDescendent,
		0,aMember->HasChildren(),aMember->StartTime,aMember->EndTime);

	ParentList LevelList;
	bool bHasChildren = aMember->HasChildren();
	// add the parent records that are in the vector
	if(bHasChildren) {
		LevelList->push_back(LevelPair(aMember->mDescendent,1));
	}

	ParentListIter it = aParentList->begin();
	while(it != aParentList->end()) {
		// add the rows that point to the parent
		InsertRow((*it).first,
			aMember->mDescendent,
			(*it).second,
			aMember->HasChildren(),aMember->StartTime,aMember->EndTime);
		if(bHasChildren) {
			LevelList->push_back(LevelPair((*it).first,(*it).second + 1));
		}
		it++;
	}

	// iterate through the children and call them
	if(bHasChildren) {
		ManagedChildIter aIter = aMember->ChildrenIter();
		while(aIter != aMember->End()) {
			RecurseSortedNodes((*aIter),LevelList);
			aIter++;
		}
	}
}


void MTBatchHierarchyLoader::InsertIntoHierarchy()
{

}

//////////////////////////////////////////////////////////////////
// protected methods
//////////////////////////////////////////////////////////////////

void MTBatchHierarchyLoader::InsertRow(long mAncestor,long mDescendent,
																			 long numGenerations,bool children,
																				COdbcTimestamp& start,COdbcTimestamp& end)
{
	COdbcPreparedArrayStatement* pInsertStatemnt = mInsertStatement;

	if(mRowCount == BATCH_SIZE) {
		pInsertStatemnt->ExecuteBatch();
		mRowCount = 0;
	}
	if(mRowCount == 0) {
		pInsertStatemnt->BeginBatch();
	}
	pInsertStatemnt->SetInteger(1,mAncestor);
	pInsertStatemnt->SetInteger(2,mDescendent);
	pInsertStatemnt->SetInteger(3,numGenerations);
	pInsertStatemnt->SetString(4,children == true ? "Y" : "N");
	pInsertStatemnt->SetDatetime(5,start);
	pInsertStatemnt->SetDatetime(6,end);
	mRowCount++;
	pInsertStatemnt->AddBatch();

}

void MTBatchHierarchyLoader::CommitOutstanding()
{
	if(mRowCount > 0) {
		mInsertStatement->ExecuteBatch();
	}
}



