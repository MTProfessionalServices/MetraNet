/**************************************************************************
 * @doc MSIXProperties
 *
 * @module	Encapsulation for Database MSIXProperties Property |
 *
 * This class encapsulates the insertion or removal of MSIXProperties Properties
 * from the database. All access to MSIXProperties should be done through this
 * class.
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


// includes
#include <comdef.h>
#include <MSIXProperties.h>
#include <loggerconfig.h>


//	@mfunc
//	Constructor. Initialize the data members.
//	@rdesc
//	No return value
CMSIXProperties::CMSIXProperties()
	: mIsRequired(TRUE),
		mUserVisible(VARIANT_TRUE),
		mFilterable(VARIANT_TRUE),
		mExportable(VARIANT_TRUE),
		mPartOfKey(VARIANT_FALSE),
		mSingleIndex(VARIANT_FALSE),
		mCompositeIndex(VARIANT_FALSE),
		mSingleCompositeIndex(VARIANT_FALSE),
		mpAttributes(NULL),
		mUniqueSuffix(0),
		mDescription(L"")
{	
}

//	@mfunc
//	Destructor
//	@rdesc
//	No return value
CMSIXProperties::~CMSIXProperties()
{
}


void CMSIXProperties::SetDN(const wchar_t * apDN)
{
	mDN = apDN;
	GenerateColumnName();
}

void CMSIXProperties::SetUniqueSuffix(int aSuffix)
{
	mUniqueSuffix = aSuffix;
	GenerateColumnName();
}

void CMSIXProperties::GenerateColumnName()
{
	mColumnName = mDN;
	mColumnName.insert(0, L"c_");
	if (mUniqueSuffix > 0)
	{
		wchar_t buffer[40];
		swprintf(buffer, L"%d", mUniqueSuffix);
		mColumnName += buffer;
	}
}



const wchar_t * CMSIXProperties::GetRequiredConstraint() const
{
	if (mIsRequired)
		return W_DB_NOT_NULL_STR;
	else
		return W_DB_NULL_STR;
}

void CMSIXProperties::AddAttribute(const wchar_t * apName, const wchar_t * apValue)
{
	if (!mpAttributes)
		mpAttributes = new XMLNameValueMapDictionary;

	(*mpAttributes)[apName] = apValue;
}
