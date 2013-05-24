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
 * 	DBInstall.h : 
 *	-----------
 *	This is the header file of the DBInstall class.
 *
 ***************************************************************************/

#ifndef _DBINSTALL_H_
#define _DBINSTALL_H_


//	All the includes
#include <SharedDefs.h>
#include <NTThreadLock.h>
#include <errobj.h>
#include <DBAccess.h>
#include <NTLogger.h>
#include <NTLogMacros.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtparamnames.h>

using namespace std;
// typedef the lists
typedef list<wstring> ObjectNameList;
typedef list<wstring>::iterator ObjectNameListIterator;

// map of object type to list of objectName 
typedef map<string, ObjectNameList> TypeObjectNameListMap;
typedef map<string, ObjectNameList>::iterator ObjectNameListMapIterator;

// import the query adapter tlb
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")
using namespace QUERYADAPTERLib;

// import the configloader tlb file
#import <MTConfigLib.tlb>
using namespace MTConfigLib;

typedef map<string, _variant_t> TagValuePair;


extern "C" DLL_EXPORT LONG WINAPI InstallDatabase();

class CDBInstall : 
  public virtual ObjectWithError,
  public DBAccess
{
public:
  // @cmember Constructor
  DLL_EXPORT CDBInstall();
  
  // @cmember Destructor
  DLL_EXPORT virtual ~CDBInstall();

  // default methods for database install ...
  DLL_EXPORT virtual BOOL Install () = 0;
  DLL_EXPORT virtual BOOL Uninstall() = 0;
  DLL_EXPORT virtual BOOL InstallDBObjects () = 0;
  DLL_EXPORT virtual BOOL DropDBObjects () = 0;
  DLL_EXPORT virtual BOOL CreateAndExecuteAlterTableStatement() = 0;
  DLL_EXPORT virtual BOOL CreateAndExecuteDropSPsAndTriggers() = 0;
  DLL_EXPORT virtual BOOL CreateAndExecuteDropTables() = 0;

protected:
  virtual BOOL InitDbAccess() = 0;
  BOOL Initialize() ;
  BOOL ProcessInstallset(IMTConfigPropSetPtr);
  BOOL DisconnectDatabase();
  void PrintInstallParameters ();
  BOOL ProcessXmlFile(const char* pInstallFile, const BOOL bReturnOnFailure=TRUE);
	BOOL ExecuteQueries(const char* pPath,const char* pFile);

	BOOL FindPairValue(const char * apName, _variant_t & arValue);

  TagValuePair mPair;
  NTLogger mLogger;
  long mTimeout;
	const char* mpInstallXmlFileName;
	const char* mpUninstallXmlFileName;
	const char* mpConfigPath;
  
  QUERYADAPTERLib::IMTQueryAdapterPtr mpQueryAdapter;
	MTConfigLib::IMTConfigPtr mpConfig;
private:

  // Copy Constructor
  CDBInstall(const CDBInstall& C) {} ;	
  
  // Assignment operator
  const CDBInstall& CDBInstall::operator=(const CDBInstall& rhs) {} ;
};

