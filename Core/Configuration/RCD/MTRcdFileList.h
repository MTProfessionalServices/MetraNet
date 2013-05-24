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
* $Header$
* 
***************************************************************************/
#ifndef __MTRCDFILELIST_H_
#define __MTRCDFILELIST_H_

#include <comutil.h>
#include <comip.h>
#include <comdef.h>
#include "resource.h"       // main symbols
#include <vector>

#include <vcue_copystring.h>

// using this for our enumeration stuff
namespace stringcoll {

	typedef std::vector< string >				ContainerType;

	// Use IEnumVARIANT as the enumerator for VB compatibility
	typedef VARIANT									EnumeratorExposedType;
	typedef IEnumVARIANT							EnumeratorInterface;

	// Our collection interface exposes the data as BSTRs
	//typedef BSTR									CollectionExposedType;
	typedef VARIANT									CollectionExposedType;

	typedef VCUE::GenericCopy<EnumeratorExposedType, ContainerType::value_type>		EnumeratorCopyType;

	// Now we have all the information we need to fill in the template arguments on the implementation classes
	typedef CComEnumOnSTL< EnumeratorInterface, &__uuidof(EnumeratorInterface), EnumeratorExposedType,
							EnumeratorCopyType, ContainerType > EnumeratorType;

};

typedef std::vector<string> RcdFileList;


/////////////////////////////////////////////////////////////////////////////
// CMTRcdFileList
class ATL_NO_VTABLE CMTRcdFileList : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRcdFileList, &CLSID_MTRcdFileList>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRcdFileList, &IID_IMTRcdFileList, &LIBID_RCDLib>
{
public:
	CMTRcdFileList() {}
	~CMTRcdFileList();

DECLARE_REGISTRY_RESOURCEID(IDR_MTRCDFILELIST)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRcdFileList)
	COM_INTERFACE_ENTRY(IMTRcdFileList)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRcdFileList
public:


	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Item)(/*[in] */long aIndex, /*[out, retval] */VARIANT *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(AddFile)(/*[in]*/ BSTR newVal);

public: // non COM methods
	void AddItem(string& aItem) { mFileList.push_back(aItem); }
	RcdFileList& GetFileList() { return mFileList; }
	void SetFileList(RcdFileList& aList) { mFileList = aList; }

protected: // data
	RcdFileList mFileList;
};

#endif //__MTRCDFILELIST_H_
