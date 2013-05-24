/**************************************************************************
 * @doc PropGenInclude
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
 *		Chen He - September 10, 1998 : Initial version
 *
 * $Header$
 ***************************************************************************/
#ifndef _ScriptHostInclude_H_
#define _ScriptHostInclude_H_

#include <stdio.h>
//#include <comdef.h>
#include <io.h>
#include <fcntl.h>

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <malloc.h>

#include "MTUtil.h"

#define MTDEBUG										0   // 0: no debug, 1: debug

#define SCRIPT_SOURCE							"script_source"
#define SCRIPT_TYPE								"script_type"
#define PROCESS_SESSION_SET				"process_session_set"
#define SCRIPT_CONFIGDATA					"script_configdata"

#define PROCESS_SESSION_SET_FLAG	"Y"

#define MAX_VALUE_SIZE						1024
#define MAX_BUFFER_SIZE						1024
#define DISK_DEVICE_CHAR					":"
#define DIR_DELIMITER							"\\"

// this should be dfined in DevStudio as OLESCRIPT_E_SYNTAX 
#define MTOLESCRIPT_E_SYNTAX			0x80020101

#endif
