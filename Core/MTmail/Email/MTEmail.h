// MTEmail.h : Declaration of the CMTEmail

#ifndef __MTEMAIL_H_
#define __MTEMAIL_H_

#include "resource.h"       // main symbols

#include <comdef.h>
#include <errobj.h>
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
* Created by: 
* $Header$
* 
***************************************************************************/

#import "EmailMessage.tlb"
using namespace EMAILMESSAGELib;

#import "MTConfigLib.tlb"

#include <vector>


/////////////////////////////////////////////////////////////////////////////
// CMTEmail
class ATL_NO_VTABLE CMTEmail : 
public CComObjectRootEx<CComSingleThreadModel>,
public CComCoClass<CMTEmail, &CLSID_MTEmail>,
public ISupportErrorInfo,
public IDispatchImpl<IMTEmail, &IID_IMTEmail, &LIBID_EMAILLib>
{
public:
	CMTEmail() : mInitialized(FALSE)
	{
	}
	
	DECLARE_REGISTRY_RESOURCEID(IDR_MTEMAIL)
		
	DECLARE_PROTECT_FINAL_CONSTRUCT()
	
	BEGIN_COM_MAP(CMTEmail)
	COM_INTERFACE_ENTRY(IMTEmail)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	END_COM_MAP()
		
		
	// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
	
	// IMTEmail
public:
	//Load and parse the XML Template
	STDMETHOD(LoadTemplate)();
	
	//Perform the variable substitution on the body & subject
	STDMETHOD(AddParam)(/*[in]*/ BSTR Name, /*[in]*/ BSTR Value);
	
	//Choose the language section to use
	STDMETHOD(put_TemplateLanguage)(/*[in]*/ BSTR newVal);
	
	//Set the name of the template to use
	STDMETHOD(put_TemplateName)(/*[in]*/ BSTR newVal);
	
	//Set the name of the template file
	STDMETHOD(put_TemplateFileName)(/*[in]*/ BSTR newVal);
	
	//Attach an HTML document to the email
	STDMETHOD(AttachURL)(BSTR apSource, BSTR apContentLocation);
	
	//Attach a file to the email
	STDMETHOD(AttachFile)(BSTR apfilename);
	
	//Initialize the email generator
	STDMETHOD(init)(::IMTEmailMessage * apEmailMessage);
	
	//Send the email
	STDMETHOD(Send)();
private:
	HRESULT ReadConfig();
	BSTR ReplaceString(BSTR Name, BSTR Value, BSTR String);
	_bstr_t mTemplateLanguage;
	_bstr_t mTemplateName;
	_bstr_t mTemplateFileName;

	_bstr_t mSmtpServer;
	long	mSmtpPort;
	long	mSmtpTimeout;

	std::vector<_bstr_t> mAttachmentFileNames;

	BOOL mInitialized;
	EMAILMESSAGELib::IMTEmailMessagePtr mpEmailMessage;
};

#endif //__MTEMAIL_H_
