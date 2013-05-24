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
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Rudi Perkins
 * $Header: c:\mainline\development\UI\server\Kiosk\kiosk\AuthTicket.cpp, 13, 10/17/2002 1:57:27 PM, Kevin Boucher$
 * 
 * 	KioskAuthTicket.cpp : 
 *	---------------
 *	This is the implementation of the KioskAuthTicket class.
 *	This class expands on the functionality provided by the class 
 *	CCOMKioskAuth by providing functionality to authenticate itself.
 ***************************************************************************/



#include "StdAfx.h"
#include <ConfigDir.h>
#include <loggerconfig.h>
#include <AuthTicket.h>
#include <mtglobal_msg.h>
#include <KioskDefs.h>
#include <time.h>
#include <mtdes.h>
#include <base64.h>
#include <securestore.h>


DLL_EXPORT 
CAuthenticationTicket::CAuthenticationTicket()
{


}

DLL_EXPORT BOOL CAuthenticationTicket::Initialize()
{

 	const char* procName = "CAuthenticationTicket::Initialize";

	mEncryptionKey="sharedsecret";

  // get the encryption key from the secure store
  static SecureStore ssUsername("pipeline");
	string rwConfigDir;
	GetMTConfigDir(rwConfigDir);
	_bstr_t aFileName = rwConfigDir.c_str();
	aFileName += "serveraccess\\protectedpropertylist.xml";

  string   rwcKey = ssUsername.GetValue(aFileName,
                                           _bstr_t("ticketagent"));

  if ((const char *)"" == rwcKey) 
  {
    SetError(KIOSK_ERR_INVALID_USER_CREDENTIALS, ERROR_MODULE, ERROR_LINE, procName,"Initialization failed to retrieve ticketagent encryption key from secure store");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError());
    mEncryptionKey="";
    return FALSE;
  }
  else
  {
    mEncryptionKey=rwcKey;
    return TRUE;
  }
}

DLL_EXPORT 
CAuthenticationTicket::~CAuthenticationTicket()
{
}

DLL_EXPORT BOOL 
CAuthenticationTicket::Create(string & sDestination,
				const char* szDelimiter,
		        const char* szAccountNamespace,
				const char* szAccountId,
				long lTime)
{
	string sTemp;

	//Put time in string buffer
	char buffer[50];
	sprintf(buffer, "%d", lTime);

	sTemp=szDelimiter;
	sTemp+=szAccountNamespace;
	sTemp+=szDelimiter;
	sTemp+=szAccountId;
	sTemp+=szDelimiter;
	sTemp+=buffer;
	sTemp+=szDelimiter;

	//Encrypt(sTemp,sDestination);
	//UnEncrypt(sDestination,sTemp);

	return Encrypt(sTemp.c_str(),sDestination);
}

void TokenizeTicket(vector<string>& aTokenizedList,const string& aStr)
{
	char delim = aStr[0];

	int aCurrentPos = 1;
	int aLoc;

	while((aLoc = aStr.find(delim,aCurrentPos)) != string::npos) {
		string& aSubStr = aStr.substr(aCurrentPos,aLoc-aCurrentPos);
		aTokenizedList.push_back(aSubStr);
		aCurrentPos = aLoc + 1;
	}
}


