
#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <AccountTools.h>
#include <stdio.h>
#include <mtprogids.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") no_namespace

// import the vendor kiosk tlb...
#import <COMKiosk.tlb> 
using namespace COMKIOSKLib;

BOOL MTAccountTools::AddAccountMapping(const std::string& aNamespace,const long aAccountId)
{
#if 0
	ComInitialize aComInit;
#endif
	HRESULT hr(S_OK);
	BOOL bRetVal(FALSE);
  BOOL bRowsetCreated(FALSE) ;
  IMTSQLRowsetPtr pRowset ;
  HRESULT nRetVal=S_OK ;

	do {
		try
		{
      // create the rowset object and begin the transaction ...
      nRetVal = pRowset.CreateInstance(MTPROGID_SQLROWSET) ;
      if (!SUCCEEDED(nRetVal))
      {
        sprintf(mErrorString,"ERROR: unable to create instance of sql rowset. Error = %d\n",
          nRetVal);
        break;
      }
      nRetVal = pRowset->Init("\\Queries\\PresServer") ;
      if (!SUCCEEDED(nRetVal))
      {
        sprintf(mErrorString,"ERROR: unable to begin transaction of sql rowset. Error = %d\n",
          nRetVal);
        break;
      }
      nRetVal = pRowset->BeginTransaction() ;
      if (!SUCCEEDED(nRetVal))
      {
        sprintf(mErrorString,"ERROR: unable to begin transaction of sql rowset. Error = %d\n",
          nRetVal);
        break;
      }
      bRowsetCreated = TRUE ;
      
      // extract the interface pointer ...
      LPDISPATCH pDispatch=NULL ;
      nRetVal = pRowset.QueryInterface (IID_IDispatch, &pDispatch) ;
      if (!SUCCEEDED(nRetVal))
      {
        sprintf(mErrorString,"ERROR: unable to get dispatch interface of rowset. Error = %d\n",
          nRetVal);
        break;
      }

			// create the vendor kiosk ...
			COMKIOSKLib::ICOMAccountMapperPtr comaccountmapper;
			hr = comaccountmapper.CreateInstance("COMAccountMapper.COMAccountMapper.1");
			if (!SUCCEEDED(hr))
			{
				sprintf(mErrorString,"ERROR: unable to create instance of com account mapper. Error = %X\n",hr);
				break;
			}

			// initialize the account mapper object ...
			hr = comaccountmapper->Initialize ();
			if (!SUCCEEDED(hr))
			{
				sprintf(mErrorString,"ERROR: unable to initialize account mapper. Error = %X\n",hr);
				break;
			}
			// add
			hr = comaccountmapper->Add (mAccountName.c_str(), aNamespace.c_str(), 
        aAccountId, pDispatch);
			if (!SUCCEEDED(hr))
			{
				sprintf(mErrorString,"ERROR: unable to add into account mapper table. Error = %X\n",hr);
				break;
			}
      nRetVal = pRowset->CommitTransaction() ;
      if (!SUCCEEDED(nRetVal))
      {
        sprintf(mErrorString,"ERROR: unable to commit transaction. Error = %X\n",nRetVal);
        break;
      }

			pDispatch->Release();

      bRetVal = TRUE;
		}
		catch (_com_error e)
		{
			hr = e.Error();
			sprintf(mErrorString,"ERROR: caught _com_error. Error = %X\n",hr);
		}
	} while(false);

  if ((bRetVal == FALSE) && (bRowsetCreated == TRUE))
  {
    pRowset->RollbackTransaction() ;
  }

  return bRetVal;
}
