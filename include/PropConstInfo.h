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
// PropConstInfo.h: interface for the PropConstInfo class.
//
//////////////////////////////////////////////////////////////////////

// ----------------------------------------------------------------------------
// Description: PropConstInfo a class that holds one property constraint info
//							The info is mapped between constraint id and the constraint 
//							mask bit.
// ----------------------------------------------------------------------------
#if !defined(AFX_PROPCONSTINFO_H__374CE313_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)
#define AFX_PROPCONSTINFO_H__374CE313_2D34_11D2_80ED_006008C0E8B7__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

//#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
//using namespace MTPipelineLib;

#include <metra.h>
#include <mtcomerr.h>
#include "PropGenInclude.h"
#include <autoinstance.h>
#include <MTSingleton.h>
#include <boost/format.hpp>

class ConditionTripletLibrary;
class ConditionTriplet;
class HashKey;

class PropGenEnums
{
public:
  enum DataType
	{
		DATATYPEUNKNOWN,
		DATATYPESTRING,
		DATATYPELONG,
		DATATYPEFLOAT,
		DATATYPEDOUBLE,
		DATATYPEBOOL,
		DATATYPETIME,
		DATATYPEDATETIME,
		DATATYPEENUM,
		DATATYPEDECIMAL,
		DATATYPELONGLONG,
	};
  enum ConditionType
	{
		UNKNOWN_CONDITION_TYPE,
		EQUAL,
		LESS_THAN,
		GREAT_THAN,
		LESS_EQUAL,
		GREAT_EQUAL,
		NOT_EQUAL
	};
  static PropGenEnums::DataType ConvertDataType(const MTPipelineLib::PropValType& aType)
  {
    switch (aType)
    {
    case MTPipelineLib::PROP_TYPE_STRING:
      return PropGenEnums::DATATYPESTRING;
    case MTPipelineLib::PROP_TYPE_ENUM:
      return PropGenEnums::DATATYPEENUM;
    case MTPipelineLib::PROP_TYPE_INTEGER:
      return PropGenEnums::DATATYPELONG;
    case MTPipelineLib::PROP_TYPE_BIGINTEGER:
      return PropGenEnums::DATATYPELONGLONG;
    case MTPipelineLib::PROP_TYPE_DOUBLE:
      return PropGenEnums::DATATYPEDOUBLE;
    case MTPipelineLib::PROP_TYPE_DATETIME:
      return PropGenEnums::DATATYPEDATETIME;
    case MTPipelineLib::PROP_TYPE_TIME:
      return PropGenEnums::DATATYPETIME;
    case MTPipelineLib::PROP_TYPE_BOOLEAN:
      return PropGenEnums::DATATYPEBOOL;
    case MTPipelineLib::PROP_TYPE_DECIMAL:
      return PropGenEnums::DATATYPEDECIMAL;
    default:
      ASSERT(false);
      MT_THROW_COM_ERROR("Unknown MTPipelineLib::PROP_TYPE_* data type!");

    }
  }

  static MTPipelineLib::PropValType ConvertDataTypeToCom(const PropGenEnums::DataType aType)
  {
    switch (aType)
    {
    case PropGenEnums::DATATYPESTRING:
      return MTPipelineLib::PROP_TYPE_STRING;
    case PropGenEnums::DATATYPEENUM:
      return MTPipelineLib::PROP_TYPE_ENUM;
    case PropGenEnums::DATATYPELONG:
      return MTPipelineLib::PROP_TYPE_INTEGER;
    case PropGenEnums::DATATYPELONGLONG:
      return MTPipelineLib::PROP_TYPE_BIGINTEGER;
    case PropGenEnums::DATATYPEDOUBLE:
      return MTPipelineLib::PROP_TYPE_DOUBLE;
		case PropGenEnums::DATATYPEDATETIME:
      return MTPipelineLib::PROP_TYPE_DATETIME;
    case PropGenEnums::DATATYPETIME:
      return MTPipelineLib::PROP_TYPE_TIME;
    case PropGenEnums::DATATYPEBOOL:
      return MTPipelineLib::PROP_TYPE_BOOLEAN;
    case PropGenEnums::DATATYPEDECIMAL:
      return MTPipelineLib::PROP_TYPE_DECIMAL;

    default:
      ASSERT(false);
      MT_THROW_COM_ERROR("Unknown PropConstInfo data type!");
    }
  }

