using System;
using System.Net.Mail;
using MetraTech.ExpressionEngine.MtProperty;
using MetraTech.ExpressionEngine.Entities;

namespace MetraTech.ExpressionEngine.UserTest
{
    /// <summary>
    /// This is just a place holder for demo purposes
    /// </summary>
    public static class EmailEngine // : IProcessingEngine
    {
        public static void EvaluateExpressions(EmailInstance email, PropertyCollection propertyCollection)
        {
            if (email == null)
                throw new ArgumentNullException("email");

            SetOutput(EmailInstance.ToPropertyName, email.ToExpression.Content, propertyCollection);
            SetOutput(EmailInstance.CcPropertyName, email.CcExpression.Content, propertyCollection);
            SetOutput(EmailInstance.SubjectPropertyName, email.SubjectExpression.Content, propertyCollection);
            SetOutput(EmailInstance.BodyPropertyName, email.BodyExpression.Content, propertyCollection);
        }

        private static void SetOutput(string outputPropertyName, string content, PropertyCollection propertyCollection)
        {
            var property = propertyCollection.Get(outputPropertyName);
            if (property == null)
                throw new ArgumentException("Unable to find output property " + outputPropertyName);
            if (property is Entity)
                throw new ArgumentException("Property is a complex type");

            ((Property)property).Value = MergeValues(content, propertyCollection);            
        }

        private static string MergeValues(string content, PropertyCollection propertyCollection)
        {
            if (string.IsNullOrEmpty(content))
                return content;

            //THis isn't designed to be efficient! We're just doing string substituions
            foreach (var property in propertyCollection)
            {
                if (property is Entity)
                    throw new ArgumentException("Property is a complex type");

                var pattern = "{" + property.Name + "}";
                content = content.Replace(pattern, ((Property)property).Value);
            }
            return content;
        }

        public static void Send(PropertyCollection properties)
        {
            if (properties == null)
                throw new ArgumentNullException("properties");

            var toValue = properties.GetValue(EmailInstance.ToPropertyName);
            var ccValue = properties.GetValue(EmailInstance.CcPropertyName);
            var subjectValue = properties.GetValue(EmailInstance.SubjectPropertyName);
            var bodyValue = properties.GetValue(EmailInstance.BodyPropertyName);

            var mail = new MailMessage();
            var smtpServer = new SmtpClient("smtp.socketlabs.com");

            mail.From = new MailAddress("your_email_address@gmail.com");
            mail.To.Add(toValue);
            if (!string.IsNullOrWhiteSpace(ccValue))
                mail.CC.Add(ccValue);
            mail.Subject = subjectValue;

            mail.IsBodyHtml = false;
            mail.Body = bodyValue;

            smtpServer.Port = 587;
            smtpServer.Credentials = new System.Net.NetworkCredential("server3994", "9uY2zevySXPPaoXU2Lbv");
            smtpServer.EnableSsl = false;

            smtpServer.Send(mail);
        }
    }
}
