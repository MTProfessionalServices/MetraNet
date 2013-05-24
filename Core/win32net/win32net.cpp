/**************************************************************************
 * @doc
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
#include "win32net.h"


#include <base64.h>

#define NET_LOGGING_ENABLED

#ifdef NET_LOGGING_ENABLED
#include <stdio.h>
#include <mttime.h>
// #include "NTThreadLock.h"

// NTThreadLock ntlock;

void NetLogDebug(const char * apFormat, ...)
{
	//if (!mspLogStream || MT_SDK_DEBUG < msLogLevel)
	//return;
  // ntlock.Lock();
  /*FILE* file = fopen("C:\\sdklog.txt", "a+c");
	va_list argp;
  char dateTime[MAX_PATH];
  time_t mttime = GetMTTime();
  struct tm  * lTime = localtime (&mttime);
	strftime(dateTime, MAX_PATH, "MetraTime[%m/%d/%y %H:%M:%S=]", lTime);
	fprintf(file, "%s DEBUG: ", dateTime);
	va_start(argp, apFormat);
	vfprintf(file, apFormat, argp);
	va_end(argp);
	fprintf(file, "\n");
	fflush(file);
	fclose(file);*/
  // ntlock.Unlock();
}


#define NET_LOG_DEBUG NetLogDebug

#else // NET_LOGGING_ENABLED

// this is like how MFC defines TRACE with debugging off
// NOTE: unless optimization is on, the strings will still appear
// in the EXE.  With optimization on, the compiler will
// detect that the strings are dead code and eliminate them
inline void NetLogNullDebug(const char *, ...) { }
#define NET_LOG_DEBUG 1 ? (void)0 : ::NetLogNullDebug

#endif // NET_LOGGING_ENABLED





/************************************************* Win32NetStream ***/

// @mfunc
// Initialize the class.  This does not connect to any site.
// @rdesc TRUE if successful
BOOL Win32NetStream::Init(const char * apProxyName /* = NULL */)
{
	BOOL error = FALSE;

	// TODO: revisit the last param.  It can be 
	//    INTERNET_FLAG_ASYNC 
	//    INTERNET_FLAG_FROM_CACHE 
	//    INTERNET_FLAG_OFFLINE 
	ASSERT(GetUserAgent());

	NET_LOG_DEBUG("InternetOpen");

	if (apProxyName)
	{
    NET_LOG_DEBUG("InternetOpen(%s, INTERNET_OPEN_TYPE_PROXY, %s)", GetUserAgent(), apProxyName);

		// proxy, in form http://proxy:80
		mInternet = ::InternetOpen(GetUserAgent(), INTERNET_OPEN_TYPE_PROXY,
															 apProxyName, NULL, 0);
	}
	else
	{
    NET_LOG_DEBUG("InternetOpen(%s, INTERNET_OPEN_TYPE_DIRECT)", GetUserAgent());

		// no proxy
		mInternet = ::InternetOpen(GetUserAgent(), INTERNET_OPEN_TYPE_DIRECT,
															 NULL, NULL, 0);
	}

	if (!mInternet)
		error = TRUE;

	DWORD param;
	if (!error)
	{
    NET_LOG_DEBUG("InternetSetOption(INTERNET_OPTION_CONNECT_TIMEOUT");

    // set timeout
		param = GetConnectTimeout();
		if (!::InternetSetOption(mInternet, INTERNET_OPTION_CONNECT_TIMEOUT,
														 &param, sizeof(param)))
			error = TRUE;
	}

 	if (!error)
	{
    NET_LOG_DEBUG("InternetSetOption(INTERNET_OPTION_RECEIVE_TIMEOUT");

		// set timeout
		param = GetConnectTimeout();
		if (!::InternetSetOption(mInternet, INTERNET_OPTION_RECEIVE_TIMEOUT,
														 &param, sizeof(param)))
			error = TRUE;
	}

 	if (!error)
	{
    NET_LOG_DEBUG("InternetSetOption(INTERNET_OPTION_RECEIVE_TIMEOUT");

		// set retries
		param = GetConnectTimeout();
		if (!::InternetSetOption(mInternet, INTERNET_OPTION_SEND_TIMEOUT,
														 &param, sizeof(param)))
			error = TRUE;
	}

	if (!error)
	{
		// set retries
		param = GetConnectRetries();
		if (!::InternetSetOption(mInternet, INTERNET_OPTION_CONNECT_RETRIES,
														 &param, sizeof(param)))
			error = TRUE;
	}

	if (error)
	{
    NET_LOG_DEBUG("Failed Win32NetStream::Init, error %d", ::GetLastError());
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "InternetOpen");
		return FALSE;
	}
	else
	{
   	NET_LOG_DEBUG("InternetOpen success");

		ClearError();
		return TRUE;
	}
}


