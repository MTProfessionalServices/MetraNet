/**************************************************************************
 * @doc QUOTE
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
 * Created by: Derek Young
 *
 * Modified by: David McCowan 5/28/99
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include "stdio.h"
#include <MTDec.h>

// generate using uuidgen
CLSID CLSID_QuotePlugIn = { /* 3bcf27e0-14fe-11d3-a6bc-00c04f58c76e */
    0x3bcf27e0,
    0x14fe,
    0x11d3,
    {0xa6, 0xbc, 0x00, 0xc0, 0x4f, 0x58, 0xc7, 0x6e}
  };

class ATL_NO_VTABLE MTQuotePlugIn
	: public MTPipelinePlugIn<MTQuotePlugIn, &CLSID_QuotePlugIn>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
																	MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:

	// property ID
	long mFlatRate;
	long mScheduledDuration;
	long mNumberConnections;
  long mAmount;
  long mXactionID;
  long mTestSession;

  // calculation parameters
#ifdef DECIMAL_PLUGINS
  MTDecimal mMinimumAmount;
  MTDecimal mMultiplier;
  MTDecimal mFlatAmount;
  MTDecimal mPerMinute;
#else
  double mMinimumAmount;
  double mMultiplier;
  double mFlatAmount;
  double mPerMinute;
#endif
  BOOL    mApplyMinimum;
  _bstr_t mChargeType;

	// interface to the logging system
	MTPipelineLib::IMTLogPtr mLogger;
};


PLUGIN_INFO(CLSID_QuotePlugIn, MTQuotePlugIn,
						"MetraPipeline.QuotePlugIn.1", "MetraPipeline.QuotePlugIn", "Free")

HRESULT
MTQuotePlugIn::PlugInConfigure(
  MTPipelineLib::IMTLogPtr aLogger,
  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
  MTPipelineLib::IMTNameIDPtr aNameID,
  MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr = S_OK;

  try
  {
    mLogger = aLogger;
  
    mLogger->LogString(
      MTPipelineLib::PLUGIN_LOG_DEBUG,
      "MTQuotePlugIn::PlugInConfigure: entered\n");

    // figure out which property we're going to take as input
    _bstr_t FlatRate      = aPropSet->NextStringWithName("csrassignedflatrate");
    _bstr_t Duration      = aPropSet->NextStringWithName("scheduledduration");
    _bstr_t NumConns      = aPropSet->NextStringWithName("numberconnections");
    _bstr_t XactionID     = aPropSet->NextStringWithName("transactionid");
    _bstr_t TestSession   = aPropSet->NextStringWithName("testsession");

    // retrieve the property we're going to set as output
    // this data is added to the session
    _bstr_t Amount        = aPropSet->NextStringWithName("amount");

   // read initialization data from the xml file
    mChargeType    = aPropSet->NextStringWithName("chargetype");
    mApplyMinimum  = aPropSet->NextBoolWithName("applyminimum");
#ifdef DECIMAL_PLUGINS
    mMinimumAmount = aPropSet->NextDecimalWithName("minimumamount");
    mPerMinute     = aPropSet->NextDecimalWithName("perminute");
    mFlatAmount    = aPropSet->NextDecimalWithName("flatamount");
#else
    mMinimumAmount = aPropSet->NextDoubleWithName("minimumamount");
    mPerMinute     = aPropSet->NextDoubleWithName("perminute");
    mFlatAmount    = aPropSet->NextDoubleWithName("flatamount");
#endif

    // look up the property IDs of the props we need
    MTPipelineLib::IMTNameIDPtr idlookup(aSysContext);

    mFlatRate          = idlookup->GetNameID(FlatRate);
	  mScheduledDuration = idlookup->GetNameID(Duration);
    mNumberConnections = idlookup->GetNameID(NumConns);
    mAmount            = idlookup->GetNameID(Amount);
    mXactionID         = idlookup->GetNameID(XactionID);
    mTestSession       = idlookup->GetNameID(TestSession);
  }
  catch (_com_error err)
  {
    hr = err.Error();
  }

	return hr;
}

HRESULT MTQuotePlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT aHr = S_OK;

#ifdef DECIMAL_PLUGINS
	
  try
  {
    char         LogBuf[1024];
    long         duration     = aSession->GetLongProperty(mScheduledDuration);
    long         numconns     = aSession->GetLongProperty(mNumberConnections);
    MTDecimal    overriderate = aSession->GetDecimalProperty(mFlatRate);
    _bstr_t      XactionID    = aSession->GetBSTRProperty(mXactionID);
    long         testsession  = aSession->GetLongProperty(mTestSession); 
    MTDecimal    quote;

    //
    // This plugin does not treat test and live sessions differently.
    //

    // calculate rate

    if (overriderate > 0.0)
    {
      // A flat rate specified by the CSR overrides all else.
      quote = overriderate;
    }
    else
    {
      if (0 == strcmp((const char *)mChargeType, (const char *)"flatrate"))
      {
        // A flat rate specified in the config mgr is next in 
        // order of precedence.
        quote = mFlatAmount;
      }
      else
      {
        quote = MTDecimal(numconns) * MTDecimal(duration) * mPerMinute; 

        //if (0.0 != mMultiplier)
        //  quote = quote * mMultiplier;

        // config mgr specifies a minimum amount.
        if (mApplyMinimum && (quote < mMinimumAmount))
            quote = mMinimumAmount;
      }
    }

    // set amount in session
    aSession->SetDecimalProperty(mAmount, quote);

    sprintf(
      LogBuf,
      "MTQuotePlugIn::PlugInProcessSession: xactionid %s quote %.02f",
      (const char *)XactionID,
      quote);

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, LogBuf);

    // set the return property specified in the
		// plug-in's configuration
  }
  catch (HRESULT hr)
  {
    aHr =  hr;
  }
  catch (_com_error err)
  {
    aHr = err.Error();
  }

#else

  try
  {
    char         LogBuf[1024];
    long         duration     = aSession->GetLongProperty(mScheduledDuration);
    long         numconns     = aSession->GetLongProperty(mNumberConnections);
    double       overriderate = aSession->GetDoubleProperty(mFlatRate);
    _bstr_t      XactionID    = aSession->GetBSTRProperty(mXactionID);
    long         testsession  = aSession->GetLongProperty(mTestSession); 
    double       quote;

    //
    // This plugin does not treat test and live sessions differently.
    //

    // calculate rate

    if (overriderate > 0.0)
    {
      // A flat rate specified by the CSR overrides all else.
      quote = overriderate;
    }
    else
    {
      if (0 == strcmp((const char *)mChargeType, (const char *)"flatrate"))
      {
        // A flat rate specified in the config mgr is next in 
        // order of precedence.
        quote = mFlatAmount;
      }
      else
      {
        quote = numconns * duration * mPerMinute; 

        //if (0.0 != mMultiplier)
        //  quote = quote * mMultiplier;

        // config mgr specifies a minimum amount.
        if (mApplyMinimum && (quote < mMinimumAmount))
            quote = mMinimumAmount;
      }
    }

    // set amount in session
    aSession->SetDoubleProperty(mAmount, quote);

    sprintf(
      LogBuf,
      "MTQuotePlugIn::PlugInProcessSession: xactionid %s quote %.02f",
      (const char *)XactionID,
      quote);

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, LogBuf);

    // set the return property specified in the
		// plug-in's configuration
  }
  catch (HRESULT hr)
  {
    aHr =  hr;
  }
  catch (_com_error err)
  {
    aHr = err.Error();
  }

#endif

	return aHr;
}

HRESULT MTQuotePlugIn::PlugInShutdown()
{
	return S_OK;
}
