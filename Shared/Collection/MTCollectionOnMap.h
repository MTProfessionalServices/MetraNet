// MTCollectionOnMap.h : Declaration of the CMTCollectionOnMap

#ifndef __MTCOLLECTIONONMAP_H_
#define __MTCOLLECTIONONMAP_H_

#include "resource.h"       // main symbols

#include <vcue_collection.h>
#include <vcue_copy.h>


#include <map>

namespace MapColl
{
	// We always need to provide the following information
	typedef std::map< CAdapt< CComBSTR >, CComVariant >				ContainerType;
	typedef VARIANT																						ExposedType;
	typedef IEnumVARIANT																			EnumeratorInterface;
	typedef IMTCollectionOnMap																CollectionInterface;

	// Typically the copy policy can be calculated from the typedefs defined above:
	// typedef VCUE::GenericCopy<ExposedType, ContainerType::value_type>		CopyType;

	// However, we may want to use a different class, as in this case:
	typedef VCUE::MapCopy<ContainerType, ExposedType>				CopyType;
	// (The advantage of MapCopy is that we don't need to provide implementations 
	//  of GenericCopy for all the different pairs of key and value types)

	// Now we have all the information we need to fill in the template arguments on the implementation classes
	typedef CComEnumOnSTL< EnumeratorInterface, &__uuidof(EnumeratorInterface), ExposedType,
							CopyType, ContainerType > EnumeratorType;

	typedef VCUE::ICollectionOnSTLCopyImpl< CollectionInterface, ContainerType, ExposedType,
							CopyType, EnumeratorType > CollectionType;
};

using namespace MapColl;

/////////////////////////////////////////////////////////////////////////////
// CMTCollectionOnMap
class ATL_NO_VTABLE CMTCollectionOnMap : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCollectionOnMap, &CLSID_MTCollectionOnMap>,
	public ISupportErrorInfo,
	public IDispatchImpl<MapColl::CollectionType, &IID_IMTCollectionOnMap, &LIBID_COLLECTIONLib>
{
public:
	CMTCollectionOnMap()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOLLECTIONONMAP1)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCollectionOnMap)
	COM_INTERFACE_ENTRY(IMTCollectionOnMap)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCollectionOnMap
public:
		// ATL's collection implementation only allows numeric indexing (due to container-independence)
	// so we have to provide our own implementation to allow string indexing into the map
	STDMETHOD(get_Item)(VARIANT Index, VARIANT* pVal)
	{
		if (pVal == NULL)
			return E_POINTER;

		HRESULT hr = S_OK;
		CComVariant var;
		return S_OK;
	}
	STDMETHOD(Add)(VARIANT Key, VARIANT Value)
	{
		// Get a BSTR from the VARIANT
		CComBSTR str;
		HRESULT hr = VCUE::GenericCopy<BSTR, VARIANT>::copy(&str, &Key);

		// If we can't convert to a string, just return
		if (FAILED(hr))
			return hr;

		// Check whether item already exists
		if (m_coll.find(str) != m_coll.end())
			return E_FAIL;	// item with this key already exists

		// Add the item to the map
		m_coll[str] = Value;
		return S_OK;
	}

	STDMETHOD(Remove)(VARIANT Index)
	{
		HRESULT hr = S_OK;
		CComVariant var;

		return S_OK;
	}

	STDMETHOD(Remove)(long Index)
	{
		
		return S_OK;
	}

	STDMETHOD(Clear)()
	{
		// NOTE: This code can be used with most STL containers
		m_coll.clear();
		return S_OK;
	}
};

#endif //__MTCOLLECTIONONMAP_H_