// @mfunc
// Connection to an HTTP server.
//  @parm Action to take (GET, POST, PUT, etc).
//  @parm Server name.
//  @parm File name on the server.
//  @parm User name
//  @parm Password
//  @parm Additional headers, separated by cr/lf.
//  @parm Optional port number.
//  @rdesc
//   A NetStreamConnection object that represents an HTTP connection
//   to the given server, file and port.  You need to close and
//   delete this connection when you're done with it.
//   Returns NULL if the connection couldn't be made.
// @xref <c NetStreamConnection> <c Win32NetStreamConnection>
NetStreamConnection * Win32NetStream::OpenHttpConnection(
	const char * apVerb,
	const char * apServer,
	const char * apFileName,
	BOOL aKeepAlive,							// = FALSE
	const char * apUserName,			// = NULL
	const char * apPassword,			// = NULL
	const char * apHeaders,				// = NULL
	int aPort)										// = DEFAULT_HTTP_PORT
{
	Win32NetStreamConnection * connection = new Win32NetStreamConnection;

	NET_LOG_DEBUG("->Connect(plain)");
	if (!connection->Connect(mInternet, apVerb, apServer, apFileName, aKeepAlive,
													 apUserName, apPassword,
													 apHeaders, aPort, FALSE))
	{
    NET_LOG_DEBUG("->Connect failed: error %d", connection->GetLastError());

		SetError(connection->GetLastError());
		delete connection;
		return NULL;
	}

	ClearError();
	return connection;
}


// @mfunc
// Connection to an HTTP server via SSL.
//  @parm Action to take (GET, POST, PUT, etc).
//  @parm Server name.
//  @parm File name on the server.
//  @parm User name
//  @parm Password
//  @parm Additional headers, separated by cr/lf.
//  @parm Optional port number.
//  @rdesc
//   A NetStreamConnection object that represents an HTTP connection
//   to the given server, file and port.  You need to close and
//   delete this connection when you're done with it.
//   Returns NULL if the connection couldn't be made.
// @xref <c NetStreamConnection> <c Win32NetStreamConnection>
NetStreamConnection * Win32NetStream::OpenSslHttpConnection(
	const char * apVerb,
	const char * apServer,
	const char * apFileName,
	BOOL aKeepAlive,							// = FALSE
	const char * apUserName,			// = NULL
	const char * apPassword,			// = NULL
	const char * apHeaders,				// = NULL
	int aPort)										// = DEFAULT_SSL_HTTP_PORT
{
	Win32NetStreamConnection * connection = new Win32NetStreamConnection;

	NET_LOG_DEBUG("->Connect(ssl)");
	if (!connection->Connect(mInternet, apVerb, apServer, apFileName, aKeepAlive,
													 apUserName, apPassword, apHeaders, aPort, TRUE))
	{
		SetError(::GetLastError(),
						 ERROR_MODULE, ERROR_LINE, "OpenSslHttpConnection");
		delete connection;
		return NULL;
	}

	ClearError();
	return connection;
}


