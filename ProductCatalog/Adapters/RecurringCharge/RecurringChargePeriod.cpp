// RecurringChargePeriod.cpp: implementation of the RecurringChargePeriod class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "RecurringChargePeriod.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

RecurringChargePeriod::RecurringChargePeriod()
{

}

RecurringChargePeriod::~RecurringChargePeriod()
{

}

void RecurringChargePeriod::SetDatePair(long aStartDate, long aEndDate)
{
	mStartDate = aStartDate;
	mEndDate = aEndDate;
}

void RecurringChargePeriod::GetDatePair(long &aStartDate, 
																				long &aEndDate)
{
	aStartDate = mStartDate;
	aEndDate = mEndDate;
}

void RecurringChargePeriod::SetStartDate(long aStartDate)
{
	mStartDate = aStartDate;
}

const long RecurringChargePeriod::GetStartDate() const
{
	return mStartDate;
}

void RecurringChargePeriod::SetEndDate(long aEndDate)
{
	mEndDate = aEndDate;
}

const long RecurringChargePeriod::GetEndDate() const
{
	return mEndDate;
}

