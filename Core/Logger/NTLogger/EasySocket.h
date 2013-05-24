
#ifndef _EasySocket_h
#define _EasySocket_h

typedef enum _MODE { CLIENT=0, SERVER } MODE;

#include <winsock.h>

class CEasySocket
{
public:
  CEasySocket() : 
      mbTCP(true), mRole(SERVER), usEndPoint(5005), 
        fStarted(FALSE), sock(INVALID_SOCKET), mLastError(0)
  {
  }

  virtual ~CEasySocket()
  {
    if ( fStarted )
      Close();
  }

  // initialize and open the connection
  // only call once
  //
  BOOL Open( BOOL bTCP, MODE client_server, USHORT Port, u_long hostlong );
  BOOL Open( BOOL bTCP, MODE client_server, USHORT Port, char * hostname );


  // close the connection
  //
  BOOL Close();

  // non-blocking call to send a message
  //
  BOOL Send(char *msg, int msglength);

  // blocking call to receive the next message
  //
  BOOL Recv(char *msg, int msglength, int *precvlength);

  // if a previous method returns FALSE, this returns the last error code
  //
  DWORD GetLastError()
        { return mLastError; }

private:
  MODE mRole;
  USHORT usEndPoint;

  // If Startup was successful, fStarted is used to keep track.
  BOOL fStarted;
  // socket descriptor
  SOCKET sock;
  DWORD mLastError;
  BOOL mbTCP; // false if UDP
  u_long mHostAddress;
  OVERLAPPED mOverlapped; // only used with asynchronous I/O

private:

  BOOL InitUdp (  );
  BOOL InitTcp (  );
  BOOL InitUdpServer (  );
  BOOL InitUdpClient (  );
  BOOL InitTcpClient (  );
  BOOL SendUdp(char *msg, int msglength);
  BOOL SendTcp(char *msg, int msglength);
  BOOL RecvUdp(char *msg, int msglength, int *precvlength);

  static u_long ResolveHostAddress( char *servername );
      //ResolveHostAddress is private until class is restructuring to allow
      //WSAStartup() to be called before this routine



  void PrintError (LPSTR lpszRoutine, LPSTR lpszCallName, DWORD dwError );

  BOOL SocketStartup ( );
  void SocketCleanup ( );

};


#endif  // _EasySocket_h
