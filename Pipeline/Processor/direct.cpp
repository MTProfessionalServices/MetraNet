/**************************************************************************
 * @doc DIRECT
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
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

/*
 * imports
 */

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
#import "MTConfigLib.tlb"

#include <processor.h>

/********************************** DirectProcessorInterface ***/

DirectProcessorInterface::DirectProcessorInterface(MTPipelineLib::IMTPipelinePlugInPtr aInterface)
	: mInterface(aInterface)
{ }

BOOL
DirectProcessorInterface::Initialize(MTPipelineLib::IMTSystemContextPtr aSystemContext,
																		 PropSet aConfigData)
{ 
	mInterface->Configure(aSystemContext, aConfigData);
	// NOTE: any errors throw _com_error objects
	return TRUE;
}

BOOL DirectProcessorInterface::Shutdown()
{ 
	mInterface->Shutdown();
	// NOTE: any errors throw _com_error objects
	return TRUE;
}

BOOL DirectProcessorInterface::ProcessSessions(MTPipelineLib::IMTSessionSetPtr aSet)
{
	mInterface->ProcessSessions(aSet);
	// NOTE: any errors throw _com_error objects
	return TRUE;
}

