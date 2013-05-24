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

#ifndef __MTDATAANALYSISVIEWCOLLECTION_H
#define __MTDATAANALYSISVIEWCOLLECTION_H

#include <NTLogger.h>
#include <MTDataAnalysisView.h>
#include <MTUtil.h>
#include <string>
#include <map>

typedef std::map<std::wstring, MTDataAnalysisView *> DataAnalysisViewColl;

class MTDataAnalysisViewColl
{
public:
  DLL_EXPORT MTDataAnalysisViewColl() ;
  DLL_EXPORT ~MTDataAnalysisViewColl() ;

  DLL_EXPORT BOOL Init() ;
  DLL_EXPORT BOOL FindView(const std::wstring &arViewName, MTDataAnalysisView * &arpView) ;
  DLL_EXPORT DataAnalysisViewColl & GetViewList() 
  { return mViewColl; } ;
private:
  void TearDown() ;

  NTLogger              mLogger ;
  DataAnalysisViewColl  mViewColl ;
} ;

#endif
