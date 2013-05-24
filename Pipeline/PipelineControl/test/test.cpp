/**************************************************************************
 * @doc TEST
 *
 * Copyright 1999 by MetraTech Corporation
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>

#include <mtcom.h>

#import <PipelineControl.tlb> rename ("EOF", "RowsetEOF")
using namespace PIPELINECONTROLLib;

#import <MetraTech.Pipeline.ReRun.tlb>
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#include <mtprogids.h>

#include <iostream>

#include <SetIterate.h>
#include <stdutils.h>
#include <MTUtil.h>
#include <errobj.h>
#include <MTDec.h>
#include <mtglobal_msg.h>
#include <conio.h>
#include <NTLogger.h>
#include <loggerconfig.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib;") \
     inject_statement("using ROWSETLib::IMTSQLRowsetPtr;") \
     inject_statement("using ROWSETLib::IMTSQLRowset;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaData;") \
     inject_statement("using MTProductCatalogInterfacesLib::IMTSessionContext;")

using namespace std;

static ComInitialize gComInitialize;
NTLogger mLogger;


BOOL DumpErrors(BOOL aAllInfo, BOOL aWithMessage)
{
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);

	failures->Refresh();

	SetIterator<IMTSessionFailuresPtr, IMTSessionErrorPtr> it;
	HRESULT hr = it.Init(failures);
	if (FAILED(hr))
	{
		cout << "couldn't initialize" << endl;
		return FALSE;
	}
	
	while (TRUE)
	{
		IMTSessionErrorPtr error = it.GetNext();
		if (error == NULL)
			break;

		DATE oleDate;
		time_t sessionTime;

		cout << "-----------------------------" << endl;
		cout << "Root SessionID: " << (const char *) error->GetRootSessionID() << endl;
		cout << "Session ID: " << (const char *) error->GetsessionID() << endl;
		cout << "Session Set ID: " << (const char *) error->GetSessionSetID() << endl;
		cout << "IP Address: " << (const char *) error->GetIPAddress() << endl;

		oleDate = error->GetMeteredTime();
		TimetFromOleDate(&sessionTime, oleDate);
		cout << "Metered at: " << ctime(&sessionTime);

		oleDate = error->GetFailureTime();
		TimetFromOleDate(&sessionTime, oleDate);
		cout << "Failed at: " << ctime(&sessionTime);

		cout << "Error Message: " << (const char *) error->GetErrorMessage() << endl;
		cout << "Error Code: 0x" << hex << error->GetErrorCode() << dec << endl;

		Message msg(error->GetErrorCode());
		string codeText;
		msg.GetErrorMessage(codeText, true);

		cout << "Error Code String: " << codeText.c_str() << endl;
		cout << "Stage Name: " << (const char *) error->GetStageName() << endl;
		cout << "PlugIn Name: " << (const char *) error->GetPlugInName() << endl;

		if (aAllInfo)
		{
			cout << "Module Name: " << (const char *) error->GetModuleName() << endl;
			cout << "Procedure Name: " << (const char *) error->GetProcedureName() << endl;
			cout << "Line Number: " << error->GetLineNumber() << endl;
		}
		if (aWithMessage)
		{
			cout << "Message: " << endl;
			cout << (const char *) error->GetXMLMessage() << endl;
		}
	}

	return TRUE;
}

BOOL AbandonSession(const char * apSessionID)
{
	mLogger.LogVarArgs(LOG_INFO, "Abandoning session %s", apSessionID);
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	failures->AbandonSession(apSessionID);
	mLogger.LogVarArgs(LOG_INFO, "Finished abandoning session %s", apSessionID);
	return TRUE;
}

BOOL DeleteSuspendedMessage(const char * apMessageID)
{
	mLogger.LogVarArgs(LOG_INFO, "Abandoning suspended message %s", apMessageID);
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	failures->AbandonLostSession(apMessageID);
	mLogger.LogVarArgs(LOG_INFO, "Finished abandoning suspended message %s", apMessageID);
	return TRUE;
}


BOOL ResubmitSession(const char * apSessionID)
{
	mLogger.LogVarArgs(LOG_INFO, "Resubmitting session %s", apSessionID);
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	failures->ResubmitSession(apSessionID);
	mLogger.LogVarArgs(LOG_INFO, "Finished resubmitting session %s", apSessionID);
	return TRUE;
}

BOOL ResubmitSuspendedMessage(const char * apMessageID)
{
	mLogger.LogVarArgs(LOG_INFO, "Resubmitting suspended message %s", apMessageID);
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	failures->ResubmitLostSession(apMessageID);
	mLogger.LogVarArgs(LOG_INFO, "Finished resubmitting suspended message %s", apMessageID);
	return TRUE;
}

BOOL AbandonAllSessions()
{
	mLogger.LogThis(LOG_INFO, "Abandon/Delete all failed sessions started");
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	failures->Refresh();

  // Use the bulk API's for resubmission.
  GUID guid = __uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions);
	MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed = MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr(guid);

  // Iterate through all the failed sessions.
	SetIterator<IMTSessionFailuresPtr, IMTSessionErrorPtr> it;
	HRESULT hr = it.Init(failures);
	if (FAILED(hr))
	{
		cout << "couldn't initialize" << endl;
		mLogger.LogThis(LOG_ERROR, "Abandon/Delete all failed sessions failed");
		return FALSE;
	}

  long retCount;
  failures->get_Count(&retCount);
  cout << retCount << " sessions found for Abandon/Delete" << endl;
  mLogger.LogVarArgs(LOG_INFO, "%d sessions found for Abandond/Delete", retCount);

  // Log and add sessions to to collection to abandon.
  IMTSessionErrorPtr error = NULL;
  long failureCount = 0;
  long totalDel = 0;

  while(TRUE)
  {
    PIPELINECONTROLLib::IMTCollectionPtr set(MTPROGID_MTCOLLECTION);

	  while (++failureCount % 100001 != 0 && (error = it.GetNext()) != NULL)
	  {
		  _bstr_t sessionID = error->GetRootSessionID();
		  cout << "Abandoning session " << (const char *) sessionID << endl;
		  mLogger.LogVarArgs(LOG_INFO, "Abandoning session: %s.", (const char *)sessionID);
      set->Add(sessionID);
    }
    
    // Abandon failed sessions.
    if (set->GetCount())
    {
      totalDel += set->GetCount();
      PIPELINECONTROLLib::IMTProgressPtr progress = NULL; // Don't need progress
      bulkFailed->DeleteCollection(set, progress);
    }
    else
    {
      break;
    }
  }

  if(failureCount > 0)
  {
    mLogger.LogVarArgs(LOG_INFO, "Abandon/Delete all failed sessions completed. (%d sessions)", totalDel);
  }
  else
  {
    mLogger.LogThis(LOG_INFO, "No sessions found to delete.");
  }
  // Done.
	return TRUE;
}

BOOL ResubmitAllSessions()
{
  mLogger.LogThis(LOG_INFO, "Resubmit all failed sessions started");

  // Use the bulk API's for resubmission.
  GUID guid = __uuidof(MetraTech_Pipeline_ReRun::BulkFailedTransactions);
  MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr bulkFailed = MetraTech_Pipeline_ReRun::IBulkFailedTransactionsPtr(guid);

 
   int numResubmitted = 0;
   numResubmitted =  bulkFailed->ResubmitAll();
   if (numResubmitted > 0)
   {
     mLogger.LogVarArgs(LOG_INFO, "Resubmit all (%d) failed sessions completed.", numResubmitted);
	 cout << "Resubmitted all (" << numResubmitted << ")failed sessions.  This total includes parents and children." << endl;
   }
   else
   {
    mLogger.LogThis(LOG_INFO, "No sessions found to resubmit.");
	cout << "No failed sessions found to resubmit." << endl;
   }

  // Done.
  return TRUE;
}

BOOL DumpMessage(const char * apSessionID)
{
	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	_variant_t var = failures->GetItem(apSessionID);
	IMTSessionErrorPtr error = var;

	_bstr_t message = error->GetXMLMessage();

	cout << "---- Message ----" << endl;
	cout << (const char *) message << endl;

	return TRUE;
}

BOOL DumpLostMessage(const char * apSessionID)
{
	IMTPipelinePtr pipeline(MTPROGID_PIPELINE);
	_bstr_t message = pipeline->GetLostMessage(apSessionID);

	cout << "---- Message ----" << endl;
	cout << (const char *) message << endl;

	return TRUE;
}

void PrintSession(_bstr_t parentUid, MTPipelineLib::IMTSessionServerPtr aServer,
									MTPipelineLib::IMTSessionPtr aSession)
{
	if (!parentUid)
		;
	else
		cout << "Parent UID: " << (const char *) parentUid << endl;

	_bstr_t uid = aSession->GetUIDAsString();
	cout << "UID: " << (const char *) uid << endl;

	SetIterator<MTPipelineLib::IMTSessionPtr, MTPipelineLib::IMTSessionPropPtr> it;
	HRESULT hr = it.Init(aSession);
	if (FAILED(hr))
	{
		cout << "Unable to initialize iterator" << endl;
		return;
	}

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPropPtr prop = it.GetNext();
		if (prop == NULL)
			break;

		_bstr_t bstrName = prop->GetName();

		string name = bstrName;
		StrToLower(name);
		cout << name;

		int spaces = 25 - name.length();
		for (int i = 0; i < spaces; i++)
			cout << ' ';

		MTPipelineLib::MTSessionPropType type = prop->Gettype();
		long nameid = prop->GetNameID();

		time_t timeVal;
		long longVal;
		__int64 int64Val;
		_bstr_t stringVal;
		double doubleVal;
		MTDecimal decVal;
		VARIANT_BOOL boolVal;
		const char * dateString;
		string timeString;

		switch (type)
		{
		case MTPipelineLib::SESS_PROP_TYPE_DATE:
			cout << "DATE\t\t";
			timeVal = aSession->GetDateTimeProperty(nameid);
			dateString = ctime(&timeVal);
			cout << dateString;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_TIME:
			longVal = aSession->GetTimeProperty(nameid);	
			// NOTE: casted to int
			cout << "TIME\t\t";
			MTFormatTime(longVal, timeString);
			cout << timeString << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_STRING:
			stringVal = aSession->GetBSTRProperty(nameid);
			cout << "STRING\t\t" << (const char *) stringVal << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONG:
			longVal = aSession->GetLongProperty(nameid);
			// NOTE: casted to int
			cout << "LONG\t\t" << longVal << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_LONGLONG:
			int64Val = aSession->GetLongLongProperty(nameid);
			cout << "LONGLONG\t\t" << int64Val << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DOUBLE:
			doubleVal = aSession->GetDoubleProperty(nameid);
			cout << "DOUBLE\t\t" << doubleVal << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_DECIMAL:
			decVal = aSession->GetDecimalProperty(nameid);
			cout << "DECIMAL\t" << decVal.Format().c_str() << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_BOOL:
			boolVal = aSession->GetBoolProperty(nameid);
			// TODO: is this the correct way to handle booleans?
			cout << "BOOL\t\t" << ((boolVal == VARIANT_TRUE) ? "TRUE" : "FALSE") << endl;
			break;

		case MTPipelineLib::SESS_PROP_TYPE_ENUM:
		{
			// TODO: it would be nice to get the string, not the number here,
			// but the string will work fine for now.  Also, have to watch the overhead
			// of the enum config object
			MTPipelineLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);
			_bstr_t value =
				enumConfig->GetEnumeratorValueByID(aSession->GetEnumProperty(nameid));
			cout << "ENUM\t\t" << ((const char *) value) << endl;
			break;
		}

			ASSERT(0);
		}

	}

	cout << endl;

	// could be a parent.  mark children as complete
	MTPipelineLib::IMTSessionSetPtr set = aServer->CreateSessionSet();
	aSession->AddSessionDescendants(set);

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> sessionit;
	hr = sessionit.Init(set);
	if (FAILED(hr))
	{
		cout << "Unable to initialize iterator" << endl;
		return;
	}
	
	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = sessionit.GetNext();
		if (session == NULL)
			break;

		PrintSession(uid, aServer, session);
	}
}

BOOL ExamineSession(const char * apSessionID)
{
	IMTPipelinePtr pipeline(MTPROGID_PIPELINE);
	MTPipelineLib::IMTSessionServerPtr server = pipeline->GetSessionServer();

	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	_variant_t var = failures->GetItem(apSessionID);
	IMTSessionErrorPtr error = var;

	MTPipelineLib::IMTSessionPtr session =
		(MTPipelineLib::IMTSession *) error->Getsession().GetInterfacePtr();

	_bstr_t parent;
	PrintSession(parent, server, session);
	return TRUE;
}

BOOL ExportSession(const char * apSessionID)
{
	IMTPipelinePtr pipeline(MTPROGID_PIPELINE);
	MTPipelineLib::IMTSessionServerPtr server = pipeline->GetSessionServer();

	IMTSessionFailuresPtr failures(MTPROGID_SESSIONFAILURES);
	_variant_t var = failures->GetItem(apSessionID);
	IMTSessionErrorPtr error = var;


	try
	{
		_bstr_t buffer =
			pipeline->ExportSession(error->Getsession());

		cout << (const char *) buffer << endl;
	}
	catch (_com_error & err)
	{
		if (err.Error() == MTAUTH_ACCESS_DENIED)
		{
			//
			// prompt for user name and password.  this is a little
			// ugly because we want to obscure the password
			//
			cout << "authorization needed" << endl;
			cout << "enter username: ";
			cout.flush();

			char usernamebuffer[280];
			// the first byte is the length of the string
			usernamebuffer[0] = (char) 255;
			char * username = _cgets(usernamebuffer);

			cout << "enter password (hidden): ";
			cout.flush();
			char password[256];
			int ch;
			int i = 0;
			while ((ch = _getch()) != '\r')
			{
				password[i++] = ch;
				_putch('*');
			}

			password[i] = '\0';

			cout << endl;

			//
			// login as the user
			//
			pipeline->Login(username, "system_user", password);

			//
			// try again
			//
			_bstr_t buffer =
				pipeline->ExportSession(error->Getsession());

			cout << (const char *) buffer << endl;
		}
	}



	return TRUE;
}

void PauseAllProcessing()
{
	cout << "Pausing all pipelines and waiting for exisiting work to complete..." << endl;

	MetraTech_Pipeline::IPipelineManagerPtr pipeline(__uuidof(MetraTech_Pipeline::PipelineManager));
	pipeline->PauseAllProcessing();

	cout << "All pipelines have successfully been paused" << endl;
}

void ResumeAllProcessing()
{
	MetraTech_Pipeline::IPipelineManagerPtr pipeline(__uuidof(MetraTech_Pipeline::PipelineManager));
	pipeline->ResumeAllProcessing();

	cout << "All pipelines have successfully resumed processing" << endl;
}


void Usage()
{
	cout << "Usage: controlpipeline <command>" << endl;
	cout << endl;
	cout << "Failed transaction commands:" << endl;
	cout << " -resubmit <uid>          Resubmit a failed session with the given UID" << endl;
	cout << " -delete <uid>            Deletes the failed session with the given UID" << endl;
	cout << " -export <uid>            Export a failed session with the given UID" << endl;
  cout << " -message <uid>           Display msix message for the failed session" << endl;
	cout << "                          with the given UID " << endl;
	cout << " -examine <uid>           Display all properties for the failed session" << endl;
	cout << "                          with the given UID" << endl;
	cout << " -resubmitall             Resubmits all failed sessions" << endl;
	cout << " -deleteall               Deletes all failed sessions" << endl;
	cout << endl;
	cout << "Suspended transaction commands:" << endl;
	cout << " -resubmitsuspended <mid> Resubmits a suspended message with the given" << endl;
	cout << "                          message ID" << endl;
	cout << " -deletesuspended <mid>   Deletes a suspended message with the given" << endl;
	cout << "                          message ID" << endl;

	// TODO: not yet supported in 4.0
  //  cout << " -suspendedmessage <mid>  Displays msix message for the suspended message" << endl;
  //	cout << "                          with the given ID " << endl;

	cout << endl;
	cout << "General pipeline commands:" << endl;
	cout << " -pause                   Pauses all pipeline processing" << endl;
	cout << " -resume                  Resumes all pipeline processing" << endl;


	cout << endl << endl;
	cout << "With no arguments, controlpipeline displays a summary of all failures." << endl;
}

int main(int argc, char * argv[])
{
	try
	{
		// add code to make sure that the logging level is set to info or higher.
		LoggerConfigReader configReader;
		if(!mLogger.Init(configReader.ReadConfiguration("logging"), "[ControlPipeline]"))
		{
			cout << "Could not initialize logger." << endl;
			return 1;
		}
		if (!(mLogger.IsOkToLog(LOG_INFO)))
		{
			cout << "Log level should at least be set at the info level to use this utility. " << endl;
			cout << "Please fix the log level and then try again." << endl;
			return 1;
		}

		if (argc == 2 && 0 == strcmpi(argv[1], "/?"))
		{
			Usage();
			return 1;
		}

		if (argc == 1)
		{
			if (!DumpErrors(FALSE, FALSE))
				cout << "Error dumping errors" << endl;
			else
				cout << endl << "Errors dumped successfully" << endl;
		}
		else if (argc == 2)
		{
			if (0 == strcmpi(argv[1], "-deleteall")
					|| 0 == strcmpi(argv[1], "-abandonall"))
			{
				if (!AbandonAllSessions())
					cout << "Error abandoning all sessions" << endl;
				else
					cout << "All failed sessions abandoned" << endl;
			}
			else if (0 == strcmpi(argv[1], "-resubmitall"))
			{
				if (!ResubmitAllSessions())
					cout << "Error resubmitting all sessions" << endl;
				else
					cout << "All failed sessions resubmitted" << endl;
			}
			else if (0 == strcmpi(argv[1], "-pause"))
			{
				PauseAllProcessing();
			}
			else if (0 == strcmpi(argv[1], "-resume"))
			{
				ResumeAllProcessing();
			}
		}
		else if (argc == 3)
		{
			if (0 == strcmpi(argv[1], "-abandon")
				|| 0 == strcmpi(argv[1], "-delete"))
			{
				if (!AbandonSession(argv[2]))
					cout << "Error abandoning sessions" << endl;
				else
					cout << "Session successfully abandoned" << endl;
			}
			else if (0 == strcmpi(argv[1], "-abandonlost") ||
							 0 == strcmpi(argv[1], "-deletelost") ||
							 0 == strcmpi(argv[1], "-deletesuspended"))
			{
				if (!DeleteSuspendedMessage(argv[2]))
					cout << "Error deleting suspended message" << endl;
				else
					cout << "Message successfully deleted" << endl;
			}
			else if (0 == strcmpi(argv[1], "-message"))
			{
				if (!DumpMessage(argv[2]))
					cout << "Error dumping message" << endl;
			}

			// TODO: not yet supported with DB queues
/*
			else if ((0 == strcmpi(argv[1], "-lostmessage")) ||
							 (0 == strcmpi(argv[1], "-suspendedmessage")))
			{
				if (!DumpLostMessage(argv[2]))
					cout << "Error dumping suspended message" << endl;
			}
*/
			else if (0 == strcmpi(argv[1], "-examine"))
			{
				if (!ExamineSession(argv[2]))
					cout << "Error examining message" << endl;
			}
			else if (0 == strcmpi(argv[1], "-resubmit"))
			{
				if (!ResubmitSession(argv[2]))
					cout << "Error resubmitting message" << endl;
				else
					cout << "Session successfully resubmitted" << endl;
			}
			else if ((0 == strcmpi(argv[1], "-resubmitlost")) ||
							 (0 == strcmpi(argv[1], "-resubmitsuspended")))
			{
				if (!ResubmitSuspendedMessage(argv[2]))
					cout << "Error resubmitting suspended message" << endl;
				else
					cout << "Message successfully resubmitted" << endl;
			}
			else if (0 == strcmpi(argv[1], "-export"))
			{
				if (!ExportSession(argv[2]))
					cout << "Error exporting message" << endl;
			}
		}
	}
	catch (_com_error err)
	{
		cout << "_com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;

		// argh... looks like logger isn't always flushing if we fail fast enough
		// sleep just long enough for a final flush
		Sleep(750);

		return -1;
	}

	return 0;
}

