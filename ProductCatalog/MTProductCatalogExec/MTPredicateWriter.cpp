// MTPredicateWriter.cpp : Implementation of CMTPredicateWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTPredicateWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPredicateWriter
STDMETHODIMP CMTPredicateWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPredicateWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
HRESULT CMTPredicateWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPredicateWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPredicateWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTPredicateWriter::Create(IMTSessionContext *aCtx, IMTCounterParameterPredicate *aPredicate, long *apID)
{
  HRESULT hr(S_OK);
	MTAutoContext context(m_spObjectContext);
	_variant_t vNull;
	vNull.ChangeType(VT_NULL);

	try
	{
		MTCOUNTERLib::IMTCounterParameterPredicatePtr predicatePtr = aPredicate;
    MTCOUNTERLib::IMTCounterParameterPtr paramPtr = predicatePtr->CounterParameter;
    MTPRODUCTVIEWLib::IProductViewPropertyPtr pvpropPtr = predicatePtr->ProductViewProperty;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc ("AddCounterParamPredicate");
    rowset->AddInputParameterToStoredProc ("id_counter_param", MTTYPE_INTEGER, INPUT_PARAM, paramPtr->ID);
    rowset->AddInputParameterToStoredProc ("id_pv_prop", MTTYPE_INTEGER, INPUT_PARAM, pvpropPtr->ID);
    rowset->AddInputParameterToStoredProc ("nm_op", MTTYPE_VARCHAR, INPUT_PARAM, OpToString((MTOperatorType)predicatePtr->Operator));
    rowset->AddInputParameterToStoredProc ("nm_value", MTTYPE_VARCHAR, INPUT_PARAM, predicatePtr->Value);
    rowset->AddOutputParameterToStoredProc ("ap_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);
    rowset->ExecuteStoredProc();
    predicatePtr->ID = rowset->GetParameterFromStoredProc("ap_id_prop");

		(*apID) = predicatePtr->ID;
		context.Complete();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	
	return S_OK;
}
