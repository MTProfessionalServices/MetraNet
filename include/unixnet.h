/**************************************************************************
 * @doc UNIXNET
 *
 * @module Unix Network Layer
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
 * Created by: billo
 * $Header$
 *
 * @index | UNIXNET
 ***************************************************************************/

#ifndef _UNIXNET_H
#define _UNIXNET_H

// metratech includes
#include <netstream.h>
#include <metraunix.h>

#include <errno.h>
#include <synch.h>  // for semaphores

#include <mtssl.h>

// std includes


/************************************************* Unix HTTP Stream **/

typedef enum {
  MT_UNIX_HTTP_STATE_INIT,
  MT_UNIX_HTTP_STATE_SENT_HEADERS,
  MT_UNIX_HTTP_STATE_SENT,
  MT_UNIX_HTTP_STATE_READ_HEADERS,
  MT_UNIX_HTTP_STATE_READING_CONTENT,
  MT_UNIX_HTTP_STATE_BOGUS
} MT_UNIX_HTTP_STATE;
  
#define MT_UNIX_HTTP_LINESIZE 2048

/* @class
 * 
 * Unix class for managing an HTTP request.
 * 
 */
class UnixHttpRequest: public ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  UnixHttpRequest(const char *apVerb, const char *apServer,
                  const char *apResource, int iSocket, 
                  SSL *aSSL, BOOL aUseProxy=FALSE);

  ~UnixHttpRequest();

  //@cmember add a single header. arg should not have a newline
  BOOL AddHeader(const char *header);

  //@cmember add multiple headers (newlines should be included)
  // returns number of headers added. (FIXME: doesn't replace headers yet.)
  BOOL AddHeaders(const char *headers);

  //@cmember send the request
  BOOL Send(void);

  //@cmember read the response headers
  // returns the number of headers.
  // returns status in the status param
  // returns a broken-up arrary of headers in the headers array.
  // returns content-length in content_len
  int ReadResponse(int *status, int *content_len);

  //@cmember read HTTP data
  int ReadData(unsigned char *buffer, int len);

  //@cmember write HTTP data
  int WriteData(const unsigned char *buffer, int buffer_size);

private:
  int   ReadLine(char *buffer, int buffer_size);

  char   mVerb[MAX_PATH];
  char  mServer[MAX_PATH];
  char  mResource[MAX_PATH];
  
  int    mSocket;
  SSL    *mSSL;
  BOOL   mUseProxy;

  char  *mRequestHeaders[256];
  int    mRequestHeaderCount;
  char  *mResponseHeaders[256];
  int    mResponseHeaderCount;

  int   mContentLength;
  int   mContentRemaining;
  int   mStatus;
  
  MT_UNIX_HTTP_STATE mState;
  
};


/************************************************* UnixNetStream ***/

/* @class
 *
 * Windows 32 version of NetStream.  Uses the WININET DLL to perform
 * the network operations.
 * 
 * @xref <c NetStream>
 */

class UnixNetStream : public NetStream
{
// @access Public:
public:

  // @cmember Constructor.
  UnixNetStream() : mInternet(NULL)
  { }

  // TODO: temporary
  virtual ~UnixNetStream()
  {
    Close();
  }

  // @cmember
  // Initialize the class.  This does not connect to any site.
  // @parm Name of proxy server to use, in form http://[user:pass@]proxy:80
  BOOL Init(const char * apProxyName = NULL);

  // @cmember
  // Connection to an HTTP server.
  NetStreamConnection *  OpenHttpConnection(
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
  int   mInternet;
    
  // @cmember Proxy identification string
  const char * mProxy;
};


/* @class
 *
 * Unix specific class that handles the connection to the webserver using
 * the WININET DLL.
 * 
 * @xref
 *   <c NetStreamConnection>
 */
class UnixNetStreamConnection : public NetStreamConnection
{
// @access Public:
public:
  // @cmember Constructor
  UnixNetStreamConnection();

  // @cmember Destructor
  ~UnixNetStreamConnection()
  {
    Close();
  }
 
  // @cmember
  // Connect to an HTTP server.
  // TODO: make this a friend
  virtual BOOL Connect(int aSession, const char * apVerb,
                       const char * apServer,
                       const char * apFileName,
                       BOOL aKeepAlive = FALSE,
                       const char * apUserName = NULL,
                       const char * apPassword = NULL,
                       const char * apHeaders = NULL,
                       int aPort = NetStream::DEFAULT_HTTP_PORT,
                       BOOL aSecure = FALSE, 
                       unsigned int timeout = 0,
                       unsigned int numretry = 0,
                       const char * apProxy = NULL);


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

  // socket used for the connection
  // (needed for keep alive reconnections).
  int mSession;

  // @cmember handle representing HTTP request
  UnixHttpRequest  *mRequest;

  // @cmember handle that holds the connection to the web server
  int mConnection;
  
  // @cmember SSL context handle
  SSL_CTX    *mSSLContext;

  // @cmember SSL connection handle
  SSL        *mSSL;

  // @cmember Proxy server name
  char*      mProxyServer;

  // @cmember Proxy server port
  int        mProxyPort;

  // @cmember Proxy authentication credentials ("username:password")
  char*      mProxyCreds;
};

#endif /* _UnixNET_H */
