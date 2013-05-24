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

#ifndef __ACCOUNTBATCHHELPER_H__
#define __ACCOUNTBATCHHELPER_H__
#pragma once

#include <mtbatchhelper.h>


/////////////////////////////////////////////////////////////////////////////////////
// Batch helper class for transactions
/////////////////////////////////////////////////////////////////////////////////////


template<class T>
class MTAccountBatchHelper : public MTBatchHelper
{
public:
  MTAccountBatchHelper() {}
  void Init(CComPtr<IObjectContext>& objContext,
    T& ControllerClass,
    IMTSessionContext* aSessionContext = NULL) 
  {
    mObjContext = objContext;
    mControllerClass = ControllerClass;
    mSessionContext = aSessionContext;
  }
  virtual ~MTAccountBatchHelper() {}

  virtual ROWSETLib::IMTRowSetPtr PerformBatchOperation(IMTCollection* pCol,IMTProgress* pProgress);
protected:
  CComPtr<IObjectContext> mObjContext;
  CComPtr<IMTSessionContext> mSessionContext;
  T mControllerClass;
};


template<class T>
ROWSETLib::IMTRowSetPtr MTAccountBatchHelper<T>::PerformBatchOperation(IMTCollection* pCol,IMTProgress* pProgress)
{
	MTAutoContext ctx(mObjContext);
  ROWSETLib::IMTRowSetPtr errorRs = MTBatchHelper::PerformBatchOperation(pCol,pProgress);

  if(errorRs->GetRecordCount() == 0) {
    ctx.Complete();
  }
  return errorRs;
}



#endif //__ACCOUNTBATCHHELPER_H__