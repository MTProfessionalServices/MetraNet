/**************************************************************************
 * @doc DBConstants
 * 
 * @module  Database Constants |
 * 
 * This file contains database constants.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | DBConstants
 ***************************************************************************/

#ifndef __DBCONSTANTS_H
#define __DBCONSTANTS_H

#include <SharedDefs.h>

#define DB_VIEW_TYPE        L"ViewType"
#define DB_SUMMARY_VIEW     L"Summary"
#define DB_PRODUCT_VIEW     L"Product"
#define DB_DISCOUNT_VIEW    L"Discount"
#define DB_DATAANALYSIS_VIEW L"DataAnalysis"
#define DB_VIEW_ID          L"ViewID"
#define DB_PARENT_VIEW_ID   L"ParentViewID"
#define DB_SESSION_ID       L"SessionID"
#define DB_NEXT_ID          L"NextID"
#define DB_VIEW_NAME        L"ViewName"
#define DB_PROPERTY_NAME    L"PropertyName"
#define DB_COLUMN_NAME      L"ColumnName"
#define DB_PROPERTY_TYPE    L"PropertyType"
#define DB_TABLE_NAME       L"TableName"
#define DB_EXT_TABLE_NAME   L"ExtAttrTableName"
#define DB_SERVICE_NAME     L"ServiceName"
#define DB_SERVICE_ID       L"ServiceID"
#define DB_DESCRIPTION      L"Description"
#define DB_DESCRIPTION_ID   L"DescriptionID"
#define DB_LANGUAGE_ID      L"LanguageID"
#define DB_LANGUAGE_CODE    L"LanguageCode"
#define DB_COUNTRY_ID       L"CountryID"
#define DB_AMOUNT           L"Amount"
#define DB_CURRENCY         L"Currency"
#define DB_COUNT            L"Count"
#define DB_ATOMIC_SESSION   L"Atomic"
#define DB_COMPOUND_SESSION L"Compound"
#define DB_CURRENT_ID       L"CurrentID" 
#define DB_INTERVAL_ID      L"IntervalID"
#define DB_ACCOUNT_ID       L"AccountID"
#define DB_START_DATE       L"StartDate"
#define DB_END_DATE         L"EndDate"
#define DB_CYCLE_TYPE_ID    L"CycleTypeID"
#define DB_CYCLE_TYPE       L"CycleType"
#define DB_PROPERTY_NAME    L"PropertyName"
#define DB_PROPERTY_TYPE    L"PropertyType"
#define DB_COLUMN_NAME      L"ColumnName"
#define DB_TIMESTAMP        L"Timestamp"
#define DB_SESSION_TYPE     L"SessionType"
#define DB_COLOR_NAME     	L"nm_color"
#define DB_TIMEZONE_VALUE  	L"TimezoneValue"
#define DB_TIMEZONE_ID    	L"id_timezone"
#define DB_TIMEZONE_NAME  	L"nm_timezone"
#define DB_TIMEZONE_INFO  	L"tx_timezone_info"
#define DB_TX_DLST     		  L"tx_DLST"
#define DB_GMT_OFFSET     	L"qn_GMT_offset"
#define DB_PROGID           L"ProgID"
#define DB_DAY_OF_MONTH     L"DayOfMonth"
#define DB_CYCLE_ID         L"CycleID"
#define DB_UID              L"SessionUID"
#define DB_PARENT_UID       L"ParentUID"
#define DB_TX_AUTH_METHOD  	L"tx_auth_method"
#define DB_TX_ACC_MAPPER  	L"tx_acc_mapper"
#define DB_ID_KIOSK  	      L"id_kiosk"
#define DB_LOGIN_NAME  	    L"nm_login"
#define DB_NAME_SPACE  	    L"nm_space"
#define DB_STATUS           L"Status"
#define DB_BATCH_ID         L"BatchID"
#define DB_TAX_FEDERAL      L"FedTax"
#define DB_TAX_STATE        L"StateTax"
#define DB_TAX_COUNTY       L"CountyTax"
#define DB_TAX_LOCAL        L"LocalTax"
#define DB_TAX_OTHER        L"OtherTax"
#define DB_TAX_TOTAL        L"TotalTax"
#define DB_TAX_AMOUNT       L"TaxAmount"
#define DB_INTERVAL_START   L"IntervalStart"
#define DB_INTERVAL_END     L"IntervalEnd"
#define DB_ENUM_TYPE_FLAG   L"EnumTypeFlag"
#define DB_RUN_ID           L"RunID"
#define DB_ADAPTER_NAME     L"AdapterName"
#define DB_CONFIG_FILE      L"ConfigFile"
#define DB_LOCALIZED_STRING_NAME      L"LocalizedString"
#define DB_STRING_VALUE      L"Value"
#define DB_STRING_ENUMERATOR      L"Enumerator"
#define DB_DATE_EFFECTIVE   L"DateEffective"
#define DB_AMOUNT_WITH_TAX  L"AmountWithTax"
#define DB_AGG_RATE					L"AggRate"
#define DB_SECONDPASS				L"SecondPass"

