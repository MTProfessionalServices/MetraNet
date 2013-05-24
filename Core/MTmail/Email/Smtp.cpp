// adopted from free code by mef.

/*

PJ Naughter
Email: pjn@indigo.ie
Web: http://indigo.ie/~pjn
16 February 2000


Module : SMTP.CPP
Purpose: Implementation for a MFC class encapsulation of the SMTP protocol
Created: PJN / 22-05-1998
History: PJN / 15-06-1998 1) Fixed the case where a single dot occurs on its own
                          in the body of a message
													2) Class now supports Reply-To Header Field
                          3) Class now supports file attachments

				 PJN / 18-06-1998 1) Fixed a memory overwrite problem which was occurring 
				                  with the buffer used for encoding base64 attachments

         PJN / 27-06-1998 1) The case where a line begins with a "." but contains
                          other text is now also catered for. See RFC821, Section 4.5.2
                          for further details.
                          2) m_sBody in CSMTPMessage has now been made protected.
                          Client applications now should call AddBody instead. This
                          ensures that FixSingleDot is only called once even if the 
                          same message is sent a number of times.
                          3) Fixed a number of problems with how the MIME boundaries
                          were defined and sent.
                          4) Got rid of an unreferenced formal parameter 
                          compiler warning when doing a release build

         PJN / 11-09-1998 1) VC 5 project file is now provided
                          2) Attachment array which the message class contains now uses
                          references instead of pointers.
                          3) Now uses Sleep(0) to yield our time slice instead of Sleep(100),
                          this is the preferred way of writting polling style code in Win32
                          without serverly impacting performance.
                          4) All ATLTRACE statements now display the value as returned from
                          GetLastError
                          5) A number of extra //ASSERTs have been added
                          6) A AddMultipleRecipients function has been added which supports added a 
                          number of recipients at one time from a single string
                          7) Extra ATLTRACE statements have been added to help in debugging

         PJN / 12-09-98   1) Removed a couple of unreferenced variable compiler warnings when code
                          was compiled with Visual C++ 6.0
                          2) Fixed a major bug which was causing an //ASSERT when the CSMTPAttachment
                          destructor was being called in the InitInstance of the sample app. 
                          This was inadvertingly introduced for the 1.2 release. The fix is to revert 
                          fix 2) as done on 11-09-1998. This will also help to reduce the number of 
                          attachment images kept in memory at one time.

         PJN / 18-01-99   1) Full CC & BCC support has been added to the classes

         PJN / 22-02-99   1) Addition of a Get and SetTitle function which allows a files attachment 
                          title to be different that the original filename
                          2) AddMultipleRecipients now ignores addresses if they are empty.
                          3) Improved the reading of responses back from the server by implementing
                          a growable receive buffer
                          4) timeout is now 60 seconds when building for debug

         PJN / 25-03-99   1) Now sleeps for 250 ms instead of yielding the time slice. This helps 
                          reduce CPU usage when waiting for data to arrive in the socket

         PJN / 14-05-99   1) Fixed a bug with the way the code generates time zone fields in the Date headers.

         PJN / 10-09-99   1) Improved CSMTPMessage::GetHeader to include mime field even when no attachments
                          are included.

         PJN / 16-02-00   1) Fixed a problem which was occuring when code was compiled with VC++ 6.0.




Copyright (c) 1998 - 2000 by PJ Naughter.  
All rights reserved.

*/

//////////////// Includes ////////////////////////////////////////////
#include "StdAfx.h"
#include "Smtp.h"
#include "fstream"
#include <sstream>
#include <time.h>
#include <mttime.h>

