/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTACCOUNTSTATEMETADATA_H_
#define __MTACCOUNTSTATEMETADATA_H_

#include "resource.h"       // main symbols
#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include "MTAccountStatesLogging.h"
#include <autologger.h>

#include <comsingleton.h>

#import <MTConfigLib.tlb>
#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")

using namespace std;
typedef list<_bstr_t> ListBusinessRules;
typedef list<_bstr_t>::iterator ListBusinessRulesIterator;

/////////////////////////////////////////////////////////////////////////////
// CMTAccountStateMetaData
class ATL_NO_VTABLE CMTAccountStateMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountStateMetaData, &CLSID_MTAccountStateMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountStateMetaData, &IID_IMTAccountStateMetaData, &LIBID_MTACCOUNTSTATESLib>
{
public:
	CMTAccountStateMetaData()
	{
		mpPendingActiveApproval = 0;
		mpActive = 0;
		mpSuspended = 0;
		mpPendingFinalBill = 0;
		mpClosed = 0;
		mpArchived = 0;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTSTATEMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTAccountStateMetaData>)

BEGIN_COM_MAP(CMTAccountStateMetaData)
	COM_INTERFACE_ENTRY(IMTAccountStateMetaData)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountStateMetaData
public:
	STDMETHOD(Initialize)();
	STDMETHOD(InitializeWithState)(BSTR StateName);

	STDMETHOD(get_PendingActiveApproval)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_PendingActiveApproval)(/*[in]*/ IMTState* newVal);
	STDMETHOD(get_Active)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_Active)(/*[in]*/ IMTState* newVal);
	STDMETHOD(get_Suspended)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_Suspended)(/*[in]*/ IMTState* newVal);
	STDMETHOD(get_PendingFinalBill)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_PendingFinalBill)(/*[in]*/ IMTState* newVal);
	STDMETHOD(get_Closed)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_Closed)(/*[in]*/ IMTState* newVal);
	STDMETHOD(get_Archived)(/*[out, retval]*/ IMTState* *pVal);
	STDMETHOD(put_Archived)(/*[in]*/ IMTState* newVal);

private:
	MTAutoInstance<MTAutoLoggerImpl<aAccountStateMetaDataLogTitle> > mLogger;

	MTACCOUNTSTATESLib::IMTStatePtr mpPendingActiveApproval;
	MTACCOUNTSTATESLib::IMTStatePtr mpActive;
	MTACCOUNTSTATESLib::IMTStatePtr mpSuspended;
	MTACCOUNTSTATESLib::IMTStatePtr mpPendingFinalBill;
	MTACCOUNTSTATESLib::IMTStatePtr mpClosed;
	MTACCOUNTSTATESLib::IMTStatePtr mpArchived;

protected:
  BOOL ProcessStateMetaData(long lArchiveAge,
														MTConfigLib::IMTConfigPropSetPtr& propSet);
};

#endif //__MTACCOUNTSTATEMETADATA_H_
