// dllmain.cpp : Implementation of DllMain.

#include "stdafx.h"
#include "resource.h"
#include "VertexATLWrapper_i.h"
#include "dllmain.h"
#include "stda.h"
#include "ctqa.h"

CVertexATLWrapperModule _AtlModule;

/* *****
// DLL Entry Point
extern "C" BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	hInstance;
	return _AtlModule.DllMain(dwReason, lpReserved); 
}
***** */

class CVertexATLWrapperApp : public CWinApp
{
public:

// Overrides
	virtual BOOL InitInstance();
	virtual int ExitInstance();

	DECLARE_MESSAGE_MAP()
};

BEGIN_MESSAGE_MAP(CVertexATLWrapperApp, CWinApp)
END_MESSAGE_MAP()

CVertexATLWrapperApp theApp;

BOOL CVertexATLWrapperApp::InitInstance()
{
	return CWinApp::InitInstance();
}

int CVertexATLWrapperApp::ExitInstance()
{
	return CWinApp::ExitInstance();
}