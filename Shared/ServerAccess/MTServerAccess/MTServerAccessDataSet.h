	
// MTServerAccessDataSet.h : Declaration of the CMTServerAccessDataSet

#ifndef __MTSERVERACCESSDATASET_H_
#define __MTSERVERACCESSDATASET_H_

#include "resource.h"       // main symbols
#include "MTServerAccessData.h"
#include "MTServerAccessDefs.h"
#include <errobj.h>
#include <NTLogger.h>
#include <NTThreadLock.h>
#include <loggerconfig.h>
#include <mtcryptoapi.h>

#include <vector>

using namespace std;

#import <MTServerAccess.tlb>

#import <MTConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTServerAccessDataSet
class ATL_NO_VTABLE CMTServerAccessDataSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTServerAccessDataSet, &CLSID_MTServerAccessDataSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTServerAccessDataSet, &IID_IMTServerAccessDataSet, &LIBID_MTSERVERACCESSLib>,
	public ObjectWithError
{
public:
	CMTServerAccessDataSet()
	{
	    mSize = 0;
		mbCryptoInitialized = false;
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(MTSERVERACCESS_STR), 
					 MTSERVERACCESS_STR);
	}
  
DECLARE_REGISTRY_RESOURCEID(IDR_MTSERVERACCESSDATASET)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTServerAccessDataSet)
	COM_INTERFACE_ENTRY(IMTServerAccessDataSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

HRESULT FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
}


	void FinalRelease()
	{
		// TODO: the entries will leak, but the leak won't grow
#if 0
		if (mServerAccessDataList.entries() != 0)
		    mServerAccessDataList.clearAndDestroy();
#endif
		m_pUnkMarshaler.Release();

	}
	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTServerAccessDataSet
public:
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Initialize)();
	STDMETHOD(InitializeFromLocation)(BSTR aLocation);
	STDMETHOD(FindAndReturnObject)(/*[in]*/ BSTR ServerType, /*[out]*/ IMTServerAccessData** pVal);
	STDMETHOD(FindAndReturnObjectIfExists)(/*[in]*/ BSTR ServerType, /*[out]*/ IMTServerAccessData** pVal);

protected:
    BOOL Decrypt(std::string& arStr);

private:
	HRESULT Initialize(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT Add(BSTR ServerType, 
							BSTR ServerName, 
							long NumRetries, 
							long Timeout, 
							long Priority, 
							long Secure, 
							long PortNumber, 
							BSTR UserName, 
							BSTR Password,
							long DTCenabled,
							BSTR dbname,
							BSTR datasource,
							BSTR dbdriver,
							BSTR dbtype);
	void CMTServerAccessDataSet::FindAndReturnObjectInternal(	BSTR ServerType, 
																														IMTServerAccessData **pVal);

private:

    // encryption object
    CMTCryptoAPI mCrypto;

	bool mbCryptoInitialized;

    long mSize;
    NTLogger mLogger;

	typedef vector<_variant_t> ServerAccessDataList;
	// static so it doesn't need to be reloaded
	static ServerAccessDataList mServerAccessDataList;
	static BOOL mServerListLoaded;

	// lock around the server access data list
	NTThreadLock mLock;
};

#endif //__MTSERVERACCESSDATASET_H_
