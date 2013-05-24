/**************************************************************************
 * @doc DBLocale
 * 
 * @module  Encapsulation for Database Locale Info
 * 
 * This class encapsulates access to all the localized information
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
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | DBLocale
 ***************************************************************************/

#ifndef __DBLocale_H
#define __DBLocale_H

#include <DBAccess.h>
#include "MTSingleton.h"
#include <NTThreadLock.h>
#include <errobj.h>
#include <autologger.h>
#include <DbObjectsLogging.h>
#include <CodeLookup.h>
#include <DBViewHierarchy.h>
#include <ConfigChange.h>
#include <ThreadLock.h>
#include <MTDec.h>
#include <autoinstance.h>
#include <LanguageList.h>
#include <string>
#include <map>

using std::string;
using std::map;

// disable warning ...
#pragma warning( disable : 4251 4275 )

#define MAX_NUM_LEN 255
#define MAX_ID_LEN 10
#define DESCRIPTION_KEY_DELIMITER _T("|")

#define PRESSERVER_CONFIGDIR  L"PresServer"
#define EUROCONVERSION_FILE   L"euro_conversion.xml"
#define LOCALECURRENCY_FILE   L"LocaleCurrency.xml"

// @struct holds the description details
class LOCALDESCRIPTION {
public:
  std::wstring Description;
  std::wstring URL;
};

typedef map<__int64, wstring>	DBLocaleColl;
typedef DBLocaleColl::iterator DBLocaleIter;

typedef map<wstring, MTDecimal>	DBEuroConversionColl;
typedef DBEuroConversionColl::iterator DBEuroConversionCollIter;

// forward declarations ...
struct IMTQueryAdapter ;

// @class DBLocale
class DBLocale :
  public DBAccess,
  public virtual ObjectWithError,
  private MTSingleton<DBLocale>,
	public ConfigChangeObserver
{
// @access Public:
public:
  // @cmember Get the property description
  DLL_EXPORT std::wstring GetLocalePropertyDesc(const int &arViewID, const std::wstring &arPropertyName, 
    const std::wstring &arLangCode) ;
  // @cmember Get the property description
  DLL_EXPORT std::wstring GetLocaleViewDesc(const int &arViewID, const std::wstring &arLangCode) ;
  // @cmember Get the description 
	DLL_EXPORT std::wstring GetLocaleDesc(int aDescID, int aLangID) ;
  DLL_EXPORT std::wstring GetLocaleDesc(const int &arDescID, const std::wstring &arLangCode) ;
  DLL_EXPORT std::wstring GetLocaleDesc(const std::wstring &arFQN, const std::wstring &arLangCode) ;
	// @cmember returns a formatted string representation of currency
	// E.g. getLocaleCurrency ("3.789", "USD")
	// would return "$3.79" 
  DLL_EXPORT std::wstring GetLocaleCurrency (const MTDecimal &arAmount, const std::wstring &arCurrencyCode) ;
  // @cmember returns a formatted string representation of currency in Euro
	// E.g. getEuroCurrency ("3.789", "DEM")
	// would return "$3.79" 
  DLL_EXPORT std::wstring GetEuroCurrency (const MTDecimal &arAmount, const std::wstring &arCurrencyCode) ;
	
  // @cmember get local datetime
	// E.g. GetDateTime (<gmt datetime>, VARIANT_TRUE, <local datetime with daylight saving>)
	//									
  DLL_EXPORT BOOL GetDateTime (VARIANT aInputDateTime, 
															long aMTZoneCode,
															VARIANT_BOOL aDayLightSavingFlag, 
															VARIANT *apLocalDateTime) ;

  // @cmember Get a pointer to the DBServiceCollection.
	DLL_EXPORT static DBLocale * GetInstance() ;
  // @cmember release the pointer to the DBServiceCollection.
	DLL_EXPORT static void ReleaseInstance() ;

  // @cmember Initialize the DBLocale object
  DLL_EXPORT BOOL Init();
  // @cmember Constructor.
  DLL_EXPORT DBLocale() ;
  // @cmember Destructor
	DLL_EXPORT virtual ~DBLocale();
  // @cmember Get the language id from the code
	DLL_EXPORT long GetLanguageID(const std::wstring& arLangCode);

	virtual void ConfigurationHasChanged();


// @access Protected:
protected:
// @access Private:
private:
  //
  //  currency formatting configuration
  //
  typedef struct
  {
    _bstr_t CURRENCY_SYMBOL;  // currency symbol string, i.e $
    _bstr_t CURRENCY_THOUSANDS_DELIMITER;  // thousands delimiiter character, i.e ,
    _bstr_t CURRENCY_FRACTION_DELIMITER;  // fraction delimiter character, i.e . before cents
    long CURRENCY_SYMBOL_POSITION;  // -1= symbol before number, +1= symbol after number
  } LOCALE_CURRENCY_STRUCT;

  typedef std::map<_bstr_t, LOCALE_CURRENCY_STRUCT> LOCALE_CURRENCY_MAP;

	typedef std::map<std::pair<long,long>,std::wstring>  InstanceNameMap;

  LOCALE_CURRENCY_MAP locale_currency_map;
  BOOL ReadConfigLocaleCurrency () ;
  //
  //  currency formatting configuration
  //
	
  // @cmember parse variant date, return time_t value
	time_t ParseVariantDate(VARIANT aDate);

  // @cmember add the currency delimiters
  std::wstring AddCurrencyDelimiters(std::wstring &arCurrencyString,
    const std::wstring &arLocaleDelimiter,
    const std::wstring &arLocaleFraction) ;
  // @cmember Get the description query 
  std::wstring GetDescriptionQuery() ;
  
  // @cmember Get the Adjust DayLightSaving Time 
	void AdjustDayLightSavingTime(struct tm * aTimeStruct, 
																struct tm ** aNewTimeStruct, 
																BOOL flag);

	// @cmember Create key into the map from description and language
  __int64 MakeKey(int aDescID, int aLangID)
	{
		return ((((__int64)aDescID) << 32) + aLangID);
	}

  // @cmember the logging object 
	MTAutoInstance<MTAutoLoggerImpl<szDbObjectsTag,szDbObjectsDir> >	mLogger;  // @cmember the thread lock
  // @cmember the collection
  DBLocaleColl                    mColl ;
  DBEuroConversionColl            mEuroConvColl ;
  // @cmember the query adapter 
  IMTQueryAdapter *               mpQueryAdapter ;
	MTAutoSingleton<CCodeLookup> mpCodeLookup;
	MTAutoSingleton<DBViewHierarchy> mpViewHierarchy;
	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
	ConfigChangeObservable mObserver;
	NTThreadLock mLocaleLock,mEuroLock;

	// map of priceable item type to display name
	InstanceNameMap mInstanceNameMap;
	MTAutoSingleton<CLanguageList> mLangList;
};

// reenable the warning
#pragma warning( default : 4251 4275)

#endif // __DBLocale_H
