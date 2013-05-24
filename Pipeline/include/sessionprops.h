/**************************************************************************
 * @doc SESSIONPROPS
 *
 * @module |
 *
 *
 * Copyright 2004 by MetraTech Corporation
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
 * @index | SESSIONPROPS
 ***************************************************************************/

#ifndef _SESSIONPROPS_H
#define _SESSIONPROPS_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

enum ReservedNameID
{
	// session related
	SessionUID,
	ObjectOwnerID,
	MeteredTimestamp,
	Timestamp,
	ServiceID,
	ProductViewID,
	IPAddress,
	//_SessionID and _SessionSetID:
	//4.0 work, these properties need to be put
	//into t_failed_transaction, so that we can map them back into
	//t_session_set and t_schedule tables
	SessionID,
	SessionSetID,

	SessionContextUserName,
	SessionContextPassword,
	SessionContextNamespace,
	SessionContextSerialized,
	ErrorString,
	ErrorCode,
	TransactionCookie,

	// object owner related
	ObjectOwnerActionType,
	ObjectOwnerTotalCount,
	ObjectOwnerWaitingCount,
	ObjectOwnerOwnerStage,
	ObjectOwnerErrorFlag,
	ObjectOwnerNextOwnerID,
	ObjectOwnerFeedbackOnSessionSet,
	ObjectOwnerTransactionObject,
	ObjectOwnerRowsetObject,
	ObjectOwnerTransactionID,
	ObjectOwnerRSIDCache,

	// write product view

	// product catalog
};



#endif /* _SESSIONPROPS_H */
