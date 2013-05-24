/**************************************************************************
 * @doc RuleSetConfigInclude
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
 *
 * Modification History:
 *		Chen He - August 5, 1998 : Initial version
 *
 * $Header$
 ***************************************************************************/
#ifndef _RuleSetConfigInclude_H_
#define _RuleSetConfigInclude_H_

#include <string>

#include "MTUtil.h"
#include "loggerconfig.h"

#define MTDEBUG							0   // 0: no debug, 1: debug


#define MAX_BUFFER_SIZE			256
#define MAX_LOG_STRING			256

// define name symbol
#define DEFAULT_ACTIONS			"default_actions"
#define ACTION							"action"
#define CONSTRAINT_SET			"constraint_set"
#define ACTIONS							"actions"
#define CONSTRAINT					"constraint"
#define PROP_NAME						"prop_name"
#define CONDITION						"condition"
#define PROP_VALUE					"prop_value"

// header info
#define	SYSCONFIGDATA				"mtsysconfigdata"
#define EFFECTIVEDATE				"effective_date"
#define	TIMEOUT							"timeout" 
#define CONFIGFILETYPE			"configfiletype"
#define CONFIG_DATA					"CONFIG_DATA"

#define DEFAULT_TIMEOUT			30


#define RULESET_NAME				"name"
#define RULESET_PROGID			"progid"
#define RULESET_DESCRIPTION	"description"
#define RULESET_INPUTS			"inputs"
#define RULESET_INPUT				"input"

#define RULESET_OUTPUTS			"outputs"
#define RULESET_OUTPUT			"output"
#define RULESET_ARGUMENT		"argument"
#define RULESET_PROPERTY		"property"

#define MTCONFIGDATA				"mtconfigdata"
#define RULESET_VERSION			"version"
#define RULESET_PROCESSOR		"processor"
#define RULESET_CONFIGDATA	"configdata"

#define gpEnumTypeTag				L"enumtype"
#define gpEnumSpaceTag			L"enumspace"
#define gpPropertyTypeTag	  L"type"

#define gpEnum							"enum"

#endif
