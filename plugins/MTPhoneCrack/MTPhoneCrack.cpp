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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <stdio.h>
#include <PlugInSkeleton.h>
#include <mtprogids.h>
#include <mtcomerr.h>




#import <PhoneLookup.tlb>
using namespace PHONELOOKUPLib;

//shouldn't need it anymore: Syscontext object aggregates IEnumConfig interface
//#import <MTEnumConfig.tlb>

#define MAX __max
#define MIN __min

// generate using uuidgen
//CLSID __declspec(uuid("68354511-FFFA-11D2-AE57-00C04F54FE3B")) CLSID_MTPhoneCrack;

CLSID CLSID_MTPhoneCrack = { /* 68354511-FFFA-11D2-AE57-00C04F54FE3B */
    0x68354511,
    0xFFFA,
    0x11D2,
    {0xAE, 0x57, 0x00, 0xC0, 0x4f, 0x54, 0xFE, 0x3B}
  };


class ATL_NO_VTABLE MTPhoneCrack
	: public MTPipelinePlugIn<MTPhoneCrack, &CLSID_MTPhoneCrack>
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

protected: // Non COM Methods

private: // data
  MTPipelineLib::IMTLogPtr mLogger;

  long mUserPhoneNumber,mDNISDigits,mCallType,mBridgeName,mTransport,mCountry,
    mInternationalFlag, mCountryCode, mNPA, mNXX, mCountryNameID,mRegion,mLocality;

  //RAK
  long mDialIn, mDialOut, mTollFree, mToll, mInt, mDomestic;

  IPhoneNumberParserPtr mPhoneParser;
	//MTPipelineLib::IMTEnumTypePtr enumPtr;
	MTPipelineLib::IMTNameIDPtr NameIDPtr;
  //RAK_bstr_t mDialInStr, mDialOutStr, mTollFreeStr, mTollStr, mIntStr, mDomesticStr;
	MTPipelineLib::IEnumConfigPtr mEnumConfig;
};



PLUGIN_INFO(CLSID_MTPhoneCrack, MTPhoneCrack,
						"MTPipeline.MTPhoneCrack.1", "MTPipeline.MTPhoneCrack", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTPhoneCrack::PlugInConfigure"
HRESULT MTPhoneCrack::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{

  // Store pointers for use in process session		 
  NameIDPtr = aNameID;			
	// enumPtr = aSysContext;
  mLogger = aLogger;
  
  char buffer[1024];

  // step 1: get the properties from the XML
  _bstr_t HostName,ConfigPath,ConfigFileName;

  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("DNISDigits",&mDNISDigits)
    DECLARE_PROPNAME("userphonenumber",&mUserPhoneNumber)
    DECLARE_PROPNAME("bridgename",&mBridgeName)
    DECLARE_PROPNAME("transport",&mTransport)
    DECLARE_PROPNAME("country",&mCountry)
    DECLARE_PROPNAME_OPTIONAL("regiondescription",&mRegion)
    DECLARE_PROPNAME_OPTIONAL("localitydescription",&mLocality)
    DECLARE_PROPNAME("internationalflag",&mInternationalFlag)
    DECLARE_PROPNAME("calltype",&mCallType)
	  DECLARE_PROPNAME_OPTIONAL("CountryCode", &mCountryCode)
	  DECLARE_PROPNAME_OPTIONAL("NPA", &mNPA)
	  DECLARE_PROPNAME_OPTIONAL("NXX", &mNXX)
	  DECLARE_PROPNAME_OPTIONAL("CountryNameID", &mCountryNameID)
  END_PROPNAME_MAP

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,"MTPhoneCrack: ProcessProperties Start");
  HRESULT hr =  ProcessProperties(inputs,aPropSet,aNameID,mLogger,PROCEDURE);
  
  if(SUCCEEDED(hr)) {
	aPropSet->Reset();
    HostName = aPropSet->NextStringWithName("hostname");
    ConfigPath = aPropSet->NextStringWithName("configpath");
    ConfigFileName = aPropSet->NextStringWithName("configfilename");

    //mDialInStr = aPropSet->NextStringWithName("DialIn");
    mDialIn = aPropSet->NextLongWithName("DialIn");
	//mDialOutStr = aPropSet->NextStringWithName("DialOut");
	mDialOut = aPropSet->NextLongWithName("DialOut");

    //mTollFreeStr = aPropSet->NextStringWithName("TollFree");
    //mTollStr = aPropSet->NextStringWithName("Toll");
    //mIntStr = aPropSet->NextStringWithName("International");
    //mDomesticStr = aPropSet->NextStringWithName("Domestic");

		mTollFree = aPropSet->NextLongWithName("TollFree");
  	mToll = aPropSet->NextLongWithName("Toll");
  	mInt = aPropSet->NextLongWithName("International");
  	mDomestic = aPropSet->NextLongWithName("Domestic");

    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,"MTPhoneCrack: ProcessProperties Succeeded");

  }
  else
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "MTPhoneCrack: Failed in ProcessProperties");
  }

	try
	{
		mEnumConfig = aSysContext->GetEnumConfig();
	}
	catch(_com_error& e)
	{
		sprintf(buffer, "PhoneCrack plugin: unable to get IEnumConfig pointer from IMTSystemContext");
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, _bstr_t(buffer));
		return ReturnComError(e);
	}

  
  mPhoneParser.CreateInstance(MTPROGID_PHONEPARSER);

  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,"MTPhoneCrack: Starting PhoneParser->Read");
  mPhoneParser->Read (HostName, ConfigPath, ConfigFileName);
  mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG,"MTPhoneCrack: PhoneParser->Read Completed");

  return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTPhoneCrack::PlugInProcessSession"
