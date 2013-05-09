Attribute VB_Name = "Constants"
' //==========================================================================
' // Copyright 1998-2001 by MetraTech Corporation
' // All rights reserved.
' //
' // THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
' // NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
' // example, but not limitation, MetraTech Corporation MAKES NO
' // REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
' // PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
' // DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
' // COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
' //
' // Title to copyright in this software and any associated
' // documentation shall at all times remain with MetraTech Corporation,
' // and USER agrees to preserve the same.
' //==========================================================================

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'  Constants.bas                                                            '
'  Constants for use with account hierarchies helper.                       '
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'
Public Const ACCOUNT_XML_TOP = "account_hierarchies"

'Node names
Public Const HIERARCHY_ROOT_NODE = "fragment/parent"
Public Const ENTITY_NODE = "hierarchy"
Public Const ENTITY_CHILD_NODES = "hierarchy"
Public Const ENTITY_ID = "id_acc"
Public Const ENTITY_NAME = "child"
Public Const ENTITY_PARENT_ID = "parent_id"

'Node queries
Public Const ANY_ENTITY_CHILD_NODES = "//hierarchy"
Public Const ANY_ENTITY_WITH_ID = "//hierarchy[id_acc = '[ID]']"
Public Const ANY_ENTITY_WITH_PARENT_ID = "//parent[parent_id = '[ID]']"
Public Const ANY_ENTITY_WITH_NAME = "//hierarchy[child = '[NAME]']"
Public Const CHILD_WITH_ID = "hierarchy[id_acc = '[ID]']"

Public Const ANY_HIGHLIGHTED_ENTITY = "//hierarchy[@highlight = 'true']"

'Attributes
Public Const VISIBLE_ATTRIBUTE = "visible"
Public Const HIGHLIGHT_ATTRIBUTE = "highlight"
Public Const DISABLED_ATTRIBUTE = "disabled"
Public Const CHILDREN_ATTRIBUTE = "bChildren"
