/**************************************************************************
 * @doc BASE64
 *
 * @module |
 *
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
 * Created by: Derek Young
 * $Header$
 *
 * @index | BASE64
 ***************************************************************************/

#ifndef _BASE64_H
#define _BASE64_H

#include <vector>
#include <string> 

using std::string;
using std::vector;

BOOL rfc1421encode(const unsigned char * apSrc, int aSrcLen, string & arDest);
BOOL rfc1421encode_nonewlines(const unsigned char * apSrc, 
                              int aSrcLen, string & arDest);

/* Possible return values */
#define ERROR_NONE       0
#define ERROR_ARGS       1
#define ERROR_EQUAL      2
#define ERROR_INCOMPLETE 3

int rfc1421decode (const char * apSrc, int aSrcLen, 
                   vector<unsigned char> & arDest);

#endif /* _BASE64_H */
