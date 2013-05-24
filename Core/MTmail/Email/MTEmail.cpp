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
* Created by: 
* $Header$
* 
***************************************************************************/

// MTEmail.cpp : Implementation of CMTEmail
#include "StdAfx.h"
#include "Email.h"
#include "MTEmail.h"
#include "MTEmailTagDefs.h"
#include "mtcomerr.h"
#include "ConfigDir.h"
#include "Smtp.h"

#import <MTConfigLib.tlb>
using namespace MTConfigLib;


/////////////////////////////////////////////////////////////////////////////
// CMTEmail
// ---------------------------------------------------------------------------
// Name:          init
// Arguments:     IMTEmailMessage * apEmailMessage -- a pointer to
//                                                    an EmailMessage object
//
// Return Value:  S_OK
// Errors Raised: Returns any COM errors that occur
//                E_FAIL - "Unable to create a NewMail Object"
// Description:   Initializes the Email Generator with an EmailMessage Object.
//                A CDONTS mail object is created
// ---------------------------------------------------------------------------

STDMETHODIMP CMTEmail::init(::IMTEmailMessage * apEmailMessage)
{
	
	try
	{
		mpEmailMessage.Attach((EMAILMESSAGELib::IMTEmailMessage *)apEmailMessage, true);
	}
	catch (_com_error e)
	{	
		return ReturnComError(e);
	}

	mAttachmentFileNames.clear();
	mInitialized = TRUE;
	
	return S_OK;
}

// ---------------------------------------------------------------------------
// Name:          Send
// Arguments:     <none>
// Return Value:  S_OK
// Errors Raised: Returns all COM Errors encountered
//                E_FAIL -- if no recipient specified OR if the CDONTS send fails
// Description:   This function populates the properties of the CDONTS mail object
//                then calls the CDONTS object Send method to send the email.
//                Additionally,  a check is made to ensure that a recipient for
//                the message has been specified.
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::Send()
{
	_bstr_t MsgTo;
	
	try 
	{
		CSMTPMessage msg;
		msg.SetImportance(CSMTPMessage::IMPORTANCE(mpEmailMessage->GetImportance()));
		msg.SetBodyFormat(CSMTPMessage::BODY_FORMAT(mpEmailMessage->GetBodyFormat()));

		MsgTo = mpEmailMessage->GetTo();
		if(MsgTo.length() < 1)
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:No recipient specified for message.";
			return Error((char *)ErrorString);
		}

		msg.AddMultipleRecipients((wchar_t*)mpEmailMessage->GetCC(), CSMTPMessage::CC);
		msg.AddMultipleRecipients((wchar_t*)mpEmailMessage->GetBcc(), CSMTPMessage::BCC);
		msg.AddMultipleRecipients((wchar_t*)mpEmailMessage->GetTo(), CSMTPMessage::TO);

		msg.m_From = CSMTPAddress((wchar_t*)mpEmailMessage->GetFrom());

		msg.AddBody((wchar_t*)mpEmailMessage->GetBody());
		msg.m_sSubject = mpEmailMessage->GetSubject();

		std::vector<CSMTPAttachment> attachments;
		attachments.resize(mAttachmentFileNames.size());
		for (size_t i = 0; i < attachments.size() ; i++)
		{
			if(!attachments[i].Attach((wchar_t*)mAttachmentFileNames[i]))
			{
				_bstr_t ErrorString = "**Error** MTEmail.Email:cannot attach file " + mAttachmentFileNames[i];
				return Error((char *)ErrorString);
			}
			msg.AddAttachment(&(attachments[i]));
		}

		//Create the SMTP connection
		CSMTPConnection smtp;

		// set timeout in milliseconds
		smtp.SetTimeout(mSmtpTimeout*1000);

		//Connect to the server
		if (!smtp.Connect(mSmtpServer, mSmtpPort))
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:failed to connect to SMTP server " + mSmtpServer + ": ";

			if(smtp.GetLastErrorCode())
			{
				ErrorString += smtp.GetLastError()->GetProgrammerDetail().c_str();
			}

			return Error((char *)ErrorString);
		}

		//Send the message
		if (!smtp.SendMessage(msg))
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:failed to send SMTP message: ";
			if(smtp.GetLastErrorCode())
			{
				ErrorString += smtp.GetLastError()->GetProgrammerDetail().c_str();
			}
			return Error((char *)ErrorString);
		}

		//Disconnect from the server
		smtp.Disconnect();
	}
	catch (_com_error e)
	{
		return ReturnComError(e);
	}
	
	//do not work without re-initialization
	mInitialized = FALSE;
	
	return S_OK;
}
// ---------------------------------------------------------------------------
// Name:          AttachFile 
// Arguments:     BSTR apFilename - the path of the file to attach
// Return Value:  S_OK    
// Errors Raised: COM Errors
// Description:   Attachs a file to the email message
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::AttachFile(BSTR apfilename)
{
	// check, if file exists and we have read permissions to attach it...
	if(_waccess(apfilename, 04) != 0)
	{
		_bstr_t ErrorString("**Error** MTEmail.Email: Cannot attach file ");
		ErrorString += apfilename;
		return Error(LPCOLESTR(ErrorString), IID_IMTEmail, E_FAIL);
	}

	mAttachmentFileNames.push_back(apfilename);
	return S_OK;
}
// ---------------------------------------------------------------------------
// Name:          AttachURL
// Arguments:     BSTR apSource           - The source URL of the attachment
//                BSTR apContentLocation  - Equivalent of the Base URL for
//                                          the URL source
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Attach a URL from a specified location to the email
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::AttachURL(BSTR apSource, BSTR apContentLocation)
{
	return Error("**Error** MTEmail.Email: AttachURL is not implemented", IID_IMTEmail, E_NOTIMPL);
}

