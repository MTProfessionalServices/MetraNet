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
 * $Date: 10/21/2002 8:11:19 AM$
 * $Author: Raju Matta$
 * $Revision: 45$
 ***************************************************************************/

// MTConfigLoader.cpp : Implementation of CMTConfigLoader
#include "StdAfx.h"
#include <time.h>
#include <winbase.h>

#include "ConfigLoader.h"
#include "MTConfigLoader.h"

#import <MTConfigLib.tlb>
using namespace MTConfigLib;

#include "mtprogids.h"
#include "MTUtil.h"

const char rootConfigFN[] = "MTConfiguration.xml";

#include <loggerconfig.h>

#include <ConfigDir.h>
#include <iostream>
#include <stdutils.h>
#include <mtcomerr.h>
#include <string>
using std::string;

/////////////////////////////////////////////////////////////////////////////
// CMTConfigLoader

STDMETHODIMP CMTConfigLoader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigLoader,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTConfigLoader::CMTConfigLoader() : mAutoEnumConversion(VARIANT_TRUE)
{
	mpMTConfigList = NULL;

	mInitialized = FALSE;

	mTestMode = FALSE;
}

CMTConfigLoader::~CMTConfigLoader()
{
	if (mpMTConfigList != NULL)
	{
		int refCount = mpMTConfigList->Release();

#if MTDEBUG
		cout << "refCount(CMTConfigLoader::~CMTConfigLoader()): " << refCount << endl;
#endif
	}
}

STDMETHODIMP CMTConfigLoader::Init()
{
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

	// if not initialized yet
	if (mInitialized == FALSE)
	{
		// initialize log
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("logging\\ConfigLoader\\"), CORE_TAG);
	}

	if (SetRootVal() == FALSE)
	{
		sprintf(logBuf, "Failed to set root value");
		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf) ;
		return Error(logBuf);
	}

	sprintf(logBuf, "mRoot: %s length: %d", mRoot.c_str(), mRoot.length());
#if MTDEBUG
	printf ("%s\n", logBuf);
#endif
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

  if (bRetCode == FALSE)
  {
		std::cout << "ERROR: unable to log this. Error = " << logBuf << std::endl ;
		return E_FAIL;
	}

	mInitialized = TRUE;

	return S_OK;
}

STDMETHODIMP CMTConfigLoader::InitWithPath(BSTR aRootPath)
{
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

	if (mInitialized == FALSE)
	{
		// initialize log
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration("Logging\\ConfigLoader"), CORE_TAG);
	}

	if (SetRootVal(aRootPath) == FALSE)
	{
		sprintf (logBuf, "Failed to set root value");

		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return Error(logBuf);
	}

#if MTDEBUG
	cout << "mRoot: " << mRoot << endl;
#endif

	mInitialized = TRUE;

	return S_OK;
}

