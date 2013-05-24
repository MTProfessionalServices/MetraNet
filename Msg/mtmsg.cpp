/**************************************************************************
 * @doc
 * 
 * Copyright 2000 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LISCENCED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: 
 * $Header$
 ***************************************************************************/

//
// This appears to be used only on Unix --blount
//

#ifdef UNIX
	////////////////////
	// mef: override time and size definitions
	#define USE_TIME
	#define USE_SIZE
	#include "unix_hacks.h"
	// mef: override time and size definitions
	////////////////////
#endif

#include <sdk_msg.h>
#include <unistd.h>
#include <string.h>

typedef const struct 
{
  METRATECH_MESSAGE_TYPE code;
  char *text;
} METRATECH_MESSAGE_MAP;

#include "sdk_msg.c"

const char *mt_message_lookup(METRATECH_MESSAGE_TYPE code)
{
  int i = 0, cd = (int) code;

  if ((cd & MT_ERR) || (cd & USER_DEFINED_CODE))
  {

    while (metra_message_mapping[i].code != MT_ERR_TERMINATE)
    {
      if (metra_message_mapping[i].code == code)
        break;
      i++;
    }
    if (metra_message_mapping[i].code == MT_ERR_TERMINATE)
      return NULL;
    
    return metra_message_mapping[i].text;
  } else {
    /* link with -lintl to get native language message 
     * based on LC_MESSAGES local (see man page setlocale(3C))
     */
    char *errno_error = strerror(cd); 

    return errno_error;
  }
}

