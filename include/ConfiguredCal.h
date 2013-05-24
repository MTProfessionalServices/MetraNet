/**************************************************************************
 * @doc CONFIGUREDCAL
 *
 * @module |
 *
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | CONFIGUREDCAL
 ***************************************************************************/

#ifndef _CONFIGUREDCAL_H
#define _CONFIGUREDCAL_H

#import <MTCalendar.tlb>
#import <MTConfigLib.tlb>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") 

#include <CalendarLib.h>

/****** ConfiguredCalendar *****************************************/

class ConfiguredCalendar : public Calendar
{
public:
	BOOL Setup(const char * apPathname, const char * apFilename);

protected:
	// called when a new year has to be calculated
	virtual BOOL CreateYear(CalendarYear * apYear, int aYear);


private:
	BOOL DayFromRangeCollection(CalendarDay * apDay,
															MTCALENDARLib::IMTRangeCollectionPtr aRangeCollection);

private:
	MTCALENDARLib::IMTUserCalendarPtr mCalendar;
};

/****** ConfiguredCalendarDB ****************************************
 * This class loads a calendar from the product catalog (database)  *
 * based on a calendar id.                                          *
 ********************************************************************/
class ConfiguredCalendarDB : public Calendar
{
public:
	BOOL Setup(long idCalendar);

protected:
	// called when a new year has to be calculated
	virtual BOOL CreateYear(CalendarYear * apYear, int aYear);

private:
  BOOL SetDayFromCOMDay(CalendarDay * apDay,
															MTPRODUCTCATALOGLib::IMTCalendarDayPtr apCOMDay);

private:
	MTPRODUCTCATALOGLib::IMTCalendarPtr mCalendar;
};


#endif /* _CONFIGUREDCAL_H */
