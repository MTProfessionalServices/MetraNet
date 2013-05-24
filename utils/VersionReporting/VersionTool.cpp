// VersionTool.cpp : Implementation of CVersionTool
#include "StdAfx.h"
#include "VersionReporting.h"
#include "VersionTool.h"

#include "comdef.h"
#include <iostream>

/////////////////////////////////////////////////////////////////////////////
// CVersionTool

STDMETHODIMP CVersionTool::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IVersionTool
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CVersionTool::GetVersion(BSTR *apVersion)
{
	//Get location of root.
	int current = mRootNode;

	while (true) {
		string descriptor = mDLLDirectory + mDecisionTree[current][0];
		string version = mDecisionTree[current][1];
		string fileversion;
		string branch;

		ifstream fexists(descriptor.c_str());
		if (fexists.fail())
			fileversion = "x";
		else {
			fexists.close();
			// Get size for the file version info buffer.
			DWORD dwUseless;
			char *tmpfile = new char[descriptor.size()];
			strcpy(tmpfile, descriptor.c_str());

			_bstr_t bstrTmpFile (tmpfile);
			int len = GetFileVersionInfoSize(bstrTmpFile, &dwUseless);
			
			if (len == 0)
				fileversion = "x";
			else {
				// Get File Version Info.
				BYTE *lpVerInfo = new BYTE[len];
				if (!GetFileVersionInfo(bstrTmpFile, dwUseless, len, lpVerInfo))
					return(E_FAIL);
				// Get FIXED_FILE_VER structure.
				LPVOID lpvi;
				UINT iLen;
				if (!VerQueryValue(lpVerInfo, L"\\", &lpvi, &iLen))
					return(E_FAIL);
				VS_FIXEDFILEINFO ffo = *(VS_FIXEDFILEINFO*)lpvi;
				// Create a string from the file version info.
				char *tmpbuf = new char[256];
				sprintf(tmpbuf, "%d.%d.%d.%d",
						HIWORD(ffo.dwFileVersionMS),
						LOWORD(ffo.dwFileVersionMS),
						HIWORD(ffo.dwFileVersionLS),
						LOWORD(ffo.dwFileVersionLS));

				fileversion=tmpbuf;
				// Free any memory used.
				delete [] tmpbuf;
				delete lpVerInfo;
			}
			// This should be addressed. It is a potential memory leak.
			//		delete [] tmpfile;
		}
		
		branch = (version == fileversion) ? mDecisionTree[current][2] : mDecisionTree[current][3];
		if (branch[0] == '@') {
			current = atoi(branch.substr(1, string::npos).c_str());
		} else {
			wchar_t* tmp = new wchar_t[branch.size()+1];
			mbstowcs(tmp, branch.c_str(), branch.size()+1);
			*apVersion = ::SysAllocString(tmp);
			delete [] tmp;
			break;
		}
	}

	return S_OK;
}
