using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Security;
using MetraTech.DomainModel.MetraPay;

namespace MetraTech.MetraPay.Client
{
    [ServiceContract]
    public interface IBatchUpdateServiceCallback
    {
        [OperationContract(IsOneWay = true)]
        void CreditCardsUpdated(string transactionId, List<CreditCardPaymentMethod> updatedCards);
    }

    [ServiceContract(CallbackContract = typeof(IBatchUpdateServiceCallback))]
    public interface IBatchUpdateService
    {
        [OperationContract(IsOneWay = true)]
        void UpdateCreditCards(string transactionId, List<Guid> cardsToUpdate);
    }

    internal interface IBatchUpdateServiceChannel : IBatchUpdateService, IClientChannel
    {
    }


    [System.Diagnostics.DebuggerStepThroughAttribute()]
    public class MetraPayBatchUpdateClient : ClientBase<IBatchUpdateService>, IBatchUpdateService
    {
        private static NetTcpBinding m_Binding;

        static MetraPayBatchUpdateClient()
        {
            m_Binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);

            m_Binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
            m_Binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
            m_Binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
            m_Binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
            m_Binding.TransactionFlow = true;
        }

        public MetraPayBatchUpdateClient(InstanceContext callbackInstance, string serverName, int serverPort, string dnsIdentityName, string serviceName)
            :
              base(callbackInstance, m_Binding,
                  new EndpointAddress(
                      new Uri(string.Format("net.tcp://{0}:{1}/{2}/BatchUpdateService", serverName, serverPort, serviceName)),
                      EndpointIdentity.CreateDnsIdentity(dnsIdentityName)
                  )
              )
        {
        }

        #region IBatchUpdateService Members

        public void UpdateCreditCards(string transactionId, List<Guid> cardsToUpdate)
        {
            base.Channel.UpdateCreditCards(transactionId, cardsToUpdate);
        }

        #endregion
    }
}
