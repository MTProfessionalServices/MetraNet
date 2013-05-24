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
#include "unixnet.h"
#include "mtsocket.h"
#include "base64.h"

#ifdef UNIX
#include <sdk_msg.h>
#endif

//#define NET_LOGGING_ENABLED

#include <string>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>


#ifdef USE_RSA_SSL

#include <e_os.h>
#include <sslc.h>
#include <cert.h>

#else  // Open SSL

#include <ssl.h>
#include <err.h>
#include <rand.h>

#endif // USE_RSA_SSL

#ifdef NET_LOGGING_ENABLED
#include <stdio.h>

void NetLogDebug(const char * apFormat, ...)
{
  //if (!mspLogStream || MT_SDK_DEBUG < msLogLevel)
  //return;

  FILE * fp = stderr;

  va_list argp;
  fprintf(fp, "DEBUG: ");
  va_start(argp, apFormat);
  vfprintf(fp, apFormat, argp);
  va_end(argp);
  fprintf(fp, "\n");
  fflush(fp);
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


/************************************************* UnixNetStream ***/

// @mfunc
// Initialize the class.  This does not connect to any site.
// @rdesc TRUE if successful
BOOL UnixNetStream::Init(const char * apProxyName /* = NULL */)
{
  BOOL error = FALSE;

  // TODO: revisit the last param.  It can be 
  //    INTERNET_FLAG_ASYNC 
  //    INTERNET_FLAG_FROM_CACHE 
  //    INTERNET_FLAG_OFFLINE 
  ASSERT(GetUserAgent());

  NET_LOG_DEBUG("InternetOpen");

  SSL_library_init();
  SSL_load_error_strings();

  // check to see if /dev/random or /dev/urandom exist
  struct stat sbuf;
  if ( stat("/dev/random",&sbuf) && stat("/dev/urandom",&sbuf) ) {
    // nope, need to generate some random crud to seed the random number generator
    int seed[8];
    srandom(time(NULL));
    for ( int i = 0; i < 8; i++ ) seed[i] = random();
    // mix it up a little
    for ( int i = 0; i < 8; i++ ) seed[i] ^= seed[(i+(seed[i]%7)+1)%8];
    RAND_seed (seed, sizeof(seed));

  } else {
    // Open SSL's RAND_load_file reads bytes from the file
    // Stoopid RSA's RAND_load_file just stats the file
#ifndef  USE_RSA_SSL
    RAND_load_file("/dev/random", 256);
#endif
  } 

  mProxy = apProxyName;
  if (!apProxyName)
  {
    // no proxy
    mInternet = 1;  // What to do on unix?  There's no stack to initialize.
  }
  else
  {
    // proxy, in form http://proxy:80

    // on unix maybe we should at least say hi to the proxy server?
    mInternet = 1; 
                            
  }

  if (!mInternet)
    error = TRUE;

  DWORD param;

  if (!error)
  {
    // set timeout
    param = GetConnectTimeout();

    // set socket timeout options here. FIXME
    // TODO: have to do a thing with select and reading here.  not pretty.
    // Usually not a good idea to mess with system defaults.
  }

  if (!error)
  {
    // set retries
    param = GetConnectRetries();
    // set socket retry options here. FIXME
    // question: does this mean setting a TCP retry count, or  
    // an MSIX level retry count? billo
  }

  if (error)
  {
    // report last error from errno
    SetError(errno, ERROR_MODULE, ERROR_LINE, "UnixNetStream::Init");
    return FALSE;
  }
  else
  {
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
// @xref <c NetStreamConnection> <c UnixNetStreamConnection>
NetStreamConnection * UnixNetStream::OpenHttpConnection(
  const char * apVerb,
  const char * apServer,
  const char * apFileName,
  BOOL aKeepAlive,              // = FALSE
  const char * apUserName,      // = NULL
  const char * apPassword,      // = NULL
  const char * apHeaders,        // = NULL
  int aPort)                    // = DEFAULT_HTTP_PORT
{
  unsigned int timeout;
  unsigned int numretry;

  timeout = GetConnectTimeout();
  numretry = GetConnectRetries();  


  UnixNetStreamConnection * connection = new UnixNetStreamConnection;

  NET_LOG_DEBUG("->Connect(plain)");
  //passing proxy informatio in last argument..... 
  if (!connection->Connect(mInternet, apVerb, apServer, apFileName, aKeepAlive,
                           apUserName, apPassword,
                           apHeaders, aPort, FALSE, timeout, numretry, mProxy))
  {
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
// @xref <c NetStreamConnection> <c UnixNetStreamConnection>
NetStreamConnection * UnixNetStream::OpenSslHttpConnection(
  const char * apVerb,
  const char * apServer,
  const char * apFileName,
  BOOL aKeepAlive,              // = FALSE
  const char * apUserName,      // = NULL
  const char * apPassword,      // = NULL
  const char * apHeaders,        // = NULL
  int aPort)                    // = DEFAULT_SSL_HTTP_PORT
{
  UnixNetStreamConnection * connection = new UnixNetStreamConnection;

  NET_LOG_DEBUG("->Connect(ssl)");
  if (!connection->Connect(mInternet, apVerb, apServer, apFileName, aKeepAlive,
                           apUserName, apPassword, apHeaders, aPort, TRUE))
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "OpenSslHttpConnection");
    delete connection;
    return NULL;
  }

  ClearError();
  return connection;
}


// @cmember Close the connection to the net.
BOOL UnixNetStream::Close()
{
  NET_LOG_DEBUG("InternetCloseHandle(mInternet)");
  if (mInternet)
  {
    // clear in case Close() is called again
    mInternet = NULL;
  }
  return TRUE;
}




/*************************************** UnixNetStreamConnection ***/

UnixNetStreamConnection::UnixNetStreamConnection() 
  /*
    :mOutputBuffer((ios::open_mode) (ios::out | ios::binary)),
  mInputBuffer((ios::open_mode) (ios::in | ios::binary))
  */
{
  // mOStream = NULL; // see solaris man page for ostream ; must init
  // mIStream = NULL;
  mConnection = -1;
  mSSLContext = NULL;
  mSSL = NULL;
  mRequest = NULL;
  mProxyServer = NULL;
  mProxyCreds  = NULL; 
}

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
UnixNetStreamConnection::Connect(int /* aSession */,
                                 const char * apVerb,
                                 const char * apServer,
                                 const char * apFileName,
                                 BOOL aKeepAlive, // = FALSE
                                 const char * apUserName, // = NULL
                                 const char * apPassword, // = NULL
                                 const char * apHeaders, // = NULL
                                 int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
                                 BOOL aSecure /* = FALSE */, 
                                 unsigned int timeout /* = 0 */, 
                                 unsigned int numretry /* = 0 */,
                                 const char * apProxy)
{
  //ASSERT(aSession);
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

  if ( mProxyServer != NULL ) delete mProxyServer;
  if ( mProxyCreds != NULL ) delete mProxyCreds;

  if(apProxy!=NULL){
    // Parse and validate proxy information
    // Acceptable formats:  http://username:password@servername:port
    //                      http://servername:port

    string proxy = apProxy;

    // look for http://
    int iHttp = proxy.find("http://",0);
    if ( iHttp != 0 ) {
      // FIXME need better error code
      SetError(MT_ERR_BAD_CONFIG, ERROR_MODULE, ERROR_LINE, "Connect (Proxy protocol specifier)");
      return FALSE;
    }

    // look for optional credentials
    int iEndCred = proxy.find("@",7);
    if ( iEndCred != string::npos && // found the '@'
         iEndCred > 7 ) {            // credentials not empty
      string temp = proxy.substr(7,iEndCred-7);
      mProxyCreds = new char[strlen(temp.c_str())+1];
      strcpy (mProxyCreds, temp.c_str()); // should contain a ':', not checking for it

    } else {
      mProxyCreds = NULL; 
      iEndCred = 6;
    }

    // look for server name and port
    int iEndSvr = proxy.find(":",iEndCred+1);
    if ( iEndSvr != string::npos &&  // found the ':'
         iEndSvr > iEndCred+1 &&     // servername not empty
         iEndSvr < proxy.size()-1) { // port not empty
      string temp = proxy.substr(iEndCred+1,iEndSvr-iEndCred-1);
      mProxyServer = new char[strlen(temp.c_str())+1];
      strcpy (mProxyServer, temp.c_str());
      temp = proxy.substr(iEndSvr+1,proxy.size()-iEndSvr-1);
      mProxyPort = atoi(temp.c_str());
      if ( mProxyPort <= 0 ) { 
        // FIXME need better error code
        SetError(MT_ERR_BAD_CONFIG, ERROR_MODULE, ERROR_LINE, "Connect (Proxy port number)");
        return FALSE;
      }

    } else {
      // FIXME need better error code
      SetError(MT_ERR_BAD_CONFIG, ERROR_MODULE, ERROR_LINE, "Connect (Proxy server name)");
      return FALSE;
    }
  
  } else {
    mProxyServer = NULL;
    mProxyCreds  = NULL; 
  }

  // keep this around in case we want to reconnect
  //mSession = aSession;

  if (aSecure)
  {
    if (mSSLContext == NULL)
    {
      mSSLContext = SSL_CTX_new(SSLv3_method());
    }
    if (mSSL != NULL)
    {
      SSL_free(mSSL);
    }

    mSSL = SSL_new(mSSLContext);

#ifdef USE_RSA_SSL
    SSL_set_connect_state(mSSL);
#endif
    mConnection = mtsocket_open_ssl(apServer, aPort, mSSL, timeout, numretry);

  } else {
    // open the connection
    // if proxy info has not been provided then open connection to metering server directly 
    if ( mProxyServer != NULL ) {
      mConnection = mtsocket_open(mProxyServer, mProxyPort, timeout, numretry);

    } else {  
      mConnection = mtsocket_open(apServer,aPort,timeout,numretry);
    }
  }

  if (mConnection < 0)
  {
    error = TRUE;
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Connect");
    return FALSE;
  }
  
  NET_LOG_DEBUG("mConnection = %lX", (DWORD) mConnection);


  // NOTE: this assumes OpenRequest sets the error
  return OpenRequest(apVerb, apServer, apFileName,
                     aKeepAlive, apUserName, apPassword, apHeaders,
                     aPort, aSecure);
}




BOOL
UnixNetStreamConnection::ReConnect(const char * apVerb,
                                    const char * apServer,
                                    const char * apFileName,
                                    BOOL aKeepAlive, // = FALSE
                                    const char * apUserName, // = NULL
                                    const char * apPassword, // = NULL
                                    const char * apHeaders, // = NULL
                                    int aPort /* = NetStream::DEFAULT_HTTP_PORT */,
                                    BOOL aSecure /* = FALSE */)
{
  // TODO: for now, we don't support Keep-Alive under Unix.  We always disconnect,
  //       then reconnect.

  assert(0); // should never get called

  //Close();
  // NOTE: this assumes the first argument isn't used..
  //return Connect(1, apVerb, apServer, apFileName, aKeepAlive, apUserName,
  //               apPassword, apHeaders, aPort, aSecure);
  return TRUE;
}



BOOL
UnixNetStreamConnection::OpenRequest(const char * apVerb,
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
  char  header[MT_UNIX_HTTP_LINESIZE];

  BOOL error = FALSE;

  // TODO: do the accept types have to be changed here?
  // TODO: flags should be different (especially for a secure connection)
  // TODO: could use HttpAddRequestHeaders before this call
  NET_LOG_DEBUG("HttpOpenRequest");


  mRequest = new UnixHttpRequest(apVerb, apServer, apFileName, mConnection,
                                 aSecure ? mSSL : NULL, mProxyServer != NULL);
  
  if (!mRequest)
    error = TRUE;

  NET_LOG_DEBUG("mRequest = %lX", (DWORD) mRequest);

  if(mProxyServer!=NULL)
    sprintf(header, "Host: %s",mProxyServer );
  else
    sprintf(header, "Host: %s",apServer);  

  mRequest->AddHeader(header);

  // add any user defined headers
  if (!error && apHeaders != NULL && mRequest->AddHeaders(apHeaders) <= 0)
    error = TRUE;

  // use authorization only if the user wants it
  if (strlen(apUserName) > 0 || strlen(apPassword) > 0)
  {
    // force the authentication by generating the string ourself
    // it will look like this:
    //  Authorization: Basic c2RrdGVzdDpzZGt0ZXN0
    // string auth;
    string auth;
    auth = "Authorization: Basic ";
    // now append username:password, base64 encoded
    char encodeBuffer[100];
    strcpy(encodeBuffer, apUserName);
    strcat(encodeBuffer, ":");
    strcat(encodeBuffer, apPassword);

    // encode
    // string encoded;
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
    mRequest->AddHeader(auth.c_str());

  }
  if(mProxyServer!=NULL){
    mRequest->AddHeader("Accept: */*");  //FIXME why?

    if ( mProxyCreds != NULL ) {
      string Pauth;
      Pauth = "Proxy-Authorization: Basic ";
      // now append username:password, base64 encoded
      char PencodeBuffer[100];
      strcpy(PencodeBuffer, mProxyCreds);

      // encode
      // string encoded;
      string Pencoded;
      if (!rfc1421encode((const unsigned char *) PencodeBuffer, strlen(PencodeBuffer), Pencoded))
      {
        // TODO: GetLastError won't do anything for this function
        // however, it should never fail
        ASSERT(0);
        error = TRUE;
      }

      // remove any trailing ='s, they're not needed
      int i = Pencoded.length() - 1;
      while (Pencoded[i] == '=')
        i--;

      Pauth.append(Pencoded.c_str(), i + 1);

      // set the header
      mRequest->AddHeader(Pauth.c_str());
    }
  }

  // TODO: do the flags have to be set differently?
  if (!error)
    NET_LOG_DEBUG("HttpSendRequestEx");

  // Send the request.
  if (!error && !mRequest->Send())
    error = TRUE;

  // TODO: do other options have to be set?
  if (error)
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Connect");
    return FALSE;
  }
  else
  {
    ClearError();
    return TRUE;
  }
}

// @cmember Retrieve an output stream that can be used to
// write across the net.
//  @parm optional buffer size.
//  @rdesc NULL if stream couldn't be created, otherwise an ostream.
#if 0
ostream *
UnixNetStreamConnection::GetOutputStream(int aBufferSize /* = 4096 */)
{
  NET_LOG_DEBUG("mOutputBuffer.Init()");
  if (!mOutputBuffer.Init(mRequest, aBufferSize))
  {
    SetError(mOutputBuffer.GetLastError());
    return NULL;
  }

  // use the ostream_withassign = operator
  mOStream = &mOutputBuffer;
  // don't delete the mOutputBuffer
#ifndef UNIX
  mOStream.delbuf(0);  // can't do it on solaris
#endif
  return &mOStream;
}


// @mfunc Retrieve an input stream that can be used to
// read across the net.
//  @parm optional buffer size.
//  @rdesc NULL if stream couldn't be created, otherwise an istream.
istream *
UnixNetStreamConnection::GetInputStream(int aBufferSize /* = 4096 */)
{
  // make sure all remaining bytes are gone, if the stream was ever used
  // (the stream won't have been initialized when doing a GET
  if (mOStream.rdbuf())
    mOStream.flush();

  BOOL error = FALSE;
  // sync has already been called
  NET_LOG_DEBUG("HttpEndRequest");
  
  // Note: win32 does HttpEndRequest here.  Not sure what that
  // call does.  At this point we've sent all the headers and
  // the body anyway.

  if (!error)
  {
    // retrieve the response code
    DWORD response;
    DWORD dwSize = sizeof(response);
    if (mRequest->ReadResponse((int *)&response, (int *)&dwSize) < 0)
      error = TRUE;
    else
      // allow user to retrieve it
      SetResponse(HttpResponse((int) response));
  }

  if (error)
  {
    // error already set by ReadResponse()
    return NULL;
  }

  if (!mInputBuffer.Init(mRequest, aBufferSize))
  {
    SetError(mInputBuffer.GetLastError());
    return NULL;
  }

  // use the ostream_withassign = operator
  mIStream = &mInputBuffer;

  // don't delete the mOutputBuffer
#ifndef UNIX
  mOStream.delbuf(0);  // can't do this on solaris
#endif

  ClearError();
  return &mIStream;
}


#endif

int UnixNetStreamConnection::EndRequest()
{
  // Note: win32 does HttpEndRequest here.  Not sure what that
  // call does.  At this point we've sent all the headers and
  // the body anyway.

  // retrieve the response code
  BOOL error = FALSE;
  DWORD response;
  DWORD dwSize = sizeof(response);
  if (mRequest->ReadResponse((int *)&response, (int *)&dwSize) < 0)
    error = TRUE;
  else
  {
    // only set the content length if a Content-Length header was received
    if (dwSize != -1) {
      SetContentLength(dwSize);
    }

    // allow user to retrieve it
    SetResponse(HttpResponse((int) response));
  }

  if (error)
  {
    // error already set by ReadResponse()
    return NULL;
  }

  return TRUE;
}

int UnixNetStreamConnection::ReceiveBytes(char * apBuffer, int aLen, int * apLenRead)
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

  // NOTE: if TRUE is returned and size == 0, that means EOF
  size = 0;

  // the netstream isn't really interested in reading how much is available to read.
  // i.e. it's not asking for content_length.
  // so we'll just read what we can and tell how much we did.
  // The mRequest is smart enough not to read more than content_length
  size = mRequest->ReadData((unsigned char *)apBuffer, aLen);

  *apLenRead = size;
  AddBytesProcessed(size);
  return (size >= 0);
}

int UnixNetStreamConnection::SendBytes(const char * apBuffer, int aLen)
{
  DWORD size = mRequest->WriteData((const unsigned char *)apBuffer, aLen);

  if (size != (DWORD) aLen)
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Consume");
    return FALSE;
  }

  ClearError();

  return TRUE;
}


