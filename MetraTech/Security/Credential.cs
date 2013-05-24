using System;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;

namespace MetraTech.Security
{
  /// <summary>
  ///    Credentials
  /// </summary>
  [ComVisible(false)]
  public class Credentials
  {
    private const string queryPath = @"Queries\Security";
    private readonly Logger logger = new Logger("[MetraTech.Security.Auth.Credentials]");
    public int _numberOfFailuresSinceLogin = 0;
    public bool _isEnabled = false;

    /// <summary>
    ///   UserName
    /// </summary>
    public string UserName
    {
      get;
      set;
    }
    /// <summary>
    ///   Name_Space
    /// </summary>
    public string Name_Space
    {
      get;
      set;
    }
    /// <summary>
    ///   PasswordHash
    /// </summary>
    public string PasswordHash
    {
      get;
      set;
    }
    /// <summary>
    ///   ExpireDate
    /// </summary>
    public DateTime? ExpireDate
    {
      get;
      set;
    }
    /// <summary>
    ///   LastLoginDate
    /// </summary>
    public DateTime? LastLoginDate
    {
      get;
      set;
    }
    /// <summary>
    ///   LastLogoutDate
    /// </summary>
    public DateTime? LastLogoutDate
    {
      get;
      set;
    }
    /// <summary>
    ///   AutoResetFailuresDate
    /// </summary>
    public DateTime? AutoResetFailuresDate
    {
      get;
      set;
    }
    /// <summary>
    ///   NumberOfFailuresSinceLogin
    /// </summary>
    public int NumberOfFailuresSinceLogin
    {
      get
      {
        return _numberOfFailuresSinceLogin;
      }
      set
      {
        _numberOfFailuresSinceLogin = value;
      }
    }
    /// <summary>
    ///   IsEnabled
    /// </summary>
    public bool IsEnabled
    {
      get
      {
        return _isEnabled;
      }
      set
      {
        _isEnabled = value;
      }
    }
    /// <summary>
    /// Gets or sets sign of authentication type in MetraNet.
    /// </summary>
    public AuthenticationType AuthenticationType
    {
      get;
      set;
    }

    /// <summary>
    ///   Credentials
    /// </summary>
    /// <param name="username"></param>
    /// <param name="name_space"></param>
    public Credentials(string username, string name_space)
    {

      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__GET_CREDENTIALS__"))
          {
            stmt.AddParam("%%USERNAME%%", username);
            stmt.AddParam("%%NAME_SPACE%%", name_space);
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              if (reader.Read())
              {
                UserName = reader.GetString("nm_login");
                Name_Space = reader.GetString("nm_space");
                PasswordHash = reader.IsDBNull("tx_password") ? null : reader.GetString("tx_password");
                ExpireDate = reader.IsDBNull("dt_expire") ? MetraTime.Max : reader.GetDateTime("dt_expire");
                LastLoginDate = reader.IsDBNull("dt_last_login") ? MetraTime.Max : reader.GetDateTime("dt_last_login");
                LastLogoutDate = reader.IsDBNull("dt_last_logout") ? MetraTime.Max : reader.GetDateTime("dt_last_logout");
                NumberOfFailuresSinceLogin = reader.IsDBNull("num_failures_since_login") ? 0 : reader.GetInt32("num_failures_since_login");
                AutoResetFailuresDate = reader.IsDBNull("dt_auto_reset_failures") ? MetraTime.Max : reader.GetDateTime("dt_auto_reset_failures");
                IsEnabled = reader.IsDBNull("b_enabled") ? true : reader.GetBoolean("b_enabled");
                AuthenticationType = (AuthenticationType)reader.GetInt32("auth_type");
              }
              else
              {
                UserName = username;
                Name_Space = name_space;
              }
            }
          }
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Error getting user credentials for {0}, {1}", username, name_space), e);
        throw;
      }

    }
  }
}
