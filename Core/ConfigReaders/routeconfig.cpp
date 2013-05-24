/**************************************************************************
 * @doc ROUTECONFIG
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>

#import "MTConfigLib.tlb"
using namespace MTConfigLib;

#include <routeconfig.h>

#include <mtglobal_msg.h>

#include <mtcomerr.h>

/****************************************** MeterRouteReader ***/

MeterRoutes::MeterRoutes()
{ }

MeterRoutes::~MeterRoutes()
{ }



BOOL MeterRouteReader::ReadConfiguration(IMTConfigPtr & arReader,
																				 const char * apConfigDir,
																				 MeterRoutes & arInfo)
{
	try
	{
		std::string fullName;
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


BOOL MeterRouteReader::GetFileName(const char * apConfigDir,
								   std::string & arListenerConfig)
{
	if (!apConfigDir || !*apConfigDir)
	{
		SetError(CORE_ERR_BAD_CONFIG_DIRECTORY, ERROR_MODULE, ERROR_LINE,
						 "MeterRouteReader::GetFileName");
		return FALSE;
	}

	arListenerConfig = apConfigDir;

	if (arListenerConfig[arListenerConfig.length() - 1] != '\\')
		arListenerConfig += '\\';

	arListenerConfig += "meter\\route.xml";
	return TRUE;
}


BOOL MeterRouteReader::ReadConfiguration(IMTConfigPropSetPtr & arTop,
																				 MeterRoutes & arInfo)
{
	const char * functionName = "MeterRouteReader::ReadConfiguration";

	try
	{
		arInfo.mVersion = arTop->NextLongWithName("version");

		/*
			<responsesto>
			  <metername>meter1</metername>
			  <machine>dyoung</machine>
			  <queue>ListenerFeedback</queue>
			</responsesto>
		*/

		//
		// store routing information
		//

		while (TRUE)
		{
			IMTConfigPropSetPtr responsesto = arTop->NextSetWithName(L"responsesto");
			if (responsesto == NULL)
				break;
			
			MeterRouteQueueInfo info;

			// meter name (required)
			info.SetMeterName(responsesto->NextStringWithName(L"metername"));

			// machine name (optional)
			if (responsesto->NextMatches(L"machine", PROP_TYPE_STRING) == VARIANT_TRUE)
				info.SetMachineName(responsesto->NextStringWithName(L"machine"));
			else
				info.SetMachineName(L"");

			// queue name (required)
			info.SetQueueName(responsesto->NextStringWithName(L"queue"));

			arInfo.mQueueInfo.push_back(info);
		}

		return TRUE;
	}
	catch (_com_error err)
	{
		ErrorObject * obj = CreateErrorFromComError(err);
		SetError(obj);
		delete obj;
		return FALSE;
	}
}

