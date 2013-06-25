/**************************************************************************
 * @doc ODBCSESSIONMAPPINGDEF
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | ODBCSESSIONMAPPINGDEF
 ***************************************************************************/
#ifndef _ODBCSESSIONMAPPINGDEF_H
#define _ODBCSESSIONMAPPINGDEF_H

#include <mttime.h>

#ifdef WIN32
// only include this header one time
#pragma once
#endif


/////////////////////////////////////////////////////
// COdbcSessionPropertyMapping template definition
/////////////////////////////////////////////////////

// TODO: Implement type checking logic

// Constructor for built in t_acc_usage properties
template<class STMT>
COdbcSessionPropertyMapping<STMT>::COdbcSessionPropertyMapping(int aSessionId,
																															 int aColumnPosition, 
																															 OdbcSqlDatatype aType, 
																															 bool aNullable,
																															 CMSIXProperties::PropertyType aMSIXType,
																															 MSIXPropertyValue * apDefaultVal)
{
	mSessionId = aSessionId;
	mColumnPosition = aColumnPosition;
	mType = aType;
	mNullable = aNullable;
	mMSIXType = aMSIXType;
	mDefaultVal = apDefaultVal;
}

template<class STMT>
COdbcSessionPropertyMapping<STMT>*
COdbcSessionPropertyMapping<STMT>::Create(int aSessionId, 
																					int aColumnPosition, 
																					OdbcSqlDatatype aType, 
																					bool aNullable,
																					CMSIXProperties::PropertyType aMSIXType,
																					MSIXPropertyValue * apDefaultVal /* = NULL */)
{
	return new COdbcSessionPropertyMapping<STMT>(aSessionId, aColumnPosition, aType, aNullable, aMSIXType, apDefaultVal);
}

