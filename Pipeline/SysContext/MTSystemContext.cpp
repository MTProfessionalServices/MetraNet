// MTSystemContext.cpp : Implementation of CMTSystemContext
#include "StdAfx.h"
#include "SysContext.h"
#include "MTSystemContextDef.h"
#include "MTUtil.h"

#include <mtprogids.h>
#include <mtglobal_msg.h>



#include <mtcomerr.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

//#include <EnumType_i.c>

//struct CLSID_MTEnumType;
//CLSID CLSID_MTEnumType = {0xB8138855,0x22A2,0x11D3,{0xB6,0x72,0x00,0x10,0x4B,0x2B,0x98,0x0B}};

/////////////////////////////////////////////////////////////////////////////
// CMTSystemContext

CMTSystemContext::CMTSystemContext()
	: mpLog(NULL),
		mpNameID(NULL),
		mpEnum(NULL),
		mpEffectiveFileConfig(NULL)
{ }


STDMETHODIMP CMTSystemContext::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTLog,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Description: return the logger interface
// Return Value: logger interface used to log messages to the system log file.
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::GetLog(IMTLog * * log)
{
	return mpLog->QueryInterface(IID_IMTLog, (void **) log);
}

// ----------------------------------------------------------------
// Description: return the name ID object
// Return Value: name ID interface used to log up IDs for any string.
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::GetNameID(IMTNameID * * nameid)
{
	return mpNameID->QueryInterface(__uuidof(MTPipelineLib::IMTNameID), (void **) nameid);
}

// ----------------------------------------------------------------
// Description: return the enumeration object (used to lookup enumerated type values).
// Return Value: enumeration object
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::GetEnumConfig(IEnumConfig * * enum_config)
{
	return mpEnum->QueryInterface(__uuidof(MTPipelineLib::IEnumConfig), (void **) enum_config);
}


// ----------------------------------------------------------------
// Description: return the name ID object
// Return Value: name ID interface used to log up IDs for any string.
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::get_EffectiveConfig(IMTConfigFile ** apEffectiveConfig)
{
	ASSERT(apEffectiveConfig);
	if(!apEffectiveConfig) return E_POINTER;

	*apEffectiveConfig = mpEffectiveFileConfig;
	(*apEffectiveConfig)->AddRef();
	return S_OK;
}

