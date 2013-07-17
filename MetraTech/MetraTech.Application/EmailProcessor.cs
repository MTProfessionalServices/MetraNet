using MetraTech.Domain.Notifications;
using System;
using System.Net;
using System.Net.Mail;

namespace MetraTech.Application
{
  public static class EmailProcessor
  {
    public static void SendEmail(NotificationEndpoint emailEndpoint, MailMessage message)
    {
      if (emailEndpoint == null) throw new ArgumentNullException("emailEndpoint");
      using (var smtpClient = new SmtpClient(emailEndpoint.EndpointConfiguration.EndpointAddress))
      {
        if (emailEndpoint.EndpointConfiguration.Port != null)
        {
          smtpClient.Port = emailEndpoint.EndpointConfiguration.Port.Value;
        }

        var networkAuthenticationConfiguration = emailEndpoint.AuthenticationConfiguration as NetworkAuthenticationConfiguration;
        if (networkAuthenticationConfiguration == null) throw new ArgumentException("Only network configuration credentials are supported for Email Notifications");
        smtpClient.Credentials = new NetworkCredential(networkAuthenticationConfiguration.UserName, networkAuthenticationConfiguration.Password);

        smtpClient.Send(message);
      }
    }
  }
}
