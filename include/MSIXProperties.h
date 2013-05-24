/**************************************************************************
 * @doc MSIXProperties
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
 * @index | MSIXProperties
 ***************************************************************************/

#ifndef _MSIXPROPERTIES_H_
#define _MSIXPROPERTIES_H_

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

//	All the includes
#include "MTUtil.h"
#include "NTLogger.h"
#include "SharedDefs.h"
#include <XMLParser.h>
#include <string>


// need to inherit from XMLUserObject for purposes of extending
// the functionality
class CMSIXProperties
{
public:
	enum PropertyType
	{
		TYPE_STRING,
		TYPE_WIDESTRING,
		TYPE_INT32,
		TYPE_TIMESTAMP,
		TYPE_FLOAT,
		TYPE_DOUBLE,
		TYPE_NUMERIC,
		TYPE_DECIMAL,
		TYPE_ENUM,
		TYPE_BOOLEAN,
		TYPE_TIME,
    TYPE_INT64
	};

	public:

		// @cmember Constructor
		CMSIXProperties();

		// @cmember Destructor
		virtual ~CMSIXProperties();

		// Friend functions  
  //DLL_EXPORT friend ostream& operator<<(ostream& os, const CMSIXProperties& C);
	
		//	Accessors
		const std::wstring& GetDN() const { return mDN; } 
		BOOL GetIsRequired() const { return mIsRequired; } 
		const int GetLength() const { return mLength; } 
		const std::wstring& GetDefault() const { return mDefault; } 
		PropertyType GetPropertyType() const { return mPropType; }
		const std::wstring& GetEnumNamespace() const { return mEnumNamespace; } 
		const std::wstring& GetEnumEnumeration() const { return mEnumEnumeration; } 

		//	Mutators
	  void SetDN(const wchar_t* DN);

		inline void SetDataType(const wchar_t* type) 
			{ mType = type; }
		inline void SetIsRequired(BOOL aRequired) 
			{ mIsRequired = aRequired; }
		inline void SetLength(const int &length) 
			{ mLength = length; }
		inline void SetDefault(const wchar_t* s_default) 
			{ mDefault = s_default; }
		inline void SetDescriptionID(const long &descID) 
			{ mDescriptionID = descID; }
		inline void SetUserVisible(const VARIANT_BOOL &userVisible) 
			{ mUserVisible = userVisible; }
		inline void SetFilterable(const VARIANT_BOOL &filterable) 
			{ mFilterable = filterable; }
		inline void SetExportable(const VARIANT_BOOL &exportable) 
			{ mExportable = exportable; }
		inline void SetPartOfKey(const VARIANT_BOOL &partofkey) 
			{ mPartOfKey = partofkey; }
    inline void SetAccountIdentifier(const VARIANT_BOOL &abAccIsAccountIdentifier) 
			{ mbIsAccountIdentifer = abAccIsAccountIdentifier; }
		inline void SetSingleIndex(const VARIANT_BOOL &singleindex) 
			{ mSingleIndex = singleindex; }
		inline void SetCompositeIndex(const VARIANT_BOOL &compositeindex) 
			{ mCompositeIndex = compositeindex; }
		inline void SetSingleCompositeIndex(const VARIANT_BOOL &singlecompositeindex) 
			{ mSingleCompositeIndex = singlecompositeindex; }
		void SetPropertyType(PropertyType aType)
			{ mPropType = aType; }
		inline void SetEnumNamespace(const wchar_t* s_namespace) 
			{ mEnumNamespace = s_namespace; }
		inline void SetEnumEnumeration(const wchar_t* s_enum) 
			{ mEnumEnumeration = s_enum; }
		inline void SetReferenceTable(const wchar_t* s_reference_table)
		{ mReference = s_reference_table; }
		inline void SetRefColumn(const wchar_t* s_ref_column)
		{ mRefColumn = s_ref_column; }
    	void SetDescription(const wchar_t* s_description)
		{ mDescription = s_description; }

	  
	void AddAttribute(const wchar_t * apName, const wchar_t * apValue);

	const XMLNameValueMapDictionary * GetAttributes() const
	{ return mpAttributes.GetObject(); }


	 //
	// database related accessors
	//
	const wchar_t * GetRequiredConstraint() const;
	const std::wstring& GetColumnName() const { return mColumnName; } 

	void SetColumnName(const wchar_t * apColumnName)
	{ mColumnName = apColumnName; }

	void SetUniqueSuffix(int aSuffix);

	int GetUniqueSuffix()
	{ return mUniqueSuffix; }


	//
	// product view specific
	//
    const VARIANT_BOOL GetUserVisible() const { return mUserVisible; }
    const VARIANT_BOOL GetFilterable() const { return mFilterable; }
    const VARIANT_BOOL GetExportable() const { return mExportable; }
    const VARIANT_BOOL GetPartOfKey() const { return mPartOfKey; }
    const VARIANT_BOOL GetSingleIndex() const { return mSingleIndex; }
    const VARIANT_BOOL GetCompositeIndex() const { return mCompositeIndex; }
    const VARIANT_BOOL GetSingleCompositeIndex() const { return mSingleCompositeIndex; }
		const long GetDescriptionID() const { return mDescriptionID; } 
		const std::wstring& GetDataType() const { return mType; } 
		const std::wstring& GetReferenceTable() const { return mReference; }
		const std::wstring& GetRefColumn() const { return mRefColumn; }
    const VARIANT_BOOL GetAccountIdentifer() const { return mbIsAccountIdentifer; }
    const std::wstring& GetDescription() const { return mDescription; }


	private:
	void GenerateColumnName();

	private:

		std::wstring mDN;
		std::wstring mType;
		BOOL mIsRequired;
		std::wstring mColumnName;
		long mLength;
		std::wstring mDefault;
		long mDescriptionID;
    VARIANT_BOOL mUserVisible ;
    VARIANT_BOOL mFilterable ;
    VARIANT_BOOL mExportable ;
    VARIANT_BOOL mPartOfKey ;
    VARIANT_BOOL mSingleIndex ;
    VARIANT_BOOL mCompositeIndex ;
    VARIANT_BOOL mSingleCompositeIndex ;
    VARIANT_BOOL mbIsAccountIdentifer;
    

		std::wstring mReference;
		std::wstring mRefColumn;
    	std::wstring mDescription;

  	PropertyType mPropType;

	// used to guarantee unique column names, the suffix is appended to the
	// column name when there are duplicates
	// 0 means don't use a suffix.
	int mUniqueSuffix;

	std::wstring mEnumNamespace;
	std::wstring mEnumEnumeration;

	XMLNameValueMap mpAttributes;

};

#endif // _MSIXPROPERTIES_H_
