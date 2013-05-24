/**************************************************************************
 * @doc NETSTREAM
 * 
 * @module NetStream Network Layer |
 * 
 * This is the network layer
 *
 * {bml Netstream.bmp}
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
 * @index | NETSTREAM
 ***************************************************************************/

#ifndef _NETSTREAM_H
#define _NETSTREAM_H

#include <errobj.h>

class NetStream;
class NetStreamConnection;
class NetStreamBuf;

/*************************************************** HttpResponse ***/

// @class Wrapper for HTTP response code.  Allows the user
// to get more information about a code.
class HttpResponse
{
// @access Public:
public:
	// @cmember
	// Constructor
	HttpResponse(int aCode)
	{ mCode = aCode; }

	// @cmember
	// Constructor, code will be unknown
	HttpResponse()
	{ mCode = 0; }

	// @cmember
	// Copy constructor
	HttpResponse(const HttpResponse & aResponse)
	{ *this = aResponse; }


	// @cmember
	// allow easy casting back to integer
	operator int () const
	{
		return mCode;
	}

	// @cmember
	// Allow class to be set from another class.
	HttpResponse & operator =(const HttpResponse & aResponse)
	{
		mCode = aResponse;
		return *this;
	}

	// @cmember
	// Allow code to be set from a code.
	HttpResponse & operator =(int aCode)
	{
		mCode = aCode;
		return *this;
	}

	// @cmember
	// return the 100's place digit of the code
	int GetRange() const
	{
		return mCode / 100;
	}

	// @cmember
	// is the code informational?
	int IsInformational() const
	{ return GetRange() == 1; }

	// @cmember
	// is the code successful?
	int IsSuccessful() const
	{ return GetRange() == 2; }

	// @cmember
	// is the code a redirection?
	int IsRedirection() const
	{ return GetRange() == 3; }

	// @cmember
	// is the code a client error?
	int IsClientError() const
	{ return GetRange() == 4; }

	// @cmember
	// is the code a server error?
	int IsServerError() const
	{ return GetRange() == 5; }

	// @cmember
	// Return the string for the error message
	// @devnote NOTE: stupid win32 headers re#define
	//          GetMessage so don't use that name
	const char * GetStatusString() const;

	// @cmember,mstruct Structure used to represent status code strings
  // porting change: this must be public to avoid anachonism warnings
  // when initialized in a file. (SUN compiler)
	struct CodeInfo
	{
		// @@field code
		short mCode;
		// @@field ascii message
		const char * mMessage;
		// @@field min version (ie 2 means >=HTTP 1.2)
		short mMinVersion;
	};

protected:


// @access Private:
private:

	// @cmember Real HTTP code
	short mCode;

  // @cmember table of status messages
	static CodeInfo smCodeTable[];
};


/****************************************************** NetStream ***/

// user agent in case the caller doesn't call SetUserAgent
#define NS_DEFAULT_USER_AGENT "MetraTech NetStream"

/* @class
 *
 * Abstract interface to network layer.  This class allows you to
 * perform HTTP operations and handles security options.
 * 
 */

class NetStream : public ObjectWithError
{
// @access Public:
public:

	// @cmember
	// Constructor.  You must also call Init.
	NetStream();

	// @cmember Destructor.
	// @devnote destructors in derived classes should call Close()
	virtual ~NetStream();

	// @cmember Initialize the class.  This does not connect to any site.
	// @parm Name of proxy server to use, in form http://proxy:80
	virtual BOOL Init(const char * apProxyName) = 0;

	// @cmember,menum constants
	enum
	{
		// @@emem default timeout of five minutes
		DEFAULT_TIMEOUT = 1000*5*60,
		// @@emem default number of retries
		DEFAULT_RETRIES = 5,
		// @@emem default HTTP port
		DEFAULT_HTTP_PORT = 80,
		// @@emem default HTTP port for SSL
		DEFAULT_HTTP_SSL_PORT = 443
	};

	// @cmember,mfunc Open a connection to an HTTP server
	//  @@parm Action to take (GET, POST, PUT, etc).
	//  @@parm Server name.
	//  @@parm File name on the server.
	//  @@parmopt Username
	//  @@parmopt Password
	//  @@parmopt Additional headers, separated by cr/lf.
	//  @@parmopt Optional port number.
	//  @@rdesc
	//   A NetStreamConnection object that represents an HTTP connection
	//   to the given server, file and port.  You need to close and
	//   delete this connection when you're done with it.
	//  @@xref <c NetStreamConnection>
	virtual NetStreamConnection * OpenHttpConnection(
		const char * apVerb,
		const char * apServer,
		const char * apFileName,
		BOOL aKeepAlive = FALSE,
		const char * apUserName = NULL,
		const char * apPassword = NULL,
		const char * apHeaders = NULL,
		int aPort = DEFAULT_HTTP_PORT) = 0;


