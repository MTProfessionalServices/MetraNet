/*
Module : SMTP.H
Purpose: Defines the interface for a MFC class encapsulation of the SMTP protocol
Created: PJN / 22-05-1998

  Copyright (c) 1998 - 2000 by PJ Naughter.  
  All rights reserved.
  
*/


/////////////////////////////// Defines ///////////////////////////////////////
#ifndef __SMTP_H__
#define __SMTP_H__

#include <atlbase.h>
#include <vector>
#include <string> 
#include "errobj.h" 

/////////////////////////////// Classes ///////////////////////////////////////


//Simple Socket wrapper class
class CSMTPSocket
{
public:
	//Constructors / Destructors
	CSMTPSocket();
	~CSMTPSocket();
	
	//methods
	BOOL  Create();
	BOOL  Connect(LPCTSTR pszHostAddress, int nPort = 110);
	BOOL  Send(LPCSTR pszBuf, int nBuf);
	void  Close();
	int   Receive(LPSTR pszBuf, int nBuf);
	BOOL  IsReadible(BOOL& bReadible);
	
protected:
	BOOL   Connect(const SOCKADDR* lpSockAddr, int nSockAddrLen);
	SOCKET m_hSocket;
	BOOL   m_bWsaInit;
};


//Encapsulation of an SMTP email address, used for recipients and in the From: field
class CSMTPAddress : public ObjectWithError
{
public: 
	//Constructors / Destructors
	CSMTPAddress();
	CSMTPAddress(const CSMTPAddress& address);
	CSMTPAddress(const std::wstring& sAddress);
	CSMTPAddress(const std::wstring& sFriendly, const std::wstring& sAddress);
	CSMTPAddress& operator=(const CSMTPAddress& r);
	
	//Methods
	std::wstring GetRegularFormat() const;
	
	//Data members
	std::wstring        m_sFriendlyName; //Would set it to contain something like "PJ Naughter"
	std::wstring        m_sEmailAddress; //Would set it to contains something like "pjn@indigo.ie"
};


//Encapsulation of an SMTP file attachment
class CSMTPAttachment : public ObjectWithError
{
public:
	//Constructors / Destructors
	CSMTPAttachment();
	~CSMTPAttachment();
	
	//methods
	BOOL Attach(const std::wstring& sFilename);
	std::wstring GetFilename() const { return m_sFilename; };
	const char* GetEncodedBuffer() const { return m_pszEncoded; };
	int GetEncodedSize() const { return m_nEncodedSize; };
	std::wstring GetTitle() const { return m_sTitle; };
	void SetTitle(const std::wstring& sTitle) { m_sTitle = sTitle; };
	
protected:
	int Base64BufferSize(int nInputSize);
	BOOL EncodeBase64(const char* aIn, int aInLen, char* aOut, int aOutSize, int* aOutLen);
	static char m_base64tab[];
	
	std::wstring  m_sFilename;    //The filename you want to send
	std::wstring  m_sTitle;       //What it is to be known as when emailed
	char*    m_pszEncoded;   //The encoded representation of the file
	int      m_nEncodedSize; //size of the encoded string
};


////////////////// Forward declaration
class CSMTPConnection;


//Encapsulation of an SMTP message
class CSMTPMessage : public ObjectWithError
{
public:
	//Enums
	enum RECIPIENT_TYPE { TO, CC, BCC };
	// send it as html or plain text
	enum BODY_FORMAT { BODY_FORMAT_HTML, BODY_FORMAT_TEXT };
	enum IMPORTANCE { IMPORTANCE_LOW, IMPORTANCE_NORMAL, IMPORTANCE_HIGH };
	
	//Constructors / Destructors
	CSMTPMessage();
	~CSMTPMessage();
	
	//Recipient support
	int              GetNumberOfRecipients(RECIPIENT_TYPE RecipientType = TO) const;
	int              AddRecipient(CSMTPAddress& recipient, RECIPIENT_TYPE RecipientType = TO);
	void             RemoveRecipient(int nIndex, RECIPIENT_TYPE RecipientType = TO);
	CSMTPAddress     GetRecipient(int nIndex, RECIPIENT_TYPE RecipientType = TO) const;
	
	//Attachment support
	int              GetNumberOfAttachments() const;
	int              AddAttachment(CSMTPAttachment* pAttachment);
	void             RemoveAttachment(int nIndex);
	CSMTPAttachment* GetAttachment(int nIndex) const;
	
	//Misc methods
	virtual std::wstring  GetHeader(LPCSTR szBoundary) const;
	void             AddBody(const std::wstring& sBody);
	BOOL             AddMultipleRecipients(const std::wstring& sRecipients, RECIPIENT_TYPE RecipientType);
	void			 SetImportance(IMPORTANCE importance);
	void			 SetBodyFormat(BODY_FORMAT bodyFormat);
	
	//Data Members
	CSMTPAddress m_From;
	std::wstring      m_sSubject;
	std::wstring      m_sXMailer;
	CSMTPAddress m_ReplyTo;
	
protected:
	void FixSingleDot(std::wstring& sBody);
	
	std::wstring m_sBody;
	std::vector<CSMTPAddress> m_ToRecipients;
	std::vector<CSMTPAddress> m_CCRecipients;
	std::vector<CSMTPAddress> m_BCCRecipients;
	std::vector<CSMTPAttachment*> m_Attachments;

	BODY_FORMAT m_BodyFormat;
	IMPORTANCE m_Importance;
	
	friend class CSMTPConnection;
private:
	std::string GetContentHeader() const;
	std::string GetImportanceHeader() const;
};


//The main class which encapsulates the SMTP connection
class CSMTPConnection : public ObjectWithError
{
public:
	//Constructors / Destructors
	CSMTPConnection();
	virtual ~CSMTPConnection();
	
	//Methods
	BOOL    Connect(LPCTSTR pszHostName, int nPort=25);
	BOOL    Disconnect();
	std::string GetLastCommandResponse() const { return m_sLastCommandResponse; };
	int     GetLastCommandResponseCode() const { return m_nLastCommandResponseCode; };
	DWORD   GetTimeout() const { return m_dwTimeout; };
	void    SetTimeout(DWORD dwTimeout) { m_dwTimeout = dwTimeout; };
	BOOL    SendMessage(CSMTPMessage& Message);
	
protected:
	BOOL SendBoundary(LPCSTR szPrefix, LPCSTR szSuffix);
	BOOL SendRCPTForRecipient(CSMTPAddress& recipient);
	virtual BOOL ReadCommandResponse(int nExpectedCode);
	virtual BOOL ReadResponse(LPSTR pszBuffer, int nInitialBufSize, LPSTR pszTerminator, 
		int nExpectedCode, LPSTR* ppszOverFlowBuffer, int nGrowBy=4096);
	
	CSMTPSocket  m_SMTP;
	BOOL         m_bConnected;
	std::string  m_sLastCommandResponse;
	std::string m_sBoundary;
	DWORD       m_dwTimeout;
	int         m_nLastCommandResponseCode;
};


#endif //__SMTP_H__

