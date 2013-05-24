
#include <metra.h>
#include <securestore.h>
#import "MTConfigLib.tlb"

#include <loggerconfig.h>
#include <mtprogids.h>

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

SecureStore::SecureStore()
{
  mrwcEntityName = (const char *)"";
  mblnInitialized   = FALSE;
}

SecureStore::SecureStore(const char * chrEntityName)
{
	// Default is to name container with "metratech" prefix.
  mrwcEntityName = chrEntityName;
	mrwcContainerName = "metratech";
	mrwcContainerName += mrwcEntityName;
  mblnInitialized   = FALSE;
}

SecureStore::SecureStore(const char * chrContainerName, const char * chrEntityName)
{
  mrwcEntityName = chrEntityName;
	mrwcContainerName = chrContainerName;
  mblnInitialized   = FALSE;
}

SecureStore::~SecureStore()
{
  mblnInitialized = FALSE;
}

std::string & 
SecureStore::GetValue(_bstr_t bstrFilename, _bstr_t bstrFindName)
{
  _bstr_t bstrName;
  _bstr_t bstrValue;
  _bstr_t bstrInitialized;

  if (!mblnInitialized)
  {
    mrwcValue = (const char *)"";

    LoggerConfigReader lcrConfigReader;
    mntlLogger.Init(lcrConfigReader.ReadConfiguration("logging"),
                    (const char *)"SecureStore");


    //
    // This routine expects that createkeys has already been run
    // to initialize the key container. If this is the first call
    // to createkeys, then the decryption step will fail because
    // the sessionkey blob will not exist yet. 
    //
    mCrypto.CreateKeys(mrwcContainerName,
                       TRUE,
                       mrwcEntityName);

    wchar_t* name = L"protectedpropertylist.xml";
		wchar_t *fileName = (wchar_t *)(bstrFilename.GetBSTR());
		wchar_t* pdest = wcsstr(fileName, name);
		
    if (pdest != NULL)
    {
      if (0 != mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_Ticketing, mrwcContainerName, TRUE, mrwcEntityName))
      {
        mntlLogger.LogVarArgs(LOG_ERROR,
                             "Unable to initialize crypto object: %s",
                             mCrypto.GetCryptoApiErrorString());
        goto Done;
      }
    }
    else
    {
      if (0 != mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_DatabasePassword, mrwcContainerName, TRUE, mrwcEntityName))
      {
        mntlLogger.LogVarArgs(LOG_ERROR,
                             "Unable to initialize crypto object: %s",
                             mCrypto.GetCryptoApiErrorString());
        goto Done;
      }
    }

    //
    // Initialize the input propset.
    //
    MTConfigLib::IMTConfigPtr inputConfig(MTPROGID_CONFIG);
    VARIANT_BOOL flag;

    MTConfigLib::IMTConfigPropSetPtr
      inputPropSet = inputConfig->ReadConfiguration(bstrFilename, &flag);

    // get the config data ...
    MTConfigLib::IMTConfigPropSetPtr inputDataSet;

    BOOL blnFound = FALSE;

    while (!blnFound &&
           (NULL != (inputDataSet = inputPropSet->NextSetWithName("dataset"))))
    {
      bstrName = inputDataSet->NextStringWithName("name");

      if (bstrFindName == bstrName)
      {
        //
        // this is the one
        //
        bstrValue       = inputDataSet->NextStringWithName("value");
        bstrInitialized = inputDataSet->NextStringWithName("initialized");

        if ((_bstr_t("TRUE") == bstrInitialized) || (_bstr_t("true") == bstrInitialized)) 
        {
          blnFound = TRUE;
        }
        else
        {
          mntlLogger.LogVarArgs(LOG_ERROR,
                               "Protected property %s in file %s is not initialized",
                               (const char *)bstrFindName,
                               (const char *)bstrFilename);
          goto Done;
        }
      }
    }

    if (blnFound)
    {
      // 
      // now, retrieve (uudecode and decrypt) the protect property
      //
			std::string plainText((const char *)bstrValue);
      // check if the value is encrypted
      inputDataSet->Reset();
      MTConfigLib::IMTConfigPropPtr valueProp = inputDataSet->NextWithName(L"value");
      _bstr_t encrypted = "false";
      if (valueProp != NULL)
      {
        MTConfigLib::IMTConfigAttribSetPtr attribSet = valueProp->GetAttribSet();
        if (attribSet != NULL)
        {
			    encrypted = attribSet->GetAttrValue("encrypted");
        }
      }
      
      if (0 == _wcsicmp(encrypted, L"true"))
      {
        if (mCrypto.Decrypt(plainText))
        {
          mntlLogger.LogVarArgs(LOG_ERROR,
                               "Unable to decrypt protected property %s from %s: %s",
                               (const char *)bstrFindName,
                               (const char *)bstrFilename,
                               mCrypto.GetCryptoApiErrorString());
          goto Done;
        }
      }

      mrwcValue = plainText.c_str();
    }
    else
    {
      mntlLogger.LogVarArgs(LOG_ERROR,
                           "Unable to find protected property %s from %s",
                           (const char *)bstrFindName,
                           (const char *)bstrFilename);
      goto Done;
    }

    mblnInitialized = TRUE;
  }

Done:

  std::string & rwcRefReturn = mrwcValue;
  return rwcRefReturn;
}
