// MTEmailMessage.h : Declaration of the CMTEmailMessage

#ifndef __MTEMAILMESSAGE_H_
#define __MTEMAILMESSAGE_H_

#include "resource.h"       // main symbols
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTEmailMessage
class ATL_NO_VTABLE CMTEmailMessage : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTEmailMessage, &CLSID_MTEmailMessage>,
	public IDispatchImpl<IMTEmailMessage, &IID_IMTEmailMessage, &LIBID_EMAILMESSAGELib>
{
public:
	CMTEmailMessage():mMessageBodyFormat(0), mMessageImportance(1), mMessageMailFormat(0) 
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTEMAILMESSAGE)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEmailMessage)
	COM_INTERFACE_ENTRY(IMTEmailMessage)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTEmailMessage
public:
	
	STDMETHOD(get_MailFormat)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_MessageMailFormat)(/*[in]*/ long newVal);
	STDMETHOD(get_Importance)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_MessageImportance)(/*[in]*/ long newVal);
	STDMETHOD(get_BodyFormat)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_MessageBodyFormat)(/*[in]*/ long newVal);
	STDMETHOD(get_Bcc)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageBcc)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_To)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageTo)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_Subject)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageSubject)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_From)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageFrom)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_CC)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageCC)(/*[in]*/ BSTR newVal);
  STDMETHOD(get_Body)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_MessageBody)(/*[in]*/ BSTR newVal);
  
	
private:
	long mMessageMailFormat;
	long mMessageImportance;
	long mMessageBodyFormat;
	_bstr_t mMessageBcc;
	//_bstr_t mMessageSubject;
	_bstr_t mMessageCC;
	_bstr_t mMessageTo;
	_bstr_t mMessageFrom;
	_bstr_t mMessageBody;
  _bstr_t mMessageSubject;
	//BSTR mMessageBcc;
	//BSTR mMessageSubject;
	//BSTR mMessageCC;
	//BSTR mMessageTo;
	//BSTR mMessageFrom;
	//BSTR mMessageBody;
};

#endif //__MTEMAILMESSAGE_H_
