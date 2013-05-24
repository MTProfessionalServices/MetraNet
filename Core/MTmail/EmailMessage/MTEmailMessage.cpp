// MTEmailMessage.cpp : Implementation of CMTEmailMessage
#include "StdAfx.h"
#include "EmailMessage.h"
#include "MTEmailMessage.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEmailMessage


STDMETHODIMP CMTEmailMessage::put_MessageBody(BSTR newVal)
{
  mMessageBody = newVal;
	return S_OK;
}


STDMETHODIMP CMTEmailMessage::put_MessageTo(BSTR newVal)
{
	mMessageTo = newVal;	
	return S_OK;
}

STDMETHODIMP CMTEmailMessage::put_MessageFrom(BSTR newVal)
{
	mMessageFrom = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::put_MessageCC(BSTR newVal)
{
	mMessageCC = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::put_MessageSubject(BSTR newVal)
{

 mMessageSubject = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_Body(BSTR *pVal)
{
	// TODO: Add your implementation code here

	* pVal = mMessageBody.copy();

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_CC(BSTR *pVal)
{
	// TODO: Add your implementation code here

	*pVal = mMessageCC.copy();

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_From(BSTR *pVal)
{
	// TODO: Add your implementation code here
	* pVal = mMessageFrom.copy();
	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_Subject(BSTR *pVal)
{
	// TODO: Add your implementation code here
	* pVal = mMessageSubject.copy();

	return S_OK;
}


STDMETHODIMP CMTEmailMessage::get_To(BSTR *pVal)
{
	// TODO: Add your implementation code here
	* pVal = mMessageTo.copy();
	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_Bcc(BSTR *pVal)
{
	// TODO: Add your implementation code here

	* pVal = mMessageBcc.copy();

	return S_OK;
}


STDMETHODIMP CMTEmailMessage::put_MessageBcc(BSTR newVal)
{
	// TODO: Add your implementation code here
	
	mMessageBcc = newVal;

	return S_OK;
}


STDMETHODIMP CMTEmailMessage::put_MessageBodyFormat(long newVal)
{
	// TODO: Add your implementation code here

	mMessageBodyFormat = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_BodyFormat(long *pVal)
{
	// TODO: Add your implementation code here
	
	* pVal = mMessageBodyFormat;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::put_MessageImportance(long newVal)
{
	// TODO: Add your implementation code here

	mMessageImportance = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_Importance(long *pVal)
{
	// TODO: Add your implementation code here
	
	* pVal = mMessageImportance;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::put_MessageMailFormat(long newVal)
{
	// TODO: Add your implementation code here
	
	mMessageMailFormat = newVal;

	return S_OK;
}

STDMETHODIMP CMTEmailMessage::get_MailFormat(long *pVal)
{
	// TODO: Add your implementation code here
	
	* pVal = mMessageMailFormat;

	return S_OK;
}

