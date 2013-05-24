/**************************************************************************
 * @doc RESUBMIT
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | RESUBMIT
 ***************************************************************************/

#ifndef _RESUBMIT_H
#define _RESUBMIT_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <NTLogger.h>
#include <msmqlib.h>

#import <PipelineControl.tlb> rename("EOF", "RowsetEOF")

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <MetraTech.Pipeline.Messages.tlb> inject_statement("using namespace mscorlib;")

class PipelineInfo;
struct PropertyCount;

/****************************************** PipelineResubmit ***/

class PipelineResubmit : public virtual ObjectWithError
{
public:
	PipelineResubmit();
	virtual ~PipelineResubmit();

	BOOL Init(const PipelineInfo & arPipelineInfo);

	BOOL SpoolMessage(const char * apMessage,
										const wchar_t * apUID,
										PropertyCount & arPropCount,
										QueueTransaction * apTran,
										int aMessageLen = 0);
private:
	NTLogger mLogger;

	MessageQueue mResubmitQueue;

	PIPELINECONTROLLib::IMTPipelinePtr mPipelineControl;

	// utility class to compress/encrypt messages
	MetraTech_Pipeline_Messages::IMessageUtilsPtr mMessageUtils;
};


#endif /* _RESUBMIT_H */
