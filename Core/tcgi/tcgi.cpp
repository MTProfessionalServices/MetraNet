/**************************************************************************
 * @doc TCGI
 *
 * Copyright 1999 by MetraTech Corporation
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

/***********************************************\
* CTCGIApp implementation.
*
*  By Thies Schrader, Oct. 1996
*
*  Freeware updated by Jeff Rago @ DDNC to make
*  Unicode compliant
\***********************************************/

#include <assert.h>			// assert macro (debugging).
#include <stdlib.h>			// atol, getenv functions
#include <tcgi.h>
#include <iostream>
#include <istream>
#include <ostream>
#include <fstream>

using std::cout;
using std::cin;
using std::ifstream;
using std::ofstream;


//using namespace std;

#define CONTENT_BUFFER_SIZE 32766



// Initialize static member.
CTCGIApp* CTCGIApp::m_lpTCGIApp = NULL;

// The one and only main function if we're using 'Console Application'.
int CTCGIApp::CGIMain( int argc, char *argv[])
{
	CTCGIApp* lpTheTCGIApp = CTCGIApp::GetTCGIApp();

	int nReturnCode = -1;
	char * lpCmdLine;

	if(argc > 1)			// 0 = program name.
		lpCmdLine = argv[1];
	else
		lpCmdLine = "";

	// CGI environment initilization.
	if(!lpTheTCGIApp->InitTCGIInstance(lpCmdLine))
		goto InitFailure;

	// SEND HEADERS MANUALLY!
	//lpTheTCGIApp->SendHeader();
	nReturnCode = lpTheTCGIApp->Run();

InitFailure:
	return nReturnCode;
}
/*
// The one and only WinMain function if we're using 'Windows Application'.
BOOL WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
					DN_char * lpCmdLine, int nShowCmd)
{
	// Are we running Win32 (hPrevInstance can be non-NULL in Win16).
	assert(hPrevInstance == NULL);

	CTCGIApp* lpTheTCGIApp = CTCGIApp::GetTCGIApp();

	int nReturnCode = -1;

	// CGI environment initilization.

	if(!lpTheTCGIApp->InitTCGIInstance(lpCmdLine))
		goto InitFailure;

	lpTheTCGIApp->SendHeader();
	nReturnCode = lpTheTCGIApp->Run();

InitFailure:
	return nReturnCode;
}
*/

// Constructor/deconstructor.
CTCGIApp::CTCGIApp()
{
	assert(!m_lpTCGIApp);	// m_lpTCGIApp should be NULL (Only one TCGIApp object!)

	m_lpTCGIApp = this;		// this is the one-and-only TCGIApp object.

	// Initlize all member data.
	m_lpstrBuffer = new char[255+1];

	// String to NULL, number to 0, debug set to false.
	m_lpstrReqProtocol	= NULL;
	m_lpstrReqMethod	= NULL;
	m_lpstrCGIURL		= NULL;
	m_lpstrPhyPath		= NULL;
	m_lpstrLogPath		= NULL;
	m_lpstrSrvSoftware	= NULL;
	m_lpstrSrvAddress	= NULL;
	m_lpstrSrvPort		= NULL;
	m_lpstrAdminEMail	= NULL;
	m_lpstrCGIVersion	= NULL;
	m_lpstrRmtAddress	= NULL;
	m_lpstrReferer		= NULL;
	m_lpstrUserName	= NULL;
	m_lpstrUserAgent	= NULL;
	m_lpstrAthMethod	= NULL;
	m_lpstrAthRealm	= NULL;
	m_lpstrAthUsername	= NULL;
	m_lpstrQueryString	= NULL;
	m_lpstrContentType	= NULL;
	m_ContentLength	= 0;

	m_bDebug			= FALSE;

/*	
	m_WinCGIOutput		= NULL;
	m_WinCGIInput		= NULL;
	

	// Initilize 'old' or default cin/cout.
	m_Oldcin			= cin;
	m_Oldcout			= cout;
*/	
	// Init the Key=Value arrays.
	int i;
	for(i = 0; i < MAX_INPUT_VARIABLES; i++)
	{
		m_alpstrKeyNames[i] = NULL;
		m_alpstrValues[i]   = NULL;
	}

	m_cKeyValuePairs	= 0;
}

