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
 * Created by: Boris Partensky
 *
 * $Header: 
 * $Date: 
 * $Author: 
 * $Revision: 
 ***************************************************************************/

#include <metra.h>
#include <comdef.h>

#include <HookSkeleton.h>
#include <mtprogids.h>
#include <SetIterate.h>
#include <ConfigChange.h>

#include <stdutils.h>
#include <ConfigDir.h>
#include <vector>
#include <GenericCollection.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTObjectCollection.h>

using namespace std;

#import <MTConfigLib.tlb>
#import <RCD.tlb>
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
//#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTServerAccess.tlb>


#include <RcdHelper.h>

using namespace MTConfigLib;

class MTPropAndFile 
{

public:
	MTPropAndFile(MTConfigLib::IMTConfigPropSetPtr& aSet,_bstr_t& aFile) : mSet(aSet), mFile(aFile) {}

	MTConfigLib::IMTConfigPropSetPtr mSet;
	_bstr_t mFile;

};




CLSID CLSID_MTCapabilityHook = /*b21740c1-ce03-4dfa-9c39-480dcf7b5db3*/
{ 0xb21740c1, 
	0xce03, 
	0x4dfa, 
	{ 0x9c, 0x39, 0x48, 0x0d, 0xcf, 0x7b, 0x5d, 0xb3 } 
};


class ATL_NO_VTABLE MTCapabilityHook :
  public MTHookSkeleton<MTCapabilityHook,&CLSID_MTCapabilityHook>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var,long* pVal);
 HRESULT FinalConstruct();
private:
	HRESULT GetList(vector<MTPropAndFile>& aList);
	RCDLib::IMTRcdPtr mRCD;
	MTConfigLib::IMTConfigPtr mConfig;
	NTLogger	mLogger;
	

};

HOOK_INFO(CLSID_MTCapabilityHook, MTCapabilityHook,
						"MetraHook.MTCapabilityHook.1", "MetraHook.MTCapabilityHook", "both")



HRESULT MTCapabilityHook::FinalConstruct()
{
	HRESULT hr(S_OK);
	LoggerConfigReader cfgRdr;
  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Security"), "[MTCapabilityHook]");
	
	hr = mRCD.CreateInstance(MTPROGID_RCD);
	if(FAILED(hr)) 
		return hr;
	return hr = mConfig.CreateInstance(MTPROGID_CONFIG);
}

/////////////////////////////////////////////////////////////////////////////
//MTCapabilityHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

