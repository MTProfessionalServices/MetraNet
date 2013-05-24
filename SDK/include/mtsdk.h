/**************************************************************************
 * @doc SDKPUB
 *
 * @module |
 *
 * The MetraTech Metering Software Development Kit.
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
 ***************************************************************************/


#ifndef _MTSDK_H
#define _MTSDK_H

#ifdef WIN32
#include <windows.h>
#endif

#ifdef UNIX
	////////////////////
	// mef: override time and size definitions
	#define USE_TIME
	#define USE_SIZE

	// the following is is a copy of code from unix_hacks.h in main include directory.	
	// in case of changes make sure to do them in both places.

      #ifdef USE_TIME
      #ifndef TIME_HACK
      #define TIME_HACK
        #include <time.h>
        #define _TIME_T
        #define _CLOCK_T
        #ifdef __cplusplus
          using std::time_t; using std::clock_t;
        #endif
      #endif
      #endif

      #ifdef USE_SIZE
      #ifndef SIZE_HACK
      #define SIZE_HACK
        #include <stddef.h>
        #define _SIZE_T
        #ifdef __cplusplus
          using std::size_t;
        #endif
      #endif
      #endif
	// mef: override time and size definitions
	////////////////////

#endif
#include <time.h>
#include <stdio.h>
#include <vector>
#include <string>

#ifndef WIN32
	using namespace std;
#endif

#ifdef WIN32
#ifndef MTSDK_DLL_EXPORT
#define MTSDK_DLL_EXPORT __declspec( dllimport )
#endif
#ifndef MTSDK_DLL_EXPORT_EXP
#define MTSDK_DLL_EXPORT_EXP __declspec( dllexport )
#endif // MTSDK_DLL_EXPORT
#endif

#ifdef UNIX 
#undef MTSDK_DLL_EXPORT
#define MTSDK_DLL_EXPORT /* nothing */
#undef MTSDK_DLL_EXPORT_EXP
#define MTSDK_DLL_EXPORT_EXP /* nothing */

#ifndef BOOL
typedef int BOOL;
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef DWORD
typedef unsigned long DWORD;
#endif

#ifndef DWORDLONG
typedef long long DWORDLONG;
#endif

#ifndef LONGLONG
typedef long long LONGLONG;
#endif

#define MAX_PATH 256
#endif // UNIX

#if !defined(UNIX) && !defined(WIN32)
#error **** Must define either UNIX or WIN32 ****
#endif


#define SDK_LOGGING


// objects defined in this file
class MTMeter;
class MTMeterSession;
class MTMeterSessionSet;
class MTMeterBatch;
class MTMeterError;
class MTMeterConfig;
class MTMeterHTTPConfig;
class MTMeterFileConfig;
class MTDecimalValue;

// private objects defined elsewhere.
class NetMeterAPI; // Necessary?
class MTFileMeterAPI;
class MSIXNetMeterAPI;
class SOAPNetMeterAPI;
class ErrorObject;


/***************************************************** enums ***/

/* @enum
 * Values that can be passed into MTMeter::EnableLogging
 */
enum MTDebugLogLevel
{
	// @emem Do not display any logging information.
	MT_LOG_NONE = 2,
	// @emem Only display informational messages.
	MT_LOG_INFO = 1,
	// @emem Display informational messages and
	//   diagnostic/debugging messages.
	MT_LOG_DEBUG = 0
};

/*************************************************** MTMeter ***/

/*
 * @class
 * The MTMeter object controls the rest of the metering library.  Each
 * application using the library should have a MTMeter object that is
 * used to generate <c MTMeterSession> objects.
 */

