/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Raju Matta
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <mtcom.h>
#include <mtprogids.h>
#include <accountplugindefs.h>
#include <TransactionPlugInSkeleton.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <DBConstants.h>
#include <stdutils.h>
#include <corecapabilities.h>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") 
// generate using uuidgen
CLSID CLSID_PRICELISTLOOKUP = {/*e413091c-46b0-4cba-93e3-d80ef935e8ea*/
    0xe413091c,
    0x46b0,
    0x4cba,
    {0x93, 0xe3, 0xd8, 0x0e, 0xf9, 0x35, 0xe8, 0xea} 
};

class ATL_NO_VTABLE PriceListLookupPlugIn : 
  public MTTransactionPlugIn<PriceListLookupPlugIn, &CLSID_PRICELISTLOOKUP>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary 
    // initialization.
	// NOTE: This method can be called any number of times in order to
	// refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(
	  MTPipelineLib::IMTLogPtr aLogger,
	  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
	  MTPipelineLib::IMTNameIDPtr aNameID,
      MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	
  virtual HRESULT 
  PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
  MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);


private:
	long mMeteredPricelist;
	long mResolvedPricelist;
  MTPipelineLib::IMTLogPtr mLogger;
	MTPRODUCTCATALOGLib::IMTProductCatalogPtr mPC;

};


PLUGIN_INFO(CLSID_PRICELISTLOOKUP, 
			PriceListLookupPlugIn,
			"MetraPipeline.PriceListLookup.1", 
			"MetraPipeline.PriceListLookup", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

HRESULT PriceListLookupPlugIn::PlugInConfigure(
  MTPipelineLib::IMTLogPtr aLogger,
  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
  MTPipelineLib::IMTNameIDPtr aNameID,
  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  mQueryInitPath = "queries\\AccountCreation";  
  const char* procName = "PriceListLookupPlugIn::PlugInConfigure";
  
  mLogger = aLogger;
  
  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("metered_pricelist",&mMeteredPricelist)
    DECLARE_PROPNAME("resolved_pricelist",&mResolvedPricelist)
  END_PROPNAME_MAP
    
  // create product catalog object
  mPC.CreateInstance(MTPROGID_MTPRODUCTCATALOG);
    
  return ProcessProperties(inputs,aPropSet,aNameID,aLogger,procName);
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT 
PriceListLookupPlugIn::PlugInProcessSessionWithTransaction(
	MTPipelineLib::IMTSessionPtr aSession,
  MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{
	HRESULT hr = S_OK;
	char buffer[255];

	_variant_t vtNull;
	vtNull.vt = VT_NULL;

	try
	{
		if(aSession->PropertyExists(mMeteredPricelist,
																MTPipelineLib::SESS_PROP_TYPE_STRING)) 
		{
			_bstr_t PriceList = aSession->GetStringProperty(mMeteredPricelist);

      if(_wcsicmp((wchar_t *)PriceList, L"NONE") == 0) {
        aSession->SetStringProperty(mResolvedPricelist, "");
        return S_OK;
      }

			MTPRODUCTCATALOGLib::IMTPriceListPtr aPriceList = 
															mPC->GetPriceListByName(PriceList);
			if(aPriceList == NULL) 
			{
   			sprintf (buffer, 
   					"Pricelist <%s> not found in product catalog", (const char*) PriceList);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, _bstr_t(buffer));
				return Error(buffer);
			}
			else 
			{
      	aSession->SetLongProperty(mResolvedPricelist,aPriceList->GetID());
			}
		}
	}

	catch (_com_error& e)
	{
		return ReturnComError(e); 
	}
		
	return (S_OK);
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT 
PriceListLookupPlugIn::PlugInShutdown()
{
	return S_OK;
}

