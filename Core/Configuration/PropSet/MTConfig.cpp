// MTConfig.cpp : Implementation of CMTConfig
// disable identifier was truncated to '255' characters in the debug information
#pragma warning(disable : 4786 4700)

#include "StdAfx.h"
#include "PropSet.h"
#include "ClassMTConfig.h"

#include "MTConfigPropSet.h"

#include <xmlconfig.h>

#include <win32net.h>

#include <mtglobal_msg.h>

VARIANT_BOOL CMTConfig::mSecureFlag = VARIANT_FALSE;
_bstr_t CMTConfig::mUsername = "";
_bstr_t CMTConfig::mPassword = "";
// port -1 means use the default port
int CMTConfig::mPort = -1;

/////////////////////////////////////////////////////////////////////////////
// CMTConfig

STDMETHODIMP CMTConfig::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfig,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   default constructor
// ----------------------------------------------------------------
CMTConfig::CMTConfig()
	: mChecksumSwitch(TRUE), // default to turn on checksum switch
		mAutoEnumConversion(TRUE)
{
}

// ----------------------------------------------------------------
// Arguments:     BSTR aConfigBuffer - the string
// Return Value:  VARIANT_BOOL* apChecksumMatch - describes whether
//						the MD5 checksum matched or not.
//				  IMTConfigPropSet * * apSet - the config prop set
// Errors Raised: N/A
// Description:   Reads the product configuration from a string
//                buffer and returns a configuration property set 
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::ReadConfigurationFromString(BSTR aConfigBuffer,
													VARIANT_BOOL* apChecksumMatch,
													IMTConfigPropSet * * apSet)
{
	_bstr_t configBuffer(aConfigBuffer);
	char* configBufChar;

	configBufChar = configBuffer;
	if (configBufChar == NULL || strlen(configBufChar) == 0)
	{
		return Error("Bad parameter: data buffer");
	}

	std::string configBufRWCS = configBuffer;

	XMLObject * results;

	if (!apChecksumMatch)
	{
		return Error("Bad parameter");
	}

	XMLConfigParser parser(0);
	parser.SetAutoConvertEnums(mAutoEnumConversion);

	if (!parser.Init(NULL, mChecksumSwitch))  // turn on the MD5 checksum flag (TRUE)
	{
		return Error("Error initializing parser");
	}

	long index = 0;
	long nread;
	std::string dataChunk;
	char buffer[4096];
	long len = configBufRWCS.length();
	long chunkSize = sizeof(buffer);
	while (TRUE)
	{
    //int nread = fread(buffer, sizeof(char), sizeof(buffer), inputfile);
		if ((index + chunkSize) > len)
		{
			chunkSize = len - index;
		}

		dataChunk = configBufRWCS.substr(index, chunkSize);
		index += chunkSize;

		memcpy(buffer, dataChunk.c_str(), chunkSize);

		nread = chunkSize;

		if (nread < 0)
		{
      return Error("Error reading buffer");
    }

		BOOL result;
		if (nread < sizeof(buffer))
			result = parser.ParseFinal(buffer, nread, &results);
		else
			result = parser.Parse(buffer, nread);

		if (!result)
		{
			// supply detailed parse error info
			int code;
			const char * message;
			int line;
			int column;
			long byte;

			parser.GetErrorInfo(code, message, line, column, byte);

			char buffer[20];
			std::string errormsg = "Parse error: ";
			errormsg += message;
			errormsg += ": line ";
			_itoa(line, buffer, 10);
			errormsg += buffer;
			errormsg += ", column ";
			_itoa(column, buffer, 10);
			errormsg += buffer;
			errormsg += ", byte 0x";
			_ltoa(byte, buffer, 16);
			errormsg += buffer;

			return Error(errormsg.c_str());
		}

    if (nread < sizeof(buffer))
      break;
  }

	XMLConfigPropSet * propset = NULL;
	propset = ConvertUserObject(results, propset);
	if (!propset)
	{
		delete results;
		return Error("Invalid result type");
	}

	// check check sum here
	if ((mChecksumSwitch == FALSE) || (parser.VerifyChecksum() == TRUE))
	{
		*apChecksumMatch = VARIANT_TRUE;
	}
	else
	{
		// checksum verification failed
		*apChecksumMatch = VARIANT_FALSE;
	}

	CComObject<CMTConfigPropSet> * setobj;
	CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

	// setobj owns the set.  it will delete the XMLConfigPropSet
	setobj->SetPropSet(propset, TRUE);

	if (mChecksumSwitch == TRUE)
		setobj->SetChecksum(parser.GetChecksum());

	// have to AddRef or the count will be 0
	return setobj->QueryInterface(IID_IMTConfigPropSet,
																reinterpret_cast<void**>(apSet));
}


