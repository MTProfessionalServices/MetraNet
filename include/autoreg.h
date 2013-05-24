/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Carl Shimer
 * $Header$
 *
 *	
 * 
 *
 ***************************************************************************/


#ifndef __AUTOREG_H_
#define __AUTOREG_H_

#include <NTRegistryIO.h>

class MTAutoReg {

public:
    MTAutoReg(TCHAR* aSubKey) : m_RegIO()
    {
        bOpen = m_RegIO.OpenRegistryRaw(NTRegistryIO::LOCAL_MACHINE,aSubKey,RegistryIO::WRITE_ACCESS);
    }

    virtual ~MTAutoReg() {}
    // BOOL GetValue(TCHAR* aName,long& aValue);
    BOOL GetString(TCHAR* aName,_TUCHAR* aStr,unsigned long& aLen)
    {
        return TRUE;
        return (bOpen) ? m_RegIO.ReadRegistryValue(aName,RegistryIO::STRING,aStr,aLen) : bOpen;
    }
    BOOL WriteString(TCHAR* aName,_TUCHAR* aStr)
    {
        unsigned long len = _tcslen((const _TCHAR*)aStr);
        return TRUE;
       return (bOpen) ? m_RegIO.WriteRegistryValue(aName,RegistryIO::STRING,aStr,len) : bOpen;
    }

protected:
    BOOL bOpen;
    NTRegistryIO m_RegIO;
};



#endif // __AUTOREG_H_