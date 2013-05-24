
#include <metra.h>
#include <ftpput.h>

CMTFtpPut::CMTFtpPut()
{
  hRootHandle       = NULL;
  hFtpConnectHandle = NULL;
  DialHandle        = 0;

  return;
}

CMTFtpPut::~CMTFtpPut()
{
  if (NULL != hFtpConnectHandle)
    InternetCloseHandle(hFtpConnectHandle);                        

  if (NULL != hRootHandle)
    InternetCloseHandle(hRootHandle);

  if (0 != DialHandle)
    InternetHangUp(DialHandle, 0);

  return;
}

BOOLEAN
CMTFtpPut::MTInternetDial(const char * PhoneBookEntry)
{
  DWORD DialRetCode = -1;

  DialRetCode = InternetDial(
                  0,
                  (LPTSTR)PhoneBookEntry,
                  INTERNET_AUTODIAL_FORCE_UNATTENDED,
                  &DialHandle,
                  0);

  if (ERROR_SUCCESS != DialRetCode)
  {
    TCHAR errbuf[256];
    MTGetLastErrorString(errbuf, GetLastError(), 128);

    sprintf(Error, "%S", errbuf);

    return FALSE;
  }

  return TRUE;
}


BOOLEAN
CMTFtpPut::MTFtpOpen()
{
  hRootHandle = InternetOpen(
                  TEXT("FtpPut Class"),
                  INTERNET_OPEN_TYPE_DIRECT,
                  NULL,
                  NULL,
                  0);

  if (NULL == hRootHandle)
  {
    TCHAR errbuf[256];
    MTGetLastErrorString(errbuf, GetLastError(), 128);

    sprintf(Error, "%S", errbuf);

    return FALSE;
  }

  return TRUE;
}

BOOLEAN
CMTFtpPut::MTFtpConnect(
  const char * DestMachine,
  const char * FtpUsername,
  const char * FtpPassword)
{
  hFtpConnectHandle = InternetConnect(
                        hRootHandle,
                        DestMachine,
                        INTERNET_DEFAULT_FTP_PORT, 
                        FtpUsername,
                        FtpPassword,
                        INTERNET_SERVICE_FTP,
                        INTERNET_FLAG_PASSIVE,
                        1);

  if (NULL == hFtpConnectHandle)
  {
    TCHAR errbuf[256];
    MTGetLastErrorString(errbuf, GetLastError(), 128);

    sprintf(Error, "%S", errbuf);

    return FALSE;
  }

  return TRUE;
}

BOOLEAN
CMTFtpPut::MTFtpPutFile(
  const char * SrcFile,
  const char * DestFileName)
{
  BOOLEAN bRet = FtpPutFile(
                   hFtpConnectHandle,
                   SrcFile,
                   DestFileName,
                   FTP_TRANSFER_TYPE_BINARY,
                   1);

  if (FALSE == bRet)
  {
    TCHAR errbuf[256];
    MTGetLastErrorString(errbuf, GetLastError(), 128);

    sprintf(Error, "%S", errbuf);

    return FALSE;
  }

  return TRUE;
}

void
CMTFtpPut::MTGetLastErrorString(TCHAR * buf, int Error, int len)
{

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    Error,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
    (LPTSTR) buf,
    len,
    0);

  return;
}

const char *
CMTFtpPut::MTFtpGetError()
{
  return Error;
}
