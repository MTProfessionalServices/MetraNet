/**************************************************************************
 * @doc MTCONFIGLOADER
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Chen He
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/
	
// MTConfigLoader.h : Declaration of the CMTConfigLoader

#ifndef __MTCONFIGLOADER_H_
#define __MTCONFIGLOADER_H_


#include <comdef.h>
#include "resource.h"       // main symbols

#include <map>
#include <string>

using std::map;
using std::string;
using std::wstring;

#include "errobj.h"

#include "NTRegistryIO.h"
#include "MTConfigFileList.h"

#include "MTConfigInclude.h"
#include <IMTConfigLoader.h>
#include <MTConfigFileListImpl.h>

typedef map<string, string> CPathColl;


/////////////////////////////////////////////////////////////////////////////
// CMTConfigLoader
class ATL_NO_VTABLE CMTConfigLoader : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTConfigLoader, &CLSID_MTConfigLoader>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTConfigLoader, &IID_IMTConfigLoader, &LIBID_MTConfigLOADERLib>
{
public:
	CMTConfigLoader();
	~CMTConfigLoader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTCONFIGLOADER)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTConfigLoader)
	COM_INTERFACE_ENTRY(IMTConfigLoader)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTConfigLoader
public:
	STDMETHOD(GetPath)(/*[in]*/BSTR aCompName, 
			/*[out, retval]*/BSTR* apRetVal);

	STDMETHOD(GetEffectiveFileWithDate)(/*[in]*/BSTR aCompName, 
			/*[in]*/BSTR aFileName, 
			/*[in]*/VARIANT aDate, 
			/*[out,retval]*/::IMTConfigPropSet** apConfigPropSet);

	STDMETHOD(GetEffectiveFile)(/*[in]*/BSTR aCompName, 
			/*[in]*/BSTR aFileName, 
			/*[out, retval]*/::IMTConfigPropSet** apConfigPropSet);

	STDMETHOD(GetActiveFiles)(/*[in]*/BSTR aCompName, 
			/*[in]*/BSTR aFileName, 
			/*[out, retval]*/IMTConfigFileList** apConfigFileList);

	STDMETHOD(GetAllFiles)(/*[in]*/BSTR aCompName, 
			/*[in]*/BSTR aFileName,
			/*[out, retval]*/IMTConfigFileList** apConfigFileList);

	STDMETHOD(InitWithPath)(/*[in]*/BSTR aRootPath);

	STDMETHOD(Init)();

	STDMETHOD(get_AutoEnumConversion)(VARIANT_BOOL* vbResult);
	STDMETHOD(put_AutoEnumConversion)(VARIANT_BOOL vbInput);

private:
	typedef CComObject<CMTConfigFileList> MTConfigFileListObj;

	BOOL NumberCheck(const string & aStrNo);
	BOOL FilenameEvaluator(const string & aOrgFN, 
												 const string & aFdFN, 
													BOOL& apVerFlag);

	time_t ParseVariantDate(VARIANT aDate);

	HRESULT RemoveDismissedFile(IMTConfigFileList* apConfigList);

	BOOL SetConfigInfo(const string & aFullFileName, 
										IMTConfigFileList* apConfigList, 
										BOOL& apVerFlag);

	BOOL GetConfigFiles(const string & aFullPath, 
											const string & aFileName, 
											IMTConfigFileList* apConfigList);

	void GetFullFileNM(char* apCompName, char* apFileName, 
										 string & aFullPath,
										 string & aFileName);

	void PathNameSuffix(string & aPath);

	BOOL LoadRootConfig();

	BOOL SetRootVal(BSTR aRootPath=NULL);

	void GetTestFilename(const string & aFilename, string & aTestFilename);

	// member variables
	NTLogger						mLogger;

	string						  mRoot;

	CPathColl						mCPathList;

	IMTConfigFileList*	mpMTConfigList;

	BOOL								mInitialized;

	BOOL								mTestMode;
	VARIANT_BOOL								mAutoEnumConversion;

};

#endif //__MTCONFIGLOADER_H_
