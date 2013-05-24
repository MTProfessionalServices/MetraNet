#pragma warning(disable:4786)

#include <mtcom.h>
#include <comdef.h>
#include <iostream>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <stdutils.h>
#include <DBAccess.h>
#include <DBInstall.h>
#include <map>
#include <string>
#include <ConfigDir.h>

#define EXE_NAME	"InstallRptSupport"
#define DBS_PARAM	"-rs"
#define DB_PARAM	"-rdbn"
#define DB_TYPE_PARAM	"-rdbt"
#define DB_USER_PARAM	"-rdbu"
#define DB_PASSWORD_PARAM	"-rdbp"
#define HELP_PARAM "-help"

#define	DEFAULT_DBS	"local"
#define	DEFAULT_DB	"NetMeter"
#define	DEFAULT_DB_TYPE	"MSSQL"
#define	DEFAULT_DB_USER	"nmdbo"
#define	DEFAULT_DB_PASSWORD	"nmdbo"

#define QUERY_TAG L"query"

#define	INSTALL_POPULATING_QUERIES_DIR "\\Queries\\Reporting\\PopulateReportingDBObjects"
#define	INSTALL_DATAMART_QUERIES_DIR "\\Queries\\Reporting\\InstallReportingDBObjects"

#define	QUERY_LIST_FILE_NAME "QueryList.xml"

#define MSSQL_DB_TYPE	"MSSQL"
#define ORACLE_DB_TYPE	"ORACLE"

using namespace std;

// import the usage server tlb ...
#import <ReportingInfo.tlb> 
using namespace REPORTINGINFOLib ;

#import "QueryAdapter.tlb" rename("GetUserName", "QAGetUserName") no_namespace

#import <ReportingInfo.tlb> 
using namespace REPORTINGINFOLib ;

#import "MTConfigLib.tlb"


using namespace std;

typedef map<string, string> ParamMap;

class Params
{

public:
  Params() : mDBS("local"), mDBName("NetMeter"), mDBType("MSSQL"), mUserName("nmdbo"), mPassword("nmdbo")  {} ;
  ~Params() {} ;

  BOOL ParseArgs(int argc, char * argv[]) ;
  const string GetServerOrDSNName() const
  { return mDBS; } ;
  const string GetDBName() const 
  { return mDBName; } ;
	const string GetDBType() const 
  { return mDBType; } ;
  const string GetUserName() const
  { return mUserName ; } ;
  const string GetPassword() const
  { return mPassword ; } ;
private:
  void PrintUsage() ;

  string mDBS, mDBName, mDBType, mUserName, mPassword;
} ;



class DBOperationsWrapper
{

public:
	DBOperationsWrapper() : mInstallFileName(QUERY_LIST_FILE_NAME)
	{
		GetMTConfigDir(mConfigDir);
	};
	~DBOperationsWrapper();
	BOOL InitQueryAdapter(const char* aConfigPath);
	BOOL InitDbAccess(const char* aConfigPath);
	BOOL InitDbAccess(Params aParams);
	BOOL ExecuteQueries();

private:
	DBAccess mDBAccess;
	IMTQueryAdapter* mpQueryAdapter;
	
	string	mInstallFileName;
	string	mDirectory;
	string mConfigDir;
	
	//CDBInstall_Extension* mpInstallExt;
  
};