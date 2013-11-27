/**************************************************************************
 * @doc TEST
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
 * $Header$
 ***************************************************************************/

#include <iostream>
#include <mtcom.h>
#include "test.h"
#include <mtprogids.h>

using std::cout;
using std::endl;

static ComInitialize gComInitialize;
const char* filename = "tariffs\\Alltariffs.xml";
const char* outfilename = "test\\modulereader\\out.xml";

void MTGetHostName(char buff[],int size)
{
	WSADATA data;
	::WSAStartup(MAKEWORD(1, 0), &data);
  if(::gethostname(buff,size) != 0) {
    DWORD err;
    err = WSAGetLastError();
  }
  ::WSACleanup();
}

int main()
{
  IMTModulePtr aModule(MTPROGID_MODULE);
  IMTModuleDescriptorPtr aSubModule(MTPROGID_MODDESCRIPT);
  IMTModuleDescriptorPtr newModule(MTPROGID_MODDESCRIPT);
 
  _bstr_t orgtype;
  _bstr_t bsName;

  char Hostname[512];
  memset(Hostname,0,512);

  MTGetHostName(Hostname,512);

  aModule->PutModuleDataFileName(_bstr_t(filename));
 // aModule->PutRemoteHost(_bstr_t(Hostname));
  aModule->Read();

  bsName = "Default";
  IMTModulePtr aSubMod = aModule->GetSubModule(L"Default");

   aSubMod->GetName();


  cout << "module name: " << bsName << endl;

  bsName = "IBM";
  orgtype = "SubDir";
  newModule->PutName(bsName);
  newModule->PutOrgType(orgtype);

  aModule->PutModDescriptor(newModule.GetInterfacePtr());
  aModule->PutModuleDataFileName(outfilename);
  aModule->Write();

  aModule = NULL;
  aSubModule = NULL;
  newModule = NULL;

 return TRUE;
}