// @cmember close the connection to the net
void UnixNetStreamConnection::Close()
{
  // close the request and the connection
  // TODO: is it OK to use this order if the first one fails
  // and the second succeeds?
  BOOL error = FALSE;

  if (mRequest)
  {
    NET_LOG_DEBUG("InternetCloseHandle(mRequest)");
    delete mRequest;
    mRequest = NULL;
  }

  if (mConnection)
  {
    NET_LOG_DEBUG("InternetCloseHandle(mConnection)");
    if (mConnection >= 0)
    {
      mtsocket_close(mConnection);
      mConnection = -1;
    }
  }

  if (mSSL != NULL)
  {
    SSL_free(mSSL);
    mSSL = NULL;
  }

  if (mSSLContext != NULL)
  {
    SSL_CTX_free(mSSLContext);
    mSSLContext = NULL;
  }

  if ( mProxyServer != NULL ) {
    delete mProxyServer;
    mProxyServer = NULL;
  }

  if ( mProxyCreds != NULL ) {
    delete mProxyCreds;
    mProxyCreds = NULL;
  }

  if (error)
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Close");
  }
}


/********************************************** UnixNetStreamBuf ***/

// @mfunc Constructor.  You must call Init as well.
// @parm Buffer mode
//  @flag ios::out | An output stream
//  @flag ios::in  | An input stream
#if 0
UnixNetStreamBuf::UnixNetStreamBuf(ios::open_mode m) :
  NetStreamBuf(m)
{
  mRequest = NULL;
  mBuffer = NULL;
  mBufferLen = 0;
}


