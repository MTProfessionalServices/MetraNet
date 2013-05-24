/**************************************************************************
 * @doc
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 *******************************************************************************/


#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <autoinstance.h>
#include <MTUtil.h>
#include <SharedDefs.h>
#include <mtprogids.h>

extern MTAutoInstance<InstallLogger> g_Logger;

#import <MTProductCatalogExec.tlb> rename("EOF", "EOFX")

BOOL InstCallConvention CreateUnionProductViewJoinedViews() 
{
#if 0
	try 
	{
		MTPRODUCTCATALOGEXECLib::IMTCounterViewWriterPtr 
			writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterViewWriter));
		writer->CreateAllViews();
		g_Logger->LogThis(LOG_DEBUG, "Created Product Views joined views");
	} 
	catch (_com_error& e) 
	{
		g_Logger->LogVarArgs(LOG_ERROR, "A COM exception occured in CreateUnionProductViewJoinedViews! error %x", e.Error());
		return FALSE;
	}
#endif
	return TRUE;
}

BOOL InstCallConvention CreateUnionUsageView() 
{
#if 0
	try 
	{
		MTPRODUCTCATALOGEXECLib::IMTCounterViewWriterPtr 
			writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterViewWriter));
		_bstr_t bstrViewName = writer->CreateUsageView();
		g_Logger->LogVarArgs(LOG_DEBUG, "Created Usage Table Joined View (%s)",(const char*)bstrViewName);
	} 
	catch (_com_error& e) 
	{
		g_Logger->LogVarArgs(LOG_ERROR, "A COM exception occured in CreateUnionUsageView! error %x", e.Error());
		return FALSE;
	}
#endif

	return TRUE;
}
BOOL InstCallConvention CreateUnionProductViewViews() 
{
	//TODO: implement to install views that don't join t_acc_usage
	return TRUE;
}
