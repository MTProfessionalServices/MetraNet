/**************************************************************************
* Copyright 1997-2001 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

#ifndef _ODBCSESSIONWRITERSESSION_H_
#define _ODBCSESSIONWRITERSESSION_H_

#import <MTPipelineLib.tlb>
#include <sharedsess.h>
#include <ConfigDir.h>
#include <mtglobal_msg.h>


class CSessionWriterSession
{
private:
	SharedSession* mpSharedSession;
	SharedSessionHeader* mpHeader;

  long mInternalSessId;

  bool mbWasNull;
	bool mbWasTypeIncompatible;

	void ClearProperty(SharedPropVal * apProp)
	{
		if (apProp->GetType() == SharedPropVal::ASCII_PROPERTY)
		{
			mpHeader->FreeString(apProp->GetAsciiIDValue());
			apProp->SetFreeValue();
		}
		else if (apProp->GetType() == SharedPropVal::UNICODE_PROPERTY)
		{
			mpHeader->FreeWideString(apProp->GetUnicodeIDValue());
			apProp->SetFreeValue();
		}
	}

public:
	
	CSessionWriterSession(SharedSessionHeader* aHeader, MTPipelineLib::IMTSessionPtr aSession)
		:
		mpHeader(aHeader),
		mbWasNull(true),
		mbWasTypeIncompatible(false)
	{
		mInternalSessId = aSession->GetSessionID();
		mpSharedSession = mpHeader->GetSession(mInternalSessId);
		ASSERT(mpSharedSession != NULL);
		mpSharedSession->AddRef();
	}

	~CSessionWriterSession()
	{
		if (mpSharedSession)
		{
			int newCount = mpSharedSession->Release(mpHeader);
		}
	}

	SharedSessionHeader* GetHeader()
	{
		return mpHeader;
	}

  long GetInternalSessionId()
  {
    return mInternalSessId;
  }

	// Only set the value if it does not exist
	void ApplyDefaultDoubleValue(long aPropId, double aDoubleVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetDoubleValue(aDoubleVal);
	}

	void ApplyDefaultLongValue(long aPropId, long aLongVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetLongValue(aLongVal);
	}

	void ApplyDefaultOLEDateValue(long aPropId, double aOLEDateVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetOLEDateValue(aOLEDateVal);
	}

	void ApplyDefaultDateTimeValue(long aPropId, time_t aDateTimeVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetDateTimeValue(aDateTimeVal);
	}

	void ApplyDefaultStringValue(long aPropId, const wchar_t * aStringVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);

		if ((wcslen(aStringVal) * sizeof(wchar_t)) < SharedSessionHeader::TINY_STRING_MAX)
		{
			// small enough to go into the SharedPropVal directly
			prop->SetTinyStringValue(aStringVal);
		}
		else
		{
			// set the value
			long id;
			const wchar_t * str = mpHeader->AllocateWideString(aStringVal, id);
			if (str == NULL)
				throw _com_error(PIPE_ERR_SHARED_OBJECT_FAILURE);

			prop->SetUnicodeIDValue(id);
		}
	}

	void ApplyDefaultTimeValue(long aPropId, long aTimeVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetTimeValue(aTimeVal);
	}

	void ApplyDefaultBooleanValue(long aPropId, BOOL aBoolVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetBooleanValue(aBoolVal);
	}

	void ApplyDefaultEnumValue(long aPropId, long aEnumVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetEnumValue(aEnumVal);
	}

	void ApplyDefaultDecimalValue(long aPropId, const unsigned char* aDecimalVal)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL != prop) return;

		long ref;
		prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
		prop->SetDecimalValue(aDecimalVal);
	}

	double GetDoubleProperty(long aPropId)
	{
		const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);
		if (NULL == prop) 
		{
			mbWasNull = true;
			mbWasTypeIncompatible = false;
			return 0.0;
		}

		if (prop->GetType() != SharedPropVal::DOUBLE_PROPERTY)
		{
			mbWasNull = true;
			mbWasTypeIncompatible = true;
			return 0.0;
		}
	
		mbWasNull = false;
		mbWasTypeIncompatible = false;
		return prop->GetDoubleValue();
	}

	long GetLongProperty(long aPropId)
	{
		const SharedPropVal * prop = mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);
		if (NULL == prop) 
		{
			mbWasNull = true;
			mbWasTypeIncompatible = false;
			return 0;
		}

		if (prop->GetType() != SharedPropVal::LONG_PROPERTY)
		{
			mbWasNull = true;
			mbWasTypeIncompatible = true;
			return 0;
		}
	
		mbWasNull = false;
		mbWasTypeIncompatible = false;
		return prop->GetLongValue();
	}

	// Was the last property accessed a null?
	bool WasNull()
	{
		return mbWasNull;
	}

	// Refines the null flag and tells us whether the property existed but
	// was not of a compatible type.
	bool WasTypeIncompatible()
	{
		return mbWasTypeIncompatible;
	}

	const SharedPropVal * GetReadableProperty(long aPropId)
	{
		return mpSharedSession->GetReadablePropertyWithID(mpHeader, aPropId);
	}

	SharedPropVal* GetWriteableProperty(long aPropId)
	{
		return mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
	}

	bool PropertyExists(long aPropId, MTPipelineLib::MTSessionPropType aType)
	{
		const SharedPropVal* prop = GetReadableProperty(aPropId);

		if (NULL == prop) return false;
		
		bool exists=false;
		switch (prop->GetType())
		{
		case SharedPropVal::DECIMAL_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_DECIMAL);
			break;
		case SharedPropVal::OLEDATE_PROPERTY:
		case SharedPropVal::TIMET_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_DATE);
			break;
		case SharedPropVal::TIME_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_TIME);
			break;
		case SharedPropVal::ASCII_PROPERTY:
		case SharedPropVal::UNICODE_PROPERTY:
		case SharedPropVal::TINYSTRING_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_STRING);
			break;
		case SharedPropVal::LONG_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_LONG);
			break;
		case SharedPropVal::LONGLONG_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_LONGLONG);
			break;
		case SharedPropVal::DOUBLE_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_DOUBLE);
			break;
		case SharedPropVal::BOOL_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_BOOL);
			break;
		case SharedPropVal::ENUM_PROPERTY:
			exists = (aType == MTPipelineLib::SESS_PROP_TYPE_ENUM);
			break;
		default:
			ASSERT(0);
			exists = false;
			break;
		}

		return exists;
	}

	void SetLongProperty(long aPropId, long aValue)
	{
		SharedPropVal * prop = mpSharedSession->GetWriteablePropertyWithID(mpHeader, aPropId);
		if (NULL == prop) 
		{
			long ref;
			prop = mpSharedSession->AddProperty(mpHeader, ref, aPropId);
			if (prop == NULL)
			{
				throw _com_error(PIPE_ERR_SHARED_OBJECT_FAILURE);
			}
		}
		ClearProperty(prop);
		prop->SetLongValue(aValue);
	}

	long GetServiceID()
	{
		return mpSharedSession->GetServiceID();
	}

	const unsigned char* GetUID()
	{
		return mpSharedSession->GetUID();
	}
};

#endif
