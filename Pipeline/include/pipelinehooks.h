/**************************************************************************
 * @doc PIPELINEHOOKS
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
 * @index | PIPELINEHOOKS
 ***************************************************************************/

#ifndef _PIPELINEHOOKS_H
#define _PIPELINEHOOKS_H

#include <errobj.h>

#import "MTPipelineLibExt.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

class PipelineHooks : public ObjectWithError
{
public:
	BOOL ReadHookFile(MTPipelineLib::IMTConfigPtr aConfig,
										MTPipelineLib::IMTConfigPropSetPtr & arPropset);


	BOOL SetupHookHandler(MTPipelineLib::IMTConfigPropSetPtr aPropSet,
												const char * apSetName);

	BOOL HooksRequired() const
	{ return mHooksRequired; }

	void ExecuteAllHooks(_variant_t aArg1, unsigned long aArg2)
	{
		mHandler->ExecuteAllHooks(aArg1, aArg2);
	}

	void ClearHooks()
	{
		mHandler->ClearHooks();
	}

private:
	MTPipelineLibExt::IMTHookHandlerPtr mHandler;
	BOOL mHooksRequired;
};

#endif /* _PIPELINEHOOKS_H */
