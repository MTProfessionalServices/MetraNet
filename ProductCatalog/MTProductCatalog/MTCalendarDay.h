// MTCalendarDay.h : Declaration of the CMTCalendarDay

#ifndef __MTCALENDARDAY_H_
#define __MTCALENDARDAY_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <MTObjectCollection.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarDay
class CMTCalendarDay : 
 public CMTPCBase,
 public PropertiesBase
{
public:
	CMTCalendarDay(){};

// IMTCalendarDay
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Code)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Code)(/*[in]*/ long newVal);
	STDMETHOD(GetCodeAsString)(/*[out, retval]*/ BSTR* newVal);
  STDMETHOD(CreatePeriod)(/*[out, retval]*/ IMTCalendarPeriod* *apCalPeriod);
	STDMETHOD(RemovePeriod)(/*[in]*/ long periodID);
	STDMETHOD(GetPeriods)(/*[out, retval]*/ IMTCollection** apPeriodColl);
	STDMETHOD(ValidatePeriodTimes)(/*[in]*/ IMTCalendarDay* thisDay, /*[in]*/ long startVal, /*[in]*/ long endVal, /*[out, retval]*/ VARIANT_BOOL* pVal);
private:
	MTObjectCollection<IMTCalendarPeriod> mPeriods; 

};

// macro that needs to be included in all derived classes
#define DEFINE_MT_CALENDARDAY_METHODS												\
	DEFINE_MT_PCBASE_METHODS																					\
	DEFINE_MT_PROPERTIES_BASE_METHODS														\
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal)								\
		{ return CMTCalendarDay::get_ID(pVal); }												\
	STDMETHOD(put_ID)(/*[in]*/ long newVal)													 \
		{ return CMTCalendarDay::put_ID(newVal); }											\
	STDMETHOD(get_Code)(/*[out, retval]*/ long *pVal)							\
		{ return CMTCalendarDay::get_Code(pVal); }											\
	STDMETHOD(put_Code)(/*[in]*/ long newVal)												\
		{ return CMTCalendarDay::put_Code(newVal); }									\
	STDMETHOD (GetCodeAsString) (/*[out, retval]*/ BSTR* pVal)												\
		{ return CMTCalendarDay::GetCodeAsString(pVal); }							\
	STDMETHOD(CreatePeriod)(/*[out, retval]*/ IMTCalendarPeriod* *apCalPeriod)									\
		{ return CMTCalendarDay::CreatePeriod(apCalPeriod); }					\
	STDMETHOD(RemovePeriod)(/*[in]*/ long periodID)									\
		{ return CMTCalendarDay::RemovePeriod(periodID); }						\
	STDMETHOD(GetPeriods)(/*[out, retval]*/ IMTCollection* *apPeriodColl)									\
		{ return CMTCalendarDay::GetPeriods(apPeriodColl); }						\
	STDMETHOD(ValidatePeriodTimes)(/*[in]*/ long startVal, /*[in]*/ long endVal, /*[out, retval]*/ VARIANT_BOOL* pVal)			\
		{ return CMTCalendarDay::ValidatePeriodTimes(this, startVal, endVal, pVal);	}

#endif //__MTCALENDARDAY_H_