	// @cmember,mfunc Connection to an HTTP server via SSL.
	//  @@parm Action to take (GET, POST, PUT, etc).
	//  @@parm Server name.
	//  @@parm File name on the server.
	//  @@parmopt Username
	//  @@parmopt Password
	//  @@parmopt Additional headers, separated by cr/lf.
	//  @@parmopt Optional port number.
	//  @@rdesc
	//   A NetStreamConnection object that represents an HTTP connection
	//   to the given server, file and port.  You need to close and
	//   delete this connection when you're done with it.
	//  @@xref <c NetStreamConnection>
	virtual NetStreamConnection * OpenSslHttpConnection(
		const char * apVerb,
		const char * apServer,
		const char * apFileName,
		BOOL aKeepAlive = FALSE,
		const char * apUserName = NULL,
		const char * apPassword = NULL,
		const char * apHeaders = NULL,
		int aPort = DEFAULT_HTTP_SSL_PORT) = 0;


	// @cmember,mfunc
	// Close the connection to the server.
	virtual BOOL Close() = 0;

	// @cmember
	// Set the user agent string sent to the web server with
	// each request.
	void SetUserAgent(const char * apUserAgent);

	// @cmember Return the user agent string.
	const char * GetUserAgent()	const;

	// @cmember,mfunc
	// Set the duration in milliseconds that the operation will wait
	// before timing out.
	// @@parm maximum timeout, in milliseconds
	void SetConnectTimeout(int aTimeout)
	{ mTimeout = aTimeout; }

	// @cmember,mfunc
	// Return the timeout in milliseconds.
	// @@rdesc timeout, in milliseconds
	int GetConnectTimeout() const
	{ return mTimeout; }


	// @cmember,mfunc
	// Set the number of retries to make before giving up.
	// @@parm the max number of retries requested.
	void SetConnectRetries(int aRetries)
	{ mRetries = aRetries; }

	// @cmember,mfunc
	// Get the number of retries
	// @@rdesc the max number of retries requested
	int GetConnectRetries() const
	{ return mRetries; }


// @access Protected:
protected:

// @access Private:
private:
	// @cmember User agent string.  can be NULL
	string mUserAgent;
	// @cmember Max timeout in milliseconds
	int mTimeout;
	// @cmember Max retries
	int mRetries;
};


/******************************************** NetStreamConnection ***/

/* @class
 *
 * Class returned by NetStream that represents a connection
 * to an HTTP server.
 * 
 * @xref <c NetStream>
 */
class NetStreamConnection : public ObjectWithError
{
// @access Public:
public:
	NetStreamConnection();

	// @cmember,mfunc Destructor
	// @devnote: Your derived class should do a Close in its destructor.
	virtual ~NetStreamConnection()
	{ }

	// @cmember,mfunc close the connection to the net
	// @devnote You should override this function to actually close the stream.
	virtual void Close() = 0;

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
												 BOOL aSecure = FALSE) = 0;

	// @cmember
	// Override this method to send the contents of the buffer across
	// the net.
	//  @parm beginning of buffer.
	//  @parm buffer length.
	//  @rdesc TRUE if function succeeds
	virtual int SendBytes(const char * apBuffer, int aLen) = 0;

	// mark the end of output to the server - start receiving bytes now
	virtual int EndRequest() = 0;

	// @cmember
	// Override this method to read from the network into the buffer.
	//  @parm beginning of buffer.
	//  @parm buffer length.
	//  @rdesc TRUE if function succeeds
	virtual int ReceiveBytes(char * apBuffer, int aLen, int * apLenRead) = 0;

	// keep alive methods
	//virtual void SetContentLength(unsigned int aLen) = 0;
	unsigned int GetContentLength()
	{ return mContentLength; }

	unsigned int GetBytesProcessed()
	{ return mContentBytesProcessed; }

	void ClearBytesProcessed()
	{ mContentBytesProcessed = 0; }

	// @cmember,mfunc
	// Return the response code for this connection
	// @@rdesc HttpResponse object that holds the HTTP response code.
	HttpResponse GetResponse()
	{ return mResponseCode; }

	// @cmember,mfunc
	// Called by to set the response code.
	// @parm HttpResponse that holds the HTTP response code.
	void SetResponse(HttpResponse aResponse)
	{ mResponseCode = aResponse; }


// @access Protected:
protected:

	void SetContentLength(unsigned int alen)
	{ mContentLength = alen; }


	void AddBytesProcessed(unsigned int aLen)
	{ mContentBytesProcessed += aLen; }

// @access Private:
private:

	// @cmember set after an OpenHttpConnection call is made
	HttpResponse mResponseCode;

	unsigned int mContentLength;
	unsigned int mContentBytesProcessed;
};

#endif /* _NETSTREAM_H */
