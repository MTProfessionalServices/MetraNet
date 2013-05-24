/**************************************************************************
 * @doc ISAPI
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
// disable warning...Variable is being referneced.
#pragma warning(disable:4101)

#include <metra.h>
#include <mtcom.h>
#include <tchar.h>
#include <httpext.h>

#import "MTConfigLib.tlb"
using namespace MTConfigLib;

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping
using namespace MTConfigLib;

#include <SharedDefs.h>
#include <handler.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <NTLogMacros.h>
#include <autocritical.h>
#include <errobj.h>
#include <listener_msg.h>
#include <ConfigDir.h>
#include <makeunique.h>
#include <multiinstance.h>
#include <mtzlib.h>

#include "listener.h"
#include "asserthelper.h"

LPBYTE GetPostData(EXTENSION_CONTROL_BLOCK *pecb, BOOL fNullTerminate);
BOOL IsZipped(EXTENSION_CONTROL_BLOCK *ecb, unsigned long &uncompressedMessageLen);
char * GetMessage(EXTENSION_CONTROL_BLOCK *ecb);


//
// to turn on keep-alive, uncomment the USE_CONTENT_LENGTH and USE_KEEP_ALIVE together
//
// NOTE: turning on keep-alive should wait until IIS5 - otherwise Nagle's algorithm
// reduced metering rate to 5/sec (200ms delay)
//#define USE_CONTENT_LENGTH
//#define USE_KEEP_ALIVE


//////////////////////////////////////////////////////////////////////
// globals
//////////////////////////////////////////////////////////////////////

static MeterHandler * gHandler = NULL;
#ifdef _DEBUG
static ListenerAssertHelper g_AssertHelper;
#endif
static MTListenerStrings* g_Listenerstrings = NULL;

static BOOL gInitialized = FALSE;

static const char* g_DATE = __DATE__;
static const char* g_TIME = __TIME__;
static const char* g_TIMESTAMP = __TIMESTAMP__;

//////////////////////////////////////////////////////////////////////
//MTListenerStrings section
//////////////////////////////////////////////////////////////////////

// cleanup

MTListenerStrings::~MTListenerStrings()
{  
	Message::FreeMessageModules();
}

// Initstrings load all the resource strings from the message library.
// we want to prefetch the strings instead of loading from the resource
// dll every time we need a string.


BOOL MTListenerStrings::InitStrings()
{
	BOOL bRetVal = FALSE;
	// step 1: load the message library
	std::string aModuleName;
	GetModuleName(aModuleName);

	// step 2: load all strings
	if(Message::AddModule(aModuleName.c_str())) {
		// the message library was loaded
		for(int i=MT_LISTENER_MSG_BEGIN + 1;i <MT_LISTENER_MSG_END_NON_INSERTS;i++) {
			
			Message aMessage(i);
			std::string pString;
			string msgString;
			// passing true to GetErrorMessage will strip CRLF from the end of the string
			aMessage.GetErrorMessage(msgString,true);
			pString = msgString.c_str();
			ASSERT(!(pString == _T("")));

			m_vector.push_back(pString);
		}
		m_bInited = true;
		bRetVal = TRUE;
	}
	else {
		// this shouldn't happen if the software is configured correctly.
		// If it happens in release, we will return FALSE
		//ASSERT(!"Failed to load message library");
		bRetVal = false;
	}
	return bRetVal;
}

// GetString returns a reference to a resource string

const std::string& MTListenerStrings::GetString(const unsigned int id)
{
	ASSERT(MT_LISTENER_MSG_BEGIN < id && id < MT_LISTENER_MSG_END_NON_INSERTS);
	// must use GET_MSG_ID(id)-1 because we ignore the beginning tag
	std::string& msg = m_vector[GET_MSG_ID(id)-1];
	ASSERT(!(msg == _T("")));
	return msg;
}

// return the path and name of the resource dll.  This needs
// to be superceded by a more comprehensive mechanism

void MTListenerStrings::GetModuleName(std::string& aModuleName)
{
	char buff[MAX_PATH];
	const char* mname = "listener.dll";
	HMODULE  aHandle = ::GetModuleHandle(mname);
	if(aHandle != NULL) {
		::GetModuleFileName(aHandle,buff,MAX_PATH);
		buff[strlen(buff) - strlen(mname)] = '\0';
		aModuleName = buff;
		aModuleName += LISTENER_MSG_MODULE;
	}
}

// preformats the badrequesthead string. This is done
// as a seperate method because of the debug / release
// conditional code.

const std::string& MTListenerStrings::GetBadRequestHead()
{
	if(m_BadRequestHead == _T("")) {
		ASSERT(m_bInited);
#ifdef _DEBUG
		Message aMessage(MT_LISTENER_BAD_REQUEST_HEAD_DEBUG);
#else
		Message aMessage(MT_LISTENER_BAD_REQUEST_HEAD_RELEASE);
#endif
		string msgString;
		char pidBuffer[100];
		int pid = ::GetCurrentProcessId();
		aMessage.FormatErrorMessage(msgString,true,
			_itoa(pid, pidBuffer, 10), g_DATE,g_TIME,g_TIMESTAMP);
		m_BadRequestHead = msgString.c_str();
	}
	return m_BadRequestHead;
}


#ifdef _DEBUG

//////////////////////////////////////////////////////////////////////
// ListenerAssertHelper section
//////////////////////////////////////////////////////////////////////

int ListenerAssertHelper::HandleAssert(std::string& aMessage ,ErrorObject& aError) 
{

	aMessage = g_Listenerstrings->GetBadRequestHead();
	aMessage += "<br><pre>";
	aMessage += aError.GetProgrammerDetail().c_str();
	aMessage += "</pre></body></html";
	return HSE_STATUS_SUCCESS;
}
#endif




//////////////////////////////////////////////////////////////////////
// ISAPI Extension methods
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// DLL Main
//////////////////////////////////////////////////////////////////////


///MTListenerPerf * myperf = NULL;

BOOL WINAPI DllMain(IN HINSTANCE hinstDll,IN DWORD dwReason,IN LPVOID lpvContext)
{
	BOOL bRetVal = TRUE;

	try {

		switch(dwReason)
		{
		case DLL_PROCESS_ATTACH:
			// initialize the assert handling code.  _CRTDBG_MODE_DEBUG means 
			// log all asserts to the Debug console (instead of a window).  
			// LISTENER_TAG is for the NTlogger.
			ASSERT_HELPER_FUNC(g_AssertHelper,Init(_CRTDBG_MODE_DEBUG,LISTENER_TAG));
			break;
		case DLL_PROCESS_DETACH:
			break;
		}
	}
#ifdef _DEBUG
	catch(ErrorObject&) {
		// we caught an assert.  it will allready be logged
		bRetVal = FALSE;
	}
#endif
	catch(...) {
		bRetVal = FALSE;
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG,_T("Unknown exception caught in ") ERROR_MODULE);
#ifdef _DEBUG
		throw;
#endif
	}

	return bRetVal;
}



//////////////////////////////////////////////////////////////////////
// Initialize
// 
// Initializes the module.  Called by GetExtensionVersion
//////////////////////////////////////////////////////////////////////

BOOL WINAPI Initialize()
{
	NTLogger logger;
	LoggerConfigReader loggerConfigReader;
	logger.Init(loggerConfigReader.ReadConfiguration(LISTENER_STR), LISTENER_TAG);

	logger.LogThis(LOG_INFO, "Initializing listener...");

	// loads the message files
	ASSERT(!g_Listenerstrings);
	g_Listenerstrings = new MTListenerStrings();
	if(!g_Listenerstrings->InitStrings())
	{
		logger.LogThis(LOG_FATAL, "InitStrings failed!");
		return FALSE;
	}

	try 
	{
		// initializes the library that talks to the pipeline
		ASSERT(!gHandler);
		gHandler = new MeterHandler();
		if (!gHandler->Init(CompletionHook))
		{
			logger.LogThis(LOG_FATAL, "MeterHandler::Init failed!");
			logger.LogErrorObject(LOG_FATAL, gHandler->GetLastError());
			return FALSE;
		}

		logger.LogThis(LOG_INFO, "Listener successfully initialized");
		return TRUE;
	}
	catch(ErrorObject&) 
	{
		// we caught an assert.  it will allready be logged
	}
	catch(_com_error&) 
	{
		logger.LogThis(LOG_FATAL, _T("_com_error exception caught in ") ERROR_MODULE _T(" Initialize\n"));
	}
	catch(...) 
	{
		logger.LogThis(LOG_FATAL, _T("Unknown exception caught in ") ERROR_MODULE _T(" Initialize\n"));
#ifdef _DEBUG
		throw;
#endif
	}

	logger.LogThis(LOG_FATAL, "Listener initialization failed!");
	return FALSE;
}


//////////////////////////////////////////////////////////////////////
// GetExtensionVersion
//
// Purpose:
//
//    The first function called after IIS successfully 
//    loads the DLL.  The function should use the 
//    version structure provided by IIS to set the ISAPI
//    architectural version number of this extension.
//
//    A simple text-string is also set so that 
//    administrators can identify the DLL.
//
//    Note that HSE_VERSION_MINOR and HSE_VERSION_MAJOR
//    are constants defined in httpext.h.
//////////////////////////////////////////////////////////////////////


BOOL WINAPI GetExtensionVersion(OUT HSE_VERSION_INFO * pVer)
{
	BOOL success = Initialize();
	if (!success)
		return FALSE;

	pVer->dwExtensionVersion = MAKELONG(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);

	// get the name of the extension from the resource file
	strcpy(pVer->lpszExtensionDesc,g_Listenerstrings->GetString(MT_LISTENER_EXTENSION_NAME).c_str());

	return TRUE;
}


//////////////////////////////////////////////////////////////////////
//HttpExtensionProc
//
// Purpose:    
//
//    Function called by the IIS Server when a request 
//    for the ISAPI dll arrives.  The HttpExtensionProc                  
//    function processes the request and outputs the
//    appropriate response to the web client using
//    WriteClient().
//////////////////////////////////////////////////////////////////////

#define MSIX_CONTENT_TYPE "application/x-metratech-xml"
#define MSIX_BATCH_CONTENT_TYPE "application/x-metratech-xml-batch"
#define XML_CONTENT_TYPE "text/xml"

#pragma warning( disable : 4297 ) // disable throw specification warning (we only throw in debug builds)
DWORD WINAPI HttpExtensionProc(IN EXTENSION_CONTROL_BLOCK * pECB)
{
	// NOTE: starting with IIS 4.0, we do not need to return
	// HSE_STATUS_SUCCESS_AND_KEEP_CONN if we have specified 
	// keep alive.

	DWORD Retval = HSE_STATUS_SUCCESS;
	std::string outMessageBuffer;

  // what's our output message
	const char * outputMessage = "<HTML><HEAD><TITLE>Unhandled Exception</TITLE></HEAD><BODY>Unhandled Exception</BODY></HTML>";
  // what's our output status
	const char * outputStatus = "400 Bad Request"; 		
  // what's out output content type
	const char * outputContentType = "text/html"; 	

	// output from the MSIX handler
	std::string msixOutput;

	BOOL completeImmediately = TRUE;
	try {

		bool isPost     = strcmp(pECB->lpszMethod, g_Listenerstrings->GetString(MT_LISTENER_HTTP_POST).c_str()) == 0;
		bool isMSIX     = ((strcmp(pECB->lpszContentType, MSIX_CONTENT_TYPE) == 0) || 
											 (strcmp(pECB->lpszContentType, XML_CONTENT_TYPE) == 0));  // TODO: who sends this?

		// checks that the request is valid:
		//   - the method must be POST and
		//   - the content type must be MSIX
		bool validRequest = isPost && isMSIX;

		if (validRequest)
		{
			// retrieves and potentially decodes the POST data
			char * message = GetMessage(pECB);

			// parse it!
			if (gHandler->HandleStream(message, msixOutput, FALSE, completeImmediately, pECB))
			{
				outputMessage = msixOutput.c_str();
				outputStatus = g_Listenerstrings->GetString(MT_LISTENER_GOOD_REQUEST).c_str();
				outputContentType = g_Listenerstrings->GetString(MT_LISTENER_CONTENT_TYPE).c_str();
			}
			else
				validRequest = false;

			delete [] message;
		}

		// reports any bad requests back to the user
		if (!validRequest)
		{
			outMessageBuffer = g_Listenerstrings->GetBadRequestHead();
			outMessageBuffer += (const char *) g_Listenerstrings->GetString(MT_LISTENER_BAD_REQUST_TAIL).c_str();
			outputMessage = outMessageBuffer.c_str();
			
			outputStatus = g_Listenerstrings->GetString(MT_LISTENER_BAD_REQUST).c_str();
			outputContentType = g_Listenerstrings->GetString(MT_LISTENER_HTML_CONTENT_TYPE).c_str();
		}
	} // end try
#ifdef _DEBUG
	catch(ErrorObject& aError) {
		// we caught an assert.
		Retval = ListenerAssertHelper::HandleAssert(outMessageBuffer,aError);
		outputMessage = outMessageBuffer.c_str();
		outputStatus = g_Listenerstrings->GetString(MT_LISTENER_BAD_REQUST).c_str();
		outputContentType = g_Listenerstrings->GetString(MT_LISTENER_HTML_CONTENT_TYPE).c_str();
	}
#else
	catch(ErrorObject&) {
		Retval = HSE_STATUS_ERROR;
	}
#endif
  catch(std::exception & e) 
	{
    NTLogger myLogger ;
    LoggerConfigReader cfgRdr ; 
    myLogger.Init(cfgRdr.ReadConfiguration(LISTENER_STR), LISTENER_TAG) ; 
    myLogger.LogThis (LOG_ERROR, _T("Standard exception caught in ") ERROR_MODULE _T(" HttpExtensionProc\n")) ;
    try
    {
      myLogger.LogVarArgs (LOG_ERROR, "Exception type: %s; Message: %s", 
                           typeid(e).name(), 
                           e.what() != NULL ? e.what() : "<no exception message>");
    }
    catch(...)
    {
      myLogger.LogThis (LOG_ERROR, _T(e.what() != NULL ? e.what() : "<no exception message>"));
    }
    Retval = HSE_STATUS_ERROR;
	}
	catch(...) 
	{
    NTLogger myLogger ;
    LoggerConfigReader cfgRdr ; 
    myLogger.Init(cfgRdr.ReadConfiguration(LISTENER_STR), LISTENER_TAG) ; 
    myLogger.LogThis (LOG_ERROR, _T("Unknown exception caught in ") ERROR_MODULE _T(" HttpExtensionProc\n")) ;
		Retval = HSE_STATUS_ERROR;
#ifdef _DEBUG
		throw;
#endif
	}

	if (completeImmediately)
	{
		CompleteRequest(pECB, outputMessage, outputStatus, outputContentType);
		return Retval;
	}
	else
		return HSE_STATUS_PENDING;
}

void CompletionHook(const char * apUID, const char * apMessage, void * apArg)
{
	EXTENSION_CONTROL_BLOCK * ecb = (EXTENSION_CONTROL_BLOCK *) apArg;

	const char * outputStatus = g_Listenerstrings->GetString(MT_LISTENER_GOOD_REQUEST).c_str();
	const char * outputContentType = g_Listenerstrings->GetString(MT_LISTENER_CONTENT_TYPE).c_str();

	CompleteRequest(ecb, apMessage, outputStatus, outputContentType);
}




void CompleteRequest(EXTENSION_CONTROL_BLOCK * apECB,
										 const char * apOutputMessage,
										 const char * apOutputStatus,
										 const char * apOutputContentType)
{
	//
	// prepare headers 
	//

	HSE_SEND_HEADER_EX_INFO HeaderExInfo;
	HeaderExInfo.pszStatus = apOutputStatus;
	HeaderExInfo.cchStatus = strlen(HeaderExInfo.pszStatus);

	string headerString;

#ifdef USE_CONTENT_LENGTH
	Message aMessage(MT_LISTENER_CONTENT_TYPE_STR__WITH_LENGTH);
	aMessage.FormatErrorMessage(headerString,true,strlen(apOutputMessage),
					 apOutputContentType);
#else
	Message aMessage(MT_LISTENER_CONTENT_TYPE_STR);
	aMessage.FormatErrorMessage(headerString,true,apOutputContentType);
#endif
	headerString += "\r\n";

	HeaderExInfo.pszHeader = headerString.c_str();
	HeaderExInfo.cchHeader = strlen(HeaderExInfo.pszHeader);

#ifdef USE_KEEP_ALIVE
	HeaderExInfo.fKeepConn = TRUE;
#else
	HeaderExInfo.fKeepConn = FALSE;
#endif

	//
	// send headers using IIS-provided callback
	// (note - if we needed to keep connection open,
	//  we would set fKeepConn to TRUE *and* we would
	//  need to provide correct Content-Length: header)

	apECB->ServerSupportFunction(
		apECB->ConnID,
		HSE_REQ_SEND_RESPONSE_HEADER_EX,
		&HeaderExInfo,
		NULL,
		NULL);

	// Calculate length of string to output to client
	DWORD dwBytesToWrite = strlen(apOutputMessage);

	// send text using IIS-provided callback
	apECB->WriteClient(apECB->ConnID, (void *) apOutputMessage, &dwBytesToWrite, HSE_IO_SYNC);

	DWORD dwState = HSE_STATUS_SUCCESS;
	apECB->ServerSupportFunction(apECB->ConnID,
															 HSE_REQ_DONE_WITH_SESSION, &dwState, NULL, 0);
}


//////////////////////////////////////////////////////////////////////
//TerminateExtension
//
//	This function is called when the WWW service is shutdown
//
//  according to the MSDN docs:
//
//  "Since TerminateExtension is never called by IIS until all 
//  outstanding requests have been processed, it is not necessary to
//  include code to wait for outstanding requests within TerminateExtension."
//////////////////////////////////////////////////////////////////////

BOOL WINAPI TerminateExtension(IN DWORD dwFlags)
{
	NTLogger logger;
	LoggerConfigReader loggerConfigReader;
	logger.Init(loggerConfigReader.ReadConfiguration(LISTENER_STR), LISTENER_TAG);
	logger.LogThis(LOG_INFO, "Shutting down listener...");

	try
	{
		if (gHandler)
		{
			delete gHandler;
			gHandler = NULL;
		}
		
		if (g_Listenerstrings)
			delete g_Listenerstrings;
		
		logger.LogThis(LOG_INFO, "Listener successfully shutdown");
		
		return TRUE;
	}
	catch(std::exception & ex) 
	{
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG, _T(ex.what()));
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG, _T("Standard exception caught while shutting down Listener!"));
	}
	catch(_com_error & e) 
	{
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG, _T((const char *) e.Description()));
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG, _T("COM exception caught while shutting down Listener!"));
	}
	catch(...) 
	{
		MT_LOG_FATAL_STRING(LISTENER_STR,LISTENER_TAG, _T("Unknown exception caught while shutting down Listener!"));
	}

	return FALSE;
}


//////////////////////////////////////////////////////////////////////
//GetPostData
//
// Description:
//
//  This function returns a pointer to a buffer containing the complete POST
//  data sent by the client.  The caller is responsible for deleting the
//  buffer when it's no longer needed.
//
//  Arguments:
//
//  pecb - Pointer to the extension control block for the request
//  fNullTerminate - If this is true, then allocate an extra byte to the
//  buffer and set it to NULL.
//
// from -Wade Hilmo, Microsoft, on DejaNews
//////////////////////////////////////////////////////////////////////
LPBYTE GetPostData(
    EXTENSION_CONTROL_BLOCK *pecb,
    BOOL fNullTerminate
    )
{
	LPBYTE pbRet;
	DWORD dwBytesCopied, dwBytesRemaining, dwBuffSize;
	BOOL bRet;

	//
	// Allocate a buffer for the POST data
	//

	if (fNullTerminate)
		pbRet = new BYTE[pecb->cbTotalBytes + 2];
	else
		pbRet = new BYTE[pecb->cbTotalBytes];

	if (!pbRet)
		return FALSE;

	//
	// Copy what data we already have to the buffer.  If there's
	// no more data, return.
	//

	CopyMemory(pbRet, pecb->lpbData, pecb->cbAvailable);

	if (pecb->cbAvailable == pecb->cbTotalBytes)
	{
		if (fNullTerminate) {
			pbRet[pecb->cbTotalBytes] = 0;
			pbRet[pecb->cbTotalBytes+1] = 0;
		}

		return pbRet;
	}

	//
	// Use ReadClient to get the remaining data
	//

	dwBytesCopied = pecb->cbAvailable;

	while (dwBytesCopied < pecb->cbTotalBytes)
	{
		dwBytesRemaining = pecb->cbTotalBytes - dwBytesCopied;

		dwBuffSize = dwBytesRemaining;

		bRet = pecb->ReadClient(pecb->ConnID,
														pbRet + dwBytesCopied,
														&dwBuffSize);
		if (!bRet)
		{
			// For some reason ReadClient fails instantaneously on the first call for large requests (>85mb)
			// It fails with error code 10054 ("An existing connection was forcibly 
			// closed by the remote host.") However, there is no evidence of the connection
			// being closed. To solve this, gzip content encoding has been introduced into
			// the SDK and Listener. Typically compression ratios are > 90%. This pushes
			// the ReadClient problem so far out it is for all practical purposes solved (CR12786)
			delete pbRet;
			char buffer[256];
			sprintf(buffer, "ECB->ReadClient failed: %d", ::GetLastError());
			throw MTException(buffer);
		}

		//
		// Verify that we got some data. 
		// Also, if ReadClient succeeds, but zero bytes were read, then the
		// client gracefully closed the connection before it POSTed the number
		// of bytes it indicated in its Content-length request header.
		// This is also considered an error.
		//
		if (!dwBuffSize)
		{
			delete pbRet;
			throw MTException("ECB->ReadClient call read 0 bytes!");
		}

		dwBytesCopied += dwBuffSize;
	}

	if (fNullTerminate)
		pbRet[pecb->cbTotalBytes] = 0;

	return pbRet;
}


//////////////////////////////////////////////////////////////////////
// IsZipped
//
// Description:
//
// This function returns true if the message has been compressed.
// The size of the uncompressed message is set in uncompressedMessageLen
//
// Arguments:
//
// pecb - Pointer to the extension control block for the request
//////////////////////////////////////////////////////////////////////
BOOL IsZipped(EXTENSION_CONTROL_BLOCK *pECB, unsigned long &uncompressedMessageLen) 
{
	// checks for optional gzip content encoding HTTP request header
	char contentEncoding[64];
	DWORD contentEncodingLen = sizeof(char) * 64;
	if (!pECB->GetServerVariable(pECB->ConnID, "HTTP_CONTENT-ENCODING", contentEncoding, &contentEncodingLen))
		return false;

	// only gzip encoding is currently supported
	if (strcmp(contentEncoding, "gzip") != 0)
	{
		std::string msg = "Unsupported HTTP content encoding: ";
		msg += contentEncoding;
		throw MTException(msg);
	}
		
	// retrieves the original message length (tacked on by the SDK)
	char contentLengthUncompressed[128];
	DWORD contentLengthUncompressedLen = sizeof(char) * 128;
	if (!pECB->GetServerVariable(pECB->ConnID, 
															 "HTTP_CONTENT-LENGTH-UNCOMPRESSED",
															 contentLengthUncompressed,
															 &contentLengthUncompressedLen))
		throw MTException("Content-encoding header found but subsequent Content-Length-Uncompressed header missing!");
		
	uncompressedMessageLen = atol(contentLengthUncompressed);
		
	return true;  
}




//////////////////////////////////////////////////////////////////////
// GetMessage
//
// Description:
//
// Returns a decoded message that is contained in the current POST data.
// Handles optional gzip encoding. Caller is responsible for deleting
// message buffer.
//
// Arguments:
//
// pecb - Pointer to the extension control block for the request
//////////////////////////////////////////////////////////////////////
char * GetMessage(EXTENSION_CONTROL_BLOCK *ecb) 
{
	// gets the NULL terminated posted data
	char * postData = (char *) GetPostData(ecb, TRUE);
	int totalLen = ecb->cbTotalBytes;

	// if the message isn't encoded just return the original post data 
	unsigned long uncompressedMessageLen = -1;
	if (!IsZipped(ecb, uncompressedMessageLen))
		return postData;


	//
	// decompresses the message
	//
	unsigned char * uncompressedData;
	uncompressedData = new unsigned char[uncompressedMessageLen + 1];
	
	int rc = MTZLib::Uncompress(uncompressedData, &uncompressedMessageLen, (unsigned char *) postData, totalLen);
	if (rc != Z_OK)
	{
		delete [] postData;
		delete [] uncompressedData;
		char buffer[256];
		sprintf(buffer, "Failure decompressing message: rc=%d; originalSize=%d; totalLen=%d", rc, uncompressedMessageLen, totalLen);
		throw MTException(buffer);
	}
	
	// original post data is no longer needed so free it
	delete [] postData;

	uncompressedData[uncompressedMessageLen] = '\0';
	return (char *) uncompressedData;
}


