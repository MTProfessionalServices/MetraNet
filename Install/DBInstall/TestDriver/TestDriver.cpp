
/**************************************************************************
* @doc TEST
*
* Copyright 1998 by MetraTech Corporation
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech Corporation MAKES NO
* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech Corporation,
* and USER agrees to preserve the same.
*
* Created by: Raju Matta (for the Kiosk module)
*
* Modified by:
*
* $Header$
***************************************************************************/

#pragma warning( disable : 4786 )

#include <mtcom.h>
#include <comdef.h>
#include <windows.h>
#include <iostream>
#include <adoutil.h>
#include <DBInstall.h>

using std::cout;
using std::endl;

// test driver class..
class TestDriver
{
public:
  TestDriver() : mbUninstalling(false), mbInstallWithoutDropDB(false) {};
  virtual ~TestDriver() {};
  
  BOOL testDBInstall ();
  BOOL testDBDrop ();
  BOOL ParseArgs (int argc, char* argv[]);
  void PrintUsage();
  
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
    long GetTimeoutValue() const { return mTimeoutValue; } 
    const string& GetAction() const { return mAction; } 
    int GetIsStaging() const {return mIsStaging; }

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
    { mTimeoutValue = TimeoutValue; } 
    
private:
  
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
    string mDBType ;
    string mAction ;
    string mDataSource ;
    long mTimeoutValue;
    
    bool mbUninstalling;
    bool mbInstallWithoutDropDB;

	int mIsStaging;
    
};


int
main (int argc, char** argv)
{
  ComInitialize comstruct;
  
  TestDriver testdriver;
  
  if (!testdriver.ParseArgs(argc, argv))
  {
    cout << "ERROR: Parsing of arguments failed"  << endl;
    return -1;
  }
  
  if (stricmp(testdriver.GetAction().c_str(), "drop") == 0)
	{
		if (!testdriver.testDBDrop())
			return -1;
		else
			return 0;
	}

  // local variables
  if (!testdriver.testDBInstall())
  {
    cout << "ERROR: Installation of Database failed"  << endl;
    return -1;
  }
  
  cout << "SUCCESS: Installation of Database succeeded"  << endl;
  
  return 0;
}

BOOL
TestDriver::testDBDrop()
{
  // if the database type is oracle ...
  if (stricmp(mDBType.c_str(), "oracle") == 0)
  {
		CDBInstall_Oracle dbInstall(false);

    if (!dbInstall.Initialize(mSALogon.c_str(),
      mSAPassword.c_str(),
      mDatabaseName.c_str(),
      mDataSource.c_str(),
      mDBOLogon.c_str(),
      mDBOPassword.c_str(),
      mDataDeviceLocation.c_str(),
      mDataDeviceSize,
      mTimeoutValue))
    {
      cout << "ERROR: Unable to Initialize " << endl;
      return FALSE;
    }

	 	if (!dbInstall.DropDBObjects())
			return FALSE;
	}
	else
	{
		CDBInstall_SQLServer dbInstall(0);
    if (!dbInstall.Initialize(
			mSALogon.c_str(),
      mSAPassword.c_str(),
      mDatabaseName.c_str(),
      mServerName.c_str(),
      mDBOLogon.c_str(),
      mDBOPassword.c_str(),
      mDataDeviceName.c_str(),
      mDataDeviceLocation.c_str(),
      mDataDeviceSize,
      mLogDeviceName.c_str(),
      mLogDeviceLocation.c_str(),
      mLogDeviceSize,
      mDataDumpDeviceFile.c_str(),
      mLogDumpDeviceFile.c_str(),
      mTimeoutValue))
    {
      cout << "ERROR: Unable to Initialize " << endl;
      return FALSE;
    }

	 	if (!dbInstall.DropDBObjects())
			return FALSE;
	}
	return TRUE;
}

