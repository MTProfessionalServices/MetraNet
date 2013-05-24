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
 * $Header: DBInstall.cpp, 53, 9/11/2002 9:28:47 AM, Alon Becker$
 * 
 * 	DBInstall.cpp : 
 *	---------------
 *	This is the implementation of the DBInstall class.
 ***************************************************************************/


// All the includes

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

// ADO includes
#include <mtcryptoapi.h>

#include <comdef.h>
#include <adoutil.h>

// Local 
#include <DBInstall.h>
#include <loggerconfig.h>
#include <ConfigDir.h>
#include <iostream>

#import <RCD.tlb>
// All the constants

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName") no_namespace

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

// @mfunc CDBInstall default constructor
// @parm 
// @rdesc This implementations is for the default constructor of the 
// Core Database Install class
DLL_EXPORT 
CDBInstall::CDBInstall() :
  mpQueryAdapter(0),
	mTimeout(0),
	mpInstallXmlFileName(NULL),
	mpUninstallXmlFileName(NULL)
{
  // initialize the logger
  LoggerConfigReader configReader;
  mLogger.Init (configReader.ReadConfiguration(DBINSTALL_STR), DBINSTALL_TAG);
}

// @mfunc CDBInstall destructor
// @parm 
// @rdesc This implementations is for the destructor of the 
// Core Database Install class
DLL_EXPORT 
CDBInstall::~CDBInstall()
{
}

BOOL CDBInstall::Initialize()
{
  HRESULT hOK ;
  // instantiate a query adapter object second
  try
  {
    hOK = mpQueryAdapter.CreateInstance(MTPROGID_QUERYADAPTER);
    if (!SUCCEEDED(hOK))
    {
		    mLogger.LogVarArgs (LOG_ERROR,
          "Unable to instantiate Query Adapter object. Error = <%d>", hOK);
        return (FALSE);	
    }
    
    // initialize the query adapter object
    _bstr_t configPath = mpConfigPath;
    mpQueryAdapter->Init(configPath);
  }
  catch(_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "CDBInstall::Initialize", 
      "Unable to create query adapter");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE);
  }
  
  // instantiate a config loader object second
  try
  {
		HRESULT hOk = mpConfig.CreateInstance(MTPROGID_CONFIG);
    if (!SUCCEEDED(hOK))
    {
		    mLogger.LogVarArgs (LOG_ERROR,
          "Unable to instantiate mtconifg object. Error = <%d>", hOK);
        return (FALSE);	
    }
  }
  catch(_com_error e)
  {
    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, "CDBInstall::Initialize",
      "Unable to create config loader");
    mLogger.LogErrorObject (LOG_ERROR, GetLastError()) ;
    return (FALSE);
  }
  return TRUE ;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall::DisconnectDatabase
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall::DisconnectDatabase()
{
	if (!DBAccess::Disconnect())
	{
	    SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		return (FALSE);
	}
	return TRUE;
}

BOOL CDBInstall::ProcessXmlFile(const char* pInstallFile, const BOOL bReturnOnFailure)
{
	VARIANT_BOOL vUnused;

	char buff[MAX_PATH];
	RCDLib::IMTRcdPtr aRcd(MTPROGID_RCD);
	sprintf(buff,"%s\\%s\\%s",(const char*)aRcd->GetConfigDir(),DB_INSTALL_CONFIG_PATH,pInstallFile);

	IMTConfigPropSetPtr confSetPtr = mpConfig->ReadConfiguration (buff,&vUnused);
	IMTConfigPropSetPtr ConfigDataSet = confSetPtr->NextSetWithName("mtconfigdata");

	IMTConfigPropSetPtr installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
	
	// loop through all the install set
	try
	{
	  while (installSet != NULL)
		{
			BOOL bRetval;
			bRetval = ProcessInstallset(installSet);
			if((!bRetval) && (bReturnOnFailure)) 
        return bRetval;

			installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
		}	
	}
	catch (_com_error& e)
	{
	  SetError (e.Error(), ERROR_MODULE, ERROR_LINE, 
      "Unable to process xml file." );
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
    mLogger.LogVarArgs (LOG_ERROR, "Unable to process xml file %s in directory %s",
      pInstallFile, DB_INSTALL_CONFIG_PATH) ;
		return (FALSE);
	}
	return TRUE;

}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall::ProcessInstallset
// Description	  : Process an InstallSet XML set
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall::ProcessInstallset(IMTConfigPropSetPtr installSet)
{
	_bstr_t option;
	_bstr_t message;
	_bstr_t queryTag;
	_variant_t vtParam;
	long count;

	// NOTE: option is not used
	option = installSet->NextStringWithName(OPTION_STR);
	message = installSet->NextStringWithName(MESSAGE_STR);
	queryTag = installSet->NextStringWithName(QUERY_TAG_STR);
	count = installSet->NextLongWithName(QUERY_PARAM_COUNT_STR);

	mpQueryAdapter->ClearQuery();
	mpQueryAdapter->SetQueryTag(queryTag);

	// get the parameters only if the count is more than 0
	IMTConfigPropSetPtr queryParamSet;
	queryParamSet = installSet->NextSetWithName(QUERY_PARAM_SET_STR);

	while (queryParamSet != NULL)
	{
			for (int i = 0; i < count; i++)
		{
				_bstr_t param = queryParamSet->NextStringWithName(PARAM_STR);
				string wstrParam(param);

			_variant_t vtParam;
			if (!FindPairValue(wstrParam.c_str(), vtParam))
			{
				mLogger.LogThis(LOG_ERROR,
								"Values not found in the map");
				return (FALSE);
			}

			mpQueryAdapter->AddParam(param, vtParam);
		}
		queryParamSet = installSet->NextSetWithName(QUERY_PARAM_SET_STR);
	}

	wstring langRequest;
	langRequest = mpQueryAdapter->GetQuery();

	// set the timeout number to be a high value
	cout << (const char *)message << endl;
	if (!DBAccess::Execute(langRequest, mTimeout))
	{
			SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR,
			"Database execution failed for dropping database");
		return (FALSE);
	}

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall::ExecuteQueries
// Description	  : Process Queries
// The data base must be initialized before this call!
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall::ExecuteQueries(const char* pPath,const char* pFile)
{
	VARIANT_BOOL vUnused;
	char buff[MAX_PATH];
	sprintf(buff,"%s\\%s",pPath,pFile);

	IMTConfigPropSetPtr confSetPtr = mpConfig->ReadConfiguration (buff,&vUnused);
	IMTConfigPropSetPtr ConfigDataSet = confSetPtr->NextSetWithName("mtconfigdata");

	// read the default set
	IMTConfigPropSetPtr installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
	
	// loop through all the install set
	try
	{
	    while (installSet != NULL)
		{
	    	_bstr_t option;
			_bstr_t message;
			_bstr_t queryTag;
			_variant_t vtParam;
			long count;
	
			// TODO: option is not used
			option = installSet->NextStringWithName(OPTION_STR);
			message = installSet->NextStringWithName(MESSAGE_STR);
			queryTag = installSet->NextStringWithName(QUERY_TAG_STR);
			count = installSet->NextLongWithName(QUERY_PARAM_COUNT_STR);

			mpQueryAdapter->ClearQuery();
			mpQueryAdapter->SetQueryTag(queryTag);

			wstring langRequest;
			langRequest = mpQueryAdapter->GetQuery();

			// execute the language request
			cout << (const char *)message << endl;
			if (!DBAccess::Execute(langRequest))
			{
			    SetError(DBAccess::GetLastError());
				mLogger.LogThis(LOG_ERROR,
								"Database execution failed for dropping database");
				return (FALSE);
			}
			installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
		}	
	}
	catch (_com_error e)
	{
	    SetError (e.Error(), 
				  ERROR_MODULE, 
				  ERROR_LINE, 
				  "ConfigLoader threw a COM exception" );
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		mLogger.LogVarArgs (LOG_ERROR, "Error Description= %s", (char*) e.Description()) ;
		return (FALSE);
	}
	return TRUE;
}

