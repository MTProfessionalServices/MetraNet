/**************************************************************************
 * @doc
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 *
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/
// SumItem.cpp: implementation of the SumItem class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "Summation.h"
#include "SumItem.h"

#include <metra.h>
#include <SetIterate.h>
#include <sessioniterate.h>
#include <mtcomerr.h>
#include <stdutils.h>

using namespace MTPipelineLib;

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

// --------------------------------------------------------------------------
// Arguments: none
//
// Return Value: none
// Errors Raised: none
// Description: construction
// --------------------------------------------------------------------------
SumItem::SumItem() : mDefaultId(0)
{
	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), PIPELINE_TAG);
}

SumItem::~SumItem()
{

}


//////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: <systemContext> - idLookup object and MTLog object
//						<apPropSet> - propSet configuration file
//
// Return Value: none
// Errors Raised: error object
// Description: plug-in configuration
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "SumItem::SumItemConfig()"
void SumItem::SumItemConfig(IUnknown * systemContext,
														IMTConfigPropSetPtr apPropSet)
{
	char logBuf[MAX_BUFFER_SIZE];
	ErrorObject localError;
	_bstr_t	propName;

	try
	{
		IMTNameIDPtr idlookup(systemContext);

		// read in configuration
		//IMTConfigPropSetPtr propSet(apPropSet);

		propName = apPropSet->NextStringWithName(INPUT_PROP_NAME);
		mInputPropName = propName;
		mInputPropID = idlookup->GetNameID(propName);

		propName = apPropSet->NextStringWithName(INPUT_PROP_TYPE);
		if (PropTypeConversion(propName) == FALSE)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			sprintf(logBuf, "Error - unknown %s: %s(possible %s: %s)", 
							INPUT_PROP_TYPE, 
							(char*)propName,
							INPUT_PROP_TYPE,
							INPUT_PROP_TYPE_LIST);
			localError.GetProgrammerDetail() = logBuf;
			mLogger.LogErrorObject(LOG_ERROR, &localError);

			throw localError;
		}

		// optional input_service_id tag to support heterogeneous children
		if (apPropSet->NextMatches(INPUT_SERVICE_ID, MTPipelineLib::PROP_TYPE_INTEGER))
			mInputServiceId = apPropSet->NextLongWithName(INPUT_SERVICE_ID);
		else
			mInputServiceId = -1;

		propName = apPropSet->NextStringWithName(OUTPUT_PROP_NAME);
		mOutputPropName = propName;
		mOutputPropID = idlookup->GetNameID(propName);

		propName = apPropSet->NextStringWithName(ACTION);
		if (ActionConversion(propName) == FALSE)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			sprintf(logBuf, 
							"Error - unknown %s: %s(possible %s: %s)",
							ACTION,
							(char*)propName,
							ACTION,
							ACTION_LIST);
			localError.GetProgrammerDetail() = logBuf;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}

		// see if they have a default value.  This is NOT a required property
		BSTR aDefaultName;
		if(SUCCEEDED(apPropSet->raw_NextStringWithName(_bstr_t("default"),&aDefaultName))) {
			mDefaultId = idlookup->GetNameID(aDefaultName);
			::SysFreeString(aDefaultName);
		}

	}
	catch (HRESULT hr)
	{
		localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

		sprintf(logBuf, "Error - Caught HRESULT=%lx", hr);
		localError.GetProgrammerDetail() = logBuf;
		mLogger.LogErrorObject(LOG_ERROR, &localError);
		throw localError;
	}
	catch (_com_error err)
	{
		localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

		sprintf(logBuf, 
						"Error - caught com error: Description: %s Source: %s", 
						err.Description(),
						err.Source());
		localError.GetProgrammerDetail() = logBuf;
		mLogger.LogErrorObject(LOG_ERROR, &localError);
		throw localError;
	}

}


//////////////////////////////////////////////////////////////////////
// --------------------------------------------------------------------------
// Arguments: <apSession> - session object
//						<apChildren> - session set object
//
// Return Value: none
// Errors Raised: error object
// Description: process session object
// --------------------------------------------------------------------------
#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "SumItem::SumItemProc()"
void SumItem::SumItemProc(MTPipelineLib::IMTSessionPtr apSession,
													MTPipelineLib::IMTSessionSetPtr apChildren)
{
	char logBuf[MAX_BUFFER_SIZE];
	ErrorObject localError;
	double doubleVal = 0.0;
	MTDecimal decimalVal(0L);
	long longVal = 0;
	__int64 int64Val = 0;

	switch(mAction)
	{
	///////////////////////////////////////////////////////////////
	// get total summation
	case ACTION_TYPE_SUMMATION:
		switch (mType)
		{
		case ::PROP_TYPE_DOUBLE:
			{
				doubleVal = SumChildrenDouble(mInputPropID, apChildren);
				apSession->SetDoubleProperty(mOutputPropID, round(doubleVal));
			}
			break;

		case ::PROP_TYPE_DECIMAL:
			{
				decimalVal = SumChildrenDecimal(mInputPropID, apChildren);
				apSession->SetDecimalProperty(mOutputPropID, decimalVal);
			}
			break;

		case ::PROP_TYPE_INTEGER:
			{
				longVal = SumChildrenLong(mInputPropID, apChildren);
				apSession->SetLongProperty(mOutputPropID, longVal);
			}
			break;

		case ::PROP_TYPE_BIGINTEGER:
			{
				int64Val = SumChildrenLongLong(mInputPropID, apChildren);
				apSession->SetLongLongProperty(mOutputPropID, int64Val);
			}
			break;

		case ::PROP_TYPE_DATETIME:
			{
				longVal = SumChildrenDateTime(mInputPropID, apChildren);
				apSession->SetDateTimeProperty(mOutputPropID, longVal);
			}
			break;
					
		case ::PROP_TYPE_TIME:
			{
				longVal = SumChildrenTime(mInputPropID, apChildren);
				apSession->SetTimeProperty(mOutputPropID, longVal);
			}
			break;

		default:
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError.GetProgrammerDetail() = "Error - Unknown data type(for SUM)";
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
		break;

	///////////////////////////////////////////////////////////////
	// get average value
	case ACTION_TYPE_AVERAGE:
		switch (mType)
		{
		case ::PROP_TYPE_DOUBLE:
			if (apChildren->GetCount() != 0)
			{
				doubleVal = AverageChildren(mInputPropID, apChildren, mType);
			}
			apSession->SetDoubleProperty(mOutputPropID, round(doubleVal));
			break;
		case ::PROP_TYPE_DECIMAL:
			if (apChildren->GetCount() != 0)
			{
				decimalVal = AverageChildrenDecimal(mInputPropID, apChildren, mType);
			}
			apSession->SetDecimalProperty(mOutputPropID, decimalVal);
			break;
		default:
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError.GetProgrammerDetail() = "Error - Unknown data type(for AVE)";
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
		break;

	///////////////////////////////////////////////////////////////
	// get minimum value
	case ACTION_TYPE_MINIMUM:
		switch (mType)
		{
		case ::PROP_TYPE_DOUBLE:
			{
				doubleVal = MinChildrenDouble(mInputPropID, apChildren);
				apSession->SetDoubleProperty(mOutputPropID, round(doubleVal));
			}
			break;

		case ::PROP_TYPE_DECIMAL:
			{
				decimalVal = MinChildrenDecimal(mInputPropID, apChildren);
				apSession->SetDecimalProperty(mOutputPropID, decimalVal);
			}
			break;

		case ::PROP_TYPE_INTEGER:
			{
				longVal = MinChildrenLong(mInputPropID, apChildren);
				apSession->SetLongProperty(mOutputPropID, longVal);
			}
			break;

		case ::PROP_TYPE_DATETIME:
			{
				longVal = MinChildrenDateTime(mInputPropID,apSession,apChildren);
				apSession->SetDateTimeProperty(mOutputPropID, longVal);
			}
			break;
					
		case ::PROP_TYPE_TIME:
			{
				longVal = MinChildrenTime(mInputPropID, apChildren);
				apSession->SetTimeProperty(mOutputPropID, longVal);
			}
			break;

		default:
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError.GetProgrammerDetail() = "Error - Unknown data type(for MIN)";
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
		break;

	///////////////////////////////////////////////////////////////
	// get maximum value
	case ACTION_TYPE_MAXIMUM:
		switch (mType)
		{
		case ::PROP_TYPE_DOUBLE:
			{
				doubleVal = MaxChildrenDouble(mInputPropID, apChildren);
				apSession->SetDoubleProperty(mOutputPropID, round(doubleVal));
			}
			break;

		case ::PROP_TYPE_DECIMAL:
			{
				decimalVal = MaxChildrenDecimal(mInputPropID, apChildren);
				apSession->SetDecimalProperty(mOutputPropID, decimalVal);
			}
			break;

		case ::PROP_TYPE_INTEGER:
			{
				longVal = MaxChildrenLong(mInputPropID, apChildren);
				apSession->SetLongProperty(mOutputPropID, longVal);
			}
			break;

		case ::PROP_TYPE_DATETIME:
			{
				longVal = MaxChildrenDataTime(mInputPropID, apSession,apChildren);
				apSession->SetDateTimeProperty(mOutputPropID, longVal);
			}
			break;
					
		case ::PROP_TYPE_TIME:
			{
				longVal = MaxChildrenTime(mInputPropID, apChildren);
				apSession->SetTimeProperty(mOutputPropID, longVal);
			}
			break;

		default:
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
			localError.GetProgrammerDetail() = "Error - Unknown data type(for MAX)";
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
		break;

	///////////////////////////////////////////////////////////////
	// not implemented action
	default:
		localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);
		localError.GetProgrammerDetail() = "Error - Unknown action type";
		mLogger.LogErrorObject(LOG_ERROR, &localError);
		throw localError;
	}

	if (mLogger.IsOkToLog(LOG_DEBUG))
	{
		if (mType == ::PROP_TYPE_DOUBLE)
		{
			sprintf(logBuf, 
							"Set %s property(PropertyName=%s, PropertyID=%d, Value=%f, Action=%s): %s", 
							mTypeName.c_str(),
							mOutputPropName.c_str(),
							mOutputPropID,
							round(doubleVal),
							mActionName.c_str(),
							PROCEDURE);
		}
		else if (mType == ::PROP_TYPE_DECIMAL)
		{
			sprintf(logBuf, 
							"Set %s property(PropertyName=%s, PropertyID=%d, Value=%s, Action=%s): %s", 
							mTypeName.c_str(),
							mOutputPropName.c_str(),
							mOutputPropID,
							decimalVal.Format().c_str(),
							mActionName.c_str(),
							PROCEDURE);
		}
		else
		{
			sprintf(logBuf, 
							"Set %s property(PropertyName=%s, PropertyID=%d, Value=%d, Action=%s): %s", 
							mTypeName.c_str(),
							mOutputPropName.c_str(),
							mOutputPropID,
							longVal,
							mActionName.c_str(),
							PROCEDURE);
		}

		mLogger.LogThis(LOG_DEBUG, logBuf);
	}
}


void SumItem::ProcessChildrenSessions(IMTSessionSetPtr& sessions,
																			SumItemInstance& aProc)
{
	char logBuf[MAX_BUFFER_SIZE];
	ErrorObject localError;

	// passing in the service ID to the iterator will filter out sessions that don't match
	// the service ID.  If mInputServiceId is -1, then all sessions are returned.
	SessionIterator it;
	HRESULT hr = it.Init(sessions, mInputServiceId);
	if (FAILED(hr))
	  throw hr;
	
	while (TRUE)
	{
	    IMTSessionPtr session = it.GetNext();
	  	if (session == NULL)
		  break;

		try
		{
			aProc.ProcessSession(session);
		}
		catch (_com_error err)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, ERROR_LINE, PROCEDURE);

			_bstr_t desc(err.Description());
			sprintf(logBuf, 
					"Error - can not get %s property(PropertyName=%s, PropertyID=%d, Description=%s, Error=%0x) for action=%s", 
					mTypeName.c_str(),
					mInputPropName.c_str(),
					aProc.GetProp(),
					(char*)desc,
					err.Error(),
					mActionName.c_str());
			localError.GetProgrammerDetail() = logBuf;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
	}
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenDouble : public SumItemInstance, public SumItemResult<double> {
public:
	MTSumChildrenDouble(long aProp) : SumItemInstance(aProp), mTotal(0) {}
	void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetDoubleProperty(mProp);

	}
	double GetResult() { return mTotal; }

protected:
	double mTotal;
};

//////////////////////////////////////////////////////////////////////////////
//MTSumChildrenDecimal
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenDecimal : public SumItemInstance, public SumItemResult<MTDecimal> {
public:
	MTSumChildrenDecimal(long aProp) : SumItemInstance(aProp), mTotal(0L) {}
	void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetDecimalProperty(mProp);

	}
	MTDecimal GetResult() { return mTotal; }

protected:
	MTDecimal mTotal;
};

//////////////////////////////////////////////////////////////////////////////
//MTSumChildrenLong
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenLong : public SumItemInstance, public SumItemResult<long> {
public:
	MTSumChildrenLong(long aProp) : SumItemInstance(aProp), mTotal(0L) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetLongProperty(mProp);

	}
	long GetResult() { return mTotal; }

protected:
	long mTotal;
};

//////////////////////////////////////////////////////////////////////////////
//MTSumChildrenLongLong
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenLongLong : public SumItemInstance, public SumItemResult<__int64> {
public:
	MTSumChildrenLongLong(long aProp) : SumItemInstance(aProp), mTotal((__int64)0) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetLongLongProperty(mProp);

	}
	__int64 GetResult() { return mTotal; }

protected:
	__int64 mTotal;
};

//////////////////////////////////////////////////////////////////////////////
//MTSumChildrenDateTime
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenDateTime : public MTSumChildrenLong {
public:

	MTSumChildrenDateTime(long aProp) : MTSumChildrenLong(aProp) {}
	void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetDateTimeProperty(mProp);
	}
};


//////////////////////////////////////////////////////////////////////////////
//MTSumChildrenTime
//////////////////////////////////////////////////////////////////////////////

class MTSumChildrenTime : public MTSumChildrenLong {
public:

	MTSumChildrenTime(long aProp) : MTSumChildrenLong(aProp) {}
	void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		mTotal += aSession->GetTimeProperty(mProp);
	}
};


template <class T> class MTMinItem {
public:
	MTMinItem() : bNotCalculated(true),Minimum(0L) {}
	void CalculateMinimum(T aAmount) 
	{
		if (bNotCalculated) {
			Minimum = aAmount;
			bNotCalculated = false;
		}
		else if (Minimum > aAmount)
		{
			Minimum = aAmount;
		}
	}
	T GetMinimum() { return Minimum; }

protected:
	T Minimum;
	bool bNotCalculated;
};

//////////////////////////////////////////////////////////////////////////////
//MTMinChildrenDouble
//////////////////////////////////////////////////////////////////////////////

class MTMinChildrenDouble : public SumItemInstance, public MTMinItem<double> {
public:
	MTMinChildrenDouble(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMinimum(aSession->GetDoubleProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMinChildrenDecimal
//////////////////////////////////////////////////////////////////////////////

class MTMinChildrenDecimal : public SumItemInstance, public MTMinItem<MTDecimal> {
public:
	MTMinChildrenDecimal(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMinimum(aSession->GetDecimalProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMinChildrenLong
//////////////////////////////////////////////////////////////////////////////

class MTMinChildrenLong : public SumItemInstance, public MTMinItem<long> {
public:
	MTMinChildrenLong(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMinimum(aSession->GetLongProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMinChildrenTime
//////////////////////////////////////////////////////////////////////////////

class MTMinChildrenTime : public MTMinChildrenLong {
public:
	MTMinChildrenTime(long aProp) : MTMinChildrenLong(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMinimum(aSession->GetTimeProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMinChildrenDateTime
//////////////////////////////////////////////////////////////////////////////

class MTMinChildrenDateTime : public MTMinChildrenLong{
public:
	MTMinChildrenDateTime(long aProp) : MTMinChildrenLong(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMinimum(aSession->GetDateTimeProperty(mProp));
	}
};

template <class T> class MTMaxItem {
public:
	MTMaxItem() : bNotCalculated(true),Maximum(0L) {}
	void CalculateMaximum(T aAmount) 
	{
		if (bNotCalculated) {
			Maximum = aAmount;
			bNotCalculated = false;
		}
		else if (Maximum < aAmount)
		{
			Maximum = aAmount;
		}
	}
	T GetMaximum() { return Maximum; }

protected:
	T Maximum;
	bool bNotCalculated;
};


//////////////////////////////////////////////////////////////////////////////
//MTMaxChildrenDouble
//////////////////////////////////////////////////////////////////////////////

class MTMaxChildrenDouble : public SumItemInstance, public MTMaxItem<double> {
public:
	MTMaxChildrenDouble(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMaximum(aSession->GetDoubleProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMaxChildrenDecimal
//////////////////////////////////////////////////////////////////////////////

class MTMaxChildrenDecimal : public SumItemInstance, public MTMaxItem<MTDecimal> {
public:
	MTMaxChildrenDecimal(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMaximum(aSession->GetDecimalProperty(mProp));
	}
};

//////////////////////////////////////////////////////////////////////////////
//MTMaxChildrenLong
//////////////////////////////////////////////////////////////////////////////

class MTMaxChildrenLong : public SumItemInstance, public MTMaxItem<long> {
public:
	MTMaxChildrenLong(long aProp) : SumItemInstance(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMaximum(aSession->GetLongProperty(mProp));
	}
};
//////////////////////////////////////////////////////////////////////////////
//MTMaxChildrenTime
//////////////////////////////////////////////////////////////////////////////

class MTMaxChildrenTime : public MTMaxChildrenLong {
public:
	MTMaxChildrenTime(long aProp) : MTMaxChildrenLong(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMaximum(aSession->GetTimeProperty(mProp));
	}
};
//////////////////////////////////////////////////////////////////////////////
//MTMaxChildrenDateTime
//////////////////////////////////////////////////////////////////////////////

class MTMaxChildrenDateTime : public MTMaxChildrenLong {
public:
	MTMaxChildrenDateTime(long aProp) : MTMaxChildrenLong(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession)
	{
		CalculateMaximum(aSession->GetDateTimeProperty(mProp));
	}
};


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

double SumItem::SumChildrenDouble(long aProp, IMTSessionSetPtr sessions) 
{
	MTSumChildrenDouble aChildDouble(aProp);
	ProcessChildrenSessions(sessions,aChildDouble);
	return aChildDouble.GetResult();
}

//////////////////////////////////////////////////////////////////////////////

MTDecimal SumItem::SumChildrenDecimal(long aProp, IMTSessionSetPtr sessions) 
{
	MTSumChildrenDecimal aChildDecimal(aProp);
	ProcessChildrenSessions(sessions,aChildDecimal);
	return aChildDecimal.GetResult();
}



//////////////////////////////////////////////////////////////////////////////
long SumItem::SumChildrenLong(long aProp, IMTSessionSetPtr sessions)
{
	MTSumChildrenLong aChildLong(aProp);
	ProcessChildrenSessions(sessions,aChildLong);
	return aChildLong.GetResult();
}

//////////////////////////////////////////////////////////////////////////////
__int64 SumItem::SumChildrenLongLong(long aProp, IMTSessionSetPtr sessions)
{
	MTSumChildrenLongLong aChildLongLong(aProp);
	ProcessChildrenSessions(sessions,aChildLongLong);
	return aChildLongLong.GetResult();
}



//////////////////////////////////////////////////////////////////////////////
long SumItem::SumChildrenDateTime(long aProp, IMTSessionSetPtr sessions)
{
	MTSumChildrenDateTime aChildDateTime(aProp);
	ProcessChildrenSessions(sessions,aChildDateTime);
	return aChildDateTime.GetResult();
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::SumChildrenTime(long aProp, IMTSessionSetPtr sessions)
{
	MTSumChildrenTime aChildDateTime(aProp);
	ProcessChildrenSessions(sessions,aChildDateTime);
	return aChildDateTime.GetResult();
}



//////////////////////////////////////////////////////////////////////////////
double SumItem::MinChildrenDouble(long aProp, IMTSessionSetPtr sessions)
{
	MTMinChildrenDouble aMinChildDouble(aProp);
	ProcessChildrenSessions(sessions,aMinChildDouble);
	return aMinChildDouble.GetMinimum();

}

//////////////////////////////////////////////////////////////////////////////
MTDecimal SumItem::MinChildrenDecimal(long aProp, IMTSessionSetPtr sessions)
{
	MTMinChildrenDecimal aMinChildDecimal(aProp);
	ProcessChildrenSessions(sessions,aMinChildDecimal);
	return aMinChildDecimal.GetMinimum();
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MinChildrenLong(long aProp, IMTSessionSetPtr sessions)
{
	MTMinChildrenLong aMinChildLong(aProp);
	ProcessChildrenSessions(sessions,aMinChildLong);
	return aMinChildLong.GetMinimum();
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MinChildrenDateTime(long aProp, MTPipelineLib::IMTSessionPtr aParent,
																	IMTSessionSetPtr sessions)
{	
	MTMinChildrenDateTime aMinChildDateTime(aProp);
	ProcessChildrenSessions(sessions,aMinChildDateTime);

	long aMinimum = aMinChildDateTime.GetMinimum();
	if(aMinimum == 0 && mDefaultId > 0) {
		aMinimum = aParent->GetDateTimeProperty(mDefaultId);
	}
	return aMinimum;
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MinChildrenTime(long aProp, IMTSessionSetPtr sessions)
{
	MTMinChildrenTime aMinChildTime(aProp);
	ProcessChildrenSessions(sessions,aMinChildTime);
	return aMinChildTime.GetMinimum();
}


//////////////////////////////////////////////////////////////////////////////
double SumItem::MaxChildrenDouble(long aProp, IMTSessionSetPtr sessions)
{
	MTMaxChildrenDouble aMaxChildDouble(aProp);
	ProcessChildrenSessions(sessions,aMaxChildDouble);
	return aMaxChildDouble.GetMaximum();
}

//////////////////////////////////////////////////////////////////////////////
MTDecimal SumItem::MaxChildrenDecimal(long aProp, IMTSessionSetPtr sessions)
{
	MTMaxChildrenDecimal aMaxChildDecimal(aProp);
	ProcessChildrenSessions(sessions,aMaxChildDecimal);
	return aMaxChildDecimal.GetMaximum();
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MaxChildrenLong(long aProp, IMTSessionSetPtr sessions)
{	
	MTMaxChildrenLong aMaxChildLong(aProp);
	ProcessChildrenSessions(sessions,aMaxChildLong);
	return aMaxChildLong.GetMaximum();
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MaxChildrenDataTime(long aProp, MTPipelineLib::IMTSessionPtr aParent,
																	IMTSessionSetPtr sessions)
{
	MTMaxChildrenDateTime aMaxChildDateTime(aProp);
	ProcessChildrenSessions(sessions,aMaxChildDateTime);

	long aMaximum = aMaxChildDateTime.GetMaximum();
	if(aMaximum == 0 && mDefaultId > 0) {
		aMaximum = aParent->GetDateTimeProperty(mDefaultId);
	}

	return aMaximum;
}


//////////////////////////////////////////////////////////////////////////////
long SumItem::MaxChildrenTime(long aProp, IMTSessionSetPtr sessions)
{
	MTMaxChildrenTime aMaxChildTime(aProp);
	ProcessChildrenSessions(sessions,aMaxChildTime);
	return aMaxChildTime.GetMaximum();
}


//////////////////////////////////////////////////////////////////////////////
double SumItem::round(double val)
{
	// no round needed
	return val; //((int) ((val) * 100.0)) / 100.0;
}

///////////////////////////////////////////////////////////////////////////////
double SumItem::AverageChildren(long aProp, 
											 IMTSessionSetPtr sessions, 
											 ::PropValType aType)
{
	char logBuf[MAX_BUFFER_SIZE];
	ErrorObject localError;
	double	ave = 0.0;
	double	totalDouble = 0.0;
	long		totalLong = 0;

	unsigned int aCount = 0;
	SetIterator<IMTSessionSetPtr, IMTSessionPtr> it;
	HRESULT hr = it.Init(sessions);
	if (FAILED(hr))
	  throw hr;
	
	while (TRUE)
	{
	    IMTSessionPtr session = it.GetNext();
	  	if (session == NULL)
		  break;

		try
		{
			if (aType == ::PROP_TYPE_DOUBLE)
			{
				double amount = session->GetDoubleProperty(aProp);
				totalDouble += amount;
			}
			else
			{
				long amount = session->GetLongProperty(aProp);
				totalLong += amount;
			}

			aCount++;
		}
		catch (_com_error err)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, 
							ERROR_LINE, PROCEDURE);
			_bstr_t desc(err.Description());
			sprintf(logBuf, 
					"Error - can not get %s property(PropertyName=%s, PropertyID=%d, Description=%s) for action=%s", 
					mTypeName.c_str(),
					mInputPropName.c_str(),
					aProp,
					(char*)desc,
					mActionName.c_str());
			localError.GetProgrammerDetail() = logBuf;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
	}

	if (aCount == 0)
	{
		sprintf(logBuf, 
				"No children in the session was found: Property Name: %s, Action Name: %s.", 
				mInputPropName.c_str(),
				mActionName.c_str());
		localError.GetProgrammerDetail() = logBuf;
		mLogger.LogErrorObject(LOG_WARNING, &localError);
	}
	else
	{
		if (aType == ::PROP_TYPE_DOUBLE)
		{
			ave = totalDouble/aCount;
		}
		else
		{
			ave = totalLong/aCount;
		}
	}

	return ave;
}


///////////////////////////////////////////////////////////////////////////////
MTDecimal SumItem::AverageChildrenDecimal(long aProp, 
																					IMTSessionSetPtr sessions, 
																					::PropValType aType)
{
	char logBuf[MAX_BUFFER_SIZE];
	ErrorObject localError;
	double	totalDouble = 0.0;
	long		totalLong = 0;
	MTDecimal	totalDecimal(0L);

	long aCount = 0;
	SetIterator<IMTSessionSetPtr, IMTSessionPtr> it;
	HRESULT hr = it.Init(sessions);
	if (FAILED(hr))
	  throw hr;
	
	while (TRUE)
	{
	    IMTSessionPtr session = it.GetNext();
	  	if (session == NULL)
		  break;

		try
		{
			if (aType == ::PROP_TYPE_DOUBLE)
			{
				double amount = session->GetDoubleProperty(aProp);
				totalDouble += amount;
			}
			else if (aType == ::PROP_TYPE_DECIMAL)
			{
				MTDecimal dec = session->GetDecimalProperty(aProp);
				totalDecimal += dec;
			}
			else if (aType == ::PROP_TYPE_INTEGER)
			{
				long amount = session->GetLongProperty(aProp);
				totalLong += amount;
			}

			aCount++;
		}
		catch (_com_error err)
		{
			localError.Init(::GetLastError(), ERROR_MODULE, 
							ERROR_LINE, PROCEDURE);
			_bstr_t desc(err.Description());
			sprintf(logBuf, 
					"Error - can not get %s property(PropertyName=%s, PropertyID=%d, Description=%s) for action=%s", 
					mTypeName.c_str(),
					mInputPropName.c_str(),
					aProp,
					(char*)desc,
					mActionName.c_str());
			localError.GetProgrammerDetail() = logBuf;
			mLogger.LogErrorObject(LOG_ERROR, &localError);
			throw localError;
		}
	}

	MTDecimal ave;

	if (aCount == 0)
	{
		sprintf(logBuf, 
				"No children in the session was found: Property Name: %s, Action Name: %s.", 
				mInputPropName.c_str(),
				mActionName.c_str());
		localError.GetProgrammerDetail() = logBuf;
		mLogger.LogErrorObject(LOG_WARNING, &localError);
	}
	else
	{
		if (aType == ::PROP_TYPE_DECIMAL)
		{
			ave = totalDecimal/MTDecimal(aCount);
		}
		else
		{
			ave = MTDecimal(totalLong) / MTDecimal(aCount);
		}
	}

	return ave;
}


///////////////////////////////////////////////////////////////////////////////
BOOL SumItem::PropTypeConversion(BSTR aPropType)
{
	_bstr_t propTypeBstr(aPropType);
	char*		propTypeChar;

	propTypeChar = propTypeBstr;
	if (propTypeChar == NULL || strlen(propTypeChar) == 0)
	{
		return FALSE;
	}

	mtstring propTypeStr = propTypeChar;
	StrToUpper(propTypeStr);

	if (propTypeStr.size() == strlen(INTEGER) && 
			propTypeStr == INTEGER)
	{
		mType = ::PROP_TYPE_INTEGER;
		mTypeName = INTEGER;
	}
	else if (propTypeStr.size() == strlen(DOUBLE) && 
					propTypeStr == DOUBLE)
	{
		mType = ::PROP_TYPE_DOUBLE;
		mTypeName = DOUBLE;
	}
	else if (propTypeStr.size() == strlen(DECIMAL_TAG) && 
					propTypeStr == DECIMAL_TAG)
	{
		mType = ::PROP_TYPE_DECIMAL;
		mTypeName = DECIMAL_TAG;
	}
	else if (propTypeStr.size() == strlen(DATETIME) && 
						propTypeStr == DATETIME)
	{
		mType = ::PROP_TYPE_DATETIME;
		mTypeName = DATETIME;
	}
	else if (propTypeStr.size() == strlen(TIME) && 
						propTypeStr == TIME)
	{
		mType = ::PROP_TYPE_TIME;
		mTypeName = TIME;
	}
	else
	{
		return FALSE;
	}

	return TRUE;
}


///////////////////////////////////////////////////////////////////////////////
BOOL SumItem::ActionConversion(BSTR aAction)
{
	_bstr_t actionBstr(aAction);
	char*		actionChar;

	actionChar = actionBstr;
	if (actionChar == NULL || strlen(actionChar) == 0)
	{
		mActionName = "";
		return FALSE;
	}

	mtstring actionStr = actionChar;
	StrToUpper(actionStr);

	if (actionStr.size() == strlen(SUMMATION) && 
			actionStr == SUMMATION)
	{
		mAction = ACTION_TYPE_SUMMATION;
		mActionName = SUMMATION;
	}
	else if (actionStr.size() == strlen(AVERAGE) && 
					actionStr == AVERAGE)
	{
		mAction = ACTION_TYPE_AVERAGE;
		mActionName = AVERAGE;
	}
	else if (actionStr.size() == strlen(MINIMUM) && 
					actionStr == MINIMUM)
	{
		mAction = ACTION_TYPE_MINIMUM;
		mActionName = MINIMUM;
	}
	else if (actionStr.size() == strlen(MAXIMUM) && 
					actionStr == MAXIMUM)
	{
		mAction = ACTION_TYPE_MAXIMUM;
		mActionName = MAXIMUM;
	}
	else 
	{
		mActionName = "";
		return FALSE;
	}

	return TRUE;
}
