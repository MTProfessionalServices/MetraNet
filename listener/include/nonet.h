/**************************************************************************
 * @doc NONET
 *
 * @module |
 *
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
 * $Header$
 *
 * @index | NONET
 ***************************************************************************/

#ifndef _NONET_H
#define _NONET_H
#ifdef WIN32
// only want this header brought in one time
#pragma once
#endif // WIN32

#include <comip.h>
#include <handler.h>
#include <mtsdk.h>
#include <msixapi.h>

#import <MTEnumConfigLib.tlb>

class NoNetNetMeterAPI : public MSIXNetMeterAPI
{
public:
	/*
	 * generic NetMeter API interface
	 */

	NoNetNetMeterAPI(Win32NetStream * apNet)
		: MSIXNetMeterAPI(apNet),
			mInitialized(FALSE)
	{ }
	virtual ~NoNetNetMeterAPI()
	{ }

	BOOL HandleStream(const std::string & message, std::string & output);

	virtual BOOL Init();
	virtual BOOL Close();


private:
	MeterHandler mHandler;

	MSIXMessage * ParseResults(MSIXParser & arParser, const std::string & arResults);

protected:
	virtual MSIXMessage * SendRequest(MSIXParser & arParser,
																		MeteringServer & arServer,
																		const MSIXMessage & arMessage);

	BOOL mInitialized;
};

class MTMeterNoNetConfig : public MTMeterConfig
{
public:
	MTMeterNoNetConfig();

	virtual ~MTMeterNoNetConfig();

	BOOL HandleStream(const std::string & message, std::string & output);

	// must call init before handlestream
	BOOL Init()
	{ return mpAPI->Init(); }

	void AddServer(int priority, const char * serverName,
								 int port, BOOL secure, const char * username,
								 const char * password);

// @access Protected:
protected:
	// @cmember
	//   Called by MTMeter.  Do not use this function in other cases.
	virtual NetMeterAPI * GetAPI();
	// @cmember
	//   Here just because this function needs an implementation. Do not use.
	virtual NetMeterAPI * GetSoapAPI();

// @access Protected:
protected:
	// @cmember
	//   Object used by the implementation of MTMeterHTTPConfig.
	NoNetNetMeterAPI * mpAPI;
};

#endif /* _NONET_H */
