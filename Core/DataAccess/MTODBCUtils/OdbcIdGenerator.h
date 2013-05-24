/**************************************************************************
* Copyright 1997-2001 by MetraTech
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

#ifndef _ODBCIDGENERATOR_H_
#define _ODBCIDGENERATOR_H_

#include <metra.h>
#include <NTThreadLock.h>
#include "OdbcConnection.h"
#include <map>

// TODO: remove undefs
#if defined(MTODBCUTILS_DEF)
#undef DllExport
#define DllExport __declspec(dllexport)
#else
#undef DllExport
#define DllExport
#endif

// a singleton
// can't use MTSingleton, since COdbcConnectionInfo needs to be passed in
class COdbcIdGenerator
{
private:
	struct Sequence
	{
		Sequence() : currentBlockStart(0), currentBlockEnd(0)
		{	}

		int currentBlockStart;
		int currentBlockEnd;

		std::string selectQuery;
		std::string updateQuery;
	};

	typedef std::map<string, Sequence*> SequenceMap;
	typedef std::pair<std::string, Sequence*> SequenceMapPair;

private:
	static COdbcIdGenerator* mpsInstance;
	static NTThreadLock msLock;
	static DWORD msNumRefs;

	COdbcConnectionInfo mInfo;
	COdbcConnection* mConnection;
	bool mIsOracle;

	SequenceMap mSequences;

private:	
	COdbcIdGenerator(const COdbcConnectionInfo& aInfo) : mInfo(aInfo), mConnection(NULL) 
	{
		mIsOracle = (mInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
	}

	virtual ~COdbcIdGenerator();

	Sequence* CreateSequence(const std::string & sequenceName);
	void GetNextBlock(Sequence* sequence, bool retry = false);

public:
	DllExport static COdbcIdGenerator * GetInstance(const COdbcConnectionInfo& aInfo);
	DllExport static void ReleaseInstance();

	// gets the next available ID for the given sequence name
	// by default, the sequence defaults to 'id_sess' used in t_acc_usage
	// other sequence names can be found in t_current_id
	DllExport int GetNext(const std::string & sequenceName = "id_sess");
};

class COdbcLongIdGenerator
{
private:
	struct Sequence
	{
		Sequence() : currentBlockStart(0), currentBlockEnd(0)
		{	}

		__int64 currentBlockStart;
		__int64 currentBlockEnd;

		std::string selectQuery;
		std::string updateQuery;
	};

	typedef std::map<string, Sequence*> SequenceMap;
	typedef std::pair<std::string, Sequence*> SequenceMapPair;

private:
	static COdbcLongIdGenerator* mpsInstance;
	static NTThreadLock msLock;
	static DWORD msNumRefs;

	COdbcConnectionInfo mInfo;
	COdbcConnection* mConnection;
	bool mIsOracle;

	SequenceMap mSequences;

private:	
	COdbcLongIdGenerator(const COdbcConnectionInfo& aInfo) : mInfo(aInfo), mConnection(NULL) 
	{
		mIsOracle = (mInfo.GetDatabaseType() == COdbcConnectionInfo::DBTYPE_ORACLE);
	}

	virtual ~COdbcLongIdGenerator();

	Sequence* CreateSequence(const std::string & sequenceName);
	void GetNextBlock(Sequence* sequence, bool retry = false);

public:
	DllExport static COdbcLongIdGenerator * GetInstance(const COdbcConnectionInfo& aInfo);
	DllExport static void ReleaseInstance();

	// gets the next available ID for the given sequence name
	// by default, the sequence defaults to 'id_sess' used in t_acc_usage
	// other sequence names can be found in t_current_id
	DllExport __int64 GetNext(const std::string & sequenceName = "id_sess");
};

#endif