  static const wchar_t* ConvertDataTypeToString(const PropGenEnums::DataType aType)
  {
    switch (aType)
    {
    case PropGenEnums::DATATYPESTRING:
      return L"string";
    case PropGenEnums::DATATYPEENUM:
      return L"enum";
    case PropGenEnums::DATATYPELONG:
      return L"integer/long";
    case PropGenEnums::DATATYPELONGLONG:
      return L"longlong";
    case PropGenEnums::DATATYPEDOUBLE:
      return L"double";
		case PropGenEnums::DATATYPEDATETIME:
      return L"datetime";
    case PropGenEnums::DATATYPETIME:
      return L"time";
    case PropGenEnums::DATATYPEBOOL:
      return L"bool";
    case PropGenEnums::DATATYPEDECIMAL:
      return L"decimal";
    default:
      ASSERT(false);
      MT_THROW_COM_ERROR("Unknown PropConstInfo data type!");
    }
  }

  static const wchar_t* ConvertConditionTypeToCom(PropGenEnums::ConditionType aConditionType)
  {
    switch (aConditionType)
    {
		case PropGenEnums::LESS_THAN:
			return L"less_than";
		case PropGenEnums::GREAT_THAN:
			return L"greater_than";
		case PropGenEnums::LESS_EQUAL:
			return L"less_equal";
		case PropGenEnums::GREAT_EQUAL:
			return L"greater_equal";
		case PropGenEnums::EQUAL:
			return L"equals";
		case PropGenEnums::NOT_EQUAL:
			return L"not_equals";
		default:
      ASSERT(false);
      MT_THROW_COM_ERROR("Unknown PropGenEnums::ConditionType enum value!");
		}
  }

};

class HashKey
{
private:
  HashKey();
public:
  static void Get(const long& aPropNameID, 
    const PropGenEnums::DataType& aType,
    const _variant_t& aValue,
    std::string* aKey)
  {
    return Get(aPropNameID, 0, aValue, aType, aKey);
  }
  
  static void Get(const long& aPropNameID, 
    const int& aCondition, 
    const _variant_t& aValue,
    const PropGenEnums::DataType& aType,
    std::string* aKey)
  {
    //TODO: Decimal Support
    double dtemp;
    HRESULT hr;
    MTDecimal	decValue;
    boost::format fmt("%1%%2%%3%%4%");

    fmt % aPropNameID % aType % aCondition;

    switch (aType)
    {
    case PropGenEnums::DATATYPESTRING:
      {
        string sValue = (_bstr_t)aValue;
        fmt % sValue.c_str();
        break;
      }

    case PropGenEnums::DATATYPEENUM:
    case PropGenEnums::DATATYPELONG:
      {
        long longValue = (long)aValue;
        fmt % longValue;
        break;
      }

    case PropGenEnums::DATATYPELONGLONG:
      {
        __int64 int64Value = (__int64)aValue;
        fmt % int64Value;
        break;
      }

    case PropGenEnums::DATATYPEDOUBLE:
      {
        double doubleValue = (double)aValue;
        fmt % doubleValue;
        break;
      }

    case PropGenEnums::DATATYPEDATETIME:
      {
        long longValue = (long)aValue;
        fmt % longValue;
        break;
      }

    case PropGenEnums::DATATYPEBOOL:
      {
        VARIANT_BOOL boolValue = (VARIANT_BOOL)aValue;
        fmt % boolValue;
        break;
      }
    case PropGenEnums::DATATYPEDECIMAL:
      {
        decValue = (DECIMAL)aValue;
        hr = VarR8FromDec(&decValue, &dtemp);
        ASSERT(SUCCEEDED(hr));

        fmt % dtemp;
        break;
      }

    default:
      // log error message
      ASSERT(false);
      break;
    }

    *aKey = fmt.str();

  }
};


