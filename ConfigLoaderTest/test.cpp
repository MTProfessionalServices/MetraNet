/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

#include <metra.h>
#include <time.h>
#include <iostream>


//#include "test.h"
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

#include "MTUtil.h"

#include <SetIterate.h>
#include <mtcomerr.h>

#include <stdutils.h>
using std::string;
using std::cout;
using std::endl;

#include "..\\MTConfigInclude.h"


_COM_SMARTPTR_TYPEDEF(IUnknown, __uuidof(IUnknown));

static class ComInitialize
{
public:
	ComInitialize()
	{ ::CoInitializeEx(NULL, COINIT_MULTITHREADED); }

	~ComInitialize()
	{ ::CoUninitialize(); }

} gComInitialize;



void Test1(char* aVal)
{


	IMTConfigLoaderPtr configLoader("MetraTech.MTConfigLoader.1");

	_bstr_t path(aVal);

	cout << "Calling InitWithPath()" << endl;
	configLoader->InitWithPath(path);
	

	IMTConfigPropSetPtr confSetPtr;
	
	_bstr_t	name;

	//time_t ltime;
	//time(&ltime);
	//_variant_t var(ltime);

	_bstr_t ldate;
	ldate = "1998-12-01T00:15:30-05:00";
	_variant_t var(ldate);

#if 0
	confSetPtr = configLoader->GetEffectiveFile("\\database", 
																								"MTSQLServer.xml");

	if (confSetPtr == NULL)
	{
		cout << "error returned" << endl;
		return;
	}
#endif
	cout << endl << "(1) Test GetEffectiveFile() - \\test\\ConfigLoader, configtest2.xml" << endl;
	confSetPtr = configLoader->GetEffectiveFile("\\test\\ConfigLoader", 
																							"configtest2.xml");

	if (confSetPtr == NULL)
	{
		cout << "error returned" << endl;
		return;
	}

	name = confSetPtr->NextStringWithName("svcname");
	cout << "Output data: " << (char*)name << endl;

	cout << endl;

	cout << "(2) Test GetEffectiveFileWithDate()" << endl;
	confSetPtr = configLoader->GetEffectiveFileWithDate("\\test\\ConfigLoader", 
																											"configtest2.xml", var);

	if (confSetPtr == NULL)
	{
		cout << "error returned" << endl;
		return;
	}
	name = confSetPtr->NextStringWithName("svcname");
	cout << "Output data: " << (char*)name << endl;

	cout << endl;

	cout << "(3) Test GetPath()" << endl;
	_bstr_t gpath = configLoader->GetPath("\\test\\ConfigLoader");
	cout << "Path: "<< (char*)gpath << endl;

	cout << endl;

	cout << "(4) Test GetEffectiveFile() with no file found: xxconfigtest2.xml" << endl;
	try
	{
		confSetPtr = configLoader->GetEffectiveFile("\\test\\ConfigLoader", 
																								"xxconfigtest2.xml");

		if (confSetPtr == NULL)
		{
			cout << "error returned" << endl;
			return;
		}
		name = confSetPtr->NextStringWithName("svcname");
		cout << "Output data: " << (char*)name << endl;
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

	cout << endl;

	cout << "(5) Test GetEffectiveFile() with no input file name" << endl;
	try
	{
		confSetPtr = configLoader->GetEffectiveFile("\\test\\ConfigLoader", 
																								"");

		if (confSetPtr == NULL)
		{
			cout << "error returned" << endl;
			return;
		}
		name = confSetPtr->NextStringWithName("svcname");
		cout << "Output data: " << (char*)name << endl;
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

	cout << endl;
	cout << "(6) Test GetEffectiveFile() with no <mtsysconfigdata> section" << endl;
	confSetPtr = configLoader->GetEffectiveFile("\\test\\ConfigLoader", 
																								"configtest.xml");
	
	if (confSetPtr == NULL)
	{
		cout << "error returned" << endl;
		return;
	}
	name = confSetPtr->NextStringWithName("svcname");
	cout << "Output data: " << (char*)name << endl;

	cout << endl;
	cout << "(7) Test GetEffectiveFile() with no option fields: <timeout> and <configfiletype>" << endl;
	confSetPtr = configLoader->GetEffectiveFile("\\test\\ConfigLoader", 
																								"configtest1.xml");
	
	if (confSetPtr == NULL)
	{
		cout << "error returned" << endl;
		return;
	}
	name = confSetPtr->NextStringWithName("svcname");
	cout << "Output data: " << (char*)name << endl;

}

void Test2(char* aReletiveDir, char* aFilename)
{
	if (aReletiveDir == NULL)
	{
		cout << "Missing relative path name" << endl;
		return;
	}

	if (aFilename == NULL)
	{
		cout << "Missing file name" << endl;
		return;
	}

	_bstr_t relativeName(aReletiveDir);
	_bstr_t filename(aFilename);

	IMTConfigLoaderPtr configLoader("MetraTech.MTConfigLoader.1");
	IMTConfigFileListPtr pConfigFileList;
#if 0
	cout << "(1) Test GetActiveFiles() before calling Init()" << endl;
	try
	{
	  configLoader->GetActiveFiles(relativeName, filename);
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}
#endif

	cout << "Calling Init()" << endl;
	configLoader->Init();

	IMTConfigPropSet*	conSet;
#if 0
	cout << "(2) Test GetActiveFiles()" << endl;
	IMTConfigFileListPtr pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																																			"configtest2.xml");

	long count = pConfigFileList->GetCount();

	cout << "(3) Test pConfigFileList->GetItem(i)" << endl;
	cout << "(4) Test conFilePtr->GetConfigData()" << endl;
	for (int i = 1; i <= count; i++)
	{
		_variant_t varConfSet = pConfigFileList->GetItem(i);

		IMTConfigFilePtr conFilePtr(varConfSet);

		conSet = conFilePtr->GetConfigData();

		IMTConfigPropSetPtr confSetPtr(conSet);

		if (confSetPtr == NULL)
		{
			cout << "error returned" << endl;
			return;
		}
		_bstr_t	name = confSetPtr->NextStringWithName("svcname");

		cout << endl << "Output data[" << i << "]: " << (char*)name << endl;
	}

	cout << "(5) Test GetPath()" << endl;
	_bstr_t gpath = configLoader->GetPath("\\test\\ConfigLoader");
	cout << "Path: "<< (char*)gpath << endl;
#endif

	cout << "(6) Test GetActiveFiles()" << endl;
	pConfigFileList = configLoader->GetActiveFiles(relativeName, filename);

	cout << "(7) Test pConfigFileList->Get_NewEnum()" << endl;
	IUnknown * unk = pConfigFileList->Get_NewEnum();

	SetIterator<IMTConfigFileListPtr, IMTConfigFilePtr> it;
	HRESULT hr = it.Init(pConfigFileList);
	if (FAILED(hr))
	  throw hr;

	long effectiveDate;
	struct tm *gmt;

	while (TRUE)
	{
		IMTConfigFilePtr conFilePtr = it.GetNext();
		if (conFilePtr == NULL)
		{
			break;
		}

		conSet = conFilePtr->GetConfigData();

		IMTConfigPropSetPtr confSetPtr(conSet);

		if (confSetPtr == NULL)
		{
			cout << "error returned" << endl;
			return;
		}
		_bstr_t	name = confSetPtr->NextStringWithName("svcname");

		cout << endl << "Output data:\t\t" << (char*)name << endl;
		
		effectiveDate = conFilePtr->GetEffectDate();

    gmt = gmtime( &effectiveDate );
    cout << "Effective time(GMT):\t" << asctime( gmt ) << endl;
	}
#if 0

	cout << endl;
	cout << "(10) Test GetActiveFiles() with no file found: xxconfigtest2.xml" << endl;
	try
	{
		pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																										"xxconfigtest2.xml");
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

	cout << endl;

	cout << "(11) Test GetActiveFiles() with configtest3.xml and configtest3_v100.xml" << endl;
	try
	{
		pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																										"configtest3.xml");
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

	cout << endl;

	cout << "(12) Test GetActiveFiles() with file name as .xml" << endl;
	try
	{
		pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																										".xml");
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}
#endif
}

