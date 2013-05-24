using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;

using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using System.Reflection;
using MetraTech.DomainModel.ProductView;
using MetraTech.Interop.MTAuth;
using MetraTech.Auth.Capabilities;
using System.Security.Cryptography;
using MetraTech.DataAccess;
using MetraTech.Security.Crypto;
using System.Transactions;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using MetraTech.Security;
using AuthCap = MetraTech.Auth.Capabilities;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IAuthService
  {
    /*
    •	Removed appName parameter from all methods
    •	Added passwordExpirationDays parameter to LoginAccount method
    •	Added logic to LoginAccount method to use Auth class to manage password expirations properly
    •	Added definition of new “Logon Account” capability and how it is to be registered in CapabilityTypes.xml
    */

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoginAccount(string nameSpace,
                      string userName,
                      string password,
                      int ticketLifespanMins,
                      out int? passwordExpirationDays,
                      out string ticket,
                      out string sessionContext);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void LoginAccountWithAdditionalData(string nameSpace,
                                        string userName,
                                        string password,
                                        int ticketLifespanMins,
                                        string loggedInAs,
                                        string applicationName,
                                        out int? passwordExpirationDays,
                                        out string ticket,
                                        out string sessionContext);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void TicketToAccount(string nameSpace,
                         string userName,
                         int ticketLifespanMins,
                         out string ticket,
                         out string sessionContext);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void TicketToAccountWithAdditionalData(string nameSpace,
                                           string userName,
                                           int ticketLifespanMins,
                                           string loggedInAs,
                                           string applicationName,
                                           out string ticket,
                                           out string sessionContext);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ValidateTicket(string ticket,
                        out string nameSpace,
                        out string userName,
                        out string sessionContext);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void InvalidateTicket(string ticket);
  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class AuthService : CMASServiceBase, IAuthService
  {
    private static Logger mLogger = new Logger("[AuthService]");

    #region Interface Methods.

    /// <summary>
    /// 
    /// </summary>
    /// <param name="nameSpace"></param>
    /// <param name="userName"></param>
    /// <param name="password"></param>
    /// <param name="ticketLifespanMins"></param>
    /// <param name="passwordExpirationDays"></param>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    [OperationCapability("LogonAccount")]
    public void LoginAccount(string nameSpace,
                             string userName,
                             string password,
                             int ticketLifespanMins,
                             out int? passwordExpirationDays,
                             out string ticket,
                             out string sessionContext)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("LoginAccout"))
      {
        LoginAccount(nameSpace, userName, password, ticketLifespanMins, null, null, out passwordExpirationDays, out ticket,
                     out sessionContext);
      }
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="nameSpace"></param>
    /// <param name="userName"></param>
    /// <param name="password"></param>
    /// <param name="ticketLifespanMins"></param>
    /// <param name="loggedInAs"></param>
    /// <param name="applicationName"></param>
    /// <param name="passwordExpirationDays"></param>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    [OperationCapability("LogonAccount")]
    public void LoginAccountWithAdditionalData(string nameSpace, string userName, string password,
                                               int ticketLifespanMins, string loggedInAs, string applicationName,
                                               out int? passwordExpirationDays, out string ticket,
                                               out string sessionContext)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("LoginAccountWithAdditionalData"))
      {
        LoginAccount(nameSpace, userName, password, ticketLifespanMins, null, null, out passwordExpirationDays, out ticket,
                     out sessionContext);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="nameSpace"></param>
    /// <param name="userName"></param>
    /// <param name="ticketLifespanMins"></param>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    [OperationCapability("Impersonation")]
    [OperationCapability("Manage Account Hierarchies")]
    public void TicketToAccount(string nameSpace,
                                string userName,
                                int ticketLifespanMins,
                                out string ticket,
                                out string sessionContext)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("TicketToAccount"))
      {
        TicketToAccount(nameSpace, userName, ticketLifespanMins, null, null, out ticket, out sessionContext);
      }
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="nameSpace"></param>
    /// <param name="userName"></param>
    /// <param name="ticketLifespanMins"></param>
    /// <param name="loggedInAs"></param>
    /// <param name="applicationName"></param>
    /// <param name="ticket"></param>
    /// <param name="sessionContext"></param>
    public void TicketToAccountWithAdditionalData(string nameSpace, string userName, int ticketLifespanMins,
                                                  string loggedInAs, string applicationName, out string ticket,
                                                  out string sessionContext)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("TicketToAccountWithAdditionalData"))
      {
        TicketToAccount(nameSpace, userName, ticketLifespanMins, loggedInAs, applicationName, out ticket, out sessionContext);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="ticket"></param>
    /// <param name="nameSpace"></param>
    /// <param name="userName"></param>
    /// <param name="sessionContext"></param>
    [OperationCapability("Unlimited Capability")]
    public void ValidateTicket(string ticket,
                               out string nameSpace,
                               out string userName,
                               out string sessionContext)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ValidateTicket"))
      {
        IMTSessionContext outContext = null;

        TicketManager.ValidateTicket(GetSessionContext(), ticket, out nameSpace, out userName, out outContext);

        sessionContext = outContext.ToXML();
      }
    }

    /// <summary>
    /// Invalidate Ticket
    /// </summary>
    /// <param name="ticket">ticket id to be invalidated.</param>
    public void InvalidateTicket(string ticket)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("InvalidateTicket"))
      {
        TicketManager.InvalidateTicket(ticket);
      }
    }

    #endregion

    #region Private Methods

    private void LoginAccount(string nameSpace, string userName, string password, int ticketLifespanMins, string loggedInAs, string applicationName,
                              out int? passwordExpirationDays, out string ticket, out string sessionContext)
    {
      try
      {
        IMTSessionContext userSessionContext = null;

        ticket = sessionContext = null;
        passwordExpirationDays = null;

        MetraTech.Security.Auth auth = new MetraTech.Security.Auth();
        auth.Initialize(userName, nameSpace);

        if (auth.CheckIfAccountIsDormant())
        {
          #region Audit Entry

          AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_LOGIN_DORMANT_ACCOUNT_FAILED,
                                 GetSessionContext().AccountID,
                                 (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_LOGIN, -1,
                                 String.Format("account dormant for username {0}, nameSpace = {1}.", userName, nameSpace));

          #endregion

          throw new MASBasicException("Login Failed. User account is dormant");
        }

        if (auth.Credentials.ExpireDate != null)
        {
          if (MetraTime.Now > auth.Credentials.ExpireDate)
          {
            #region Audit Entry

            AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_LOGIN_PASSWORD_EXPIRED_FAILED,
                                   GetSessionContext().AccountID,
                                   (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_LOGIN, -1,
                                   String.Format("password expired for username {0}, nameSpace = {1}.", userName, nameSpace));

            #endregion

            throw new MASBasicException("Login Failed. password expired.");
          }
        }
        else
        {
          auth.SetPasswordExpiryDate();
        }

        if (!auth.Credentials.IsEnabled || auth.Credentials.NumberOfFailuresSinceLogin > PasswordConfig.GetInstance().LoginAttemptsAllowed)
        {
          if (MetraTime.Now > auth.Credentials.AutoResetFailuresDate)
          {
            auth.UnlockAccount(GetSessionContext());
          }
          else
          {
            auth.RecordLoginFailure();

            #region Audit Entry

            AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_LOGIN_ACCOUNT_LOCKED_FAILED,
                                   GetSessionContext().AccountID,
                                   (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_LOGIN, -1,
                                   String.Format("Account locked for user name {0}, nameSpace = {1}.", userName, nameSpace));

            #endregion

            throw new MASBasicException("Login Failed. Account Locked out.");
          }
        }

        try
        {
          IMTLoginContext loginContext = new MTLoginContextClass();

          if (!string.IsNullOrEmpty(loggedInAs) || !string.IsNullOrEmpty(applicationName))
          {
            userSessionContext = loginContext.LoginWithAdditionalData(userName, nameSpace, password, loggedInAs, applicationName);
          }
          else
          {
            userSessionContext = loginContext.Login(userName, nameSpace, password);
          }

          sessionContext = userSessionContext.ToXML();
        }
        catch
        {
          #region Audit Entry

          AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_LOGIN_FAILED,
                                 GetSessionContext().AccountID,
                                 (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_LOGIN, -1,
                                 String.Format("Login Failed for user name {0}, nameSpace = {1}.", userName, nameSpace));

          #endregion

          throw new MASBasicException("Login Failed.");
        }

        using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(),
                                                             EnterpriseServicesInteropOption.Full))
        {
          auth.RecordSuccessfulLogin();

          #region Audit Entry

          AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_LOGIN_SUCCESS,
                                 GetSessionContext().AccountID,
                                 (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_LOGIN, -1,
                                 String.Format("Login successful for user name {0}, nameSpace = {1}.", userName, nameSpace));

          #endregion

          scope.Complete();
        }

        ticket = TicketManager.CreateTicket(userSessionContext.AccountID, nameSpace, userName, ticketLifespanMins);

        if (auth.Credentials.ExpireDate.Value.Subtract(MetraTime.Now).Days < PasswordConfig.GetInstance().DaysToStartWarningPasswordWillExpire)
        {
          passwordExpirationDays = (auth.Credentials.ExpireDate.Value.Subtract(MetraTime.Now).Days);
        }
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("Error while creating ticket.", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Error while creating ticket.", e);

        throw new MASBasicException("Error while creating ticket.");
      }
    }

    private void TicketToAccount(string nameSpace, string userName, int ticketLifespanMins, string loggedInAs, string applicationName,
                                 out string ticket, out string sessionContext)
    {
      try
      {
        // don't need to check super user details
        int impersonatorId = GetSessionContext().AccountID;
        if (!GetSessionContext().SecurityContext.IsSuperUser())
        {
          #region Check Caller Has "Manage Account Hierarchies" capability

          AccountIdentifier acc = new AccountIdentifier(userName, nameSpace);
          int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(acc);

          if (!HasManageAccHeirarchyAccess(acctId, MetraTech.DomainModel.Enums.Core.Global.AccessLevel.WRITE,
                                         MetraTech.Interop.MTAuth.MTHierarchyPathWildCard.SINGLE))
          {
            mLogger.LogError("You do not have 'Manage Account Hierarchies' capability");
            throw new MASBasicException("You do not have 'Manage Account Hierarchies' capability");
          }

          #endregion

          // user could be ticketing back to their account, so don't check impersonation
          if (acctId != impersonatorId)
          {
            #region Impersonation

            // check if the account can impersonate the specified account unless they are a csr
            if (!CanImpersonateAccount(acctId, impersonatorId))
            {
              mLogger.LogError("You cannot impersonate the specified account.");
              throw new MASBasicException("You cannot impersonate the specified account.");
            }

            #endregion
          }
        }

        MetraTech.Interop.MTAuth.MTSessionContext sessContext = (MTSessionContext)this.GetSessionContext();
        IMTLoginContext loginContext = new MTLoginContextClass();
        IMTSessionContext context;

        if (!string.IsNullOrEmpty(loggedInAs) || !string.IsNullOrEmpty(applicationName))
        {
          context = loginContext.LoginAsMPSAccountWithAdditionalData(sessContext, nameSpace, userName, loggedInAs, applicationName);
        }
        else
        {
          context = loginContext.LoginAsMPSAccount(sessContext, nameSpace, userName);
        }

        sessionContext = context.ToXML();

        ticket = TicketManager.CreateTicket(context.AccountID, nameSpace, userName, ticketLifespanMins);
      }
      catch (MASBasicException masE)
      {
        mLogger.LogException("Error while Ticket to account.", masE);
        throw;
      }
      catch (Exception e)
      {
        mLogger.LogException("Error while Ticket to account.", e);

        throw new MASBasicException("Error while Ticket to account.");
      }
    }

    #endregion

  }
}
