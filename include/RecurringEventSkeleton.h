#ifndef __RECURRINGEVENTSKELETON_H__
#define __RECURRINGEVENTSKELETON_H__
#pragma once

#define MT_SUPPORT_IDispatch
#include <IRecurringEventAdapter.h>
#include <IRecurringEventAdapter_i.c>
#include <RecurringEventAdapterLib.h>
#include <RecurringEventAdapterLib_i.c>
#include <ComSkeleton.h>
#include <comdef.h>

template <class T, const CLSID* pclsid,
	class ThreadModel = CComMultiThreadModel>
class ATL_NO_VTABLE MTRecurringEventSkeleton : 
  public MTImplementedInterface<T,IRecurringEventAdapter2,pclsid,&IID_IRecurringEventAdapter2,&LIBID_RECURRINGEVENTADAPTERLib,ThreadModel>
  
{
public:
	BEGIN_COM_MAP(T)
  MT_INTERFACE_ENTRY(&IID_IRecurringEventAdapter2,IRecurringEventAdapter2)
	#ifdef MT_SUPPORT_IDispatch
	COM_INTERFACE_ENTRY(IDispatch)
	#endif
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	END_COM_MAP()

	// these should be redifined
	STDMETHOD(Initialize)(BSTR eventName,
												BSTR configFile, 
												IMTSessionContext* context, 
												VARIANT_BOOL limitedInit)
	{ return S_OK; }

	STDMETHOD(Execute)(IRecurringEventRunContext* context, 
										 BSTR* detail)
	{ return S_OK; }

	STDMETHOD(Reverse)(IRecurringEventRunContext* context, 
										 BSTR* detail)
	{ return S_OK; }

	STDMETHOD(Shutdown)() { return S_OK; }

  STDMETHOD(CreateBillingGroupConstraints)(long intervalID, long materializationID)
	{ return S_OK; }

  STDMETHOD(SplitReverseState)(long parentRunID, 
                               long parentBillingGroupID,
                               long childRunID, 
                               long childBillingGroupID)
	{ return S_OK; }

	STDMETHOD(get_SupportsScheduledEvents)(VARIANT_BOOL* pRetVal) { return S_OK; }
	STDMETHOD(get_SupportsEndOfPeriodEvents)(VARIANT_BOOL* pRetVal) { return S_OK; }
	STDMETHOD(get_Reversibility)(ReverseMode* pRetVal) { return S_OK; }
	STDMETHOD(get_AllowMultipleInstances)(VARIANT_BOOL* pRetVal) { return S_OK; }

	STDMETHOD(get_BillingGroupSupport)(BillingGroupSupportType* pRetVal) { return S_OK; }
	STDMETHOD(get_HasBillingGroupConstraints)(VARIANT_BOOL* pRetVal) { return S_OK; }
  
};


#endif //__RECURRINGEVENTSKELETON_H__
