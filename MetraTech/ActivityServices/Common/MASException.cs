using System;
using System.Collections.Generic;
using System.Globalization;
using System.Resources;
using System.Text;
using System.ServiceModel;
using System.Threading;

namespace MetraTech.ActivityServices.Common
{
  #region Abstract Base Classes
  [Serializable]
  public abstract class MASBaseFaultDetail
  {
  }

  public abstract class MASBaseException : Exception
  {
    public MASBaseException()
      : base()
    {
    }

    public MASBaseException(string message)
      : base(message)
    {
    }

    public abstract FaultException CreateFaultDetail();
  }
  #endregion

  #region Exception Classes
  [Serializable]
  public class MASBasicFaultDetail : MASBaseFaultDetail
  {
    #region Members
    private List<string> m_DetailMessage = new List<string>();
    private UInt64 m_ErrorCode;
    #endregion

    #region Constructors
    public MASBasicFaultDetail()
    {
    }

    public MASBasicFaultDetail(string baseMessage)
    {
      m_DetailMessage.Add(baseMessage);
    }

    public MASBasicFaultDetail(string baseMessage, ErrorCodes errorCode)
    {
      m_DetailMessage.Add(baseMessage);
        m_ErrorCode = (ulong) errorCode;
    }
    #endregion

    #region Public Properties
    public List<string> ErrorMessages
    {
      get { return m_DetailMessage; }
    }

    public ErrorCodes ErrorCode
    {
      get { return (ErrorCodes)m_ErrorCode; }
      set { m_ErrorCode = (ulong) value; }
    }
    #endregion
  }

  public class MASBasicException : MASBaseException
  {
    #region Members
    private List<string> m_ErrorMessages = new List<string>();
    private UInt64 m_ErrorCode;
    private static ResourceManager resources = Exceptions.ResourceManager;
    #endregion

    #region Constructors
    public MASBasicException(string baseMessage)
    {
      m_ErrorMessages.Add(baseMessage);
      m_ErrorCode = 0;
    }

    public MASBasicException(string baseMessage, ErrorCodes errorCode)
    {
      m_ErrorMessages.Add(resources.GetString(((ErrorCodes)errorCode).ToString())); 
      m_ErrorMessages.Add(baseMessage);
      m_ErrorCode = (ulong)errorCode;
    }

    public MASBasicException(ErrorCodes errorCode)
    {
      m_ErrorMessages.Add(resources.GetString(((ErrorCodes)errorCode).ToString()));
      m_ErrorCode = (ulong)errorCode;
    }

    public MASBasicException(MASBasicFaultDetail detail)
    {
      foreach (string msg in detail.ErrorMessages)
      {
        this.m_ErrorMessages.Add(msg);
      }
        this.ErrorCode = detail.ErrorCode;
    }
    #endregion

    #region Public Methods
    public void AddErrorMessage(string message)
    {
      m_ErrorMessages.Add(message);
    }

    public override FaultException CreateFaultDetail()
    {
      MASBasicFaultDetail detail = new MASBasicFaultDetail();

      detail.ErrorMessages.AddRange(m_ErrorMessages);
      detail.ErrorCode = this.ErrorCode;
      FaultException<MASBasicFaultDetail> fe;
      if (ErrorCode != 0)
      {
        fe = new FaultException<MASBasicFaultDetail>(detail, this.Message);
      }
      else
      {
        fe = new FaultException<MASBasicFaultDetail>(detail, "Handled Exception in MetraNet Activity Services");
      }
      return fe;
    }
    #endregion

    #region Public Properties
    public override string Message
    {
      get
      {
        CultureInfo ci = Thread.CurrentThread.CurrentCulture;
        string msg = resources.GetString(((ErrorCodes)m_ErrorCode).ToString(), ci);

        for (int i = 0; i < m_ErrorMessages.Count; i++)
        {
          msg += string.Format("\\n{0}", m_ErrorMessages[i]);
        }

        return msg;
      }
    }

