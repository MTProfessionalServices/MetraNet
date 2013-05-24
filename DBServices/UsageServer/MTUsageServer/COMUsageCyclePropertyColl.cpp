// COMUsageCyclePropertyColl.cpp : Implementation of CCOMUsageCyclePropertyColl
#include "StdAfx.h"
#include "MTUsageServer.h"
#include "COMUsageCyclePropertyColl.h"
#include <loggerconfig.h>
#include <stdutils.h>

using std::map;
using std::wstring;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCyclePropertyColl
CCOMUsageCyclePropertyColl::CCOMUsageCyclePropertyColl()
{
  LoggerConfigReader cfgRdr ;

  // initialize the logger ...
  mLogger.Init (cfgRdr.ReadConfiguration("UsageServer"), "[UsageCyclePropertyColl]") ;
}

CCOMUsageCyclePropertyColl::~CCOMUsageCyclePropertyColl()
{
  // free the list ...
  mPropColl.clear() ;
}

STDMETHODIMP CCOMUsageCyclePropertyColl::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_ICOMUsageCyclePropertyColl
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	AddProperty
// Arguments:     aName - the name of the usage cycle property 
//                aValue - the value of the usage cycle property
// Return Value:  
// Errors Raised: 
// Description:   The AddProperty method adds a usage cyle property
//  of the specified name and value.
// ----------------------------------------------------------------
STDMETHODIMP CCOMUsageCyclePropertyColl::AddProperty(BSTR aName, VARIANT aValue)
{
  wstring wstrName (aName) ;

  // validate the properties ...
  if (wstrName.length() == 0)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddProperty() failed. No property name specified.") ;
    return Error ("AddProperty() failed. No property name specified.") ;
  }
  if (aValue.vt == VT_NULL)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddProperty() failed. No value specified for property name = %s.", 
      ascii(wstrName).c_str()) ;
    return Error ("AddProperty() failed. No value specified.") ;
  }    

  // find the property in the map ...
	StrToLower(wstrName);
  BOOL bRetCode = mPropColl.count (wstrName) > 0;

  // if the property wasnt found ... raise an error ...
  if (bRetCode == FALSE)
  {
    // add the property to the map ...
    mPropColl[wstrName] = aValue;
  }
  else
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "AddProperty() failed. Duplicate property name found = %s.", 
      ascii(wstrName).c_str()) ;
    return Error ("AddProperty() failed. Duplicate property name found.") ;
  }

  return (S_OK) ;
}

// ----------------------------------------------------------------
// Name:     	GetProperty
// Arguments:     aName - the name of the usage cycle property 
//                aValue - the value of the usage cycle property
// Return Value:  
// Errors Raised: 
// Description:   The GetProperty method gets the specified usage 
//  cyle property from the collection.
// ----------------------------------------------------------------
STDMETHODIMP CCOMUsageCyclePropertyColl::GetProperty(BSTR aName, VARIANT *apValue)
{
  wstring wstrName (aName) ;
  _variant_t vtValue ;
  BOOL bRetCode=TRUE ;

  // validate the property name...
  if (wstrName.length() == 0)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "GetProperty() failed. No property name specified.") ;
    return Error ("GetProperty() failed. No property name specified.") ;
  }
  // find the property in the map ...
  StrToLower(wstrName);


	UsageCyclePropColl::iterator it = mPropColl.find(wstrName);
  // if the property wasnt found ... raise an error ...
	if (it == mPropColl.end())
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "GetProperty() failed. Property name not found. Name = %s.", 
      ascii(wstrName).c_str()) ;
    return Error ("GetProperty() failed. Property name not found.") ;
  }

	vtValue = it->second;
  *apValue = vtValue.Detach() ;

  return (S_OK) ;
}

// ----------------------------------------------------------------
// Name:     	ModifyProperty
// Arguments:     aName - the name of the usage cycle property 
//                aValue - the value of the usage cycle property
// Return Value:  
// Errors Raised: 
// Description:   The ModifyProperty method modifies the specified 
//  usage cyle property.
// ----------------------------------------------------------------
STDMETHODIMP CCOMUsageCyclePropertyColl::ModifyProperty(BSTR aName, VARIANT aValue)
{
  wstring wstrName (aName) ;

  // validate the properties ...
  if (wstrName.length() == 0)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "ModifyProperty() failed. No property name specified.") ;
    return Error ("ModifyProperty() failed. No property name specified.") ;
  }
  if (aValue.vt == VT_NULL)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "ModifyProperty() failed. No value specified for property name = %s.", 
      ascii(wstrName).c_str()) ;
    return Error ("ModifyProperty() failed. No value specified.") ;
  }    

  // find the property in the map ...
  StrToLower(wstrName) ;
  BOOL bRetCode = mPropColl.count (wstrName) > 0;

  // if the property wasnt found ... raise an error ...
  if (bRetCode == FALSE)
  {
    mLogger.LogVarArgs (LOG_ERROR, 
      "ModifyProperty() failed. Property name not found. Name = %s.", 
      ascii(wstrName).c_str()) ;
    return Error ("ModifyProperty() failed. Property name not found.") ;
  }
  else
  {
    // remove the property ...
    mPropColl.erase (wstrName) ;

    // add the property to the map ...
    mPropColl[wstrName] = aValue;
  }

  return (S_OK) ;
}
