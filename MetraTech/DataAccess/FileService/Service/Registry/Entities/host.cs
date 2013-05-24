namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.Net;
  using System.Net.Sockets;
  using System.Transactions;
  // MetraTech Assemblies
  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region Host cDatabase Class
  /// <summary>
  /// The host configuration represents the host registration, and the service state
  /// </summary>
  public class HostConfiguration : BasicEntity
  {
    public static readonly TLog Log = new TLog("MetraTech.FileService.HostConfiguration");
    private IPAddress[] m_AddressList = null;
    private string m_Host = "";

    public HostConfiguration(IStandardRepository db, ServiceHostBE host)
      : base(db, host)
    {
    }

    public string Host
    {
      get
      {
        if (m_Host != null && m_Host != String.Empty)
          return m_Host;

        try
        {
          m_Host = Dns.GetHostName();
        }
        catch (SocketException e)
        {
          Log.Error("SocketException Source : " + e.Source + " : Message : " + e.Message);
          throw;
        }
        catch (Exception e)
        {
          Log.Error("Exception Source : " + e.Source + " : Message : " + e.Message);
          throw;
        }
        return m_Host;
      }
    }

    public IPAddress[] AddressList
    {
      get
      {
        if (m_AddressList != null && m_AddressList.Length != 0)
          return m_AddressList;

        try
        {
          m_AddressList = Dns.GetHostAddresses(Host);
          foreach (IPAddress ip in m_AddressList)
          {
            Log.Info(String.Format("FLS m_HostCfg registered address {0}", ip));
          }
        }
        catch (ArgumentNullException e)
        {
          Log.Error(e.Message);
          throw;
        }
        catch (ArgumentOutOfRangeException e)
        {
          Log.Error(e.Message);
          throw;
        }
        catch (SocketException e)
        {
          Log.Error(e.Message);
          throw;
        }
        catch (ArgumentException e)
        {
          Log.Error(e.Message);
          throw;
        }
        return m_AddressList;
      }
    }

    public bool Update()
    {
      if(IsUpToDate()) return false;

      Log.Info("Updating Host Record");
      ServiceHostBE me = Instance as ServiceHostBE;
      me._Name = Host;

      if (AddressList.Length > 0)
        me._Address = AddressList[0].ToString();
      else
        me._Address = "0.0.0.0";

      if (!Register())
        return false;

      return true;
    }

    /// <summary>
    /// Determines if the instance is current
    /// </summary>
    /// <returns></returns>
    public override bool IsUpToDate()
    {
      ServiceHostBE me = Instance as ServiceHostBE;
      if (null == me || me.Id == Guid.Empty)
        return false;

      ServiceHostBE host = DB.LoadInstance(typeof(ServiceHostBE).FullName, Instance.Id) as ServiceHostBE;
      if (null != host)
      {
        if (me._Version < host._Version)
        {
          return false;
        }
        return true;
      }
      return false;
    }
    /// <summary>
    /// 
    /// </summary>
    public bool IsRegistered()
    {
      if (Instance.Id == Guid.Empty)
      {
        ServiceHostBE me = FindHost((Instance as ServiceHostBE)._Name, (Instance as ServiceHostBE)._Address);
        if (null == me)
          return false;
        Instance = me;
        return true;
      }

      ServiceHostBE shost = DB.LoadInstance(typeof(ServiceHostBE).FullName, Instance.Id) as ServiceHostBE;
      if (shost != null)
      {
        Log.Info("Host " + shost._Name + " already registered");
        Instance = shost;
        return true;
      }
      return false;
    }
    /// <summary>
    /// 
    /// </summary>
    public bool Register()
    {
      // Make sure we don't double register
      if (IsRegistered())
      {
        Log.Info("Already Registered");
        return true;
      }
      Log.Info("Registering");
      UpdateState(EServiceState.READY);
      Log.Info("Registered");
      return true;
    }

    public void Unregister()
    {
      if (null != Instance && Instance.Id != Guid.Empty)
      {
        ServiceHostBE me = Instance as ServiceHostBE;
        DB.DeleteInstance(me);
      }
    }

    public void UpdateState(EServiceState state)
    {
      ServiceHostBE me = Instance as ServiceHostBE;
      me._State = state;
      try
      {
        DB.SaveInstance(me);
      }
      catch (TransactionAbortedException ex)
      {
        Log.Error("Unable to save host state: " + ex.Message);
      }
      catch
      {
        Log.Error("Unable to save host state");
      }
    }

    private ServiceHostBE FindHost(string name, string addr)
    {
      // Try hard to find it...
      MTList<DataObject> serviceHosts = DB.LoadInstances(typeof(ServiceHostBE).FullName, new MTList<DataObject>());

      if (serviceHosts.TotalRows <= 0) return null;

      foreach (ServiceHostBE shost in serviceHosts.Items)
        if ((shost._Name == name) && (shost._Address == addr))
          return shost;

      return null;
    }
  }

  #endregion
  //////////////////////////////////////////////////////////////////////////////////////
}
