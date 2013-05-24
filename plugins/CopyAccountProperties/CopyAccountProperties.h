/**************************************************************************
 * Copyright 2002 by MetraTech Corporation
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
 ***************************************************************************/

/***************************************************************************
 * CopyAccountProperties.h                                                 *
 * Header for CopyAccountProperties.cpp -- Plugin for copying properties   *
 *                                         from one account or template    *
 *                                         to another account.             *
 ***************************************************************************/
#include <TransactionPlugInSkeleton.h>
#include <mtprogids.h>
#include <vector>
#include <map>


#import <MTAccount.tlb> rename ("EOF", "RowsetEOF") //no_function_mapping

using namespace std;
//using namespace MTACCOUNTLib;
/***************************************************************************
 * UUID -- 36ac1c62-b9cd-4c7d-9505-cafffc6e6aea                            *
 ***************************************************************************/
CLSID CLSID_MTCOPYACCOUNTPROPERTIES = {
  0x36ac1c62,
  0xb9cd,
  0x4c7d,
  {0x95, 0x05, 0xca, 0xff, 0xfc, 0x6e, 0x6a, 0xea}
};
/***************************************************************************/


/***************************************************************************
 * Typedefs                                                                *
 ***************************************************************************/

typedef enum {
  COPY_PROP_TYPE_SESSION = 0,
  COPY_PROP_TYPE_EXTENSION = 1,
  COPY_PROP_TYPE_TEMPLATE = 2
} CopyPropType;

struct MTCopyProperty {
  CopyPropType PropType;
  _bstr_t SourceProperty;
  _bstr_t SourceExtension;
  _bstr_t DestinationProperty;
  _bstr_t DestinationExtension;
  bool Required;
  bool PartOfKey;
};

typedef vector<MTCopyProperty *> MTPropertyNameVector;
typedef map<_bstr_t, _bstr_t> MTExtensionNameMap;
typedef map<_bstr_t, MTPipelineLib::MTSessionPropType> MTSessionPropTypeMap;
  
/***************************************************************************
 * Plugin class                                                            *
 ***************************************************************************/
class ATL_NO_VTABLE CMTCopyAccountPropertiesPlugin : public MTTransactionPlugIn<CMTCopyAccountPropertiesPlugin, &CLSID_MTCOPYACCOUNTPROPERTIES>
{
public:
  CMTCopyAccountPropertiesPlugin() :
      mlngSourcePropID(-1),
      mlngDestinationPropID(-1)
  {
  }

protected:
  virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
                                  MTPipelineLib::IMTConfigPropSetPtr aPropSet,
                                  MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

  virtual HRESULT PlugInShutdown();

  virtual HRESULT PlugInProcessSessionWithTransaction(MTPipelineLib::IMTSessionPtr aSession,
                                                      MTPipelineLib::IMTSQLRowsetPtr aTransactionRS);
  
private:
  long mlngSourcePropID;                          /* Property containing the ID of the source */
  long mlngDestinationPropID;                     /* Property containing the ID of the target */
  MTPropertyNameVector mCopyProperties;           /* Properties to copy       */
  MTExtensionNameMap mDestExtensions;             /* Map of source extension names */
  MTSessionPropTypeMap mSessionPropTypes;         /* Map of types of session properties */

	
  MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
	MTPipelineLib::IMTSystemContextPtr mSysContext;
};
//----- This object has been replaced by a batch version, now using the name: MetraPipeline.MTCopyAccountProperties
PLUGIN_INFO(CLSID_MTCOPYACCOUNTPROPERTIES,
            CMTCopyAccountPropertiesPlugin,
            "XXX_depricated_MetraPipeline.MTCopyAccountProperties.1",
            "XXX_depricated_MetraPipeline.MTCoypAccountProperties",
            "Free")

  

