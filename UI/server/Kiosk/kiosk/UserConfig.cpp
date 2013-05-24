/**************************************************************************
* @doc
*
* Copyright 1998 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Raju Matta
* $Header$
*
*	UserConfig.cpp :
*	--------------
*	This is the implementation of the UserConfig class.
***************************************************************************/

// All the includes
// ADO includes
#include <StdAfx.h>
#include <comdef.h>
#include <adoutil.h>

// Local includes
#include <UserConfig.h>
#include <loggerconfig.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>


// import the config loader tlb
#import <MTCLoader.tlb> no_namespace
// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace
// All the constants

// field definition for the user information
FIELD_DEFINITION USER_INFO_FIELDS[] =
{
  { DB_ACCOUNT_ID, DB_INTEGER_TYPE },
  { DB_LOGIN_NAME, DB_STRING_TYPE },
  { DB_NAME_SPACE, DB_STRING_TYPE }
};

// @mfunc CUserConfig default constructor
// @parm
// @rdesc This implementations is for the default constructor of the
// Core Kiosk Gate class
DLL_EXPORT
CUserConfig::CUserConfig() :
  mpQueryAdapter(NULL), 
  mInitialized(FALSE),
  mAcctID(-1)
{
}


// @mfunc CUserConfig destructor
// @parm
// @rdesc This implementations is for the destructor of the
// Core Kiosk Gate class
DLL_EXPORT
CUserConfig::~CUserConfig()
{
  TearDown() ;
}

void CUserConfig::TearDown()
{
  if (mpQueryAdapter != NULL)
  {
    mpQueryAdapter->Release() ;
    mpQueryAdapter = NULL ;
  }

  mInitialized = FALSE ;
}

// @mfunc Initialize
// @parm
// @rdesc 
DLL_EXPORT BOOL
CUserConfig::Initialize()
{
  const char* procName = "CUserConfig::Initialize";

  // tear down the allocated memory ...
  TearDown() ;

  // instantiate a query adapter object second
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    mConfigPath = PRES_SERVER_QUERY_PATH;
    queryAdapter->Init(mConfigPath);
    
    // extract and detach the interface ptr ...
    mpQueryAdapter = queryAdapter.Detach();
  }
  catch (_com_error e)
  {
    SetError(e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to initialize query adapter");
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    return (FALSE);
  }
  
  // set the initialized flag ...
  mInitialized = TRUE ;
  
  return (TRUE) ;
}


// @mfunc Initialize
// @parm
// @rdesc 
DLL_EXPORT BOOL
CUserConfig::LoadDefaultUserConfiguration(const wstring& arExtensionName)
{
  _bstr_t buffer;
  const char* procName = "CUserConfig::LoadDefaultUserConfiguration";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to get config info.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  // instantiate a config loader object
  try
  {
    IMTConfigLoaderPtr configLoader (MTPROGID_CONFIGLOADER);
    
	string aExtensionDir;
	GetExtensionsDir(aExtensionDir);
	_bstr_t aSiteConfigDir = aExtensionDir.c_str();
	aSiteConfigDir += DIR_SEP;
	aSiteConfigDir += arExtensionName.c_str();
	aSiteConfigDir += DIR_SEP;
	aSiteConfigDir += NEW_MPSSITECONFIG_DIR;

    // initialize the configLoader ...
    configLoader->InitWithPath(aSiteConfigDir);
    
    // open the config file ...
    IMTConfigPropSetPtr profileSetPtr = 
      configLoader->GetEffectiveFile("", DEFAULT_USER_PROFILE_XML_FILE);

	// check for the null existence of the object
	if (profileSetPtr == NULL)
	{
	  mLogger->LogVarArgs (LOG_ERROR, 
						  "Unable to create configuration set for provider <%s>", 
						  _bstr_t(arExtensionName.c_str()));
	  mLogger->LogThis (LOG_ERROR, "GetEffectiveFile on DefaultUserProfile.xml file failed");
	  mLogger->LogThis (LOG_ERROR, "Could be because the effective date is ahead of the current GMT time");
	  return (FALSE);
	}

    // read the profile set
    IMTConfigPropSetPtr profileSet;
    profileSet = profileSetPtr->NextSetWithName(PROFILE_SET_STR);
    
    while (profileSet != NULL)
    {
      wstring profilename = profileSet->NextStringWithName(PROFILE_NAME_STR);
      
      _variant_t profilevalue;
      PropValType type;
      profilevalue = profileSet->NextVariantWithName(PROFILE_VALUE_STR, &type);
      
      // check if value is NULL
      if (profilevalue.vt == NULL)
      {
        mLogger->LogThis(LOG_ERROR, "NextVariantWithName returned NULL");
        return (FALSE);
      }
      
      // Add each profile value
			wstring strProfileName = profilename;
      mDefaultProfileMap[strProfileName] = profilevalue;
      profileSet = profileSetPtr->NextSetWithName(PROFILE_SET_STR);
    }
  }
  catch(_com_error& e)
  {
	buffer = "Unable to create configuration set for provider <";
	buffer += _bstr_t(arExtensionName.c_str());
	buffer += ">", 
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, buffer);
    mLogger->LogErrorObject (LOG_ERROR, GetLastError());
	mLogger->LogThis (LOG_ERROR, (const char*)buffer); 
    return (FALSE);
  }

  return (TRUE);
}

