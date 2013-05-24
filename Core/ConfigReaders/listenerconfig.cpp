/**************************************************************************
 * @doc LISTENERCONFIG
 *
 * Copyright 1998 by MetraTech Corporation
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

#include <metralite.h>

#include <mtcom.h>

#import "MTConfigLib.tlb"
using namespace MTConfigLib;

#include <listenerconfig.h>

#include <mtglobal_msg.h>

#include <mtcomerr.h>
#import <RCD.tlb>
#include <mtprogids.h>
#include <SetIterate.h>
#include <RcdHelper.h>


/**************************************** ListenerInfoReader ***/

// ----------------------------------------------------------------
// Name:     	ReadConfiguration
// Arguments:     <arReader> - propset
//                <apConfigDir> - dir to use
//								<arInfo>	The listenerInfo object to populate
// Return Value:  Boolean
// Description:   Reads the XML configuration
// ----------------------------------------------------------------

BOOL ListenerInfoReader::ReadConfiguration(IMTConfigPtr & arReader,
																					 const char * apConfigDir,
																					 ListenerInfo & arInfo)
{
	try
	{
		string fullName;
		if (!GetFileName(apConfigDir, fullName))
			return FALSE;								// error already set

		VARIANT_BOOL flag;

		IMTConfigPropSetPtr propset =
			arReader->ReadConfiguration(fullName.c_str(), &flag);

		return ReadConfiguration(propset, arInfo);
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}


// ----------------------------------------------------------------
// Name:     	GetFileName
// Arguments:     <apConfigDir> -config dir
//                <arListenerConfig> - buffer to populate
// Description:   returns the fullpath to the XML 
// ----------------------------------------------------------------

BOOL ListenerInfoReader::GetFileName(const char * apConfigDir,
									 std::string & arListenerConfig)
{
	if (!apConfigDir || !*apConfigDir)
	{
		SetError(CORE_ERR_BAD_CONFIG_DIRECTORY, ERROR_MODULE, ERROR_LINE,
						 "ListenerInfoReader::GetFileName");
		return FALSE;
	}

	arListenerConfig = apConfigDir;

	if (arListenerConfig[arListenerConfig.length() - 1] != '\\')
		arListenerConfig += '\\';

	arListenerConfig += "pipeline\\listener.xml";
	return TRUE;
}

// ----------------------------------------------------------------
// Name:     	ReadConfiguration
// Arguments:     <arTop> - propset
//                <arInfo> - listener info to populate
// Description:   Reads the top of the listener.xml
// ----------------------------------------------------------------

BOOL ListenerInfoReader::ReadConfiguration(IMTConfigPropSetPtr & arTop,
																					 ListenerInfo & arInfo)
{
	const char * functionName = "ListenerInfoReader::ReadConfiguration";

	try
	{
		arInfo.mVersion = arTop->NextLongWithName(LISTENERCONFIG_VERSION_TAG);

		//
		// name of this meter/listener
		//
		arInfo.mMeterName = arTop->NextStringWithName(L"metername");

		// feedback_timeout (optional)
		if (arTop->NextMatches(L"feedback_timeout", PROP_TYPE_INTEGER) == VARIANT_TRUE)
			arInfo.mDefaultFeedbackTimeout = arTop->NextLongWithName(L"feedback_timeout");
		else
			arInfo.mDefaultFeedbackTimeout = -1;

		//
		// store routing information
		//

		IMTConfigPropSetPtr routeto = arTop->NextSetWithName(L"routeto");

		// machine name (optional)
		if (routeto->NextMatches(L"machine", PROP_TYPE_STRING) == VARIANT_TRUE)
			arInfo.mRouteToMachine = routeto->NextStringWithName(L"machine");
		else
			arInfo.mRouteToMachine = "";

		// queue name (required)
		arInfo.mRouteToQueue = routeto->NextStringWithName("queue");

		//
		// service routing information
		//

		return ReadServiceToStageMap(arInfo);
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}

// ----------------------------------------------------------------
// Name:     	ReadServiceToStageMap
// Arguments:     <arInfo> - all of the listener properties
// Return Value:  TRUE on success
// Description:   Reads the service to stage map.  This file is distributed 
// across multiple extensions
// ----------------------------------------------------------------

BOOL ListenerInfoReader::ReadServiceToStageMap(ListenerInfo & arInfo)
{
	BOOL bRetVal = TRUE;
	const char* pFunctionName = " ListenerInfoReader::ReadServiceToStageMap";

	// step 1: create an instance of the RCD
	RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
	IMTConfigPtr aConfig(MTPROGID_CONFIG);
	aRCD->Init();
	// step 2: query for the ServiceToStageMap.xml file
	RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\pipeline\\ServiceToStageMap.xml",VARIANT_TRUE);
	// step 3: iterate through each XML file
	SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

	if(FAILED(it.Init(aFileList))) return FALSE;
	while (TRUE)
	{
		_variant_t aVariant= it.GetNext();
		_bstr_t afile = aVariant;
		if(afile.length() == 0) break;
	
		VARIANT_BOOL bUnused;
		IMTConfigPropSetPtr aXmlFile = aConfig->ReadConfiguration(afile,&bUnused);

		// step 4: pull out the directions and populate arInfo
		IMTConfigPropSetPtr direction = aXmlFile->NextSetWithName("direction");
		while ((bool) direction)
		{
			// get attributes of the direction tag
			IMTConfigAttribSetPtr attrSet = direction->GetAttribSet();
			int timeout = -1;
			try
			{
				_bstr_t timeoutStr = attrSet->GetAttrValue("timeout");
				wchar_t * end;
				timeout = wcstol(timeoutStr, &end, 10);
				if ((const wchar_t *) timeoutStr + timeoutStr.length() != end)
				{
					// timeout value is not an integer
					SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
									 pFunctionName,
									 "value of timeout attribute of direction tag is not an integer");
					return FALSE;
				}
			}
			catch (_com_error &)
			{ /* no timeout specified - leave at -1 */ }

			long id = direction->NextLongWithName("ServiceID");
			_bstr_t name = direction->NextStringWithName("stage");

			// have to allocate the key and value on the heap
			if (arInfo.mStages.find(id) != arInfo.mStages.end())
			{
				StageMapInfo & oldMapping = arInfo.mStages[id];

				char buffer[512];
				sprintf(buffer, "Mapping from service ID %d listed more than once, "
								"second time to stage %s", id, oldMapping.GetName());
				SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
								 pFunctionName,
								 buffer);
				return FALSE;
			}

			StageMapInfo & mapInfo = arInfo.mStages[id];
			mapInfo.SetName(name);

			if (timeout == -1)
				mapInfo.SetUnspecifiedTimeout();
			else
				mapInfo.SetTimeout(timeout);

			direction = aXmlFile->NextSetWithName("direction");
		}
	}

	// check that it found mapping configuration
	if(arInfo.mStages.size() == 0) {
		SetError(CORE_ERR_NOSERVICETOSTAGEMAPPINGS_FOUND, ERROR_MODULE, ERROR_LINE,
						 pFunctionName);
		return FALSE;
	}

	return TRUE;
}

