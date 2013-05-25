/**************************************************************************
 * CMTPathRegEx
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

#include <StdAfx.h>
#include <namedpipe.h>


NamedPipeServer::NamedPipeServer(const char* aPipe) : mTimeout(200)
{
	mhPipe = INVALID_HANDLE_VALUE;
  mPipeName = aPipe;
}

NamedPipeServer::NamedPipeServer(const char* aPipe, int aTimeout)
{
	mhPipe = INVALID_HANDLE_VALUE;
  mPipeName = aPipe;
  mTimeout = aTimeout;
}


NamedPipeServer::~NamedPipeServer()
{
  if (mhPipe != INVALID_HANDLE_VALUE)
  {
    DisconnectNamedPipe(mhPipe);
  }
  if (mhPipe != INVALID_HANDLE_VALUE)
  {
    CloseHandle(mhPipe);
  }
}


bool NamedPipeServer::CreateAndWaitForConnection()
{
	mhPipe = CreateNamedPipeA(mPipeName.c_str(), PIPE_ACCESS_OUTBOUND, PIPE_TYPE_BYTE | PIPE_WAIT, PIPE_UNLIMITED_INSTANCES, 0, 0, mTimeout, NULL);
  return ConnectNamedPipe(mhPipe, NULL) ? true : false;
}


bool NamedPipeServer::WritePipe(const char* pStr)
{
	DWORD nReaded = 0;
	if (mhPipe == INVALID_HANDLE_VALUE)
		return false;
	char buffer[1024];
  DWORD nWritten = 0;
  DWORD nCount = sprintf(buffer, pStr);
	if (nCount <= 0)
		return false;
	return WriteFile(mhPipe, (BYTE*)buffer, nCount, &nWritten, NULL) != FALSE && nWritten == nCount;
}

NamedPipeClient::NamedPipeClient(const char* aPipe) : mRead(0), mFirstRead(true)
{
	mhPipe = INVALID_HANDLE_VALUE;
  mPipeName = aPipe;
}

NamedPipeClient::~NamedPipeClient()
{
	if (mhPipe != INVALID_HANDLE_VALUE)
		CloseHandle(mhPipe);
}

bool NamedPipeClient::Connect()
{
	mhPipe = CreateFileA(mPipeName.c_str(), GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
  mFirstRead = true;
  return mhPipe != INVALID_HANDLE_VALUE;
}



bool NamedPipeClient::ReadPipe(string& buf)
{
  if(mFirstRead)
    mRead = 0;
  mFirstRead = false;

	char buffer[1024];
	if(ReadFile(mhPipe, buffer, sizeof(buffer)-1, &mRead, NULL) == FALSE)
    return false;
  else
  {
    buffer[mRead] = 0;
    buf = buffer;
  }
	return true;
}

