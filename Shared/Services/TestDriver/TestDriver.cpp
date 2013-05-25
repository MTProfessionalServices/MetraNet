
/**************************************************************************
 * @doc TEST
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 * Created by: Raju Matta (for the Services module)
 *
 * Modified by:
 *
 * $Header$
 ***************************************************************************/

// ----------------------------------------------------------------
// Name:        TestServiceDefs.exe
// Usage:       TestServiceDefs [-l all|servicename]|[-dump]|[-auto]
// Arguments:   
//    -l <service> Loads the given service definition. Values can
//                 either be "all" or a specific filename, such as
//				   "metratech.com\recurringcharge.xml".
//	  -dump 	   Dumps all of the properties and their types
//				   from the current service collection.
//	  -auto	       Creates an autosdk file from the current
//				   service collection.
// Description: This tool helps test service definitions. It will
//				validate the XML and identify omitted or 
//				mismatched tags. If the -l option is used with the
//	            "all" value, then services.xml is consulted to
//				determine the current service definition collection.
// ----------------------------------------------------------------

#include <metralite.h>
#include <mtcom.h>
#import <MTConfigLib.tlb>
#include <ServicesCollection.h>
#include <loggerconfig.h>
#include <stdutils.h>

#include <stdio.h>

#include <strstream>
using namespace std;

class TestDriver
{
	public:
  		TestDriver() {};
  		virtual ~TestDriver() {};

  		BOOL ParseArgs (int argc, wchar_t* argv[]) ;
  		void PrintUsage() ;

  		DWORD GetNumThreads() const ;

		//	Accessors
		const wstring& GetXMLFileName() const { return mXMLFileName; } 

		//	Mutators
		void SetXMLFileName(const wchar_t* xmlfilename) 
	        { mXMLFileName = xmlfilename; }

	private:

  		wstring mXMLFileName;
};

void PrintError(const char * apStr, const ErrorObject * obj)
{
	cout << apStr << ": " << hex << obj->GetCode() << dec << endl;
	string message;
	obj->GetErrorMessage(message, true);
	cout << message.c_str() << "(";
	const string detail = obj->GetProgrammerDetail();
	cout << detail.c_str() << ')' << endl;

	if (strlen(obj->GetModuleName()) > 0)
		cout << " module: " << obj->GetModuleName() << endl;
	if (strlen(obj->GetFunctionName()) > 0)
		cout << " function: " << obj->GetFunctionName() << endl;
	if (obj->GetLineNumber() != -1)
		cout << " line: " << obj->GetLineNumber() << endl;

	char * theTime = ctime(obj->GetErrorTime());
	cout << " time: " << theTime << endl;
}

int DumpServices()
{
	// local variables
	CServicesCollection services;
	if (!services.Initialize())
	{
		PrintError("Unable to initialize services collection", services.GetLastError());
		return -1;
	}

	ServicesDefList & list = services.GetDefList();
  ServicesDefList::const_iterator it = list.begin();
	while (it != list.end())
	{
		CMSIXDefinition * service = *it;
		DumpMSIXDef(service);
    it++;
	}
	return 0;
}

int DumpAutosdk()
{
	// local variables
	CServicesCollection services;
	if (!services.Initialize())
	{
		PrintError("Unable to initialize services collection", services.GetLastError());
		return -1;
	}

	ServicesDefList & list = services.GetDefList();
	ServicesDefList::const_iterator it = list.begin();
	while (it != list.end())
	{
		CMSIXDefinition * service = *it;
		string output;
		MSIXDefAsAutosdk(service, output);
		cout << output.c_str() << endl << endl;
    it++;
	}
	return 0;
}

extern "C" int 
wmain(int argc, wchar_t** argv)
{
    ComInitialize cominit;

    TestDriver testdriver;

		if (argc == 2 && 0 == wcscmp(argv[1], L"-dump"))
			return DumpServices();

		if (argc == 2 && 0 == wcscmp(argv[1], L"-auto"))
			return DumpAutosdk();

		if (argc == 2 && 0 == wcscmp(argv[1], L"-?")) {
			testdriver.PrintUsage();
			return 0;
		}


  	// if we don't have enough args ... exit
    if (!testdriver.ParseArgs(argc, argv))
  	{
    	return 0;
  	}

    // local variables
	CServicesCollection* p;
	p = new CServicesCollection;

	NTLogger logger;
	LoggerConfigReader cfgRdr;
	logger.Init(cfgRdr.ReadConfiguration(PRODUCT_VIEW_STR), CORE_TAG);


	// call the initialize method on the collection object
	if (!p->Initialize(testdriver.GetXMLFileName().c_str()))
	{
	    cout << "ERROR: Unable to initialize" << endl;
		logger.LogThis(LOG_ERROR, "Unable to initialize");
		delete p;
		p = 0;
		return (-1);
	}
	cout << "SUCCESS: Initialization succeeded" << endl;

	// delete the pointer
	delete p;

	return 0;
}


void 
TestDriver::PrintUsage()
{
	cout << "\nUsage: TestServiceDefs [-l all|servicename]|[-dump]|[-auto]" << endl;
  	cout << "\n-l <xml filename>   - service to load or all" << endl;
  	cout << "-dump               - dumps all properties and types" << endl;
  	cout << "-auto               - creates autosdk files" << endl;

	cout << "\nExample: TestServiceDefs -l all" << endl;
  	cout << "         TestServiceDefs -l metratech.com\\recurringcharge.xml" << endl;

	cout << "\nThis tool helps test service definitions. It will" << endl;
	cout << "validate the XML and identify omitted or" << endl;
	cout << "mismatched tags. If the -l option is used with the" << endl;
	cout << "\"all\" value or if -dump or -auto are used, then" << endl;
	cout << "services.xml is consulted to determine the current" << endl;
	cout << "service definition collection." << endl;
  	return;
}


BOOL 
TestDriver::ParseArgs (int argc, wchar_t* argv[])
{
  	// local variables ...
  	int i;
  	wstring wstrText;


  	// if we don't have enough args ... exit
  	if (argc < 2)
  	{
    	PrintUsage();
    	return FALSE;
  	}

    // parse the arguments ...
    for (i = 1; i < argc; i++)
    {
      wstring wstrOption(argv[i]);
      
      if (strcasecmp(wstrOption, wstring(L"-l")) == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          mXMLFileName = argv[i];
          wstring::size_type pos;
          while ((pos = mXMLFileName.find(L"/")) != wstring::npos)
           mXMLFileName.replace(pos, 1, L"\\"); 
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
    }

  	return TRUE;
}




