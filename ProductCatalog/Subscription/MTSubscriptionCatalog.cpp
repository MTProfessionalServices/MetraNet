// MTSubscriptionCatalog.cpp : Implementation of CMTSubscriptionCatalog

#include "StdAfx.h"
#include "MTSubscriptionCatalog.h"
#include <mtcomerr.h>

#import <MTSubscriptionExec.tlb> rename ("EOF", "EOFX")


// CMTSubscriptionCatalog

STDMETHODIMP CMTSubscriptionCatalog::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSubscriptionCatalog
	};

	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTSubscriptionCatalog::SubscribeToGroups(IMTCollection* pCol,
                                                       IMTProgress*   pProgress,
                                                       VARIANT_BOOL   bUnsubscribeConflicting,
                                                       VARIANT_BOOL*  pDateModified,
                                                       VARIANT        transaction,
                                                       IMTRowSet**    ppRowset)
{
  // NOTE: This method does not do failure auditing because everything in
  // the transaction is rolled back in case of one failure

  try
  {
    // check capability to create subscriptions
    CHECKCAP(CREATESUB_CAP);

    GUID subGUID = __uuidof(MTSubscriptionExecLib::MTSubscriptionCatalogWriter);
    MTSubscriptionExecLib::IMTSubscriptionCatalogWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else
    {
      SubWriter.CreateInstance(subGUID);
    }

    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));

    SubWriter->SubscribeToGroups(reinterpret_cast<MTSubscriptionExecLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr()),
                                 reinterpret_cast<MTSubscriptionExecLib::IMTCollection*>(pCol),
                                 reinterpret_cast<MTSubscriptionExecLib::IMTProgress*>(pProgress),
                                 bUnsubscribeConflicting,
                                 pDateModified,
                                 reinterpret_cast<MTSubscriptionExecLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));

    ROWSETLib::IMTRowSetPtr rs = errorRs; // QI
    *ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
  }
  catch(_com_error& err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTSubscriptionCatalog::SubscribeAccounts(IMTCollection* pCol,
                                                       IMTProgress*   pProgress,
                                                       VARIANT_BOOL   bUnsubscribeConflicting,
                                                       VARIANT_BOOL*  pDateModified,
                                                       VARIANT        transaction,
                                                       IMTRowSet**    ppRowset)
{
  // NOTE: This method does not do failure auditing because everything in
  // the transaction is rolled back in case of one failure

  HRESULT hr = S_OK;

  try
  {
    // check capability to create subscriptions
    bool bCreateSubNotChecked = true;
    bool bSelfSubNotChecked   = true;
    long curAccountID = GetSecurityContext()->AccountID;
    long size;
    pCol->get_Count(&size);
    for(long i = 1; i <= size; i++) 
    {
	    _variant_t var;

	    hr = pCol->get_Item(i, &var);
	    if (FAILED(hr))
		    return hr;

      MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr = var;

      var.Clear();

      if(!(memberPtr->IsGroupSub))
      {
        if (memberPtr->AccountID == curAccountID)
        {
          if (bSelfSubNotChecked)
          {
            // Only need to do this once.
            bSelfSubNotChecked = false;
            CHECKCAP(SELF_SUBSCRIBE);
          }
        }
        else
        {
          if (bCreateSubNotChecked)
          {
            // Only need to do this once.
            bCreateSubNotChecked = false;
            CHECKCAP(CREATESUB_CAP);
          }
        }

        if ((!bSelfSubNotChecked)
         && (!bCreateSubNotChecked))
        {
          // We know we can do anything so we are done!
          break;
        }
      }
    }

    GUID subGUID = __uuidof(MTSubscriptionExecLib::MTSubscriptionCatalogWriter);
    MTSubscriptionExecLib::IMTSubscriptionCatalogWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else
    {
      SubWriter.CreateInstance(subGUID);
    }

    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));

    SubWriter->SubscribeAccounts(reinterpret_cast<MTSubscriptionExecLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr()),
                                 reinterpret_cast<MTSubscriptionExecLib::IMTCollection*>(pCol),
                                 reinterpret_cast<MTSubscriptionExecLib::IMTProgress*>(pProgress),
                                 bUnsubscribeConflicting, 
                                 pDateModified,
                                 reinterpret_cast<MTSubscriptionExecLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));

    ROWSETLib::IMTRowSetPtr rs = errorRs; // QI
    *ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
  }
  catch(_com_error& err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTSubscriptionCatalog::SetSessionContext(IMTSessionContext* apSessionContext)
{
	try
	{
		mSessionContextPtr = apSessionContext;

		//give derived classes a chance to set session context of nested classes 
		OnSetSessionContext(apSessionContext);
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	
	return S_OK;
}

STDMETHODIMP CMTSubscriptionCatalog::GetSessionContext(IMTSessionContext **apSessionContext)
{
	//return an (addref'ed) copy
	MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr ctxtCopy = mSessionContextPtr;
	*apSessionContext = reinterpret_cast<IMTSessionContext *>(ctxtCopy.Detach());

	return S_OK;
}

// derived class can override this method to set session context of nested objects
// method should throw exception on error
void CMTSubscriptionCatalog::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
}

//helper method used to pass session context from business obj to executant
MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr CMTSubscriptionCatalog::GetSessionContextPtr()
{
	return mSessionContextPtr;
}


MTAuthInterfacesLib::IMTSecurityContextPtr CMTSubscriptionCatalog::GetSecurityContext()
{
  return  MTAuthInterfacesLib::IMTSecurityContextPtr(reinterpret_cast<IMTSecurityContext*>(mSessionContextPtr->GetSecurityContext().GetInterfacePtr()));
}
