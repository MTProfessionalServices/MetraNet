
#ifndef __MTCONFIGINCLUDE_H_
#define __MTCONFIGINCLUDE_H_

#define MAX_VALUE_SIZE			1024
#define MAX_FILENAME_SIZE		256
#define MAX_BUFFER_SIZE			256

#define DEFAULT_LINGER_DAY	365

#define MTDEBUG 0   // 1 debug flag on, 0 debug flag off

#define DEPLOYMENT_STATUS			"deployment_status"
#define TEST_DEPLOYMENT_MODE	"test_deployment_mode"

#define COMPONENT				"component"
#define COMPONENT_NAME	"component_name"
#define COMPONENT_VALUE "component_path"

#define MTSYSCONFIGDATA	"mtsysconfigdata"
#define MTCONFIGDATA		"mtconfigdata"
#define EFFECTIVE_DATE	"effective_date"
#define LINGER_DAY			"timeout"
#define FILE_TYPE				"configfiletype"

#define XML_EXT					".xml"
#define WILDCARD_CHAR		"*"
#define VERSION_SYMBOL	"_v"
#define TEST_SYMBOL			"test"

#define TEST_FILENAME_SUFFIX	"_vtest"

#define DEFAULT_EFFECTIVE_DATE_STR	"1975-03-27T05:00:00Z"
#define DEFAULT_EFFECTIVE_DATE			165128400 // datetime in long "1975-03-27T05:00:00Z"

#endif