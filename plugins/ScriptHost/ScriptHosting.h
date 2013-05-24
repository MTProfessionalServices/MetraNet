// ScriptHosting.h: interface for the CScriptHosting class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_SCRIPTHOSTING_H__514D3567_481C_11D2_80F6_006008C0E8B7__INCLUDED_)
#define AFX_SCRIPTHOSTING_H__514D3567_481C_11D2_80F6_006008C0E8B7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "ScriptedFrame.h"
#include "MTScriptingDispids.h"

class CScriptHosting  
{
public:
	CScriptHosting();
	virtual ~CScriptHosting();

public:
	// Public methods
	BOOL Serialization(IUnknown * systemContext,
										MTPipelineLib::IMTConfigPropSetPtr apPropSet);
	// Private Methods
	// serialize with configuration tables.

	BOOL InitializeScriptHost(IUnknown * systemContext);

	HRESULT ProcessSession(MTPipelineLib::IMTSessionPtr apSession);
	// process session to generate new Property Value(Product name for Product 
	// Determination, view name for View Determination, etc.)

	HRESULT ProcessSessionSet(MTPipelineLib::IMTSessionSetPtr apSessions);
	// process session to generate new Property Value(Product name for Product 
	// Determination, view name for View Determination, etc.)

	BOOL QuitScript();

	BOOL Shutdown();

	BOOL GetSHProcFlag( void )
	{
		return mSHProcFlag;
	}

	const string& GetErrorMsg()
	{
		return mErrorMsg;
	}

private:
	BOOL ProcessScriptFilename(IUnknown* systemContext,string aFilename);

	BOOL GetConfigRoot(string& aRoot);


	CScriptedFrame*	mpScriptedFrame;
	string				mScriptFileName;
	wstring				mScriptType;

	BOOL						mSHProcFlag;

	MTPipelineLib::IMTConfigPropSetPtr mScriptConfig;

	string				mErrorMsg;

	NTLogger				mLogger;

};

#endif // !defined(AFX_SCRIPTHOSTING_H__514D3567_481C_11D2_80F6_006008C0E8B7__INCLUDED_)
