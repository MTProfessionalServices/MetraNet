/**************************************************************************
 * @doc PropGenInclude
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
#ifndef _PropGenInclude_H_
#define _PropGenInclude_H_

#include <list>
#include <map>
#include <vector>
#include <string>

using std::map;
using std::list;
using std::vector;

#include <MTDec.h>
#include "MTUtil.h"

typedef vector<int>							PCIDMaskColl;

#define MTDEBUG					0   // 0: no debug, 1: debug

#define SUCCESS					0
#define FAILURE					1
#define BITS_IN_BYTE		8
#define MAX_BUFFER_SIZE	128
#define MAX_LOG_STRING	512

// define name symbol for PropGenerator::Serialization
#define DEFAULT_ACTIONS							"default_actions"
#define ACTION											"action"
#define CONSTRAINT_SET							"constraint_set"
#define ACTIONS											"actions"
#define CONSTRAINT									"constraint"
#define PROP_NAME										"prop_name"
#define PROP_SOURCE_NAME						"prop_source_name"
#define PROP_SOURCE_TYPE						"prop_source_type"
#define CONDITION										"condition"
#define PROP_VALUE									"prop_value"

#define INVALID_PROP_CONST_TYPE			-1

#endif
