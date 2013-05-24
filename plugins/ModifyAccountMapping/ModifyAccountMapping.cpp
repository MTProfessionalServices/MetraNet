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
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY -- PATENTS,
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
 ***************************************************************************/
#include <StdAfx.h>
#include <PlugInSkeleton.h>
#include <TransactionPlugInSkeleton.h>
#include <stdio.h>
#include <AccountMapping.h>

// import Rowset tlb file
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
using namespace ROWSETLib;

// import COMKiosk tlb file
#import <COMKiosk.tlb> 
using namespace COMKIOSKLib;

#import <MTEnumConfigLib.tlb> 

CLSID CLSID_ModifyAccountMapping = {  
	  0x89732740,
		0xEC74,
		0x11d3,
		{ 0x95, 0x97, 0x00, 0xb0, 0xd0, 0x25, 0xb1, 0x21 }
};
//
class ATL_NO_VTABLE ModifyAccountMapping : 
	public MTTransactionPlugIn<ModifyAccountMapping, &CLSID_ModifyAccountMapping >
{
protected:
   // Initialize the processor, looking up any necessary property IDs.
   // The processor can also use this time to do any other necessary initialization.
   virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
									MTPipelineLib::IMTConfigPropSetPtr aPropSet,
									MTPipelineLib::IMTNameIDPtr aNameID,
									MTPipelineLib::IMTSystemContextPtr aSysContext);

   // Shutdown the processor.  The processor can release any resources
   // it no longer needs.
   virtual HRESULT PlugInShutdown();


   // process the session
   virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);

private: // data
  MTPipelineLib::IMTLogPtr mLogger;
  COMKIOSKLib::ICOMAccountMapperPtr mpAccountMapper;
  long mOperation; 
  long mLoginName;  
  long mNameSpace; 
  long mNewLoginName; 
  long mNewNameSpace;

  MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};

// this macro provides information to the plug-in skeleton on how the COM
// object should be registered, its CLSID, and its threading model.  If you are
// familiar with ATL COM objects, this macro basically provides all of the information
// to ATL so this class can act as a COM object
PLUGIN_INFO(CLSID_ModifyAccountMapping, ModifyAccountMapping,
			"MetraPipeline.ModifyAccountMapping.1",
			"MetraPipeline.ModifyAccountMapping", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////
HRESULT ModifyAccountMapping::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                              MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                              MTPipelineLib::IMTNameIDPtr aNameID,
                                              MTPipelineLib::IMTSystemContextPtr aSysContext)
{
  HRESULT hr(S_OK);
  _bstr_t buffer;
  
  // grab an instance of the logger so we can use it in process sessions if
  // we need to 
  mLogger = aLogger;
  
  // Declare the list of properties we will read from the XML configuration
  // When ProcessProperties is called, it loads the property Ids into the
  // variable that was passed 
  DECLARE_PROPNAME_MAP(inputs)
    DECLARE_PROPNAME("Operation",&mOperation)
    DECLARE_PROPNAME("LoginName",&mLoginName)
    DECLARE_PROPNAME("NameSpace",&mNameSpace)
    DECLARE_PROPNAME("NewLoginName",&mNewLoginName)
    DECLARE_PROPNAME("NewNameSpace",&mNewNameSpace)
    END_PROPNAME_MAP
    
  mQueryInitPath = "\\Queries\\PresServer";  
  
  hr = mpAccountMapper.CreateInstance("COMAccountMapper.COMAccountMapper.1");
  if (!SUCCEEDED(hr))
  {
    buffer = "Unable to create instance of COMAccountMapper object";
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    return Error((char*)buffer);
  }
  
  // initialize the account mapper object ...
  hr = mpAccountMapper->Initialize ();
  if (!SUCCEEDED(hr))
  {
    buffer = "Unable to initialize COMAccountMapper object";
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buffer);
    return Error((char*)buffer);
  } 
  
  hr = ProcessProperties(inputs, aPropSet, aNameID, mLogger,/*PROCEDURE*/NULL);
  if (!SUCCEEDED(hr))
    return hr;
  
 	try
  {
    //get enum config pointer from system context
    mEnumConfig = aSysContext->GetEnumConfig();
    _ASSERTE(mEnumConfig != NULL);
  }
  catch(_com_error& e)
  {
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Failed to get EnumConfig Interface pointer from SysContext");
    return ReturnComError(e);
  }
  
  return hr;
}
/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////
HRESULT ModifyAccountMapping::PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession, MTPipelineLib::IMTSQLRowsetPtr aTransactionRS)
{

    //TODO: Add logging/error checking
	HRESULT hr(S_OK);

    _bstr_t sOperation;
	_bstr_t bstrOperationString;
	int iOperation;
	char buf[512];

	try
	{
		sOperation = mEnumConfig->GetEnumeratorByID(aSession->GetEnumProperty(mOperation));
		
		if (sOperation.length() == 0)  // blank, return error
	  		return Error("Blank Operation");

		if (0 == _wcsicmp((wchar_t*)sOperation, L"Add"))
		{
			iOperation = 0;
			bstrOperationString = "Adding";
		}
		else if (0 == _wcsicmp((wchar_t*)sOperation, L"Update"))
		{
			iOperation = 1;
			bstrOperationString = "Updating";
		}
		else if (0 == _wcsicmp((wchar_t*)sOperation, L"Delete") ||
				(0 == _wcsicmp((wchar_t*)sOperation, L"NO-OP")))
		{
			iOperation = 2;
			bstrOperationString = "Deleting";
		}
		else
		{
			sprintf(buf, 
					"Unsupported Account Operation <%s> passed in", (const char*)sOperation);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
		  	return Error (buf);
		}

    	sprintf(buf, "%s account mapper information", (const
													   char*)bstrOperationString);
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);

		_bstr_t bstrLoginName = aSession->GetStringProperty(mLoginName);
		_bstr_t bstrNameSpace = aSession->GetStringProperty(mNameSpace);
		_bstr_t bstrNewLoginName = aSession->GetStringProperty(mNewLoginName);
		_bstr_t bstrNewNameSpace = aSession->GetStringProperty(mNewNameSpace);

		hr = mpAccountMapper->Modify (iOperation, 
                                  bstrLoginName, 
                                  bstrNameSpace, 
                                  bstrNewLoginName, 
                                  bstrNewNameSpace,
                                  aTransactionRS);
		if (!SUCCEEDED(hr))
		{
		    sprintf(buf, "Unable to modify account mapper info. Error = %X\n", hr);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);
			return Error(buf);
		}
	}
	catch (_com_error& e)
	{
	    return ReturnComError(e);
	}


	return hr;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////
HRESULT 
ModifyAccountMapping::PlugInShutdown()
{
	return S_OK;
}