// ----------------------------------------------------------------
// Arguments:     BSTR aHostName - the name of the remote host
//				  BSTR aRelativePath - the relative path to the
//						configuration files on the remote host.
//                VARIANT_BOOL aSecure - determines whether SSL is used
// Return Value:  VARIANT_BOOL* apChecksumMatch - describes whether
//                      the MD5 checksum matched or not.
//				  IMTConfigPropSet * * apSet - the config prop set
// Errors Raised: N/A
// Description:   Reads the product configuration from a remote
//                host and returns a configuration property set 
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::ReadConfigurationFromHost(BSTR aHostName,
												  BSTR aRelativePath,
												  VARIANT_BOOL aSecure,
												  VARIANT_BOOL* apChecksumMatch,
												  IMTConfigPropSet * * apSet)
{
	_bstr_t host(aHostName);
	_bstr_t path(aRelativePath);

	std::string buffer("http");
	if (aSecure == VARIANT_TRUE)
		buffer += 's';
	buffer += "://";
	buffer += host;
	buffer += "/config/";
	buffer += path;

	return ReadFromURLInternal(buffer.c_str(), apChecksumMatch, apSet);
}


// ----------------------------------------------------------------
// Arguments:     BSTR aURL - the url where the configuration is
//						located.
// Return Value:  VARIANT_BOOL* apChecksumMatch - describes whether
//						the MD5 checksum matched or not.
//				  IMTConfigPropSet * * apSet - the config prop set
// Errors Raised: N/A
// Description:   Reads the product configuration from a URL
//                and returns a configuration property set 
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::ReadConfigurationFromURL(BSTR aURL,
												 VARIANT_BOOL* apChecksumMatch,
												 IMTConfigPropSet * * apSet)
{
	_bstr_t url(aURL);
	return ReadFromURLInternal(url, apChecksumMatch, apSet);
}


