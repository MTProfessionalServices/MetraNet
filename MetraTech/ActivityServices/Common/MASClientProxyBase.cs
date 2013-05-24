using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ActivityServices.Common
{
  [Serializable]
  public abstract class CMASClientProxyBase
  {
    #region Members
    private string m_UserName;
    private string m_Password;
    #endregion

    #region Public Methods
    public abstract void Invoke();

    public abstract IAsyncResult BeginInvoke(AsyncCallback asyncCallback, object stateObject);
    public abstract void EndInvoke(IAsyncResult result);
    #endregion

    #region Properties
    public string UserName
    {
      get { return m_UserName; }
      set { m_UserName = value; }
    }

    public string Password
    {
      get { return m_Password; }
      set { m_Password = value; }
    }
    #endregion
  }

  [Serializable]
  public abstract class CMASEventClientProxyBase : CMASClientProxyBase
  {
    #region Members
    protected Dictionary<string, object> m_StateInitData;
    #endregion

    #region Properties
    public System.Collections.Generic.Dictionary<string, object> Out_StateInitData
    {
      get
      {
        return this.m_StateInitData;
      }
      set
      {
        this.m_StateInitData = value;
      }
    }
    #endregion
  }

  [Serializable]
  public abstract class CMASEventMIClientProxyBase : CMASEventClientProxyBase
  {
    #region Members
    protected Guid m_ProcessorInstanceId;
    #endregion

    #region Properties
    public Guid InOut_ProcessorInstanceId
    {
      get { return m_ProcessorInstanceId; }
      set { m_ProcessorInstanceId = value; }
    }
    #endregion
  }
}
