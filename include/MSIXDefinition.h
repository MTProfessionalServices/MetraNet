/**************************************************************************
 * @doc MSIXDefinition
 * 
 * @module  Encapsulation for Database Service Property |
 * 
 * This class encapsulates the insertion or removal of Service Properties
 * from the database. All access to Service Properties should be done 
 * through this class.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Raju Matta
 * $Header$
 *
 * @index | MSIXDefinition
 ***************************************************************************/

#ifndef _MSIXDEFINITION_H_
#define _MSIXDEFINITION_H_

#ifdef WIN32
// only want this header brought in one time
#pragma once

// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <string>
#include <map>
#include <list>
#include <vector>
#include "MSIXProperties.h"
#include "UniqueKey.h"
#include "errobj.h"

#include "XMLParser.h" // to get parser definitions

// this stores the ddl information
typedef list<CMSIXProperties *> MSIXPropertiesList;
typedef map<wstring, CMSIXProperties *> MSIXPropertyMap;
typedef vector<UniqueKey *> UniqueKeyList;

class CMSIXDefinitionObjectFactory;

// need to inherit from XMLUserObject for purposes of extending
// the functionality
class CMSIXDefinition :
  public XMLUserObject,
  public virtual ObjectWithError
{
	friend CMSIXDefinitionObjectFactory;
public:

		// @cmember Constructor
	CMSIXDefinition();

	// @cmember Destructor
	virtual ~CMSIXDefinition();

	// Copy Constructor
	CMSIXDefinition (const CMSIXDefinition& C);	

	// Assignment operator
	const CMSIXDefinition& CMSIXDefinition::operator=(const CMSIXDefinition& rhs);


	//	Accessors
	const std::wstring & GetName() const { return mName; } 

	const std::wstring & GetTableName() const { return mTableName; }
	const std::wstring & GetBackupTableName() const { return mBackupTableName; }

	const std::string & GetChecksum() const;
	const std::string & GetFileName() const { return mFileName; }
  const std::wstring & GetDescription() const { return mDescription; } 
  bool GetCanResubmitFrom() const { return mCanResubmitFrom; }

	const int GetID() const { return mID; } 

	//	Mutators
	void SetName(const wchar_t* name) 
	{ mName = name; }
	void SetTableName(const wchar_t * name)
	{ mTableName = name; }
	void SetBackupTableName(const wchar_t * name)
	{ mBackupTableName = name; }
	void SetID(const int id) 
	{ mID = id; }
	void SetChecksum(const char* checksum) 
	{ mChecksum = checksum; }
	void SetFileName(const char* filename)
	{ mFileName = filename; }	
    void SetDescription(const wchar_t * description)
	{ mDescription = description; }
    void SetCanResubmitFrom(bool canResubmitFrom)
	{ mCanResubmitFrom = canResubmitFrom; }

	// method to print out the ddl contents
	void PrintDefinitionContents();

	MSIXPropertiesList& GetMSIXPropertiesList() { 
		return mPropertiesList; }


	// calculate a table name given the prefix, then call SetTableName with it.
	void CalculateTableName(const wchar_t * apPrefix);

	// calculate the backup table name
	void CMSIXDefinition::CalculateBackupTableName(const wchar_t * apPrefix);

	// generate the table name but don't call SetTableName
	wstring GenerateTableName(const wchar_t * apPrefix);

	// generates the long version of the table - doesn't work with Oracle
	wstring GenerateLongTableName(const wchar_t * apPrefix);

	//
	// XML user object data and methods
	//
	static const int msTypeId;

	// accessor to get the type ID
	int GetTypeId() const { return msTypeId; }

	// method to write to XML
	void Output(XMLWriter& arWriter) const;

	// find a property based on name
	BOOL FindProperty(const std::wstring &arPropertyName, CMSIXProperties * & arpProperty);

	void AddAttribute(const wchar_t * apName, const wchar_t * apValue);

	const XMLNameValueMapDictionary * GetAttributes() const
	{ return mpAttributes.GetObject(); }

   UniqueKeyList& GetUniqueKeyList() { return mUniqueKeyList; }
   BOOL HasPartition() { return mbHasPartition; }

protected:

	// do any setup/post processing after the definition was parsed.
	// if this returns failure, parsing is considered failed.
	virtual BOOL Setup()
	{ return TRUE; }

private:
	void AddProperty (const wchar_t* dn,
										const wchar_t* type,
										const wchar_t* length,
										const wchar_t* required,
										const wchar_t* defaultVal);
  

	// method to add properties to the list
	void AddPropertyToList (CMSIXProperties* p);
   void AddUniqueKeyToList (UniqueKey *uniqueKey) 
   {
      mUniqueKeyList.push_back(uniqueKey);
   }
   void SetPartition(BOOL bValue) {mbHasPartition = bValue;}
private:
	int mID;
	std::wstring mName;
	std::wstring mTableName;
	std::wstring mBackupTableName;
	std::string mChecksum; 
	std::string mFileName;
	std::wstring mDescription;
  // The following flag should be set true if this PV contains
  // an unaltered copy of the source data from the associated service
  // definition.  If so, then rerun is free to recreate an SVC record
  // from the corresponding PV record.  The reason for doing this is that
  // for high volume services we can really afford to keep SVC records around
  // for longer than necessary.  For the moment, we assume that the value of
  // this flag is the same for every service that may be guided to the PV or 
  // for none of them.
  bool mCanResubmitFrom;
	MSIXPropertyMap mMap;
	MSIXPropertiesList mPropertiesList;
   UniqueKeyList mUniqueKeyList;

	XMLNameValueMap mpAttributes;
   BOOL mbHasPartition;
};


#endif // _MSIXDEFINITION_H_
