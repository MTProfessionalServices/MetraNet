/**************************************************************************
 *
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
 *
 * Author: Anagha Rangarajan
 * 
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <map>
#include <vector>
#include <mttime.h>
#include <autocritical.h>

/***************************************************************************
 * Typedefs                                                                *
 ***************************************************************************/

typedef enum 
{
  OPERATION_MIN = 0,
  OPERATION_MAX = 1
} OperationType;

struct SourceItem 
{
  _bstr_t SourcePropertyName;
  _bstr_t ServiceDefName;
  long SourcePropertyID;
  long ServiceID;
};

typedef std::vector<SourceItem *> SourceVector;


// generate using uuidgen
CLSID CLSID_SETCOMPOUNDPROP = 
{ /* B41C4531-B1BA-46da-9D6E-D8E6356BA759 */
    0xb41c4531,
    0xb1ba,
    0x46da,
    {0x9d, 0x6e, 0xd8, 0xe6, 0x35, 0x6b, 0xa7, 0x59}
};


#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTSetCompoundProp::PlugInConfigure"

class ATL_NO_VTABLE MTSetCompoundProp
	: public MTPipelinePlugIn<MTSetCompoundProp, &CLSID_SETCOMPOUNDPROP>
{
	protected:
		virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
					MTPipelineLib::IMTConfigPropSetPtr aPropSet,
					MTPipelineLib::IMTNameIDPtr aNameID,
                    MTPipelineLib::IMTSystemContextPtr aSysContext);

		virtual HRESULT PlugInShutdown();

		virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);
	
	protected:
	  HRESULT Recurse(MTPipelineLib::IMTSessionPtr aSession, bool bIsRoot);
		HRESULT RecursiveSetProp(MTPipelineLib::IMTSessionPtr aSession, DATE finalValue);
		void GetSourceValues(MTPipelineLib::IMTSessionPtr aSession);

	
	private:
		MTPipelineLib::IMTLogPtr mLogger;
		long mTargetPropertyID;
		OperationType mOp;
		SourceVector mSourceProperties;
		long mFirstPassCompleted;
		MTPipelineLib::IMTSessionServerPtr mSessionServer;
		DATE finalValue;

	  BOOL mIsOkayToLogDebug;

};


PLUGIN_INFO(CLSID_SETCOMPOUNDPROP, MTSetCompoundProp,
						"MetraPipeline.SetCompoundProp.1", "MetraPipeline.SetCompoundProp", "Free")
