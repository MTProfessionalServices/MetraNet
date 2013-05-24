/**************************************************************************
* Copyright 2006 by MetraTech Corporation
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
//#include "sdk_msg.h"

#ifdef WIN32
#include <conio.h>              // for _getch
#endif

#include <string.h>
#include <iostream>

#ifdef UNIX
#include <varargs.h>
#define __va_list va_list
#endif

#define ARGCOUNT 12

using namespace std;

// WARNING:  don't change the order of these!
static char *args[] = { "h", "n", "p", "bh", "bn", "bp",
      "a", "d", "t", "ssl", "sync", "proxy"};

// WARNING:  don't change the order of these either!
static char *prompts[ARGCOUNT]
       = { "Server hostname",
           "Server username",
           "Server password",
           "Failover Server hostname, <return> for none",
           "Failover Server username",
           "Failover Server password",
           "Account Name",
           "Transaction description",
           "Units (floating point number)",
           "Use SSL? y/[n]",
           "Use Synchronous mode (the pipeline must be running)? y/[n]",
           "Proxy Server (http://user:password@proxyserver:port)" };

class SimpleMeter
{
public:
  SimpleMeter()
  { 
  }
  
  // entry point called from main
  void TestSimple(int argc, char * argv[]);
  
private:

  char *argvals[ARGCOUNT];
  char argdvals[ARGCOUNT][256];

  void usage();
  
  // meter the transaction based on the info entered by the user
  // returns NULL if there is no error
  MTMeterError * MeterIt(const char *accountname,
       const char *desc,
       float units,
       bool UseSynch);
  
  // print an error if there is one
  void PrintError(const char * prefix, const MTMeterError * err);
  
  // wait for a key and return its value
  static int GetKey();
  
  // configuration object - used to initialize the Metering SDK
  // with HTTP transport
  MTMeterHTTPConfig* mConfig;
  
  // the entry point to the Metering SDK - all Metering objects
  // are created from here.
  MTMeter* mMeter;
  
};

void SimpleMeter::usage()
{
  cout << "Usage:" << endl;
  cout << "simple [-h host] [-n username] [-p password]" << endl;
  cout << "  [-bh backuphost] -bn backupusername] -bp backuppassword]" << endl;
  cout << "  [-a accountname] [-d description] [-t units] [-ssl y|n] [-sync y|n]" << endl;
  cout << "  [-proxy http://user:pwd@proxy:port]" << endl;
}

void SimpleMeter::TestSimple(int argc, char * argv[])
{
  int i, j;

  cout << "MetraTech simple metering sample" << endl;

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


  const char* proxy;
  if ( strlen(argvals[11]) ) {
    proxy = argvals[11];
  } else {
    proxy = NULL;
  }

  // summarize the metering information
  cout << endl << "Metering with the following information:" << endl;
  for (i = 0; i < ARGCOUNT; i++) {
    if ( argvals[i] ) {
      cout << "    " << prompts[i] << ": ";
      if ( i == 9 || i == 10 ) {
        cout << (argvals[i][0]?argvals[i]:"n");
      } else {
        cout << argvals[i];
      }
      cout << endl;
    }
  }

  cout << endl;

  const char* PrimaryHost = argvals[0];
  const char* Username = argvals[1];
  const char* Password = argvals[2];
  const char* FailoverHost = argvals[3];
  const char* FailoverUsername = argvals[4];
  const char* FailoverPassword = argvals[5];
  const char* AccountName = argvals[6];
  const char* TransactionDescription = argvals[7];

  float units = (float) atof(argvals[8]);

  bool UseSSL = FALSE;
  int Port = MTMeterHTTPConfig::DEFAULT_HTTP_PORT; 
  if (argvals[9][0] == 'y' || argvals[9][0] == 'Y') {
	  UseSSL = TRUE;
	  Port = MTMeterHTTPConfig::DEFAULT_HTTPS_PORT;
  }

  bool UseSynch = FALSE;
  if (argvals[10][0] == 'y' || argvals[10][0] == 'Y') UseSynch = TRUE;

  // initialize the SDK

  mConfig = new MTMeterHTTPConfig(proxy);
  mMeter = new MTMeter(*mConfig);

  if (!mMeter->Startup()) 
  {
    MTMeterError * err = mMeter->GetLastErrorObject();
    PrintError("Could not initialize the SDK: ", err);
    delete err;
    return;
  }
  
  if (!mConfig->AddServer(0, PrimaryHost, Port, UseSSL, Username, Password))            
  {
    MTMeterError * err = mMeter->GetLastErrorObject();
    PrintError("Could not set SDK configuration properties: ", err);
    delete err;
    return;
  }

  // Add the FAILOVER server if requested
  if (FailoverHost && *FailoverHost) 
  {
    if (!mConfig->AddServer(1, FailoverHost, Port, UseSSL, FailoverUsername, FailoverPassword))    
    {
      MTMeterError * err = mMeter->GetLastErrorObject();
      PrintError("Could not set SDK configuration properties: ", err);
      delete err;
      return;
    }
  }
  
  // meter the session
  MTMeterError *err = MeterIt(AccountName, TransactionDescription, units, UseSynch);

  if (!err) {
    cout << "The session has been metered!" << endl;
  } else {
    PrintError("The session has not been metered: ", err);
    delete err;
  }
  
  // close the sdk
  mMeter->Shutdown();
  
  // pause, in case this is run from a shortcut
  cout << "Press any key to continue..." << endl;
  (void) GetKey();
}

MTMeterError * SimpleMeter::MeterIt(const char *accountname,
                                    const char *desc, float units, bool UseSynch)
{
  // service name is "metratech.com/TestService"
  MTMeterSession * session = mMeter->CreateSession("metratech.com/TestService");
  
  session->SetResultRequestFlag(UseSynch);
  
  // set the session's time field to the current time.
  time_t t = time(NULL);
  
  // these property names have to match those on the server
  if (!session->InitProperty("AccountName", accountname)
    || !session->InitProperty("Description", desc)
    || !session->InitProperty("Units", units)
    || !session->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
  {
    MTMeterError * err = session->GetLastErrorObject();
    delete session;
    
    return err;
  }
  
  // send the session to the server
  if (!session->Close()) {
    MTMeterError * err = session->GetLastErrorObject();
    delete session;
    return err;
  }
  
  if (session->GetResultRequestFlag()) {
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

  // sessions created with CreateSession must be deleted.
  delete session;
  
  // success! no error to return
  return NULL;
}


void SimpleMeter::PrintError(const char * prefix, const MTMeterError * err)
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
int SimpleMeter::GetKey()
{
#ifdef _WIN32
  return _getch();
#else
  return getchar();
#endif
}

int main(int argc, char * argv[])
{
	::CoInitializeEx(NULL, COINIT_MULTITHREADED);
  SimpleMeter meter;
  meter.TestSimple(argc, argv);
  ::CoUninitialize();
  return 0;
}

