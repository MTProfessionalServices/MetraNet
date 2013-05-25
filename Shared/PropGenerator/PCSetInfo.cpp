/**************************************************************************
 * @doc PCSetInfo
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 *
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/
// PCSetInfo.cpp: implementation of the PCSetInfo class.
//
//////////////////////////////////////////////////////////////////////
#include "StdAfx.h"
#include "PCSetInfo.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

// --------------------------------------------------------------------------
// Arguments:			None
//
// Return Value:	None
// Errors Raised: None
// Description:		Construction
// --------------------------------------------------------------------------
PCSetInfo::PCSetInfo()
{
#if MTDEBUG
	cout << "PCSetInfo::PCSetInfo() - 1" << endl;
#endif

}

// --------------------------------------------------------------------------
// Arguments:			<aPCIDMaskList> - property constraint set bit mask
//
// Return Value:	None
// Errors Raised: None
// Description:		Construction
// --------------------------------------------------------------------------
PCSetInfo::PCSetInfo(const PCIDMaskColl& aPCIDMaskList)
{
#if MTDEBUG
	cout << "PCSetInfo::PCSetInfo() - 2" << endl;
#endif

	SetPCSetIDMask(aPCIDMaskList);
}


// --------------------------------------------------------------------------
// Arguments: none
//
// Return Value: none
// Errors Raised: none
// Description: destruction - clean up the bit mask list
// --------------------------------------------------------------------------
PCSetInfo::~PCSetInfo()
{
#if MTDEBUG
	cout << "PCSetInfo::~PCSetInfo()" << endl;
#endif

	mPCSetIDMaskList.clear();
}


// --------------------------------------------------------------------------
// Arguments: <aPCIDMaskList> - property constraint set bit mask
//
// Return Value:	none
// Errors Raised: none
// Description: set the bit mask into the object's member variable
// --------------------------------------------------------------------------
void PCSetInfo::SetPCSetIDMask(const PCIDMaskColl& aPCIDMaskList)
{
	if (mPCSetIDMaskList.size() != 0)
	{
		// perform operation: mPCSetIDMaskList = mPCSetIDMaskList | aPCIDMaskList;
		int entries1 = mPCSetIDMaskList.size();
		int entries2 = aPCIDMaskList.size();

		// since in aPCIDMaskList there is always the last bucket 
		// which has the bit set (only one in each aPCIDMaskList)
		if (entries1 == entries2)
		{
			mPCSetIDMaskList[entries1-1] = 
				mPCSetIDMaskList[entries1-1] | aPCIDMaskList[entries1-1];
		}
		else
		{	// when the number of entries in two lists are not equal
			if (entries1 > entries2)
			{
				mPCSetIDMaskList[entries2-1] = 
					mPCSetIDMaskList[entries2-1] | aPCIDMaskList[entries2-1];

			}
			else
			{
				for (int i = entries1; i < entries2; i++)
				{
					mPCSetIDMaskList.push_back(aPCIDMaskList[i]);
				}
			}

		}
	}
	else
	{
		// if it is an empty list, just copy it over
		mPCSetIDMaskList = aPCIDMaskList;
	}
}


// --------------------------------------------------------------------------
// Arguments: <aPCIDMaskList> - property constraint set bit mask 
//
// Return Value:	bool - true successfull, false - failure
// Errors Raised: 
// Description: compare current bit mask agains passing in bit mask 
// --------------------------------------------------------------------------
bool PCSetInfo::PCIDEval(const PCIDMaskColl& aPCIDMaskList)
{
	bool ret;
	PCIDMaskColl tempMaskList;

	// perform operation: ret = mPCSetIDMaskList == aPCIDMaskList;
	int entries1 = mPCSetIDMaskList.size();
	int entries2 = aPCIDMaskList.size();
	ret = false;

	if (entries1 == entries2)
	{
		ret = true;
		for (int i = 0; i < entries1; i++)
		{
			tempMaskList.push_back(mPCSetIDMaskList[i] & aPCIDMaskList[i]);

			if (mPCSetIDMaskList[i] != tempMaskList[i])
			{
				ret = false;
				break;
			}
		}
	}
	else if (entries1 < entries2)
	{
		ret = true;
		for (int i = 0; i < entries1; i++)
		{
			tempMaskList.push_back(mPCSetIDMaskList[i] & aPCIDMaskList[i]);

			if (mPCSetIDMaskList[i] != tempMaskList[i])
			{
				ret = false;
				break;
			}
		}
	}

	tempMaskList.clear();

	return ret;
}
