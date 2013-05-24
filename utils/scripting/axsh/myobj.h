
#include "windows.h"
//#include "oleauto.h"

class CMyObject : public IDispatch
{

public:

	CMyObject();

	/***** IUnknown Methods *****/
	STDMETHODIMP QueryInterface(REFIID riid, void**ppvObj);
	STDMETHODIMP_(ULONG) AddRef();
	STDMETHODIMP_(ULONG) Release();

	/***** IDispatch Methods *****/
	STDMETHODIMP GetTypeInfoCount(UINT* iTInfo);
	
	STDMETHODIMP GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo** ppTInfo);

	STDMETHODIMP GetIDsOfNames(	
						REFIID riid, 
						OLECHAR** rgszNames,
						UINT cNames, LCID lcid, 
						DISPID* rgDispId);

	STDMETHODIMP Invoke(
						DISPID dispIdMember, 
						REFIID riid, 
						LCID lcid,  
						WORD wFlags, 
						DISPPARAMS* pDispParams,  
						VARIANT* pVarResult, 
						EXCEPINFO* pExcepInfo,  
						UINT* puArgErr);
	
	HRESULT FetchTypeInfo(LCID lcid, REFCLSID clsid);

	void HelloBongo(void);
	HRESULT CreateObject(BSTR bstrProgId, LPDISPATCH *pDisp);

private:

	virtual ~CMyObject();
	long m_cRefCount;
	LPTYPEINFO m_pTypeInfo;
};