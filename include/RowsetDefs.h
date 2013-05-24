/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LISCENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 ***************************************************************************/

#ifndef __ROWSETDEFS_H
#define __ROWSETDEFS_H

typedef enum 
{
  INPUT_PARAM = 0x00,
  OUTPUT_PARAM = 0x01,
  IN_OUT_PARAM = 0x02,
  RETVAL_PARAM = 0x03
} MTParameterDirection;

typedef enum
{
  MTTYPE_SMALL_INT = 0x00,
  MTTYPE_INTEGER = 0x01,
  MTTYPE_FLOAT = 0x02,
  MTTYPE_DOUBLE = 0x03,
  MTTYPE_VARCHAR = 0x04,
  MTTYPE_VARBINARY = 0x05,
  MTTYPE_DATE = 0x06,
  MTTYPE_NULL = 0x07,
  MTTYPE_DECIMAL = 0x08,
  MTTYPE_W_VARCHAR = 0x09,
  MTTYPE_BIGINT = 0x0A,
} MTParameterType;

#endif
