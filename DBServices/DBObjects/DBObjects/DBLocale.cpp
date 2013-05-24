/**************************************************************************
 * @doc DBLocale
 * 
 * @module  Encapsulation for Database Services Collection|
 * 
 * This class encapsulates access to all the defined services in the
 * database. 
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

#include <metra.h>
#include <mtprogids.h>
#include <DBLocale.h>
#include <DBSQLRowset.h>
#include <DBConstants.h>
#include <DBViewHierarchy.h>
#include <DBProductView.h>
#include <DBProductViewProperty.h>
#include <mtglobal_msg.h>
#include <DBConstants.h>
#include <loggerconfig.h>

//#include <ConfiguredCal.h>
#include <CalendarLib.h>
#include <mtzoneinfo.h>
#include <ConfigDir.h>
#include <math.h>
#include <autocritical.h>

#ifdef max
#undef max
#endif
#ifdef min
#undef min
#endif

// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

//
//	@mfunc
//	Constructor. Initialize the data members.
//  @rdesc 
//  No return value
//
DBLocale::DBLocale()
: mpQueryAdapter(NULL)
{
}

//
//	@mfunc
//	Destructor
//  @rdesc 
//  No return value
//
DBLocale::~DBLocale()
{
	// stop the observer thread.  This is necessary so that we don't delete 
	// member variables that may be in use while we are trying to perform synchronization
	mObserver.StopThread(INFINITE);

  // delete the allocated memory ...


  mColl.clear() ;
  mEuroConvColl.clear() ;

  // release the interface ptrs ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
  }
}

// call GetInstance on the DBLocale Singleton
DLL_EXPORT DBLocale * DBLocale::GetInstance()
{
	return MTSingleton<DBLocale>::GetInstance();
}

// call ReleaseInstance on the DBLocale Singleton
DLL_EXPORT void DBLocale::ReleaseInstance()
{
	MTSingleton<DBLocale>::ReleaseInstance();
}

void DBLocale::ConfigurationHasChanged()
{
	// step 1: lock the collections
	AutoCriticalSection aLock(&mLocaleLock);
	AutoCriticalSection aEuroLock(&mEuroLock);

	// step 2: clear the collections
	mColl.clear() ;
	mEuroConvColl.clear() ;
	locale_currency_map.clear();

	if(mpQueryAdapter != NULL) {
		mpQueryAdapter->Release();
		mpQueryAdapter = NULL;
	}

	// step 3: reinitialize the object
	Init();
}

//
//	@mfunc
//	Initialize the DBLocale. Read in all the defined descriptions and 
//  associated properties from the database.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code
//  is saved in the mLastError data member.
//
BOOL DBLocale::Init()
{
  // local variables ...
  BOOL bRetCode=TRUE;
  BOOL bRetCode2=TRUE ;
  DBSQLRowset myRowset;
  std::wstring wstrDesc ;
  std::wstring wstrLangCode ;
  std::wstring wstrCurrCode ;
  std::wstring wstrKey;
  std::wstring wstrCmd ;
  _bstr_t bstrCurrencyCode ;
  MTDecimal convRate ;
	
	if(!mObserver.IsRunning()) {

		mObserver.Init("DbLocaleChangeEvent");
		mObserver.AddObserver(*this);

		if (!mObserver.StartThread()) {
			SetError(FALSE,"Failed to start observer thread.");
			return FALSE;
		}
	}

  // if the query adapter isnt initialized ...
  if (mpQueryAdapter == NULL)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
//      _bstr_t configPath = "\\Localization" ;
      _bstr_t configPath = "\\Queries\\Localization" ;
      queryAdapter->Init(configPath) ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;
      bRetCode = DBAccess::Init((wchar_t*)configPath) ;
      if (bRetCode == FALSE)
      {
        SetError (DBAccess::GetLastError(), "Init() failed. Unable to initialize dbaccess layer");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBLocale::Init", 
        "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
      bRetCode = FALSE ;
    }
  }
    
  // if we havent gotten an error yet ...
  if (bRetCode == TRUE)
  {
    // get the description query ...
    wstrCmd = GetDescriptionQuery() ;
    
    // execute a command to get the product view properties from the database ...
    bRetCode = DBAccess::Execute (wstrCmd, myRowset) ;
    if (bRetCode == FALSE)
    {
      SetError(DBAccess::GetLastError(), "Unable to execute database query") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    
    // iterate over all the records ...
    while (bRetCode == TRUE && !myRowset.AtEOF())
    {
			int nDescID;
			int nLangCode;

      // get the description id, language id, country code and description
      myRowset.GetIntValue(_variant_t (DB_DESCRIPTION_ID), nDescID) ;
      myRowset.GetIntValue(_variant_t (DB_LANGUAGE_ID), nLangCode) ;
      myRowset.GetWCharValue(_variant_t (DB_DESCRIPTION), wstrDesc) ;
      
      // add the new entry into the map ...
      mColl[MakeKey(nDescID, nLangCode)] = wstrDesc;
      
      // Move to next record
      bRetCode = myRowset.MoveNext();
    }
    
    // disconnect from the database ...
    bRetCode2 = DBAccess::Disconnect() ;
    if (bRetCode2 == FALSE)
    {
      // if there's no error pending ... log it
      if (bRetCode == TRUE)
      {
        SetError(DBAccess::GetLastError(), "Unable to disconnect from database");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        bRetCode = FALSE ;
      }
    }
  }
  try
  {
    // read in the euro conversion table ...
    CONFIGLOADERLib::IMTConfigLoaderPtr configLoader(MTPROGID_CONFIGLOADER);

    // initialize the configLoader ...
    configLoader->Init() ;

    CONFIGLOADERLib::IMTConfigPropSetPtr confSet = 
      configLoader->GetEffectiveFile(PRESSERVER_CONFIGDIR, EUROCONVERSION_FILE);

    // get the config data ...
    CONFIGLOADERLib::IMTConfigPropSetPtr subset ;

    // read in the xml config file ...
    while ((subset = confSet->NextSetWithName("euro_conversion")) != NULL)
    {
      // read in the current view's data ...
      bstrCurrencyCode = subset->NextStringWithName("currency_code") ;
      convRate = subset->NextDecimalWithName("conversion_rate") ;
      wstrCurrCode = bstrCurrencyCode ;

      // insert the key and values ...
      mEuroConvColl[wstrCurrCode] = convRate ;
    }
  }
  catch (_com_error e)
  {
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBLocale::Init", 
      "Unable to initialize euro conversion table");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
    bRetCode = FALSE ;
  }

	std::string tzdir;
	if (!GetMTConfigDir(tzdir))
	{
    SetError(DBAccess::GetLastError(), "Unable to get configuration root directory");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    bRetCode = FALSE ;
	}
	else
	{
		tzdir += "\\timezone\\zoneinfo";
		settzdir(tzdir.c_str());
	}

  // read the supported currency list

  BOOL bOK = ReadConfigLocaleCurrency () ;

  return bRetCode ;
}

//
// @mfunc 
//
// @parm 
// @rdesc 
//
//
std::wstring DBLocale::GetLocalePropertyDesc(const int &arViewID, 
              const std::wstring &arPropertyName, 
              const std::wstring &arLangCode) 
{
  // local variables ...
  std::wstring wstrRetVal ;
  int nDesc ;
  DBProductView *pView=NULL ;
  DBProductViewProperty *pProperty=NULL ;
  BOOL bRetCode=TRUE ;
  std::wstring wstrPropertyName ;
  
  // convert the property to lower case ...
  wstrPropertyName = arPropertyName ;
  _wcslwr((wchar_t *) wstrPropertyName.c_str()); //wstrPropertyName.toLower();

	// convert if it is a product catalog instance ID
	long realViewID = arViewID;
	if(realViewID < 0 && !mVHinstance->TranslateID(realViewID,realViewID)) {
		mLogger->LogVarArgs(LOG_ERROR,"Unable to translate product catalog view id %d",realViewID);
		return wstrRetVal;
	}

	// find the view ...
	try {
		bRetCode = mpViewHierarchy->FindView(realViewID, (DBView * &) pView);
		if (bRetCode == FALSE)
		{
			SetError(mpViewHierarchy->GetLastError(), "Unable to find view");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		}
		// found the view ...
		else
		{
			std::wstring wstrViewType = pView->GetViewType() ;
			//if (wstrViewType.compareTo (DB_DATAANALYSIS_VIEW, RWWString::ignoreCase) != 0)
			if (_wcsicmp(wstrViewType.c_str(), DB_DATAANALYSIS_VIEW) != 0)
			{
				// if the property name has c_ at the beginning of it ... remove it ...
				//int index = wstrPropertyName.find (L"c_", 0) ;
				if (_wcsnicmp(wstrPropertyName.c_str(), L"c_", 2) == 0)
				{
					// remove the c_ ...
					wstrPropertyName = wstrPropertyName.erase (0, 2) ;
				}
			}
			// find the property
			bRetCode = pView->FindProperty (wstrPropertyName, pProperty) ;
			if (bRetCode == FALSE)
			{
				SetError(pView->GetLastError());
				mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				mLogger->LogVarArgs (LOG_ERROR, 
					L"Unable to find property with name = %s in view with id = %d",
					wstrPropertyName.c_str(), realViewID) ;
			}
			else
			{
				// get the description for the property ...
				nDesc = pProperty->GetDescriptionID() ;

				// call GetLocaleDesc ...
				wstrRetVal = GetLocaleDesc (nDesc, arLangCode) ;

				// if the size of the retrurn val is 0 ... print out an error ...
				if (wstrRetVal.length() == 0)
				{
					mLogger->LogVarArgs (LOG_ERROR,
						"Unable to find description for property = %s, desc id = %d and view id = %d",
						(const char*)ascii(wstrPropertyName).c_str(), nDesc, realViewID) ; 
				}
			}
		}
	}
	catch(ErrorObject&) {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, "DBLocale::GetLocalePropertyDesc") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to get view hierarhcy while getting property description.") ;
	}

  return wstrRetVal ;
}

//
// @mfunc 
//
// @parm 
// @rdesc 
//
//




std::wstring DBLocale::GetLocaleViewDesc(const int &arViewID, 
                                      const std::wstring &arLangCode) 
{
  // local variables ...
  std::wstring wstrRetVal ;
  int nDesc ;
  DBView *pView=NULL ;
  BOOL bRetCode=TRUE ;

	if(arViewID < 0) {
		long InstanceID = -arViewID;

		long nLangCode = GetLanguageID(arLangCode);
		if (-1 == nLangCode) return L"";

		InstanceNameMap::iterator it = mInstanceNameMap.find(std::pair<long,long>(InstanceID,nLangCode));
		if(it != mInstanceNameMap.end()) {
			return std::wstring(((*it).second).c_str());
		}
		else {

			// run query to get display name from instance ID
			try {
				ROWSETLib::IMTSQLRowsetPtr aRowset(MTPROGID_SQLROWSET);
				aRowset->Init("\\Queries\\Localization");
				aRowset->SetQueryTag("__GET_INSTANCE_DISPLAYNAME__");
				aRowset->AddParam("%%INSTANCE_ID%%",CONVERT_INSTANCE_ID(InstanceID));
				aRowset->AddParam("%%LANGUAGE_CODE%%",nLangCode);
				aRowset->Execute();
				wstrRetVal = (const wchar_t*)_bstr_t(aRowset->GetValue("tx_desc"));
				mInstanceNameMap[std::pair<long,long>(InstanceID,nLangCode)] = wstrRetVal;
			}
			catch(_com_error&) {
				mLogger->LogVarArgs (LOG_ERROR,"Unable to look up priceable item instance name for id %d",InstanceID);
				return std::wstring(L"");
			}
		}
	}
	else {

		// find the view ...
		try {
			bRetCode = mpViewHierarchy->FindView(arViewID, pView) ;
			if (bRetCode == FALSE)
			{
				SetError(mpViewHierarchy->GetLastError(), "Unable to find view");
				mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
				mLogger->LogVarArgs (LOG_ERROR, "Unable to find view with id = %d", arViewID) ;
			}
			// found the view ...
			else
			{
				// get the description for the property ...
				nDesc = pView->GetViewDescriptionID() ;
    
				// call GetLocaleDesc ...
				wstrRetVal = GetLocaleDesc (nDesc, arLangCode) ;
			}
		}
		catch(ErrorObject&) {
			SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, "DBLocale::GetLocaleViewDesc") ;
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs (LOG_ERROR, 
				"Unable to get view hierarhcy while getting view description.") ;
		}
	}

  return wstrRetVal ;
}

std::wstring DBLocale::GetLocaleDesc(const std::wstring &arFQN, 
                                  const std::wstring &arLangCode) 
{
  // local variables ...
  std::wstring wstrRetVal ;
  int nDesc ;
  BOOL bRetCode=TRUE ;

	try {
    // get the id for the fqn ...
    if (!mpCodeLookup->GetEnumDataCode(arFQN.c_str(), nDesc))
    {
      SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBLocale::GetLocaleDesc");
      mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
      mLogger->LogVarArgs (LOG_WARNING, "Unable to get code lookup id for string = %s.",
        ascii(arFQN).c_str()) ;
    }
    else
    {
      // call GetLocaleDesc ...
      wstrRetVal = GetLocaleDesc (nDesc, arLangCode) ;
    }
  }
	catch(ErrorObject&) {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, "DBLocale::GetLocaleDesc") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
      "Unable to get code lookup while getting localized description.") ;
	}
  return wstrRetVal ;
}
//
// @mfunc 
//
// @parm 
// @rdesc 
//
//
std::wstring DBLocale::GetLocaleDesc(const int &arDescID, 
                                  const std::wstring &arLangCode) 
{
	if(arDescID < 0) {
		return GetLocaleViewDesc(arDescID,arLangCode);
	}

	long nLangID = GetLanguageID(arLangCode);
	if (-1 == nLangID) return L"";
	
	return GetLocaleDesc(arDescID, nLangID);
}

std::wstring DBLocale::GetLocaleDesc(int aDescID, int aLangID) 
{
  // local variables ...
  std::wstring wstrRetVal ;
  BOOL bRetCode=FALSE;

  // find the key in the map ...
	{
		AutoCriticalSection aLock(&mLocaleLock);
		DBLocaleIter pos;
		//mLogger->LogVarArgs(LOG_DEBUG, "Finding <%d>", (long)MakeKey(aDescID,aLangID));
		if ((pos = mColl.find(MakeKey(aDescID, aLangID))) != mColl.end())
		{
			bRetCode = TRUE;
			wstrRetVal = (*pos).second;
		}
	}
  if (bRetCode == FALSE)
  {
    mLogger->LogVarArgs (LOG_DEBUG, 
      L"Unable to find value in description collection. Description ID = %d, Language ID = %d", aDescID, aLangID) ;
  }

  return wstrRetVal ;
}

#define CURRENCY_SET_TAG "currency"
#define CURRENCY_CODE_TAG "currency_code"
#define CURRENCY_SYMBOL_TAG "currency_symbol"
#define CURRENCY_THOUSANDS_DELIMITER_TAG "currency_thousands_delimiter"
#define CURRENCY_FRACTION_DELIMITER_TAG "currency_fraction_delimiter"
#define CURRENCY_SYMBOL_POSITION_TAG "currency_symbol_position"

//
// @mfunc 
//
// @parm 
// @rdesc 
//
//
BOOL DBLocale::ReadConfigLocaleCurrency () 
{
  BOOL bOK = TRUE;
	std::string aConfigDir;
	_bstr_t m_ConfigFilename;
	GetMTConfigDir(aConfigDir);
	m_ConfigFilename = aConfigDir.c_str();
	m_ConfigFilename += L"PresServer\\LocaleCurrency.xml";
	VARIANT_BOOL checksumMatch;
  _bstr_t currency_code;
  LOCALE_CURRENCY_STRUCT locale_struct;


	try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
    MTConfigLib::IMTConfigPropSetPtr propSet;
    MTConfigLib::IMTConfigPropSetPtr propSetCurrency;

		// read the configuration file ...
		//
		propSet = config->ReadConfiguration(m_ConfigFilename, &checksumMatch);

		if (propSet == NULL)
		{
      mLogger->LogVarArgs (LOG_ERROR, 
        "DBLocale::ReadConfigLocaleCurrency failed %s", (char *)m_ConfigFilename) ;
			return FALSE;
		}

		while ( NULL != (propSetCurrency = propSet->NextSetWithName(CURRENCY_SET_TAG)))
    {
		  currency_code =	propSetCurrency->NextStringWithName(CURRENCY_CODE_TAG);
		  locale_struct.CURRENCY_SYMBOL = propSetCurrency->NextStringWithName(CURRENCY_SYMBOL_TAG);
		  locale_struct.CURRENCY_THOUSANDS_DELIMITER = propSetCurrency->NextStringWithName(CURRENCY_THOUSANDS_DELIMITER_TAG);
		  locale_struct.CURRENCY_FRACTION_DELIMITER = propSetCurrency->NextStringWithName(CURRENCY_FRACTION_DELIMITER_TAG);
		  locale_struct.CURRENCY_SYMBOL_POSITION = propSetCurrency->NextLongWithName(CURRENCY_SYMBOL_POSITION_TAG);

		  locale_currency_map.insert(LOCALE_CURRENCY_MAP::value_type(currency_code, locale_struct));
    }
	}
	catch (_com_error err)
	{
    mLogger->LogVarArgs (LOG_ERROR, 
        "DBLocale::ReadConfigLocaleCurrency failed %s", err.Description()) ;
    return FALSE;
	}

  return bOK;
}


//
// @mfunc 
//
// @parm 
// @rdesc 
//
//
std::wstring DBLocale::GetLocaleCurrency (const MTDecimal &arAmount, 
                                       const std::wstring &arCurrencyCode) 
{
  // local variables ...
  std::wstring wstrRetVal ;
  std::wstring wstrAmount ;
  std::wstring wstrDelimiter ;
  std::wstring wstrFraction ;
  std::wstring wstrDelimited ;
  _bstr_t code;
  wchar_t * symbol = NULL;
  long after;

	// format rounded to two digits
	string asciiAmountBuffer = arAmount.Format(2);
	wstring amountBuffer;
	ASCIIToWide(amountBuffer, asciiAmountBuffer);

  code = arCurrencyCode.c_str();
  
  // switch on the currency code ...

  LOCALE_CURRENCY_MAP::iterator iter = locale_currency_map.find(code);

	if (iter == locale_currency_map.end())
	{
    // unknown currency

    // Just return whatever was passed in as arguments .
    wstrRetVal = amountBuffer.c_str() ;
    // add the symbol ...
		wstrRetVal += arCurrencyCode ;

    // Log a warning.
    mLogger->LogVarArgs (LOG_WARNING, 
        "GetLocaleCurrency passed unknown currency = %s", arCurrencyCode.c_str()) ;

	}
  else
  {
    wstrDelimiter = (wchar_t *)((*iter).second).CURRENCY_THOUSANDS_DELIMITER;
    wstrFraction = (wchar_t *)((*iter).second).CURRENCY_FRACTION_DELIMITER;
    symbol = (wchar_t *)((*iter).second).CURRENCY_SYMBOL;
    after = ((*iter).second).CURRENCY_SYMBOL_POSITION;

    // add the currency delimiters ...
    wstrAmount = amountBuffer.c_str();
  	wstrDelimited = AddCurrencyDelimiters(wstrAmount, wstrDelimiter, wstrFraction);

    // add the symbol ...
    if ( after > 0)
    {
		  wstrRetVal = wstrDelimited + symbol ;
    }
    else
    {
		  wstrRetVal = symbol;
		  wstrRetVal += wstrDelimited;
    }
  }

  return wstrRetVal;
}

//
// @mfunc 
//
// @parm 
// @rdesc 
//
//
std::wstring DBLocale::GetEuroCurrency (const MTDecimal &arAmount, 
                                     const std::wstring &arCurrencyCode) 
{
  // local variables ...
  std::wstring wstrRetVal ;
	wstring amount;
  std::wstring wstrAmount ;
  MTDecimal newAmount ;
	MTDecimal convRate;
  BOOL bRetCode=TRUE ;

  // find the currency code in the collection ...
	{
		AutoCriticalSection aEuroLock(&mEuroLock);
		DBEuroConversionCollIter Iter = mEuroConvColl.find(arCurrencyCode);
		bRetCode = (Iter == mEuroConvColl.end());
		if (bRetCode == TRUE) 
		{
			convRate = Iter->second;
		}
	}
  if (bRetCode == FALSE)
  {
    // unsupported country ... log error and return NULL ...
    SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, "DBLocale::GetEuroCurrency");
    mLogger->LogErrorObject (LOG_WARNING, GetLastError()) ;
    mLogger->LogVarArgs (LOG_WARNING, "Unable to GetEuroCurrency for Currency Code = %s", 
      ascii(arCurrencyCode.c_str())) ;

   	wstrRetVal = L"" ;
  }
  else
  {
    // multiply the amount by the conversion rate ...
    newAmount = arAmount / convRate ;

    // copy the amount into a string ...
		string asciiAmount;
		// round to 2 decimal places
		asciiAmount = newAmount.Format(2);

		ASCIIToWide(amount, asciiAmount);

    // add the currency delimiters ...
    wstrAmount = amount.c_str() ;
  	wstrRetVal = AddCurrencyDelimiters(wstrAmount, PERIOD_LOCALE_DELIMITER, COMMA_LOCALE_DELIMITER);

    // add the symbol ...
		wstrRetVal = wstrRetVal + CURRENCY_SYMBOL_EUR ;
  }
	return wstrRetVal;
}

// @mfunc add delimiters to the currency based on the locale
// @parm an currency string from the GetLocaleCurrency function
// @parm the language the description is desired in
// @parm the country to help localize the description
// @rdesc returns a string with commas/periods in it as appropriate
std::wstring DBLocale::AddCurrencyDelimiters( std::wstring &arCurrencyString,
                                          const std::wstring &arLocaleDelimiter,
                                          const std::wstring &arLocaleFraction)
{
	int delimitLength = 3; // number of digits in each delimiter group
	int decimalPointLength = 3; // # of digits after decimal point and decimal point
  int negSignChar=0 ;
  int numChars = 0;
  std::wstring wstrRetVal ;
  BOOL bInserted=FALSE ;

  if (arCurrencyString.length() == 0)
  {
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBLocale::AddCurrencyDelimiters", "Blank currency string.");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return wstrRetVal ;
  }

  // replace fractions if necessary
  //if (arLocaleFraction.compareTo (PERIOD_LOCALE_DELIMITER, RWWString::ignoreCase) != 0)
  if (_wcsicmp(arLocaleFraction.c_str(), PERIOD_LOCALE_DELIMITER) != 0)
  {
    int nPos = arCurrencyString.find_first_of(PERIOD_LOCALE_DELIMITER, 0) ;
    arCurrencyString.replace (nPos, 1, arLocaleFraction) ;
  }

  // get the size of the whole number amount ...
  numChars = arCurrencyString.length() - decimalPointLength ;

  // if the currency string is negative ...
  if (arCurrencyString.find(L"-") != string::npos)
  {
    numChars-- ;
    negSignChar = 1 ;
  }
  wstrRetVal = arCurrencyString ;

  // iterate through the string ... start out with the first position to insert a
  // LOCALE_DELIMIER (",") ... advance by the size of delimitLength (3) ... the 
  // input string looks like 1234567890.12 and should come out as 1,234,567,890.12 ...
  for (int i=(numChars % delimitLength); i < numChars; i+=delimitLength)
  {
    // if we've already inserted the first thing then add one to the position (i)
    // to indicate the inserted LOCALE_DELLIMETER (",") ...
    if (bInserted == TRUE)
    {
      i++ ;
    }

    // skip if we're starting at the beginning ...
    if (i != 0)
    {
      wstrRetVal.insert (i+negSignChar, arLocaleDelimiter.c_str()) ;
      bInserted = TRUE ;
    }
  }

	return wstrRetVal;	
}

//
//	@mfunc
//	Create the query to get the description
//  @rdesc 
//  Return the mLastError data member
//
std::wstring DBLocale::GetDescriptionQuery()
{
  std::wstring wstrCmd ;
  try
  {
    // get the query ...
    _bstr_t queryTag, queryString ;
    queryTag = "__GET_DESCRIPTION_INFO__" ;
    mpQueryAdapter->SetQueryTag(queryTag) ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBLocale::GetDescriptionQuery", 
      "Unable to get description query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to create query. Error Description = %s", (char*)e.Description()) ;
  }
  return wstrCmd ;
}


//
//	@mfunc
//	Adjust DayLightSaving time
//  @rdesc 
//  Return void
//
void DBLocale::AdjustDayLightSavingTime(struct tm * aTimeStruct, struct tm ** aNewTimeStruct, BOOL flag)
{
	time_t val;

	int dstFlag = aTimeStruct->tm_isdst;

	if (!flag && (aTimeStruct->tm_isdst > 0))
	{
		time_t tmTValue = mktime(aTimeStruct);

		val = tmTValue - (60 * 60);

		struct tm * newTm = localtime(&val);

		*aNewTimeStruct = newTm;
	}
	else
	{
		*aNewTimeStruct = aTimeStruct;
	}

}

//
//	@mfunc
//	Get local DateTime
//  @rdesc 
//  Return TRUE/FALSE
//
BOOL DBLocale::GetDateTime(VARIANT aInputDateTime, 
													 long aMTZoneCode,
													 VARIANT_BOOL aDayLightSavingFlag, 
													 VARIANT *apLocalDateTime)
{
	_variant_t var(aInputDateTime);

	time_t timeVal;
	timeVal = ParseVariantDate(var);
	if (timeVal == -1)
	{
		mLogger->LogVarArgs(LOG_ERROR, "Parse input variant date failed: DBLocale::GetDateTime()");
		return FALSE;
	}

  string tz = Calendar::TranslateZone(aMTZoneCode);
	//const char * tz = Calendar::TranslateZone(aMTZoneCode);
	
	if (tz.length() == 0)
	{
		mLogger->LogVarArgs(LOG_ERROR, 
											"Unsupported timezone ID %d: DBLocale::GetDateTime()", 
											aMTZoneCode);
		return FALSE;
	}
	
	// local time in struct tm format
	struct tm * newTm = tzlocaltime(tz.c_str(), &timeVal);
	ASSERT(newTm);

	BOOL flag = (aDayLightSavingFlag == VARIANT_TRUE) ? TRUE : FALSE;

	struct tm * adjustedTm;
	AdjustDayLightSavingTime(newTm, &adjustedTm, flag);

#if 0
	char* tmStr = asctime(adjustedTm);

	cout << "asctime: " << tmStr << endl;
#endif

	DATE dateTime;
	OleDateFromStructTm(&dateTime, adjustedTm);

	const _variant_t & varResult = dateTime;
	::VariantInit(apLocalDateTime);
	const tagVARIANT * vp = &varResult;
	::VariantCopy(apLocalDateTime, const_cast<tagVARIANT *>(vp));

	return TRUE;
}


//
//	@mfunc
//	Parse variant date
//  @rdesc 
//  Return time_t
//
time_t DBLocale::ParseVariantDate(VARIANT aDate)
{
	time_t	lDate = 0;
	DATE		varDate;
	_bstr_t	bstrDate;

	switch(aDate.vt)
	{
		case VT_I4:
			lDate = aDate.lVal;
			break;

		case VT_DATE:
			varDate = aDate.date;
			TimetFromOleDate(&lDate, varDate);
			break;

		case (VT_DATE | VT_BYREF):
			varDate = *(aDate.pdate);
			TimetFromOleDate(&lDate, varDate);
			break;

		case VT_BSTR:
			bstrDate = aDate.bstrVal;

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				mLogger->LogVarArgs(LOG_ERROR, 
									"Bad input date format(MTParseISOTime) in: DBLocale::ParseVariantDate()");
				return -1;
				
			}
			break;

		case (VT_BSTR | VT_BYREF):
			bstrDate = *(aDate.pbstrVal);

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				mLogger->LogVarArgs(LOG_ERROR, 
					"Bad effective date ref format(MTParseISOTime) in: DBLocale::ParseVariantDate()");
				return -1;
			}
			break;

		default:
			mLogger->LogVarArgs(LOG_ERROR, 
				"Unknown input variant date type in: DBLocale::ParseVariantDate()");
			lDate = -1;
	}

	return lDate;
}

DLL_EXPORT long DBLocale::GetLanguageID(const std::wstring& arLangCode)
{
	// lookup the currency code ID
	std::wstring aTempStr(arLangCode);
	StrToLower(aTempStr);
	_bstr_t langkey = aTempStr.c_str();
	const ReverseLanguageList& alist = mLangList->GetReverseLanguageList();
	ReverseLanguageListIterator iter = alist.find(langkey);
	if(iter == alist.end()) {
		mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
												 (const char*)langkey);
		return -1;
	}
	return (*iter).second;
}