class MTSDK_DLL_EXPORT MTMeter
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  <mf MTMeter.Startup> must still be called before using other
	//   methods in class.
	// @@parm
	//   Configuration object which holds specifics about the transport
	//   and protocol used to send messages to the server.
	// @@xref <c MTMeterConfig>
	MTMeter(MTMeterConfig & config);

	// @cmember,mfunc
	//   Destructor.  The destructor calls <mf MTMeter.Shutdown> if <mf MTMeter.Shutdown>
	//   hasn't been called already.
	virtual ~MTMeter();

	// @cmember,mfunc
	//   Initialize the object.  This function must be called before any
	//   other method is used in this class.
	// @@rdesc
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeter.GetLastErrorObject> can be called to get more information.
	BOOL Startup();

	// @cmember,mfunc
	//   Shuts down the class.  This function frees up any memory used.
	// @@rdesc
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeter.GetLastErrorObject> can be called to get more information.
	BOOL Shutdown();

	// @cmember,mfunc
	//   Generates a new <c MTMeterSession> to hold property values that are
	//   used to describe a metered event.
	// @@parm
	//   Name of service.  Must match the name of a service defined on
	//   the metering server.
	// @@rdesc
	//   Session that will hold properties. Must be deleted
	//   when no longer needed.
	MTMeterSession * CreateSession(const char * serviceName);

	// @cmember,mfunc
	//   Generates a new <c MTMeterSessionSet> to hold sessions that
	//	 will be metered together in this set
	// @@rdesc
	//   SessionSet that contains sessions to be metered together. Must be deleted
	//   when no longer needed.
	MTMeterSessionSet * CreateSessionSet();

	// @cmember,mfunc
	//   Generates a new <c MTMeterBatch> , which is an object representing batches.
	//	 <c MTMeterSessionSet> instances and <c MTMeterSession> instances can belong in a batch.
	// @@rdesc
	//   Batch object with batch properties. must be deleted after it is used.
	MTMeterBatch * CreateBatch();

	// @cmember,mfunc
	//   Loads new <c MTMeterBatch> with the provided UID, which is an object representing batches.
	//	 <c MTMeterSessionSet> instances and <c MTMeterSession> instances can belong in a batch.
	// @@rdesc
	//   Batch object with batch properties. must be deleted after it is used.
	MTMeterBatch * Refresh(const char * apUID);

	// @cmember,mfunc
	//   Loads a <c MTMeterBatch> with name and namespace provided, which is an object representing batches.
	//	 <c MTMeterSessionSet> instances and <c MTMeterSession> instances can belong in a batch.
	// @@rdesc
	//   Batch object with batch properties. must be deleted after it is used.
	MTMeterBatch * LoadBatchByName(const char * apNameSpace, const char * apName, const char* apSequenceNumber);

	// @cmember,mfunc
	//   Loads new <c MTMeterBatch> with the provided UID, which is an object representing batches.
	//	 <c MTMeterSessionSet> instances and <c MTMeterSession> instances can belong in a batch.
	// @@rdesc
	//   Batch object with batch properties. must be deleted after it is used.
	MTMeterBatch * LoadBatchByUID(const char * apUID);

	// @cmember,mfunc
	//   Return the error code, or 0 if there was no error.
	// @@rdesc
	//   Error code.  For Windows NT, the code is either a Win32 error
	//   or it's an error code defined in sdk_msg.h.
	unsigned long GetLastError() const;

	// @cmember,mfunc
	//   Returns an <c MTMeterError> object that holds information about the
	//   last error.  The MTMeterError object must be deleted after it
	//   is used.
	// @@rdesc
	//   MTMeteringError object representing the last error that
	//   occurred in the MTMeter object or NULL if there was no error.
	//   The object must be deleted after use.
	MTMeterError * GetLastErrorObject() const;

	// @cmember,mfunc
	//   Meter a file which was previously recorded using local mode. Sessions will
	//   be metered until either an error occurrs (returning FALSE) or all sessions 
	//   are replayed which returns TRUE.
	//   
	// @@rdesc
	//   Returns TRUE or FALSE to indicate whether local mode replay was
	//   successful.
	//   
	BOOL MeterFile (char * FileName);

	// @cmember,mfunc
	//   Call this function if you're having problems debugging an
	//   application using the metering object.  The log produced can
	//   help track down bugs and can help MetraTech diagnose problems.
	//   This method only enables logging in the debug version of the
	//   library.  In the release version, it does nothing.
	// @@parm
	//   Detail level used to log messages.  See <t MTDebugLogLevel> for values.
	// @@parm
	//   stdio file pointer where logging messages are sent.
	static void EnableDiagnosticLogging(MTDebugLogLevel level, FILE * logStream);

	// @cmember,mfunc
	// call this function to generate a new sessionUID for use in a MSIX message.  This
	// call is mostly useful if used when manually generating msix messages through
	// an integration tool like biztalk.
	//
	// The buffer is dynamically allocated and must be deleted by the caller.

	char* GenerateNewSessionUID();

// @access Protected:
protected:
	// @cmember Object used by the implementation of MTMeter
	NetMeterAPI * mpAPI;
	NetMeterAPI * mpSoapAPI;
	MTMeterConfig * mpConfig;

// @access Private:
private:
	// @cmember Object used by the implementation of MTMeter
	ErrorObject * mpErrObj;

	// @cmember method used by the implementation of MTMeter
	void SetError(unsigned long aCode, const char * apModule,
								int aLine, const char * apProcedure);

	// @cmember method used by the implementation of MTMeter
	void SetError(const ErrorObject * apError);
};

/********************************************* MTMeterConfig ***/

/*
 * @class
 *   The MTMeterConfig object holds configuration information about
 *   the transport and protocol used by the SDK.
 */

class MTSDK_DLL_EXPORT MTMeterConfig
{
	friend MTMeter;

// @access Public:
public:
	// @cmember,mfunc
	//   Destructor.
	virtual ~MTMeterConfig()
	{ }

	// @cmember,menum
	//   Protocol choices used to send sessions.  Currently MSIX
	//   is the only protocol supported.
	enum Protocol
	{
		// @@emem Metered Session Information Exchange protocol.
		//    See www.msix.org for more details.
		MSIX_PROTOCOL
	};

// @access Protected:
protected:

	// @cmember
	//   Used by MTMeter only.  Do not use this function
	//   in any other case.
	virtual NetMeterAPI * GetAPI() = 0;	
	// @cmember
	//   Used by MTMeter only.  Do not use this function
	//   in any other case.
	virtual NetMeterAPI * GetSoapAPI() = 0;


};


/***************************************** MTMeterHTTPConfig ***/

/*
 * @class
 *   The MTMeterConfig object holds configuration information about
 *   the HTTP transport and protocol used by the SDK.
 */

