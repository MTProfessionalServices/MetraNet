// TicketAgent.cpp : Implementation of CTicketAgent
/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include <comdef.h>
#include "comticketagent.h"
#include "TicketAgent.h"
#include <MTUtil.h>
#include <time.h>
#include <mtdes.h>
#include <base64.h>

#import <comticketagent.tlb>

/////////////////////////////////////////////////////////////////////////////
// CTicketAgent

STDMETHODIMP CTicketAgent::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ITicketAgent
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/*
STDMETHODIMP CTicketAgent::CreateTicket(BSTR sNamespace, BSTR sAccountIdentifier, long lExpirationOffset, BSTR *pTicket)
{

	CAuthenticationTicket ticket;

	string sTicket("");
	_bstr_t bstrNamespace(sNamespace);
	_bstr_t bstrAccountIdentifier(sAccountIdentifier);

	// Determine the expiration time
	time_t timeExpiration;
	if (lExpirationOffset!=0)
	{
		// Expiration is current time plus offset
		time(&timeExpiration);

		timeExpiration+=lExpirationOffset;
	}
	else
	{
		//Doesn't Expire
		timeExpiration=0;
	}

	if (ticket.Create(sTicket,mDelimiter,bstrNamespace,bstrAccountIdentifier,timeExpiration))
	{
		_bstr_t bstrTicket(sTicket);

		*pTicket = ::SysAllocString (bstrTicket) ;
	}
	else
	{
		*pTicket = ::SysAllocString (L"") ;
	}

	//Testing
	//string sAccountId("");
	//ticket.GetAccountIdentifier(sTicket,bstrNamespace, sAccountId);

	return S_OK;
}
*/


// ----------------------------------------------------------------
// Arguments:     sNamespace - MPS namespace the authentication is for
//                sAccountIdentifier - accound identifier the authentication is for
//                lExpirationOffset - expiration time expressed as number of seconds from now
//                                    0 indicates ticket does not expire
// Return Value:  pTicket - the encrypted ticket returned as a string   
// Errors Raised: 
// Description:   The method returns an encrypted MPS authentication ticket that can be used by
//                to allow a subscriber to log into MPS for a particular namespace and accountidentifier.
// ----------------------------------------------------------------

STDMETHODIMP CTicketAgent::CreateTicketWithAdditionalData(BSTR sNamespace, BSTR sAccountIdentifier, long lExpirationOffset, BSTR sLoggedInAs, BSTR sApplicationName, BSTR *pTicket)
{
  // Make sure encryption key has been set
  if (mEncryptionKey.length()==0)
  {
    return Error("Error: The encryption key must be set prior to calling the CreateTicket method");
  }

	string sTicket;
	_bstr_t bstrNamespace(sNamespace);
	_bstr_t bstrAccountIdentifier(sAccountIdentifier);
	_bstr_t bstrLoggedInAs(sLoggedInAs);
	_bstr_t bstrApplicationName(sApplicationName);

	// Determine the expiration time
	time_t timeExpiration;
	if (lExpirationOffset!=0)
	{
		// Expiration is current time plus offset
		time(&timeExpiration);

		timeExpiration+=lExpirationOffset;
	}
	else
	{
		//Doesn't Expire
		timeExpiration=0;
	}

  //Create Ticket

	string sTemp;

	//Put time in string buffer
	char buffer[50];
	sprintf(buffer, "%d", timeExpiration);

  // convert to utf-8 before encryption
  string tempNamespace, tempAccountIdentifier, tempLoggedInAs, tempApplicationName;
  WideStringToUTF8((wchar_t*)bstrNamespace, tempNamespace);  
  WideStringToUTF8((wchar_t*)bstrAccountIdentifier, tempAccountIdentifier);
	WideStringToUTF8((wchar_t*)bstrLoggedInAs, tempLoggedInAs);
	WideStringToUTF8((wchar_t*)bstrApplicationName, tempApplicationName);

	sTemp=mDelimiter;
	sTemp+=tempNamespace;
	sTemp+=mDelimiter;
	sTemp+=tempAccountIdentifier;
	sTemp+=mDelimiter;
	sTemp+=buffer;
	sTemp+=mDelimiter;
	sTemp += tempLoggedInAs;
	sTemp += mDelimiter;
	sTemp += tempApplicationName;
	sTemp += mDelimiter;

  //Encrypt ticket

  char * pBuffer;
  long lenBuffer;

  encryptDES((char *) sTemp.c_str(), strlen(sTemp.c_str()), &pBuffer, &lenBuffer, mEncryptionKey);

	rfc1421encode((const unsigned char *)pBuffer, lenBuffer, sTicket);

  delete pBuffer;

  _bstr_t bstrTicket(sTicket.c_str());

	*pTicket = ::SysAllocString (bstrTicket) ;

	return S_OK;
}

STDMETHODIMP CTicketAgent::CreateTicket(BSTR sNamespace, BSTR sAccountIdentifier, long lExpirationOffset, BSTR *pTicket)
{
	return CreateTicketWithAdditionalData(sNamespace, sAccountIdentifier, lExpirationOffset, L"", L"", pTicket);
}

STDMETHODIMP CTicketAgent::get_Delimiter(BSTR *pVal)
{
	*pVal = mDelimiter.copy();
	return S_OK;
}

STDMETHODIMP CTicketAgent::put_Delimiter(BSTR newVal)
{
	mDelimiter=newVal;
	return S_OK;
}

STDMETHODIMP CTicketAgent::get_Key(BSTR *pVal)
{
	*pVal = mEncryptionKey.copy();

	return S_OK;
}

