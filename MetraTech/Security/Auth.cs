using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.Transactions;

using MetraTech;
using MetraTech.Interop.MTAuth;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.Security.Crypto;
using MetraTech.Interop.comticketagent;
using MetraTech.Interop.COMSecureStore;
using MetraTech.Interop.RCD;
using System.Web;
using MetraTech.Interop.MTServerAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;

[assembly: Guid("469EACD7-1E5B-4910-8D5C-9A3F86572B7C")]
namespace MetraTech.Security
{
  #region Enums
  /// <summary>
  /// Possible return status of login method.
  /// </summary>
  [Guid("E92C0028-6E0A-4e7e-B62E-A44766F4550E")]
  public enum LoginStatus 
  {
    /// <summary>
    ///   OK
    /// </summary>
    OK = 100,
    /// <summary>
    ///   OKPasswordExpiringSoon
    /// </summary>
    OKPasswordExpiringSoon = 101,
    /// <summary>
    ///   FailedPasswordExpired
    /// </summary>
    FailedPasswordExpired = 200,
    /// <summary>
    ///   FailedUsernameOrPassword
    /// </summary>
    FailedUsernameOrPassword = 201,
    /// <summary>
    ///   Username is Locked. For instance too many failed login attempts
    /// </summary>
    FailedUsernameIsLocked = 202,
    /// <summary>
    ///   NoCapabilityToLogonToThisApplication
    /// </summary>
    NoCapabilityToLogonToThisApplication = 300
  }
  #endregion

  #region Interface
  /// <summary>
  /// 
  /// </summary>
  [Guid("A69BF9CB-1056-4df5-A937-0BDAA5FF602F")]
  public interface IAuth
  {
    /// <summary>
    ///   Initialize
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="name_space"></param>
    void Initialize(string userName, string name_space);

    /// <summary>
    /// Initialize with additional data
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="name_space"></param>
    /// <param name="loggedInAs"></param>
    /// <param name="applicationName"></param>
    void Initialize(string userName, string name_space, string loggedInAs, string applicationName);

    /// <summary>
    ///   Login
    /// </summary>
    /// <param name="password"></param>
    /// <param name="application"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    LoginStatus Login(string password, string application, ref object sessionContext /* IMTSessionContext */);
    
    /// <summary>
    ///    LoginWithTicket
    /// </summary>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    LoginStatus LoginWithTicket(string ticket, ref object sessionContext /* IMTSessionContext */);
    /// <summary>
    ///   CreateTicket
    /// </summary>
    /// <returns></returns>
    string CreateTicket();
    /// <summary>
    ///   CreateTicket No Expire
    /// </summary>
    /// <returns></returns>
    string CreateTicketNoExpire();
    /// <summary>
    ///   CreateEntryPoint
    /// </summary>
    /// <param name="application"></param>
    /// <param name="name_spaceType"></param>
    /// <param name="accountIDToLoad"></param>
    /// <param name="url"></param>
    /// <param name="loadFrame"></param>
    /// <param name="isNewMetraCare"></param>
    /// <returns></returns>
    string CreateEntryPoint(string application, string name_spaceType, int accountIDToLoad, string url, bool loadFrame, bool isNewMetraCare);

    string EncryptStringData(string data);
    string DecryptStringData(string encryptedData);

    #region IPasswordManager members re-declaration

    /// <summary>
    /// Gets a <see cref="Credentials"/> object.
    /// </summary>
    Credentials Credentials
    {
      get;
    }

