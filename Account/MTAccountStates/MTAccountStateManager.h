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

#ifndef __MTACCOUNTSTATEMANAGER_H_
#define __MTACCOUNTSTATEMANAGER_H_

#include "resource.h"       // main symbols


#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <autologger.h>
#include "MTAccountStatesLogging.h"

#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CMTAccountStateManager
class ATL_NO_VTABLE CMTAccountStateManager : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAccountStateManager, &CLSID_MTAccountStateManager>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAccountStateManager, &IID_IMTAccountStateManager, &LIBID_MTACCOUNTSTATESLib>
{
public:
	CMTAccountStateManager() :
		mAccountID (-1),
		mState(L"")
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCOUNTSTATEMANAGER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAccountStateManager)
	COM_INTERFACE_ENTRY(IMTAccountStateManager)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAccountStateManager
public:
	STDMETHOD(Initialize)(/*[in]*/ long lAccountID, /*[in]*/ BSTR StateName);
	STDMETHOD(GetStateObject)(/*[out,retval]*/ IMTAccountStateInterface** pVal);
	STDMETHOD(GetCurrentStateObject)(/*[in]*/ long lAccountID, 
																	 /*[out,retval]*/ IMTAccountStateInterface** pVal);

private:
	long mAccountID;
	_bstr_t mState;
	MTAutoInstance<MTAutoLoggerImpl<aAccountStateManagerLogTitle> >	mLogger;
	MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr mpAccountState;

protected:
  BOOL GetCurrentState(MTACCOUNTSTATESLib::IMTSQLRowsetPtr& rowset, 
											 long lAccountID, 
											 _bstr_t& bstrCurrentState);
};

#endif //__MTACCOUNTSTATEMANAGER_H_
