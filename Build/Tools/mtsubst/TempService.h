#ifndef __TEMPSERVICE_H__
#define __TEMPSERVICE_H__
#pragma once

//#pragma comment( lib, "advapi32.lib" )


#include <Metra.h>
#include <comdef.h>
#include <comutil.h>


#include <stdio.h>
#include <stdlib.h>

//#include <string>
#include <iostream>
#include <namedpipe.h>
using namespace std;


//static char* pipename = "\\\\.\\pipe\\mynamedpipe";
static char* pipename = "\\\\.\\pipe\\mynamedpipe";
static HANDLE hPipe;
static const int BUFSIZE = 1024;


class CTempService
{
public:
	typedef void (*PROC)( int argc, wchar_t* argv[] );
	typedef void (*ERR)( const wchar_t* pszFcn, DWORD err );
	
	// the following variables must be defined by app using this class
	static PROC					s_proc;
	static ERR					s_err;
	static const wchar_t* const s_pszServiceName;

    static bool IsAdmin();
    static bool IsLocalSystem();
    static void wmain( int argc, wchar_t* argv[] );

    static bool WriteStdOutFromNamedPipe();
    static bool WriteBufferToNamedPipe(const char* buf);
	

private:
    static void* GetAdminSid();
    static void* GetLocalSystemSid();

    static void WINAPI Handler( DWORD );
    static void WINAPI ServiceMain( DWORD argc, wchar_t* argv[] );

    static void StartAsService( int argc, wchar_t** argv );
	  

    static SERVICE_STATUS_HANDLE	s_hss;
    static SERVICE_STATUS			s_ss;
};
#endif
