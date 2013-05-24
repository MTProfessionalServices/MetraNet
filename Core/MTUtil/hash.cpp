/**************************************************************************
 * @doc HASH
 *
 * Copyright 1999 by MetraTech Corporation
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
 ***************************************************************************/

int HashBytes(const unsigned char * apBytes, int aLen)
{
	// hashpjm from the Dragon Book
	unsigned h = 0, g;
	for (int i = 0; i < aLen; i++)
	{
		h = (h << 4) + apBytes[i];
		if (g = h & 0xF0000000)
		{
			h = h ^ (g >> 24);
			h = h ^ g;
		}
	}
	//return h % UID_BUCKETS;
	// NOTE: mod h by the number of buckets in your hash table
	return h;
}