#define DB_LANG_ID          L"LanguageID"
#define DB_LANG_CODE        L"LanguageCode"
#define DB_LANGUAGE_STRING  L"LanguageString"
#define DB_ENUM_NAMESPACE   L"EnumNamespace"
#define DB_ENUM_ENUMERATION L"EnumEnumeration"
#define DB_FILTERABLE_FLAG  L"Filterable"
#define DB_EXPORTABLE_FLAG  L"Exportable"

#define DB_FILTER_NAME      L"FilterName"
#define DB_FILTER_OPERATOR  L"FilterOperator"
#define DB_FILTER_VALUE     L"FilterValue"
#define DB_FILTER_CRITERIA  L"FilterCriteria"

#define DB_TAX_AMOUNT_COLUMN L"(au.tax_federal + au.tax_state + au.tax_county + au.tax_local + au.tax_other)"
#define DB_AMOUNT_WITH_TAX_COLUMN L"(au.amount + au.tax_federal + au.tax_state + au.tax_county + au.tax_local + au.tax_other)"

// payment server
// defined above #define MTPARAM_ACCOUNTID            L"%%ACCOUNT_ID%%"
#define DB_PSACCOUNTID         L"id_acc"
#define DB_CUSTOMERNAME        L"nm_customer"
#define DB_ADDRESS             L"nm_address"
#define DB_CITY                L"nm_city"
#define DB_STATE               L"nm_state"
#define DB_ZIP                 L"nm_zip"
#define DB_PSCOUNTRY           L"nm_country"
#define DB_EMAIL               L"nm_email"
#define DB_CREDITCARDTYPE      L"id_creditcardtype"
#define DB_LASTFOURDIGITS      L"nm_lastfourdigits"
#define DB_CREDITCARDNUMBER    L"nm_ccnum"
#define DB_EXPDATE             L"nm_expdate"
#define DB_EXPDATEFORMAT       L"id_expdatef"
#define DB_STARTDATE           L"nm_startdate"
#define DB_STARTDATEFORMAT     L"id_startdatef"
#define DB_ISSUERNUMBER        L"nm_issuernumber"
#define DB_XACTIONID           L"nm_xactionid"
#define DB_TERMINALID          L"id_termid"
#define DB_TEXT_DESC           L"tx_desc"
#define DB_CARDID              L"nm_cardid"
#define DB_CARDVERIFYVALUE     L"nm_cardverifyvalue"
#define DB_CUSTOMERREFERENCEID L"nm_customerreferenceid"
#define DB_CUSTOMERVATNUMBER   L"nm_customervatnumber"
#define DB_COMPANYADDRESS      L"nm_companyaddress"
#define DB_COMPANYPOSTALCODE   L"nm_companypostalcode"
#define DB_COMPANYPHONE        L"nm_companyphone"
#define DB_RESERVED1           L"nm_reserved1"
#define DB_RESERVED2           L"nm_reserved2"
#define DB_RETAINCARDINFO      L"id_retaincardinfo"
#define DB_PRIMARY             L"nm_primary"
#define DB_ENABLED             L"nm_enabled"
#define DB_AUTHRECEIVED        L"nm_authreceived"
#define DB_VALIDATED           L"nm_validated"
#define DB_RETRYONFAILURE      L"nm_retryonfailure"
#define DB_NUMBERRETRIES       L"id_numberretries"
#define DB_CONFIRMREQUESTED    L"nm_confirmrequested"
#define DB_DELAY               L"id_delay"
#define DB_BILLEARLY           L"nm_billearly"
#define DB_PCARD               L"nm_pcard"
#define DB_ACCOUNTTYPE         L"id_accounttype"
#define DB_BANKNAME            L"nm_bankname"
#define DB_ROUTINGNUMBER       L"nm_routingnumber"
#define DB_ACCOUNTNUMBER       L"nm_accountnumber"

