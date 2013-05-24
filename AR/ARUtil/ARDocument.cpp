/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "ARDocument.h"
#include <comdef.h>
#include <mtcomerr.h>

#define DOMDOC_PROGID "MSXML2.DOMDocument.4.0"

ARDocument::ARDocument()
: mDomDoc(DOMDOC_PROGID)
{
  
}

ARDocument::~ARDocument()
{
}

ARDocument::ARDocument(const wchar_t* xml)
: mDomDoc(DOMDOC_PROGID)
{
  operator=(xml);
}

ARDocument::ARDocument(const ARDocument& arDoc)
{
  operator=(arDoc);
}


ARDocument::ARDocument(const MSXML2::IXMLDOMDocumentPtr& domDoc)
{
  operator=(domDoc);
}

ARDocument& ARDocument::operator=(const wchar_t* xml)
{
  if(!mDomDoc->loadXML(xml))
  {
    MT_THROW_COM_ERROR("parse error");
  }
  
  return *this;
}

ARDocument& ARDocument::operator=(const ARDocument& arDoc)
{
  operator=(arDoc.mDomDoc);

  return *this;
}

ARDocument& ARDocument::operator=(const MSXML2::IXMLDOMDocumentPtr& domDoc)
{
  //copy (clone) the document
  mDomDoc = domDoc->cloneNode(VARIANT_TRUE);

  return *this;
}

void ARDocument::AddChild(ARDocument& doc)
{
  //AddChild takes the document over, leaving the passed-in doc empty
  
  MSXML2::IXMLDOMNodePtr root = mDomDoc->documentElement;
  MSXML2::IXMLDOMNodePtr child = doc.mDomDoc->documentElement;

  root->appendChild(child);
}

MSXML2::IXMLDOMDocumentPtr ARDocument::GetAsDomDoc()
{
  return mDomDoc;
}

_bstr_t ARDocument::GetAsString()
{
  return mDomDoc->xml;
}

void ARDocument::SetStringProperty(const _bstr_t& name, const _bstr_t& value)
{
  //!!fix me (common, faster function for finding the node)
  _bstr_t path = "//" + name; 
  MSXML2::IXMLDOMNodePtr node = mDomDoc->selectSingleNode(path);
  if (node == NULL)
    MT_THROW_COM_ERROR("Cannot find node: %S in doc %S", (const wchar_t*) name, (const wchar_t*) mDomDoc->xml);

  node->text = value;
}

void ARDocument::SetLongProperty(const _bstr_t& name, long value)
{
	char buffer[50];
	sprintf(buffer, "%d", value);
  SetStringProperty(name, buffer);
}

void ARDocument::SetDoubleProperty(const _bstr_t& name, double value)
{
	char buffer[50];
	sprintf(buffer, "%f", value);
  SetStringProperty(name, buffer);
}

void ARDocument::SetDateTimeProperty(const _bstr_t& name, time_t value)
{
  string str;
	::MTFormatISOTime(value, str);
  SetStringProperty(name, str.c_str());
}

void ARDocument::SetBoolProperty(const _bstr_t& name, bool value)
{
  if(value)
    SetStringProperty(name, "true");
  else
    SetStringProperty(name, "false");
}

void ARDocument::SetDecimalProperty(const _bstr_t& name, const _variant_t& value)
{
  //use variant's conversion from DECIMAL to BSTR
  _bstr_t str = value;
  
  SetStringProperty(name, str);
}

void ARDocument::SetLongLongProperty(const _bstr_t& name, __int64 value)
{
	char buffer[50];
	sprintf(buffer, "%I64d", value);
  SetStringProperty(name, buffer);
}

