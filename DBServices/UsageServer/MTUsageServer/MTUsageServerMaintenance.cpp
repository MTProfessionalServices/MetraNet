// MTUsageServerMaintenance.cpp : Implementation of CMTUsageServerMaintenance
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "MTUsageServerMaintenance.h"

#include <mtcom.h>
#include <comdef.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <UsageServerConstants.h>

#undef min
#undef max

#include <mttime.h>
#include <MTDate.h>


// import the usage server tlb ...
#import <MTUsageServer.tlb> rename( "EOF", "RowsetEOF" )

/////////////////////////////////////////////////////////////////////////////
// CMTUsageServerMaintenance


STDMETHODIMP CMTUsageServerMaintenance::RunRecurringEvents()
{

    HRESULT nRetVal=S_OK ;

      // create the usageserver ...
    MTUSAGESERVERLib::ICOMUsageServerPtr usageServer;
      
      nRetVal = usageServer.CreateInstance(MTPROGID_USAGESERVER) ;
      if (!SUCCEEDED(nRetVal))
      {
        //cout << "ERROR: unable to create instance of usage server. Error = " << hex << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return nRetVal;
      }


      // do the periodic stuff for the beginning of the period ... 
      nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
        MTUSAGESERVERLib::EVENT_PERIOD_BEGIN) ;
      if (!SUCCEEDED (nRetVal))
      {
        //cout << "ERROR: Unable to execute recurring events. Error = " << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return nRetVal;
      }
      
      // do the periodic stuff for the end of the period ... 
      nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
        MTUSAGESERVERLib::EVENT_PERIOD_SOFT_CLOSE) ;
      if (!SUCCEEDED (nRetVal))
      {
        //cout << "ERROR: Unable to execute recurring events. Error = " << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return nRetVal;
      }
      
      // do the periodic stuff for the end of the period ... 
      nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
        MTUSAGESERVERLib::EVENT_PERIOD_HARD_CLOSE) ;
      if (!SUCCEEDED (nRetVal))
      {
        //cout << "ERROR: Unable to execute recurring events. Error = " << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return nRetVal;
      }

	return nRetVal;
}


STDMETHODIMP CMTUsageServerMaintenance::CloseIntervals(VARIANT aExpirationDate, int aSoftGracePeriod, int aHardGracePeriod)
{

      HRESULT nRetVal=S_OK ;

      // create the usageserver ...
      MTUSAGESERVERLib::ICOMUsageServerPtr usageServer;
      MTUSAGESERVERLib::ICOMUsageIntervalCollPtr pUsageIntervalColl=NULL ;

      long nIntervalSoftClose=aSoftGracePeriod;
      long nIntervalHardClose=aHardGracePeriod;

      _variant_t vtEOF ;

      nRetVal = usageServer.CreateInstance(MTPROGID_USAGESERVER) ;
      if (!SUCCEEDED(nRetVal))
      {
        //cout << "ERROR: unable to create instance of usage server. Error = " << hex << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return nRetVal;
      }

        // get the usage interval collection ...
      pUsageIntervalColl = usageServer->GetUsageIntervals(USAGE_INTERVAL_OPEN) ;
      if (pUsageIntervalColl == NULL)
      {
        //cout << "ERROR: unable to get usage interval collection. Error = " << hex << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return E_FAIL;
      }

      _variant_t vtTempDate(aExpirationDate);
      vtTempDate.ChangeType(VT_DATE);

      //Calculate Soft and Hard close end dates
      _variant_t vtSoftCloseDate;
      _variant_t vtHardCloseDate;

      if (nIntervalSoftClose>0) 
      {
          vtSoftCloseDate = ((double)vtTempDate - nIntervalSoftClose);
          vtSoftCloseDate.ChangeType(VT_DATE);
      }
      else
      {
          vtSoftCloseDate = aExpirationDate;
          vtSoftCloseDate.ChangeType(VT_DATE);
      }

      if (nIntervalHardClose>0) 
      {
          vtHardCloseDate = ((double)vtTempDate - nIntervalHardClose);
          vtHardCloseDate.ChangeType(VT_DATE);
      }
      else
      {
          vtHardCloseDate = aExpirationDate;
          vtHardCloseDate.ChangeType(VT_DATE);
      }

      _variant_t vtExpired ;
    
      // iterate through the collection and check for expired usage intervals ...
      pUsageIntervalColl->get_RowsetEOF(&vtEOF) ;
      while (vtEOF.boolVal == VARIANT_FALSE)
      {
        // check to see if the usage interval is expired ...
        pUsageIntervalColl->get_Expired(vtSoftCloseDate, &vtExpired) ;
        if (vtExpired.boolVal == VARIANT_TRUE)
        {
          // usage interval is expired ... update it to closed ...
          pUsageIntervalColl->PutStatus(USAGE_INTERVAL_PENDING_SOFT_CLOSE);
        }
        
        // move to the next record ...
        pUsageIntervalColl->MoveNext() ;
        
        // get the eof flag ...
        pUsageIntervalColl->get_RowsetEOF(&vtEOF) ;
      }
      
      // get the usage interval collection ...
      pUsageIntervalColl = usageServer->GetUsageIntervals(USAGE_INTERVAL_SOFT_CLOSED) ;
      if (pUsageIntervalColl == NULL)
      {
        //cout << "ERROR: unable to get usage interval collection. Error = " << hex << nRetVal << endl ;
        //cout << "Please check the MetraTech log for more information." << endl ;
        return E_FAIL;
      }

      _variant_t vtClosed ;

      // iterate through the collection and check for expired usage intervals ...
      pUsageIntervalColl->get_RowsetEOF(&vtEOF) ;
      while (vtEOF.boolVal == VARIANT_FALSE)
      {
        // check to see if the usage interval is expired ...
        pUsageIntervalColl->get_Closed(vtHardCloseDate, &vtClosed) ;
        if (vtClosed.boolVal == VARIANT_TRUE)
        {
          // usage interval is expired ... update it to closed ...
          pUsageIntervalColl->PutStatus(USAGE_INTERVAL_PENDING_HARD_CLOSE) ;
        }
        
        // move to the next record ...
        pUsageIntervalColl->MoveNext() ;
        
        // get the eof flag ...
        pUsageIntervalColl->get_RowsetEOF(&vtEOF) ;
      }



	return nRetVal;
}