// ----------------------------------------------------------------
// Arguments:     BSTR aURL - the url where the configuration is
//						located.
// Return Value:  VARIANT_BOOL* apChecksumMatch - describes whether
//						the MD5 checksum matched or not.
//				  IMTConfigPropSet * * apSet - the config prop set
// Errors Raised: N/A
// Description:   Reads the product configuration from a URL
//                and returns a configuration property set (internal
//                use, not exported). Used to implement the common
//				  functionality between ReadConfiguationFromURL and
//                ReadConfigurationFromHost.
// ----------------------------------------------------------------
HRESULT CMTConfig::ReadFromURLInternal(const char * apURL,
									   VARIANT_BOOL * apChecksumMatch,
									   IMTConfigPropSet * * apSet)
{
	if (!apChecksumMatch || !apSet)
		return E_POINTER;

	XMLConfigParser parser(0);
	parser.SetAutoConvertEnums(mAutoEnumConversion);

	if (!parser.Init(NULL, mChecksumSwitch))  // turn on the MD5 checksum flag (TRUE)
		return Error("Error initializing parser");


	URL_COMPONENTSA components;
	memset(&components, 0, sizeof(components));
	components.dwStructSize = sizeof(components);
	components.dwHostNameLength = 1; // non zero
	components.dwUrlPathLength = 1; // non zero
	if (!::InternetCrackUrlA(apURL, strlen(apURL), 0, &components))
		return HRESULT_FROM_WIN32(::GetLastError());

	std::string host(components.lpszHostName, components.dwHostNameLength);
	std::string path(components.lpszUrlPath, components.dwUrlPathLength);

	Win32NetStream netstream;
	if (!netstream.Init())
	{
		const ErrorObject * err = netstream.GetLastError();
		return HRESULT_FROM_WIN32(err->GetCode());
	}

	NetStreamConnection * conn;
	if (mSecureFlag)
	{
		int port;
		if (mPort == -1)
			port = NetStream::DEFAULT_HTTP_SSL_PORT;
		else
			port = mPort;

		conn = netstream.OpenSslHttpConnection("GET", 
																					 host.c_str(),
																					 path.c_str(),
																					 FALSE,
																					 mUsername,
																					 mPassword,
																					 NULL,
																					 port);
	}
	else
	{
		int port;
		if (mPort == -1)
			port = NetStream::DEFAULT_HTTP_PORT;
		else
			port = mPort;

		conn = netstream.OpenHttpConnection("GET", 
																				host.c_str(),
																				path.c_str(),
																				FALSE,
																				mUsername,
																				mPassword,
																				NULL,
																				port);
	}

	if (!conn)
	{
		const ErrorObject * err = netstream.GetLastError();

		std::string errorBuffer("Unable to initiate request to host ");
		errorBuffer += host;
		errorBuffer += " path ";
		errorBuffer += path;
		return Error(errorBuffer.c_str(), IID_IMTConfig, HRESULT_FROM_WIN32(err->GetCode()));
	}

	if (!conn->EndRequest())
	{
		const ErrorObject * err = conn->GetLastError();
		return HRESULT_FROM_WIN32(err->GetCode());
	}

	HttpResponse resp = conn->GetResponse();
	if (!resp.IsSuccessful())
	{
		std::string errorBuffer("Bad HTTP response (");
		char buffer[20];
		_itoa((int) resp, buffer, 10);
		errorBuffer += buffer;
		errorBuffer += ") returned from host ";
		errorBuffer += host;
		errorBuffer += " path ";
		errorBuffer += path;
		return Error(errorBuffer.c_str(), IID_IMTConfig, CORE_ERR_BAD_HTTP_RESPONSE);
	}

	XMLObject * results = NULL;

	char buffer[4096];

	int nread = 0;
	do
	{
		if (!conn->ReceiveBytes(buffer, sizeof(buffer), &nread))
		{
			const ErrorObject * err = conn->GetLastError();
			HRESULT code = HRESULT_FROM_WIN32(err->GetCode());
			delete conn;
			return HRESULT_FROM_WIN32(code);
		}

		BOOL result;
		if (nread < sizeof(buffer))
			result = parser.ParseFinal(buffer, nread, &results);
		else
			result = parser.Parse(buffer, nread);

		if (!result)
		{
			delete conn;
			// supply detailed parse error info
			int code;
			const char * message;
			int line;
			int column;
			long byte;

			parser.GetErrorInfo(code, message, line, column, byte);

			char buffer[20];
			std::string errormsg = "Parse error: ";
			errormsg += apURL;
			errormsg += ": ";
			errormsg += message;
			errormsg += ": line ";
			_itoa(line, buffer, 10);
			errormsg += buffer;
			errormsg += ", column ";
			_itoa(column, buffer, 10);
			errormsg += buffer;
			errormsg += ", byte 0x";
			_ltoa(byte, buffer, 16);
			errormsg += buffer;

			return Error(errormsg.c_str());
		}

    if (nread < sizeof(buffer))
      break;
	} while (nread > 0);

	delete conn;

	XMLConfigPropSet * propset = NULL;
	propset = ConvertUserObject(results, propset);
	if (!propset)
	{
		delete results;
		return Error("Invalid result type");
	}

	// check check sum here
	if ((mChecksumSwitch == FALSE) || (parser.VerifyChecksum() == TRUE))
	{
		*apChecksumMatch = VARIANT_TRUE;
	}
	else
	{
		// checksum verification failed
		*apChecksumMatch = VARIANT_FALSE;
	}

	CComObject<CMTConfigPropSet> * setobj;
	CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

	// setobj owns the set.  it will delete the XMLConfigPropSet
	setobj->SetPropSet(propset, TRUE);

	if (mChecksumSwitch == TRUE)
		setobj->SetChecksum(parser.GetChecksum());

	// have to AddRef or the count will be 0
	return setobj->QueryInterface(IID_IMTConfigPropSet,
																reinterpret_cast<void**>(apSet));
}


// ----------------------------------------------------------------
// Arguments:     BSTR aFilename - the name of the config file
// Return Value:  VARIANT_BOOL* apChecksumMatch - describes whether
//                      the MD5 checksum matched or not.
//				  IMTConfigPropSet * * apSet - the config prop set
// Errors Raised: N/A
// Description:   Reads in the given configuration file and 
//                returns a configuration property set 
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::ReadConfiguration(BSTR aFilename, VARIANT_BOOL* apChecksumMatch,
										IMTConfigPropSet * * apSet)
{
	if (!apChecksumMatch)
		return E_POINTER;

	_bstr_t filename(aFilename);

	XMLConfigParser parser(0);
	parser.SetAutoConvertEnums(mAutoEnumConversion);

	if (!parser.Init(NULL, mChecksumSwitch))  // turn on the MD5 checksum flag (TRUE)
		return Error("Error initializing parser");
	
	XMLConfigPropSet * propset;
	try {
		propset = parser.ParseFile(filename);
		if (!propset)
			return Error(parser.GetLastError()->GetProgrammerDetail().c_str());
	}
	catch( ... ) {
		char msg[2048];
		sprintf(msg, "Exception thrown in XMLConfigParser::ParseFile() trying to parse <%s>", (char*)filename);
		return Error(msg);
	}

	// check check sum here
	if ((mChecksumSwitch == FALSE) || (parser.VerifyChecksum() == TRUE))
	{
		*apChecksumMatch = VARIANT_TRUE;
	}
	else
	{
		// checksum verification failed
		*apChecksumMatch = VARIANT_FALSE;
	}

	CComObject<CMTConfigPropSet> * setobj;
	CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

	// setobj owns the set.  it will delete the XMLConfigPropSet
	setobj->SetPropSet(propset, TRUE);

	if (mChecksumSwitch == TRUE)
		setobj->SetChecksum(parser.GetChecksum());

	// have to AddRef or the count will be 0
	return setobj->QueryInterface(IID_IMTConfigPropSet,
																reinterpret_cast<void**>(apSet));
}


