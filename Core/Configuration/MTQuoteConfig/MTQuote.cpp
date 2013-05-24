// MTQuote.cpp : Implementation of CMTQuote

#include "StdAfx.h"

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTQuoteConfig.h"
#include "MTQuote.h"
#include <loggerconfig.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <string.h>
#include <ConfigDir.h>
/////////////////////////////////////////////////////////////////////////////
// CMTQuote

STDMETHODIMP CMTQuote::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTQuote
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTQuote::Read(BSTR bstrHostName, BSTR bstrPath, BSTR bstrFileName)
{
	// TODO: Add your implementation code here
	IMTConfigPtr pConfig;
	IMTConfigPropSetPtr pProp;
	VARIANT_BOOL bChkSum=false;
	VARIANT_BOOL bSecure=false;
	std::string cstrTemp;

	mHostName = bstrHostName;
	
	mPath = "";
	if (mHostName == (_bstr_t)"")
		if (GetMTConfigDir (cstrTemp))
			mPath = (char *)cstrTemp.c_str();
	mPath += bstrPath;
	mPath += L"\\";

	mPath += bstrFileName;

	_bstr_t RelativePath;
	RelativePath = mPath;

	try 
	{
		pConfig.CreateInstance("MetraTech.MTConfig.1", NULL, CLSCTX_INPROC_SERVER);

		if (mHostName != (_bstr_t)"")
			pProp = pConfig->ReadConfigurationFromHost (bstrHostName, RelativePath, bSecure, &bChkSum);
		else
			pProp = pConfig->ReadConfiguration (RelativePath, &bChkSum);


		IMTConfigPropSetPtr MTConfigSet = pProp->NextSetWithName(OLESTR("mtconfigdata"));
		IMTConfigPropSetPtr MTProcessorSet = MTConfigSet->NextSetWithName(OLESTR("processor"));
		IMTConfigPropSetPtr ConfigSet = MTProcessorSet->NextSetWithName(OLESTR("configdata"));

		// Get the values
		mChargeType = ConfigSet->NextStringWithName(L"chargetype");
		mApplyMinimum = ConfigSet->NextBoolWithName(L"applyminimum");
		mMinAmount  = ConfigSet->NextDoubleWithName(L"minimumamount");
		mPerMinuteAmount  = ConfigSet->NextDoubleWithName(L"perminute");
		mFlatAmount  = ConfigSet->NextDoubleWithName(L"flatamount");

	}
	catch (_com_error Error)
	{
/*
		HRESULT nRetVal = CORE_ERR_NO_PROP_SET ; 
		ErrorObject Err (CORE_ERR_NO_PROP_SET, ERROR_MODULE, ERROR_LINE, 
				"PhoneNumberParser::Read");
		mLogger.LogErrorObject(LOG_ERROR, &Err) ;
		mLogger.LogVarArgs (LOG_ERROR, "Unable to read configuration file <%s> from host <%s>.", 
					(char*)RelativePath, (char*)(_bstr_t)bstrHostName);
*/
		throw Error;	
	}

	return S_OK;
}

