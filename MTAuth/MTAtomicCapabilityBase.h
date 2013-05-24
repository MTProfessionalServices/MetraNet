/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTATOMICCAPABILITYBASE_H_
#define __MTATOMICCAPABILITYBASE_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityBase
class ATL_NO_VTABLE CMTAtomicCapabilityBase : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTAtomicCapabilityBase, &CLSID_MTAtomicCapabilityBase>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTAtomicCapabilityBase, &IID_IMTAtomicCapabilityBase, &LIBID_MTAUTHLib>
{
public:
	CMTAtomicCapabilityBase()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTATOMICCAPABILITYBASE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTAtomicCapabilityBase)
	COM_INTERFACE_ENTRY(IMTAtomicCapabilityBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mID = -1;
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTAtomicCapabilityBase
public:
	STDMETHOD(Remove)(/*[in]*/IMTAtomicCapability* apThisPtr, IMTPrincipalPolicy* aPolicy);
	STDMETHOD(Save)(/*[in]*/IMTAtomicCapability* apCap, /*[in]*/IMTPrincipalPolicy* apPolicy);
	STDMETHOD(SetCapabilityType)(/*[in]*/IMTAtomicCapabilityType* apType);
	STDMETHOD(GetCapabilityType)(IMTAtomicCapability* thisPtr, /*[out, retval]*/IMTAtomicCapabilityType** apType);
	STDMETHOD(get_ParentID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ParentID)(/*[in]*/ long newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
private:
	MTAUTHLib::IMTAtomicCapabilityTypePtr mType;
	long mID;
	long mParentID;

#define DECLARE_ATOMIC_BASE_CLASS_POINTER	MTAUTHLib::IMTAtomicCapabilityBasePtr mAC;

#define DEFINE_ATOMIC_FINAL_CONSTRUCT	\
	HRESULT FinalConstruct()	\
	{	\
		HRESULT hr = mAC.CreateInstance(__uuidof(MTAUTHLib::MTAtomicCapabilityBase));	\
		if (FAILED(hr))	return hr;	\
		return CoCreateFreeThreadedMarshaler(	\
			GetControllingUnknown(), &m_pUnkMarshaler.p);	}

#define IMPLEMENT_BASE_ATOMIC_CAP_METHODS	\
		STDMETHOD(get_ID)( long *pVal)	\
		{	(*pVal) = mAC->ID; return S_OK; }	\
		STDMETHOD(put_ID)(long newVal)	\
		{	mAC->ID = newVal; return S_OK; }	\
		STDMETHOD(get_ParentID)( long *pVal)	\
		{	(*pVal) = mAC->ParentID; return S_OK; }	\
		STDMETHOD(put_ParentID)(long newVal)	\
		{	mAC->ParentID = newVal; return S_OK; }	\
		STDMETHOD(get_CapabilityType)(IMTAtomicCapabilityType** apType)	\
		{ \
			MTAUTHLib::IMTAtomicCapabilityPtr thisPtr = this;	\
			MTAUTHLib::IMTAtomicCapabilityTypePtr outPtr = mAC->GetCapabilityType(thisPtr);	\
			(*apType) = (IMTAtomicCapabilityType*)outPtr.Detach(); return S_OK; \
		} \
		STDMETHOD(put_CapabilityType)(IMTAtomicCapabilityType* apType)	\
		{ mAC->SetCapabilityType((MTAUTHLib::IMTAtomicCapabilityType*)apType); return S_OK; }
};

#endif //__MTATOMICCAPABILITYBASE_H_
