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
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Raju Matta
 *
 * $Header: SharedDefs.h, 31, 5/13/2001 11:43:52 AM, Derek Young$
 *
 *	ServicesDefs.h
 *	--------------
 *	This file holds constants, typedefs and forward class definitions
 *	specific to the UsageCycle Application
 *
 ***************************************************************************/

#ifndef _SHAREDDEFS_H_
#define _SHAREDDEFS_H_


// includes

#ifndef ASSERT
// use assert from assert.h unless it's already been defined.
// ASSERT is defined by MFC as well.
#include <assert.h>
#define ASSERT assert
#endif // ASSERT

// forward class forward

// declarations from other libraries

// global constant for ...
const char NAME_STR[] = "name";
const char TABLE_NAME_STR[] = "tablename";
const char DISTINGUISHED_NAME_STR[] = "dn";
const char TYPE_STR[] = "type";
const char LENGTH_STR[] = "length";
const char REQUIRED_STR[] = "required";
const char DEFAULTVALUE_STR[] = "defaultvalue";
const char PTYPE_STR[] = "ptype";
const char DESCRIPTION_ID_STR[] = "descriptionid";
const char UNIQUEKEY_STR[] = "uniquekey";
const char COL_STR[] = "col";
const char PARTITION_STR[] = "partition";
const char DESCRIPTION_STR[] = "description";

// const for the null string
const char NULL_STR[] = "";

const char YES_FLAG[] = "Y";
const char NO_FLAG[] = "N";
const char DB_NULL_STR[] = "NULL";
const char DB_NOT_NULL_STR[] = "NOT NULL";
const char DB_CHAR_STR[] = "char";
const char DB_VARCHAR_STR[] = "varchar";
const char DB_INT_STR[] = "int";
const char DB_DATETIME_STR[] = "datetime";
const char DB_DATETIME_STR_ORACLE[] = "date";
const char PTYPE_STRING_STR[] = "string";
const char PTYPE_INT32_STR[] = "int32";
const char PTYPE_INT64_STR[] = "int64";
const char PTYPE_TIMESTAMP_STR[] = "timestamp";

//----------------------------------------------------------
// Number precision (total number of significant digits)
// and scale (number of digits to right of decimal point)
const int METRANET_PRECISION_MAX            = 22;
const char METRANET_PRECISION_MAX_STR[]     = "22";
const wchar_t METRANET_PRECISION_MAX_WSTR[] = L"22";

const int METRANET_SCALE_MAX                = 10;
const char METRANET_SCALE_MAX_STR[]         = "10";
const wchar_t METRANET_SCALE_MAX_WSTR[]     = L"10";

// These PRECISION_AND_SCALE strings must be lowercase to satisfy DBProperty::Init().
const char METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_STR[]     =  "decimal(22,10)";
const wchar_t METRANET_DECIMAL_PRECISION_AND_SCALE_MAX_WSTR[] = L"decimal(22,10)";
const char METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_STR[]     =  "numeric(22,10)";
const wchar_t METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_WSTR[] = L"numeric(22,10)";
const char METRANET_NUMBER_PRECISION_AND_SCALE_MAX_STR[]      =  "number(22,10)";
const wchar_t METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR[]  = L"number(22,10)";

const wchar_t W_DB_NUMERIC_STR[] = L"numeric(22,10)";

const char METRANET_DECIMAL_MIN_VALUE_STR[] = "-999999999999.9999999999";
const char METRANET_DECIMAL_MAX_VALUE_STR[] =  "999999999999.9999999999";

//----------------------------------------------------------

const wchar_t W_NULL_STR[] = L"";
const wchar_t W_YES_FLAG[] = L"Y";
const wchar_t W_NO_FLAG[] = L"N";
const wchar_t W_DB_NULL_STR[] = L"NULL";
const wchar_t W_DB_NOT_NULL_STR[] = L"NOT NULL";
const wchar_t W_DB_CHAR_STR[] = L"char";
const wchar_t W_DB_VARCHAR_STR[] = L"varchar";
const wchar_t W_DB_NCHAR_STR[] = L"nchar";
const wchar_t W_DB_NVARCHAR_STR[] = L"nvarchar";
const wchar_t W_DB_NVARCHAR_STR_ORACLE[] = L"nvarchar2";
const wchar_t W_DB_INT_STR[] = L"int";
const wchar_t W_DB_INT_STR_ORACLE[] = L"number(10)";
const wchar_t W_DB_BIGINT_STR[] = L"bigint";
const wchar_t W_DB_BIGINT_STR_ORACLE[] = L"number(20)";
const wchar_t W_DB_DATETIME_STR[] = L"datetime";
const wchar_t W_DB_DATETIME_STR_ORACLE[] = L"date";
const wchar_t W_DB_FLOAT_STR[] = L"float";
const wchar_t W_DB_DOUBLE_STR[] = L"double precision";
const wchar_t W_DB_ENUM_STR[] = L"enum";
const wchar_t W_PTYPE_STRING_STR[] = L"string";
const wchar_t W_PTYPE_WSTRING_STR[] = L"unistring";
const wchar_t W_PTYPE_INT32_STR[] = L"int32";
const wchar_t W_PTYPE_INT64_STR[] = L"int64";
const wchar_t W_PTYPE_TIMESTAMP_STR[] = L"timestamp";
const wchar_t W_PTYPE_FLOAT_STR[] = L"float";
const wchar_t W_PTYPE_DOUBLE_STR[] = L"double";
const wchar_t W_PTYPE_ENUM_STR[] = L"enum";
const wchar_t W_PTYPE_BOOLEAN_STR[] = L"boolean";
const wchar_t W_PTYPE_TIME_STR[] = L"time";
const wchar_t W_ALL_STR[] = L"all";