//-------------------------------------------------------------------
//
//
//
//-------------------------------------------------------------------
STDMETHODIMP CMTConfigLoader::GetAllFiles(BSTR aCompName, 
				BSTR aFileName,
				IMTConfigFileList * * apConfigFileList)
{
	BOOL bRetCode;
	HRESULT hRes;
	char logBuf[MAX_BUFFER_SIZE];
	int ref;

	try
	{
		if (mInitialized == FALSE)
		{
			sprintf (logBuf, "ConfigLoader is not initialized - call Init() first");
			MT_THROW_COM_ERROR(logBuf);
		}
	
		if (apConfigFileList == NULL)
		{
			sprintf (logBuf, "Bad return address");
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
			return E_POINTER;
		}
	
		_bstr_t bstrCompName(aCompName);
		_bstr_t bstrFileName(aFileName);
		char*		pCompNameChar;
		char*		pFileNameChar;
	
		pCompNameChar = bstrCompName;
		pFileNameChar = bstrFileName;
		if (pFileNameChar == NULL || strlen(pFileNameChar) == 0)
		{
			sprintf (logBuf, "Bad input parameter(aFileName)");
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
			MT_THROW_COM_ERROR(logBuf);
		}
	
		string fullFilePath;
		string fileName;
	
		// Get file path and file name with *
		GetFullFileNM(pCompNameChar, pFileNameChar, fullFilePath, fileName);
	
		MTConfigFileListObj* pMTConfigList;
		hRes = MTConfigFileListObj::CreateInstance(&pMTConfigList);
		ASSERT(SUCCEEDED(hRes));
	
		// set ref count to 1
		pMTConfigList->AddRef();
	
		if (GetConfigFiles(fullFilePath, fileName, pMTConfigList) == FALSE)
		{
			ref = pMTConfigList->Release();
			sprintf (logBuf, 
				"Can not get config data from %s%s", 
				fullFilePath.c_str(),
				pFileNameChar);
			bRetCode = mLogger.LogThis(LOG_ERROR, logBuf) ;
			MT_THROW_COM_ERROR(logBuf);
		}
	
		pMTConfigList->CalculateEffDate();
	
		// increase the reference counter to 1
		hRes = pMTConfigList->QueryInterface(IID_IMTConfigFileList,
															reinterpret_cast<void**>(apConfigFileList));
	
		// Adjust the ref count - we done with pMTConfigList
		ref = pMTConfigList->Release();
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	
	return hRes;
}

STDMETHODIMP CMTConfigLoader::GetActiveFiles(BSTR aCompName, 
				BSTR aFileName, 
				IMTConfigFileList * * apConfigFileList)
{
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];

	try
	{
		if (mInitialized == FALSE)
		{
			sprintf (logBuf, "ConfigLoader is not initialized - call Init() first");
			MT_THROW_COM_ERROR(logBuf);
		}
		
		if (apConfigFileList == NULL)
		{
			sprintf (logBuf, "Bad return address(apConfigFileList)");
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
			return E_POINTER;
		}
		
		IMTConfigFileList* pMTConfigList = NULL;
	
		GetAllFiles(aCompName, aFileName, &pMTConfigList);

		// No configuration file was found
		if (pMTConfigList == NULL)
		{
#if MTDEBUG
			cout << "No Config data available" << endl;
#endif
			sprintf (logBuf, 
							 "No Config data available for %s", 
							 (const char*)_bstr_t(aFileName));
			bRetCode = mLogger.LogThis(LOG_ERROR, logBuf) ;
			MT_THROW_COM_ERROR(logBuf);  
		}

		HRESULT hRes = RemoveDismissedFile(pMTConfigList);

		if (!SUCCEEDED(hRes))
		{
			pMTConfigList->Release();
#if MTDEBUG
			cout << "Error returned from RemoveDismissedFile()" << endl;
#endif
			sprintf (logBuf, "Error returned from RemoveDismissedFile()");
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
			return hRes;
		}

		*apConfigFileList = pMTConfigList;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

/*-------------------------------------------------------------
*
*
*
*--------------------------------------------------------------*/
STDMETHODIMP CMTConfigLoader::GetEffectiveFile(BSTR aCompName, 
				BSTR aFileName, 
				::IMTConfigPropSet * * apConfigPropSet)
{
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];


	if (apConfigPropSet == NULL)
	{
		sprintf (logBuf, "Bad return address(apConfigPropSet)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
		return E_POINTER;
	}

	*apConfigPropSet = NULL;
	time_t curDate;
	time(&curDate);

	VARIANT varDate;

	varDate.vt = VT_I8;
	varDate.llVal = curDate;
	HRESULT hRes = GetEffectiveFileWithDate(aCompName, 
																					aFileName, 
																					varDate, 
																					apConfigPropSet);

	if (!SUCCEEDED(hRes))
	{
		sprintf (logBuf, "Error returned from GetEffectiveFileWithDate()");
		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf) ;
		return hRes;
	}

	return hRes;
}

////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTConfigLoader::GetEffectiveFileWithDate(BSTR aCompName, 
				BSTR aFileName, 
				VARIANT aDate, 
				::IMTConfigPropSet * * apConfigPropSet)
{
	BOOL bRetCode;
	char logBuf[MAX_BUFFER_SIZE];


	IMTConfigFileList* pMTConfigList = NULL;

	if (mInitialized == FALSE)
	{
		sprintf (logBuf, "ConfigLoader is not initialized - call Init() first");
		return Error(logBuf);
	}

	if (apConfigPropSet == NULL)
	{
		sprintf (logBuf, "Bad return address(apConfigPropSet)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
		return E_POINTER;
	}

	time_t effDate = ParseVariantDate(aDate);

	if (effDate <= 0LL)
	{
#if MTDEBUG
		cout << "Error returned from ParseVariantDate()" << endl;
#endif
		sprintf (logBuf, "Error returned from ParseVariantDate()");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
		return E_INVALIDARG;
	}

	// clean up the list if it is not the first time call
	if (mpMTConfigList != NULL)
	{
		mpMTConfigList->Release();

		mpMTConfigList = NULL;
	}

	try
	{
		GetAllFiles(aCompName, aFileName, &pMTConfigList);
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	// No configuration file was found
	if (pMTConfigList == NULL)
	{
#if MTDEBUG
		cout << "No Config data available" << endl;
#endif
		sprintf (logBuf, 
						 "No Config data available for %s", 
						 (const char*)_bstr_t(aFileName));
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf) ;
		return Error(logBuf);  // throw an exception or S_FALE which will not throw exception
	}

	// get effective configuration
	HRESULT hRes = pMTConfigList->get_EffectConfig((long) effDate, apConfigPropSet);

	// Save the config list pointer so that the main pointer of propSet 
	// will not get either lost or deleted
	mpMTConfigList = pMTConfigList;

	return hRes;
}


STDMETHODIMP CMTConfigLoader::get_AutoEnumConversion(VARIANT_BOOL* vbResult)
{
	ASSERT(vbResult);
	if(!vbResult) return E_POINTER;
	*vbResult = mAutoEnumConversion;
	return S_OK;
}

STDMETHODIMP CMTConfigLoader::put_AutoEnumConversion(VARIANT_BOOL vbInput)
{
	mAutoEnumConversion = vbInput;
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////////////////
BOOL CMTConfigLoader::SetRootVal(BSTR aPath)
{
	char logBuf[MAX_BUFFER_SIZE];
	BOOL bRetCode = TRUE;
  
	_bstr_t bstrPath(aPath);
	char* charPath = (char*)bstrPath;

	if (charPath == NULL)
	{
		if (GetMTConfigDir(mRoot) == FALSE)
		{
			sprintf(logBuf, "Fail in getting configuration directory name");
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			return FALSE;
		}
		
	}
	else
	{
		mRoot = bstrPath;
		PathNameSuffix(mRoot);
	}

	return bRetCode;
}

BOOL CMTConfigLoader::LoadRootConfig()
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];
	string fullFN;
	_bstr_t		compName;
	_bstr_t		compValue;
	char*			compChar;
	string	RWCompName;
	string	RWCompValue;


	// if this is not first time to load the config
	if (mInitialized == TRUE)
	{
		if (mCPathList.size() > 0)
		{
			mCPathList.clear();
		}
	}

	fullFN = mRoot + rootConfigFN;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	VARIANT_BOOL flag;
	config->PutAutoEnumConversion(mAutoEnumConversion);
	MTConfigLib::IMTConfigPropSetPtr mainSet = config->ReadConfiguration(fullFN.c_str(), &flag);
	if (mainSet == NULL)
	{
		sprintf (logBuf,"Error read root config file(config->ReadConfiguration())");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return FALSE;
	}

	// check to see if the deployment status header exists
	if (mainSet->NextMatches(DEPLOYMENT_STATUS, MTConfigLib::PROP_TYPE_SET) == VARIANT_TRUE)
	{
		MTConfigLib::IMTConfigPropSetPtr deployStatus = mainSet->NextSetWithName(DEPLOYMENT_STATUS);
		if (deployStatus != NULL)
		{
			VARIANT_BOOL testMode = deployStatus->NextBoolWithName(TEST_DEPLOYMENT_MODE);
			mTestMode = (testMode == VARIANT_TRUE) ? TRUE : FALSE;
		}

	}

	MTConfigLib::IMTConfigPropSetPtr subSet = mainSet->NextSetWithName(COMPONENT);

	if (subSet == NULL)
	{
		sprintf (logBuf, "Error read root config file(mainSet->NextSetWithName(%s))", COMPONENT);
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return FALSE;
	}

	while (subSet != NULL)
	{
		// get name
		compName = subSet->NextStringWithName(COMPONENT_NAME);
		compChar = compName;
		if (compChar == NULL)
		{
			//log error
			sprintf (logBuf, "Expecting TAG name: %s (subSet->NextStringWithName())", COMPONENT_NAME);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			bRetCode = FALSE;
			break;
		}
		RWCompName = compName;

		// get value
		compValue = subSet->NextStringWithName(COMPONENT_VALUE);
		compChar = compValue;
		if (compChar == NULL)
		{
			//log error
			sprintf (logBuf, "Expecting TAG name: %s (subSet->NextStringWithName())", COMPONENT_VALUE);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			bRetCode = FALSE;
			break;
		}	
			
		RWCompValue = compValue;

		PathNameSuffix(RWCompValue);

		// add to the list
		mCPathList[RWCompName] = RWCompValue;

		subSet = mainSet->NextSetWithName(COMPONENT);
	}

	return bRetCode;
}