// @mfunc GetConfigInfo
// @parm 
// @parm 
// @rdesc
DLL_EXPORT BOOL
CUserConfig::GetConfigInfo(const wstring &arLoginName, 
                           const wstring &arNameSpace)
{
  const char* procName = "CUserConfig::GetConfigInfo";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to get config info.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }
  // local variables
  string buffer;
  wstring wstrTagName;
  wstring wstrTagValue;
  wstring wstrLangCode;
  wstring wstrLoginName;
  wstring langRequest;
  DBSQLRowset rowset;
  HRESULT hOK = S_OK;
  
  long lProfileID = 0;
  long lAccountID = 0;
  long lKioskID = 0;
  
  // copy the default profile map to the user profile map
  mUserProfileMap = mDefaultProfileMap;

  // build the query
  CreateInitQuery (arLoginName, arNameSpace, langRequest);

  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database initialization failed for User Config");
    return (FALSE);
  }
  
  // execute the language request
  if (!DBAccess::Execute(langRequest, rowset))
  {
    mLogger->LogThis(LOG_ERROR, "Database execution failed for User Config");
    return (FALSE);
  }
  
  //If either the BOF or EOF property is True, there is no current record.
  if (rowset.GetRecordCount() ==	0)
  {
    mLogger->LogVarArgs (LOG_DEBUG, 
      L"No rows found for user config object with login <%s> and namespace <%s>",
      arLoginName.c_str(), arNameSpace.c_str()) ;
    mLogger->LogThis (LOG_DEBUG, L"Using the default user profile map");


	// if there are 0 rows, we still need to get the language code and the
	// other information
	CreateQueryToGetNonProfileInfo(arLoginName, arNameSpace, langRequest);
  
  	// execute the language request
  	if (!DBAccess::Execute(langRequest, rowset))
  	{
	  mLogger->LogThis(LOG_ERROR, "Database execution failed for User Config");
      return (FALSE);
	}

	if (rowset.GetRecordCount() ==	0)
  	{
	  	buffer = "Non profile info not found for <";
		buffer += (const char*) _bstr_t(arLoginName.c_str());
		buffer += "> and namespace <";
		buffer += (const char*) _bstr_t(arNameSpace.c_str());
		buffer += ">";
    	SetError(KIOSK_ERR_ACCOUNT_NOT_FOUND, 
			 	ERROR_MODULE, 
			 	ERROR_LINE, 
			 	procName,
			 	buffer.c_str());
    	mLogger->LogThis (LOG_INFO, buffer.c_str()); 
		return FALSE;
	}
	else if (rowset.GetRecordCount() > 1)
  	{
	  	buffer = "More than one row found for non profile info for <";
		buffer += (const char*) _bstr_t(arLoginName.c_str());
		buffer += "> and namespace <";
		buffer += (const char*) _bstr_t(arNameSpace.c_str());
		buffer += ">";
    	SetError(KIOSK_ERR_ACCOUNT_NOT_FOUND, 
			 	ERROR_MODULE, 
			 	ERROR_LINE, 
			 	procName,
			 	buffer.c_str());
    	mLogger->LogThis (LOG_ERROR, buffer.c_str()); 
		return FALSE;
	}
	else
	{
	  	// Parse the record set
    	// get the langcode, profile ID and account ID 
    	rowset.GetWCharValue(_variant_t(LANG_CODE_STR), mLangCode);
    	rowset.GetLongValue(_variant_t(PROFILE_ID_STR), mProfileID);
    	rowset.GetLongValue(_variant_t(ACCOUNT_ID_STR), mAcctID);
	}

  	// disconnect from the database
  	if (!DBAccess::Disconnect())
	{
	  SetError(DBAccess::GetLastError());
	  mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
  	}
	
	return TRUE;
  }
  
  // Parse the record set
  while (!rowset.AtEOF())
  {
    // get the langcode, tagnametype and tagvalue
    rowset.GetWCharValue(_variant_t(TAG_NAME_STR), wstrTagName);
    rowset.GetWCharValue(_variant_t(TAG_VALUE_STR), wstrTagValue);
    rowset.GetWCharValue(_variant_t(LANG_CODE_STR), mLangCode);
    rowset.GetLongValue(_variant_t(PROFILE_ID_STR), mProfileID);
    rowset.GetLongValue(_variant_t(ACCOUNT_ID_STR), mAcctID);

	// check for the key in the profile map -- wstrTagName is the key
	// if it does not exist, then insert a new key value pair
	// else update the value by first deleting the record and then inserting
	// a new one
		wstring strTagName = wstrTagName;
		mUserProfileMap[strTagName] = wstrTagValue.c_str();
    
    // Move to next record
    if (!rowset.MoveNext())
    {
      SetError (rowset.GetLastError(),
        "GetConfigInfo() failed. Unable to move to next row of rowset") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
  }

  // disconnect from the database
  if (!DBAccess::Disconnect())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
  }
  
  return (TRUE);
}
// @mfunc UpdateLanguage
// @parm
// @rdesc 
DLL_EXPORT BOOL
CUserConfig::UpdateUserLanguage(const wstring &arLoginName, 
								const wstring &arNameSpace,
								const wstring &arLangCode)
{
  wstring langRequest ;

  const char* procName = "CUserConfig::UpdateUserLanguage";
  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to update language for user.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for User Config");
    return (FALSE);
  }
  // get the localized site id ...
    if (!DBAccess::InitializeForStoredProc(L"GetLocalizedSiteInfo"))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Initialization of GetLocalizedSiteInfo stored procedure failed");
    return FALSE;
  }
  
  // add the parameters ...
  _variant_t vtValue = arNameSpace.c_str() ;
  if (!DBAccess::AddParameterToStoredProc (L"nm_space", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = arLangCode.c_str() ;
  if (!DBAccess::AddParameterToStoredProc (L"tx_lang_code", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  //add the output parameter ...
  if (!DBAccess::AddParameterToStoredProc (L"id_site", MTTYPE_INTEGER, OUTPUT_PARAM))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add output parameter to stored procedure.");
    return FALSE;
  }

  // execute the stored procedure ...
  if (!DBAccess::ExecuteStoredProc())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }

  // get the parameter ...
  if (!DBAccess::GetParameterFromStoredProc (L"id_site", vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }
  
  long nNewSiteID = vtValue.lVal ;

  // get the current site id ... 
  wstring wstrCmd ;
  CreateGetCurrentSiteIDQuery (arLoginName, arNameSpace, wstrCmd) ;

  // execute the query ...
  DBSQLRowset myRowset ;
  if (!DBAccess::Execute(wstrCmd, myRowset))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to execute get current site id query.");
    return FALSE;
  }

  // get the site id ...
  long nCurrentSiteID = -1 ;
  myRowset.GetLongValue ("id_site", nCurrentSiteID) ;

  // update the user language ...
  CreateUpdateUserLanguageQuery (arLoginName, nCurrentSiteID, nNewSiteID, wstrCmd) ;

  // execute the query ...
  if (!DBAccess::Execute(wstrCmd))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to execute get current site id query.");
    return FALSE;
  }

#if 0
  // intialize the stored procedure ...
  if (!DBAccess::InitializeForStoredProc(L"UpdateUserLanguage"))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Initialization of stored procedure failed");
    return FALSE;
  }
  
  // add the parameters ...
  _variant_t vtValue = arLoginName.c_str() ;
  if (!DBAccess::AddParameterToStoredProc (L"nm_login", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = arNameSpace.c_str() ;
  if (!DBAccess::AddParameterToStoredProc (L"nm_space", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  vtValue = arLangCode.c_str() ;
  if (!DBAccess::AddParameterToStoredProc (L"tx_lang_code", MTTYPE_VARCHAR, INPUT_PARAM, vtValue))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to add parameter to stored procedure.");
    return FALSE;
  }
  
  // execute the stored procedure ...
  if (!DBAccess::ExecuteStoredProc())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis (LOG_ERROR, "Unable to execute stored procedure.");
    return FALSE;
  }
#endif
  // update the member property if successful
  mLangCode = arLangCode;

  // disconnect from the database
  if (!DBAccess::Disconnect())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
  }

  return TRUE ;
}