// @cmember Close the connection to the net.
BOOL Win32NetStream::Close()
{
	NET_LOG_DEBUG("InternetCloseHandle(mInternet)");
	if (mInternet)
	{
		if (!::InternetCloseHandle(mInternet))
		{
      NET_LOG_DEBUG("InternetCloseHandle failed: error %d", ::GetLastError());

			SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "Close");
			return FALSE;
		}
		// clear in case Close() is called again
		mInternet = NULL;
	}
	return TRUE;
}




/*************************************** Win32NetStreamConnection ***/

Win32NetStreamConnection::Win32NetStreamConnection() :
	//mOutputBuffer((ios::open_mode) (ios::out | ios::binary)),
	//mInputBuffer((ios::open_mode) (ios::in | ios::binary)),
	mConnection(NULL),
	mRequest(NULL)
{}

// @mfunc
// Connect to an HTTP server.
//  @parm Handle to internet connection.
//  @parm Action to take (GET, POST, PUT, etc).
//  @parm Server name.
//  @parm File name on the server.
//  @parm User name
//  @parm Password
//  @parm Optional port number.
//  @rdesc
//   TRUE if the function succeeds
// @xref <c NetStream>
BOOL
Win32NetStreamConnection::Connect(HINTERNET aSession, const char * apVerb,
																	const char * apServer,
																	const char * apFileName,
																	BOOL aKeepAlive, // = FALSE
																	const char * apUserName, // = NULL
																	const char * apPassword, // = NULL
																	const char * apHeaders, // = NULL
																	int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
																	BOOL aSecure /* = FALSE */)
{
	ASSERT(aSession);
	ASSERT(apVerb);
	ASSERT(apServer);
	ASSERT(apFileName);
	ASSERT(aPort > 0);

	BOOL error = FALSE;
	NET_LOG_DEBUG("InternetConnect");

	// if username either field is NULL they're both overridden
	if (apUserName == NULL || apPassword == NULL)
	{
		apUserName = "";
		apPassword = "";
	}


	// keep this around in case we want to reconnect
	//mSession = aSession;

	// open the connection
	mConnection = ::InternetConnect(aSession, apServer, aPort,
																	apUserName, apPassword,
																	INTERNET_SERVICE_HTTP, 0, 0);
	
  if (!mConnection)
  {
    NET_LOG_DEBUG("InternetConnect failed: error %d", ::GetLastError());
		error = TRUE;
  }

	NET_LOG_DEBUG("mConnection = %lX", (DWORD) mConnection);


	// NOTE: this assumes OpenRequest sets the error
	return OpenRequest(apVerb, apServer, apFileName,
										 aKeepAlive, apUserName, apPassword, apHeaders,
										 aPort, aSecure);
}