void CMTConfigLoader::PathNameSuffix(string & aPath)
{
	if (aPath.length() != 0)
	{
		if (aPath[aPath.length()-1] != '\\')
		{
			aPath = aPath + "\\";
		}
	}

}


void CMTConfigLoader::GetFullFileNM(char * apCompName, 
																		char * apFileName, 
																		string & aFullPath,
																		string & aFileName)
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];
	// compose a full file path
	string path;

	CPathColl::iterator it = mCPathList.find(apCompName);
	if (it == mCPathList.end())
	{
		// use input as the relative path if component name is not
		// in the list
		path = apCompName;
		PathNameSuffix(path);
	}
	else
	{
		path = it->second;
	}

	if (path.length() > 0 && path[0] == '\\')
	{
		path = path.erase(0, 1);
	}

	aFullPath = (mRoot + path).c_str();

	// parse file name to add * as possible version number
	aFileName = apFileName;
	string::size_type id = strfind(aFileName, XML_EXT);

	if (id == string::npos)
	{
		aFileName = aFileName + WILDCARD_CHAR + XML_EXT;
	}
	else
	{
		aFileName.insert(id, WILDCARD_CHAR);
	}

#if MTDEBUG
	cout << aFileName << " id: " << id << endl;
#endif
	sprintf (logBuf, "Filename: %s", aFileName.c_str());
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
}


