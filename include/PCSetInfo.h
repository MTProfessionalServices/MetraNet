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
// PCSetInfo.h: interface for the PCSetInfo class.
//
//////////////////////////////////////////////////////////////////////

// ----------------------------------------------------------------------------
// Description: PCSetInfo a class that holds property set constraint info
//							The info is held in bit mask format.  Each bit represents
//							one constraint.
// ----------------------------------------------------------------------------

#if !defined(AFX_PCSETINFO_H__374CE314_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)
#define AFX_PCSETINFO_H__374CE314_2D34_11D2_80ED_006008C0E8B7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000


#include "PropGenInclude.h"

class PCSetInfo  
{
public:
	// --------------------------------------------------------------------------
	// Description: Construction that initialize the default member value
	// --------------------------------------------------------------------------
	PCSetInfo();
	// --------------------------------------------------------------------------
	// Description: Copy Construction that initialize the mask list value 
	// --------------------------------------------------------------------------
	PCSetInfo(const PCIDMaskColl& aPCIDMaskList);

	// --------------------------------------------------------------------------
	// Description: Destruction of the object
	// --------------------------------------------------------------------------
	virtual ~PCSetInfo();

public:

	// --------------------------------------------------------------------------
	// Description: Method that returns mask link list
	// --------------------------------------------------------------------------
	const PCIDMaskColl& GetPCSetIDMaskList() const
	{
		return mPCSetIDMaskList;
	}

	// --------------------------------------------------------------------------
	// Description: Method that sets mask link list
	// --------------------------------------------------------------------------
	void SetPCSetIDMask(const PCIDMaskColl& aPCIDMaskList);

	// --------------------------------------------------------------------------
	// Description: Method that evaluates a given mask list against member 
	//							variable
	// --------------------------------------------------------------------------
	bool PCIDEval(const PCIDMaskColl& aPCIDMaskList);

private:
	PCIDMaskColl	mPCSetIDMaskList;

};

typedef map<int, PCSetInfo>	PCSetInfoColl;

typedef list<int> PCSetInfoSequencialColl;

#endif // !defined(AFX_PCSETINFO_H__374CE314_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)
