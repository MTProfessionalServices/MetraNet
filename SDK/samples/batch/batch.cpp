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
//#include "sdk_msg.h"

#ifdef WIN32
#include <conio.h>              // for _getch
#endif

#include <string>
//#include <iostream.h>
#include <iostream>
#include <time.h>

#ifdef UNIX
#include <varargs.h>
#define __va_list va_list
#endif

using namespace std;

#define ARGCOUNT 12
#define SESSIONS 10

// WARNING:  don't change the order of these!
static char *args[] = { 
	"h", 
	"n", 
	"p", 
	"bh", 
	"bn", 
	"bp",
	"a", 
	"d", 
	"t", 
	"ssl", 
	"sync",
	"port"};

// WARNING:  don't change the order of these either!
static char *prompts[12] = { 
	"Server hostname",
	"Server username",
	"Server password",
	"Failover Server hostname, <return> for none",
	"Failover Server username",
	"Failover Server password",
	"Account Name",
	"Transaction description",
	"Units (floating point number)", "Use SSL? y/[n]",
	"Use Synchronous mode (the pipeline must be running)? y/[n]",
	"Port" };

class BatchTest
{
	public:
  	// construct the default configuration object, and use that to 
  	// construct the meter object
  	BatchTest() : mMeter(mConfig) 
		{ 
			mID = -1;
			mName = "";
			mNamespace = "";
			mUID = "";
		}
 	 
  	// entry point called from main
  	bool testInitialize(int argc, char * argv[]);

		// 
		bool testCreateBatchAndSubmitSessions(const char* accountname,
																					const char* desc,
																					double units,
																					bool bUseSynch);


		// 
	  bool testLoadByUID(string UID, 
															string name, 
															string anamespace);

		// 
		bool testLoadByName(string name, 
											 	string anamespace, 
											 	string sequencenumber,
											 	int ID);
		//
		bool testMarkAsFailed(string UID, 
													string comment);

		//
		bool testMarkAsCompleted(string UID, 
														 string comment);

		//
		bool testMarkAsBackout(string UID, 
													 string comment);

		//
		bool testMarkAsDismissed(string UID, 
														 string comment);

		//
		bool testUpdateMeteredCount();

		//
		void testShutdown();

  	void PrintError(const char * prefix, const MTMeterError * err);

		// accessors and mutators
	  const int GetID() const { return mID; }
	  const string GetName() const { return mName; }
	  const string GetNamespace() const { return mNamespace; }
	  const string GetSource() const { return mSource; }
	  const string GetUID() const { return mUID; }
	  const string GetSequenceNumber() const { return mSequenceNumber; }

		//
		void dumpBatch(MTMeterBatch* batch);
	  
	private:
  	char *argvals[12];
  	char argdvals[12][256];
	
  	void usage();
 	 
  	// wait for a key and return its value
  	static int GetKey();
 	 
  	// configuration object - used to initialize the Metering SDK
  	// with HTTP transport
  	MTMeterHTTPConfig mConfig;
 	 
  	// the entry point to the Metering SDK - all Metering objects
  	// are created from here.
  	MTMeter mMeter;

		// batch local members
		int mID;
		string mName;
		string mNamespace;
		string mSource;
		string mUID;
		string mSequenceNumber;
};
	
//
//
//
void BatchTest::usage()
{
  cout << "Usage: \nbatchtest [-h host] [-n username] [-p password]\n  [-bh backuphost] -bn backupusername] -bp backuppassword]\n  [-a accountname] [-d description] [-t units] [-ssl y|n] [-sync y|n] [-port port]" << endl;
}

//
//
//
bool BatchTest::testInitialize(int argc, char * argv[])
{
  int i, j;

  for (i = 0; i < ARGCOUNT; i++) 
	{
    argvals[i] = NULL;
    *argdvals[i] = '\0';
  }

  if (argc == 2 &&
      (!strncmp(argv[1], "-u", 2) ||
       !strncmp(argv[1], "-?", 2) ||
       !strncmp(argv[1], "-help", 5))) 
	{
    usage();
    return NULL;
  }

  // Parse command line
  for (i = 1; i < argc; i++) 
	{
    if (argv[i][0] != '-') 
		{
      usage();
      return NULL;
    }
    for (j = 0; j < ARGCOUNT; j++) 
		{
      if (!strcmp(argv[i] + 1, args[j])) 
			{
				if (i + 1 == argc) 
				{
	  			// Need value
	  			usage();
	  			return NULL;
				}

				if (argv[i + 1][0] == '-') 
				{ 
					usage(); 
					return NULL; 
				}

				argvals[j] = argv[++i];
				break;
			}

			if (j == ARGCOUNT - 1) 
			{
				cout << "Error: unrecognized argument: " << argv[i] << endl;
				usage();
				return NULL;
      }
    } 
  }

	// initialize the SDK
	MTMeterError* err = NULL;
	if (!mMeter.Startup()) 
	{
		BatchTest test;
		test.PrintError("Could not initialize the SDK: ", err);
		return FALSE;
	}

	mConfig.AddServer(0,// priority (highest)
		    "a",			// hostname
				80,			// port
		    false,		// secure
		    "",			// username
		    "");	// password
  
  
  // pause, in case this is run from a shortcut
  //cout << "Press any key to continue..." << endl;
  //(void) GetKey();

	return TRUE;
}

