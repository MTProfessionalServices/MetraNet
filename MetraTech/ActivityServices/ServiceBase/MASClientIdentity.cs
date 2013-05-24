#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Principal;
using MetraTech.Interop.MTAuth;

namespace MetraTech.ActivityServices.Services.Common
{

  public class CMASClientIdentity : IIdentity
  {
    private IMTSessionContext m_SessionContext;
    private string m_Name;

    public CMASClientIdentity(string userName, IMTSessionContext sessionContext)
    {
      m_Name = userName;
      m_SessionContext = sessionContext;
    }

    #region IIdentity Members

    public string AuthenticationType
    {
      get { return "MTAuth"; }
    }

    public bool IsAuthenticated
    {
      get { return true; }
    }

    public string Name
    {
      get { return m_Name; }
    }

    #endregion

    public IMTSessionContext SessionContext
    {
      get { return m_SessionContext; }
    }
  }
}