// @mfunc Destructor
UnixNetStreamBuf::~UnixNetStreamBuf()
{
  // write any remaining bytes
  sync();

  // free mRequestHeaders

  // free mResponseHeaders

  // delete the buffer if it was allocated
  if (mBuffer)
    delete [] mBuffer;
}


// @mfunc Initialize the buffers.  Must be used before any I/O is done.
BOOL UnixNetStreamBuf::Init(UnixHttpRequest *aRequest, int aBufferLen)
{
  ASSERT(aRequest);

  mRequest = aRequest;

  // allocate a buffer of the given size
  // TODO: if the buffer is the same size we don't need to reinitialize it
  if (mBuffer)
    delete [] mBuffer;

  mBuffer = new char[aBufferLen];

  setbuf(mBuffer, aBufferLen);
  ClearError();
  return TRUE;
}


// @mfunc
// Called to send bytes across the net.
//  @parm beginning of buffer.
//  @parm buffer length.
//  @rdesc TRUE if function succeeds
BOOL UnixNetStreamBuf::Consume(const char * apBuffer, int aLen)
{
  DWORD size = 0;
  
  NET_LOG_DEBUG("InternetWriteFile(mRequest)");

  // TODO: temporary
  //const char * apTail = apBuffer + aLen - 7;

  size = mRequest->WriteData((const unsigned char *)apBuffer, aLen);

  if (size != (DWORD) aLen)
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Consume");
    return FALSE;
  }

  ClearError();
  return TRUE;
}

