
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <DBConstants.h>
#include <AccountTools.h>
#include <multi.h>
#include <errutils.h>
#include <string>
#include <iostream>
using namespace std;

// test driver class..
class TestDriver
{
	public:
  		TestDriver() {};
  		virtual ~TestDriver() {};

  		BOOL ParseArgs (int argc, wchar_t* argv[]);
  		void PrintUsage();
		BOOL AddAccountMappings();

		//	Accessors
		const _bstr_t& GetLogin() const { return mLogin; } 
		const _bstr_t& GetName_Space() const { return mName_Space; } 
		const long GetAccountID() const { return mAccountID; } 
        const wstring& GetMultiPipelineLogin() const { return mMultiPipelineLogin; } 
        const wstring& GetMultiPipelinePassword() const { return mMultiPipelinePassword; } 
        const wstring& GetMultiPipelineDomain() const { return mMultiPipelineDomain; } 

		//	Mutators
		void SetLogin(const wchar_t* login)
		    { mLogin = login; } 
		void SetName_Space(const wchar_t* name_space)
		    { mName_Space = name_space; } 
		void SetAccountID(const long aAccountID)
            { mAccountID = aAccountID; }
		void SetMultiPipelineLogin(const wchar_t* multipipelinelogin)
		    { mMultiPipelineLogin = multipipelinelogin; } 
		void SetMultiPipelinePassword(const wchar_t* multipipelinepassword)
		    { mMultiPipelinePassword = multipipelinepassword; } 
		void SetMultiPipelineDomain(const wchar_t* multipipelinedomain)
		    { mMultiPipelineDomain = multipipelinedomain; } 

	private:

		_bstr_t mLogin;
		_bstr_t mName_Space;
        long mAccountID;
        wstring mMultiPipelineLogin;
	    wstring mMultiPipelinePassword;
	    wstring mMultiPipelineDomain;

};

//
// Print Usage
//
void 
TestDriver::PrintUsage()
{
  	cout << "\nUsage: AddAccountMappings [options]" << endl;
  	cout << "\tOptions: "<< endl;
  	cout << "\t\t-u [username]   - demo " << endl;
  	cout << "\t\t-n [namespace]  - namespace " << endl;
	cout << "\t\t-a [accountID] - account ID" << endl;
    cout << "\t\t-login [multi-instance related]" << endl ;
    cout << "\t\t-password [multi-instance related]" << endl ;
    cout << "\t\t-domain [multi-instance related]" << endl ;
  	cout << "\tExample: "<< endl;
  	cout << "\t\tAddAccountMappings -u demo -n metratech.com/external -a 123" << endl;
  	cout << "\t\t -login pipeline1 -password pipeline1 " << endl;
  	return;
}

// 
// Parse arguments
//
BOOL 
TestDriver::ParseArgs (int argc, wchar_t* argv[])
{
  	// local variables ...
  	int i;

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

      // get the login ...
      if (_wcsicmp(wstrOption.c_str(), L"-u") == 0)
      {
   		// get the thread mode ...
   		if (i + 1 < argc)
        {
          // increment i ...
          i++;
            
          // get the login name ...
          SetLogin(argv[i]);
        }
        else
        {
          PrintUsage();
          return FALSE;
        }
      }
      // get the name space ...
      else if (_wcsicmp(wstrOption.c_str(), L"-n") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          SetName_Space(argv[i]);
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      // get the name space ...
      else if (_wcsicmp(wstrOption.c_str(), L"-a") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          long accountID = _wtol (argv[i]);
          SetAccountID(accountID);
        }
        else
        {
		    PrintUsage();
            return FALSE;
        }
      }
    // get the pipeline login ...
    else if (_wcsicmp(wstrOption.c_str(), L"-login") == 0)
    {
      // 
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
          
        // set the pipeline login...
        SetMultiPipelineLogin(argv[i]) ;
      }
      else
      {
		PrintUsage();
        return FALSE;
      }
    }
    // get the pipeline password ...
    else if (_wcsicmp(wstrOption.c_str(), L"-password") == 0)
    {
      // 
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
         
        // set the pipeline password...
        SetMultiPipelinePassword(argv[i]) ;
      }
      else
      {
		PrintUsage();
        return FALSE;
      }
    }      
    // get the pipeline domain ...
    else if (_wcsicmp(wstrOption.c_str(), L"-domain") == 0)
    {
      // 
      if (i + 1 < argc)
      {
        // increment i ...
        i++;
          
        // set the pipeline domain...
        SetMultiPipelineDomain(argv[i]) ;
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



//
// main
//
extern "C" int 
wmain(int argc, wchar_t** argv) 
{
	ComInitialize aComInit;
  TestDriver testdriver;

  // parse the arguments
  if (!testdriver.ParseArgs(argc, argv))
  {
	cout << "ERROR: Parsing of arguments failed"  << endl;
	return -1;
  }

  const char* login = NULL;
  const char* password = NULL;
  const char* domain = NULL;

  if (testdriver.GetMultiPipelineLogin().length() != 0)
  {
	login = (const char*) _bstr_t (testdriver.GetMultiPipelineLogin().c_str());
  }

  if (testdriver.GetMultiPipelinePassword().length() != 0)
  {
	password = (const char*) _bstr_t (testdriver.GetMultiPipelinePassword().c_str());
  }

  if (testdriver.GetMultiPipelineDomain().length() != 0)
  {
	domain = (const char*) _bstr_t (testdriver.GetMultiPipelineDomain().c_str());
  }

  // multi instance setup
  MultiInstanceSetup multiSetup;
  if (!multiSetup.SetupMultiInstance(login, password, domain))
  {
	string buffer;
	StringFromError(buffer, "Multi-instance setup failed", multiSetup.GetLastError());
	cout << buffer.c_str() << endl;
	return -1;
  }

  if (!testdriver.AddAccountMappings())
  {
	cout << "ERROR: Adding of account mappings failed" << endl;
	return -1;
  }
  cout << "SUCCESS: Adding of account mappings succeeded" << endl;


  return 0;
}

BOOL
TestDriver::AddAccountMappings()
{
  // add the account to the following table:
  // t_account_mapper,
  cout << "Adding user with Login <" 
	   << (const char *) GetLogin() << "> and name_space <"
       << (const char *)GetName_Space() << "> and accountID <" 
	   << GetAccountID() << ">" << endl;

	MTAccountTools aAccountTool((char *) GetLogin());
	BOOL bRetVal = aAccountTool.AddAccountMapping(string(_bstr_t(GetName_Space())),GetAccountID());
	if(!bRetVal) {
		cout << aAccountTool.GetErrorString();
		return bRetVal;
	}

  return TRUE;
}