char CSMTPAttachment::m_base64tab[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                      "abcdefghijklmnopqrstuvwxyz0123456789+/";
#define BASE64_MAXLINE  76
#define EOL  "\r\n"

//////////////// Implementation //////////////////////////////////////
CSMTPSocket::CSMTPSocket()
{
	m_hSocket = INVALID_SOCKET; //default to an invalid scoket descriptor
	m_bWsaInit = FALSE;
}

CSMTPSocket::~CSMTPSocket()
{
	Close();
}

BOOL CSMTPSocket::Create()
{
	if(!m_bWsaInit)
	{
		WSADATA dummy;
		m_bWsaInit = (0 == ::WSAStartup(MAKEWORD( 2, 0 ), &dummy));
		if(!m_bWsaInit)
			return FALSE;
	}
	m_hSocket = socket(AF_INET, SOCK_STREAM, 0);
	return (m_hSocket != INVALID_SOCKET);
}

BOOL CSMTPSocket::Connect(LPCTSTR pszHostAddress, int nPort)
{
	//For correct operation of the T2A macro, see MFC Tech Note 59
	USES_CONVERSION;
	
	//must have been created first
	if(m_hSocket == INVALID_SOCKET)
		return FALSE;
	
	LPSTR lpszAscii = T2A((LPTSTR)pszHostAddress);
	
	//Determine if the address is in dotted notation
	SOCKADDR_IN sockAddr;
	ZeroMemory(&sockAddr, sizeof(sockAddr));
	sockAddr.sin_family = AF_INET;
	sockAddr.sin_port = htons((u_short)nPort);
	sockAddr.sin_addr.s_addr = inet_addr(lpszAscii);
	
	//If the address is not dotted notation, then do a DNS 
	//lookup of it.
	if (sockAddr.sin_addr.s_addr == INADDR_NONE)
	{
		LPHOSTENT lphost;
		lphost = gethostbyname(lpszAscii);
		if (lphost != NULL)
			sockAddr.sin_addr.s_addr = ((LPIN_ADDR)lphost->h_addr)->s_addr;
		else
		{
			WSASetLastError(WSAEINVAL); 
			return FALSE;
		}
	}
	
	//Call the protected version which takes an address 
	//in the form of a standard C style struct.
	return Connect((SOCKADDR*)&sockAddr, sizeof(sockAddr));
}

BOOL CSMTPSocket::Connect(const SOCKADDR* lpSockAddr, int nSockAddrLen)
{
	return (connect(m_hSocket, lpSockAddr, nSockAddrLen) != SOCKET_ERROR);
}

BOOL CSMTPSocket::Send(LPCSTR pszBuf, int nBuf)
{
	//must have been created first
	if(m_hSocket == INVALID_SOCKET)
		return FALSE;
	
	return (send(m_hSocket, pszBuf, nBuf, 0) != SOCKET_ERROR);
}

int CSMTPSocket::Receive(LPSTR pszBuf, int nBuf)
{
	//must have been created first
	if(m_hSocket == INVALID_SOCKET)
		return FALSE;
	
	return recv(m_hSocket, pszBuf, nBuf, 0); 
}

void CSMTPSocket::Close()
{
	if (m_hSocket != INVALID_SOCKET)
	{
		closesocket(m_hSocket);
		m_hSocket = INVALID_SOCKET;
	}
	if(m_bWsaInit)
	{
		::WSACleanup();
		m_bWsaInit = false;
	}
}

BOOL CSMTPSocket::IsReadible(BOOL& bReadible)
{
	timeval timeout = {0, 0};
	fd_set fds;
	FD_ZERO(&fds);
	FD_SET(m_hSocket, &fds);
	int nStatus = select(0, &fds, NULL, NULL, &timeout);
	if (nStatus == SOCKET_ERROR)
	{
		return FALSE;
	}
	else
	{
		bReadible = !(nStatus == 0);
		return TRUE;
	}
}

std::string Unicode2Utf8(const std::wstring& wstr)
{
	size_t len = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), wstr.length(), NULL, 0, NULL, NULL);
	
	if (len == 0)
		return "";
	
	char * out = (char*) alloca(len + 1);
	
	len = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), wstr.length(), out, len, NULL, NULL);
	
	out[len] = 0;
	
	return out;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: QuotedPrintable()
// DESCRIPTION	: try to encode the string according to RFC 1521. 
// RETURN		: std::string
// ARGUMENTS	: std::string str
// 				: bool bHeader = true - encode it for header, according to RFC 1522
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 1/23/01, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
std::string QuotedPrintable(std::string str, bool bHeader = false)
{
	std::string strout;
	bool bEncoded = false;
	for(std::string::const_iterator it = str.begin() ; it != str.end() ; ++it)
	{
		char c = *it;
		// check that code belongs to ascii
		bool bSpecial = ((c <= 0) || (c == '='));
		bool bHeaderSpecial = ((c == '?') /*|| (c == '_')*/ || (c == '\n') || (c == '\r'));

		if(bSpecial || (bHeader && bHeaderSpecial))
		{
			char buf[5];
			sprintf(buf, "=%02X", BYTE(c)); 
			strout += buf;
			bEncoded = true;
		}
		else
			strout += c;
	}

	// add header fields according to RFC 1522
	if(bHeader && bEncoded)
		strout = "=?utf-8?Q?" + strout + "?=";

	return strout;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: TrimAll()
// DESCRIPTION	: remove the blanks at the beginning and the end of the line
// RETURN		: static void
// ARGUMENTS	: std::wstring* pString
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 1/26/01, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
static void TrimAll(std::wstring* pString, LPCTSTR pszBlanks = _T(" \n\r\t"))
{
	size_t pos;
	if(pString->npos != (pos = pString->find_last_not_of(pszBlanks)))
		*pString = pString->substr(0, pos+1);
	if(pString->npos != (pos = pString->find_first_not_of(pszBlanks)))
		*pString = pString->substr(pos);
}


CSMTPAddress::CSMTPAddress() 
{
}

CSMTPAddress::CSMTPAddress(const CSMTPAddress& address)
{
	*this = address;
}

CSMTPAddress::CSMTPAddress(const std::wstring& sAddress)
{
    const char * functionName = "CSMTPAddress::CSMTPAddress";

	// Now divide the substring into friendly names and e-mail addresses
	size_t nMark = sAddress.find(_T('<'));
	if (nMark != sAddress.npos)
	{
		m_sFriendlyName = sAddress.substr(0, nMark);
		size_t nMark2 = sAddress.rfind(_T('>'));
		if (nMark2 < nMark)
		{
			//SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An error occurred while parsing the recipients string\n"));
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,
					"An error occurred while parsing the recipients string\n");
			return;
		}
		// End of mark at closing bracket or end of string
		if(nMark2 == sAddress.npos)
		{
			nMark2 = sAddress.length() - 1;
		}
		m_sEmailAddress = sAddress.substr(nMark + 1, nMark2 - (nMark + 1));
	}
	else
	{
		m_sEmailAddress = sAddress;
		m_sFriendlyName = L"";
	}
	
	// remove excessive characters around email and friendly name
	TrimAll(&m_sEmailAddress, _T(" \n\r\t<>"));
	TrimAll(&m_sFriendlyName, _T(" \n\r\t\""));

	_ASSERT(m_sEmailAddress.length()); //An empty address is not allowed
}

