/**************************************************************************
 *
 * Copyright 2001 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 * $Header: c:\development35\ProductCatalog\Counter\MTCounterParameter.h, 24, 7/9/2002 3:56:17 PM, Alon Becker$
 *
 ***************************************************************************/


#ifndef __MTCOUNTERPARAMETER_H_
#define __MTCOUNTERPARAMETER_H_

#include "MTCounterView.h"
#include "counterincludes.h"
#include <PropertiesBase.h>
#include <MTPCBase.h>


#define USAGE_TABLE L"t_acc_usage"


using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParameter
class ATL_NO_VTABLE CMTCounterParameter : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCounterParameter, &CLSID_MTCounterParameter>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterParameter, &IID_IMTCounterParameter, &LIBID_MTCOUNTERLib>,
  public CMTPCBase,
	public PropertiesBase
{
public:
	CMTCounterParameter() : mbPropertyOfUsageTable(FALSE),
													mName(L""),
													mDescription(L""),
													mValue(L""),
													mFinalValue(L""),
													mAlias(L""),
													mPVName(L""),
													mPropertyName(L""),
													mTableName(L""),
													mViewName(L""),
													mPVTableName(L""),
													mColumnName(L""),
                          mpCharge(NULL),
                          mAdjustmentTable(L""),
                          mPITypeID(-1),
													mbIsShared(false)
                          {}
	
	HRESULT FinalConstruct();
	void FinalRelease();


DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPARAMETER)

DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCounterParameter)
	COM_INTERFACE_ENTRY(IMTCounterParameter)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCounterParameter
public:
	STDMETHOD(Save)(/*[out, retval]*/ long* apDBID);
	STDMETHOD(get_Counter)(/*[out, retval]*/ IMTCounter* *pVal);
	STDMETHOD(put_Counter)(/*[in]*/ IMTCounter* newVal);
	STDMETHOD(CreatePredicate)(/*[out, retval]*/IMTCounterParameterPredicate** apPredicate);
	STDMETHOD(get_Predicates)(/*[out, retval]*/ IMTCollection* *pVal);
	STDMETHOD(get_ReadOnly)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_ReadOnly)(/*[in]*/ VARIANT_BOOL newVal);
	DEFINE_MT_PROPERTIES_BASE_METHODS1
  DEFINE_MT_PCBASE_METHODS
	STDMETHOD(get_ViewName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_FinalValue)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_ColumnName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_TableName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_DBType)(/*[out, retval]*/ BSTR	pVal);
	STDMETHOD(get_DBType)(/*[out, retval]*/ MTCounterParamDBType* pVal);
	STDMETHOD(put_Kind)(/*[out, retval]*/ BSTR	pVal);
	STDMETHOD(get_Kind)(/*[out, retval]*/ MTCounterParamKind*	pVal);
	STDMETHOD(put_Value)(/*[out, retval]*/ BSTR	pVal);
	STDMETHOD(get_Value)(/*[out, retval]*/ BSTR* pVal);
	STDMETHOD(put_Name)(/*[out, retval]*/ BSTR pVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Alias)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Alias)(/*[out, retval]*/ BSTR newVal);
	STDMETHOD(get_ProductViewName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_ProductViewTable)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_PropertyName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_TypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TypeID)(/*[in]*/ long newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[out, retval]*/ long newVal);
  STDMETHOD(put_DisplayName)(/*[out, retval]*/ BSTR pVal);
	STDMETHOD(get_DisplayName)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(put_Description)(/*[out, retval]*/ BSTR pVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);

  STDMETHOD(get_ChargeID)(/*[out, retval]*/ long *pVal);

  STDMETHOD(put_AdjustmentTable)(/*[out, retval]*/ BSTR newVal);
	STDMETHOD(get_AdjustmentTable)(/*[out, retval]*/ BSTR *pVal);

  STDMETHOD(get_PriceableItemTypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PriceableItemTypeID)(/*[out, retval]*/ long newVal);

	STDMETHOD(get_Shared)(/*[out, retval]*/ VARIANT_BOOL *pVal);

	
  
private:
	//CProductViewCollection mPVColl; TODO: Enable
	_bstr_t mName;
	_bstr_t mDescription;
	_bstr_t mValue;
	_bstr_t mFinalValue;

	_bstr_t mAlias;
	_bstr_t mPVName;
	_bstr_t mPropertyName;
	_bstr_t mTableName;
	_bstr_t mViewName;
	_bstr_t mPVTableName;
	_bstr_t mColumnName;
	long	mlTypeID;
	long	mlID;
  long mPITypeID;
	bool mbPropertyOfUsageTable;
	long mCounterID;
	MTCounterParamKind meKind;
	MTCounterParamDBType meDBType;
	bool mbIsShared;

  _bstr_t mAdjustmentTable;
	

	HRESULT SetPVNameAndPropertyNameFromValue();
	HRESULT SetProductViewTableAndColumn();
	void SetFinalValueFromValue();
	_bstr_t GetMSIXFileFromPVName(const _bstr_t& aPVName);
	
	CComPtr<IUnknown> mUnkMarshalerPtr;
	NTThreadLock mLock;

  MTObjectCollection<IMTCounterParameterPredicate> mPredicates;
  MTPRODUCTCATALOGLib::IMTChargePtr mpCharge;
};

#endif //__MTCOUNTERPARAMETER_H_



