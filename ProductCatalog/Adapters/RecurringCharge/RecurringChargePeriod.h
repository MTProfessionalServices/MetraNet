// RecurringChargePeriod.h: interface for the RecurringChargePeriod class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_RECURRINGCHARGEPERIOD_H__7A43FB31_790D_4436_80CE_4F2DB578F437__INCLUDED_)
#define AFX_RECURRINGCHARGEPERIOD_H__7A43FB31_790D_4436_80CE_4F2DB578F437__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class RecurringChargePeriod  
{
public:
	RecurringChargePeriod();
	virtual ~RecurringChargePeriod();

	inline bool operator ==(const RecurringChargePeriod & arVar) const
	{
		if (this != &arVar)
		{
			return (mStartDate == arVar.mStartDate && mEndDate == arVar.mEndDate);
		}
		else
		{
			return true;
		}
	}

public:
	void SetDatePair(long aStartDate,long aEndDate);
	void GetDatePair(long& aStartDate, long& aEndDate);

	void SetStartDate(long aStartDate);
	const long GetStartDate() const;

	void SetEndDate(long aEndDate);
	const long GetEndDate() const;

private:
	long mStartDate;
	long mEndDate;
};

#endif // !defined(AFX_RECURRINGCHARGEPERIOD_H__7A43FB31_790D_4436_80CE_4F2DB578F437__INCLUDED_)
