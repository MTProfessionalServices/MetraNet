/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY -- PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Raju Matta
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#ifndef PAYMENTSERVERDEFS_H
#define PAYMENTSERVERDEFS_H

#define MT_OFFLINE           3
#define MT_BUSY              4

#define ICV_MAX_FIELD_LEN 32
#define XACTION_LEN       1024
#define MT_STD_MEMBER_LEN 128
#define MT_ZIP_LEN        10
#define MT_RESP_LEN       512
#define MT_MAX_AMT_LEN    32

#if 0
// moved to creditcard.idl
typedef enum
{
  YYMM = 7,
  MMYY = 8,
  YYYYMM = 9,
  MMYYYY = 10,
  MM_slash_YY = 11,
  YY_slash_MM = 12,
  MM_slash_YYYY = 13,
  YYYY_slash_MM = 14,
  MT_DATE_FORMAT_NOT_SUPPORTED = 15
} MTDateFormat;
#endif 

typedef enum
{
  USE_ACCOUNTID,
  USE_ACCOUNTID_LAST4_TYPE,
  USE_ACCOUNTID_ROUTINGNUMBER_LAST4_TYPE
} MTLookupType;

//
// Don't change these values. Services has code that is written to
// these values. Adding new constants is no problem.
//
typedef enum
{
  OBSOLETE0                                      = 0,
  CC_FIND_UPDATE_BY_NUMBER_DATE_TYPE             = 1,
  OBSOLETE2                                      = 2,
  OBSOLETE3                                      = 3,
  OBSOLETE4                                      = 4,
  CC_FIND_BY_ACCOUNTID_LAST4_TYPE                = 5,
  CC_FIND_BY_ACCOUNTID                           = 6,
  OBSOLETE7                                      = 7,
  OBSOLETE8                                      = 8,
  OBSOLETE9                                      = 9,
  ACH_FIND_BY_ACCOUNTID                          = 10,
  ACH_FIND_BY_ACCOUNTID_ROUTINGNUMBER_LAST4_TYPE = 11,
  DECRYPT_CC_NUMBER                              = 12,
  DECRYPT_ACH_NUMBER                             = 13,
  CC_ADD_ACCOUNT_AND_PAYMENT_METHOD              = 14,
  CC_ADD_PAYMENT_METHOD                          = 15,
  ACH_ADD_ACCOUNT_AND_PAYMENT_METHOD             = 16,
  ACH_ADD_PAYMENT_METHOD                         = 17,
  UPDATE_ACCOUNT                                 = 18,
  CC_UPDATE_PAYMENT_METHOD                       = 19,
  ACH_UPDATE_PAYMENT_METHOD                      = 20,
  CC_UPDATE_PRIMARY_INDICATOR                    = 21,
  ACH_UPDATE_PRIMARY_INDICATOR                   = 22,
  CC_DELETE_PAYMENT_METHOD                       = 23,
  ACH_DELETE_PAYMENT_METHOD                      = 24,
  GET_ACCOUNT_AND_PRIMARY_PAYMENT_METHOD         = 25,
	UPDATE_AUTHORIZATION                           = 26
} AccountActionType;

typedef enum
{
  PREAUTH_INSERT,
  PREAUTH_SELECT,
  PREAUTH_DELETE,
  PREAUTH_UNKNOWN_ACTION
} PreauthLookupType;

#endif // PAYMENTSERVERDEFS_H
