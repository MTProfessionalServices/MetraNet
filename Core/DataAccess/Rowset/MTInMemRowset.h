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
* Created by: 
* $Header$
* 
***************************************************************************/
	
// MTInMemRowset.h : Declaration of the CMTInMemRowset

#ifndef __MTINMEMROWSET_H_
#define __MTINMEMROWSET_H_

#include "resource.h"       // main symbols
#include <autologger.h>
#include <DbObjectsLogging.h>

class DBInMemRowset ;

/////////////////////////////////////////////////////////////////////////////
// CMTInMemRowset
class ATL_NO_VTABLE CMTInMemRowset : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTInMemRowset, &CLSID_MTInMemRowset>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTInMemRowset, &IID_IMTInMemRowset, &LIBID_ROWSETLib>
{
public:
	CMTInMemRowset() ;
  ~CMTInMemRowset() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTINMEMROWSET)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTInMemRowset)
	COM_INTERFACE_ENTRY(IMTInMemRowset)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTInMemRowset
public:
// ----------------------------------------------------------------
// The EOF property returns the current status of the rowset cursor.
// ----------------------------------------------------------------
	STDMETHOD(get_EOF)(/*[out, retval]*/ VARIANT *pVal);
// ----------------------------------------------------------------
// The Sort method is not implemented for the in-memory rowset..
// ----------------------------------------------------------------
	STDMETHOD(Sort)(BSTR aPropertyName, MTSortOrder aSortOrder);
// ----------------------------------------------------------------
// The AddRow method adds a row to the rowset.
// ----------------------------------------------------------------
	STDMETHOD(AddRow)();
// ----------------------------------------------------------------
// The AddColumnData adds the data in the specified column.
// ----------------------------------------------------------------
	STDMETHOD(AddColumnData)(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue);
// ----------------------------------------------------------------
// The ModifyColumnData modifies the data in the specified column.
// ----------------------------------------------------------------
	STDMETHOD(ModifyColumnData)(/*[in]*/ BSTR apName, /*[in]*/ VARIANT aValue);
// ----------------------------------------------------------------
// The AddColumnDefinition method adds a new column to the rowset definition.
// ----------------------------------------------------------------
	STDMETHOD(AddColumnDefinition)(/*[in]*/ BSTR apName, /*[in]*/ BSTR apType);
// ----------------------------------------------------------------
// The Init method initializes the in-memory rowset.
// ----------------------------------------------------------------
	STDMETHOD(Init)();
// ----------------------------------------------------------------
// The RecordCount property gets the number of records in the rowset.
// ----------------------------------------------------------------
	STDMETHOD(get_RecordCount)(/*[out, retval]*/ long *pVal);
// ----------------------------------------------------------------
// The Type property gets the data type of the specified column,
// ----------------------------------------------------------------
	STDMETHOD(get_Type)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// ----------------------------------------------------------------
// The Value property gets the value of the specified column.
// ----------------------------------------------------------------
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
// ----------------------------------------------------------------
// The Name property gets the name of the specified column.
// ----------------------------------------------------------------
	STDMETHOD(get_Name)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
// ----------------------------------------------------------------
// The Count property gets the number of columns in the rowset.
// ----------------------------------------------------------------
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
// ----------------------------------------------------------------
// The MoveFirst method moves to the first row in a populated rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveFirst)();
// ----------------------------------------------------------------
// The MoveNext method moves to the next row in a populated rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveNext)();
// ----------------------------------------------------------------
// The MoveLast method moves to the last row in a populated rowset.
// ----------------------------------------------------------------
	STDMETHOD(MoveLast)();
		// ----------------------------------------------------------------
	// The CurrentPage property gets the current page of the cursor.
	// ----------------------------------------------------------------
  STDMETHOD(get_CurrentPage)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The CurrentPage property sets the current page of the cursor.
	// ----------------------------------------------------------------
	STDMETHOD(put_CurrentPage)(/*[in]*/ long newVal);
	// ----------------------------------------------------------------
	// The PageCount property gets the number of pages in the rowset.
	// ----------------------------------------------------------------
	STDMETHOD(get_PageCount)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The PageSize property gets the current page size.
	// ----------------------------------------------------------------
	STDMETHOD(get_PageSize)(/*[out, retval]*/ long *pVal);
	// ----------------------------------------------------------------
	// The PageSize property sets the page size.
	// ----------------------------------------------------------------
	STDMETHOD(put_PageSize)(/*[in]*/ long newVal);

	STDMETHOD(putref_Filter)(IMTDataFilter* pFilter);
	STDMETHOD(get_Filter)(IMTDataFilter** pFilter);
	STDMETHOD(ResetFilter)();
	STDMETHOD(get_ValueNoLog)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(ApplyExistingFilter)();
  STDMETHOD(RemoveRow)();


private:
  DBInMemRowset *         mpRowset ;
  MTAutoInstance<MTAutoLoggerImpl<szDbAccessTag,szDbObjectsDir> >	mLogger; 
};

#endif //__MTINMEMROWSET_H_