// ----------------------------------------------------------------
// Arguments:     BSTR aName - the name of the new config prop set
// Return Value:  IMTConfigPropSet * * apSet - the new, empty, config
//						property set.
// Errors Raised: N/A
// Description:   Creates a new instance of a configuration property
//                set with the given name and returns it.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::NewConfiguration(BSTR aName, IMTConfigPropSet * * apSet)
{
	_bstr_t bstr(aName);
	XMLConfigPropSet * set = new XMLConfigPropSet(bstr);

	CComObject<CMTConfigPropSet> * setobj;
	CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

	// setobj owns the set.  it will delete the XMLConfigPropSet
	setobj->SetPropSet(set, TRUE);

	// have to AddRef or the count will be 0
	return setobj->QueryInterface(IID_IMTConfigPropSet,
								reinterpret_cast<void**>(apSet));
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  VARIANT_BOOL *apVal - the value of the checksum
//						switch.
// Errors Raised: N/A
// Description:   Gets the value of the checksum switch
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_ChecksumSwitch(VARIANT_BOOL *apVal)
{
	if (apVal == NULL)
			return E_POINTER;

	*apVal = mChecksumSwitch ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     VARIANT_BOOL aNewVal - the new checksum switch
//						value.
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the value of the checksum switch
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_ChecksumSwitch(VARIANT_BOOL aNewVal)
{
	mChecksumSwitch = (aNewVal == VARIANT_TRUE) ? TRUE : FALSE;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     VARIANT_BOOL aConvert - the new AutoEnumConversion
//						value.
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the value of the AutoEnumConversion flag
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_AutoEnumConversion(/*[in]*/ VARIANT_BOOL aConvert)
{
	mAutoEnumConversion = (aConvert == VARIANT_TRUE);

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  VARIANT_BOOL * apConvert - the AutoEnumConversion
//						flag's value.
// Errors Raised: N/A
// Description:   Gets the value of the AutoEnumConversion flag
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_AutoEnumConversion(/*[out, retval]*/ VARIANT_BOOL * apConvert)
{
	*apConvert = mAutoEnumConversion ? VARIANT_TRUE : VARIANT_FALSE;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aUsername - the new username
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the username used when reading from a remote host.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_Username(/*[in]*/ BSTR aUsername)
{
	mUsername = aUsername;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR * apUsername - the username
// Errors Raised: N/A
// Description:   Gets the username used when reading from a remote host.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_Username(/*[out, retval]*/ BSTR * apUsername)
{
	if (apUsername == NULL)
		return E_POINTER;

	*apUsername = mUsername.copy();

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR aPassword - the new password
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the password (the password for what ???)
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_Password(/*[in]*/ BSTR aPassword)
{
	mPassword = aPassword;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR * apPassword - the password
// Errors Raised: N/A
// Description:   Gets the password
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_Password(/*[out, retval]*/ BSTR * apPassword)
{
	if (apPassword == NULL)
		return E_POINTER;

	*apPassword = mPassword.copy();

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     VARIANT_BOOL aSecureFlag - the new value of the
//						secure flag.
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the secure flag. This flag determines whether
//				  to use SSL or not when connecting to remote hosts.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_SecureFlag(/*[in]*/ VARIANT_BOOL aSecureFlag)
{
	mSecureFlag = aSecureFlag;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  VARIANT_BOOL * apSecureFlag - the value of the
//						secure flag.
// Errors Raised: N/A
// Description:   Gets the secure flag
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_SecureFlag(/*[out, retval]*/ VARIANT_BOOL * apSecureFlag)
{
	*apSecureFlag = mSecureFlag;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the port. This is used to specifiy a port on
//				  a remote host to connect to. If not specified the
//				  default port for the given protocol will be used.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::put_Port(/*[in]*/ int aPort)
{
	mPort = aPort;
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  int * apPort - the port
// Errors Raised: N/A
// Description:   Gets the port
// ----------------------------------------------------------------
STDMETHODIMP CMTConfig::get_Port(/*[out, retval]*/ int * apPort)
{
	if (!apPort)
		return E_POINTER;

	*apPort = mPort;
	return S_OK;
}