STDMETHODIMP CMTUsageServerMaintenance::RunSpecificRecurringEvent(MTRecurringEvent aEvent)
{
      HRESULT nRetVal=S_OK ;

      //Validate the passed value
      if (aEvent<=::__EVENT_BEGIN||aEvent>=::__EVENT_END)
      {
        return Error ("RunSpecificRecurringEvent: Bad Parameter: Event value out of bounds", IID_IMTUsageServerMaintenance, E_FAIL);
      }

      // create the usageserver ...
      MTUSAGESERVERLib::ICOMUsageServerPtr usageServer;
      
      nRetVal = usageServer.CreateInstance(MTPROGID_USAGESERVER) ;
      if (!SUCCEEDED(nRetVal))
      {
        return Error ("Unable to create Usage Server component", IID_IMTUsageServerMaintenance, nRetVal) ;
      }

      if (aEvent==::EVENT_PERIOD_BEGIN||aEvent==::EVENT_PERIOD_ALL)
      {
        // do the periodic stuff for the beginning of the period ... 
        nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
          MTUSAGESERVERLib::EVENT_PERIOD_BEGIN) ;
        if (!SUCCEEDED (nRetVal))
        {
          return Error ("Error running EVENT_PERIOD_BEGIN", IID_IMTUsageServerMaintenance, nRetVal) ;
        }
      }

      if (aEvent==::EVENT_PERIOD_SOFT_CLOSE||aEvent==::EVENT_PERIOD_ALL)
      {
        // do the periodic stuff for the end of the period ... 
        nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
          MTUSAGESERVERLib::EVENT_PERIOD_SOFT_CLOSE) ;
        if (!SUCCEEDED (nRetVal))
        {
          return Error ("Error running EVENT_PERIOD_SOFT_CLOSE", IID_IMTUsageServerMaintenance, nRetVal) ;
       }
      }

      if (aEvent==::EVENT_PERIOD_HARD_CLOSE||aEvent==::EVENT_PERIOD_ALL)
      {
        // do the periodic stuff for the end of the period ... 
        nRetVal = usageServer->DoRecurringEvent (USAGE_CYCLE_PERIOD_BILLING, 
          MTUSAGESERVERLib::EVENT_PERIOD_HARD_CLOSE) ;
        if (!SUCCEEDED (nRetVal))
        {
          return Error ("Error running EVENT_PERIOD_HARD_CLOSE", IID_IMTUsageServerMaintenance, nRetVal) ;
        }
      }

	return nRetVal;

}