BOOL CDBInstall::FindPairValue(const char * apName, _variant_t & arValue)
{
	TagValuePair::const_iterator it;
	it = mPair.find(apName);
	if (it == mPair.end())
		return FALSE;

	arValue = it->second;
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall::ProcessInstallset
// Description	  : Process an InstallSet XML set
/////////////////////////////////////////////////////////////////////////////


DLL_EXPORT
CDBInstall_SQLServer::CDBInstall_SQLServer(int IsStaging):
  mSALogon(NULL_STR),
	mSAPassword(NULL_STR),
	mDatabaseName(NULL_STR),
	mServerName(NULL_STR),
	mDBOLogon(NULL_STR),
	mDBOPassword(NULL_STR),
	mDataDeviceName(NULL_STR),
	mDataDeviceLocation(NULL_STR),
//	mDataDeviceVDev(0),
	mDataDeviceSize(0),
//	mDataDeviceSize2K(0),
	mLogDeviceName(NULL_STR),
	mLogDeviceLocation(NULL_STR),
//	mLogDeviceVDev(0),
	mLogDeviceSize(0),
//	mLogDeviceSize2K(0),
	mDataDumpDeviceFile(NULL_STR),
	mLogDumpDeviceFile(NULL_STR)
{
  if (!IsStaging)
  {
		mpInstallXmlFileName = DB_INSTALL_XML_FILE;
		mpUninstallXmlFileName = DB_UNINSTALL_XML_FILE;
		mpConfigPath = DB_INSTALL_CONFIG_PATH;
  }
  else
  {
		mpInstallXmlFileName = "StagingDBInstall.xml";
		mpUninstallXmlFileName = "StagingDBUnInstall.xml";
		mpConfigPath = DB_INSTALL_CONFIG_PATH;
  }
}

DLL_EXPORT 
CDBInstall_SQLServer::~CDBInstall_SQLServer()
{
}

// @mfunc Initialize
// @parm 
// @parm 
// @rdesc 
DLL_EXPORT BOOL
CDBInstall_SQLServer::Initialize(const char* salogon,
					   const char* sapassword,
					   const char* dbname,
					   const char* servername,
					   const char* dbouserlogon,
					   const char* dbouserpassword,
					   const char* datadevicename,
					   const char* datadeviceloc,
//					   long datadevvdev,
//					   long datadevsize2K,
					   long datadevsize,
					   const char* logdevicename,
					   const char* logdeviceloc,
//					   long logdevvdev,
//					   long logdevsize2K,
					   long logdevsize,
					   const char* datadumpdevfile,
					   const char* logdumpdevfile,
					   long timeoutvalue)
{
	// local variables
	HRESULT hOK = S_OK;
	BOOL bRetCode = TRUE;

	const char* procName = "CDBInstall_SQLServer::Initialize";

  // call CDBInstall::Initialize ...
  if (!CDBInstall::Initialize())
  {
    mLogger.LogVarArgs (LOG_ERROR, "Unable to initialize sql server install.") ;
    return (FALSE) ;
  }
	// set the class attributes here
	SetSALogon(salogon);
	SetSAPassword(sapassword);
	SetDatabaseName(dbname);
	SetServerName(servername);
	SetDBOLogon(dbouserlogon);
	SetDBOPassword(dbouserpassword);

	SetDataDeviceName(datadevicename);
	SetDataDeviceLocation(datadeviceloc);
	SetDataDeviceSize(datadevsize);

	SetLogDeviceName(logdevicename);
	SetLogDeviceLocation(logdeviceloc);
	SetLogDeviceSize(logdevsize);

	SetDataDumpDeviceFile(datadumpdevfile);
	SetLogDumpDeviceFile(logdumpdevfile);
	SetTimeoutValue(timeoutvalue);

	// start inserting values into the map
	mPair["%%SA_LOGON%%"] = salogon;
	mPair["%%SA_PASSWORD%%"] = sapassword;
	mPair["%%DATABASE_NAME%%"] = dbname;
	mPair["%%SERVER_NAME%%"] = servername;
	mPair["%%DBO_LOGON%%"] = dbouserlogon;
	mPair["%%DBO_PASSWORD%%"] = dbouserpassword;
	mPair["%%DATA_DEVICE_NAME%%"] = datadevicename; 
	mPair["%%DATA_DEVICE_LOCATION%%"] = datadeviceloc;
	mPair["%%DATA_DEVICE_SIZE%%"] = datadevsize;
	mPair["%%LOG_DEVICE_NAME%%"] = logdevicename;
	mPair["%%LOG_DEVICE_LOCATION%%"] = logdeviceloc;
	mPair["%%LOG_DEVICE_SIZE%%"] = logdevsize;
	mPair["%%DATA_DUMP_DEVICE_FILE%%"] = datadumpdevfile;
	mPair["%%LOG_DUMP_DEVICE_FILE%%"] = logdumpdevfile;
	mPair["%%TIMEOUT_VALUE%%"] = timeoutvalue;

	return (TRUE);
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_SQLServer::InitDbAccess
// Description	  : 
/////////////////////////////////////////////////////////////////////////////
DLL_EXPORT
BOOL CDBInstall_SQLServer::InitDbAccess()
{
  _variant_t servername;
  _variant_t salogon;
  _variant_t sapassword;
  
  if ((!FindPairValue("%%SERVER_NAME%%", servername)) ||
				(!FindPairValue("%%SA_LOGON%%", salogon)) ||
        (!FindPairValue("%%SA_PASSWORD%%", sapassword)))
  {
    mLogger.LogThis(LOG_ERROR,
						"Values not found for SA logon/password & server name");
    return (FALSE);
  }
  
  wstring wstrservername(servername.bstrVal);
  wstring wstrsalogon(salogon.bstrVal);
  wstring wstrsapassword(sapassword.bstrVal);
  
  // initialize the database context
  // change the hard coding to macro
  if (!DBAccess::Init(MASTER_DB_STR, 
    wstrservername, 
    wstrsalogon, 
    wstrsapassword))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Owner object");
    return (FALSE);
  }
  
  return TRUE;
}


//	@mfunc Install
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_SQLServer::Install ()
{
	BOOL bRetVal = FALSE;
	// initialize the database connection
	if(InitDbAccess()) 
  {
		// uninstall the database
		ProcessXmlFile(mpUninstallXmlFileName, FALSE);
		
    // install the database
		bRetVal = ProcessXmlFile(mpInstallXmlFileName);
	}
	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}

//	@mfunc Install_withoutDropDB
// 	@parm  
//  @rdesc Builds the query required for installing a database, before first dropping it
//  executing it.
DLL_EXPORT BOOL
CDBInstall_SQLServer::Install_withoutDropDB ()
{
	BOOL bRetVal = FALSE;
	// initialize the database connection
	if(InitDbAccess()) 
  {
	
    // install the database
		bRetVal = ProcessXmlFile(mpInstallXmlFileName);
	}
	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}

//
//
//
BOOL CDBInstall_SQLServer::Uninstall()
{
// initialize the database connection
	BOOL bRetVal = FALSE;


	if(InitDbAccess()) 
  {
		bRetVal = ProcessXmlFile(mpUninstallXmlFileName);
	}

	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}

//	@mfunc ChangeDBOwner
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_SQLServer::ChangeDBOwner()
{
	// get the parameters required for Init
	_variant_t dbname;
	_variant_t servername;
	_variant_t salogon;
	_variant_t sapassword;

	if ((!FindPairValue("%%DATABASE_NAME%%", dbname)) ||
        (!FindPairValue("%%SERVER_NAME%%", servername)) ||
        (!FindPairValue("%%SA_LOGON%%", salogon)) ||
        (!FindPairValue("%%SA_PASSWORD%%", sapassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found in the map for DB/server name, SA logon/password");
		return (FALSE);
	}

	wstring wstrdbname(dbname.bstrVal);
	wstring wstrservername(servername.bstrVal);
	wstring wstrsalogon(salogon.bstrVal);
	wstring wstrsapassword(sapassword.bstrVal);

	// initialize the database context
	if (!DBAccess::Init(wstrdbname, 
						wstrservername, 
						wstrsalogon, 
						wstrsapassword))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Owner object");
		return (FALSE);
	}

	// read the MTDBInstall.xml file
	VARIANT_BOOL vUnused;

	char buff[MAX_PATH];
	RCDLib::IMTRcdPtr aRcd(MTPROGID_RCD);
	sprintf(buff,"%s\\%s\\%s",(const char*)aRcd->GetConfigDir(),DB_INSTALL_CONFIG_PATH,CHANGE_DB_OWNER_XML_FILE);

	IMTConfigPropSetPtr confSetPtr = mpConfig->ReadConfiguration (buff,&vUnused);
	IMTConfigPropSetPtr ConfigDataSet = confSetPtr->NextSetWithName("mtconfigdata");

	// read the default set
	IMTConfigPropSetPtr installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
	
	// loop through all the install set
	try
	{
	  while (installSet != NULL)
		{
	    	_bstr_t option;
			_bstr_t message;
			_bstr_t queryTag;
			_variant_t vtParam;
			long count;
	
			// TODO: option is not used
			option = installSet->NextStringWithName(OPTION_STR);
			message = installSet->NextStringWithName(MESSAGE_STR);
			queryTag = installSet->NextStringWithName(QUERY_TAG_STR);
			count = installSet->NextLongWithName(QUERY_PARAM_COUNT_STR);

			mpQueryAdapter->ClearQuery();
			mpQueryAdapter->SetQueryTag(queryTag);

			// get the parameters only if the count is more than 0
			IMTConfigPropSetPtr queryParamSet;
			queryParamSet = installSet->NextSetWithName(QUERY_PARAM_SET_STR);

			while (queryParamSet != NULL)
			{
			    for (int i = 0; i < count; i++)
				{
				    _bstr_t param = queryParamSet->NextStringWithName(PARAM_STR);
				    string wstrParam(param);

					_variant_t vtParam;
					if (!FindPairValue(wstrParam.c_str(), vtParam))
					{
					    mLogger.LogThis(LOG_ERROR, 
										"Values not found in the map");
					    return (FALSE);
					}

					mpQueryAdapter->AddParam(param, vtParam);
				}
				queryParamSet = installSet->NextSetWithName(QUERY_PARAM_SET_STR);
			}

			wstring langRequest;
			langRequest = mpQueryAdapter->GetQuery();

			// execute the language request
			cout << (const char *)message << endl;
			if (!DBAccess::Execute(langRequest))
			{
			    SetError(DBAccess::GetLastError());
				mLogger.LogThis(LOG_ERROR,
								"Database execution failed for dropping database");
				return (FALSE);
			}
			installSet = ConfigDataSet->NextSetWithName(INSTALL_SET_STR);
		}	
	}
	catch (_com_error e)
	{
	    SetError (e.Error(), 
				  ERROR_MODULE, 
				  ERROR_LINE, 
				  "ConfigLoader threw a COM exception" );
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
	    SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		return (FALSE);
	}

	return (TRUE);
}

//	@mfunc DropDBOwner
// 	@parm  
//  @rdesc Builds the query required for dropping the database owner and then
//  executing it
DLL_EXPORT BOOL
CDBInstall_SQLServer::DropDBOwner()
{
  const char* procName = "CDBInstall_SQLServer::DropDBOwner";

	// get the parameters required for Init
	_variant_t dbname;
	_variant_t servername;
	_variant_t salogon;
	_variant_t sapassword;
	_variant_t dbologon;
	_variant_t dbopassword;

	if ((!FindPairValue("%%DATABASE_NAME%%", dbname)) ||
        (!FindPairValue("%%SERVER_NAME%%", servername)) ||
        (!FindPairValue("%%DBO_LOGON%%", dbologon)) ||
        (!FindPairValue("%%DBO_PASSWORD%%", dbopassword)) ||
        (!FindPairValue("%%SA_LOGON%%", salogon)) ||
        (!FindPairValue("%%SA_PASSWORD%%", sapassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found in the map for DB/server name, SA logon/password");
		return (FALSE);
	}

	wstring wstrdbname(dbname.bstrVal);
	wstring wstrservername(servername.bstrVal);
	wstring wstrsalogon(salogon.bstrVal);
	wstring wstrsapassword(sapassword.bstrVal);
	wstring wstrdbologon(dbologon.bstrVal);
	wstring wstrdbopassword(dbopassword.bstrVal);

  // initialize the database context
  // change the hard coding to macro
  if (!DBAccess::Init(MASTER_DB_STR, 
    wstrservername, 
    wstrsalogon, 
    wstrsapassword))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Owner object");
    return (FALSE);
  }

	// the drop should occur in this order database owner 
	// create the statement to drop the database owner 
	mLogger.LogThis(LOG_INFO, "--- Starting drop of database owner ---");
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	  mpQueryAdapter->ClearQuery();
		queryTag = "__DROP_DBO_LOGIN__";
		mpQueryAdapter->SetQueryTag(queryTag);

		mpQueryAdapter->AddParam(MTPARAM_DBO_LOGON, dbologon.bstrVal);

		langRequest = mpQueryAdapter->GetQuery();
		cout << langRequest.c_str() << endl;
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __DROP_DBO_LOGON__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for dropping dbo owner statement");
		return (FALSE);
	}
	
	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		return (FALSE);
	}

	return (TRUE);
}

//	@mfunc InstallDBObjects
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_SQLServer::InstallDBObjects()
{

	// get the parameters required for Init
	_variant_t dbname;
	_variant_t servername;
	_variant_t dbologon;
	_variant_t dbopassword;

	if ((!FindPairValue("%%DATABASE_NAME%%", dbname)) ||
        (!FindPairValue("%%SERVER_NAME%%", servername)) ||
        (!FindPairValue("%%DBO_LOGON%%", dbologon)) ||
        (!FindPairValue("%%DBO_PASSWORD%%", dbopassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found DB/server name, DBO Logon/Password");
		return (FALSE);
	}

	wstring wstrdbname(dbname.bstrVal);
	wstring wstrservername(servername.bstrVal);
	wstring wstrdbologon(dbologon.bstrVal);
	wstring wstrdbopassword(dbopassword.bstrVal);

	// initialize the database context
	if (!DBAccess::Init(wstrdbname, 
						wstrservername, 
						wstrdbologon, 
						wstrdbopassword))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Install object");
		return (FALSE);
	}

	//
	RCDLib::IMTRcdPtr aRcd(MTPROGID_RCD);
	char buff[MAX_PATH];
	sprintf(buff,"%s%s",(const char*)aRcd->GetConfigDir(),DB_INSTALL_CONFIG_PATH);
	BOOL bRetVal =  ExecuteQueries(buff,DB_OBJECTS_XML_FILE);
	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		bRetVal = FALSE;
	}

	return bRetVal;
}


//	@mfunc DropDBObjects
// 	@parm  
//  @rdesc Builds the query required for dropping the database objects and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_SQLServer::DropDBObjects()
{
	// get the parameters required for Init
	_variant_t dbname;
	_variant_t servername;
	_variant_t dbologon;
	_variant_t dbopassword;

	// need to decrypt the password before doing database init.
	// encryption object
  CMTCryptoAPI mCrypto;
	int result;
	result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
        if (result != 0)
	{
		mLogger.LogThis(LOG_ERROR,"failed in mCrypto::Initialize");
		return (FALSE);
	}
	
	std::string strPassword;
	strPassword = mDBOPassword.c_str();
	result = mCrypto.Decrypt(strPassword);
        if (result != 0)
	{
		mLogger.LogThis(LOG_ERROR,"failed in mCrypto::Decrypt");
		return (FALSE);
	}
	wstring wstrdbopassword((wchar_t*)_bstr_t(strPassword.c_str()));

	if ((!FindPairValue("%%DATABASE_NAME%%", dbname)) ||
        (!FindPairValue("%%SERVER_NAME%%", servername)) ||
        (!FindPairValue("%%DBO_LOGON%%", dbologon)) ||
        (!FindPairValue("%%DBO_PASSWORD%%", dbopassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found DB/server name, DBO Logon/Password");
		return (FALSE);
	}

	wstring wstrdbname(dbname.bstrVal);
	wstring wstrservername(servername.bstrVal);
	wstring wstrdbologon(dbologon.bstrVal);

	// initialize the database context
	if (!DBAccess::Init(wstrdbname, 
						wstrservername, 
						wstrdbologon, 
						wstrdbopassword))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Install object");
		return (FALSE);
	}

	// the drop should occur in this order
	// 1) foreign keys
	// 3) stored procedures
	// 4) triggers
	// 5) tables
	// at the end of all this, there should be no remnants of our schema left

	// create the statement to drop the primary, foreign keys & constraints
	// for this, you have to alter the table
	mLogger.LogThis(LOG_INFO, 
					"--- Starting drop of keys (foreign, primary and constraints) ---");
	if (!CreateAndExecuteAlterTableStatement())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute alter table statements");
		return (FALSE);
	}

	// create the statement to drop the sp and triggers 
	mLogger.LogThis(LOG_INFO, 
					"--- Starting drop of sps and triggers ---");
	if (!CreateAndExecuteDropSPsAndTriggers())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute drop sps and triggers");
		return (FALSE);
	}

	// create the statement to drop the tables 
	mLogger.LogThis(LOG_INFO, "--- Starting drop of tables ---");
	if (!CreateAndExecuteDropTables())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute drop tables");
		return (FALSE);
	}

	mLogger.LogThis(LOG_INFO, 
					"--- There should be no remnants of MetraTech left in the DB ---");

	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		return FALSE;
	}

	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_SQLServer::CreateAndExecuteAlterTableStatement()
{
    const char* procName = "CDBInstall_SQLServer::CreateAndExecuteAlterTableStatement";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_ALTER_TABLE_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_ALTER_TABLE_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for selecting alter table statement");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, 
						 "No keys (foreign, primary and constraints) to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing alter table statement");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, 
					 "Done with dropping keys (foreign, primary and constraints)");

	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_SQLServer::CreateAndExecuteDropSPsAndTriggers()
{
    const char* procName = "CDBInstall_SQLServer::CreateAndExecuteDropSPsAndTriggers";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_DROP_SPROC_AND_TRIGGERS_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_DROP_SPROC_AND_TRIGGERS_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for building drop list for sps/triggers");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, "No sps or triggers to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing drop list for sps/triggers");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, "Done with dropping sps and triggers");
	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_SQLServer::CreateAndExecuteDropTables()
{
    const char* procName = "CDBInstall_SQLServer::CreateAndExecuteDropTables";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_DROP_TABLES_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_DROP_TABLES_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for building drop list for tables");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, "No tables to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing drop list tables");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, "Done with dropping tables");
	return (TRUE);
}



//
//
//
void
CDBInstall::PrintInstallParameters ()
{
	string msgbuf;
	string strVal;

	msgbuf = "--------------------------------------------";
	msgbuf += "\n\t";

	TagValuePair::iterator it;
	for (it = mPair.begin(); it != mPair.end(); ++it)
	{
		msgbuf += (it->first).c_str();
		msgbuf += "------->";
		
		_variant_t val = it->second;
		switch (val.vt) 
		{
		    case VT_I4:
			  char strValue[10];
			  _ltoa(val, strValue, 10);
			  msgbuf += strValue;
			  msgbuf += "\n\t";
			  break;

		    case VT_BSTR:
			  strVal = _bstr_t(val);
			  msgbuf += strVal;
			  msgbuf += "\n\t";
			  break;
			  
		    default:
			  mLogger.LogThis(LOG_ERROR, "Invalid Parameter");
			  break;
		}
	}

	msgbuf += "--------------------------------------------";

	mLogger.LogVarArgs(LOG_DEBUG, "<%s>", msgbuf);
	return;
}

DLL_EXPORT
CDBInstall_Oracle::CDBInstall_Oracle(int IsStaging):
  mSALogon(NULL_STR),
	mSAPassword(NULL_STR),
	mDBName(NULL_STR),
	mDataSource(NULL_STR),
	mDBOUser(NULL_STR),
	mDBOPassword(NULL_STR),
	mDataDevLocation(NULL_STR),
	mDataDevSize(0)
{
	Setup(IsStaging);
}

void
CDBInstall_Oracle::Setup(int IsStaging)
{
	mpInstallXmlFileName = ORACLE_DB_INSTALL_XML_FILE;
	mpUninstallXmlFileName = ORACLE_DB_UNINSTALL_XML_FILE;
	mpConfigPath = DB_INSTALL_CONFIG_PATH;
	
  if (IsStaging)
		mpInstallXmlFileName = "StagingDBInstall_Oracle.xml";
}


DLL_EXPORT 
CDBInstall_Oracle::~CDBInstall_Oracle()
{
}

// @mfunc Initialize
// @parm 
// @parm 
// @rdesc 
DLL_EXPORT BOOL
CDBInstall_Oracle::Initialize(const char* salogon,
					   const char* sapassword,
					   const char* dbname,
					   const char* datasourcename,
					   const char* dbouserlogon,
					   const char* dbouserpassword,
             const char* datadeviceloc,
					   long datadevsize,
					   long timeoutvalue)
{
	// local variables
	HRESULT hOK = S_OK;
	BOOL bRetCode = TRUE;

	const char* procName = "CDBInstall_Oracle::Initialize";

  // call CDBInstall::Initialize ...
  if (!CDBInstall::Initialize())
  {
    mLogger.LogThis (LOG_ERROR, "Unable to initialize sql server install.") ;
    return (FALSE) ;
  }
  // assign the values to the data members ...
  mSALogon = salogon ;
  mSAPassword = sapassword ;
  mDBName = dbname ;
  mDataSource = datasourcename ;
  mDBOUser = dbouserlogon ;
  mDBOPassword = dbouserpassword ;
  mDataDevLocation = datadeviceloc ;
  mDataDevSize = datadevsize ;
  mTimeout = timeoutvalue ;

	// start inserting values into the map
	mPair["%%SA_LOGON%%"] = mSALogon.c_str();
	mPair["%%SA_PASSWORD%%"] = mSAPassword.c_str();
	mPair["%%DATABASE_NAME%%"] = mDBName.c_str();
	mPair["%%DATA_SOURCE%%"] = mDataSource.c_str();
	mPair["%%DBO_LOGON%%"] = mDBOUser.c_str();
	mPair["%%DBO_PASSWORD%%"] = mDBOPassword.c_str();
	mPair["%%DATA_DEVICE_LOCATION%%"] = mDataDevLocation.c_str();
	mPair["%%DATA_DEVICE_SIZE%%"] = mDataDevSize;
	mPair["%%TIMEOUT_VALUE%%"] = mTimeout;

	return (TRUE);
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Oracle::InitDbAccess
// Description	  : Initializes the database connection
/////////////////////////////////////////////////////////////////////////////
DLL_EXPORT
BOOL CDBInstall_Oracle::InitDbAccess()
{
  _variant_t datasource;
  _variant_t salogon;
  _variant_t sapassword;
  
  if ((!FindPairValue("%%DATA_SOURCE%%", datasource)) ||
				(!FindPairValue("%%SA_LOGON%%", salogon)) ||
        (!FindPairValue("%%SA_PASSWORD%%", sapassword)))
  {
    mLogger.LogThis(LOG_ERROR,
						"Values not found for SA logon/password & data source");
    return (FALSE);
  }
  
  wstring wstrDataSource(datasource.bstrVal);
  wstring wstrSALogon(salogon.bstrVal);
  wstring wstrSAPassword(sapassword.bstrVal);
  
  // initialize the database context
  // change the hard coding to macro
  if (!DBAccess::InitByDataSource(wstrDataSource, 
    wstrSALogon, 
    wstrSAPassword))
  {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Installation");
    return (FALSE);
  }
  
  return TRUE;
}


//	@mfunc Install
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_Oracle::Install ()
{
	BOOL bRetVal = FALSE;
	// initialize the database connection
	if(InitDbAccess()) 
  {
		// uninstall the database
		ProcessXmlFile(mpUninstallXmlFileName, FALSE);

		// install the database
    bRetVal = ProcessXmlFile(mpInstallXmlFileName);
	}
	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}

//	@mfunc Install_withoutDropDB
// 	@parm  
//  @rdesc Builds the query required for installing a database, before first dropping it
//  executing it.
DLL_EXPORT BOOL
CDBInstall_Oracle::Install_withoutDropDB ()
{
	BOOL bRetVal = FALSE;
	// initialize the database connection
	if(InitDbAccess()) 
  {
    // install the database
		bRetVal = ProcessXmlFile(mpInstallXmlFileName);
	}
	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}

BOOL CDBInstall_Oracle::Uninstall()
{
// initialize the database connection
	BOOL bRetVal = FALSE;


	if(InitDbAccess()) 
  {
		bRetVal = ProcessXmlFile(mpUninstallXmlFileName);
	}

	// disconnect from the database
	DisconnectDatabase();

  return bRetVal;
}





//	@mfunc AddTablespace
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_Oracle::AddTablespace()
{
	// get the parameters required for Init
	_variant_t datasource;
	_variant_t salogon;
	_variant_t sapassword;

	if ((!FindPairValue("%%DATA_SOURCE%%", datasource)) ||
        (!FindPairValue("%%SA_LOGON%%", salogon)) ||
        (!FindPairValue("%%SA_PASSWORD%%", sapassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found data source, DBO Logon/Password");
		return (FALSE);
	}

	wstring wstrDataSource(datasource.bstrVal);
	wstring wstrSALogon(salogon.bstrVal);
	wstring wstrSAPassword(sapassword.bstrVal);

	// initialize the database context
	if (!DBAccess::InitByDataSource(wstrDataSource, 
						wstrSALogon, 
						wstrSAPassword))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Install object");
		return (FALSE);
	}

	BOOL bRetVal = ProcessXmlFile(ORACLE_ADD_TABLESPACE_XML_FILE);

	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		bRetVal = FALSE;
	}

	return (bRetVal);
}

//	@mfunc InstallDBObjects
// 	@parm  
//  @rdesc Builds the query required for dropping the database and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_Oracle::InstallDBObjects()
{
	// get the parameters required for Init
	_variant_t datasource;
	_variant_t dbologon;
	_variant_t dbopassword;

	if ((!FindPairValue("%%DATA_SOURCE%%", datasource)) ||
        (!FindPairValue("%%DBO_LOGON%%", dbologon)) ||
        (!FindPairValue("%%DBO_PASSWORD%%", dbopassword)))
	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found data source, DBO Logon/Password");
		return (FALSE);
	}

	wstring wstrDataSource(datasource.bstrVal);
	wstring wstrDBOLogon(dbologon.bstrVal);
	wstring wstrDBOPassword(dbopassword.bstrVal);

	// initialize the database context
	if (!DBAccess::InitByDataSource(wstrDataSource, 
						wstrDBOLogon, 
						wstrDBOPassword))
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Install object");
		return (FALSE);
	}

	// loop through all the install set
	RCDLib::IMTRcdPtr aRcd(MTPROGID_RCD);
	char buff[MAX_PATH];
	sprintf(buff,"%s%s",(const char*)aRcd->GetConfigDir(),DB_INSTALL_CONFIG_PATH);
	BOOL bRetVal =  ExecuteQueries(buff,ORACLE_DB_OBJECTS_XML_FILE);

	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		bRetVal = FALSE;
	}

	return (bRetVal);
}

