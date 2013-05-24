using System;
using System.Collections.Generic;
using System.Net;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.RCD;
using System.Xml;
using System.IO;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using System.Net.Mail;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface INotificationService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SendEmailNotification(string templateName, LanguageCode language, string emailAddress, Dictionary<string, string> replacements);
  }

  [ServiceBehavior]
  public class NotificationService : CMASServiceBase, INotificationService
  {
    private static string m_SMTPHost;
    private static Int32 m_SMTPPort = 25;
    private static string m_SMTPUserName;
    private static string m_SMTPPassword;
    private static readonly Logger m_Logger = new Logger("[NotificationService]");

    public static string SMTPHost
    {
      get
      {
        if (string.IsNullOrEmpty(m_SMTPHost))
        {

          IMTServerAccessDataSet serverAccess = new MTServerAccessDataSetClass();
          serverAccess.Initialize();
          IMTServerAccessData serverData = serverAccess.FindAndReturnObjectIfExists("MailRelay");
          if (serverData != null)
          {
            m_SMTPHost = serverData.ServerName;
            m_SMTPPort = serverData.PortNumber;
            m_SMTPUserName = serverData.UserName;
            m_SMTPPassword = serverData.Password;
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
              if (addressNode != null)
                m_SMTPHost = addressNode.InnerText.Trim();
            }
          }
        }
        m_Logger.LogDebug("Using SMTP Host: {0} Port: {1}", m_SMTPHost, m_SMTPPort);

        return m_SMTPHost;
      }
    }

    #region INotificationService Members

    public void SendEmailNotification(string templateName, LanguageCode language, string emailAddress, Dictionary<string, string> replacements)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SendEmailNotification"))
      {
        try
        {
          m_Logger.LogDebug("Sending notification to {0} for template {1}", emailAddress, templateName);

          string templateFile = Path.ChangeExtension(templateName, ".xml");

          IMTRcd rcd = new MTRcd();
          string path = Path.Combine(rcd.ConfigDir, Path.Combine("EmailTemplate", templateFile));
          if (!File.Exists(path))
          {
            throw new MASBasicException(String.Format("Unable to locate the email template file '{0}'", templateFile));
          }

          TextReader r = new StreamReader(path);

          XmlSerializer xs = new XmlSerializer(typeof(EmailTemplate));
          EmailTemplate et;
          et = (EmailTemplate)xs.Deserialize(r);

          MailStruct mst = null;

          foreach (MailStruct mailStruct in et.MailStructs)
          {
            if (String.Compare(mailStruct.language, language.ToString(), true) == 0)
            {
              mst = mailStruct;
              break;
            }
          }

          if (mst != null)
          {
            StringBuilder Body = new StringBuilder();
            Body.Append(mst.message_body);

            foreach (KeyValuePair<string, string> kvp in replacements)
            {
              Body.Replace(kvp.Key, kvp.Value);
            }

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
            var sc = new SmtpClient();
            sc.Host = m_SMTPHost;
            sc.Port = m_SMTPPort;
            if (!String.IsNullOrEmpty(m_SMTPUserName))
            {
              var creds = new NetworkCredential(m_SMTPUserName, m_SMTPPassword);
              var auth = creds.GetCredential(m_SMTPHost, m_SMTPPort, "Basic");
              sc.Credentials = auth;
            }

            if (String.IsNullOrEmpty(sc.Host))
            {
              throw new MASBasicException(String.Format("Unable to locate mail server"));
            }

            //Send the mail
            sc.Send(mail);
          }
          else
          {
            throw new MASBasicException("Unable to locate mail template for specified language");
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("Exception sending email notification", masE);

          throw;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception sending email notification", e);
          throw;
        }
      }
    }

    #endregion
  }

  #region Internal Classes
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

  #endregion
}