class CDBInstall_SQLServer : 
public CDBInstall
{
public:
    
  // @cmember Constructor
  DLL_EXPORT CDBInstall_SQLServer(int IsStaging);
  
  // @cmember Destructor
  DLL_EXPORT virtual ~CDBInstall_SQLServer();
  
  // default methods for database install ...
  DLL_EXPORT virtual BOOL Install ();
  DLL_EXPORT virtual BOOL Install_withoutDropDB ();
  DLL_EXPORT virtual BOOL Uninstall();
  DLL_EXPORT virtual BOOL InstallDBObjects ();
  DLL_EXPORT BOOL ChangeDBOwner ();
  DLL_EXPORT BOOL DropDBOwner ();

  // stuff added for building lists of objects to be dropped
  DLL_EXPORT virtual BOOL DropDBObjects ();
  DLL_EXPORT virtual BOOL CreateAndExecuteAlterTableStatement();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropSPsAndTriggers();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropTables();
  DLL_EXPORT virtual BOOL InitDbAccess() ;
  
  // @cmember Initialize the CDBInstall_SQLServer object
  DLL_EXPORT BOOL Initialize(const char* salogon,
    const char* sapassword,
    const char* dbname,
    const char* servername,
    const char* dbouserlogon,
    const char* dbouserpassword,
    const char* datadevicename,
    const char* datadeviceloc,
//    long datadevvdev,
//    long datadevsize2K,
    long datadevsizemeg,
    const char* logdevicename,
    const char* logdeviceloc,
//    long logdevvdev,
//    long logdevsize2K,
    long logdevsizemeg,
    const char* datadumpdevfile,
    const char* logdumpdevfile,
    long timeoutvalue);
  
  //	Accessors
  const string& GetSALogon() const { return mSALogon; } 
  const string& GetSAPassword() const { return mSAPassword; } 
  const string& GetDatabaseName() const { return mDatabaseName; } 
  const string& GetServerName() const { return mServerName; } 
  const string& GetDBOLogon() const { return mDBOLogon; } 
  const string& GetDBOPassword() const { return mDBOPassword; } 
  const string& GetDataDeviceName() const { return mDataDeviceName; } 
  const string& GetDataDeviceLocation() const { return mDataDeviceLocation; } 
  long GetDataDeviceSize() const { return mDataDeviceSize; } 
  const string& GetLogDeviceName() const { return mLogDeviceName; } 
  const string& GetLogDeviceLocation() const { return mLogDeviceLocation; } 
  long GetLogDeviceSize() const { return mLogDeviceSize; } 
  const string& GetDataDumpDeviceFile() const { return mDataDumpDeviceFile; } 
  const string& GetLogDumpDeviceFile() const { return mLogDumpDeviceFile; } 
  long GetTimeoutValue() const { return mTimeout; } 
  
  //	Mutators
  void SetSALogon(const char* SALogon)
  { mSALogon = SALogon; } 
  void SetSAPassword(const char* SAPassword)
  { mSAPassword = SAPassword; } 
  void SetDatabaseName(const char* DatabaseName)
  { mDatabaseName = DatabaseName; } 
  void SetServerName(const char* ServerName)
  { mServerName = ServerName; } 
  void SetDBOLogon(const char* DBOLogon)
  { mDBOLogon = DBOLogon; } 
  void SetDBOPassword(const char* DBOPassword)
  { mDBOPassword = DBOPassword; } 
  
  void SetDataDeviceName(const char* DataDeviceName)
  { mDataDeviceName = DataDeviceName; } 
  void SetDataDeviceLocation(const char* DataDeviceLocation)
  { mDataDeviceLocation = DataDeviceLocation; } 
  void SetDataDeviceSize(const long DataDeviceSize)
  { mDataDeviceSize = DataDeviceSize; } 
  
  void SetLogDeviceName(const char* LogDeviceName)
  { mLogDeviceName = LogDeviceName; } 
  void SetLogDeviceLocation(const char* LogDeviceLocation)
  { mLogDeviceLocation = LogDeviceLocation; } 
  void SetLogDeviceSize(const long LogDeviceSize)
  { mLogDeviceSize = LogDeviceSize; } 
  
  void SetDataDumpDeviceFile(const char* DataDumpDeviceFile)
  { mDataDumpDeviceFile = DataDumpDeviceFile; } 
  void SetLogDumpDeviceFile(const char* LogDumpDeviceFile)
  { mLogDumpDeviceFile = LogDumpDeviceFile; }
  
  void SetTimeoutValue(const long TimeoutValue)
  { mTimeout = TimeoutValue; } 
  
  
private:
  
  // Copy Constructor
  CDBInstall_SQLServer (const CDBInstall_SQLServer& C) {} ;	
  
  // Assignment operator
  const CDBInstall_SQLServer& CDBInstall_SQLServer::operator=(const CDBInstall_SQLServer& rhs) {} ;
  
  string mSALogon;
  string mSAPassword;
  string mDatabaseName; 
  string mServerName;
  string mDBOLogon;
  string mDBOPassword;
  string mDataDeviceName;
  string mDataDeviceLocation;
  long mDataDeviceSize;
  string mLogDeviceName;
  string mLogDeviceLocation;
  long mLogDeviceSize;
  string mDataDumpDeviceFile;
  string mLogDumpDeviceFile;
};