HRESULT MTCapabilityHook::ExecuteHook(VARIANT var,long* pVal)
{
  HRESULT hr(S_OK);
  MTConfigLib::IMTConfigPropSetPtr cctSet,actsSet, enumSet, decSet, pathSet, ConfigSet;
  MTConfigLib::IMTConfigPropPtr prop;
  vector<MTPropAndFile> fileList;
  vector<MTPropAndFile>::iterator it;
  try
  {
    MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
    
    hr = GetList(fileList);
    
    for (it = fileList.begin(); it != fileList.end(); ++it)
    {
      ConfigSet = (*it).mSet;
      /*
      <compositetype>
      <name>Issue Credits</name>
      <description>Guards actions around Issuing Credits with or without a max amount</description>
      <editor>DEFAULT_CAPABILITY_EDITOR_DIALOG</editor>
      <progid>Metratech.MTIssueCreditCapability</progid>
      <CSRAssignable ptype="BOOLEAN">T</CSRAssignable>
      <SubscriberAssignable ptype="BOOLEAN">T</SubscriberAssignable>
      <AllowMultipleInstances ptype="BOOLEAN">T</AllowMultipleInstances>
      <UmbrellaSensitive ptype="BOOLEAN">T</UmbrellaSensitive>
      <atomictypes>
      <mtenumtypecapability>
      <Description>Specify Currency</Description>
      <TypeName>Global/SystemCurrencies/SystemCurrencies</TypeName>
      </mtenumtypecapability>
      <mtdecimalcapability>
      <Description>Specify Credit Limit</Description>
      </mtdecimalcapability>
      </atomiccapabilities>
      </atomictypes>
      </compositetype>
      
        
      */
      
      
      while((cctSet = ConfigSet->NextSetWithName("compositetype")) != NULL)
      {
        MTAUTHLib::IMTCompositeCapabilityTypePtr ctPtr(MTPROGID_COMPOSITE_CAPABILITY_TYPE);
        _bstr_t bstrName = cctSet->NextStringWithName("name");
        _bstr_t bstrDesc = cctSet->NextStringWithName("description");
        _bstr_t bstrEditor = cctSet->NextStringWithName("editor");
        _bstr_t bstrProgid = cctSet->NextStringWithName("progid");
        VARIANT_BOOL bCSRAssignable = cctSet->NextBoolWithName("csrassignable");
        VARIANT_BOOL bSubscriberAssignable = cctSet->NextBoolWithName("subscriberassignable");
        VARIANT_BOOL bAllowMultipleInstances = cctSet->NextBoolWithName("allowmultipleinstances");
        VARIANT_BOOL bUmbrellaSensitive = cctSet->NextBoolWithName("umbrellasensitive");
        
        ctPtr->Name = bstrName;
        ctPtr->Description = bstrDesc;
        ctPtr->Editor = bstrEditor;
        ctPtr->ProgID = bstrProgid;
        ctPtr->CSRAssignable = bCSRAssignable;
        ctPtr->SubscriberAssignable = bSubscriberAssignable;
        ctPtr->AllowMultipleInstances = bAllowMultipleInstances;
        ctPtr->UmbrellaSensitive = bUmbrellaSensitive;
        
        actsSet = cctSet->NextSetWithName("atomictypes");
        
        if(actsSet != NULL)
        {
          while((prop = actsSet->Next()) != NULL)
          {
            if (prop->GetPropType() ==  MTConfigLib::PROP_TYPE_SET)
            {
              MTAUTHLib::IMTAtomicCapabilityTypePtr atomicTypePtr;
              atomicTypePtr = security->GetAtomicCapabilityTypeByName(prop->GetName());
              MTConfigLib::IMTConfigPropSetPtr atomicTypeSet = prop->PropValue;
              atomicTypePtr->CompositionDescription = atomicTypeSet->NextStringWithName("description");
              if(stricmp((char*)atomicTypePtr->Name, "MTEnumTypeCapability") == 0)
                atomicTypePtr->ParameterName = atomicTypeSet->NextStringWithName("typename");
              ctPtr->AddAtomicCapabilityType(atomicTypePtr);
            }
          }
        }

        ctPtr->Save();
        
      }
    }
    ConfigChangeEvent event;
		event.Init();
		event.Signal();
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }
  return hr;
}


// ----------------------------------------------------------------
// Name:     			GetList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

HRESULT MTCapabilityHook::GetList(vector<MTPropAndFile>& aList)
{
	HRESULT hr = S_OK;
	
	try
	{
		VARIANT_BOOL bChecksum;
		RCDLib::IMTRcdFileListPtr aFileList;
		const _bstr_t aQuery("config\\Security\\CapabilityTypes.xml");
		
		aFileList = mRCD->RunQuery(aQuery,VARIANT_TRUE);
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

		if(aFileList->GetCount() == 0) 
		{
			const char* szLogMsg = "no CapabilityTypes.xml found in any of the extensions";
			mLogger.LogThis(LOG_ERROR,szLogMsg);
			hr = Error (szLogMsg);
		}
		else 
		{
	
			hr = it.Init(aFileList);
			if(FAILED(hr)) 
				return hr;
			
			while (TRUE)
			{
				_variant_t aVariant= it.GetNext();
				_bstr_t afile = aVariant;
				if(afile.length() == 0) break;
				MTConfigLib::IMTConfigPropSetPtr confSet = mConfig->ReadConfiguration(afile,&bChecksum);
				MTPropAndFile aPair(confSet,afile);
				aList.push_back(aPair);
			}
		}

	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return hr;
}