class ConditionTriplet
{
public:
  ConditionTriplet(const long& aPropNameID,
				const int& aCondition,
				const _variant_t& aValue,
				const MTPipelineLib::PropValType& aType);
  /*
  enum DataType
	{
		DATATYPEUNKNOWN,
		DATATYPESTRING,
		DATATYPELONG,
		DATATYPEFLOAT,
		DATATYPEDOUBLE,
		DATATYPEBOOL,
		DATATYPETIME,
		DATATYPEDATETIME,
		DATATYPEENUM,
		DATATYPEDECIMAL,
		DATATYPELONGLONG,
	};
  enum ConditionType
	{
		UNKNOWN_CONDITION_TYPE,
		EQUAL,
		LESS_THAN,
		GREAT_THAN,
		LESS_EQUAL,
		GREAT_EQUAL,
		NOT_EQUAL
	};
  */

  virtual ~ConditionTriplet();


  const long& GetPropNameID() const
	{
		return mPropNameID;
	}

	const int GetCondition() const
	{
		return mCondition;
	}

	const wchar_t * GetComCondition() const
	{
		return PropGenEnums::ConvertConditionTypeToCom((PropGenEnums::ConditionType) mCondition);
	}

	_variant_t GetComValue() const
	{
		_variant_t val;

    switch (mType)
    {
    case PropGenEnums::DATATYPESTRING:
      {
        val = mStrValue;
        break;
      }
    case PropGenEnums::DATATYPEENUM:
    case PropGenEnums::DATATYPELONG:
      {
        val = mLongValue;
        break;
      }

    case PropGenEnums::DATATYPELONGLONG:
      {
        val = mLongLongValue;
        break;
      }

    case PropGenEnums::DATATYPEDOUBLE:
      {
        val = mDoubleValue;
        break;
      }

    case PropGenEnums::DATATYPEDATETIME:
      {
        val = mLongValue;
        break;
      }

    case PropGenEnums::DATATYPEBOOL:
      {
        val = mBoolValue;
        break;
      }
    case PropGenEnums::DATATYPEDECIMAL:
      {
        val = mDecimalValue;
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

	MTPipelineLib::PropValType GetComDataType() const
	{
		return PropGenEnums::ConvertDataTypeToCom(mType);
	}


  PropGenEnums::DataType GetType() const
	{
		return mType;
	}

  const wchar_t* GetTypeAsString() const
	{
		return PropGenEnums::ConvertDataTypeToString(mType);
	}

  _variant_t ConditionTriplet::GetSessionValue(CMTSessionBase* apSession);
  
private:
  friend class RTCondition;
  friend class HashKey;
  bool Evaluate(CMTSessionBase* apSession);
  

 	bool PCEval(const wchar_t* aInValue);
	bool PCEval(const long& aInValue);
	bool PCEval(const __int64& aInValue);
	bool PCEval(const float& aInValue);
	bool PCEval(const double& aInValue);
	bool PCEval(const MTDecimal& aInValue);
	bool PCEval(const bool& aInValue);
	

	void SetPropNameID(const long& aPropNameID)
	{
		mPropNameID = aPropNameID;
	}
  const void GetHashKey(string* pKey) const
	{
    _variant_t val = GetComValue();
    return HashKey::Get(mPropNameID, mCondition, val, mType, pKey);
	}
	void SetCondition(const int& aCondition)
	{
		mCondition = aCondition;
	}
	const wchar_t * GetStrValue() const
	{
		return mStrValue;
	}
	const long GetLongValue() const
	{
		return mLongValue;
	}
	const __int64 GetLongLongValue() const
	{
		return mLongLongValue;
	}
	const float GetFloatValue() const
	{
		return mFloatValue;
	}
	const double GetDoubleValue() const
	{
		return mDoubleValue;
	}
	MTDecimal GetDecimalValue() const
	{
		return mDecimalValue;
	}
	const bool GetBoolValue() const  // VARIANT_BOOL is a short
	{
		return mBoolValue;
	}
	void SetValue(const wstring& aValue)
	{
		mStrValue = new wchar_t [aValue.size()+1];
    wcscpy(mStrValue, aValue.c_str());
	}
	void SetValue(const long& aValue)
	{
		mLongValue = aValue;
	}
	void SetValue(const __int64& aValue)
	{
		mLongLongValue = aValue;
	}
	void SetValue(const float& aValue)
	{
		mFloatValue = aValue;
	}
	void SetValue(const double& aValue)
	{
		mDoubleValue = aValue;
	}
	void SetValue(const MTDecimal& aValue)
	{
		mDecimalValue = aValue;
	}
	void SetValue(const bool& aValue)
	{
		mBoolValue = aValue;
	}
  void SetType(const PropGenEnums::DataType& aType)
	{
		mType = aType;
	}

  // --------------------------------------------------------------------------
	// Description: set property constraint info - string
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const wstring& aValue,
					const PropGenEnums::DataType& aType);

	// --------------------------------------------------------------------------
	// Description: set property constraint info - long
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const long& aValue,
					const PropGenEnums::DataType& aType);

	// --------------------------------------------------------------------------
	// Description: set property constraint info - long long
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const __int64& aValue,
					const PropGenEnums::DataType& aType);