void Test3()
{
	IMTConfigLoaderPtr configLoader("MetraTech.MTConfigLoader.1");

	cout << "Calling Init()" << endl;
	configLoader->Init();

	cout << endl;

	cout << "(1) Test GetActiveFiles() for match checksum()" << endl;
	try
	{
		IMTConfigFileListPtr pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																																				"view.xml");
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

	cout << endl;

	cout << "(2) Test GetActiveFiles() with mismatch checksum" << endl;
	try
	{
		IMTConfigFileListPtr pConfigFileList = configLoader->GetActiveFiles("\\test\\ConfigLoader", 
																																				"small.xml");
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

}

void Test4()
{
	IMTConfigLoaderPtr configLoader("MetraTech.MTConfigLoader.1");

	cout << "Starting test4: " << endl;
	cout << "Calling Init()" << endl;
	configLoader->Init();

	cout << endl;
	try
	{
		IMTConfigFileListPtr pConfigFileList = configLoader->GetAllFiles("\\test\\ConfigLoader", 
																																				"configtest2.xml");

		SetIterator<IMTConfigFileListPtr, IMTConfigFilePtr> it;
		HRESULT hr = it.Init(pConfigFileList);
		if (FAILED(hr))
			throw hr;

		long effectiveDate;
		struct tm *gmt;

		while (TRUE)
		{
			IMTConfigFilePtr conFilePtr = it.GetNext();
			if (conFilePtr == NULL)
			{
				break;
			}
#if 0
			conSet = conFilePtr->GetConfigData();

			IMTConfigPropSetPtr confSetPtr(conSet);

			if (confSetPtr == NULL)
			{
				cout << "error returned" << endl;
				return;
			}
			_bstr_t	name = confSetPtr->NextStringWithName("svcname");

			cout << endl << "Output data:\t\t" << (char*)name << endl;
#endif
			effectiveDate = conFilePtr->GetEffectDate();

			gmt = gmtime( &effectiveDate );
			cout << "Effective time(GMT):\t" << asctime( gmt ) << endl;
		}
	}
	catch(_com_error err)
	{
		cout << "caught exception" << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "Source: " << (const char *) src << endl;
	}

}


int main(int argc, char * argv[])
{
	int loopCount;
#if 0
	string aFilename("audioconfcall_vINSTALL12.xml");

	string filename;
	long length;
	string setName;

	// get file name without extension
	string::size_type index = strfind(aFilename, XML_EXT)
	filename = aFilename.substr(0, index);

	index = strfind(filename, VERSION_SYMBOL)
	index += strlen(VERSION_SYMBOL);
	length = filename.length() - index;

	setName = filename.substr(index, length);

	string temp;
	const char* c;
	for (index = setName.length()-1; index >= 0; index--)
	{
		temp = setName.substr(index, 1);
		c = temp.c_str();
		if (!isdigit(*c))
		{
			break;
		}
	}

	index++;

	length = setName.length() - index;
	temp = setName(index, length);

	c = temp.c_str();

	long aVersion = atol(c);

	temp = setName.substr(0, index);

	cout << aVersion << endl;
	cout << temp << endl;
#endif

	if (argv[2] == NULL || strlen(argv[2]) == 0)
	{
		loopCount = 1;
	}
	else
	{
		loopCount = atol(argv[2]);
	}

	try
	{
#if 0
		for (int i = 0; i < loopCount ; i++)
		{
		cout << "Entering Test1" << endl;
		Test1(argv[1]);
		}
		cout << endl;

#endif


		cout << "Entering Test4" << endl;
//		Test2(argv[1], argv[2]);

//		cout << "Entering Test3" << endl;
//		Test3();
		Test4();
		cout << "Test successfull" << endl;

	}
	catch (HRESULT hr)
	{
		cout << "***ERROR! " << hex << hr << dec << endl;
	}
	catch (_com_error err)
	{
		cout << "***ERROR _com_error thrown: " << endl;
		cout << " HRESULT: " << hex << err.Error() << dec << endl;
		cout << " Message: " << err.ErrorMessage() << endl;

		_bstr_t desc = err.Description();
		_bstr_t src =  err.Source();

		if (desc.length() > 0)
			cout << "  Description: " << (const char *) desc << endl;
		if (src.length() > 0)
			cout << "  Source: " << (const char *) src << endl;
	}
	catch (...)
	{
		cout << "***ERROR everything else " << endl;
	}

	return 0;
}