// ---------------------------------------------------------------------------
// Name:          put_TemplateFile
// Arguments:     BSTR newVal -- The path of the email template file
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Set the path of the email template
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::put_TemplateFileName(BSTR newVal)
{
	try
	{
		mTemplateFileName = newVal;
	}
	
	catch (_com_error e)
	{
		return ReturnComError(e);
	}
	
	return S_OK;
}
// ---------------------------------------------------------------------------
// Name:          put_TemplateName
// Arguments:     BSTR newVal -- Name of the template
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Set the name of the template to use (this template is contained
//                in the template file.
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::put_TemplateName(BSTR newVal)
{
	try
	{
		mTemplateName = newVal;
	}
	
	catch (_com_error e)
	{
		return ReturnComError(e);
	}


	return S_OK;
}
// ---------------------------------------------------------------------------
// Name:          put_TemplateLanguage
// Arguments:     BSTR newVal -- Language of the template
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Set the language to the template to use (Contained in the template)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::put_TemplateLanguage(BSTR newVal)
{
	try
	{
		mTemplateLanguage = newVal;
	}
	
	catch (_com_error e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}
// ---------------------------------------------------------------------------
// Name:          AddParam
// Arguments:     BSTR Name   -- Variable Name to replace
//                BSTR Value  -- Value to replace 'Name' with
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Replace all occurrences of 'Name' with 'Value' in the message
//                subject and body.
// ---------------------------------------------------------------------------
STDMETHODIMP CMTEmail::AddParam(BSTR Name, BSTR Value)
{
	_bstr_t bString;
	_bstr_t bReturn;
	
	//if nothing has been loaded, then fail
	if(mInitialized == FALSE)
	{
		_bstr_t ErrorString("**Error** MTEmail.Email:Email object has not been initialized.");
		return Error((char *)ErrorString);
	}
	
	//Get the body 
	bString = mpEmailMessage->GetBody();
	
	if(bString.length() > 0)
		mpEmailMessage->PutMessageBody(ReplaceString(Name, Value, bString));
	
	//Get the subject
	bString = mpEmailMessage->GetSubject();
	
	if(bString.length() > 0)
		mpEmailMessage->PutMessageSubject(ReplaceString(Name, Value, bString));
	
	
  return(S_OK);
}

////////////////////////////
// ReplaceString          //
///////////////////////////
// ---------------------------------------------------------------------------
// Name:          ReplaceString
// Arguments:     BSTR Name     -- Name to search for 
//                BSTR Value    -- Value to substitute for 'Name'
//                BSTR String   -- String to search in
// Return Value:  S_OK
// Errors Raised: COM Errors
// Description:   Replace all occurrences of Name
// ---------------------------------------------------------------------------
BSTR CMTEmail::ReplaceString(BSTR Name, BSTR Value, BSTR String)
{
  wchar_t *wcb;
  wchar_t *wcName = (wchar_t *)Name;
  wchar_t *wcValue = (wchar_t *)Value;
  
  _bstr_t bMessage = String;
  wchar_t *wcMessage = (wchar_t *)bMessage;

  _bstr_t NewMsg;

  //Find the first instance of name in our message
  wcb = wcsstr(wcMessage, wcName);
    
  while(wcb != NULL)  //while we can find our tag
  {
    *wcb = L'\0';   //mark as null
   
    //Put the contents of the message upto the tag into the new message, then add the new value
    NewMsg = NewMsg + wcMessage + wcValue;

     //Advance pointer to original message past end of tag
    wcMessage = wcb + wcslen(wcName);
    
    //find the next (if any) occurrence of the tag
    wcb = wcsstr(wcMessage, wcName);
  }

  //No more tags...put the rest of the old message into the new message
  NewMsg = NewMsg + wcMessage;
  
  return(NewMsg);
}
// ---------------------------------------------------------------------------
// Name:          LoadTemplate
// Arguments:     <none>
// Return Value:  S_OK
// Errors Raised: COM Errors
//                E_FAIL -- Email Generator has not been initialized
//                E_FAIL -- A valid template was not specified
//                E_FAIL -- Unable to create an instance of a PropSet object
//                E_FAIL -- The specified language could not be found in the 
//                          template
//                E_FAIL -- A COM error occurred.
// Description:   Loads the language-specific template from the specified file
//                and populates the EmailMessage object based on the fields 
//                defined in the template.
// ---------------------------------------------------------------------------
////////////////////////////////////////////////////////////////

STDMETHODIMP CMTEmail::LoadTemplate()
{
	if (mInitialized == FALSE)
	{
		_bstr_t ErrorString = "**Error** MTEmail.Email:Object not initialized.";
		return Error((char *)ErrorString);
	}

	HRESULT hr = ReadConfig();
	if(FAILED(hr))
		return hr;
	
	VARIANT_BOOL CheckSumMatch;
	
	BOOL bFoundLanguage = FALSE;
	
	_bstr_t PropVal;      //value returned from PropSet, also used to set emailmessage properties
	
	
	if(mTemplateFileName.length() < 1 || mTemplateName.length() < 1 || mTemplateLanguage.length() < 1)
	{
		_bstr_t ErrorString = "**Error** MTEmail.Email:Template Information Incomplete ";
		
		if( mTemplateFileName.length() < 1)
			ErrorString += "-- Template file not specified.";
		
		if( mTemplateName.length() < 1 )
			ErrorString += "-- Template name not specified.";
		
		if( mTemplateLanguage.length() < 1)
			ErrorString += "-- Template language not specified.";
		
		
		return Error((char *)ErrorString, NULL, 0);
	}
	
	//Use PropSet to attempt to parse the template file
	try
	{
		
		MTConfigLib::IMTConfigPtr pConfig;
		
		hr = pConfig.CreateInstance("MetraTech.MTConfig.1");
		if(FAILED(hr))
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:Unable to create PropSet object.";
			return Error((char *)ErrorString);
		}
		
		//read in the template file
		MTConfigLib::IMTConfigPropSetPtr pPropSet;
		pPropSet = pConfig->ReadConfiguration(mTemplateFileName, &CheckSumMatch);
		
		//get the set of templates
		MTConfigLib::IMTConfigPropSetPtr pPropTemplateSet;
		pPropTemplateSet = pPropSet->NextSetWithName(EMAIL_SET_TAG);
		
		//search for the name tag
		PropVal = pPropTemplateSet->NextStringWithName(EMAIL_NAME);
		
		//If we didn't get the name we wanted on the first try, check all template names
		//If the template can't be found, NextString...an exeption is thrown
		while(wcscmp(PropVal, mTemplateName))
			PropVal = pPropTemplateSet->NextStringWithName(EMAIL_NAME);
		
		
		//Since we got here, we found the template name...now look for the correct language
		//The language tag must immediately follow the template name
		MTConfigLib::IMTConfigPropPtr pProp;
		
		
		//Now check for the language we want
		//loop until we get to the next template name
		while(wcscmp(PropVal, (_bstr_t)EMAIL_NAME))
		{
			pProp = pPropTemplateSet->Next();
			
			PropVal = pProp->GetName();
			
			if (!wcscmp(PropVal, (_bstr_t)EMAIL_LANG))
			{
				if (!wcscmp((_bstr_t)pProp->GetPropValue(), mTemplateLanguage))
				{
					bFoundLanguage = TRUE;
					break;
				}
			}
		}
		
		if(bFoundLanguage == FALSE)
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:Unable to find language: ";
			ErrorString += mTemplateLanguage;
			ErrorString += " in template: ";
			ErrorString += mTemplateName;
			ErrorString += ".";
			
			return Error((char *)ErrorString);
		}
		
		//Otherwise, we did find the language, now we can begin parsing the data
		MTConfigLib::IMTConfigPropSetPtr pDefaultSet;
		pDefaultSet = pPropTemplateSet->NextSetWithName(EMAIL_DEF_SET_TAG);
		
		pProp = pDefaultSet->Next();
		
		_bstr_t Temp;

		mpEmailMessage->PutMessageImportance(1);

		
		while(pProp != NULL)
		{
			Temp = pProp->GetName();
			
			if(!strcmp(Temp, EMAIL_TO_TAG))
				mpEmailMessage->PutMessageTo((_bstr_t)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_FROM_TAG)) 
				mpEmailMessage->PutMessageFrom((_bstr_t)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_SUBJECT_TAG))
				mpEmailMessage->PutMessageSubject((_bstr_t)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_CC_TAG))
				mpEmailMessage->PutMessageCC((_bstr_t)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_BCC_TAG))
				mpEmailMessage->PutMessageBcc((_bstr_t)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_IMPORTANCE_TAG))
				mpEmailMessage->PutMessageImportance((long)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_MAILFORMAT_TAG))
				mpEmailMessage->PutMessageMailFormat((long)pProp->GetPropValue());
			
			else if(!strcmp(Temp, EMAIL_BODYFORMAT_TAG))
				mpEmailMessage->PutMessageBodyFormat((long)pProp->GetPropValue());
			
			pProp = pDefaultSet->Next(); 
		}
		
		mpEmailMessage->PutMessageBody(pPropTemplateSet->NextStringWithName(EMAIL_MESSAGE_BODY_TAG));
  } 
  
  catch (_com_error e)
  {
	  _bstr_t eMsg = e.Description();
	  
	  if(eMsg.length() < 1)
	  {
		  eMsg = "**Error** MTEmail.Email:Unknown error in LoadTemplate()";
		  return Error((char *)eMsg);
	  }
	  else
		  return Error((char *)e.Description());
	  
  }
  
  return S_OK;
}

