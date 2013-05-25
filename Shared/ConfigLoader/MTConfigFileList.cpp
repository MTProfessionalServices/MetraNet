/**************************************************************************
 * @doc MTCONFIGFILELIST
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

// MTConfigFileList.cpp : Implementation of CMTConfigFileList
#include "StdAfx.h"
#include <comdef.h>
#include "ConfigLoader.h"
#include "MTConfigFileListImpl.h"
#include "MTConfigInclude.h"

#include <loggerconfig.h>

#include <stdutils.h>
#include <string>
using std::string;


/////////////////////////////////////////////////////////////////////////////
// CMTConfigFileList

STDMETHODIMP CMTConfigFileList::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigFileList,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTConfigFileList::CMTConfigFileList()
{
#if MTDEBUG
	cout << "CMTConfigFileList::CMTConfigFileList() called" << endl;
#endif

	mSize = 0;

	// initialize log
	LoggerConfigReader configReader;
	mAuditLogger.Init(configReader.ReadConfiguration("ConfigLoader"), CONFIGLOADER_TAG);

}

CMTConfigFileList::~CMTConfigFileList()
{
#if MTDEBUG
	cout << "CMTConfigFileList::~CMTConfigFileList() called: " << mSize << endl;
#endif

	while (mSize > 0)
	{
		RemoveItem(mSize);
	}
}

STDMETHODIMP CMTConfigFileList::get_Count(long * apVal)
{
	if (apVal == NULL)
			return E_POINTER;

	*apVal = mSize;

	return S_OK;
}

STDMETHODIMP CMTConfigFileList::put_Count(long aNewVal)
{
	mSize = aNewVal;

	return S_OK;
}

STDMETHODIMP CMTConfigFileList::get_Item(long aIndex, VARIANT * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	VariantInit(apVal);
	apVal->vt = VT_UNKNOWN;
	apVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
		return E_INVALIDARG;

	//VariantCopy(apVal, mConfigFileList[aIndex-1]);
	VariantCopy(apVal, &mConfigFileList[aIndex-1]);

	return S_OK;
}


STDMETHODIMP CMTConfigFileList::get__NewEnum(LPUNKNOWN * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = NULL;
	typedef CComObject<CComEnum<IEnumVARIANT, 
												&IID_IEnumVARIANT, 
												VARIANT, 
												_Copy<VARIANT> > > enumVar;

	enumVar* pEnumVar = new enumVar;
	ASSERT(pEnumVar);

	// NOTE: end pointer has to be one past the end of the list
	HRESULT hRes = pEnumVar->Init(&mConfigFileList[0], 
																&mConfigFileList[mSize - 1] + 1,
																NULL,
																AtlFlagCopy);
	if (SUCCEEDED(hRes))
	{
		hRes = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)apVal);
	}

	if (FAILED(hRes))
	{
		delete pEnumVar;
	}

	return hRes;
}

STDMETHODIMP CMTConfigFileList::AddCFile(::IMTConfigPropSet* apMainVal, 
																				 ::IMTConfigPropSet* apVal, 
																				 long aEffDate, 
																				 long aLingerDate,
																				 BSTR	aFilename)
{
	if (apVal == NULL)
	{
		return E_POINTER;
	}

	long effectDate;
	IMTConfigFile* pConfigFile;

	// Create a new MTConfigFile object
	CComObject<CMTConfigFile>* pMTCFile;

	HRESULT hRes = CComObject<CMTConfigFile>::CreateInstance(&pMTCFile);
	ASSERT(SUCCEEDED(hRes));

	// set ref count to 1
	pMTCFile->AddRef();

	// Set the value into the object
	pMTCFile->put_MainConfigData(apMainVal);

	pMTCFile->put_ConfigData(apVal);

	pMTCFile->put_EffectDate(aEffDate);

	pMTCFile->put_LingerDate(aLingerDate);

	pMTCFile->put_ConfigFilename(aFilename);

	// get IDispatch pointer
	LPDISPATCH lpDisp = NULL;
	pMTCFile->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	ASSERT(lpDisp);

	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;

	string srcNameString;
	string tgNameString;
	long srcVersion;
	long tgVersion;

	BSTR filename;
	string srcFilename;
	string targetFilename;

	srcFilename = _bstr_t(aFilename);

	// search through the list to find the right index for new config
	for (int index = 0; index < mSize; index++)
	{
		lpDisp = NULL;
		
		lpDisp = mConfigFileList[index].pdispVal;

		lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);

		ASSERT(pConfigFile);

		pConfigFile->get_EffectDate(&effectDate);

		pConfigFile->get_ConfigFilename(&filename);

		targetFilename = _bstr_t(filename);
		SysFreeString(filename);

		// Adjust the ref counter
		int ref = lpDisp->Release();
#if MTDEBUG
		cout << "ref(CMTConfigFileList::AddCFile): " << ref << endl;
#endif

		if (aEffDate == effectDate)
		{
			ParseFilename(srcFilename, srcNameString, &srcVersion);
			ParseFilename(targetFilename, tgNameString, &tgVersion);

			// sort file in alphabetical order of file name
			if (strcasecmp(srcNameString, tgNameString) == 0)
			{
				if (srcVersion >= tgVersion)
				{
					break;
				}
			}
			else if (strcasecmp(srcNameString, tgNameString) > 0)
			{
				break;
			}

		}
		else if (aEffDate > effectDate)
		{
			break;
		}
	}

	// insert data into the right position
	mConfigFileList.insert(mConfigFileList.begin() + index, var);
	mSize++;

	pMTCFile->Release();

	return S_OK;
}

STDMETHODIMP CMTConfigFileList::CalculateEffDate()
{
	int index;
	long effDate1;
	long effDate2;
	long lingerDate;
	long dismissDate;
	IMTConfigFile* pConfigFile;
	LPDISPATCH lpDisp = NULL;
	int ref;


	ASSERT(mConfigFileList.size());

	lpDisp = mConfigFileList[0].pdispVal;

	lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);

	ASSERT(pConfigFile);

	pConfigFile->get_EffectDate(&effDate1);

	// adjust the ref counter
	ref = pConfigFile->Release();

	for (index = 1; index < mSize; index++)
	{
		lpDisp = NULL;

		lpDisp = mConfigFileList[index].pdispVal;
		lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);

		ASSERT(pConfigFile);
		
		pConfigFile->get_EffectDate(&effDate2);
		pConfigFile->get_LingerDate(&lingerDate);
		
		if (effDate1 >= effDate2)
		{
			pConfigFile->put_ExpireDate(effDate1);
			dismissDate = effDate1 + (lingerDate * 24 * 60 * 60); // seconds in one day
			pConfigFile->put_DismissDate(dismissDate);

			// adjust the ref counter
			ref = pConfigFile->Release();

			effDate1 = effDate2;
		}
		else
		{
			// adjust the ref counter
			ref = pConfigFile->Release();

			// TODO: log error here

			return S_FALSE;
		}
	}

	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTConfigFileList::get_EffectConfig(long aCurDate, 
																								 ::IMTConfigPropSet* * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	long effDate;
	long expDate;
	int index;
	IMTConfigFile* pConfigFile;
	LPDISPATCH lpDisp = NULL;
	int ref;

	*apVal = NULL;
	for (index = 0; index < mSize; index++)
	{
		lpDisp = NULL;

		lpDisp = mConfigFileList[index].pdispVal;
		lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);

		ASSERT(pConfigFile);
		
		pConfigFile->get_EffectDate(&effDate);
		pConfigFile->get_ExpireDate(&expDate);

		// if the file is in effect and no expiration date or 
		// the file has expiration date but not expired yet
		if (aCurDate >= effDate && ((expDate == 0) || (aCurDate < expDate)))
		{
			pConfigFile->get_ConfigData(apVal);
			ref = pConfigFile->Release();
			//cout << "ref(get_effectiveConfig): " << ref << endl;

			BSTR filename;

			pConfigFile->get_ConfigFilename(&filename);

			_bstr_t filenameBstr(filename,false);
			
			string filenameRWCS;
			filenameRWCS = filenameBstr;

			LogConfigFilename(filenameRWCS);

			break;
		}

		ref = pConfigFile->Release();
	}

	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTConfigFileList::RemoveItem(long aIndex)
{
#if 0
	LPDISPATCH			lpDisp = NULL;
	IMTConfigFile*	pConfigFile;
	int							ref;

	CComVariant& var = mConfigFileList[aIndex-1];
	lpDisp = var.pdispVal;

	if (lpDisp != NULL)
	{

		lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);
		// adjust the refcounter
		ref = lpDisp->Release();
		cout << "ref(CMTConfigFileList::RemoveItem(ADJ): " << ref << endl;

		// delete the object
		if (pConfigFile != NULL)
		{
			ref = pConfigFile->Release();
			cout << "ref(CMTConfigFileList::RemoveItem): " << ref << endl;
		}
	}
#endif

	mConfigFileList.erase(mConfigFileList.begin() + aIndex - 1);

	mSize--;

	return S_OK;
}

//////////////////////////////////////////////////////////////////////
void CMTConfigFileList::LogConfigFilename(const string & aFilename)
{
	BOOL							bRetCode;
	char							logBuf[MAX_BUFFER_SIZE];

	sprintf (logBuf, "Loaded configuration file: %s", aFilename.c_str());
	bRetCode = mAuditLogger.LogThis(LOG_INFO, logBuf);
}


//////////////////////////////////////////////////////////////////////
void CMTConfigFileList::ParseFilename(const string & aFilename, 
																			string & aNameString, 
																			long* aVersion)
{
	string filename;
	long length;
	string setName;

	// get file name without extension
	string::size_type index = strfind(aFilename, XML_EXT);
	filename = aFilename.substr(0, index);

	index = strfind(filename, VERSION_SYMBOL);
	index += strlen(VERSION_SYMBOL);
	length = filename.length() - index;

	setName = filename.substr(index, length);

	string temp;
	const char* c;
	for (index = setName.length(); index >= 1; index--)
	{
		temp = setName[index-1];
		c = temp.c_str();
		if (!isdigit(*c))
		{
			break;
		}
	}

	length = setName.length() - index;
	temp = setName.substr(index, length);

	c = temp.c_str();

	aNameString = setName.substr(0, index);
	*aVersion = atol(c);

}
