/**************************************************************************
 * @doc MSMQHANDLER
 *
 * Copyright 2004 by MetraTech Corporation
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
 * Created by: Travis Gebhardt
 *
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#import "MTConfigLib.tlb"
#include <handler.h>
using namespace MTConfigLib;

#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <queue.h>
#include <MTMSIXUnicodeConversion.h>
#include <autocritical.h>
#include <perflog.h>


template <class _InsertStmt>
BOOL DBMessageHandler<_InsertStmt>::Initialize(MeterHandler * meterHandler,
																	const ListenerInfo & listenerInfo,
																	const PipelineInfo & pipelineInfo)
{
	if (!MessageHandler::Initialize(meterHandler, listenerInfo, pipelineInfo))
		return FALSE;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging"), "[dbhandler]");

	// initializes the parser for validation
	mParser.SetValidateOnly(TRUE);
	if (!mParser.InitForValidate(pipelineInfo))
	{
		SetError(mParser.GetLastError());
		mLogger.LogThis(LOG_ERROR, "Unable to initialize MSIX parser for validation");
		return FALSE;
	}

	return TRUE;
}



// NOTE: must be reentrant
template <class _InsertStmt>
BOOL DBMessageHandler<_InsertStmt>::HandleMessage(const char * apMessage, string & arOutput,
																		 BOOL aParseOnly, BOOL & arCompleteImmediately,
																		 void * apArg, 
																		 BOOL & requestCompleted,
																		 ValidationData & validationData)
{
	const char * functionName = "DBMessageHandler::HandleMessage";

	MarkRegion region("HandleMessage");

	// the parser is not thread safe
	// this lock also guards the DB product and underlying staging tables (CR12158)
	AutoCriticalSection lockit(&mParserLock);

	BOOL success = TRUE;

	requestCompleted = FALSE;
	
	PropertyCount propCount;
	propCount.total = 0;
	propCount.smallStr = 0;
	propCount.mediumStr = 0;
	propCount.largeStr = 0;
	validationData.mpPropCount = &propCount;

	DBSessionProduct<_InsertStmt>* results = NULL;
	try
	{
		MarkEnterRegion("ConvertToAscii");

		MTMSIXUnicodeConversion ConversionObj(apMessage);
		const char* pTemporaryStream = ConversionObj.ConvertToASCII();

		MarkExitRegion("ConvertToAscii");


		MarkEnterRegion("ValidateMSIX");

		BOOL requiresFeedback;
		BOOL requiresEncryption = FALSE;
		BOOL isRetry;

		success = ValidateMSIXMessage(pTemporaryStream,	strlen(pTemporaryStream),
																	&results,
																	validationData,
																	requiresEncryption);
		requiresFeedback = validationData.mRequiresFeedback;
		isRetry = validationData.mIsRetry;


		MarkExitRegion("ValidateMSIX");

		if (success)
		{
			BOOL sendToPipeline = TRUE;
			arCompleteImmediately = !requiresFeedback;

			std::string dbMessageID;;
			results->GetMessageUID(dbMessageID);

			if (success && requiresFeedback)
			{
				if (!mMeterHandler->PrepareForFeedback(validationData.mMessageID, /* MSIX message ID (external) */
																							 dbMessageID.c_str(),       /* DB message ID (internal) */
																							 apArg, isRetry,
																											requestCompleted, sendToPipeline))
				{
					SetError(mMeterHandler->GetLastError());
					success = FALSE;
				}
			}

			if (success && sendToPipeline)
			{
				MarkRegion spoolRegion("SpoolMessage");
				results->SpoolMessage();
			}
		}
	}
	catch (_com_error & err)
	{
		success = FALSE;
		string buffer;
		StringFromComError(buffer, "Error handling message", err);
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer.c_str());
	}
	// catches MTException, OdbcException and standard STL exceptions
	catch (std::exception & e)
	{
		success = FALSE;
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName, e.what());
	}
	catch (...)
	{
		success = FALSE;
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName, "Unknown exception caught");
#ifdef _DEBUG
		mLogger.LogThis(LOG_FATAL, "Unhandled exception caught and rethrown! "
										"Attach a debugger to the listener process and break on unhandled exceptions to debug.");
		throw;
#endif		
	}
	
	// if builder's results aren't cleaned up, db blocking can occur - always clean them up!
	if (results)
		delete results;

	return success;
}

template <class _InsertStmt>
BOOL DBMessageHandler<_InsertStmt>::ValidateMSIXMessage(const char * apMSIXStream, int aLen,
																					 DBSessionProduct<_InsertStmt>** results,
																					 ValidationData & arValidationData,
																					 BOOL & arRequiresEncryption)
{
	if (!mParser.SetupParser())
	{
		SetError(mParser);
		return FALSE;
	}

	// TODO: exception semantics
	if (!mParser.Validate(apMSIXStream, aLen, (ISessionProduct**) results, arValidationData))
	{
		SetError(mParser);
		return FALSE;
	}

	return TRUE;
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class DBMessageHandler<COdbcPreparedArrayStatement>;
template class DBMessageHandler<COdbcPreparedBcpStatement>;
