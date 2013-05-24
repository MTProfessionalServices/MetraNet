using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.RCD;
using YAAC = MetraTech.Interop.MTYAAC;

namespace MetraTech.Security
{
  /// <summary>
  ///   EmailTemplate
  /// </summary>
  [Serializable]
  [ComVisible(false)]
  public class EmailTemplate
  {
    /// <summary>
    ///    MailStructs
    /// </summary>
    public List<MailStruct> MailStructs = new List<MailStruct>();
  }

  /// <summary>
  ///    MailStruct
  /// </summary>
  [Serializable]
  [ComVisible(false)]
  public class MailStruct
  {
    /// <summary>
    ///   language
    /// </summary>    
    public string language;
    /// <summary>
    ///   default_headers
    /// </summary>
    public DefaultHeaders default_headers;
    /// <summary>
    ///   message_body
    /// </summary>
    public string message_body;
  }

  /// <summary>
  ///   DefaultHeaders
  /// </summary>
  [Serializable]
  [ComVisible(false)]
  public class DefaultHeaders
  {
    /// <summary>
    ///   body_html
    /// </summary>
    public Int32 body_html;
    /// <summary>
    ///  def_from
    /// </summary>
    public string def_from;
    /// <summary>
    ///   def_to
    /// </summary>
    public string def_to;
    /// <summary>
    ///   def_subject
    /// </summary>
    public string def_subject;
    /// <summary>
    ///   def_cc
    /// </summary>
    public string def_cc;
    /// <summary>
    ///   def_bcc
    /// </summary>
    public string def_bcc;
    /// <summary>
    ///   def_importance
    /// </summary>
    public Int32 def_importance;
  }

  /// <summary>
  /// Provides a base for password managers.
  /// </summary>
  public abstract class PasswordManagerBase : IPasswordManager
  {
    #region Data

    protected const string queryPath = @"Queries\Security";
    private Credentials credentials = null;

    #endregion

    #region Properties

    /// <summary>
    /// Gets or internally sets the Credentials object to be managed.
    /// </summary>
    public Credentials Credentials
    {
      get
      {
        return credentials;
      }
      protected set
      {
        credentials = value;
      }
    }

    /// <summary>
    /// Gets an instance of the <see cref="Logger"/> object to be used for the password management logging activities.
    /// </summary>
    protected abstract Logger Logger
    {
      get;
    }

    #endregion

    #region IPasswordManager Members

    #region Abstract methods

    /// <summary>
    ///   Initialize
    /// </summary>
    /// <param name="credentials"></param>
    public virtual void Initialize(Credentials credentials)
    {
      if (credentials == null)
        throw new ArgumentNullException("Credentials for initialize password manager is null!");

      Credentials = credentials;
    }

    public abstract string HashNewPassword(string plainTextPassword);

    public abstract bool IsPasswordValid(string plainTextPassword);

    public abstract bool IsNewAccount();

    public abstract int DaysUntilPasswordExpires();

    public abstract bool ChangePassword(string password, string newPassword, Interop.MTAuth.IMTSessionContext sessionContext);

    public abstract bool UnlockAccount(Interop.MTAuth.IMTSessionContext sessionContext);

    public abstract bool LockAccount(Interop.MTAuth.IMTSessionContext sessionContext);

    public abstract bool CheckPasswordStrength(string plainTextPassword);

    public abstract void SetPasswordExpiryDate();

    public abstract string GeneratePassword();

    public abstract void UpdatePassword(string password, Interop.MTAuth.IMTSessionContext sessionContext);

    #endregion

    #region Base implementation

    /// <summary>
    ///   Record a login failure.
    /// </summary>
    public void RecordLoginFailure()
    {
      // (a) MetraTime.Now + passwordManager.Config.MinutesBeforeAutoResetPassword = dt_auto_reset_failures
      // (b) Bump up num_failures_since_login 
      Credentials.AutoResetFailuresDate = MetraTime.Now.AddMinutes(PasswordConfig.GetInstance().MinutesBeforeAutoResetPassword);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__UPDATE_LOGIN_FAILURE__"))
        {

          stmt.AddParam("%%USERNAME%%", Credentials.UserName);
          stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
          stmt.AddParam("%%AUTO_RESET_FAILURE_DATE%%", Credentials.AutoResetFailuresDate.Value);

          stmt.ExecuteNonQuery();
        }
      }
    }