// @mfunc
// Called to read bytes from the net.
//  @parm beginning of buffer.
//  @parm buffer length.
//  @parm pointer to int returning true length read.
//  @rdesc TRUE if function succeeds
BOOL UnixNetStreamBuf::Produce(char * apBuffer, int aLen,
                               int * apLenRead)
{
  // NOTE: if TRUE is returned and size == 0, that means EOF
  DWORD size = 0;
  NET_LOG_DEBUG("InternetReadFile(mRequest)");

  // the netstream isn't really interested in reading how much is available to read.
  // i.e. it's not asking for content_length.
  // so we'll just read what we can and tell how much we did.
  // The mRequest is smart enough not to read more than content_length
  size = mRequest->ReadData((unsigned char *)apBuffer, aLen);
  if (size <= 0) 
  {
    *apLenRead = 0;
    SetError(errno, ERROR_MODULE, ERROR_LINE, "Produce");
    return FALSE;
  }

  *apLenRead = size;
  return (size > 0);
}
#endif

/*
 * Constructor for HTTP unix class
 */
UnixHttpRequest::UnixHttpRequest(const char *apVerb,
                                 const char *apServer,
                                 const char *apResource,
                                 int iSocket,
                                 SSL *aSSL,
                                 BOOL aUseProxy)
{
  assert(apVerb != NULL);
  assert(apServer != NULL);
  assert(apResource != NULL);

  mRequestHeaderCount = 0;
  mResponseHeaderCount = 0;
  mContentLength = -1;
  mStatus = -1;

  mState = MT_UNIX_HTTP_STATE_INIT;
  
  mSocket = iSocket;
  mSSL = aSSL;
  strcpy(mVerb, apVerb);
  strcpy(mServer, apServer);
  strcpy(mResource, apResource);

  mUseProxy = aUseProxy;
}

