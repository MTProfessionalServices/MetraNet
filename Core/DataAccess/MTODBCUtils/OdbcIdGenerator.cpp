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

#include "OdbcIdGenerator.h"
#include "OdbcStatement.h"
#include "OdbcException.h"
#include "OdbcResultSet.h"
#include "autocritical.h"

class COdbcBadConnections
{
private:
  std::vector<COdbcConnection*> mBadConnections;
public:
  COdbcBadConnections()
  {
  }
  ~COdbcBadConnections()
  {
    for(std::vector<COdbcConnection*>::iterator it = mBadConnections.begin();
        it != mBadConnections.end();
        ++it)
    {
      delete *it;
    }
  }
  void push_back(COdbcConnection* conn)
  {
    mBadConnections.push_back(conn);
  }
};



DWORD COdbcIdGenerator::msNumRefs = 0;
COdbcIdGenerator* COdbcIdGenerator::mpsInstance = 0;
NTThreadLock COdbcIdGenerator::msLock;

// Get a single instance of the COdbcIdGenerator for a type of connection
// Currently only one COdbcIdGenerator is supported, meaning:
//   all request's must use the same connection info, or an exception will be thrown
//   If in the future support for different COdbcConnectionInfos is needed
//   store a map instead of a single instance.
COdbcIdGenerator* COdbcIdGenerator::GetInstance(const COdbcConnectionInfo& aInfo)
{
	AutoCriticalSection lock(&msLock);

	// if the object does not exist..., create a new one
	if (mpsInstance == 0)
	{
		mpsInstance = new COdbcIdGenerator(aInfo);
	}
	else
	{
		//verify the COdbcConnectionInfo matches
		if (mpsInstance->mInfo != aInfo)
		{
			ASSERT(0);
			throw COdbcException("COdbcIdGenerator only supports one COdbcConnectionInfo");
		}
	}

	// if we got a valid pointer.. increment...
	if (mpsInstance != 0)
	{
	    msNumRefs++;
	}

	return (mpsInstance);
}

void COdbcIdGenerator::ReleaseInstance()
{
	AutoCriticalSection lock(&msLock);

	// decrement the reference counter
	if (mpsInstance != 0)
	{
		msNumRefs--;
	}

	// if the number of references is 0, delete the pointer
	if (msNumRefs == 0)
	{
		delete mpsInstance;
		mpsInstance = 0;
	}
}


COdbcIdGenerator::~COdbcIdGenerator()
{
	delete mConnection;

	for (SequenceMap::iterator it = mSequences.begin(); it != mSequences.end(); it++)
		delete it->second;
}

void COdbcIdGenerator::GetNextBlock(Sequence* sequence, bool retry /* = false */)
{
  COdbcBadConnections badBoys;
  int i=2;
  while(i-- > 0)
  {
    bool propagateException = false;
    try
    {
      if (mConnection == NULL)
      {
        mConnection = new COdbcConnection(mInfo);
        mConnection->SetAutoCommit(false);
        if (!mIsOracle)
          // SQL Server needs the connection to have serializable isolation level
          mConnection->SetTransactionIsolation(COdbcConnection::READ_COMMITTED);
      }
      ASSERT(mConnection);
	
      // Select out the next current available block of ids
      COdbcStatement* selectStmt = mConnection->CreateStatement();
      COdbcResultSet* rs = selectStmt->ExecuteQuery(sequence->selectQuery);
      bool result = rs->Next();
      if (!result)
      {
        propagateException = true;
        throw COdbcException("Unable to retrieve current id_sess value from t_current_id");
      }

      ASSERT(result);
      int start = rs->GetInteger(1);
      ASSERT(!rs->Next());
      delete rs;
      rs = NULL;
      delete selectStmt;
      selectStmt = NULL;

      COdbcStatement* updateStmt = mConnection->CreateStatement();
      int numRows = updateStmt->ExecuteUpdate(sequence->updateQuery);
      delete updateStmt;
      updateStmt = NULL;

      mConnection->CommitTransaction();

      sequence->currentBlockStart = start;
      sequence->currentBlockEnd = sequence->currentBlockStart + int(1000);

      // Success, get outta here.
      return;
    }
    catch (COdbcException & e)
    {
      // propagates the one exception this method raises itself
      // or passes on the connectivity exception to the caller if
      // retrying didn't help
      if (propagateException || 0==i)
        throw;
		
      LoggerConfigReader configReader;
      NTLogger logger;
      logger.Init(configReader.ReadConfiguration("logging"), "[ODBC]");
      logger.LogVarArgs(LOG_WARNING, "ODBC exception caught in COdbcIdGenerator: %s", e.what());
      logger.LogThis(LOG_WARNING, "Retrying...");

      // assumes that the ODBC exception is due to a connectivity issue
      badBoys.push_back(mConnection);
      mConnection = NULL;
    }
  }
}