// @mfunc Add
// @parm
// @rdesc 
DLL_EXPORT BOOL
CUserConfig::Add(const wstring &arLoginName, const wstring &arNameSpace,
                 const wstring &arLangCode, const long &arAcctID, 
                 const long &arTimeZoneID, LPDISPATCH pRowset)
{
  const char* procName = "CUserConfig::Add";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to add user.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  // assign the account id ...
  mAcctID = arAcctID ;
  mLangCode = arLangCode ;

  // convert the timezone id to a string ...
  _bstr_t wstrTimezoneIDValue;
  wchar_t wcharTimezoneIDValue[12];
  wstrTimezoneIDValue = _ltow_s(arTimeZoneID, wcharTimezoneIDValue, 10);

  
  // local variables ...
  BOOL bOK = TRUE;
  HRESULT hOK = S_OK;
  long nSiteID ;
  
  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for User Config");
    return (FALSE);
  }

  // create the query to get the language code and name space for the new user ...
  ROWSETLib::IMTSQLRowsetPtr pSQLRowset(pRowset) ;
  BOOL bRetCode = CreateAndExecuteGetLocalizedSiteInfoQuery(arNameSpace, 
    arLangCode, pSQLRowset) ;
  if (bRetCode == FALSE)
  {
    return FALSE ;
  }
  // get the value from the stored procedure ...
  _variant_t vtValue = pSQLRowset->GetParameterFromStoredProc ("id_site") ;
  nSiteID = vtValue.lVal ;

  // if the siteid is -99 then we were unable to insert a new localized site record ...
  if (nSiteID == -99)
  {
    mLogger->LogThis(LOG_ERROR, "Unable to insert localized site information.");
    return (FALSE);
  }
  
  // Set the profile ID
  // Before that get the new ID from the database
  if (!GetCurrentID(PROFILE_ID_STR, mProfileID, pSQLRowset))
  {
    mLogger->LogThis (LOG_ERROR, "Unable to get new profile ID");
    return (FALSE);
  }
  // create the query to insert into the t_site_user table
  bRetCode = CreateAndExecuteInsertSiteUserInfo(mProfileID, arLoginName, 
    nSiteID, pSQLRowset) ;
  if (bRetCode == FALSE)
  {
    return FALSE ;
  }