BOOL UnixHttpRequest::Send(void)
{
  char line[MT_UNIX_HTTP_LINESIZE + 1];
  int n, i;

  assert(mSocket >= 0);
  if ( mUseProxy ) {
    assert(mSSL == NULL); // no SSL with proxy
    sprintf(line, "%s http://%s%s HTTP/1.1\r\n", mVerb, mServer, mResource);
  } else {
    sprintf(line, "%s %s HTTP/1.1\r\n", mVerb, mResource);
  }
  i = strlen(line);
  if (mSSL != NULL) {
    n = SSL_write(mSSL, (char *)line, i);
    if (n < i)
    {
      //unsigned long e = SSL_get_error(mSSL, n);
      // FIXME need to handle the case where SSL_get_error(mSSL,n) != SSL_ERROR_SSL
      unsigned long e = ERR_get_error();
      char foo[256];
      ERR_error_string(e, foo);
      
      fprintf(stderr, "SSL error: %s\n", foo);

      if (ERR_lib_error_string(e)) fprintf(stderr, "Lib:    %s\n", ERR_lib_error_string(e));
      if (ERR_func_error_string(e)) fprintf(stderr, "Func:   %s\n", ERR_func_error_string(e));
      if (ERR_reason_error_string(e)) fprintf(stderr, "Reason: %s\n", ERR_reason_error_string(e));

      SetError(errno, ERROR_MODULE, ERROR_LINE, "UnixHttpRequest::Send");
      return FALSE;
    }
  } else {
    n = mtsocket_write(mSocket, (const unsigned char *)line, i);
    if (n < i)
    {
      SetError(errno, ERROR_MODULE, ERROR_LINE, "UnixHttpRequest::Send");
      return FALSE;
    }
  }
  for (i = 0; i < mRequestHeaderCount; i++)
  {
    sprintf(line, "%s\r\n", mRequestHeaders[i]);
    if (mSSL != NULL)
      n = SSL_write(mSSL, (char *)line, strlen(line));
    else 
      n = mtsocket_write(mSocket, (const unsigned char *)line, strlen(line));
    if (n < strlen(line))
    {
      SetError(errno, ERROR_MODULE, ERROR_LINE, "UnixHttpRequest::Send");
      return FALSE;
    }
  }
    
  sprintf(line, "\r\n");
  if (mSSL != NULL)
    n = SSL_write(mSSL, (char *)line, strlen(line));
  else 
    n = mtsocket_write(mSocket, (const unsigned char *)line, strlen(line));
  if (n < strlen(line))
  {
    SetError(errno, ERROR_MODULE, ERROR_LINE, "UnixHttpRequest::Send");
    return FALSE;
  }
  mState = MT_UNIX_HTTP_STATE_SENT_HEADERS;


  return TRUE;
}

