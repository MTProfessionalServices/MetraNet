/**************************************************************************
 * @doc CRC32
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
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | CRC32
 ***************************************************************************/

#ifndef _CRC32_H
#define _CRC32_H

/* Need an unsigned type capable of holding 32 bits; */

typedef unsigned long int UNS_32_BITS;

UNS_32_BITS crc_32_tab[];

inline void UpdateCRC32(unsigned char aByte, unsigned long * apCrc)
{
	*apCrc = crc_32_tab[(*apCrc ^ aByte) & 0xff] ^ (*apCrc >> 8);
}

unsigned long CalculateCRC(unsigned char * apStart, unsigned char * apEnd);

#endif /* _CRC32_H */
