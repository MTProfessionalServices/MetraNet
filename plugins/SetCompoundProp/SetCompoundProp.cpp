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
 * Author: Anagha Rangarajan
 * This plugin sets the value of the destination property, for the entire compound
 * based on the operation to be performed on the source property.
 * For example, setting the _timestamp property for the audioconfcall parent session,
 * all audioconfconnection sessions
 ***************************************************************************/


#include "SetCompoundProp.h"



HRESULT MTSetCompoundProp::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
					MTPipelineLib::IMTConfigPropSetPtr aPropSet,
					MTPipelineLib::IMTNameIDPtr aNameID,
                    MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;
	mIsOkayToLogDebug = mLogger->OKToLog(MTPipelineLib::PLUGIN_LOG_DEBUG);

	HRESULT hr;
    try 
    {
		
		if (aPropSet->NextMatches(L"TargetPropertyName", MTPipelineLib::PROP_TYPE_STRING))
		{
			mTargetPropertyID = aNameID->GetNameID(aPropSet->NextStringWithName(L"TargetPropertyName"));
		}
		else 
			return Error("No TargetPropertyName specified!");

		if (aPropSet->NextMatches(L"Type",  MTPipelineLib::PROP_TYPE_STRING))
		{
			std::string dataType = aPropSet->NextStringWithName(L"Type");
			if ( _stricmp(dataType.c_str(), "DateTime") != 0)
				return Error("Only properties of type DateTime are currently supported!");
		}
		else
			return Error("No Type specified!");
	
		if (aPropSet->NextMatches(L"Operation",  MTPipelineLib::PROP_TYPE_STRING))
		{
			std::string operation = aPropSet->NextStringWithName(L"Operation");

			if (_stricmp(operation.c_str(), "Min") == 0)
				mOp = OPERATION_MIN;
			else if (_stricmp(operation.c_str(), "Max") == 0)
				mOp = OPERATION_MAX;
			else
				return Error("Only Min and Max are the two operations currently supported!");
		}
		else
			return Error("No operation specified");

		// the mutex is no longer used since starting in v4.0 the
    // pipeline guarantees there is no parallelism under an object owner.
		// for backward compatibility it is tolerated in the config file
		if (aPropSet->NextMatches(L"MutexName",  MTPipelineLib::PROP_TYPE_STRING))
			aPropSet->NextStringWithName(L"MutexName");

		MTPipelineLib::IMTConfigPropSetPtr sourcesSet = aPropSet->NextSetWithName(L"Sources");
		if (sourcesSet != NULL)
		{
			MTPipelineLib::IMTConfigPropSetPtr sourceSet;
			SourceItem *pSourceItem;
			sourceSet = sourcesSet->NextSetWithName(L"Source");
			while(sourceSet != NULL)
			{
				pSourceItem = new SourceItem;
				pSourceItem->ServiceDefName = sourceSet->NextStringWithName(L"ServiceDefName");
				pSourceItem->SourcePropertyName = sourceSet->NextStringWithName(L"SourcePropertyName");
				pSourceItem->SourcePropertyID = aNameID->GetNameID(pSourceItem->SourcePropertyName);
				pSourceItem->ServiceID = aNameID->GetNameID(pSourceItem->ServiceDefName);
				mSourceProperties.push_back(pSourceItem);
				sourceSet = sourcesSet->NextSetWithName(L"Source");
			}

		}
		//make sure that there is at least one source block
		if (mSourceProperties.size() == 0)
			return Error("No source properties found!");

		const char* FirstPassCompleted = "FirstPassCompleted";
		mFirstPassCompleted = aNameID->GetNameID(FirstPassCompleted);

		//cache the session server
		hr = mSessionServer.CreateInstance("MetraPipeline.MTSessionServer.1");
		if (FAILED(hr))
		{
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, "Unable to create session server object");
			return Error("Could not create session server object");
		}

	}
	catch(_com_error& err) 
	{
		return ReturnComError(err);
	}
	return S_OK;
}

