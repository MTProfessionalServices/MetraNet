// AudioConfMeterTestCtl.h : Declaration of the CAudioConfMeterTestCtl

#pragma once
#include "resource.h"       // main symbols

#include "AudioConfMeterTestLib.h"
#include <stdint.h>
#include <OdbcConnMan.h>
#include <OdbcConnection.h>
#include <OdbcStatement.h>
#include <OdbcResultSet.h>
#include <HashAggregate.h>
#include <PlanInterpreter.h>
#include <DatabaseSelect.h>
#include <DesignTimeExpression.h>
#include <DatabaseMetering.h>
#include <atlcomtime.h>

#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif



// CAudioConfMeterTestCtl

class ATL_NO_VTABLE CAudioConfMeterTestCtl :
  public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CAudioConfMeterTestCtl, &CLSID_AudioConfMeterTestCtl>,
  public IDispatchImpl< IAudioConfMeterTestCtl, &IID_IAudioConfMeterTestCtl, &LIBID_AudioConfMeterTestLibLib >
{
public:
	CAudioConfMeterTestCtl();

DECLARE_REGISTRY_RESOURCEID(IDR_AUDIOCONFMETERTESTCTL)

DECLARE_NOT_AGGREGATABLE(CAudioConfMeterTestCtl)

BEGIN_COM_MAP(CAudioConfMeterTestCtl)
	COM_INTERFACE_ENTRY(IAudioConfMeterTestCtl)
  COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()



	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

public:
STDMETHOD(SetSessionSetSize)(ULONG sessionSetSize);
  STDMETHOD(SetCallCount)(ULONG callCount);
  STDMETHOD(SetConnsPerCall)(ULONG connsPerCall, VARIANT_BOOL randomizeConnsPerCall);
  STDMETHOD(SetFeaturesPerCall)(ULONG featuresPerCall, VARIANT_BOOL randomizeFeaturesPerCall);
  STDMETHOD(SetNumberOfAccounts)(ULONG numberOfAccounts, BSTR offeringName);
  STDMETHOD(SetAccountRange)(LONG startingAccountId, LONG endingAccountId);
  STDMETHOD(ClearAccountRange)(void);
  STDMETHOD(IncludeUnsubscribedAccounts)();
  STDMETHOD(ClearUnsubscribedAccounts)(void);
  STDMETHOD(SetCallDateRange)(BSTR startDate, BSTR endDate);
  STDMETHOD(GenerateTestData)(void);

private:

  DesignTimeOperator *CreateMasterCallData(DesignTimePlan &plan);
  DesignTimeOperator *CreatePayerAccountMapping(DesignTimePlan &plan);
  DesignTimeOperator *JoinAccountsToCalls(DesignTimePlan &plan, DesignTimeOperator *genCall, DesignTimeOperator *accountGen);
  DesignTimeOperator *GenerateMasterCallCopies(DesignTimePlan &plan, DesignTimeOperator *accountJoin);
  void UnrollMasterCallData(DesignTimePlan &plan, DesignTimeOperator *copy, DesignTimeUnroll **unrollConnection, DesignTimeUnroll **unrollFeature);
  DesignTimeOperator *GenerateConferenceData(DesignTimePlan &plan, DesignTimeOperator *copyOpr);
  DesignTimeOperator *GenerateConnectionData(DesignTimePlan &plan, DesignTimeUnroll *unrollConnection);
  DesignTimeOperator *GenerateFeatureData(DesignTimePlan &plan, DesignTimeUnroll *unrollFeature);

private:

  ULONG               mSessionSetSize;
  ULONG               mCallCount;
  ULONG               mConnsPerCall;
  VARIANT_BOOL        mRandomizeConnsPerCall;
  ULONG               mFeaturesPerCall;
  VARIANT_BOOL        mRandomizeFeaturesPerCall;
  ULONG               mNumberOfAccounts;
  BSTR                mOfferingName;
  VARIANT_BOOL        mLimitAccountRange;
  long                mStartingAccountId;
  long                mEndingAccountId;
  VARIANT_BOOL        mIncludeUnsubscribedAccounts;
  ULONG               mUnsubscribedPercentage;
  DATE                mStartDate;
  DATE                mEndDate;
};

OBJECT_ENTRY_AUTO(__uuidof(AudioConfMeterTestCtl), CAudioConfMeterTestCtl)
