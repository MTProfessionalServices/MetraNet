/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include <comsvcs.h>
#include <comdef.h>
#include <mtparamnames.h>
#include <mtprogids.h>

#include <MTObjectCollection.h>
#include <mtcomerr.h>
#include <MTUtil.h>
#include <mtglobal_msg.h>
#include <mtautocontext.h>
#include <MTTypeConvert.h>
#include <MTProductCatalog.h>
#include <RowsetDefs.h>
#include <PropertiesBase.h>


#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 
#import <GenericCollection.tlb> 
#import <AuditEventsLib.tlb> 
#import <Counter.tlb> rename ("EOF", "RowsetEOF")
#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalogExec.tlb> rename ("EOF", "RowsetEOF")
#import <Counter.tlb> rename("EOF", "RowsetEOF")
#import <RCD.tlb>
#import <MSXML3.dll>
#import <MTYAAC.tlb> rename ("EOF", "RowsetEOF") 


