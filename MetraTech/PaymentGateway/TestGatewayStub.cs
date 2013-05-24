using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.DomainModel.MetraPay;
using System.Xml;
using System.Configuration;
using System.Threading;
using MetraTech.ActivityServices.Common;

namespace MetraTech.MetraPay.PaymentGateway
{
  public class TestGatewayStub : IPaymentGateway
  {
    private static int m_RequestCount = 0;
    private static int m_VoidCount = 0;
    private int m_FailureInterval;
    private int m_TimeoutInterval;
    private int m_SleepTooLongInterval;
    private int m_VoidSettledInterval;

    private Logger m_Logger = new Logger("[TestGatewayStub]");

    #region IPaymentGateway Members
    public void Init(string configFile)
    {
      ExeConfigurationFileMap map = new ExeConfigurationFileMap();
      map.ExeConfigFilename = configFile;

      Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

      m_FailureInterval = int.Parse(config.AppSettings.Settings["FailureInterval"].Value);
      m_TimeoutInterval = int.Parse(config.AppSettings.Settings["TimeoutInterval"].Value);
      m_SleepTooLongInterval = int.Parse(config.AppSettings.Settings["SleepTooLongInterval"].Value);
      m_VoidSettledInterval = int.Parse(config.AppSettings.Settings["VoidSettledInterval"].Value);
    }

    public bool ValidatePaymentMethod(MetraPaymentMethod paymentMethod)
    {
      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 

      if (m_FailureInterval != 0)
      {
        if (Interlocked.Increment(ref m_RequestCount) % m_FailureInterval == 0)
        {
          throw new PaymentProcessorException("Payment processing failed");
        }
      }

      return true;
    }
    public void AuthorizeCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, out string requestParms, out string warnings, double timeout = 0, string cos = "")
    {
      requestParms = "";
      warnings = null;

      m_Logger.LogDebug("Received payment method type: {0}", ccPaymentMethod.GetType().AssemblyQualifiedName);
      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 


 //     FailureCheck(timeout);
    }

    public void CaptureCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, string requestParms, out string warnings, double timeout = 0, string cos = "")
    {
      warnings = null;
      m_Logger.LogDebug("Received payment method type: {0}", ccPaymentMethod.GetType().AssemblyQualifiedName);
      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 

      FailureCheck(timeout);
    }

    public void Debit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "")
    {
      warnings = null;
      m_Logger.LogDebug("Received payment method type: {0}", paymentMethod.GetType().AssemblyQualifiedName);

      paymentInfo.TransactionID = Guid.NewGuid().ToString(); 
      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 
            
      FailureCheck(timeout);
    }



    public void Credit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "")
    {
      warnings = null;
      m_Logger.LogDebug("Received payment method type: {0}", paymentMethod.GetType().AssemblyQualifiedName);

      paymentInfo.TransactionID = Guid.NewGuid().ToString(); 
      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 

      FailureCheck(timeout);
    }

    public void Void(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings, double timeout = 0, string cos = "")
    {
      warnings = null;
      m_Logger.LogDebug("Received payment method type: {0}", paymentMethod.GetType().AssemblyQualifiedName);

      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600)); 
      
      //    FailureCheck(timeout);
      Interlocked.Increment(ref m_VoidCount);
      if (m_VoidSettledInterval != 0)
      {
        Interlocked.Increment(ref m_VoidCount);
        if (m_VoidCount % m_VoidSettledInterval == 0)
        {
          throw new MASBasicException(ErrorCodes.TRANSACTION_ALREADY_SETTLED);
    }
      }
    }

    public bool GetACHTransactionStatus(string transactionId, out string warnings)
    {
      warnings = null;

      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600));

      if (m_FailureInterval != 0)
      {
        if (Interlocked.Increment(ref m_RequestCount) % m_FailureInterval == 0)
        {
          throw new PaymentProcessorException("Payment processing failed");
        }
      }

      return true;
    }

    public void DownloadACHTransactionsReport(string url, out string warnings)
    {
      warnings = null;

      Random rnd = new Random();
      Thread.Sleep(rnd.Next(300, 600));

      if (m_FailureInterval != 0)
      {
        if (Interlocked.Increment(ref m_RequestCount) % m_FailureInterval == 0)
        {
          throw new PaymentProcessorException("Payment processing failed");
        }
      }
    }

    public void GetCreditCardUpdates(string transactionId, List<CreditCardPaymentMethod> cardsToUpdate, ref List<CreditCardPaymentMethod> updatedCards)
    {
        updatedCards.AddRange(cardsToUpdate);
    }

    public void ReverseAuthorizedCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo, string requestParms, out string warnings, double timeout = 0, string cos = "")
    {
        warnings = null;
        m_Logger.LogDebug("Received payment method type: {0}", ccPaymentMethod.GetType().AssemblyQualifiedName);
        Random rnd = new Random();
        Thread.Sleep(rnd.Next(300, 600));

        FailureCheck(timeout);
    }

    private void FailureCheck(double timeout)
    {
      if ((m_FailureInterval != 0) || (m_TimeoutInterval != 0) || (m_SleepTooLongInterval != 0))
      {
        Interlocked.Increment(ref m_RequestCount);
        if ((m_FailureInterval != 0) && (m_RequestCount % m_FailureInterval == 0))
        {
          throw new PaymentProcessorException("Payment processing failed");
        }
        if ((m_TimeoutInterval != 0) && (m_RequestCount % m_TimeoutInterval == 0))
        {
          throw new TimeoutException();
        }
        if ((m_SleepTooLongInterval != 0) && (m_RequestCount % m_SleepTooLongInterval == 0))
        {
          Thread.Sleep(new TimeSpan(0, 0, 0, 0, (int)timeout * 3));
        }
      }
    }
    #endregion
  }
}
