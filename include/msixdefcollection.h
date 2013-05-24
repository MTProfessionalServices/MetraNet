/**************************************************************************
 * @doc MSIXDEFCOLLECTION
 *
 * @module |
 *
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
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MSIXDEFCOLLECTION
 ***************************************************************************/

#ifndef _MSIXDEFCOLLECTION_H
#define _MSIXDEFCOLLECTION_H

#include <errobj.h>

#include <XMLParser.h>
#include <ConfigChange.h>
#include <autocritical.h>
#include <autologger.h>
#include <MSIXDefinitionObjectFactory.h>

class CMSIXDefinition;
class CCodeLookup;

extern char gLoggingMsg[];

class MSIXDefCollection : 
	public XMLParser,
	public ConfigChangeObserver
{
public:
	typedef list<CMSIXDefinition *> MSIXDefinitionList;

public:
	MSIXDefCollection();
	virtual ~MSIXDefCollection();


	CMSIXDefinition * ParseString(XMLParser& arParser, const char* apStr);

	virtual BOOL Initialize(const wchar_t* pDirName = NULL,BOOL bDirectory = TRUE);

	void SetPath(const char * apPath)
	{ mPath = apPath; }

	void SetIndexFile(const char * apIndex)
	{ mIndexFile = apIndex; }


	CMSIXDefinition * ReadDefFile(XMLParser & arParser,
																const char * apFilename, const char * apExtensionDir);


	virtual void InsertToList(CMSIXDefinition * apDef);

	virtual void DeleteAll();

	virtual void ConfigurationHasChanged();

	MSIXDefinitionList & GetDefList()
	{ return mDefList; }


	BOOL FindDefinition(const wstring &arName,
											CMSIXDefinition * & arpDef);

private:
	CMSIXDefinitionObjectFactory mFactory;
	NTThreadLock mLock;

	MSIXDefinitionList mDefList;

	CCodeLookup * mpCodeLookup;

	MTAutoInstance<MTAutoLoggerImpl<gLoggingMsg> >	mLogger;

	wstring mDirectoryName;
	string mPath;
	string mIndexFile;

	BOOL mNeedsRestart;
};

// debugging helper function
void DumpMSIXDef(CMSIXDefinition * apDef);

void MSIXDefAsAutosdk(CMSIXDefinition * apDef, string & arBuffer);

#endif /* _MSIXDEFCOLLECTION_H */
