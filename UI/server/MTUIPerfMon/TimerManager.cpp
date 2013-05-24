// TimerManager.cpp : Implementation of CTimerManager
#include "StdAfx.h"
#include "MTUIPerfMon.h"
#include "TimerManager.h"

/////////////////////////////////////////////////////////////////////////////
// CTimerManager

STDMETHODIMP CTimerManager::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ITimerManager
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
/////////////////////////////////////////////////////////////////////////////
//  Function      : Initialize(strAppID, strDate)                          //
//  Description   : Initialize the report manager.  An XML Document will   //
//                : be created and initialized.                            //
//  Inputs        : strAppID  -- ID of the application                     //
//                : strDate   -- Date and time of application init.        //
//  Outputs       : none                                                   //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CTimerManager::Initialize(BSTR strAppID, BSTR strDate)
{
  MSXML2::IXMLDOMDocumentPtr pXMLDoc("MSXML2.DOMDocument.4.0");         //XML DOMDocument
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;                      //XML parse error object
  MSXML2::IXMLDOMNodePtr pApplicationNode = NULL;                       //Application node
  MSXML2::IXMLDOMNodePtr pNode;                                         //General purpose node

  RCDLib::IMTRcdPtr pRCD("MetraTech.RCD");
  _bstr_t strConfigPath;
  _bstr_t strQuery;
  _bstr_t strXML;
  long lngErrorCode = 0;
  
  try {
    pXMLDoc->async = VARIANT_FALSE;


    //Load the configuration file
    strConfigPath = pRCD->ConfigDir + "UIPerfMon\\UIPerfMonConfig.xml";

    if(pXMLDoc->load(strConfigPath) == false)    
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- Unable to open configuration file.", IID_ITimerManager, 0)));
    
    //Check for parse error
    pParseError = pXMLDoc->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0)
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- A parse error occurred while reading the configuration file.", IID_ITimerManager, 0)));
    

    //Now get the configuration for the specified report
    strQuery = _bstr_t(L"/mt_perfmon_config/application[@name='") + strAppID + _bstr_t(L"']");

    pApplicationNode = pXMLDoc->selectSingleNode(strQuery);

    //Check if entry is found
    if(pApplicationNode == NULL)
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- Unable to find application entry in configuration file.", IID_ITimerManager, 0)));


    pNode = pApplicationNode->selectSingleNode(L"report_path");

    if(pNode == NULL)
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- Unable to get report path for the application entry.", IID_ITimerManager, 0)));

    //Get the report path
    mstrReportPath = pRCD->InstallDir + pNode->text;


    //Now create the application data set
    strXML = _bstr_t(L"<application><id>") + strAppID + _bstr_t(L" ") + strDate + _bstr_t(L"</id></application>");
    
    //Load the XML into the global doc.
    if(mpXMLDoc->loadXML(strXML) == false)
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- Unable to load generated XML.  Something is not right!", IID_ITimerManager, 0)));

    pParseError = mpXMLDoc->parseError;

    lngErrorCode = pParseError->errorCode;
    
    if(lngErrorCode != 0)
      return(returnUIPerfMonError(Error("CTimerManager::Initialize -- A parse error occurred while reading the generated XML.  Doh!", IID_ITimerManager, 0)));

    //We are done!
  }
  
  catch(_com_error& err)
	{
    return(returnUIPerfMonError(err));
  }

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Function    : InitializeTimerXML(BSTR strSessionID, BSTR strDate,      //
//              :                    BSTR *strXML)                         //
//  Description : Provide XML for the timer XML document to use.           //
//  Inputs      : strSessionID -- ID of the session on the server.         //
//              : strDate      -- Date and time of session start.          //
//  Outputs     : strXML       -- XML string                               //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CTimerManager::InitializeTimerXML(BSTR strSessionID, BSTR *strXML)
{
	_bstr_t strTempXML;

  try {
  //Generate the XML
  strTempXML = _bstr_t(L"<session><id>") + strSessionID + _bstr_t(L"</id><results /></session>");
  
  //Get the XML
  *strXML = strTempXML.copy();

  }
  
  catch(_com_error& err)
	{
    return(returnUIPerfMonError(err));
  }

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Function    : StoreTimerXML(strXML)                                    //
//  Description : Store the supplied session XML in the overall document.  //
//  Inputs      : strXML  --  XML to store.                                //
//  Outputs     : none                                                     //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CTimerManager::StoreTimerXML(BSTR strXML)
{
  MSXML2::IXMLDOMDocumentPtr pXMLDoc("MSXML2.DOMDocument.4.0");
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;
  MSXML2::IXMLDOMNodePtr pSessionNode = NULL;
  long lngErrorCode = 0;

  try {
    //Attempt to load the document
     if(pXMLDoc->loadXML(strXML) == false)
      return(returnUIPerfMonError(Error("CTimerManager::StoreTimerXML -- Unable to load the supplied XML string.", IID_ITimerManager, 0)));

    //Check for parse error
    pParseError = pXMLDoc->parseError;

    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0)
      return(returnUIPerfMonError(Error("CTimerManager::StoreTimerXML -- A parse error occurred while loading the supplied XML string.", IID_ITimerManager, 0)));

    //Add the session
    pSessionNode = pXMLDoc->selectSingleNode("/session");

    if(pSessionNode == NULL)
      return(returnUIPerfMonError(Error("CTimerManager::StoreTimerXML -- Error getting the session data from the XML.", IID_ITimerManager, 0)));


    HRESULT hr = mpXMLDoc->documentElement->appendChild(pSessionNode);
    if(FAILED(hr))
      return(returnUIPerfMonError(Error("CTimerManager::StoreTimerXML -- An error occurred while adding the XML to the stored document.", IID_ITimerManager, 0)));
  }
  
  catch(_com_error& err)
	{
    return(returnUIPerfMonError(err));
  }

	return S_OK;
}
/////////////////////////////////////////////////////////////////////////////
//  Function      : WriteOutputXMLFile()                                   //
//  Description   : Write the test result set to the specified file.       //
//  Inputs        : none                                                   //
//  Outputs       : none                                                   //
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CTimerManager::WriteOutputXMLFile()
{
  MSXML2::IXMLDOMDocumentPtr pXMLDoc("MSXML2.DOMDocument.4.0");
  MSXML2::IXMLDOMNodePtr pNode = NULL;
  MSXML2::IXMLDOMParseErrorPtr pParseError = NULL;
  long lngErrorCode = 0;
  HRESULT hr;

  try {
    //Try to load the report config file, otherwise generate a new document
    pXMLDoc->async = false;

    if(pXMLDoc->load(mstrReportPath) == false)
      pXMLDoc->loadXML(L"<mt_script_performance />");

//      return(returnUIPerfMonError(Error("CTimerManager::WriteOutputXMLFile -- Unable to load report file to append data.", IID_ITimerManager, 0)));
  
    //Check for parse error
    pParseError = pXMLDoc->parseError;
    
    lngErrorCode = pParseError->errorCode;

    if(lngErrorCode != 0)
      return(returnUIPerfMonError(Error("CTimerManager::WriteOutputXMLFile -- A parse error occurred when loading the report path.", IID_ITimerManager, 0)));

    //Get the node for the document
    pNode = pXMLDoc->selectSingleNode("/mt_script_performance");


    //Add the node to the reports doc.
    hr = pNode->appendChild(mpXMLDoc->documentElement);

    if(FAILED(hr))
      return(returnUIPerfMonError(Error("CTimerManager::WriteOutputFile -- An error occurred when adding the application data to the report XML.", IID_ITimerManager, 0)));

    //Save the document
    hr = pXMLDoc->save(mstrReportPath);

    if(FAILED(hr))
      return(returnUIPerfMonError(Error("CTimerManager::WriteOutputXMLFile -- An error occurred while saving the test results.", IID_ITimerManager, 0)));

  }

  catch(_com_error &err)
  {
    return(returnUIPerfMonError(err));
  }

  return S_OK;
}