class MTSDK_DLL_EXPORT MTMeterHTTPConfig : public MTMeterConfig
{
public:
	// @cmember,mfunc
	//   Constructor.  You must still call <mf MTMeter.Init> to initialize the
	//   Metering SDK.
	// @@parm
	//   An optional proxy server setting.  If the proxy server's name
	//   is "proxy1" and runs on port 8000, the syntax of this parameter
	//   would be "http:://proxy1:8000".  If the parameter is NULL, no
	//   proxy server will be used.
	// @@parm
	//   Protocol to use when sending messages to the server.  Currently
	//   only the Metered Session Information Exchange (MSIX) protocol
	//   is supported.
	MTMeterHTTPConfig(const char * proxyName = NULL, Protocol prot = MSIX_PROTOCOL);

	// @cmember,mfunc
	//   Destructor.
	virtual ~MTMeterHTTPConfig();


	enum PortNumbers
	{
		DEFAULT_HTTP_PORT = 80,
		DEFAULT_HTTPS_PORT = 443
	};

	// @cmember,mfunc
	//   Add a Metering Server to be used to meter sessions.  More than
	//   one server may be added.  The library will attempt to send
	//   sessions to the server with the highest priority first, then
	//   attempt to send to servers with lower priority if the attempt
	//   fails.  The higher the priority argument value, the higher the
	//   priority of the server.  If more than one server has the same
	//   same priority, the library will pick any one of these at
	//   random.
	// @@parm
	//   Priority of the server.  The server with the highest value as this
	//   argument will be used first.
	// @@parm
	//   Hostname of the server.
	// @@parm
	//   Port number on the server.  Usually port 80 when not using SSL
	//   and 443 when using SSL.  A value from the PortNumbers enumeration
	//   can be used for this argument.
	// @@parm
	//   If TRUE, use SSL to encrypt all communications.  If FALSE,
	//   don't use encryption when sending data.
	// @@parm
	//   Username used for HTTP authentication on the server.
	// @@parm
	//   Password used for HTTP authentication on the server.
	BOOL AddServer(int priority, const char * serverName,
								 int port, BOOL secure, const char * username,
								 const char * password);


	// @cmember,mfunc
	//   Set the duration in milliseconds that each operation will wait
	//   before timing out.  If a network operation takes longer than
	//   this timeout, the Metering SDK will try again until all its
	//   retries have been used.  If the SDK is still unable to send the
	//   message to the server, the message will be sent to the next
	//   server added with <mf MTMeterHTTPConfig.AddServer>.  If the
	//   message fails to be sent to any server, the operation will
	//   return an error.
	// @@parm
	//   Timeout value in milliseconds.
	void SetConnectTimeout(int timeout);

	// @cmember,mfunc
	//   Retrieves the timeout value in milliseconds.
	// @@rdesc
	//   Timeout value in milliseconds.
	int GetConnectTimeout() const;

	// @cmember,mfunc
	//   Sets the number of retries to make before giving up.
	//   If a network operation fails more times than this for any reason, the
	//   Metering SDK will attempt to resend the message to the next
	//   server listed with <mf MTMeterHTTPConfig.AddServer>.
	// @@parm
	//   Number of retries to attempt before trying the next host.
	void SetConnectRetries(int retries);

	// @cmember,mfunc
	//   Get the number of retries each network operation will make
	//   before moving to the next server.
	// @@rdesc
	//   Number of retries to attempt
	int GetConnectRetries() const;

	// @cmember,mfunc
	//   Return the error code, or 0 if there was no error.
	// @@rdesc
	//   Error code.  For Windows NT, the code is either a Win32 error
	//   or it's an error code defined in sdk_msg.h.
	unsigned long GetLastError() const;

	// @cmember,mfunc
	//   Returns an <c MTMeterError> object that holds information about the
	//   last error.  The MTMeterError object must be deleted after it
	//   is used.
	// @@rdesc
	//   MTMeteringError object representing the last error that
	//   occurred in the MTMeter object or NULL if there was no error.
	//   The object must be deleted after use.
	MTMeterError * GetLastErrorObject() const;
	
  void SetProxyData(std::string proxyName);
  std::string GetProxyData() const;

// @access Protected:
protected:
	// @cmember
	//   Called by MTMeter.  Do not use this function in other cases.
	virtual NetMeterAPI * GetAPI();
	// @cmember
	//   Called by MTMeter.  Do not use this function in other cases.
	virtual NetMeterAPI * GetSoapAPI();

	// @cmember method used by the implementation of MTMeter
	void SetError(unsigned long aCode, const char * apModule,
								int aLine, const char * apProcedure);

	// @cmember method used by the implementation of MTMeter
	void SetError(const ErrorObject * apError);
	
// @access Protected:
protected:
	// @cmember
	//   Object used by the implementation of MTMeterHTTPConfig.
	MSIXNetMeterAPI * mpAPI;
	SOAPNetMeterAPI * mpSoapAPI;

private:
	// @cmember Object used by the implementation of MTMeter
	ErrorObject * mpErrObj;
};

/*
 * @class
 *   The MTMeterFileConfig object holds configuration information about
 *   the local mode file used by the SDK.
 */

