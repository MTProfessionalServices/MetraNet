// QueryParams.h : Declaration of the CQueryParams

#ifndef __QUERYPARAMS_H_
#define __QUERYPARAMS_H_

// Main symbols
#include "resource.h"

//HierarchyReports
#import <MTHierarchyReports.tlb> rename("EOF", "HR_EOF")

/////////////////////////////////////////////////////////////////////////////
// CQueryParams
class ATL_NO_VTABLE CQueryParams : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CQueryParams, &CLSID_QueryParams>,
	public ISupportErrorInfo,
	public IDispatchImpl<IQueryParams, &IID_IQueryParams, &LIBID_MTHIERARCHYREPORTSLib>
{
  public:
    CQueryParams() :
        m_pUnkMarshaler(NULL),
        m_lTopRows(0),      // Return all rows
      	m_ptrProductSlice(NULL),
	      m_ptrSessionSlice(NULL),
	      m_ptrAccountSlice(NULL),
       	m_ptrTimeSlice(NULL),
	      m_bstrExtension("")
    {
		  /* Do nothing here */
	  }

    DECLARE_REGISTRY_RESOURCEID(IDR_QUERYPARAMS)
    DECLARE_GET_CONTROLLING_UNKNOWN()

    DECLARE_PROTECT_FINAL_CONSTRUCT()

    BEGIN_COM_MAP(CQueryParams)
	    COM_INTERFACE_ENTRY(IQueryParams)
	    COM_INTERFACE_ENTRY(IDispatch)
	    COM_INTERFACE_ENTRY(ISupportErrorInfo)
	    COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
    END_COM_MAP()

	  HRESULT FinalConstruct()
	  {
      return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
	  }

	  void FinalRelease()
	  {
		  m_pUnkMarshaler.Release();
	  }

    // Public Data
	  CComPtr<IUnknown> m_pUnkMarshaler;

    // ISupportsErrorInfo
	  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

  // IQueryParams
  public:
	  STDMETHOD(get_TopRows)(/*[out, retval]*/ long *plVal);
    STDMETHOD(put_TopRows)(/*[in]*/ long lVal);

 	  STDMETHOD(get_SingleProductSlice)(/*[out, retval]*/ ISingleProductSlice **pProductSlice);
    STDMETHOD(put_SingleProductSlice)(/*[in]*/ ISingleProductSlice* pProductSlice);

 	  STDMETHOD(get_SessionSlice)(/*[out, retval]*/ IViewSlice **pSessionSlice);
    STDMETHOD(put_SessionSlice)(/*[in]*/ IViewSlice *pSessionSlice);

 	  STDMETHOD(get_AccountSlice)(/*[out, retval]*/ IAccountSlice **pAccountSlice);
    STDMETHOD(put_AccountSlice)(/*[in]*/ IAccountSlice *pAccountSlice);

 	  STDMETHOD(get_TimeSlice)(/*[out, retval]*/ ITimeSlice **pTimeSlice);
    STDMETHOD(put_TimeSlice)(/*[in]*/ ITimeSlice *pTimeSlice);

 	  STDMETHOD(get_Extension)(/*[out, retval]*/ BSTR *pbstrExtension);
    STDMETHOD(put_Extension)(/*[in]*/ BSTR bstrExtension);

  private:

    // Maximum number of rows to return in a query.
	  long m_lTopRows;

		MTHIERARCHYREPORTSLib::ISingleProductSlicePtr m_ptrProductSlice;
		MTHIERARCHYREPORTSLib::IViewSlicePtr m_ptrSessionSlice;
		MTHIERARCHYREPORTSLib::IAccountSlicePtr m_ptrAccountSlice;
 		MTHIERARCHYREPORTSLib::ITimeSlicePtr m_ptrTimeSlice;
		_bstr_t m_bstrExtension;
};

#endif //__QUERYPARAMS_H_

//-- EOF --