//
//
//
void BatchTest::testShutdown()
{
  // close the sdk
  mMeter.Shutdown();
	return;
}

//
//
//
bool BatchTest::testCreateBatchAndSubmitSessions(
	const char *accountname,
	const char *desc, 
	double units, 
	bool bUseSynch)
{
  MTMeterBatch * batch = mMeter.CreateBatch();

  /* Seed the random-number generator with current time so that
   * the numbers will be different every time we run.
   */
  srand((unsigned)time(NULL));
	int randomNumber = rand();
	char  buffer[200];
	sprintf(buffer, "%d", randomNumber);

	time_t rawtime;
  struct tm * timeinfo;
  time ( &rawtime );
  timeinfo = localtime ( &rawtime );
  //printf ("Current date and time are: %s", asctime (timeinfo) );

	batch->SetName(buffer);
	batch->SetNameSpace("C++ SDK");
	batch->SetExpectedCount(10);
	batch->SetSource("C++ SDK");
	batch->SetSequenceNumber(buffer);
	batch->SetSourceCreationDate(rawtime);

	// ----------------------------------------------------------------------
	// save the batch
	if (!batch->Save())
		cout << "save failed" << endl;	

	// set the test batch attributes
	mUID = batch->GetUID();
	mName = batch->GetName();
	mNamespace = batch->GetNameSpace();
	mSequenceNumber = batch->GetSequenceNumber();
	mID = batch->GetBatchID();

	dumpBatch(batch);

	MTMeterSession * session;
  MTMeterSessionSet * sessionset = batch->CreateSessionSet();
  for (int i = 0; i < SESSIONS; i++)
  {
		session = sessionset->CreateSession("metratech.com/TestService");
    session->SetResultRequestFlag(false);
  
    // set the session's time field to the current time.
    time_t t = time(NULL);
  
    // these property names have to match those on the server
    if (!session->InitProperty("AccountName", accountname) || 
				!session->InitProperty("Description", desc) || 
				!session->InitProperty("Units", units*i) || 
				!session->InitProperty("Time", t, MTMeterSession::SDK_PROPTYPE_DATETIME))
    {
			MTMeterError* err = session->GetLastErrorObject();
			delete sessionset;
			return FALSE;
    }
  }

#if 0
  // send the session to the server
  if (!sessionset->Close()) 
	{
		MTMeterError* err = sessionset->GetLastErrorObject();
		delete session;
		delete err;
    return FALSE;
  }
#endif

  // sessions created with CreateSession must be deleted.
  delete sessionset;

	return TRUE;
}

//
//
//
bool BatchTest::testLoadByUID(string UID, 
												 string Name, 
												 string Namespace)

{
  MTMeterBatch * batch = mMeter.LoadBatchByUID(UID.c_str());
	if ((Name != batch->GetName()) ||
			(Namespace != batch->GetNameSpace()))
	{
		dumpBatch(batch);
		return FALSE;
	}
	
	return TRUE;
}

//
//
//
bool BatchTest::testLoadByName(string Name, 
															 string Namespace, 
															 string SequenceNumber,
															 int ID)
{
  MTMeterBatch * batch = mMeter.LoadBatchByName(Name.c_str(),
																								Namespace.c_str(),
																								SequenceNumber.c_str());
	if (ID != batch->GetBatchID())
	{
		dumpBatch(batch);
		return FALSE;
	}

	return TRUE;
}

//
//
//
bool BatchTest::testMarkAsFailed(string UID, string Comment)
{
  MTMeterBatch * batch = mMeter.LoadBatchByUID(UID.c_str());

	batch->SetComment("Marking as failed from C++ SDK");
	batch->MarkAsFailed();
	return TRUE;
}

//
//
//
bool BatchTest::testMarkAsCompleted(string UID, 
																		string Comment)
{
  MTMeterBatch * batch = mMeter.LoadBatchByUID(UID.c_str());

	batch->SetComment("Marking as completed from C++ SDK");
	batch->MarkAsCompleted();
	return TRUE;
}

