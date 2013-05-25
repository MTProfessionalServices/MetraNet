/**************************************************************************
 * @doc PropConstInfo
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
// PropConstInfo.cpp: implementation of the PropConstInfo class.
//
//////////////////////////////////////////////////////////////////////

#include "StdAfx.h"
#include "metra.h"
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include "PropConstInfo.h"
#include "stdutils.h"
#include "MTSourceInfo.h"
#include <iostream>

using namespace MTPipelineLib;
using namespace std;

ConditionTriplet::ConditionTriplet(const long& aPropNameID,
														const int& aCondition,
														const _variant_t& aValue,
														const MTPipelineLib::PropValType& aType
														) :
	mPropNameID(0),
  mCondition(PropGenEnums::UNKNOWN_CONDITION_TYPE),
	mLongLongValue(0LL),
	mType(PropGenEnums::DATATYPEUNKNOWN)
{
	PropGenEnums::DataType	type;

	switch (aType)
	{
  case PROP_TYPE_DEFAULT:
	case PROP_TYPE_STRING:
		{
			type = PropGenEnums::DATATYPESTRING;
			wstring sValue = (_bstr_t)aValue;
			SetPCInfo(aPropNameID, aCondition, sValue, type);
			break;
		}

	case PROP_TYPE_INTEGER:
		{
			type = PropGenEnums::DATATYPELONG;
			long longValue = (long)aValue;
			SetPCInfo(aPropNameID, aCondition, longValue, type);
			break;
		}
		
  case PROP_TYPE_BIGINTEGER:
		{
			type = PropGenEnums::DATATYPELONGLONG;
			__int64 longlongValue = (__int64)aValue;
			SetPCInfo(aPropNameID, aCondition, longlongValue, type);
			break;
		}
		
	case PROP_TYPE_ENUM:
		{
			type = PropGenEnums::DATATYPEENUM;
			long longValue = (long)aValue;
			SetPCInfo(aPropNameID, aCondition, longValue, type);
			break;
		}
	

	case PROP_TYPE_DOUBLE:
		{
			type = PropGenEnums::DATATYPEDOUBLE;
			double doubleValue = (double)aValue;
			SetPCInfo(aPropNameID, aCondition, doubleValue, type);
			break;
		}

	case PROP_TYPE_DATETIME:
		{
			type = PropGenEnums::DATATYPEDATETIME;
			long longValue = (long)aValue;
			SetPCInfo(aPropNameID, aCondition, longValue, type);
			break;
		}

	case PROP_TYPE_TIME:
		{
			type = PropGenEnums::DATATYPETIME;
			long longValue = (long)aValue;
			SetPCInfo(aPropNameID, aCondition, longValue, type);
			break;
		}

	case PROP_TYPE_BOOLEAN:
		{
			type = PropGenEnums::DATATYPEBOOL;
      bool boolVal = (bool)aValue;
			SetPCInfo(aPropNameID, aCondition, boolVal, type);
			break;
		}
	case PROP_TYPE_DECIMAL:
		{
			type = PropGenEnums::DATATYPEDECIMAL;
			MTDecimal decimalValue = (DECIMAL)aValue;
			SetPCInfo(aPropNameID, aCondition, decimalValue, type);
			break;
		}

	default:
		break;
	}
}


ConditionTriplet::~ConditionTriplet()
{
  if (mType == PropGenEnums::DATATYPESTRING && mStrValue != NULL)
  {
    delete [] mStrValue;
  }
}


void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const wstring& aValue,
															const	PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}
void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const long& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}
void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const __int64& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}

void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const float& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}

void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const double& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}

void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const MTDecimal& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}

void ConditionTriplet::SetPCInfo(const long& aPropNameID,
															const int& aCondition,
															const bool& aValue,
															const PropGenEnums::DataType& aType)
{
	SetPropNameID(aPropNameID);
	SetCondition(aCondition);
	SetValue(aValue);
	SetType(aType);
}

bool ConditionTriplet::Evaluate(CMTSessionBase* apSession)
{
  switch(mType)
  {
    case PropGenEnums::DATATYPESTRING:
		  return PCEval((const wchar_t*)apSession->GetStringProperty(mPropNameID));
    case PropGenEnums::DATATYPELONG:
      return PCEval(apSession->GetLongProperty(mPropNameID));
    case PropGenEnums::DATATYPELONGLONG:
      return PCEval(apSession->GetLongLongProperty(mPropNameID));
    case PropGenEnums::DATATYPEENUM:
      return PCEval(apSession->GetEnumProperty(mPropNameID));
    case PropGenEnums::DATATYPEDOUBLE:
      return PCEval(apSession->GetDoubleProperty(mPropNameID));
    case PropGenEnums::DATATYPEBOOL:
      return PCEval(apSession->GetBoolProperty(mPropNameID));
    case PropGenEnums::DATATYPETIME:
      return PCEval(apSession->GetTimeProperty(mPropNameID));
    case PropGenEnums::DATATYPEDATETIME:
      return PCEval(apSession->GetDateTimeProperty(mPropNameID));
    case PropGenEnums::DATATYPEDECIMAL:
      {
        MTDecimal val = apSession->GetDecimalProperty(mPropNameID);
        return PCEval(val);
      }
    default:
      {
        char buf[256];
        sprintf(buf, "Unknown PropConstInfo type '%d', property id: %d", mType, mPropNameID);
        MT_THROW_COM_ERROR(buf);
      }
  }
}

_variant_t ConditionTriplet::GetSessionValue(CMTSessionBase* apSession)
{
  switch(mType)
  {
    case PropGenEnums::DATATYPESTRING:
		  return (const wchar_t*)apSession->GetStringProperty(mPropNameID);
    case PropGenEnums::DATATYPELONG:
      return  apSession->GetLongProperty(mPropNameID);
    case PropGenEnums::DATATYPELONGLONG:
      return apSession->GetLongLongProperty(mPropNameID);
    case PropGenEnums::DATATYPEENUM:
      return apSession->GetEnumProperty(mPropNameID);
    case PropGenEnums::DATATYPEDOUBLE:
      return apSession->GetDoubleProperty(mPropNameID);
    case PropGenEnums::DATATYPEBOOL:
      return apSession->GetBoolProperty(mPropNameID);
    case PropGenEnums::DATATYPETIME:
      return apSession->GetTimeProperty(mPropNameID);
    case PropGenEnums::DATATYPEDATETIME:
      return apSession->GetDateTimeProperty(mPropNameID);
    case PropGenEnums::DATATYPEDECIMAL:
      {
        return apSession->GetDecimalProperty(mPropNameID);
      }
    default:
      {
        char buf[256];
        sprintf(buf, "Unknown PropConstInfo type '%d', property id: %d", mType, mPropNameID);
        MT_THROW_COM_ERROR(buf);
      }
  }
}

bool ConditionTriplet::PCEval(const wchar_t* aInValue)
{
	bool eval = false;

	
	const wchar_t * value = GetStrValue();

	switch(GetCondition())
	{
  case PropGenEnums::EQUAL:		// for '=='
		if (0 == wcscmp(aInValue, value))
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (0 != wcscmp(aInValue, value))
			eval = true;
		break;
	
	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}

bool ConditionTriplet::PCEval(const long& aInValue)
{
	bool eval = false;
	
	long value = GetLongValue();

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if (aInValue == value)
			eval = true;
		break;

	case PropGenEnums::LESS_THAN:		// for '<'
		if (aInValue < value)
			eval = true;
		break;

	case PropGenEnums::GREAT_THAN:		// for '>'
		if (aInValue > value)
			eval = true;
		break;

	case PropGenEnums::LESS_EQUAL:		// for '<='
		if (aInValue <= value)
			eval = true;
		break;

	case PropGenEnums::GREAT_EQUAL:		// for '>='
		if (aInValue >= value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (aInValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}


bool ConditionTriplet::PCEval(const __int64& aInValue)
{
	bool eval = false;
	
	__int64 value = GetLongLongValue();

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if (aInValue == value)
			eval = true;
		break;

	case PropGenEnums::LESS_THAN:		// for '<'
		if (aInValue < value)
			eval = true;
		break;

	case PropGenEnums::GREAT_THAN:		// for '>'
		if (aInValue > value)
			eval = true;
		break;

	case PropGenEnums::LESS_EQUAL:		// for '<='
		if (aInValue <= value)
			eval = true;
		break;

	case PropGenEnums::GREAT_EQUAL:		// for '>='
		if (aInValue >= value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (aInValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}


bool ConditionTriplet::PCEval(const float& aInValue)
{
	bool eval = false;
	
	float value = GetFloatValue();

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if (aInValue == value)
			eval = true;
		break;

	case PropGenEnums::LESS_THAN:		// for '<'
		if (aInValue < value)
			eval = true;
		break;

	case PropGenEnums::GREAT_THAN:		// for '>'
		if (aInValue > value)
			eval = true;
		break;

	case PropGenEnums::LESS_EQUAL:		// for '<='
		if (aInValue <= value)
			eval = true;
		break;

	case PropGenEnums::GREAT_EQUAL:		// for '>='
		if (aInValue >= value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (aInValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}


bool ConditionTriplet::PCEval(const double& aInValue)
{
	bool eval = false;
	
	double value = GetDoubleValue();

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if (aInValue == value)
			eval = true;
		break;

	case PropGenEnums::LESS_THAN:		// for '<'
		if (aInValue < value)
			eval = true;
		break;

	case PropGenEnums::GREAT_THAN:		// for '>'
		if (aInValue > value)
			eval = true;
		break;

	case PropGenEnums::LESS_EQUAL:		// for '<='
		if (aInValue <= value)
			eval = true;
		break;

	case PropGenEnums::GREAT_EQUAL:		// for '>='
		if (aInValue >= value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (aInValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}

bool ConditionTriplet::PCEval(const MTDecimal& aInValue)
{
	bool eval = false;

	
	MTDecimal value = GetDecimalValue();
	//HACK:: cast away const-ness for operators to work
	MTDecimal InValue = (MTDecimal)aInValue;

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if(InValue == value)
		eval = true;
		break;

	case PropGenEnums::LESS_THAN:		// for '<'
		if (InValue < value)
			eval = true;
		break;

	case PropGenEnums::GREAT_THAN:		// for '>'
		if (InValue > value)
			eval = true;
		break;

	case PropGenEnums::LESS_EQUAL:		// for '<='
		if (InValue <= value)
			eval = true;
		break;

	case PropGenEnums::GREAT_EQUAL:		// for '>='
		if (InValue >= value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for '!='
		if (InValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}


bool ConditionTriplet::PCEval(const bool& aInValue)
{
	bool eval = false;

	
	bool value = GetBoolValue();

	switch(GetCondition())
	{
	case PropGenEnums::EQUAL:		// for '=='
		if (aInValue == value)
			eval = true;
		break;

	case PropGenEnums::NOT_EQUAL:		// for "!="
		if (aInValue != value)
			eval = true;
		break;

	default:
		throw TYPE_E_UNDEFINEDTYPE;
	}

	return eval;
}

ConditionTripletLibrary* ConditionTripletLibrary::GetInstance() 
{
  AutoCriticalSection lock(&mLock);
  // if the object does not exist..., create a new one
  if (mpsInstance == 0)
  {
    //if you see next line reported as a mem leak in Numega - it's ok.
    mpsInstance = new ConditionTripletLibrary();
  }
  // if we got a valid pointer.. increment...
  if (mpsInstance != 0)
  {
    msNumRefs++;
  }
  return (mpsInstance);
}

void ConditionTripletLibrary::ReleaseInstance()
{
  AutoCriticalSection lock(&mLock);

  // decrement the reference counter
  if (mpsInstance != 0)
  {
    msNumRefs--;
  }

  // if the number of references is 0, delete the pointer
  if (msNumRefs == 0)
  {
    delete mpsInstance;
    mpsInstance = 0;
  }
}

ConditionTriplet* ConditionTripletLibrary::Add(const long& aPropNameID,
                                              const int& aCondition,
                                              const _variant_t& aValue,
                                              const MTPipelineLib::PropValType& aType)
{
  string key;
  HashKey::Get(aPropNameID, aCondition, aValue, PropGenEnums::ConvertDataType(aType), &key);
  AutoCriticalSection lock(&mLock);
  map<string, ConditionTriplet*>::iterator it = mTriplets.find(key);
  ConditionTriplet* out = NULL;
  if(it == mTriplets.end())
  {
    //if you see next line reported as a mem leak in Numega - it's ok. These pointers will go away on process
    //shutdown, since they are a part of a singleton
     pair<map<string, ConditionTriplet*>::iterator, bool> find = 
      mTriplets.insert(std::make_pair(key, new ConditionTriplet(aPropNameID, aCondition, aValue, aType)));
    ASSERT(find.second == true);
    out = find.first->second;
  }
  else
    out = it->second;
  return out;
}

bool RTCondition::Evaluate(CMTSessionBase* apSession)
{
  ASSERT(mpTripletPtr != NULL);
  bool ret = mpTripletPtr->Evaluate(apSession);
  mbExecuted = 1;
  mbStatus = ret;
  //invalidate all the rules that reference this condition
  //so that we don't have to execute other conditions there.
  if(false)//ret == false)
  {
    for(vector<RTRule*>::iterator it = mReferencingRules->begin(); it != mReferencingRules->end(); it++)
    {
      RTRule* r = *it;
      r->Executable = false;
    }
  }
  return ret;
}


__int64 ConditionTripletLibrary::msNumRefs = 0;
ConditionTripletLibrary* ConditionTripletLibrary::mpsInstance = 0;
NTThreadLock ConditionTripletLibrary::mLock;
