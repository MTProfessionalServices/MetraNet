/**************************************************************************
 * @doc ADOUtils
 * 
 * @module  utility functions for ADO
 * 
 * This module contains utility functions for ADO that make for easier
 * query generation and error handling
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Navdip Bhachech
 * $Header$
 *
 * @index | ADOUtils
 ***************************************************************************/
#include <metra.h>
#include <time.h>
#include <math.h>
#include <comdef.h>
#include <adoutil.h>
#include <mtcomerr.h>

// maximum length of any number
#define MAX_NUM_LEN 255

#if 0
// max message len in gettype function
#define MAX_MSG_LEN 255

// defines for Date Code from MFC
// Verifies will fail if the needed buffer size is too large
#define MAX_TIME_BUFFER_SIZE    128         // matches that in timecore.cpp
#define MIN_DATE                (-657434L)  // about year 100
#define MAX_DATE                2958465L    // about year 9999

// Half a second, expressed in days
#define HALF_SECOND  (1.0/172800.0)

// One-based array of days in year at month start
static int sMonthDays[13] =
	{0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365};
#endif
// @mfunc handles Com and ADO errors. goes through the ADO errors and puts them
//		into a list of strings. The strings are user displayable descriptive strings
//		@parm the COM exception thrown
//		@parm the list to put the errors in
//		@parm the ado connection pointer
void GetCOMError( _com_error & arComError, LISTADOERROR & arListADOError,
                 _ConnectionPtr & arConnectionPtr)
{
	long errNum;
	_TCHAR tempError[MAX_NUM_LEN];
	std::wstring errorString;

	try
	{
		// ADO Error/Exception Handler
		GetADOError( arListADOError, arConnectionPtr );
		errNum = arComError.Error();
		_stprintf(tempError, _T("ErrorNumber: %X | Description: "), errNum);
		errorString = tempError;
		errorString += arComError.ErrorMessage();

		//Non-ADO Native error/Exception Handler
		arListADOError.push_front(errorString);

		// #import bug workaround (should not be necessary after Visual C++ 5.0 Service Pack 3)
		//IErrorInfo * pErr = arComError.ErrorInfo();
		//pErr->Release();
		//pErr->Release();
	}
  catch(...)
  {
		arListADOError.push_front(_T("Unknown Error"));
  }
}

// @mfunc handles ADO errors. builds a list of ADO error strings
//		@parm the list of string holding errors
//		@parm the ADO connection
void GetADOError(LISTADOERROR & arListADOError, _ConnectionPtr & arConnectionPtr)
{
	ErrorsPtr 	errorsCollection = NULL;
	ErrorPtr		adoError	= NULL;

	long nCount;
	long errNum;
	std::wstring errorString;
	_TCHAR tempErrorString[MAX_NUM_LEN + 42];
	long iter;
	_variant_t position;

	try
	{
		if( arConnectionPtr == NULL )
			return;

		// Get errorsCollection from connection
		try
		{	
			errorsCollection = arConnectionPtr->GetErrors();
		}
		catch (_com_error & err)
		{
			std::string msg;
			std::wstring wmsg;
			StringFromComError(msg, "No ADOError info. Retrieving errors from connection failed", err);
			ASCIIToWide(wmsg, msg);
			arListADOError.push_front(wmsg.c_str());
			return;
		}
		
		nCount = errorsCollection->GetCount();

		// Loop through errorsCollection
		for(iter = 0; iter < nCount; iter++)
		{
			errorString = _T("");
			try			
			{
				// Get Error Item
				position = iter;
				adoError = errorsCollection->GetItem(position);

				// Get Error Number
				errNum = adoError->GetNumber();
				_stprintf(tempErrorString, _T("ErrorNumber: %X | Description: "), errNum);
				errorString = tempErrorString;

				// Get Error Description
        if(adoError->GetDescription().length() > 0)
				  errorString += adoError->GetDescription();
				errorString += _T(" | Source: ");

				// Get Error Source
				if(adoError->GetSource().length() > 0)
          errorString += adoError->GetSource();
				errorString += _T(" | NativeError: ");

				// Get Native Error
				errNum = adoError->GetNativeError();
				_stprintf(tempErrorString, _T("%ld | SQLState: "), errNum);
				errorString += tempErrorString;

				// Get SQL State
        //may be this would solve random *** UNABLE TO LOG ADO ERROR*** crashes
        //casting _bstr_t to wchar_t* operator will return NULL for empty bstr
        //+= operator will crash in this case
        if(adoError->GetSQLState().length() > 0)
				  errorString += adoError->GetSQLState();
			}
			catch (_com_error & err)
			{
				//log whatever error info we've got
				std::string msg;
				std::wstring wmsg;
				StringFromComError(msg, " - incomplete ADOError info. Retrieving error failed", err);
				ASCIIToWide(wmsg, msg);

				errorString += wmsg.c_str();
			}

			// push the error string on the list
			arListADOError.push_front( errorString );

			// Release Error Object
			adoError = NULL;
		}
	}
	catch(...)
	{
		arListADOError.push_front( _T("*** UNABLE TO LOG ADO ERROR *** (Unknown Exception was raised while logging exception)") );
	}
}

