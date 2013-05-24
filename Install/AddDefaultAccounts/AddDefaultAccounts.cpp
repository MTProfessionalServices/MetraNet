
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <iostream>
#include <DBConstants.h>
#include <COMKiosk_i.c>
#include <multi.h>
#include <errutils.h>
#include <string>
#include <stdutils.h>
#include <iostream>

#include <AccountTools.h>

// import the vendor kiosk tlb...
#import <COMKiosk.tlb> 
using namespace COMKIOSKLib ;

using namespace std;

// test driver class..
class TestDriver
{
	public:
  		TestDriver():mDayOfMonth(0), mLanguage(L"US"), mUCT("Monthly"),
      mFirstDayOfMonth(0), mSecondDayOfMonth(0), mDayOfWeek(0), mStartDay(0),
      mStartMonth(0), mStartYear(0), mAccountType(L"CORESUBSCRIBER") {};
  		virtual ~TestDriver() {};

  		BOOL ParseArgs (int argc, wchar_t* argv[]);
  		void PrintUsage();
		BOOL AddUser() ;

		//	Accessors
		const wstring& GetLogin() const { return mLogin; } 
		const wstring& GetPassword() const { return mPassword; } 
		const wstring& GetName_Space() const { return mName_Space; } 
    const wstring& GetLanguage() const { return mLanguage; } 
    const wstring& GetAccountType() const { return mAccountType; } 
    const wstring& GetLoginApp() const {return mLoginApp; }
    const long GetDayOfMonth() const { return mDayOfMonth;}
    const wstring& GetMultiPipelineLogin() const { return mMultiPipelineLogin; } 
    const wstring& GetMultiPipelinePassword() const { return mMultiPipelinePassword; } 
    const wstring& GetMultiPipelineDomain() const { return mMultiPipelineDomain; } 
    const _bstr_t GetUCT() const { return mUCT; }
    const long GetFirstDayOfMonth() const { return mFirstDayOfMonth;}
    const long GetSecondDayOfMonth() const { return mSecondDayOfMonth;}
    const long GetDayOfWeek() const { return mDayOfWeek;}
    const long GetStartDay() const { return mStartDay;}
    const long GetStartMonth() const { return mStartMonth;}
    const long GetStartYear() const { return mStartYear;}
    
		//	Mutators
		void SetLogin(const wchar_t* login)
		    { mLogin = login; } 
		void SetPassword(const wchar_t* password)
		    { mPassword = password; } 
		void SetName_Space(const wchar_t* name_space)
		    { mName_Space = name_space; } 
        void SetLanguage(const wchar_t* language)
		    { mLanguage = language; } 
        void SetDayOfMonth(const long aDayOfMonth)
            { mDayOfMonth = aDayOfMonth ; }
		void SetMultiPipelineLogin(const wchar_t* multipipelinelogin)
		    { mMultiPipelineLogin = multipipelinelogin; } 
		void SetMultiPipelinePassword(const wchar_t* multipipelinepassword)
		    { mMultiPipelinePassword = multipipelinepassword; } 
		void SetMultiPipelineDomain(const wchar_t* multipipelinedomain)
		    { mMultiPipelineDomain = multipipelinedomain; } 
    void SetAccountType(const wchar_t* aAccountType)
		    { mAccountType = aAccountType; } 
    void SetLoginApp (const wchar_t * aLoginApp)
    { mLoginApp = aLoginApp;}

	private:

	wstring mLogin;
	wstring mPassword;
	wstring mName_Space;
	wstring mLanguage ;
	wstring mMultiPipelineLogin;
	wstring mMultiPipelinePassword;
	wstring mMultiPipelineDomain;
  wstring mAccountType;
	int mDayOfMonth ;
	int mFirstDayOfMonth ;
	int mSecondDayOfMonth ;
  int mDayOfWeek ;
  int mStartDay ;
  int mStartMonth ;
  int mStartYear ;
  wstring mLoginApp;
  _bstr_t mUCT ;

};

