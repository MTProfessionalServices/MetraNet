/**************************************************************************
 * @doc WIN32NET
 *
 * @module Windows 32 Network Layer |
 *
 * This is an implementation of NetStream for the win32(95/nt) platform.
 *
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 *
 * @index | WIN32NET
 ***************************************************************************/

#ifndef _WIN32NET_H
#define _WIN32NET_H

// metratech includes
#include <netstream.h>

// std includes
#include <wininet.h>

/************************************************* Win32NetStream ***/

/* @class
 *
 * Windows 32 version of NetStream.  Uses the WININET DLL to perform
 * the network operations.
 * 
 * @xref <c NetStream>
 */

class Win32NetStream : public NetStream
{
// @access Public:
public:

	// @cmember Constructor.
	Win32NetStream() : mInternet(NULL)
	{ }

	// TODO: temporary
	virtual ~Win32NetStream()
	{
		Close();
	}

	// @cmember
	// Initialize the class.  This does not connect to any site.
	// @parm Name of proxy server to use, in form http://proxy:80
	BOOL Init(const char * apProxyName = NULL);

	// @cmember
	// Connection to an HTTP server.
	NetStreamConnection *	OpenHttpConnection(
		const char * apVerb,
		const char * apServer,
		const char * apFileName,
		BOOL aKeepAlive = FALSE,
		const char * apUserName = NULL,
		const char * apPassword = NULL,
		const char * apHeaders = NULL,
		int aPort = DEFAULT_HTTP_PORT);

	// @cmember
	// Connection to an HTTP server via SSL.
	NetStreamConnection * OpenSslHttpConnection(
		const char * apVerb,
		const char * apServer,
		const char * apFileName,
		BOOL aKeepAlive = FALSE,
		const char * apUserName = NULL,
		const char * apPassword = NULL,
		const char * apHeaders = NULL,
		int aPort = DEFAULT_HTTP_SSL_PORT);

	// @cmember
	// Close the connection to the net.
	// TODO: why isn't this function being called by NetStream::~NetStream
	virtual BOOL Close();

// @access Protected:
protected:

// @access Private:
private:
	// @cmember Internet HANDLE returned by WININET.DLL
	HINTERNET mInternet;
};


/*************************************** Win32NetStreamConnection ***/

/* @class
 *
 * Win32 specific class that handles the connection to the webserver using
 * the WININET DLL.
 * 
 * @xref
 *   <c NetStreamConnection>
 */
class Win32NetStreamConnection : public NetStreamConnection
{
// @access Public:
public:
	// @cmember Constructor
	Win32NetStreamConnection();

	// TODO: temporary
	~Win32NetStreamConnection()
	{
		Close();
	}

	// @cmember
	// Connect to an HTTP server.
	// TODO: make this a friend
	virtual BOOL Connect(HINTERNET aSession, const char * apVerb,
											 const char * apServer,
											 const char * apFileName,
											 BOOL aKeepAlive = FALSE,
											 const char * apUserName = NULL,
											 const char * apPassword = NULL,
											 const char * apHeaders = NULL,
											 int aPort = NetStream::DEFAULT_HTTP_PORT,
											 BOOL aSecure = FALSE);


	// @cmember
	// If connected with Keep-Alive, use this method to
	// reuse the connection.
	virtual BOOL ReConnect(const char * apVerb, const char * apServer,
												 const char * apFileName,
												 BOOL aKeepAlive = FALSE,
												 const char * apUserName = NULL,
												 const char * apPassword = NULL,
												 const char * apHeaders = NULL,
												 int aPort = NetStream::DEFAULT_HTTP_PORT,
												 BOOL aSecure = FALSE);


	int SendBytes(const char * apBuffer, int aLen);
	int EndRequest();
	int ReceiveBytes(char * apBuffer, int aLen, int * apLenRead);

	// @cmember close the connection to the net
	void Close();

// @access Protected:
protected:

// @access Private:
private:

	// @cmember used by Connect and ReConnect
	BOOL
	OpenRequest(const char * apVerb,
							const char * apServer,
							const char * apFileName,
							BOOL aKeepAlive, // = FALSE
							const char * apUserName, // = NULL
							const char * apPassword, // = NULL
							const char * apHeaders, // = NULL
							int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
							BOOL aSecure /* = FALSE */);


	// @cmember handle representing HTTP request
	HINTERNET mRequest;

	// @cmember handle that holds the connection to the web server
	HINTERNET mConnection;
};

#endif /* _WIN32NET_H */
