using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Transactions;
using MetraTech.Accounts.Type;
using MetraTech.DataAccess;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Interop.MTAuth;
using MetraTech.Security.Crypto;
using YAAC = MetraTech.Interop.MTYAAC;

namespace MetraTech.Security
{
  /// <summary>
  /// Implements the password manager for authentication against MetraNet DB
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("77649030-1298-4a7d-B7D1-6442E2FE1B95")]
  internal class PasswordManager : PasswordManagerBase
  {
	  #region data

    private Logger logger = new Logger("[MetraTech.Security.Crypto.PasswordManager]");
    private CryptoManager crypto = new CryptoManager();
    //private Auditor auditor = new Auditor();

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

    #region Public methods

    /// <summary>
    /// Generate a strong password without ambiguos characters
    /// </summary>
    /// <returns></returns>
    public override string GeneratePassword()
    {
      return RandomPassword.Generate();
    }

    /// <summary>
    /// Returns the number of days until the current password expires.
    /// </summary>
    /// <returns></returns>
    public override int DaysUntilPasswordExpires()
    {
      int days = PasswordConfig.GetInstance().DaysBeforePasswordExpires;

      if (IsNewAccount())
      {
        return 0;  // new accounts should change their password right away.
      }

      DateTime? expireDate = Credentials.ExpireDate;

      if (expireDate != null)
      {
        days = MetraTime.Now.Subtract((DateTime) expireDate).Days * -1;
      }

      return days;
    }

    /// <summary>
    /// Changes the password for the username and namespace set in the initialize, if the old password is correct.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="newPassword"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    public override bool ChangePassword(string password, string newPassword, IMTSessionContext sessionContext)
    {
      bool success = false;
      Auditor auditor = new Auditor();

      try
      {
        // CORE-566 - Removed manage account hierarchy check that isn't really needed for a user to set their own
        //            password.  They are still required to provide a valid old password.
        //if (HasManageAccountCapability((YAAC.IMTSessionContext)sessionContext))
        //{
          // check if password is valid
          if (IsPasswordValid(password))
          {
            // check password strength
            if (!CheckPasswordStrength(newPassword))
            {
              throw new PasswordStrengthException("Password is not strong enough.");
            }

            // make sure password is not any of the previous 4
            if (HasPasswordBeenUsedBefore(newPassword))
            {
              throw new PasswordStrengthException("Password has been used before.");
            }

            // update password, successful audit is done inside transactionaly
            UpdatePasswordExtended(newPassword, sessionContext);
            success = true;
          }
          else
          {
            // Audit change password failure

            auditor.FireFailureEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_CHANGE_PASSWORD_INVALID_FAILED,
                   sessionContext.AccountID,
                   (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                   -1,
                   String.Format("Change password failed for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space),
                   sessionContext.LoggedInAs,
                   sessionContext.ApplicationName);
            success = false;
          }
        //}
        //else
        //{
        //  // Audit change password failure, no capability
        //  auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_CHANGE_PASSWORD_NO_CAPABILITY_FAILED,
        //         -1,
        //         (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
        //         -1,
        //         String.Format("Change password failed for username={0} namespace={1}", m_UserName, Credentials.Name_Space));
        //  success = false;
        //}
      }
      catch (Exception exp)
      {
        // Audit change password failure and log exception
        auditor.FireFailureEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_CHANGE_PASSWORD_INVALID_FAILED,
               sessionContext.AccountID,
               (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
               -1,
               String.Format("Change password failed for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space),
               sessionContext.LoggedInAs,
               sessionContext.ApplicationName);
        logger.LogException("Invalid change password call.", exp);
        throw;
      }
      return success;


#region pseudocode
      /*
      Begin ChangePassword
        check rights to change password on passed in session context
         
        if password is valid
          check password business rules
          update password 
          audit
          return true
        else
          audit
          return false
      End 
      */
#endregion

    }

    /// <summary>
    /// Check if the passed in password meets the passord strength requirements defined in config.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public override bool CheckPasswordStrength(string plainTextPassword)
    {
      bool success = false;

      PasswordConfig config = PasswordConfig.GetInstance();
      if (config.EnsureStrongPasswords)
      {
        // Check password strength (configured in config/security/mtpassword.xml)
        //  * Must be at least 7 characters and less than 1024
        //  * Must contain at least one one lower case letter, one upper case letter, one digit and one special character
        //  * Valid special characters including space are _ !@#$%^&*+=
        string regexString = string.IsNullOrEmpty(config.PasswordStrengthRegex.Text) ? config.PasswordStrengthRegex.Text : config.PasswordStrengthRegex.Text.Trim();
        Regex regex = new Regex(regexString);

        if (regex.IsMatch(plainTextPassword))
        {
          success = true;
        }
      }
      else
      {
        return true;
      }

      return success;
    }

    /// <summary>
    /// Unlock account - this resets the num_failures_since_login to 0 and sets b_enabled to 'Y'
    /// </summary>
    /// <returns></returns>
    public override bool UnlockAccount(IMTSessionContext sessionContext)
    {
      bool success = false;
      Auditor auditor = new Auditor();

      YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
      accountCatalog.Init((YAAC.IMTSessionContext)sessionContext);
      YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(Credentials.UserName, Credentials.Name_Space, MetraTime.Now);

      if (HasManageAccountCapability((YAAC.IMTSessionContext)sessionContext))
      {
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Run query to unlock account
          try
          {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                  using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__SECURITY_UNLOCK_ACCOUNT__"))
                  {
                    stmt.AddParam("%%USERNAME%%", Credentials.UserName);
                    stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
                      stmt.ExecuteNonQuery();
                      success = true;
                  }
              }
          }
          catch (Exception e)
          {
            // Audit UnlockAccount failure and log exception
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_UNLOCK_ACCOUNT_FAILED,
                   yaac.ID,
                  (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                   yaac.ID,
                   String.Format("Unlock account failed for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space));
            logger.LogException(String.Format("Error unlocking account for {0}, {1}", Credentials.UserName, Credentials.Name_Space), e);
            throw;
          }

          // Audit unlock success
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_UNLOCK_ACCOUNT_SUCCESS,
                 yaac.ID,
                 (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                 yaac.ID,
                 String.Format("Unlock account succeeded for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space));

          scope.Complete();
        }
      }      
      return success;
    }

    /// <summary>
    /// Lock account - Sets b_enabled to 'N' on t_user_credentials and will prevent login.
    /// </summary>
    /// <returns></returns>
    public override bool LockAccount(IMTSessionContext sessionContext)
    {
      bool success = false;
      Auditor auditor = new Auditor();

      YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
      accountCatalog.Init((YAAC.IMTSessionContext)sessionContext);
      YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(Credentials.UserName, Credentials.Name_Space, MetraTime.Now);

      if (HasManageAccountCapability((YAAC.IMTSessionContext)sessionContext))
      {
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          // Run query to unlock account
          try
          {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                  using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__SECURITY_LOCK_ACCOUNT__"))
                  {
                    stmt.AddParam("%%USERNAME%%", Credentials.UserName);
                    stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
                      stmt.ExecuteNonQuery();
                      success = true;
                  }
              }
          }
          catch (Exception e)
          {
            // Audit LockAccount failure and log exception
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOCK_ACCOUNT_FAILED,
                   yaac.ID,
                 (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                   yaac.ID,
                   String.Format("Lock account failed for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space));
            logger.LogException(String.Format("Error locking account for {0}, {1}", Credentials.UserName, Credentials.Name_Space), e);
            throw;
          }

          // Audit lock success
          auditor.FireEvent((int)MTAuditEvent.AUDITEVENT_LOCK_ACCOUNT_SUCCESS,
                 yaac.ID,
                (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                 yaac.ID,
                 String.Format("Lock account succeeded for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space));
          
          scope.Complete();
        }
      }
      return success;
    }

    /// <summary>
    /// Creates a Hashed password based on the plain text, and username and name_space salt.
    /// And a NEW key.  Should not be used to compare password hashes.  Instead use Metratech.Security.Crypto.CompareHash.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public override string HashNewPassword(string plainTextPassword)
    {
      // We decided to check the password strength here, bacause all older code was already coming down this path.
      // CheckPasswordStrength is on the interface and may be called from outside as well.  The password strength will not
      // be checked if the flag EnsureStrongPasswords is set to false.
      if (CheckPasswordStrength(plainTextPassword))
      {
        string saltedPassword = SaltPassword(plainTextPassword);
        // Run crypto hash HMAC-SHA-256
        string hashedPassword = crypto.Hash(HashKeyClass.PasswordHash, saltedPassword);

        return hashedPassword;
      }
      else
      {
        logger.LogWarning("Password strength is not sufficient."); 
        throw new PasswordStrengthException();
      }

    }

    /// <summary>
    ///   Check if the specified password is valid.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public override bool IsPasswordValid(string plainTextPassword)
    {
      bool isValid = false;

      isValid = crypto.CompareHash(HashKeyClass.PasswordHash, 
                                   Credentials.PasswordHash, 
                                   SaltPassword(plainTextPassword));

      return isValid;
    }

    /// <summary>
    /// Check if this is a new account
    /// </summary>
    /// <returns></returns>
    public override bool IsNewAccount()
    {
      bool ret = true;

      // Check if any rows in t_credentials_history
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__SECURITY_PASSWORDS_ALREADY_USED__"))
        {

          stmt.AddParam("%%ROW_COUNT%%", 1);
          stmt.AddParam("%%USERNAME%%", Credentials.UserName);
          stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            if (reader.Read())
            {
              ret = false;
            }
          }
        }
      }

      return ret;
    }

    /// <summary>
    ///   Set a new password expiry date based on configuration data.
    /// </summary>
    public override void SetPasswordExpiryDate()
    {
      Credentials.ExpireDate = MetraTime.Now.AddDays(PasswordConfig.GetInstance().DaysBeforePasswordExpires);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__UPDATE_PASSWORD_EXPIRY_DATE__"))
          {

              stmt.AddParam("%%USERNAME%%", Credentials.UserName);
              stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
              stmt.AddParam("%%EXPIRYDATE%%", Credentials.ExpireDate.Value);

              stmt.ExecuteNonQuery();
          }
      }
    }


    /// <summary>
    ///   Set password to expire today.
    /// </summary>
    public void ExpirePassword()
    {
      Credentials.ExpireDate = MetraTime.Now.AddDays(1);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__UPDATE_PASSWORD_EXPIRY_DATE__"))
          {

            stmt.AddParam("%%USERNAME%%", Credentials.UserName);
            stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
              stmt.AddParam("%%EXPIRYDATE%%", Credentials.ExpireDate.Value);

              stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    ///   Update the existing password with the given plain text password.  It will be set to expire, so it must be changed on next login.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="sessionContext"></param>
    public override void UpdatePassword(string password, IMTSessionContext sessionContext)
    {
      Auditor auditor = new Auditor();

      try
      {
        if (HasManageAccountCapability((YAAC.IMTSessionContext)sessionContext))
        {
          // check password strength
          if (!CheckPasswordStrength(password))
          {
            throw new PasswordStrengthException("Password is not strong enough.");
          }

          // make sure password is not any of the previous 4
          if (HasPasswordBeenUsedBefore(password))
          {
            throw new PasswordStrengthException("Password has been used before.");
          }

          // update password, successful audit is done inside transactionaly
          UpdatePasswordExtended(password, sessionContext);
          ExpirePassword();
        }
      }
      catch (Exception exp)
      {
        // Audit change password failure and log exception
        auditor.FireFailureEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_CHANGE_PASSWORD_INVALID_FAILED,
               sessionContext.AccountID,
               (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
               -1,
               String.Format("Update password failed for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space),
               sessionContext.LoggedInAs,
               sessionContext.ApplicationName);
        logger.LogException("Invalid update password call.", exp);
        throw;
      }
    }

    
    #endregion

    #region private methods

    /// <summary>
    /// Check that the session context passed in has the write access to manage the account
    /// </summary>
    /// <param name="sessionContext"></param>
    private bool HasManageAccountCapability(YAAC.IMTSessionContext sessionContext)
    {
      bool success = false;

      // We don't check manage account hierarchy capability for non-hierarchy accounts such as Independent
      if (IsNonHierarchyAccount(sessionContext))
      {
        success = true;
      }
      else
      {
        try
        {
          //Check that the user has the rights to change the password, based on the passed in session context
          YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
          accountCatalog.Init(sessionContext);
          YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(Credentials.UserName, Credentials.Name_Space, MetraTime.Now);
          
          IMTSecurity security = new MTSecurityClass();
          IMTCompositeCapability capability = security.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
          capability.GetAtomicEnumCapability().SetParameter("WRITE");
          capability.GetAtomicPathCapability().SetParameter(yaac.HierarchyPath, MTHierarchyPathWildCard.SINGLE);
          sessionContext.SecurityContext.CheckAccess((YAAC.IMTCompositeCapability)capability);

          success = true;
        }
        catch (Exception exp)
        {
          logger.LogException(String.Format("No 'Manage Account Hierarchies' capability for account {0}, {1} with write access.", Credentials.UserName, Credentials.Name_Space), exp);
        }
      }

      return success;
    }

    /// <summary>
    /// Is account visible in hierarchy and doesn't require manage account hierarchy capability
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    private bool IsNonHierarchyAccount(YAAC.IMTSessionContext sessionContext)
    {
      bool success = false;

      try
      {
        //Check that the user has the rights to change the password, based on the passed in session context
        YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
        accountCatalog.Init(sessionContext);
        YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(Credentials.UserName, Credentials.Name_Space, MetraTime.Now);
        
        AccountTypeManager accountTypeManager = new AccountTypeManager();
        IMTAccountType accountType = accountTypeManager.GetAccountTypeByName((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext, yaac.AccountType);

        if (!accountType.IsVisibleInHierarchy)
        {
          success = true;
        }
      }
      catch (Exception exp)
      {
        logger.LogException(String.Format("Error determining if account  {0}, {1} is not visible in hierarchy.", Credentials.UserName, Credentials.Name_Space), exp);
      }

      return success;
    }

    /// <summary>
    /// Update password in database
    /// </summary>
    /// <param name="plainTextPassword">New password for the user</param>
    /// <param name="sessionContext">Session context provide additional information for the audit.</param>
    private void UpdatePasswordExtended(string plainTextPassword, IMTSessionContext sessionContext)
    {
      Auditor auditor = new Auditor();

      string hashedPassword = HashNewPassword(plainTextPassword);

      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, 
                                                           new TransactionOptions(), 
                                                           EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__SECURITY_UPDATE_PASSWORD__"))
            {

              stmt.AddParam("%%USERNAME%%", Credentials.UserName);
              stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
              stmt.AddParam("%%HASHED_PASSWORD%%", hashedPassword);
              stmt.ExecuteNonQuery();
            }

          SetPasswordExpiryDate();
          RecordPasswordHistory();
          
          // Audit Successful Change Password
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_CHANGE_PASSWORD_SUCCESS,
                             sessionContext.AccountID, 
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                             sessionContext.AccountID,
                             String.Format("Change password successful for username={0} namespace={1}", Credentials.UserName, Credentials.Name_Space), 
                             sessionContext.LoggedInAs, 
                             sessionContext.ApplicationName);
        }
        scope.Complete();
      }
    }

    /// <summary>
    ///   Record Password History
    /// </summary>
    public void RecordPasswordHistory()
    {
      Credentials.AutoResetFailuresDate = MetraTime.Now.AddMinutes(PasswordConfig.GetInstance().MinutesBeforeAutoResetPassword);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__UPDATE_CREDENTIALS_HISTORY__"))
          {

            stmt.AddParam("%%USERNAME%%", Credentials.UserName);
            stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
            stmt.AddParam("%%PASSWORD_HASH%%", Credentials.PasswordHash);
            stmt.AddParam("%%END%%", MetraTime.Now);
            stmt.ExecuteNonQuery();
          }
      }
    }

    /// <summary>
    /// Check to see if the password has been used before.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    private bool HasPasswordBeenUsedBefore(string plainTextPassword)
    {
      bool ret = false;
      List<string> usedHashes = new List<string>();

      // Don't allow the current password to be used again, even if it is not in the 
      // history (which is the case for newly created accounts that haven't yet changed their password).
      usedHashes.Add(Credentials.PasswordHash);

      // Get the last N (determined by config) passwords and add them to the list of used passwords
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__SECURITY_PASSWORDS_ALREADY_USED__"))
          {

            stmt.AddParam("%%ROW_COUNT%%", PasswordConfig.GetInstance().NumberOfLastPasswordsThatAreUnique);
            stmt.AddParam("%%USERNAME%%", Credentials.UserName);
            stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      usedHashes.Add(reader.GetString("tx_password"));
                  }
              }
          }
      }

      // Has the proposed new password been used before with any key
      foreach (string h in usedHashes)
      {
        string keyId = crypto.ParseKeyFromHash(h);
        string saltedPassword = SaltPassword(plainTextPassword);
        string newHashedPassword = crypto.HashWithKey(HashKeyClass.PasswordHash, keyId, saltedPassword);
        if (usedHashes.Contains(newHashedPassword))
        {
          ret = true;
        }
      }

      return ret;
    }

    /// <summary>
    ///  Prepare plain text password for hash
    ///  Run MD5 Hash on clear text password
    ///  Append username and namespace as salt
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    private string SaltPassword(string plainTextPassword)
    {
      string md5Hash = GetMD5(plainTextPassword);
      string saltedPassword = md5Hash + Credentials.UserName.ToLower() + Credentials.Name_Space.ToLower();
      return saltedPassword;
    }

    /// <summary>
    ///   GetMD5
    /// </summary>
    /// <param name="plainText"></param>
    /// <returns></returns>
    public string GetMD5(string plainText)
    {
      using (MD5 md5Hasher = MD5.Create())
      {
        // Convert the input string to a byte array and compute the hash.
        byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(plainText));

        // Create a new Stringbuilder to collect the bytes and create a string.
        StringBuilder builder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
          builder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return builder.ToString();
      }
    }
    #endregion

  }
}
