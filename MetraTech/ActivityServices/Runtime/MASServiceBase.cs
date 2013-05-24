using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Dispatcher;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;

using MetraTech.ActivityServices.Interfaces;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;

namespace MetraTech.ActivityServices.Runtime
{
  public class CMASServiceBase : IServiceBehavior, IErrorHandler
  {
    private static Logger m_Logger;

    static CMASServiceBase()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[MASErrorHandler]");
    }

    #region IErrorHandler Members

    public bool HandleError(Exception error)
    {
      return false;
    }

    public void ProvideFault(Exception error, System.ServiceModel.Channels.MessageVersion version, ref System.ServiceModel.Channels.Message fault)
    {
      if (error is MASBaseException)
      {
        FaultException fe = ((MASBaseException)error).CreateFaultDetail();
        MessageFault messageFault = fe.CreateMessageFault();
        fault = Message.CreateMessage(version, messageFault, fe.Action);
      }
      else
      {
        m_Logger.LogException("Unhandled exception in ActivityServices service", error);

        MASBasicFaultDetail faultDetail = new MASBasicFaultDetail("An unexpected error occurred in MetraNet Activity Services.");

        FaultException<MASBasicFaultDetail> fe = new FaultException<MASBasicFaultDetail>(faultDetail, "Unhandled Exception in MetraNet Activity Services");
        MessageFault messageFault = fe.CreateMessageFault();
        fault = Message.CreateMessage(version, messageFault, fe.Action);
      }
    }

    #endregion

    #region IServiceBehavior Members

    public void AddBindingParameters(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase, System.Collections.ObjectModel.Collection<ServiceEndpoint> endpoints, BindingParameterCollection bindingParameters)
    {
    }

    public void ApplyDispatchBehavior(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
    {
      foreach (ChannelDispatcher disp in serviceHostBase.ChannelDispatchers)
      {
        disp.ErrorHandlers.Add(this);
      }
    }

    public void Validate(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
    {
    }

    #endregion

    protected int ResolveAccountIdentifier(AccountIdentifier acct)
    {
      if (acct.AccountID != null)
      {
        return (int)acct.AccountID;
      }
      else
      {
        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("dbo.LookupAccount"))
              {
                  stmt.AddReturnValue(MTParameterType.Integer);

                  stmt.AddParam("login", MTParameterType.String, acct.Username);
                  stmt.AddParam("namespace", MTParameterType.String, acct.Namespace);

                  stmt.ExecuteNonQuery();

                  int retval = (int)stmt.ReturnValue;

                  return retval;
              }
          }
        }
        catch(Exception e)
        {
          m_Logger.LogException("Exception resolving account by username/namespace", e);

          throw new MASBasicException("Unable to locate account specified");
         } 
      }
    }

    protected IMTSessionContext GetSessionContext()
    {
      IMTSessionContext retval = null;

      CMASClientIdentity identity = null;
      try
      {
        identity = (CMASClientIdentity)ServiceSecurityContext.Current.PrimaryIdentity;

        retval = identity.SessionContext;        
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception getting identity in GetSubscriptions", e);

        throw new MASBasicException("Service security identity is of improper type");
      }

      return retval;
    }
  }
}