CTCGIApp::~CTCGIApp()
{
	// delete all strings.
	delete[] m_lpstrBuffer;
	delete[] m_lpstrReqProtocol;
	delete[] m_lpstrReqMethod;
	delete[] m_lpstrCGIURL;
	delete[] m_lpstrPhyPath;
	delete[] m_lpstrLogPath;
	delete[] m_lpstrSrvSoftware;
	delete[] m_lpstrSrvAddress;
	delete[] m_lpstrSrvPort;
	delete[] m_lpstrAdminEMail;
	delete[] m_lpstrCGIVersion;
	delete[] m_lpstrRmtAddress;
	delete[] m_lpstrReferer;
	delete[] m_lpstrUserName;
	delete[] m_lpstrUserAgent;
	delete[] m_lpstrAthMethod;
	delete[] m_lpstrAthRealm;
	delete[] m_lpstrAthUsername;
	delete[] m_lpstrQueryString;
	delete[] m_lpstrContentType;

	// Flush output.
	cout.flush();

/*	
	// If we used WinCGIInput, close and delete it (restoring old DN_cin).
	if(m_WinCGIInput)
	{
		DN_cin = m_OldDN_cin;	// Restore old DN_cin.
		m_WinCGIInput->close();
		delete m_WinCGIInput;
	}

	// If we used WinCGIOutput, close and delete it (restoring old DN_cout).
	if(m_WinCGIOutput)
	{
		DN_cout = m_OldDN_cout;	// Restore old DN_cout.
		m_WinCGIOutput->close();
		delete m_WinCGIOutput;
	}
	
*/
	// Delete Key=Value arrays.
	int i;
	for(i = 0; i < MAX_INPUT_VARIABLES; i++)
	{
		delete[] m_alpstrKeyNames[i];
		delete[] m_alpstrValues[i];
	}

	m_lpTCGIApp = NULL;		// So GetTCGIApp asserts.
}

CTCGIApp* CTCGIApp::GetTCGIApp()
{
	assert(m_lpTCGIApp);	// Has the one-and-only TCGIApp object been made?

	return m_lpTCGIApp;
}

// Initilization function.
void CTCGIApp::GetEnvironment(const char* lpstrEnvString, char** lplpstrBuffer)
{
	delete[] *lplpstrBuffer;

	DWORD cchEnvSize;

	// Get env. string size.
	cchEnvSize = GetEnvironmentVariableA(lpstrEnvString, NULL, 0);
	
	// Create buffer.
	*lplpstrBuffer = new char[cchEnvSize+1];

	// Get the actual environment string.
	GetEnvironmentVariableA(lpstrEnvString, *lplpstrBuffer, cchEnvSize);
}

BOOL CTCGIApp::InitStdCGI()
{
	GetEnvironment("SERVER_PROTOCOL", &m_lpstrReqProtocol);
	GetEnvironment("REQUEST_METHOD", &m_lpstrReqMethod);
	GetEnvironment("SCRIPT_NAME", &m_lpstrCGIURL);
	GetEnvironment("PATH_TRANSLATED", &m_lpstrPhyPath);
	GetEnvironment("PATH_INFO", &m_lpstrLogPath);
	GetEnvironment("SERVER_SOFTWARE", &m_lpstrSrvSoftware);
	GetEnvironment("SERVER_NAME", &m_lpstrSrvAddress);
	GetEnvironment("SERVER_PORT", &m_lpstrSrvPort);
	// AdminEMail here!
	GetEnvironment("GATEWAY_INTERFACE", &m_lpstrCGIVersion);
	GetEnvironment("REMOTE_ADDR", &m_lpstrRmtAddress);
	GetEnvironment("REMOTE_HOST", &m_lpstrReferer);
	GetEnvironment("REMOTE_USER", &m_lpstrUserName);	
	GetEnvironment("HTTP_USER_AGENT", &m_lpstrUserAgent);
	GetEnvironment("AUTH_TYPE", &m_lpstrAthMethod);
	// AthRealm here!
	// AthUsername here!
	GetEnvironment("QUERY_STRING", &m_lpstrQueryString);
	GetEnvironment("CONTENT_TYPE", &m_lpstrContentType);

	char* lpstrContentLengthStr = NULL;
	GetEnvironment("CONTENT_LENGTH", &lpstrContentLengthStr);
	m_ContentLength = atol(lpstrContentLengthStr);
	delete[] lpstrContentLengthStr;
	
	// cin and cout are already correct.

	return TRUE;
}