BOOL CMTConfigLoader::GetConfigFiles(const string & aFullPath,
																		 const string & aFileName,
																		 IMTConfigFileList * apConfigList)
{
	BOOL							bRetCode;
	char							logBuf[MAX_BUFFER_SIZE];
	WIN32_FIND_DATAA	fileData;  // for ascii version
	string 					  fileName;
	BOOL							nameVerFlag = TRUE;
	BOOL							verFlag1;
	BOOL							verFlag2 = TRUE;
	HANDLE						hFile = 0;
	int								numberOfConfig = 0;

	fileName = aFullPath + aFileName;

	string filePath;
	string localFilename;

	ParseFilename(fileName, filePath, localFilename);

#if MTDEBUG
		cout << "fileName: " << fileName << endl;
		cout << "filePath: " << filePath << endl;
		cout << "localFilename: " << localFilename << endl;
#endif

	if (mTestMode)
	{
		// get test file name
		string testFilename;
		GetTestFilename(fileName, testFilename);
		
		// check if there is a test file exist
		if (CheckFile(testFilename))
		{
			if (SetConfigInfo(testFilename, apConfigList, verFlag2) == FALSE)
			{
				// log error message
				bRetCode = mLogger.LogVarArgs(LOG_DEBUG, 
																		"Bad config file found - filename: %s", 
																		testFilename.c_str());

				return FALSE;
			}

			return TRUE;
		}
	}

	// call FindFirstFile(), findNextFile() to get real file name
	hFile = FindFirstFileA(fileName.c_str(), &fileData); // ascii version
	if (hFile == INVALID_HANDLE_VALUE)
	{
#if MTDEBUG
		cout << "No file found: " << aFullPath << aFileName << endl;
#endif

		sprintf (logBuf, "No file found - Path: %s filename: %s", 
						aFullPath.c_str(), aFileName.c_str());
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

		FindClose(hFile);
		return FALSE;
	}

	// use while loop to get all the files
	bRetCode = TRUE;
	while (bRetCode)
	{
#if MTDEBUG
		cout << "found file: " << filePath << fileData.cFileName << endl;
#endif

		verFlag1 = TRUE;
		// filter out possible similar file name
		if (FilenameEvaluator(localFilename, fileData.cFileName, verFlag1) == TRUE)
		{
			sprintf (logBuf, "Found file - Path: %s filename: %s", 
							localFilename.c_str(), fileData.cFileName);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

#if 0  // turn off the version number check so that both versioned and none versioned files will coexist.
			if (nameVerFlag == TRUE && nameVerFlag != verFlag1)
			{
				nameVerFlag = verFlag1;
			}
			else
			{
				if (nameVerFlag == FALSE)
				{
					sprintf (logBuf, 
					"File name with a version number and without a version number coexist: %s", aFileName.c_str());
					bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

					FindClose(hFile);

					return FALSE;
				}
			}
#endif
			// get the real full file name
			fileName = filePath + fileData.cFileName;

			// for each file, read in the MTsysconfigdata section
			// to get effective date, linger date of the file
			// set these value in config list

			// if there is no mtsysconfigdata section exist
			// this is a version less config file
			if (SetConfigInfo(fileName, apConfigList, verFlag2) == FALSE)
			{
				// log error message
#if MTDEBUG
				cout << "Bad config file found: " << fileName << endl;
#endif
				sprintf (logBuf, "Bad config file found - filename: %s", 
								fileName.c_str());
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

				return FALSE;
			}

			// increment the number of config files found
			numberOfConfig++;

			// this is a version less config file
			if (verFlag2 == FALSE)
			{
				// for version less file, we stop here
#if MTDEBUG
				cout << "load version less file: " << fileName << endl;
#endif
				sprintf (logBuf, "load version less file - filename: %s", fileName.c_str());
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

				break;
			}
		}
		else
		{
			sprintf (logBuf, "Filter out similar file - Path: %s filename: %s", 
							filePath.c_str(), fileData.cFileName);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		}

		// get next file
		bRetCode = FindNextFileA(hFile, &fileData);
	}

	FindClose(hFile);

	if (numberOfConfig == 0)
	{
		sprintf (logBuf, "No file found(2) - Path: %s filename: %s", 
						aFullPath.c_str(), aFileName.c_str());
		bRetCode = mLogger.LogThis(LOG_ERROR, logBuf);
		return FALSE;
	}
	else
	{
		return TRUE;
	}
}

