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
// DerivedPropInfo.cpp: implementation of the DerivedPropInfo class.
//
//////////////////////////////////////////////////////////////////////
#include "StdAfx.h"
#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#include <MTSessionBaseDef.h>
#include "DerivedPropInfo.h"

using namespace MTPipelineLib;
using namespace std;
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

// --------------------------------------------------------------------------
// Arguments:			<aNameID> - property name id
//								<aPropType> - property data type in propset enum format
//								<aPropValue> - property value in varient format
//
// Return Value:	None
// Errors Raised:	None
// Description:		Construction that save the property info to member variable
// --------------------------------------------------------------------------
DerivedPropInfo::DerivedPropInfo(long aNameID, 
																MTPipelineLib::PropValType aPropType,
																_variant_t aPropValue) : 
	mDerivedPropValueType(PropGenEnums::DATATYPEUNKNOWN),
	mDerivedPropLongLongValue(0LL)
{
	mDerivedPropNameID = aNameID;

	switch (aPropType)
	{
	//TODO: Decimal Support
	case MTPipelineLib::PROP_TYPE_DEFAULT:
	case MTPipelineLib::PROP_TYPE_STRING:
		{
      if(mDerivedPropStrValue != NULL)
      {
        delete [] mDerivedPropStrValue;
      }
      mDerivedPropStrValue = new wchar_t [((_bstr_t)aPropValue).length() + 1];
      wcscpy(mDerivedPropStrValue, (const wchar_t *) (_bstr_t) aPropValue);
			mDerivedPropValueType = PropGenEnums::DATATYPESTRING;
			break;
		}

	case MTPipelineLib::PROP_TYPE_INTEGER:
		{
			mDerivedPropLongValue = (long)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPELONG;
			break;
		}
	case MTPipelineLib::PROP_TYPE_BIGINTEGER:
		{
			mDerivedPropLongLongValue = (__int64)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPELONGLONG;
			break;
		}
	case MTPipelineLib::PROP_TYPE_ENUM:
		{
			mDerivedPropLongValue = (long)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPEENUM;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DOUBLE:
		{
			mDerivedPropDoubleValue = (double)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPEDOUBLE;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DATETIME:
		{
			mDerivedPropLongLongValue = (time_t)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPEDATETIME;
			break;
		}

	case MTPipelineLib::PROP_TYPE_TIME:
		{
			mDerivedPropLongValue = (long)aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPETIME;
			break;
		}

	case MTPipelineLib::PROP_TYPE_BOOLEAN:
		{
			VARIANT_BOOL boolValue = (VARIANT_BOOL)aPropValue;
			
			if (boolValue == VARIANT_TRUE)
				mDerivedPropBoolValue = true;
			else if (boolValue == VARIANT_FALSE)
				mDerivedPropBoolValue = false;
			else
				ASSERT(0);

			mDerivedPropValueType = PropGenEnums::DATATYPEBOOL;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DECIMAL:
		{
			mDerivedPropDecimalValue = (DECIMAL) aPropValue;
			mDerivedPropValueType = PropGenEnums::DATATYPEDECIMAL;
			break;
		}
	

	case MTPipelineLib::PROP_TYPE_UNKNOWN:
	default:
		{
			// log error msg
			break;
		}
	} // switch

}


const PropGenEnums::DataType	DerivedPropInfo::GetNativeValueType(MTPipelineLib::PropValType aPropType) const
{

	PropGenEnums::DataType	nativeType = PropGenEnums::DATATYPEUNKNOWN;

	switch (aPropType)
	{
	//TODO: Decimal Support
	case MTPipelineLib::PROP_TYPE_DEFAULT:
	case MTPipelineLib::PROP_TYPE_STRING:
		{
			nativeType = PropGenEnums::DATATYPESTRING;
			break;
		}

	case MTPipelineLib::PROP_TYPE_INTEGER:
		{
			nativeType = PropGenEnums::DATATYPELONG;
			break;
		}
	case MTPipelineLib::PROP_TYPE_BIGINTEGER:
		{
			nativeType = PropGenEnums::DATATYPELONGLONG;
			break;
		}
	case MTPipelineLib::PROP_TYPE_ENUM:
		{
			nativeType = PropGenEnums::DATATYPEENUM;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DOUBLE:
		{
			nativeType = PropGenEnums::DATATYPEDOUBLE;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DATETIME:
		{
			nativeType = PropGenEnums::DATATYPEDATETIME;
			break;
		}

	case MTPipelineLib::PROP_TYPE_TIME:
		{
			nativeType = PropGenEnums::DATATYPETIME;
			break;
		}

	case MTPipelineLib::PROP_TYPE_BOOLEAN:
		{
			nativeType = PropGenEnums::DATATYPEBOOL;
			break;
		}
	case MTPipelineLib::PROP_TYPE_DECIMAL:
		{
			nativeType = PropGenEnums::DATATYPEDECIMAL;
			break;
		}
	

	case MTPipelineLib::PROP_TYPE_UNKNOWN:
	default:
		{
			// log error msg
			break;
		}
	} // switch

	return nativeType;
}


// --------------------------------------------------------------------------
// Arguments: none
//
// Return Value: none
// Errors Raised: none
// Description: destruction
// --------------------------------------------------------------------------
DerivedPropInfo::~DerivedPropInfo()
{
  if (mDerivedPropValueType == PropGenEnums::DATATYPESTRING && mDerivedPropStrValue != NULL)
  {
    delete [] mDerivedPropStrValue;
  }
}


int DerivedPropInfo::SetPropertyToSession(CMTSessionBase* apSession, 
																					IMTLogPtr apIMTLog, 
																					IMTNameIDPtr apIdlookup) const
{
	_bstr_t name;
  char logStr[MAX_LOG_STRING];

	if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
	{
		name = apIdlookup->GetName(mDerivedPropNameID);
	}

	switch(mDerivedPropValueType)
	{
		case PropGenEnums::DATATYPESTRING:
		{	
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
        wchar_t logStr1[MAX_LOG_STRING];
				wsprintf(logStr1, L"Property Name: %s, Value(string): %s", 
								(wchar_t*)name, 
								mDerivedPropStrValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr1);
			}
			// Set the property into session object and we all set
			apSession->SetStringProperty(mDerivedPropNameID, _bstr_t(mDerivedPropStrValue));
		break;
		}

		case PropGenEnums::DATATYPEENUM:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(ENUM): %d", (char*)name, mDerivedPropLongValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetEnumProperty(mDerivedPropNameID, mDerivedPropLongValue);
			break;
		}

		case PropGenEnums::DATATYPELONG:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(LONG): %d", (char*)name, mDerivedPropLongValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetLongProperty(mDerivedPropNameID, mDerivedPropLongValue);
			break;
		}

		case PropGenEnums::DATATYPELONGLONG:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(LONGLONG): %I64d", (char*)name, mDerivedPropLongLongValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetLongLongProperty(mDerivedPropNameID, mDerivedPropLongLongValue);
			break;
		}

		case PropGenEnums::DATATYPETIME:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(TIME): %d", (char*)name, mDerivedPropLongValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetTimeProperty(mDerivedPropNameID, mDerivedPropLongValue);
			break;
		}

		case PropGenEnums::DATATYPEDOUBLE:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(DOUBLE): %f", (char*)name, mDerivedPropDoubleValue);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetDoubleProperty(mDerivedPropNameID, mDerivedPropDoubleValue);
			break;
		}

		case PropGenEnums::DATATYPEDATETIME:
		{
			struct tm *dateTime;;
			dateTime = gmtime(&mDerivedPropLongLongValue);

			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(DATETIME): %s", (char*)name, asctime(dateTime));
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetDateTimeProperty(mDerivedPropNameID, mDerivedPropLongValue);
			break;
		}

		case PropGenEnums::DATATYPEBOOL:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property Name: %s, Value(BOOL): %s",
									(char*)name, mDerivedPropBoolValue == true ? "true" : "false");
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetBoolProperty(mDerivedPropNameID, mDerivedPropBoolValue);
			break;
		}
		case PropGenEnums::DATATYPEDECIMAL:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				MTDecimal decimalValue = mDerivedPropDecimalValue;
				sprintf(logStr, "Property Name: %s, Value(DECIMAL): %s", 
											(char*)name, decimalValue.Format().c_str());
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}
			// Set the property into session object and we all set
			apSession->SetDecimalProperty(mDerivedPropNameID, mDerivedPropDecimalValue);
			break;
		}

		default:
		{
			if (apIMTLog->OKToLog(PLUGIN_LOG_DEBUG))
			{
				sprintf(logStr, "Property ID: %d, Property Value: <Invalid type>", (char*)name);
				apIMTLog->LogString(PLUGIN_LOG_DEBUG, logStr);
			}

			return FAILURE;
		}

	} // switch()

	return SUCCESS;
}