    /// <summary>
    /// Initialize
    /// </summary>
    /// <param name="credentials"></param>
    void Initialize(Credentials credentials);
    /// <summary>
    /// HashNewPassword
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    string HashNewPassword(string plainTextPassword);
    /// <summary>
    /// IsPasswordValid
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    bool IsPasswordValid(string plainTextPassword);
    /// <summary>
    /// DaysUntilPasswordExpires
    /// </summary>
    /// <returns></returns>
    int DaysUntilPasswordExpires();
    /// <summary>
    /// ChangePassword
    /// </summary>
    /// <param name="password"></param>
    /// <param name="newPassword"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool ChangePassword(string password, string newPassword, IMTSessionContext sessionContext);
    /// <summary>
    /// UnlockAccount
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool UnlockAccount(IMTSessionContext sessionContext);
    /// <summary>
    /// LockAccount
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    bool LockAccount(IMTSessionContext sessionContext);
    /// <summary>
    /// CheckPasswordStrength
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    bool CheckPasswordStrength(string plainTextPassword);
    /// <summary>
    /// SetPasswordExpiryDate
    /// </summary>
    void SetPasswordExpiryDate();
    /// <summary>
    ///   RecordLoginFailure
    /// </summary>
    void RecordLoginFailure();
    /// <summary>
    ///   RecordSuccessfulLogin
    /// </summary>
    void RecordSuccessfulLogin();
    /// <summary>
    ///   CheckIfAccountIsDormant
    /// </summary>
    /// <returns></returns>
    bool CheckIfAccountIsDormant();
    /// <summary>
    ///   IsNewAccount
    /// </summary>
    /// <returns></returns>
    bool IsNewAccount();
    /// <summary>
    ///   GeneratePassword
    /// </summary>
    /// <returns></returns>
    string GeneratePassword();

    /// <summary>
    ///   Update the existing password with the given plain text password.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="sessionContext"></param>
    void UpdatePassword(string password, IMTSessionContext sessionContext);

    /// <summary>
    ///    Email the given password using the email template in RMP\config\emailtemplate\UpdatePasswordEMailNotificationTemplate.xml
    /// </summary>
    /// <param name="emailAddress"></param>
    /// <param name="firstName"></param>
    /// <param name="lastName"></param>
    /// <param name="password"></param>
    /// <param name="updateTime"></param>
    /// <param name="languageCode"></param>
    /// <param name="sessionContext"></param>
    void EmailPasswordUpdate(string emailAddress,
                             string firstName,
                             string lastName,
                             string password,
                             DateTime updateTime,
                             string languageCode,
                             IMTSessionContext sessionContext);

    #endregion
  }

  #endregion

