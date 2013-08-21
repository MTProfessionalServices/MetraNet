using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Domain.Notifications;

namespace MetraTech.Domain.Test
{
    /// <summary>
    /// A class for test entities generation 
    /// </summary>
    public class EntityFactory
    {
        public static NotificationConfiguration CreateTestNotificationConfiguration(NotificationEndpoint notificationEndpoint)
        {
            const string eventType = "ThresholdCrossingEvent";
            const string notificationConfigurationName = "Threshold Notification";
            var subjectTemplate = EmailTemplates.ThresholdCrossingTemplateSubject;
            var bodyTemplate = EmailTemplates.ThresholdCrossingTemplateBody;

            return CreateTestNotificationConfiguration(notificationEndpoint, subjectTemplate, bodyTemplate, eventType, notificationConfigurationName);
        }

        public static NotificationConfiguration CreateTestNotificationConfiguration(NotificationEndpoint notificationEndpoint,
                                                                                    string subjectTemplate, string bodyTemplate,
                                                                                    string eventType,
                                                                                    string notificationConfigurationName)
        {
            var localizedEmailTemplate = new LocalizedEmailTemplate
                {
                    SubjectTemplate = subjectTemplate,
                    BodyTemplate = bodyTemplate
                };

            var localizedEmailTemplateRuRu = new LocalizedEmailTemplate
                {
                    SubjectTemplate = "RU-RU" + subjectTemplate,
                    BodyTemplate = "RU-RU" + bodyTemplate
                };

            var emailTemplate = new EmailTemplate
                {
                    ToRecipient = "mdesousa@metratech.com",
                    CarbonCopyRecipients = new List<string> {"smalinovskiy123@metratech.com", "smalinovskiy234@metratech.com"},
                    DeliveryLanguage = "en-us",
                    EmailTemplateDictionary =
                        new EmailTemplateDictionary {{"en-us", localizedEmailTemplate}, {"ru-ru", localizedEmailTemplateRuRu}}
                };

            var notificationConfiguration = new NotificationConfiguration
                {
                    EntityId = Guid.NewGuid(),
                    CreationDate = DateTime.Now,
                    ModifiedDate = DateTime.Now,
                    EventType = eventType,
                    NotificationType = NotificationType.Email,
                    NotificationEndpoint = notificationEndpoint,
                    MessageTemplate = emailTemplate,
                    ExternalId = "ExternalId " + Guid.NewGuid()
                };

            notificationConfiguration.Name.Add("en-us", notificationConfigurationName);
            notificationConfiguration.Name.Add("ru-ru", "RU-RU " + notificationConfigurationName);
            notificationConfiguration.Description.Add("en-us", notificationConfigurationName);
            notificationConfiguration.Description.Add("ru-ru", "RU-RU " + notificationConfigurationName);

            return notificationConfiguration;
        }

        public static NotificationEndpoint CreateTestNotificationEndpoint(string externalId = null)
        {
            var authenticationConfiguration = new NetworkAuthenticationConfiguration
            {
                UserName = "server3994",
                Password = "9uY2zevySXPPaoXU2Lbv"
            };

            var endpointConfiguration = new EmailEndpointConfiguration
            {
                EndpointAddress = "smtp.socketlabs.com",
                Port = 1234
            };

            var notificationEndpoint = new NotificationEndpoint
            {
                EntityId = Guid.NewGuid(),
                CreationDate = DateTime.Now,
                ModifiedDate = DateTime.Now,
                ExternalId = (string.IsNullOrEmpty(externalId) ? "ExternalId " + Guid.NewGuid() : externalId),
                Active = true,
                AuthenticationConfiguration = authenticationConfiguration,
                EndpointConfiguration = endpointConfiguration
            };

            notificationEndpoint.Name.Add("en-us", "Corporte Email");
            notificationEndpoint.Name.Add("ru-ru", "Ru-RU Corporte Email");
            notificationEndpoint.Description.Add("en-us", "Corporte Email");
            notificationEndpoint.Description.Add("ru-ru", "RU-RU Corporte Email");
            return notificationEndpoint;
        }
    }
}
