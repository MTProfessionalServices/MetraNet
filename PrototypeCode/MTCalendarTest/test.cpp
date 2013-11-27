/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * $Header$
 ***************************************************************************/

#include <time.h>
#include <iostream>
#include <string>

#include "test.h"
#include <mtprogids.h>

#include <metra.h>

#include <SetIterate.h>

#import <MTCalendar.tlb>
using namespace MTCALENDARLib;

#include "MTUtil.h"

#include <errobj.h>

using std::string;
using std::endl;
using std::cout;
using std::hex;
using std::dec;

// test driver class..
class TestDriver
{
	public:
  		TestDriver();
  		virtual ~TestDriver();

  		BOOL ParseArgs (int argc, char* argv[]);
  		void PrintUsage();
        BOOL Test1();
        BOOL Test2();
        BOOL Test3();
        BOOL Test4();
		BOOL Initialize();

		//	Accessors
		const string& GetLocalCode() const { return mLocalCode; } 
		const string& GetLocalStartTime() const { return mLocalStartTime; } 
		const string& GetLocalEndTime() const { return mLocalEndTime; } 

		const string& GetLocalDate() const { return mLocalDate; } 
		const string& GetLocalValue() const { return mLocalValue; } 
		const string& GetLocalNotes() const { return mLocalNotes; } 

		const string& GetLocalDay() const { return mLocalDay; } 
		const string& GetRCCode() const { return mRCCode; } 

		const string& GetTestName() const { return mTestName; } 
        const string& GetInXMLFileName() const { return mInXMLFileName; } 
        const string& GetOutXMLFileName() const { return mOutXMLFileName; } 
        const string& GetHostName() const { return mHostName; } 

		//	Mutators
		void SetLocalCode(const char* code)
		    { mLocalCode = code; } 
		void SetLocalStartTime(const char* starttime)
		    { mLocalStartTime = starttime; } 
		void SetLocalEndTime(const char* endtime)
		    { mLocalEndTime = endtime; } 

		void SetLocalDate(const char* mydate)
		    { mLocalDate = mydate; } 
		void SetLocalValue(const char* myvalue)
		    { mLocalValue = myvalue; } 
		void SetLocalNotes(const char* notes)
		    { mLocalNotes = notes; } 

		void SetLocalDay(const char* myday)
		    { mLocalDay = myday; } 
		void SetTestName(const char* testname)
		    { mTestName = testname; } 
		void SetRCCode(const char* rccode)
		    { mRCCode = rccode; } 
  
        void SetInXMLFileName(const char* inxmlfilename) 
            { mInXMLFileName = inxmlfilename; }
        void SetOutXMLFileName(const char* outxmlfilename) 
            { mOutXMLFileName = outxmlfilename; }
        void SetHostName(const char* hostname) 
            { mHostName = hostname; }

	private:

		string mHostName;
		string mLocalCode;
		string mRCCode;
		string mLocalStartTime;
		string mLocalEndTime;

		string mLocalDate;
		string mLocalValue;
		string mLocalNotes;

		string mLocalDay;
		string mTestName;
		string mInXMLFileName;
		string mOutXMLFileName;

};

