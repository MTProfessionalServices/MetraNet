using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.UI.Common
{
  [Serializable]
  public class UserData 
  {
    #region Public Methods
    public UserData()
    {
      nonWorkflowDataMap = new Dictionary<string, object>();
    }
    
    /// <summary>
    ///    Given a dataKey and data object, store this information.
    ///    If a data object with the given dataKey exists, then that object will be replaced with the given data object.
    /// </summary>
    /// <param name="dataKey"></param>
    /// <param name="data"></param>
    public void SetData(string dataKey, object data)
    {
      nonWorkflowDataMap[dataKey] = data;
    }

    /// <summary>
    ///    Given a dataKey return the object corresponding to that key. 
    ///    If the key does not exist, null is returned.
    /// </summary>
    /// <param name="dataKey"></param>
    /// <returns></returns>
    public object GetData(string dataKey)
    {
      object data = null;
      try
      {
        data = nonWorkflowDataMap[dataKey];
      }
      catch(KeyNotFoundException)
      {
      }

      return data;
    }
    #endregion

    #region Properties

    // UserName
    private string userName;
    public string UserName
    {
      get { return userName; }
      set { userName = value; }
    }

    // NameSpace
    private string nameSpace;
    public string NameSpace
    {
      get { return nameSpace; }
      set { nameSpace = value; }
    }

    // Account ID
    private int accountId;
    public int AccountId
    {
      get { return accountId; }
      set { accountId = value; }
    }

    private IMTSessionContext sessionContext;
    public IMTSessionContext SessionContext
    {
      get { return sessionContext; }
      set { sessionContext = value; }
    }

    public string SessionPassword
    {
      get { return ((char)8).ToString() + sessionContext.ToXML(); }
    }

    private string ticket;
    public string Ticket
    {
      get { return ticket; }
      set { ticket = value; }
    }

    #endregion

    #region Internal Methods
    internal void SetUserName(string userName)
    {
      this.userName = userName;
    }

    internal void SetNameSpace(string nameSpace)
    {
      this.nameSpace = nameSpace;
    }

    internal void SetAccountId(int accountId)
    {
      this.accountId = accountId;
    }

    internal void SetSessionContext(IMTSessionContext sessionContext)
    {
      this.sessionContext = sessionContext;
    }

    internal void SetTicket(string ticket)
    {
      this.ticket = ticket;
    }
    #endregion

    #region Data
    // Container for non workflow data. 
    [NonSerialized]
    private Dictionary<string, object> nonWorkflowDataMap;

    private const string PROP_USERNAME = "username";
    private const string PROP_NAMESPACE = "namespace";
    private const string PROP_ACCOUNTID = "accountId";
    private const string PROP_SESSION_CONTEXT = "sessionContext";
    private const string PROP_TICKET = "ticket";
    #endregion


    #region Static
    public static UserData GetSystemAcctUserData()
    {
      MetraTech.Interop.MTAuth.IMTLoginContext loginContext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");

      MetraTech.Interop.MTAuth.MTSessionContext suCtx = loginContext.Login(accessData.UserName, "system_user", accessData.Password);
      UserData userData = new UserData();

      userData.NameSpace = "system_user";
      userData.SessionContext = suCtx;
      userData.UserName = accessData.UserName;
      userData.AccountId = suCtx.AccountID;
      userData.Ticket = String.Empty;

      return userData;
    }
    #endregion
  }
}