void CTCGIApp::GetProfileString(const char* lpstrSection, const char* lpstrKey,
			const char* lpstrINIFileName, char** lplpstrBuffer)
{
	assert(m_lpstrBuffer);		// Buffer should be valid (see constructor).

	delete[] *lplpstrBuffer;		// Delete old buffer value.

	GetPrivateProfileStringA(lpstrSection, lpstrKey, "", m_lpstrBuffer,
			255, lpstrINIFileName);

	// Allocate return string buffer.
	*lplpstrBuffer = new char[strlen(m_lpstrBuffer)+1];

	// Copy profile into return string buffer.
	strcpy(*lplpstrBuffer, m_lpstrBuffer);
}

/*
BOOL CTCGIApp::InitWinCGI(const char* lpstrCmdLine)
{
	// First argument in the command line should be the input ini file name.
	// If not, we are not dealing with WinCGI.

	if(lpstrCmdLine[0] == '\0')
		return FALSE;

	// Get the input ini file name (first command line argument)
	char* lpstrINIFileName;

	if(strchr(lpstrCmdLine, ' '))
	{
		// Get the size of the input ini file name.
		int InputINIFileNameSize = strchr(lpstrCmdLine, ' ') - lpstrCmdLine;

		// Allocate place for the name.
		lpstrINIFileName = new DN_char[InputINIFileNameSize + 1];

		// Copy the name to out buffer.
		DN_strncpy(lpstrINIFileName, lpstrCmdLine, InputINIFileNameSize);

		// '\0'-terminate the string.
		lpstrINIFileName[InputINIFileNameSize] = '\0';
	}
	else
	{
		// The complete command line is our file name.
		lpstrINIFileName = new DN_char[DN_strlen(lpstrCmdLine) + 1];
		DN_strcpy(lpstrINIFileName, lpstrCmdLine);
	}

	// WinCGI; try getting the name and opening the WinCGI output file,
	// if this fails, we are not dealing with WinCGI (or there is a big
	// problem with the server...).

	// Allocate string for input and output file name.
	DN_char* lpstrOutputFileName = new DN_char[MAX_PATH+1];
	DN_char* lpstrInputFileName  = new DN_char[MAX_PATH+1];
	
	// Get the input and output file name.
	GetPrivateProfileString(DN_"System", DN_STR("Content File"), DN_CH(""), lpstrInputFileName,
						MAX_PATH, lpstrINIFileName);
	GetPrivateProfileString(DN_STR("System"), DN_STR("Output File"), DN_CH(""), lpstrOutputFileName,
						MAX_PATH, lpstrINIFileName);
	
	if(lpstrOutputFileName[0] == '\0')
	{
		// Could not initilize.
		delete[] lpstrINIFileName;
		delete[] lpstrInputFileName;
		delete[] lpstrOutputFileName;
		return FALSE;
	}

	// Open input and output file (deleting old output file).
	if(lpstrInputFileName[0] != '\0')
	{
		m_WinCGIInput = new ifstream(lpstrInputFileName);
		DN_cin  = *m_WinCGIInput;
	}
	
	m_WinCGIOutput = new ofstream(lpstrOutputFileName, ios::out | ios::trunc);
	DN_cout = *m_WinCGIOutput;
	
	delete[] lpstrInputFileName;
	delete[] lpstrOutputFileName;

	
	// Setup the rest of the environment.
	DN_char* lpstrDebugModeStr = NULL;
	GetProfileString(DN_STR("System"), DN_STR("Debug Mode"), lpstrINIFileName, &lpstrDebugModeStr);
	m_bDebug = (DN_toupper(lpstrDebugModeStr[0])==DN_CH('Y')) ? TRUE : FALSE;	
	delete[] lpstrDebugModeStr;
	
	GetProfileString(DN_STR("CGI"), DN_STR("Request Protocol"), lpstrINIFileName,
												&m_lpstrReqProtocol);
	GetProfileString(DN_STR("CGI"), DN_STR("Request Method"), lpstrINIFileName, &m_lpstrReqMethod);
	GetProfileString(DN_STR("CGI"), DN_STR("Executable Path"), lpstrINIFileName, &m_lpstrCGIURL);
	GetProfileString(DN_STR("CGI"), DN_STR("Physical Path"), lpstrINIFileName, &m_lpstrPhyPath);
	GetProfileString(DN_STR("CGI"), DN_STR("Logical Path"), lpstrINIFileName, &m_lpstrLogPath);
	GetProfileString(DN_STR("CGI"), DN_STR("Server Software"), lpstrINIFileName, &m_lpstrSrvSoftware);
	GetProfileString(DN_STR("CGI"), DN_STR("Server Name"), lpstrINIFileName, &m_lpstrSrvAddress);
	GetProfileString(DN_STR("CGI"), DN_STR("Server Port"), lpstrINIFileName, &m_lpstrSrvPort);
	GetProfileString(DN_STR("CGI"), DN_STR("Server Admin"), lpstrINIFileName, &m_lpstrAdminEMail);
	GetProfileString(DN_STR("CGI"), DN_STR("CGI Version"), lpstrINIFileName, &m_lpstrCGIVersion);
	GetProfileString(DN_STR("CGI"), DN_STR("Remote Address"), lpstrINIFileName, &m_lpstrRmtAddress);
	GetProfileString(DN_STR("CGI"), DN_STR("Referer"), lpstrINIFileName, &m_lpstrReferer);
	GetProfileString(DN_STR("CGI"), DN_STR("From"), lpstrINIFileName, &m_lpstrUserName);
	GetProfileString(DN_STR("Extra Headers", DN_STR("User-Agent", lpstrINIFileName,
												&m_lpstrUserAgent);
	GetProfileString(DN_STR("CGI"), DN_STR("Authentication Method"), lpstrINIFileName,
												&m_lpstrAthMethod);
	GetProfileString(DN_STR("CGI"), DN_STR("Authentication Realm"), lpstrINIFileName,
												&m_lpstrAthRealm);
	GetProfileString(DN_STR("CGI"), DN_STR("Authentication Username"), lpstrINIFileName,
												&m_lpstrAthUsername);
	GetProfileString(DN_STR("CGI"), DN_STR("Query String"), lpstrINIFileName, &m_lpstrQueryString);
	GetProfileString(DN_STR("CGI"), DN_STR("Content Type"), lpstrINIFileName, &m_lpstrContentType);
	
	// Get Content Length (don't use GetPrivateProfileInt, since only int.)
	DN_char* lpstrContentLengthStr = NULL;
	GetProfileString(DN_STR("CGI"), DN_STR("Content Length"), lpstrINIFileName,
												&lpstrContentLengthStr);
	m_ContentLength = DN_atol(lpstrContentLengthStr);
	delete[] lpstrContentLengthStr;

	delete[] lpstrINIFileName;

	return TRUE;
}
*/

