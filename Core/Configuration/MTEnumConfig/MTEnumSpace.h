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

// MTEnumSpace.h : Declaration of the CMTEnumSpace

#ifndef __MTENUMSPACE_H_
#define __MTENUMSPACE_H_

#include "resource.h"       // main symbols
#include "MTEnumConfig.h"
#include "EnumConfig.h"
#include <autologger.h>
#include "enumtypelogging.h"

//#import <MTEnumConfig.tlb>


/////////////////////////////////////////////////////////////////////////////
// CMTEnumSpace
class ATL_NO_VTABLE CMTEnumSpace : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumSpace, &CLSID_MTEnumSpace>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumSpace, &IID_IMTEnumSpace, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumSpace(): mName(L""), mDescription(L""), mLocation(L"")
	{
		mEnumTypeCollection = MTENUMCONFIGLib::IMTEnumTypeCollectionPtr("Metratech.MTEnumTypeCollection.1");
	
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMSPACE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumSpace)
	COM_INTERFACE_ENTRY(IMTEnumSpace)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

void FinalRelease()
{
	m_pUnkMarshaler.Release();
}

CComPtr<IUnknown> m_pUnkMarshaler;

// IMTEnumSpace
public:
	HRESULT FinalConstruct();
	//INTERNAL USE ONLY
	STDMETHOD(WriteSet)(IMTConfigPropSet*);
	//File where this enum space is defined
	STDMETHOD(get_Location)(/*[out, retval]*/ BSTR *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(put_Location)(/*[in]*/ BSTR newVal);
	//Returnes enum space description
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	//sets enum space description
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	//returns enum space name
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	//sets enum space name
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	//adds enum type to this enum space
	STDMETHOD(Add)(IMTEnumType*);
	//Returns MTEnumType by given name
	STDMETHOD(GetEnumType)(BSTR name, IMTEnumType** pEnum);
	//Returns enum types in this enum space
	STDMETHOD(GetEnumTypes)(IMTEnumTypeCollection** pEnumColl);
	// return the extension name
	STDMETHOD(get_Extension)(BSTR* pExtensionName);

private:
	MTAutoInstance<MTAutoLoggerImpl<LoggingMsg> >	mLogger;
	MTENUMCONFIGLib::IMTEnumTypeCollectionPtr mEnumTypeCollection;
	_bstr_t mName, mDescription, mLocation,mExtension;
};
#endif //__MTENUMSPACE_H_
