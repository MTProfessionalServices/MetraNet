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
#include <SecuredHookSkeleton.h>
#include <mtprogids.h>
#include <SetIterate.h>

#include <stdutils.h>
#include <ConfigDir.h>
#include <vector>
//#include <GenericCollection.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTObjectCollection.h>


using namespace std;

#import <MTConfigLib.tlb>
#import <RCD.tlb>
#import <MTAuth.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTServerAccess.tlb>
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <COMKiosk.tlb> rename ("EOF", "RowsetEOF")
#import <GenericCollection.tlb>

#include <RcdHelper.h>
#include <RowsetDefs.h>

#define CONFIG_DIR "Queries\\Auth"

using namespace MTConfigLib;

class MTPropAndFile 
{

public:
	MTPropAndFile(MTConfigLib::IMTConfigPropSetPtr& aSet,_bstr_t& aFile) : mSet(aSet), mFile(aFile) {}

	MTConfigLib::IMTConfigPropSetPtr mSet;
	_bstr_t mFile;

};

class MTYYACAndPropSet
{

public:
  MTYYACAndPropSet(MTConfigLib::IMTConfigPropSetPtr& aSet,MTYAACLib::IMTYAACPtr& aYaac) : mSet(aSet), mYaac(aYaac) {}

	MTConfigLib::IMTConfigPropSetPtr mSet;
  MTYAACLib::IMTYAACPtr mYaac;

};


CLSID CLSID_MTSecurityPolicyHook = /*f49622e6-539b-4ad3-ad04-a3cd67b6b674*/
{ 0xf49622e6, 
	0x539b, 
	0x4ad3, 
	{ 0xad, 0x04, 0xa3, 0xcd, 0x67, 0xb6, 0xb6, 0x74 } 
};


class ATL_NO_VTABLE MTSecurityPolicyHook :
  public MTSecuredHookSkeleton<MTSecurityPolicyHook,&CLSID_MTSecurityPolicyHook>
{
public:
 virtual HRESULT ExecuteHook(MTAuthInterfacesLib::IMTSessionContextPtr context, VARIANT var,long* pVal);
 HRESULT FinalConstruct();
private:
	HRESULT GetList(vector<MTPropAndFile>& aList);
	RCDLib::IMTRcdPtr mRCD;
	MTConfigLib::IMTConfigPtr mConfig;
	NTLogger	mLogger;
	

};

HOOK_INFO(CLSID_MTSecurityPolicyHook, MTSecurityPolicyHook,
						"MetraHook.MTSecurityPolicyHook.1", "MetraHook.MTSecurityPolicyHook", "both")



HRESULT MTSecurityPolicyHook::FinalConstruct()
{
	HRESULT hr(S_OK);
	LoggerConfigReader cfgRdr;
  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Security"), "[MTSecurityPolicyHook]");
	
	hr = mRCD.CreateInstance(MTPROGID_RCD);
	if(FAILED(hr)) 
		return hr;
	return hr = mConfig.CreateInstance(MTPROGID_CONFIG);
}

/////////////////////////////////////////////////////////////////////////////
//MTSecurityPolicyHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