CSMTPAddress::CSMTPAddress(const std::wstring& sFriendly, const std::wstring& sAddress) : 
m_sFriendlyName(sFriendly), m_sEmailAddress(sAddress) 
{
	_ASSERT(m_sEmailAddress.length()); //An empty address is not allowed
}

CSMTPAddress& CSMTPAddress::operator=(const CSMTPAddress& r) 
{ 
	m_sFriendlyName = r.m_sFriendlyName; 
	m_sEmailAddress = r.m_sEmailAddress; 
	return *this;
}

std::wstring CSMTPAddress::GetRegularFormat() const
{
	USES_CONVERSION;
	_ASSERT(m_sEmailAddress.length()); //An empty address is not allowed

	
	std::wstring sAddress;
	if (m_sFriendlyName.empty())
		sAddress = m_sEmailAddress;  //Just transfer the address across directly
	else
		sAddress = _T("\"") + std::wstring(A2T(QuotedPrintable(Unicode2Utf8(m_sFriendlyName), true).c_str())) + _T("\" <") + m_sEmailAddress + _T(">");
	
	return sAddress;
}





CSMTPAttachment::CSMTPAttachment()
{
	m_pszEncoded = NULL;
	m_nEncodedSize = 0;
}

CSMTPAttachment::~CSMTPAttachment()
{
	//free up any memory we allocated
	if (m_pszEncoded)
	{
		delete [] m_pszEncoded;
		m_pszEncoded = NULL;
	}
}

BOOL CSMTPAttachment::Attach(const std::wstring& sFilename)
{
    const char * functionName = "CSMTPAttachment::Attach";

	if(sFilename.length() == 0)  //Empty Filename !
		return FALSE;
	
	//free up any memory we previously allocated
	if (m_pszEncoded)
	{
		delete [] m_pszEncoded;
		m_pszEncoded = NULL;
	}
	
	//determine the file size
	_stat fstat;
	if (_wstat(sFilename.c_str(), &fstat) != 0)
	{
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("Failed to get the status for file to be attached, probably does not exist\n"));
		return FALSE;
	}
	
	//open up the file for reading in
	FILE* infile = _wfopen(sFilename.c_str(), L"rb");
	if (infile == NULL)
	{
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("Failed to open file to be attached\n"));
		return FALSE;
	}
	
	//read in the contents of the input file
	char* pszIn = new char[fstat.st_size];
	size_t read_size = fread(pszIn, 1, fstat.st_size, infile);
	fclose(infile);
	
	if(read_size != size_t(fstat.st_size))
	{
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("Failed to read file to be attached\n"));
		return FALSE;
	}
	
	//allocate the encoded buffer
	int nOutSize = Base64BufferSize(fstat.st_size);
	m_pszEncoded = new char[nOutSize];
	
	//Do the encoding
	EncodeBase64(pszIn, fstat.st_size, m_pszEncoded, nOutSize, &m_nEncodedSize);
	
	//delete the input buffer
	delete [] pszIn;
	
	//Hive away the filename
	TCHAR sPath[_MAX_PATH];
	TCHAR sFname[_MAX_FNAME];
	TCHAR sExt[_MAX_EXT];
	_tsplitpath(sFilename.c_str(), NULL, NULL, sFname, sExt);
	_tmakepath(sPath, NULL, NULL, sFname, sExt);
	m_sFilename = sPath;
	m_sTitle = sPath;
	
	return TRUE;
}

int CSMTPAttachment::Base64BufferSize(int nInputSize)
{
	int nOutSize = (nInputSize+2)/3*4;                    // 3:4 conversion ratio
	nOutSize += strlen(EOL)*nOutSize/BASE64_MAXLINE + 3;  // Space for newlines and NUL
	return nOutSize;
}

BOOL CSMTPAttachment::EncodeBase64(const char* pszIn, int nInLen, char* pszOut, int nOutSize, int* nOutLen)
{
	//Input Parameter validation
	if((pszIn == NULL) || (pszOut == NULL) || (nOutSize == 0) || (nOutSize < Base64BufferSize(nInLen)))
		return FALSE;
	
	//Set up the parameters prior to the main encoding loop
	int nInPos  = 0;
	int nOutPos = 0;
	int nLineLen = 0;
	
	// Get three characters at a time from the input buffer and encode them
	for (int i=0; i<nInLen/3; ++i) 
	{
		//Get the next 2 characters
		int c1 = pszIn[nInPos++] & 0xFF;
		int c2 = pszIn[nInPos++] & 0xFF;
		int c3 = pszIn[nInPos++] & 0xFF;
		
		//Encode into the 4 6 bit characters
		pszOut[nOutPos++] = m_base64tab[(c1 & 0xFC) >> 2];
		pszOut[nOutPos++] = m_base64tab[((c1 & 0x03) << 4) | ((c2 & 0xF0) >> 4)];
		pszOut[nOutPos++] = m_base64tab[((c2 & 0x0F) << 2) | ((c3 & 0xC0) >> 6)];
		pszOut[nOutPos++] = m_base64tab[c3 & 0x3F];
		nLineLen += 4;
		
		//Handle the case where we have gone over the max line boundary
		if (nLineLen >= BASE64_MAXLINE-3) 
		{
			char* cp = EOL;
			pszOut[nOutPos++] = *cp++;
			if (*cp) 
				pszOut[nOutPos++] = *cp;
			nLineLen = 0;
		}
	}
	
	// Encode the remaining one or two characters in the input buffer
	char* cp;
	switch (nInLen % 3) 
	{
    case 0:
		{
			cp = EOL;
			pszOut[nOutPos++] = *cp++;
			if (*cp) 
				pszOut[nOutPos++] = *cp;
			break;
		}
    case 1:
		{
			int c1 = pszIn[nInPos] & 0xFF;
			pszOut[nOutPos++] = m_base64tab[(c1 & 0xFC) >> 2];
			pszOut[nOutPos++] = m_base64tab[((c1 & 0x03) << 4)];
			pszOut[nOutPos++] = '=';
			pszOut[nOutPos++] = '=';
			cp = EOL;
			pszOut[nOutPos++] = *cp++;
			if (*cp) 
				pszOut[nOutPos++] = *cp;
			break;
		}
    case 2:
		{
			int c1 = pszIn[nInPos++] & 0xFF;
			int c2 = pszIn[nInPos] & 0xFF;
			pszOut[nOutPos++] = m_base64tab[(c1 & 0xFC) >> 2];
			pszOut[nOutPos++] = m_base64tab[((c1 & 0x03) << 4) | ((c2 & 0xF0) >> 4)];
			pszOut[nOutPos++] = m_base64tab[((c2 & 0x0F) << 2)];
			pszOut[nOutPos++] = '=';
			cp = EOL;
			pszOut[nOutPos++] = *cp++;
			if (*cp) 
				pszOut[nOutPos++] = *cp;
			break;
		}
    default: 
		{
			return FALSE; 
			break;
		}
	}
	pszOut[nOutPos] = 0;
	*nOutLen = nOutPos;
	return TRUE;
}





