/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __AUTH_H__
#define __AUTH_H__
#pragma once

#define PRINCIPAL_TAG "principal"
#define DESCRIPTION_TAG "description"
#define CSR_ASSIGNABLE_TAG "csrassignable"
#define SUBSCRIBER_ASSIGNABLE_TAG "subscriberassignable"
#define POLICIES_TAG "policies"
#define POLICY_TAG "policy"
// ESR-6421 a port of ESR-6007/ESR-5722 reduce the size of the tags
#define COMPOSITE_CAPS_TAG "cs"  // compositecapabilities
#define COMPOSITE_CAP_TAG "c"    // compositecapability
#define ATOMIC_CAPS_TAG "as"     // atomiccapabilities
#define ATOMIC_CAP_TAG "a"       // atomiccapability
#define ENUMTYPE_CAP_TAG "ec"   // mtenumtypecapability
#define PATH_CAP_TAG "pc"       // mtpathcapability
#define DECIMAL_CAP_TAG "dc"    // mtdecimalcapability
#define STR_COL_CAP_TAG "sc"    // mtstringcolcapability
#define VALUE_TAG "v"            // value
#define OP_TAG "op"
// ESR-6421 a port of ESR-6007/ESR-5722 reduce the size of the tags
#define WILDCARD_TAG "wc" // wildcard
#define ROLES_TAG "rs" // roles
#define ROLE_TAG "r" // role
#define TYPE_ATTRIB "type"
#define NAME_ATTRIB "name"
// ESR-6421 a port of ESR-6007/ESR-5722 reduce the size of the tags
#define AUTH_NAME_TAG "n" // name
#define GUID_ATTRIB "guid"
#define ACCOUNT_ID_TAG "id_acc"
#define SECURITY_CONTEXT_TAG "securitycontext"
// ESR-6421 a port of ESR-6007/ESR-5722 reduce the size of the tags
#define DBID_TAG "d" // dbid
#define AUTH_PROGID_TAG "p" // progid
#define PARAM_NAME_TAG "parametername"

#define APPLICATION_NAME_TAG "applicationname"
#define LOGGEDINAS_TAG "loggedinas"

#endif //__AUTH_H__
