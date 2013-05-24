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

#ifndef __ARDOCUMENT_H_
#define __ARDOCUMENT_H_

#include <string>
#import <msxml4.dll>

using std::wstring;
using std::string;


// a XML document used for building documents for the ARInterface
class ARDocument
{
public:
  ARDocument();

  ARDocument(const wchar_t* xml);
  ARDocument(const ARDocument& arDoc);
  ARDocument(const MSXML2::IXMLDOMDocumentPtr& domDoc);

  ~ARDocument();

  ARDocument& operator=(const wchar_t* xml);
  ARDocument& operator=(const ARDocument& arDoc);
  ARDocument& operator=(const MSXML2::IXMLDOMDocumentPtr& domDoc);

  void SetStringProperty(const _bstr_t& name, const _bstr_t& value);
  void SetLongProperty(const _bstr_t& name, long value);
  void SetDoubleProperty(const _bstr_t& name, double value);
  void SetDateTimeProperty(const _bstr_t& name, time_t value);
  void SetBoolProperty(const _bstr_t& name, bool value);
  void SetDecimalProperty(const _bstr_t& name, const _variant_t& value);
  void SetLongLongProperty(const _bstr_t& name, __int64 value);

  void AddChild(ARDocument& doc);

  MSXML2::IXMLDOMDocumentPtr GetAsDomDoc();
  _bstr_t GetAsString();

  //data
private:
  MSXML2::IXMLDOMDocumentPtr mDomDoc;
};


#endif
