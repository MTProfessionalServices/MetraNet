#include "InstallRptSupport.h"

void Params::PrintUsage()
{
	std::cout	<< endl << "Usage: " <<	EXE_NAME	<< " [options]"<<endl<<endl
				<< "Options:" <<endl<<endl
				<<	HELP_PARAM << "\t[Prints this message]" << endl
				<<	DBS_PARAM << "\t[Reporting server or data source name" <<endl
				<<	DB_PARAM << "\t[Reporting database name (Default: \"Netmeter\")]"<<endl
				<<	DB_TYPE_PARAM << "\t[Reporting database type - MSSQL | ORACLE (Default: \"MSSQL\")]"<<endl
				<<	DB_USER_PARAM << "\t[Reporting database user name (Default: \"nmdbo\")]"<<endl
				<<	DB_PASSWORD_PARAM << "\t[Reporting database user password (Default: \"nmdbo\")]"<<endl<<endl
				<< "Note:" <<endl
				<< "If "<<DB_TYPE_PARAM<<" is MSSSQL, then "<<DBS_PARAM<<" is always assumed to be server name."<<endl
				<< ", if "<<DB_TYPE_PARAM<<" is ORACLE, then "<<DBS_PARAM<<" is always assumed to be ODBC DSN"<<endl;
  return ;
}

BOOL Params::ParseArgs(int argc, char * argv[])
{
  

	int i ;
  string Key ;
	string Value ;
	ParamMap params;
	ParamMap::iterator it;
  
  for (i=1; i < argc ; i++)
  {
    Key = string(_strlwr(argv[i]));
		if (i + 1 < argc)
    {
			i++ ;
      Value = argv[i] ;
    }
		params[Key] = string(Value);
	}
	//if HELP_PARAM found, just print usage
	if ((it = params.find(HELP_PARAM)) != params.end())
  {
		PrintUsage();
		return FALSE;
  }
	
	//Find parameters in the map
	//or set defaults
	if ((it = params.find(DBS_PARAM)) != params.end())
  {
		mDBS = (*it).second;
  }
  else
  {
		PrintUsage();
		return FALSE;
	}
		
	if ((it = params.find(DB_PARAM)) != params.end())
	{
		mDBName = (*it).second;
	}
	else
	{
		mDBName = DEFAULT_DB;
	}
		
	if ((it = params.find(DB_TYPE_PARAM)) != params.end())
  {
		mDBType = (*it).second;
		if(	_stricmp(mDBType.c_str(), MSSQL_DB_TYPE) != 0 &&
				_stricmp(mDBType.c_str(), ORACLE_DB_TYPE) != 0)
		{
			std::cout << "Unknown DB Type: "<< mDBType.c_str()<<endl;
			return FALSE;
		}

  }
  else
  {
		mDBType = DEFAULT_DB_TYPE;
  }
    
  if ((it = params.find(DB_USER_PARAM)) != params.end())
  {
		mUserName = (*it).second;
  }
  else
  {
		mUserName = DEFAULT_DB_USER;
  }
		
	if ((it = params.find(DB_PASSWORD_PARAM)) != params.end())
  {
		mPassword = (*it).second;
  }
  
	else
  {
		mPassword = DEFAULT_DB_PASSWORD;
  }

	return TRUE ;
}


int main(int argc, char* argv[])
{
  // parse the args ...
	int OK = 0;
	int FAIL = 1;
	Params args;
	DBOperationsWrapper dbops;

  if (!args.ParseArgs(argc, argv))
  {
    return OK;
  }

  std::cout	<<	"DEBUG:	Reporting DB parameters:" << endl
				<<	"\tReporting DB Server Name: " << args.GetServerOrDSNName().c_str() << endl
				<<	"\tReporting DB  Name: " << args.GetDBName().c_str() << endl
				<<	"\tReporting DB  Type: " << args.GetDBType().c_str() << endl
				<<	"\tReporting DB  User Name: " << args.GetUserName().c_str() << endl
				<<	"\tReporting DB  Password: " << args.GetPassword().c_str() << endl;

	::CoInitializeEx(NULL, COINIT_MULTITHREADED);

//do not install views or stored procs
#if 0
	//First install reporting views on local NetMeter
	// create the reporting view ...
	try
	{
		cout << "DEBUG:	Installing Reporting Views."<<endl;
		REPORTINGINFOLib::IMTReportingViewPtr reportingView(MTPROGID_REPORTINGVIEW);
		reportingView->Add();
		cout << "Done."<<endl;
	}
	catch(_com_error& e)
	{
		cout << "ERROR: " << e.Description() << endl;
		return FAIL;
	}

	//initialize QueryAdapter and DataAccess to queries\Reporting\PopulateReportingDBObjects
	//and install stored procs needed to update reporting data marts
	cout << "DEBUG:	Installing Populate Reporting Data Marts Stored Procedure on local server, NetMeter db."<<endl;
	if(	!dbops.InitDbAccess(INSTALL_POPULATING_QUERIES_DIR) ||
			!dbops.InitQueryAdapter(INSTALL_POPULATING_QUERIES_DIR) ||
			!dbops.ExecuteQueries())
		return FAIL;
	cout << "Done."<<endl;
#endif
	//Now reinitialize QueryAdapter and DataAccess to reporting server/database
	//and install reporting datamarts
	std::cout << "DEBUG:	Installing Reporting Data Marts Queries on "<<args.GetServerOrDSNName().c_str()<<endl;
	if(	!dbops.InitDbAccess(args) ||
			!dbops.InitQueryAdapter(INSTALL_DATAMART_QUERIES_DIR) ||
			!dbops.ExecuteQueries())
		return FAIL;
	std::cout << "Done."<<endl;
	
	






	return 0;
}