// code to test the DB Install object
BOOL
TestDriver::testDBInstall()
{
	// local variables ...
	_bstr_t newValue;
	string wstrName;
	_variant_t vtValue; 
	_variant_t vtIndex;
	BOOL bInstallFailed = FALSE;

	// if the database type is oracle ...
	if (stricmp(mDBType.c_str(), "oracle") == 0)
	{
		// create and initialize a db install object ...
		CDBInstall_Oracle DBInstall(mIsStaging);
		if (!DBInstall.Initialize(mSALogon.c_str(),
			mSAPassword.c_str(),
			mDatabaseName.c_str(),
			mDataSource.c_str(),
			mDBOLogon.c_str(),
			mDBOPassword.c_str(),
			mDataDeviceLocation.c_str(),
			mDataDeviceSize,
			mTimeoutValue))
		{
			cout << "ERROR: Unable to Initialize " << endl;

			return FALSE;
		}

		if(!mbUninstalling) 
		{
			if (!mbInstallWithoutDropDB)
			{
				// start the install
				if (!DBInstall.Install())
				{
					cout << "ERROR: Unable to Install " << endl;
					bInstallFailed = TRUE;
				}
			}
			if ( !bInstallFailed && !mIsStaging )
			{
				// install the database objects like tables, sps, etc.
				if (!DBInstall.InstallDBObjects())
				{
					cout << "ERROR: Unable to install DB objects." << endl;
					bInstallFailed = TRUE;
				}
			}

			// drop the install if anything failed
			if (bInstallFailed)
			{
				DBInstall.Uninstall();
				return FALSE;
			}
		}
		else 
		{
			// drop the whole thing
			if (!DBInstall.Uninstall())
			{
				cout << "ERROR: Unable to uninstall " << endl;
				return FALSE;
			}
		}
	}
	// else if the database type is sqlserver ...
	else // if (stricmp(mDBType.c_str(), "sqlserver") == 0)
	{

		// create and initialize a db install object ...
		CDBInstall_SQLServer DBInstall(mIsStaging);
		if (!DBInstall.Initialize(mSALogon.c_str(),
			mSAPassword.c_str(),
			mDatabaseName.c_str(),
			mServerName.c_str(),
			mDBOLogon.c_str(),
			mDBOPassword.c_str(),
			mDataDeviceName.c_str(),
			mDataDeviceLocation.c_str(),
			mDataDeviceSize,
			mLogDeviceName.c_str(),
			mLogDeviceLocation.c_str(),
			mLogDeviceSize,
			mDataDumpDeviceFile.c_str(),
			mLogDumpDeviceFile.c_str(),
			mTimeoutValue))
		{
			cout << "ERROR: Unable to Initialize " << endl;

			return FALSE;
		}

		if(!mbUninstalling) 
		{
			// start the install
			if (mIsStaging == 1)
				//install the staging database
		 {
			 if (!DBInstall.Install_withoutDropDB())
			 {
				 cout << "ERROR: Unable to Create StagingDB " << endl;
				 bInstallFailed = TRUE;
			 }
		 }
			else
			{    //install the normal database

				if (!DBInstall.Install())
				{
					cout << "ERROR: Unable to Install " << endl;
					bInstallFailed = TRUE;
				}
			}

			if ( !bInstallFailed )
			{
				// change the database owner
				if (!DBInstall.ChangeDBOwner())
				{
					cout << "ERROR: Unable to change DB owner " << endl;
					bInstallFailed = TRUE;
				}
			}

			if ( !bInstallFailed && !mIsStaging)
			{
				// install the database objects like tables, sps, etc.
				if (!DBInstall.InstallDBObjects())
				{
					cout << "ERROR: Unable to install DB objects " << endl;
					bInstallFailed = TRUE;
				}
			}

			// drop the install if anything failed
			if (bInstallFailed)
			{
				DBInstall.Uninstall();
				return FALSE;
			}
		}
		else 
		{
			// uninstall the database
			if (!DBInstall.Uninstall())
			{
				cout << "ERROR: Unable to uninstall " << endl;
				return FALSE;
			}

			// drop the dbo owner
			if (!DBInstall.DropDBOwner())
			{
				cout << "ERROR: Unable to drop DB owner " << endl;
				return FALSE;
			}
		}
	}

	return TRUE;
}