//
//
//
bool BatchTest::testMarkAsBackout(string UID, 
																	string Comment)
{
  MTMeterBatch * batch = mMeter.LoadBatchByUID(UID.c_str());

	batch->SetComment("Marking as backout from C++ SDK");
	batch->MarkAsBackout();

	return TRUE;
}

//
//
//
bool BatchTest::testMarkAsDismissed(string UID, 
																		string Comment)
{
  MTMeterBatch * batch = mMeter.LoadBatchByUID(UID.c_str());

	batch->SetComment("Marking as dismissed from C++ SDK");
	batch->MarkAsDismissed();

	return TRUE;
}

//
//
//
void BatchTest::PrintError(const char * prefix, const MTMeterError* err)
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
	{
    cerr << "*UNKNOWN ERROR*" << endl;
  }
}


// wait for a key
//
//
int BatchTest::GetKey()
{
#ifdef _WIN32
  return _getch();
#else
  return getchar();
#endif
}

//
//
//
void BatchTest::dumpBatch(MTMeterBatch* b)
{
	cout << "---------------------------------------------------------" << endl;
	cout << "UID Encoded = " << b->GetUID() << endl;
	cout << "Name = " << b->GetName() << endl;
	cout << "Namespace = " << b->GetNameSpace() << endl;
	cout << "Status = " << b->GetStatus() << endl;
	time_t rawCreationDate = b->GetCreationDate();
  struct tm * creationDateInfo;
  time(&rawCreationDate);
  creationDateInfo = localtime (&rawCreationDate);
	cout << "Creation Date = " << asctime(creationDateInfo) << endl;
	cout << "Source = " << b->GetSource() << endl;
	cout << "Sequence Number = " << b->GetSequenceNumber() << endl;
	cout << "Completed Count = " << b->GetCompletedCount() << endl;
	cout << "Expected Count = " << b->GetExpectedCount() << endl;
	cout << "Failure Count = " << b->GetFailureCount() << endl;
	time_t rawSourceCreationDate = b->GetSourceCreationDate();
  struct tm * srcCreationDateInfo;
  time(&rawSourceCreationDate);
  srcCreationDateInfo = localtime (&rawSourceCreationDate);
	cout << "Source Creation Date = " << asctime(srcCreationDateInfo) << endl;
	cout << "---------------------------------------------------------" << endl;
	
	return;
}

//
//
//
int main(int argc, char * argv[])
{
  BatchTest test;

	// -----------------------------------------------------------------
	cout << "Initializing the test..." << endl;
  if (!test.testInitialize(argc, argv))
	{
		cout << "Initialize failed..." << endl;
		return -1;	
	}

	// -----------------------------------------------------------------
	cout << "Testing Creation..." << endl;
  if (!test.testCreateBatchAndSubmitSessions("demo",
																						 "C++ SDK",
																						 111.222,
																						 true))
	{
		cout << "CreateBatchAndSubmitSessions failed..." << endl;
		return -1;
  }

	// -----------------------------------------------------------------
	cout << "Testing LoadByUID..." << endl;
	if (!test.testLoadByUID(test.GetUID(),
													test.GetName(),
													test.GetNamespace()))
	{
		cout << "LoadByUID failed..." << endl;
		return -1;
  }

	// -----------------------------------------------------------------
	cout << "Testing LoadByName..." << endl;
  if (!test.testLoadByName(test.GetName(), 
														test.GetNamespace(), 
														test.GetSequenceNumber(), 
													 test.GetID()))
	{
		cout << "LoadByName failed..." << endl;
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Testing MarkAsFailed..." << endl;
	if (!test.testMarkAsFailed(test.GetUID(), "Marking batch as failed..."))
	{
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Testing MarkAsCompleted..." << endl;
	if (!test.testMarkAsCompleted(test.GetUID(), "Marking batch as completed..."))
	{
		cout << "MarkAsCompleted failed..." << endl;
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Testing MarkAsFailed..." << endl;
	if (!test.testMarkAsFailed(test.GetUID(), "Marking batch as failed..."))
	{
		cout << "MarkAsCompleted failed..." << endl;
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Testing MarkAsBackout..." << endl;
	if (!test.testMarkAsBackout(test.GetUID(), "Marking batch as backout..."))
	{
		cout << "MarkAsBackout failed..." << endl;
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Testing MarkAsDismissed..." << endl;
	if (!test.testMarkAsDismissed(test.GetUID(), "Marking batch as dismissed..."))
	{
		cout << "MarkAsDismissed failed..." << endl;
		return -1;
	}

	// -----------------------------------------------------------------
	cout << "Shutting down the test..." << endl;
  test.testShutdown();

	cout << "------- SUCCESS -------" << endl;

  return 0;
}
