
#define WINNT
#include <metra.h>
#include <stdlib.h>
#include <hostname.h>

const DWORD BUFFER_SIZE=100;

// Returns the DNS host name of the local computer. 
bstr_t GetNTHostName() {

   HRESULT hr         = S_OK;
   BSTR   hostName;
   DWORD   dwSize      = 0;
   wchar_t* pBuf = new wchar_t[BUFFER_SIZE];
   dwSize = BUFFER_SIZE; 
   if(pBuf == NULL)
      _com_issue_error(E_OUTOFMEMORY);

   if(!GetComputerNameEx((COMPUTER_NAME_FORMAT)ComputerNameDnsHostname,
                     pBuf,
                     &dwSize)) {
      if(GetLastError() == ERROR_MORE_DATA) {
         delete [] pBuf;
         pBuf = new wchar_t[dwSize+1]; //+1 shouldn't be necessary but Microsoft sample code used it
         if(pBuf == NULL)
            _com_issue_error(E_OUTOFMEMORY);

         if(!GetComputerNameEx((COMPUTER_NAME_FORMAT)ComputerNameDnsHostname, pBuf, &dwSize) ) {
            hr =   HRESULT_FROM_WIN32(GetLastError());
            delete [] pBuf;
            pBuf    = NULL;
            _com_issue_error(hr);
         }
      }
      else
         _com_issue_error(HRESULT_FROM_WIN32(GetLastError()));
   }

   hostName = SysAllocString(pBuf);
   delete [] pBuf;

   return bstr_t(hostName, false);
}