	// --------------------------------------------------------------------------
	// Description: set property constraint info - float
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const float& aValue,
					const PropGenEnums::DataType& aType);

	// --------------------------------------------------------------------------
	// Description: set property constraint info - double
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const double& aValue,
					const PropGenEnums::DataType& aType);
	// --------------------------------------------------------------------------
	// Description: set property constraint info - decimal
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const MTDecimal& aValue,
					const PropGenEnums::DataType& aType);


	// --------------------------------------------------------------------------
	// Description: set property constraint info - boolean
	// --------------------------------------------------------------------------
	void SetPCInfo(const long& aPropNameID,
					const int& aCondition,
					const bool& aValue,
					const PropGenEnums::DataType& aType);

 	long					mPropNameID;
	int						mCondition;
	//Seems like mPropertyType is always "VALUE"
  //this is not used. Removing.
  //PropertyType	mPropertyType;
	PropGenEnums::DataType			mType;

  union
	{
	wchar_t *			mStrValue;
	long					mLongValue;
	float					mFloatValue;
	double				mDoubleValue;
	bool	        mBoolValue;
	DECIMAL			  mDecimalValue;
	__int64				mLongLongValue;
	};

};





class ConditionTripletLibrary
{
private:
  map<string, ConditionTriplet*> mTriplets;
  static __int64 msNumRefs;
  static ConditionTripletLibrary * mpsInstance;
  

  static NTThreadLock mLock;

  ConditionTripletLibrary(){}

  virtual ~ConditionTripletLibrary()
  {
    for(map<string, ConditionTriplet*>::iterator it = mTriplets.begin(); it != mTriplets.end(); it++)
    {
      delete (*it).second;
    }

  }
public:

  map<string, ConditionTriplet*>::iterator Find(const string& key)
  {
    return mTriplets.find(key);
  }
  ConditionTriplet* Add(const long& aPropNameID,
												const int& aCondition,
												const _variant_t& aValue,
												const MTPipelineLib::PropValType& aType);
  
  static ConditionTripletLibrary* GetInstance();

  static void ReleaseInstance();

};