#if 0
// code from MFC to convert from tm to oledate
BOOL OleDateFromTm(WORD aYear, WORD aMonth, WORD aDay,
	WORD aHour, WORD aMinute, WORD aSecond, DATE& arDateDest)
{
	// Validate year and month (ignore day of week and milliseconds)
	if (aYear > 9999 || aMonth < 1 || aMonth > 12)
		return FALSE;

	//  Check for leap year and set the number of days in the month
	BOOL bLeapYear = ((aYear & 3) == 0) &&
		((aYear % 100) != 0 || (aYear % 400) == 0);

	int nDaysInMonth =
		sMonthDays[aMonth] - sMonthDays[aMonth-1] +
		((bLeapYear && aDay == 29 && aMonth == 2) ? 1 : 0);

	// Finish validating the date
	if (aDay < 1 || aDay > nDaysInMonth ||
		aHour > 23 || aMinute > 59 ||
		aSecond > 59)
	{
		return FALSE;
	}

	// Cache the date in days and time in fractional days
	long nDate;
	double dblTime;

	//It is a valid date; make Jan 1, 1AD be 1
	nDate = aYear*365L + aYear/4 - aYear/100 + aYear/400 +
		sMonthDays[aMonth-1] + aDay;

	//  If leap year and it's before March, subtract 1:
	if (aMonth <= 2 && bLeapYear)
		--nDate;

	//  Offset so that 12/30/1899 is 0
	nDate -= 693959L;

	dblTime = (((long)aHour * 3600L) +  // hrs in seconds
		((long)aMinute * 60L) +  // mins in seconds
		((long)aSecond)) / 86400.;

	arDateDest = (double) nDate + ((nDate >= 0) ? dblTime : -dblTime);

	return TRUE;
}