template<class STMT>
inline void COdbcSessionPropertyMapping<STMT>::WriteSessionProperty(CSessionWriterSession* aSession, 
																																		STMT* aStatement)
{
	const SharedPropVal * prop;

	// gets property from shared memory (except if it is the session UID)
	if (mSessionId != -3) 
	{
		prop = aSession->GetReadableProperty(mSessionId);

    //if the property is subscription entity and it is not set in the session,
    //set it to account id (the payee)

    if(!prop && (mSessionId == PipelinePropIDs::SubscriptionEntityIDCode()))
    {
      mSessionId = PipelinePropIDs::AccountIDCode();
      prop = aSession->GetReadableProperty(mSessionId);
    }
		// property is not in session and not required
		if (!prop && mNullable) 
		{
			// sets the default value if there is one
			if (mDefaultVal)
				ApplyDefault(aStatement);

			return;
		}
		// property is not in session and IS required
		else if (!prop && !mNullable)
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_INVALID_PROPERTY,
													 PropertyError(mSessionId, buffer));
		}
	}

	switch(mType)
	{
	case eInteger:
		if (prop->GetType() == SharedPropVal::LONG_PROPERTY)
		{
			aStatement->SetInteger(mColumnPosition, prop->GetLongValue());
		} 
		else if (prop->GetType() == SharedPropVal::ENUM_PROPERTY)
		{
			aStatement->SetInteger(mColumnPosition, prop->GetEnumValue());
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eBigInteger:
		if (prop->GetType() == SharedPropVal::LONG_PROPERTY)
		{
			aStatement->SetBigInteger(mColumnPosition, prop->GetLongValue());
		} 
		else if (prop->GetType() == SharedPropVal::ENUM_PROPERTY)
		{
			aStatement->SetBigInteger(mColumnPosition, prop->GetEnumValue());
		}
		else if (prop->GetType() == SharedPropVal::LONGLONG_PROPERTY)
		{
			aStatement->SetBigInteger(mColumnPosition, prop->GetLongLongValue());
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eString:
		if (prop->GetType() == SharedPropVal::TINYSTRING_PROPERTY)
		{
			const wchar_t * str = prop->GetTinyStringValue();

			// Convert to ASCII
			if (!mNullable && wcslen(str) == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetString(mColumnPosition, " ", 1);
			else
				aStatement->SetString(mColumnPosition, WideStringToString(str));
		}
		// TODO: convert type?
		else if (prop->GetType() == SharedPropVal::UNICODE_PROPERTY)
		{
			long id = prop->GetUnicodeIDValue();
			const wchar_t * str = aSession->GetHeader()->GetWideString(id);
			if (!str)
			{
				throw _com_error(E_FAIL);							// what error should be returned here?
			}
			// Convert to ASCII
			if (!mNullable && wcslen(str) == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetString(mColumnPosition, " ", 1);
			else
				aStatement->SetString(mColumnPosition, WideStringToString(str));
		}
		else if (prop->GetType() == SharedPropVal::EXTRA_LARGE_STRING_PROPERTY)
		{
			wchar_t * str = prop->CopyExtraLargeStringValue(aSession->GetHeader());
			ASSERT(str);
			if (!str)
			{
				std::string buffer;
				throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
														 PropertyError(mSessionId, buffer));
			}

			// Convert to ASCII
			if (!mNullable && wcslen(str) == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetString(mColumnPosition, " ", 1);
			else
				aStatement->SetString(mColumnPosition, WideStringToString(str));

			// must free the buffer
			delete [] str;
		}
		else if (prop->GetType() == SharedPropVal::BOOL_PROPERTY)
		{
      static const int sizeOfTrue = strlen(DB_BOOLEAN_TRUE_A);
      static const int sizeOfFalse = strlen(DB_BOOLEAN_FALSE_A);
			if (prop->GetBooleanValue())
				aStatement->SetString(mColumnPosition, DB_BOOLEAN_TRUE_A, sizeOfTrue);
			else
				aStatement->SetString(mColumnPosition, DB_BOOLEAN_FALSE_A, sizeOfFalse);
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDecimal:
		if (prop->GetType() == SharedPropVal::DECIMAL_PROPERTY)
		{
			const unsigned char* decVal = prop->GetDecimalValue();
			aStatement->SetDecimal(mColumnPosition, (const DECIMAL *)decVal);
		}
		else if (prop->GetType() == SharedPropVal::DOUBLE_PROPERTY)
		{
			// TODO: Go directly from double to SQL decimal
			_variant_t variantVal(prop->GetDoubleValue());
			DECIMAL decVal = (DECIMAL)variantVal;
			aStatement->SetDecimal(mColumnPosition, &decVal);			
		}
		else if (prop->GetType() == SharedPropVal::LONGLONG_PROPERTY)
		{
			_variant_t variantVal(prop->GetLongLongValue());
			DECIMAL decVal = (DECIMAL)variantVal;
			aStatement->SetDecimal(mColumnPosition, &decVal);			
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDouble:
		if (prop->GetType() == SharedPropVal::DOUBLE_PROPERTY)
		{
			aStatement->SetDouble(mColumnPosition, prop->GetDoubleValue());
		} 
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDatetime:
		if(prop->GetType() == SharedPropVal::OLEDATE_PROPERTY) 
		{
			DATE dateVal = prop->GetOLEDateValue();
			aStatement->SetDatetime(mColumnPosition, &dateVal);
		}
		else if(prop->GetType() == SharedPropVal::TIMET_PROPERTY) 
		{
			time_t timetVal = prop->GetDateTimeValue();
			TIMESTAMP_STRUCT timestampVal;
			TimetToOdbcTimestamp(&timetVal, &timestampVal);
			aStatement->SetDatetime(mColumnPosition, timestampVal);
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eBinary:
		ASSERT(mSessionId == -3 || mSessionId == PipelinePropIDs::CollectionIDCode());
		if (mSessionId == -3)
		{
			const unsigned char* uid = aSession->GetUID();
			aStatement->SetBinary(mColumnPosition, uid, 16);
		} 
		else
		{
			if (prop->GetType() == SharedPropVal::UNICODE_PROPERTY) {
				long id = prop->GetUnicodeIDValue();
				const wchar_t * str = aSession->GetHeader()->GetWideString(id);
				if (!str)
				{
					std::string buffer;
					throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
															 PropertyError(mSessionId, buffer));
				}
				
				// decodes the UID back to binary 
				unsigned char batchUID[16];
				MSIXUidGenerator::Decode(batchUID, WideStringToString(str));

				aStatement->SetBinary(mColumnPosition, batchUID, 16);
			}
			else
			{
				std::string buffer;
				throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
														 PropertyError(mSessionId, buffer));
			}
		}
		break;

	case eWideString:
		if (prop->GetType() == SharedPropVal::TINYSTRING_PROPERTY)
		{
			const wchar_t * str = prop->GetTinyStringValue();
      int len = wcslen(str);
			if (!mNullable && len == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetWideString(mColumnPosition, L" ", 1);
			else
				aStatement->SetWideString(mColumnPosition, str, len);
		}
		// TODO: convert type?
		else if (prop->GetType() == SharedPropVal::UNICODE_PROPERTY)
		{
			long id = prop->GetUnicodeIDValue();
			const wchar_t * str = aSession->GetHeader()->GetWideString(id);
			if (!str)
			{
				std::string buffer;
				throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
														 PropertyError(mSessionId, buffer));
			}
      int len = wcslen(str);
			if (!mNullable && len == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetWideString(mColumnPosition, L" ", 1);
			else
				aStatement->SetWideString(mColumnPosition, str, len);			
		}
		else if (prop->GetType() == SharedPropVal::EXTRA_LARGE_STRING_PROPERTY)
		{
			wchar_t * str = prop->CopyExtraLargeStringValue(aSession->GetHeader());
			ASSERT(str);
			if (!str)
			{
				std::string buffer;
				throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
														 PropertyError(mSessionId, buffer));
			}

      int len = wcslen(str);
			if (!mNullable && len == 0)
				// use a single space instead of empty string to support Oracle
				aStatement->SetWideString(mColumnPosition, L" ", 1);
			else
				aStatement->SetWideString(mColumnPosition, str, len);			

			// must free the buffer
			delete [] str;
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	default:
		throw COdbcException("Invalid Datatype in COdbcSessionPropertyMapping::WriteSessionProperty");
	}
}

// this method is based on WriteSessionProperty and should for the
// most part be kept in synch with it. the major difference is that
// this method uses a MSIXPropertyValue object rather than a
// SharedPropVal object.
template<class STMT>
void COdbcSessionPropertyMapping<STMT>::ApplyDefault(STMT* aStatement)
{
	switch(mType)
	{
	case eInteger:
		if ((mMSIXType == CMSIXProperties::TYPE_INT32) ||
				(mMSIXType == CMSIXProperties::TYPE_ENUM))
		{
			int val;
			mDefaultVal->GetValue(val);
			aStatement->SetInteger(mColumnPosition, val); 
		} 
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eBigInteger:
		if ((mMSIXType == CMSIXProperties::TYPE_INT64) ||
        (mMSIXType == CMSIXProperties::TYPE_INT32) ||
				(mMSIXType == CMSIXProperties::TYPE_ENUM))
		{
			__int64 val;
			mDefaultVal->GetInt64Value(val);
			aStatement->SetBigInteger(mColumnPosition, val); 
		} 
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eString:
		if ((mMSIXType == CMSIXProperties::TYPE_STRING) ||
				(mMSIXType == CMSIXProperties::TYPE_WIDESTRING))
		{
			const std::wstring * val;
			mDefaultVal->GetValue(&val);

			// Convert to ASCII
			aStatement->SetString(mColumnPosition, WideStringToString(val->c_str()));
		}
		else if (mMSIXType == CMSIXProperties::TYPE_BOOLEAN)
		{
			BOOL val;
			mDefaultVal->GetBooleanValue(val);
			if (val)
				aStatement->SetString(mColumnPosition, DB_BOOLEAN_TRUE_A);
			else
				aStatement->SetString(mColumnPosition, DB_BOOLEAN_FALSE_A);
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDecimal:
		if (mMSIXType == CMSIXProperties::TYPE_DECIMAL)
		{
			const MTDecimalVal * val;
			mDefaultVal->GetValue(&val);
			MTDecimal dec(*val);
			aStatement->SetDecimal(mColumnPosition, &((DECIMAL) dec));
		}
		else if ((mMSIXType == CMSIXProperties::TYPE_DOUBLE) ||
						 (mMSIXType == CMSIXProperties::TYPE_FLOAT))
		{
			// TODO: Go directly from double to SQL decimal
			double val;
			mDefaultVal->GetValue(val);
			_variant_t variantVal(val);
			DECIMAL decVal = (DECIMAL)variantVal;
			aStatement->SetDecimal(mColumnPosition, &decVal);			
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDouble:
		if (mMSIXType == CMSIXProperties::TYPE_DOUBLE)
		{
			double val;
			mDefaultVal->GetValue(val);
			aStatement->SetDouble(mColumnPosition, val);
		} 
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eDatetime:
		if(mMSIXType == CMSIXProperties::TYPE_TIMESTAMP) 
		{
			time_t val;
			mDefaultVal->GetTimestampValue(val);
			TIMESTAMP_STRUCT timestampVal;
			TimetToOdbcTimestamp(&val, &timestampVal);
			aStatement->SetDatetime(mColumnPosition, timestampVal);
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	case eWideString:
		if ((mMSIXType == CMSIXProperties::TYPE_STRING) ||
				(mMSIXType == CMSIXProperties::TYPE_WIDESTRING))
		{
			const std::wstring * val;
			mDefaultVal->GetValue(&val);
			aStatement->SetWideString(mColumnPosition, *val);
		}
		else
		{
			std::string buffer;
			throw COdbcException(PIPE_ERR_PROP_TYPE_MISMATCH,
													 PropertyError(mSessionId, buffer));
		}
		break;

	default:
		throw COdbcException("Invalid Datatype in COdbcSessionPropertyMapping::ApplyDefault");
	}
}

// Guarantee that the DB type and the MSIX type are compatible
// with one another.  At least warn if they are not because it
// might imply a performance hit.
template<class STMT>
void COdbcSessionPropertyMapping<STMT>::ValidateType()
{
	// TODO: validate types!
}

template<class STMT>
COdbcSessionPropertyMapping<STMT>::~COdbcSessionPropertyMapping()
{
	// frees the default value if there is one
	if (mDefaultVal)
	{
		delete mDefaultVal;
		mDefaultVal = NULL;
	}
}


/////////////////////////////////////////////////////
// COdbcSessionWriterBase template definition
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
COdbcSessionWriterBase<STMT, MAPPING>::COdbcSessionWriterBase()
	: mStatementObject(NULL),
		mInitialized(false),
		mEnumConfig(NULL),
    mMetraTime(__uuidof(METRATIMELib::MetraTimeClient))
{
	// NOTE: setup is not called here for two reasons
	//   first - it calls a virtual function.  this can be dangerous because
	//           the subclass hasn't been constructed.
	//   second - delaying the Setup call means we don't read the
	//            database schema until we need it.
///	SetUp(aConnection, apTableName);

}

template<class STMT, class MAPPING>
COdbcSessionWriterBase<STMT, MAPPING>::~COdbcSessionWriterBase()
{
	TearDown();
}

template<class STMT, class MAPPING>
void COdbcSessionWriterBase<STMT, MAPPING>::WriteDateCreated(int aColumn,
																														 CSessionWriterSession* aSession)
{
	time_t currentTime;
  // COM 32BIT TIME_T
  long comTime;
  HRESULT hr = mMetraTime->raw_GetMTTime(&comTime);
  if (FAILED(hr))
  {
    currentTime = time(NULL);
  }
  else
  {
    currentTime = comTime;
  }
	struct tm * gmTime = gmtime(&currentTime);

	TIMESTAMP_STRUCT ts;
  ts.year = gmTime->tm_year + 1900;
  ts.month = gmTime->tm_mon + 1;
  ts.day = gmTime->tm_mday;
  ts.hour = gmTime->tm_hour;
  ts.minute = gmTime->tm_min;
  ts.second = gmTime->tm_sec;
  ts.fraction = 0;

	GetStatement()->SetDatetime(aColumn, ts);
}

template<class STMT, class MAPPING>
inline void COdbcSessionWriterBase<STMT, MAPPING>::WriteSession(__int64 sessionId, CSessionWriterSession* aSession)
{
	ASSERT(GetStatement());

	// Write mapped columns
	mMappings.WriteMappedProperties(aSession, GetStatement());

	GetStatement()->AddBatch();
}

template<class STMT, class MAPPING>
void COdbcSessionWriterBase<STMT, MAPPING>::UpdateBatchIDs(CSessionWriterSession* aSession)
{
	const SharedPropVal * prop;

	prop = aSession->GetReadableProperty(PipelinePropIDs::CollectionIDCode());
	if (!prop)
		// nothing to do - _CollectionID isn't set
		return;

	if (prop->GetType() == SharedPropVal::UNICODE_PROPERTY)
	{
		long id = prop->GetUnicodeIDValue();
		const wchar_t * str = aSession->GetHeader()->GetWideString(id);
		if (!str)
		{
			ASSERT(0);
			throw _com_error(E_FAIL);							// what error should be returned here?
		}

		std::map<std::wstring, int>::iterator it;
		std::wstring key = str;
		it = mBatchCounts.find(key);
		if (it == mBatchCounts.end())
		{
			// not found in the map
			mBatchCounts[key] = 1;
		}
		else
		{
			// increment the count
			it->second++;
		}
	}
	else
		ASSERT(0);
}

template<class STMT, class MAPPING>
void COdbcSessionWriterBase<STMT, MAPPING>::WriteBatchIDs()
{
}

template<class STMT, class MAPPING>
inline void COdbcSessionWriterBase<STMT, MAPPING>::WriteChildSession(__int64 sessionId, 
																																		 __int64 parentId,
																																		 CSessionWriterSession* aSession)
{
	// NOTE: we can just call though to WriteSession because the base implementation doesn't
	// do anything special for parents/children
	WriteSession(sessionId, aSession);
}

template<class STMT, class MAPPING>
inline int COdbcSessionWriterBase<STMT, MAPPING>::ExecuteBatch()
{
	ASSERT(GetStatement());
	return GetStatement()->ExecuteBatch();
}

template<class STMT, class MAPPING>
void COdbcSessionWriterBase<STMT, MAPPING>::TearDown()
{
	// Clean up the old stuff
  mOdbcManager->Reinitialize(mConnectionCommand);
	mMappings.Clear();

  mStatementObject = NULL;
  mConnectionHandle = boost::shared_ptr<COdbcConnectionHandle>();
}

template<class STMT, class MAPPING>
int COdbcSessionWriterBase<STMT, MAPPING>::GetSpecialPropertySessionId(const string & arColumnName)
{
	static map<string, int> gColumnToId;
  static bool gInit = false;

	if (gInit == false)
	{
    gInit = true;
		// NOTE: all column names must be lowercase!
		gColumnToId.operator[]("tx_uid") = -3;
		gColumnToId.operator[]("id_svc") = PipelinePropIDs::ServiceIDCode();
		gColumnToId.operator[]("id_usage_interval") = PipelinePropIDs::IntervalIdCode();
		gColumnToId.operator[]("id_acc") = PipelinePropIDs::PayingAccountCode();
		gColumnToId.operator[]("id_payee") = PipelinePropIDs::AccountIDCode();
		gColumnToId.operator[]("id_view") = PipelinePropIDs::ProductViewIDCode();
		gColumnToId.operator[]("dt_session") = PipelinePropIDs::TimestampCode();
		gColumnToId.operator[]("amount") = PipelinePropIDs::AmountCode();
		gColumnToId.operator[]("am_currency") = PipelinePropIDs::CurrencyCode();
		gColumnToId.operator[]("tax_federal") = PipelinePropIDs::FedTaxCode();
		gColumnToId.operator[]("tax_state") = PipelinePropIDs::StateTaxCode();
		gColumnToId.operator[]("tax_local") = PipelinePropIDs::LocalTaxCode();
		gColumnToId.operator[]("tax_county") = PipelinePropIDs::CountyTaxCode();
		gColumnToId.operator[]("tax_other") = PipelinePropIDs::OtherTaxCode();
		gColumnToId.operator[]("id_pi_instance") = PipelinePropIDs::PriceableItemInstanceIDCode();
		gColumnToId.operator[]("id_pi_template") = PipelinePropIDs::PriceableItemTemplateIDCode();
		gColumnToId.operator[]("id_prod") = PipelinePropIDs::ProductOfferingIDCode();
    // We calculate dt_crt in WriteDateCreated; we don't not fetch it from a session property.
// 		gColumnToId.operator[]("dt_crt") = PipelinePropIDs::MeteredTimestampCode();
		gColumnToId.operator[]("tx_batch") = PipelinePropIDs::CollectionIDCode();
		gColumnToId.operator[]("id_se") = PipelinePropIDs::SubscriptionEntityIDCode();
		gColumnToId.operator[]("div_currency") = PipelinePropIDs::DivisionCurrencyCode();
		gColumnToId.operator[]("div_amount") = PipelinePropIDs::DivisionAmountCode();
        gColumnToId.operator[]("is_implied_tax") = PipelinePropIDs::TaxInclusiveCode();
        gColumnToId.operator[]("tax_calculated") = PipelinePropIDs::TaxCalculatedCode();
        gColumnToId.operator[]("tax_informational") = PipelinePropIDs::TaxInformationalCode();
	}

	map<string, int>::iterator it;
	std::string columnName = arColumnName;
	StrToLower(columnName);
	if ((it = gColumnToId.find(columnName)) != gColumnToId.end())
		return (*it).second;
	else
		throw COdbcException("column '" + arColumnName + "' has no matching session property");
	return 0;
}

template<class STMT, class MAPPING>
double COdbcSessionWriterBase<STMT, MAPPING>::GetTotalExecuteMillis()
{
	// TODO: not implemented for Bcp case
	return 0;
	///return mStatement->GetTotalExecuteMillis();
}


template<class STMT, class MAPPING>
inline BOOL COdbcSessionWriterBase<STMT, MAPPING>::ConvertDefault(const CMSIXProperties * msixProperty,
																																	MSIXPropertyValue ** defaultVal)
{
	if (!msixProperty->GetIsRequired())
	{
		// converts default value if prop is non-required and default is present
		if (msixProperty->GetDefault().length() != 0)
		{
			*defaultVal = new MSIXPropertyValue();
			if (!AttemptDefaultConversion(msixProperty, *defaultVal))
				return FALSE;
		}
		// handles special case for non-required enums with no default value
		// these are stored as 0 instead of NULL so that localization joins
		// will work correctly
		else if (msixProperty->GetPropertyType() == CMSIXProperties::TYPE_ENUM)
		{
			*defaultVal = new MSIXPropertyValue();
			**defaultVal = (int) 0;
		}
	}
	
	return TRUE;
}

template<class STMT, class MAPPING>
BOOL COdbcSessionWriterBase<STMT, MAPPING>::AttemptDefaultConversion(const CMSIXProperties * apProperty,
																																		 MSIXPropertyValue * apDefaultVal)
{
	std::wstring defaultStr = apProperty->GetDefault().c_str();
	apDefaultVal->SetUnknownValue(defaultStr.c_str());

	// forces a data conversion so we can find out about problems now
	// rather than later when we are trying to write a session
	switch (apProperty->GetPropertyType())
	{
	case CMSIXProperties::TYPE_INT32:
	{
		int val;
		return apDefaultVal->GetValue(val);
	}
	case CMSIXProperties::TYPE_INT64:
	{
		__int64 val;
		return apDefaultVal->GetInt64Value(val);
	}
	case CMSIXProperties::TYPE_FLOAT:
	case CMSIXProperties::TYPE_DOUBLE:
	{
		double val;
		return apDefaultVal->GetValue(val);
	}
	case CMSIXProperties::TYPE_TIMESTAMP:
	{
		time_t val;
		return apDefaultVal->GetTimestampValue(val);
	}
	case CMSIXProperties::TYPE_BOOLEAN:
	{
		BOOL val;
		return apDefaultVal->GetBooleanValue(val);
	}
	case CMSIXProperties::TYPE_ENUM:
	{
		try {
			_bstr_t enumNamespace(apProperty->GetEnumNamespace().c_str());
			_bstr_t enumEnumeration(apProperty->GetEnumEnumeration().c_str());
			
			long val;
			val = mEnumConfig->GetID(enumNamespace, enumEnumeration, _bstr_t(defaultStr.c_str()));

			//stores the enum as an integer
			*apDefaultVal = (int) val;
		}
		catch (_com_error&)
		{
			return FALSE;
		}

		return TRUE;
	}
	case CMSIXProperties::TYPE_STRING:
	case CMSIXProperties::TYPE_WIDESTRING:
	{
		// string props cannot be longer than 255
		if (defaultStr.length() > 255)
			return FALSE;
		
		const MSIXString * val;
		return apDefaultVal->GetValue(&val);
	}
	case CMSIXProperties::TYPE_DECIMAL:
	{
		const MTDecimalVal * val;
		return apDefaultVal->GetValue(&val);
	}		
	}

	// property is of unknown type
	return FALSE;
}



/////////////////////////////////////////////////////
// COdbcSessionAccUsageWriter template definition
/////////////////////////////////////////////////////
template<class STMT, class MAPPING>
COdbcSessionAccUsageWriter<STMT, MAPPING>::COdbcSessionAccUsageWriter(const COdbcConnectionInfo& aConnectionInfo,
                                                                      const char* szAccUsageName /* = NULL */)
	: 
	mIdSessColumnPos(1),
	mIdParentSessColumnPos(1),
	mIdDtCrt(-1),	// not yet set..
	mAccUsageName(szAccUsageName ? szAccUsageName : "t_acc_usage"),
	COdbcSessionWriterBase<STMT, MAPPING>()
{
	SetUp(aConnectionInfo);
}

template<class STMT, class MAPPING>
inline void COdbcSessionAccUsageWriter<STMT, MAPPING>::WriteSession(__int64 sessionId, CSessionWriterSession* aSession)
{
	ASSERT(GetStatement());

	// First write id_sess
	GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);
	WriteDateCreated(mIdDtCrt, aSession);

	// let the base class do the rest
	COdbcSessionWriterBase<STMT, MAPPING>::WriteSession(sessionId, aSession);
}

// same as COdbcBcpSessionWriterBase::WriteChildSession
template<class STMT, class MAPPING>
inline void COdbcSessionAccUsageWriter<STMT, MAPPING>::WriteChildSession(__int64 sessionId, 
																													__int64 parentId,
																													CSessionWriterSession* aSession)
{
	ASSERT(GetStatement());

	// First write id_sess
	GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);
	GetStatement()->SetBigInteger(mIdParentSessColumnPos, parentId);
	WriteDateCreated(mIdDtCrt, aSession);

	// let the base class do the rest
	COdbcSessionWriterBase<STMT, MAPPING>::WriteChildSession(sessionId, parentId, aSession);
}

template<class STMT, class MAPPING>
void COdbcSessionAccUsageWriter<STMT, MAPPING>::SetUp(const COdbcConnectionInfo& aConnectionInfo)
{
  boost::shared_ptr<COdbcConnection> apConnection(new COdbcConnection(aConnectionInfo));

	COdbcColumnMetadataVector v = apConnection->GetMetadata()->GetColumnMetadata(
		  apConnection->GetConnectionInfo().GetCatalog(), mAccUsageName);
	COdbcColumnMetadataVector::iterator it = v.begin();

	// Implement special handling of id_sess, id_parent_sess, dt_crt (these are identifiers that we generate and set)
	while (it != v.end())
	{
		if (0 == stricmp((*it)->GetColumnName().c_str(), "id_sess"))
		{
			mIdSessColumnPos = (*it)->GetOrdinalPosition();
		}
		else if (0 == stricmp((*it)->GetColumnName().c_str(), "id_parent_sess"))
		{
			mIdParentSessColumnPos = (*it)->GetOrdinalPosition();
		}
		else if (0 == stricmp((*it)->GetColumnName().c_str(), "dt_crt"))
		{
			mIdDtCrt = (*it)->GetOrdinalPosition();
		}
		else
		{
			int sessionId = GetSpecialPropertySessionId((*it)->GetColumnName());
			mMappings.AddMapping(MAPPING::Create(sessionId, 
																					 (*it)->GetOrdinalPosition(), 
																					 (*it)->GetDataType(), 
																					 (*it)->IsNullable(),
																					 CMSIXProperties::TYPE_DECIMAL)); 
		}
		it++;
	}
}


/////////////////////////////////////////////////////
// COdbcSessionProductViewWriter template definition
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
COdbcSessionProductViewWriter<STMT, MAPPING>::COdbcSessionProductViewWriter()
	: mIdSessColumnPos(1)
{ }


template<class STMT, class MAPPING>
void COdbcSessionProductViewWriter<STMT, MAPPING>::WriteSession(__int64 sessionId, CSessionWriterSession* aSession)
{
	// First write id_sess
	GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);

	COdbcSessionWriterBase<STMT, MAPPING>::WriteSession(sessionId, aSession);
}

template<class STMT, class MAPPING>
void COdbcSessionProductViewWriter<STMT, MAPPING>::WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession)
{
	// no different for parents/children
	WriteSession(sessionId, aSession);
}

bool inline IsCoreColumn(const string & arColumnName)
{
	bool coreColumn = false;
	if (0 == stricmp(arColumnName.c_str(), "id_sess"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_sess"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tx_UID"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_acc"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_payee"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_view"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_usage_interval"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_parent_sess"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_prod"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_svc"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "dt_session"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "amount"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "am_currency"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "dt_crt"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tx_batch"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tax_federal"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tax_state"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tax_county"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tax_local"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "tax_other"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_pi_instance"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_pi_template"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "id_se"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "div_currency"))
		coreColumn = true;
	else if (0 == stricmp(arColumnName.c_str(), "div_amount"))
		coreColumn = true;
    else if (0 == stricmp(arColumnName.c_str(), "is_implied_tax"))
		coreColumn = true;
    else if (0 == stricmp(arColumnName.c_str(), "tax_calculated"))
		coreColumn = true;
    else if (0 == stricmp(arColumnName.c_str(), "tax_informational"))
		coreColumn = true;
	return coreColumn;
}

/// same as COdbcBcpSessionProductViewWriter
template<class STMT, class MAPPING>
void COdbcSessionProductViewWriter<STMT, MAPPING>::SetUp(const COdbcConnectionInfo&  aConnectionInfo,
																												 CMSIXDefinition* apProductView, 
																												 MTPipelineLib::IMTNameIDPtr aNameID)
{
	mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);

  boost::shared_ptr<COdbcConnection> apConnection(new COdbcConnection(aConnectionInfo));

	string tableName(ascii(apProductView->GetTableName()));

	// Generate the column mappings that connect session properties to db columns
	COdbcColumnMetadataVector v = apConnection->GetMetadata()->GetColumnMetadata(
		apConnection->GetConnectionInfo().GetCatalog(), 
		tableName);
	COdbcColumnMetadataVector::iterator it = v.begin();

	// Assume that database columns are named by appending c_ to product view property name.
	// We'll walk through both of these lists to do a type validation.
	MSIXPropertiesList & propList = apProductView->GetMSIXPropertiesList();

	// Note that the product view also has 2 special columns, id_sess and 
	// id_usage_interval. Adjust for the two extra columns.
	int numSpecialCols = 2;
	if (propList.size() != (v.size()  - numSpecialCols))
	{
		char buf[256];
		sprintf(buf, "Product view table '%s' has %d columns and product view definition has %d properties", 
						(*it)->GetTableName().c_str(),
						v.size() - numSpecialCols, 
						propList.size());
		throw COdbcException(buf);
	}

	while(it != v.end())
	{
		// Find the MSIX properties for all database columns except id_sess
		BOOL bResult;
		string columnName = (*it)->GetColumnName();
		
		if (0 == stricmp(columnName.c_str(), "id_sess"))
		{
			mIdSessColumnPos = (*it)->GetOrdinalPosition();
		}
		else if (0 == stricmp(columnName.c_str(), "id_usage_interval"))
		{
			int sessionId = GetSpecialPropertySessionId((*it)->GetColumnName());
			mMappings.AddMapping(MAPPING::Create(sessionId, 
				(*it)->GetOrdinalPosition(), 
				(*it)->GetDataType(),
				(*it)->IsNullable(),
				CMSIXProperties::TYPE_INT32));
		}
		else
		{
			// Allow columns named with prepended c_
			if((columnName[0] != 'c' && columnName[0] != 'C') || columnName[1] != '_')
			{
				throw COdbcException("Found Product View column '" + 
					columnName + "' that doesn't begin with 'c_'");
			}
			
			std::wstring wPropertyName;
			bResult = ASCIIToWide(wPropertyName, columnName.c_str()+2, columnName.length()-2);

			// Get the property for this prod view column
			CMSIXProperties* msixProperty;
			bResult = apProductView->FindProperty(wPropertyName, msixProperty);
			if (!bResult) 
			{
				throw COdbcException("Could not find matching product view property for product view column '" + 
														 columnName + "'");
			}

			ASSERT(0 == wcsicmp(wPropertyName.c_str(),
													msixProperty->GetDN().c_str()));

			// Found the MSIX property.  Get the session id.
			// TODO: validate type compatibility between session and db column
			int sessionId = aNameID->GetNameID(msixProperty->GetDN().c_str());

			MSIXPropertyValue * defaultVal = NULL;
			if (!ConvertDefault(msixProperty, &defaultVal))
			{
				std::string buffer = "Cannot initialize default value of property '";
				buffer += ascii(wPropertyName) +	"' from ";
				buffer += ascii(apProductView->GetName());
				throw COdbcException(buffer);
			}
			
			mMappings.AddMapping(MAPPING::Create(sessionId, 
																					 (*it)->GetOrdinalPosition(), 
																					 (*it)->GetDataType(),
																					 (*it)->IsNullable(),
																					 msixProperty->GetPropertyType(),
																					 defaultVal));
		}
		it++;
	}
}



/////////////////////////////////////////////////////
// COdbcSessionFullTableWriter template definition
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
COdbcSessionFullTableWriter<STMT, MAPPING>::COdbcSessionFullTableWriter()
	: mIdSessColumnPos(1),
		COdbcSessionWriterBase<STMT, MAPPING>()
{ }


template<class STMT, class MAPPING>
void COdbcSessionFullTableWriter<STMT, MAPPING>::WriteSession(__int64 sessionId, CSessionWriterSession* aSession)
{
	// First write id_sess
 	GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);
	WriteDateCreated(mIdDtCrt, aSession);

	// let the base class do the rest
	COdbcSessionWriterBase<STMT, MAPPING>::WriteSession(sessionId, aSession);
}

template<class STMT, class MAPPING>
void COdbcSessionFullTableWriter<STMT, MAPPING>::WriteChildSession(__int64 sessionId, __int64 parentId, CSessionWriterSession* aSession)
{
	GetStatement()->SetBigInteger(mIdSessColumnPos, sessionId);
	GetStatement()->SetBigInteger(mIdParentSessColumnPos, parentId);
	WriteDateCreated(mIdDtCrt, aSession);

	WriteSession(sessionId, aSession);
}

template<class STMT, class MAPPING>
void COdbcSessionFullTableWriter<STMT, MAPPING>::SetUp(const COdbcConnectionInfo& aConnectionInfo,
																											 CMSIXDefinition* apProductView, 
																											 MTPipelineLib::IMTNameIDPtr aNameID)
{
	string tableName(ascii(apProductView->GetTableName()));

  boost::shared_ptr<COdbcConnection> apConnection(new COdbcConnection(aConneectionInfo));

	// Generate the column mappings that connect session properties to db columns
	COdbcColumnMetadataVector v = apConnection->GetMetadata()->GetColumnMetadata(
		apConnection->GetConnectionInfo().GetCatalog(), 
		tableName);
	COdbcColumnMetadataVector::iterator it = v.begin();

	// Assume that database columns are named by appending c_ to product view property name.
	// We'll walk through both of these lists to do a type validation.
	MSIXPropertiesList & propList = apProductView->GetMSIXPropertiesList();

	// Note that the product view will also have a special id_sess column, so there should one extra column
	if (propList.entries() + 20  != v.size())
	{
		char buf[256];
		sprintf(buf, "Product view table '%s' has %d columns and product view definition has %d properties", 
						(*it)->GetTableName().c_str(),
						v.size(), 
						propList.entries());
		throw COdbcException(buf);
	}

	while(it != v.end())
	{
		// Find the MSIX properties for all database columns except id_sess
		BOOL bResult;
		string columnName = (*it)->GetColumnName();

		if (0 == stricmp((*it)->GetColumnName().c_str(), "id_sess"))
		{
			mIdSessColumnPos = (*it)->GetOrdinalPosition();
		}
		else if (0 == stricmp((*it)->GetColumnName().c_str(), "id_parent_sess"))
		{
			mIdParentSessColumnPos = (*it)->GetOrdinalPosition();
		}
		else if (0 == stricmp((*it)->GetColumnName().c_str(), "dt_crt"))
		{
			mIdDtCrt = (*it)->GetOrdinalPosition();
		}
		else
		{
			if (IsCoreColumn((*it)->GetColumnName()))
			{
				int sessionId = GetSpecialPropertySessionId((*it)->GetColumnName());
				mMappings.AddMapping(MAPPING::Create(sessionId, 
																						 (*it)->GetOrdinalPosition(), 
																						 (*it)->GetDataType(), 
																						 (*it)->IsNullable(),
																						 CMSIXProperties::TYPE_DECIMAL));
			}
			else
			{
				if ((columnName[0] != 'c' && columnName[0] != 'C') || columnName[1] != '_') 
				{
					throw COdbcException("Found Product View column '" + 
															 columnName + "' that doesn't begin with 'c_'");
				}
				std::wstring wPropertyName;
				bResult = ASCIIToWide(wPropertyName, columnName.c_str()+2, columnName.length()-2);
				CMSIXProperties* msixProperty;
				bResult = apProductView->FindProperty(wPropertyName, msixProperty);
				if (!bResult) 
				{
					throw COdbcException("Could not find matching product view property for product view column '" + 
															 columnName + "'");
				}

				ASSERT(0 == wcsicmp(wPropertyName.c_str(),
														msixProperty->GetDN().c_str()));

				// Found the MSIX property.  Get the session id.
				// TODO: validate type compatibility between session and db column
				int sessionId = aNameID->GetNameID(msixProperty->GetDN().c_str());
		
				mMappings.AddMapping(MAPPING::Create(sessionId, 
																						 (*it)->GetOrdinalPosition(), 
																						 (*it)->GetDataType(),
																						 (*it)->IsNullable(),
																						 msixProperty->GetPropertyType()));
			}
		}
		it++;
	}
}



/////////////////////////////////////////////////////
// COdbcSessionMappings template definition
/////////////////////////////////////////////////////

template<class STMT, class MAPPING>
void COdbcSessionMappings<STMT, MAPPING>::WriteMappedProperties(CSessionWriterSession* aSession,
																																STMT * apStatement)
{
	// Write non-compuatable special properties
	vector<MAPPING*>::iterator it = mMappings.begin();
	while(it != mMappings.end())
	{
		(*it++)->WriteSessionProperty(aSession, apStatement);
	}
}


#endif /* _ODBCSESSIONMAPPINGDEF_H */