typedef unsigned int Bit;
class RTRule;
class RTCondition
{
public:
  RTCondition(ConditionTriplet* aTriple) : mpTripletPtr(aTriple)
                                           ,mReferencingRules(new vector<RTRule*>)
  {
    mbExecuted = 0;
    mbStatus = 0;
  }
  ~RTCondition()
  {
    delete mReferencingRules;
  }
  const long& GetPropNameID() const
	{
	 ASSERT(mpTripletPtr != NULL);
   return mpTripletPtr->GetPropNameID();
	}

  const wchar_t* GetTypeAsString() const
	{
	 ASSERT(mpTripletPtr != NULL);
   return mpTripletPtr->GetTypeAsString();
	}

  _variant_t GetValue() const
	{
	 ASSERT(mpTripletPtr != NULL);
   return mpTripletPtr->GetComValue();
	}

  bool Evaluate(CMTSessionBase* apSession);
  
  void SetExecuted(bool aResult)
  {
    mbExecuted = 1;
    mbStatus = aResult;
  }
  void Reset()
  {
    mbExecuted = 0;
    mbStatus = 0;
  }
  bool ExecutedSuccessfully()
  {
    return mbExecuted & mbStatus;
  }
  bool Executed()
  {
    return mbExecuted;
  }
  bool Success()
  {
    return mbStatus;
  }
  void AddReferencingRule(RTRule* apRule)
  {
    mReferencingRules->push_back(apRule);
  }
private:
  Bit mbExecuted : 1;
  Bit mbStatus : 1;
  vector<RTRule*>* mReferencingRules;
  ConditionTriplet* mpTripletPtr;

};

class RTRule
{
public:
  RTRule(int aOffset) : Executable(1)//, Offset(aOffset) 
  {}
  Bit Executable : 1;
  void AddCondition(RTCondition* aCond)
  {
    aCond->AddReferencingRule(this);
    mConditions.push_back(aCond);
  }
  void Reset()
  {
    Executable = 1;
  }
  vector<RTCondition*>* GetConditions()
  {
    return &mConditions;
  }
  //offset only for debugging purposes - remove later
  //offset is determined by the rule location in the vector.
  int Offset;
  vector<RTCondition*> mConditions;
};


template <class T>
class AutoReset
{
  //private:
public:
  AutoReset(const AutoReset<T>& aRhs);
  AutoReset(T* pIn);
	~AutoReset();
protected:
  T* pObject;
private:
	long* mpCount;
  long AddRef();
	long Release();
};

template <class T> AutoReset<T>::AutoReset(const AutoReset<T>& aRhs)
{
  pObject = aRhs.pObject;
	mpCount = aRhs.mpCount;
	if(mpCount)
	{
		AddRef();
		ASSERT(*mpCount >= 0);
	}
}


template <class T> AutoReset<T>::AutoReset(T* pIn) : pObject(pIn)
{
	if (NULL == pIn)
		mpCount = NULL;
	else {
		mpCount = new long;
		*mpCount = 1;
	}
}

template <class T> AutoReset<T>::~AutoReset()
{
	Release();

	// even if it wasn't released we clear out the autoptr
	pObject = NULL;
	mpCount = NULL;
}

template <class T> long AutoReset<T>::AddRef()
{
// Check the point of mpCount, make sure it isn't NULL
	ASSERT(mpCount);
#ifdef WIN32
	return ::InterlockedIncrement(mpCount);
#else
	// this needs to be atomic
	return ++(*mpCount);
#endif
}

template <class T> long AutoReset<T>::Release()
{
// if mpCount is NULL, do nothing
	if(NULL == mpCount)
		return 0;

 	long aCount;
#ifdef WIN32
 aCount = ::InterlockedDecrement(mpCount);
#else
 aCount = (*mpCount)--;
#endif

 ASSERT(aCount >= 0);
 if(aCount == 0)
 {
   pObject->Reset();
	 delete mpCount;
	 mpCount = NULL;
 }
 return aCount;
}







#endif // !defined(AFX_PROPCONSTINFO_H__374CE313_2D34_11D2_80ED_006008C0E8B7__INCLUDED_)

