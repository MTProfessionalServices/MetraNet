/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* 
***************************************************************************/
	
// MTCompositeCapability.h : Declaration of the CMTCompositeCapability

#ifndef __MTCOMPOSITECAPABILITYBASE_H_
#define __MTCOMPOSITECAPABILITYBASE_H_

#include "resource.h"       // main symbols


/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapability
class ATL_NO_VTABLE CMTCompositeCapabilityBase : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCompositeCapabilityBase, &CLSID_MTCompositeCapabilityBase>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCompositeCapabilityBase, &IID_IMTCompositeCapabilityBase, &LIBID_MTAUTHLib>
{
public:
	CMTCompositeCapabilityBase()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOMPOSITECAPABILITYBASE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCompositeCapabilityBase)
	COM_INTERFACE_ENTRY(IMTCompositeCapabilityBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		mType = NULL;
		mID = -1;
		mActorAccount = -1;
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
	

// IMTCompositeCapability
public:
	STDMETHOD(GetAtomicCapabilityByName)(IMTCompositeCapability* aThisPtr, /*[in]*/BSTR aAtomicName, /*[out, retval]*/IMTAtomicCapability** apCap);
  STDMETHOD(GetAtomicEnumCapability)(IMTCompositeCapability* aThisPtr, /*[out, retval]*/IMTEnumTypeCapability** apCap);
  STDMETHOD(GetAtomicPathCapability)(IMTCompositeCapability* aThisPtr, /*[out, retval]*/IMTPathCapability** apCap);
  STDMETHOD(GetAtomicDecimalCapability)(IMTCompositeCapability* aThisPtr, /*[out, retval]*/IMTDecimalCapability** apCap);
	STDMETHOD(Remove)(/*[in]*/IMTCompositeCapability* aThisPtr, /*[in]*/IMTPrincipalPolicy* aPolicy);
	STDMETHOD(GetCapabilityType)(/*[in]*/IMTCompositeCapability* thisPtr, /*[out, retval]*/ IMTCompositeCapabilityType** pVal);
	STDMETHOD(SetCapabilityType)(/*[in]*/ IMTCompositeCapabilityType* newVal);
	STDMETHOD(Save)(/*[in]*/IMTCompositeCapability* aThisPtr, IMTPrincipalPolicy* aPolicy);
	STDMETHOD(AddAtomicCapability)(/*[in]*/IMTAtomicCapability* aAtomicCap);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(Implies)(IMTCompositeCapability* aThisPtr, /*[in]*/IMTCompositeCapability* aCapability, VARIANT_BOOL aCheckparameters, /*[out, retval]*/VARIANT_BOOL* aResult);
	STDMETHOD(get_AtomicCapabilities)(/*[in]*/IMTCollection** aCaps);

  STDMETHOD(FromXML)(IMTCompositeCapability* aThisPtr, IDispatch* aDomNode);
  STDMETHOD(ToXML)(IMTCompositeCapability* aThisPtr, BSTR* apXmlString);
  STDMETHOD(ToString)(IMTCompositeCapability* aThisPtr, BSTR* apString);
  STDMETHOD(get_ActorAccountID)(/*[out, retval]*/ long *pVal);
  STDMETHOD(put_ActorAccountID)(/*[in]*/ long newVal);
  STDMETHOD(GetAtomicCollectionCapability)(/*[in]*/IMTCompositeCapability *aThisPtr, /*[out, retval]*/IMTStringCollectionCapability **apCap);
private:
	MTObjectCollection<IMTAtomicCapability> mAtomicCaps;
	MTAUTHLib::IMTCompositeCapabilityTypePtr mType;
	long mID;
	long mActorAccount;
  MSXML2::IXMLDOMNodePtr ValidateAtomicCap(MTAUTHLib::IMTCompositeCapabilityPtr& aThisPtr, MSXML2::IXMLDOMNodePtr& aNodePtr, char* aTag);
  MSXML2::IXMLDOMNodePtr ValidateTag(MTAUTHLib::IMTAtomicCapabilityPtr& aAtomicPtr, MSXML2::IXMLDOMNodePtr& aNodePtr, char* aTag);
};



#endif //__MTCOMPOSITECAPABILITY_H_