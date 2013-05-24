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
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/
	
// COMLocaleTranslator.h : Declaration of the CCOMLocaleTranslator

#ifndef __COMLOCALETRANSLATOR_H_
#define __COMLOCALETRANSLATOR_H_

#include "resource.h"       // main symbols
#include <ComDataLogging.h>
#include <autologger.h>
// forward declaration 
class DBLocale ;

/////////////////////////////////////////////////////////////////////////////
// CCOMLocaleTranslator
class ATL_NO_VTABLE CCOMLocaleTranslator : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMLocaleTranslator, &CLSID_COMLocaleTranslator>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMLocaleTranslator, &IID_ICOMLocaleTranslator, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMLocaleTranslator() ;
  virtual ~CCOMLocaleTranslator() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMLOCALETRANSLATOR)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMLocaleTranslator)
	COM_INTERFACE_ENTRY(ICOMLocaleTranslator)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMLocaleTranslator
public:
// The GetLocalizedString method gets the localized string for the specified name
	STDMETHOD(GetLocalizedString)(/*[in]*/ BSTR aFQN, /*[out,retval]*/ BSTR *pDesc);
// The GetLocalizedMonth method gets the localized string for the specified month
	STDMETHOD(GetLocalizedMonth)(/*[in]*/ BSTR aMonth, /*[out,retval]*/ BSTR *pDesc);
// The GetLocalizedWeekday method gets the localized string for the specified weekday
	STDMETHOD(GetLocalizedWeekday)(/*[in]*/ BSTR aWeekday, /*[out,retval]*/ BSTR *pDesc);

// The GetDateTime method gets the converted date time value based on the timezone and daylight savings time.
	STDMETHOD(GetDateTime)(/*[in]*/ VARIANT aInputDateTime, 
													/*[in]*/ long aMTZoneCode, 
													/*[in]*/ VARIANT_BOOL aDayLightSavingFlag, 
													/*[out,retval]*/ VARIANT *apLocalDateTime);
// The LanguageCode property gets the language code.
	STDMETHOD(get_LanguageCode)(/*[out, retval]*/ BSTR *pVal);
// The LanguageCode property sets the language code.
	STDMETHOD(put_LanguageCode)(/*[in]*/ BSTR newVal);
// The GetViewDescription method gets the localized view description for the specified view.
	STDMETHOD(GetViewDescription)(/*[in]*/ long aViewID, /*[out,retval]*/ BSTR *apDesc);
// The GetCurrency method gets the localized currency for the specified currency code and amount.
	STDMETHOD(GetCurrency)(/*[in]*/ VARIANT aAmount, /*[in]*/ BSTR aUOM, /*[out,retval]*/ BSTR *pCurrency);
// The GetEuroCurrency method gets the Euro currency for the specified amount and currency code.
  STDMETHOD(GetEuroCurrency)(/*[in]*/ VARIANT aAmount, /*[in]*/ BSTR aUOM, /*[out,retval]*/ BSTR *pCurrency);
// The GetDescription method gets the localized description for the specified description id
	STDMETHOD(GetDescription)(/*[in]*/ long aDescID, /*[out,retval]*/ BSTR *pDesc);
// The GetPropertyDescription method gets the localized property name for the specified property name and view id.
	STDMETHOD(GetPropertyDescription)(/*[in]*/ long aViewID, /*[in]*/ BSTR aName, /*[out,retval]*/ BSTR *pDesc) ;
// The GetLocaleListForEnumTypes method gets the localized string list for the specified enumerated type.
  STDMETHOD(GetLocaleListForEnumTypes)(/*[in]*/BSTR aLangCode, /*[in]*/ BSTR aEnumSpace, /*[in]*/ BSTR aEnumTypeName, /*out,retval*/ LPDISPATCH *pRowset);
// The Init method initializes the locale translator with the specified language code.
	STDMETHOD(Init)(BSTR aLangCode);
// Get the language 
  STDMETHOD(get_LanguageID)(/*[out,retval]*/ long* aLanguageID);
// The GetLocalizedDescription method gets the localized string for the specified id
	STDMETHOD(GetLocalizedDescription)(/*[in]*/ long aDescriptionID, /*[out,retval]*/ BSTR *pDesc);
private:
  DBLocale *mpLocale ;
  _bstr_t mLangCode ;
	MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
};

#endif //__COMLOCALETRANSLATOR_H_
