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
//
// Description
// -----------
// The ARPropagation Executant allows session data to be exported in real time
// to an AR system while the sessions are being processed within a stage.
// This COM+ object (executant) works with the ComPlusPlugin to participate
// in the pipeline transaction (the ComPlusPlugin gets called by the stage,
// the ComPlusPlugin instantiates and calls the ARPropagationWriter).
//
// The ARPropagation Executant can be configured to call any AR interface.
// It's main purpose is to export account data, but it can also be used to
// export other data such as sales person, territory, or payment data if
// real-time integration of this data is desired.
//
// Configuration
// -------------
// To configure an executant specify the AR interface and map session properties
// to nodes in an AR Interface xml document.
//
// Example:
// <configdata>
//   <ExecutantProgid>MetraTech.ARPropagationWriter</ExecutantProgid>
//   <ExecutantConfigdata>
//     <Method>CreateOrUpdateAccounts</Method>
//     <ARDocument>CreateOrUpdateAccount.xml</ARDocument>
//     <LanguageCode>de</LanguageCode>
//     <Properties>
//       <Property>
//         <PropertyName>username</PropertyName>
//         <NodeName>ExtAccountID</NodeName>
//         <Type>string</Type>
//       </Property>
//       <Property>
//         <PropertyName>country</PropertyName>
//         <NodeName>Country</NodeName>
//         <Type>enum</Type>
//         <LocalizeValue ptype="BOOLEAN">false</LocalizeValue>
//       </Property>
//     </Properties>
//   </ExecutantConfigdata>
// </configdata>
//
// Method:        AR interface method to call
// ARDocument:    Name of template xml document in the schema required by the A/R interface
//                method. Loaded from extensions\AR\config\AR\MTARInterface
// LanguageCode:  Language to be used to export enum properties in their localized value.
//                Only used if a <LocalizeValue> is true. Leave empty if localization is
//                not needed (to avoid unnecessary loading of locale information)
// PropertyName:  Name of session property to be mapped
// NodeName:      Name of xml document node to map property to
// Type:          Type of session property. Valid values are: string, boolean, decimal,
//                double, datetime, time, boolean, enum
// LocalizeValue: Optional tag, used for properties of type enum. If true: enum will be
//               exported localized to the language specified in LanguageCode.
//               If false or omitted: enum will be exported in language neutral form.
//
//***************************************************************************

#ifndef __ARPROPAGATIONWRITER_H_
#define __ARPROPAGATIONWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>


/////////////////////////////////////////////////////////////////////////////
// CARPropagationWriter
class ATL_NO_VTABLE CARPropagationWriter : 
  public CComObjectRootEx<CComSingleThreadModel>,
  public CComCoClass<CARPropagationWriter, &CLSID_ARPropagationWriter>,
  public ISupportErrorInfo,
  public IObjectControl,
  public IDispatchImpl<IMTPipelineExecutant, &__uuidof(IMTPipelineExecutant), &LIBID_ARPROPAGATIONEXECLib>
{
public:
  CARPropagationWriter()
  {
  }

DECLARE_REGISTRY_RESOURCEID(IDR_ARPROPAGATIONWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CARPropagationWriter)

BEGIN_COM_MAP(CARPropagationWriter)
  COM_INTERFACE_ENTRY(IMTPipelineExecutant)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
  COM_INTERFACE_ENTRY(IObjectControl)
  COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
  STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
  STDMETHOD(Activate)();
  STDMETHOD_(BOOL, CanBePooled)();
  STDMETHOD_(void, Deactivate)();

// IMTPipelineExecutant
public:
  STDMETHOD(Configure)(IDispatch * systemContext, IMTConfigPropSet * propSet, VARIANT * configState);
  STDMETHOD(ProcessSessions)(IMTSessionSet * sessions, IDispatch * systemContext, VARIANT configState);

// data
private:
  CComPtr<IObjectContext> mpObjectContext;
};

#endif //__ARPROPAGATIONWRITER_H_
