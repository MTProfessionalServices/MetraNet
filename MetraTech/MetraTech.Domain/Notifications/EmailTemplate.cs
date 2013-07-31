using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Mail;
using System.Runtime.Serialization;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Xsl;
using MetraTech.Domain.Events;

namespace MetraTech.Domain.Notifications
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class EmailTemplate
  {
    [DataMember]
    public string DeliveryLanguage { get; set; } // TODO: this is an expression

    [DataMember]
    public string ToRecipient { get; set; } // TODO: this is an expression

    [DataMember]
    public IEnumerable<string> CarbonCopyRecipients { get; set; } // TODO: this is an expression

    [DataMember]
    public EmailTemplateDictionary EmailTemplateDictionary { get; set; }

    public MailMessage CreateMailMessage(Event triggeredEvent, MailAddress fromAddress, MailAddress replyToAddress)
    {
      LocalizedEmailTemplate localizedTemplate;
      if (!EmailTemplateDictionary.TryGetValue(DeliveryLanguage, out localizedTemplate))
      {
        throw new ArgumentException("A localized template could not be found for this recipient");
      }

      var subject = ProcessTemplate(localizedTemplate.SubjectTemplate, triggeredEvent);
      var body = ProcessTemplate(localizedTemplate.BodyTemplate, triggeredEvent);

      MailMessage message = null;
      try
      {
        message = new MailMessage();
        message.From = fromAddress;
        message.Subject = subject;
        message.Body = body;
        message.IsBodyHtml = true;

        if (replyToAddress != null) message.ReplyToList.Add(replyToAddress);

        var toMailAddress = new MailAddress(ToRecipient);
        message.To.Add(toMailAddress);
        
        foreach (var recipient in CarbonCopyRecipients)
        {
          var carbonCopyMailAddress = new MailAddress(recipient);
          message.CC.Add(carbonCopyMailAddress);
        }
        return message;
      }
      catch (Exception)
      {
        if (message != null) message.Dispose();
        throw;
      }
    }

    private static string ProcessTemplate(string template, Event eventInstance)
    {
      using (var reader = new StringReader(template))
      {
        var templateReader = XmlReader.Create(reader);
        var xslCompiledTransform = RetrieveCompiledTransform(templateReader);
        var serializedEvent = eventInstance.Serialize();
        var renderedDocument = CompiledRender(xslCompiledTransform, serializedEvent);
        var stringReader = new StreamReader(renderedDocument);
        return stringReader.ReadToEnd();
      }
    }

    public static XslCompiledTransform RetrieveCompiledTransform(XmlReader xmlTemplate)
    {
      // Create and load the transform with script execution enabled.
      var transform = new XslCompiledTransform();
      var settings = new XsltSettings { EnableScript = true };

      transform.Load(xmlTemplate, settings, null);
      return transform;
    }

    public static MemoryStream CompiledRender(XslCompiledTransform transform, XNode serializedEvent)
    {
      if (transform == null) throw new ArgumentNullException("transform");
      if (serializedEvent == null) throw new ArgumentNullException("serializedEvent");

      MemoryStream renderedDocument = null;

      try
      {
        renderedDocument = new MemoryStream();

        // Create a reader to read the event xml
        // Create a writer for writing the transformed file.
        XmlWriter writer = null;
        try
        {
          using (var xmlReader = serializedEvent.CreateReader(ReaderOptions.OmitDuplicateNamespaces))
          {
            writer = XmlWriter.Create(renderedDocument, new XmlWriterSettings { ConformanceLevel = ConformanceLevel.Auto });
            var xsltArguments = new XsltArgumentList();
            var extensionObject = new ExtendedXsltFunctions();
            xsltArguments.AddExtensionObject("urn:extendedFunctions", extensionObject);
            // Execute the transformation.
            transform.Transform(xmlReader, xsltArguments, writer);
          }
        }
        catch (Exception)
        {
          if (writer != null)
          {
            renderedDocument = null; // avoid CA2202
          }
          throw;
        }
        // Reset writer to the beginning and return
        renderedDocument.Seek(0, SeekOrigin.Begin);
        return renderedDocument;
      }
      catch (Exception)
      {
        if (renderedDocument != null) renderedDocument.Dispose();
        throw;
      }
    }
  }
}
