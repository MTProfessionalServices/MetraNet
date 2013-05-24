/**************************************************************************
 * @doc
 *
 * Copyright 1997-2000 by MetraTech Corporation
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
 * Created by: Chen He
 *
 * $Header$
 ***************************************************************************/

#ifndef _SummationInclude_H_
#define _SummationInclude_H_

#include "MTUtil.h"

#define MTDEBUG					0   // 0: no debug, 1: debug

#define CHUNKSIZE				10

#define MAX_BUFFER_SIZE	256
#define MAX_LOG_STRING	256

#define SESSION_ID					"SessionID"

// define name symbol
#define SUMMATION_ITEM			"summation_item"
#define	INPUT_PROP_NAME			"input_prop_name"
#define INPUT_PROP_TYPE			"input_prop_type"
#define INPUT_SERVICE_ID    "input_service_id"
#define OUTPUT_PROP_NAME		"output_prop_name"
#define ACTION							"action"
#define COUNTER_PROP_NAME		"counter_prop_name"

// propType name
#define INTEGER							"INTEGER"
#define	DOUBLE							"DOUBLE"
#define	DECIMAL_TAG					"DECIMAL"
#define	DATETIME						"DATETIME"
#define	TIME								"TIME"
#define INPUT_PROP_TYPE_LIST	"INTEGER, DOUBLE, DATETIME, and TIME"

// action name
#define	SUMMATION						"SUM"
#define	AVERAGE							"AVE"
#define	MINIMUM							"MIN"
#define	MAXIMUM							"MAX"
#define ACTION_LIST					"SUM, AVE, MIN, and MAX"



#define INVALID_PROP_CONST_TYPE			-1

#endif
