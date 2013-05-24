/**************************************************************************
 * @doc COLLECTIONADAPTER
 *
 * @module |
 *
 *
 * Copyright 2001 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | COLLECTIONADAPTER
 ***************************************************************************/

#ifndef _COLLECTIONADAPTER_H
#define _COLLECTIONADAPTER_H

class CollectionAdapter
{
public:
	CollectionAdapter(VBA::_CollectionPtr aCollection)
		: mCollection(aCollection)
	{ }

	HRESULT get__NewEnum(IUnknown * * pVal)
	{ return mCollection->raw__NewEnum(pVal); }

	CollectionAdapter * operator -> ()
	{ return this; }

private:
	VBA::_CollectionPtr mCollection;
};


#endif /* _COLLECTIONADAPTER_H */