//
//
//
BOOL 
TestDriver::Test1()
{
    HRESULT hr = S_OK;
	char	errStr[255];
    const char* procName = "TestDriver::Test1";

	const int CHUNKSIZE = 10;
	VARIANT rgvar[CHUNKSIZE] = { 0 };

    // create the MTUserCalendar object
    MTCALENDARLib::IMTUserCalendarPtr mtusercalendar;
	hr = mtusercalendar.CreateInstance(MTPROGID_USER_CALENDAR);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTUserCalendar object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t infile(mInXMLFileName);
	_bstr_t hostname(mHostName);
	//hr = mtusercalendar->ReadFromHost(hostname, "test\\Calendar", infile);
	//hr = mtusercalendar->Read("e:\\development\\config\\test\\calendar\\", infile );
	hr = mtusercalendar->Read("\\test\\calendar\\", infile );
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to do read xml file" << hex << hr << endl;
		return (FALSE);
	}

	// output data here 
	long count = 0;
	mtusercalendar->get_Count(&count);

    if (count > 0)
    {
	    SetIterator<IMTUserCalendarPtr, IMTCalendarDatePtr> it;
	    HRESULT hr = it.Init(mtusercalendar);
	    if (FAILED(hr))
		    return hr;
	
	    while (TRUE)
	    {
		    IMTCalendarDatePtr date = it.GetNext();
		    if (date == NULL)
			    break;
    
		    // perform the operation
		    try 
		    {
				_bstr_t retdate;
				_bstr_t retnotes;
				retdate = date->GetDate();
				retnotes = date->GetNotes();

				cout << (char*) retdate << endl;
				cout << (char*) retnotes << endl;
		    }
		    catch (ErrorObject aLocalError)
		    {
			    sprintf(errStr, "Error: %s, %s(%d) %s(%d)", 
					    aLocalError.GetModuleName(),
					    aLocalError.GetFunctionName(),
					    aLocalError.GetLineNumber(),
					    aLocalError.GetProgrammerDetail().c_str(),
					    aLocalError.GetCode());
			    cout << errStr << endl;
			    return FALSE;
		    }
		    catch (HRESULT hr)
		    {
                cout << "Error = " << hex << hr << endl ;
			    return FALSE;
		    }
		    catch (_com_error err)
		    {
                cout << "ERROR: Error = " << hex << err.Error() << dec << endl;
                return FALSE;
            }	
        }
    }


#if 0
	if (count > 0)
	{
	    IUnknown* unk = mtusercalendar->Get_NewEnum();
		IEnumVARIANTPtr ienum(unk);
		unk->Release();

		do
		{
		  ULONG cFetched;

			hr = ienum->Next(CHUNKSIZE, rgvar, &cFetched);
			if (FAILED(hr))
			  throw hr;

			for( ULONG i = 0; i < cFetched; i++ )
			{
			    // Do something with rgvar[i]
				_variant_t var(rgvar[i]);
				IMTCalendarDatePtr date(var);

				_bstr_t retdate;
				_bstr_t retnotes;
				retdate = date->GetDate();
				retnotes = date->GetNotes();

				cout << (char*) retdate << endl;
				cout << (char*) retnotes << endl;
				
				VariantClear(&rgvar[i]);
			}
		} while (hr == S_OK);
	}
	// ---------------------------------------------------------------
#endif

	//hr = mtusercalendar->Remove(36506);
	//hr = mtusercalendar->Remove(36161);
	//hr = mtusercalendar->Remove(36345);
	//hr = mtusercalendar->Remove(36519);

	// check for the days
	if (mtusercalendar->GetMonday() != NULL)
	  cout << "Monday is checked" << endl;
	else
	  cout << "Monday is not checked" << endl;

	if (mtusercalendar->GetTuesday() != NULL)
	  cout << "Tuesday is checked" << endl;
	else
	  cout << "Tuesday is not checked" << endl;
	  
	if (mtusercalendar->GetWednesday() != NULL)
	  cout << "Wednesday is checked" << endl;
	else
	  cout << "Wednesday is not checked" << endl;
	  
	if (mtusercalendar->GetThursday() != NULL)
	  cout << "Thursday is checked" << endl;
	else
	  cout << "Thursday is not checked" << endl;
	  
	if (mtusercalendar->GetFriday() != NULL)
	  cout << "Friday is checked" << endl;
	else
	  cout << "Friday is not checked" << endl;
	  
	if (mtusercalendar->GetSaturday() != NULL)
	  cout << "Saturday is checked" << endl;
	else
	  cout << "Saturday is not checked" << endl;
	  
	if (mtusercalendar->GetSunday() != NULL)
	  cout << "Sunday is checked" << endl;
	else
	  cout << "Sunday is not checked" << endl;

	if (mtusercalendar->GetDefaultWeekday() != NULL)
	  cout << "Default weekday is checked" << endl;
	else
	  cout << "Default weekday is not checked" << endl;
	  
	if (mtusercalendar->GetDefaultWeekday() != NULL)
	  cout << "Default weekend is checked" << endl;
	else
	  cout << "Default weekend is not checked" << endl;

    // create the MTTimezone object
    MTCALENDARLib::IMTTimezonePtr mttimezone;

	mttimezone = mtusercalendar->GetTimezone();
	if (mttimezone == NULL)
	{
	  cout << "timezones not defined" << endl;
	}
	else
	{  
	  cout << "timezone id = " << mttimezone->GetTimezoneID() << endl;
	  cout << "timezone offset = " << mttimezone->GetTimezoneOffset() << endl;
	}

	// write to an xml file
	//hr = mtusercalendar->WriteToHost(hostname, "test\\Calendar", outfile);
	_bstr_t outfile("eatshit.xml");
	hr = mtusercalendar->Write("E:\\development\\config\\test\\Calendar", outfile);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to do write xml file" << hex << hr << endl;
		return (FALSE);
	}

	return (TRUE);
}

