/**************************************************************************
 * @doc
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
 * Created by: Carl Shimer
 *
 * This module provides a number of exported function for use by 
 * InstallShield
 *
 * $Date$
 * $Author$
 * $Revision$
 */
#define UNICODE
#define _UNICODE

#include <metra.h>
#include <mtcom.h>
#include <installutil.h>
#include <lmerr.h>
#include <lmcons.h>
#include <lmserver.h>
#include <lmapibuf.h>
#include <stdlib.h>


//////////////////////////////////////////////////////////////////
// GetListOfSQLServers
//
// Query to OS for a list of SQL servers in the domain.
//
// lpszValue: pointer to a string that will contain a space delimited
// list of SQL servers.
//
// len: the lenght of lpszValue
//
// lpIValue: The number of SQL servers available
//
// return value: The number of names contained in lpszvalue.  If
// the return value and lpIvalue don't match, the function did not
// return all of the servers available.
//////////////////////////////////////////////////////////////////

LONG InstCallConvention GetListOfSQLServers(LPSTR lpszValue,DWORD len,LPLONG lpIValue)
{
    ASSERT(lpszValue != NULL && len > 0 && lpIValue != NULL);

    SERVER_INFO_100* pInfoList;
    DWORD entriesRead,entriesAvailable;
    unsigned int counter(0);

    *lpIValue = 0;


    // step 1: query NT for the list of SQL servers

    DWORD retval = NetServerEnum(NULL,  // the local machine
                    100,                // use SERVER_INFO_100 structures
                    (unsigned char**)&pInfoList,
                    MAX_PREFERRED_LENGTH,                // allocate only as much as we can use
                    &entriesRead,
                    &entriesAvailable,
                    SV_TYPE_SQLSERVER,
                    NULL,               // use the current domain
                    0);
    if(retval != NERR_Success) {
        retval = 0;
    }
    else {
        *lpIValue = entriesAvailable;

        // step 2: nuke string.  We aren't using TCHAR's because we will be
        // talking to installshield
        strcat(lpszValue,"");

        // set the number of servers to 0
        retval = 0;

        for(unsigned int i=0,j=0;
            i<entriesRead && j < len;
            i++) {
                ASSERT(pInfoList[i].sv100_name != NULL);

                counter = wcslen((const wchar_t *)pInfoList[i].sv100_name);

                if(counter + j > len) {
                    // not enough space left
                    break;
                }

                wcstombs(&lpszValue[j],(const wchar_t *)pInfoList[i].sv100_name,
                        len - j); // number of bytes left
 
                j += counter;
                retval++;

                if(j +1 < len)
                    strcat(&lpszValue[j++]," ");
            }
    }
    // increment retval so it is the end of the array
    retval++;

    NetApiBufferFree(pInfoList);
    return retval+1;
}