BOOL
Win32NetStreamConnection::ReConnect(const char * apVerb,
																		const char * apServer,
																		const char * apFileName,
																		BOOL aKeepAlive, // = FALSE
																		const char * apUserName, // = NULL
																		const char * apPassword, // = NULL
																		const char * apHeaders, // = NULL
																		int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
																		BOOL aSecure /* = FALSE */)
{
	BOOL error = FALSE;

	// We have to read all outstanding data on the Internet handle 
	// before we can resubmit request. Just discard the data. 
#if 0
	char buf;
	DWORD dwSize;
	do
	{
		::InternetReadFile(mRequest, &buf, sizeof(buf), &dwSize);
	}
	while (dwSize != 0);
#endif
//	if (!::HttpEndRequest(mRequest, NULL, 0, 0))
//	{
//		DWORD er = ::GetLastError();
//	}


#if 0
	// TODO: will this close the connection on keep alive?
	if (mRequest)
	{
		::InternetCloseHandle(mRequest);
		mRequest = NULL;
	}

	return OpenRequest(apVerb, apServer, apFileName,
										 aKeepAlive, apUserName, apPassword, apHeaders,
										 aPort, aSecure);
#endif



	ASSERT(apVerb);
	ASSERT(apServer);
	ASSERT(apFileName);
	ASSERT(aPort > 0);

//	InternetCloseHandle(mRequest);


#if 0
	// TODO: I don't want to cache but boundschecker reports this
	// flag as conflicting with INTERNET_FLAG_SECURE for some reason

	DWORD flags =
		INTERNET_FLAG_RELOAD				// always load from the net
		| INTERNET_FLAG_NO_CACHE_WRITE // don't write to the cache
		| INTERNET_FLAG_NO_COOKIES	// don't try to use cookies
		| INTERNET_FLAG_PRAGMA_NOCACHE; // don't cache at proxies

	// add SSL if requested
	if (aSecure)
		flags |= INTERNET_FLAG_SECURE;

	// add keep alive flag if requested
	if (aKeepAlive)
		flags |= INTERNET_FLAG_KEEP_CONNECTION;


	

	// TODO: do the accept types have to be changed here?
	// TODO: flags should be different (especially for a secure connection)
	// TODO: could use HttpAddRequestHeaders before this call
	NET_LOG_DEBUG("HttpOpenRequest");
	mRequest = ::HttpOpenRequest(mConnection, 
									apVerb, 
									apFileName,
									NULL, // version (=HTTP/1.0)
									NULL, // referrer
									NULL, // accept types,
									flags, // flags
									0); // context
	if (!mRequest)
		error = TRUE;

	NET_LOG_DEBUG("mRequest = %lX", (DWORD) mRequest);

#endif


	// add any user defined headers
	if (!error && apHeaders != NULL &&
			!::HttpAddRequestHeaders(mRequest, apHeaders, -1,
															 HTTP_ADDREQ_FLAG_REPLACE | HTTP_ADDREQ_FLAG_ADD))
	 error = TRUE;

	// use authorization only if the user wants it
	if (strlen(apUserName) > 0 || strlen(apPassword) > 0)
	{
		// force the authentication by generating the string ourself
		// it will look like this:
		//  Authorization: Basic c2RrdGVzdDpzZGt0ZXN0
		string auth;
		auth = "Authorization: Basic ";
		// now append username:password, base64 encoded
		char encodeBuffer[100];
		strcpy(encodeBuffer, apUserName);
		strcat(encodeBuffer, ":");
		strcat(encodeBuffer, apPassword);

		// encode
		string encoded;
		if (!rfc1421encode((const unsigned char *) encodeBuffer, strlen(encodeBuffer), encoded))
		{
			// TODO: GetLastError won't do anything for this function
			// however, it should never fail
			ASSERT(0);
			error = TRUE;
		}

		// remove any trailing ='s, they're not needed
		int i = encoded.length() - 1;
		while (encoded[i] == '=')
			i--;

		auth.append(encoded.c_str(), i + 1);

		// set the header
		if (!error && !::HttpAddRequestHeaders(mRequest, auth.c_str(), -1,
																					 HTTP_ADDREQ_FLAG_ADD))
			error = TRUE;
	}


	// TODO: do the flags have to be set differently?
	if (!error)
		NET_LOG_DEBUG("HttpSendRequestEx");
	if (!error && !::HttpSendRequestEx(mRequest,
																		 NULL,	// buffers in
																		 NULL,	// buffers out
																		 0,			// flags?
																		 0))		// context?
		error = TRUE;


	// TODO: do other options have to be set?
	if (error)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "Connect");
		return FALSE;
	}
	else
	{
		ClearError();
		return TRUE;
	}




}