#if 0
  // insert into the t_profile table
  DefaultProfileIterator itr(mDefaultProfileMap);
  wstring wstrValue;
  wstring wstrKey ;
  wchar_t wcharValue[10];
  itr.reset();
  while (itr())
  {
    // get the key ...
    wstrKey = itr.key() ;

    // if the timezoneid is valid (not -99) and the key is TimeZoneID ... use the one passed ...
    if ((arTimeZoneID != -99) && 
      (wstrKey.compareTo (L"timeZoneID", wstring::ignoreCase) == 0))
    {
      wstrValue = wstrTimezoneIDValue ;
    }
    else
    {
      switch (itr.value().vt)
      {
      case VT_I4:
        wstrValue = _ltow(itr.value().lVal, wcharValue, 10);
        break;
        
      case VT_BSTR:
        wstrValue = _bstr_t(itr.value());
        break;
        
      default:
        mLogger->LogThis(LOG_ERROR, "Invalid Parameter");
        break;
      }
    }
    // create the insert user profile query ...
    bRetCode = CreateAndExecuteInsertOrUpdateUserProfileInfo (INS_QUERY_TYPE_STR, 
      itr.key(), wstrValue, DEFAULT_DESC_STR, mProfileID, pSQLRowset) ;
    if (bRetCode == FALSE)
    {
      return FALSE ;
    }
  }
#endif

  return (TRUE);
}

// @mfunc Delete
// @parm
// @rdesc 
DLL_EXPORT BOOL
CUserConfig::Delete(const wstring &arLoginName, const wstring &arNameSpace,
					const wstring &arLangCode, const long &arAcctID, 
					const long &arTimeZoneID, LPDISPATCH pRowset)
{
  const char* procName = "CUserConfig::Delete";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to delete user.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }

  // assign the account id ...
  mAcctID = arAcctID ;
  mLangCode = arLangCode ;

  // convert the timezone id to a string ...
  _bstr_t wstrTimezoneIDValue;
  wchar_t wcharTimezoneIDValue[12];
  wstrTimezoneIDValue = _ltow_s(arTimeZoneID, wcharTimezoneIDValue, 10);

  
  // local variables ...
  BOOL bOK = TRUE;
  HRESULT hOK = S_OK;
  long nSiteID ;
  
  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for User Config");
    return (FALSE);
  }

  // create the query to get the language code and name space for the new user ...
  ROWSETLib::IMTSQLRowsetPtr pSQLRowset(pRowset) ;
  BOOL bRetCode = CreateAndExecuteGetLocalizedSiteInfoQuery(arNameSpace, 
    arLangCode, pSQLRowset) ;
  if (bRetCode == FALSE)
  {
    return FALSE ;
  }
  // get the value from the stored procedure ...
  _variant_t vtValue = pSQLRowset->GetParameterFromStoredProc ("id_site") ;
  nSiteID = vtValue.lVal ;

  // if the siteid is -99 then we were unable to insert a new localized site record ...
  if (nSiteID == -99)
  {
    mLogger->LogThis(LOG_ERROR, "Unable to insert localized site information.");
    return (FALSE);
  }
  
  // Set the profile ID
  // Before that get the new ID from the database
  if (!GetCurrentID(PROFILE_ID_STR, mProfileID, pSQLRowset))
  {
    mLogger->LogThis (LOG_ERROR, "Unable to get new profile ID");
    return (FALSE);
  }
  // create the query to insert into the t_site_user table
  bRetCode = CreateAndExecuteDeleteSiteUserInfo(arLoginName, nSiteID, pSQLRowset) ;
  if (bRetCode == FALSE)
  {
    return FALSE ;
  }

  return (TRUE);
}

// @mfunc GetUserConfigValue
// @parm tag name
// @parm tag type
// @rdesc returns the corresponding value from the map
DLL_EXPORT BOOL
CUserConfig::GetUserConfigValue (const wstring &arTagName,
                                 _variant_t& arValue)
{
  // check to make sure we're initialized ...
  const char* procName = "CUserConfig::GetUserConfigValue";
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to get config info.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }
  // find the value in the map ...
	std::wstring strTagName = arTagName;
	Profile::iterator it = mUserProfileMap.find(strTagName);
	if (it == mUserProfileMap.end())
	{
    mLogger->LogVarArgs(LOG_ERROR,
      L"Tag name <%s> not found in the map", arTagName.c_str());
    return (FALSE);
	}

	arValue = it->second;
	return TRUE;
}