//
//
//
BOOL 
TestDriver::Test2()
{
    HRESULT hr = S_OK;

	// ---------------------------------------------------------------
    // create the MTUserCalendar object
    MTCALENDARLib::IMTUserCalendarPtr mtusercalendar;
	hr = mtusercalendar.CreateInstance(MTPROGID_USER_CALENDAR);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTUserCalendar object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	// ---------------------------------------------------------------
    // create the MTRangeCollection object
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection1;
	hr = mtrangecollection1.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection2;
	hr = mtrangecollection2.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection3;
	hr = mtrangecollection3.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t RCCode;
	RCCode = "monday";
	mtrangecollection1->put_Code(RCCode);
	mtusercalendar->put_Monday(mtrangecollection1);

	RCCode = "wednesday";
	mtrangecollection2->put_Code(RCCode);
	mtusercalendar->put_Wednesday(mtrangecollection2);

	RCCode = "defaultweekday";
	mtrangecollection3->put_Code(RCCode);
	mtusercalendar->put_DefaultWeekday(mtrangecollection3);

	// write to an xml file
	_bstr_t outfile(mOutXMLFileName);
	_bstr_t hostname(mHostName);
	hr = mtusercalendar->WriteToHost(hostname, "test\\Calendar", outfile);
	//hr = mtusercalendar->Write("\\Calendar", outfile);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to do write xml file" << hex << hr << endl;
		return (FALSE);
	}

	return 0;
}


//
//
//
BOOL 
TestDriver::Test3()
{
    HRESULT hr = S_OK;

	// ---------------------------------------------------------------
    // create the MTUserCalendar object
    MTCALENDARLib::IMTUserCalendarPtr mtusercalendar;
	hr = mtusercalendar.CreateInstance(MTPROGID_USER_CALENDAR);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTUserCalendar object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	// ---------------------------------------------------------------
    // create the MTRangeCollection object
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection1;
	hr = mtrangecollection1.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection2;
	hr = mtrangecollection2.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection3;
	hr = mtrangecollection3.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t RCCode;
	RCCode = "monday";
	mtrangecollection1->put_Code(RCCode);
	mtusercalendar->put_Monday(mtrangecollection1);

	RCCode = "wednesday";
	mtrangecollection2->put_Code(RCCode);
	mtusercalendar->put_Wednesday(mtrangecollection2);

	RCCode = "defaultweekend";
	mtrangecollection3->put_Code(RCCode);
	mtusercalendar->put_DefaultWeekend(mtrangecollection3);

    // create the MTRange object
    MTCALENDARLib::IMTRangePtr mtrange1;
	hr = mtrange1.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangePtr mtrange2;
	hr = mtrange2.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

    MTCALENDARLib::IMTRangePtr mtrange3;
	hr = mtrange3.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t Code;
	_bstr_t StartTime;
	_bstr_t EndTime;

	// do stuff for monday
	Code = "Peak";
	StartTime = "07:00";
	EndTime = "07:00";

	mtrange1->put_Code(Code);
	mtrange1->put_StartTime(StartTime);
	mtrange1->put_EndTime(EndTime);

	mtrangecollection1->Add(mtrange1);

	// do stuff for wednesday
	Code = "Peak";
	StartTime = "08:00";
	EndTime = "09:00";

	mtrange2->put_Code(Code);
	mtrange2->put_StartTime(StartTime);
	mtrange2->put_EndTime(EndTime);

	mtrangecollection2->Add(mtrange2);

	mtrange3->put_Code(Code);
	mtrange3->put_StartTime(StartTime);
	mtrange3->put_EndTime(EndTime);

	mtrangecollection3->Add(mtrange3);

	// write to an xml file
	_bstr_t outfile(mOutXMLFileName);
	_bstr_t hostname(mHostName);
	hr = mtusercalendar->WriteToHost(hostname, "test\\Calendar", outfile);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to do write xml file" << hex << hr << endl;
		return (FALSE);
	}

	return 0;
}