int COdbcIdGenerator::GetNext(const std::string & sequenceName /* = "id_sess" */)
{
	AutoCriticalSection lock(&msLock);

	// looks up the sequence based on the given name
	Sequence* sequence = NULL;
	SequenceMap::const_iterator it = mSequences.find(sequenceName);
	if (it == mSequences.end())
		sequence = CreateSequence(sequenceName);
	else
		sequence = it->second;
	ASSERT(sequence);

	if (sequence->currentBlockStart == sequence->currentBlockEnd)
	{
		GetNextBlock(sequence);
		ASSERT(sequence->currentBlockStart < sequence->currentBlockEnd);
	}
	
	return sequence->currentBlockStart++;
}

COdbcIdGenerator::Sequence* COdbcIdGenerator::CreateSequence(const std::string & sequenceName)
{
	Sequence* sequence = new Sequence;

	if (mIsOracle)
		sequence->selectQuery = "SELECT id_current FROM t_current_id WHERE nm_current = '" + sequenceName + "' FOR UPDATE OF id_current ";
	else
		sequence->selectQuery = "SELECT id_current FROM t_current_id WITH(UPDLOCK) WHERE nm_current = '" + sequenceName + "' ";
	sequence->updateQuery = "UPDATE t_current_id SET id_current = id_current + 1000 WHERE nm_current = '" + sequenceName + "'";

	mSequences.insert(SequenceMapPair(sequenceName, sequence));

	return sequence;
}




DWORD COdbcLongIdGenerator::msNumRefs = 0;
COdbcLongIdGenerator* COdbcLongIdGenerator::mpsInstance = 0;
NTThreadLock COdbcLongIdGenerator::msLock;

// Get a single instance of the COdbcLongIdGenerator for a type of connection
// Currently only one COdbcLongIdGenerator is supported, meaning:
//   all request's must use the same connection info, or an exception will be thrown
//   If in the future support for different COdbcConnectionInfos is needed
//   store a map instead of a single instance.
COdbcLongIdGenerator* COdbcLongIdGenerator::GetInstance(const COdbcConnectionInfo& aInfo)
{
	AutoCriticalSection lock(&msLock);

	// if the object does not exist..., create a new one
	if (mpsInstance == 0)
	{
		mpsInstance = new COdbcLongIdGenerator(aInfo);
	}
	else
	{
		//verify the COdbcConnectionInfo matches
		if (mpsInstance->mInfo != aInfo)
		{
			ASSERT(0);
			throw COdbcException("COdbcLongIdGenerator only supports one COdbcConnectionInfo");
		}
	}

	// if we got a valid pointer.. increment...
	if (mpsInstance != 0)
	{
	    msNumRefs++;
	}

	return (mpsInstance);
}

void COdbcLongIdGenerator::ReleaseInstance()
{
	AutoCriticalSection lock(&msLock);

	// decrement the reference counter
	if (mpsInstance != 0)
	{
		msNumRefs--;
	}

	// if the number of references is 0, delete the pointer
	if (msNumRefs == 0)
	{
		delete mpsInstance;
		mpsInstance = 0;
	}
}