DerivedPropInfoLibrary* DerivedPropInfoLibrary::GetInstance() 
{
  AutoCriticalSection lock(&mLock);
  // if the object does not exist..., create a new one
  if (mpsInstance == 0)
  {
    //if you see next line reported as a mem leak in Numega - it's ok.
    mpsInstance = new DerivedPropInfoLibrary();
  }
  // if we got a valid pointer.. increment...
  if (mpsInstance != 0)
  {
    msNumRefs++;
  }
  return (mpsInstance);
}

void DerivedPropInfoLibrary::ReleaseInstance()
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

const DerivedPropInfo* DerivedPropInfoLibrary::Add( const long& aPropNameID,
                        const MTPipelineLib::PropValType& aType,
												const _variant_t& aValue)
{
  string key;
  HashKey::Get(aPropNameID, PropGenEnums::ConvertDataType(aType), aValue, &key);
  AutoCriticalSection lock(&mLock);
  DerivedPropInfo* out = NULL;
  map<string, DerivedPropInfo*>::iterator it = mTriplets.find(key);
  if(it == mTriplets.end())
  {
    //if you see next line reported as a mem leak in Numega - it's ok. These pointers will go away on process
    //shutdown, since they are a part of a singleton
    pair<map<string, DerivedPropInfo*>::iterator, bool> find = 
      mTriplets.insert(std::make_pair(key, new DerivedPropInfo(aPropNameID, aType, aValue)));
    ASSERT(find.second == true);
    out = find.first->second;
  }
  else
    out = it->second;
  return out;
}


__int64 DerivedPropInfoLibrary::msNumRefs = 0;
DerivedPropInfoLibrary* DerivedPropInfoLibrary::mpsInstance = 0;
NTThreadLock DerivedPropInfoLibrary::mLock;