// Services stuff
const char SERVICE_STR[] = "Service";
const char DEFINESERVICE_STR[] = "defineservice";
const char SERVICE_NAME_STR[] = "svcname";
const char SERVICE_CONFIG_PATH[] = "\\Service";
const char SERVICE_XML_FILE[] = "service.xml";

const char FILENAME_STR[] = "filename";
const char MSIXDEF_STR[] = "msixdef";

// const for database field names
const wchar_t SERVICE_ID_STR[] = L"id_service";

// Product view stuff
const char PRODUCT_VIEW_STR[] = "ProductView";
const char PRODUCT_VIEW_NAME_STR[] = "productviewname";
const char PRODUCT_VIEW_CONFIG_PATH[] = "\\ProductView";
const char PRODUCT_VIEW_XML_FILE[] = "productview.xml";

// const for database field names
const wchar_t PRODUCT_VIEW_ID_STR[] = L"id_prod_view";

// core stuff
const char CORE_STR[] = "Core";


// --------------------------------------------------------
// DB Install stuff starts here
const char DBINSTALL_STR[] = "DBInstall";
const char DB_INSTALL_CONFIG_PATH[] = "\\Queries\\DBInstall";
const char DB_INSTALL_XML_FILE[] = "MTDBInstall.xml";
const char DB_UNINSTALL_XML_FILE[] = "MTDBUnInstall.xml";
const char DB_OBJECTS_XML_FILE[] = "MTDBObjects.xml";
const char ORACLE_DB_INSTALL_XML_FILE[] = "MTDBInstall_Oracle.xml";
const char ORACLE_DB_UNINSTALL_XML_FILE[] = "MTDBUnInstall_Oracle.xml";
const char ORACLE_DB_OBJECTS_XML_FILE[] = "MTDBObjects_Oracle.xml";
const char ORACLE_ADD_TABLESPACE_XML_FILE[] = "MTAddTablespace_Oracle.xml" ;
const char CHANGE_DB_OWNER_XML_FILE[] = "MTChangeDBOwner.xml";
const char DEFAULT_SET_STR[] = "defaultset";
const char INSTALL_SET_STR[] = "installset";
const char MESSAGE_STR[] = "message";
const char OPTION_STR[] = "option";
const char QUERY_PARAM_SET_STR[] = "query_param_set";
const char PARAM_TAG_STR[] = "paramtag";
const char PARAM_VALUE_STR[] = "paramvalue";
const char QUERY_TAG_STR[] = "query_tag";
const char QUERY_PARAM_COUNT_STR[] = "query_param_count";
const char PARAM_STR[] = "param";
const wchar_t MASTER_DB_STR[] = L"master";

// --------------------------------------------------------
// Code lookup stuff starts here
const char CODE_LOOKUP_STR[] = "CodeLookup";

// listener stuff here
const char LISTENER_STR[] = "listener";

// install
const char INSTALL_STR[] = "install";

// stuff for credit card
const char VISA_CARD[]         = "VISA";
const char MASTER_CARD[]       = "MASTERCARD";
const char AMEX_CARD[]         = "AMEX";
const char DISCOVER_CARD[]     = "DISCOVER";
const char JCB_CARD[]          = "JCB";
const char CARTEBLANCHE_CARD[] = "CARTE BLANCHE";
const char DINERS_CARD[]       = "DINERS CLUB";
const char VISA_PCARD[]        = "VISA - PURCHASE CARD";
const char MASTER_PCARD[]      = "MASTERCARD - PURCHASE CARD";
const char AMEX_PCARD[]        = "AMEX - PURCHASE CARD";

// typedefs

#endif	// _SHAREDDEFS_H_

