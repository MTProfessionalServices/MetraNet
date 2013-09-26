using System;
using MetraTech.Domain;
using MetraTech.Domain.Events;
using MetraTech.Domain.Notifications;
using MetraTech.Domain.Test;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Net.Mail;
using System.Collections.Generic;

namespace MetraTech.Application.Test
{
  [TestClass]
  public class EmailProcessorTest
  {
    [TestMethod]
    public void SendEmailTest()
    {
      var emailEndpoint = CreateTestEndpoint();

      var localizedEmailTemplate = new LocalizedEmailTemplate
      {
        SubjectTemplate = EmailTemplates.ThresholdCrossingTemplateSubject,
        BodyTemplate = EmailTemplates.ThresholdCrossingTemplateBody
      };

      var emailTemplate = new EmailTemplate
      {
          ToRecipient = "event.Account.EmailAddress",
          CarbonCopyRecipients = new List<string>(),
          DeliveryLanguage = "event.Account.LanguageCode",
          EmailTemplateDictionary = new EmailTemplateDictionary { { "en-us", localizedEmailTemplate } }
      };

      var account = new Account
      {
          EmailAddress = "mdesousa@metratech.com",
          LanguageCode = "en-us"
      };

      var triggeredEvent = new ThresholdCrossingEvent
      {
        UsageQuantityForPriorTier = new Quantity(1000m, "MIN"),
        PriceForPriorTier = new Money(0.25m, "USD"),
        UsageQuantityForNextTier = new Quantity(2000m, "MIN"),
        PriceForNextTier = new Money(0.20m, "USD"),
        CurrentUsageQuantity = new Quantity(1025m, "MIN"),
        ThresholdPeriodStart = new DateTime(2013, 1, 1),
        ThresholdPeriodEnd = new DateTime(2014, 1, 1),
        SubscriptionId = Guid.Empty,
        Account = account
      };

      var fromAddress = new MailAddress("mdesousa@metratech.com");

      var message = emailTemplate.CreateMailMessage(triggeredEvent, fromAddress, null);

      EmailProcessor.SendEmail(emailEndpoint, message);
    }

    public static NotificationEndpoint CreateTestEndpoint()
    {
      var emailEndpoint = new NotificationEndpoint();
      emailEndpoint.EndpointConfiguration = new EmailEndpointConfiguration();
      emailEndpoint.EndpointConfiguration.EndpointAddress = "smtp.socketlabs.com";
      emailEndpoint.AuthenticationConfiguration = new NetworkAuthenticationConfiguration
      {
        UserName = "server3994",
        Password = "9uY2zevySXPPaoXU2Lbv"
      };
      return emailEndpoint;
    }
  }
}