class CDBInstall_Oracle : 
public CDBInstall
{
public:
    
  // @cmember Constructor
  //DLL_EXPORT CDBInstall_Oracle();
  DLL_EXPORT CDBInstall_Oracle(int IsStaging = 0);
  
  // @cmember Destructor
  DLL_EXPORT virtual ~CDBInstall_Oracle();
  
  // default methods for database install ...
  DLL_EXPORT virtual BOOL Install ();
  DLL_EXPORT virtual BOOL Install_withoutDropDB ();
  DLL_EXPORT virtual BOOL Uninstall();
  DLL_EXPORT virtual BOOL InstallDBObjects ();


  // stuff added for building lists of objects to be dropped
  DLL_EXPORT virtual BOOL DropDBObjects ();
  DLL_EXPORT virtual BOOL CreateAndExecuteAlterTableStatement ();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropSPsAndTriggers();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropTables();
  
  
  // @cmember Initialize the CDBInstall_Oracle object
  DLL_EXPORT BOOL Initialize(const char* salogon, const char* sapassword,
    const char* dbname, const char* datasourcename, const char* dbouserlogon,
    const char* dbouserpassword, const char* datadeviceloc, long datadevsize,
    long timeoutvalue);
  DLL_EXPORT BOOL AddTablespace() ;
  DLL_EXPORT virtual BOOL InitDbAccess() ;

private:
  
  // Copy Constructor
  CDBInstall_Oracle (const CDBInstall_Oracle& C) {} ;	
  
  // Assignment operator
  const CDBInstall_Oracle& CDBInstall_Oracle::operator=(const CDBInstall_Oracle& rhs) {} ;
  
  // Internal setup
  void Setup(int mIsStaging);
  
  string mSALogon;
  string mSAPassword;
  string mDBName; 
  string mDataSource;
  string mDBOUser;
  string mDBOPassword;
  string mDataDevLocation;
  long mDataDevSize;
};

/////////////////////////////////////////////////////////////////////////////
// CDBInstall_Extension
//
// Provides a mechanism to iterate through a queries file and execute 
// the SQL statements.
/////////////////////////////////////////////////////////////////////////////

class CDBInstall_Extension : public CDBInstall
{
public:
	
	DLL_EXPORT CDBInstall_Extension(const char* pDirectory,const char* pInstallFile,const char* pUninstallFile);
	DLL_EXPORT virtual ~CDBInstall_Extension() {}

	// default methods for database install.  Since an extension does not acutally
	// set up the database, these methods don't do anything
  DLL_EXPORT virtual BOOL Install();
  DLL_EXPORT virtual BOOL Uninstall();

	// the method that executes the queries
  DLL_EXPORT virtual BOOL InstallDBObjects ();

	// initializes 
	DLL_EXPORT BOOL Initialize();
	DLL_EXPORT virtual BOOL DropDBObjects ();
	DLL_EXPORT virtual BOOL CreateAndExecuteAlterTableStatement ();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropSPsAndTriggers();
  DLL_EXPORT virtual BOOL CreateAndExecuteDropTables();
  DLL_EXPORT virtual BOOL InitDbAccess();

private:
	// don't want to compiler to generate these functions
  CDBInstall_Extension (const CDBInstall_Extension& C);
  const CDBInstall_Extension& CDBInstall_Extension::operator=(const CDBInstall_Extension& rhs);

protected:
	string mDirectory;
	string mInstallFileName;
	string mUninstallFileName;

};

#endif //_DBINSTALL_H_