// CGI Application functions.
BOOL	CTCGIApp::InitTCGIInstance(const char* lpstrCmdLine)
{
	// We test for standard CGI by checking for an environment
	// label called SCRIPT_NAME, if it exists, we're pretty sure
	// we have standard CGI (StdCGI) otherweis, try for WinCGI
	// and if that fails, we don't have a CGI session.

	// Try for StdCGI.
 /*  
	if(!getenv("SCRIPT_NAME") != NULL)
	{
		if(!InitWinCGI(lpstrCmdLine))
			return FALSE;
	}
	else
	{
		if(!InitStdCGI())
			return FALSE;
	}
   */ 
	if (!InitStdCGI())
	    return FALSE;

	// Parse input (querystring and content-type input (if correct type))
	this->ParseInput();

	return TRUE;
}

// Header function for normal text html output (override, if something else).
void CTCGIApp::SendHeader()
{
	cout << "HTTP/1.0 200 OK\n";
	cout << "Content-type: text/html\n\n";
}

// Return the CGI key variable number uiValueNumber.
const char* CTCGIApp::GetCGIValue(unsigned int uiValueNumber)
{
	if(uiValueNumber < m_cKeyValuePairs)
		return m_alpstrValues[uiValueNumber];
	else
		return NULL;
}

// Return the CGI value variable number uiKeyNumber.
const char* CTCGIApp::GetCGIKey(unsigned int uiKeyNumber)
{
	if(uiKeyNumber < m_cKeyValuePairs)
		return m_alpstrKeyNames[uiKeyNumber];
	else
		return NULL;
}