CDBInstall_Extension::CDBInstall_Extension(const char* pDirectory,const char* pInstallFile,const char* pUninstallFile)  
: mDirectory(pDirectory), mInstallFileName(pInstallFile), mUninstallFileName(pUninstallFile)
{
	mpConfigPath = pDirectory;

}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Extension::Initialize
// Description	    : Initialize the query adapter and other stuff in the base class
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall_Extension::Initialize()
{
  // call CDBInstall::Initialize
  if (!CDBInstall::Initialize())
  {
    mLogger.LogThis (LOG_ERROR, "Unable to initialize sql server install.") ;
    return FALSE;
  }
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Extension::InitDbAccess
// Description	    : Initialize the database connection
/////////////////////////////////////////////////////////////////////////////
DLL_EXPORT
BOOL CDBInstall_Extension::InitDbAccess()
{
	wstring aTempStr;
	ASCIIToWide(aTempStr, mDirectory.c_str());
	if(!DBAccess::Init(aTempStr)) {
    SetError(DBAccess::GetLastError());
    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Owner object");
    return (FALSE);
	}
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Extension::InstallDBObjects
// Description	    : Execute the queries
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall_Extension::InstallDBObjects()
{
	BOOL bRetVal = InitDbAccess();
	if(bRetVal) {

		bRetVal =  ExecuteQueries(mDirectory.c_str(),mInstallFileName.c_str());

		// disconnect from the database
		if (!DBAccess::Disconnect())
		{
			SetError(DBAccess::GetLastError());
			mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
			bRetVal = FALSE;
		}
	}
	return bRetVal;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Extension::Install
// Description	    : Simply calls through to InstallDBObjects
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall_Extension::Install()
{
	return InstallDBObjects();
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CDBInstall_Extension::Uninstall
// Description	    : Uninstalls via the uninstall file
/////////////////////////////////////////////////////////////////////////////

BOOL CDBInstall_Extension::Uninstall()
{

	BOOL bRetVal = InitDbAccess();
	if(bRetVal) {
		bRetVal =  ExecuteQueries("",mUninstallFileName.c_str());

		// disconnect from the database
		if (!DBAccess::Disconnect())
		{
			SetError(DBAccess::GetLastError());
			mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
			bRetVal = FALSE;
		}
	}
	return bRetVal;

}





//	@mfunc DropDBObjects
// 	@parm  
//  @rdesc Builds the query required for dropping the database objects and then
//  executing it.
DLL_EXPORT BOOL
CDBInstall_Oracle::DropDBObjects()
{
	// get the parameters required for Init
	_variant_t datasource;
	_variant_t dbologon;
	_variant_t dbopassword;
    
	string decryptedUserPwd;

	// need to decrypt the password before doing database init.

	// encryption object

  CMTCryptoAPI mCrypto;
	int result;
	result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, "mt_dbaccess", TRUE, "dbaccess");
        if (result != 0)
	{
		mLogger.LogThis(LOG_ERROR,"failed in mCrypto::Initialize");
		return (FALSE);
	}
	
	string strPassword;
	strPassword = mDBOPassword.c_str();
	result = mCrypto.Decrypt(strPassword);
        if (result != 0)
	{
		mLogger.LogThis(LOG_ERROR,"failed in mCrypto::Decrypt");
		return (FALSE);
	}
	//PrintInstallParameters();

	if ((!FindPairValue("%%DATA_SOURCE%%", datasource)) ||
        (!FindPairValue("%%DBO_LOGON%%", dbologon)) ||
        (!FindPairValue("%%DBO_PASSWORD%%", dbopassword)))
  	{
		mLogger.LogThis(LOG_ERROR, 
						"Values not found DB/server name, DBO Logon/DBO Password");
		return (FALSE);
	}


	wstring wstrdatasource(datasource.bstrVal);
	wstring wstrdbologon(dbologon.bstrVal);
	wstring wstrdbopassword((wchar_t*)_bstr_t(strPassword.c_str()));

	// initialize the database context
	if (!DBAccess::InitByDataSource(wstrdatasource, 
						wstrdbologon, 
						wstrdbopassword))  
	{
		SetError(DBAccess::GetLastError());
	    mLogger.LogThis(LOG_ERROR,
						"Database initialization failed for Database Install object");
		return (FALSE);
	}

	// the drop should occur in this order
	// 1) foreign keys
	// 3) stored procedures
	// 4) triggers
	// 5) tables
	// at the end of all this, there should be no remnants of our schema left

	// create the statement to drop the primary, foreign keys & constraints
	// for this, you have to alter the table
	mLogger.LogThis(LOG_INFO, 
					"--- Starting drop of keys (foreign, primary and constraints) ---");
	if (!CreateAndExecuteAlterTableStatement())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute alter table statements");
		return (FALSE);
	}

	// create the statement to drop the sp and triggers 
	mLogger.LogThis(LOG_INFO, 
					"--- Starting drop of sps and triggers ---");
	if (!CreateAndExecuteDropSPsAndTriggers())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute drop sps and triggers");
		return (FALSE);
	}

	// create the statement to drop the tables 
	mLogger.LogThis(LOG_INFO, "--- Starting drop of tables ---");
	if (!CreateAndExecuteDropTables())
	{
		mLogger.LogThis(LOG_ERROR, "Cannot create and execute drop tables");
		return (FALSE);
	}

	mLogger.LogThis(LOG_INFO, 
					"--- There should be no remnants of MetraTech left in the DB ---");

	// disconnect from the database
	if (!DBAccess::Disconnect())
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, "Database disconnect failed");
		return FALSE;
	}

	return (TRUE);
}