CSMTPMessage::CSMTPMessage() 
	: m_sXMailer(_T("Metratech MTMail v1.0")),
		m_BodyFormat(BODY_FORMAT_TEXT),
		m_Importance(IMPORTANCE_NORMAL)
{
}

CSMTPMessage::~CSMTPMessage()
{
}

int CSMTPMessage::GetNumberOfRecipients(RECIPIENT_TYPE RecipientType) const
{
	int nSize = 0;
	switch (RecipientType)
	{
	case TO:  nSize = m_ToRecipients.size();  break;
	case CC:  nSize = m_CCRecipients.size();  break;
	case BCC: nSize = m_BCCRecipients.size(); break;
	default: _ASSERT(FALSE);                      break;
		;
	}
	
	return nSize;
}

int CSMTPMessage::AddRecipient(CSMTPAddress& recipient, RECIPIENT_TYPE RecipientType)
{
	int nIndex = -1;
	switch (RecipientType)
	{
    case TO:  nIndex =  m_ToRecipients.size();
		m_ToRecipients.push_back(recipient);  break;
    case CC:  nIndex =  m_CCRecipients.size();
		m_CCRecipients.push_back(recipient);  break;
    case BCC: nIndex =  m_BCCRecipients.size();
		m_BCCRecipients.push_back(recipient); break;
    default: _ASSERT(FALSE);                            
		;
	}
	
	return nIndex;
}

void CSMTPMessage::RemoveRecipient(int nIndex, RECIPIENT_TYPE RecipientType)
{
	switch (RecipientType)
	{
    case TO:  m_ToRecipients.erase(m_ToRecipients.begin()+nIndex);  break;
    case CC:  m_CCRecipients.erase(m_CCRecipients.begin()+nIndex);  break;
    case BCC: m_BCCRecipients.erase(m_BCCRecipients.begin()+nIndex); break;
    default:  _ASSERT(FALSE);                    break;
		;
	}
}

CSMTPAddress CSMTPMessage::GetRecipient(int nIndex, RECIPIENT_TYPE RecipientType) const
{
	CSMTPAddress address;
	
	switch (RecipientType)
	{
    case TO:  address = m_ToRecipients.at(nIndex);  break;
    case CC:  address = m_CCRecipients.at(nIndex);  break;
    case BCC: address = m_BCCRecipients.at(nIndex); break;
    default: _ASSERT(FALSE);                            break;
		;
	}
	
	return address;
}

int CSMTPMessage::AddAttachment(CSMTPAttachment* pAttachment)
{
	_ASSERT(pAttachment->GetFilename().length()); //an empty filename !
	int iIndex = m_Attachments.size();
	m_Attachments.push_back(pAttachment);
	return iIndex;
}

void CSMTPMessage::RemoveAttachment(int nIndex)
{
	m_Attachments.erase(m_Attachments.begin()+nIndex);
}

CSMTPAttachment* CSMTPMessage::GetAttachment(int nIndex) const
{
	return m_Attachments.at(nIndex);
}

int CSMTPMessage::GetNumberOfAttachments() const
{
	return m_Attachments.size();
}

