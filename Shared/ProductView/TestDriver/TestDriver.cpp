
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
* Created by: Raju Matta (for the ProductView module)
*
* Modified by:
*
* $Header$
***************************************************************************/

#include <metralite.h>
#include <mtcom.h>
#include <ProductViewOps.h>

#include <ProductViewCollection.h>
#import <MTEnumConfigLib.tlb>
#include <mtprogids.h>
#include <multi.h>
#include <errutils.h>
#include <string>
#include <iostream>

using namespace std;

// import the rowset tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
using namespace ROWSETLib  ;

class TestDriver
{
public:
  TestDriver() {};
  virtual ~TestDriver() {};
  
  BOOL ParseArgs (int argc, char* argv[]) ;
  void PrintUsage() ;
   
		//	Accessors
    const wstring& GetAction() const { return mAction; } 
    const wstring& GetXMLFileName() const { return mXMLFileName; } 
    const wstring& GetMultiPipelineLogin() const { return mMultiPipelineLogin; } 
    const wstring& GetMultiPipelinePassword() const { return mMultiPipelinePassword; } 
    const wstring& GetMultiPipelineDomain() const { return mMultiPipelineDomain; } 
    
    //	Mutators
    void SetAction(const wchar_t* action) 
    { mAction = action; }
    void SetXMLFileName(const wchar_t* xmlfilename) 
    { mXMLFileName = xmlfilename; }
	void SetMultiPipelineLogin(const wchar_t* multipipelinelogin)
		    { mMultiPipelineLogin = multipipelinelogin; } 
	void SetMultiPipelinePassword(const wchar_t* multipipelinepassword)
		    { mMultiPipelinePassword = multipipelinepassword; } 
	void SetMultiPipelineDomain(const wchar_t* multipipelinedomain)
		    { mMultiPipelineDomain = multipipelinedomain; } 
   
private:
  wstring mAction;
  wstring mXMLFileName;
  wstring mMultiPipelineLogin;
  wstring mMultiPipelinePassword;
  wstring mMultiPipelineDomain;
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


int DumpProductViews()
{
	// local variables
	CProductViewCollection productViews;
	if (!productViews.Initialize())
	{
		PrintError("Unable to initialize services collection", productViews.GetLastError());
		return -1;
	}

	ProductViewDefList & list = productViews.GetDefList();
	ProductViewDefList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXDefinition * def = *it;
		DumpMSIXDef(def);
	}
	return 0;
}

int DumpAutosdk()
{
	// local variables
	CProductViewCollection coll;
	if (!coll.Initialize())
	{
		PrintError("Unable to initialize services collection", coll.GetLastError());
		return -1;
	}

	ProductViewDefList & list = coll.GetDefList();
	ProductViewDefList::iterator it;
	for (it = list.begin(); it != list.end(); ++it)
	{
		CMSIXDefinition * view = *it;
		string output;
		MSIXDefAsAutosdk(view, output);
		cout << output << endl << endl;
	}
	return 0;
}


int main(int argc, char** argv)
{
  ComInitialize comInit;

  TestDriver testdriver;
  
	if (argc == 2 && 0 == strcmp(argv[1], "-dump"))
		return DumpProductViews();

	if (argc == 2 && 0 == strcmp(argv[1], "-auto"))
		return DumpAutosdk();

  // if we don't have enough args ... exit
  if (!testdriver.ParseArgs(argc, argv))
  {
    return 1;
  }

	// cache an enum config object
	MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);

	ProductViewOps aProductViewOps;

	if(!aProductViewOps.Initialize()) {
		cout << aProductViewOps.GetLastError()->GetProgrammerDetail().c_str() << endl;
	}
	else {
		const wchar_t * filename;
		if (testdriver.GetXMLFileName() == L"all" || testdriver.GetXMLFileName() == L"")
			filename = NULL;
		else
			filename = testdriver.GetXMLFileName().c_str();

		if(0 == mtwcscasecmp(testdriver.GetAction().c_str(), L"drop")) {
			if(!aProductViewOps.DropTable(filename)) {
				if(aProductViewOps.GetLastError()) {
					cout << aProductViewOps.GetLastError()->GetProgrammerDetail().c_str() << endl;
					return -1;
				}
				else {
					cout << "Unknown error" << endl;
					return -1;
				}
			}
			else {
				cout << "Successfully dropped table" << endl;
			}
		}
		else {
			if(!aProductViewOps.AddTable(filename)) {
				cout << aProductViewOps.GetLastError()->GetProgrammerDetail().c_str() << endl;
				return -1;
			}
			else {
				cout << "Succesfully added table" << endl;
			}
		}
	}
  return 0;
}


void 
TestDriver::PrintUsage()
{
  cout << "\nUsage: AddProductView [options]" << endl;
  cout << "\tOptions: "<< endl;
  cout << "\t\t-a [action] action - create/drop (default: create)" << endl;
  cout << "\t\t-l [xml filename] - values: all/filename" << endl;
  cout << "\tExample: "<< endl;
  cout << "\t\tAddProductView -a drop -l all (or)" << endl;
  cout << "\t\tAddProductView -a drop -l metratech.com\\recurringcharge.msixdef" << endl;
  
  return;
}


BOOL 
TestDriver::ParseArgs (int argc, char* argv[])
{
  // local variables ...
  int i;
  string strText;
  _bstr_t bstrValue ;
  
  
  // if we don't have enough args ... exit
  if (argc < 2)
  {
    PrintUsage();
    return FALSE;
  }
  
  // parse the arguments ...
  for (i = 1; i < argc; i++)
  {
    string strOption(argv[i]);
    
    // if tables need to be dropped or created
    if (mtstrcasecmp(strOption.c_str(), "-a") == 0)
    {
      // get the thread mode ...
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        
        // get the action name ...
        strText = argv[i];
        
        // make sure it's a valid test name ...
        if (mtstrcasecmp(strText.c_str(), "drop") == 0)
        {
          mAction = L"drop";
        }
        else if (mtstrcasecmp(strText.c_str(), "create") == 0)
        {
          mAction = L"create";
        }
        else
        {
          mAction = L"create";
          //PrintUsage();
          //return FALSE;
        }
      }
      else
      {
        PrintUsage();
        return FALSE;
      }
    }
    // else check to see if this option is for the number of threads ...
    else if (mtstrcasecmp(strOption.c_str(), "-l") == 0)
    {
      // 
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
        bstrValue = argv[i];
        mXMLFileName = bstrValue ;
		
				// convert all "/" to "\"
				if (mXMLFileName.find(L"/") != wstring::npos)
					mXMLFileName.replace(mXMLFileName.find(L"/"), 1, L"\\");
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
