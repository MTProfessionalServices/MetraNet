/**************************************************************************
 * @doc NETSTREAM
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

// metratech includes
#include <metra.h>
#include <netstream.h>

/*************************************************** HttpResponse ***/

#ifndef WIN32
#define lock() /* nothing */
#define unlock() /* nothing */
#endif

HttpResponse::CodeInfo HttpResponse::smCodeTable[] =
{
	// 1xx            INFORMATIONAL
	{ 100, "Continue",																		1 },
	{ 101, "Switching Protocols",													1 },

	// 2xx           SUCCESSFUL
	{ 200, "OK",																					0 },
	{ 201, "Created",																			0 },
	{ 202, "Accepted",																		0 },
	{ 203, "Non-Authoriative Information",								1 },
	{ 204, "No Content",																	0 },
	{ 205, "Reset Content",																1 },
	{ 206, "Partial Content",															1 },
	{ 220, "Uses Protocol Extensions",										2 },

	// 3xx           REDIRECTION
	{ 300, "Multiple Choices",														1 }, 
	{ 301, "Moved Permanently",														0 }, 
	{ 302, "Moved Temporarily",														0 }, 
	{ 303, "See Other",																		1 }, 
	{ 304, "Not Modified",																0 }, 
	{ 305, "Use Proxy",																		1 }, 

	// 4xx           CLIENT ERROR
	{ 400, "Bad Request",																	0 }, 
	{ 401, "Unauthorized",																0 }, 
	{ 402, "Payment Required",														1 }, 
	{ 403, "Forbidden",																		0 }, 
	{ 404, "Not Found",																		0 }, 
	{ 405, "Method Not Allowed",													1 }, 
	{ 406, "Not Acceptable",															1 }, 
	{ 407, "Proxy Authentication Required",								1 }, 
	{ 408, "Request Timeout",															1 }, 
	{ 409, "Conflict",																		1 },
	{ 410, "Gone",																				1 }, 
	{ 411, "Length Required",															1 }, 
	{ 412, "Precondition Failed",													1 }, 
	{ 413, "Request Entity To Large",											1 }, 
	{ 414, "Request-URI Too Long",												1 }, 
	{ 415, "Unsupported Media Type",											0 }, 
	{ 420, "Bad Protocol Extension Request",							2 }, 
	{ 421, "Protocol Extension Unknown",									2 }, 
	{ 422, "Protocol Extension Refused",									2 }, 
	{ 423, "Bad Protocol Extension Parameters",						2 }, 

	// 5xx           SERVER ERROR
	{ 500, "Internal Server Error",												0 }, 
	{ 501, "Not Implemented",															0 }, 
	{ 502, "Bad Gateway",																	0 }, 
	{ 503, "Service Unavailable",													0 }, 
	{ 504, "Gateway Timeout",															1 }, 
	{ 505, "HTTP Version Not Supported",									1 }, 
	{ 520, "Protocol Extension Error",										2 }, 
	{ 521, "Protocol Extension Not Implemented",					2 }, 
	{ 522, "Protocol Extension Parameters Not Acceptable",2 },
};

const char * HttpResponse::GetStatusString() const
{
	// this isn't the fastest lookup, but who cares
	for (int i = 0; i < sizeof(smCodeTable) / sizeof(smCodeTable[0]); i++)
	{
		if (smCodeTable[i].mCode == mCode)
			return smCodeTable[i].mMessage;
	}

	// what else can we return
	return "Unknown";
}


/****************************************************** NetStream ***/

NetStream::NetStream()
{
	mUserAgent = NS_DEFAULT_USER_AGENT;
	mTimeout = DEFAULT_TIMEOUT;
	mRetries = DEFAULT_RETRIES;
}

NetStream::~NetStream()
{ }

// @mfunc
// Set the user agent string sent to the web server with
// each request.
// @parm user agent string sent to web server in User-Agent: header
void NetStream::SetUserAgent(const char * apUserAgent)
{
	if (apUserAgent)
		mUserAgent = apUserAgent;
	else
		mUserAgent.resize(0);
}



// @mfunc Return the user agent string.
// @rdesc The user agent string, or NULL if it hasn't been set.
const char * NetStream::GetUserAgent() const
{
	if (mUserAgent.length() == 0)
		return NULL;
	return mUserAgent.c_str();
}

/******************************************** NetStreamConnection ***/

NetStreamConnection::NetStreamConnection() :
	mResponseCode(0),
	mContentLength(0),
	mContentBytesProcessed(0)
{ }