//	@mfunc SetUserConfigValue
//	@parm Tag Name
//	@parm Tag Type
//	@parm Tag Value
//	@rdesc Find the associated string tag value in the Profile Map
//	This function sets the value for a profile name.
//	For eg:  "black" for "bgcolor"
//	Set the map with the appropriate values.
//	If the key does not exist, enter a new key and value pair
//	else update the existing value for the key by first deleting
//	it and then inserting a new value.
DLL_EXPORT BOOL
CUserConfig::SetUserConfigValue (const wstring &arTagName,
                                 const wstring &arTagValue)
{
  DBSQLRowset rowset;
  string buffer;
  const char* procName = "CUserConfig::SetUserConfigValue";

  // check to make sure we're initialized ...
  if (!mInitialized)
  {
    SetError (KIOSK_ERR_NOT_INITIALIZED, ERROR_MODULE, ERROR_LINE,
      procName, "Unable to get config info.") ;
    mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE) ;
  }
  
  BOOL bOK = TRUE;
  BOOL bProfileExistsInTable;
  wstring langRequest;

  // check to see if the profile value exists for that profile ID
  CreateQueryToSeeIfProfileExists(arTagName, langRequest);

  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for User Config");
    return (FALSE);
  }

  // execute the language request
  if (!DBAccess::Execute(langRequest, rowset))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database execution failed");
    return (FALSE);
  }

	if (rowset.GetRecordCount() == 0)
  {
	 	buffer = "Profile info not found for <";
		buffer += (const char*) _bstr_t(arTagName.c_str());
		buffer += "> and value <";
		buffer += (const char*) _bstr_t(arTagValue.c_str());
		buffer += ">";
   	mLogger->LogThis (LOG_INFO, buffer.c_str()); 
		bProfileExistsInTable = FALSE;
	}
	else 
  {
  	bProfileExistsInTable = TRUE;
	}
  
  // check for the key in the table -- wstrTagName is the key
  // if it does not exist, then insert a new key value pair and add in table
  // else update the value by first deleting the record and then inserting
  // a new one
  if (bProfileExistsInTable != TRUE)
  {
		wstring strTagName = arTagName;
    mUserProfileMap[strTagName] = arTagValue.c_str();
    CreateInsertOrUpdateUserProfileInfo (INS_QUERY_TYPE_STR, arTagName, 
      arTagValue, DEFAULT_DESC_STR, mProfileID, langRequest) ;
  }
  else
  {
		wstring strTagName = arTagName;
    mUserProfileMap.erase(strTagName);
    mUserProfileMap[strTagName] = arTagValue.c_str();
    CreateInsertOrUpdateUserProfileInfo  (UPD_QUERY_TYPE_STR, arTagName, 
      arTagValue, DEFAULT_DESC_STR, mProfileID, langRequest) ;
  }
  
  // execute the language request
  if (!DBAccess::Execute(langRequest))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database execution failed");
    return (FALSE);
  }

  // disconnect from the database
  if (!DBAccess::Disconnect())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
  }
  
  return (TRUE);
}



