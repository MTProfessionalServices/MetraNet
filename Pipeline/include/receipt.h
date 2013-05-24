/**************************************************************************
 * @doc RECEIPT
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 * @index | RECEIPT
 ***************************************************************************/

#ifndef _RECEIPT_H
#define _RECEIPT_H

#include <errobj.h>
#include <NTLogger.h>
#include <msmqlib.h>

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

/******************************************** SessionReceipt ***/

class MSIXSession;

class SessionReceipt : public ObjectWithError
{
public:
	SessionReceipt();
	virtual ~SessionReceipt();

	BOOL Init(const wchar_t * apMachineName, const wchar_t * apQueueName,
						const wchar_t * apFailedReceiptMachine,
						const wchar_t * apFailedQueueName,
						BOOL aPrivate);

	BOOL SendReceiptOfSuccess(MTPipelineLib::IMTSessionPtr aSession, BOOL aExpress);
	BOOL SendReceiptOfSuccess(MTPipelineLib::IMTSessionSetPtr aSet, BOOL aExpress);

	BOOL SendReceiptOfError(MTPipelineLib::IMTSessionPtr aSession,
													QueueTransaction & arTran, BOOL aExpress);
	BOOL SendReceiptOfError(MTPipelineLib::IMTSessionSetPtr aSet,
													QueueTransaction & arTran, BOOL aExpress);

private:
	BOOL SendReceiptInternal(unsigned char * apUID, BOOL aFailed,
													 QueueTransaction * apTran, BOOL aExpress,
													 long aServiceID);

	MessageQueue mReceiptQueue;
	MessageQueue mFailedReceiptQueue;

	NTLogger mLogger;
};

#endif /* _RECEIPT_H */