// Return the CGI input variable ass. with KeyName.
const char* CTCGIApp::GetCGIInput(const char* lpstrKeyName)
{
	unsigned int i = 0;
	while(i < m_cKeyValuePairs)
	{
		if(stricmp(lpstrKeyName, m_alpstrKeyNames[i]) == 0)
			break;	// i pointing to correct value.
		i++;
	}
	
	if(i < m_cKeyValuePairs)
		return m_alpstrValues[i];
	else
		return NULL;	// Not found. (should be other than "")
}

// Parse support functions.
// Convert a HTML ESC-sequence to a character.
char CTCGIApp::Esc2Char(char* Esc)
{
	char Char;

	Char = (Esc[0] >= 'A' ? ((Esc[0] & 0xdf) - 'A') + 10 : (Esc[0] - '0'));
	Char *= 16;
	Char += (Esc[1] >= 'A' ? ((Esc[1] & 0xdf) - 'A') + 10 : (Esc[1] - '0'));

	return Char;
}

// Converts a string with HTML ESC-sequences to one without. Fixed 10/03/1998 thanks to Thomas Windbuehl
void CTCGIApp::UnEsc(char* EscString)
{
	int UnEscStrPos,EscStrPos;
	
	for (UnEscStrPos=0,EscStrPos=0; EscString[EscStrPos];++UnEscStrPos,++EscStrPos)
	{
		if(EscString[EscStrPos] == '+')
			EscString[EscStrPos] = ' ';

		if((EscString[UnEscStrPos] = EscString[EscStrPos]) == '%')
		{
			EscString[UnEscStrPos] = Esc2Char(&EscString[EscStrPos+1]);
			EscStrPos+=2;
		}
	}

	// NULL-term the string.
	EscString[UnEscStrPos] = '\0';
}

