using System;
using MetraTech.Domain;
using MetraTech.Domain.Events;
using MetraTech.Domain.Notifications;
using MetraTech.Domain.Test;
using MetraTech.Domain.Test.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;

namespace MetraTech.Application.Test
{
  [TestClass]
  public class NotificationProcessorTest
  {
    [TestMethod]
    public void TestNotification()
    {
      var notificationEndpoint = CreateTestNotificationEndpoint();
      var notificationConfiguration = CreateTestNotificationConfiguration(notificationEndpoint);

      var fakeContext = new FakeMetraNetContext
        {
          NotificationEndpoints = new List<NotificationEndpoint> { notificationEndpoint }.ToIDbSet(),
          NotificationConfigurations = new List<NotificationConfiguration> { notificationConfiguration }.ToIDbSet()
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

      NotificationProcessor.ProcessEvent(fakeContext, triggeredEvent);
    }

    [TestMethod]
    public void TestApprovalNotification()
    {
      var notificationEndpoint = CreateTestNotificationEndpoint();
      var notificationConfiguration = CreateTestNotificationConfiguration(notificationEndpoint,
        EmailTemplates.ChangeApprovedTemplateSubject, EmailTemplates.ChangeApprovedTemplateBody,
        "event.SubmitterEmail", "\"en-us\"", "Approval Notification", "ChangeNotificationEvent");

      var fakeContext = new FakeMetraNetContext
      {
        NotificationEndpoints = new List<NotificationEndpoint> { notificationEndpoint }.ToIDbSet(),
        NotificationConfigurations = new List<NotificationConfiguration> { notificationConfiguration }.ToIDbSet()
      };

      var triggeredEvent = new ChangeNotificationEvent()
      {
        ChangeId = "1234567",
        Comment = "This is a very good change!",
        SubmitterEmail = "mdesousa@metratech.com"
      };

      NotificationProcessor.ProcessEvent(fakeContext, triggeredEvent);
    }

    public static NotificationConfiguration CreateTestNotificationConfiguration(NotificationEndpoint notificationEndpoint)
    {
      var subjectTemplate = EmailTemplates.ThresholdCrossingTemplateSubject;
      var bodyTemplate = EmailTemplates.ThresholdCrossingTemplateBody;
      const string toRecipient = "event.Account.EmailAddress";
      const string deliveryLanguage = "event.Account.LanguageCode";
      const string notificationConfigurationName = "Threshold Notification";
      const string eventType = "ThresholdCrossingEvent";
      return CreateTestNotificationConfiguration(notificationEndpoint, subjectTemplate, bodyTemplate, toRecipient, deliveryLanguage, notificationConfigurationName, eventType);
    }

    public static NotificationConfiguration CreateTestNotificationConfiguration(NotificationEndpoint notificationEndpoint,
                                                                          string subjectTemplate, string bodyTemplate,
                                                                          string toRecipient, string deliveryLanguage,
                                                                          string notificationConfigurationName,
                                                                          string eventType)
    {
      var localizedEmailTemplate = new LocalizedEmailTemplate
        {
          SubjectTemplate = subjectTemplate,
          BodyTemplate = bodyTemplate
        };

      var emailTemplate = new EmailTemplate
        {
          ToRecipient = toRecipient,
          CarbonCopyRecipients = new List<string>(),
          DeliveryLanguage = deliveryLanguage,
          EmailTemplateDictionary = new EmailTemplateDictionary {{"en-us", localizedEmailTemplate}}
        };

      var notificationConfiguration = new NotificationConfiguration();
      notificationConfiguration.EntityId = Guid.NewGuid();
      notificationConfiguration.CreationDate = DateTime.Now;
      notificationConfiguration.ModifiedDate = DateTime.Now;
      notificationConfiguration.Name.Add("en-us", notificationConfigurationName);
      notificationConfiguration.EventType = eventType;
      notificationConfiguration.NotificationType = NotificationType.Email;
      notificationConfiguration.NotificationEndpoint = notificationEndpoint;
      notificationConfiguration.MessageTemplate = emailTemplate;
      return notificationConfiguration;
    }

    public static NotificationEndpoint CreateTestNotificationEndpoint()
    {
      var authenticationConfiguration = new NetworkAuthenticationConfiguration
      {
        UserName = "server3994",
        Password = "9uY2zevySXPPaoXU2Lbv"
      };

      var endpointConfiguration = new EmailEndpointConfiguration
      {
        EndpointAddress = "smtp.socketlabs.com"
      };

      var notificationEndpoint = new NotificationEndpoint();
      notificationEndpoint.EntityId = Guid.NewGuid();
      notificationEndpoint.CreationDate = DateTime.Now;
      notificationEndpoint.ModifiedDate = DateTime.Now;
      notificationEndpoint.Name.Add("en-us", "Corporte Email");
      notificationEndpoint.Active = true;
      notificationEndpoint.AuthenticationConfiguration = authenticationConfiguration;
      notificationEndpoint.EndpointConfiguration = endpointConfiguration;
      return notificationEndpoint;
    }
  }
}
