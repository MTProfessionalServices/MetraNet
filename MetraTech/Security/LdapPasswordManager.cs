using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.DirectoryServices.Protocols;
using System.DirectoryServices;

namespace MetraTech.Security
{
  /// <summary>
  /// Provides the authentication against Active Directory using LDAP.
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("E6375FEE-EFE9-4854-9517-DDF552A66574")]
  internal class LdapPasswordManager : PasswordManagerBase
  {
    #region Data

    private const string NotSupportedMethodMessage = "Method {0} is not supported by LdapPasswordManager";
    private Logger logger = new Logger("[MetraTech.Security.Crypto.LdapPasswordManager]");
    private static MetraTech.DataAccess.ConnectionInfo ldapServerInfo = new DataAccess.ConnectionInfo("LDAPserver");

    /// <summary>
    /// LdapConnectionString has to be in the format: LDAP://domain.com
    /// </summary>
    private static string LdapConnectionString = string.Format("LDAP://{0}", ldapServerInfo.Server);

    #endregion

    #region Properties

    /// <summary>
    /// Gets an instance of the <see cref="Logger"/> object to be used for the password management logging activities.
    /// </summary>
    protected override Logger Logger
    {
      get { return logger; }
    }

    #endregion

    #region IPasswordManager Members

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public override string HashNewPassword(string plainTextPassword)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "HashNewPassword"));
    }

    /// <summary>
    /// Verifies the user credentials against Active Directory.
    /// </summary>
    /// <param name="plainTextPassword">The password of the user indicated in the Credentials object.</param>
    /// <returns>True if the credentials are valid and false otherwise.</returns>
    public override bool IsPasswordValid(string plainTextPassword)
    {
      try
      {
        using (DirectoryEntry ldap = new DirectoryEntry(LdapConnectionString, Credentials.UserName, plainTextPassword, AuthenticationTypes.Secure))
        {
          using (DirectorySearcher ds = new DirectorySearcher(ldap))
          {
            ds.FindOne();
          }
        }

        return true;
      }
      catch (Exception)
      {
        return false;
      }
    }

    /// <summary>
    /// Check if this is a new account
    /// </summary>
    /// <returns>Always returns false.</returns>
    public override bool IsNewAccount()
    {
      // TODO: implement this feature via AD request.
      return false;
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <returns></returns>
    public override int DaysUntilPasswordExpires()
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "DaysUntilPasswordExpires"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="newPassword"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    public override bool ChangePassword(string password, string newPassword, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "ChangePassword"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    public override bool UnlockAccount(Interop.MTAuth.IMTSessionContext sessionContext)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "UnlockAccount"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    public override bool LockAccount(Interop.MTAuth.IMTSessionContext sessionContext)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "LockAccount"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public override bool CheckPasswordStrength(string plainTextPassword)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "CheckPasswordStrength"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    public override void SetPasswordExpiryDate()
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "SetPasswordExpiryDate"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <returns></returns>
    public override string GeneratePassword()
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "GeneratePassword"));
    }

    /// <summary>
    /// Not supported.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="sessionContext"></param>
    public override void UpdatePassword(string password, Interop.MTAuth.IMTSessionContext sessionContext)
    {
      throw new NotSupportedException(string.Format(NotSupportedMethodMessage, "UpdatePassword"));
    }

    #endregion
  }
}
