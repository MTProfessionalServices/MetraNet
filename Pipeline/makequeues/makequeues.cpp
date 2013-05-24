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
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <msmqlib.h>
#include <getopt.h>

#include <stdio.h>
#include <time.h>

#include <iostream>
using namespace std;

class MakeQueues
{
public:
	void Usage(const char * apProgName);
	int ParseArgs(int argc, char * * argv);
	int MakeRequiredQueues();
	BOOL MakeQueue(const char * apName, const char * apLabel, BOOL aJournal,
								 BOOL aTransactional);

private:
	BOOL mRoutingQueue;
	BOOL mErrorQueue;
	BOOL mAuditQueue;
	BOOL mFailedAuditQueue;
	BOOL mResubmitQueue;

	std::string mRoutingQueueName;
	std::string mErrorQueueName;
	std::string mAuditQueueName;
	std::string mFailedAuditQueueName;
	std::string mResubmitQueueName;

	BOOL mPrivate;
};

void MakeQueues::Usage(const char * apProgName)
{
	cout << "Usage: " << apProgName << " [options]" << endl
			 << "Options:" << endl
			 << "  -r [name] or" << endl
			 << "  -routingqueue[=name]   make the routing queue (name is optional)" << endl
			 << "  -e [name] or" << endl
			 << "  -errorqueue[=name]     make the error queue (name is optional)" << endl
			 << "  -a [name] or" << endl
			 << "  -auditqueue[=name]     make the audit queue (name is optional)" << endl
			 << "  -f [name] or" << endl
			 << "  -failedauditqueue[=name] make the failed audit queue (name is optional)" << endl
			 << "  -s [name] or" << endl
			 << "  -resubmitqueue[=name]  make the resubmit queue (name is optional)" << endl
			 << "  -all                   make all queues (with default names)" << endl
			 << "  -p or" << endl
			 << "  -public                create public queues (default is private)" << endl
			 << "  -usage                 print usage" << endl;
}

int MakeQueues::ParseArgs(int argc, char * * argv)
{
	// set the defaults;
	mRoutingQueue = FALSE;
	mAuditQueue = FALSE;
	mErrorQueue = FALSE;
	mFailedAuditQueue = FALSE;
	mResubmitQueue = FALSE;

	mRoutingQueueName = "RoutingQueue";
	mErrorQueueName = "ErrorQueue";
	mAuditQueueName = "AuditQueue";
	mFailedAuditQueueName = "FailedAuditQueue";
	mResubmitQueueName = "ResubmitQueue";

	mPrivate = TRUE;

  // the program name
  const char *progname = argv[0];
  // the default return value is initially 0 (success)
  int retval = 0;

	// use this while trying to parse a numeric argument
	//char ignored;

  // short options string
  char *shortopts = "s:i:p:d:t:ux";
  // long options list
  struct option longopts[] =
  {
    // name,						has_arg,								flag,		val    // longind
		{ "routingqueue",   optional_argument,      0,      'r' }, //       0
		{ "errorqueue",     optional_argument,      0,      'e' }, //       1
		{ "auditqueue",     optional_argument,      0,      'a' }, //       2
		{ "all",            no_argument,            0,      'x' }, //       3
		{ "public",         no_argument,            0,      'p' }, //       3
		{ "usage",          no_argument,            0,      'u' }, //       4
		{ "failedauditqueue", no_argument,          0,      'f' }, //       5
		{ "resubmitqueue",  no_argument,            0,      's' }, //       6
    // end-of-list marker
    { 0, 0, 0, 0 }
  };

  // long option list index
  int longind = 0;

	int optionsSupplied = 0;

  // during argument parsing, opt contains the return value from getopt()
  int opt;
	while ((opt = getopt_long_only(argc, argv, shortopts, longopts, &longind)) != EOF)
	{
		optionsSupplied++;
		switch (opt)
		{
		case 0:											// long option without equivalent short option
			break;
		case 'r':										// -routingqueue[=name]
			mRoutingQueue = TRUE;
			if (optarg)
				mRoutingQueueName = optarg;
			break;
		case 'e':										// -errorqueue[=name]
			mErrorQueue = TRUE;
			if (optarg)
				mErrorQueueName = optarg;
			break;
		case 'a':										// -auditqueue[=name]
			mAuditQueue = TRUE;
			if (optarg)
				mAuditQueueName = optarg;
			break;
		case 'f':										// -failedauditqueue[=name]
			mFailedAuditQueue = TRUE;
			if (optarg)
				mFailedAuditQueueName = optarg;
			break;
		case 's':										// -resubmitqueue[=name]
			mResubmitQueue = TRUE;
			if (optarg)
				mResubmitQueueName = optarg;
			break;
		case 'x':										// -all
			mRoutingQueue = TRUE;
			mAuditQueue = TRUE;
			mErrorQueue = TRUE;
			mFailedAuditQueue = TRUE;
			mResubmitQueue = TRUE;
			break;
		case 'p':										// -public
			mPrivate = FALSE;
			break;
		default:
			optionsSupplied--;
//			cerr << progname
//					 << " getopt_long_only unexpectedly returned " << opt << endl;
			return 1;
		}
	}

	if (optionsSupplied == 0)
	{
		Usage(progname);
		return 1;
	}

	return 0;
}