// code from MFC to convert from oledate to tm
// Note: this was showing the month off by 1. added a fix for this
BOOL TmFromOleDate(DATE aDateSrc, struct tm& arTmDest)
{
	// The legal range does not actually span year 0 to 9999.
	if (aDateSrc > MAX_DATE || aDateSrc < MIN_DATE) // about year 100 to about 9999
		return FALSE;

	long nDays;             // Number of days since Dec. 30, 1899
	long nDaysAbsolute;     // Number of days since 1/1/0
	long nSecsInDay;        // Time in seconds since midnight
	long nMinutesInDay;     // Minutes in day

	long n400Years;         // Number of 400 year increments since 1/1/0
	long n400Century;       // Century within 400 year block (0,1,2 or 3)
	long n4Years;           // Number of 4 year increments since 1/1/0
	long n4Day;             // Day within 4 year block
							//  (0 is 1/1/yr1, 1460 is 12/31/yr4)
	long n4Yr;              // Year within 4 year block (0,1,2 or 3)
	BOOL bLeap4 = TRUE;     // TRUE if 4 year block includes leap year

	double dblDate = aDateSrc; // tempory serial date

	// If a valid date, then this conversion should not overflow
	nDays = (long)dblDate;

	// Round to the second
	dblDate += ((aDateSrc > 0.0) ? HALF_SECOND : -HALF_SECOND);

	nDaysAbsolute = (long)dblDate + 693959L; // Add days from 1/1/0 to 12/30/1899

	dblDate = fabs(dblDate);
	nSecsInDay = (long)((dblDate - floor(dblDate)) * 86400.);

	// Calculate the day of week (sun=1, mon=2...)
	//   -1 because 1/1/0 is Sat.  +1 because we want 1-based
	arTmDest.tm_wday = (int)((nDaysAbsolute - 1) % 7L) + 1;

	// Leap years every 4 yrs except centuries not multiples of 400.
	n400Years = (long)(nDaysAbsolute / 146097L);

	// Set nDaysAbsolute to day within 400-year block
	nDaysAbsolute %= 146097L;

	// -1 because first century has extra day
	n400Century = (long)((nDaysAbsolute - 1) / 36524L);

	// Non-leap century
	if (n400Century != 0)
	{
		// Set nDaysAbsolute to day within century
		nDaysAbsolute = (nDaysAbsolute - 1) % 36524L;

		// +1 because 1st 4 year increment has 1460 days
		n4Years = (long)((nDaysAbsolute + 1) / 1461L);

		if (n4Years != 0)
			n4Day = (long)((nDaysAbsolute + 1) % 1461L);
		else
		{
			bLeap4 = FALSE;
			n4Day = (long)nDaysAbsolute;
		}
	}
	else
	{
		// Leap century - not special case!
		n4Years = (long)(nDaysAbsolute / 1461L);
		n4Day = (long)(nDaysAbsolute % 1461L);
	}

	if (bLeap4)
	{
		// -1 because first year has 366 days
		n4Yr = (n4Day - 1) / 365;

		if (n4Yr != 0)
			n4Day = (n4Day - 1) % 365;
	}
	else
	{
		n4Yr = n4Day / 365;
		n4Day %= 365;
	}

	// n4Day is now 0-based day of year. Save 1-based day of year, year number
	arTmDest.tm_yday = (int)n4Day + 1;
	arTmDest.tm_year = n400Years * 400 + n400Century * 100 + n4Years * 4 + n4Yr;

	// Handle leap year: before, on, and after Feb. 29.
	if (n4Yr == 0 && bLeap4)
	{
		// Leap Year
		if (n4Day == 59)
		{
			/* Feb. 29 */
			arTmDest.tm_mon = 2;
			arTmDest.tm_mday = 29;
			goto DoTime;
		}

		// Pretend it's not a leap year for month/day comp.
		if (n4Day >= 60)
			--n4Day;
	}

	// Make n4DaY a 1-based day of non-leap year and compute
	//  month/day for everything but Feb. 29.
	++n4Day;

	// Month number always >= n/32, so save some loop time */
	for (arTmDest.tm_mon = (n4Day >> 5) + 1;
		n4Day > sMonthDays[arTmDest.tm_mon]; arTmDest.tm_mon++);

	arTmDest.tm_mday = (int)(n4Day - sMonthDays[arTmDest.tm_mon-1]);

DoTime:
	if (nSecsInDay == 0)
		arTmDest.tm_hour = arTmDest.tm_min = arTmDest.tm_sec = 0;
	else
	{
		arTmDest.tm_sec = (int)nSecsInDay % 60L;
		nMinutesInDay = nSecsInDay / 60L;
		arTmDest.tm_min = (int)nMinutesInDay % 60;
		arTmDest.tm_hour = (int)nMinutesInDay / 60;
	}

	// Note: nav's fix for date issue - month was 1 off, years off by 1900
	// weekdays off by 1, day of year off by 1
	arTmDest.tm_mon--;
	arTmDest.tm_year = arTmDest.tm_year - 1900;
	arTmDest.tm_wday--;
	arTmDest.tm_yday--;

	return TRUE;
}

