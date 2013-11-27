/**************************************************************************
 * @doc TEST
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
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#import <MTConfigLib.tlb>
//MTConfigLib

#include <ConfiguredCal.h>
#include <CalendarLib.h>

#include "NTRegistryIO.h"

#include <MTUtil.h>

#include <errno.h>
#include <mtprogids.h>

#include <ConfigDir.h>
#include <MTDate.h>

static ComInitialize gComInit;

void clearAndDestroy(TimeSegmentVector & segments)
{
	TimeSegmentVector::iterator it;
	for (it = segments.begin(); it != segments.end(); it++)
		delete *it;

	segments.clear();
}

class TestCalendar : public Calendar
{
protected:
	// called when a new year has to be calculated
	virtual BOOL CreateYear(CalendarYear * apYear, int aYear);
};


BOOL TestCalendar::CreateYear(CalendarYear * apYear, int aYear)
{
	CalendarDay * weekday = new CalendarDay;
	TimeRange * range = new TimeRange("Off-Peak",
																		TimeRange::MakeTimeOfDay(0, 0, 0),
																		TimeRange::MakeTimeOfDay(9, 0, 0));
	weekday->AddTimeRange(range);

	range = new TimeRange("Peak",
												TimeRange::MakeTimeOfDay(9, 0, 0),
												TimeRange::MakeTimeOfDay(17, 0, 0));
	weekday->AddTimeRange(range);

	range = new TimeRange("Off-Peak",
												TimeRange::MakeTimeOfDay(17, 0, 0),
												TimeRange::MakeTimeOfDay(24, 0, 0));
	weekday->AddTimeRange(range);


	CalendarDay * weekend = new CalendarDay;
	range = new TimeRange("Weekend",
												TimeRange::MakeTimeOfDay(0, 0, 0),
												TimeRange::MakeTimeOfDay(24, 0, 0));
	weekend->AddTimeRange(range);

	apYear->OwnDay(weekday);
	apYear->OwnDay(weekend);

	//
	// determine the day of week of the first day of the year
	//
	

	// tm_sec Seconds after minute (0 - 59)
	// tm_min Minutes after hour (0 - 59)
	// tm_hour Hours since midnight (0 - 23)
	// tm_mday Day of month (1 - 31)
	// tm_mon Month (0 - 11; January = 0)
	// tm_year Year (current year minus 1900)
	// tm_wday Day of week (0 - 6; Sunday = 0)
	// tm_yday Day of year (0 - 365; January 1 = 0)
	// tm_isdst Always 0 for gmtime
	struct tm timeStruct;
	timeStruct.tm_sec = 0;
	timeStruct.tm_min = 0;
	timeStruct.tm_hour = 0;
	timeStruct.tm_mday = 1;
	timeStruct.tm_mon = 0;
	timeStruct.tm_year = aYear;
	timeStruct.tm_wday = 0;
	timeStruct.tm_yday = 0;

	time_t firstOfYear = mktime(&timeStruct);

	timeStruct = *gmtime(&firstOfYear);
	ASSERT(timeStruct.tm_year == aYear);
	ASSERT(timeStruct.tm_mon == 0);
	ASSERT(timeStruct.tm_mday == 1);

	int dayOfWeek = timeStruct.tm_wday;
	for (int i = 0; i < 365; i++)
	{
		switch (dayOfWeek)
		{
		case 0:											// sun
			apYear->SetDay(i, weekend);
			break;
		case 1:											// mon
			apYear->SetDay(i, weekday);
			break;
		case 2:											// tue
			apYear->SetDay(i, weekday);
			break;
		case 3:											// wed
			apYear->SetDay(i, weekday);
			break;
		case 4:											// thur
			apYear->SetDay(i, weekday);
			break;
		case 5:											// fri
			apYear->SetDay(i, weekday);
			break;
		case 6:											// sat
			apYear->SetDay(i, weekend);
			break;
		default:
			ASSERT(0);
		}

		dayOfWeek++;
		dayOfWeek = dayOfWeek % 7;
	}

	return TRUE;
}

void PrintTimeSegments(TimeSegmentVector & arSegments)
{
	for (int i = 0; i < (int) arSegments.size(); i++)
	{
		TimeSegment * segment = arSegments[i];

		cout << "Segment ";
		time_t startTime = segment->GetStartTime();
		const char * startString = ctime(&startTime);
		cout << startString << "\tfor " << segment->GetDuration()
				 << " until ";
		time_t endTime = segment->GetEndTime();
		ASSERT(endTime == segment->GetStartTime() + segment->GetDuration());

		const char * endString = ctime(&endTime);
		cout << endString << "\t = " << segment->GetCode().c_str() << endl;
	}
}

int StandardTest()
{
	TestCalendar calendar;

	time_t start = time(NULL);
	time_t end = start + (24 * 60 * 60);
	TimeSegmentVector segments;
	calendar.SplitTimeSpan(start, end, "EST", segments);

	PrintTimeSegments(segments);
	clearAndDestroy(segments);
	return 0;
}

int ConfiguredTest()
{
	ConfiguredCalendar calendar;
	if (!calendar.Setup("test\\calendar", "calendar.xml"))
		return -1;

	time_t start = time(NULL);
	time_t end = start + (24 * 60 * 60);
	TimeSegmentVector segments;
	calendar.SplitTimeSpan(start, end, "EST", segments);

	PrintTimeSegments(segments);
	clearAndDestroy(segments);

	return 0;
}

int ConfiguredDBTest(long idCal)
{
	cout << "Test Calendar DB Class" << endl;
	cout << "======================================================" << endl;

	ConfiguredCalendarDB calendar;
	if (!calendar.Setup(idCal))
		return -1;

	time_t start = time(NULL);
	time_t end = start + (24 * 60 * 60);
	TimeSegmentVector segments;
	calendar.SplitTimeSpan(start, end, "EST", segments);

	PrintTimeSegments(segments);
	clearAndDestroy(segments);

	return 0;
}

int ConfiguredDummyTest()
{
	cout << "Test Calendar Dummy Class" << endl;
	cout << "======================================================" << endl;

	TestCalendar calendar;
	//if (!calendar.Setup(idCal)
	//	return -1;

	time_t start = time(NULL);
	time_t end = start + (24 * 60 * 60);
	TimeSegmentVector segments;
	calendar.SplitTimeSpan(start, end, "EST", segments);

	PrintTimeSegments(segments);
	clearAndDestroy(segments);

	return 0;
}

////////////////////////////////////////////////////////////////////////
BOOL GetConfigFileName(string aPath, string aConfigFile, 
											 string& aFilename)
{
	string configRoot;
	if (!GetMTConfigDir(configRoot))
	{
		cout << "*** Failed to get configuration root directory!" << endl;
		return FALSE;
	}

	PathNameSuffix(configRoot);
		
	aFilename = configRoot + aPath;
	PathNameSuffix(aFilename);

	aFilename += aConfigFile;

	return TRUE;
}


//////////////////////////////////////////////////////////////////////////////////////
long GetLongDateTimeValue(MTConfigLib::IMTConfigPropSetPtr aPropSet, char* aFieldName)
{
	long datetime;
	
	try
	{
		MTConfigLib::IMTConfigPropPtr prop = aPropSet->NextWithName(aFieldName);

		if (prop == NULL)
		{
			cout << "*** Failed to get field: " << aFieldName << endl;
			return -1;
		}

		MTConfigLib::PropValType type;
		VARIANT propVal;

		// try to get the value
		propVal = prop->GetValue(&type);

		// release the property now whether it was the correct type or not
		if (type != MTConfigLib::PROP_TYPE_DATETIME)
		{
			cout << "*** Error: Field: " <<  aFieldName;
			cout << " type is not MTConfigLib::DATETIME" << endl;
			return -1;
		}
		datetime = (long)propVal.lVal;

	}
	catch(_com_error err)
	{
		// a required line for starting error message
		cout << ">>>>>>>>>>>>>>>>> ERROR OCCURRED IN TEST <<<<<<<<<<<<<<<<<<<<<<" << endl;

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc(err.Description());
		_bstr_t src(err.Source());

		char* str;

		str = desc;
		if (str)
			cout << "  Description: " << str << endl;

		str = src;
		if (str)
			cout << "  Source: " << str << endl;

		return -1;
	}

	return datetime;
}


/////////////////////////////////////////////////////////////////////////////////
BOOL LoadOneTestConfigSet(TimeSegmentVector& aSegments,
													MTConfigLib::IMTConfigPropSetPtr aTestConfigSet)
{
	long start;
	long end;

	try
	{
		MTConfigLib::IMTConfigPropSetPtr testSet;
		while ((testSet = aTestConfigSet->NextSetWithName("time_segment")) != NULL)
		{
			start = GetLongDateTimeValue(testSet, "start_time");
			end = GetLongDateTimeValue(testSet, "end_time");

			_bstr_t code = testSet->NextStringWithName(_bstr_t("code"));

			const TimeRange * range = new TimeRange((char*)code, start, end);

			long durationInRange = end - start;
			// save in segments
			TimeSegment * segment = new TimeSegment(start, durationInRange,
																							range);

			aSegments.push_back(segment);
		}

	}
	catch(_com_error err)
	{
		// a required line for starting error message
		cout << ">>>>>>>>>>>>>>>>> ERROR OCCURRED IN TEST <<<<<<<<<<<<<<<<<<<<<<" << endl;

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc(err.Description());
		_bstr_t src(err.Source());

		char* str;

		str = desc;
		if (str)
			cout << "  Description: " << str << endl;

		str = src;
		if (str)
			cout << "  Source: " << str << endl;

		return FALSE;
	}

	
	return TRUE;
}


////////////////////////////////////////////////////////////////////////////////
BOOL CheckTestResult(TimeSegmentVector& aExpectedSegments, 
										 TimeSegmentVector& aSegments)
{
	char* dateString;
	char expStartString[64];
	char expEndString[64];
	char startString[64];
	char endString[64];

	int expectedEntries = (int) aExpectedSegments.size();
	int entries = (int) aSegments.size();

	if (entries > expectedEntries)
	{
		entries = expectedEntries;
	}

	for (int i = 0; i < entries; i++)
	{
		TimeSegment * expectedSegment = aExpectedSegments[i];
		TimeSegment * segment = aSegments[i];

		time_t expectedStart = expectedSegment->GetStartTime();
		time_t expectedEnd = expectedSegment->GetEndTime();
		string expectedCode = expectedSegment->GetCode();

		dateString = ctime(&expectedStart);
		strcpy(expStartString, dateString);

		dateString = ctime(&expectedEnd);
		strcpy(expEndString, dateString);

		time_t start = segment->GetStartTime();
		time_t end = segment->GetEndTime();

		dateString = ctime(&start);
		strcpy(startString, dateString);

		dateString = ctime(&end);
		strcpy(endString, dateString);

		string code = segment->GetCode();

		if (expectedStart != start ||
				expectedEnd != end ||
				expectedCode != code)
		{
			cout << "*** Total segment: " << entries << endl;
			cout << "*** Error segment: " << (i+1) << " mismatch!" << endl;
			
			// print out detail
			cout << "Expected start date: (" << expectedStart;
			cout << ") " << expStartString << endl;
			cout << "Actual start time: (" << start << ") " << startString << endl;

			cout << endl << "Expected end date: (" << expectedEnd;
			cout << ") " << expEndString << endl;
			cout << "Actual end time: (" << end << ") " << endString << endl;

			cout << "Expected code: " << expectedCode.data() << " actual code: " << code.data() << endl;
			
			return FALSE;
		}

	}

	return TRUE;
}


////////////////////////////////////////////////////////////////////////////////
int AutoTest(char* aPath, char* aConfigFile)
{
	string aFilename;

	if (!GetConfigFileName(aPath, aConfigFile, aFilename))
	{
		cout << "Fail to get test config file name!" << endl;
		return -1;
	}

	ConfiguredCalendar calendar;
	if (!calendar.Setup("test\\calendar", "calendar.xml"))
		return -1;

	cout << "timezone: " << _timezone << endl;
	cout << "daylight saving zone: " << _daylight << endl;
	try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
		VARIANT_BOOL flag;

		MTConfigLib::IMTConfigPropSetPtr mainSet =
			config->ReadConfiguration(_bstr_t(aFilename.data()), &flag);

		MTConfigLib::IMTConfigPropSetPtr testSet;
		while ((testSet = mainSet->NextSetWithName("calendar_test_set")) != NULL)
		{
			cout << endl;
			_bstr_t testName = testSet->NextStringWithName("test_set_name");

			time_t start = GetLongDateTimeValue(testSet, "start_time");
			if (start == -1)
			{
				cout << "*** Failed to get start_time" << endl;
				return -1;
			}

			time_t end = GetLongDateTimeValue(testSet, "end_time");
			if (end == -1)
			{
				cout << "*** Failed to get end_time" << endl;
				return -1;
			}

			cout << "+++++++++++++++++++++++++++++++++++++++++++++++++++" << endl;
			const char * startString = ctime(&start);
			cout << "Start: " << startString << endl;

			const char * endString = ctime(&end);
			cout << "End: " << endString << endl;

			long offset;
			BOOL offsetFlag = FALSE;
			if (testSet->NextMatches("time_offset", MTConfigLib::PROP_TYPE_INTEGER) == VARIANT_TRUE)
			{
				offset = testSet->NextLongWithName("time_offset");
				offsetFlag = TRUE;
				cout << "Offset: " << offset << endl;
			}

			cout << "+++++++++++++++++++++++++++++++++++++++++++++++++++" << endl;

			TimeSegmentVector expectedSegments;
			// 1) load configuration file
			if (!LoadOneTestConfigSet(expectedSegments, testSet))
			{
				cout << "*** Failed to load test config set!" << endl;
			}

			// 2) run the test
			TimeSegmentVector segments;
			if (offsetFlag == TRUE)
			{
				calendar.SplitTimeSpan(start, end, "EST", segments);
			}
			else
			{
				calendar.SplitTimeSpan(start, end, "EST", segments);
			}

			// 3) compare the result
			if (CheckTestResult(expectedSegments, segments))
			{
				cout << "Test Calendar Set: " << (char*) testName;
				cout << " successfully" << endl;
				
				cout << endl << "---------------- Test result -----------------" << endl;
				PrintTimeSegments(segments);
				cout << "--------------------------------------------------" << endl;
			}
			else
			{
				cout << endl << "---------------- Expected result -----------------" << endl;
				PrintTimeSegments(expectedSegments);

				cout << endl << "---------------- Test result -----------------" << endl;
				PrintTimeSegments(segments);

				cout << endl << "*** Error in Test Calendar Set: " << (char*) testName << endl;
				cout << "*** Result mismatch." << endl;
			}

			// clean up
			clearAndDestroy(expectedSegments);
			clearAndDestroy(segments);
		}
	}
	catch(_com_error err)
	{
		// a required line for starting error message
		cout << ">>>>>>>>>>>>>>>>> ERROR OCCURRED IN TEST <<<<<<<<<<<<<<<<<<<<<<" << endl;

		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc(err.Description());
		_bstr_t src(err.Source());

		char* str;

		str = desc;
		if (str)
			cout << "  Description: " << str << endl;

		str = src;
		if (str)
			cout << "  Source: " << str << endl;

		return -1;
	}

	return 0;
}

void PrintRange(const DateRange & dr)
{
	MTDate dtStart(dr.GetStartDate()); 
	MTDate dtEnd(dr.GetEndDate());
	std::string strStart;
	std::string strEnd;
	LPCSTR strFormat = "%y/%m/%d %H:%M:%S";
	dtStart.ToString(strFormat, strStart);
	dtEnd.ToString(strFormat, strEnd);

	cout << "Range " << strStart.c_str() << " - " << strEnd.c_str() << " is " << dr.Days() << " days long.\n";
}

bool TestDateRange()
{
	MTDate dt6_01(6, 1, 2001);	// 06/01/2001
	MTDate dt6_02(6, 2, 2001);	// 06/02/2001
	MTDate dt6_10(6, 10,2001);	// 06/10/2001
	MTDate dt6_20(6, 20,2001);	// 06/20/2001
	MTDate dt6_30(6, 30,2001);	// 06/30/2001
	MTDate dt7_01(7, 1, 2001);	// 07/01/2001

	// 6/10/01 - infinity
	DateRange dr_6_10__inf(dt6_10.GetSecondsSinceEpoch(), 0);
	// infinity - 6/20/01
	DateRange dr_inf__6_20(0, dt6_20.GetSecondsSinceEpoch());
	// 6/1 - 6/10 
	DateRange dr_6_01__6_10(dt6_01.GetSecondsSinceEpoch(), dt6_10.GetSecondsSinceEpoch());
	// 6/20 - 6/30
	DateRange dr_6_20__6_30(dt6_20.GetSecondsSinceEpoch(), dt6_30.GetSecondsSinceEpoch());
	// 6/10 - 6/20 
	DateRange dr_6_10__6_20(dt6_10.GetSecondsSinceEpoch(), dt6_20.GetSecondsSinceEpoch());
	// 6/10 - 6/30 
	DateRange dr_6_10__6_30(dt6_10.GetSecondsSinceEpoch(), dt6_30.GetSecondsSinceEpoch());
	// 6/1 - 6/20 
	DateRange dr_6_01__6_20(dt6_01.GetSecondsSinceEpoch(), dt6_20.GetSecondsSinceEpoch());
	// 6/1 - 6/30 
	DateRange dr_6_01__6_30(dt6_01.GetSecondsSinceEpoch(), dt6_30.GetSecondsSinceEpoch());
	// 6/1 - 7/1 
	DateRange dr_6_01__7_01(dt6_01.GetSecondsSinceEpoch(), dt7_01.GetSecondsSinceEpoch());
	// 6/1 - 6/1
	DateRange dr_6_01__6_01(dt6_01.GetSecondsSinceEpoch(), dt6_01.GetSecondsSinceEpoch());
	// 6/1 - 6/2 
	DateRange dr_6_01__6_02(dt6_01.GetSecondsSinceEpoch(), dt6_02.GetSecondsSinceEpoch());

	PrintRange(dr_6_01__6_01);
	PrintRange(dr_6_01__6_02);
	PrintRange(dr_6_01__6_30);
//	PrintRange(dr_6_10__inf);


	DateRange dr1 = dr_6_10__inf.Intersection(dr_6_01__6_30);
	if(dr1 != dr_6_10__6_30)
	{
		cout << "unsubscription intersect has failed";
		return false;
	}

	PrintRange(dr1);

	DateRange dr2 = dr_inf__6_20.Intersection(dr_6_01__6_30);
	if(dr2 != dr_6_01__6_20)
	{
		cout << "subscription intersect has failed";
		return false;
	}

	PrintRange(dr2);

	DateRange dr3 = dr_6_01__6_30.After(dr_inf__6_20);
	if(dr3 != dr_6_20__6_30)
	{
		cout << "unsubscription after has failed";
		return false;
	}

	PrintRange(dr3);

	cout << "success";
	return true;
}


int main (int argc, char * argv[])
{
	int ret;

	//TestDateRange();
	TestCalendar dummy;

	if (argc == 3)
	{
		ret = AutoTest(argv[1], argv[2]);
	}
	else
	{
		//ret = ConfiguredTest();
		ret = ConfiguredDummyTest();
		ret = ConfiguredDBTest(217);
	}
	
	return ret;
}

