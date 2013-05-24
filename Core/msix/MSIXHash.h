/**************************************************************************
 * @doc MSIXHASH
 *
 * @module |
 *
 *
 * Copyright 2000 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MSIXHASH
 ***************************************************************************/

#ifndef _MSIXHASH_H
#define _MSIXHASH_H

#include <string.h>

// NOTE: to regenerate MSIXHash.cpp, use the following command line:
// gperf -C -G -t -L C++ -Z MSIXTagHashInternal msix.gperf > MSIXHash.cpp

//
// options:
//
// `-C' Makes the contents of all generated lookup tables constant,
//      i.e., "readonly." Many compilers can generate more efficient code for
//      this by putting the tables in readonly memory.
//
// `-G' Generate the static table of keywords as a static global
//      variable, rather than hiding it inside of the lookup function (which
//      is the default behavior).
//
// `-t' Allows the user to include a structured type
//      declaration for generated code. Any text before %%
//      is considered part of the type declaration. Key
//      words and additional fields may follow this, one
//      group of fields per line.
//
// `-L generated language name' Instructs gperf to generate code in the
//      language specified by the option's argument. Languages handled are
//      currently C++ and C. The default is C.
//
// `-Z class name' Allow user to specify name of generated C++
//      class. Default name is Perfect_Hash.

// enumeration used to identify MSIX tags
enum MSIXTag
{
	MSIX_BeginSessionRS,
	MSIX_Code,
	MSIX_CommitSession,
	MSIX_CommitSessionRS,
	MSIX_Dn,
	MSIX_Message,
	MSIX_Message_Entity,
	MSIX_Message_Timestamp,
	MSIX_Message_Version,
	MSIX_Message_TransactionID,
	MSIX_Msix,
	MSIX_Session,
	MSIX_SessionStatus,
	MSIX_Session_Commit,
	MSIX_Session_Feedback,
	MSIX_Session_Insert,
	MSIX_Session_ParentId,
	MSIX_Session_Prop,
	MSIX_Session_Props,
	MSIX_Session_Value,
	MSIX_Status,
	MSIX_Uid,
};

struct MSIXHashEntry { char * name; enum MSIXTag tag; };

const struct MSIXHashEntry * FindMSIXTag(const char *str, unsigned int len);


#endif /* _MSIXHASH_H */