    /// <summary>
    ///   Record a login success.
    /// </summary>
    public void RecordSuccessfulLogin()
    {
      // (a) dt_auto_reset_failures = null
      // (b) num_failures_since_login = 0
      // (c) dt_last_login = MetraTime.Now

      Credentials.AutoResetFailuresDate = MetraTime.Now.AddMinutes(PasswordConfig.GetInstance().MinutesBeforeAutoResetPassword);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(queryPath, "__UPDATE_LOGIN_SUCCESS__"))
        {

          stmt.AddParam("%%USERNAME%%", Credentials.UserName);
          stmt.AddParam("%%NAME_SPACE%%", Credentials.Name_Space);
          stmt.ExecuteNonQuery();
        }
      }
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
      bool ret = false;

      YAAC.IMTYAAC objYAAC;
      YAAC.MTAccountCatalogClass objAccountCatalog = new YAAC.MTAccountCatalogClass();
      objAccountCatalog.Init((YAAC.IMTSessionContext)LoginAsSU());
      objYAAC = objAccountCatalog.GetActorAccount(MetraTime.Now);

      switch (objYAAC.AccountType.ToLower())
      {
        case "systemaccount":
          // Has the account been dormant for too long?  For System Account's this means not logged in.
          TimeSpan dormant = new TimeSpan(0);
          if (Credentials.LastLoginDate != null)
          {
            dormant = MetraTime.Now.Subtract(Credentials.LastLoginDate.Value);
          }

          if (dormant.Days > PasswordConfig.GetInstance().DaysOfInactivityBeforeAccountLocked)
          {
            ret = true;
          }
          break;

        default:
          // Define dormant as:  is the account configured to login to MetraView in it's current state.
          YAAC.IMTAccountStateManager accStateMgr = objYAAC.GetAccountStateMgr();
          YAAC.IMTAccountStateInterface state = accStateMgr.GetStateObject();
          if (state.CanLoginToMetraView())
          {
            ret = true;
          }
          break;
      }

      return ret;
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
      try
      {
        IMTRcd rcd = new MTRcd();
        string path = rcd.ConfigDir + "EmailTemplate\\UpdatePasswordEMailNotificationTemplate.xml";
        if (!File.Exists(path))
        {
          throw new ApplicationException(String.Format("Unable to locate the email template file '{0}'", path));
        }

        EmailTemplate et;

        using (TextReader r = new StreamReader(path))
        {
          XmlSerializer xs = new XmlSerializer(typeof(EmailTemplate));
          et = (EmailTemplate)xs.Deserialize(r);
        }

        bool mailSent = false;

        foreach (MailStruct mst in et.MailStructs)
        {
          if (mst.language.ToUpper() == languageCode.ToUpper())
          {
            StringBuilder Body = new StringBuilder();
            Body.Append(mst.message_body);

            Body.Replace("%%FIRSTNAME%%", firstName);
            Body.Replace("%%LASTNAME%%", lastName);
            Body.Replace("%%PASSWORD%%", password);
            Body.Replace("%%TIME%%", updateTime.ToLongDateString());

            MailMessage mail = new MailMessage();

            mail.From = new MailAddress(mst.default_headers.def_from);
            mail.To.Add(new MailAddress(emailAddress));
            if (mst.default_headers.def_cc != "")
            {
              mail.CC.Add(new MailAddress(mst.default_headers.def_cc));
            }

            if (mst.default_headers.def_bcc != "")
            {
              mail.Bcc.Add(new MailAddress(mst.default_headers.def_bcc));
            }
            mail.Subject = mst.default_headers.def_subject;
            if (mst.default_headers.body_html == 0)
            {
              mail.IsBodyHtml = true;
            }
            if (mst.default_headers.def_importance == 1)
            {
              mail.Priority = MailPriority.High;
            }
            mail.Body = Body.ToString();

            //Setup SMTP Client
            System.Net.Mail.SmtpClient sc = new SmtpClient();
            sc.Host = GetSmtpHost();

            if (String.IsNullOrEmpty(sc.Host))
            {
              throw new ApplicationException(String.Format("Unable to locate mail server"));
            }

            //Send the mail
            sc.Send(mail);

            Console.WriteLine("Mail sent");

            mailSent = true;
          }
        }

        if (!mailSent)
        {
          throw new ApplicationException(String.Format("Unable to locate email template for username '{0}' and namespace '{1}' and language code '{2}'", Credentials.UserName, Credentials.Name_Space, languageCode));
        }
      }
      catch (Exception e)
      {
        Logger.LogException(String.Format("Unable to send password update email for username '{0}' and namespace '{1}'", Credentials.UserName, Credentials.Name_Space), e);
        throw;
      }
    }

    #endregion

    #endregion

    #region Private methods

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

    /// <summary>
    ///   Return the first SMTP host from the config files by searching in the following order:
    ///   (1) Look for "MailRelay" element in servers.xml 
    ///   (2) Look for "address" element in RMP\config\email\email.xml
    /// </summary>
    /// <returns></returns>
    private string GetSmtpHost()
    {
      string host = String.Empty;

      IMTServerAccessDataSet serverAccess = new MTServerAccessDataSetClass();
      serverAccess.Initialize();
      IMTServerAccessData serverData = serverAccess.FindAndReturnObjectIfExists("MailRelay");
      if (serverData != null)
      {
        host = serverData.ServerName;
      }
      else
      {
        IMTRcd rcd = new MTRcd();
        string path = rcd.ConfigDir + "email\\email.xml";
        if (File.Exists(path))
        {
          XmlDocument doc = new XmlDocument();
          doc.Load(path);
          XmlNode addressNode = doc.SelectSingleNode("//smtp_server/address");
          host = addressNode.InnerText.Trim();
        }
      }

      return host;
    }

    #endregion
  }
}
