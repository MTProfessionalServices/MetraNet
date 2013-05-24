/**************************************************************************
* Copyright 2004 by MetraTech
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

#ifndef __MTSUBINFO_H_
#define __MTSUBINFO_H_


#include "resource.h"
#include "MTProductCatalog.h"


class ATL_NO_VTABLE CMTSubInfo : 
  public CComObjectRootEx<CComMultiThreadModel>,
  public CComCoClass<CMTSubInfo, &CLSID_MTSubInfo>,
  public ISupportErrorInfo,
  public IDispatchImpl<IMTSubInfo, &IID_IMTSubInfo, &LIBID_MTPRODUCTCATALOGLib>
{
public:

  CMTSubInfo();

  DECLARE_REGISTRY_RESOURCEID(IDR_MTSUBINFO)
  DECLARE_GET_CONTROLLING_UNKNOWN()

  DECLARE_PROTECT_FINAL_CONSTRUCT()

  BEGIN_COM_MAP(CMTSubInfo)
	  COM_INTERFACE_ENTRY(IMTSubInfo)
	  COM_INTERFACE_ENTRY(IDispatch)
	  COM_INTERFACE_ENTRY(ISupportErrorInfo)
	  COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
  END_COM_MAP()

  HRESULT FinalConstruct();

  void FinalRelease()
  {
    m_pUnkMarshaler.Release();
  }

  CComPtr<IUnknown> m_pUnkMarshaler;

  // ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

public:

  // IMTSubInfo

  STDMETHOD(get_AccountID) (/*[out, retval]*/ long* pVal);
  STDMETHOD(put_AccountID) (/*[in]*/          long  newVal);

  STDMETHOD(get_CorporateAccountID) (/*[out, retval]*/ long* pVal);
  STDMETHOD(put_CorporateAccountID) (/*[in]*/          long  newVal);

  STDMETHOD(get_SubsID) (/*[out, retval]*/ long* pVal);
  STDMETHOD(put_SubsID) (/*[in]*/          long  newVal);

  STDMETHOD(get_SubsStartDate) (/*[out, retval]*/ DATE* pVal);
  STDMETHOD(put_SubsStartDate) (/*[in]*/          DATE  newVal);

  STDMETHOD(get_SubsStartDateAsBSTR) (/*[out, retval]*/ BSTR* pVal);
  STDMETHOD(put_SubsStartDateAsBSTR) (/*[in]*/          BSTR  newVal);

  STDMETHOD(get_SubsStartDateType) (/*[out, retval]*/ MTPCDateType* pVal);
  STDMETHOD(put_SubsStartDateType) (/*[in]*/          MTPCDateType  newVal);

  STDMETHOD(get_SubsEndDate) (/*[out, retval]*/ DATE* pVal);
  STDMETHOD(put_SubsEndDate) (/*[in]*/          DATE  newVal);

  STDMETHOD(get_SubsEndDateAsBSTR) (/*[out, retval]*/ BSTR* pVal);
  STDMETHOD(put_SubsEndDateAsBSTR) (/*[in]*/          BSTR  newVal);

  STDMETHOD(get_SubsEndDateType) (/*[out, retval]*/ MTPCDateType* pVal);
  STDMETHOD(put_SubsEndDateType) (/*[in]*/          MTPCDateType  newVal);

  STDMETHOD(get_ProdOfferingID) (/*[out, retval]*/ long* pVal);
  STDMETHOD(put_ProdOfferingID) (/*[in]*/          long  newVal);

  STDMETHOD(get_IsGroupSub) (/*[out, retval]*/ VARIANT_BOOL* pVal);

  STDMETHOD(get_GroupSubID) (/*[out, retval]*/ long* pVal);
  STDMETHOD(put_GroupSubID) (/*[in]*/          long  newVal);

  STDMETHOD(GetAll) (long*         pAccountID,
                     long*         pCorporateAccountID,
                     long*         pSubsID,
                     DATE*         pSubsStartDate,
                     MTPCDateType* pSubsStartDateType,
                     DATE*         pSubsEndDate,
                     MTPCDateType* pSubsEndDateType,
                     long*         pProdOfferingID,
                     VARIANT_BOOL* pIsGroupSub,
                     long*         pGroupSubID);
  STDMETHOD(PutAll) (long         newAccountID,
                     long         newCorporateAccountID,
                     long         newSubsID,
                     DATE         newSubsStartDate,
                     MTPCDateType newSubsStartDateType,
                     DATE         newSubsEndDate,
                     MTPCDateType newSubsEndDateType,
                     long         newProdOfferingID,
                     VARIANT_BOOL newIsGroupSub,
                     long         newGroupSubID);
  STDMETHOD(GetAllWithBSTRDates) (long*         pAccountID,
                                  long*         pCorporateAccountID,
                                  long*         pSubsID,
                                  BSTR*         pSubsStartDate,
                                  MTPCDateType* pSubsStartDateType,
                                  BSTR*         pSubsEndDate,
                                  MTPCDateType* pSubsEndDateType,
                                  long*         pProdOfferingID,
                                  VARIANT_BOOL* pIsGroupSub,
                                  long*         pGroupSubID);
  STDMETHOD(PutAllWithBSTRDates) (long         newAccountID,
                                  long         newCorporateAccountID,
                                  long         newSubsID,
                                  BSTR         newSubsStartDate,
                                  MTPCDateType newSubsStartDateType,
                                  BSTR         newSubsEndDate,
                                  MTPCDateType newSubsEndDateType,
                                  long         newProdOfferingID,
                                  VARIANT_BOOL newIsGroupSub,
                                  long         newGroupSubID);

private:

  long         mAccountID;
  long         mCorporateAccountID;
  long         mSubsID;
  DATE         mSubsStartDate;
  MTPCDateType mSubsStartDateType;
  DATE         mSubsEndDate;
  MTPCDateType mSubsEndDateType;
  long         mProdOfferingID;
  VARIANT_BOOL mIsGroupSub;
  long         mGroupSubID;         // Only valid if mIsGroupSub is VARIANT_TRUE.
};


#endif // #ifndef __MTSUBINFO_H_
