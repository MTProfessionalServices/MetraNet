using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.CompilerServices;
using System.ServiceModel;
using MetraTech.DomainModel.MetraPay;
using System.ServiceModel.Description;
using System.ServiceModel.Security;
using MetraTech.ActivityServices.Common;

#region Assembly Attribute
[assembly: InternalsVisibleTo("MetraTech.Core.Services, PublicKey=" +
            "00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
            "bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
            "e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
            "66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
            "df27e798")]
#endregion


namespace MetraTech.MetraPay.Client
{
  [ServiceContract]
  internal interface ITransactionProcessingService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitDebit(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitOneTimeDebit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitPreAuth(Guid token, ref MetraPaymentInfo paymentInfo, out Guid authToken, string arRequestId, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitCapture(Guid authorizationToken, ref MetraPaymentInfo actualPaymentInfo, double timeout, string cos);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitCredit(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitOneTimeCredit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void SubmitVoid(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void GetACHTransactionStatus(string transactionId, out bool bProcessed);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void DownloadACHTransactionsReport(string url);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void SubmitAuthReversal(Guid authToken, ref MetraPaymentInfo paymentInfo, double timeout, string cos);
  }

  internal interface ITransactionProcessingServiceSvcChannel : ITransactionProcessingService, IClientChannel
  {
  }


  [System.Diagnostics.DebuggerStepThroughAttribute()]
  internal class MetraPayTProcessorClient : ClientBase<ITransactionProcessingService>, ITransactionProcessingService
  {
    private static NetTcpBinding m_Binding;

    static MetraPayTProcessorClient()
    {
      m_Binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);

      m_Binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
      m_Binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
      m_Binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
      m_Binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
      m_Binding.TransactionFlow = true;
    }

    public MetraPayTProcessorClient(string serverName, int serverPort, string dnsIdentityName, string serviceName)
      :
        base(m_Binding,
            new EndpointAddress(
                new Uri(string.Format("net.tcp://{0}:{1}/{2}/TransactionProcessingSvc", serverName, serverPort, serviceName)),
                EndpointIdentity.CreateDnsIdentity(dnsIdentityName)
            )
        )
    {
    }

    #region ITransactionProcessingService Members

    public void SubmitDebit(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitDebit(token, ref paymentInfo, timeout, cos);
    }

    public void SubmitOneTimeDebit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitOneTimeDebit(paymentMethod, ref paymentInfo, timeout, cos);
    }

    public void SubmitPreAuth(Guid token, ref MetraPaymentInfo paymentInfo, out Guid authToken, string arRequestId, double timeout, string cos)
    {
        base.Channel.SubmitPreAuth(token, ref paymentInfo, out authToken, arRequestId, timeout, cos);
    }

    public void SubmitCapture(Guid authorizationToken, ref MetraPaymentInfo actualPaymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitCapture(authorizationToken, ref actualPaymentInfo, timeout, cos);
    }

    public void SubmitCredit(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitCredit(token, ref paymentInfo, timeout, cos);
    }

    public void SubmitOneTimeCredit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitOneTimeCredit(paymentMethod, ref paymentInfo, timeout, cos);
    }

    public void SubmitVoid(Guid token, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitVoid(token, ref paymentInfo, timeout, cos);
    }

    public void GetACHTransactionStatus(string transactionId, out bool bProcessed)
    {
      base.Channel.GetACHTransactionStatus(transactionId, out bProcessed);
    }

    public void DownloadACHTransactionsReport(string url)
    {
      base.Channel.DownloadACHTransactionsReport(url);
    }

    public void SubmitAuthReversal(Guid authToken, ref MetraPaymentInfo paymentInfo, double timeout, string cos)
    {
        base.Channel.SubmitAuthReversal(authToken, ref paymentInfo, timeout, cos);
    }

    #endregion
  }
}