int UnixHttpRequest::ReadLine(char *line, int len)
{
  unsigned char *ptr = (unsigned char *)line;
  int         n;

  assert(len > 0);
  assert(len <= MT_UNIX_HTTP_LINESIZE);
  assert(mSocket >= 0);

  if (mSSL != NULL)
    n = SSL_read(mSSL, (char *)ptr, 1);
  else 
    n = mtsocket_read(mSocket, ptr, 1);
  
  while ((n > 0) && (*ptr != '\n') && (*ptr != '\r') && (n < len))
  {
    if (mSSL != NULL)
      n = SSL_read(mSSL, (char *)++ptr, 1);
    else 
      n = mtsocket_read(mSocket, ++ptr, 1);
  }
  if (n == 0)
  {
    // indicates EOF before EOL
    SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, 
             "UnixHttpRequest::ReadLine");
    *ptr = 0x00;
    return -1;
  }

  if (*ptr == '\r')
  {   
    if (mSSL != NULL)
      n = SSL_read(mSSL, (char *)++ptr, 1);
    else 
      n = mtsocket_read(mSocket, ++ptr, 1);
    if ((n != 1) || (*ptr != '\n'))
    {       
      // CR with out LF is bad
      SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, 
               "UnixHttpRequest::ReadLine");
      return -1;
    }
  }
  if (*ptr != '\n')
  {   
    // line too long
    SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, 
             "UnixHttpRequest::ReadLine");
    *(++ptr) = 0x00;
  } else {
    *ptr = 0x00;
  }
  return (ptr - (unsigned char *)line);

}


