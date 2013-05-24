/**************************************************************************
* @doc ACCOUNTDEFCREATOR
*
* @module |
*
*
* Copyright 2001 by MetraTech Corporation
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
*
* @index | ACCOUNTDEFCREATOR
***************************************************************************/

#ifndef _ACCOUNTDEFCREATOR_H
#define _ACCOUNTDEFCREATOR_H

#include <MSIXDefinition.h>

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

#include <DBAccess.h>

// forward declaration
struct IMTQueryAdapter;

// config path for account xml file
const char ACCOUNT_CONFIG_PATH[] = "\\Queries\\Account";
const char ACCOUNT_VIEW_CONFIG_PATH[] = "\\AccountView";
const char ACCOUNT_VIEW_XML_FILE[] = "account.xml";

class AccountDefCreator : public virtual ObjectWithError
{
public:
		// @cmember Constructor
		AccountDefCreator();
    
    // @cmember Destructor
    virtual ~AccountDefCreator();
    
    // @cmember Initialize the Product View Definition object
    BOOL Initialize ();
    
    // method to create a table
    BOOL CreateTable (CMSIXDefinition & arDef);
    
    // method to drop table
    BOOL DropTable(CMSIXDefinition & arDef);
    
    // method to insert data
    BOOL InsertData(CMSIXDefinition & arDef,
      MTACCOUNTLib::IMTAccountPropertyCollection* mtptr, VARIANT apRowset = vtMissing);
    
    // method to insert data
    BOOL UpdateData(CMSIXDefinition & arDef,
      MTACCOUNTLib::IMTAccountPropertyCollection* mtptr, VARIANT apRowset = vtMissing);
    
    // method to insert data
    BOOL GetData(CMSIXDefinition & arDef,
      long arAccountID,
			VARIANT apRowset,
      map<wstring, _variant_t>& propcoll);
    
private:
  
		// method to create ddl
		BOOL GenerateCreateTableQuery(CMSIXDefinition & arDef, wstring& langRequest);
    
    // @cmember create "drop table" query
    BOOL GenerateDropTableQuery(CMSIXDefinition & arDef, wstring& langRequest);
    
    // @cmember create insert proc query
    BOOL GenerateCreateInsertStoredProcQuery(CMSIXDefinition & arDef,
      wstring& langRequest);
    
    // @cmember create update proc query
    BOOL GenerateCreateUpdateStoredProcQuery(CMSIXDefinition & arDef,
      wstring& langRequest);
    
    // @cmember create "drop stored proc" query
    BOOL GenerateDropInsertStoredProcQuery(CMSIXDefinition & arDef,
      wstring& langRequest);
    
    // @cmember create "drop update stored proc" query
    BOOL GenerateDropUpdateStoredProcQuery(CMSIXDefinition & arDef, 
      wstring& langRequest);
    
    // @cmember 
    BOOL GenerateInsertDataQuery(CMSIXDefinition & arDef,
      MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
      wstring& langRequest);
    
    // @cmember 
    BOOL GenerateUpdateDataQuery(CMSIXDefinition & arDef,
      MTACCOUNTLib::IMTAccountPropertyCollection* mtptr,
      wstring& langRequest);
    
    // @cmember 
    BOOL GenerateGetDataQuery(CMSIXDefinition & arDef,
      long arAccountID, wstring& langRequest);
    
    
    BOOL CreateForeignKeyRelationships(CMSIXDefinition & arDef);
    
    BOOL CreateSingleIndex(CMSIXDefinition & arDef);
    
    BOOL CreateCompositeIndex(CMSIXDefinition & arDef);
    
    // method to create stored procs 
    BOOL CreateInsertStoredProc (CMSIXDefinition & arDef); 
    
    // method to create stored procs 
    BOOL CreateUpdateStoredProc (CMSIXDefinition & arDef); 
    
    
    // method to drop insert stored proc
    BOOL DropInsertStoredProc (CMSIXDefinition & arDef); 
    
    // method to drop update stored proc 
    BOOL DropUpdateStoredProc (CMSIXDefinition & arDef); 
    
    
    
    //	void CalculateTableName();
    
    // set up a map from prop name to prop object
    //	void MapProperties();
    
protected:
  
private:
  
  // set to TRUE when object is initialized to avoid Init overhead
  BOOL mInitialized;
  
  NTLogger mLogger;
  
  
  //        MSIXPropertyMap mMap;
  wstring mDBType;
  
  _bstr_t configPath;
};



#endif /* _ACCOUNTDEFCREATOR_H */
