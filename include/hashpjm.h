/**************************************************************************
 * @doc HASHPJM
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
 * @index | HASHPJM
 ***************************************************************************/

#ifndef _HASHPJM_H
#define _HASHPJM_H

//
// hashpjm from the Dragon Book
//
// returns an evenly distributed number based on a sequence of bytes.
// useful for hash tables, etc.
// the second version returns the same value regardless of case.
//

unsigned int HashData(const unsigned char * apUID, int aLen);

unsigned int HashDataCaseInsensitive(const unsigned char * apBytes, int aLen);

#endif /* _HASHPJM_H */
