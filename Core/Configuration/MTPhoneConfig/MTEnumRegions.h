// MTEnumRegions.h : Declaration of the CMTEnumRegions

#ifndef __MTENUMREGIONS_H_
#define __MTENUMREGIONS_H_

#include "resource.h"       // main symbols
#include <vector>
using std::vector;

/////////////////////////////////////////////////////////////////////////////
// CMTEnumRegions
class ATL_NO_VTABLE CMTEnumRegions : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEnumRegions, &CLSID_MTEnumRegions>,
	public IDispatchImpl<IMTEnumRegions, &IID_IMTEnumRegions, &LIBID_PHONELOOKUPLib>
{
public:
	CMTEnumRegions() : mCount(0)
	{
	}

	virtual ~CMTEnumRegions ()
	{
		for (int i=0 ; i < mCount; i++)
		{
//			mRegionList[i]->Release();
		}

	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMREGIONS)

BEGIN_COM_MAP(CMTEnumRegions)
	COM_INTERFACE_ENTRY(IMTEnumRegions)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IMTEnumRegions
public:
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ LPDISPATCH *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(Add)(IMTRegion * pItem);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(InitFromPropSet )(IDispatch * pSet);
	STDMETHOD(Read )(BSTR bstrHostName, BSTR bstrFileName);
	STDMETHOD(ReadFromDatabase )(BSTR bstrCountry);

private:
  vector<CComPtr<IMTRegion> > mRegionList;
	long	mCount;	
};

#endif //__MTENUMREGIONS_H_