//
//
//
BOOL 
TestDriver::Test4()
{
    HRESULT hr = S_OK;
	_bstr_t RCCode;

	// ---------------------------------------------------------------
    // create the MTUserCalendar object
    MTCALENDARLib::IMTUserCalendarPtr mtusercalendar;
	hr = mtusercalendar.CreateInstance(MTPROGID_USER_CALENDAR);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTUserCalendar object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	// ---------------------------------------------------------------
    // create the MTCalendarDate object
    MTCALENDARLib::IMTCalendarDatePtr mtcalendardate1;
	hr = mtcalendardate1.CreateInstance(MTPROGID_DATE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTCalendarDate object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTCalendarDatePtr mtcalendardate2;
	hr = mtcalendardate2.CreateInstance(MTPROGID_DATE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTCalendarDate object" 
      		<< hex << hr << endl;
		return (FALSE);

	}

	// ------------------------------------------------------------
    // create the MTRange object
    MTCALENDARLib::IMTRangePtr mtrange3;
	hr = mtrange3.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangePtr mtrange4;
	hr = mtrange4.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t Code;
	_bstr_t StartTime;
	_bstr_t EndTime;

	// do stuff for monday
	Code = "Peak";
	StartTime = "07:00";
	EndTime = "07:00";

	mtrange3->put_Code(Code);
	mtrange3->put_StartTime(StartTime);
	mtrange3->put_EndTime(EndTime);


	// do stuff for wednesday
	Code = "Peak";
	StartTime = "08:00";
	EndTime = "09:00";
	mtrange4->put_Code(Code);
	mtrange4->put_StartTime(StartTime);
	mtrange4->put_EndTime(EndTime);

	// ---------------------------------------------------------------
    // create the MTRangeCollection object
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection3;
	hr = mtrangecollection3.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection4;
	hr = mtrangecollection4.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	_bstr_t Notes;
	time_t tTime;
	DATE  Date = 42678;
	TimetFromOleDate(&tTime, Date);
	struct tm* timeTm1 = gmtime(&tTime);
	cout << "wDay = " << timeTm1->tm_mday << endl;
	cout << "wDayOfWeek = " << timeTm1->tm_wday << endl; 
	cout << "wHour = " << timeTm1->tm_hour << endl;
	cout << "wMinute = " << timeTm1->tm_min << endl;
	cout << "wMonth = " << timeTm1->tm_mon << endl;
	cout << "wSecond = " << timeTm1->tm_sec << endl;
	cout << "wYear = " << timeTm1->tm_year + 1900 << endl;

	Notes = "Independence Day";

	RCCode = "holiday";
	mtrangecollection3->put_Code(RCCode);
	mtrangecollection3->Add(mtrange3);

	mtcalendardate1->put_Date(Date);
	mtcalendardate1->put_Notes(Notes);
	mtcalendardate1->put_RangeCollection(mtrangecollection3);

	Date = 42679;
	TimetFromOleDate(&tTime, Date);
	struct tm* timeTm2 = gmtime(&tTime);
	cout << "wDay = " << timeTm2->tm_mday << endl;
	cout << "wDayOfWeek = " << timeTm2->tm_wday << endl; 
	cout << "wHour = " << timeTm2->tm_hour << endl;
	cout << "wMinute = " << timeTm2->tm_min << endl;
	cout << "wMonth = " << timeTm2->tm_mon << endl;
	cout << "wSecond = " << timeTm2->tm_sec << endl;
	cout << "wYear = " << timeTm2->tm_year + 1900 << endl;

	Notes = "Christmas";
	RCCode = "holiday";
	mtrangecollection4->put_Code(RCCode);
	mtrangecollection4->Add(mtrange4);

	mtcalendardate2->put_Date(Date);
	mtcalendardate2->put_Notes(Notes);
	mtcalendardate2->put_RangeCollection(mtrangecollection4);

	mtusercalendar->Add(mtcalendardate1);
	mtusercalendar->Add(mtcalendardate2);

	// ---------------------------------------------------------------
    // create the MTRangeCollection object
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection1;
	hr = mtrangecollection1.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangeCollectionPtr mtrangecollection2;
	hr = mtrangecollection2.CreateInstance(MTPROGID_RANGE_COLLECTION);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRangeCollection object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	RCCode = "monday";
	mtrangecollection1->put_Code(RCCode);
	mtusercalendar->put_Monday(mtrangecollection1);

	RCCode = "wednesday";
	mtrangecollection2->put_Code(RCCode);
	mtusercalendar->put_Wednesday(mtrangecollection2);


    // create the MTRange object
    MTCALENDARLib::IMTRangePtr mtrange1;
	hr = mtrange1.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}
    MTCALENDARLib::IMTRangePtr mtrange2;
	hr = mtrange2.CreateInstance(MTPROGID_RANGE);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTRange object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	// do stuff for monday
	Code = "Peak";
	StartTime = "07:00";
	EndTime = "07:00";

	mtrange1->put_Code(Code);
	mtrange1->put_StartTime(StartTime);
	mtrange1->put_EndTime(EndTime);

	mtrangecollection1->Add(mtrange1);

	// do stuff for wednesday
	Code = "Peak";
	StartTime = "08:00";
	EndTime = "09:00";
	mtrange2->put_Code(Code);
	mtrange2->put_StartTime(StartTime);
	mtrange2->put_EndTime(EndTime);

	mtrangecollection2->Add(mtrange2);

	// write to an xml file
	_bstr_t outfile(mOutXMLFileName);
	_bstr_t hostname(mHostName);
	hr = mtusercalendar->WriteToHost(hostname, "test\\Calendar", outfile);
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to do write xml file" << hex << hr << endl;
		return (FALSE);
	}

	return 0;
}