#if 0
// generic property description ids
#define AMOUNT_DESC_ID          827
#define CURRENCY_DESC_ID        828
#define TAX_AMOUNT_DESC_ID      829
#define INTERVAL_ID_DESC_ID     874
#define TIMESTAMP_DESC_ID       875
#endif

// generic property fully qualified names ...
#define DB_AMOUNT_FQN           L"metratech.com/Amount"
#define DB_CURRENCY_FQN         L"metratech.com/Currency"
#define DB_TAX_AMOUNT_FQN       L"metratech.com/TaxAmount"
#define DB_INTERVAL_ID_FQN      L"metratech.com/IntervalID"
#define DB_TIMESTAMP_FQN        L"metratech.com/Timestamp"
#define DB_SESSION_ID_FQN        L"metratech.com/SessionID"
#define DB_AMOUNT_WITH_TAX_FQN  L"metratech.com/AmountWithTax"

// miscellaneous definitions ...
#define DB_INTEGER_TYPE     L"integer"
#define DB_INT_TYPE_ORACLE      L"number(10)"
#define DB_INT_TYPE         L"int"

#define DB_NUMBER_TYPE_ORACLE   L"number"

#define DB_VARCHAR_TYPE     L"varchar"
#define DB_VARCHAR_TYPE_ORACLE  L"varchar2"

#define DB_FLOAT_TYPE       L"float"
#define DB_FLOAT_TYPE_ORACLE    L"number"

#define DB_DOUBLE_TYPE      L"double"
#define DB_DOUBLE_TYPE_ORACLE   L"number"

#define DB_DATE_TYPE        L"datetime"
#define DB_DATE_TYPE_ORACLE L"date"
#define DB_CHAR_TYPE        L"char"
#define DB_CHAR_TYPE_ORACLE     L"char"

#define DB_SMALLINT_TYPE    L"smallint"
#define DB_SMALLINT_TYPE_ORACLE L"number(10)"

#define DB_NUMERIC_TYPE			METRANET_NUMERIC_PRECISION_AND_SCALE_MAX_WSTR
#define DB_NUMERIC_TYPE_ORACLE	METRANET_NUMBER_PRECISION_AND_SCALE_MAX_WSTR

#define DB_WSTRING_TYPE			L"nvarchar"
#define DB_WSTRING_TYPE_ORACLE L"nvarchar2"
#define DB_ENUM_TYPE        L"enum"
#define DB_BOOLEAN_TRUE     L"1"
#define DB_BOOLEAN_FALSE    L"0"
#define DB_DECIMAL_TYPE			L"decimal"
#define DB_BIGINT_TYPE      L"bigint"
#define DB_BIGINT_TYPE_ORACLE L"number(20)"

#define DB_STRING_TYPE      L"string"
#define DB_INT32_TYPE       L"int32"
#define DB_INT64_TYPE       L"int64"
#define DB_TIMESTAMP_TYPE   L"timestamp"

// property type descriptions ...
#define MTPROP_TYPE_INTEGER   L"INT32"
#define MTPROP_TYPE_FLOAT     L"FLOAT"
#define MTPROP_TYPE_DOUBLE    L"DOUBLE"
#define MTPROP_TYPE_DATE      L"TIMESTAMP"
#define MTPROP_TYPE_STRING    L"STRING"
#define MTPROP_TYPE_BSTR      L"BSTR"
#define MTPROP_TYPE_UNISTRING L"UNISTRING"
#define MTPROP_TYPE_EMPTY     L"EMPTY"
#define MTPROP_TYPE_CHAR      L"CHAR"
#define MTPROP_TYPE_UNKNOWN   L"UNKNOWN"
#define MTPROP_TYPE_ENUM      L"ENUM"
#define MTPROP_TYPE_BOOLEAN   L"BOOLEAN"
#define MTPROP_TYPE_NUMERIC   L"NUMERIC"
#define MTPROP_TYPE_DECIMAL   L"DECIMAL"
#define MTPROP_TYPE_VARBINARY L"VARBINARY"
#define MTPROP_TYPE_BIGINTEGER   L"INT64"

#define DBSP_GET_CURRENT_ID L"GetCurrentID"
#define DBSP_PARAM_SESSION_ID   L"id_sess"
#define DBSP_PARAM_INTERVAL_ID  L"id_interval"
#define DBSP_PARAM_ID           L"id"
#define DBSP_PARAM_NAME         L"nm_current"

#define MAX_INT_SIZE        64
#define MAX_CHAR_SIZE       255

// use theis format when using RWDate's asString ...
#define STD_DATE_FORMAT             "%m/%d/%Y"

