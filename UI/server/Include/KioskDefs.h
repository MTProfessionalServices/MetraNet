
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
 * Created by: Raju Matta
 * $Header$
 *	KioskDefs.h
 *	-----------
 *	This file holds constants, typedefs and forward class definitions
 *	specific to the Kiosk Application
 *
 ***************************************************************************/

#ifndef _KIOSKDEFS_H_
#define _KIOSKDEFS_H_

#include <metra.h>

// defines ...
const char PRES_SERVER_DIR[] = "PresServer" ;
const wchar_t GATEWAY_CONFIG[] = L"gateway.xml" ;
const wchar_t SITE_CONFIG[] = L"site.xml" ;
const wchar_t LOCALIZED_SITE_CONFIG[] = L"localized_site.xml" ;
const wchar_t VIEW_TO_ASP_MAPPING[] = L"viewtoaspmapping.xml" ;
const wchar_t NEW_MPSSITECONFIG_DIR[] = L"\\MPS\\siteconfig\\";

// forward from other libraries

// credentials type
const long LOGIN_PWD_TYPE = 1;
const long CERTIFICATE_TYPE = 2;

const wchar_t PROVIDERID_STR[] = L"PROVIDERID";
const wchar_t REFERRINGURL_STR[] = L"REFERRINGURL";
const wchar_t OPENSTATUS_STR[] = L"Open";
const wchar_t USERCONFIG_TYPE_STR[] = L"US";
const wchar_t SITECONFIG_TYPE_STR[] = L"SC";
const wchar_t INS_QUERY_TYPE_STR[] = L"INSERT";
const wchar_t UPD_QUERY_TYPE_STR[] = L"UPDATE";
const wchar_t DEFAULT_DESC_STR[] = L"System";

// const for the log file for debugging -- com stuff
const char KIOSK_STR[] = "Kiosk";

// const for database field names
const wchar_t ACCOUNT_ID_STR[] = L"id_acc";
const wchar_t TARIFF_ID_STR[] = L"id_tariff";
const wchar_t TARIFF_NAME_STR[] = L"nm_tariff";
const wchar_t TAG_NAME_STR[] = L"nm_tag";
const wchar_t TAG_VALUE_STR[] = L"val_tag";
const wchar_t PROFILE_ID_STR[] = L"id_profile";
const wchar_t KIOSK_ID_STR[] = L"id_kiosk";
const wchar_t KIOSK_USER_ID_STR[] = L"id_kiosk_user";
const wchar_t LOGIN_NAME_STR[] = L"nm_login";
const wchar_t DEFAULT_LANG_ID_STR[] = L"id_def_lang";
const wchar_t LANG_CODE_STR[] = L"tx_lang_code";
const wchar_t WEB_URL_STR[] = L"webURL";
const wchar_t NAME_SPACE_STR[] = L"nm_space";
const wchar_t CURRENT_ID_STR[] = L"id_current";
const wchar_t SITE_ID_STR[] = L"id_site";
const wchar_t GEOCODE_STR[] = L"geocode";
const wchar_t TAX_EXEMPT_STR[] = L"in_tax_exempt";
const wchar_t PAYMENT_METHOD_ID_STR[] = L"id_payment_method";
const wchar_t START_DATE_STR[] = L"dt_start";
const wchar_t END_DATE_STR[] = L"dt_end";
const wchar_t USAGE_CYCLE_TYPE_STR[] = L"tx_cycle_type_method";
const wchar_t CURRENCY_STR[] = L"tx_currency";
const wchar_t ACCOUNT_USAGE_CYCLE_ID_STR[] = L"id_usage_cycle";

// const for the method names
const wchar_t ADD_STR[] = L"Add";
const wchar_t INITIALIZE_STR[] = L"Initialize";
const wchar_t GET_INSTANCE_STR[] = L"GetInstance";
const wchar_t GET_NEW_INSTANCE_STR[] = L"GetNewInstance";

// const for config path
const char PRES_SERVER_CONFIG_PATH[] = "\\PresServer";
const char PRES_SERVER_QUERY_PATH[] = "\\Queries\\PresServer";
const wchar_t W_US_ENGLISH_LANGUAGE_STR[] = L"US";
const wchar_t W_ACTIVE_STATUS_STR[] = L"A";

// xml file names
const char DEFAULT_USER_PROFILE_XML_FILE[] = "DefaultUserProfile.xml";
const char TIMEZONE_XML_FILE[] = "timezone.xml";
const char COLORS_XML_FILE[] = "colors.xml";
const char SITE_XML_FILE[] = "site.xml" ;

// xml tag string -- profile related
const char PROFILE_SET_STR[] = "profileset";
const char PROFILE_NAME_STR[] = "profile_name";
const char PROFILE_VALUE_STR[] = "profile_value";

// xml tag string -- colors related
const char COLOR_STR[] = "color";
const char COLOR_NAME_STR[] = "color_name";
const char DESCID_STR[] = "description_id";

// xml tag string -- timezone related
const char TIMEZONE_STR[] = "timezone";
const char ID_TIMEZONE_STR[] = "id_timezone";
const char NM_TIMEZONE_STR[] = "nm_timezone";
const char TX_TIMEZONE_INFO_STR[] = "tx_timezone_info";
const char TX_DLST_STR[] = "tx_DLST";
const char QN_GMT_OFFSET_STR[] = "qn_GMT_offset";

// xml tag strings -- site related 
const char LOCALIZED_SITES_STR[] = "localized_sites" ;
const char LOCALIZED_SITE_STR[] = "localized_site" ;
const char SITE_NAME_STR[] = "site_name" ;
// typedefs

#define ADD_ACCOUNT_MAPPING         0
#define UPDATE_ACCOUNT_MAPPING      1
#define DELETE_ACCOUNT_MAPPING      2

#endif	// _KIOSKDEFS_H_

