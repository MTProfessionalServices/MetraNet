/**************************************************************************
 * @doc CONTROLUTILS
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
 * @index | CONTROLUTILS
 ***************************************************************************/

#ifndef _CONTROLUTILS_H
#define _CONTROLUTILS_H

#include <msmqlib.h>
#include <pipemessages.h>

#import <PipelineControl.tlb> rename("EOF", "RowsetEOF")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")

HRESULT GetMessageBodyFromQueue(MessageQueue & arQueue,
																const wchar_t * apSessionID,
																std::string & arBody,
																int & arAppSpecific,
																PropertyCount & arPropCount);

HRESULT GetMessageBodyFromQueue(MessageQueue & arQueue,
																const wchar_t * apSessionID,
																unsigned char * * apBody,
																int * apBodyLength,
																int & arAppSpecific,
																PropertyCount & arPropCount);

HRESULT RemoveFromQueue(MessageQueue & arQueue,
												const wchar_t * apSessionID,
												PIPELINECONTROLLib::IMTTransactionPtr aTxn);

HRESULT SpoolMessage(MessageQueue & arMessageQueue,
										 const char * apMessage,
										 int aMessageLen,
										 const wchar_t * apUID, BOOL aExpress,
										 PropertyCount & arPropCount,
										 PIPELINECONTROLLib::IMTTransactionPtr aTxn);

HRESULT DecryptMessage(const unsigned char * apMessage, int aMessageLength,
											 std::string & arDecrypted,
											 MetraTech_Pipeline_Messages::IMessageUtilsPtr aMessageUtils = NULL);

#endif /* _CONTROLUTILS_H */
