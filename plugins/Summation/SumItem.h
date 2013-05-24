/**************************************************************************
 * @doc
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
// SumItem.h: interface for the SumItem class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_SUMITEM_H__BA1793E6_BF64_11D2_8111_006008C0E8B7__INCLUDED_)
#define AFX_SUMITEM_H__BA1793E6_BF64_11D2_8111_006008C0E8B7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

#include "metra.h"
#include "errobj.h"
#include "mtglobal_msg.h"

#include "NTLogger.h"
#include <loggerconfig.h>

#include "SummationInclude.h"
#include <MTDec.h>

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

template<class T> class SumItemResult {
public:
virtual T GetResult() = 0;
};



class SumItemInstance {

public:
	SumItemInstance(long aProp) : mProp(aProp) {}
	virtual void ProcessSession(MTPipelineLib::IMTSessionPtr& aSession) = 0;
	long GetProp() { return mProp; }

protected:

	long mProp;
};



class SumItem
{

public:
	enum ActionType
	{
		ACTION_TYPE_SUMMATION,
		ACTION_TYPE_AVERAGE,
		ACTION_TYPE_MINIMUM,
		ACTION_TYPE_MAXIMUM,
	};


public:
	// --------------------------------------------------------------------------
	// Description: construction
	// --------------------------------------------------------------------------
	SumItem();

	// --------------------------------------------------------------------------
	// Description: destruction
	// --------------------------------------------------------------------------
	virtual ~SumItem();

	// --------------------------------------------------------------------------
	// Description: load configuration file
	// --------------------------------------------------------------------------
	void SumItemConfig(IUnknown * systemContext,
										MTPipelineLib::IMTConfigPropSetPtr apPropSet);

	// --------------------------------------------------------------------------
	// Description: process session object
	// --------------------------------------------------------------------------
	void SumItemProc(MTPipelineLib::IMTSessionPtr apSession,
										MTPipelineLib::IMTSessionSetPtr apChildren);


private:
	// --------------------------------------------------------------------------
	// Description: 
	// --------------------------------------------------------------------------
	BOOL ActionConversion(BSTR aAction);

	// --------------------------------------------------------------------------
	// Description: convert action string into native enum code
	// --------------------------------------------------------------------------
	BOOL PropTypeConversion(BSTR aPropType);

	// --------------------------------------------------------------------------
	// Description: process children session
	// --------------------------------------------------------------------------
	void ProcessChildrenSessions(MTPipelineLib::IMTSessionSetPtr& sessions,SumItemInstance& aProc);

	// --------------------------------------------------------------------------
	// Description: sum double value in children session
	// --------------------------------------------------------------------------
	double SumChildrenDouble(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: sum decimal value in children session
	// --------------------------------------------------------------------------
	MTDecimal SumChildrenDecimal(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: sum long value in children session
	// --------------------------------------------------------------------------
	long SumChildrenLong(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: sum long long value in children session
	// --------------------------------------------------------------------------
	__int64 SumChildrenLongLong(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: sum date and time value in children session
	// --------------------------------------------------------------------------
	long SumChildrenDateTime(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: sum time value in children session
	// --------------------------------------------------------------------------
	long SumChildrenTime(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: calculate average children session value
	// --------------------------------------------------------------------------
	double AverageChildren(long aProp,
		MTPipelineLib::IMTSessionSetPtr sessions, 
		::PropValType aType);
	
	// --------------------------------------------------------------------------
	// Description: calculate average children session value
	// --------------------------------------------------------------------------
	MTDecimal AverageChildrenDecimal(long aProp,
		MTPipelineLib::IMTSessionSetPtr sessions, 
		::PropValType aType);

	// --------------------------------------------------------------------------
	// Description: get minimum double value
	// --------------------------------------------------------------------------
	double MinChildrenDouble(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);
	
	// --------------------------------------------------------------------------
	// Description: get minimum decimal value
	// --------------------------------------------------------------------------
	MTDecimal MinChildrenDecimal(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get minimum long value
	// --------------------------------------------------------------------------
	long MinChildrenLong(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get minimum date time value
	// --------------------------------------------------------------------------
	long MinChildrenDateTime(long aProp, MTPipelineLib::IMTSessionPtr aParent,
												MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get minimum time value
	// --------------------------------------------------------------------------
	long MinChildrenTime(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get maximum double value
	// --------------------------------------------------------------------------
	double MaxChildrenDouble(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);
	
	// --------------------------------------------------------------------------
	// Description: get maximum decimal value
	// --------------------------------------------------------------------------
	MTDecimal MaxChildrenDecimal(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get maximum long value
	// --------------------------------------------------------------------------
	long MaxChildrenLong(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);
	
	// --------------------------------------------------------------------------
	// Description: get maximum date time value
	// --------------------------------------------------------------------------
	long MaxChildrenDataTime(long aProp, MTPipelineLib::IMTSessionPtr aParent,
												MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: get maximum time value
	// --------------------------------------------------------------------------
	long MaxChildrenTime(long aProp, MTPipelineLib::IMTSessionSetPtr sessions);

	// --------------------------------------------------------------------------
	// Description: round up double value
	// --------------------------------------------------------------------------
	double round(double val);


private:
	long						mInputPropID;
	string				mInputPropName;

	long            mInputServiceId;

	::PropValType		mType;
	string				mTypeName;

	long						mOutputPropID;
	string				mOutputPropName;

	ActionType			mAction;
	string				mActionName;

	long						mDefaultId;
	NTLogger				mLogger;
};


#endif // !defined(AFX_SUMITEM_H__BA1793E6_BF64_11D2_8111_006008C0E8B7__INCLUDED_)
