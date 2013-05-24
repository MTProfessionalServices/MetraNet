#ifndef _FTPPUT_H_
#define _FTPPUT_H_

#include <stdio.h>
#include <win32net.h>

class CMTFtpPut
{
public:

  CMTFtpPut();
  ~CMTFtpPut();

  BOOLEAN       CMTFtpPut::MTInternetDial(const char * PhoneBookEntry);
  BOOLEAN       CMTFtpPut::MTFtpOpen();
  BOOLEAN       CMTFtpPut::MTFtpConnect(
                  const char * DestMachine,
                  const char * FtpUsername,
                  const char * FtpPassword);
  BOOLEAN       CMTFtpPut::MTFtpPutFile(
                  const char * SrcFile,
                  const char * DestFileName);
  const char  * CMTFtpPut::MTFtpGetError();

private:

  HINTERNET hRootHandle;
  HINTERNET hFtpConnectHandle;
  DWORD     DialHandle;

  char Error[1024];

  void CMTFtpPut::MTGetLastErrorString(TCHAR * buf, int Error, int len);
};

#endif // #ifndef _FTPPUT_H_