    public ErrorCodes ErrorCode
    {
      get { return (ErrorCodes)m_ErrorCode; }
      set { m_ErrorCode = (ulong) value; }
    }
    #endregion
  }

  [Serializable]
  public class PaymentProcessorFaultDetail : MASBaseFaultDetail
  {
    #region Members
    private List<string> m_DetailMessage = new List<string>();
    #endregion

    #region Constructors
    public PaymentProcessorFaultDetail()
    {
    }

    public PaymentProcessorFaultDetail(string baseMessage)
    {
      m_DetailMessage.Add(baseMessage);
    }
    #endregion

    #region Public Properties
    public List<string> ErrorMessages
    {
      get { return m_DetailMessage; }
    }
    #endregion
  }

  public class PaymentProcessorException : MASBaseException
  {
    #region Members
    private List<string> m_ErrorMessages = new List<string>();
    #endregion

    #region Constructors
    public PaymentProcessorException(string baseMessage)
    {
      m_ErrorMessages.Add(baseMessage);
    }

    public PaymentProcessorException(PaymentProcessorFaultDetail detail)
    {
      foreach (string msg in detail.ErrorMessages)
      {
        this.m_ErrorMessages.Add(msg);
      }
    }
    #endregion

    #region Public Methods
    public void AddErrorMessage(string message)
    {
      m_ErrorMessages.Add(message);
    }

    public override FaultException CreateFaultDetail()
    {
      PaymentProcessorFaultDetail detail = new PaymentProcessorFaultDetail();

      detail.ErrorMessages.AddRange(m_ErrorMessages);

      FaultException<PaymentProcessorFaultDetail> fe = new FaultException<PaymentProcessorFaultDetail>(detail, "Handled Exception Communicating with the Payment Processor.");

      return fe;
    }
    #endregion

    #region Public Properties
    public override string Message
    {
      get
      {
        string msg = m_ErrorMessages[0];

        for (int i = 1; i < m_ErrorMessages.Count; i++)
        {
          msg += string.Format("\\n{0}", m_ErrorMessages[i]);
        }

        return msg;
      }
    }
    #endregion
  }



  [Serializable]
  public class ArNotificationProcessorFaultDetail : MASBaseFaultDetail
  {
      #region Members
      private List<string> m_DetailMessage = new List<string>();
      #endregion

      #region Constructors
      public ArNotificationProcessorFaultDetail()
      {
      }

      public ArNotificationProcessorFaultDetail(string baseMessage)
      {
          m_DetailMessage.Add(baseMessage);
      }
      #endregion

      #region Public Properties
      public List<string> ErrorMessages
      {
          get { return m_DetailMessage; }
      }
      #endregion
  }

  public class ArNotificationProcessorException : MASBaseException
  {
      #region Members
      private List<string> m_ErrorMessages = new List<string>();
      #endregion

      #region Constructors
      public ArNotificationProcessorException(string baseMessage)
      {
          m_ErrorMessages.Add(baseMessage);
      }

      public ArNotificationProcessorException(ArNotificationProcessorFaultDetail detail)
      {
          foreach (string msg in detail.ErrorMessages)
          {
              this.m_ErrorMessages.Add(msg);
          }
      }
      #endregion

      #region Public Methods
      public void AddErrorMessage(string message)
      {
          m_ErrorMessages.Add(message);
      }

      public override FaultException CreateFaultDetail()
      {
          ArNotificationProcessorFaultDetail detail = new ArNotificationProcessorFaultDetail();

          detail.ErrorMessages.AddRange(m_ErrorMessages);

          FaultException<ArNotificationProcessorFaultDetail> fe = new FaultException<ArNotificationProcessorFaultDetail>(detail, "Handled Exception Communicating with the AR Payment Notification Processor.");

          return fe;
      }
      #endregion

      #region Public Properties
      public override string Message
      {
          get
          {
              string msg = m_ErrorMessages[0];

              for (int i = 1; i < m_ErrorMessages.Count; i++)
              {
                  msg += string.Format("\\n{0}", m_ErrorMessages[i]);
              }

              return msg;
          }
      }
      #endregion
  }


  #endregion
}