std::wstring CSMTPMessage::GetHeader(LPCSTR szBoundary) const
{
	USES_CONVERSION;
	//Form the Timezone info which will form part of the Date header
	TIME_ZONE_INFORMATION tzi;
	int nTZBias;
	if (GetTimeZoneInformation(&tzi) == TIME_ZONE_ID_DAYLIGHT)
		nTZBias = tzi.Bias + tzi.DaylightBias;
	else
		nTZBias = tzi.Bias;
	wchar_t szTZBias[20];
	swprintf(szTZBias, _T("%+.2d%.2d"), -nTZBias/60, nTZBias%60);
	
	//Create the "Date:" part of the header
	wchar_t szDate[50];
	time_t now = GetMTTime();
	wcsftime(szDate, 50, _T("%a, %d %b %Y %H:%M:%S "), localtime(&now));
	
	std::wstring sDate(szDate);
	sDate += szTZBias;
	
	//Create the "To:" part of the header
	std::wstring sTo;
	for (int i=0; i<GetNumberOfRecipients(TO); i++)
	{
		CSMTPAddress recipient = GetRecipient(i, TO);
		if (i)
			sTo += _T(",");
		sTo += recipient.GetRegularFormat();
	}
	
	//Create the "Cc:" part of the header
	std::wstring sCc;
	for (i=0; i<GetNumberOfRecipients(CC); i++)
	{
		CSMTPAddress recipient = GetRecipient(i, CC);
		if (i)
			sCc += _T(",");
		sCc += recipient.GetRegularFormat();
	}
	
	//No Bcc info added in header
	
	//Stick everything together
	std::wstringstream stBuf;
	if (sCc.length())
	{
		stBuf << _T("From: ") << m_From.GetRegularFormat() << _T("\r\n")
			<< _T("To: ") << sTo << _T("\r\n")
			<< _T("Cc: ") << sCc << _T("\r\n")
			<< _T("Subject: ") << A2T(QuotedPrintable(Unicode2Utf8(m_sSubject), true).c_str()) << _T("\r\n")
			<< _T("Date: ") << sDate << _T("\r\n")
			<< _T("X-Mailer: ") << m_sXMailer << _T("\r\n");
	}
	else
	{
		stBuf << _T("From: ") << m_From.GetRegularFormat() << _T("\r\n")
			<< _T("To: ") << sTo << _T("\r\n")
			<< _T("Subject: ") << A2T(QuotedPrintable(Unicode2Utf8(m_sSubject), true).c_str()) << _T("\r\n")
			<< _T("Date: ") << sDate << _T("\r\n")
			<< _T("X-Mailer: ") << m_sXMailer << _T("\r\n");
	}
	
	std::wstring sBuf = stBuf.str();

	sBuf += A2T(GetImportanceHeader().c_str());
	
	//push_back the optional Reply-To Field
	if (m_ReplyTo.m_sEmailAddress.length())
	{
		std::wstring sReply(_T("Reply-To: ")+m_ReplyTo.GetRegularFormat()+_T("\r\n"));
		sBuf += sReply;
	}
	
	//push_back the optional fields if attachments are included
	if (m_Attachments.size())
		sBuf += _T("MIME-Version: 1.0\r\nContent-type: multipart/mixed; boundary=\"")+ std::wstring(A2OLE(szBoundary)) + _T("\"\r\n");
	else
	{
		// avoid long textual message being automatically converted by the server:
		sBuf += _T("MIME-Version: 1.0\r\n");
		sBuf += A2T(GetContentHeader().c_str());
	}
	
	sBuf += _T("\r\n");
	
	//Return the result
	return sBuf;
}

void CSMTPMessage::FixSingleDot(std::wstring& sBody)
{
	int nFind = sBody.find(_T("\n."));
	if (nFind != -1)
	{
		std::wstring sLeft(sBody.substr(0,nFind+1));
		std::wstring sRight(sBody.substr(nFind+1));
		FixSingleDot(sRight);
		sBody = sLeft + _T(".") + sRight;
	}
}

void CSMTPMessage::AddBody(const std::wstring& sBody)
{
	m_sBody = sBody;
	
	//Fix the case of a single dot on a line in the message body
	FixSingleDot(m_sBody);
}

BOOL CSMTPMessage::AddMultipleRecipients(const std::wstring& sRecipients, RECIPIENT_TYPE RecipientType)
{
	
	if(0 == sRecipients.length())
		return FALSE;
	
	//Loop through the whole string, adding recipients as they are encountered
	int length = sRecipients.length();
	TCHAR* buf = new TCHAR[length + 1];	// Allocate a work area (don't touch parameter itself)
	_tcscpy(buf, sRecipients.c_str());
	bool bQuoted = false;
	for (int pos=0, start=0; pos<=length; pos++)
	{
		// copy quoted friendly names as is
		if(buf[pos] == _T('"'))
			bQuoted = !bQuoted;

		if(bQuoted)
			continue;

		//Valid separators between addresses are ',' or ';'
		if ((buf[pos] == _T(',')) || (buf[pos] == _T(';')) || (buf[pos] == 0))
		{
			buf[pos] = 0;	//Redundant when at the end of string, but who cares.

			std::wstring wstrAddr(&buf[start]);
			// add the address
			CSMTPAddress To(wstrAddr);
			if (To.m_sEmailAddress.length())
				AddRecipient(To, RecipientType);
			
			//Move on to the next position
			start = pos + 1;
		}
	}

	delete[] buf;
	return TRUE;
}







CSMTPConnection::CSMTPConnection()
{
	USES_CONVERSION;
	m_bConnected = FALSE;

	m_dwTimeout = 30000; //default timeout of 60 seconds when debugging

	m_sBoundary = "#Metratech_email_parts_boundary#";
	// add guid to the boundary
	GUID guid;
	HRESULT hr = E_FAIL;
	hr = ::CoCreateGuid(&guid);
	if(SUCCEEDED(hr))
	{
		OLECHAR strGuid[50];
		if(StringFromGUID2(guid, strGuid, sizeof(strGuid)))
		{
			m_sBoundary += OLE2A(strGuid);
		}
	}

}

CSMTPConnection::~CSMTPConnection()
{
	if (m_bConnected)
		Disconnect();
}

