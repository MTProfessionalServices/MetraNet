/**************************************************************************
 * @doc IPADDRESS
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

#include <MTUtil.h>

// IP address as a string
void EncodeIPAddress(const unsigned char * apIPBytes, std::string & arIP)
{
	char buffer[64];
	sprintf(buffer, "%d.%d.%d.%d",
					(int) apIPBytes[0],
					(int) apIPBytes[1],
					(int) apIPBytes[2],
					(int) apIPBytes[3]);
	arIP = buffer;
}

// convert string back to bytes
BOOL DecodeIPAddress(const char * apIPString, unsigned char * apIPBytes)
{
	int bytes[4];

	int count = sscanf(apIPString, "%d.%d.%d.%d",
										 &bytes[0],
										 &bytes[1],
										 &bytes[2],
										 &bytes[3]);
	if (count != 4)
		return FALSE;

	apIPBytes[0] = (unsigned char) bytes[0];
	apIPBytes[1] = (unsigned char) bytes[1];
	apIPBytes[2] = (unsigned char) bytes[2];
	apIPBytes[3] = (unsigned char) bytes[3];
	return TRUE;
}
