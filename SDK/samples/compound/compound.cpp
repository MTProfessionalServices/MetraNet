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

using std::cout;
using std::cin;
using std::ios;
using std::cerr;
using std::endl;
using std::hex;
using std::dec;

#ifdef UNIX
#endif

int bUseSynch=FALSE ;

class CompoundMeter
{
public:
  // construct the default configuration object, and use that to 
  // construct the meter object
  CompoundMeter() : mMeter(mConfig)
  { }
  
  // entry point called from main
  void TestCompound(int argc, char * argv[]);
  
private:
  
  // meter the transaction based on the info entered by the user
  // returns NULL if there is no error
  MTMeterError * MeterIt(const char * host, const char * username,
    const char * password, const char * accountname, const char * parentdesc);
  
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


void CompoundMeter::TestCompound(int argc, char * argv[])
{
  cout << "MetraTech Compound metering example." << endl;
  
  // read the server host name
  cout << "Server host name: ";
  char host[256];
  cin.getline(host, sizeof(host));
  
  // read the server username
  cout << "Server username: ";
  char username[256];
  *username = 0;
  cin.getline(username, sizeof(username));
  
  // read the server password
  cout << "Server password: ";
  char password[256];
  *password = 0;
  cin.getline(password, sizeof(password));
  
  // read the user's account name
  cout << "Account Name: ";
  char accountname[256];
  cin.getline(accountname, sizeof(accountname));
  
  // read the description
  cout << "Parent description: ";
  char desc[256];
  cin.getline(desc, sizeof(desc));
  
 
  // summarize the metering information
  cout << endl << "Metering with the following information:" << endl;
  cout << "Host: " << host << endl;
  cout << "Username: " << username << endl;
  cout << "Password: " << password << endl;
  cout << "Account Name: " << accountname << endl;
  cout << "Description: " << desc << endl;

  
  // initialize the SDK
  if (!mMeter.Startup())
  {
    MTMeterError * err = mMeter.GetLastErrorObject();
    PrintError("Could not initialize the SDK: ", err);
    delete err;
    return;
  }
  
  int bUseSSL = FALSE;
  // if we are using SSL to send the session ... pass the 
  // appropriate parameters correctly (port and secure flag) 
  if (bUseSSL == TRUE)
  {
    if (!mConfig.AddServer(0,            					// priority (highest)
      host,                   // hostname
      MTMeterHTTPConfig::DEFAULT_HTTPS_PORT,			// port (from mtsdk.h)
      TRUE,			              // secure (yes)
      username,		            // username
      password))	            // password
		{
    	MTMeterError * err = mMeter.GetLastErrorObject();
    	PrintError("Could not set SDK configuration properties: ", err);
    	delete err;
    	return;
  	}
  }
  // otherwise ... we're not using SSL to send the session ... pass the 
  // appropriate parameters correctly (port and secure flag) 
  else
  {
    if (!mConfig.AddServer(0,					              // priority (highest)
      host,				              // hostname
      MTMeterHTTPConfig::DEFAULT_HTTP_PORT,				// port (default plaintext HTTP)
      FALSE,			              // secure? (no)
      username,		              // username
      password))	              // password
		{
    	MTMeterError * err = mMeter.GetLastErrorObject();
    	PrintError("Could not set SDK configuration properties: ", err);
    	delete err;
    	return;
  	}
  }
  
  // meter the session
  MTMeterError * err = MeterIt(host, username, password, accountname, desc);
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
  cout << "Press any key to continue..." << endl;
  (void) GetKey();
  return;
}

MTMeterError * CompoundMeter::MeterIt(const char * host, const char * username,
                                    const char * password, const char * accountname,
									const char * parentdesc)

{
  
 
	 // read the units
  cout << endl << endl << "Number of child sessions: ";
  int sessions;
  cin >> sessions;
  char temp[256];
  cin.getline(temp, sizeof(temp));

	
	// service name is "metratech.com/testparent"
  MTMeterSession * session = mMeter.CreateSession("metratech.com/testparent");

	time_t t = time(NULL);

	// Set the parent property names which have to match those on the server
	if (!session->InitProperty("AccountName", accountname)
		|| !session->InitProperty("Description", parentdesc)
      || !session->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
	{
		MTMeterError * err = session->GetLastErrorObject();
		delete session;
    
		return err;
	}
  
  for (int i=0 ; i < sessions; i++)
  {
	MTMeterSession * child = session->CreateChildSession("metratech.com/TestService");
    
    // read the description
	cout << "Child description: ";
	char desc[256];
	cin.getline(desc, sizeof(desc));
  
	// read the units
	cout << "Units (floating point number): ";
	float units;
	cin >> units;
	cin.getline(temp, sizeof(temp));

  
	// set the session's time field to the current time.
	t = time(NULL);
  
	// these property names have to match those on the server
	if (!child->InitProperty("AccountName", accountname)
		|| !child->InitProperty("Description", desc)
		|| !child->InitProperty("Units", units)
      || !child->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
	{
		MTMeterError * err = child->GetLastErrorObject();
		delete child;
    
		return err;
	}
  }

  // send the session to the server
  if (!session->Close())
  {
    MTMeterError * err = session->GetLastErrorObject();
    delete session;
    
    return err;
  }
  
  if (session->GetResultRequestFlag())
  {
	MTMeterSession * ResultSession = session->GetSessionResults();
	if (ResultSession)
	{
		float Amount;
		float perunit;
		cout.setf (ios::showpoint);
		cout.setf (ios::fixed, ios::floatfield);
		cout.precision (2);
		if (ResultSession->GetProperty ("_Amount", Amount)  &&
				ResultSession->GetProperty ("PerUnit", perunit))
			cout << endl << "A per unit cost of " << perunit << " was applied, resulting in a charge of " << Amount << endl << endl;
	}
  }

  // sessions created with CreateSession must be deleted.
  delete session;
  
  // success! no error to return
  return NULL;
}


void CompoundMeter::PrintError(const char * prefix, const MTMeterError * err)
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
int CompoundMeter::GetKey()
{
#ifdef _WIN32
  return _getch();
#else
  return getchar();
#endif
}



int main(int argc, char * argv[])
{
  CompoundMeter meter;
  meter.TestCompound(argc, argv);
  return 0;
}