//	@mfunc Get the user and its associated account
//	@parm
//	@rdesc
//	Returns the record set pointer.  This contains the data from the
//	database.  If no rows returned, throw an exception and in case of
//	exception that is caught from ADO, return null pointer
DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr
CUserConfig::GetUserAccountInfo()
{
  // local variables
  BOOL bOK = TRUE;
  HRESULT hOK = S_OK;
  DBSQLRowset rowset;
  wstring langRequest;
  
  wstring wstrLoginName;
  wstring wstrNameSpace;
  long lAccountID = 0;
  const char* procName = "CUserConfig::GetUserAccountInfo()";
  
  ROWSETLib::IMTInMemRowsetPtr inmemrowset(MTPROGID_INMEMROWSET);
  
  // build the query
  CreateQueryToSelectUserAccountInfo (langRequest);

  // initialize the database context
  if (!DBAccess::Init((wchar_t *)mConfigPath))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database initialization failed for User Config");
    return (FALSE);
  }
  
  // execute the language request
  if (!DBAccess::Execute(langRequest, rowset))
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR,
						"Database execution failed for User Config");
    return (NULL);
  }
  
  // If either the BOF or EOF property is True, there is no current record.
  if (rowset.GetRecordCount() ==	0)
  {
    mLogger->LogThis(LOG_ERROR, "No rows found in the t_account_mapper table");
    return (NULL);
  }
  
  // initialize the inmemrowset
  try
  {
    hOK = inmemrowset->Init();
    if (!SUCCEEDED(hOK))
    {
      mLogger->LogVarArgs (LOG_ERROR,
								"Unable to instantiate Rowset object. Error = <%d>", hOK);
      return (NULL);
    }
  }
  catch (_com_error e)
  {
    SetError (e.Error(),
      ERROR_MODULE,
      ERROR_LINE,
      "InMemRowset threw a COM exception" );
    mLogger->LogErrorObject(LOG_ERROR, GetLastError());
    return (NULL);
  }
  
  // build the base for storing the values that come back from the
  // database
  int nNumFields = (sizeof(USER_INFO_FIELDS)/sizeof(FIELD_DEFINITION));
  for (int i = 0; i < nNumFields; i++)
  {
    // add the field definition
    hOK = inmemrowset->AddColumnDefinition (USER_INFO_FIELDS[i].FieldName,
      USER_INFO_FIELDS[i].FieldType);
    if (!SUCCEEDED(hOK))
    {
      DWORD nError = ERROR_INVALID_PARAMETER;
      SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
      mLogger->LogVarArgs (LOG_ERROR, "Unable to create a row set. Error <%d>", nError);
    }
  }
  
  // Parse the record set
  // CrackStrVariant turns any datatype into a string
  while (!rowset.AtEOF())
  {
    // get the langcode, tagnametype and tagvalue
    rowset.GetLongValue(_variant_t(ACCOUNT_ID_STR), lAccountID);
    rowset.GetWCharValue(_variant_t(LOGIN_NAME_STR), wstrLoginName);
    rowset.GetWCharValue(_variant_t(NAME_SPACE_STR), wstrNameSpace);
    
    // add the rows to the rowset
    hOK = inmemrowset->AddRow();
    if (!SUCCEEDED(hOK))
    {
      DWORD nError = ERROR_INVALID_PARAMETER;
      SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
      mLogger->LogVarArgs (LOG_ERROR, "Unable to add row. Error <%d>", nError);
    }
    
    // add account id first
    hOK = inmemrowset->AddColumnData(DB_ACCOUNT_ID, lAccountID);
    if (!SUCCEEDED(hOK))
    {
      DWORD nError = ERROR_INVALID_PARAMETER;
      SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
      mLogger->LogVarArgs (LOG_ERROR, "Unable to add field data. Error <%d>", nError);
    }
    
    // add login name second
    hOK = inmemrowset->AddColumnData(DB_LOGIN_NAME, (_variant_t)wstrLoginName.c_str());
    if (!SUCCEEDED(hOK))
    {
      DWORD nError = ERROR_INVALID_PARAMETER;
      SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
      mLogger->LogVarArgs (LOG_ERROR, "Unable to add field data. Error <%d>", nError);
    }
    
    // add name space third
    hOK = inmemrowset->AddColumnData(DB_NAME_SPACE, (_variant_t)wstrNameSpace.c_str());
    if (!SUCCEEDED(hOK))
    {
      DWORD nError = ERROR_INVALID_PARAMETER;
      SetError(nError, ERROR_MODULE, ERROR_LINE, procName);
      mLogger->LogVarArgs (LOG_ERROR, "Unable to add field data. Error <%d>", nError);
    }
    
    // Move to next record
    if (!rowset.MoveNext())
    {
      SetError (rowset.GetLastError(),
        "GetUserAccountInfo() failed. Unable to move to next row of rowset") ;
      mLogger->LogErrorObject (LOG_ERROR, GetLastError()) ;
      return FALSE ;
    }
  }

  // disconnect from the database
  if (!DBAccess::Disconnect())
  {
    SetError(DBAccess::GetLastError());
    mLogger->LogThis(LOG_ERROR, "Database disconnect failed");
  }
  
  return (inmemrowset);
}



//	@mfunc CreateInitQuery
//	@parm  pLoginName
//	@parm  pName_Space
//	@rdesc Builds the query required for initializing the kiosk gate using
//	the provider ID.
void
CUserConfig::CreateInitQuery (const wstring &arLoginName,
                              const wstring &arNameSpace,
                              wstring& langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateInitQuery";
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__SELECT_USER_CONFIG_PROFILE_PRESSERVER__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arNameSpace.c_str();
    mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __SELECT_USER_CONFIG_PROFILE_PRESSERVER__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  return;
}

//	@mfunc CreateQueryToGetNonProfileInfo
//	@parm  pLoginName
//	@parm  pName_Space
void
CUserConfig::CreateQueryToGetNonProfileInfo (const wstring &arLoginName,
                              const wstring &arNameSpace,
                              wstring& langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateQueryToGetNonProfileInfo";
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__SELECT_USER_CONFIG_NON_PROFILE_INFO__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arNameSpace.c_str();
    mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __SELECT_USER_CONFIG_NON_PROFILE_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  return;
}

//	@mfunc CreateQueryToSeeIfProfileExists
//  @parm  arTagName, 
void
CUserConfig::CreateQueryToSeeIfProfileExists (const wstring &arTagName,
                              wstring& langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateQueryToSeeIfProfileExists";
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__SELECT_USER_PROFILE_RECORD__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arTagName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_TAGNAME, vtParam);
    
    vtParam = mProfileID;
    mpQueryAdapter->AddParam(MTPARAM_PROFILEID, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __SELECT_USER_CONFIG_NON_PROFILE_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  return;
}

