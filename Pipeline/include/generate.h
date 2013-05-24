/**************************************************************************
 * @doc GENERATE
 *
 * @module |
 *
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
 *
 * @index | GENERATE
 ***************************************************************************/

#ifndef _GENERATE_H
#define _GENERATE_H

#include <genparser.h>
#include <MSIX.h>
#include <NTLogger.h>
#include <pipelineconfig.h>
#include <ServicesCollection.h>
#include <pipemessages.h>
#include <batchsupport.h>
#include <flow.h>
#include <mtcryptoapi.h>
#import <MTEnumConfigLib.tlb>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.Messages.tlb> \
  inject_statement("using namespace mscorlib;")

/*********************************** PipelineObjectGenerator ***/

typedef list<MSIXSession *> MSIXSessionList;
typedef std::vector<MTPipelineLib::IMTSessionPtr> SessionObjectVector;

class PipelineObjectGenerator : public ObjectWithError
{
public:
	PipelineObjectGenerator();
	virtual ~PipelineObjectGenerator();

	BOOL Init(const PipelineInfo & arPipelineInfo,
						MTPipelineLib::IMTSessionServerPtr aSessionServer);

	// if the message has a batch ID, the apUID will be filled in.
	// otherwise it's left untouched.
	BOOL ParseAndGenerate(const char * apMessage,
												unsigned long bufferSize,
												SessionObjectVector & arSessionObjects,
												PipelineFlowControl * apFlowControl,
												unsigned char * apUID,
												int * apSessionCount,
												ValidationData & arParsedData,
												BOOL aIgnoreDefaults = FALSE,
												BOOL aIgnoreOptionals = FALSE);

	BOOL GenerateSession(MSIXTimestamp aTimestamp,
											 const wchar_t * apIPAddress,
											 MSIXSession * apSess,
											 MTPipelineLib::IMTSessionPtr & arSessionObj,
											 BOOL aIgnoreDefaults = FALSE,
											 BOOL aIgnoreOptionals = FALSE);

	BOOL ParseSessions(const char * apMSIXStream,
										 MSIXTimestamp & arTimestamp,
										 std::wstring & arIPAddress,
										 MSIXSessionList & arSessions);

private:
	BOOL AddSessionProperties(MSIXTimestamp aTimestamp,
														const wchar_t * apIPAddress,
														MTPipelineLib::IMTSessionPtr aSession,
														CMSIXDefinition * apService,
														MSIXSession * apMSIXSession,
														BOOL aIgnoreDefaults,
														BOOL aIgnoreOptionals);

	BOOL AddInitialProperties(time_t aMeteredTime,
														const wchar_t * apIPAddress,
														MTPipelineLib::IMTSessionPtr aSession);

	BOOL GetService(MSIXSession * apSess, CMSIXDefinition * & apService);

	// parse a straight XML MSIX message
	BOOL ParseMSIXMessage(MSIXParser & arParser,
												const char * apMSIXStream,
												MSIXTimestamp & arTimestamp,
												std::wstring & arIPAddress,
												MSIXSessionList & arSessions);


	BOOL ParseAndGenerateMSIXMessage(
		const char * apMSIXStream,
		int aLen,
		SessionObjectVector & arSessionObjects,
		PipelineFlowControl * arFlowControl,
		unsigned char * apUID,
		ValidationData & arParsedData,
		BOOL aIgnoreDefaults,
		BOOL aIgnoreOptionals);


private:

	enum { UID_LENGTH = 16 };

	MTPipelineLib::IMTNameIDPtr mNameID;
  NTLogger mLogger;
	MTPipelineLib::IMTSessionServerPtr mSessionServer;

	CServicesCollection mServices;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;

	// used for decryption of messages from the listener
	// and re-encryption of encrypted properties
  CMTCryptoAPI mCrypto;

	// fast parser used to parse messages and generate objects in place
	PipelineMSIXParser<SharedMemorySessionBuilder> mParser;

	// utility class to compress/encrypt messages
	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;
};

#endif /* _GENERATE_H */