class MTSDK_DLL_EXPORT MTMeterFileConfig : public MTMeterHTTPConfig
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  You must still call <mf MTMeter.Init> to initialize the
	//   Metering SDK.
	MTMeterFileConfig();

	virtual ~MTMeterFileConfig();

	// @cmember,mfunc
	//   Add a Metering Server to be used to meter sessions.  More than
	//   one server may be added.  The library will attempt to send
	//   sessions to the server with the highest priority first, then
	//   attempt to send to servers with lower priority if the attempt
	//   fails.  The higher the priority argument value, the higher the
	//   priority of the server.  If more than one server has the same
	//   same priority, the library will pick any one of these at
	//   random.
	// @@parm
	//   Priority of the server.  The server with the highest value as this
	//   argument will be used first.
	// @@parm
	//   Hostname of the server.
	// @@parm
	//   Port number on the server.  Usually port 80 when not using SSL
	//   and 443 when using SSL.  A value from the PortNumbers enumeration
	//   can be used for this argument.
	// @@parm
	//   If TRUE, use SSL to encrypt all communications.  If FALSE,
	//   don't use encryption when sending data.
	// @@parm
	//   Username used for HTTP authentication on the server.
	// @@parm
	//   Password used for HTTP authentication on the server.
	BOOL AddServer(int priority, const char * serverName,
								 int port, BOOL secure, const char * username,
								 const char * password);

	// @cmember,mfunc
	//   Sets the full path and file name for local mode recording of 
	//   sessions
	// @@parm
	//   The full path and file name used for local recording.
	void SetMeterFile (char * FileName);

	// @cmember,mfunc
	//   Sets the full path and file name for the meterstore. If specified
	//   the session keys are recorded to prevent duplicate processing
	//   
	// @@parm
	//   The full path and file name used for the meter store.
	void SetMeterStore (char * FileName);

  void SetProxyData(std::string proxyName);

// @access Protected:
protected:
	// @cmember
	//   Called by MTMeter.  Do not use this function in other cases.
	virtual NetMeterAPI * GetAPI();

// @access Protected:
protected:
	// @cmember
	//   Object used by the implementation of MTMeterHTTPConfig.
	MTFileMeterAPI *	mpAPI;
};

/******************************************** MTMeterSession ***/

/* @class
 * The MTMeterSession object holds the property values for a metered
 * session.  Objects of this type are created by <mf
 * MTMeter.CreateSession>.  <mf MTMeterSession.InitProperty> should be
 * called for each property value before <mf MTMeterSession.Save> or
 * <mf MTMeterSession.Close> is called to send the properties to the
 * server.  <mf MTMeterSession.SetProperty> may be called to modify
 * properties before the session is Closed, and
 * <mf MTMeterSession.GetProperty> can be used to retrieve property values
 * from the session.
 */

class MTSDK_DLL_EXPORT MTMeterSession
{
// @access Protected:
protected:
	// @cmember,mfunc
	//   Constructor.  You cannot construct MTMeterSession objects directly.
	MTMeterSession();

// @access Public:
public:
	// @cmember,mfunc
	//   Destructor.  For the properties of the session to be sent to
	//   the metering server, <mf MTMeterSession.Close> or
	//   <mf MTMeterSession.Save> must be called before deleting the object.
	virtual ~MTMeterSession();

	// @cmember,menum
	//    Property types understood by the SDK

	
	enum SDKPropertyTypes
	{
		// @@emem Undefined property type
		SDK_PROPTYPE_UNDEFINED = 0,
		// @@emem Boolean property type
		SDK_PROPTYPE_BOOLEAN = 1,
		// @@emem Integer property type
		SDK_PROPTYPE_INTEGER = 2,
		// @@emem Date/Time property type time_t
		SDK_PROPTYPE_DATETIME = 3,
		// @@emem Long property which is metered as int
		SDK_PROPTYPE_LONG = 4,
		// @@emem Float property type
		SDK_PROPTYPE_FLOAT = 5,
		// @@emem Ascii string property type.
		SDK_PROPTYPE_STRING = 6,
		// @@emem 64 Bit Integer property type
		SDK_PROPTYPE_BIGINTEGER = 7		
	};
	

	// @cmember,mfunc
	//   After each property has been initialized to the correct value,
	//   Close sends the session and its parents and children, when
	//   appropriate, to the metering server.  The session is marked
	//   complete by a call to Close and further modification is not
	//   allowed on the session object.  The metering server is allowed
	//   to begin processing a session after it has been closed.  When a
	//   session is closed, any parents of the session are saved but
	//   will still be modifiable.  Any children of the session will be
	//   closed and will not allow further modification.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL Close() = 0;

	// @cmember,mfunc
	//   After each property has been initialized to appropriate values,
	//   Save sends the session and its parents and children when
	//   appropriate to the metering server.  After a session has been
	//   saved, it is still possible to modify property values by
	//   calling <mf MTMeterSession.SetProperty>.  A session can be
	//   saved any number of times before finally being closed.  If a
	//   session could potentially remain open for a long period of
	//   time, saving the session periodically will ensure that the
	//   properties are sent to the server.  When a session is saved,
	//   any parents and children of the session will be saved and will
	//   still allow further modification.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL Save() = 0;

	// @cmember,mfunc
	//   After each property has been initialized to the correct value,
	//   the ToXML method converts a session into its XML representation.
	//   The session can then be closed if necessary.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL ToXML(char * buffer, int & bufferSize) = 0;


	// @cmember,mfunc
	//   Get a session identifier that uniquely identifies a session on
	//   the Metering Server.
	// @@parm
	//   Pointer to a character buffer at least 23 bytes long.  This
	//   will hold the session ID and a null terminating byte.  The size
	//   of this buffer is not checked.
	virtual void GetSessionID(char * sessionId) const = 0;

