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
  internal interface IPaymentInstrumentMgmtSvc
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void AddPaymentMethod(MetraPaymentMethod paymentMethod, out Guid token);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void UpdatePaymentMethod(Guid token, MetraPaymentMethod paymentMethod);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void DeletePaymentMethod(Guid token);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    [TransactionFlow(TransactionFlowOption.Allowed)]
    void AddCreditCardAndPreAuth(CreditCardPaymentMethod ccPaymentInstrument, ref MetraPaymentInfo paymentInfo, out Guid instrumentToken, out Guid authToken, string arRequestId);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void UpdatePaymentMethodNoCheck(Guid token, MetraPaymentMethod paymentMethod);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    [FaultContract(typeof(PaymentProcessorFaultDetail))]
    void ReverseChargeAuthorization(Guid authToken, Guid paymentToken, ref MetraPaymentInfo paymentInfo);

  }

  
  internal interface IPaymentInstrumentMgmtSvcChannel : IPaymentInstrumentMgmtSvc, IClientChannel
  {
  }


  [System.Diagnostics.DebuggerStepThroughAttribute()]
  internal class MetraPayClient : ClientBase<IPaymentInstrumentMgmtSvc>, IPaymentInstrumentMgmtSvc
  {
    private static NetTcpBinding m_Binding;

    static MetraPayClient()
    {
      m_Binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);

      m_Binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
      m_Binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
      m_Binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
      m_Binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
      m_Binding.TransactionFlow = true;
    }

    public MetraPayClient(string serverName, int serverPort, string dnsIdentityName, string serviceName)
      :
        base(m_Binding,
            new EndpointAddress(
                new Uri(string.Format("net.tcp://{0}:{1}/{2}/PaymentInstrumentMgmtSvc", serverName, serverPort, serviceName)),
                EndpointIdentity.CreateDnsIdentity(dnsIdentityName)
            )
        )
    {
    }

    #region IPaymentInstrumentMgmtSvc Members

    public void AddPaymentMethod(MetraPaymentMethod paymentMethod, out Guid token)
    {
      base.Channel.AddPaymentMethod(paymentMethod, out token);
    }

    public void UpdatePaymentMethod(Guid token, MetraPaymentMethod paymentMethod)
    {
      base.Channel.UpdatePaymentMethod(token, paymentMethod);
    }

    public void DeletePaymentMethod(Guid token)
    {
      base.Channel.DeletePaymentMethod(token);
    }

    public void AddCreditCardAndPreAuth(CreditCardPaymentMethod ccPaymentInstrument, ref MetraPaymentInfo paymentInfo, out Guid instrumentToken, out Guid authToken, string arRequestId)
    {
        base.Channel.AddCreditCardAndPreAuth(ccPaymentInstrument, ref paymentInfo, out instrumentToken, out authToken, arRequestId);
    }

    public void UpdatePaymentMethodNoCheck(Guid token, MetraPaymentMethod paymentMethod)
    {
        base.Channel.UpdatePaymentMethodNoCheck(token, paymentMethod);
    }

    public void ReverseChargeAuthorization(Guid authToken, Guid paymentToken, ref MetraPaymentInfo paymentInfo)
    {
        base.Channel.ReverseChargeAuthorization(authToken, paymentToken, ref paymentInfo);
    }


    #endregion
  }
}