HRESULT MTPhoneCrack::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  try
  {
    _bstr_t Bridge = aSession->GetBSTRProperty(mBridgeName);
    mPhoneParser->SetEffectiveDevice (Bridge);
    
    //_bstr_t CallType = aSession->GetBSTRProperty(mCallType);
    long CallType = aSession->GetEnumProperty(mCallType);
    
    
    //if (CallType == mDialInStr)
    if (CallType == mDialIn)
    {
      _bstr_t DNIS = aSession->GetBSTRProperty(mDNISDigits);
      mPhoneParser->PutDialedNumber (DNIS);
    }
    //else if (CallType == mDialOutStr)
    else if (CallType == mDialOut)
    {
      _bstr_t UserPhoneNumber = aSession->GetBSTRProperty(mUserPhoneNumber);
      mPhoneParser->PutDialedNumber (UserPhoneNumber);
    }
    else
    {
      mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR,
        _bstr_t("CPhoneCrack::Configure: Unknown Call Type\n"));
      return E_FAIL;
    }
    
    // set the return property specified in the
    // plug-in's configuration
    _bstr_t bstrCountryName = mPhoneParser->GetCountryName();
    if(bstrCountryName.length() > 0)
      aSession->SetBSTRProperty(mCountry, bstrCountryName);
    else
    {
      char buf[1024];
      sprintf("Country Name Not Found for specified phone number: <%s>", (const char*)mPhoneParser->GetDialedNumber());
      MT_THROW_COM_ERROR(buf);
    }
    
    _bstr_t bstrRegionDescription = mPhoneParser->GetRegionDescription();
    if ((mRegion != -1) && (bstrRegionDescription.length() > 0))
      aSession->SetBSTRProperty(mRegion, bstrRegionDescription);

    _bstr_t bstrLocalityDescription = mPhoneParser->GetLocalityDescription();
    if ((mLocality != -1) && (bstrLocalityDescription.length() > 0))
      aSession->SetBSTRProperty(mLocality, bstrLocalityDescription);

    // if dial-in and toll free --> toll free
    // if dial-in and toll --> toll 
    //RAKif (CallType == mDialInStr)
    if (CallType == mDialIn)
    {
      if (mPhoneParser->GetTollFree())
        aSession->SetEnumProperty(mTransport, mTollFree);
      else
        aSession->SetEnumProperty(mTransport,mToll);
    }
    
    // if dial-out and international --> international 
    // if dial-out and not international --> domestic
    //RAKif (CallType == mDialInStr)
    if (CallType == mDialOut)
    {
      if (mPhoneParser->GetInternational())
        aSession->SetEnumProperty(mTransport,mInt);
      else
        aSession->SetEnumProperty(mTransport,mDomestic);
    }
    
    if (mPhoneParser->GetInternational())
      aSession->SetBoolProperty(mInternationalFlag, VARIANT_TRUE);
    else
      aSession->SetBoolProperty(mInternationalFlag, VARIANT_FALSE);
    
    // Set some optional properties as requested
    if (mCountryCode != -1)
      aSession->SetBSTRProperty(mCountryCode, mPhoneParser->GetCountryCode());
    
    if (mNPA != -1)
      aSession->SetBSTRProperty(mNPA, mPhoneParser->GetNationalCode());
    
    if (mNXX != -1)
      aSession->SetBSTRProperty(mNXX, mPhoneParser->GetLocalityCode());
    
    if (mCountryNameID != -1)
    {
      _bstr_t name = mEnumConfig->GetFQN(L"Global", L"CountryName", bstrCountryName);
      aSession->SetEnumProperty(mCountryNameID, NameIDPtr->GetNameID((const wchar_t *)name));
    }
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTPhoneCrack::PlugInShutdown()
{
	return S_OK;
}