// 
// constructor
//
TestDriver::TestDriver()
{
	cout << "Entering Constructor" << endl;
	::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	cout << "Leaving Constructor" << endl;
}


// 
// destructor
//
TestDriver::~TestDriver() 
{
	cout << "Entering Destructor" << endl;
	::CoUninitialize();
	cout << "Leaving Destructor" << endl;
}

//

//
// Print Usage
//
void 
TestDriver::PrintUsage()
{
  	cout << "\nUsage: TestCalendar [options]" << endl;
  	cout << "\tOptions: "<< endl;
  	cout << "\t\t-t [test type] - test1 " << endl;
	cout << "\t\t-h [hostname] " << endl;
	cout << "\t\t-i [in xml filename] " << endl;
	cout << "\t\t-o [out xml filename] " << endl;
  	cout << "\tExample: "<< endl;
  	cout << "\t\tTestCalendar -t test1 -i infilename.xml -o outfilename.xml" << endl;

  	return;
}

//
// Initialize the test driver 
//
BOOL 
TestDriver::Initialize()
{
	// set the code, start time and end time
	SetLocalCode("peak");
	SetLocalStartTime("11/2/99");
	SetLocalEndTime("11/3/99");

	SetLocalDate("11/2/99");//
	SetLocalValue("My Birthday");
	SetLocalNotes("Cool");

	SetRCCode("monday");
	SetLocalDay("Monday");
	SetHostName("gargoyle");

	return (TRUE);
}


