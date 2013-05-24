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

#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>
#include <autoptr.h>

#include "OdbcSessionMapping.h"
#include "OdbcSessionRouter.h"

#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcPreparedArrayStatement.h"
#include "OdbcException.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"
#include "OdbcSessionTypeConversion.h"
#include "DistributedTransaction.h"

#include <RowsetDefs.h>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

// Stuff for shared session impl.
#include "OdbcSessionWriterSession.h"

#import <MTConfigLib.tlb>
#include <pipelineconfig.h>
#include <perflog.h>

std::string& PropertyError(long aPropId, std::string& arMessage)
{
	arMessage = "Property error: ";

	static BOOL propIdsInitialize = FALSE;

	if (!propIdsInitialize)
		PipelinePropIDs::Init();

	// NOTE: since creating a name ID object to generate a verbose error string
	// is expensive, it's not done for some of the pipeline's "special" reserved
	// properties which frequently don't exist.
	if (aPropId != PipelinePropIDs::ProfileStageCode()
			&& aPropId != PipelinePropIDs::NewParentIDCode()
			&& aPropId != PipelinePropIDs::NewParentInternalIDCode()
			&& aPropId != PipelinePropIDs::NextStageCode())
	{
		try
		{
			MTPipelineLib::IMTNameIDPtr nameid(MTPROGID_NAMEID);

			std::wstring name = nameid->GetName(aPropId);
			StrToLower(name);

			arMessage += ascii(name);

			cerr << arMessage << endl;

			return arMessage;
		}
		catch (_com_error &)
		{
			// fall through
		}
	}

	arMessage += "unknown";
	return arMessage;
}


COdbcSessionWriter::COdbcSessionWriter(COdbcLongIdGenerator* aGenerator,
																			 SharedSessionHeader* apHeader)
	:
	mGenerator(aGenerator),
	mCurrentSessionsInBatch(0),
	mCurrentSessionsInBuffer(0),
	mTotalCheckRequiredTicks(0),
	mTotalApplyDefaultsTicks(0),
	mTotalWriteSessionPropertiesTicks(0),
	mTicksPerSec(0),
	mpHeader(apHeader),
	mpProductView(NULL),
	mIsInitialized(FALSE),
	mIsDataMetered(false)
{
	LARGE_INTEGER freq;
	::QueryPerformanceFrequency(&freq);
	mTicksPerSec = freq.QuadPart;
}

COdbcSessionWriter::~COdbcSessionWriter()
{
	vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
	while(it != mWriters.end())
		delete (*it++);

	mWriters.clear();
}