DLL_EXPORT BOOL 	
CAuthenticationTicket::GetAccountIdentifier(const char* szTicket,
																						wstring & sTicketAccountID,
																						wstring & sTicketNamespace,
																						wstring & sTicketLoggedInAs,
																						wstring & sTicketApplicationName)
{
	const char* procName = "CAuthenticationTicket::GetAccountIdentifier";

	string sClearTextTicket;
	string sToken;               
	string sNamespace;
	string sAccountIdentifier;
	long ltimeExpiration;

	string sLoggedInAs;
	string sApplicationName;

	sTicketAccountID=L"";
	sTicketNamespace=L"";
	sTicketLoggedInAs			 = L"";
	sTicketApplicationName = L"";

	if (szTicket && (!UnEncrypt(szTicket,sClearTextTicket)))
	{
	  SetError(KIOSK_ERR_INVALID_USER_CREDENTIALS, ERROR_MODULE, ERROR_LINE, procName,"Unencryption failed");
		mLogger->LogErrorObject (LOG_ERROR, GetLastError());
		return false;
	}

	if (!sClearTextTicket.length())
	{
		mLogger->LogThis(LOG_DEBUG, "Decrypted authentication ticket was empty");
		return false;
	}

	//Tokenize the string
	//(sClearTextTicket,1) refers to the first character of the ticket to be used as the delimiter
	vector<string> components;
	TokenizeTicket(components, sClearTextTicket);

	if (components.size() != 5)
		return false;

  ASCIIToWide(sTicketNamespace, components[0].c_str(), components[0].length(), 65001);
	if (!sTicketNamespace.length())
		return false;

  ASCIIToWide(sTicketAccountID, components[1].c_str(), components[1].length(), 65001);

	ltimeExpiration=atol(components[2].c_str());

	ASCIIToWide(sTicketLoggedInAs, components[3].c_str(), components[3].length(), 65001);
	ASCIIToWide(sTicketApplicationName, components[4].c_str(), components[4].length(), 65001);

	if (ltimeExpiration!=0)
	{
		//See if ticket has expired
		time_t ltimeCurrent;
		time(&ltimeCurrent);

		if (ltimeExpiration<ltimeCurrent)
		{
			char buffer[50];
			sprintf(buffer, "%d", (ltimeCurrent-ltimeExpiration));

			string sMsg;
			sMsg = "Authorization Ticket expired by ";
			sMsg += buffer;
			sMsg += " seconds for account <" + components[1] + "> in namespace <" + components[0] + ">";
		  SetError(KIOSK_ERR_INVALID_USER_CREDENTIALS, ERROR_MODULE, ERROR_LINE, procName,sMsg.c_str());
			mLogger->LogErrorObject(LOG_WARNING, GetLastError());
			return false;
		}
		else
		{
			char buffer[50];
			sprintf(buffer, "%d", (ltimeExpiration-ltimeCurrent));

			string sMsg;
			sMsg = "Authentication Ticket would have expired in ";
			sMsg += buffer;
			sMsg += " seconds for account <" + components[1] + "> in namespace <" + components[0] + ">";
			mLogger->LogThis(LOG_DEBUG, sMsg.c_str());
		}
	}

	return true;
}

BOOL 
CAuthenticationTicket::Encrypt(const char* szSource, string &sDestination)
{
  char * pBuffer;
  long lenBuffer;

  encryptDES((char *)szSource, strlen(szSource), &pBuffer, &lenBuffer, mEncryptionKey.c_str());

#if 0
	char test[1024];
	memset(test,0,1024);
	decryptDES(out, test, strlen(out),mEncryptionKey);
#endif

	string keyString = sDestination.c_str();
	rfc1421encode((const unsigned char *)pBuffer, lenBuffer, keyString);

  delete pBuffer;

	return true;
}

BOOL 
CAuthenticationTicket::UnEncrypt(const char* szSource, string &sDestination)
{
  
	vector<unsigned char> dest;
	if (rfc1421decode(szSource, strlen(szSource), dest) != ERROR_NONE)
	{
		return FALSE;
	}

	char * pInBuffer;
	pInBuffer = new char[dest.size()+1];

	memcpy(pInBuffer, &dest[0], dest.size());
	pInBuffer[dest.size()]='\0';

	char * pOutBuffer;
  long lenOutBuffer;

	decryptDES(pInBuffer, dest.size(), &pOutBuffer, &lenOutBuffer, mEncryptionKey.c_str());

	sDestination=pOutBuffer;

	delete pInBuffer;
	delete pOutBuffer;

	return TRUE;

}

