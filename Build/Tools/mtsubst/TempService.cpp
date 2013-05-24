#include <TempService.h>

SERVICE_STATUS_HANDLE   CTempService::s_hss;
SERVICE_STATUS          CTempService::s_ss;
const wchar_t* const CTempService::s_pszServiceName = L"mtsubsttemp";


void* CTempService::GetAdminSid()
{
	SID_IDENTIFIER_AUTHORITY ntauth = SECURITY_NT_AUTHORITY;
	void* psid = 0;
	if ( !AllocateAndInitializeSid( &ntauth, 2,
		SECURITY_BUILTIN_DOMAIN_RID,
		DOMAIN_ALIAS_RID_ADMINS,
		0, 0, 0, 0, 0, 0, &psid ) )
		s_err( L"AllocateAndInitializeSid", GetLastError() );
	return psid;
}

void* CTempService::GetLocalSystemSid()
{
	SID_IDENTIFIER_AUTHORITY ntauth = SECURITY_NT_AUTHORITY;
	void* psid = 0;
	if ( !AllocateAndInitializeSid( &ntauth, 1,
		SECURITY_LOCAL_SYSTEM_RID,
		0, 0, 0, 0, 0, 0, 0, &psid ) )
		s_err( L"AllocateAndInitializeSid", GetLastError() );
	return psid;
}

bool CTempService::IsAdmin()
{
	bool bIsAdmin = false;
	HANDLE htok = 0;
	if ( !OpenProcessToken( GetCurrentProcess(), TOKEN_QUERY, &htok ) )
		s_err( L"OpenProcessToken", GetLastError() );

	DWORD cb = 0;
	GetTokenInformation( htok, TokenGroups, 0, 0, &cb );
	TOKEN_GROUPS* ptg = (TOKEN_GROUPS*)malloc( cb );
	if ( !ptg )
		s_err( L"malloc", GetLastError() );
	if ( !GetTokenInformation( htok, TokenGroups, ptg, cb, &cb ) )
		s_err( L"GetTokenInformation", GetLastError() );

	void* pAdminSid = GetAdminSid();

	SID_AND_ATTRIBUTES* const end = ptg->Groups + ptg->GroupCount;
	for ( SID_AND_ATTRIBUTES* it = ptg->Groups; end != it; ++it )
		if ( EqualSid( it->Sid, pAdminSid ) )
			break;

	bIsAdmin = end != it;

	FreeSid( pAdminSid );
	free( ptg );
	CloseHandle( htok );

	return bIsAdmin;
}

bool CTempService::IsLocalSystem()
{
	bool bIsLocalSystem = false;
	HANDLE htok = 0;
	if ( !OpenProcessToken( GetCurrentProcess(), TOKEN_QUERY, &htok ) )
		s_err( L"OpenProcessToken", GetLastError() );

	BYTE userSid[256];
	DWORD cb = sizeof userSid;
	if ( !GetTokenInformation( htok, TokenUser, userSid, cb, &cb ) )
		s_err( L"GetTokenInformation", GetLastError() );
	TOKEN_USER* ptu = (TOKEN_USER*)userSid;

	void* pLocalSystemSid = GetLocalSystemSid();

	bIsLocalSystem = EqualSid( pLocalSystemSid, ptu->User.Sid ) ? true : false;

	FreeSid( pLocalSystemSid );
	CloseHandle( htok );

	return bIsLocalSystem;
}

void CTempService::StartAsService( int argc, wchar_t** argv )
{
	wchar_t szModuleFileName[MAX_PATH];
	GetModuleFileNameW( 0, szModuleFileName, sizeof szModuleFileName / sizeof *szModuleFileName );

	// come up with unique name for this service
	SC_HANDLE hscm = OpenSCManager( 0, SERVICES_ACTIVE_DATABASE, SC_MANAGER_CREATE_SERVICE );
	if ( !hscm )
		s_err( L"OpenSCManager", GetLastError() );

	SC_HANDLE hsvc = 0;
	for ( int nRetry = 0; nRetry < 10; ++nRetry )
	{
		hsvc = CreateServiceW(	hscm,
			s_pszServiceName,
			s_pszServiceName,
			SERVICE_START | SERVICE_QUERY_STATUS | DELETE,
			SERVICE_WIN32_SHARE_PROCESS | SERVICE_INTERACTIVE_PROCESS,
			SERVICE_DEMAND_START,
			SERVICE_ERROR_NORMAL,
			szModuleFileName,
			0, 0,
			0,
			0, 0 );
		if ( hsvc )
			break;
		else if ( ERROR_SERVICE_EXISTS == GetLastError() )
		{
			SC_HANDLE hsvc = OpenServiceW( hscm, s_pszServiceName, DELETE );
			DeleteService( hsvc );
			CloseServiceHandle( hsvc );
			hsvc = 0;
			// try again
		}
		else break;
	}		

	if ( !hsvc )
		s_err( L"CreateService", GetLastError() );

  
	if ( !StartServiceW( hsvc, argc, (const wchar_t**)argv ) )
		s_err( L"StartService", GetLastError() );

  //Create Named Pipe Client and read
	WriteStdOutFromNamedPipe();


	DeleteService( hsvc );
	CloseServiceHandle( hsvc );
	CloseServiceHandle( hscm );

}

bool CTempService::WriteStdOutFromNamedPipe()
{
  //DWORD dwRead;
  NamedPipeClient np(pipename);
  string buf;
  int tries = 0;
  DWORD cbWritten;

  while(np.Connect() == FALSE)
  {
    if(tries == 5)
      return false;
    Sleep(200);
    tries++;
  }
  
	while (np.ReadPipe(buf))
	{
    int sz = (int)buf.length();
    WriteFile(GetStdHandle(STD_OUTPUT_HANDLE), 
      buf.c_str(), sz, &cbWritten, NULL); 
	}
  return true;
}


bool CTempService::WriteBufferToNamedPipe(const char* buf)
{
  NamedPipeServer nps(pipename, 1000);
  bool ret = nps.CreateAndWaitForConnection();
  if(!ret)
  {
    cout << "There was an error trying to create named pipe." <<  endl;
    return false;
  }
  else
  {
    nps.WritePipe(buf);
  }
  return true;
}






void WINAPI CTempService::Handler( DWORD )
{
	SetServiceStatus( s_hss, &s_ss );
}

void WINAPI CTempService::ServiceMain( DWORD argc, wchar_t* argv[] )
{
	s_ss.dwCurrentState = SERVICE_RUNNING;
	s_ss.dwServiceType = SERVICE_WIN32_OWN_PROCESS | SERVICE_INTERACTIVE_PROCESS;

	s_hss = RegisterServiceCtrlHandlerW( s_pszServiceName, Handler );
	SetServiceStatus( s_hss, &s_ss );

	// call application specific logic while running under LocalSystem's token
	s_proc( argc, argv );

	s_ss.dwCurrentState = SERVICE_STOPPED;
	SetServiceStatus( s_hss, &s_ss );
}
	
void CTempService::wmain( int argc, wchar_t* argv[] )
{
  if ( IsLocalSystem() )
	{
		// launched by SCM
		SERVICE_TABLE_ENTRYW ste[] = { 
			{ const_cast<wchar_t*>( s_pszServiceName ), ServiceMain },
			{ 0, 0 }
		};
		StartServiceCtrlDispatcherW( ste );
		return;
	}
	StartAsService( argc - 1, argv + 1 );
}
