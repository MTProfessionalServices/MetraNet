/**************************************************************************
 * @doc AUTHERR
 *
 * @module |
 *
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | AUTHERR
 ***************************************************************************/

#ifndef _AUTHERR_H
#define _AUTHERR_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#import <AuditEventsLib.tlb>

// audit authorization failures
void AuditAuthFailures(_com_error & arError,
											 AuditEventsLib::MTAuditEvent aEvent,
											 int aUserID,	AuditEventsLib::MTAuditEntityType aEntity,
											 int aObjectID);

#endif /* _AUTHERR_H */
