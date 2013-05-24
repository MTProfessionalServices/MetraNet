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


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTProductCatalogExecps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTProductCatalogExec.h"
#include "MTProductCatalogExec_i.c"

#include "MTPCTimeSpanWriter.h"
#include "MTProductOfferingReader.h"
#include "MTProductOfferingWriter.h"
#include "MTPriceableItemReader.h"
#include "MTPriceableItemTypeReader.h"
#include "MTPriceableItemTypeWriter.h"
#include "MTCounterTypeReader.h"
#include "MTCounterReader.h"
#include "MTCounterWriter.h"
#include "MTCounterParamReader.h"
#include "MTParamTableDefinitionReader.h"
#include "MTRateScheduleWriter.h"
#include "MTRuleSetWriter.h"
#include "MTPriceableItemWriter.h"
#include "MTRateScheduleReader.h"
#include "MTRuleSetReader.h"
#include "MTCounterViewReader.h"
#include "MTPriceListReader.h"
#include "MTPriceListWriter.h"
#include "MTDiscountReader.h"
#include "MTDiscountWriter.h"
#include "MTAccountReader.h"
#include "MTAccountWriter.h"
#include "MTPriceListMappingReader.h"
#include "MTSubscriptionReader.h"
#include "MTSubscriptionWriter.h"
#include "MTPropertyMetaDataSetReader.h"
#include "MTNonRecurringChargeReader.h"
#include "MTNonRecurringChargeWriter.h"
#include "MTPriceListMappingWriter.h"
#include "MTCounterPropertyDefinitionReader.h"
#include "MTCounterPropertyDefinitionWriter.h"
#include "MTAttributeMetaDataSetReader.h"
#include "MTRecurringChargeReader.h"
#include "MTRecurringChargeWriter.h"
#include "MTCounterMapReader.h"
#include "MTCounterMapWriter.h"
#include "MTCounterTypeWriter.h"
#include "MTBasePropsWriter.h"
#include "MTAggregateChargeReader.h"
#include "MTAggregateChargeWriter.h"
#include "MTExtendedPropWriter.h"
#include "MTCalendarReader.h"
#include "MTCalendarWriter.h"
#include "MTParamTableDefinitionWriter.h"
#include "MTProductViewWriter.h"
#include "MTDDLWriter.h"
#include "MTChargeReader.h"
#include "MTChargeWriter.h"
#include "MTPredicateWriter.h"
#include "MTChargePropertyWriter.h"
#include "MTChargePropertyReader.h"
#include "MTCounterParamWriter.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTProductOfferingReader, CMTProductOfferingReader)
OBJECT_ENTRY(CLSID_MTProductOfferingWriter, CMTProductOfferingWriter)
OBJECT_ENTRY(CLSID_MTPriceableItemReader, CMTPriceableItemReader)
OBJECT_ENTRY(CLSID_MTCounterTypeReader, CMTCounterTypeReader)
OBJECT_ENTRY(CLSID_MTCounterTypeWriter, CMTCounterTypeWriter)
OBJECT_ENTRY(CLSID_MTCounterReader, CMTCounterReader)
OBJECT_ENTRY(CLSID_MTCounterWriter, CMTCounterWriter)
OBJECT_ENTRY(CLSID_MTCounterParamReader, CMTCounterParamReader)
OBJECT_ENTRY(CLSID_MTCounterParamWriter, CMTCounterParamWriter)
OBJECT_ENTRY(CLSID_MTParamTableDefinitionReader, CMTParamTableDefinitionReader)
OBJECT_ENTRY(CLSID_MTPCTimeSpanWriter, CMTPCTimeSpanWriter)
OBJECT_ENTRY(CLSID_MTPriceableItemTypeReader, CMTPriceableItemTypeReader)
OBJECT_ENTRY(CLSID_MTPriceableItemTypeWriter, CMTPriceableItemTypeWriter)
OBJECT_ENTRY(CLSID_MTRateScheduleWriter, CMTRateScheduleWriter)
OBJECT_ENTRY(CLSID_MTRuleSetWriter, CMTRuleSetWriter)
OBJECT_ENTRY(CLSID_MTRateScheduleReader, CMTRateScheduleReader)
OBJECT_ENTRY(CLSID_MTPriceableItemWriter, CMTPriceableItemWriter)
OBJECT_ENTRY(CLSID_MTRuleSetReader, CMTRuleSetReader)
OBJECT_ENTRY(CLSID_MTCounterViewReader, CMTCounterViewReader)
OBJECT_ENTRY(CLSID_MTPriceListReader, CMTPriceListReader)
OBJECT_ENTRY(CLSID_MTPriceListWriter, CMTPriceListWriter)
OBJECT_ENTRY(CLSID_MTDiscountReader, CMTDiscountReader)
OBJECT_ENTRY(CLSID_MTDiscountWriter, CMTDiscountWriter)
OBJECT_ENTRY(CLSID_MTAccountReader, CMTAccountReader)
OBJECT_ENTRY(CLSID_MTAccountWriter, CMTAccountWriter)
OBJECT_ENTRY(CLSID_MTPriceListMappingReader, CMTPriceListMappingReader)
OBJECT_ENTRY(CLSID_MTSubscriptionReader, CMTSubscriptionReader)
OBJECT_ENTRY(CLSID_MTSubscriptionWriter, CMTSubscriptionWriter)
OBJECT_ENTRY(CLSID_MTPropertyMetaDataSetReader, CMTPropertyMetaDataSetReader)
OBJECT_ENTRY(CLSID_MTNonRecurringChargeReader, CMTNonRecurringChargeReader)
OBJECT_ENTRY(CLSID_MTNonRecurringChargeWriter, CMTNonRecurringChargeWriter)
OBJECT_ENTRY(CLSID_MTPriceListMappingWriter, CMTPriceListMappingWriter)
OBJECT_ENTRY(CLSID_MTCounterPropertyDefinitionReader, CMTCounterPropertyDefinitionReader)
OBJECT_ENTRY(CLSID_MTCounterPropertyDefinitionWriter, CMTCounterPropertyDefinitionWriter)
OBJECT_ENTRY(CLSID_MTAttributeMetaDataSetReader, CMTAttributeMetaDataSetReader)
OBJECT_ENTRY(CLSID_MTRecurringChargeReader, CMTRecurringChargeReader)
OBJECT_ENTRY(CLSID_MTRecurringChargeWriter, CMTRecurringChargeWriter)
OBJECT_ENTRY(CLSID_MTCounterMapReader, CMTCounterMapReader)
OBJECT_ENTRY(CLSID_MTCounterMapWriter, CMTCounterMapWriter)
OBJECT_ENTRY(CLSID_MTCounterTypeWriter, CMTCounterTypeWriter)
OBJECT_ENTRY(CLSID_MTBasePropsWriter, CMTBasePropsWriter)
OBJECT_ENTRY(CLSID_MTAggregateChargeReader, CMTAggregateChargeReader)
OBJECT_ENTRY(CLSID_MTAggregateChargeWriter, CMTAggregateChargeWriter)
OBJECT_ENTRY(CLSID_MTExtendedPropWriter, CMTExtendedPropWriter)
OBJECT_ENTRY(CLSID_MTCalendarReader, CMTCalendarReader)
OBJECT_ENTRY(CLSID_MTCalendarWriter, CMTCalendarWriter)
OBJECT_ENTRY(CLSID_MTParamTableDefinitionWriter, CMTParamTableDefinitionWriter)
OBJECT_ENTRY(CLSID_MTProductViewWriter, CMTProductViewWriter)
OBJECT_ENTRY(CLSID_MTDDLWriter, CMTDDLWriter)
OBJECT_ENTRY(CLSID_MTChargeWriter, CMTChargeWriter)
OBJECT_ENTRY(CLSID_MTChargeReader, CMTChargeReader)
OBJECT_ENTRY(CLSID_MTPredicateWriter, CMTPredicateWriter)
OBJECT_ENTRY(CLSID_MTChargePropertyWriter, CMTChargePropertyWriter)
OBJECT_ENTRY(CLSID_MTChargePropertyReader, CMTChargePropertyReader)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    
		if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTPRODUCTCATALOGEXECLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
		{
        _Module.Term();
		}

    return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
    return _Module.UnregisterServer(TRUE);
}

