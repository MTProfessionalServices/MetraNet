/**************************************************************************
 * @doc RESTART
 *
 * @module |
 *
 *
 * Copyright 2002 by MetraTech Corporation
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
 * @index | RESTART
 ***************************************************************************/

#ifndef _RESTART_H
#define _RESTART_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <NTThreader.h>
#include <NTLogger.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent")
#import <rowsetinterfaceslib.tlb> rename("EOF", "XEOF")
#import <MTProductCatalogInterfacesLib.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.Pipeline.tlb> \
  inject_statement("using namespace mscorlib;") \
  inject_statement("using namespace RowSetInterfacesLib;") \
  inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaDataPtr;") \
  inject_statement("using MTProductCatalogInterfacesLib::IMTPropertyMetaData;")

/******************************************** RestartService ***/

class RestartService : public NTThreader
{
public:
	// throws on error
	void Init(const PipelineInfo & arInfo);

	virtual int ThreadMain();

	// return true if this service is required.  If not, the thread doesn't
	// need to be started.
	BOOL ServiceRequired();

private:
	MetraTech_Pipeline::ISuspendedTxnManagerPtr mSuspendedTxnManager;

	NTLogger mLogger;

	// period in milliseconds
	int mPeriodMS;
};

#endif /* _RESTART_H */