STDMETHODIMP CMTQuote::Write()
{
	// Save the values to a file 

  IMTConfigPtr config("MetraTech.MTConfig.1");
  IMTConfigPropSetPtr PropSet;


  // TODO: should this always be xmlconfig?
  PropSet = config->NewConfiguration("xmlconfig");

  IMTConfigPropSetPtr MTSysConfigData = PropSet->InsertSet("mtsysconfigdata");

  time_t ltime;
  time(&ltime);
  MTSysConfigData->InsertProp("effective_date", MTConfigLib::PROP_TYPE_DATETIME, (long)ltime);
  MTSysConfigData->InsertProp("timeout", MTConfigLib::PROP_TYPE_INTEGER, (long)30);
  MTSysConfigData->InsertProp("configfiletype", MTConfigLib::PROP_TYPE_STRING, "CONFIG_DATA");

  IMTConfigPropSetPtr MTConfigData = PropSet->InsertSet("mtconfigdata");
  MTConfigData->InsertProp("version", MTConfigLib::PROP_TYPE_INTEGER, (long)1);

  IMTConfigPropSetPtr ProcessorData = MTConfigData->InsertSet("processor");
  ProcessorData->InsertProp("name", MTConfigLib::PROP_TYPE_STRING, "quote");
  ProcessorData->InsertProp("progid", MTConfigLib::PROP_TYPE_STRING, "MetraPipeline.QuotePlugIn.1");

  IMTConfigPropSetPtr ConfigData = ProcessorData->InsertSet("configdata");
	
  ConfigData->InsertProp("csrassignedflatrate", MTConfigLib::PROP_TYPE_STRING, "flatrate");
  ConfigData->InsertProp("scheduledduration", MTConfigLib::PROP_TYPE_STRING, "scheduledduration");
  ConfigData->InsertProp("numberconnections", MTConfigLib::PROP_TYPE_STRING, "numberconnections");
  ConfigData->InsertProp("transactionid", MTConfigLib::PROP_TYPE_STRING, "transactionid");
  ConfigData->InsertProp("testsession", MTConfigLib::PROP_TYPE_STRING, "testsession");
  ConfigData->InsertProp("amount", MTConfigLib::PROP_TYPE_STRING, "_Amount");

  ConfigData->InsertProp("chargetype", MTConfigLib::PROP_TYPE_STRING, mChargeType);
  ConfigData->InsertProp("applyminimum", MTConfigLib::PROP_TYPE_BOOLEAN, mApplyMinimum);
  ConfigData->InsertProp("minimumamount", MTConfigLib::PROP_TYPE_DOUBLE, mMinAmount);
  ConfigData->InsertProp("perminute", MTConfigLib::PROP_TYPE_DOUBLE, mPerMinuteAmount);
  ConfigData->InsertProp("flatamount", MTConfigLib::PROP_TYPE_DOUBLE, mFlatAmount);

  _bstr_t RelativePath;
  VARIANT_BOOL bSecure = VARIANT_FALSE;

  RelativePath = mPath;
  char * c1 = mHostName;
  char * c2 = RelativePath;

  if (mHostName != (_bstr_t)"")
    PropSet->WriteToHost(mHostName, RelativePath, L"", L"",
									       bSecure, VARIANT_TRUE);
  else
    PropSet->Write(RelativePath);
			
  return S_OK;
}

STDMETHODIMP CMTQuote::get_MinAmount(double *pVal)
{
	*pVal = mMinAmount;
	return S_OK;
}

STDMETHODIMP CMTQuote::put_MinAmount(double newVal)
{
	mMinAmount = newVal;
	return S_OK;
}

STDMETHODIMP CMTQuote::get_FlatAmount(double *pVal)
{
	*pVal = mFlatAmount;
	return S_OK;
}

STDMETHODIMP CMTQuote::put_FlatAmount(double newVal)
{
	mFlatAmount = newVal;
	return S_OK;
}

STDMETHODIMP CMTQuote::get_PerMinuteAmount(double *pVal)
{
	*pVal = mPerMinuteAmount;
	return S_OK;
}

STDMETHODIMP CMTQuote::put_PerMinuteAmount(double newVal)
{
	mPerMinuteAmount = newVal;
	return S_OK;
}

STDMETHODIMP CMTQuote::get_ApplyMinimum(VARIANT_BOOL *pVal)
{
	*pVal = mApplyMinimum;
	return S_OK;
}

STDMETHODIMP CMTQuote::put_ApplyMinimum(VARIANT_BOOL newVal)
{
	mApplyMinimum = newVal;
	return S_OK;
}

STDMETHODIMP CMTQuote::get_ChargeType(BSTR *pVal)
{
	*pVal = mChargeType.copy();
	return S_OK;
}

STDMETHODIMP CMTQuote::put_ChargeType(BSTR newVal)
{
	mChargeType = newVal;
	return S_OK;
}
