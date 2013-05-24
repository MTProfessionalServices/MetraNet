/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header: c:\development35\Core\Configuration\RCD\MTRcd.h, 15, 10/15/2002 6:55:27 PM, Travis Gebhardt$
* 
***************************************************************************/
#ifndef __MTRCD_H_
#define __MTRCD_H_

#include "resource.h"       // main symbols
#include <RCD.h>
#include <comutil.h>
#include <comip.h>
#include <comdef.h>
//#include <comsingleton.h>
#include <NTThreader.h>
#include <dirwatch.h>
#include <MTRcdFileList.h>
#include <NTThreadLock.h>

class MTWatchThread : public NTThreader
{
public:
	// ctors, dtors
	MTWatchThread();
	virtual ~MTWatchThread();

public: //propertise
	void SetBaseWatchDir(const string aStr) 
	{ 
		mBaseWatchDir = aStr;
		mDirWatch.SetWatchDir(aStr);
	}
public: // methods
	
	void TerminateThread();
	void WaitForThreadStartup();
	int ThreadMain();  // abstract method implementation
	void AddWatchCallBack(MTWatchCallBack*);

protected:
	string mBaseWatchDir;
	HANDLE mhEvent;
	HANDLE mStartEvent;
	MTDirWatch mDirWatch;


};

/////////////////////////////////////////////////////////////////////////////
// CMTRcd
class ATL_NO_VTABLE CMTRcd : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRcd, &CLSID_MTRcd>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRcd, &IID_IMTRcd, &LIBID_RCDLib>
{
public:
	CMTRcd() : mbInit(false), mExtensionDir("")
	{
	}
	virtual ~CMTRcd();


//DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTRcd>)
DECLARE_REGISTRY_RESOURCEID(IDR_MTRCD)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRcd)
	COM_INTERFACE_ENTRY(IMTRcd)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
	STDMETHOD(FinalConstruct)();

// IMTRcd
public:
	STDMETHOD(GetMaxDate)(/*[out, retval]*/ DATE* pRetVal);
	STDMETHOD(GetMinDate)(/*[out, retval]*/ DATE* pRetVal);
	STDMETHOD(GetUTCDate)(/*[out,retval]*/ DATE* pRetVal);
	STDMETHOD(get_ConfigDir)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(RunQueryInAlternateFolder)(/*[in]*/ BSTR query, /*[in]*/ VARIANT_BOOL bRecurse, /*[in]*/ BSTR AlternateFolder,/*[out,retval]*/ IMTRcdFileList** ppFileList);
	STDMETHOD(get_ExtensionList)(/*[out, retval]*/ IMTRcdFileList* *pVal);
	STDMETHOD(RegisterCallBack)(/*[in]*/ BSTR query,/*[in]*/ IUnknown* pHook,/*[in]*/ VARIANT vHookArg);
	STDMETHOD(RunQuery)(/*[in]*/ BSTR query, /*[in]*/ VARIANT_BOOL bRecurse, /*[in,out]*/ IMTRcdFileList** ppFileList);
	STDMETHOD(Init)();
	STDMETHOD(get_ExtensionDir)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ExtensionDir)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ExtensionListWithPath)(/*[out, retval]*/ IMTRcdFileList** ppFileList);
	STDMETHOD(get_InstallDir)(/*[out, retval]*/ BSTR* pVal);
	STDMETHOD(get_ErrorMessage)(VARIANT aErrorCode,BSTR *pVal);
	STDMETHOD(AddErrorResourceLibrary)(BSTR filename);
	STDMETHOD(get_ErrorAsLong)(VARIANT aErrorCode,long* pVal);
	STDMETHOD(GetExtensionFromPath)(/*[in]*/ BSTR path, /*[out, retval]*/ BSTR* pExtension);

protected: // methods
	void GetFilesByQuery(const mtstring& seed,
												const mtstring& aQuery,
												BOOL bRecurse,
												RcdFileList& aFileList);
	void GetFilesbyQueryInExtension(const mtstring& seed,const mtstring& aQuery,bool bRecurse,RcdFileList& aFileList);
	void FindExtensionFolders(std::vector<string>& aVec,bool bFullPath = false);
	HRESULT GetExtensionListInternal(std::vector<string>& aExtensionList,IMTRcdFileList **pVal);
	long ErrorCodeFromVariant(_variant_t& var);

protected: //data
	bool mbInit;
	_bstr_t mExtensionDir;
	std::vector<string> mExtensionList;
	std::vector<string> mExtensionListFullPath;
	NTThreadLock mExtensionListLock;
};

#endif //__MTRCD_H_