        // @cmember, mfunc
        //   Get the session name
        // virtual void GetName(char *name) const = 0;

	// @cmember,mfunc
	//   Get a reference ID that can be displayed to a user.  This ID is
	//   shorter and more easily displayed and read by the user.  The
	//   reference ID samples part of the session ID.  Therefore it
	//   doesn't uniquely identify a session.  There is a small
	//   probability that a user will have two sessions with the same
	//   reference ID.  Other information about the session can then be
	//   used to determine which session a user is referring to.
	// @@parm
	//   Pointer to a character buffer at least 10 bytes long.  This
	//   will hold the reference ID and a null terminating byte.  The
	//   reference ID is a nine character string made up of uppercase
	//   characters and numbers.  The size of this buffer is not checked.
	virtual void GetReferenceID(char * referenceId) const = 0;

	// @cmember,mfunc
	//   Return the error code, or 0 if there was no error.
	// @@rdesc
	//   Error code.  For Windows NT, the code is either a Win32 error
	//   or it's an error code defined in sdk_msg.h.
	virtual unsigned long GetLastError() const = 0;

	// @cmember,mfunc
	//   Return an <c MTMeterError> object that holds information about the
	//   last error.  The <c MTMeterError> object must be deleted after it
	//   is used.
	// @@rdesc
	//   <c MTMeterError> object representing the last error that
	//   occurred in the MTMeterSession object or NULL if there was no error.
	//   The object must be deleted after use.
	virtual MTMeterError * GetLastErrorObject() const = 0;