BOOL
Win32NetStreamConnection::OpenRequest(const char * apVerb,
																	const char * apServer,
																	const char * apFileName,
																	BOOL aKeepAlive, // = FALSE
																	const char * apUserName, // = NULL
																	const char * apPassword, // = NULL
																	const char * apHeaders, // = NULL
																	int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
																	BOOL aSecure /* = FALSE */)
{
	ASSERT(apVerb);
	ASSERT(apServer);
	ASSERT(apFileName);
	ASSERT(aPort > 0);

	// TODO: I don't want to cache but boundschecker reports this
	// flag as conflicting with INTERNET_FLAG_SECURE for some reason
	DWORD flags =
		INTERNET_FLAG_RELOAD				// always load from the net
		| INTERNET_FLAG_NO_CACHE_WRITE // don't write to the cache
		| INTERNET_FLAG_NO_COOKIES	// don't try to use cookies
		| INTERNET_FLAG_PRAGMA_NOCACHE; // don't cache at proxies

	// add SSL if requested
	if (aSecure)
		flags |= INTERNET_FLAG_SECURE;

	// add keep alive flag if requested
	if (aKeepAlive)
		flags |= INTERNET_FLAG_KEEP_CONNECTION;

	BOOL error = FALSE;

	// TODO: do the accept types have to be changed here?
	// TODO: flags should be different (especially for a secure connection)
	// TODO: could use HttpAddRequestHeaders before this call
	NET_LOG_DEBUG("HttpOpenRequest");
	mRequest = ::HttpOpenRequest(mConnection, apVerb, apFileName,
															 NULL, // version (=HTTP/1.0)
															 NULL, // referrer
															 NULL, // accept types,
															 flags, // flags
															 0); // context
	if (!mRequest)
		error = TRUE;

	NET_LOG_DEBUG("mRequest = %lX", (DWORD) mRequest);

	// add any user defined headers
	if (!error && apHeaders != NULL &&
			!::HttpAddRequestHeaders(mRequest, apHeaders, -1,
															 HTTP_ADDREQ_FLAG_REPLACE | HTTP_ADDREQ_FLAG_ADD))
	 error = TRUE;

	// use authorization only if the user wants it
	if (strlen(apUserName) > 0 || strlen(apPassword) > 0)
	{
		// force the authentication by generating the string ourself
		// it will look like this:
		//  Authorization: Basic c2RrdGVzdDpzZGt0ZXN0
		string auth;
		auth = "Authorization: Basic ";
		// now append username:password, base64 encoded
		char encodeBuffer[100];
		strcpy(encodeBuffer, apUserName);
		strcat(encodeBuffer, ":");
		strcat(encodeBuffer, apPassword);

		// encode
		string encoded;
		if (!rfc1421encode((const unsigned char *) encodeBuffer, strlen(encodeBuffer), encoded))
		{
			// TODO: GetLastError won't do anything for this function
			// however, it should never fail
			ASSERT(0);
			error = TRUE;
		}

		// remove any trailing ='s, they're not needed
		int i = encoded.length() - 1;
		while (encoded[i] == '=')
			i--;

		auth.append(encoded.c_str(), i + 1);

		// set the header
		if (!error && !::HttpAddRequestHeaders(mRequest, auth.c_str(), -1,
																					 HTTP_ADDREQ_FLAG_ADD))
			error = TRUE;
	}


	// TODO: do the flags have to be set differently?
	if (!error)
		NET_LOG_DEBUG("HttpSendRequestEx");
	if (!error && !::HttpSendRequestEx(mRequest,
																		 NULL,	// buffers in
																		 NULL,	// buffers out
																		 0,			// flags?
																		 0))		// context?
	{
// TODO: ignoring invalid certificate authorities
//...   Again:
//   if (!HttpSendRequest (hReq,...))
//      dwError = GetLastError ();
//   if (dwError == ERROR_INTERNET_INVALID_CA)
//   {      DWORD dwFlags;
//      DWORD dwBuffLen = sizeof(dwFlags);
//      InternetQueryOption (hReq, INTERNET_OPTION_SECURITY_FLAGS,
//            (LPVOID)&dwFlags, &dwBuffLen);
//      dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
//      InternetSetOption (hReq, INTERNET_OPTION_SECURITY_FLAGS,
//                            &dwFlags, sizeof (dwFlags) );
//      goto again;   }


		DWORD errCode = ::GetLastError();
		error = TRUE;
		if (errCode == ERROR_INTERNET_INVALID_CA)
		{
			DWORD flags;
			DWORD buffLen = sizeof(flags);
			::InternetQueryOption(mRequest, INTERNET_OPTION_SECURITY_FLAGS,
														&flags, &buffLen);
			flags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
			::InternetSetOption(mRequest, INTERNET_OPTION_SECURITY_FLAGS,
													&flags, sizeof(flags));
			if (!::HttpSendRequestEx(mRequest,
															 NULL,	// buffers in
															 NULL,	// buffers out
															 0,			// flags?
															 0))		// context?
			{
				errCode = ::GetLastError();
			}
			else
			{
				error = FALSE;
			}
		}

		if (error && errCode == ERROR_INTERNET_SEC_CERT_CN_INVALID)
		{
			DWORD flags;
			DWORD buffLen = sizeof(flags);
			::InternetQueryOption(mRequest, INTERNET_OPTION_SECURITY_FLAGS,
														&flags, &buffLen);
			flags |= SECURITY_FLAG_IGNORE_CERT_CN_INVALID;
			::InternetSetOption(mRequest, INTERNET_OPTION_SECURITY_FLAGS,
													&flags, sizeof(flags));
			if (::HttpSendRequestEx(mRequest,
															 NULL,	// buffers in
															 NULL,	// buffers out
															 0,			// flags?
															 0))		// context?
			{
				error = FALSE;
			}

		}

	}


	// TODO: do other options have to be set?
	if (error)
	{
    NET_LOG_DEBUG("OpenRequest failed: error %d", ::GetLastError());

		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "Connect");
		return FALSE;
	}
	else
	{
		ClearError();
		return TRUE;
	}
}


