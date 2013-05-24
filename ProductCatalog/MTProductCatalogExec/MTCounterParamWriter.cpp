// MTCounterParamWriter.cpp : Implementation of CMTCounterParamWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterParamWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParamWriter

STDMETHODIMP CMTCounterParamWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterParamWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterParamWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterParamWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCounterParamWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTCounterParamWriter::Create(IMTSessionContext *apCtxt, long alCounterID, IMTCounterParameter *apParam, long *aDBID)
{
  MTAutoContext context(m_spObjectContext);
  
  if (!apParam || !aDBID)
    return E_POINTER;
  
  //init out var
  *aDBID = 0;
  
  try
  {
    _variant_t val;
    _variant_t vtNull;
    vtNull.vt = VT_NULL;
    _variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
    
    MTCOUNTERLib::IMTCounterParameterPtr CounterParamPtr = apParam;
    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    GENERICCOLLECTIONLib::IMTCollectionPtr PredicateCollPtr;
    MTCOUNTERLib::IMTCounterParameterPredicatePtr CounterParamPredicatePtr;
    MTPRODUCTCATALOGEXECLib::IMTPredicateWriterPtr predicateWriter
      (__uuidof(MTPRODUCTCATALOGEXECLib::MTPredicateWriter));
    
    
    bool bUnowned = alCounterID < 0;
    
    rs->Init(CONFIG_DIR);
    rs->InitializeForStoredProc("AddCounterParam");

    rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, vLanguageCode);
    
    //if counter property is null then it's a standalone parameter
    //object
    val = bUnowned ? vtNull : alCounterID;
    
    rs->AddInputParameterToStoredProc (L"id_counter", MTTYPE_INTEGER, 
      INPUT_PARAM, val);
    
    val = bUnowned ? vtNull : CounterParamPtr->GetTypeID();
    
    rs->AddInputParameterToStoredProc (L"id_counter_param_type", MTTYPE_INTEGER, 
      INPUT_PARAM, val);
    
    val = CounterParamPtr->Value;
    if((V_VT(&val) == VT_NULL) || (V_VT(&val) == VT_EMPTY))
			MT_THROW_COM_ERROR("Counter Parameter value not set");

    rs->AddInputParameterToStoredProc (L"nm_counter_value", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);

    //if this counter parameter is owned by the counter, then
    //it's anonymous. Even if base props stuff was set, normalize it out
    

    val = bUnowned ?  CounterParamPtr->Name : vtNull;
    
    rs->AddInputParameterToStoredProc (L"nm_name", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);

    val = bUnowned ?  CounterParamPtr->Description : vtNull;
    
    rs->AddInputParameterToStoredProc (L"nm_desc", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);

    val = bUnowned ?  CounterParamPtr->DisplayName : vtNull;
    
    rs->AddInputParameterToStoredProc (L"nm_display_name", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);
    
    //init output
    rs->AddOutputParameterToStoredProc (L"identity", MTTYPE_INTEGER, 
      OUTPUT_PARAM);
    
    rs->ExecuteStoredProc();
    
    //Get PK from newly created entry
    val = rs->GetParameterFromStoredProc("identity");
    
    CounterParamPtr->PutID((long)val);
    
    PredicateCollPtr = CounterParamPtr->Predicates;
    long numPredicates = PredicateCollPtr->GetCount();
    
    for (int j=1; j <= numPredicates; ++j)
    {
      CounterParamPredicatePtr = PredicateCollPtr->GetItem(j);
      predicateWriter->Create
        (reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtxt), 
        reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameterPredicate*>(CounterParamPredicatePtr.GetInterfacePtr()));
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  
  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTCounterParamWriter::Update(IMTSessionContext *apCtxt, IMTCounterParameter *apParam)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCounterParamWriter::Remove(IMTSessionContext *apCtxt, IMTCounterParameter *apParam)
{
	// TODO: Add your implementation code here

	return S_OK;
}