// ----------------------------------------------------------------
// Description: set the information about the configuration file used
//              to configure the plug-in.
//              INTERNAL use only.
// Arguments: apEffectiveConfig - config loader info object
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::put_EffectiveConfig(IMTConfigFile * apEffectiveConfig)
{
	ASSERT(apEffectiveConfig);
	if(!(apEffectiveConfig)) return E_POINTER;

	if(mpEffectiveFileConfig) {
		mpEffectiveFileConfig->Release();
	}

	mpEffectiveFileConfig = apEffectiveConfig;
	mpEffectiveFileConfig->AddRef();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	get_ExtensionName
// arguments:		<pExtensionName> the extension name
// Description: Returns the raw extension name (like audioconf, videoconf)
// ----------------------------------------------------------------

STDMETHODIMP CMTSystemContext::get_ExtensionName(BSTR* pExtensionName)
{
	ASSERT(pExtensionName);
	if(!pExtensionName) return E_POINTER;
	*pExtensionName = mExtensionName.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	put_ExtensionName
// arguments:		<aExtensionName> the extension name
// Description:  sets the raw extension name (like audioconf, videoconf)
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::put_ExtensionName(BSTR aExtensionName)
{
	ASSERT(aExtensionName);
	if(!aExtensionName) return E_POINTER;
	mExtensionName = aExtensionName;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	get_StageDirectory
// arguments:		<pStageDir> the stage directory
// Description:   Gets the full path to the stage directory, i.e. C:\metratech\
// RMP\extensions\audioconf\config\pipeline\foo
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::get_StageDirectory(BSTR* pStageDir)
{
	ASSERT(pStageDir);
	if(!pStageDir) return E_POINTER;
	*pStageDir = mStageFolder.copy();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	put_StageDirectory
// arguments:		<aStageDir> the stage directory
// Description:   Sets the full path to the stage directory
// ----------------------------------------------------------------

STDMETHODIMP CMTSystemContext::put_StageDirectory(BSTR aStageDir)
{
	ASSERT(aStageDir);
	if(!aStageDir) return E_POINTER;
	mStageFolder = aStageDir;
	return S_OK;
}

HRESULT CMTSystemContext::FinalConstruct()
{
	try
	{
		MTPipelineLib::IMTLogPtr logger(MTPROGID_LOG);
		mpLog = logger.Detach();

		MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
		mpNameID = nameID.Detach();

		MTPipelineLib::IEnumConfigPtr enumPtr(MTPROGID_ENUM_CONFIG);
		mpEnum = enumPtr.Detach();

		mpEffectiveFileConfig = NULL;

    int result = mCrypto.CreateKeys("metratechpipeline", true, "pipeline");
    if (result == 0) {
      result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", true, "pipeline");
		}
		if(result != 0) {
			// TODO: this string doesn't actually make it to the caller.
			//       for now, they just see the HRESULT.  Should we log the string?
      char chrBuf[1024];
      sprintf(chrBuf, 
              "Unable to initialize crypto functions: %x: %s",
              result,
              mCrypto.GetCryptoApiErrorString());
			return Error(chrBuf, IID_IMTSystemContext, CORE_ERR_CRYPTO_FAILURE);
    }
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	return S_OK;
}

void CMTSystemContext::FinalRelease()
{
	if (mpLog != NULL)
		mpLog->Release();
	if (mpNameID != NULL)
		mpNameID->Release();


	if(mpEffectiveFileConfig) {
		mpEffectiveFileConfig->Release();
		mpEffectiveFileConfig = NULL;
	}

	if (mpEnum != NULL)
		mpEnum->Release();
}

// ----------------------------------------------------------------
// Name:     	Decrypt
// arguments:		<aEncryptedStr> The encrypted value
//							<pvalue>		The decrypted string
// Description:   Decrypts a value encrypted by the listener.  Note: this only
// works for encrypted strings (which is all we support for encryptionn anyway)
// ----------------------------------------------------------------

STDMETHODIMP CMTSystemContext::Decrypt(BSTR aEncryptedStr,BSTR* pvalue)
{
	// step 1: check args
	bool bTest = aEncryptedStr && pvalue;
	ASSERT(bTest);
	if(!bTest) return E_POINTER;
	HRESULT hr = S_OK;

	// step 2: decrypt the string
	std::string aTempEncryptedStr = (const char*)_bstr_t(aEncryptedStr);

  // step 3: Decrypt
	if(mCrypto.Decrypt(aTempEncryptedStr) != 0) {
			_bstr_t aTempErrorStr = "Unable to decrypt \"";
			aTempErrorStr += aTempEncryptedStr.c_str();
			aTempErrorStr += "\" error: ";
			aTempErrorStr += mCrypto.GetCryptoApiErrorString();
			hr = Error((const wchar_t*)aTempErrorStr);
		}
	else {
    // step 4: UTF8 to wide string conversion of plain text
    std::wstring wstrPlainText;
    ::ASCIIToWide(wstrPlainText, aTempEncryptedStr.c_str(), aTempEncryptedStr.size(), CP_UTF8);
		_bstr_t aTempBstr(wstrPlainText.c_str());
		*pvalue = aTempBstr.copy();
	}
	return hr;
}

// ----------------------------------------------------------------
// Name:     	Encrypt
// arguments:		<aStringToEncrypt> The unencrypted value
//							<pvalue>		The encrypted string
// Description:
// ----------------------------------------------------------------
STDMETHODIMP CMTSystemContext::Encrypt(BSTR aStringToEncrypt, BSTR* pvalue)
{
	// step 1: check args
	bool bTest = aStringToEncrypt && pvalue;
	ASSERT(bTest);
	if(!bTest) return E_POINTER;
	HRESULT hr = S_OK;

	// step 2: string to encrypt
	std::string aTempEncryptedStr = (const char*)_bstr_t(aStringToEncrypt);

  // step 3: Encrypt
  if(mCrypto.Encrypt(aTempEncryptedStr) != 0)
  {
    _bstr_t aTempErrorStr = "Unable to encrypt \"";
    aTempErrorStr += aTempEncryptedStr.c_str();
    aTempErrorStr += "\" error: ";
    aTempErrorStr += mCrypto.GetCryptoApiErrorString();
    hr = Error((const wchar_t*)aTempErrorStr);
  }
  else
  {
    // step 4: UTF8 to wide string conversion of plain text
    std::wstring wstrPlainText;
    ::ASCIIToWide(wstrPlainText, aTempEncryptedStr.c_str(), aTempEncryptedStr.size(), CP_UTF8);
	  _bstr_t aTempBstr(wstrPlainText.c_str());
	  *pvalue = aTempBstr.copy();
  }
  return hr;
}