HRESULT MTSecurityPolicyHook::ExecuteHook(MTAuthInterfacesLib::IMTSessionContextPtr context,
																					VARIANT var,long* pVal)
{
  HRESULT hr(S_OK);
  try
  {

		MTConfigLib::IMTConfigPropSetPtr prSet, ConfigSet;
		MTConfigLib::IMTConfigAttribSetPtr attribSet;
		vector<MTPropAndFile> fileList;
		vector<MTPropAndFile>::iterator it;
		vector<MTYYACAndPropSet> accList;
		COMKIOSKLib::ICOMAccountPtr account(__uuidof(COMKIOSKLib::COMAccount));
  
    //session context is passed in
    MTAUTHLib::IMTSecurityPtr security(MTPROGID_MTSECURITY);
    MTAUTHLib::IMTSessionContextPtr ctx = context.GetInterfacePtr();

    hr = GetList(fileList);
    
    for (it = fileList.begin(); it != fileList.end(); ++it)
    {
      ConfigSet = (*it).mSet;
      
      while((prSet = ConfigSet->NextSetWithName("principal")) != NULL)
      {
        attribSet = prSet->GetAttribSet();
        
        if (attribSet == NULL)
        {
          mLogger.LogThis (LOG_ERROR,
            "UNable to get attributes of 'principal' set");
          MT_THROW_COM_ERROR(MTAUTH_SECURITY_PRINCIPAL_DESERIALIZATION_FAILED);
        }
        
        _bstr_t bstrPrType = attribSet->GetAttrValue("type");
        
        //make sure to process roles first
        if(stricmp((char*)bstrPrType, "role") == 0)
        {
          MTAUTHLib::IMTRolePtr role = security->CreateRole(ctx);
          role->FromXML(ctx, prSet->WriteToBuffer());
          role->Save();
        }
        else if(stricmp((char*)bstrPrType, "account") == 0)
        {
          //store account sets aside for now, they have to be
          //processed after roles
          MTYAACLib::IMTYAACPtr acc(MTPROGID_MTYAAC);
          MTYYACAndPropSet accPair(prSet, acc);
          accList.push_back(accPair);
          continue;
        }
        
      }
      
      //deserialize account principals
      vector<MTYYACAndPropSet>::const_iterator accIt;
      for(accIt = accList.begin(); accIt != accList.end(); accIt++)
      {
        accIt->mYaac->FromXML((MTYAACLib::IMTSessionContextPtr)ctx, accIt->mSet->WriteToBuffer());
        accIt->mYaac->Save();
	
		MTYAACLib::IMTSessionContextPtr yaacCtx = reinterpret_cast<MTYAACLib::IMTSessionContext *>(ctx.GetInterfacePtr());

		MTYAACLib::IMTYAACPtr newYaac(MTPROGID_MTYAAC);
		newYaac->InitAsSecuredResource(accIt->mYaac->AccountID, yaacCtx);

		MTAUTHLib::IMTPrincipalPolicyPtr policy = newYaac->GetActivePolicy(yaacCtx);
		GENERICCOLLECTIONLib::IMTCollectionPtr capColl = policy->Capabilities;
		
		_bstr_t accPathStr = newYaac->HierarchyPath;

		bool bFound = false;
		for(int i=1;i<=capColl->GetCount();i++) {
          MTAUTHLib::IMTCompositeCapabilityPtr capPtr = capColl->GetItem(i);

		  if(_wcsicmp((wchar_t*)capPtr->CapabilityType->Name, L"Manage Account Hierarchies") == 0)
		  {
          _bstr_t pathstr = (const wchar_t*)capPtr->GetAtomicPathCapability()->GetParameter()->GetPath();
		  _bstr_t enumVal = (_bstr_t)capPtr->GetAtomicEnumCapability()->GetParameter()->Value;

		  if( _wcsicmp((wchar_t*)pathstr, (wchar_t*)(accPathStr + L"/")) == 0 &&
            _wcsicmp((wchar_t*)enumVal, L"WRITE") == 0 )
          {
            bFound = true;

			break;
          }
		  }
		}

		if(!bFound)
		{
			MTAUTHLib::IMTCompositeCapabilityPtr mahPtr = security->GetCapabilityTypeByName("Manage Account Hierarchies")->CreateInstance();
			MTAUTHLib::IMTPathCapabilityPtr pathPtr = mahPtr->GetAtomicPathCapability();
			MTAUTHLib::IMTEnumTypeCapabilityPtr enumPtr = mahPtr->GetAtomicEnumCapability();

			pathPtr->SetParameter(accPathStr + "/", MTAUTHLib::SINGLE);
			enumPtr->SetParameter("WRITE");

			policy->AddCapability(mahPtr);

			newYaac->Save();
		}

      }                  
    }
    
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

HRESULT MTSecurityPolicyHook::GetList(vector<MTPropAndFile>& aList)
{
	HRESULT hr = S_OK;
	
	try
	{
		VARIANT_BOOL bChecksum;
		RCDLib::IMTRcdFileListPtr aFileList;
		const _bstr_t aQuery("config\\Security\\Policies.xml");
		
		aFileList = mRCD->RunQuery(aQuery,VARIANT_TRUE);
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

		if(aFileList->GetCount() == 0) 
		{
			const char* szLogMsg = "no Policies.xml found in any of the extensions";
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
