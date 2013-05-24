/**************************************************************************
 * @doc ProductViewDDL
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
 * @index | ProductViewDDL
 ***************************************************************************/

#ifndef _PRODUCTVIEWDDL_H_
#define _PRODUCTVIEWDDL_H_

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
#include <string>

class CProductViewDDL 
{
	public:

		// @cmember Constructor
		DLL_EXPORT CProductViewDDL() {};

		// @cmember Destructor
		DLL_EXPORT virtual ~CProductViewDDL() {};

		// Friend functions  
		DLL_EXPORT friend ostream& operator<<(ostream& os, const CProductViewDDL& C);
	
		// Copy Constructor
		DLL_EXPORT CProductViewDDL (const CProductViewDDL& C);	

		// Assignment operator
		DLL_EXPORT const CProductViewDDL& CProductViewDDL::operator=(const CProductViewDDL& rhs);

		//	Accessors
		const std::wstring& GetDN() const { return mDN; } 
		const std::wstring& GetType() const { return mType; } 
		const std::wstring& GetIsRequired() const { return mIsRequired; } 
		const int GetLength() const { return mLength; } 
		const std::wstring& GetDefault() const { return mDefault; } 
		const int GetDescriptionID() const { return mDescriptionID; } 
		const std::wstring& GetColumnName() const { return mColumnName; } 

		//	Mutators
		inline void SetDN(const wchar_t* DN) 
			{ mDN = DN; mColumnName = mDN; mColumnName.prepend(L"c_") ;}
		inline void SetType(const wchar_t* type) 
			{ mType = type; }
		inline void SetIsRequired(const wchar_t* isRequired) 
			{ mIsRequired = isRequired; }
		inline void SetLength(const int length) 
			{ mLength = length; }
		inline void SetDefault(const wchar_t* s_default) 
			{ mDefault = s_default; }
		inline void SetDescriptionID(const int descid) 
			{ mDescriptionID = descid; }

	private:

		std::wstring mDN;
		std::wstring mType;
		std::wstring mIsRequired;
        std::wstring mColumnName;
		int mLength;
		std::wstring mDefault;
		int mDescriptionID;
};

#endif // _PRODUCTVIEWDDL_H_
