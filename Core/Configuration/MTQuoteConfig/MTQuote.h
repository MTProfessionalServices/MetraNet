// MTQuote.h : Declaration of the CMTQuote

#ifndef __MTQUOTE_H_
#define __MTQUOTE_H_

#import	<MTConfigLib.tlb> 
using namespace MTConfigLib;

#include "comdef.h"
#include "resource.h"       // main symbols
#include <string>
#include "NTLogger.h"

/////////////////////////////////////////////////////////////////////////////
// CMTQuote
class ATL_NO_VTABLE CMTQuote : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTQuote, &CLSID_MTQuote>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTQuote, &IID_IMTQuote, &LIBID_MTQUOTECONFIGLib>
{
public:
	CMTQuote()
	{
	mHostName = L"";
	mPath = L"";

	// initialize the logger
//	LoggerConfigReader configReader;
//	mLogger.Init (configReader.ReadConfiguration("Core"), CORE_TAG);
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTQUOTE)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTQuote)
	COM_INTERFACE_ENTRY(IMTQuote)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTQuote
public:
	STDMETHOD(get_ChargeType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ChargeType)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ApplyMinimum)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ApplyMinimum)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_PerMinuteAmount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_PerMinuteAmount)(/*[in]*/ double newVal);
	STDMETHOD(get_FlatAmount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_FlatAmount)(/*[in]*/ double newVal);
	STDMETHOD(get_MinAmount)(/*[out, retval]*/ double *pVal);
	STDMETHOD(put_MinAmount)(/*[in]*/ double newVal);
	STDMETHOD(Write)();
	STDMETHOD(Read)(/*[in]*/BSTR bstrHost, /*[in]*/BSTR bstrRelativePath, /*[in]*/BSTR bstrFile);

	
private:
		_bstr_t			mHostName;
		_bstr_t			mPath;
		NTLogger		mLogger;
		double			mMinAmount;
		double			mPerMinuteAmount;
		double			mFlatAmount;
		_bstr_t			mChargeType;
		VARIANT_BOOL	mApplyMinimum;
};

#endif //__MTQUOTE_H_