// definitions for the locale translator ...
#define COMMA_LOCALE_DELIMITER        L","
#define PERIOD_LOCALE_DELIMITER       L"."

#define CURRENCY_CODE_USD   L"USD"
#define CURRENCY_CODE_DEM   L"DEM"
#define CURRENCY_CODE_INR   L"INR"
#define CURRENCY_CODE_GBP   L"GBP"
#define CURRENCY_CODE_JPY   L"JPY"
#define CURRENCY_CODE_FRF   L"FRF"
#define CURRENCY_CODE_BEF   L"BEF"
#define CURRENCY_CODE_ESP   L"ESP"
#define CURRENCY_CODE_IEP   L"IEP"
#define CURRENCY_CODE_ITL   L"ITL"
#define CURRENCY_CODE_LUF   L"LUF"
#define CURRENCY_CODE_NLG   L"NLG"
#define CURRENCY_CODE_ATS   L"ATS"
#define CURRENCY_CODE_NONE  L" "

#define CURRENCY_SYMBOL_USD L"$ "
#define CURRENCY_SYMBOL_DEM L" DM"
#define CURRENCY_SYMBOL_INR L" Rs" 
#define CURRENCY_SYMBOL_GBP L"&pound "
#define CURRENCY_SYMBOL_JPY L"&yen "
#define CURRENCY_SYMBOL_FRF L" FF"
#define CURRENCY_SYMBOL_BEF L" BF"
#define CURRENCY_SYMBOL_ESP L" Ptas"
#define CURRENCY_SYMBOL_IEP L"Ir&pound "
#define CURRENCY_SYMBOL_ITL L"Lit " 
#define CURRENCY_SYMBOL_LUF L"LuxF "
#define CURRENCY_SYMBOL_NLG L"nlG "
#define CURRENCY_SYMBOL_ATS L"AuS "
#define CURRENCY_SYMBOL_EUR L" EUR"
#define CURRENCY_SYMBOL_NONE L" "

const double DEM_CONVERSION_RATE = 1.95583 ;
const double FRF_CONVERSION_RATE = 6.55957 ;
const double BEF_CONVERSION_RATE = 40.3399 ;
const double ESP_CONVERSION_RATE = 166.386 ;
const double IEP_CONVERSION_RATE = .787564 ;
const double ITL_CONVERSION_RATE = 1936.27 ;
const double LUF_CONVERSION_RATE = 40.3399 ;
const double NLG_CONVERSION_RATE = 2.20371 ;
const double ATS_CONVERSION_RATE = 13.7 ;

// definitions for contact information
const char * const CONTACT_FIRST_NAME = "givenname" ;
const char * const CONTACT_MIDDLE_INIT = "middleinitial" ;
const char * const CONTACT_LAST_NAME = "sn" ;
const char * const CONTACT_ADDR1 = "address1" ;
const char * const CONTACT_ADDR2 = "address2" ;
const char * const CONTACT_ADDR3 = "address3" ;
const char * const CONTACT_CITY = "city" ;
const char * const CONTACT_STATE = "state" ;
const char * const CONTACT_ZIP = "zip" ;
const char * const CONTACT_COUNTRY = "c" ;
const char * const CONTACT_ACCOUNT_TYPE = "accounttype" ;
const char * const CONTACT_BILL_TO = "1" ;

// definitions for QuickBooks Transaction types 
#define QB_PAYMENT          L"PAYMENT"
#define QB_INVOICE          L"INVOICE"

const DWORD DB_SERVICEID_SIZE=18 ;
const DWORD DB_SERVICENAME_SIZE=18 ;
const DWORD DB_UPDATEID_SIZE=18 ;
const DWORD DB_DELIVERERID_SIZE=18 ;
const DWORD DB_TABLENAME_SIZE=32 ;
const DWORD DB_PROPERTYNAME_SIZE=18 ;
const DWORD DB_PROPERTYTYPE_SIZE=18 ;
const DWORD DB_DEFAULTVALUE_SIZE=18 ;
const DWORD DB_COLUMNNAME_SIZE=32 ;

// 
// *****************************************************************************
// DEVELOPER NOTE(KDF): The DB_SOURCERID_SIZE value must be greater than or equal 
//  to the DB_SESSIONID_SIZE due to reasons specified in DBAccess.cpp. 
// *****************************************************************************
//
const DWORD DB_SOURCERID_SIZE=18 ; 
const DWORD DB_SESSIONID_SIZE=16 ;

#endif // __DBCONSTANTS_H

