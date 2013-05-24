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
	
// COMPropertyCollection.h : Declaration of the CCOMPropertyCollection

#ifndef __COMPROPERTYCOLLECTION_H_
#define __COMPROPERTYCOLLECTION_H_

#include "resource.h"       // main symbols
#include <DBInMemRowset.h>
#include <DBProductViewProperty.h>
#include <ComDataLogging.h>
#include <autologger.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMPropertyCollection
class ATL_NO_VTABLE CCOMPropertyCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMPropertyCollection, &CLSID_COMPropertyCollection>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMPropertyCollection, &IID_ICOMPropertyCollection, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMPropertyCollection() ;
  virtual ~CCOMPropertyCollection() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMPROPERTYCOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMPropertyCollection)
	COM_INTERFACE_ENTRY(ICOMPropertyCollection)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
  
// ICOMPropertyCollection
public:
// The ViewID property gets the view id.
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
// The ViewID property sets the view id.
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// The Init method initializes the property collection for the specified view id.
  STDMETHOD(Init)();
// The EOF property gets the current status of the rowset cursor.
  STDMETHOD(get_EOF)(/*[out, retval]*/ VARIANT *pVal);
// The RecordCount property gets the number of rows in the rowset.
	STDMETHOD(get_RecordCount)(/*[out, retval]*/ long *pVal);
// The Type property gets the type for the specified column.
	STDMETHOD(get_Type)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// The Value property gets the value for the specified column.
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
// The Name property gets the name for the specified column.
	STDMETHOD(get_Name)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// The Count property gets the number of columns in the rowset.
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
// The MoveFirst method moves to the first row of the rowset.
	STDMETHOD(MoveFirst)();
// The MoveNext method moves to the next row of the rowset.
	STDMETHOD(MoveNext)();
// The MoveLast method moves to the last row of the rowset.
	STDMETHOD(MoveLast)();
private:
  BOOL InitializePropertyCollection() ;
  BOOL AddProperty(DBProductViewProperty *pProperty,
    const std::wstring &arViewType) ;
  BOOL AddAccountUsageProperties(const std::wstring &arType) ;
  BOOL AddRow (const std::wstring &arName, const std::wstring &arType,
    const std::wstring &arColumnName, const std::wstring &arEnumNamespace, 
    const std::wstring &arEnumEnumeration, const BOOL &arFilterable, const BOOL &arExportable) ;

  long                    mViewID;  
  DBInMemRowset          *mpRowset ;
	MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
};

#endif //__COMPROPERTYCOLLECTION_H_