	// @cmember,mfunc
	//   Initialize and initially set a property's Unicode value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or
	//   <mf MTMeterSession.Close> has been called.

	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   Pointer to a Unicode string that holds the property's value.
	//   The property must be specified as a Unicode string in the
	//   service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name,
														const wchar_t * val) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's ASCII value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or <mf
	//   MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   Pointer to an ASCII string that holds the property's value.
	//   The property must be specified as an ASCII string in the
	//   service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name,
														const char * val) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's integer value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or
	//   <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's integer value.  The property must be specified
	//   as an integer in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name, int val,
								SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's 64 bit integer value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or
	//   <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's 64 bit integer value.  The property must be specified
	//   as an 64 bit integer in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name, 
                            LONGLONG val) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's float value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or
	//   <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's float value.  The property must be specified
	//   as a float in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name,
														float val) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's double value.
	//   InitProperty must be called before
	//   <mf MTMeterSession.SetProperty> may be called.  InitProperty may
	//   not be called after <mf MTMeterSession.Save> or <mf MTMeterSession.Close>
	//   has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's double value.  The property must be specified
	//   as a double in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get
	//   more information.
	virtual BOOL InitProperty(const char * name,
														double val) = 0;

	// @cmember,mfunc
	//   Initialize and initially set a property's timestamp value.
	//   InitProperty must be called before <mf MTMeterSession.SetProperty>
	//   may be called.  InitProperty may not be called after <mf MTMeterSession.Save>
	//   or <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's time value, in GMT.  The property must be
	//   specified as a timestamp in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL InitProperty(const char * name, time_t timestamp,
										SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME) = 0;

	
	virtual BOOL InitProperty(const char * name, 
														const MTDecimalValue * val) = 0;

	// @cmember,mfunc
	//   Modify a session's Unicode string value.  <mf MTMeterSession.InitProperty> must be
	//   called before SetProperty may be called.  SetProperty may not
	//   be called after <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's Unicode string value.  The property must be
	//   specified as a Unicode string in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name,
													 const wchar_t * val) = 0;

	// @cmember,mfunc
	//   Modify a session's ASCII string value.  <mf MTMeterSession.InitProperty> must be
	//   called before SetProperty may be called.  SetProperty may not
	//   be called after <mf MTMeterSession.Close> has been called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's ASCII string value.  The property must be
	//   specified as an ASCII string in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name,
													 const char * val) = 0;

	// @cmember,mfunc
	//   Modify a session's integer value.
	//   <mf MTMeterSession.InitProperty> must be called before SetProperty may be called.
	//   SetProperty may not be called after <mf MTMeterSession.Close> has been
	//   called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's integer value.  The property must be
	//   specified as an integer in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name, int val,
										SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER) = 0;

	// @cmember,mfunc
	//   Modify a session's 64 bit integer value.
	//   <mf MTMeterSession.InitProperty> must be called before SetProperty may be called.
	//   SetProperty may not be called after <mf MTMeterSession.Close> has been
	//   called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's 64 bit integer value.  The property must be
	//   specified as a 64 bit integer in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name, 
                           LONGLONG val) = 0;

	// @cmember,mfunc
	//   Modify a session's float value.
	//   <mf MTMeterSession.InitProperty> must be called before SetProperty may be called.
	//   SetProperty may not be called after <mf MTMeterSession.Close> has been
	//   called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's float value.  The property must be
	//   specified as a float in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name,
													 float val) = 0;

	// @cmember,mfunc
	//   Modify a session's double value.
	//   <mf MTMeterSession.InitProperty> must be called before SetProperty may be called.
	//   SetProperty may not be called after <mf MTMeterSession.Close> has been
	//   called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's double value.  The property must be
	//   specified as a double in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name,
													 double val) = 0;

	// @cmember,mfunc
	//   Modify a session's timestamp value.
	//   <mf MTMeterSession.InitProperty> must be called before SetProperty may be called.
	//   SetProperty may not be called after <mf MTMeterSession.Close> has been
	//   called.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   The property's time value, in GMT.  The property must be
	//   specified as a timestamp in the service definition.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL SetProperty(const char * name, time_t val,
										SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME) = 0;


	virtual BOOL SetProperty(const char * name, 
														const MTDecimalValue * val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's Unicode string value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   Pointer to a wchar_t pointer that will point to the Unicode
	//   string value.  The value is constant and must not be modified.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name, const wchar_t * * val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's ASCII string value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   Pointer to a char pointer that will point to the ASCII
	//   string value.  The value is constant and must not be modified.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name, const char * * val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's integer value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   A reference to an integer that will hold the property value.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name, int & val, 
										SDKPropertyTypes ptype = SDK_PROPTYPE_INTEGER) = 0;

	// @cmember,mfunc
	//   Retrieve a session's 64 bit integer value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   A reference to a 64 bit integer that will hold the property value.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name, 
                           LONGLONG & val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's float value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   A reference to a float that will hold the property value.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name,
													 float & val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's double value.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   A reference to a double that will hold the property value.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name,
													 double & val) = 0;

	// @cmember,mfunc
	//   Retrieve a session's time value, in GMT.  The property
	//   must have been initialized before GetProperty can return it.
	// @@parm
	//   Property name.  The name must match the property name in the
	//   service definition.
	// @@parm
	//   A reference to a time_t that will hold the property value, in GMT.
	// @@rdesc 
	//   If TRUE, the function succeeded.  If FALSE, the function failed
	//   and <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual BOOL GetProperty(const char * name, time_t & timestamp, 
										SDKPropertyTypes ptype = SDK_PROPTYPE_DATETIME) = 0;

	virtual BOOL GetProperty(const char * name, 
														const MTDecimalValue * * val) = 0;

	// @cmember,mfunc
	//   Create a child of this session.  Any number of children
	//   can be created for a parent session.  Once <mf MTMeterSession.Close>
	//   has been called on a session, no more children can be created.
	//   Sessions that have been saved can still have more children
	//   added to them.
	//   When the child is deleted, it is removed from the parent.
	//   When a parent session is deleted, it deletes any children
	//   still connected to it.
	// @@parm
	//   Service name of child session.
	// @@rdesc
	//   Child MTMeterSession.  Either the child must be deleted, or its
	//   parent must be deleted.  If CreateChildSession returns NULL,
	//   <mf MTMeterSession.GetLastErrorObject> can be called to get more information.
	virtual MTMeterSession * CreateChildSession(const char * serviceName) = 0;

	// @cmember,mfunc
	//   Gets results of session when using synchronous metering.  This may be used
	//   only when RequestResponseFlag is set to TRUE.
	// @@rdesc
	//   An MTMeterSession instance containing the results of the
	//   session.  Use the MTMeterSession's <MTMeterSession.GetProperty>
	//   method to read the results.
	virtual MTMeterSession * GetSessionResults() = 0;

	// @cmember,mfunc
	//   Prevents session destructor from deleting synchronous metering results.
	//   If you use this, you are responsible for freeing results.
	//   MTMeterSession object.
	virtual void DetachSessionResults() = 0;

	// @cmember,mfunc
	//   Deprecated.  Use <mf MTMeterSession.SetRequestResponse> instead.
	virtual void SetResultRequestFlag(BOOL aGetFeedback = TRUE) = 0;

	// @cmember,mfunc
	//   Deprecated.  Use <mf MTMeterSession.GetRequestResponse> instead.
	virtual BOOL GetResultRequestFlag() = 0;

	// @cmember,mfunc
	//   Enables or disables synchronous metering.  
	// @@parm
	//   TRUE to enable, FALSE to disable
	virtual void SetRequestResponse(BOOL aGetFeedback /* = TRUE */) = 0;

	// @cmember,mfunc
	//   Returns value of RequestResponse flag, indicating whether synchronous
	//   metering is enabled.
	// @@rdesc
	//   TRUE if enabled, FALSE if disabled.
	virtual BOOL GetRequestResponse() = 0;

   // BEGIN: The following methods reflect performance related changes
   virtual BOOL CreatePropertyStream(std::string name, 
                                     std::string value) = 0;

   virtual BOOL CreateExistingPropertyStream() = 0;
   virtual void CreatePropertiesHeader() = 0;
   virtual void CreatePropertiesFooter() = 0;
   virtual void CreateHeader() = 0;
   virtual void CreateFooter() = 0;
   virtual BOOL IsFastMode() const = 0;
   virtual void SetFastMode(BOOL fastMode) = 0;
   // END:


};

/********************************************** MTMeterSessionSet ***/

class MTSDK_DLL_EXPORT MTMeterSessionSet
{
protected:
	MTMeterSessionSet()
	{ }

public:
	virtual ~MTMeterSessionSet()
	{ }

	// creates a session as part of set
	virtual MTMeterSession * CreateSession(const char * serviceName) = 0;

	// retrieves the unique ID assigned to this set
	virtual void GetSessionSetID(char * sessionSetID) const = 0;

	// sends all sessions to the server
	virtual BOOL Close() = 0;

	// converts the session set to XML
	virtual BOOL ToXML(char * buffer, int & bufferSize) = 0;

