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
#include <iostream>
#include <mtprogids.h>
#include <SetIterate.h>

#include <stdutils.h>
#include <ConfigDir.h>
#include <vector>
#include <GenericCollection.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <MTObjectCollection.h>
#include <Counter.h>

using namespace std;

#import <MTConfigLib.tlb>
#import <RCD.tlb>
#import "Counter.tlb" rename ("EOF", "RowsetEOF") 

#include <RcdHelper.h>

using namespace MTConfigLib;

class MTPropAndFile {

public:
	MTPropAndFile(MTConfigLib::IMTConfigPropSetPtr& aSet,_bstr_t& aFile) : mSet(aSet), mFile(aFile) {}

	MTConfigLib::IMTConfigPropSetPtr mSet;
	_bstr_t mFile;

};



CLSID CLSID_MTCounterTypeHook = /*0514559d-82b0-4d19-9f59-f7ad0be33c31*/
{ 0x514559d, 
	0x82b0, 
	0x4d19, 
	{ 0x9F, 0x59, 0xF7, 0xAD, 0x0B, 0xE3, 0x3C, 0x31 } 
};


class ATL_NO_VTABLE MTCounterTypeHook :
  public MTHookSkeleton<MTCounterTypeHook,&CLSID_MTCounterTypeHook>
{
public:
 virtual HRESULT ExecuteHook(VARIANT var,long* pVal);
 HRESULT FinalConstruct();
private:
	HRESULT GetCounterTypeList(vector<MTPropAndFile>& aList);
	RCDLib::IMTRcdPtr mRCD;
	MTConfigLib::IMTConfigPtr mConfig;
	NTLogger	mLogger;
	

};

HOOK_INFO(CLSID_MTCounterTypeHook, MTCounterTypeHook,
						"MetraHook.MTCounterTypeHook.1", "MetraHook.MTCounterTypeHook", "both")



HRESULT MTCounterTypeHook::FinalConstruct()
{
	HRESULT hr(S_OK);
	LoggerConfigReader cfgRdr;
  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("CounterType"), "[MTCounterTypeHook]");
	
	hr = mRCD.CreateInstance(MTPROGID_RCD);
	if(FAILED(hr)) 
		return hr;
	return hr = mConfig.CreateInstance(MTPROGID_CONFIG);
}

/////////////////////////////////////////////////////////////////////////////
//MTCounterTypeHook::ExecuteHook
/////////////////////////////////////////////////////////////////////////////

HRESULT MTCounterTypeHook::ExecuteHook(VARIANT var,long* pVal)
{
	HRESULT hr(S_OK);
	MTConfigLib::IMTConfigPropSetPtr ConfigSet, TypesSet, TypeSet, FormulaSet, ParamsSet, ParamSet;
	vector<MTPropAndFile> fileList;
	vector<MTPropAndFile>::iterator it;
	
	//1. Read all CounterType.xml files (only one file is shipped)
	
	hr = GetCounterTypeList(fileList);
	
	for (it = fileList.begin(); it != fileList.end(); ++it)
	{
		ConfigSet = (*it).mSet;
		
		//2. iterate through files, load MTCounterType object and save it
		try
		{
			TypesSet = ConfigSet->NextSetWithName("CounterTypes");
			
			while((TypeSet = TypesSet->NextSetWithName("CounterType")) != NULL)
			{
				MTCOUNTERLib::IMTCounterTypePtr CounterTypePtr(__uuidof(MTCOUNTERLib::MTCounterType));
				CounterTypePtr->Name = TypeSet->NextStringWithName("Name");
				CounterTypePtr->Description = TypeSet->NextStringWithName("Description");
        CounterTypePtr->ValidForDistribution = TypeSet->NextBoolWithName("ValidForDistribution");
				
				FormulaSet = TypeSet->NextSetWithName("FormulaDef");
				CounterTypePtr->FormulaTemplate = FormulaSet->NextStringWithName("Formula");
				
				try
				{
					ParamsSet = FormulaSet->NextSetWithName("Params");
				}
				catch(_com_error&)
				{
					//it's OK, no parameters for this CounterType
					ParamsSet = NULL;
				}
				
				if(ParamsSet)
				{
					MTObjectCollection<IMTCounterParameter> objColl;
					
					while((ParamSet = ParamsSet->NextSetWithName("Param")) != NULL)
					{
						MTCOUNTERLib::IMTCounterParameterPtr CounterParamPtr(__uuidof(MTCOUNTERLib::MTCounterParameter));
						CounterParamPtr->Name = ParamSet->NextStringWithName("Name");
						CounterParamPtr->PutKind(ParamSet->NextStringWithName("Kind"));
						CounterParamPtr->PutDBType(ParamSet->NextStringWithName("DBType"));
						
						objColl.Add( (IMTCounterParameter*) CounterParamPtr.Detach());
					}
					//set parameter collection on MTCounterType object
					objColl.CopyTo((IMTCollection**)&(CounterTypePtr->Parameters));
					CounterTypePtr->Parameters = reinterpret_cast<MTCOUNTERLib::IMTCollection*>(objColl.Detach());
				}
				
				//save counter type to database
				CounterTypePtr->Save();
			}
		}
		catch(_com_error& e)
		{
			return ReturnComError(e);
		}
	}
	return hr;
}


// ----------------------------------------------------------------
// Name:     			GetCounterTypeList
// Arguments:     EnumFileList (std::vector)	- list of files retrieved from master file list
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY 
// ----------------------------------------------------------------

HRESULT MTCounterTypeHook::GetCounterTypeList(vector<MTPropAndFile>& aList)
{
	HRESULT hr = S_OK;
	
	try
	{
		VARIANT_BOOL bChecksum;
		RCDLib::IMTRcdFileListPtr aFileList;
		const _bstr_t aQuery("config\\CounterType\\CounterType.xml");
		
		aFileList = mRCD->RunQuery(aQuery,VARIANT_TRUE);
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

		if(aFileList->GetCount() == 0) 
		{
			const char* szLogMsg = "no CounterType.xml found in anyof the extensions";
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
