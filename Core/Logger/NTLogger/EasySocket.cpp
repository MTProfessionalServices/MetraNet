//
//
// This class implements a simple UDP socket for
// sending and recieving broadcast messages.
//
//

#include <stdio.h>
#include <time.h>
#include <windows.h>
#include <winsock.h>
//#include <wsnwlink.h>
#include "EasySocket.h"

#define MAX_ADDLEN 80

//
//
//
//////////////////////////////////////////////////////////////////////////

// ResolveHostAddress
// Added routine to return host address for a server name that is the ip address
// or the DNS name of the server
u_long CEasySocket::ResolveHostAddress( char *servername )
{
  struct hostent *hp;
  unsigned int addr;

  addr=inet_addr(servername);

  if(addr==INADDR_NONE)
  {
    hp=gethostbyname(servername);
    if (hp==NULL)
      addr=0;
    else
      addr=*((unsigned long*)hp->h_addr);
  }

  //long error=WSAGetLastError();

  return addr;
}

//
//
//
//////////////////////////////////////////////////////////////////////////
BOOL CEasySocket::Open(BOOL bTCP, MODE client_server, USHORT Port, u_long hostlong )
{
  BOOL bOK = TRUE;

  // only open one port

  if ( fStarted )
    return FALSE;

  mbTCP = bTCP; 
  mHostAddress = hostlong;

  mRole = client_server;
  usEndPoint = Port;

  if ( !SocketStartup ( ) )
    return FALSE;

  if ( mbTCP )
  {
    bOK = InitTcp();
  }
  else
  {
    bOK = InitUdp();
  }

  if (! bOK )
    SocketCleanup ( );

  return bOK;
}

// Open
// Added this routine to open the socket based on the hostname.
// Because the WSAStartUp() is called inside of this method and
// because of the all encompassing nature of the method, the Open
// routine was copied. A reworking of the class would factor out
// the WSAStartup() required to resolve the hostname.
//
//////////////////////////////////////////////////////////////////////////
BOOL CEasySocket::Open(BOOL bTCP, MODE client_server, USHORT Port, char * hostname )
{
    BOOL bOK = TRUE;

  // only open one port

  if ( fStarted )
    return FALSE;

  mbTCP = bTCP; 

  mRole = client_server;
  usEndPoint = Port;

  if ( !SocketStartup ( ) )
    return FALSE;

  if (stricmp(strlwr(hostname),"[broadcast]")==0)
  {
    mHostAddress = INADDR_BROADCAST;
  }
  else
  {
    mHostAddress=ResolveHostAddress(hostname);
    if (mHostAddress==0)
      bOK = FALSE;
  }

  if (bOK)
  {
    if ( mbTCP )
    {
      bOK = InitTcp();
    }
    else
    {
      bOK = InitUdp();
    }
  }

  if (! bOK )
    SocketCleanup ( );

  return bOK;
}



//
//
//
//////////////////////////////////////////////////////////////////////////

BOOL CEasySocket::Close()
{
  BOOL bOK = TRUE;

  SocketCleanup ( );

  return bOK;
}

//
//
//
//////////////////////////////////////////////////////////////////////////

BOOL CEasySocket::Send(char *msg, int length)
{
  BOOL bOK = TRUE;

  if (mbTCP)
    bOK = SendTcp(msg, length);
  else
    bOK = SendUdp(msg, length);

  return bOK;
}


//
//
//
//////////////////////////////////////////////////////////////////////////

BOOL CEasySocket::Recv(char *msg, int msglength, int *precvlength)
{
  BOOL bOK = TRUE;

  bOK = RecvUdp(msg, msglength, precvlength);

  return bOK;
}




//
// InitUdp () function calls appropriate handler function (client/server),
// if protocol=UDP  is specified. By default, the role of the application
// is - SERVER.
//
BOOL CEasySocket::
InitUdp ( )
{
  BOOL bOK = TRUE;
      
  //
  // Initialize the global socket descriptor.
  //
  sock = socket ( AF_INET, SOCK_DGRAM, 0 );

  if ( INVALID_SOCKET ==  sock)
  {
    PrintError ( "InitUdp", "socket", WSAGetLastError() );
    return FALSE;
  }
    
  switch ( mRole )
  {
    case CLIENT:
	    bOK = InitUdpClient ( );
	    break;

    default:
    case SERVER:
	    bOK = InitUdpServer ( );
      break;
  }

  return bOK;
}