int UnixHttpRequest::ReadResponse(int *status, 
                                  int *content_len)
{
  char line [MT_UNIX_HTTP_LINESIZE + 1];
  char temp [MT_UNIX_HTTP_LINESIZE + 1];
  int   n;

  assert(mSocket >= 0);
  assert (mState != MT_UNIX_HTTP_STATE_INIT);

  if (mState == MT_UNIX_HTTP_STATE_SENT)
  {
    // read status/headers the first time.

    n = ReadLine(line, MT_UNIX_HTTP_LINESIZE); // get the status line
    
    if (n <= 0)
    {
      SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, 
               "UnixHttpRequest::ReadResponse");
      *status = -1;
      *content_len = -1;
      return -1;
    }
    if (!strncmp(line, "HTTP/1.1 100", 12))
    {   
      // skip any HTTP continue headers 
      while ((n = ReadLine(line, MT_UNIX_HTTP_LINESIZE)) > 1);
     
      // skip blank lines
      while ((n = ReadLine(line, MT_UNIX_HTTP_LINESIZE)) <= 1);
    }
      
    if (strncmp(line, "HTTP/", 5))
    {   
      *status = -1;
      *content_len = -1;
      return(-1); 
    }
    sscanf(line, "%s %d", temp, status);
    
    mStatus = *status;

    /* > 1 because last header is a CR/LF, which gets read as 1 */
    while ((n = ReadLine(line, MT_UNIX_HTTP_LINESIZE)) > 1)
    { 
      if (!strncasecmp(line, "Content-length:", strlen("Content-length")))
      {       
        mContentRemaining = mContentLength = *content_len = 
          atoi (line + strlen("Content-length: "));
      }
      mResponseHeaders[mResponseHeaderCount] = (char *)malloc(n);
      strcpy(mResponseHeaders[mResponseHeaderCount], line);
      mResponseHeaderCount++;
    }

    if (n < 0)
    {
      SetError(MT_ERR_BAD_HTTP_RESPONSE, ERROR_MODULE, ERROR_LINE, 
               "UnixHttpRequest::ReadResponse");
      return -1;
    }
  }

  *status = mStatus;
  *content_len = mContentLength;
    
  mState = MT_UNIX_HTTP_STATE_READ_HEADERS;

  return mResponseHeaderCount;
}

