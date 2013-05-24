/**************************************************************************
 * @doc ERROBJ
 *
 * @module Error object |
 *
 * Hold error codes and lookup error strings.
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
 * Created by: billo
 * $Header$
 *
 * @index | ERROBJ
 ***************************************************************************/

// This is a workaround for compilers that don't support namespaces.

// this file can be included multiple times
// it's OK to have using statements over and over again

#ifndef UNIX

#ifdef _STRING_
using std::string;
using std::wstring;
#endif

#ifdef _VECTOR_
using std::vector;
using std::allocator;
#endif

#ifdef _MAP_
using std::map;
using std::less;
#endif

#ifdef _DEQUE_
using std::deque;
#endif

#ifdef _STACK_
using std::stack;
#endif

#ifdef _LIST_
using std::list;
#endif

#endif // UNIX