  #region IAuth implementation
  /// <summary>
  /// 
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("B3886E01-06A5-47c8-BF09-4C02D45D7DBC")]
  public class Auth : IAuth, IPasswordManager
  {
    #region Data
    private IPasswordManager passwordManager;
    private CryptoManager crypto = new CryptoManager();
    private Logger logger = new Logger("[MetraTech.Security.Auth]");

    private string m_loggedInAs;
    private string m_applicationName;

    /// <summary>
    /// Internally gets or sets the instance of a class implementing the <see cref="IPasswordManager"/> interface
    /// </summary>
    private IPasswordManager PasswordManager
    {
      get
      {
        if (this.passwordManager == null)
        {
          throw new ApplicationException("Auth instance not initialized. Call Initialize method at first.");
        }

        return this.passwordManager;
      }
      set
      {
        this.passwordManager = value;
      }
    }

    /// <summary>
    /// Gets the <see cref="Credentials"/> object the password manager is initialized with.
    /// </summary>
    public Credentials Credentials
    {
      get
      {
        return PasswordManager.Credentials;
      }
    }

    #endregion

    #region Public Methods

    /// <summary>
    ///    Initialize
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="name_space"></param>
    public void Initialize(string userName, string name_space)
    {
      Credentials cr = new Credentials(userName, name_space);

      ((IPasswordManager)this).Initialize(cr);
    }

    /// <summary>
    /// Initialize with additional data
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="name_space"></param>
    /// <param name="loggedInAs"></param>
    /// <param name="applicationName"></param>
    public void Initialize(string userName, string name_space, string loggedInAs, string applicationName)
    {
      m_loggedInAs = loggedInAs;
      m_applicationName = applicationName;

      Initialize(userName, name_space);
    }

    /// <summary>
    /// Login to MetraNet application.  Populates a valid SessionContext on success.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="application"></param>
    /// <param name="sessionContext"></param>
    /// <returns>LoginStatus.OK or LoginStatus.OKPasswordExpiringSoon on success.</returns>
    public LoginStatus Login(string password, string application,  ref object sessionContext)
    {
      Auditor auditor = new Auditor();
      Credentials credentials = PasswordManager.Credentials;

      //If the account does not exist in the system
      if (credentials.AuthenticationType == AuthenticationType.MetraNetInternal && credentials.PasswordHash == null)
      {        
            PasswordManager.RecordLoginFailure();
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_FAILED,
                               -1,
                               (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                               -1,
                               String.Format("Login failed for username={0} namespace={1}. Invalid Account State.", credentials.UserName, credentials.Name_Space));

            return LoginStatus.FailedUsernameOrPassword;
      }      
      
      // Has the account been dormant for too long?
      if (PasswordManager.CheckIfAccountIsDormant())
      {
        auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_DORMANT_ACCOUNT_FAILED,
                   -1, 
                   (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                   -1,
                   String.Format("Login failed for username={0} namespace={1}", credentials.UserName, credentials.Name_Space));

        return LoginStatus.FailedPasswordExpired;
      }
      
      // Set the password expiry date the first time the user logs in
      if (credentials.ExpireDate == null)
      {
        PasswordManager.SetPasswordExpiryDate();
      }
      else
      {
        // Has password expired?
        if (MetraTime.Now > credentials.ExpireDate)
        {
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_PASSWORD_EXPIRED_FAILED,
                             -1, 
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                             -1,
                             String.Format("Login failed for username={0} namespace={1}", credentials.UserName, credentials.Name_Space));
          
          return LoginStatus.FailedPasswordExpired;
        }
      }
      
      // Make sure account is not locked, and not too many login attempts
      if (!credentials.IsEnabled || credentials.NumberOfFailuresSinceLogin >= PasswordConfig.GetInstance().LoginAttemptsAllowed)
      {
        // Check if time to auto unlock account
        if (MetraTime.Now > credentials.AutoResetFailuresDate)
        {
          bool result = PasswordManager.UnlockAccount(LoginAsSU());
        }
        else
        {
          PasswordManager.RecordLoginFailure();
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_ACCOUNT_LOCKED_FAILED,
                             -1, 
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                             -1,
                             String.Format("Login failed for username={0} namespace={1}", credentials.UserName, credentials.Name_Space)); 
          return LoginStatus.FailedUsernameIsLocked;
        }
      }

      bool areHashesEqual = PasswordManager.IsPasswordValid(password);
          
      // Compare existing hash value to new hash
      if (areHashesEqual)
      {
        // sessionContext = GetSessionContext(credentials.UserName, credentials.Name_Space);
        // TODO:  Get SessionContext and set it, can do this directly now instead of using IMTLoginContext.  Note: we tried this and it had problems.  Code commented below.
        IMTLoginContext loginContext = new MTLoginContextClass();
        if (!string.IsNullOrEmpty(m_loggedInAs) || !string.IsNullOrEmpty(m_applicationName))
        {
          sessionContext = loginContext.LoginWithAdditionalData(PasswordManager.Credentials.UserName, PasswordManager.Credentials.Name_Space, password, m_loggedInAs, m_applicationName);
        }
        else
        {
          sessionContext = loginContext.Login(PasswordManager.Credentials.UserName, PasswordManager.Credentials.Name_Space, password);
        }

        // Check capability for login to the specified application is allowed
        if (application != null)
        {
          if (!HasAppLoginCapability((YAAC.IMTSessionContext)sessionContext, application))
          {
            PasswordManager.RecordLoginFailure();
            auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_NO_CAPABILITY_FAILED,
                               -1,
                               (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                               -1,
                               String.Format("Login failed for username={0} namespace={1}", credentials.UserName, credentials.Name_Space));
            return LoginStatus.NoCapabilityToLogonToThisApplication;
          }
        }

        if (!CheckAccountState((YAAC.IMTSessionContext)sessionContext))
        {
          PasswordManager.RecordLoginFailure();
          auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_FAILED,
                             -1,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                             -1,
                             String.Format("Login failed for username={0} namespace={1}. Invalid Account State.", credentials.UserName, credentials.Name_Space));

          return LoginStatus.FailedUsernameOrPassword;
        }
      
        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required,
                                                             new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          PasswordManager.RecordSuccessfulLogin();

          // Audit successful login
          // CORE-3843
          auditor.FireEventWithAdditionalData((int)MTAuditEvent.AUDITEVENT_LOGIN_SUCCESS,
                             ((IMTSessionContext)sessionContext).AccountID,
                             (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                             ((IMTSessionContext)sessionContext).AccountID,
                             String.Format("Login successful for username={0} namespace={1}", credentials.UserName, credentials.Name_Space),
                             ((IMTSessionContext)sessionContext).LoggedInAs, 
                             ((IMTSessionContext)sessionContext).ApplicationName);
          scope.Complete();
        }
        
        // New accounts should change their password
        if (PasswordManager.IsNewAccount())
        {
          return LoginStatus.OKPasswordExpiringSoon;
        }

        if (((System.DateTime)(credentials.ExpireDate)).Subtract(MetraTime.Now).Days < PasswordConfig.GetInstance().DaysToStartWarningPasswordWillExpire) 
        {
          return LoginStatus.OKPasswordExpiringSoon;
        }
        else
        {
          return LoginStatus.OK;
        }
      }
      else
      {
        PasswordManager.RecordLoginFailure();
        auditor.FireFailureEvent((int)MTAuditEvent.AUDITEVENT_LOGIN_FAILED,
                           -1, 
                           (int)MTAuditEntityType.AUDITENTITY_TYPE_LOGIN,
                           -1,
                           String.Format("Login failed for username={0} namespace={1}", credentials.UserName, credentials.Name_Space)); 
        return LoginStatus.FailedUsernameOrPassword;
      }

      #region pseudo code
      /*
      Begin Login
      
      Check if password has expired and return LoginStatus.FAILED_PASSWORD_EXPIRED
       
      // Make sure account is not locked 
      If Account Locked Then

        // Check if time to auto unlock account
        If reset lock time Then
          MetraTech.Security.Auth.UnlockAccount()
        Else
          Update database failed login
          return LoginStatus.FAILED_PASSWORD_EXPIRED
        End If 
      End If

      // Get existing hash
      Look up existing password hash for username and namespace in netmeter database (t_user_credentials)

      // Create new hash with old key (New hash algorithm)
      Call MetraTech.Security.Hash.ParseKeyFromHash to get the key id used in the hash
      Run MD5 Hash on clear text password
      Append username and namespace as salt
      Call MetraTech.Security.Hash.HashString with buffer and key id

      //Compare existing hash value to new hash
      If existing hash value equals new hash value Then
         
        // Check if login to the specified application is allowed
        If application != null Then
         // Check login capability
         If no cap Then   
           Update database failed login  
           return LoginStatus.NO_CAPABILITY_TO_LOG_ON_TO_THIS_APPLICATION
         End If
        End If

        Get SessionContext and set it
        Update database successful login (this includes t_user_credentials - dt_last_login, num_failures_since_login, dt_auto_reset_failures, b_enabled, and t_user_credentials_audit)
        
        // Check if password is expiring soon
        If expiring in 14 days or less Then
          return LoginStatus.OK_PASSWORD_EXPIRING_SOON 
        Else
          return LoginStatus.OK
        End If
      Else
        Update database failed login
        Return LoginStatus.FAILED_USERNAME_OR_PASSWORD
      End If

      SessionContext = null
      Throw any exceptions
    End Login 
    */
      #endregion

    }

    /// <summary>
    /// Tries to login with the supplied ticket.  Returns either LoginStatus.OK or LoginStatus.FailedUsernameOrPassword.
    /// Returns populated session context on successful login.  It is passed in ByRef and Variant so it can be used in asp script as well.
    /// </summary>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    public LoginStatus LoginWithTicket(string ticket, ref object sessionContext)
    {
      LoginStatus ret = LoginStatus.FailedUsernameOrPassword;
      try
      {
        IMTLoginContext loginContext = new MTLoginContextClass();
        sessionContext = loginContext.LoginWithTicket(PasswordManager.Credentials.Name_Space, ticket);
        if (sessionContext != null)
        {
          ret = LoginStatus.OK;
        }
      }
      catch (Exception e)
      {
        logger.LogDebug(e.Message);
      }

      return ret;
    }

    /// <summary>
    /// Creates a ticket for login, based on the credentials supplied to initialize.
    /// </summary>
    /// <returns></returns>
    public string CreateTicket()
    {
      string ticket = "";

      ITicketAgent ticketAgent = GetTicketAgent();

      // Create the ticket
      if (!string.IsNullOrEmpty(m_loggedInAs) || !string.IsNullOrEmpty(m_applicationName))
      {
        ticket = ticketAgent.CreateTicketWithAdditionalData(PasswordManager.Credentials.Name_Space, PasswordManager.Credentials.UserName, 1200, m_loggedInAs, m_applicationName);
      }
      else
      {
        ticket = ticketAgent.CreateTicket(PasswordManager.Credentials.Name_Space, PasswordManager.Credentials.UserName, 1200);
      }

      return ticket;
    }

    /// <summary>
    /// Creates a ticket for login, based on the credentials supplied to initialize.
    /// </summary>
    /// <returns></returns>
    public string CreateTicketNoExpire()
    {
      string ticket = "";

      ITicketAgent ticketAgent = GetTicketAgent();

      // Create the ticket
      ticket = ticketAgent.CreateTicket(PasswordManager.Credentials.Name_Space, PasswordManager.Credentials.UserName, 0);

      return ticket;
    }

    /// <summary>
    /// Returns a URL that can be used to login to a MetraNet application.
    /// </summary>
    /// <param name="application"></param>
    /// <param name="name_spaceType"></param>
    /// <param name="accountIDToLoad"></param>
    /// <param name="url"></param>
    /// <param name="loadFrame"></param>
    /// <param name="isNewMetraCare"></param>
    /// <returns></returns>
    public string CreateEntryPoint(string application, string name_spaceType, int accountIDToLoad, string url, bool loadFrame, bool isNewMetraCare)
    {
      string ticket = "";
      try
      {
        ITicketAgent ticketAgent = GetTicketAgent();

        // Create the ticket
        ticket = ticketAgent.CreateTicket(PasswordManager.Credentials.Name_Space, PasswordManager.Credentials.UserName, 1200);

        // Build the URL
        if (accountIDToLoad.ToString() != "0")
        {
          url = String.Format("/{0}/EntryPoint.asp?logon={1}" +
                              "&namespace={2}" +
                              "&ticket={3}" +
                              "&AccountID={4}" +
                              "&namespaceType={5}" +
                              "&loadFrame={6}" +
                              "&URL={7}&isNewMetraCare={8}", HttpUtility.UrlEncode(application),
                                          HttpUtility.UrlEncode(PasswordManager.Credentials.UserName),
                                          HttpUtility.UrlEncode(PasswordManager.Credentials.Name_Space),
                                          HttpUtility.UrlEncode(ticket),
                                          HttpUtility.UrlEncode(accountIDToLoad.ToString()),
                                          HttpUtility.UrlEncode(name_spaceType),
                                          HttpUtility.UrlEncode(loadFrame.ToString()),
                                          HttpUtility.UrlEncode(url),
                                          HttpUtility.UrlEncode(isNewMetraCare.ToString()));
        }
        else
        {
          url = String.Format("/{0}/EntryPoint.asp?logon={1}" +
                              "&namespace={2}" +
                              "&ticket={3}" +
                              "&namespaceType={4}" +
                              "&loadFrame={5}" +
                              "&URL={6}&isNewMetraCare={7}", HttpUtility.UrlEncode(application),
                                          HttpUtility.UrlEncode(PasswordManager.Credentials.UserName),
                                          HttpUtility.UrlEncode(PasswordManager.Credentials.Name_Space),
                                          HttpUtility.UrlEncode(ticket),
                                          HttpUtility.UrlEncode(name_spaceType),
                                          HttpUtility.UrlEncode(loadFrame.ToString()),
                                          HttpUtility.UrlEncode(url),
                                          HttpUtility.UrlEncode(isNewMetraCare.ToString()));
        }
      }
      catch (Exception e)
      {
        logger.LogException(String.Format("Error creating entry point. {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}",
                                           application,  
                                           name_spaceType,  
                                           accountIDToLoad.ToString(), 
                                           url, 
                                           loadFrame.ToString(), 
                                           isNewMetraCare.ToString(),
                                           PasswordManager.Credentials.UserName,
                                           PasswordManager.Credentials.Name_Space), e);
        throw;
      }
      return url;
    }

    /// <summary>
    /// Gets if the account the object is instantiated for is new.
    /// </summary>
    /// <returns></returns>
    public bool IsNewAccount()
    {
      return PasswordManager.IsNewAccount();
    }

    /// <summary>
    /// Checks if the indicated value satisfies password strength requirements.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public bool CheckPasswordStrength(string plainTextPassword)
    {
      return PasswordManager.CheckPasswordStrength(plainTextPassword);
    }

    /// <summary>
    /// Changes the password of the account the object is instantiated for.
    /// </summary>
    /// <param name="password">Old password.</param>
    /// <param name="newPassword">New password.</param>
    /// <param name="sessionContext">Current session context.</param>
    /// <returns></returns>
    public bool ChangePassword(string password, string newPassword, IMTSessionContext sessionContext)
    {
      return PasswordManager.ChangePassword(password, newPassword, sessionContext);
    }

    /// <summary>
    ///    Email the given password using the email template in RMP\config\emailtemplate\UpdatePasswordEMailNotificationTemplate.xml
    /// </summary>
    /// <param name="emailAddress">An address to send email to.</param>
    /// <param name="firstName">First name of the recipient.</param>
    /// <param name="lastName">Last name of the recipient.</param>
    /// <param name="password">A recipient's password.</param>
    /// <param name="updateTime">Time when the password was updated.</param>
    /// <param name="languageCode">A value indicating the email language.</param>
    /// <param name="sessionContext">The current session context.</param>
    public void EmailPasswordUpdate(string emailAddress,
                             string firstName,
                             string lastName,
                             string password,
                             DateTime updateTime,
                             string languageCode,
                             IMTSessionContext sessionContext)
    {
      PasswordManager.EmailPasswordUpdate(emailAddress, firstName, lastName, password, updateTime, languageCode, sessionContext);
    }

    /// <summary>
    /// Creates a Hashed password based on the plain text, and username and name_space salt.
    /// And a NEW key.  Should not be used to compare password hashes.  Instead use Metratech.Security.Crypto.CompareHash.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public string HashNewPassword(string plainTextPassword)
    {
      return PasswordManager.HashNewPassword(plainTextPassword);
    }

    /// <summary>
    ///   Check if the specified password is valid.
    /// </summary>
    /// <param name="plainTextPassword"></param>
    /// <returns></returns>
    public bool IsPasswordValid(string plainTextPassword)
    {
      return PasswordManager.IsPasswordValid(plainTextPassword);
    }

    /// <summary>
    ///   Update the existing password with the given plain text password.  It will be set to expire, so it must be changed on next login.
    /// </summary>
    /// <param name="password"></param>
    /// <param name="sessionContext"></param>
    public void UpdatePassword(string password, IMTSessionContext sessionContext)
    {
      PasswordManager.UpdatePassword(password, sessionContext);
    }

    /// <summary>
    /// Generate a strong password without ambiguos characters
    /// </summary>
    /// <returns></returns>
    public string GeneratePassword()
    {
      return PasswordManager.GeneratePassword();
    }

    /// <summary>
    /// Check if the account is dormant.  
    /// Right now there is a small difference between system users and other accounts.  
    /// The difference is the definition of dormant or inactive.  Sytem users define it
    /// as last login was more days than the DaysOfInactivityBeforeAccountLocked, but
    /// other account types base this on the account state information (CanLoginToMetraView).
    /// </summary>
    /// <returns></returns>
    public bool CheckIfAccountIsDormant()
    {
      return PasswordManager.CheckIfAccountIsDormant();
    }

    /// <summary>
    ///   Record a login success.
    /// </summary>
    public void RecordSuccessfulLogin()
    {
      PasswordManager.RecordSuccessfulLogin();
    }

    /// <summary>
    ///   Record a login failure.
    /// </summary>
    public void RecordLoginFailure()
    {
      PasswordManager.RecordLoginFailure();
    }

    /// <summary>
    ///   Set a new password expiry date based on configuration data.
    /// </summary>
    public void SetPasswordExpiryDate()
    {
      PasswordManager.SetPasswordExpiryDate();
    }

    /// <summary>
    /// Lock account - Sets b_enabled to 'N' on t_user_credentials and will prevent login.
    /// </summary>
    /// <returns></returns>
    public bool LockAccount(IMTSessionContext sessionContext)
    {
      return PasswordManager.LockAccount(sessionContext);
    }

    /// <summary>
    /// Unlock account - this resets the num_failures_since_login to 0 and sets b_enabled to 'Y'
    /// </summary>
    /// <returns></returns>
    public bool UnlockAccount(IMTSessionContext sessionContext)
    {
      return PasswordManager.UnlockAccount(sessionContext);
    }

    /// <summary>
    /// Returns the number of days until the current password expires.
    /// </summary>
    /// <returns></returns>
    public int DaysUntilPasswordExpires()
    {
      return PasswordManager.DaysUntilPasswordExpires();
    }

    /// <summary>
    /// This method is implemented explicitly to hide it from managed code.
    /// </summary>
    /// <param name="credentials"></param>
    public void Initialize(Credentials credentials)
    {
      if (credentials == null)
      {
        throw new ArgumentNullException("credentials");
      }

      string passwordManagerTypeName = PasswordConfig.GetInstance().GetPasswordManagerTypeName(credentials.AuthenticationType.ToString());
      PasswordManager = (PasswordManagerBase)Activator.CreateInstance(Type.GetType(passwordManagerTypeName, true));

      PasswordManager.Initialize(credentials);
    }

    #endregion

    #region Private Methods

    /// <summary>
    /// Check if the session context passed in is in the proper state
    /// Returns false if is in the state that prevents logging in, or true otherwise
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <returns></returns>
    private bool CheckAccountState(YAAC.IMTSessionContext sessionContext)
    {
      bool success = false;

      try
      {
        YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
        accountCatalog.Init(sessionContext);
        YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(PasswordManager.Credentials.UserName, PasswordManager.Credentials.Name_Space, MetraTime.Now);

        // CORE-5711 Suspended account cannot login to MetraView 
        // Added vaidation for suspended account
        var stateObject = yaac.GetAccountStateMgr().GetStateObject();
        string accountState = stateObject.Name;

        if (accountState == "SU")
        {
          try
          {
            // Check if Suspended state has already finished.
            stateObject.CanChangeToActive(yaac.AccountID, MetraTime.Now);
            success = true;
          }
          catch (COMException)
          {
            // The CanChangeToActive method throws COMException if indicated account doesn't match the change status rule.
            success = false;
          }
        }
        else if ((accountState != "AC") && (accountState != "PA") && (accountState != "PF") && (accountState != "CL"))
        {
          success = false;
        }
        else
        {
          success = true;
        }
      }
      catch (Exception e)
      {
        logger.LogException(string.Format("Unable to check account state for account {0}",PasswordManager.Credentials.UserName), e);
      }

      return success;
    }
       

    /// <summary>
    /// Check that the session context passed in has the login capability for the app
    /// </summary>
    /// <param name="sessionContext"></param>
    /// <param name="app"></param>
    public bool HasAppLoginCapability(YAAC.IMTSessionContext sessionContext, string app)
    {
      bool success = false;

      try
      {
        //Check that the user has the rights to change the password, based on the passed in session context
        YAAC.IMTAccountCatalog accountCatalog = new YAAC.MTAccountCatalogClass();
        accountCatalog.Init(sessionContext);
        YAAC.IMTYAAC yaac = accountCatalog.GetAccountByName(PasswordManager.Credentials.UserName, PasswordManager.Credentials.Name_Space, MetraTime.Now);

        IMTSecurity security = new MTSecurityClass();
        IMTCompositeCapability capability = security.GetCapabilityTypeByName("Application LogOn").CreateInstance();
        capability.GetAtomicEnumCapability().SetParameter(app);
        sessionContext.SecurityContext.CheckAccess((YAAC.IMTCompositeCapability)capability);

        success = true;
      }
      catch (Exception ex)
      {
        logger.LogWarning(String.Format("No 'Application LogOn' capability for account {0}, {1} to {2}; {3} ", PasswordManager.Credentials.UserName, PasswordManager.Credentials.Name_Space, app, ex.Message));
      }

      return success;
    }

    /// <summary>
    /// Returns a ticket agent populated with the secure key.
    /// </summary>
    /// <returns></returns>
    private ITicketAgent GetTicketAgent()
    {
      ITicketAgent ticketAgent = new TicketAgentClass();

      try
      {
        IMTRcd rcd = new MTRcdClass();
        IGetProtectedProperty secureStore = new GetProtectedPropertyClass();

        // Initialize secure store 
        secureStore.Initialize("pipeline", rcd.ConfigDir + @"\serveraccess\protectedpropertylist.xml", "ticketagent");

        // Set the key
        ticketAgent.Key = secureStore.GetValue();
      }
      catch (Exception e)
      {
        logger.LogException("Error getting ticket agent.", e);
        throw;
      }
      return ticketAgent;
    }

    private IMTSessionContext LoginAsSU()
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = accessData.UserName;
      string suPassword = accessData.Password;
      return loginContext.Login(suName, "system_user", suPassword);
    }

    //private IMTSessionContext GetSessionContext(string userName, string name_space)
    //{
    //  IMTSessionContext sessionContext = new MTSessionContextClass();
    //  int accountId = 0;

    //  using (IMTConnection conn = ConnectionManager.CreateConnection())
    //  {
      //    using(IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\accountcreation", "__SELECT_ACCOUNT_ID__"))
      //    {

    //    stmt.AddParam("%%LOGIN_ID%%", userName);
    //    stmt.AddParam("%%NAME_SPACE%%", name_space);
       
    //    using (IMTDataReader reader = stmt.ExecuteReader())
    //    {
    //      if (reader.Read())
    //      {
    //        accountId = reader.GetInt32("id_acc");
    //      }
    //      else
    //      {
    //        string errorMessage = String.Format("Unable to find account id for username '{0}' and name space '{1}'", userName, name_space);
    //        logger.LogError(errorMessage);
    //        throw new ApplicationException(errorMessage);
    //      }
    //    }
      //  }
    //  }

    //  sessionContext.AccountID = accountId;
    //  MTSecurityContext securityContext = new MetraTech.Interop.MTAuth.MTSecurityContextClass();
    //  securityContext.AccountID = accountId;
    //  sessionContext.SecurityContext = securityContext;

    //  return sessionContext;
    //}
    #endregion


    #region IAuth Members


    public string EncryptStringData(string data)
    {
        return crypto.Encrypt(CryptKeyClass.Ticketing, data);
    }

    public string DecryptStringData(string encryptedData)
    {
        return crypto.Decrypt(CryptKeyClass.Ticketing, encryptedData);
    }

    #endregion
  }
  #endregion

}
