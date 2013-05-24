/**************************************************************************
 * @doc TEST
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
 * Created by: Carl Shimer
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef __ADSIUTIL_H__
#define __ADSIUTIL_H__
#include <metra.h>
#pragma warning(disable: 4192 4196)
#pragma warning(disable: 4196)
#import <activeds.tlb> exclude("_LARGE_INTEGER") exclude("_GUID") rename ("_LARGE_INTEGER","_ACTIVEDS_LARGE_INTEGER") \
rename ("GetObject","ADSGetObject") \
inject_statement("#pragma warning(disable: 4196)") inject_statement("struct _ACTIVEDS_LARGE_INTEGER {struct { DWORD LowPart; LONG  HighPart; };LONGLONG QuadPart; }  ;") 
#import <adsiis.dll>
#import <iisext.dll>

#include <iiscnfg.h>
#include <iads.h>
#include <adshlp.h>

#include <string>



class MTVdir {
public:
  MTVdir() : m_bInitADSI(false), m_Hr(S_OK) {}

  bool InitADSI(LPCSTR pPath);

  LONG CreateIISVdir(const std::string& lpszVdir, std::string& lpszPath);
	LONG DeleteIISVdir(const std::string& lpszVdir);
  LONG SetIISVdirPerms(const std::string& lpszVdir, LONG pSecParams);
  LONG GetVdirPhysicalPath (const std::string& lpszVdir, std::string& lpszPath) ;
	LONG SetBasicAuth(const std::string& lpszVdir);

protected: // data

  HRESULT                     m_Hr;
	_variant_t                  m_variant;			// Variant used to set some properties in the metabase
	ActiveDs::IADsContainerPtr	m_virtDirRoot;	// Virtual root
	ActiveDs::IADsPtr			m_virtDir;			// The new virtual directory
  IISExt::IISApp*             m_pIISApp;
  IID                         m_IId_IISApp;
	IID													m_IID_IADsContainer;
  bool                        m_bInitADSI;

};

#endif //__ADSIUTIL_H__