/**************************************************************************
 * @doc TCGI
 *
 * @module |
 *
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
 *
 * @index | TCGI
 ***************************************************************************/

#ifndef _TCGI_H
#define _TCGI_H

/***********************************************\
*   CGI Class. Class library for making Common
* Gateway Interface (CGI) applications. 
*
* Use cout for outputting to browser, cin for
* getting content type input (note that input
* often comes through the query string (see
* GetQueryString() function)).
*
*   By Thies Schrader, Oct 1996.
*
*   Update by Jeff Rago @ DDNC to make UNICODE
*   compliant.  Removed WinCGI capabilities.
*
*   update by dyoung@metratech.com - remove
*   unicode changes.  leave WinCGI out.
\***********************************************/

#include <windows.h>

//typedef char DN_char;

#define MAX_INPUT_VARIABLES	100

class CTCGIApp
{
private:
	static		CTCGIApp* m_lpTCGIApp;	// Pointer to the one-and-only TCGIApp object.

	char*		m_lpstrBuffer;		// Buffer for holding internal funcs.

	char*		m_lpstrReqProtocol;	// Request protocol.
	char*		m_lpstrReqMethod;	// Request method.
	
	char*		m_lpstrCGIURL;	// Executable path.
	char*		m_lpstrPhyPath;	// Physical path.
	char*		m_lpstrLogPath;	// Logical path.
	
	char*		m_lpstrSrvSoftware;	// Server software running.
	char*		m_lpstrSrvAddress;	// Server name.
	char*		m_lpstrSrvPort;	// Server port.
	char*		m_lpstrAdminEMail;	// Server admin (email).
	char*		m_lpstrCGIVersion;	// CGI version spoken by server.
	
	char*		m_lpstrRmtAddress;	// Remote address (IP-number).
	char*		m_lpstrReferer;	// Remote address (text).
	char*		m_lpstrUserName;	// Remote user name.
	char*		m_lpstrUserAgent;	// Remote user agent (browser).

	char*		m_lpstrAthMethod;	// Authenticated method.
	char*		m_lpstrAthRealm;	// Authenticated realm.
	char*		m_lpstrAthUsername;	// Authenticated user name.

	char*		m_lpstrQueryString;	// Query string (input string).
	char*		m_lpstrContentType;	// Content type (input (cin)).
	long			m_ContentLength;	// Content size (input (cin)).

	char*		m_alpstrKeyNames[MAX_INPUT_VARIABLES];
	char*		m_alpstrValues[MAX_INPUT_VARIABLES];
								// Above for Key=Value pairs in CGI input.
	unsigned int	m_cKeyValuePairs;	// Count of Key=Value pairs.


/*	
	ofstream*		m_WinCGIOutput;	// Output file for WinCGI.
	ifstream*		m_WinCGIInput;		// Input file for WinCGI (content).

	ostream_withassign m_Oldcout;		// Old cout.
	istream_withassign m_Oldcin;		// Old cin.
*/	

protected:
	// StdCGI.
	BOOL			InitStdCGI();		// Initilize standard CGI.
	void			GetEnvironment(const char* lpstrEnvString, char** lplpstrBuffer);
								// Support function (getenv).
	
	// WinCGI.
	//BOOL			InitWinCGI(const DN_char* lpstrCmdLine);
								// Initilize Windows CGI.
	void			GetProfileString(const char* lpstrSection, const char* lpstrKey,
					const char* lpstrInputINIFileName, char** lplpstrBuffer);
								// Support function (GetPrivateProfileString).
	// General.
	BOOL			m_bDebug;			// Are we debugging?

	// Parse functions.
	char			Esc2Char(char* Esc);// Change an ESC-seq to normal char.
	void			UnEsc(char* EscString);
								// UnEsc a string (return in ESCString).
	virtual void	ParseInput();		// Parse all input to CGI.
	void			ParseString(const char* lpstr);
								// Parse string for Key=Value pairs.
public:
	// Constructor/deconstructor.
				CTCGIApp();		// CTCGIApp constructor.
			virtual	~CTCGIApp();		// CTCGIApp deconstructor.

	// Common main function used to start processing
	static int		CGIMain(int argc, char *argv[]);

	static CTCGIApp* GetTCGIApp();	// Static member function for getting the TCGIApp object.

	// CGI Application functions.
	virtual BOOL	InitTCGIInstance(const char* lpstrCmdLine);	
								// Function for initilization.
	virtual BOOL	Run() = 0;			// Actual CGI function (called after init.)
	virtual void	SendHeader();		// Sends CGI-req. header.	

								// Get Key or Value number.
	const char*	GetCGIKey(unsigned int uiKeyNumber);
	const char*	GetCGIValue(unsigned int uiValueNumber);

	virtual const char*  GetCGIInput(const char* lpstrKeyName);
								// Returns the CGI input variable assos.
								// with KeyName.
	// Access functions.
	const char*	GetReqProtocol();	// Request protocol.
	const char*	GetReqMethod();	// Request method.
	
	const char*	GetCGIURL();		// Executable path.
	const char*	GetPhyPath();		// Physical path.
	const char*	GetLogPath();		// Logical path.
	
	const char*	GetSrvSoftware();	// Server software running.
	const char*	GetSrvAddress();		// Server name.
	const char*	GetSrvPort();		// Server port.
	const char*	GetAdminEMail();		// Server admin (email).
	const char*	GetCGIVersion();	// CGI version spoken by server.
	
	const char*	GetRmtAddress();	// Remote address (IP-number).
	const char*	GetReferer();		// Remote address (text).
	const char*	GetUserName();		// Remote user name.
	const char*	GetUserAgent();	// Remote user agent (browser).

	const char*	GetAthMethod();	// Authenticated method.
	const char*	GetAthRealm();		// Authenticated realm.
	const char*	GetAthUsername();	// Authenticated user name.

	const char*	GetQueryString();	// Query string (input).
	const char*	GetContentType();	// Content type (input, see m_CGIIn).
	long			GetContentLength();	// Content size (input, see m_CGIIn).
};


#endif /* _TCGI_H */