	// sets the pipeline distributed transaction ID that this set will be part of (if any)
	virtual void SetTransactionID(const char * transactionID) = 0;

	// sets the listener distributed transaction ID that this set will be part of (if any)
	// this provides transactional send semantics
	virtual void SetListenerTransactionID(const char * transactionID) = 0;
	
	// gets the distributed transaction ID (if set previously)
	virtual const char * GetTransactionID() const = 0;

	// ---------- 3.0 work --------------------
	// sets the session context
	virtual void SetSessionContext(const char * sessioncontext) = 0;
	
	// gets the session context
	virtual const char * GetSessionContext() const = 0;

	// sets the username
	virtual void SetSessionContextUserName(const char * username) = 0;
	
	// gets the username
	virtual const char * GetSessionContextUserName() const = 0;

	// sets the password
	virtual void SetSessionContextPassword(const char * password) = 0;
	
	// gets the password
	virtual const char * GetSessionContextPassword() const = 0;

	// sets the namespace
	virtual void SetSessionContextNamespace(const char * mtnamespace) = 0;
	
	// gets the namespace
	virtual const char * GetSessionContextNamespace() const = 0;
	// ---------- 3.0 work --------------------

	// returns the error code, or 0 if there was no error.
	//   Return the error code, or 0 if there was no error.
	virtual unsigned long GetLastError() const = 0;

	//   Returns a MTMeterError object that holds information about the
	//   last error.  The MTMeterError object must be deleted after it
	//   is used.
	virtual MTMeterError * GetLastErrorObject() const = 0;

   // BEGIN: The following methods reflect performance related changes
   // sends all sessions to the server
   virtual BOOL IsFastMode() const = 0;

   // virtual std::string GetBuffer() const = 0;
   // END:

};


/********************************************** MTMeterBatch ***/

class MTSDK_DLL_EXPORT MTMeterBatch
{
protected:
	MTMeterBatch()
	{ }

public:
	virtual ~MTMeterBatch()
	{ }

	// sets/gets the Count
	virtual void SetBatchID(long ID) = 0;
	virtual long GetBatchID() const = 0;

	// retrieves the unique ID assigned to this batch
	virtual const char * GetUID() const = 0;

	// sets/gets the name
	virtual void SetName(const char * name) = 0;
	virtual const char * GetName() const = 0; 

	// sets/gets the namespace
	virtual void SetNameSpace(const char * nspace) = 0;
	virtual const char * GetNameSpace() const = 0;

	// sets/gets the Expected Count
	virtual void SetExpectedCount(long expectedCount) = 0;
	virtual long GetExpectedCount() const = 0;

	// sets/gets the Count
	virtual void SetCompletedCount(long completedCount) = 0;
	virtual long GetCompletedCount() const = 0;

	// sets/gets the Error Count
	virtual void SetFailureCount(long failureCount) = 0;
	virtual long GetFailureCount() const = 0;

	// Set status property
	virtual void SetStatus(const char * status) = 0;
	virtual const char * GetStatus() const = 0;
	
	// Get the Batch creation date
	virtual time_t GetCreationDate() const = 0;
	virtual void SetCreationDate(time_t & creationdate) = 0;

	// Get the Batch close date
	virtual time_t GetCompletionDate() const = 0;
	virtual void SetCompletionDate(time_t & completiondate) = 0;

	// Get/Set the source creation date
	virtual void SetSourceCreationDate(time_t & createdate) = 0;
	virtual time_t GetSourceCreationDate() const = 0;
	
	// sets/gets the source
	virtual void SetSource(const char * source) = 0;
	virtual const char * GetSource() const = 0;

	// sets/gets the sequence number
	virtual void SetSequenceNumber(const char * sequencenumber) = 0;
	virtual const char * GetSequenceNumber() const = 0;	

	// Set comment property
	virtual void SetComment(const char * comment) = 0;
	virtual const char * GetComment() const = 0;

	// sets/gets the Metered Count
	virtual void SetMeteredCount(long meteredCount) = 0;
	virtual long GetMeteredCount() const = 0;

	// creates a session as part of batch
	virtual MTMeterSession * CreateSession(const char * serviceName) = 0;

	// creates a session as part of batch
	virtual MTMeterSessionSet * CreateSessionSet() = 0;

	// Refresh properties from server
  virtual BOOL Refresh() = 0;

  // Update Batch in server with current object's properties
  virtual BOOL Save() = 0;

	// Closes the batch
	virtual BOOL Close() = 0;

	// Update the batch with the following statuses
	virtual BOOL MarkAsFailed() = 0;
	virtual BOOL MarkAsDismissed() = 0;
	virtual BOOL MarkAsCompleted() = 0;
	virtual BOOL MarkAsActive() = 0;
	virtual BOOL MarkAsBackout() = 0;
	virtual BOOL UpdateMeteredCount() = 0;

	// returns the error code, or 0 if there was no error.
	//   Return the error code, or 0 if there was no error.
	virtual unsigned long GetLastError() const = 0;

	//   Returns a MTMeterError object that holds information about the
	//   last error.  The MTMeterError object must be deleted after it
	//   is used.
	virtual MTMeterError * GetLastErrorObject() const = 0;
};


/********************************************** MTMeterError ***/

/* @class
 * The MeteringError object holds an error code and allows you to
 * generate an error message for each code.
 * The MeteringError object also holds the time an error occurred
 * and information of interest to the developer.
 */