//
// InitUdp () function calls appropriate handler function (client/server),
// if protocol=UDP  is specified. By default, the role of the application
// is - SERVER.
//
BOOL CEasySocket::
InitTcp ( )
{
  BOOL bOK = TRUE;
      
  //
  // Initialize the global socket descriptor.
  //
  sock = socket ( AF_INET, SOCK_STREAM, 0 );

  if ( INVALID_SOCKET ==  sock)
  {
    PrintError ( "InitTcp", "socket", WSAGetLastError() );
    return FALSE;
  }
    
  switch ( mRole )
  {
    case SERVER:
      PrintError ( "InitTcp no server code", "socket", WSAGetLastError() );
      return FALSE;
      break;
    default:
    case CLIENT:
	    bOK = InitTcpClient ( );
	    break;
  }

#ifndef SYNCHRONOUS_IO // disable for async I/O
  memset( &mOverlapped, 0, sizeof(OVERLAPPED));
#endif

  return bOK;
}

//
// InitUdpServer () function receives the broadcast on a specified port. The
// server will have to post a recv (), before the client sends the broadcast.
// 
BOOL CEasySocket::
InitUdpServer ( )
{
  BOOL bOK = TRUE;
  
  // IP address structures needed to bind to a local port and get the sender's
  // information.
  SOCKADDR_IN saUdpServ;
  
  INT err;
  
  //
  // bind to the specified port.
  //
  saUdpServ.sin_family = AF_INET;
  saUdpServ.sin_addr.s_addr = htonl ( INADDR_ANY );
  saUdpServ.sin_port = htons ( usEndPoint );

  err = bind ( sock, (SOCKADDR FAR *)&saUdpServ, sizeof ( SOCKADDR_IN ) );

  if ( SOCKET_ERROR == err )
  {
    PrintError ( "InitUdpServer", "bind", WSAGetLastError ( ) );
    return FALSE;
  }

  
  return bOK;
}

//
// InitUdpClient () function implements the broadcast routine for an UDP
// client. The function sets the SO_BROADCAST option with the global socket.
// Calling this API is important. After binding to a local port, it sends an 
// UDP boradcasts to the IP address INADDR_BROADCAST, with a particular
// port number.
//
BOOL CEasySocket::
InitUdpClient ( )
{
   BOOL bOK = TRUE;
 
  // IP address structures needed to fill the source and destination 
  // addresses.
  SOCKADDR_IN saUdpCli;
  
  INT err;
  
  // Variable to set the broadcast option with setsockopt ().
  BOOL fBroadcast = TRUE;

    
  err = setsockopt ( sock, 
		       SOL_SOCKET,
		       SO_BROADCAST,
		       (CHAR *) &fBroadcast,
		       sizeof ( BOOL )
		       );

  if ( SOCKET_ERROR == err )
  {
    PrintError ( "InitUdpClient", "setsockopt", WSAGetLastError ( )  );
    return FALSE;
  }

  //
  // bind to a local socket and an interface.
  //
  saUdpCli.sin_family = AF_INET;
  saUdpCli.sin_addr.s_addr = htonl ( INADDR_ANY );
  saUdpCli.sin_port = htons ( 0 );

  err = bind ( sock, (SOCKADDR *) &saUdpCli, sizeof (SOCKADDR_IN) );

  if ( SOCKET_ERROR == err )
  {
    PrintError ( "InitUdpClient", "bind", WSAGetLastError ( ) );
    return FALSE;
  }


  return bOK;
}


//
//
BOOL CEasySocket::
InitTcpClient ( )
{
   BOOL bOK = TRUE;
   int SendBufferSize = 0;
 
  // IP address structures needed to fill the source and destination 
  // addresses.
  SOCKADDR_IN saTcpCli;
  
  INT err;
  
  // Variable to set the broadcast option with setsockopt ().
  BOOL fBroadcast = TRUE;

    
  // Disable send bufferring on the socket.  Setting SO_SNDBUF
  // to 0 causes winsock to stop bufferring sends and perform
  // sends directly from our buffers, thereby reducing CPU
  // usage.
  //
#if SYNCHRONOUS_IO // disable for async I/O
  err = setsockopt( sock, SOL_SOCKET, SO_SNDBUF, (char *)&SendBufferSize, sizeof(SendBufferSize) );
  if ( SOCKET_ERROR == err )
  {
    PrintError ( "InitTcpClient", "setsockopt", WSAGetLastError ( )  );
    return FALSE;
  }
#endif
  //
  // connect.
  //
  saTcpCli.sin_family = AF_INET;
  saTcpCli.sin_addr.s_addr = mHostAddress; //Not using htonl() since the address already came from a structure
  saTcpCli.sin_port = htons(usEndPoint);

  err = connect ( sock, (SOCKADDR *) &saTcpCli, sizeof (saTcpCli) );

  if ( SOCKET_ERROR == err )
  {
    PrintError ( "InitTcpClient", "connect", WSAGetLastError ( ) );
    return FALSE;
  }


  return bOK;
}




