/**************************************************************************
 * namedpipe
 *
 * Copyright 1997-2000 by MetraTech Corp.
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
 * Created by: Boris Partensky
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __NAMEDPIPE_H_
#define __NAMEDPIPE_H_

#include <string>

using namespace std;

class NamedPipeServer
{
  private:
    HANDLE mhPipe;
    string mPipeName;
    int mTimeout;
  public:
    NamedPipeServer(const char* aPipeName);
    NamedPipeServer(const char* aPipeName, int aTimeout);
    virtual ~NamedPipeServer();
    bool CreateAndWaitForConnection();
    bool WritePipe(const char* pStr);
};

class NamedPipeClient
{
  private:
    HANDLE mhPipe;
    string mPipeName;
    DWORD mRead;
    bool mFirstRead;
  public:
    NamedPipeClient(const char* aPipeName);
    virtual ~NamedPipeClient();
    bool Connect();
    bool ReadPipe(string& buf);
};




#endif