// Parses a string for Key=Value pairs, doesn't like '==' combinations.
void CTCGIApp::ParseString(const char* lpstr)
{
	if(lpstr[0] == '\0')
		return;

	int	cEqual = 0;		// Location of a '='.
	int	cAnd = -1;		// Location of a '&' (first at lpstr[-1]).

	int	KeySize;			// Size of Key part.
	int	ValueSize;    		// Size of Value part.

	int i = 0;
	do
	{
		if((lpstr[i] == '&') || (lpstr[i] == '\0'))
		{
			if(cEqual < cAnd)
			{
				ValueSize = 0;	// No '=' in last key=value.
				KeySize = i - cAnd - 1;
			}
			else
			{
				ValueSize = i - cEqual - 1;
				KeySize = cEqual - cAnd - 1;
			}

			// Allocate space for the Key and Value.
			m_alpstrKeyNames[m_cKeyValuePairs] = new char[KeySize + 1];
			m_alpstrValues[m_cKeyValuePairs]	= new char[ValueSize + 1];

			// Copy the Key and Value.
			strncpy(m_alpstrKeyNames[m_cKeyValuePairs], lpstr + cAnd + 1, KeySize);
			strncpy(m_alpstrValues[m_cKeyValuePairs], lpstr + cEqual + 1, ValueSize);

			// Null-term Key and Value.
			m_alpstrKeyNames[m_cKeyValuePairs][KeySize] = '\0';
			m_alpstrValues[m_cKeyValuePairs++][ValueSize] = '\0';

			cAnd = i;
		}
		else if(lpstr[i] == '=')
		{
			cEqual = i;
		}
	}
	while(lpstr[i++] && (m_cKeyValuePairs < MAX_INPUT_VARIABLES));
}

// Parse CGI input
void CTCGIApp::ParseInput()
{
	// Parse the query string.
	ParseString(GetQueryString());

	// if we have 'x-www-form-urlencoded', parse cin (CGI form input).
	if(GetContentLength() && (strstr(GetContentType(), "x-www-form-urlencoded") != NULL))
	{
		char* lpstrBuffer = new char[CONTENT_BUFFER_SIZE+1];
		long  lSize       = GetContentLength();

		do 
		{
			if( lSize < CONTENT_BUFFER_SIZE)
				cin.getline(lpstrBuffer, lSize, '&');
			else
				cin.getline(lpstrBuffer, CONTENT_BUFFER_SIZE, '&');

			lSize -=  ((unsigned int) cin.gcount());

			UnEsc(lpstrBuffer);
		
			ParseString(lpstrBuffer);

		} while ((lSize > 0) && (!cin.eof()) && cin.gcount());

		delete[] lpstrBuffer;
	}
}


// Access functions.
const char* CTCGIApp::GetReqProtocol()
	{ return m_lpstrReqProtocol; }
const char* CTCGIApp::GetReqMethod()
	{ return m_lpstrReqMethod; }
const char* CTCGIApp::GetCGIURL()
	{ return m_lpstrCGIURL; }
const char* CTCGIApp::GetPhyPath()
	{ return m_lpstrPhyPath; }
const char* CTCGIApp::GetLogPath()
	{ return m_lpstrLogPath; }	
const char* CTCGIApp::GetSrvSoftware()
	{ return m_lpstrSrvSoftware; }
const char* CTCGIApp::GetSrvAddress()
	{ return m_lpstrSrvAddress; }
const char* CTCGIApp::GetSrvPort()
	{ return m_lpstrSrvPort; }
const char* CTCGIApp::GetAdminEMail()
	{ return m_lpstrAdminEMail; }
const char* CTCGIApp::GetCGIVersion()
	{ return m_lpstrCGIVersion; }
const char* CTCGIApp::GetRmtAddress()
	{ return m_lpstrRmtAddress; }
const char* CTCGIApp::GetReferer()
	{ return m_lpstrReferer; }
const char* CTCGIApp::GetUserName()
	{ return m_lpstrUserName; }
const char* CTCGIApp::GetUserAgent()
	{ return m_lpstrUserAgent; }
const char* CTCGIApp::GetAthMethod()
	{ return m_lpstrAthMethod; }
const char* CTCGIApp::GetAthRealm()
	{ return m_lpstrAthRealm; }
const char* CTCGIApp::GetAthUsername()
	{ return m_lpstrAthUsername; }
const char* CTCGIApp::GetQueryString()
	{ return m_lpstrQueryString; }
const char* CTCGIApp::GetContentType()
	{ return m_lpstrContentType; }
long CTCGIApp::GetContentLength()
	{ return m_ContentLength; }

