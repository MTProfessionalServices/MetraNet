/**************************************************************************
 * @doc DerivedPropInfo
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
// DerivedPropInfo.h: interface for the DerivedPropInfo class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DERIVEDPROPINFO_H__374CE31A_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)
#define AFX_DERIVEDPROPINFO_H__374CE31A_2D34_11D2_80ED_006008C0E8B7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

//#include "StdAfx.h"

//#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <autoptr.h>
#include "PropConstInfo.h"
#include "PropGenInclude.h"
#include <iostream>

// ----------------------------------------------------------------------------
// Description: DerivedPropInfo a class that holds derived property value
// ----------------------------------------------------------------------------

class DerivedPropInfo  
{
public:
	
	enum PropertyType
	{
		PROPERTY_TYPE_UNKNOWN = 0,
		PROPERTY_TYPE_VALUE = 1
	};

private:
  friend class DerivedPropInfoLibrary;
	DerivedPropInfo(long aNameID, 
									MTPipelineLib::PropValType aPropType,
									_variant_t aPropValue);
  DerivedPropInfo(const DerivedPropInfo& aObj)
	{
    mDerivedPropNameID = aObj.mDerivedPropNameID;
    mDerivedPropValueType = aObj.mDerivedPropValueType;
    if(mDerivedPropValueType == PropGenEnums::DATATYPESTRING)
    {
      delete [] mDerivedPropStrValue;
    }
    mDerivedPropLongValue = aObj.mDerivedPropLongValue;
    mDerivedPropLongLongValue = aObj.mDerivedPropLongLongValue;
    mDerivedPropFloatValue = aObj.mDerivedPropFloatValue;
    mDerivedPropDoubleValue = aObj.mDerivedPropDoubleValue;
    mDerivedPropBoolValue = aObj.mDerivedPropBoolValue;
    mDerivedPropDecimalValue = aObj.mDerivedPropDecimalValue;
		if (mDerivedPropValueType == PropGenEnums::DATATYPESTRING)
    {
      mDerivedPropStrValue = new wchar_t [wcslen(aObj.mDerivedPropStrValue) + 1];
      wcscpy(mDerivedPropStrValue, aObj.mDerivedPropStrValue);
    }
   
	}
public:
	virtual ~DerivedPropInfo();

	// --------------------------------------------------------------------------
	// Description: Method that returns Property name ID
	// --------------------------------------------------------------------------
	const long GetDerivedPropNameID() const
	{
		return mDerivedPropNameID;
	}

	// --------------------------------------------------------------------------
	// Description: Return value type
	// --------------------------------------------------------------------------
	const PropGenEnums::DataType	GetValueType() const
	{
		return mDerivedPropValueType;
	}

	const MTPipelineLib::PropValType GetComValueType() const
	{
		return PropGenEnums::ConvertDataTypeToCom(mDerivedPropValueType);
	}

	const PropGenEnums::DataType	GetNativeValueType(MTPipelineLib::PropValType aPropType) const;

	
	int SetPropertyToSession(CMTSessionBase* apSession, 
														MTPipelineLib::IMTLogPtr apIMTLog, 
														MTPipelineLib::IMTNameIDPtr apIdlookup) const;

  void operator=(const DerivedPropInfo& aObj)
	{
    mDerivedPropNameID = aObj.mDerivedPropNameID;
    mDerivedPropValueType = aObj.mDerivedPropValueType;
    if(mDerivedPropValueType == PropGenEnums::DATATYPESTRING)
    {
      delete [] mDerivedPropStrValue;
    }
    mDerivedPropLongValue = aObj.mDerivedPropLongValue;
    mDerivedPropLongLongValue = aObj.mDerivedPropLongLongValue;
    mDerivedPropFloatValue = aObj.mDerivedPropFloatValue;
    mDerivedPropDoubleValue = aObj.mDerivedPropDoubleValue;
    mDerivedPropBoolValue = aObj.mDerivedPropBoolValue;
    mDerivedPropDecimalValue = aObj.mDerivedPropDecimalValue;
		if (mDerivedPropValueType == PropGenEnums::DATATYPESTRING)
    {
      mDerivedPropStrValue = new wchar_t [wcslen(aObj.mDerivedPropStrValue) + 1];
      wcscpy(mDerivedPropStrValue, aObj.mDerivedPropStrValue);
    }
   
	}

	_variant_t GetComValue() const
	{
		_variant_t val;

    switch (mDerivedPropValueType)
    {
    case PropGenEnums::DATATYPESTRING:
      {
        val = mDerivedPropStrValue;
        break;
      }
    case PropGenEnums::DATATYPEENUM:
    case PropGenEnums::DATATYPELONG:
      {
        val = mDerivedPropLongValue;
        break;
      }

    case PropGenEnums::DATATYPELONGLONG:
      {
        val = mDerivedPropLongLongValue;
        break;
      }

    case PropGenEnums::DATATYPEDOUBLE:
      {
        val = mDerivedPropDoubleValue;
        break;
      }

    case PropGenEnums::DATATYPEDATETIME:
      {
        val = mDerivedPropLongLongValue;
        break;
      }

    case PropGenEnums::DATATYPEBOOL:
      {
        val = mDerivedPropBoolValue;
        break;
      }
    case PropGenEnums::DATATYPEDECIMAL:
      {
        val = mDerivedPropDecimalValue;
        ASSERT(V_VT(&val) == VT_DECIMAL);
        break;
      }

    default:
      // log error message
      ASSERT(false);
      break;
    }
		return val;
	}

private:
	// derived property name ID
	long										mDerivedPropNameID;
	PropGenEnums::DataType	mDerivedPropValueType;
	// derived property value
	union
	{
		wchar_t *								mDerivedPropStrValue;
		long										mDerivedPropLongValue;
		__int64										mDerivedPropLongLongValue;
		float										mDerivedPropFloatValue;
		double									mDerivedPropDoubleValue;
		bool						mDerivedPropBoolValue;
		DECIMAL							mDerivedPropDecimalValue;
	};

  

};

class PropGenRule
{
public:
  PropGenRule() :
    mConditions(NULL), mActions(NULL) 
  {
  }
  void operator=(const PropGenRule& aObj)
	{
    mConditions = aObj.mConditions;
    mActions = aObj.mActions;
	}
  void PutConditions(MTautoptr<vector<ConditionTriplet*> >& pConditions)
  {
    mConditions = pConditions;
  }

  void PutActions(MTautoptr<vector<const DerivedPropInfo*> >& pActions)
  {
    mActions = pActions;
  }

  virtual ~PropGenRule()
  {
  }

  const vector<ConditionTriplet*>* GetConditions() const
  {
    return &mConditions;
  }
  const vector<const DerivedPropInfo*>* GetActions() const
  {
    return &mActions;
  }
private:
  MTautoptr<vector<ConditionTriplet*> >  mConditions;
  MTautoptr<vector<const DerivedPropInfo*> >  mActions;
};

class PropGenRuleSet
{
public:
  PropGenRuleSet() : mDefaultActions(NULL)
  {
  }
  virtual ~PropGenRuleSet()
  {
  }
  const vector<MTautoptr<PropGenRule> >* GetRules() const
  {
    return &mRules;
  }

  void Add(MTautoptr<PropGenRule> aRule)
  {
   mRules.push_back(aRule);
  }

  void PutDefaultActions(MTautoptr<vector<const DerivedPropInfo*> >& pDefaultActions)
  {
    mDefaultActions = pDefaultActions;
  }

  const vector<const DerivedPropInfo*>* GetDefaultActions() const
  {
    return &mDefaultActions;
  }

private:
  vector<MTautoptr<PropGenRule> > mRules;
  MTautoptr<vector<const DerivedPropInfo*> > mDefaultActions;
};


class DerivedPropInfoLibrary
{
private:
  map<string, DerivedPropInfo*> mTriplets;
  static __int64 msNumRefs;
  static DerivedPropInfoLibrary * mpsInstance;
  

  static NTThreadLock mLock;

  DerivedPropInfoLibrary(){}

  virtual ~DerivedPropInfoLibrary()
  {
    for(map<string, DerivedPropInfo*>::iterator it = mTriplets.begin(); it != mTriplets.end(); it++)
    {
      delete (*it).second;
    }

  }
public:

  map<string, DerivedPropInfo*>::iterator Find(const string& key)
  {
    return mTriplets.find(key);
  }
  const DerivedPropInfo* Add( const long& aPropNameID,
                        const MTPipelineLib::PropValType& aType,
												const _variant_t& aValue);
												
  
  static DerivedPropInfoLibrary* GetInstance();

  static void ReleaseInstance();

};


typedef vector<const DerivedPropInfo*>	DerivedPropInfoList;
typedef map<int, DerivedPropInfoList>	DerivedPropInfoListColl;

#endif // !defined(AFX_DERIVEDPROPINFO_H__374CE31A_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)
