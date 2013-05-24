/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "IMTProgress.h"
#include "GenericCollectionInterfaces.h"
#include "rowsetinterfaces.h"

#import <GenericCollection.tlb>
#import <MTProgressExec.tlb>
#include <adoutil.h>
#include <AccHierarchiesShared.h>

#ifndef __MTBATCHHELPER_H__
#define __MTBATCHHELPER_H__
#pragma once

/////////////////////////////////////////////////////////////////////////////////////
// generic batch helper class
/////////////////////////////////////////////////////////////////////////////////////

class MTBatchHelper {
public:
  MTBatchHelper() {}
  virtual ~MTBatchHelper() {}

  virtual HRESULT PerformSingleOp(long aIndex,long& FailedAccount) = 0;
  virtual ROWSETLib::IMTRowSetPtr PerformBatchOperation(IMTCollection* pCol,IMTProgress* pProgress);

protected: // methods
  void ResolveAccountNames();
protected: // data
  GENERICCOLLECTIONLib::IMTCollectionPtr mColPtr;
  MTPROGRESSEXECLib::IMTProgressPtr mProgressPtr;
public:
  ROWSETLib::IMTSQLRowsetPtr errorRs;
};





#endif //__MTBATCHHELPER_H__