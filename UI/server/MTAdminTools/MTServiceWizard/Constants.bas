Attribute VB_Name = "Constants"
'----------------------------------------------------------------------------
' Copyright 1998, 1999 by MetraTech Corporation
' All rights reserved.
'
' THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' example, but not limitation, MetraTech Corporation MAKES NO
' REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
'
' Title to copyright in this software and any associated
' documentation shall at all times remain with MetraTech Corporation,
' and USER agrees to preserve the same.
'
' $Workfile$
' $Date$
' $Author$
' $Revision$
'
'
'----------------------------------------------------------------------------

'----------------------------------------------------------------------------
'Contains constants used by the Service Wizard
'----------------------------------------------------------------------------
Public Const BLANK_SERVICE_MSIXDEF = "blank_service.msixdef"
Public Const BLANK_PV_MSIXDEF = "blank_productview.msixdef"
Public Const BLANK_STAGE_XML = "blank_stage.xml"
Public Const BLANK_AUTOSDK_XML = "blank_autoSDK.xml"
Public Const BLANK_NAMESPACE_XML = "namespace.xml"
Public Const BLANK_ACCOUNT_RESOLUTION_XML = "accountresolution.xml"
Public Const BLANK_ACCOUNT_RESOLUTION_XML2 = "accountresolution2.xml"
Public Const BLANK_ASSIGN_VALUES_XML = "assignvalues.xml"
Public Const BLANK_PCRATELOOKUP_XML = "pcratelookup.xml"
Public Const BLANK_PI_LOOKUP_XML = "pi_lookup.xml"
Public Const BLANK_SET_PI_TYPE_NAME_XML = "set_pi_type_name.xml"
Public Const BLANK_SET_PV_NAME_XML = "set_pv_name.xml"
Public Const BLANK_SET_AMOUNT_XML = "set_amount.xml"
Public Const BLANK_OVERRIDETIMESTAMP_XML = "overridetimestamp.xml"
Public Const XMLCONFIG_NODE_QUERY = "/xmlconfig"
Public Const VIEW_HIERARCHY_NODE_QUERY = XMLCONFIG_NODE_QUERY & "/view_hierarchy"
Public Const NAMESPACE_NODE_QUERY = "/xmlconfig/mtconfigdata/processor/configdata/default_actions/action/prop_value"
Public Const ASSIGNPROPS_NODE_QUERY = "/xmlconfig/mtconfigdata/processor/configdata/AssignProps"
Public Const PAYER_NODE_QUERY = "/xmlconfig/mtconfigdata/processor/configdata/Resolution/Login"
Public Const PINAME_NODE_QUERY = "/xmlconfig/mtconfigdata/processor/configdata/default_actions/action/prop_value"

''''''''''''''''''
'Queries for msixdefs
Public Const SERVICE_NAME_NODE_QUERY = "/defineservice/name"
Public Const SERVICE_DN_NODE_QUERY = "/defineservice/ptype/dn"
Public Const SERVICE_TYPE_NODE_QUERY = "/defineservice/ptype/type"
Public Const SERVICE_DEFAULT_VALUE_NODE_QUERY = "/defineservice/ptype/defaultvalue"

''''''''''''''''''
' Queries for stage files
'stage dependencies that don't depend on other plugins
Public Const STAGE_DEPENDLESS_PLUGIN_QUERY = "/xmlconfig/stage/dependencies/dependson"

'Plugins in a stage that depend on other plugins
Public Const STAGE_DEPEND_PLUGIN_QUERY = "/xmlconfig/stage/dependencies/dependency"

'stage depends query
Public Const STAGE_DEPENDS_QUERY = "/xmlconfig/stage/dependencies"

Public Const STAGE_NAME_QUERY = "/xmlconfig/stage/name"
Public Const STAGE_START_QUERY = "/xmlconfig/stage/startstage"
Public Const STAGE_FINAL_QUERY = "/xmlconfig/stage/finalstage"
Public Const STAGE_NEXT_QUERY = "/xmlconfig/stage/nextstage"
''''''''''''''''''

Public Const SERVICE_ID_NODE_QUERY = "/xmlconfig/direction/ServiceID"

'Relative to an extension's root directory
Public Const SERVICE_TO_STAGE_MAP_XML = "/config/pipeline/servicetostagemap.xml"
Public Const VIEW_HIERARCHY_XML = "/config/viewinfo/view_hierarchy.xml"
Public Const SERVICE_DIR = "/config/service"
Public Const PV_DIR = "/config/productview"

'Priceable Item
Public Const PRICEABLE_ITEM_DIR = "/config/PriceableItems"
Public Const PARAMETER_TABLE_DIR = "/config/ParamTable"

'Counters
Public Const COUNTER_TYPE_XML = "/config/CounterType/CounterType.xml"