STDMETHODIMP CTicketAgent::put_Key(BSTR newVal)
{
  mEncryptionKey=newVal;

	return S_OK;
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

// ----------------------------------------------------------------
// Arguments:     Ticket - the encrypted ticket as a string
// Return Value:  pInterface - the interface pointer to the component containing the ticket properties   
// Errors Raised: returns E_FAIL if the expiration time has expired on the ticket
// Description:   The method takes an encrypted MPS authentication ticket and returns the namespace and
//                accountidentifier of the ticket. This method was added to allow custom applications to 
//                retrieve information from an existing ticket.
// ----------------------------------------------------------------

STDMETHODIMP CTicketAgent::RetrieveTicketProperties(BSTR Ticket, LPDISPATCH *pInterface)
{

  // Make sure encryption key has been set
  if (mEncryptionKey.length()==0)
  {
    return Error("Error: The encryption key must be set prior to calling the RetrieveTicketProperties method");
  }

  COMTICKETAGENTLib::ITicketPtr pTicket("MetraTech.Ticket.1");
  
  _bstr_t bstrNamespace;
  _bstr_t bstrAccountIdentifier;
	_bstr_t bstrLoggedInAs;
	_bstr_t bstrApplicationName;

  _bstr_t bstrTicket(Ticket,true);

	string sClearTextTicket;
	string sToken;               
	string sNamespace;
	string sAccountIdentifier;

	long ltimeExpiration;

  string sTicketAccountID;
  string sTicketNamespace;
	string sTicketLoggedInAs;
	string sTicketApplicationName;

	sTicketAccountID="";
	sTicketNamespace="";
	sTicketLoggedInAs = "";
	sTicketApplicationName = "";

 	vector<unsigned char> dest;
	if (rfc1421decode((const char*)bstrTicket, strlen(bstrTicket), dest) != ERROR_NONE)
	{
		return E_FAIL;
	}

	char * pInBuffer;
	pInBuffer = new char[dest.size()+1];

	memcpy(pInBuffer, &dest[0], dest.size());
	pInBuffer[dest.size()]='\0';

	char * pOutBuffer;
  long lenOutBuffer;

	decryptDES(pInBuffer, dest.size(), &pOutBuffer, &lenOutBuffer, mEncryptionKey);

	sClearTextTicket=pOutBuffer;

	delete pInBuffer;
	delete pOutBuffer;

	if (!sClearTextTicket.length())
	{
		//mLogger.LogThis(LOG_DEBUG, "Decrypted authentication ticket was empty");
		return Error("Decrypted authentication ticket is empty");
	}

	//Tokenize the string
	//(sClearTextTicket,1) refers to the first character of the ticket to be used as the delimiter
	vector<string> components;
	TokenizeTicket(components, sClearTextTicket);

	if (components.size() != 5)
		return false;

	sTicketNamespace = components[0];
	if (!sTicketNamespace.length())
		return false;

	sTicketAccountID= components[1]; 

	ltimeExpiration=atol(components[2].c_str());
	
	sTicketLoggedInAs = components[3];
	sTicketApplicationName = components[4];
	
	if (ltimeExpiration!=0)
	{
		//See if ticket has expired
		time_t ltimeCurrent;
		time(&ltimeCurrent);

    ltimeCurrent=ltimeCurrent+60;
		if (ltimeExpiration<ltimeCurrent)
		{
			char buffer[100];
			sprintf(buffer, "Ticket has expired by %d seconds", (ltimeCurrent-ltimeExpiration));
      /*
			string sMsg;
			sMsg = "Authorization Ticket expired by ";
			sMsg += buffer;
			sMsg += " seconds for account <" + sTicketAccountID + "> in namespace <" + sTicketNamespace + ">";
		    SetError(KIOSK_ERR_INVALID_USER_CREDENTIALS, ERROR_MODULE, ERROR_LINE, procName,sMsg);
			mLogger.LogErrorObject (LOG_WARNING, GetLastError());
      */
      return Error(buffer);
			//return Error("The ticket has expired");
		}
		else
		{
      /*
			char buffer[50];
			sprintf(buffer, "%d", (ltimeExpiration-ltimeCurrent));

			string sMsg;
			sMsg = "Authentication Ticket would have expired in ";
			sMsg += buffer;
			sMsg += " seconds for account <" + sTicketAccountID + "> in namespace <" + sTicketNamespace + ">";
			mLogger.LogThis(LOG_DEBUG, sMsg);
      */
		}
	}

  // convert utf-8 back to wide characters
  wstring tempNamespace;
  wstring tempAccountIdentifier;
	wstring tempLoggedInAs;
  wstring tempApplicationName;

  ASCIIToWide(tempNamespace, sTicketNamespace.c_str(), sTicketNamespace.length(), 65001);
  ASCIIToWide(tempAccountIdentifier, sTicketAccountID.c_str(), sTicketAccountID.length(), 65001);
	ASCIIToWide(tempLoggedInAs, sTicketLoggedInAs.c_str(), sTicketLoggedInAs.length(), 65001);
	ASCIIToWide(tempApplicationName, sTicketApplicationName.c_str(), sTicketApplicationName.length(), 65001);

  pTicket->Namespace = tempNamespace.c_str();
  pTicket->AccountIdentifier = tempAccountIdentifier.c_str();
	pTicket->LoggedInAs = tempLoggedInAs.c_str();
	pTicket->ApplicationName = tempApplicationName.c_str();

  *pInterface= (IDispatch *) pTicket.Detach();

	return S_OK;
}
