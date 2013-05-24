#include <loggerconfig.h>
#include <mtprogids.h>
#include <mtcryptoapi.h>
#include <wincrypt.h>
#include <stdio.h>
#include <base64.h>
#include <string.h>
#include <NTLogger.h>

class SecureStore
{
public:
  SecureStore();
  SecureStore(const char * chrEntityName);
  SecureStore(const char * chrContainerName, const char * chrEntityName);
  ~SecureStore();

  std::string & GetValue(_bstr_t bstrFilename, _bstr_t bstrFindName);

private:
	std::string    mrwcEntityName;
	std::string    mrwcContainerName;
  CMTCryptoAPI mCrypto;
  BOOL         mblnInitialized;
  NTLogger     mntlLogger;

  std::string    mrwcValue; 
};