// @mfunc get new id based on the input from the t_current_id table
//		@parm the string to get the id for
//		@parm an int that returns the id
BOOL GetNewID(const wchar_t* pField, long& arID)
{
  	// local variables ...
  	BOOL bOK = TRUE;
	ADODBContext mDBContext;
	std::wstring langRequest;
	_RecordsetPtr pRecordset;
  	DWORD nError=NO_ERROR;

	if (!mDBContext.Init())
	{
		bOK = FALSE;
	}

	// connect to the database
	if (bOK && !mDBContext.Connect())
	{
		bOK = FALSE;
	}

   	// select the data from the t_current_id table ...
   	langRequest = L"GetCurrentID @nm_current = N'";
   	langRequest += pField;
   	langRequest += _T("'");
    
   	//  execute the command
   	if (!mDBContext.Execute (langRequest, pRecordset))
   	{
   		throw mDBContext.GetLastError();
   	}

	// check for null record set
	if (bOK && pRecordset == NULL)
	{
		bOK = FALSE;
	}
	
	if (!bOK)
	{
		throw mDBContext.GetLastError();
	}

	//If either the BOF or EOF property is True, there is no current record.
	if ((pRecordset->adoEOF ==	VARIANT_TRUE) &&
		(pRecordset->BOF	==	VARIANT_TRUE))
	{
		throw ERROR_NO_MORE_ITEMS;
	}
		
	// Parse the record set
	// CrackStrVariant turns any datatype into a string
	while (pRecordset->adoEOF == VARIANT_FALSE)
	{
		// get the uniq, nm_cde values
		arID = pRecordset->Fields->GetItem(_variant_t(_T("id_current")))->Value.lVal;

		// Move to next record
		pRecordset->MoveNext();
	}

	// disconnect from the database
	if (!mDBContext.Disconnect())
	{
	  throw mDBContext.GetLastError();
	}

  	return bOK;  
}

// @mfunc converts a char string into a wide char string
//		@parm the wide string to place the output in
//		@parm the char string to convert
//		@parm the length of the char string
int CharToWString(wstring & arWstring, const char * apChar,
         int aLen /* = -1 */)
{
 // if no length given, string should be null terminated.
 int len = MultiByteToWideChar(
  CP_UTF8,          // code page
  0,             // character-type options
  apChar,           // address of string to map
  aLen,            // number of bytes in string
  NULL,            // address of wide-character buffer
  0);             // size of buffer

 wchar_t * out = new wchar_t[len];
 (void) MultiByteToWideChar(
  CP_UTF8,          // code page
  0,             // character-type options
  apChar,           // address of string to map
  aLen,            // number of bytes in string
  out,            // address of wide-character buffer
  len);            // size of buffer

 // put it into the wstring
 arWstring.assign(out, len);
 delete [] out;
 return 0;
}

// @mfunc cracks a database type string e.g. 'varchar' into
//		a constant, e.g. VT_BSTR that can be used by other
//		objects
//		@parm an int that returns the cracked data
//		@parm the string to crack
BOOL CrackPropertyType(int & arTypeInt, const std::wstring aStrType)
{
	BOOL retval = TRUE;

	// start the conversion. list the common types first for efficiency
	if (aStrType == _T("int"))
		arTypeInt = VT_I4;
	else if (aStrType == _T("varchar"))
		arTypeInt = VT_BSTR;
	else if (aStrType == _T("datetime"))
		arTypeInt = VT_DATE; 
	else if (aStrType == _T("float"))
		arTypeInt = VT_R4;
	else if (aStrType == _T("integer"))
		arTypeInt = VT_I4;
	else if (aStrType == _T("currency"))
		arTypeInt = VT_CY;
	else if (aStrType == _T("char"))
		arTypeInt = VT_BSTR;
	else if (aStrType == _T("smallint"))
		arTypeInt = VT_I2;
	else {
		retval = FALSE; // indicate a failure
		arTypeInt = VT_BSTR; // default to string type
	}
	return retval;
}

