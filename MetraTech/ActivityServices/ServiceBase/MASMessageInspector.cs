using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel.Dispatcher;
using System.Xml.Schema;
using System.Xml;
using System.IO;
using System.ServiceModel.Channels;
using MetraTech.ActivityServices.Common;
using MetraTech.SecurityFramework;

namespace MetraTech.ActivityServices.Services.Common
{
    internal class MASMessageInspector : IDispatchMessageInspector
    {
        private Logger m_Logger = null;
        private XmlSchemaSet m_SchemaSet = null;
        private string mServiceName = null;
        private MASRequestLogger mRequestLogger;

        public MASMessageInspector(string svcName, XmlSchemaSet schemas)
        {
            m_SchemaSet = schemas;
            m_Logger = new Logger("[" + svcName + "Inspector]");
            mServiceName = svcName;

            mRequestLogger = new MASRequestLogger(mServiceName);
        }

        #region IDispatchMessageInspector Members

        public object AfterReceiveRequest(ref System.ServiceModel.Channels.Message request, System.ServiceModel.IClientChannel channel, System.ServiceModel.InstanceContext instanceContext)
        {
            try
            {
                if (!request.IsEmpty)
                {
                    ValidateMessageBody(ref request);
                }

                if (request.Headers.MessageId != null)
                {
                    mRequestLogger.MessageStarted(request.Headers.MessageId, request.Headers.Action);
                }
                if (m_Logger.WillLogTrace)
                {
                    m_Logger.LogTrace("Received message {0} for operation {1} at {2}", request.Headers.MessageId, request.Headers.Action, DateTime.Now);
                }
            }
            catch (XmlException xmlE)
            {
                m_Logger.LogException("XML Exception valditing schema", xmlE);
                m_Logger.LogError("Message: {0}", request.ToString());
                throw new MASBasicException("Invalid request message");
            }
            catch (DetectorInputDataException didE)
            {
                m_Logger.LogException("Detector input data exception validating message", didE);
                didE.Report();
                m_Logger.LogError("Message: {0}", request.ToString());
                throw new MASBasicException("Invalid request message");
            }
            catch (Exception e)
            {
                m_Logger.LogException("General exception validating schema", e);
                m_Logger.LogError("Message: {0}", request.ToString());
                throw new MASBasicException("Invalid request message");
            }

            return null;
        }

        public void BeforeSendReply(ref System.ServiceModel.Channels.Message reply, object correlationState)
        {
            try
            {
                // TOO SLOW!  ValidateMessageBody(ref reply);
                if (reply.Headers.RelatesTo != null)
                {
                    mRequestLogger.MessageCompleted(reply.Headers.RelatesTo);
                }

                if (m_Logger.WillLogTrace)
                {
                    m_Logger.LogTrace("Message {0} completed for operation {1} at {2}", reply.Headers.RelatesTo, reply.Headers.Action, DateTime.Now);
                }
            }
            catch (XmlException xmlE)
            {
                m_Logger.LogException("XML Exception valditing schema", xmlE);
                m_Logger.LogError("Message: {0}", reply.ToString());
                throw new MASBasicException("Invalid request message");
            }
            catch (DetectorInputDataException didE)
            {
                m_Logger.LogException("Detector input data exception validating message", didE);
                didE.Report();
                m_Logger.LogError("Message: {0}", reply.ToString());
                throw new MASBasicException("Invalid request message");
            }
            catch (Exception e)
            {
                m_Logger.LogException("General exception validating schema", e);
                m_Logger.LogError("Message: {0}", reply.ToString());
                throw new MASBasicException("Invalid request message");
            }
        }

        #endregion

        #region Helper Methods
        void ValidateMessageBody(ref System.ServiceModel.Channels.Message message)
        {
            if (!message.IsFault)
            {
                XmlDictionaryReaderQuotas quotas =
                        new XmlDictionaryReaderQuotas();
                XmlReader bodyReader =
                    message.GetReaderAtBodyContents().ReadSubtree();
                XmlReaderSettings wrapperSettings =
                                      new XmlReaderSettings();
                wrapperSettings.CloseInput = true;
                wrapperSettings.Schemas = m_SchemaSet;
                wrapperSettings.ValidationFlags =
                                        XmlSchemaValidationFlags.None;
                wrapperSettings.ValidationType = ValidationType.Schema;
                XmlReader wrappedReader = XmlReader.Create(bodyReader,
                                                    wrapperSettings);

                // pull body into a memory backed writer to validate
                MemoryStream memStream = new MemoryStream();
                XmlDictionaryWriter xdw =
                      XmlDictionaryWriter.CreateBinaryWriter(memStream);
                xdw.WriteNode(wrappedReader, false);
                xdw.Flush(); memStream.Position = 0;
                XmlDictionaryReader xdr =
                XmlDictionaryReader.CreateBinaryReader(memStream, quotas);

                // reconstruct the message with the validated body
                Message replacedMessage =
                    Message.CreateMessage(message.Version, null, xdr);
                replacedMessage.Headers.CopyHeadersFrom(message.Headers);
                replacedMessage.Properties.CopyProperties(message.Properties);
                message = replacedMessage;
            }
        }
        #endregion
    }
}
