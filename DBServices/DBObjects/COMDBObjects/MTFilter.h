// MTFilter.h : Declaration of the CMTFilter

#ifndef __MTFILTER_H_
#define __MTFILTER_H_

#include "resource.h"       // main symbols
#include <DBInMemRowset.h>
#include <NTLogger.h>

/////////////////////////////////////////////////////////////////////////////
// CMTFilter
class ATL_NO_VTABLE CMTFilter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTFilter, &CLSID_MTFilter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTFilter, &IID_IMTFilter, &LIBID_COMDBOBJECTSLib>
{
public:
	CMTFilter() ;
  virtual ~CMTFilter() ;

DECLARE_REGISTRY_RESOURCEID(IDR_MTFILTER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTFilter)
	COM_INTERFACE_ENTRY(IMTFilter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTFilter
public:
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
	STDMETHOD(Init)();
	STDMETHOD(Clear)();
	STDMETHOD(Remove)(long aIndex);
	STDMETHOD(Add)(/*[in]*/BSTR aName, /*[in]*/BSTR aOperator, /*[in]*/BSTR aValue, MTPropertyType aType);
private:
  void TearDown() ;
  BOOL CreateAndInitializeRowset() ;

  DBInMemRowset          *mpRowset ;
  NTLogger                mLogger ;
};

#endif //__MTFILTER_H_
