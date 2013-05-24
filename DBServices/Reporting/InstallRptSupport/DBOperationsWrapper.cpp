#include "InstallRptSupport.h"

DBOperationsWrapper::~DBOperationsWrapper()
{
	/*
	if(mpInstallExt)
	{
		delete mpInstallExt;
		mpInstallExt = NULL;
	}
	*/
}


BOOL DBOperationsWrapper::InitDbAccess(Params aParams)
{
	BOOL ret = FALSE;
	string asciiDBS, asciiDBType, asciiDBName, asciiDBUser, asciiDBPassword;
	wstring DBS, DBType, DBName, DBUser, DBPassword, mssql;
	asciiDBS = aParams.GetServerOrDSNName();
	asciiDBType = aParams.GetDBType();
	asciiDBName = aParams.GetDBName();
	asciiDBUser = aParams.GetUserName();
	asciiDBPassword = aParams.GetPassword();

	ASCIIToWide(DBS, asciiDBS);
	ASCIIToWide(DBType, asciiDBType);
	ASCIIToWide(DBName, asciiDBName);
	ASCIIToWide(DBUser, asciiDBUser);
	ASCIIToWide(DBPassword, asciiDBPassword);

	
	//Determine by DB TYPE whether we are using
	//ODBC source to connect or not
	ASCIIToWide(mssql, MSSQL_DB_TYPE);
	if (_wcsicmp(DBType.c_str(), mssql.c_str()) == 0)
		return mDBAccess.Init(DBName, DBS, DBUser, DBPassword);
	else
		return mDBAccess.InitByDataSource(DBS, DBUser, DBPassword);
	
}

BOOL DBOperationsWrapper::InitDbAccess(const char* aConfigDir)
{
	wstring rws, wideConfigDir;
	ASCIIToWide(rws, aConfigDir);
	ASCIIToWide(wideConfigDir, mConfigDir);
	wstring tempStr = wideConfigDir + rws;
	if(!mDBAccess.Init(tempStr)) 
	{
		return (FALSE);
	}
	return TRUE;
}


BOOL DBOperationsWrapper::InitQueryAdapter(const char* aConfigPath)
{
	string rws = aConfigPath;
	mDirectory = aConfigPath;
	// instantiate a query adapter object
  try
  {
    // create the queryadapter ...
    IMTQueryAdapterPtr queryAdapter(MTPROGID_QUERYADAPTER);
    
    // initialize the queryadapter ...
    queryAdapter->Init(_bstr_t(mConfigDir.c_str()) + aConfigPath);
    
    // extract and detach the interface ptr ...
    mpQueryAdapter = queryAdapter.Detach();
  }
  catch (_com_error& e)
  {
	  std::cout << "ERROR: " << (const char *)e.Description() << endl;
		return FALSE;
  }
	return TRUE;
}


BOOL DBOperationsWrapper::ExecuteQueries()
{
	
	HRESULT hr=S_OK;
	VARIANT_BOOL checksumMatch;
	MTConfigLib::IMTConfigPropSetPtr propSet;
	MTConfigLib::IMTConfigPropPtr queryTag;
	_bstr_t langRequest;
	_bstr_t tag;
	_bstr_t fullPath =	_bstr_t(mConfigDir.c_str()) + 
											mDirectory.c_str() + 
											L"\\" + 
											mInstallFileName.c_str();
	
	try
	{
		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
		// read the configuration file ...
		//
		propSet = config->ReadConfiguration(fullPath,
																&checksumMatch);
	}
	catch (_com_error& e)
	{
		std::cout << "DEBUG: No reporting related DB objects will be installed from "<<(const char *)fullPath<<endl;
		std::cout << "DEBUG: ("<<(const char *)e.Description()<<" )"<<endl;
		return TRUE;
	}
	try
	{
		if (propSet == NULL)
		{
			std::cout << "ERROR:	Couldn't create PropSet" << endl;
			return FALSE;
		}
		
		
		while ((queryTag = propSet->NextWithName(QUERY_TAG)) != NULL)
		{
			mpQueryAdapter->ClearQuery();
			tag  = queryTag->GetValueAsString();
      std::cout<<(const char *)"Executing "<<std::string((char*)tag).c_str()<<" query."<<endl;
			mpQueryAdapter->SetQueryTag(tag);
			langRequest = mpQueryAdapter->GetQuery();
			
			// execute the language request
			if (!mDBAccess.Execute((wchar_t*)langRequest))
			{
				//HACK:
				// We want to mask error message and continue if we tried to drop a non-existant
				//database object. Error message will be printed to sterr and to a log file anyway
				if (wcscspn((const wchar_t*)tag, L"DROP") <= wcslen((const wchar_t*)tag)-4)
				{
					std::cout << "DEBUG: Failed to drop DB object, it probably doesn't exist." << endl;
				}
				else
				{
					std::cout << "DBAccess failed to execute query" << endl;
					return FALSE;
				}
			}
		}
		
	}
	catch (_com_error& e)
	{
		std::cout << "ERROR: " << (const char *)e.Description()<<endl;
		return FALSE;
	}

	return TRUE;
}




