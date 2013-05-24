/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
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
 * Created by: Boris Partensky
 * $Header$
 **************************************************************************/

#ifndef _MTSQLPARAM_H_
#define _MTSQLPARAM_H_
#pragma once

#include "MTSQLConfig.h"
#include <string>
#include <RowsetDefs.h>

using namespace std;

typedef enum ParamDirection {DIRECTION_IN, DIRECTION_OUT};


class MTSQLParam {


public:
	MTSQLParam(): mDirection(DIRECTION_IN)
	{
	}
	MTSQL_DECL ~MTSQLParam();
	//TODO: Use same enumeration across different classes
	//For now make MTSQLType enum same as BuiltIn type in TreeParser and RuntimeValue objects
	enum MTSQLType {TYPE_INVALID=-1, TYPE_INTEGER, TYPE_DOUBLE, TYPE_STRING, TYPE_BOOLEAN, TYPE_DECIMAL, TYPE_DATETIME, TYPE_TIME, TYPE_ENUM, TYPE_WSTRING, TYPE_NULL, TYPE_BIGINTEGER, TYPE_BINARY};
	MTSQL_DECL void SetName(const char* pName);
	MTSQL_DECL void SetName(const string& pName);
	MTSQL_DECL void SetDirection(ParamDirection pDirection);
	MTSQL_DECL void SetType(int aType);
	MTSQL_DECL const string& GetName() const; 
	MTSQL_DECL const ParamDirection GetDirection() const;
	MTSQL_DECL const int GetType() const;
	/*
	inline const int GetStringType() 
	{ 
		return MTSQLTreeParser::getType(mType); 
	}
	*/

private:
  string mName;
	string mValue;
	//MTParameterDirection mDirection;
	ParamDirection mDirection;
	//MTParameterType mDBType;
	MTSQLType mType;
};

#endif 
