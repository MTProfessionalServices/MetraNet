// MTSessionError.h : Declaration of the CMTSessionError

#ifndef __MTSESSIONERROR_H_
#define __MTSESSIONERROR_H_

#include "resource.h"       // main symbols


#include <errobj.h>
#include <string>

#include <sessionerr.h>

#include <comutil.h>


/////////////////////////////////////////////////////////////////////////////
// CMTSessionError
class ATL_NO_VTABLE CMTSessionError : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSessionError, &CLSID_MTSessionError>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTSessionError, &IID_IMTSessionError, &LIBID_PIPELINECONTROLLib>
{
public:
	CMTSessionError()
		: mpError(NULL), mTakeOwnership(FALSE)
	{
	}

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTSESSIONERROR)

BEGIN_COM_MAP(CMTSessionError)
	COM_INTERFACE_ENTRY(IMTSessionError)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTSessionError
public:
	STDMETHOD(get_ProcedureName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ProcedureName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ModuleName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ModuleName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_PlugInName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PlugInName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_StageName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_StageName)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ErrorMessage)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ErrorMessage)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_SessionID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_SessionID)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ErrorCode)(/*[out, retval]*/ DWORD *pVal);
	STDMETHOD(put_ErrorCode)(/*[in]*/ DWORD newVal);
	STDMETHOD(get_LineNumber)(/*[out, retval]*/ int *pVal);
	STDMETHOD(put_LineNumber)(/*[in]*/ int newVal);
	STDMETHOD(get_IPAddress)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_FailureTime)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_MeteredTime)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_RootSessionID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_RootSessionID)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_XMLMessage)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_XMLMessage)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_OriginalXMLMessage)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_OriginalXMLMessage)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Session)(/*[out, retval]*/ IMTSession * * session);
	STDMETHOD(get_SessionSetID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_SessionSetID)(/*[in]*/ BSTR newVal);
  STDMETHOD(SaveXMLMessage)(/*[in]*/ BSTR xml, /*[in]*/ IMTCollection * childrenToDelete);
	STDMETHOD(get_HasSavedXMLMessage)(/*[out, retval]*/ VARIANT_BOOL * saved);
	STDMETHOD(DeleteSavedXMLMessage)();
	STDMETHOD(InitFromStream)(SAFEARRAY * message);

public:
	void SetSessionError(SessionErrorObject * apObj, BOOL aTakeOwnership)
	{
		mpError = apObj;
		mTakeOwnership = aTakeOwnership;
	}

private:
	typedef void (SessionErrorObject:: *SetMethod)(const char *);
	typedef const std::string & (SessionErrorObject:: *GetMethod)() const;

	void SetStringProperty(SetMethod apSetMethod, BSTR newVal)
	{
		mLock.Lock();
		ASSERT(mpError);

		_bstr_t bstrVal(newVal);
		(mpError->*apSetMethod)(bstrVal);

		mLock.Unlock();
	}

	void GetStringProperty(GetMethod apGetMethod, BSTR * pVal)
	{
		mLock.Lock();

		ASSERT(mpError);
		_bstr_t bstrVal(((mpError->*apGetMethod)()).c_str());

		*pVal = bstrVal.copy();

		mLock.Unlock();
	}

private:
	SessionErrorObject * mpError;
	BOOL mTakeOwnership;

	_ThreadModel::AutoCriticalSection mLock;
};

#endif //__MTSESSIONERROR_H_