// @mfunc cracks a variant returned by ADO into a user displayable string
//		Taken from the CCrack::strVariant method found in the
//		DAOVIEW sample that ships with VC++
//		@parm a string that returns the cracked data
//		@parm the variant to crack
BOOL CrackStrVariant(std::wstring &arCrackedString, const _variant_t &  arVariantToCrack)
{
	wchar_t tempNumberString[MAX_NUM_LEN];
	double tempCurrency;
	double tempDouble;
	DATE tempDate;
	struct tm tempTMStruct;
	switch(arVariantToCrack.vt){
        case VT_EMPTY:
        case VT_NULL:
            arCrackedString = _T("NULL");
            break;
        case VT_I2:
            _stprintf(tempNumberString, _T("%hd"),V_I2(&arVariantToCrack));
						arCrackedString = tempNumberString;
            break;
        case VT_I4:
            _stprintf(tempNumberString, _T("%d"),V_I4(&arVariantToCrack));
						arCrackedString = tempNumberString;
            break;
        case VT_R4:
				    _stprintf(tempNumberString, _T("%e"),(double)V_R4(&arVariantToCrack));
						arCrackedString = tempNumberString;
            break;
        case VT_R8:
				    _stprintf(tempNumberString, _T("%e"),V_R8(&arVariantToCrack));
						arCrackedString = tempNumberString;
						break;
        case VT_CY:
						// MFC would use arCrackedString = COleCurrency(arVariantToCrack).Format();
						//arCrackedString = _T("Currency");
						tempCurrency = arVariantToCrack.cyVal.int64;
						tempDouble = tempCurrency / 10000;
						_stprintf(tempNumberString, _T("%e"), tempDouble);
						arCrackedString = tempNumberString;
            break;
        case VT_DATE:
            // MFC would use arCrackedString = COleDateTime(arVariantToCrack).Format(_T("%m %d %y"));
						//arCrackedString = _T("Date");
						tempDate = arVariantToCrack.date;
						TmFromOleDate(tempDate, tempTMStruct);
						wcsftime(tempNumberString, 255, _T("%Y/%m/%d %X"), &tempTMStruct);
						arCrackedString = tempNumberString;
            break;
        case VT_BSTR:
            arCrackedString = V_BSTR( &arVariantToCrack );
            break;
        case VT_DISPATCH:
            arCrackedString = _T("VT_DISPATCH");
            break;
        case VT_ERROR:
            arCrackedString = _T("VT_ERROR");
            break;
        case VT_BOOL:
            arCrackedString = ( V_BOOL(&arVariantToCrack) ? _T("TRUE") : _T("FALSE"));
						break;
        case VT_VARIANT:
            arCrackedString = _T("VT_VARIANT");
            break;
        case VT_UNKNOWN:
            arCrackedString = _T("VT_UNKNOWN");
            break;
        case VT_I1:
            arCrackedString = _T("VT_I1");
            break;
        case VT_UI1:
				    _stprintf(tempNumberString, _T("0x%02hX"),(unsigned short)V_UI1(&arVariantToCrack));
						arCrackedString = tempNumberString;
            break;
        case VT_UI2:
            arCrackedString = _T("VT_UI2");
            break;
        case VT_UI4:
            arCrackedString = _T("VT_UI4");
            break;
        case VT_I8:
            arCrackedString = _T("VT_I8");
            break;
        case VT_UI8:
            arCrackedString = _T("VT_UI8");
            break;
        case VT_INT:
            arCrackedString = _T("VT_INT");
            break;
        case VT_UINT:
            arCrackedString = _T("VT_UINT");
            break;
        case VT_VOID:
            arCrackedString = _T("VT_VOID");
            break;
        case VT_HRESULT:
            arCrackedString = _T("VT_HRESULT");
            break;
        case VT_PTR:
            arCrackedString = _T("VT_PTR");
            break;
        case VT_SAFEARRAY:
            arCrackedString = _T("VT_SAFEARRAY");
            break;
        case VT_CARRAY:
            arCrackedString = _T("VT_CARRAY");
            break;
        case VT_USERDEFINED:
            arCrackedString = _T("VT_USERDEFINED");
            break;
        case VT_LPSTR:
            arCrackedString = _T("VT_LPSTR");
            break;
        case VT_LPWSTR:
            arCrackedString = _T("VT_LPWSTR");
            break;
        case VT_FILETIME:
            arCrackedString = _T("VT_FILETIME");
            break;
        case VT_BLOB:
            arCrackedString = _T("VT_BLOB");
            break;
        case VT_STREAM:
            arCrackedString = _T("VT_STREAM");
            break;
        case VT_STORAGE:
            arCrackedString = _T("VT_STORAGE");
            break;
        case VT_STREAMED_OBJECT:
            arCrackedString = _T("VT_STREAMED_OBJECT");
            break;
        case VT_STORED_OBJECT:
            arCrackedString = _T("VT_STORED_OBJECT");
            break;
        case VT_BLOB_OBJECT:
            arCrackedString = _T("VT_BLOB_OBJECT");
            break;
        case VT_CF:
            arCrackedString = _T("VT_CF");
            break;
        case VT_CLSID:
            arCrackedString = _T("VT_CLSID");
            break;
    }
    WORD vt = arVariantToCrack.vt;
    if(vt & VT_ARRAY){
        vt = vt & ~VT_ARRAY;
        arCrackedString = _T("Array of ");
    }
    if(vt & VT_BYREF){
        vt = vt & ~VT_BYREF;
        arCrackedString += _T("Pointer to ");
    }
    if(vt != arVariantToCrack.vt){
        switch(vt){
            case VT_EMPTY:
                arCrackedString += _T("VT_EMPTY");
                break;
            case VT_NULL:
                arCrackedString += _T("VT_NULL");
                break;
            case VT_I2:
                arCrackedString += _T("VT_I2");
                break;
            case VT_I4:
                arCrackedString += _T("VT_I4");
                break;
            case VT_R4:
                arCrackedString += _T("VT_R4");
                break;
            case VT_R8:
                arCrackedString += _T("VT_R8");
                break;
            case VT_CY:
                arCrackedString += _T("VT_CY");
                break;
            case VT_DATE:
                arCrackedString += _T("VT_DATE");
                break;
            case VT_BSTR:
                arCrackedString += _T("VT_BSTR");
                break;
            case VT_DISPATCH:
                arCrackedString += _T("VT_DISPATCH");
                break;
            case VT_ERROR:
                arCrackedString += _T("VT_ERROR");
                break;
            case VT_BOOL:
                arCrackedString += _T("VT_BOOL");
                break;
            case VT_VARIANT:
                arCrackedString += _T("VT_VARIANT");
                break;
            case VT_UNKNOWN:
                arCrackedString += _T("VT_UNKNOWN");
                break;
            case VT_I1:
                arCrackedString += _T("VT_I1");
                break;
            case VT_UI1:
                arCrackedString += _T("VT_UI1");
                break;
            case VT_UI2:
                arCrackedString += _T("VT_UI2");
                break;
            case VT_UI4:
                arCrackedString += _T("VT_UI4");
                break;
            case VT_I8:
                arCrackedString += _T("VT_I8");
                break;
            case VT_UI8:
                arCrackedString += _T("VT_UI8");
                break;
            case VT_INT:
                arCrackedString += _T("VT_INT");
                break;
            case VT_UINT:
                arCrackedString += _T("VT_UINT");
                break;
            case VT_VOID:
                arCrackedString += _T("VT_VOID");
                break;
            case VT_HRESULT:
                arCrackedString += _T("VT_HRESULT");
                break;
            case VT_PTR:
                arCrackedString += _T("VT_PTR");
                break;
            case VT_SAFEARRAY:
                arCrackedString += _T("VT_SAFEARRAY");
                break;
            case VT_CARRAY:
                arCrackedString += _T("VT_CARRAY");
                break;
            case VT_USERDEFINED:
                arCrackedString += _T("VT_USERDEFINED");
                break;
            case VT_LPSTR:
                arCrackedString += _T("VT_LPSTR");
                break;
            case VT_LPWSTR:
                arCrackedString += _T("VT_LPWSTR");
                break;
            case VT_FILETIME:
                arCrackedString += _T("VT_FILETIME");
                break;
            case VT_BLOB:
                arCrackedString += _T("VT_BLOB");
                break;
            case VT_STREAM:
                arCrackedString += _T("VT_STREAM");
                break;
            case VT_STORAGE:
                arCrackedString += _T("VT_STORAGE");
                break;
            case VT_STREAMED_OBJECT:
                arCrackedString += _T("VT_STREAMED_OBJECT");
                break;
            case VT_STORED_OBJECT:
                arCrackedString += _T("VT_STORED_OBJECT");
                break;
            case VT_BLOB_OBJECT:
                arCrackedString += _T("VT_BLOB_OBJECT");
                break;
            case VT_CF:
                arCrackedString += _T("VT_CF");
                break;
            case VT_CLSID:
                arCrackedString += _T("VT_CLSID");
                break;
        }
		}
		return TRUE;
}


