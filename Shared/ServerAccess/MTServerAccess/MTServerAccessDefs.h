
#ifndef __MTSERVERACCESSDEFS_H_
#define __MTSERVERACCESSDEFS_H_

#include <metra.h>

#define MTDEBUG							0   // 1 debug flag on, 0 debug flag off


// const for config path
const char SERVER_ACCESS_CONFIG_PATH[] = "\\ServerAccess";

// xml file name
const char SERVERS_XML_FILE[] = "servers.xml";

// xml tag names
const char SERVER_TAG[] = "server";
const char SERVER_TYPE_TAG[] = "servertype";
const char SERVER_NAME_TAG[] = "servername";
const char DATABASE_NAME_TAG[] = "databasename";
const char DATASOURCE_TAG[] = "datasourcename";
const char DATABASE_DRIVER_TAG[] = "databasedriver";
const char DATABASE_TYPE_TAG[] = "databasetype";
const char NUM_RETRIES_TAG[] = "numretries";
const char TIMEOUT_TAG[] = "timeout";
const char PRIORITY_TAG[] = "priority";
const char SECURE_TAG[] = "secure";
const char PORT_NUMBER_TAG[] = "portnumber";
const char USER_NAME_TAG[] = "username";
const char PASSWORD_TAG[] = "password";
const char DTC_ENABLED_TAG[] = "dtcenabled";

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

// tag for the mtServerAccess logger
const char MTSERVERACCESS_STR[] = "[MTServerAccess]";


#endif
