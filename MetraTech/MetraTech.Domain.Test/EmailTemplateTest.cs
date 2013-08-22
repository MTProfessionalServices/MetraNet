using System;
using System.ComponentModel;
using MetraTech.Domain.Events;
using MetraTech.Domain.Notifications;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Net.Mail;

namespace MetraTech.Domain.Test
{
    [TestClass]
    public class EmailTemplateTest
    {
        [TestMethod]
        public void CreateMailMessageTest()
        {
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

            var message = emailTemplate.CreateMailMessage(triggeredEvent, fromAddress, null, new [] { typeof(ThresholdCrossingEvent) });

            Assert.AreEqual("mdesousa@metratech.com", message.From.Address);
            Assert.AreEqual(0, message.ReplyToList.Count);
            Assert.AreEqual("Congratulations! You have reached 1000 minutes", message.Subject);
            Assert.AreEqual("<html><body>You have crossed a usage tier. Your next tier price is $0.20</body></html>", message.Body);
            Assert.AreEqual(1, message.To.Count);
        }
    }
}