// @mfunc gets a textual description of the type of a character
//		@parm the type
//		@rdesc a textual description of the type
std::wstring GetType(const int aADOType)
{
	_TCHAR tempString[MAX_MSG_LEN];
	std::wstring retString = _T("BadString");

	 switch(aADOType)
   {
   case adBigInt:
      retString = _T("(adBigInt) An 8-byte signed integer");
      break;
   case adBinary:
      retString = _T("(adBinary) A binary value");
      break;
   case adBoolean:
      retString = _T("(adBoolean) A Boolean value");
      break;
   case adBSTR:
      retString = _T("(adBSTR) A null-terminated character string (Unicode)");
      break;
   case adChar:
      retString = _T("(adChar) A String value");
      break;
   case adCurrency:
      retString = _T("(adCurrency) A currency value (8-byte signed integer scaled by 10,000)");
      break;
   case adDate:
      retString = _T("(adDate) A Date value");
      break;
   case adDBDate:
      retString = _T("(adDBDate) A date value (yyyymmdd)");
      break;
   case adDBTime:
      retString = _T("(adDBTime) A time value (hhmmss)");
      break;
   case adDBTimeStamp:
      retString = _T("(adDBTimeStamp) A date-time stamp (yyyymmddhhmmss plus a fraction in billionths)");
      break;
   case adDecimal:
      retString = _T("(adDecimal) An exact numeric value with a fixed precision and scale");
      break;
   case adDouble:
      retString = _T("(adDouble) A double-precision floating point value");
      break;
   case adEmpty:
      retString = _T("(adEmpty) No value was specified");
      break;
   case adError:
      retString = _T("(adError) A 32-bit Error code");
      break;
   case adGUID:
      retString = _T("(adGUID) A globally unique identifier (GUID)");
      break;
   case adIDispatch:
      retString = _T("(adIDispatch) A pointer to an IDispatch interface on an OLE object");
      break;
   case adInteger:
      retString = _T("(adInteger) A 4-byte signed integer");
      break;
   case adIUnknown:
      retString = _T("(adIUnknown) A pointer to an IUnknown interface on an OLE object");
      break;
   case adLongVarBinary:
      retString = _T("(adLongVarBinary) A long binary value (Parameter object only)");
      break;
   case adLongVarChar:
      retString = _T("(adLongVarChar) A long String value (Parameter object only)");
      break;
   case adLongVarWChar:
      retString = _T("(adLongVarWChar) A long null-terminated string value (Parameter object only)");
      break;
   case adNumeric:
      retString = _T("(adNumeric) An exact numeric value with a fixed precision and scale");
      break;
   case adSingle:
      retString = _T("(adSingle) A single-precision floating point value");
      break;
   case adSmallInt:
      retString = _T("(adSmallInt) A 2-byte signed integer");
      break;
   case adTinyInt:
      retString = _T("(adTinyInt) A 1-byte signed integer");
      break;
   case adUnsignedBigInt:
      retString = _T("(adUnsignedBigInt) An 8-byte unsigned integer");
      break;
   case adUnsignedInt:
      retString = _T("(adUnsignedInt) A 4-byte unsigned integer");
      break;
   case adUnsignedSmallInt:
      retString = _T("(adUnsignedSmallInt) A 2-byte unsigned integer");
      break;
   case adUnsignedTinyInt:
      retString = _T("(adUnsignedTinyInt) A 1-byte unsigned integer");
      break;
   case adUserDefined:
      retString = _T("(adUserDefined) A user-defined variable");
      break;
   case adVarBinary:
      retString = _T("(adVarBinary) A binary value (Parameter object only)");
      break;
   case adVarChar:
      retString = _T("(adVarChar) A String value (Parameter object only)");
      break;
   case adVariant:
      retString = _T("(adVariant) An OLE Automation Variant");
      break;
   case adVarWChar:
      retString = _T("(adVarWChar) A null-terminated Unicode character string (Parameter object only)");
      break;
   case adWChar:
      retString = _T("(adWChar) A null-terminated Unicode character string");
      break;
   default:
		 _stprintf(tempString, _T("Unrecognized Type <%d>"), aADOType);
		 retString = tempString;
   }
   return retString;
}
#endif 