class MTSDK_DLL_EXPORT MTMeterError
{
// @access Public:
public:
	// @cmember,mfunc Destructor.
	virtual ~MTMeterError()
	{ }

	// @cmember,mfunc Return the error code.
	// @@rdesc Error code.  For Windows NT,
	// the code is either a Win32 error or it's an error code
	// defined in sdk_msg.h.
	virtual unsigned long GetErrorCode() const = 0;

	// @cmember,mfunc
	//   Get the error message in Unicode.  GetErrorMessage fills the
	//   buffer as far as possible and terminates it with a null
	//   character.  If the buffer size is zero, GetErrorMessage
	//   returns the number of wchar_t values to hold the message and a terminating
	//   null character.
	// @@parm
	//   Pointer to buffer of type wchar_t that will hold the error message.
	// @@parm
	//   Size of buffer (number of wchar_t values it can hold).  If zero,
	//   it will be set to the size of the buffer required to hold the string
	//   and the terminating zero.
	// @@rdesc
	//   FALSE if the buffer is NULL, otherwise TRUE.
	virtual BOOL GetErrorMessage(wchar_t * buffer, int & bufferSize) const = 0;

	// @cmember,mfunc
	//   Get the error message in ASCII.  GetErrorMessage fills the
	//   buffer as far as possible and terminates it with a null
	//   character.  If the buffer size is zero, GetErrorMessage
	//   returns the number of char values to hold the message and a terminating
	//   null character.
	// @@parm
	//   Pointer to buffer of type char that will hold the error message.
	// @@parm
	//   Size of buffer (number of char values it can hold).  If zero,
	//   it will be set to the size of the buffer required to hold the string
	//   and the terminating zero.
	// @@rdesc
	//   FALSE if the buffer is NULL, otherwise TRUE.
	virtual BOOL GetErrorMessage(char * buffer, int & bufferSize) const = 0;

	// @cmember,mfunc
	//   Returns information to the programmer that can be useful in diagnosing
	//   the source of an error.
	//   GetErrorMessageEx fills the buffer as far as possible and
	//   terminates it with a null character.  If the buffer size is
	//   zero, GetErrorMessageEx returns the number of char values to hold
	//   the message and a terminating null character.
	// @@parm Pointer to buffer of type char that will hold the message.
	// @@parm
	//   Size of buffer (number of char values it can hold).  If zero,
	//   it will be set to the size of the buffer required to hold the string
	//   and the terminating zero.
	// @@rdesc
	//   FALSE if the buffer is NULL, otherwise TRUE.
	virtual int GetErrorMessageEx(char * buffer, int & bufferSize) const = 0;
	virtual int GetErrorMessageEx(wchar_t * buffer, int & bufferSize) const = 0;

	// @cmember,mfunc
	//   Returns the time the error occurred.
	// @@rdesc
	//   time_t value holding the time the error occurred, in GMT.
	virtual time_t GetErrorTime() const = 0;

// @access Protected:
protected:
	// @cmember,mfunc Constructor.  The constructor object is
	//         protected because MTMeterError objects cannot be created directly.
	MTMeterError()
	{ }
};

class MTDecimalVal;

class MTSDK_DLL_EXPORT MTDecimalValue 
{
public:
	MTDecimalValue();
	virtual ~MTDecimalValue();

	BOOL SetValue(double doubleVal);
	BOOL SetValue(long longVal);
	BOOL SetValue(const char * apStr);
	BOOL SetValue(const wchar_t * apStr);
	// stored number is hiFixedValPart*1,000,000,000 + lowFixedValPart + (fractionalValPart / 1,000,000)
	BOOL SetValue(long hiFixedValPart, long lowFixedValPart, int fractionalValPart);


	// @cmember,mfunc
	//   Returns the ASCII representation of the decimal value.
	//   Format fills the buffer as far as possible and
	//   terminates it with a null character.  If the buffer size is
	//   zero, Format returns the number of char values to hold
	//   the message and a terminating null character.
	// @@parm Pointer to buffer of type char that will hold the string.
	// @@parm
	//   Size of buffer (number of char values it can hold).  If zero,
	//   it will be set to the size of the buffer required to hold the string
	//   and the terminating zero.
	// @@rdesc
	//   FALSE if the buffer is NULL, otherwise TRUE.
	BOOL Format(char * buffer, int & bufferSize);

	// @cmember,mfunc
	//   Returns the Unicode representation of the decimal value.
	//   Format fills the buffer as far as possible and
	//   terminates it with a null character.  If the buffer size is
	//   zero, Format returns the number of char values to hold
	//   the message and a terminating null character.
	// @@parm Pointer to buffer of type wchar_t that will hold the string.
	// @@parm
	//   Size of buffer (number of wchar_t values it can hold).  If zero,
	//   it will be set to the size of the buffer required to hold the string
	//   and the terminating zero.
	// @@rdesc
	//   FALSE if the buffer is NULL, otherwise TRUE.
	BOOL Format(wchar_t * buffer, int & bufferSize);

	static MTDecimalValue * Create();

public:
	MTDecimalValue(MTDecimalVal * apDecimalVal, BOOL aOwned);
	MTDecimalValue(const MTDecimalVal * apDecimalVal, BOOL aOwned);

public:
	MTDecimalVal * mpDecimalVal;
	BOOL mOwned;
};

#endif /* _MTSDK_H */
