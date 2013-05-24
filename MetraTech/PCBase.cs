/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Boris Partensky
* $$
* 
***************************************************************************/
using System;
using MetraTech.Interop.MTProductCatalog;



namespace MetraTech
{
  /// <summary>
	/// Implements IMTPCBase
	/// </summary>
	public class PCBase : PropertiesBase, MetraTech.Interop.MTProductCatalog.IMTPCBase
	{
    public PCBase(){}
    public void SetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx)
    {
      mSessionContextPtr = aCtx;
      OnSetSessionContext(aCtx);
    }
    public MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContext()
    {
      return mSessionContextPtr;
    }

    protected MetraTech.Interop.MTProductCatalog.IMTSessionContext GetSessionContextPtr()
    {
      return mSessionContextPtr;
    }
    protected MetraTech.Interop.MTProductCatalog.IMTSecurityContext GetSecuritysContextPtr()
    {
      return mSessionContextPtr.SecurityContext;
    }

    protected virtual void OnSetSessionContext(MetraTech.Interop.MTProductCatalog.IMTSessionContext aCtx)
    {
    }

  
    protected MetraTech.Interop.MTProductCatalog.IMTSessionContext mSessionContextPtr;
	}
}