//
// sends UDP broadcasts to the IP address INADDR_BROADCAST
//
BOOL CEasySocket::SendUdp(char *msg, int length)
{
  BOOL bOK = TRUE;

  // IP address structures needed to fill the source and destination 
  // addresses.
  SOCKADDR_IN saUdpServ;
  INT err;

  //
  // Fill an IP address structure, to send an IP broadcast. The 
  // packet will be broadcasted to the specified port.
  //
  saUdpServ.sin_family = AF_INET;
  saUdpServ.sin_addr.s_addr = mHostAddress;
  saUdpServ.sin_port = htons ( usEndPoint );

  err = sendto ( sock,
		 msg,
		 length,
		 0,
		 (SOCKADDR *) &saUdpServ,
		 sizeof ( SOCKADDR_IN )
		 );

  if ( SOCKET_ERROR == err )
  {
    DWORD dwError = WSAGetLastError ( );

    // this means no one is listening
    // ignore error

    if ( dwError != WSAEHOSTUNREACH )
    {
      PrintError ( "SendUdp", "sendto", dwError );
      return FALSE;
    }
  }
  return bOK;
}

//
// sends via TCP
//
BOOL CEasySocket::SendTcp(char *msg, int length)
{
  BOOL bOK = TRUE;

#if SYNCHRONOUS_IO // disable for async I/O

  INT err;

  err = send ( sock,
		 msg,
		 length,
		 0 );

  if ( SOCKET_ERROR == err )
  {
    DWORD dwError = WSAGetLastError ( );

    PrintError ( "SendTcp", "sendto", dwError );
    return FALSE;
  }

#else
  DWORD dwIoSize;

  bOK = WriteFile(
                 (HANDLE)sock,
                 msg,
                 length,
                 &dwIoSize,
                 &mOverlapped
                 );
  if ( !bOK && GetLastError( ) != ERROR_IO_PENDING ) 
  {
    PrintError ( "SendTcp", "sendto", GetLastError( ) );
  }
#endif

  return bOK;
}


//
//
//
//
BOOL CEasySocket::RecvUdp(char *msg, int msglength, int *precvlength)
{
  BOOL bOK = TRUE;

  SOCKADDR_IN saUdpCli;
  
  INT err, nSize;
  
  //
  // receive a datagram on the bound port number.
  //
  nSize = sizeof ( SOCKADDR_IN );
  err = recvfrom ( sock,
		   msg,
		   msglength,
		   0,
		   (SOCKADDR FAR *) &saUdpCli,
		   &nSize
		   );

  if ( SOCKET_ERROR == err )
  {
  	PrintError ( "RecvUdp", "recvfrom", WSAGetLastError ( ) );
    return FALSE;
  }
 
  // if no error, function returned # bytes received
  *(msg + err) = NULL;
  *precvlength = err;

#if 0 // debug
  //
  // print the sender's information.
  //
  achBuffer[err] = '\0';
  fprintf ( stdout, "A Udp Datagram of length %d bytes received from ", err );
  fprintf ( stdout, "\n\tIP Adress->%s ", inet_ntoa ( saUdpCli.sin_addr ) );
  fprintf ( stdout, "\n\tPort Number->%d\n", ntohs ( saUdpCli.sin_port ) );
  fprintf ( stdout, "MessageText->%s\n", achBuffer );
#endif //debug
  
  return bOK;
}




//
// PrintError () sets the last error
//
void CEasySocket::
PrintError (
    LPSTR lpszRoutine,
	LPSTR lpszCallName,
	DWORD dwError
	)
{
#ifdef ENABLE_STDOUT
    fprintf ( stderr, 
	      "The Call to %s() in routine() %s failed with error %d\n", 
	      lpszCallName, 
	      lpszRoutine,
	      dwError 
	      );
#endif
    mLastError = dwError;
    return;
}


//
// SocketStartup () initializes the Winsock DLL with Winsock version 1.1
//
BOOL CEasySocket::
SocketStartup ( void )
{
  BOOL bOK = TRUE;
  WSADATA wsaData;

  // The Windows Sockets WSAStartup function initiates use of Ws2_32.dll by a process

    mLastError = WSAStartup ( MAKEWORD ( 1,1 ), &wsaData );
	
    if ( 0 != mLastError)
    {
	    PrintError ( "SocketStartup", "WSAStartup", mLastError );
      bOK = FALSE;
    }
    else
    {
      //
      // Set the global flag.
      //
      fStarted = TRUE;
    }
 
    return bOK;
}

//
// SocketCleanup () will close the global socket which was opened successfully by
// a call to socket (). Additionally, it will call WSACleanup (), if a call
// to WSAStartup () was made successfully.
//
void CEasySocket::
SocketCleanup ( void )
{
  if ( INVALID_SOCKET != sock )
  {
  	closesocket ( sock );
  }

  if ( TRUE == fStarted )
  {
	  WSACleanup ( );
  }

  fStarted = FALSE;

  return;
}
