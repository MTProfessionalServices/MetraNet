/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Configuration;
using System.Net.Mail;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using System.Xml.XPath;
using System.Xml.Xsl;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.Subsystems.Common
{
    /// <summary>
    /// Provides email generation and sending fubctionality.
    /// </summary>
    public static class MailHelper
    {
        #region Public methods

        /// <summary>
        /// Creates an instance of the <see cref="MailAddress"/> class.
        /// </summary>
        /// <param name="address">A email address.</param>
        /// <param name="name">A display name.</param>
        /// <returns>An instance of the <see cref="MailAddress"/> class.</returns>
        /// <exception cref="ArgumentNullException">address is null.</exception>
        /// <exception cref="ArgumentException">address is System.String.Empty ("").</exception>
        /// <exception cref="FormatException">address is not in a recognized format.-or-address contains non-ASCII characters.</exception>
        /// <remarks>Use this method to avoid referencing of the System.Net.Mail namespace.</remarks>
        public static MailAddress CreateMailAddress(string address, string name)
        {
            MailAddress result = new MailAddress(address, name);

            return result;
        }

        /// <summary>
        /// Sends an email message.
        /// </summary>
        /// <param name="body">A message body.</param>
        /// <param name="subject">A message subject.</param>
        /// <param name="isHtml">Specifies whether the body is in HTML format.</param>
        /// <param name="to">A receiver address.</param>
        /// <param name="from">A sender address.</param>
        /// <param name="cc">An additional receiver address.</param>
        /// <param name="bcc">A hidden receiver address.</param>
        /// <exception cref="ArgumentNullException">
        /// If either <paramref name="to"/> or <paramref name="from"/> is null.
        /// </exception>
        /// <exception cref="InvalidOperationException">
        ///  From address is not specified neither via method argument not via configuration file.
        ///  -or- System.Net.Mail.SmtpClient.DeliveryMethod
        ///  property is set to System.Net.Mail.SmtpDeliveryMethod.Network and SMTP host is not specified in the configuration.
        ///  -or-System.Net.Mail.SmtpClient.DeliveryMethod property is set to
        ///  System.Net.Mail.SmtpDeliveryMethod.Network and and SMTP host is empty in the configuration.
        ///  -or- invalid port specified in the configuration.
        /// </exception>
        /// <returns>true if the message was send successfully and false otherwise.</returns>
        /// <remarks>Only specific exceptions occured during sending a message are hidden.</remarks>
        public static bool SendMessage(
            string body,
            string subject,
            bool isHtml,
            MailAddress to,
            MailAddress from,
            MailAddress cc,
            MailAddress bcc)
        {
            MailMessage msg = CreateMailMessage(body, subject, isHtml, to, from, cc, bcc);
            bool result = false;

            using (SmtpClient smtp = new SmtpClient())
            {
                try
                {
                    smtp.Send(msg);
                    result = true;
                }
                catch (InvalidOperationException ex)
                {
                    // Just hide and log an exception.
                    LoggingHelper.Log(ex);
                    throw;
                }
                catch (SmtpException ex)
                {
                    // Just hide and log an exception.
                    LoggingHelper.Log(ex);
                }
            }

            return result;
        }

        /// <summary>
        /// Sends an email message.
        /// </summary>
        /// <param name="body">A message body.</param>
        /// <param name="subject">A message subject.</param>
        /// <param name="isHtml">Specifies whether the body is in HTML format.</param>
        /// <param name="to">A receiver address.</param>
        /// <param name="from">A sender address.</param>
        /// <exception cref="ArgumentNullException">
        /// If either <paramref name="to"/> or <paramref name="from"/> is null.
        /// </exception>
        /// <exception cref="InvalidOperationException">
        ///  From address is not specified neither via method argument not via configuration file.
        ///  -or- System.Net.Mail.SmtpClient.DeliveryMethod
        ///  property is set to System.Net.Mail.SmtpDeliveryMethod.Network and SMTP host is not specified in the configuration.
        ///  -or-System.Net.Mail.SmtpClient.DeliveryMethod property is set to
        ///  System.Net.Mail.SmtpDeliveryMethod.Network and and SMTP host is empty in the configuration.
        ///  -or- invalid port specified in the configuration.
        /// </exception>
        /// <returns>true if the message was send successfully and false otherwise.</returns>
        /// <remarks>Only specific exceptions occured during sending a message are hidden.</remarks>
        public static bool SendMessage(
            string body,
            string subject,
            bool isHtml,
            MailAddress to,
            MailAddress from)
        {
            return SendMessage(body, subject, isHtml, to, from, null, null);
        }

        /// <summary>
        /// Generates an email message from specified template and data and sends it.
        /// </summary>
        /// <param name="data">The data to generate a message from.</param>
        /// <param name="template">The message template.</param>
        /// <param name="subject">A message subject.</param>
        /// <param name="isHtml">Specifies whether the body is in HTML format.</param>
        /// <param name="to">A receiver address.</param>
        /// <param name="from">A sender address.</param>
        /// <param name="cc">An additional receiver address.</param>
        /// <param name="bcc">A hidden receiver address.</param>
        /// <exception cref="ArgumentNullException">
        /// If <paramref name="to"/>, <paramref name="from"/>, <paramref name="data"/> or <paramref name="template"/> is null.
        /// </exception>
        /// <exception cref="XmlException">There was an error executing the serialization <paramref name="data"/> to XML.</exception>
        /// <exception cref="XsltException">There was an error executing the XSLT transform.</exception>
        /// <returns>true if the message was send successfully and false otherwise.</returns>
        /// <remarks>Only specific exceptions occured during generating or sending a message are hidden.</remarks>
        public static bool SendMessage(
            object data,
            XslCompiledTransform template,
            string subject,
            bool isHtml,
            MailAddress to,
            MailAddress from,
            MailAddress cc,
            MailAddress bcc)
        {
            StringBuilder body = new StringBuilder();
            
            GenerateMessageText(data, template, body);
            bool result = SendMessage(body.ToString(), subject, isHtml, to, from, cc, bcc);

            return result;
        }

        /// <summary>
        /// Generates an email message from specified template and data and sends it.
        /// </summary>
        /// <param name="data">The data to generate a message from.</param>
        /// <param name="template">The message template.</param>
        /// <param name="subject">A message subject.</param>
        /// <param name="isHtml">Specifies whether the body is in HTML format.</param>
        /// <param name="to">A receiver address.</param>
        /// <param name="from">A sender address.</param>
        /// <exception cref="ArgumentNullException">
        /// If <paramref name="to"/>, <paramref name="from"/>, <paramref name="data"/> or <paramref name="template"/> is null.
        /// </exception>
        /// <exception cref="XmlException">There was an error executing the serialization <paramref name="data"/> to XML.</exception>
        /// <exception cref="XsltException">There was an error executing the XSLT transform.</exception>
        /// <returns>true if the message was send successfully and false otherwise.</returns>
        /// <remarks>Only specific exceptions occured during generating or sending a message are hidden.</remarks>
        public static bool SendMessage(
            object data,
            XslCompiledTransform template,
            string subject,
            bool isHtml,
            MailAddress to,
            MailAddress from)
        {
            return SendMessage(data, template, subject, isHtml, to, from, null, null);
        }

        #endregion

        #region Private methods

        private static MailMessage CreateMailMessage(string body, string subject, bool isHtml, MailAddress to, MailAddress from, MailAddress cc, MailAddress bcc)
        {
            if (to == null)
            {
                throw new ArgumentNullException(Constants.Arguments.To);
            }

            if (from == null)
            {
                throw new ArgumentNullException(Constants.Arguments.From);
            }

            MailMessage msg = new MailMessage();

            msg.Body = body;
            msg.IsBodyHtml = isHtml;
            msg.Subject = subject;
            msg.To.Add(to);

            if (cc != null)
            {
                msg.CC.Add(cc);
            }

            if (bcc != null)
            {
                msg.Bcc.Add(bcc);
            }

            return msg;
        }

        private static void GenerateMessageText(object data, XslCompiledTransform template, StringBuilder body)
        {
            if (data == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Data);
            }

            if (template == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Template);
            }

            StringBuilder xml = new StringBuilder();
            XmlSerializer serializer = new XmlSerializer(data.GetType());

            using (TextWriter writer = new StringWriter(xml))
            {
                serializer.Serialize(writer, data);
            }

            try
            {
                using (TextReader reader = new StringReader(xml.ToString()))
                {
                    XPathDocument doc = new XPathDocument(reader);
                    using (TextWriter writer = new StringWriter(body))
                    {
                        template.Transform(doc, null, writer);
                    }
                }
            }
            catch (XmlException ex)
            {
                // Just hide and log an exception.
                LoggingHelper.Log(ex);
                throw;
            }
            catch (XsltException ex)
            {
                // Just hide and log an exception.
                LoggingHelper.Log(ex);
                throw;
            }
        }

        #endregion
    }
}
