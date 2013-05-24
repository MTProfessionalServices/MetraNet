using System;
using System.Diagnostics;
using System.Reflection;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Transactions;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;

using MetraTech.DomainModel.Common;
using MetraTech.DataAccess;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.COMKiosk;
using MetraTech.Interop.Rowset;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using System.Xml;
using MetraTech.Xml;
using System.IO;
using System.Xml.Serialization;
using System.Net.Mail;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.RCD;
using System.Runtime.InteropServices;

namespace MetraTech.Core.Activities
{

  [Serializable]
  public class EmailTemplate
  {
    public List<MailStruct> MailStructs = new List<MailStruct>();
  }

  [Serializable]
  public class MailStruct
  {
    public string language;
    public DefaultHeaders default_headers;
    public string message_body;
    public Int32 selected = 1;
  }

  [Serializable]
  public class DefaultHeaders
  {
    public Int32 body_html;
    public string def_from;
    public string def_to;
    public string def_subject;
    public string def_cc;
    public string def_bcc;
    public Int32 def_importance;
  }


  public class EmailActivity : SequenceActivity
  {

    #region Private fields
    private CodeActivity SendEmailCodeActivity;
    [NonSerialized]
    private Logger _emailLogger;
    #endregion

    #region Properties

    /// <summary>
    /// Gets a logger object to be used from inside the activity.
    /// </summary>
    public Logger EmailLogger
    {
      get
      {
        if (_emailLogger == null)
        {
          _emailLogger = new Logger("Logging\\ActivityServices", "[EmailActivity]");
        }

        return _emailLogger;
      }
    }

    #endregion

    #region Output Properties
    public static DependencyProperty Current_AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Current_Account", typeof(Account), typeof(EmailActivity));
    [Description("Retrieves the In_Account property of the BaseAccountActivity")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    public Account Current_Account
    {
      get
      {
        return ((Account)(base.GetValue(EmailActivity.Current_AccountProperty)));
      }
      set
      {
        base.SetValue(EmailActivity.Current_AccountProperty, value);
      }
    }
    #endregion


    public EmailActivity()
    {
      InitializeComponent();
    }

    private void InitializeComponent()
    {
      this.CanModifyActivities = true;
      this.SendEmailCodeActivity = new System.Workflow.Activities.CodeActivity();

      this.SendEmailCodeActivity.Name = "SendEmailCodeActivity";
      this.SendEmailCodeActivity.ExecuteCode += new EventHandler(SendEmailCodeActivity_ExecuteCode);

      this.Activities.Add(this.SendEmailCodeActivity);
      this.Name = "SendEmailActivity";
      this.CanModifyActivities = false;
    }


    void SendEmailCodeActivity_ExecuteCode(object sender, EventArgs e)
    {
      Console.WriteLine("From Email activity..");
      try
      {

          InternalView internalView = Current_Account.GetInternalView() as InternalView;

          Dictionary<string, string> MapLang = new Dictionary<string, string>();
          MapLang.Add("US", "US");
          MapLang.Add("German", "DE");
          MapLang.Add("French", "FR");
          MapLang.Add("Italian", "IT");
          MapLang.Add("Japanese", "JP");
          string language = "";

          foreach (KeyValuePair<string, string> kvp in MapLang)
          {
              if (kvp.Value.ToString() == internalView.Language.ToString())
              {
                  language = kvp.Value;
              }
          }

          ContactView cv = new ContactView();

          //check if the view is of contact type
          foreach (string key in Current_Account.GetViews().Keys)
          {
              List<View> views = Current_Account.GetViews()[key] as List<View>;

              foreach (View view in views)
              {
                  if (view.GetType().ToString() == "MetraTech.DomainModel.AccountTypes.ContactView")
                  {
                      cv = (ContactView)view;
                  }
              }
          }

          MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
          string path = rcd.ConfigDir + "EmailTemplate\\AddAccountEMailNotificationTemplate.xml";
          if (!File.Exists(path))
          {
              throw new ApplicationException(String.Format("Unable to locate the email template file '{0}'", path));
          }

          EmailTemplate et;
          using (TextReader r = new StreamReader(path))
          {
              System.Xml.Serialization.XmlSerializer xs = new XmlSerializer(typeof(EmailTemplate));
              et = (EmailTemplate)xs.Deserialize(r);
          }

          foreach (MailStruct mst in et.MailStructs)
          {
              if (mst.language == language && mst.selected != 0)
              {
                  StringBuilder Body = new StringBuilder();
                  Body.Append(mst.message_body);

                  string UserName = Current_Account.UserName;
                  string Password = Current_Account.Password_;

                  Body.Replace("%%FIRSTNAME%%", cv.FirstName);
                  Body.Replace("%%LASTNAME%%", cv.LastName);
                  Body.Replace("%%USERNAME%%", UserName);
                  Body.Replace("%%PASSWORD_%%", Password);
                  Body.Replace("%%TIME%%", MetraTime.Now.ToLongDateString());

                  MailMessage mail = new MailMessage();

                  mail.From = new MailAddress(mst.default_headers.def_from);
                  mail.To.Add(new MailAddress(cv.Email));
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
                      IMTRcd hostrcd = new MTRcd();
                      string hostpath = hostrcd.ConfigDir + "email\\email.xml";
                      if (File.Exists(hostpath))
                      {
                          XmlDocument doc = new XmlDocument();
                          doc.Load(hostpath);
                          XmlNode addressNode = doc.SelectSingleNode("//smtp_server/address");
                          host = addressNode.InnerText.Trim();
                      }
                  }

                  System.Net.Mail.SmtpClient sc = new SmtpClient();
                  sc.Host = host;

                  if (String.IsNullOrEmpty(sc.Host))
                  {
                      throw new ApplicationException("Unable to locate mail server");
                  }

                  //Send the mail
                  sc.Send(mail);

                  Console.WriteLine("Mail sent");

              }
          }
      }
      catch (MASBasicException masBasEx)
      {
          EmailLogger.LogException("Exception occurred in SendEmailCodeActivity : ", masBasEx);
          throw;
      }
      catch (COMException comE)
      {
          EmailLogger.LogException("COM exception in creating account views", comE);
          throw new MASBasicException(comE.Message);
      }
      catch (Exception SendEmailEx)
      {
          EmailLogger.LogException("Unable to send email", SendEmailEx);
          throw new MASBasicException(SendEmailEx.Message);
      }


    }

  }
}