//
// Print Usage
//
void 
TestDriver::PrintUsage()
{
  	cout << "\nUsage: AddDefaultAccounts [options]" << endl;
  	cout << "Options: "<< endl;
  	cout << "\t-u [username]   - demo " << endl;
  	cout << "\t-p [password]   - password" << endl;
  	cout << "\t-n [namespace]  - namespace " << endl;
    cout << "\t-l [langauge]   - langauge" << endl;
    cout << "\t-dom [day of month] - day of month" << endl ;
    cout << "\t-uct [usage cycle type] - usage cycle type " << endl ;
    cout << "\t-dom1 [first day of month] - first day of month (for semi-monthly)" << endl ;
    cout << "\t-dom2 [second day of month] - second day of month (for semi-monthly)" << endl ;
    cout << "\t-dow [day of week] - day of week (for weekly)" << endl ;
    cout << "\t-sd [start day] - start day (for biweekly, quarterly, semi-annually, or annually)" << endl ;
    cout << "\t-sm [start month] - start month (for biweekly, quarterly, semi-annually, or annually)" << endl ;
    cout << "\t-sy [start year] - start year (for biweekly)" << endl ;
    cout << "\t-login [multi-instance related]" << endl ;
    cout << "\t-password [multi-instance related]" << endl ;
    cout << "\t-domain [multi-instance related]" << endl;
    cout << "\t-AccountType " << endl << endl ;
    cout << "\t-LoginApp " << endl << endl;
  	cout << "Example: "<< endl;
  	cout << "\tAddDefaultAccounts -u demo -p demo123 -n mt -l US -dom 30" << endl;
  	cout << "\t -login pipeline1 -password pipeline1 -AccountType CSR -LoginApp CSR" << endl;

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
      // else get the password ...
      else if (_wcsicmp(wstrOption.c_str(), L"-p") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          SetPassword(argv[i]);
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
      else if (_wcsicmp(wstrOption.c_str(), L"-l") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          SetLanguage(argv[i]);
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      // get the name space ...
      else if (_wcsicmp(wstrOption.c_str(), L"-dom") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          long dom = _wtol (argv[i]) ;
          SetDayOfMonth(dom);
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-dom1") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mFirstDayOfMonth = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-dom2") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mSecondDayOfMonth = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-dow") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mDayOfWeek = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-sd") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mStartDay = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-sm") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mStartMonth = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-sy") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mStartYear = _wtol (argv[i]) ;
        }
        else
        {
		        PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-uct") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // get the password...
          mUCT = argv[i] ;
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
      else if (_wcsicmp(wstrOption.c_str(), L"-AccountType") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // set the pipeline domain...
          SetAccountType(argv[i]) ;
        }
        else
        {
		    PrintUsage();
            return FALSE;
        }
      }
      else if (_wcsicmp(wstrOption.c_str(), L"-LoginApp") == 0)
      {
        // 
        if (i + 1 < argc)
        {
          // increment i ...
          i++;
          
          // set the pipeline domain...
          SetLoginApp(argv[i]) ;
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

  if (!testdriver.AddUser())
  {
	cout << "ERROR: Adding of account failed" << endl;
	return -1;
  }
  cout << "SUCCESS: Adding of account succeeded" << endl;

  return 0;
}

BOOL
TestDriver::AddUser()
{
  // local variables ...
  HRESULT nRetVal=S_OK ;

  // initialize COM ...
  ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  
  // ------------------------------- start vendor kiosk ----------------------------
  // add the user to the following 3 tables:
  // t_account_mapper,
  // t_user_credentials, and
  // t_profile
  cout << "Adding user with Login <" 
			 << ascii(GetLogin()) << "> and password <"
       << ascii(GetPassword()) << "> and namespace <" 
			 << ascii(GetName_Space()) << ">" << endl;


  MTAccountTools aAccountTool(string(_bstr_t(GetLogin().c_str())));

  BOOL bRetVal = aAccountTool.AddDefaultAccount(string(_bstr_t(GetPassword().c_str())),
		string(_bstr_t(GetName_Space().c_str())),
		string(_bstr_t(GetLanguage().c_str())),
		GetDayOfMonth(), GetUCT(), GetDayOfWeek(), GetFirstDayOfMonth(), 
    GetSecondDayOfMonth(), GetStartDay(), GetStartMonth(), GetStartYear(), GetAccountType().c_str(), GetLoginApp().c_str());
  if(!bRetVal) {
    cout << aAccountTool.GetErrorString();
  }
  return bRetVal;
}



