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
#include <conio.h>              // for _getch
#endif

#include <string.h>
#include <iostream>
using namespace std;

#ifdef UNIX
#include <varargs.h>
#define __va_list va_list
#endif

#define ARGCOUNT 11
#define SESSIONS 10

// WARNING:  don't change the order of these!
static char *args[] = { "h", "n", "p", "bh", "bn", "bp",
			"a", "d", "t", "ssl", "sync"};

// WARNING:  don't change the order of these either!
static char *prompts[11] = { "Server hostname",
			     "Server username",
			     "Server password",
			     "Failover Server hostname, <return> for none",
			     "Failover Server username",
			     "Failover Server password",
			     "Account Name",
			     "Transaction description",
			     "Units (floating point number)",
			     "Use SSL? y/[n]",
			     "Use Synchronous mode (the pipeline must be running)? y/[n]" };

class SessionSetMeter
{
public:
  // construct the default configuration object, and use that to 
  // construct the meter object
  SessionSetMeter() : mMeter(mConfig)
  { }
  
  // entry point called from main
  void TestSessionSet(int argc, char * argv[]);
  
private:

  char *argvals[11];
  char argdvals[11][256];

  void usage();
  
  // meter the transaction based on the info entered by the user
  // returns NULL if there is no error
  MTMeterError * MeterIt(const char *accountname,
			 const char *desc,
			 float units,
			 bool bUseSynch);
  
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

void SessionSetMeter::usage()
{
  cout << "Usage: \nsimple [-h host] [-n username] [-p password]\n  [-bh backuphost] -bn backupusername] -bp backuppassword]\n  [-a accountname] [-d description] [-t units] [-ssl y|n] [-sync y|n]" << endl;
}

void SessionSetMeter::TestSessionSet(int argc, char * argv[])
{
  int i, j;

  cout << "MetraTech session set metering sample" << endl;

  for (i = 0; i < ARGCOUNT; i++) {
    argvals[i] = NULL;
    *argdvals[i] = '\0';
  }

  if (argc == 2 &&
      (!strncmp(argv[1], "-u", 2) ||
       !strncmp(argv[1], "-?", 2) ||
       !strncmp(argv[1], "-help", 5))) {
    usage();
    return;
  }

  // Parse command line
  for (i = 1; i < argc; i++) {
    if (argv[i][0] != '-') {
      usage();
      return;
    }
    for (j = 0; j < ARGCOUNT; j++) {
      if (!strcmp(argv[i] + 1, args[j])) {
	if (i + 1 == argc) {
	  // Need value
	  usage();
	  return;
	}
	if (argv[i + 1][0] == '-') { usage(); return; }
	argvals[j] = argv[++i];
	break;
      }
      if (j == ARGCOUNT - 1) {
	cout << "Error: unrecognized argument: " << argv[i] << endl;
	usage();
	return;
      }
    } 
  }

  // Prompt for remaining arguments
  for (j = 0; j < ARGCOUNT; j++) {
    if (argvals[j] != NULL) continue;

    // Special case for failover:
    // If any command line args set, don't ask for failover server
    if (j == 3 && argc > 1) { continue; }

    // Another special case for failover:
    // Don't ask for username/password if hostname isn't set
    if (j == 4 && (!argvals[3] || *argvals[3] == '\0')) { j++; continue; }

    cout << prompts[j] << ": ";
    cin.getline(argdvals[j], 256);
    argvals[j] = argdvals[j];
  }

  float units = (float) atof(argvals[8]);
  bool bUseSSL = FALSE;
  bool bUseSynch = FALSE;

  if (argvals[9][0] == 'y' || argvals[10][0] == 'Y') bUseSSL = TRUE;
  if (argvals[10][0] == 'y' || argvals[10][0] == 'Y') bUseSynch = TRUE;

  // summarize the metering information
  cout << endl << "Metering with the following information:" << endl;
  for (i = 0; i < ARGCOUNT - 2; i++) {
    if (argvals[i] && *argvals[i]) cout << "    " << prompts[i] << ": " << argvals[i] << endl;
  }
  for (i = ARGCOUNT - 2; i < ARGCOUNT; i++) {
    cout << "    " << prompts[i] << ": ";
    if (argvals[i] && *argvals[i]) {
      cout << argvals[i] << endl;
    } else {
      cout << "n" << endl; 
    }
  }

  cout << endl;

  // initialize the SDK
  if (!mMeter.Startup()) {
    MTMeterError * err = mMeter.GetLastErrorObject();
    PrintError("Could not initialize the SDK: ", err);
    delete err;
    return;
  }
  
  if (!mConfig.AddServer(0,			// priority (highest)
		    argvals[0],		// hostname
		    bUseSSL ? MTMeterHTTPConfig::DEFAULT_HTTPS_PORT : MTMeterHTTPConfig::DEFAULT_HTTP_PORT,
		    bUseSSL,		// secure
		    argvals[1],		// username
		    argvals[2]))	// password
	{
   	MTMeterError * err = mMeter.GetLastErrorObject();
   	PrintError("Could not set SDK configuration properties: ", err);
   	delete err;
   	return;
	}

  // Add the FAILOVER server if requested
  if (argvals[3] && *argvals[3]) {
      if (!mConfig.AddServer(1,		// priority
                        argvals[3],     // hostname
                        bUseSSL ? MTMeterHTTPConfig::DEFAULT_HTTPS_PORT : MTMeterHTTPConfig::DEFAULT_HTTP_PORT,
                        bUseSSL,        // secure
                        argvals[4],     // username
                        argvals[5]))    // password
			{
			 	MTMeterError * err = mMeter.GetLastErrorObject();
   			PrintError("Could not set SDK configuration properties: ", err);
   			delete err;
   			return;
			}
  }
  
  // meter the session
  MTMeterError *err = MeterIt(argvals[6], argvals[7], units, bUseSynch);

  if (!err) {
    cout << "The session has been metered!" << endl;
  } else {
    PrintError("The session has not been metered: ", err);
    delete err;
  }
  
  // close the sdk
  mMeter.Shutdown();
  
  // pause, in case this is run from a shortcut
  cout << "Press any key to continue..." << endl;
  (void) GetKey();
}

MTMeterError * SessionSetMeter::MeterIt(const char *accountname,
					const char *desc, float units, bool bUseSynch)
{
  // service name is "metratech.com/TestService"
  
  
  MTMeterSession * session;
  MTMeterSessionSet * sessionset = mMeter.CreateSessionSet();

  for (int i = 0; i < SESSIONS; i++)
  {
    session = sessionset->CreateSession("metratech.com/TestService");
    session->SetResultRequestFlag(bUseSynch);
  
    // set the session's time field to the current time.
    time_t t = time(NULL);
  
    // these property names have to match those on the server
    if (!session->InitProperty("AccountName", accountname)
	|| !session->InitProperty("Description", desc)
	|| !session->InitProperty("Units", units*i)
        || !session->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
      {
	MTMeterError * err = session->GetLastErrorObject();
	delete sessionset;
	return err;
      }
  }

    // send the session to the server
  if (!sessionset->Close()) {
    MTMeterError * err = sessionset->GetLastErrorObject();
    delete session;
    return err;
  }
  
  /*
  if (sessionset->GetResultRequestFlag()) {
    MTMeterSession *ResultSession = session->GetSessionResults();
    if (ResultSession) {
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
  */

  // sessions created with CreateSession must be deleted.
  delete sessionset;
  
  // success! no error to return
  return NULL;
}


void SessionSetMeter::PrintError(const char * prefix, const MTMeterError * err)
{
  cerr << prefix << ": ";
  if (err) {
    int size = 0;
    err->GetErrorMessage((char *) NULL, size);
    char * buf = new char[size];
    err->GetErrorMessage(buf, size);
    
    cerr << hex << err->GetErrorCode() << dec << ": " << buf << endl;
  } else {
    cerr << "*UNKNOWN ERROR*" << endl;
  }
}


// wait for a key
int SessionSetMeter::GetKey()
{
#ifdef _WIN32
  return _getch();
#else
  return getchar();
#endif
}

int main(int argc, char * argv[])
{
  SessionSetMeter meter;
  meter.TestSessionSet(argc, argv);
  return 0;
}









