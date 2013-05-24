
#ifndef __MTACCOUNTDEFS_H_
#define __MTACCOUNTDEFS_H_

#include <metra.h>

#define MTDEBUG							0   // 1 debug flag on, 0 debug flag off


// const for config path

// xml file name

// xml tag names

// == operator
inline bool operator ==(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

// == operator
inline bool operator <(const CComVariant & arVar1, const CComVariant & arVar2)
{
    ASSERT(0);
	return FALSE;
}

// tag for the mtaccount logger
const char MTACCOUNT_STR[] = "MTAccount";
const char MTSQLADAPTER_STR[] = "MTSQLAdapter";
const char MTLDAPADAPTER_STR[] = "MTLDAPAdapter";
const char MTACCOUNT_ADAPTERS_CONFIG_PATH[] = "\\Account\\Adapters";
const char MTACCOUNT_CONFIG_PATH[] = "\\Queries\\Account";
const char MTACCOUNT_ADAPTERS_XML_FILE[] = "\\AccountAdapters.xml";

// tag names
const char ADAPTER_SET_TAG[] = "AccountType\\AccountViews\\AdapterSet";
const char NAME_TAG[] = "Name";
const char PROGID_TAG[] = "ProgID";
const char CONFIGFILE_TAG[] = "ConfigFile";

#endif
