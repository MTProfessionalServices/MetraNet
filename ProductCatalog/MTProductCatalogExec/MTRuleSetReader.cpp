/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <mttime.h>
#include <formatdbvalue.h>

#include "MTProductCatalogExec.h"
#include "MTRuleSetReader.h"

#include <mtautocontext.h>
#import <MTPipelineLib.tlb> rename("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include <DBRSLoader.h>

using MTPRODUCTCATALOGLib::IMTRuleSetPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetReader

/******************************************* error interface ***/
STDMETHODIMP CMTRuleSetReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRuleSetReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRuleSetReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRuleSetReader::CanBePooled()
{
	return FALSE;
} 

void CMTRuleSetReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTRuleSetReader::FindWithID(::IMTSessionContext* apCtxt, 
																					long aRateSchedID,
																					IMTParamTableDefinition * apParamTable,
                                          ::IMTRuleSet *apRuleSet,
                                          VARIANT aRefDate)
{
	MTAutoContext context(mpObjectContext);
	try
	{

		DBRSLoader loader;
		if (!loader.Init())
		{
			ASSERT(0);
			return Error("Unable to initialize rate schedule loader");
		}

    /*
    //set refdate used to retrieve previous versions of the ruleset
    _variant_t vtRefDate;
    wstring strRefDate;
    if(!OptionalVariantConversion(aRefDate,VT_DATE,vtRefDate))
    {
      vtRefDate = GetMTOLETime();
    }
    FormatValueForDB(vtRefDate,FALSE,strRefDate);
    */

		// last argument is modification date
		long ptid;
		HRESULT hr;
		if (FAILED(hr = apParamTable->get_ID(&ptid)))
			return hr;

		CachedRateSchedulePropGenerator * schedule = loader.CreateRateSchedule(ptid, 0L);
		if (!loader.LoadRateScheduleToRuleSet(apRuleSet, apParamTable, aRateSchedID,
																					schedule, aRefDate))
		{
			ASSERT(0);
			delete schedule;
			return Error("Unable to load rate schedule");
		}
		delete schedule;
	}
	catch(_com_error& e)
	{ return ReturnComError(e); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRuleSetReader::CreateRuleSet(::IMTSessionContext* apCtxt, ::IMTRuleSet **apRuleset)
{
	MTAutoContext context(mpObjectContext);

	try
	{
    ::IMTRuleSetPtr ruleset(MTPROGID_MTRULESET);
    *apRuleset = (::IMTRuleSet *) ruleset.Detach();
	}
	catch(_com_error& e)
	{ return ReturnComError(e); }

	context.Complete();
	return S_OK;
}
