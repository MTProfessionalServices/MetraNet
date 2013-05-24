/**************************************************************************
 * @doc MTSQLPIPELINEINTERPRETER
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by: Travis Gebhardt
 *
 * $Date: 3/12/2002 4:37:05 PM$
 * $Author: Derek Young$
 * $Revision: 1$
 *
 * @index | MTSQLPIPELINEINTERPRETER
 ***************************************************************************/

#ifndef _MTSQLPIPELINEINTERPRETER_H
#define _MTSQLPIPELINEINTERPRETER_H

#include <mtcomerr.h>
#include <MTSQLInterpreter.h>
#include <MTSQLInterpreterSessionInterface.h>


// this activation record interfaces with a session
// it is mostly read-only (except boolean _ExecutePlugin property)
class MTSQLPipelineActivationRecord : public ActivationRecord
{
private:
	MTPipelineLib::IMTSessionPtr mSessionPtr;
public:
	MTSQLPipelineActivationRecord(MTPipelineLib::IMTSessionPtr aSessionPtr)
		: mSessionPtr(aSessionPtr)
	{ }

	//
	// read methods
	//
	void getLongValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_LONG) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignLong(mSessionPtr->GetLongProperty(id));
	}
	void getLongLongValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_LONGLONG) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignLongLong(mSessionPtr->GetLongLongProperty(id));
	}
	void getDoubleValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DOUBLE) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDouble(mSessionPtr->GetDoubleProperty(id));
	}
	void getDecimalValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DECIMAL) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDec(&DECIMAL(mSessionPtr->GetDecimalProperty(id)));
	}
	void getStringValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignString(std::string((const char *)(mSessionPtr->GetBSTRProperty(id))));
	}
	void getWStringValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignWString(std::wstring((const wchar_t *)(mSessionPtr->GetBSTRProperty(id))));
	}
	void getBooleanValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_BOOL) == VARIANT_FALSE) 
			value->assignNull();
    else
			(value->assignBool(VARIANT_TRUE==mSessionPtr->GetBoolProperty(id) ? 
																true : 
																false));
	}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_DATE) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignDatetime(mSessionPtr->GetOLEDateProperty(id));
	}
	void getTimeValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_TIME) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignTime(mSessionPtr->GetTimeProperty(id));
	}
	void getEnumValue(const Access * access, RuntimeValue * value)
	{
		long id = (static_cast<const MTSessionAccess *>(access))->getID();
		if(mSessionPtr->PropertyExists(id, MTPipelineLib::SESS_PROP_TYPE_ENUM) == VARIANT_FALSE) 
			value->assignNull();
    else
			value->assignEnum(mSessionPtr->GetEnumProperty(id));
	}


	//
	// write method
	//
	void setBooleanValue(const Access * access, const RuntimeValue * val)
	{
		long id = getID(access);
		if (id == PipelinePropIDs::ExecutePluginCode())
			mSessionPtr->SetBoolProperty(id, val->getBool() ? VARIANT_TRUE : VARIANT_FALSE);
		else
			MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}


	//
	// illegal write methods
	//
	void setLongValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setLongLongValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setDoubleValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setDecimalValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setStringValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setWStringValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setTimeValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}
	void setEnumValue(const Access * access, const RuntimeValue * val)
	{
		MT_THROW_COM_ERROR(PIPE_ERR_CONDITION_OTHER_PROP_SET);
	}

	// gets the property's name ID value (keeps the one-liner methods short)
	long getID(const Access * access)
	{
		return static_cast<const MTSessionAccess *>(access)->getID();
	}

	ActivationRecord* getStaticLink() 
	{
		// This is always a global environment; can't have a static link.
		return NULL;
	}
};


#endif