//
//
//
DLL_EXPORT BOOL
CDBInstall_Oracle::CreateAndExecuteAlterTableStatement()
{
    const char* procName = "CDBInstall_Oracle::CreateAndExecuteAlterTableStatement";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_ALTER_TABLE_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_ALTER_TABLE_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for selecting alter table statement");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, 
						 "No keys (foreign, primary and constraints) to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing alter table statement");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, 
					 "Done with dropping keys (foreign, primary and constraints)");

	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_Oracle::CreateAndExecuteDropSPsAndTriggers()
{
    const char* procName = "CDBInstall_Oracle::CreateAndExecuteDropSPsAndTriggers";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_DROP_SPROC_AND_TRIGGERS_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_DROP_SPROC_AND_TRIGGERS_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for building drop list for sps/triggers");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, "No sps or triggers to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing drop list for sps/triggers");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, "Done with dropping sps and triggers");
	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_Oracle::CreateAndExecuteDropTables()
{
    const char* procName = "CDBInstall_Oracle::CreateAndExecuteDropTables";
	
	// get the query
	_bstr_t queryTag;
	_bstr_t queryString;
	DBSQLRowset rowset;
	wstring langRequest;
	
	try
	{
	    mpQueryAdapter->ClearQuery();
		queryTag = "__CREATE_DROP_TABLES_STATEMENT__";
		mpQueryAdapter->SetQueryTag(queryTag);

		langRequest = mpQueryAdapter->GetQuery();
	}
	catch (_com_error& e)
	{
	    SetError (e.Error(), ERROR_MODULE, ERROR_LINE, procName, 
				  "Unable to get query for __CREATE_DROP_TABLES_STATEMENT__");
		mLogger.LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	if (!DBAccess::Execute(langRequest, rowset))
	{
		SetError(DBAccess::GetLastError());
		mLogger.LogThis(LOG_ERROR, 
						"Database execution failed for building drop list for tables");
		return (FALSE);
	}
	
	if (rowset.GetRecordCount() == 0)
	{
		mLogger.LogThis (LOG_INFO, "No tables to be dropped");
		return (TRUE);
	}

	// Parse the record set
  	BOOL bOK = TRUE ;
	string rwstrName;
	wstring wstrName;
	ObjectNameList objectnamelist;

	while ((!rowset.AtEOF()) && (bOK == TRUE))
	{
	    // no need to cast to variant
		rowset.GetCharValue("statement", rwstrName);

		// 
		wstrName = (const wchar_t*)_bstr_t(rwstrName.c_str());

		// Fill up the hash dictionary 
		objectnamelist.insert(objectnamelist.begin(),wstrName);

		// Move to next record
		bOK = rowset.MoveNext();
	}
	
	// once the list is built, we need to execute it
	ObjectNameListIterator itr;
	for (itr = objectnamelist.begin(); itr != objectnamelist.end(); ++itr)
	{
	  langRequest = (*itr).c_str();
	  _bstr_t bstrLangRequest = langRequest.c_str();
	  mLogger.LogVarArgs (LOG_DEBUG, "Executing <%s>", (const char*) bstrLangRequest) ;
	  
	  if (!DBAccess::Execute(langRequest, rowset))
		{
		  SetError(DBAccess::GetLastError());
		  mLogger.LogThis(LOG_ERROR, 
						  "Database execution failed for executing drop list tables");
		  return (FALSE);
		}
	}

	mLogger.LogThis (LOG_INFO, "Done with dropping tables");
	return (TRUE);
}


//
//
//
DLL_EXPORT BOOL
CDBInstall_Extension::CreateAndExecuteAlterTableStatement()
{
	return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_Extension::CreateAndExecuteDropSPsAndTriggers()
{
  return (TRUE);
}

//
//
//
DLL_EXPORT BOOL
CDBInstall_Extension::CreateAndExecuteDropTables()
{
  return (TRUE);
}

DLL_EXPORT BOOL
CDBInstall_Extension::DropDBObjects()
{
  return (TRUE);
}
