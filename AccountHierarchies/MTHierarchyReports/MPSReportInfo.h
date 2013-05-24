// MPSReportInfo.h : Declaration of the CMPSReportInfo

#ifndef __MPSREPORTINFO_H_
#define __MPSREPORTINFO_H_

#include "resource.h"       // main symbols
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMPSReportInfo
class ATL_NO_VTABLE CMPSReportInfo : 
	public CComObjectRootEx<CComSingleThreadModel>,
  public ISupportErrorInfo,
	public CComCoClass<CMPSReportInfo, &CLSID_MPSReportInfo>,
	public IDispatchImpl<IMPSReportInfo, &IID_IMPSReportInfo, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
  CMPSReportInfo() :
      mlngIndex(-1),
      msType(0),
      msViewType(0),
      msRestrictionBillable(0),
      msRestrictionFolderAccount(0),
      msRestrictionIndependentAccount(0),
      msRestrictionOwnedFolders(0),
      msRestrictionOwnedBillableFolders(0),
      msDisplayMethod(0),
      mlngAccountIDOverride(-1),
      mbRestricted(VARIANT_FALSE)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MPSREPORTINFO)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMPSReportInfo)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IMPSReportInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMPSReportInfo
public:
  STDMETHOD(get_RestrictionIndependentAccount)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_RestrictionIndependentAccount)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_AccountIDOverride)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountIDOverride)(/*[in]*/ long newVal);
	STDMETHOD(get_Index)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Index)(/*[in]*/ long newVal);
	STDMETHOD(get_RestrictionBillableOwnedFolders)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_RestrictionBillableOwnedFolders)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_RestrictionOwnedFolders)(/*[out, retval]*/ MPS_RESTRICTION *pVal);
	STDMETHOD(put_RestrictionOwnedFolders)(/*[in]*/ MPS_RESTRICTION newVal);
	STDMETHOD(get_DisplayData)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DisplayData)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_DisplayMethod)(/*[out, retval]*/ MPS_DISPLAY_METHOD *pVal);
	STDMETHOD(put_DisplayMethod)(/*[in]*/ MPS_DISPLAY_METHOD newVal);
	STDMETHOD(get_Restricted)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Restricted)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_RestrictionFolderAccount)(/*[out, retval]*/ MPS_RESTRICTION *pVal);
	STDMETHOD(put_RestrictionFolderAccount)(/*[in]*/ MPS_RESTRICTION newVal);
	STDMETHOD(get_RestrictionBillable)(/*[out, retval]*/ MPS_RESTRICTION *pVal);
	STDMETHOD(put_RestrictionBillable)(/*[in]*/ MPS_RESTRICTION newVal);
	STDMETHOD(get_ViewType)(/*[out, retval]*/ MPS_VIEW_TYPE *pVal);
	STDMETHOD(put_ViewType)(/*[in]*/ MPS_VIEW_TYPE newVal);
	STDMETHOD(get_Type)(/*[out, retval]*/ MPS_REPORT_TYPE *pVal);
	STDMETHOD(put_Type)(/*[in]*/ MPS_REPORT_TYPE newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InlineAdjustments)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InteractiveReport)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_InlineVATTaxes)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InlineVATTaxes)(/*[in]*/ VARIANT_BOOL newVal);


	

private:
	long mlngIndex;
	short msType;
  short msViewType;
  short msRestrictionBillable;
  short msRestrictionFolderAccount;
  short msRestrictionIndependentAccount;
  short msRestrictionOwnedFolders;
  short msRestrictionOwnedBillableFolders;  
  short msDisplayMethod;
  long mlngAccountIDOverride;
  

  VARIANT_BOOL mbRestricted;
	VARIANT_BOOL mbInlineVATTaxes;
	VARIANT_BOOL mbInteractiveReport;
	VARIANT_BOOL mbInlineAdjustments;

	_bstr_t mstrName;
  _bstr_t mstrDescription;
  _bstr_t mstrDisplayData;
};

#endif //__MPSREPORTINFO_H_
