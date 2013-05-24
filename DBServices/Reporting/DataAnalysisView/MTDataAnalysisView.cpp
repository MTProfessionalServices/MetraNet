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
#include <MTDataAnalysisView.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <SharedDefs.h>

// import the config loader ...
#import <MTConfigLib.tlb>

//
//	@mfunc
//	Constructor. Initialize the appropriate data members.
//  @rdesc 
//  No return value
//
MTDataAnalysisView::MTDataAnalysisView()
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
MTDataAnalysisView::~MTDataAnalysisView()
{
  TearDown() ;
}

void MTDataAnalysisView::TearDown()
{
  // delete all the allocate memory ...
  DataAnalysisViewPropColl::iterator it;
	for (it = mViewPropColl.begin(); it != mViewPropColl.end(); it++)
    delete it->second;

  mViewPropColl.clear();
}

//
//	@mfunc
//	Initialize the view collection
//  @rdesc 
//  No return value
//
BOOL MTDataAnalysisView::Init(const wstring &arConfigFile)
{
  // local variables
  MTDataAnalysisViewProp *pViewProp=NULL ;
  wstring wstrDirName, lowercaseStr ;
  _bstr_t name, columnName, type, filterableFlag ;
  _bstr_t enumNamespace, enumEnumeration ;
  _bstr_t viewName, queryTag ;

  // call TearDown() ...
  TearDown() ;

  // get the directory name and file from the config file ...
  wstrDirName = arConfigFile ;
  lowercaseStr = wstrDirName;
  StrToLower(lowercaseStr);
  //int pos = wstrDirName.index (L"dataAnalysisView", RWWString::ignoreCase) ;
  unsigned int pos;
  pos = lowercaseStr.find(L"dataanalysisview", 0);
  if (pos != string::npos)
  {
	int length = wstrDirName.length() ;
	wstrDirName.erase (pos, length) ;
  }

  mConfigPath = wstrDirName ;
  mConfigPath += L"\\Queries\\dataAnalysisView" ;

  // create the config loader to read the xml file ...
  try
  {

		VARIANT_BOOL aChecksumsMatch;
    MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);
		MTConfigLib::IMTConfigPropSetPtr confSet = aConfig->ReadConfiguration((const wchar_t*)arConfigFile.c_str(),&aChecksumsMatch);

    // get the query tag ...
    viewName = confSet->NextStringWithName("view_name") ;
    queryTag = confSet->NextStringWithName("query_tag") ;
    
    // copy the view name and query tag to data members ...
    mViewName = viewName ;
    mQueryTag = queryTag ;
    StrToLower(mViewName);

    // get all the properties ...
    MTConfigLib::IMTConfigPropSetPtr subset ;
    while (((subset = confSet->NextSetWithName("property")) != NULL))
    {
      // read in the current properties data ...
      name = subset->NextStringWithName("name") ;
      columnName = subset->NextStringWithName("column_name") ;
      MTConfigLib::IMTConfigPropPtr typeItem = subset->NextWithName("type") ;

      type = typeItem->GetPropValue() ;
      wstring wstrType(type) ;
      if (_wcsicmp(wstrType.c_str(), DB_ENUM_TYPE) == 0)
      {
        enumNamespace = typeItem->GetAttribSet()->GetAttrValue("Namespace");
        enumEnumeration = typeItem->GetAttribSet()->GetAttrValue("Enum");
      }
      else
      {
        enumNamespace = " " ;
        enumEnumeration = " " ;
      }
      try
      {
        filterableFlag = subset->NextStringWithName("filterable") ;
      }
      catch (_com_error)
      {
        filterableFlag = "Y" ;
      }
      // create a new MTDataAnalysisViewProp ...
      pViewProp = new MTDataAnalysisViewProp ;
      ASSERT (pViewProp) ;
      if (pViewProp == NULL)
      {
        mLogger.LogVarArgs (LOG_ERROR, 
          "Unable to create MTDataAnalysisViewProp object. Error = %x", ::GetLastError() ) ;
        return FALSE ;
      }
      
      // initialize the summary view object ...
      pViewProp->Init(name, columnName, type, enumNamespace, 
        enumEnumeration, filterableFlag) ;

      // insert the property into the collection ...
      mViewPropColl[pViewProp->GetName()] = pViewProp;
      pViewProp = NULL ;
    }
  }
  catch (_com_error e)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Error encountered while reading DataAnalysis file %s. Error = %x",
      ascii(arConfigFile).c_str(), e.Error()) ;
    _bstr_t errMsg = e.Description() ;
    mLogger.LogVarArgs (LOG_ERROR, 
      "Error message: %s.", (char*) errMsg) ;
    return FALSE ;
  }
  return TRUE ;
}

BOOL MTDataAnalysisView::FindProperty(const wstring &arName, 
                                      MTDataAnalysisViewProp * & arpProp)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  
  // null out the view ptr ...
  arpProp = NULL ;
  
  // find the element ...
	DataAnalysisViewPropColl::iterator findIt;
	findIt = mViewPropColl.find(arName);
  if (findIt == mViewPropColl.end())
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "Unable to find property with name = %s in view with name %s.", 
      ascii(arName).c_str(), ascii(mViewName).c_str()) ;
    return FALSE;
  }

  arpProp = findIt->second;
   
  return bRetCode ;
}



void MTDataAnalysisViewProp::Init (const _bstr_t &arName, 
																	 const _bstr_t &arColumnName, const _bstr_t &arType, 
																	 const _bstr_t &arEnumNamespace, const _bstr_t &arEnumEnumeration,
																	 const _bstr_t &arFilterableFlag)
{
  mName = arName ;
  mType = arType ;
  mColumnName = arColumnName ;
  mEnumNamespace = arEnumNamespace ;
  mEnumEnumeration = arEnumEnumeration ;
  wstring filterable = arFilterableFlag ;
 
  if (_wcsicmp(filterable.c_str(), L"N") == 0)
  {
    mFilterableFlag = VARIANT_FALSE ;
  }
  else
  {
    mFilterableFlag = VARIANT_TRUE ;
  }

	//converts the string type to the proper MSIX enumeration type
	//(taken from MSIXDefinition.cpp)
	if (0 == _wcsicmp(mType.c_str(), W_PTYPE_STRING_STR))
		mMSIXType = CMSIXProperties::TYPE_STRING;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_WSTRING_STR))
		mMSIXType = CMSIXProperties::TYPE_WIDESTRING;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_INT32_STR))
		mMSIXType = CMSIXProperties::TYPE_INT32;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_INT64_STR))
		mMSIXType = CMSIXProperties::TYPE_INT64;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_TIMESTAMP_STR))
		mMSIXType = CMSIXProperties::TYPE_TIMESTAMP;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_FLOAT_STR))
		mMSIXType = CMSIXProperties::TYPE_DOUBLE;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_DOUBLE_STR)) 
		mMSIXType = CMSIXProperties::TYPE_DOUBLE;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_BOOLEAN_STR)) 
		mMSIXType = CMSIXProperties::TYPE_BOOLEAN;
	else if (0 == _wcsicmp(mType.c_str(), W_PTYPE_ENUM_STR))
		mMSIXType = CMSIXProperties::TYPE_ENUM;
	else
	{
		SetError(FALSE, ERROR_MODULE, ERROR_LINE,
						 "MTDataAnalysisViewProp::Init", "Unknown data type in DataAnalysisView file");
		return;
	}


  return ;
}