/*------------------------------------------------------------------
 *
 *	file format:
 *		<xmlconfig>
 *			<mtsysconfigdata>
 *				<effective_date ptype="DATATIME">1998-11-1T00:00:00Z</effective_date>
 *				<linger_day>30</linger_day>
 *				<file_type>CONFIG_DATA</file_type>
 *			</mtsysconfigdata>
 *
 *			<mtconfigdata>
 *				<!-- config data -->
 *
 *			</mtconfigdata>
 *
 *		</xmlconfig>
 *
 *------------------------------------------------------------------*/
BOOL CMTConfigLoader::SetConfigInfo(const string & aFullFileName, 
																		IMTConfigFileList * apConfigList,
																		BOOL& aVerFlag)
{
	BOOL							bRetCode;
	char							logBuf[MAX_BUFFER_SIZE];

	if (apConfigList == NULL)
	{
		sprintf (logBuf, "Bad argument(apConfigList)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return FALSE;
	}

	long		effectDate = 0;
	long		lingerDate = 0;
	_bstr_t	fileType;
	string RWCType;


	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	//config->PutAutoEnumConversion(false);

	VARIANT_BOOL flag;

	MTConfigLib::IMTConfigPropSetPtr mainSet = NULL;

	try {
		config->PutAutoEnumConversion(mAutoEnumConversion);
		mainSet = config->ReadConfiguration(aFullFileName.c_str(), &flag);
	}
	catch(_com_error&) {
	// we don't really care... obviously the file failed to parse.
	}

	if (mainSet == NULL)
	{
		sprintf (logBuf, "Error read config file(config->ReadConfiguration())");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return FALSE;
	}

	if (flag == VARIANT_FALSE)
	{
		sprintf (logBuf, "Checksum mismatch - file %s",
						aFullFileName.c_str());
		bRetCode = mLogger.LogThis(LOG_WARNING, logBuf);
	}

	VARIANT_BOOL propSetFlag;
	propSetFlag = mainSet->NextMatches(MTSYSCONFIGDATA, MTConfigLib::PROP_TYPE_SET);

	if (!mTestMode && propSetFlag == VARIANT_TRUE)
	{
		MTConfigLib::IMTConfigPropSetPtr subSet = mainSet->NextSetWithName(MTSYSCONFIGDATA);

		MTConfigLib::IMTConfigPropPtr prop = subSet->NextWithName(EFFECTIVE_DATE);

		if (prop == NULL)
		{
			//log error
			sprintf (logBuf, "Expecting TAG name: %s (subSet->NextWithName()) in", EFFECTIVE_DATE);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

			return FALSE;
		}

		MTConfigLib::PropValType type;
		VARIANT propVal;

		// try to get the value
		propVal = prop->GetValue(&type);

		// release the property now whether it was the correct type or not
		if (type != MTConfigLib::PROP_TYPE_DATETIME)
		{
			// log error
			sprintf (logBuf, "%s TYPE should be MTConfigLib::PROP_TYPE_DATETIME", EFFECTIVE_DATE);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			return FALSE;
		}
		effectDate = (long)propVal.lVal;

		prop = subSet->NextWithName(LINGER_DAY);
		if (prop == NULL)
		{
			//use default linger_day value
			lingerDate = DEFAULT_LINGER_DAY;

			sprintf (logBuf, "No option field [%s] specified", LINGER_DAY);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

		}
		else
		{
			// try to get the value
			propVal = prop->GetValue(&type);

			if (type != MTConfigLib::PROP_TYPE_INTEGER)
			{
				// log error and use default value
				sprintf (logBuf, "%s TYPE should be MTConfigLib::PROP_TYPE_INTEGER", LINGER_DAY);
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
				lingerDate = DEFAULT_LINGER_DAY;
			}
			else
			{
				lingerDate = (long)propVal.lVal;
			}
		}

		prop = subSet->NextWithName(FILE_TYPE);

		if (prop == NULL)
		{
#if MTDEBUG
			cout << "No file type specified: [" << FILE_TYPE << "]" << endl;
#endif
			sprintf (logBuf, "No option field [%s] specified: %s", FILE_TYPE);
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

			RWCType = "CONFIG_DATA";
		}
		else
		{
			// try to get the value
			propVal = prop->GetValue(&type);

			if (type != MTConfigLib::PROP_TYPE_STRING)
			{
				// log error and use default value
				sprintf (logBuf, "%s TYPE should be MTConfigLib::PROP_TYPE_STRING", 
								FILE_TYPE);
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
				lingerDate = DEFAULT_LINGER_DAY;
			}
			else
			{
				RWCType = (_bstr_t)propVal;
			}
		}

	}
	else  // no effective date section, using the default value
	{
		effectDate = DEFAULT_EFFECTIVE_DATE;
		lingerDate = DEFAULT_LINGER_DAY;
		RWCType = "CONFIG_DATA";

		// log message
		bRetCode = mLogger.LogVarArgs(LOG_DEBUG, 
																	"Using default effective date: [%s]", 
																	aFullFileName);
	}

	MTConfigLib::IMTConfigPropSetPtr configDataSet;
	configDataSet = mainSet->NextSetWithName(MTCONFIGDATA);

	if (configDataSet == NULL)
	{
		bRetCode = mLogger.LogVarArgs(LOG_DEBUG, 
																	"Load versionless configuration file [%s]", 
																	aFullFileName.c_str());
		aVerFlag = FALSE;
		mainSet->Reset();

		configDataSet = mainSet;
	}

	::IMTConfigPropSet * pMainSetObj;
	::IMTConfigPropSet * pConfigSetObj;

	// Get object pointers for AddCFile() call
	int ref;

	mainSet->QueryInterface(IID_IMTConfigPropSet, 
													(void**)&pMainSetObj);

	configDataSet->QueryInterface(IID_IMTConfigPropSet, 
																(void**)&pConfigSetObj);

	_bstr_t filenameBstr(aFullFileName.c_str());
	HRESULT hRes = apConfigList->AddCFile(pMainSetObj, 
																				pConfigSetObj, 
																				effectDate, 
																				lingerDate,
																				filenameBstr);

	ref = pMainSetObj->Release();

	ref = pConfigSetObj->Release();

	if (!SUCCEEDED(hRes))
	{
		sprintf (logBuf, "Fail to add config file to list(apConfigList->AddCFile())");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

		return FALSE;
	}

	return TRUE;
}

STDMETHODIMP CMTConfigLoader::GetPath(BSTR aCompName,  
																			BSTR * apRetVal)
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];

	if (mInitialized == FALSE)
	{
		sprintf (logBuf, "ConfigLoader is not initialized - call Init() first");
		return S_FALSE;
	}

	if (apRetVal == NULL)
	{
		sprintf (logBuf, "Bad return address(apRetVal)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

		return E_POINTER;
	}

	_bstr_t compNameBstr(aCompName);

	char* pCompNameChar;

	// compose a full file path
	string path;

	pCompNameChar = compNameBstr;

	if (pCompNameChar == NULL || strlen(pCompNameChar) == 0)
	{
		sprintf (logBuf, "Bad input parameter(aCompName)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return Error(logBuf);
	}

	CPathColl::iterator it = mCPathList.find(pCompNameChar);
	if (it == mCPathList.end())
	{
		// use input as the relative path if component name is not
		// in the list
		path = compNameBstr;
		PathNameSuffix(path);
	}
	else
	{
		path = it->second;
	}

	if (path.length() > 0 && path[0] == '\\')
	{
		path = path.erase(0, 1);
	}

	string aFullPath = mRoot + path;

	_bstr_t val(aFullPath.c_str());

	*apRetVal = val.copy();

	return S_OK;
}


HRESULT CMTConfigLoader::RemoveDismissedFile(IMTConfigFileList * apConfigList)
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];

	if (apConfigList == NULL)
	{
		sprintf (logBuf, "Bad parameter(apConfigList)");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return E_POINTER;
	}

	long						count = 0;
	LPDISPATCH			lpDisp = NULL;
	IMTConfigFile*	pConfigFile;
	long						dismissDate;
	time_t					curDate;

	time(&curDate);

	apConfigList->get_Count(&count);

	if (count == 0)
	{
		sprintf (logBuf, "No config in list");
		bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		return S_OK;
	}

	//TODO: from the end of the list to remove the file with dismiss date
	// earlier than curDate
	VARIANT var;
	while (count)
	{
		// get_Item() call uses VariantCopy() which increments pdispVal
		// refcount by 1
		apConfigList->get_Item(count, &var);

		lpDisp = NULL;
		lpDisp = var.pdispVal;

		lpDisp->QueryInterface(IID_IMTConfigFile, (void**)&pConfigFile);

		ASSERT(pConfigFile);

		pConfigFile->get_DismissDate(&dismissDate);

		// Adjust the ref Counter
		int ref = lpDisp->Release();

		if (curDate >= dismissDate && dismissDate != 0)
		{
			ref = pConfigFile->Release();
			apConfigList->RemoveItem(count);
		}
		else
		{
			// Since the list is sorted, we don't have to go further
			ref = pConfigFile->Release();
			break;
		}

		count--;
	}

	return S_OK;
}

