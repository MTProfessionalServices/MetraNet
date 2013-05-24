// AudioConfMeteringTestApp.h : main header file for the PROJECT_NAME application
//

#pragma once

#include "resource.h"		// main symbols


// CAudioConfMeteringTestAppApp:
// See AudioConfMeteringTestApp.cpp for the implementation of this class
//

class CAudioConfMeteringTestAppApp : public CWinApp
{
public:
	CAudioConfMeteringTestAppApp();

// Overrides
	public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern CAudioConfMeteringTestAppApp theApp;