BOOL CSMTPConnection::Connect(LPCTSTR pszHostName, int nPort)
{
    const char * functionName = "CSMTPConnection::Connect";

	//For correct operation of the T2A macro, see MFC Tech Note 59
	USES_CONVERSION;
	
	//paramater validity checking
	if((pszHostName == NULL) || (*(pszHostName) == 0))
	{
		return FALSE;
	}
	
	
	//Create the socket
	if (!m_SMTP.Create())
	{
		std::stringstream str;
		str << "Failed to create client socket, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//Connect to the SMTP Host
	if (!m_SMTP.Connect(pszHostName, nPort))
	{
		std::stringstream str;
		str << "Could not connect to the SMTP server " << T2A(pszHostName) << " on port " << nPort << "GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	else
	{
		//We're now connected !!
		m_bConnected = TRUE;
		
		//check the response to the login
		if (!ReadCommandResponse(220))
		{
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected SMTP login response was received\n"));
			Disconnect();
			return FALSE;
		}
		
		//retreive the localhost name
		char sHostName[100];
		gethostname(sHostName, sizeof(sHostName));
		TCHAR* pszHostName = A2T(sHostName);
		
		//Send the HELO command
		std::wstring sBuf(_T("HELO ") + std::wstring(pszHostName) + _T("\r\n"));
		LPCSTR pszData = T2A(sBuf.c_str());
		int nCmdLength = strlen(pszData);
		if (!m_SMTP.Send(pszData, nCmdLength))
		{
			Disconnect();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected error occurred while sending the HELO command\n"));
			return FALSE;
		}
		//check the response to the HELO command
		if (!ReadCommandResponse(250))
		{
			Disconnect();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected HELO response was received\n"));
			return FALSE;
		} 
		
		return TRUE;
	}
}

BOOL CSMTPConnection::Disconnect()
{
    const char * functionName = "CSMTPConnection::Disconnect";
	BOOL bSuccess = FALSE;      
	
	//disconnect from the SMTP server if connected 
	if (m_bConnected)
	{
		char sBuf[10];
		strcpy(sBuf, "QUIT\r\n");
		int nCmdLength = strlen(sBuf);
		if (!m_SMTP.Send(sBuf, nCmdLength))
		{
			std::stringstream str;
			str << "Failed in call to send QUIT command, GetLastError returns: " << GetLastError();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		}
		
		//Check the reponse
		bSuccess = ReadCommandResponse(221);
		if (!bSuccess)
		{
			SetLastError(ERROR_BAD_COMMAND);
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected QUIT response was received\n"));
		}
		
		//Reset all the state variables
		m_bConnected = FALSE;
	}
	else
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("Already disconnected from SMTP server, doing nothing\n"));
	
	//free up our socket
	m_SMTP.Close();
	
	return bSuccess;
}

BOOL CSMTPConnection::SendMessage(CSMTPMessage& Message)
{
    const char * functionName = "CSMTPConnection::SendMessage";
	//For correct operation of the T2A macro, see MFC Tech Note 59
	USES_CONVERSION;
	
	//paramater validity checking
    if(!m_bConnected) //Must be connected to send a message
		return FALSE;
	
	if(0 ==Message.m_From.m_sEmailAddress.length())
		return FALSE;

	//Must be sending to someone
	if(0 == Message.GetNumberOfRecipients(CSMTPMessage::TO) + 
		Message.GetNumberOfRecipients(CSMTPMessage::CC) + 
		Message.GetNumberOfRecipients(CSMTPMessage::BCC))
	{
		return FALSE;
	}
	
	//Send the MAIL command
	std::wstring sBuf(_T("MAIL FROM:<") + Message.m_From.m_sEmailAddress + _T(">\r\n"));
	LPCSTR pszMailFrom = T2A(sBuf.c_str());
	int nCmdLength = strlen(pszMailFrom);
	if (!m_SMTP.Send(pszMailFrom, nCmdLength))
	{
		std::stringstream str;
		str << "Failed in call to send MAIL command, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//check the response to the MAIL command
	if (!ReadCommandResponse(250))
	{
		SetLastError(ERROR_BAD_COMMAND);
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected MAIL response was received\n"));
		return FALSE;
	} 
	
	//Send the RCPT command, one for each recipient (includes the TO, CC & BCC recipients)
	
	//First the "To" recipients
	for (int i=0; i<Message.GetNumberOfRecipients(CSMTPMessage::TO); i++)
	{
		CSMTPAddress recipient = Message.GetRecipient(i, CSMTPMessage::TO);
		if (!SendRCPTForRecipient(recipient))
			return FALSE;
	}
	
	//Then the "CC" recipients
	for (i=0; i<Message.GetNumberOfRecipients(CSMTPMessage::CC); i++)
	{
		CSMTPAddress recipient = Message.GetRecipient(i, CSMTPMessage::CC);
		if (!SendRCPTForRecipient(recipient))
			return FALSE;
	}
	
	//Then the "BCC" recipients
	for (i=0; i<Message.GetNumberOfRecipients(CSMTPMessage::BCC); i++)
	{
		CSMTPAddress recipient = Message.GetRecipient(i, CSMTPMessage::BCC);
		if (!SendRCPTForRecipient(recipient))
			return FALSE;
	}
	
	//Send the DATA command
	char* pszDataCommand = "DATA\r\n";
	nCmdLength = strlen(pszDataCommand);
	if (!m_SMTP.Send(pszDataCommand, nCmdLength))
	{
		std::stringstream str;
		str << "Failed in call to send DATA command, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//check the response to the DATA command
	if (!ReadCommandResponse(354))
	{
		SetLastError(ERROR_BAD_COMMAND);
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected DATA response was received\n"));
		return FALSE;
	} 
	
	//Send the Header
	std::wstring sHeader = Message.GetHeader(m_sBoundary.c_str());
	const char* pszHeader = T2A(sHeader.c_str());
	nCmdLength = strlen(pszHeader);
	if (!m_SMTP.Send(pszHeader, nCmdLength))
	{
		std::stringstream str;
		str << "Failed in call to send the header, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//Send the Mime Header for the body
	if (Message.m_Attachments.size())
	{
		LPCSTR szPrefix = "\r\n\r\n--";
		std::string szSuffix = "\r\n" + Message.GetContentHeader() + "\r\n";

		if (!SendBoundary(szPrefix, szSuffix.c_str()))
		{
			std::stringstream str;
			str << "Failed in call to send the body header, GetLastError returns: " << GetLastError();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
			return FALSE;
		}
	}
	
	//Send the body
	std::string sBody = QuotedPrintable(Unicode2Utf8(Message.m_sBody));
	if (!m_SMTP.Send(sBody.c_str(), sBody.length()))
	{
		std::stringstream str;
		str << "Failed in call to send the body, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//Send all the attachments
	for (i=0; i< int(Message.m_Attachments.size()); i++)
	{
		CSMTPAttachment* pAttachment = Message.m_Attachments.at(i);
		
		//First send the Mime header for each attachment
		if (!SendBoundary("\r\n\r\n--", "\r\n"))
		{
			std::stringstream str;
			str << "Failed in call to send MIME attachment header, GetLastError returns: " << GetLastError();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
			return FALSE;
		}

		std::wstring sContent;
		sContent =  
			_T("Content-Type: application/octet-stream; name=\"") + pAttachment->GetFilename() + _T("\"\r\n") \
			_T("Content-Transfer-Encoding: base64\r\n")\
			_T("Content-Disposition: attachment; filename=\"") + pAttachment->GetTitle() + _T("\"\r\n\r\n");
		
		char* pszContent = T2A(sContent.c_str());
		nCmdLength = strlen(pszContent);
		if (!m_SMTP.Send(pszContent, nCmdLength))
		{
			std::stringstream str;
			str << "Failed in call to send MIME attachment header, GetLastError returns: " << GetLastError();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
			return FALSE;
		}
		
		//Then send the encoded attachment
		if (!m_SMTP.Send(pAttachment->GetEncodedBuffer(), pAttachment->GetEncodedSize()))
		{
			std::stringstream str;
			str << "Failed in call to send the attachment, GetLastError returns: " << GetLastError();
			SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
			return FALSE;
		}
	}
	
	//Send the final mime boundary
	if (Message.m_Attachments.size())
	{
		if (!SendBoundary("\r\n--", "--"))
		{
			std::stringstream str;
			str << "Failed in call to send MIME attachment boundary, GetLastError returns: " << GetLastError();
			return FALSE;
		}
	}
	
	//Send the end of message indicator
	char* pszEOM = "\r\n.\r\n";
	nCmdLength = strlen(pszEOM);
	if (!m_SMTP.Send(pszEOM, nCmdLength))
	{
		std::stringstream str;
		str << "Failed in call to send End Of Message indicator, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//check the response to the End of Message command
	if (!ReadCommandResponse(250))
	{
		SetLastError(ERROR_BAD_COMMAND);
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected end of message response was received\n"));
		return FALSE;
	} 
	
	return TRUE;
}

BOOL CSMTPConnection::SendRCPTForRecipient(CSMTPAddress& recipient)
{
    const char * functionName = "CSMTPConnection::SendRCPTForRecipient";
	//For correct operation of the T2A macro, see MFC Tech Note 59
	USES_CONVERSION;
	
	if(0== recipient.m_sEmailAddress.length()) //must have an email address for this recipient
		return FALSE;
	
	std::wstring sBuf(_T("RCPT TO:<") + recipient.m_sEmailAddress + _T(">\r\n"));
	LPSTR pszRCPT = T2A(sBuf.c_str());
	
	int nCmdLength = strlen(pszRCPT);
	if (!m_SMTP.Send(pszRCPT, nCmdLength))
	{
		std::stringstream str;
		str << "Failed in call to send RCPT command, GetLastError returns: " << GetLastError();
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName, str.str().c_str());
		return FALSE;
	}
	
	//check the response to the RCPT command
	if (!ReadCommandResponse(250))
	{
		SetLastError(ERROR_BAD_COMMAND);
		SetError(E_FAIL, ERROR_MODULE, ERROR_LINE, functionName,("An unexpected RCPT response was received: " + GetLastCommandResponse()).c_str());
		return FALSE;
	} 
	
	return TRUE;
}

BOOL CSMTPConnection::ReadCommandResponse(int nExpectedCode)
{
	LPSTR pszOverFlowBuffer = NULL;
	char sBuf[256];
	BOOL bSuccess = ReadResponse(sBuf, 256, "\r\n", nExpectedCode, &pszOverFlowBuffer);
	if (pszOverFlowBuffer)
		delete [] pszOverFlowBuffer;
	
	return bSuccess;
}

BOOL CSMTPConnection::ReadResponse(LPSTR pszBuffer, int nInitialBufSize, LPSTR pszTerminator, int nExpectedCode, LPSTR* ppszOverFlowBuffer, int nGrowBy)
{
	if(NULL == ppszOverFlowBuffer)          //Must have a valid string pointer
		return FALSE;

	if(*ppszOverFlowBuffer != NULL) //Initially it must point to a NULL string
		return FALSE;
	
	//must have been created first
	if(!m_bConnected)
		return FALSE;
	
	//The local variables which will receive the data
	LPSTR pszRecvBuffer = pszBuffer;
	int nBufSize = nInitialBufSize;
	
	//retrieve the reponse using until we
	//get the terminator or a timeout occurs
	BOOL bFoundTerminator = FALSE;
	int nReceived = 0;
	DWORD dwStartTicks = ::GetTickCount();
	while (!bFoundTerminator)
	{
		//Has the timeout occured
		if ((::GetTickCount() - dwStartTicks) >	m_dwTimeout)
		{
			pszRecvBuffer[nReceived] = '\0';
			SetLastError(WSAETIMEDOUT);
			m_sLastCommandResponse = pszRecvBuffer; //Hive away the last command reponse
			return FALSE;
		}
		
		//check the socket for readability
		BOOL bReadible;
		if (!m_SMTP.IsReadible(bReadible))
		{
			pszRecvBuffer[nReceived] = '\0';
			m_sLastCommandResponse = pszRecvBuffer; //Hive away the last command reponse
			return FALSE;
		}
		else if (!bReadible) //no data to receive, just loop around
		{
			Sleep(250); //Sleep for a while before we loop around again
			continue;
		}
		
		//receive the data from the socket
		int nBufRemaining = nBufSize-nReceived-1; //Allows allow one space for the NULL terminator
		if (nBufRemaining<0)
			nBufRemaining = 0;
		int nData = m_SMTP.Receive(pszRecvBuffer+nReceived, nBufRemaining);
		
		//Reset the idle timeout if data was received
		if (nData)
		{
			dwStartTicks = ::GetTickCount();
			
			//Increment the count of data received
			nReceived += nData;							   
		}
		
		//If an error occurred receiving the data
		if (nData == SOCKET_ERROR)
		{
			//NULL terminate the data received
			if (pszRecvBuffer)
				pszBuffer[nReceived] = '\0';
			
			m_sLastCommandResponse = pszRecvBuffer; //Hive away the last command reponse
			return FALSE; 
		}
		else
		{
			//NULL terminate the data received
			if (pszRecvBuffer)
				pszRecvBuffer[nReceived] = '\0';
			
			if (nBufRemaining-nData == 0) //No space left in the current buffer
			{
				//Allocate the new receive buffer
				nBufSize += nGrowBy; //Grow the buffer by the specified amount
				LPSTR pszNewBuf = new char[nBufSize];
				
				//copy the old contents over to the new buffer and assign 
				//the new buffer to the local variable used for retreiving 
				//from the socket
				if (pszRecvBuffer)
					strcpy(pszNewBuf, pszRecvBuffer);
				pszRecvBuffer = pszNewBuf;
				
				//delete the old buffer if it was allocated
				if (*ppszOverFlowBuffer)
					delete [] *ppszOverFlowBuffer;
				
				//Remember the overflow buffer for the next time around
				*ppszOverFlowBuffer = pszNewBuf;        
			}
		}
		
		//Check to see if the terminator character(s) have been found
		bFoundTerminator = (strstr(pszRecvBuffer, pszTerminator) != NULL);
	}
	
	//Remove the terminator from the response data
	pszRecvBuffer[nReceived - strlen(pszTerminator)] = '\0';
	
	//determine if the response is an error
	char sCode[4];
	strncpy(sCode, pszRecvBuffer, 3);
	sCode[3] = '\0';
	sscanf(sCode, "%d", &m_nLastCommandResponseCode);
	BOOL bSuccess = (m_nLastCommandResponseCode == nExpectedCode);
	
	if (!bSuccess)
	{
		SetLastError(WSAEPROTONOSUPPORT);
		m_sLastCommandResponse = pszRecvBuffer; //Hive away the last command reponse
	}
	
	return bSuccess;
}

BOOL CSMTPConnection::SendBoundary(LPCSTR szPrefix, LPCSTR szSuffix)
{
	std::string strSend(szPrefix + m_sBoundary + szSuffix);
	return m_SMTP.Send(strSend.c_str(), strSend.length());
}

void CSMTPMessage::SetImportance(IMPORTANCE importance)
{
	m_Importance = IMPORTANCE_NORMAL;
	if((importance >= IMPORTANCE_LOW) && (importance <= IMPORTANCE_HIGH))
		m_Importance = importance;
	else
	{
		// bad importance.
		_ASSERT(0);
	}
}

void CSMTPMessage::SetBodyFormat(BODY_FORMAT BodyFormat)
{
	m_BodyFormat = BODY_FORMAT_TEXT;
	if((BodyFormat >= BODY_FORMAT_HTML) && (BodyFormat <= BODY_FORMAT_TEXT))
		m_BodyFormat = BodyFormat;
	else
	{
		// bad BodyFormat.
		_ASSERT(0);
	}
}

std::string CSMTPMessage::GetContentHeader() const
{
	std::string strHeader = "Content-Type: text/";
	if(m_BodyFormat == BODY_FORMAT_HTML)
		strHeader += "html";
	else
		strHeader += "plain";
	strHeader += "; charset=utf-8\r\n"
				 "Content-Transfer-Encoding: quoted-printable\r\n";

	return strHeader;
}

std::string CSMTPMessage::GetImportanceHeader() const
{
	switch(m_Importance)
	{
	case IMPORTANCE_LOW:
		return "X-Priority: 5\r\n"
			   "X-MSMail-Priority: Low\r\n";
	case IMPORTANCE_NORMAL:
		return "X-Priority: 3\r\n";
	case IMPORTANCE_HIGH:
		return "X-Priority: 1\r\n"
			   "X-MSMail-Priority: High\r\n";
	}
	return "";
}