// 
// Parse arguments
//
BOOL 
TestDriver::ParseArgs (int argc, char* argv[])
{
	cout << "Entering ParseArgs" << endl;

  	// local variables ...
  	int i;
  	string Text;

  	// if we don't have enough args ... exit
  	if (argc < 2)
  	{
    	PrintUsage();
    	return (FALSE);
  	}

  	// parse the arguments ...
  	for (i = 1; i < argc; i++)
  	{
	    string strOption(argv[i]);

    	// get the code ...
    	if (stricmp(strOption.c_str(), "-t") == 0)
    	{
      		// get the thread mode ...
      		if (i + 1 < argc)
      		{
        		// increment i ...
        		i++;

        		// set the code...
				Text = argv[i];

        		// set the name... 
				SetTestName(Text);
      		}
      		else
      		{
        		PrintUsage();
        		return (FALSE);
      		}
    	}
		// else check to see if this option is for the number of threads ...
    	else if (stricmp(strOption.c_str(), "-i") == 0)
    	{
		  // 
		  if (i + 1 < argc)
		  {
			// increment i ...
        	i++;
        	mInXMLFileName = argv[i] ;
		  }
		}
		// else check to see if this option is for the number of threads ...
    	else if (stricmp(strOption.c_str(), "-o") == 0)
    	{
		  // 
		  if (i + 1 < argc)
		  {
			// increment i ...
        	i++;
        	mOutXMLFileName = argv[i] ;
		  }
		}
    	else if (stricmp(strOption.c_str(), "-h") == 0)
    	{
		  // 
		  if (i + 1 < argc)
		  {
			// increment i ...
        	i++;
        	mHostName = argv[i] ;
		  }
		}
  	}

	cout << "Leaving ParseArgs" << endl;
  	return (TRUE);
}


//
//
//
int 
main(int argc, char* argv[])
{
    cout << "Entering main()" << endl;

	TestDriver testdriver;

	// parse the arguments
	if (!testdriver.ParseArgs(argc, argv))
	{
	  cout << "ERROR: Parsing of arguments failed"  << endl;
	  return -1;
	}
	cout << "SUCCESS: Parsing of arguments succeeded"  << endl;
	  
	// initialize
	if (!testdriver.Initialize())
	{
	  cout << "ERROR: Initialization failed"  << endl;
	  return -1;
	}
	cout << "SUCCESS: Initialization succeeded"  << endl;

	try
	{
	  if (0 == stricmp(testdriver.GetTestName().c_str(), "test1"))
	  {
	    testdriver.Test1();
	  }
	  else if (0 == stricmp(testdriver.GetTestName().c_str(), "test2"))
	  {
	    testdriver.Test2();
	  }
	  else if (0 == stricmp(testdriver.GetTestName().c_str(), "test3"))
	  {
	    testdriver.Test3();
	  }
	  else if (0 == stricmp(testdriver.GetTestName().c_str(), "test4"))
	  {
	    testdriver.Test4();
	  }
	  else if (0 == stricmp(testdriver.GetTestName().c_str(), "all"))
	  {
	    testdriver.Test1();
	    testdriver.Test2();
	    testdriver.Test3();
	    testdriver.Test4();
	  }
	  else
	  {
		cout << "ERROR: Unknown argument passed" << endl;
		return -1;
	  }
	}
	catch (HRESULT hr)
	{
		cout << "***ERROR! " << hex << hr << dec << endl;
		return -1;
	}
	catch (_com_error err)
	{
		cout << "***ERROR _com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}
#if 0
	catch (...)
	{
		cout << "***ERROR everything else " << endl;
		return -1;
	}
#endif

    cout << "SUCCESS: Test succeeded"  << endl;

	return 0;
}

