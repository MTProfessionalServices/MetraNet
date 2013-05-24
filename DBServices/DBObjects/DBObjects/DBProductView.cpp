/**************************************************************************
 * @doc DBProductView
 * 
 * @module  Encapsulation of a single product view|
 * 
 * This class encapsulates the properties of a single product view.
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
 * @index | DBProductView
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <mtprogids.h>
#include <mtparamnames.h>
#include <DBProductView.h>
#include <DBProductViewProperty.h>
#include <DBConstants.h>
#include <DBSQLRowset.h>
#include <DBInMemRowset.h>
#include <DBMiscUtils.h>
#include <mtglobal_msg.h>
#include <DBUsageCycle.h>
#include <DBLocale.h>
#include <loggerconfig.h>
#include <xmlconfig.h>


// import the query adapter tlb ...
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

using namespace std;

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
DBProductViewAbstract::DBProductViewAbstract()
: mpQueryAdapter(NULL), 
	mSelectClause(L""), 
	mNumEnums (1)
{
  // create the language list singleton object ...
  mpLanguageList = CLanguageList::GetInstance() ;
  if (mpLanguageList == NULL)
  {
    SetError(DB_ERR_NO_INSTANCE, 
      ERROR_MODULE, 
      ERROR_LINE,
      "DBProductView::DBProductView",
      "Unable to get instance of language list singleton");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
}


//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
DBProductViewAbstract::~DBProductViewAbstract()
{
  // delete all the allocate memory ...
  for (DBProductViewPropCollIter Iter = mPropColl.begin(); Iter != mPropColl.end(); Iter++)
  {
    DBProductViewProperty *pProp = (*Iter).second ;
    delete pProp ;
  }
  mPropColl.clear() ;
  for (DBProductViewPropCollIter ResvdIter = mResvdPropColl.begin(); ResvdIter != mResvdPropColl.end(); ResvdIter++)
  {
    DBProductViewProperty *pProp = (*ResvdIter).second ;
    delete pProp ;
  }
  mResvdPropColl.clear() ;

  // release the interface ptrs ...
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
  }
  mLangCodeColl.clear() ;
  // release the language list singleton object ...
  if (mpLanguageList != NULL)
  {
	  	mpLanguageList->ReleaseInstance() ;
      mpLanguageList = NULL ;
  }
}

DBProductView::DBProductView()
{
  mWhereClause = L" ";
  mFromClause = L" ";
  mConfigPath = "" ;
}

DBProductView::~DBProductView()
{
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::Init(const std::wstring &arViewType, const int &arViewID, 
                         const std::wstring &arName, const int &arDescriptionID,
                         CMSIXDefinition *pPV) 
{
  // local variables
  BOOL bRetCode=TRUE ;
  std::wstring wstrName ;
  std::wstring wstrColumn ;
  std::wstring wstrType ;
	CMSIXProperties::PropertyType msixPropType;
	_variant_t defaultVal;
  int nDesc=0 ;
  VARIANT_BOOL vbUserVisible = VARIANT_TRUE ;
  VARIANT_BOOL vbFilterable  = VARIANT_TRUE ;
  VARIANT_BOOL vbExportable  = VARIANT_TRUE ;
  VARIANT_BOOL vbIsRequired  = VARIANT_TRUE;
  DBProductViewProperty *pDBProperty=NULL ;
  CMSIXProperties *pPVProp=NULL ;
  std::wstring wstrFQN ;
  std::wstring wstrEnumNamespace ;
  std::wstring wstrEnumEnumeration;
	HRESULT hr; 


  // initialize the view ...
  bRetCode = DBView::Init (arViewType, arViewID, arName, arDescriptionID) ;
  if (bRetCode == FALSE)
  {
    SetError(DBView::GetLastError(), 
      "Init() failed. Unable to initialize product view");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

	hr = mNameID.CreateInstance(MTPROGID_NAMEID);
	if (FAILED(hr))
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, "DBProductView::Init");
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}


	//creates the enum config object
	hr = mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);	
	if(FAILED(hr))
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, "DBProductView::Init");
		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	
  // copy the data members out of the product view ...
  ASSERT (pPV) ;
  mTableName = pPV->GetTableName() ;
  
  // get the product view properties iterator ...

	MSIXPropertiesList::iterator it;
	for (it = pPV->GetMSIXPropertiesList().begin();
			 it != pPV->GetMSIXPropertiesList().end() && bRetCode == TRUE;
			 ++it)
	{
    // create a new product view property ...
    pDBProperty = new DBProductViewProperty ;
    ASSERT (pDBProperty) ;
    if (pDBProperty == NULL)
    {
      bRetCode = FALSE ;
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBProductView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      break ;
    }
    
    // get the product view property and copy the parameters ...
    pPVProp = *it;
    wstrName = pPVProp->GetDN() ;
    wstrColumn = pPVProp->GetColumnName() ;
    wstrType = pPVProp->GetDataType() ;
		msixPropType = pPVProp->GetPropertyType();
    vbUserVisible = pPVProp->GetUserVisible() ;
    vbFilterable = pPVProp->GetFilterable() ;
    vbExportable = pPVProp->GetExportable() ;
		vbIsRequired = pPVProp->GetIsRequired();
 
    //if (wstrType.compareTo (DB_ENUM_TYPE, RWWString::ignoreCase) == 0)
	if (_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) == 0)
    {
      // get the namespace and enumeration ...
      wstrEnumNamespace = pPVProp->GetEnumNamespace() ;
      wstrEnumEnumeration = pPVProp->GetEnumEnumeration() ;
    }

    // get the description id ... create the string then get it ...
    wstrFQN = arName ;
    wstrFQN += L"/" ;
    wstrFQN += wstrName ;
	  nDesc = (long) mNameID->GetNameID(_bstr_t(wstrFQN.c_str()));

		//converts the default value to a variant
    if (!ConvertDefaultValue(defaultVal, *pPVProp)) {
      SetError (DB_ERR_DEFAULT_VALUE_ERROR, ERROR_MODULE, ERROR_LINE, "DBProductView::Init") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
			mLogger->LogVarArgs(LOG_ERROR,
												 "Could not convert default value for property '%s'.",
												 ascii(wstrName).c_str());
      //TODO: is any cleanup necessary?? can't tell... 
			return FALSE;
		}

		//TODO: this is getting sloppy and error prone
		// initialize the property object ...
		bRetCode = pDBProperty->Init(wstrName, wstrColumn, wstrType, msixPropType,  nDesc,
																 vbUserVisible, vbFilterable, vbExportable, defaultVal, vbIsRequired) ;
		if (bRetCode == FALSE)
		{
			SetError(pDBProperty->GetLastError(), 
							 "Init() failed. Unable to initialize product view property");
			mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		}
		else
		{
			// do a find to see id the property exists ...
			if (mPropColl.count(wstrName) > 0)
			{
				mLogger->LogVarArgs (LOG_ERROR, 
														L"Found duplicate property with name = %s in product view with name = %s.", 
														wstrName.c_str(), mName.c_str()) ;
				bRetCode = FALSE ;
			}
			// add the element to the view collection ...
			mPropColl[pDBProperty->GetName()] = pDBProperty ;
			
			// if this property is user visible and not an enum type ... add the column name and 
			// property name to the select clause ...
			if ((vbUserVisible == VARIANT_TRUE) && 
					(_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) != 0))
			{
				AddToSelectClause(wstrColumn, wstrColumn) ;
			}
			else if (_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) == 0)
			{
				// add the enum specific values to the property ...
				pDBProperty->SetEnumNamespace (wstrEnumNamespace) ;
				pDBProperty->SetEnumEnumeration (wstrEnumEnumeration) ;
				pDBProperty->SetEnumColumnName(mNumEnums) ;
				
				// add the enum to the clauses
				AddEnumToQuery(wstrColumn, wstrColumn) ;
			}
		}
	}
	
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_AMOUNT, DB_AMOUNT, DB_AMOUNT_FQN, DB_DOUBLE_TYPE, 
      CMSIXProperties::TYPE_DOUBLE, VARIANT_TRUE, VARIANT_TRUE, VARIANT_TRUE, 
      _variant_t(), vbIsRequired) ;
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_CURRENCY, DB_CURRENCY, DB_CURRENCY_FQN, 
      DB_STRING_TYPE, CMSIXProperties::TYPE_STRING, VARIANT_TRUE, VARIANT_TRUE, 
      VARIANT_TRUE, _variant_t(), vbIsRequired) ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_TAX_AMOUNT, DB_TAX_AMOUNT_COLUMN, DB_TAX_AMOUNT_FQN, 
      DB_FLOAT_TYPE, CMSIXProperties::TYPE_FLOAT, VARIANT_TRUE, VARIANT_FALSE, 
      VARIANT_FALSE, _variant_t(), vbIsRequired) ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_INTERVAL_ID, DB_INTERVAL_ID, DB_INTERVAL_ID_FQN, 
      DB_INTEGER_TYPE, CMSIXProperties::TYPE_INT32, VARIANT_TRUE, VARIANT_FALSE, 
      VARIANT_FALSE, _variant_t(), vbIsRequired) ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_TIMESTAMP, DB_TIMESTAMP, DB_TIMESTAMP_FQN, 
      DB_DATE_TYPE, CMSIXProperties::TYPE_TIMESTAMP, VARIANT_TRUE, VARIANT_TRUE, 
      VARIANT_TRUE, _variant_t(), vbIsRequired) ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_AMOUNT_WITH_TAX, DB_AMOUNT_WITH_TAX_COLUMN, 
      DB_AMOUNT_WITH_TAX_FQN, DB_FLOAT_TYPE, CMSIXProperties::TYPE_FLOAT, VARIANT_TRUE, 
      VARIANT_FALSE, VARIANT_FALSE, _variant_t(), vbIsRequired) ;
  }

  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    bRetCode = AddReservedProperty (DB_SESSION_ID, DB_SESSION_ID, DB_SESSION_ID_FQN, 
      DB_INTEGER_TYPE, CMSIXProperties::TYPE_INT32, VARIANT_TRUE, VARIANT_FALSE, 
      VARIANT_FALSE, _variant_t(), vbIsRequired) ;
  }
  // if we havent hit an error yet ...
  if (bRetCode == TRUE)
  {
    try
    {
      // create the queryadapter ...
      IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
      
      // initialize the queryadapter ...
      mConfigPath = "\\Queries\\Database" ;
      queryAdapter->Init(mConfigPath) ;
      
      // extract and detach the interface ptr ...
      mpQueryAdapter = queryAdapter.Detach() ;
    }
    catch (_com_error e)
    {
      //SetError(e) ;
      SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::Init", 
        "Unable to initialize query adapter");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      mLogger->LogVarArgs (LOG_ERROR, 
        "Init() failed. Error Description = %s", (char*)e.Description()) ;
      bRetCode = FALSE ;
    }
  }

  if (!PopulateLanguageCollection())
  {
	return FALSE;
  }
    
  return bRetCode ;
}


BOOL DBProductView::AddReservedProperty(const std::wstring &arName, const std::wstring &arColumn, 
                                        const std::wstring &arFQN, const std::wstring &arType,
                                        const CMSIXProperties::PropertyType &arMSIXType, 
                                        const VARIANT_BOOL &arUserVisible,
                                        const VARIANT_BOOL &arFilterable, 
                                        const VARIANT_BOOL &arExportable,
                                        const _variant_t &arDefault,
                                        const VARIANT_BOOL &arIsRequired)
{
  // local variables ...
  DBProductViewProperty *pDBProperty=NULL ;
  BOOL bRetCode=TRUE ;
  long nDesc ;

  // create a new product view property ...
  pDBProperty = new DBProductViewProperty ;
  ASSERT (pDBProperty) ;
  if (pDBProperty == NULL)
  {
    bRetCode = FALSE ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBProductView::AddReservedProperty") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  else
  {      
    // get the description id for amount ...
    nDesc = (long) mNameID->GetNameID(arFQN.c_str());
    
    // initialize the property object ...
    bRetCode = pDBProperty->Init(arName, arColumn, arType, arMSIXType, 
      nDesc, arUserVisible, arFilterable, arExportable, arDefault, arIsRequired) ;
    if (bRetCode == FALSE)
    {
      SetError(pDBProperty->GetLastError(), 
        "AddReservedProperty() failed. Unable to initialize product view property");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
    else
    {
      // do a find to see id the property exists ...
      if (mResvdPropColl.count (DB_AMOUNT) > 0 || 
					mPropColl.count (DB_AMOUNT) > 0)
      {
        delete pDBProperty ;
        pDBProperty = NULL ;
      }
      else
      {
        // add the element to the view collection ...
        mResvdPropColl[pDBProperty->GetName()] = pDBProperty ;
      }
    }
  }
  return bRetCode ;
}

//converts the default value from the string found in the
//product view def to the respective variant type
//returns TRUE on success
BOOL DBProductViewAbstract::PopulateLanguageCollection() 
{
    const char* procName = "DBProductViewAbstract::PopulateLanguageCollection";

	// get the map
	LanguageList ll = mpLanguageList->GetLanguageList();
	if (ll.empty())
	{
		mLogger->LogThis (LOG_ERROR, "Language List is empty!"); 
		return FALSE;
	}

	int nLangCode;
	LanguageListIterator itr;
	for (itr = ll.begin(); itr != ll.end(); itr++)
	{
	    wstring wstrLangCode;
	    // the first item (key) contains the concatenated string of the number
	    // (i.e ID) and the language code.  Strip that out
	    nLangCode = (*itr).first;
		wstrLangCode = (*itr).second;

		mLangCodeColl[wstrLangCode] = nLangCode ;
	}

	return TRUE;
}



//converts the default value from the string found in the
//product view def to the respective variant type
//returns TRUE on success
//returns FALSE on failure (from either a type conversion problem,
//failed variant operation, or unhandled property type)
BOOL DBProductView::ConvertDefaultValue(_variant_t &arDefaultVal,
																				const CMSIXProperties &arMSIXProp) 
{
	std::wstring defaultValStr = arMSIXProp.GetDefault();
	CMSIXProperties::PropertyType msixType = arMSIXProp.GetPropertyType();

	//if we fail anywhere, the default value variant will be empty
	//and correspond to a NULL in the database

	arDefaultVal.ChangeType(VT_EMPTY);
	
	//if no default is provided then leave the variant's type as VT_EMPTY
	if (defaultValStr == L"")
		return TRUE;
	
	switch (msixType) 
  {
    
  case CMSIXProperties::TYPE_INT32: 
    {
      int intVal;
      if (!XMLConfigNameVal::ConvertToInteger(defaultValStr.c_str(), &intVal))
        return FALSE;
      arDefaultVal = (long) intVal;
      break;
    }
    
  case CMSIXProperties::TYPE_INT64: 
    {
      __int64 int64Val;
      if (!XMLConfigNameVal::ConvertToBigInteger(defaultValStr.c_str(), &int64Val))
        return FALSE;
      arDefaultVal = int64Val;
      break;
    }
    
  case CMSIXProperties::TYPE_FLOAT:
  case CMSIXProperties::TYPE_DOUBLE: 
    {
      double doubleVal;		
      if (!XMLConfigNameVal::ConvertToDouble(defaultValStr.c_str(), &doubleVal)) 
        return FALSE;
      arDefaultVal = doubleVal;
      break;
    }
  case CMSIXProperties::TYPE_DECIMAL: 
    {
      MTDecimalVal decimalVal;		
      if (!XMLConfigNameVal::ConvertToDecimal(defaultValStr.c_str(), &decimalVal)) 
        return FALSE;
      arDefaultVal = DECIMAL(MTDecimal(decimalVal));
      break;
    }
    
  case CMSIXProperties::TYPE_TIMESTAMP: 
    {
      DATE dateVal;
      time_t dateValAnsi;
      
      if (!XMLConfigNameVal::ConvertToDateTime(defaultValStr.c_str(), &dateValAnsi))
        return FALSE;
      
      //converts from time_t to OLE DATE object
      OleDateFromTimet(&dateVal, dateValAnsi);
      {
        _variant_t temp(dateVal, VT_DATE);
        arDefaultVal = temp;
      }
      break;		
    }
    
  case CMSIXProperties::TYPE_BOOLEAN: 
    {
      BOOL boolVal;
      if (!XMLConfigNameVal::ConvertToBoolean(defaultValStr.c_str(), &boolVal))
        return FALSE;
      if (boolVal)
        defaultValStr = DB_BOOLEAN_TRUE;  
      else
        defaultValStr = DB_BOOLEAN_FALSE;   
    }
    
    //CAUTION !!!!
    //case TYPE_BOOLEAN is meant to fall through to the TYPE_STRING case below
    //CAUTION !!!!
    
  case CMSIXProperties::TYPE_STRING:
  case CMSIXProperties::TYPE_WIDESTRING: 
    {
      // TODO: can this be done more efficiently?
      arDefaultVal = _bstr_t(defaultValStr.c_str());
      
      
      break;
    }
    
    
  case CMSIXProperties::TYPE_ENUM: 
    {
      _bstr_t enumSpace, enumType, enumVal, FQN;
      
      enumSpace = arMSIXProp.GetEnumNamespace().c_str();
      enumType = arMSIXProp.GetEnumEnumeration().c_str();
      
      enumVal = defaultValStr.c_str();
      FQN = mEnumConfig->GetFQN(enumSpace, enumType, enumVal);
      
      if(FQN.length() == 0) {
        mLogger->LogVarArgs(LOG_ERROR, "Enumeration %s/%s/%s not found in enum collection.",
          (const char*)enumSpace, (const char*)enumType, (const char*)enumVal);
        return FALSE;
      }
      arDefaultVal = (long) mNameID->GetNameID((const wchar_t *)FQN);
      break;
    }
    
  default: 
    mLogger->LogVarArgs(LOG_ERROR, "Unsupported MSIX type for default value");
    return FALSE;
  }
	
	return TRUE;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const std::wstring &arLangCode, DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call GetDisplayItems with no extension ...
  GetDisplayItems (arAcctID, arIntervalID,arLangCode, L" ", arpRowset,instanceID) ;

  return bRetCode ;
}

BOOL DBProductView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const std::wstring &arLangCode, const std::wstring &arExtension,
                                     DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBProductView::GetDisplayItems", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBProductView::GetDisplayItems") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // get the language id ...
  std::wstring wstrKey = arLangCode ;
  int nLangCode = 840 ; // default to english 
  StrToLower(wstrKey);
  LangCodeCollIter langiter = mLangCodeColl.find (wstrKey) ;
  if (langiter == mLangCodeColl.end())
  {
    mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
												 ascii(wstrKey).c_str()) ;
  }
	else
	{
		nLangCode = langiter->second;
	}
  // lock the threadlock to create and execute the query ...
  mLock.Lock() ;

  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }


  // create the query to get the items for the product ...
  if (mChildViewList.size() > 0)
  {
    wstrCmd = CreateProductViewItemsQuery (arAcctID,  arIntervalID, 
      mTableName, mID, DB_COMPOUND_SESSION, arExtension, nLangCode,instanceID) ;
  }
  else
  {
    wstrCmd = CreateProductViewItemsQuery (arAcctID,  arIntervalID,
      mTableName, mID, DB_ATOMIC_SESSION, arExtension, nLangCode,instanceID) ;
  }
  mLock.Unlock() ;
  
  // issue a query to get the items for the product ...
  bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "GetDisplayItems() failed. Unable to execute database query(2)");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }

  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
  }
  
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::Summarize(const int &arAcctID, const int &arIntervalID,DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call Summarize with no extension ...
  Summarize (arAcctID, arIntervalID,arpRowset, L" ") ;

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::Summarize(const int &arAcctID, const int &arIntervalID,DBSQLRowset * & arpRowset,
                              const std::wstring &arExtension) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd ;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBProductView::Summarize", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }

  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;

	// lock the threadlock to create and execute the query ...
	mLock.Lock() ;
	// create the query to get the items for the product ...
	wstrCmd = CreateProductViewSummarizeQuery (arAcctID,  arIntervalID,
	 mTableName, mID, mName, mType, mDescriptionID, arExtension) ;
	mLock.Unlock() ;

  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }
	// issue a query to get the items for the product ...
	bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
	if (bRetCode == FALSE)
	{
		SetError(myDBAccess.GetLastError(), 
			"Summarize() failed. Unable to execute database query");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::GetDisplayItems (const int &arAcctID, const int &arIntervalID,
                                     const int &arSessionID, const std::wstring &arLangCode,
                                     DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // call GetDisplayItems with no extension ...
  GetDisplayItems (arAcctID, arIntervalID, arSessionID,arLangCode, L" ", arpRowset,instanceID) ;

  return bRetCode ;
}

BOOL DBProductView::GetDisplayItems (const int &arAcctID, 
																		 const int &arIntervalID,
                                     const int &arSessionID,
																		 const std::wstring &arLangCode,
                                     const std::wstring &arExtension, DBSQLRowset * & arpRowset,long instanceID ) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DBSQLRowset *pRowset=NULL ;
  DBProductView *pView=NULL ;
  int nViewID ;
  std::wstring wstrCmd ;

  // get the usage cycle collection ...
	MTAutoSingleton<DBUsageCycleCollection> pUsageCycle;
	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
	MTautoptr<MTPCViewHierarchy> aHierarchy;

	  // get the language id ...
  std::wstring wstrKey = arLangCode ;
  int nLangCode = 840 ; // default to english 
  StrToLower(wstrKey);
  LangCodeCollIter langiter = mLangCodeColl.find (wstrKey) ;
  if (langiter == mLangCodeColl.end())
  {
    mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
      ascii(wstrKey).c_str()) ;
  } 
	else
	{
		nLangCode = langiter->second;
	}

	try {
		// get an instance to the view collection ...
		aHierarchy= mVHinstance->GetAccHierarchy(arAcctID,arIntervalID,arLangCode.c_str());
	}
	catch(ErrorObject& err) {
		SetError(&err);
		return FALSE;
	}

	// if this product view has children ...
  if (mChildViewList.size() > 0)
  {
    // create a InMemRowset ...
    arpRowset = new DBSQLRowset ;
    ASSERT (arpRowset) ;
    if (arpRowset == NULL)
    {
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, 
        "DBProductView::GetDisplayItems") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
    
    // initialize the rowset with the appropriate columns ...
    bRetCode = InitializeInMemRowset (arpRowset) ;
    if (bRetCode == TRUE)
    {
      // iterate over my children and get a line item for each child ...
      for (DBViewIDCollIter Iter = mChildViewList.begin(); Iter != mChildViewList.end(); Iter++)
      {
        // find the view ...
        nViewID = *Iter ;
				bRetCode = aHierarchy->FindView (nViewID, (DBView * &) pView) ;
        if (bRetCode == FALSE)
        {
          SetError(aHierarchy->GetLastError(), 
            "GetDisplayItems() failed. Unable to find view(2)");
          mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
          break ;
        }
        // found the view ...
        else
        {
          // call summarize() ...
          bRetCode = pView->Summarize(arAcctID, arIntervalID, arSessionID, pRowset) ;
          if (bRetCode == FALSE)
          {
            SetError(pView->GetLastError(), 
              "GetDisplayItems() failed. Unable to summarize view(2)");
            mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
            break ;
          }
          else
          {
            // insert the summarization into the nonSQLRowset ...
            bRetCode = InsertIntoInMemRowset (arpRowset, pRowset) ;
            
            // clean up the rowset ...
            delete pRowset ;
            pView = NULL ;
            
            if (bRetCode == FALSE)
            {
              break ;
            }
          }
        }
      }
			// after inserting into the inmem rowset, move to the begining
			arpRowset->MoveFirst();
    }
  }
  // otherwise .. the product view doesnt have any children ... get the items associated
  // with the parent session id ...
  else
  {
    // create a SQL Rowset ...
    arpRowset = new DBSQLRowset ;
    ASSERT (arpRowset) ;
    if (arpRowset == NULL)
    {
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE,
        "DBProductView::GetDisplayItems") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }


    // lock the threadlock to create and execute the query ...
    mLock.Lock() ;

    // create the query to get the items associated with the session id for the product ...
    wstrCmd = CreateProductViewItemChildrenQuery (arAcctID,  arIntervalID,
      arSessionID,mTableName, mID, DB_ATOMIC_SESSION, 
      arExtension, nLangCode) ;
    mLock.Unlock() ;
    
    // initialize the access to the database ...
    DBAccess myDBAccess ;
    bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
    if (bRetCode == FALSE)
    {
      pUsageCycle->ReleaseInstance() ;
      SetError(myDBAccess.GetLastError(), 
        "Init() failed. Unable to initialize database access layer");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return bRetCode ;
    }

    // issue a query to get the items for the product ...
    bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
    
    if (bRetCode == FALSE)
    {
      SetError(myDBAccess.GetLastError(), 
        "GetDisplayItems() failed. Unable to execute database query(5)");
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    }
  }
  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::Summarize(const int &arAcctID, const int &arIntervalID,
                              const int &arSessionID, DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBProductView::GetDisplayItems", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset ;
  ASSERT (arpRowset) ;
  if (arpRowset == NULL)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "DBProductView::Summarize") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // lock the threadlock to create and execute the query ...
  mLock.Lock() ;
  // create the query to get the items for the product ...
  wstrCmd = CreateProductViewChildrenSummaryQuery (arAcctID,  arIntervalID,
    arSessionID, mTableName, mID, mName, mType, mDescriptionID) ;
  mLock.Unlock() ;
  
	// issue a query to get the items for the product ...
	// initialize the access to the database ...
	DBAccess myDBAccess ;
	bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
	if (bRetCode == FALSE)
	{
		pUsageCycle->ReleaseInstance() ;
		SetError(myDBAccess.GetLastError(), 
			"Init() failed. Unable to initialize database access layer");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
		return bRetCode ;
	}

	bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
  if (bRetCode == FALSE)
  {
    SetError(myDBAccess.GetLastError(), 
      "Summarize() failed. Unable to execute database query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
  }
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductView::GetDisplayItemDetail(const int &arAcctID, const int &arIntervalID,
                                         const int &arSessionID, const std::wstring &arLangCode,
                                         DBSQLRowset * & arpRowset) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  std::wstring wstrCmd;

  // get the usage cycle collection ...
  DBUsageCycleCollection *pUsageCycle= DBUsageCycleCollection::GetInstance() ;
  if (pUsageCycle == NULL)
  {
    SetError (DB_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "DBProductView::GetDisplayItems", "Unable to get instance of the usage cycle collection") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return FALSE ;
  }
  
  // create a SQL Rowset ...
  arpRowset = new DBSQLRowset;
  
	// get the language id ...
	std::wstring wstrKey = arLangCode ;
	int nLangCode = 840 ; // default to english 
	StrToLower(wstrKey) ;
	LangCodeCollIter langiter =  mLangCodeColl.find (wstrKey) ;
	if (langiter == mLangCodeColl.end())
	{
		mLogger->LogVarArgs (LOG_WARNING, "Unable to find language code in collection. Lang Code = %s",
				ascii(wstrKey).c_str()) ;
	}
	else
	{
		nLangCode = langiter->second;
	}


	// lock the threadlock to create and execute the query ...
	mLock.Lock() ;

	// create the query to get the items for the product ...
	if (mChildViewList.size() > 0)
	{
		wstrCmd = CreateProductViewItemDetailQuery (arAcctID,  arIntervalID,
			arSessionID, mTableName, mID, DB_COMPOUND_SESSION, nLangCode) ;
	}
	else
	{
		wstrCmd = CreateProductViewItemDetailQuery (arAcctID,  arIntervalID, 
			arSessionID, mTableName, mID, DB_ATOMIC_SESSION, nLangCode) ;
	}
	mLock.Unlock() ;

  // initialize the access to the database ...
  DBAccess myDBAccess ;
  bRetCode = myDBAccess.Init((wchar_t*)mConfigPath) ;
  if (bRetCode == FALSE)
  {
    pUsageCycle->ReleaseInstance() ;
    SetError(myDBAccess.GetLastError(), 
      "Init() failed. Unable to initialize database access layer");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return bRetCode ;
  }

	// issue a query to get the items for the product ...
	bRetCode = myDBAccess.ExecuteDisconnected (wstrCmd, (DBSQLRowset &) *arpRowset) ;
	if (bRetCode == FALSE)
	{
		SetError(myDBAccess.GetLastError(), 
			"GetDisplayItemDetail() failed. Unable to execute database query");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
	}
  // release the usage cycle collection ...
  if (pUsageCycle != NULL)
  {
    pUsageCycle->ReleaseInstance() ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	
//  @parm 
//  @rdesc 
//  
//
BOOL DBProductViewAbstract::FindProperty (const std::wstring &arName, 
                                          DBProductViewProperty * & arpProperty)
{
  // local variables
  BOOL bRetCode=TRUE ;
  std::wstring wstrString ;

  // find the property in the map ...
  if (arName.empty())
  {
    bRetCode = FALSE ;
    SetError(DB_ERR_INVALID_PARAMETER, ERROR_MODULE, ERROR_LINE, 
      "DBProductView::FindProperty");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    arpProperty = NULL ;
  }
  else
  {
    wstrString = arName ;
    StrToLower(wstrString);
		DBProductViewPropCollIter Iter = mPropColl.find(wstrString);
		if (Iter == mPropColl.end())
    {
      // look in the reserved property collection ...
      DBProductViewPropCollIter ResvdIter = mResvdPropColl.find(wstrString);
      if (ResvdIter == mResvdPropColl.end())
      {
        bRetCode = FALSE ;
        SetError(DB_ERR_ITEM_NOT_FOUND, ERROR_MODULE, ERROR_LINE, 
          "DBProductView::FindProperty");
        mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
        mLogger->LogVarArgs (LOG_ERROR, L"Unable to find property with name = %s.", 
          arName.c_str()) ;
      }
			else
			{
				arpProperty = ResvdIter->second;
			}
    }
		else
		{
			arpProperty = Iter->second;
		}
  }

  return bRetCode ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
std::wstring DBProductView::CreateProductViewSummarizeQuery(const int &arAcctID,
          const int &arIntervalID, 
          const std::wstring &arPDTableName,const int &arViewID, 
          const std::wstring &arViewName, const std::wstring &arViewType, 
          const int &arDescriptionID, const std::wstring &arExtension)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_PRODUCT_VIEW_SUMMARIZE__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam) ;
    vtParam = arViewName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWNAME, vtParam) ;
    vtParam = arViewType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWTYPE, vtParam) ;
    vtParam = (long) arDescriptionID ;
    mpQueryAdapter->AddParam (MTPARAM_DESCID, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = arExtension.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam, VARIANT_TRUE) ;
        
    // get the query ...
    _bstr_t queryString ;    
    queryString = mpQueryAdapter->GetQuery() ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::CreateProductViewSummarizeQuery", 
      "Unable to get __GET_PRODUCT_VIEW_SUMMARIZE__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

std::wstring DBProductViewAbstract::ReplaceLangCode (const int &arLangCode, const std::wstring &arWhereClause)
{
  std::wstring wstrWhereClause ;
  std::wstring wstrLangCode ;
  std::wstring tmpStr;
  tmpStr = MTPARAM_LANGCODE;

  wchar_t wstrTempNum[64] ;
  unsigned int nNum ;

  // copy the where clause ...
  wstrWhereClause = arWhereClause ;

  // create the lang code string ...
  wstrLangCode = _itow (arLangCode, wstrTempNum, 10) ;

  // replace all the instances of the lang_code ...
  while ((nNum = wstrWhereClause.find(MTPARAM_LANGCODE)) != string::npos)
  {
    wstrWhereClause.replace(nNum, tmpStr.length(), wstrLangCode);
  }

  return wstrWhereClause ;
}



std::wstring DBProductView::CreateProductViewItemsQuery(const int &arAcctID,
          const int &arIntervalID, 
          const std::wstring &arPDTableName, const int &arViewID, 
          const std::wstring &arSessionType, const std::wstring &arExtension, 
          const int &arLangCode,
					long instanceID)
{
  // local variables ...
  std::wstring wstrCmd ;
  std::wstring wstrWhereClause ;
  _variant_t vtParam ;
  _bstr_t queryTag ;  

  try
  {
    // replace the lang code in the where clause ...
    wstrWhereClause = ReplaceLangCode (arLangCode, mWhereClause) ;

    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    // if the account id isnt -1 then get the transaction for the account id ...
    if (arAcctID != -1)
    {
      queryTag = "__GET_PRODUCT_VIEW_ITEMS_EXT__" ;
    }
    // otherwise ... get all the transactions for the interval ...
    else
    {
      queryTag = "__GET_ALL_PRODUCT_VIEW_ITEMS_EXT__" ;
    }
    
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam);
    vtParam = wstrWhereClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_WHERECLAUSE, vtParam);
    vtParam = mFromClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_FROMCLAUSE, vtParam);
    vtParam = arSessionType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SESSIONTYPE, vtParam);
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam);

    // only add the account id if it's not -1 ...
    if (arAcctID != -1)
    {
      vtParam = (long) arAcctID ;
      mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam);
    }
    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam);
    vtParam = (long) arIntervalID;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam);
    vtParam = arExtension.c_str();
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam, VARIANT_TRUE) ;

		if(instanceID == 0) {
			mpQueryAdapter->AddParam ("%%INSTANCE_ID%%", "is NULL");
		}
		else {
			char buff[100];
			sprintf(buff,"= %d",CONVERT_INSTANCE_ID(instanceID));
			mpQueryAdapter->AddParam ("%%INSTANCE_ID%%", buff);
		}
            
    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery();
    wstrCmd = (wchar_t*)queryString;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::CreateProductViewItemsQuery", 
      "Unable to get __GET_PRODUCT_VIEW_ITEMS_EXT__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

//
//	@mfunc
//	Create the product view summarize query. 
//  @rdesc 
//  The product view summarize query.
//
std::wstring DBProductView::CreateProductViewChildrenSummaryQuery(const int &arAcctID,
          const int &arIntervalID, const int &arSessionID, 
          const std::wstring &arPDTableName, const int &arViewID, 
          const std::wstring &arViewName, const std::wstring &arViewType, 
          const int &arDescriptionID)
{
  // local variables ...
  std::wstring wstrCmd ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_PV_SUMMARIZE_CHILDREN__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam) ;
    vtParam = arViewName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWNAME, vtParam) ;
    vtParam = arViewType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWTYPE, vtParam) ;
    vtParam = (long) arDescriptionID ;
    mpQueryAdapter->AddParam (MTPARAM_DESCID, vtParam) ;
    vtParam = (long) arSessionID;
    mpQueryAdapter->AddParam (MTPARAM_PARENTID, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
        
    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::CreateProductViewChildrenSummaryQuery", 
      "Unable to get __GET_PV_SUMMARIZE_CHILDREN__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

std::wstring DBProductView::CreateProductViewItemChildrenQuery(const int &arAcctID,
          const int &arIntervalID, const int &arSessionID, 
          const std::wstring &arPDTableName, const int &arViewID,
          const std::wstring &arSessionType, const std::wstring &arExtension, 
          const int &arLangCode)
{
  // local variables ...
  std::wstring wstrCmd ;
  std::wstring wstrWhereClause ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // replace the lang code in the where clause ...
    wstrWhereClause = ReplaceLangCode (arLangCode, mWhereClause) ;

    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_PV_CHILD_ITEMS_EXT__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    vtParam = wstrWhereClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_WHERECLAUSE, vtParam) ;
    vtParam = mFromClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_FROMCLAUSE, vtParam) ;
    vtParam = arSessionType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SESSIONTYPE, vtParam) ;
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
    vtParam = (long) arSessionID ;
    mpQueryAdapter->AddParam (MTPARAM_PARENTID, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
    vtParam = arExtension.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_EXT, vtParam, VARIANT_TRUE) ;

    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::CreateProductViewItemChildrenQuery", 
      "Unable to get __GET_PV_CHILD_ITEMS_EXT__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

//
//	@mfunc
//	Create the product view items query. 
//  @rdesc 
//  The product view items query.
//
std::wstring DBProductView::CreateProductViewItemDetailQuery(const int &arAcctID,
          const int &arIntervalID, const int &arSessionID, 
          const std::wstring &arPDTableName, const int &arViewID,
          const std::wstring &arSessionType, const int &arLangCode)
{
  // local variables ...
  std::wstring wstrCmd ;
  std::wstring wstrWhereClause ;
  _variant_t vtParam ;
  _bstr_t queryTag ;

  try
  {
    // replace the lang code in the where clause ...
    wstrWhereClause = ReplaceLangCode (arLangCode, mWhereClause) ;

    // set the query tag and initialize the parameter list ...
    mpQueryAdapter->ClearQuery() ;

    queryTag = "__GET_PV_ITEM_DETAIL__" ;
    mpQueryAdapter->SetQueryTag (queryTag) ;

    vtParam = mSelectClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SELECTCLAUSE, vtParam) ;
    vtParam = wstrWhereClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_WHERECLAUSE, vtParam) ;
    vtParam = mFromClause.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_FROMCLAUSE, vtParam) ;
    vtParam = arSessionType.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_SESSIONTYPE, vtParam) ;
    vtParam = arPDTableName.c_str() ;
    mpQueryAdapter->AddParam (MTPARAM_TABLENAME, vtParam) ;
    vtParam = (long) arSessionID ;
    mpQueryAdapter->AddParam (MTPARAM_SESSIONID, vtParam) ;
    vtParam = (long) arAcctID ;
    mpQueryAdapter->AddParam (MTPARAM_ACCOUNTID, vtParam) ;
    vtParam = (long) arViewID ;
    mpQueryAdapter->AddParam (MTPARAM_VIEWID, vtParam) ;
    vtParam = (long) arIntervalID ;
    mpQueryAdapter->AddParam (MTPARAM_INTERVALID, vtParam) ;
            
    // get the query ...
    _bstr_t queryString ;
    queryString = mpQueryAdapter->GetQuery () ;
    wstrCmd = (wchar_t*) queryString ;
  }
  catch (_com_error e)
  {
    wstrCmd = L"" ;
    //SetError(e) ;
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, "DBProductView::CreateProductViewItemDetailQuery", 
      "Unable to get __GET_PV_ITEM_DETAIL__ query");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    mLogger->LogVarArgs (LOG_ERROR, 
        "Unable to get query. Error Description = %s", (char*)e.Description()) ;
  }

  return wstrCmd ;
}

