// mtsubst.cpp : Defines the entry point for the console application.
//
#include <metra.h>
#include <mtcom.h>
#include <comdef.h>
#include <comutil.h>
#include <TempService.h>


#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <iostream>

using namespace std;

void Err( const wchar_t* pszFcn, DWORD nErr);
void TempServiceProc( int argc, wchar_t* argv[] );
CTempService::PROC   CTempService::s_proc			= TempServiceProc;
CTempService::ERR    CTempService::s_err			= Err;
HANDLE hChildStdoutRd, hChildStdoutWr, hSaveStdout, hChildStdoutRdDup;
void  ReadFromPipe(string&);



void Quit( const wchar_t* pszMsg, int nExitCode = 1 )
{
	wprintf( L"%s\n", pszMsg );
	exit( nExitCode );
}

void Err( const wchar_t* pszFcn, DWORD nErr = GetLastError() )
{
	wchar_t szErrMsg[256];
  wchar_t szMsg[512];
	if ( FormatMessageW( FORMAT_MESSAGE_FROM_SYSTEM, 0, nErr, 0, szErrMsg, sizeof szErrMsg / sizeof *szErrMsg, 0 ) )
		 swprintf( szMsg, L"%s failed: %s", pszFcn, szErrMsg );
	else swprintf( szMsg, L"%s failed: 0x%08X", pszFcn, nErr );
	Quit( szMsg );
  return;
}

void GetError(string& ret, DWORD nErr = GetLastError())
{
	char szErrMsg[256];
	char szMsg[512];
	if ( FormatMessageA( FORMAT_MESSAGE_FROM_SYSTEM, 0, nErr, 0, szErrMsg, sizeof szErrMsg / sizeof *szErrMsg, 0 ) )
		 sprintf( szMsg, "%s", szErrMsg);
	else sprintf( szMsg, "0x%08X", nErr );
  ret = szMsg;
  return;
}

void ReadFromPipe(string& buf) 
{ 
	DWORD dwRead; 
	// Close the write end of the pipe before reading from the 
	// read end of the pipe. 
	if (!CloseHandle(hChildStdoutWr)) 
		cout << "Failed to Close hChildStdoutWr handle"; 

  for (;;) 
   { 
     CHAR chBuf[BUFSIZE]; 
      if( !ReadFile( hChildStdoutRdDup, chBuf, BUFSIZE, &dwRead, 
         NULL)) 
      {
        break;
      }
      else if(dwRead == 0)
        break;
      chBuf[dwRead] = '\0';
      buf += string(chBuf);
   } 

	return;
} 


char* GetLastErrorString();
void wmain( int argc, wchar_t* argv[] )
{
	// we were launched from the command line, so install ourself as a temporary service
	// and restart in the System logon session
	if ( !CTempService::IsAdmin() )
		 cout << L"You must be a member of the local Administrator's group to run this program" << endl;
	CTempService::wmain( argc, argv );
}



char* GetLastErrorString()
{
	LPVOID lpMsgBuf;
if (!FormatMessage( 
    FORMAT_MESSAGE_ALLOCATE_BUFFER | 
    FORMAT_MESSAGE_FROM_SYSTEM | 
    FORMAT_MESSAGE_IGNORE_INSERTS,
    NULL,
    GetLastError(),
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
    (LPTSTR) &lpMsgBuf,
    0,
    NULL ))
{
   // Handle the error.
   return "failed to get error message";
}
else return (char*)lpMsgBuf;

}


void TempServiceProc( int argc, wchar_t* argv[] )
{
  PROCESS_INFORMATION pi;
  SECURITY_ATTRIBUTES saAttr; 
  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES); 
  saAttr.bInheritHandle = TRUE; 
  saAttr.lpSecurityDescriptor = NULL; 



  BOOL fSuccess;
  // Save the handle to the current STDOUT.
  hSaveStdout = GetStdHandle(STD_OUTPUT_HANDLE);

  if( !CreatePipe( &hChildStdoutRd, &hChildStdoutWr, &saAttr, 0) )
  {
    cout << "Stdout pipe creation failed\n" << endl;
    return;
  }
  cout << "Created Pipe" << endl;

  // Set a write handle to the pipe to be STDOUT.
  if( !SetStdHandle(STD_OUTPUT_HANDLE, hChildStdoutWr) )
  {
    cout << "Redirecting STDOUT failed" << endl;
    return;
  }
  // Create noninheritable read handle and close the inheritable read handle.
  fSuccess = DuplicateHandle( GetCurrentProcess(), hChildStdoutRd,
    GetCurrentProcess(), &hChildStdoutRdDup ,
    0, FALSE,
    DUPLICATE_SAME_ACCESS );
  if( !fSuccess )
  {
    cout << "DuplicateHandle failed" << endl;
    return;
  }
  CloseHandle( hChildStdoutRd );

  STARTUPINFOW si = { sizeof si };
  ZeroMemory( &si, sizeof(STARTUPINFOW) );
  si.cb = sizeof(STARTUPINFO);
  si.hStdOutput = hChildStdoutWr;
  si.hStdError = hChildStdoutWr;
  si.dwFlags |= STARTF_USESTDHANDLES;

  //construct command line out of arguments in order
  //to pass them onto the child process.
  wstring cmdline = L"subst.exe ";
  for ( int i = 1; i < argc; ++i )
  {
    
    const wchar_t* arg = argv[i];
    if(arg[0] != L'/')
    {
      cmdline += L"\"";
    }
    cmdline += wstring(arg);
    if(arg[0] != L'/')
    {
      cmdline += L"\" ";
    }
    else 
      cmdline += L" ";
  }

  //execute real subst.exe with given parameters. Catch child stdout from the pipe
  if ( !CreateProcessW( 0, (LPWSTR)cmdline.c_str(), 0, 0, TRUE, CREATE_NO_WINDOW, 0, 0, &si, &pi ) )
    Err( L"CreateProcess" );

  string buf;
  ReadFromPipe(buf);

  if( !SetStdHandle(STD_OUTPUT_HANDLE, hSaveStdout) )
  {
    cout << "Restoring STDOUT failed" << endl;
    return;
  }

  //since we are a NT service now, we use named pipe as a means to dispatch child's stdout
  //back to originating mtsubst.exe process.
  CTempService::WriteBufferToNamedPipe(buf.c_str());

  CloseHandle(hChildStdoutWr);
  CloseHandle(hSaveStdout);
  CloseHandle( pi.hThread );
  CloseHandle( pi.hProcess );

}