time_t CMTConfigLoader::ParseVariantDate(VARIANT aDate)
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];
	time_t		lDate = 0LL;
	DATE		varDate;
	_bstr_t	bstrDate;

	switch(aDate.vt)
	{
		case VT_I4:
			lDate = aDate.lVal;
			break;

		case VT_I8:
			lDate = aDate.llVal;
			break;

		case VT_DATE:
			varDate = aDate.date;
			TimetFromOleDate(&lDate, varDate);
			break;

		case (VT_DATE | VT_BYREF):
			varDate = *(aDate.pdate);
			TimetFromOleDate(&lDate, varDate);
			break;

		case VT_BSTR:
			bstrDate = aDate.bstrVal;

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				sprintf (logBuf, "Bad effective date format(MTParseISOTime)");
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			}
			break;

		case (VT_BSTR | VT_BYREF):
			bstrDate = *(aDate.pbstrVal);

			//     YYYY-MM-DDThh:mm:ssTZD
			// ex: 1994-11-05T08:15:30-05:00
			if (MTParseISOTime((char *)bstrDate, &lDate) == FALSE)
			{
				sprintf (logBuf, "Bad effective date ref format(MTParseISOTime)");
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			}
			break;

		default:
			lDate = -1;
	}

	return lDate;
}


BOOL CMTConfigLoader::FilenameEvaluator(const string & aOrgFN, 
																				const string & aFdFN, 
																				BOOL& aVerFlag)
{
	BOOL			bRetCode = TRUE;
	char			logBuf[MAX_BUFFER_SIZE];
	int				extIndex = 0;
	int				len;
	string localFilename;


	string::size_type index = strfind(aFdFN, VERSION_SYMBOL);

	// 1. if filename does not have format fn_vnnn.xml
	if (index == string::npos)
	{
		string::size_type index = strfind(aFdFN, XML_EXT);

		if (index < 0)
		{
			localFilename = aFdFN + WILDCARD_CHAR + XML_EXT;
		}
		else
		{
			localFilename = aFdFN;
			localFilename.insert(index, WILDCARD_CHAR);
		}

		// 1.1 or aOrgFN != aFdFN
		if (strcasecmp(localFilename, aOrgFN) == 0)
		{
			// no version number in file name
			aVerFlag = FALSE;
			sprintf (logBuf, "File name %s does not have a version number", 
							aFdFN.c_str());
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
		}
		else
		{
			sprintf (logBuf, "File name %s does not match", aFdFN.c_str());
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

			return FALSE;
		}
		
	}
	else
	{
		// 2. if filename satisfy aOrgFN == fn
		string fnString;
		string fnOrgString;
		string wildcardExt(WILDCARD_CHAR);

#if MTDEBUG
		cout << "org file name: " << aOrgFN << endl;
		cout << "file name: " << aFdFN << endl;
#endif

		wildcardExt += XML_EXT;

		string::size_type extIndex = strfind(aOrgFN, wildcardExt);

		fnString = aFdFN.substr(0, index);
		fnOrgString = aOrgFN.substr(0, extIndex);

#if MTDEBUG
		cout << "sub org file name: " << fnOrgString << endl;
		cout << "sub file name: " << fnString << endl;
#endif

		if (strcasecmp(fnOrgString, fnString) == 0)
		{
			// check if the version number is defined
			index += strlen(VERSION_SYMBOL);  // get beginning of the version number
			string::size_type extIndex = strfind(aFdFN, XML_EXT);
			len = extIndex - index;
			string ver = aFdFN.substr(index , len);

#if MTDEBUG
			cout << ver << endl;
#endif

			if (NumberCheck(ver) == FALSE)
			{
				sprintf (logBuf, "Version number(%s) in file name %s is invalid", ver, 
								aFdFN.c_str());
				bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
				return FALSE;
			}
#if 0
			if (!mTestMode)
			{
				if (ver.compareTo(TEST_SYMBOL, RWCString::ignoreCase) == 0)
				{
					mLogger.LogVarArgs(LOG_DEBUG, 
														"Test file: %s ignored when it is not in tets mode",
														aFdFN.c_str());
					return FALSE;
				}
			}
#endif

		}
		else
		{
			sprintf (logBuf, "File name %s does not match", aFdFN.c_str());
			bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);
			return FALSE;
		}

	}

	sprintf (logBuf, "File name %s matches", aFdFN.c_str());
	bRetCode = mLogger.LogThis(LOG_DEBUG, logBuf);

	return TRUE;
}


BOOL CMTConfigLoader::NumberCheck(const string & aStrNo)
{
	return TRUE;
#if 0
	long verInt;
	char newVer[64];


	verInt = atol(aStrNo.c_str());
	sprintf(newVer, "%d", verInt);

	if ((aStrNo.length() == strlen(newVer)) &&
			(strncmp(aStrNo.c_str(), newVer, strlen(newVer)) == 0))
	{
		return TRUE;
	}
	else
	{
		// if this is a test version
		if (aStrNo.compareTo(TEST_SYMBOL, RWCString::ignoreCase) == 0)
		{
			return TRUE;
		}
	}

	return FALSE;
#endif
}


/////////////////////////////////////////////////////////////////////
void CMTConfigLoader::GetTestFilename(const string & aFilename, string & aTestFilename)
{
	aTestFilename = aFilename;
	string::size_type index = aFilename.find(WILDCARD_CHAR);

	if (index != string::npos)
	{
		aTestFilename.replace(index, strlen(WILDCARD_CHAR), TEST_FILENAME_SUFFIX);
	}
	mLogger.LogVarArgs(LOG_DEBUG, "Test file name: %s", aTestFilename.c_str());
}