HRESULT MTSetCompoundProp::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
  HRESULT hr;

	try
	{
		// only performs calculation if the sentinel property doesn't exist
		// if it exists, all work for the compound has already been done
		if (aSession->PropertyExists(mFirstPassCompleted, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_FALSE)
		{
			MTPipelineLib::IMTSessionPtr pSession, parentSession;
			pSession = aSession;
			if (pSession->GetIsParent() == VARIANT_FALSE)
			{
				while (pSession->GetParentID() != -1)
					pSession = mSessionServer->GetSession(pSession->GetParentID());
			}
			//at this point pSession should point to the parent session
			parentSession = pSession;
			
			//initialize the finalValue
			
			if (mOp == OPERATION_MIN)
			{
				finalValue = GetMaxMTOLETime(); //this is only upto 2038:-(
			}
			else if (mOp == OPERATION_MAX)
			{
				finalValue = 0; //this represents 30 December 1899, midnight 
			}
				
			GetSourceValues(pSession);
			// get all children and examine their properties. Support n-deep compounds and set the max or min
			hr = Recurse(pSession, true);
			
			if (mIsOkayToLogDebug)
			{
				char buf[512];
				sprintf(buf, "The final value for the target property is: %f\n", finalValue);
				mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
			}
			
			//now set the target property in the entire compound to this value.
			parentSession->SetOLEDateProperty(mTargetPropertyID, finalValue);
			parentSession->SetBoolProperty(mFirstPassCompleted, VARIANT_TRUE);
			hr = RecursiveSetProp(parentSession, finalValue);
		}
	
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}


HRESULT MTSetCompoundProp::Recurse(MTPipelineLib::IMTSessionPtr aSession, bool bIsRoot)
{
  if (!bIsRoot)
	{
     GetSourceValues(aSession);
     // base case: session is not a parent
	 if (aSession->GetIsParent() == VARIANT_FALSE)
		return S_OK;
	}

	SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
	HRESULT hr = it.Init(aSession->SessionChildren());
	if (FAILED(hr))
		return hr;

	while (TRUE)
	{
		MTPipelineLib::IMTSessionPtr session = it.GetNext();
		if (session == NULL)
			break;

		hr = Recurse(session, false);
		if (FAILED(hr))
			return hr;
	}

  return S_OK;
}

void MTSetCompoundProp::GetSourceValues(MTPipelineLib::IMTSessionPtr aSession)
{
	SourceVector::iterator iSourceProp;
	SourceItem *pSourceItem;
	DATE tmpVal;

	for (iSourceProp = mSourceProperties.begin(); iSourceProp != mSourceProperties.end();
		iSourceProp++)
	{
		pSourceItem = *iSourceProp;
		long i = aSession->GetServiceID();
		if ((aSession->GetServiceID() == pSourceItem->ServiceID)&&
			(aSession->PropertyExists(pSourceItem->SourcePropertyID, MTPipelineLib::SESS_PROP_TYPE_DATE) 
			== VARIANT_TRUE))
		{
			
			tmpVal = aSession->GetOLEDateProperty(pSourceItem->SourcePropertyID); 
			//get the value and add it to the list
			//mListValues.push_back(aSession->GetOLEDateProperty(pSourceItem->SourcePropertyID));
			if (mOp == OPERATION_MAX)
			{	
				if (tmpVal > finalValue)
					finalValue = tmpVal;
			}
			else if (mOp == OPERATION_MIN)
			{
				if (tmpVal < finalValue)
					finalValue = tmpVal;
			}
		}
	}
}


HRESULT MTSetCompoundProp::RecursiveSetProp(MTPipelineLib::IMTSessionPtr aSession, DATE finalValue)
{
	if (aSession->GetIsParent() == VARIANT_TRUE)
	{
        SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(aSession->SessionChildren());
		if (FAILED(hr))
			return hr;

		while (TRUE)
		{
			MTPipelineLib::IMTSessionPtr session = it.GetNext();
			if (session == NULL)
				break;

			 hr = RecursiveSetProp(session, finalValue);
			 if (FAILED(hr))
				return hr;
		}
	}
	else
	{
	 aSession->SetOLEDateProperty(mTargetPropertyID, finalValue);
	 aSession->SetBoolProperty(mFirstPassCompleted, VARIANT_TRUE);
	}
	return S_OK;
}



HRESULT MTSetCompoundProp::PlugInShutdown()
{
  SourceItem *pSourceItem;
  std::vector <SourceItem *>::size_type i;

  for (i = 0; i < mSourceProperties.size(); i++)
	{
		pSourceItem = mSourceProperties.at(i);
		delete pSourceItem;
		pSourceItem = NULL;
	}
  return S_OK;
}
