/**************************************************************************
 * @doc MTAUTOCONTEXT
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
 * @index | MTAUTOCONTEXT
 ***************************************************************************/

#ifndef _MTAUTOCONTEXT_H
#define _MTAUTOCONTEXT_H

class MTAutoContext
{
public:
	MTAutoContext(CComPtr<IObjectContext> & arObjectContext)
		: mCompleted(FALSE), mrObjectContext(arObjectContext)
	{ }

	~MTAutoContext()
	{
		if (mrObjectContext)
		{
			if (mCompleted)
				mrObjectContext->SetComplete();
			else
				mrObjectContext->SetAbort();
		}
	}

	void Complete()
	{ mCompleted = TRUE; }

private:
	BOOL mCompleted;

	CComPtr<IObjectContext> & mrObjectContext;
};


#endif /* _MTAUTOCONTEXT_H */
