/**************************************************************************
* Copyright 1998, 1999 by MetraTech Corporation
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
***************************************************************************/

// Include metering objects
#include "mtsdk.h"
#include "sdk_msg.h"

#ifdef WIN32
#include <conio.h>							// for _getch
#endif
#include <string.h>

#include <iostream>
using namespace std;

#ifdef UNIX
#include <curses.h>
#define _getch getch
#endif

bool bUseSynch = false;
bool bUseSets = false;

class AccountGen
{
public:
  // construct the default configuration object, and use that to
  // construct the meter object
  AccountGen() : mMeter(mConfig)
  { }

  // entry point called from main
  void Test(int argc, char * argv[]);

private:

  // meter the transaction based on the info entered by the user
  // returns NULL if there is no error
  MTMeterError * CreateAccount(const char * host, 
  														 const char * accountname,
  														 const char * desc, 
  														 int units, 
  														 long sessions, 
  														 long sets);

  // print an error if there is one
  void PrintError(const char * prefix, const MTMeterError * err);

  // wait for a key and return its value
  static int GetKey();

  // configuration object - used to initialize the Metering SDK
  // with HTTP transport
  MTMeterHTTPConfig mConfig;

  // the entry point to the Metering SDK - all Metering objects
  // are created from here.
  MTMeter mMeter;
};

void AccountGen::Test(int argc, char * argv[])
{
  cout << "MetraTech simple metering example." << endl;

  // read the server host name
  cout << "Server host name: ";
  char host[256];
  cin.getline(host, sizeof(host));

  // read the user's account name
  cout << "Account Name: ";
  char accountname[256];
  cin.getline(accountname, sizeof(accountname));

  // read the description
  cout << "Transaction description: ";
  char desc[256];
  cin.getline(desc, sizeof(desc));

  // prompt for synchronous mode
  cout << "Do you want to meter synchronously? [y/n] ";
  char sendSynch[10];

  *sendSynch = 0;
  cin.getline(sendSynch, sizeof(sendSynch));

  // if no indicator was entered ... do not send the session
  // using SSL
  if (strlen(sendSynch) == 0)
  {
    bUseSynch = false;
  }
  else if (strlen(sendSynch) == 1)
  {
    if (sendSynch[0] == 'y' || sendSynch[0] == 'Y')
    {
      cout << "Metering Synchronously." << endl;
      bUseSynch = true;
    }
    else if (sendSynch[0] == 'n' || sendSynch[0] == 'N')
    {
      bUseSynch = false;
    }
    else
    {
      cout << "Invalid response. Not sending the session using Sychronous mode." << endl ;
      bUseSynch = false;
    }
  }
  else
  {
    cout << "Invalid response. Metering aynchronously." << endl ;
    bUseSynch = false;
  }

  // prompt for synchronous mode
  cout << "Do you want to use sessionsets? [y/n] ";
  char useSets[10];

 *useSets = 0;
  cin.getline(useSets, sizeof(useSets));

  if (strlen(useSets) == 0)
  {
    bUseSets = false;
  }
  else if (strlen(useSets) == 1)
  {
    if (useSets[0] == 'y' || useSets[0] == 'Y')
    {
      bUseSets = true;
    }
    else if (useSets[0] == 'n' || useSets[0] == 'N')
    {
      bUseSets = false;
    }
    else
    {
      cout << "Invalid response. Metering without using sessionsets." << endl ;
      bUseSets = false;
    }
  }
  else
  {
    cout << "Invalid response. Metering without using sessionsets." << endl ;
    bUseSets = false;
  }

  long sessions = 1;
  long sets = 1;
  int units = 10;

  if (bUseSets == true)
  {
      // read the # of sessions per set
      cout << "Sessions Per Sets: ";
      cin >> sessions;
  }

  if (bUseSets == true)
  {
      // read the # sets
      cout << "Number of sets to meter: ";
      cin >> sets;
  }

  // summarize the metering information
  cout << endl << "Metering with the following information:" << endl;
  cout << "Host: " << host << endl;
  cout << "Account Name: " << accountname << endl;
  cout << "Description: " << desc << endl;


  if (bUseSynch == true)
    cout << "Using Synchronous mode to send the session." << endl ;
  else
    cout << "Not using Synchronous to send the session." << endl ;

  if (bUseSets == true)
    cout << "Using sessionsets. Sessions Per Set: " << sessions << " Sets: " << sets << endl;
  else
    cout << "Not using sessionsets." << endl;

  // initialize the SDK
  if (!mMeter.Startup())
  {
    MTMeterError * err = mMeter.GetLastErrorObject();
    PrintError("Could not initialize the SDK: ", err);
    delete err;
    return;
  }

  // if we are using SSL to send the session ... pass the
  // appropriate parameters correctly (port and secure flag)
  mConfig.AddServer(0,					              // priority (highest)
    host,				              // hostname
    MTMeterHTTPConfig::DEFAULT_HTTP_PORT,				// port (default plaintext HTTP)
    FALSE,			              // secure? (no)
    "",		              // username
    "");	              // password

  // meter the session
  MTMeterError * err = CreateAccount(host, accountname, desc, units, sessions, sets);
  if (!err)
    cout << "The session has been metered!" << endl;
  else
  {
    PrintError("The session has not been metered: ", err);
    delete err;
  }


  // close the sdk
  mMeter.Shutdown();

  // pause, in case this is run from a shortcut
  //cout << "Press any key to continue..." << endl;
  //(void) GetKey();
  return;
}


