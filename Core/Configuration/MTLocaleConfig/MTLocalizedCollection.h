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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/

// MTLocalizedCollection.h : Declaration of the CMTLocalizedCollection

#ifndef __MTLOCALIZEDCOLLECTION_H_
#define __MTLOCALIZEDCOLLECTION_H_

#include "resource.h"       // main symbols
#include <LocaleConfig.h>
#include <autologger.h>
#include "localelogging.h"
//#include "LocaleConfig.h"
#include "MTLocalizedEntry.h"


using namespace std;
typedef map<_bstr_t, CMTLocalizedEntry*> LocalizedMap;
typedef map<_bstr_t, CMTLocalizedEntry*>::iterator LocalizedMapIt;



/////////////////////////////////////////////////////////////////////////////
// CMTLocalizedCollection
class ATL_NO_VTABLE CMTLocalizedCollection : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTLocalizedCollection, &CLSID_MTLocalizedCollection>,
	public IDispatchImpl<IMTLocalizedCollection, &IID_IMTLocalizedCollection, &LIBID_MTLOCALECONFIGLib>
{
public:
	friend class CLocaleConfig;
	
	CMTLocalizedCollection() : mLanguageCode(L"")
	{
	}
	~CMTLocalizedCollection()
	{
		LocalizedMapIt it;
		for(it = mLocalizedMap.begin(); it != mLocalizedMap.end(); it++)
		{
			delete (*it).second;
			(*it).second = NULL;
		}
		mLocalizedMap.clear();
		
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTLOCALIZEDCOLLECTION)

DECLARE_PROTECT_FINAL_CONSTRUCT()
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTLocalizedCollection)
	COM_INTERFACE_ENTRY(IMTLocalizedCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY_FUNC(IID_NULL,0,_This)
  COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()


  HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;


// IMTLocalizedCollection
public:
	//Hit collection end?
	STDMETHOD(End)(/*[out, retval]*/ int* true_false);
	//Move to next element in collection
	STDMETHOD(Next)();
	//Ste iterator to collection begin
	STDMETHOD(Begin)();
	//Return FQN of an element at current iterator position
	STDMETHOD(GetFQN)(BSTR* aValue);
	//Return LanguageCode of an element at current iterator position
	STDMETHOD(GetLanguageCode)(BSTR* aValue);
	//Return Localized String of an element at current iterator position
	STDMETHOD(GetLocalizedString)(BSTR* aValue);
	//Return Extension of an element at current iterator position
	STDMETHOD(GetExtension)(BSTR* aValue);
	//Return Extension of an element at current iterator position
	STDMETHOD(GetNamespace)(BSTR* aValue);

	
	//Returns localized string for specified FQN and language
	STDMETHOD(Find)(BSTR fqn, BSTR lang, BSTR* aVal);
	//INTERNAL USE ONLY
	STDMETHOD(Add)(BSTR aExtension, BSTR aNamespace, BSTR aLangCode, BSTR aFQN, BSTR aValue);
	//Clears internal collection
	STDMETHOD(Clear)();

	//Langauge Code
	//STDMETHOD(get_LanguageCode)(/*[out, retval]*/ BSTR *pVal);
	//STDMETHOD(put_LanguageCode)(/*[in]*/ BSTR newVal);

	//Number of elements in collection
	STDMETHOD(get_Size)(/*[out, retval]*/ long*);

	//Returns item for specified index
	//STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);

	//Same as Size()
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	
	//NOT USED DIRECTLY
	//STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
private:
	BOOL InsertEntryIntoCollection(BSTR fqn, BSTR lang, CMTLocalizedEntry* pEntry);
	void AdvanceIterator(LocalizedMapIt* it, const int offset);
	_bstr_t mLanguageCode;
	LocalizedMap mLocalizedMap;
	LocalizedMapIt mIterator;
	MTAutoInstance<MTAutoLoggerImpl<LoggingMsg> >	mLogger;
};

#endif //__MTLOCALIZEDCOLLECTION_H_
