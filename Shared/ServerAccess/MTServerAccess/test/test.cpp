
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
 * Created by: Raju Matta 
 * $Header$
 ***************************************************************************/

#include <metralite.h>
#include <iostream>
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>

#include <windows.h>
#include <stdio.h>

#include <SetIterate.h>
#include <mtcomerr.h>
#include <errobj.h>

#import <MTServerAccess.tlb>
using namespace MTSERVERACCESSLib;
using namespace std;

// test driver class..
class TestDriver
{
	public:
  		TestDriver();
  		virtual ~TestDriver();

  		BOOL ParseArgs (int argc, char* argv[]);
  		void PrintUsage();
        BOOL Test1();
		BOOL Initialize();

		//	Accessors
		const string& GetTestName() const { return mTestName; } 

		//	Mutators
		void SetTestName(const char* testname)
		    { mTestName = testname; } 

	private:

		string mTestName;
};



int 
main(int argc, char** argv)
{
    cout << "Entering main()" << endl;

	TestDriver testdriver;

	// parse the arguments
	if (!testdriver.ParseArgs(argc, argv))
	{
	  cout << "ERROR: Parsing of arguments failed"  << endl;
	  return -1;
	}
	cout << "SUCCESS: Parsing of arguments succeeded"  << endl;
	  
	// initialize
	if (!testdriver.Initialize())
	{
	  cout << "ERROR: Initialization failed"  << endl;
	  return -1;
	}
	cout << "SUCCESS: Initialization succeeded"  << endl;

	try
	{
	  if (stricmp(testdriver.GetTestName().c_str(), "test1") == 0)
	  {
	    testdriver.Test1();
	  }
	  else
	  {
		cout << "ERROR: Unknown argument passed" << endl;
		return -1;
	  }
	}
	catch (HRESULT hr)
	{
		cout << "***ERROR! " << hex << hr << dec << endl;
		return -1;
	}
	catch (_com_error err)
	{
		cout << "***ERROR _com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
		return -1;
	}
#if 0
	catch (...)
	{
		cout << "***ERROR everything else " << endl;
		return -1;
	}
#endif

    cout << "SUCCESS: Test succeeded"  << endl;

	return 0;
}

// 
// constructor
//
TestDriver::TestDriver()
{
	cout << "Entering Constructor" << endl;
	::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	cout << "Leaving Constructor" << endl;
}


// 
// destructor
//
TestDriver::~TestDriver() 
{
	cout << "Entering Destructor" << endl;
	::CoUninitialize();
	cout << "Leaving Destructor" << endl;
}

//

//
// Print Usage
//
void 
TestDriver::PrintUsage()
{
  	cout << "\nUsage: TestServerAccess [options]" << endl;
  	cout << "\tOptions: "<< endl;
  	cout << "\t\t-t [test type] - test1 " << endl;
  	cout << "\tExample: "<< endl;
  	cout << "\t\tTestServerAccess -t test1 " << endl;

  	return;
}

//
// Initialize the test driver 
//
BOOL 
TestDriver::Initialize()
{
	return (TRUE);
}


// 
// Parse arguments
//
BOOL 
TestDriver::ParseArgs (int argc, char* argv[])
{
	cout << "Entering ParseArgs" << endl;

  	// local variables ...
  	int i;
  	string Text;

  	// if we don't have enough args ... exit
  	if (argc < 2)
  	{
    	PrintUsage();
    	return (FALSE);
  	}

  	// parse the arguments ...
  	for (i = 1; i < argc; i++)
  	{
	    string strOption(argv[i]);

    	// get the code ...
    	if (stricmp(strOption.c_str(), "-t") == 0)
    	{
      		// get the thread mode ...
      		if (i + 1 < argc)
      		{
        		// increment i ...
        		i++;

        		// set the code...
				Text = argv[i];

        		// set the name... 
				SetTestName(Text.c_str());
      		}
      		else
      		{
        		PrintUsage();
        		return (FALSE);
      		}
    	}
  	}

	cout << "Leaving ParseArgs" << endl;
  	return (TRUE);
}


// this test does the com test
BOOL 
TestDriver::Test1()
{
    HRESULT hr = S_OK;
    const char* procName = "TestDriver::Test1";
	
    // create the MTServerAccessDataSet object
    MTSERVERACCESSLib::IMTServerAccessDataSetPtr mtdataset;
	hr = mtdataset.CreateInstance("MTServerAccess.MTServerAccessDataSet.1");
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to create instance of MTServerAccessDataSet object" 
      		<< hex << hr << endl;
		return (FALSE);
	}

	hr = mtdataset->Initialize();
    if (!SUCCEEDED(hr))
    {
    	cout << "ERROR: unable to initialize " << hex << hr << endl;
		return (FALSE);
	}

	long count = 0;
	mtdataset->get_Count(&count);
	if (count == 0)
    {
    	cout << "INFO: no data found in the xml file" << endl;
		return (FALSE);
	}
    cout << "Number: " << count << endl;

	
	try 
	{
	    if (count > 0)
      	{
			SetIterator<MTSERVERACCESSLib::IMTServerAccessDataSetPtr, 
			            MTSERVERACCESSLib::IMTServerAccessDataPtr> it;
			HRESULT hr = it.Init(mtdataset);
			if (FAILED(hr)) return hr;
	
			while (TRUE)
			{
			    MTSERVERACCESSLib::IMTServerAccessDataPtr data = it.GetNext();
		    	if (data == NULL) break;

			    string servertype;
				string servername;
				long numretries;
				long priority;
				long secure;
				long timeout;
				servertype = data->GetServerType();
				servername = data->GetServerName();
				numretries = data->GetTimeout();
				priority = data->GetPriority();
				secure = data->GetSecure();
				timeout = data->GetTimeout();

				printf( "server type: <%s> ", servertype.c_str());
				printf( "server name: <%s> \n", servername.c_str());
				printf( "num retries: <%d> \n", numretries);
				printf( "priority: <%d> \n", priority);
				printf( "secure: <%d> \n", secure);
				printf( "timeout: <%d> \n", timeout);
		    }
        }
    }
	catch (HRESULT hr)
	{
	    cout << "Error = " << hex << hr << endl ;
		return FALSE;
	}
	catch (_com_error err)
	{
	    cout << "ERROR: Error = " << hex << err.Error() << dec << endl;
        return FALSE;
    }	

	try
	{
	  MTSERVERACCESSLib::IMTServerAccessDataPtr mt;
	  mt = mtdataset->FindAndReturnObject("paymentserver"); 
    }
	catch (HRESULT hr)
	{
	    cout << "Error = " << hex << hr << endl ;
		return FALSE;
	}
	catch (_com_error err)
	{
	    cout << "ERROR: Error = " << hex << err.Error() << dec << endl;
        return FALSE;
    }	




	return (TRUE);
}

