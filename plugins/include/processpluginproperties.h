/**************************************************************************
 *
 * Copyright 2002 by MetraTech Corporation
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
 ***************************************************************************/

#ifndef __PROCESSPLUGINPROPERTIES_H__
#define __PROCESSPLUGINPROPERTIES_H__
#pragma once

struct MTPropMapItem{
  const char* aPropName;
  long* aPropId;
  bool  aOptional;
};

#define DECLARE_PROPNAME_MAP(a) MTPropMapItem a[] = { 
#define DECLARE_PROPNAME(a,b) {a,b,false}, 
#define DECLARE_PROPNAME_OPTIONAL(a,b) {a,b,true}, 
#define END_PROPNAME_MAP {NULL,NULL} }; 

HRESULT ProcessProperties(MTPropMapItem aPropMap[],
                                              MTPipelineLib::IMTConfigPropSetPtr& aPropSet,
                                              MTPipelineLib::IMTNameIDPtr& aNamePtr,
                                              MTPipelineLib::IMTLogPtr& aLogger,
                                              const char* aDebugHead)
{
  _bstr_t DebugStr = "";
  _bstr_t aTempStr;

  if(aDebugHead) {
    DebugStr = aDebugHead;
  }
  DebugStr += " Args: ";

  // get the properties
  for(unsigned int i=0;aPropMap[i].aPropName != NULL;i++) {
	try
	{
	aTempStr = aPropSet->NextStringWithName(aPropMap[i].aPropName);
	DebugStr += _bstr_t(aPropMap[i].aPropName) + " = " + aTempStr + "\n";
    (*aPropMap[i].aPropId) = aNamePtr->GetNameID(aTempStr);
    }
	catch (_com_error err)
	{
		if (aPropMap[i].aOptional)
		{
			aPropSet->Reset();
			(*aPropMap[i].aPropId) = -1;
			_bstr_t bstrTemp (L"Skipping optional property : ");
			bstrTemp += aPropMap[i].aPropName;
			if(aLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG)) 
				aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, bstrTemp);
  		}
		else
			throw err;
	}
	
  }

  // log the values
	if(aLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG)) {
    aLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, DebugStr);
  }
  return S_OK;
}

#endif //__PROCESSPLUGINPROPERTIES_H__