void COdbcSessionWriter::CheckRequired(CSessionWriterSession* aSession)
{
	// Catch required properties that don't exist
	if(aSession->PropertyExists(PipelinePropIDs::AccountIDCode(),
															MTPipelineLib::SESS_PROP_TYPE_LONG) == false) 
	{
		throw COdbcException("Required property _AccountID not set");
	}
	if(aSession->PropertyExists(PipelinePropIDs::TimestampCode(),
															MTPipelineLib::SESS_PROP_TYPE_DATE) == false) 
	{
		throw COdbcException("Required property _Timestamp not set");
	}
	if(aSession->PropertyExists(PipelinePropIDs::ProductViewIDCode(),
															MTPipelineLib::SESS_PROP_TYPE_LONG) == false) 
	{
		throw COdbcException("Required property _ProductViewID property not set");
	}

	if(aSession->PropertyExists(PipelinePropIDs::AmountCode(),
															MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == false &&
		 aSession->PropertyExists(PipelinePropIDs::AmountCode(),
															MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == false ) 
	{
		throw COdbcException("Required property _Amount not set");
	}

	if(aSession->PropertyExists(PipelinePropIDs::IntervalIdCode(),
															MTPipelineLib::SESS_PROP_TYPE_LONG) == false) 
	{
		throw COdbcException("Required property _IntervalID not set");
	}

}

void COdbcSessionWriter::ApplyDefaults(CSessionWriterSession* aSession)
{
	aSession->ApplyDefaultStringValue(PipelinePropIDs::CurrencyCode(), L"USD");

	// If the service is not set, move it into the session
	aSession->ApplyDefaultLongValue(PipelinePropIDs::ServiceIDCode(), aSession->GetServiceID());
}

__int64 COdbcSessionWriter::WriteSession(CSessionWriterSession* aSession)
{
	ASSERT(mIsInitialized);

	mCurrentSessionsInBuffer++;

	LARGE_INTEGER tick, tock;

	::QueryPerformanceCounter(&tick);

	CheckRequired(aSession);

	::QueryPerformanceCounter(&tock);
	mTotalCheckRequiredTicks += (tock.QuadPart - tick.QuadPart);

	::QueryPerformanceCounter(&tick);

	ApplyDefaults(aSession);

	::QueryPerformanceCounter(&tock);
	mTotalApplyDefaultsTicks += (tock.QuadPart - tick.QuadPart);

	::QueryPerformanceCounter(&tick);

	// Create the id_sess for the session
  static const std::string id_sess_generator("id_sess");
	__int64 id_sess = mGenerator->GetNext(id_sess_generator);

  // Save session mapping.
  mSessionMap[id_sess] = aSession->GetInternalSessionId();

  // Write the session
	ASSERT(!mWriters.empty());
	vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
	while(it != mWriters.end())
	{
		(*it++)->WriteSession(id_sess, aSession);
	}

	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionPropertiesTicks += (tock.QuadPart - tick.QuadPart);

	return id_sess;
}

__int64 COdbcSessionWriter::WriteChildSession(__int64 aParentId,
																								 CSessionWriterSession* aSession)
{
	ASSERT(mIsInitialized);

	mCurrentSessionsInBuffer++;

	LARGE_INTEGER tick, tock;

	::QueryPerformanceCounter(&tick);

	CheckRequired(aSession);

	::QueryPerformanceCounter(&tock);
	mTotalCheckRequiredTicks += (tock.QuadPart - tick.QuadPart);

	::QueryPerformanceCounter(&tick);

	ApplyDefaults(aSession);

	::QueryPerformanceCounter(&tock);
	mTotalApplyDefaultsTicks += (tock.QuadPart - tick.QuadPart);

	::QueryPerformanceCounter(&tick);

	// Create the id_sess for the session
	__int64 id_sess = mGenerator->GetNext();

  // Save session mapping.
  mSessionMap[id_sess] = aSession->GetInternalSessionId();

  // Write the session
	ASSERT(!mWriters.empty());
	vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
	while(it != mWriters.end())
	{
		(*it++)->WriteChildSession(id_sess, aParentId, aSession);
	}

	::QueryPerformanceCounter(&tock);
	mTotalWriteSessionPropertiesTicks += (tock.QuadPart - tick.QuadPart);

	return id_sess;
}

__int64 COdbcSessionWriter::WriteSession(MTPipelineLib::IMTSessionPtr aSession)
{
	// intialize if necessary
	if (!mIsInitialized)
	{
		Setup();
		mIsInitialized = TRUE;
	}

	ASSERT(mpHeader != NULL);
	CSessionWriterSession sessionWriterSession(mpHeader, aSession);
	return WriteSession(&sessionWriterSession);
}

__int64 COdbcSessionWriter::WriteChildSession(__int64 aParentId,
																						  MTPipelineLib::IMTSessionPtr aSession)
{
	// intialize if necessary
	if (!mIsInitialized)
	{
		Setup();
		mIsInitialized = TRUE;
	}

	ASSERT(mpHeader != NULL);
	CSessionWriterSession sessionWriterSession(mpHeader, aSession);
	return WriteChildSession(aParentId, &sessionWriterSession);
}

void COdbcSessionWriter::BeginBatch()
{
	// for each batch reset counter mCurrentSessionsInBatch
	mCurrentSessionsInBatch = 0;
	mCurrentSessionsInBuffer = 0;

	// propagate call to all writers
///	ASSERT(!mWriters.empty());
	vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
	while(it != mWriters.end())
	{
		(*it++)->BeginBatch();
	}
}

int COdbcSessionWriter::ExecuteBatch()
{
	ASSERT(mIsInitialized);

	// Do a simple optimization so that we don't commit if no sessions have
	// been added to the batch.
	if (mCurrentSessionsInBuffer > 0)
	{
		int numRows=0;
		ASSERT(!mWriters.empty());
		vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
		while(it != mWriters.end())
    {
			numRows = (*it++)->ExecuteBatch();
      // If this ain't true we have had a problem with inserts.
      ASSERT(numRows == mCurrentSessionsInBuffer);
    }
    // Update counters to move stuff out of memory buffers and flush into staging.
		mCurrentSessionsInBatch += mCurrentSessionsInBuffer;
    mCurrentSessionsInBuffer = 0;

		if (numRows > 0)
		{
		   mIsDataMetered = true;

		   if (mAutoEndBatch)
			  EndBatch();
		}
		else
			mIsDataMetered = false;
			return numRows;
	}
	else
	{
		mIsDataMetered = false;
		return 0;
	}
}

void COdbcSessionWriter::EndBatch()
{
  mCurrentSessionsInBatch = 0;
  mCurrentSessionsInBuffer = 0;
  mSessionMap.clear();

  for(vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
      it != mWriters.end();
      ++it)
  {
    (*it)->EndBatch();
  }
}

double COdbcSessionWriter::GetTotalExecuteMillis()
{
	double totalMillis=0.0;
	vector<COdbcSessionStatementWriter*>::iterator it = mWriters.begin();
	while(it != mWriters.end())
	{
		totalMillis += (*it++)->GetTotalExecuteMillis();
	}
	return totalMillis;
}

double COdbcSessionWriter::GetTotalCheckRequiredMillis() const
{
	return (1000.0*mTotalCheckRequiredTicks)/mTicksPerSec;
}

	// Total number of milliseconds spent setting default values
double COdbcSessionWriter::GetTotalApplyDefaultsMillis() const
{
	return (1000.0*mTotalApplyDefaultsTicks)/mTicksPerSec;
}

	// Total number of milliseconds spent actually writing session properties
double COdbcSessionWriter::GetTotalWriteSessionPropertiesMillis() const
{
	return (1000.0*mTotalWriteSessionPropertiesTicks)/mTicksPerSec;
}

void COdbcSessionWriter::SetStringProperty(SharedSession* sess, long aPropId, const wchar_t * aStringVal)
{
	SharedPropVal * prop = sess->GetWriteablePropertyWithID(mpHeader, aPropId);
	if (NULL != prop) return;

	long ref;
	prop = sess->AddProperty(mpHeader, ref, aPropId);

	if ((wcslen(aStringVal) * sizeof(wchar_t)) < SharedSessionHeader::TINY_STRING_MAX)
	{
		// small enough to go into the SharedPropVal directly
		prop->SetTinyStringValue(aStringVal);
	}
	else
	{
		// set the value
		long id;
		const wchar_t * str = mpHeader->AllocateWideString(aStringVal, id);
		if (str == NULL)
			throw _com_error(PIPE_ERR_SHARED_OBJECT_FAILURE);

		prop->SetUnicodeIDValue(id);
	}
}

void COdbcSessionWriter::SetLongProperty(SharedSession* sess, long aPropId, long aLongVal)
{
	SharedPropVal * prop = sess->GetWriteablePropertyWithID(mpHeader, aPropId);
	if (NULL != prop)
    return;

	long ref;
	prop = sess->AddProperty(mpHeader, ref, aPropId);
	prop->SetLongValue(aLongVal);
}

void COdbcSessionWriter::UpdateFailedSessions(COdbcConnection* conn, ConstarintQueryPtr& query)
{
  MTautoptr<COdbcStatement> stmt = conn->CreateStatement();
  stmt->ExecuteUpdate(query->FindQuery);

  std::vector<string> MarkAsFailed;
  stmt = conn->CreateStatement();
  MTautoptr<COdbcResultSet> resultSet = stmt->ExecuteQuery(query->GetSessIdQuery);
 	while (resultSet->Next())
  {
    // Get a pointer to the session.  we still need to addref on it
    __int64 id_sess = resultSet->GetBigInteger(1);
    string constraint_values = resultSet->GetString(2);
    bool dbconflict = resultSet->GetInteger(3) == 1 ? true : false;

    //-----
    // When dbconflict is true that means constraint failed because record 
    // already exists in database. When dbconflict is false duplicate record
    // exists in session set. If record is duplicate in set, then let one
    // of the records pass.
    //-----
    if (dbconflict == true)
      // All sessions that conflict with database are marked as failed.
      MarkAsFailed.push_back(constraint_values);
    else 
    {
      // Did we aslready process this session.
      bool bFound = false;
		  for(std::vector<string>::const_iterator it=MarkAsFailed.begin(); it != MarkAsFailed.end(); it++)
		  {
        if (constraint_values == *it)
        {
          bFound = true;
          break;
        }
		  }		

      // If not in the mark as failed list then add to list and skip record.
      // This will allow a single duplicate from with in the session set to complete.
      if (!bFound)
      {
        MarkAsFailed.push_back(constraint_values);
        continue;
      }
    }

    // Get internal session id.
   	map<__int64, long>::iterator it = mSessionMap.find(id_sess);
	  if(it == mSessionMap.end())
	  {
      char buf[512];
      sprintf(buf, "Failed to find internal session id based on session set id: %d", id_sess);
		  throw COdbcException(buf);
	  }
	  else
    {
      // Mark session as failed.
      MTautoptr<char> error = new char[query->ErrorText.size()+constraint_values.size()+128];
	  // ESR-2953 throw a valid duplicate constraint error msg
	  int errlen; 
      errlen =  sprintf(error, query->ErrorText.c_str(), constraint_values.c_str(),
              dbconflict ? " Duplicate found in database." : " Duplicate found in session set.");

      // ESR-2953 if the length of the error msg is greater then 255, then truncate to 255 by putting the NULL byte '\0' 
	  // into error unless error is truncated to 255 then "SharedSessionHeader::AllocateBytes" will return a NULL string
	  // LARGE_STRING_MAX = 512, divide by 2 to get 256, subtract one to get 255
	  if (errlen > ((SharedSessionHeader::LARGE_STRING_MAX / 2) - 1))
	  {
		error[((SharedSessionHeader::LARGE_STRING_MAX / 2) - 1)]= '\0';
	  } 

      SharedSession* sess = mpHeader->GetSession((*it).second);
      SetStringProperty(sess, PipelinePropIDs::ErrorStringCode(), _bstr_t(error));
	  // ESR-2953 error message for t_failed_transaction.tx_errorcodemessage
      SetLongProperty(sess, PipelinePropIDs::ErrorCodeCode(), PIPE_ERR_UNIQUE_CONSTRAINT_VIOLATION);
      sess->MarkRootAsFailed(mpHeader);
    }
  } 
  resultSet->Close();
}

// EOF