MTMeterError * AccountGen::CreateAccount(const char * host, 
																				 const char * accountname,
                                    		 const char * desc, 
                                    		 int units, 
                                    		 long sessions, 
                                    		 long sets)
{
  MTMeterSessionSet * sessionset;
  MTMeterSession * session;
  long sps;
  long n;
  long i;
  long s;

  s = sets;
  for (i = 0; i < s; i++)
  {
		if (bUseSets == true)
			sessionset = mMeter.CreateSessionSet();

  	if (bUseSets == true)
			sps = sessions;
		else
			sps = 1;

    for (n = 0; n < sps; n++)
		{
			// create session(s) for metering to TestService
			if (bUseSets == true)
			{                    
      	sessionset->SetSessionContextUserName("demo");
      	sessionset->SetSessionContextPassword("demo123");
      	sessionset->SetSessionContextNamespace("mt");
				session = sessionset->CreateSession("metratech.com/accountcreation");
				cout << "Using SessionSets..." << endl;
			}
    	else
			{
				session = mMeter.CreateSession("metratech.com/accountcreation");
				cout << "Using Sessions..." << endl;
			}
	
    	cout << "Metering Synch = " << (int) bUseSynch << endl;
    	//   session->SetResultRequestFlag(bUseSynch);
    	session->SetResultRequestFlag(true);
                     	
    	// set the session's time field to the current time.
    	time_t t = time(NULL);
	
    	// these property names have to match those on the server
    	if (!session->InitProperty("username", accountname) || 
					!session->InitProperty("operation", "Add") || 
					!session->InitProperty("actiontype", "Both") || 
					!session->InitProperty("currency", "USD") || 
					!session->InitProperty("_Accountid", 0) || 
					!session->InitProperty("billable", "T") || 
					!session->InitProperty("password_", "a") || 
					!session->InitProperty("language", "US") || 
					!session->InitProperty("timezoneID", 18) || 
					!session->InitProperty("timezoneoffset", "-5") || 
					!session->InitProperty("taxexempt", "F") || 
					!session->InitProperty("city", "Springfield") || 
					!session->InitProperty("state", "MA") || 
					!session->InitProperty("zip", "01923") || 
					!session->InitProperty("accounttype", "IndependentAccount") || 
					!session->InitProperty("contacttype", "Bill-To") || 
					!session->InitProperty("paymentmethod", "CASHORCHECK") || 
					!session->InitProperty("firstname", accountname) || 
					!session->InitProperty("lastname", "unix") || 
					!session->InitProperty("email", "pradeep@unix.com") || 
					!session->InitProperty("phonenumber", "1-IMBATMAN") || 
					!session->InitProperty("company", "Wayne Tech Inc.") || 
					!session->InitProperty("address1", "Wayne Manor") || 
					!session->InitProperty("address2", "") || 
					!session->InitProperty("address3", "") || 
					!session->InitProperty("country", "USA") || 
					!session->InitProperty("facsimiletelephonenumber", "") || 
					!session->InitProperty("middleinitial", "L") || 
					!session->InitProperty("statusreason", 5) || 
					!session->InitProperty("folder", "F") || 
					!session->InitProperty("usagecycletype", "daily") || 
					!session->InitProperty("accountstatus", "AC") || 
					!session->InitProperty("accountstartdate", t, MTMeterSession::SDK_PROPTYPE_DATETIME) || 
					!session->InitProperty("name_space", "mt"))
     	{
       	MTMeterError * err = session->GetLastErrorObject();
       	delete session;
       	return err;
     	}
 	 	}
	
	 	cout << " Session(s) " << n << " has been create..." << endl;
	 	if (bUseSets == true)
   	{
	   	// close sessionset and send to the server
	   	cout << "Closing Sessionset..." << endl;
	   	if (!sessionset->Close())
	   	{
		   	MTMeterError * err = sessionset->GetLastErrorObject();
		   	delete sessionset;
		   	return err;
	   	}
	 	}
   	// close session and send to the server
   	else
   	{
     	cout << "Closing Session..." << endl;
	   	if (!session->Close())
	   	{
		   	MTMeterError * err = session->GetLastErrorObject();
		   	delete session;
		   	return err;
	   	}
	 	}
 	}

  // sessions created with CreateSession must be deleted.
  delete session;

  // success! no error to return
  return NULL;
}

void AccountGen::PrintError(const char * prefix, const MTMeterError * err)
{
  cerr << prefix << ": ";
  if (err)
  {
    int size = 0;
    err->GetErrorMessage((char *) NULL, size);
    char * buf = new char[size];
    err->GetErrorMessage(buf, size);

    cerr << hex << err->GetErrorCode() << dec << ": " << buf << endl;
  }
  else
    cerr << "*UNKNOWN ERROR*" << endl;
}


// wait for a key
int AccountGen::GetKey()
{
#ifdef _WIN32
  return _getch();
#else
  return getchar();
#endif
}


int main(int argc, char * argv[])
{
  AccountGen meter;
  meter.Test(argc, argv);
  return 0;
}