COdbcLongIdGenerator::~COdbcLongIdGenerator()
{
	delete mConnection;

	for (SequenceMap::iterator it = mSequences.begin(); it != mSequences.end(); it++)
		delete it->second;
}

void COdbcLongIdGenerator::GetNextBlock(Sequence* sequence, bool retry /* = false */)
{
  COdbcBadConnections badBoys;
  int i=2;
  while(i-- > 0)
  {
    bool propagateException = false;
    try
    {
      if (mConnection == NULL)
      {
        mConnection = new COdbcConnection(mInfo);
        mConnection->SetAutoCommit(false);
        if (!mIsOracle)
          // SQL Server needs the connection to have serializable isolation level
          mConnection->SetTransactionIsolation(COdbcConnection::READ_COMMITTED);
      }
      ASSERT(mConnection);
	
      // Select out the next current available block of ids
      COdbcStatement* selectStmt = mConnection->CreateStatement();
      COdbcResultSet* rs = selectStmt->ExecuteQuery(sequence->selectQuery);
      bool result = rs->Next();
      if (!result)
      {
        propagateException = true;
        throw COdbcException("Unable to retrieve current id_sess value from t_current_long_id");
      }

      ASSERT(result);
      __int64 start = rs->GetBigInteger(1);
      ASSERT(!rs->Next());
      delete rs;
      rs = NULL;
      delete selectStmt;
      selectStmt = NULL;
		
      COdbcStatement* updateStmt = mConnection->CreateStatement();
      int numRows = updateStmt->ExecuteUpdate(sequence->updateQuery);
      delete updateStmt;
      updateStmt = NULL;
		
      mConnection->CommitTransaction();

      sequence->currentBlockStart = start;
      sequence->currentBlockEnd = sequence->currentBlockStart + __int64(10000);

      return;
    }
    catch (COdbcException & e)
    {
      // propagates the one exception this method raises itself
      // or passes on the connectivity exception to the caller if
      // retrying didn't help
      if (propagateException || i==0)
        throw;
		
      LoggerConfigReader configReader;
      NTLogger logger;
      logger.Init(configReader.ReadConfiguration("logging"), "[ODBC]");
      logger.LogVarArgs(LOG_WARNING, "ODBC exception caught in COdbcLongIdGenerator: %s", e.what());
      logger.LogThis(LOG_WARNING, "Retrying...");

      // assumes that the ODBC exception is due to a connectivity issue
      badBoys.push_back(mConnection);
      mConnection = NULL;
    }
  }
}

__int64 COdbcLongIdGenerator::GetNext(const std::string & sequenceName /* = "id_sess" */)
{
	AutoCriticalSection lock(&msLock);

	// looks up the sequence based on the given name
	Sequence* sequence = NULL;
	SequenceMap::const_iterator it = mSequences.find(sequenceName);
	if (it == mSequences.end())
		sequence = CreateSequence(sequenceName);
	else
		sequence = it->second;
	ASSERT(sequence);

	if (sequence->currentBlockStart == sequence->currentBlockEnd)
	{
		GetNextBlock(sequence);
		ASSERT(sequence->currentBlockStart < sequence->currentBlockEnd);
	}
	
	return sequence->currentBlockStart++;
}

COdbcLongIdGenerator::Sequence* COdbcLongIdGenerator::CreateSequence(const std::string & sequenceName)
{
	Sequence* sequence = new Sequence;

	if (mIsOracle)
		sequence->selectQuery = "SELECT id_current FROM t_current_long_id WHERE nm_current = '" + sequenceName + "' FOR UPDATE OF id_current ";
	else
		sequence->selectQuery = "SELECT id_current FROM t_current_long_id WITH(UPDLOCK) WHERE nm_current = '" + sequenceName + "' ";
	sequence->updateQuery = "UPDATE t_current_long_id SET id_current = id_current + 10000 WHERE nm_current = '" + sequenceName + "'";

	mSequences.insert(SequenceMapPair(sequenceName, sequence));

	return sequence;
}