//
//
//
void CUserConfig::CreateUpdateUserLanguageQuery (const wstring &arLoginName, 
                                                 const long &arCurrentSiteID,
                                                 const long &arNewSiteID,
                                                 wstring& langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateUpdateUserLanguageQuery";
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__UPDATE_USER_LANGUAGE__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arCurrentSiteID;
    mpQueryAdapter->AddParam(MTPARAM_SITEID, vtParam);

    vtParam = arNewSiteID;
    mpQueryAdapter->AddParam(MTPARAM_NEWSITEID, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __UPATE_USER_LANGUAGE__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  return;
}
void CUserConfig::CreateGetCurrentSiteIDQuery (const wstring &arLoginName, 
                                               const wstring &arNameSpace,
                                               wstring& langRequest)
{
  // get the query
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateInitQuery";
  
  try
  {
    mpQueryAdapter->ClearQuery();
    queryTag = "__GET_CURRENT_SITE_ID__";
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arNameSpace.c_str();
    mpQueryAdapter->AddParam(MTPARAM_NAMESPACE, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get __GET_CURRENT_SITE_ID__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  return;
}

//	@mfunc CreateInsertOrUpdateUserProfileInfo
//	@parm  Query type (insert or update),
//	@parm  Tag Type,
//	@parm  Tag Value,
//	@parm  Tag Name,
//	@parm  Profile ID,
//	@parm  Profile Type,
//	@parm  Description ID
//	@rdesc Builds the query required for setting the pwd
void
CUserConfig::CreateInsertOrUpdateUserProfileInfo (const wstring &arQueryType,
                                              const wstring &arTagName,
                                              const wstring &arTagValue,
                                              const wstring &arDescription,
                                              const long &arProfileID,
                                              wstring& langRequest)
{
  // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  const char* procName = "CUserConfig::CreateQueryToSetUserConfigValue"; 
  
  if (arQueryType.compare (INS_QUERY_TYPE_STR) == 0)
    queryTag = "__INSERT_USER_PROFILE_PRESSERVER__";
  else if (arQueryType.compare (UPD_QUERY_TYPE_STR) == 0)
    queryTag = "__UPDATE_USER_PROFILE__";
  else
  {
    langRequest = L"" ;
    mLogger->LogVarArgs (LOG_ERROR, 
      L"Unable to create user profile query. Invalid query type <%s>", 
      arQueryType.c_str()) ;
    return ;
  }
  try
  {
    // get the query
    mpQueryAdapter->ClearQuery();
    mpQueryAdapter->SetQueryTag(queryTag);
    
    vtParam = arProfileID;
    mpQueryAdapter->AddParam(MTPARAM_PROFILEID, vtParam);

    vtParam = arTagName.c_str();
    mpQueryAdapter->AddParam(MTPARAM_TAGNAME, vtParam);
    
    vtParam = arTagValue.c_str();
    mpQueryAdapter->AddParam(MTPARAM_TAGVALUE, vtParam);
    
    vtParam = arDescription.c_str();
    mpQueryAdapter->AddParam(MTPARAM_TEXTDESCRIPTION, vtParam);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to setup INSERT or UPDATE query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
    
  return;
}
                                              
                                              // @mfunc CreateQueryToSelectUserAccountInfo
// @parm
// @rdesc Creates a query to select the user account information
void
CUserConfig::CreateQueryToSelectUserAccountInfo (wstring& langRequest)
{
  // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  const char* procName = "CUserConfig::CreateQueryToSelectUserAccountInfo"; 
  
  try
  {
    queryTag = "__SELECT_USER_ACCOUNT_INFO_PRESSERVER__";
    
    // get the query
    mpQueryAdapter->ClearQuery();
    mpQueryAdapter->SetQueryTag(queryTag);
    
    langRequest = mpQueryAdapter->GetQuery();
  }
  catch (_com_error e)
  {
    langRequest = L"" ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
      "Unable to get __SELECT_USER_ACCOUNT_INFO_PRESSERVER__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
    return ;
  }
  
  return;
}

BOOL 
CUserConfig::GetCurrentID(const wchar_t* pFieldName, 
                          long& arID, ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // assert for null values
  ASSERT (pFieldName);
  
  // locals..
  DBSQLRowset rowset;
  wstring langRequest;
  const char* procName = "CUserConfig::GetCurrentID";
  // initialize the stored procedure ...
  arRowset->InitializeForStoredProc ("GetCurrentID") ;
  
  // add the parameters ...
  _variant_t vtParam = pFieldName ;
  arRowset->AddInputParameterToStoredProc("nm_current", MTTYPE_VARCHAR, INPUT_PARAM, vtParam) ;
  arRowset->AddOutputParameterToStoredProc("id_current", MTTYPE_INTEGER, OUTPUT_PARAM) ;
  
  // execute the stored procedure ...
  arRowset->ExecuteStoredProc() ;
  
  // get the value from the stored procedure ...
  _variant_t vtValue = arRowset->GetParameterFromStoredProc ("id_current") ;
  arID = vtValue.lVal ;
  
  return (TRUE);  
}

//
//
//
BOOL
CUserConfig::CreateAndExecuteInsertSiteUserInfo(const long &arProfileID, 
                                 const wstring &arLoginName, 
                                 const long &arSiteID, 
                                 ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  
  try
  {
    queryTag = "__INSERT_SITE_USER_INFO_PRESSERVER__";
    
    // get the query
    arRowset->ClearQuery();
    arRowset->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arSiteID;
    arRowset->AddParam(MTPARAM_SITEID, vtParam);
    
    vtParam = arProfileID;
    arRowset->AddParam(MTPARAM_PROFILEID, vtParam);

    arRowset->Execute() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CUserConfig::CreateAndExecuteInsertSiteUserInfo()", 
      "Unable to get __INSERT_SITE_USER_INFO_PRESSERVER__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return bRetCode ;
}

//
//
//
BOOL
CUserConfig::CreateAndExecuteDeleteSiteUserInfo(const wstring &arLoginName, 
                                 const long &arSiteID, 
                                 ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  
  try
  {
    queryTag = "__DELETE_SITE_USER_INFO__";
    
    // get the query
    arRowset->ClearQuery();
    arRowset->SetQueryTag(queryTag);
    
    vtParam = arLoginName.c_str();
    arRowset->AddParam(MTPARAM_LOGINID, vtParam);
    
    vtParam = arSiteID;
    arRowset->AddParam(MTPARAM_SITEID, vtParam);
    
    arRowset->Execute() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CUserConfig::CreateAndExecuteDeleteSiteUserInfo()", 
      "Unable to get __DELETE_SITE_USER_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  
  return bRetCode ;
}

//
//
//
BOOL 
CUserConfig::CreateAndExecuteGetLocalizedSiteInfoQuery(const wstring &arNameSpace,
                                                       const wstring &arLangCode,
                                                       ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
    // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  
  try
  {
    // initialize the stored procedure ...
    arRowset->InitializeForStoredProc ("GetLocalizedSiteInfo") ;

    // add the parameters ...
    vtParam = arNameSpace.c_str();
    arRowset->AddInputParameterToStoredProc("nm_space", MTTYPE_VARCHAR, INPUT_PARAM, vtParam) ;
    vtParam = arLangCode.c_str();
    arRowset->AddInputParameterToStoredProc("tx_lang_code", MTTYPE_VARCHAR, INPUT_PARAM, vtParam) ;
    arRowset->AddOutputParameterToStoredProc("id_site", MTTYPE_INTEGER, OUTPUT_PARAM) ;

    // execute the stored procedure ...
    arRowset->ExecuteStoredProc() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "CUserConfig::CreateAndExecuteGetLocalizedSiteInfoQuery()", 
      "Unable to get and execute __GET_LOCALIZED_SITE_INFO__ query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
  return bRetCode ;
}

BOOL
CUserConfig::CreateAndExecuteInsertOrUpdateUserProfileInfo (const wstring &arQueryType,
                                              const wstring &arTagName,
                                              const wstring &arTagValue,
                                              const wstring &arDescription,
                                              const long &arProfileID,
                                              ROWSETLib::IMTSQLRowsetPtr &arRowset)
{
  // local variables
  _bstr_t queryTag;
  _bstr_t queryString;
  _variant_t vtParam;
  BOOL bRetCode=TRUE ;
  const char* procName = "CUserConfig::CreateQueryToSetUserConfigValue"; 
  
  if (arQueryType.compare (INS_QUERY_TYPE_STR) == 0)
    queryTag = "__INSERT_USER_PROFILE_PRESSERVER__";
  else if (arQueryType.compare (UPD_QUERY_TYPE_STR) == 0)
    queryTag = "__UPDATE_USER_PROFILE__";
  else
  {
    mLogger->LogVarArgs (LOG_ERROR, 
      L"Unable to create user profile query. Invalid query type <%s>", 
      arQueryType.c_str()) ;
    return FALSE;
  }
  try
  {
    // get the query
    arRowset->ClearQuery();
    arRowset->SetQueryTag(queryTag);
    
    vtParam = arProfileID;
    arRowset->AddParam(MTPARAM_PROFILEID, vtParam);

    vtParam = arTagName.c_str();
    arRowset->AddParam(MTPARAM_TAGNAME, vtParam);
    
    vtParam = arTagValue.c_str();
    arRowset->AddParam(MTPARAM_TAGVALUE, vtParam);
    
    vtParam = arDescription.c_str();
    arRowset->AddParam(MTPARAM_TEXTDESCRIPTION, vtParam);
    
    arRowset->Execute() ;
  }
  catch (_com_error e)
  {
    bRetCode = FALSE ;
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName,
      "Unable to get and execute the INSERT or UPDATE query") ;
    mLogger->LogErrorObject(LOG_ERROR, GetLastError()) ;
  }
    
  return bRetCode;
}

