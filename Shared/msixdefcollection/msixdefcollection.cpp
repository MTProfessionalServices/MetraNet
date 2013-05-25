/**************************************************************************
 * @doc SERVICECOLLECTION
 *
 * Copyright 2000 by MetraTech Corporation
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
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#import <MTConfigLib.tlb>
#include <msixdefcollection.h>

#include <MSIXDefinition.h>
#include <mtcomerr.h>
#include <MTUtil.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <CodeLookup.h>
#include <ConfigDir.h>

// RCD stuff
#import <RCD.tlb>
#include <mtprogids.h>
#include <SetIterate.h>
#include <RcdHelper.h>

using namespace MTConfigLib;

MSIXDefCollection::MSIXDefCollection() : 
	mpCodeLookup(NULL),
	mNeedsRestart(FALSE)
{
	SetObjectFactory(&mFactory);
}

MSIXDefCollection::~MSIXDefCollection()
{
	DeleteAll();

	if (mpCodeLookup)
	{
		mpCodeLookup->ReleaseInstance();
		mpCodeLookup = 0;
	}
}

char gLoggingMsg[] = "MSIXDEF";

BOOL MSIXDefCollection::Initialize(const wchar_t* pDirName,BOOL bDirectory /* = TRUE */)
{
	int file = 0;
	_bstr_t value;
	HRESULT hOK = S_OK;
	const char* procName = "MSIXDefCollection::Initialize";


	// Initialize the XML parser object
	if (!Init())
		return FALSE;

	// create a code lookup object to figure out IDs
	if (!mpCodeLookup)
	{
		mpCodeLookup = CCodeLookup::GetInstance();
		if (!mpCodeLookup)
		{
			SetError(CORE_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE,
							 procName, "Unable to create code lookup object");
			return FALSE;
		}
	}

	if (pDirName)
	{
		mDirectoryName = pDirName;
		//CR 5670: pDirName is trashed at this point

		// step 1: create an instance of the RCD
		// step 1: create an instance of the RCD
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		// step 2: query for the ServiceToStageMap.xml file
		wstring rwDir = L"config\\";
		rwDir += mDirectoryName;
		if(bDirectory)
			rwDir += L"\\*.msixdef";


		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery(rwDir.c_str(),VARIANT_TRUE);
		// step 3: iterate through each XML file
		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;

		// check to make sure that we found something
		if(aFileList->GetCount() == 0) {
			string buffer("Unable to read MSIX definition file ");
			buffer += ascii(wstring(pDirName));
	
			SetError(CORE_ERR_NOMSIXFILEFILES_FOUND, ERROR_MODULE, ERROR_LINE,
							 	procName,buffer.c_str());
			mLogger->LogErrorObject(LOG_ERROR, GetLastError());
			return FALSE;
		}

		if(FAILED(it.Init(aFileList))) return FALSE;
		
		try 
		{
			while (TRUE)
			{
				_variant_t aVariant= it.GetNext();
				string filename = (const char*)_bstr_t(aVariant);
				if(filename.length() == 0) break;
	
				CMSIXDefinition * def = ReadDefFile(*this, filename.c_str(), aRCD->GetExtensionDir());
				if (!def)
					return FALSE;						// error reading file
	
	
				// Before inserting into the list, check to see if there is a 
				// name that already exists or not.  If it does, then we need
				// to return an error and abort.
				CMSIXDefinition* pAvailableDef;
				if  (FindDefinition(def->GetName(), pAvailableDef))
				{
						string buffer;
						buffer = "A definition file with the same name <";
						buffer += ascii(def->GetName());
						buffer += "> already exists! The file name is <";
						buffer += filename;
						buffer += ">";
						SetError(CORE_ERR_NAME_CONFLICT_FOUND_IN_MSIX_FILES, 
									 	ERROR_MODULE, 
									 	ERROR_LINE, 
									 	procName,
									 	buffer.c_str());
						mLogger->LogErrorObject(LOG_ERROR, GetLastError());
						return FALSE;
				}
	
				// validate the properties in the definition
				MSIXPropertiesList & props = def->GetMSIXPropertiesList();

				BOOL validSession = TRUE;
				MSIXPropertiesList::iterator it;
				for (it = props.begin(); it != props.end(); ++it)
				{
					CMSIXProperties * serviceProp = *it;

					const wstring & name = serviceProp->GetDN();

					if (name.find(L' ') != wstring::npos)
					{
						string buffer;
						buffer = filename.c_str();
						buffer += ": property \"";
						buffer += ascii(name);
						buffer += "\" contains a illegal character";
						SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
										 procName, buffer.c_str());
						mLogger->LogErrorObject(LOG_ERROR, GetLastError());
						return FALSE;
					}
				}

				// populate the services collection object
				InsertToList(def);
			} // end while
		}
		catch (_com_error & e)
		{
			ErrorObject * err = CreateErrorFromComError(e);
			SetError(err);
			mLogger->LogErrorObject(LOG_ERROR,err);
			delete err;
			return FALSE;
		}
	}

	return TRUE;
}