const wchar_t * OpToString(MTOperatorType aOp)
{
	const wchar_t * test;
	switch (aOp)
	{
	case OPERATOR_TYPE_EQUAL:
		test = L"="; break;
	case OPERATOR_TYPE_NOT_EQUAL:
		test = L"!="; break;
	case OPERATOR_TYPE_GREATER:
		test = L">"; break;
	case OPERATOR_TYPE_GREATER_EQUAL:
		test = L">="; break;
	case OPERATOR_TYPE_LESS:
		test = L"<"; break;
	case OPERATOR_TYPE_LESS_EQUAL:
		test = L"<="; break;

	case OPERATOR_TYPE_LIKE:
	case OPERATOR_TYPE_LIKE_W:
	default:
		// TODO:
		ASSERT(0);
		return NULL;
	}

	return test;
}

MTOperatorType StringToOp(_bstr_t opStr)
{
	MTOperatorType test;
	if (opStr == _bstr_t("<"))
		test = OPERATOR_TYPE_LESS;
	else if (opStr == _bstr_t("<="))
		test = OPERATOR_TYPE_LESS_EQUAL;
	else if (opStr == _bstr_t("="))
		test = OPERATOR_TYPE_EQUAL;
	else if (opStr == _bstr_t(">="))
		test = OPERATOR_TYPE_GREATER_EQUAL;
	else if (opStr == _bstr_t(">"))
		test = OPERATOR_TYPE_GREATER;
	else if (opStr == _bstr_t("!="))
		test = OPERATOR_TYPE_NOT_EQUAL;
	else
		ASSERT(0);

	return test;
}