// print usage
void 
TestDriver::PrintUsage()
{
  cout << "\nUsage: DatabaseInstall [options]" << endl;
  cout << "\tOptions: "<< endl;
  cout << "\t\t-salogon [SA Logon] " << endl;
  cout << "\t\t-sapassword [SA Password] " << endl;
  cout << "\t\t-dbname [Database Name] " << endl;
  cout << "\t\t-servername [Server Name] " << endl;
  cout << "\t\t-dbologon [DBO Logon] " << endl;
  cout << "\t\t-dbopassword [DBO Password] " << endl;
  cout << "\t\t-datadevname [Data Device Name] " << endl;
  cout << "\t\t-datadevloc [Data Device Location] " << endl;
  cout << "\t\t-datadevsize [Data Device Size] " << endl;
  cout << "\t\t-logdevname [Log Device Name] " << endl;
  cout << "\t\t-logdevloc [Log Device Location] " << endl;
  cout << "\t\t-logdevsize [Log Device Size] " << endl;
  cout << "\t\t-datadumpdevfile [Data Dump Device File] " << endl;
  cout << "\t\t-logdumpdevfile [Log Dump Device File] " << endl;
  cout << "\t\t-timeoutvalue [Execution time out value] " << endl;
  cout << "\t\t-uninstall	[Uninstall the database only (optional)]" << endl;
  cout << "\t\t-installwithoutdropdb [Install just the objects]" << endl;
		cout << "\tExample: "<< endl;
    cout << "\t\t-salogon sa " << endl;
    cout << "\t\t-sapassword """ << endl;
    cout << "\t\t-dbname NetMeter " << endl;
    cout << "\t\t-servername INTEG " << endl;
    cout << "\t\t-dbologon nmdbo " << endl;
    cout << "\t\t-dbopassword nmdbo " << endl;
    cout << "\t\t-datadevname NMDBData " << endl;
    cout << "\t\t-datadevloc C:\\mssql\\data\\NMDBData.dat " << endl;
    cout << "\t\t-datadevsize 100 " << endl;
    cout << "\t\t-logdevname NMDBLog " << endl;
    cout << "\t\t-logdevloc C:\\mssql\\data\\NMDBLog.dat " << endl;
    cout << "\t\t-logdevsize 20 " << endl;
    cout << "\t\t-datadumpdevfile C:\\mssql\\backup\\NMDBData.dat " << endl;
    cout << "\t\t-logdumpdevfile C:\\mssql\\backup\\NMDBLog.dat " << endl;
    cout << "\t\t-timeoutvalue 1000" << endl;
	cout << "\t\t-IsStaging 0" << endl;
    
    return;
}

// parse the arguments
BOOL 
TestDriver::ParseArgs (int argc, char* argv[])
{
  // local variables...
  int i;

	if (argc <= 1)
	{
		PrintUsage();
    return FALSE;
	}

  // parse the arguments
  for (i = 1; i < argc; i++)
  {
    string strOption(argv[i]);
    
    // required for oracle
    if(stricmp(strOption.c_str(), "-uninstall") == 0) {
      mbUninstalling = true;
    }
    // required for oracle
    else if(stricmp(strOption.c_str(), "-installwithoutdropdb") == 0) {
      mbInstallWithoutDropDB = true;
    }
    
    // sa logon
    else if (stricmp(strOption.c_str(), "-salogon") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the sa logon...
        mSALogon = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // sa password
    else if (stricmp(strOption.c_str(), "-sapassword") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the sa password...
        mSAPassword = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // db name
    else if (stricmp(strOption.c_str(), "-dbname") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the db name
        mDatabaseName = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // server name
    else if (stricmp(strOption.c_str(), "-servername") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the server name
        mServerName = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // DBO logon
    else if (stricmp(strOption.c_str(), "-dbologon") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the DBO logon 
        mDBOLogon = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // DBO password
    else if (stricmp(strOption.c_str(), "-dbopassword") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the DBO password 
        mDBOPassword = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // data device name
    else if (stricmp(strOption.c_str(), "-datadevname") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the data device name
        mDataDeviceName = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // data device location
    else if (stricmp(strOption.c_str(), "-datadevloc") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the data device location
        mDataDeviceLocation = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // data device size in megs
    else if (stricmp(strOption.c_str(), "-datadevsize") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the data device size in megs
        mDataDeviceSize = atol(argv[i]);
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // log device name
    else if (stricmp(strOption.c_str(), "-logdevname") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log device name
        mLogDeviceName = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // log device location
    else if (stricmp(strOption.c_str(), "-logdevloc") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log device location
        mLogDeviceLocation = argv[i];
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // log device size in megs
    else if (stricmp(strOption.c_str(), "-logdevsize") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the data device size in megs
        mLogDeviceSize = atol(argv[i]);
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    // data dump device file
    else if (stricmp(strOption.c_str(), "-datadumpdevfile") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the data dump device file
        mDataDumpDeviceFile = argv[i];
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    // log dump device file
    else if (stricmp(strOption.c_str(), "-logdumpdevfile") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mLogDumpDeviceFile = argv[i];
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    // timeout parameter
    else if (stricmp(strOption.c_str(), "-timeoutvalue") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mTimeoutValue = atol(argv[i]);
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    else if (stricmp(strOption.c_str(), "-datasource") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mDataSource = argv[i];
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    else if (stricmp(strOption.c_str(), "-dbtype") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mDBType = argv[i];
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
		}
    else if (stricmp(strOption.c_str(), "-action") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mAction = argv[i];
      }
	}
	else if (stricmp(strOption.c_str(), "-IsStaging") == 0)
    {
      // get the test to run ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the log dump device file
        mIsStaging = atol(argv[i]);
		cout << "IsStaging was read to be: " << mIsStaging <<endl;
      }
      else
      {
        PrintUsage();
        
        return FALSE;
      }
    }
    else
    {
      PrintUsage() ;
      return FALSE ;
    }
  }
  
  return TRUE;
}

