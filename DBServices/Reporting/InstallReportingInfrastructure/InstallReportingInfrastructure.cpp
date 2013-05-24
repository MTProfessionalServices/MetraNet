/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Kevin Fitzgerald 
* $Header$
* 
***************************************************************************/

// ----------------------------------------------------------------
// Name:        InstallReportingInfrastructure
// Usage:       InstallReportingInfrastructure 
// Arguments:   N/A
// Description: Installs the reporting infrastructure by first
//              creating a reporting view, adding it, and then 
//              creating contact info table in the database.
// ----------------------------------------------------------------


#include <mtcom.h>
#include <comdef.h>
#include <iostream>
#include <mtparamnames.h>
#include <mtprogids.h>

// import the usage server tlb ...
#import <ReportingInfo.tlb> 
using namespace REPORTINGINFOLib ;

using std::cout;
using std::endl;
using std::hex;

int main ()
{
  // initialize COM ...
  ComInitialize comInit ;

  // start the try ...
	try
  {
    // create the reporting view ...
    REPORTINGINFOLib::IMTReportingViewPtr reportingView(MTPROGID_REPORTINGVIEW);

    // add the reporting view ...
    reportingView->Add() ;
 
  }
  catch (_com_error e)
  {
    cout << "Unable to install reporting infrastructure. Error = " << hex << e.Error() << endl ;
    _bstr_t errMsg = e.Description() ;
    cout << "Error Description: " << (char*) errMsg << endl ;
    return 1 ;
  }

  return 0 ;
}