#if 0
	// NOTE: this code can be used to set up for authorization.
	// HttpSendRequest can deal with the authorization
	// and get us ready for the next request


	mConnection = ::InternetConnect(aSession, apServer, aPort,
																	apUserName, apPassword,
																	INTERNET_SERVICE_HTTP, 0, 0);
	if (!mConnection)
		error = TRUE;

	NET_LOG_DEBUG("mConnection = %lX", (DWORD) mConnection);

	// TODO: I don't want to cache but boundschecker reports this
	// flag as conflicting with INTERNET_FLAG_SECURE for some reason
	DWORD flags =
		INTERNET_FLAG_RELOAD				// always load from the net
		| INTERNET_FLAG_NO_CACHE_WRITE // don't write to the cache
		| INTERNET_FLAG_NO_COOKIES	// don't try to use cookies
		| INTERNET_FLAG_PRAGMA_NOCACHE; // don't cache at proxies

	// add SSL if requested
	if (aSecure)
		flags |= INTERNET_FLAG_SECURE;

	// add keep alive flag if requested
	if (aKeepAlive)
		flags |= INTERNET_FLAG_KEEP_CONNECTION;

	if (!error)
	{
		// TODO: do the accept types have to be changed here?
		// TODO: flags should be different (especially for a secure connection)
		// TODO: could use HttpAddRequestHeaders before this call
		NET_LOG_DEBUG("HttpOpenRequest");
		mRequest = ::HttpOpenRequest(mConnection, apVerb, apFileName,
																 NULL, // version (=HTTP/1.0)
																 NULL, // referrer
																 NULL, // accept types,
																 flags, // flags
																 0); // context
		if (!mRequest)
			error = TRUE;

		NET_LOG_DEBUG("mRequest = %lX", (DWORD) mRequest);
	}


	// TODO: do the flags have to be set differently?
if (!error)
		NET_LOG_DEBUG("HttpSendRequestEx");
if (!error && !::HttpSendRequest(mRequest,
																		 NULL,	// buffers in
																		 NULL,	// buffers out
																		 0,			// flags?
																	 0))		// context?
{
}
		error = TRUE;






	char buf[1024];
	DWORD bufSize;
	if (!error)
		do
		{
			::InternetReadFile(mRequest, buf, sizeof(buf), &bufSize);
		}
		while (bufSize != 0);


	if (!error && !::InternetCloseHandle(mRequest))
		error = TRUE;

	if (!error && !::InternetCloseHandle(mConnection))
			error = TRUE;