HRESULT CMTEmail::ReadConfig()
{
	// default server and port
	mSmtpServer = L"localhost";
	mSmtpPort = 25;
	mSmtpTimeout = 30;

	try
	{
		_bstr_t PropVal;      //value returned from PropSet, also used to set emailmessage properties
		VARIANT_BOOL CheckSumMatch;
		HRESULT hr;

		MTConfigLib::IMTConfigPtr pConfig;
		
		hr = pConfig.CreateInstance("MetraTech.MTConfig.1");
		if(FAILED(hr))
		{
			_bstr_t ErrorString = "**Error** MTEmail.Email:Unable to create PropSet object.";
			return Error((char *)ErrorString);
		}
		
		//read in the template file
		std::string strConfigDir;
		GetMTConfigDir(strConfigDir);

		MTConfigLib::IMTConfigPropSetPtr pPropSet;
		pPropSet = pConfig->ReadConfiguration(std::string(strConfigDir + "\\email\\email.xml").c_str(), &CheckSumMatch);
		
		//get the set of templates
		MTConfigLib::IMTConfigPropSetPtr pPropSmtpSet;
		pPropSmtpSet = pPropSet->NextSetWithName(EMAIL_SMTP_SET_TAG);
		
		//search for the server address tag
		if (pPropSmtpSet->NextMatches(EMAIL_SMTP_SERVER_ADDRESS_TAG, PROP_TYPE_STRING) == VARIANT_TRUE)
		{
			mSmtpServer = pPropSmtpSet->NextStringWithName(EMAIL_SMTP_SERVER_ADDRESS_TAG);
		}
		// search for server port tag.
		if (pPropSmtpSet->NextMatches(EMAIL_SMTP_SERVER_PORT_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
		{
			mSmtpPort = pPropSmtpSet->NextLongWithName(EMAIL_SMTP_SERVER_PORT_TAG);
		}
		// search for server timeout tag.
		if (pPropSmtpSet->NextMatches(EMAIL_SMTP_SERVER_TIMEOUT_TAG, PROP_TYPE_INTEGER) == VARIANT_TRUE)
		{
			mSmtpTimeout = pPropSmtpSet->NextLongWithName(EMAIL_SMTP_SERVER_TIMEOUT_TAG);
		}
	}
	catch (_com_error e)
	{
	  _bstr_t eMsg = e.Description();
  
	  if(eMsg.length() < 1)
	  {
		  eMsg = "**Error** MTEmail.Email:Unknown error in LoadTemplate()";
		  return Error((char *)eMsg);
	  }
	  else
		  return Error((char *)e.Description());
  	}
	return S_OK;
}
