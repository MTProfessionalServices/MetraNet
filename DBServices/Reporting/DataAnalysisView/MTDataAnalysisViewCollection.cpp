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

#include <metra.h>
#include <MTDataAnalysisViewCollection.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#import <RCD.tlb>
#include <SetIterate.h>
#include <RcdHelper.h>
#include <stdutils.h>


// import the config loader ...
#import <MTCLoader.tlb>
using namespace CONFIGLOADERLib;

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
MTDataAnalysisViewColl::MTDataAnalysisViewColl()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("Database"), "[Data Analysis View]") ;
}

//
//	@mfunc
//	Destructor. 
//  @rdesc 
//  No return value
//
MTDataAnalysisViewColl::~MTDataAnalysisViewColl()
{
  TearDown() ;
}

void MTDataAnalysisViewColl::TearDown()
{
  // delete all the allocate memory ...
  DataAnalysisViewColl::iterator it;
  for (it = mViewColl.begin(); it != mViewColl.end(); it++)
    delete it->second;

  mViewColl.clear();
}

//
//	@mfunc
//	Initialize the view collection
//  @rdesc 
//  No return value
//
BOOL MTDataAnalysisViewColl::Init()
{
  // local variables
  MTDataAnalysisView *pView=NULL ;
  BOOL bRetCode=TRUE ;

  // call TearDown()
  TearDown() ;

  try
  {
		// create an instance of the RCD
		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery("config\\dataAnalysisView\\*.xml",VARIANT_TRUE);

		if(aFileList->GetCount() == 0) 
    {
			// log error that we can't find any configuration
			const char* pErrorMsg = "MTDataAnalysisViewColl::Init: can not find any configuration files";
			mLogger.LogThis(LOG_INFO,pErrorMsg);
			return TRUE;
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) return E_FAIL;

		while(TRUE) {

			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) {
				break;
			}

			// create a new MTDataAnalysisView object ...
			pView = new MTDataAnalysisView ;
			ASSERT (pView) ;
			if (pView == NULL)
			{
				mLogger.LogVarArgs (LOG_ERROR, 
					"Unable to create MTDataAnalysisView object. Error = %x", ::GetLastError() ) ;
				return FALSE ;
			}
    
			// initialize the summary view object ...
			bRetCode = pView->Init((const wchar_t*)afile) ;
			if (bRetCode == FALSE)
			{
				mLogger.LogVarArgs(LOG_ERROR, 
					"Unable to initialize MTDataAnalysisView.") ;
				delete pView ;
				return FALSE ;
			}

			// insert it into the list ...
			mViewColl[pView->GetName()] = pView;
		}

  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Error encountered while reading DataAnalysis file. Error = %x",
      e.Error()) ;
    _bstr_t errMsg = e.Description() ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Error message: %s.", (char*) errMsg) ;
    return FALSE ;
  }
  return TRUE ;
}


//
//	@mfunc
//	Find the associated service in the MTDataAnalysisViewColl
//  @parm The view id to find
//  @parm The pointer to the MTDataAnalysisView object
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned
//
BOOL MTDataAnalysisViewColl::FindView (const wstring &arViewName, MTDataAnalysisView * & arpView)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  wstring viewName=arViewName ;
  
  // null out the view ptr ...
  arpView = NULL ;
  
  // find the element ...
  StrToLower(viewName);
	DataAnalysisViewColl::iterator findIt;
	findIt =  mViewColl.find(viewName);
  if (findIt == mViewColl.end())
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to find data analysis view with name = %s.", ascii(arViewName).c_str()) ;
    bRetCode = FALSE ;
  }

	arpView = findIt->second;
   
  return bRetCode ;
}
