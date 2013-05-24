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
	
// MTEnumType.h : Declaration of the CMTEnumType
#pragma warning(disable:4786)

#ifndef __MTENUMTYPE_H_
#define __MTENUMTYPE_H_

#include "resource.h"       // main symbols
#include "EnumConfig.h"
#include <autologger.h>
#include "enumtypelogging.h"

#import <MTEnumConfigLib.tlb>
//#import <MTEnumConfig.tlb>

//only need this type to keep a map of values/enumerator names
//in order to check for duplicate values when adding a new
//enumerator to an enum type
typedef map<_bstr_t, _bstr_t> EnumTypeValueColl;
typedef map<_bstr_t, _bstr_t>::iterator EnumTypeValueCollIterator;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumType
class ATL_NO_VTABLE CMTEnumType : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumType, &CLSID_MTEnumType>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumType, &IID_IMTEnumType, &LIBID_MTENUMCONFIGLib>
{
public:
	CMTEnumType():mStatus(L""), mEnumSpace(L""), mEnumType(L""), mEnumTypeDescription(L""), mEnumSpaceDescription(L"")
	{
		mEnumeratorCollection = 0;
		mEnumeratorCollection = MTENUMCONFIGLib::IMTEnumeratorCollectionPtr(MTPROGID_ENUMERATOR_COLLECTION);
		mpValueColl = new EnumTypeValueColl();
	}

	~CMTEnumType();
	
DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMTYPE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEnumType)
COM_INTERFACE_ENTRY(IMTEnumType)
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

// IMTEnumType
public:
	HRESULT FinalConstruct();
	//returns all enumerators defined for this enum type
	STDMETHOD(GetEnumerators)(/*[out, retval]*/ IMTEnumeratorCollection**);
	//returns description for enum space this enum type belongs to
	STDMETHOD(get_EnumSpaceDescription)(/*[out, retval]*/ BSTR *pVal);
	//INTERNAL USE ONLY
	STDMETHOD(put_EnumSpaceDescription)(/*[in]*/ BSTR newVal);
	//Returns description for this enum type
	STDMETHOD(get_EnumTypeDescription)(/*[out, retval]*/ BSTR *pVal);
	//Sets description for this enum type
	STDMETHOD(put_EnumTypeDescription)(/*[in]*/ BSTR newVal);
	//INTERNAL USE ONLY
	STDMETHOD(WriteSet)(IMTConfigPropSet* pSet);
	//adds MTEnumerator to collection
	STDMETHOD(Add)(::IMTEnumerator*);
	//Returns name for this enum type
	STDMETHOD(get_EnumTypeName)(/*[out, retval]*/ BSTR *pVal);
	//sets name for this enum type
	STDMETHOD(put_EnumTypeName)(/*[in]*/ BSTR newVal);
	//Returns enum space name this enum type belongs to
	STDMETHOD(get_Enumspace)(/*[out, retval]*/ BSTR *pVal);
	//INERNAL USE ONLY
	STDMETHOD(put_Enumspace)(/*[in]*/ BSTR newVal);
	//CURRENTLY NOT USED
	STDMETHOD(get_Status)(/*[out, retval]*/ BSTR *pVal);
	//CURRENTLY NOT USED
	STDMETHOD(put_Status)(/*[in]*/ BSTR newVal);
private:
	_bstr_t mEnumSpace;
	_bstr_t mEnumType;
	_bstr_t mStatus;
	_bstr_t mEnumTypeDescription;
	_bstr_t mEnumSpaceDescription;
	MTAutoInstance<MTAutoLoggerImpl<LoggingMsg> >	mLogger;
	MTENUMCONFIGLib::IMTEnumeratorCollectionPtr mEnumeratorCollection;
	EnumTypeValueColl* mpValueColl;
	EnumTypeValueCollIterator mValueCollIterator;
};

#endif //__MTENUMTYPE_H_