CMSIXDefinition * MSIXDefCollection::ReadDefFile(XMLParser & arParser,
																										 const char * apFilename,
																										 const char * apExtensionDir)
{
	const char * procName = "MSIXDefCollection::ReadDefFile";

	if (mNeedsRestart)
		// restart the parser
		Restart();

	FILE* in = fopen (apFilename, "r");
	if (!in)
	{
		string buffer("Unable to read service MSIX definition file ");
		buffer += apFilename;
		// print an error message
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 procName, buffer.c_str());

		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return (FALSE);
	}

	string input;
	char buf[1024];
	while (1)
	{
		// read data from the stream
		int nread = fread(buf, sizeof(char), sizeof(buf), in);
		if (nread == 0)
		{
			break;
		}
		input.append (buf, nread);
	}

	fclose (in);
  
		// parse the XML file
		// TODO: is this a safe cast?
	CMSIXDefinition * def = ParseString(arParser, input.c_str());

	mNeedsRestart = TRUE;

	// check for NULL p
	if (!def)
	{
		const ErrorObject * obj = arParser.GetLastError();
		if (obj)
		{
			SetError(obj);

			string & buffer = mpLastError->GetProgrammerDetail();
			string filename(apFilename);
			filename += ": ";
			buffer.insert(0, filename.c_str());
		}
		else
		{
			string buffer("MSIX Parser returned a null object parsing file: ");
			buffer += apFilename;

			SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 procName, buffer.c_str());
		}

		mLogger->LogErrorObject(LOG_ERROR, GetLastError());
		return FALSE;
	}

	// chop off the extension directory
	if (apExtensionDir)
	{
		string aTempStr((const char*)apFilename);
		aTempStr = aTempStr.substr(strlen(apExtensionDir) + 1,aTempStr.length());
		aTempStr = aTempStr.substr(aTempStr.find(DIR_SEP,0)+1,aTempStr.length());
		def->SetFileName(aTempStr.c_str());
	}

		// get the new service id using the code lookup table
	int newID;
	if (!mpCodeLookup->GetEnumDataCode (def->GetName().c_str(), newID))
	{
		delete def;
		return (NULL);
	}

	// finally set the id
	def->SetID(newID);

	// convert the buffer to a checksum
	string rwChecksum;
	if (!MTMiscUtil::ConvertStringToMD5(input.c_str(), rwChecksum))
	{
		mLogger->LogThis(LOG_ERROR, "MD5 Checksum failed");
		return NULL;
	}

	// finally set the checksum
	def->SetChecksum(rwChecksum.c_str());
	return def;
}

void MSIXDefCollection::InsertToList(CMSIXDefinition * apDef)
{
	AutoCriticalSection aLock(&mLock);
	mDefList.push_back(apDef);
}

void MSIXDefCollection::DeleteAll()
{
	AutoCriticalSection aLock(&mLock);
	MSIXDefinitionList::iterator it;
	for (it = mDefList.begin(); it != mDefList.end(); ++it)
	{
		delete *it;
	}

	mDefList.clear();
}


BOOL MSIXDefCollection::FindDefinition(const wstring &arName,
																			 CMSIXDefinition * & arpDef)
{
	BOOL bRetCode=FALSE;
	// lock the critical section
	AutoCriticalSection aLock(&mLock);

	MSIXDefinitionList::iterator it;
	for (it = mDefList.begin(); it != mDefList.end(); ++it)
	{
		CMSIXDefinition * def = *it;
	
		if (mtwcscasecmp(arName.c_str(), def->GetName().c_str()) == 0)
		{
			arpDef = def;
			bRetCode = TRUE;
			break;
		}
	}

	return bRetCode;
}

void MSIXDefCollection::ConfigurationHasChanged()
{
	// step 1: lock the critical section.  Note that subsequent
	// calls will also lock the critical section... this is OK in WIN32
	AutoCriticalSection aLock(&mLock);

	// step 2: remove the contents of the collection
	DeleteAll();

	// step 3: reinitialize.  XXX this is not good if the user
	// passes a different configuration file
	Initialize(mDirectoryName.c_str());
}



CMSIXDefinition* MSIXDefCollection::ParseString(XMLParser& arParser, const char* apStr)
{
	const char * functionName = "MSIXDefCollection::ParseString";

	XMLObject* results;


	BOOL result = arParser.ParseFinal(apStr, strlen(apStr), &results);

	if (!result)
	{
		// supply detailed parse error info
		int code;
		const char * message;
		int line;
		int column;
		long byte;

		arParser.GetErrorInfo(code, message, line, column, byte);

		char buffer[20];
		string errormsg = "Parse error: ";
		errormsg += message;
		errormsg += ": line ";
		_itoa(line, buffer, 10);
		errormsg += buffer;
		errormsg += ", column ";
		_itoa(column, buffer, 10);
		errormsg += buffer;
		errormsg += ", byte 0x";
		_ltoa(byte, buffer, 16);
		errormsg += buffer;

	 	SetError(arParser);
		return NULL;
	}

	ASSERT(results);

	// Need to convert from XML object type to user object - in this case
	CMSIXDefinition * def = NULL;
	def = ConvertUserObject(results, def);
	if (!def)
	{
		// TODO: better error?
		SetError(CORE_ERR_CONFIGURATION_PARSE_ERROR, ERROR_MODULE, ERROR_LINE,
						 functionName);
	}

	return def;
}

