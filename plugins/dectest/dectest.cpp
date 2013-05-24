/**************************************************************************
 * DECTEST
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <PlugInSkeleton.h>

#include <MTDec.h>

using std::string;

// generate using uuidgen
CLSID CLSID_DecimalTest = { /* 54b7b180-7a0e-11d4-a409-00c04f484788 */
    0x54b7b180,
    0x7a0e,
    0x11d4,
    {0xa4, 0x09, 0x00, 0xc0, 0x4f, 0x48, 0x47, 0x88}
  };

class ATL_NO_VTABLE DecimalTestPlugIn
	: public MTPipelinePlugIn<DecimalTestPlugIn, &CLSID_DecimalTest>
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
	long mAmountPropID;
	long mUnitsPropID;
	MTDecimal mRate;
};


PLUGIN_INFO(CLSID_DecimalTest, DecimalTestPlugIn,
						"MetraPipeline.DecimalTest.1", "MetraPipeline.DecimalTest", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTTotalConfCharge::PlugInConfigure"
HRESULT DecimalTestPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("Amount",&mAmountPropID)
    DECLARE_PROPNAME("Units",&mUnitsPropID)
  END_PROPNAME_MAP

  HRESULT hr = ProcessProperties(inputs,aPropSet,aNameID,aLogger,PROCEDURE);
	if (FAILED(hr))
		return hr;

	mRate = aPropSet->NextDecimalWithName("Rate");
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT DecimalTestPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
#if 0
	MTDecimal val(20, 0);
	aSession->SetDecimalProperty(mUnitsPropID, val);

	MTDecimal val2;
	val2 = aSession->GetDecimalProperty(mUnitsPropID);
	string value = val.Format();
#endif

	MTDecimal val = aSession->GetDecimalProperty(mUnitsPropID);

	//MTDec rate(10, 0);
	MTDecimal result = val * mRate;

	string str = result.Format();

	aSession->SetDecimalProperty(mAmountPropID, result);
	//aSession->SetDoubleProperty(mAmountPropID, 1.45);

	//aSession->SetStringProperty(mAmountPropID, "This is a test");

  return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT DecimalTestPlugIn::PlugInShutdown()
{
	return S_OK;
}

