using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.OnlineBill;
using MetraTech.Security;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract()]
  public interface ITicketingService
  {
    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetTicket(string userName, string nameSpace, out string ticket);

    [OperationContract()]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ValidatetTicket(string userName, string nameSpace, string ticket, out bool isValid);
  }

  [ServiceBehavior()]
  public class TicketingService : CMASServiceBase, ITicketingService
  {
    private static readonly Logger m_Logger = new Logger("[TicketingService]");


    #region INotificationService Members

    public void GetTicket(string userName, string nameSpace, out string ticket)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetTicket"))
      {
      ticket = String.Empty;

      try
      {
        m_Logger.LogDebug("Creating ticket for username {0} and namespace {1}", userName, nameSpace);
        MetraTech.Security.Auth auth = new MetraTech.Security.Auth();
        auth.Initialize(userName, nameSpace);
        ticket = auth.CreateTicket();

        QueryStringEncrypt queryStringEncrypt = new QueryStringEncrypt();
        ticket = queryStringEncrypt.EncryptString(ticket);
      }
      catch (MASBasicException masE)
      {
        m_Logger.LogException(String.Format("Exception creating ticket for username '{0}' and namespace '{1}'", userName, nameSpace), masE);

        throw;
      }
      catch (Exception e)
      {
        m_Logger.LogException(String.Format("Exception creating ticket for username '{0}' and namespace '{1}'", userName, nameSpace), e);
        throw;
      }
      }
    }



    public void ValidatetTicket(string userName, string nameSpace, string ticket, out bool isValid)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ValidateTicket"))
      {
      isValid = false;

      try
      {
        m_Logger.LogDebug("Checking auth ticket");
        
        QueryStringEncrypt queryStringEncrypt = new QueryStringEncrypt();
        ticket = queryStringEncrypt.DecryptString(ticket);

        MetraTech.Security.Auth auth = new MetraTech.Security.Auth();
        auth.Initialize(userName, nameSpace);
        object ctx = null;

        LoginStatus status = auth.LoginWithTicket(ticket, ref ctx);
        if(status == LoginStatus.OK || status == LoginStatus.OKPasswordExpiringSoon)
        {
          isValid = true;
        }
      }
      catch (Exception)
      {
        m_Logger.LogInfo("Invalid ticket presented.");
      }
      }
    }

    #endregion
  }

 
}