int MakeQueues::MakeRequiredQueues()
{
	if (!mPrivate)
		cout << "Public queues will be created" << endl;

	if (mRoutingQueue)
	{
		cout << "Creating routing queue with name " << mRoutingQueueName.c_str() << endl;
		MakeQueue(mRoutingQueueName.c_str(), "Routing Queue", TRUE, FALSE);
	}

	if (mErrorQueue)
	{
		cout << "Creating error queue with name " << mErrorQueueName.c_str() << endl;
		MakeQueue(mErrorQueueName.c_str(), "Error Queue", FALSE, TRUE);
	}

	if (mAuditQueue)
	{
		cout << "Creating audit queue with name " << mAuditQueueName.c_str() << endl;
		MakeQueue(mAuditQueueName.c_str(), "Audit Queue", FALSE, FALSE);
	}

	if (mFailedAuditQueue)
	{
		cout << "Creating failed audit queue with name " << mFailedAuditQueueName.c_str() << endl;
		MakeQueue(mFailedAuditQueueName.c_str(), "Failed Audit Queue", FALSE, TRUE);
	}

	if (mResubmitQueue)
	{
		cout << "Creating resubmit queue with name " << mResubmitQueueName.c_str() << endl;
		MakeQueue(mResubmitQueueName.c_str(), "Resubmit Queue", TRUE, TRUE);
	}

	cout << "All queues created." << endl;
	return 0;
}

void LocalASCIIToWide(wchar_t * apBuffer, const char * apAscii, int aBufferLen)
{
	int asclen = strlen(apAscii);

	int len = MultiByteToWideChar(
		CP_ACP,											// code page
		0,													// character-type options
		apAscii,										// address of string to map
		asclen,											// number of bytes in string
		NULL,												// address of wide-character buffer
		0);													// size of buffer

		//wchar_t * out = new wchar_t[len];

	(void) MultiByteToWideChar(
		CP_ACP,											// code page
		0,													// character-type options
		apAscii,										// address of string to map
		asclen,											// number of bytes in string
		apBuffer,										// address of wide-character buffer
		aBufferLen);								// size of buffer

	apBuffer[len] = '\0';
}

void PrintError(const char * apStr, const ErrorObject * obj)
{
	cout << apStr << ": " << hex << obj->GetCode() << dec << endl;
	string message;
	obj->GetErrorMessage(message, true);
	cout << message << "(";
	const std::string & detail = obj->GetProgrammerDetail().c_str();
	cout << detail << ')' << endl;

	if (strlen(obj->GetModuleName()) > 0)
		cout << " module: " << obj->GetModuleName() << endl;
	if (strlen(obj->GetFunctionName()) > 0)
		cout << " function: " << obj->GetFunctionName() << endl;
	if (obj->GetLineNumber() != -1)
		cout << " line: " << obj->GetLineNumber() << endl;

	char * theTime = ctime(obj->GetErrorTime());
	cout << " time: " << theTime << endl;
}


BOOL MakeQueues::MakeQueue(const char * apName, const char * apLabel, BOOL aJournal, BOOL aTransactional)
{
	MessageQueue msgq;

	MessageQueueProps props;


	wchar_t label[256];
	LocalASCIIToWide(label, apLabel, sizeof(label) / 2);

	props.SetLabel(label);

	props.SetJournal(aJournal);
	props.SetTransactional(aTransactional);


	wchar_t queueName[512];
	LocalASCIIToWide(queueName, apName, sizeof(queueName) / 2);

	if (!msgq.CreateQueue(queueName, mPrivate, props))
	{
		HRESULT code = msgq.GetLastError()->GetCode();
		if (code == MQ_ERROR_QUEUE_EXISTS)
		{
			cout << "ERROR: Queue " << apName << " already exists!" << endl;
			return FALSE;
		}
		PrintError("ERROR: Unable to create queue", msgq.GetLastError());
		return FALSE;
	}
	return TRUE;
}

int main(int argc, char *argv[])
{
	MakeQueues makeQueues;
	int retVal = makeQueues.ParseArgs(argc, argv);
	if (retVal != 0)
		return retVal;

	return makeQueues.MakeRequiredQueues();
}
