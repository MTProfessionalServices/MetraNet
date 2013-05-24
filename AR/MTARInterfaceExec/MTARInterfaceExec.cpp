// MTARInterfaceExec.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f MTARInterfaceExecps.mk in the project directory.

#include "StdAfx.h"
#include "resource.h"
#include <initguid.h>
#include <mtglobal_msg.h>
#include "MTARInterfaceExec.h"

#include "MTARInterfaceExec_i.c"
#include "IMTARInterface_i.c"

#include "MTARConfig.h"
#include "MTARWriter.h"
#include "MTARReader.h"


namespace ARInterfaceExec {
  char pARLogMsg[] = "AR";
  char pARLogDir[] = "logging\\AR";
};

MTAutoInstance<MTAutoLoggerImpl<ARInterfaceExec::pARLogMsg, ARInterfaceExec::pARLogDir> > mARLogger;


void AppendDoc(_bstr_t& aMsg, BSTR aXmlDoc)
{
  if (aXmlDoc != NULL)
  { aMsg += ":\r\n";
    
    wstring xml = (_bstr_t)aXmlDoc;
    
    //replace "><" with ">\n"<" as poor man's XML pretty print
    wstring::size_type i = 0;
    while(wstring::npos != (i = xml.find(L"><", i)))
    { xml.replace(i, 2, L">\n<");
    }
    
    aMsg += xml.c_str();
  }
}

void ARLog(const wchar_t* aMsg, MTLogLevel aLogLevel)
{
  mARLogger->LogThis(aLogLevel, aMsg);
}

void ARLogMethod(ARInterfaceMethod aMethod, BSTR aInputDoc /*= NULL*/, bool isAREnabled /*= true*/)
{
  if (mARLogger->IsOkToLog(LOG_DEBUG))
  {
    _bstr_t msg;

    if (!isAREnabled)
    {
      msg += "DISABLED - ";
    }

    msg += ARInterfaceMethodToString(aMethod).c_str();
 
    AppendDoc(msg, aInputDoc);
    ARLog(msg);
  }
}

void ARLogMethodSuccess(ARInterfaceMethod aMethod, BSTR aOutputDoc /*= NULL*/)
{
  if (mARLogger->IsOkToLog(LOG_DEBUG))
  {
    _bstr_t msg;

    msg = ARInterfaceMethodToString(aMethod).c_str();
    msg += " succeeded";

    AppendDoc(msg, aOutputDoc);
    ARLog(msg);
  }
}

void ARLogMethodFailure(ARInterfaceMethod aMethod, _com_error & err)
{
  if (mARLogger->IsOkToLog(LOG_DEBUG))
  {
    _bstr_t msg;

    msg = "ERROR: ";
    msg += ARInterfaceMethodToString(aMethod).c_str();
    msg += " failed";
    
    string errMsg;
    StringFromComError(errMsg, "\n", err);
    
    //replace "><" with ">\n"<" as poor man's XML pretty print
    wstring::size_type i = 0;
    while(wstring::npos != (i = errMsg.find("><", i)))
    { errMsg.replace(i, 2, ">\n<");
    }

    msg += errMsg.c_str();

    ARLog(msg);
  }
}

HRESULT ReturnTranslatedARError( _com_error & err)
{
  _bstr_t ARMsg; // message received from A/R
  _bstr_t metraMsg; //message returned to MetraNet

  try
  {
    try
    {
      // AR errors are returned in Description in XML format
      ARMsg = err.Description();

      //translate error from:
      //  <ARDocuments><ARDocument><Errors>
      //    <Error><Code>991</Code><Message>message 1</Message></Error>
      //    <Error><Code>992</Code><Message>message 2</Message></Error>
      //  </Errors></ARDocument></ARDocuments>
      // to human readable format:
      // "[991] message1, [992] message 2"

      MSXML2::IXMLDOMDocumentPtr domDoc = MSXML2::IXMLDOMDocumentPtr(AR_DOMDOC_PROGID);
    
      VARIANT_BOOL canLoad = domDoc->loadXML(ARMsg);
      if(canLoad)
      {
        MSXML2::IXMLDOMNodeListPtr nodes = domDoc->selectNodes("//Error");
        for(int i = 0; i < nodes->length; i++)
        {
          MSXML2::IXMLDOMNodePtr node = nodes->item[i];
          _bstr_t errCode = node->selectSingleNode("./Code")->text;
          _bstr_t text = node->selectSingleNode("./Message")->text;
  
          if (metraMsg.length() > 0)
          { metraMsg += ", ";
          }
        
          metraMsg += "[" + errCode + "] " + text;
        }
      }
      else
      {
        MT_THROW_COM_ERROR("could not parse AR message");
      }
    }
    catch(...)
    {
      // A/R message could not be parsed completely, 
      mARLogger->LogVarArgs(LOG_ERROR, "Failed to parse A/R error: %s", (const char*)ARMsg );

      // return A/R message instead 
      metraMsg = ARMsg;
    }

    // return "A/R Error: <metraMsg>"
    MT_THROW_COM_ERROR(MTAR_AR_INTERFACE_ERROR_WITH_MSG, (const char*)metraMsg);
  }
  catch(_com_error& err)
  {
    // all code paths should end up here
    return ReturnComError(err);
  }
 
  ASSERT(0);
  return ReturnComError(err);
}

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_MTARConfig, CMTARConfig)
OBJECT_ENTRY(CLSID_MTARWriter, CMTARWriter)
OBJECT_ENTRY(CLSID_MTARReader, CMTARReader)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MTARINTERFACEEXECLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
        _Module.Term();
    return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
    return _Module.UnregisterServer(TRUE);
}