#endif



int Win32NetStreamConnection::EndRequest()
{
	BOOL error = FALSE;

	NET_LOG_DEBUG("EndRequest");
	if (!::HttpEndRequest(mRequest, NULL, 0, 0))
		error = TRUE;

	if (!error)
	{
		// retrieve the response code
		DWORD response;
		DWORD dwSize = sizeof(response);
		if (!::HttpQueryInfo(mRequest,
												 HTTP_QUERY_STATUS_CODE | HTTP_QUERY_FLAG_NUMBER,
												 &response, &dwSize, NULL))
			error = TRUE;
		else
			// allow user to retrieve it
			SetResponse(HttpResponse((int) response));

		// retrieve the content length
		unsigned int length;
		dwSize = sizeof(length);
		if(::HttpQueryInfo(mRequest,HTTP_QUERY_CONTENT_LENGTH | HTTP_QUERY_FLAG_NUMBER,
											 &length,&dwSize,NULL))
			SetContentLength(length);
		else
			SetContentLength(0);
	}

	if (error)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "GetInputStream");
		return FALSE;
	}

	return TRUE;
}

int Win32NetStreamConnection::ReceiveBytes(char * apBuffer, int aLen, int * apLenRead)
{
	// NOTE: if TRUE is returned and size == 0, that means EOF
	DWORD size;
    NET_LOG_DEBUG("InternetReadFile(mRequest)");
    
    // step 1: verify input params and data integrity
    ASSERT(apBuffer != NULL && aLen > 0 && apLenRead != NULL);
    ASSERT(((signed int)GetContentLength()) >= 0);
    ASSERT(((signed int)GetBytesProcessed()) >= 0);

    // step 2: check content length
    if( GetContentLength() > 0) {
        // we are using the content length
        unsigned int Readlen;
        Readlen = GetContentLength() - GetBytesProcessed();
        ASSERT(((signed int)Readlen) >= 0);

        // read the content length or the length of the input buffer
        if(Readlen > 0) {
            if(Readlen < (unsigned int)aLen)
                aLen = Readlen;
        }
        else {
	        // if we have allready processed the bytes in the content length,
					// indicate 0 bytes read and return TRUE
            *apLenRead = 0;
            return TRUE;
        }
    }

    // step 3: read the data
	if (!::InternetReadFile(mRequest, apBuffer,aLen, &size))
	{
		*apLenRead = 0;
		SetError(::GetLastError(),
						 ERROR_MODULE, ERROR_LINE, "Produce");
		return FALSE;
	}

    // step 4: add the bytes processed.  This is used for keep-alive.
	AddBytesProcessed(size);

	*apLenRead = size;
	return TRUE;									// return TRUE even if 0 bytes read
}

int Win32NetStreamConnection::SendBytes(const char * apBuffer, int aLen)
{
	DWORD size;
	NET_LOG_DEBUG("InternetWriteFile(mRequest)");

	if (!::InternetWriteFile(mRequest, apBuffer, aLen, &size)
			|| size != (DWORD) aLen)
	{
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "Consume");
		return FALSE;
	}

	return TRUE;
}



// @cmember close the connection to the net
void Win32NetStreamConnection::Close()
{
	// close the request and the connection
	// TODO: is it OK to use this order if the first one fails
	// and the second succeeds?
	BOOL error = FALSE;

	if (mRequest)
	{
		NET_LOG_DEBUG("InternetCloseHandle(mRequest)");
		if (!::InternetCloseHandle(mRequest))
			error = TRUE;
		mRequest = NULL;
	}

	if (mConnection)
	{
		NET_LOG_DEBUG("InternetCloseHandle(mConnection)");
		if (!::InternetCloseHandle(mConnection))
			error = TRUE;
		mConnection = NULL;
	}

	if (error)
		SetError(::GetLastError(), ERROR_MODULE, ERROR_LINE, "Close");
}


