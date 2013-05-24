/**************************************************************************
 * @doc 
 * 
 * @module  |
 * 
 * This class encapsulates.
 * 
 * Copyright 2000 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | 
 ***************************************************************************/

#ifndef __MTDATAANALYSISVIEW_H
#define __MTDATAANALYSISVIEW_H

#include <errobj.h>
#include <NTLogger.h>
#include <MTUtil.h>
#include <MSIXProperties.h>

#include <string>
#include <map>
using std::string;
using std::map;

// definitions ...
const wchar_t DATAANALYSIS_CONFIGDIR[] = L"\\Queries\\DataAnalysisView" ;
const wchar_t DATA_ANALYSIS_FILE[] = L"DataAnalysisView.xml";

// forward declaration 
class MTDataAnalysisViewProp ;

typedef map<wstring, MTDataAnalysisViewProp *> DataAnalysisViewPropColl;

class MTDataAnalysisView
{
public:
  DLL_EXPORT MTDataAnalysisView() ;
  DLL_EXPORT ~MTDataAnalysisView() ;

  DLL_EXPORT BOOL Init(const std::wstring &arConfigFile) ;
  DLL_EXPORT DataAnalysisViewPropColl & GetPropertyList() 
  { return mViewPropColl; } ;
  DLL_EXPORT BOOL FindProperty(const std::wstring &arName, 
    MTDataAnalysisViewProp * & arpProp) ;
  DLL_EXPORT std::wstring & GetQueryTag()
  { return mQueryTag ; };
  DLL_EXPORT std::wstring & GetName()
  { return mViewName ; };
  DLL_EXPORT std::wstring & GetConfigPath()
  { return mConfigPath ; };
private:
  void TearDown() ;

  NTLogger              mLogger ;
  std::wstring             mQueryTag ;
  std::wstring             mViewName ;
  std::wstring             mConfigPath ;
  DataAnalysisViewPropColl  mViewPropColl ;
} ;


class MTDataAnalysisViewProp : public virtual ObjectWithError
{
public:
  MTDataAnalysisViewProp() {} ;
  ~MTDataAnalysisViewProp() {} ;

  DLL_EXPORT void Init (const _bstr_t &arName, const _bstr_t &arColumnName, 
    const _bstr_t &arType, const _bstr_t &arEnumNamespace, const _bstr_t &arEnumEnumeration, 
    const _bstr_t &arFilterableFlag) ;
  DLL_EXPORT std::wstring & GetName()
  { return mName; };
  DLL_EXPORT std::wstring & GetType()
  { return mType ; } ;

  //gets the MSIX type of the property
  DLL_EXPORT CMSIXProperties::PropertyType GetMSIXType() const
	{ return mMSIXType ; } ;

  DLL_EXPORT std::wstring & GetColumnName()
  { return mColumnName ;} ;
  DLL_EXPORT std::wstring & GetEnumNamespace()
  { return mEnumNamespace ; } ;
  DLL_EXPORT std::wstring & GetEnumEnumeration()
  { return mEnumEnumeration ; } ;
  DLL_EXPORT BOOL GetFilterableFlag() const
  { return mFilterableFlag ; } ;
private:
  std::wstring mName ;
  std::wstring mType ;
  CMSIXProperties::PropertyType mMSIXType;
  std::wstring mColumnName ;
  std::wstring mEnumNamespace;
  std::wstring mEnumEnumeration;
  VARIANT_BOOL      mFilterableFlag ;
} ;

#endif
