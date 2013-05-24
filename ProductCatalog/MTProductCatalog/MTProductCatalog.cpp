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
//      run nmake -f MTProductCatalogps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include "MTProductCatalog.h"
#include "MTProductCatalog_i.c"
#include "Properties_i.c"
#include "MTProductCatalogInterfaces_i.c"

#include "MTActionMetaData.h"
#include "MTAttribute.h"
#include "MTAttributes.h"
#include "MTAttributeMetaData.h"
#include "MTAttributeMetaDataSet.h"
#include "MTConditionMetaData.h"
#include "MTDiscount.h"
#include "MTNonRecurringCharge.h"
#include "MTPCAccount.h"
#include "MTPCCycle.h"
#include "MTPCTimeSpan.h"
#include "MTParamTableDefinition.h"
#include "MTPriceableItemType.h"
#include "MTPriceList.h"
#include "MTPriceListMapping.h"
#include "MTProductOffering.h"
#include "MTProperty.h"
#include "MTProperties.h"
#include "MTPropertyMetaData.h"
#include "MTPropertyMetaDataSet.h"
#include "MTRateSchedule.h"
#include "MTRecurringCharge.h"
#include "MTSubscription.h"
#include "MTUsageCharge.h"
#include "ProductCatalog.h"
#include "MTCounterPropertyDefinition.h"
#include "MTAggregateCharge.h"
#include "MTCalendar.h"
#include "MTCalendarPeriod.h"
#include "MTProductCatalogMetaData.h"
#include "MTCalendarWeekday.h"
#include "MTCalendarHoliday.h"
#include "MTCalendarDay.h"
#include "MTGroupSubscription.h"
#include "MTGroupSubSlice.h"
#include "MTGSubMember.h"
#include <IMTPCBase_i.c>
#include "MTCharge.h"
#include "MTChargeProperty.h"
#include "MTSubInfo.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTActionMetaData, CMTActionMetaData)
OBJECT_ENTRY(CLSID_MTAttribute, CMTAttribute)
OBJECT_ENTRY(CLSID_MTAttributes, CMTAttributes)
OBJECT_ENTRY(CLSID_MTAttributeMetaData, CMTAttributeMetaData)
OBJECT_ENTRY(CLSID_MTAttributeMetaDataSet, CMTAttributeMetaDataSet)
OBJECT_ENTRY(CLSID_MTConditionMetaData, CMTConditionMetaData)
OBJECT_ENTRY(CLSID_MTDiscount, CMTDiscount)
OBJECT_ENTRY(CLSID_MTNonRecurringCharge, CMTNonRecurringCharge)
OBJECT_ENTRY(CLSID_MTPCAccount, CMTPCAccount)
OBJECT_ENTRY(CLSID_MTPCCycle, CMTPCCycle)
OBJECT_ENTRY(CLSID_MTPCTimeSpan, CMTPCTimeSpan)
OBJECT_ENTRY(CLSID_MTParamTableDefinition, CMTParamTableDefinition)
OBJECT_ENTRY(CLSID_MTPriceableItemType, CMTPriceableItemType)
OBJECT_ENTRY(CLSID_MTPriceList, CMTPriceList)
OBJECT_ENTRY(CLSID_MTPriceListMapping, CMTPriceListMapping)
OBJECT_ENTRY(CLSID_MTProductCatalog, CMTProductCatalog)
OBJECT_ENTRY(CLSID_MTProductOffering, CMTProductOffering)
OBJECT_ENTRY(CLSID_MTProperty, CMTProperty)
OBJECT_ENTRY(CLSID_MTProperties, CMTProperties)
OBJECT_ENTRY(CLSID_MTPropertyMetaData, CMTPropertyMetaData)
OBJECT_ENTRY(CLSID_MTPropertyMetaDataSet, CMTPropertyMetaDataSet)
OBJECT_ENTRY(CLSID_MTRateSchedule, CMTRateSchedule)
OBJECT_ENTRY(CLSID_MTRecurringCharge, CMTRecurringCharge)
OBJECT_ENTRY(CLSID_MTSubscription, CMTSubscription)
OBJECT_ENTRY(CLSID_MTUsageCharge, CMTUsageCharge)
OBJECT_ENTRY(CLSID_MTCounterPropertyDefinition, CMTCounterPropertyDefinition)
OBJECT_ENTRY(CLSID_MTAggregateCharge, CMTAggregateCharge)
OBJECT_ENTRY(CLSID_MTCalendar, CMTCalendar)
OBJECT_ENTRY(CLSID_MTCalendarPeriod, CMTCalendarPeriod)
OBJECT_ENTRY(CLSID_MTCalendarWeekday, CMTCalendarWeekday)
OBJECT_ENTRY(CLSID_MTCalendarHoliday, CMTCalendarHoliday)
OBJECT_ENTRY(CLSID_MTProductCatalogMetaData, CMTProductCatalogMetaData)
OBJECT_ENTRY(CLSID_MTGroupSubscription, CMTGroupSubscription)
OBJECT_ENTRY(CLSID_MTGSubMember, CMTGSubMember)
OBJECT_ENTRY(CLSID_MTGroupSubSlice, CMTGroupSubSlice) 
OBJECT_ENTRY(CLSID_MTCharge, CMTCharge)
OBJECT_ENTRY(CLSID_MTChargeProperty, CMTChargeProperty)
OBJECT_ENTRY(CLSID_MTSubInfo, CMTSubInfo)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTPRODUCTCATALOGLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
		{		_Module.Term();
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