int UnixHttpRequest::WriteData(const unsigned char *buffer, int buffer_size)
{
  int   remaining = buffer_size;
  const unsigned char *ptr = buffer;
  int   n;
  
  while (remaining > 0)
  {
    if (mSSL != NULL)
      n = SSL_write(mSSL, (char *)ptr, remaining);
    else 
      n = mtsocket_write(mSocket, ptr, remaining);
    if (n > 0) 
    {
      remaining -= n;
      ptr += n;
    } else {
      break;
    }
  }

  mState = MT_UNIX_HTTP_STATE_SENT;

  return buffer_size - remaining;
}

int UnixHttpRequest::ReadData(unsigned char *buffer, int buffer_size)
{
  unsigned char *ptr = buffer;
  assert(mSocket >= 0);
  assert(buffer != NULL);
  assert(buffer_size > 0);
  assert((mState == MT_UNIX_HTTP_STATE_READ_HEADERS) ||
         (mState == MT_UNIX_HTTP_STATE_READING_CONTENT));


  mState = MT_UNIX_HTTP_STATE_READING_CONTENT;

#if 0
  // never let the high level code try to read more than Content-Length:
  if (buffer_size > mContentRemaining)
  {
    buffer_size = mContentRemaining;
  }
#else
  // the metra tech server doesn't return the content lenghth! (Bogus!)
  
#endif

  int   remaining = buffer_size;

  while (remaining > 0)
  {
    int n;
    if (mSSL != NULL)
      n = SSL_read(mSSL, (char *)ptr, remaining);
    else 
      n = mtsocket_read(mSocket, ptr, remaining);

    if (n > 0)
    {
      remaining -= n;
      mContentRemaining -= n;
      ptr += n;
    } else {
      break;
    }
  }

  return buffer_size - remaining;
}

UnixHttpRequest::~UnixHttpRequest()
{

  return;
}

int UnixHttpRequest::AddHeader(const char *header)
{
  mRequestHeaders[mRequestHeaderCount] = (char *)malloc(strlen(header) + 1);
 
  strcpy(mRequestHeaders[mRequestHeaderCount], header);
 
  return ++mRequestHeaderCount;
}  

int UnixHttpRequest::AddHeaders(const char *headers)
{
  // break up the headers and store them with AddHeader.
  char line[MT_UNIX_HTTP_LINESIZE + 1];
  const char *inptr = headers;
  char *outptr = line;
  int  n = 0;

  while (*inptr)
  {
    switch (*inptr)
    {
    case '\r':
      assert(*++inptr == '\n');
    case '\n':
      *outptr = 0x00;
      mRequestHeaders[mRequestHeaderCount] = (char *)malloc(outptr - line + 1);
      strcpy(mRequestHeaders[mRequestHeaderCount], line);
      outptr = line;
      mRequestHeaderCount++;
      n++;
      inptr++;
      break;
    default:
      *outptr++ = *inptr++;
      break;
    }
  }

  return n;
}  
  












