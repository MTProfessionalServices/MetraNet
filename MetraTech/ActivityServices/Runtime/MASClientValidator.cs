using System;
using System.Collections.Generic;
using System.Text;
using System.IdentityModel.Claims;
using System.IdentityModel.Selectors;
using System.IdentityModel.Tokens;
using System.IdentityModel.Policy;
using System.Security.Principal;
using MetraTech.Interop.MTAuth;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using System.ServiceModel.Description;
using System.ServiceModel.Security;
using System.Reflection;
using MetraTech.ActivityServices.Common;
using System.Collections.ObjectModel;
using System.Security.Cryptography.X509Certificates;
using MetraTech.Interop.MTServerAccess;

namespace MetraTech.ActivityServices.Runtime
{
  internal class CMASServiceCredential : ServiceCredentials
  {

    public CMASServiceCredential()
      : base()
    {
    }

    protected override ServiceCredentials CloneCore()
    {
      return new CMASServiceCredential();
    }

    public override SecurityTokenManager CreateSecurityTokenManager()
    {
      return new CMASSecurityTokenManager(this);
    }

  }

  internal class CMASSecurityTokenManager : ServiceCredentialsSecurityTokenManager
  {
    CMASServiceCredential myUserNameCredential;

    public CMASSecurityTokenManager(CMASServiceCredential myUserNameCredential)
      : base(myUserNameCredential)
    {
      this.myUserNameCredential = myUserNameCredential;
    }

    public override SecurityTokenAuthenticator CreateSecurityTokenAuthenticator(SecurityTokenRequirement tokenRequirement, out SecurityTokenResolver outOfBandTokenResolver)
    {
      if (tokenRequirement.TokenType == SecurityTokenTypes.UserName)
      {
        outOfBandTokenResolver = null;
        return new CMASUserNameTokenAuthenticator();
      }
      else if (tokenRequirement.TokenType == SecurityTokenTypes.X509Certificate)
      {
          outOfBandTokenResolver = null;
          return new CMASX509CertificateAuthenticator();
      }
      else
      {
          return base.CreateSecurityTokenAuthenticator(tokenRequirement, out outOfBandTokenResolver);
      }
    }

  }

  #region Username/Password validators
  internal class CMASUserNameTokenAuthenticator : UserNameSecurityTokenAuthenticator
  {
      private static IMTSessionContext mSUContext = null;
      private static object mSyncContext = new object();
      private static IMTSessionContext SUContext
      {
          get
          {
              if (mSUContext == null)
              {
                  lock (mSyncContext)
                  {
                      if (mSUContext == null)
                      {
                          IMTServerAccessDataSet sads = new MTServerAccessDataSet();
                          sads.Initialize();

                          IMTServerAccessData sad = sads.FindAndReturnObject("SuperUser");

                          IMTLoginContext lc = new MTLoginContext();
                          mSUContext = lc.Login(sad.UserName, "system_user", sad.Password);
                      }
                  }
              }

              return mSUContext;
          }
      }

    protected override ReadOnlyCollection<IAuthorizationPolicy> ValidateUserNamePasswordCore(string userName, string password)
    {
      try
      {
        IMTLoginContext loginContext = new MTLoginContextClass();
        IMTSessionContext sessionContext = null;

        if(!String.IsNullOrEmpty(password) && !password.StartsWith(((char)8).ToString()))
        {
           sessionContext = loginContext.Login(userName, "system_user", password);
        }
        else if (!String.IsNullOrEmpty(password))
        {
            sessionContext = new MTSessionContextClass();
            sessionContext.FromXML(password.Substring(1));
        }
        else
        {
            string validatedNameSpace, validatedUserName;
            TicketManager.ValidateTicket(SUContext, userName, out validatedNameSpace, out validatedUserName, out sessionContext);
        }

        ClaimSet claimSet = new DefaultClaimSet(ClaimSet.System, new Claim(ClaimTypes.Name, userName, Rights.PossessProperty));
        List<IIdentity> identities = new List<IIdentity>(1);
        identities.Add(new CMASClientIdentity(userName, sessionContext));
        List<IAuthorizationPolicy> policies = new List<IAuthorizationPolicy>(1);
        policies.Add(new CMASAuthPolicy(ClaimSet.System, claimSet, DateTime.MaxValue.ToUniversalTime(), identities));
        return policies.AsReadOnly();
      }
      catch (Exception e)
      {
        throw new FaultException("Unknown Username or Password, " + e.Message);
      }
    }
  }

  internal class CMASUserNameValidator : UserNamePasswordValidator
  {
      private static IMTSessionContext mSUContext = null;
      private static object mSyncContext = new object();
      private static IMTSessionContext SUContext
      {
          get
          {
              if (mSUContext == null)
              {
                  lock (mSyncContext)
                  {
                      if (mSUContext == null)
                      {
                          IMTServerAccessDataSet sads = new MTServerAccessDataSet();
                          sads.Initialize();

                          IMTServerAccessData sad = sads.FindAndReturnObject("SuperUser");

                          IMTLoginContext lc = new MTLoginContext();
                          mSUContext = lc.Login(sad.UserName, "system_user", sad.Password);
                      }
                  }
              }

              return mSUContext;
          }
      }

      public override void Validate(string userName, string password)
      {
          try
          {
              IMTLoginContext loginContext = new MTLoginContextClass();
              IMTSessionContext sessionContext = null;

              if (!String.IsNullOrEmpty(password) && !password.StartsWith(((char)8).ToString()))
              {
                  sessionContext = loginContext.Login(userName, "system_user", password);
              }
              else if (!String.IsNullOrEmpty(password))
              {
                  sessionContext = new MTSessionContextClass();
                  sessionContext.FromXML(password.Substring(1));
              }
              else
              {
                  string validatedNameSpace, validatedUserName;
                  TicketManager.ValidateTicket(SUContext, userName, out validatedNameSpace, out validatedUserName, out sessionContext);
              }

              CMASIdentityAuthPolicy.SetSessionContext(userName, sessionContext);
          }
          catch (Exception e)
          {
              throw new FaultException("Unknown Username or Password, " + e.Message);
          }
      }
  }
  #endregion

  #region X509 Certificate validators
  internal class CMASX509CertificateAuthenticator : X509SecurityTokenAuthenticator
    {
        protected override System.Collections.ObjectModel.ReadOnlyCollection<IAuthorizationPolicy> ValidateTokenCore(SecurityToken token)
        {
            try
            {
                // Call the base method as an easy way to validate the certificate
                base.ValidateTokenCore(token);

                // Then try to login to MetraNet to validate the cert has been registered
                // and to get the session context
                IMTLoginContext loginContext = new MTLoginContextClass();
                IMTSessionContext sessionContext = null;

                sessionContext = loginContext.Login(
                    ((X509SecurityToken)token).Certificate.SerialNumber,
                    "auth",
                    ((X509SecurityToken)token).Certificate.Thumbprint);

                ClaimSet claimSet = new DefaultClaimSet(ClaimSet.System, new Claim(ClaimTypes.Name, ((X509SecurityToken)token).Certificate.SerialNumber, Rights.PossessProperty));
                List<IIdentity> identities = new List<IIdentity>(1);
                identities.Add(new CMASClientIdentity(((X509SecurityToken)token).Certificate.SerialNumber, sessionContext));
                List<IAuthorizationPolicy> policies = new List<IAuthorizationPolicy>(1);
                policies.Add(new CMASAuthPolicy(ClaimSet.System, claimSet, DateTime.MaxValue.ToUniversalTime(), identities));
                return policies.AsReadOnly();
            }
            catch (Exception e)
            {
                throw new FaultException("Unknown Username or Password, " + e.Message);
            }
        }
    }
  #endregion

  internal class CMASAuthPolicy : IAuthorizationPolicy
  {
    String id = Guid.NewGuid().ToString();
    ClaimSet issuer;
    ClaimSet issuance;
    DateTime expirationTime;
    IList<IIdentity> identities;

    public CMASAuthPolicy(ClaimSet issuer, ClaimSet issuance, DateTime expirationTime, IList<IIdentity> identities)
    {
      if (issuer == null)
        throw new ArgumentNullException("issuer");
      if (issuance == null)
        throw new ArgumentNullException("issuance");

      this.issuer = issuer;
      this.issuance = issuance;
      this.identities = identities;
      this.expirationTime = expirationTime;
    }

    public string Id
    {
      get { return this.id; }
    }

    public ClaimSet Issuer
    {
      get { return this.issuer; }
    }

    public DateTime ExpirationTime
    {
      get { return this.expirationTime; }
    }

    public bool Evaluate(EvaluationContext evaluationContext, ref object state)
    {
      evaluationContext.AddClaimSet(this, this.issuance);

      if (this.identities != null)
      {
        object value;
        IList<IIdentity> contextIdentities;
        if (!evaluationContext.Properties.TryGetValue("Identities", out value))
        {
          contextIdentities = new List<IIdentity>(this.identities.Count);
          evaluationContext.Properties.Add("Identities", contextIdentities);
        }
        else
        {
          contextIdentities = value as IList<IIdentity>;
        }
        foreach (IIdentity identity in this.identities)
        {
          contextIdentities.Add(identity);
        }
      }

      evaluationContext.RecordExpirationTime(this.expirationTime);
      return true;
    }
  }

  internal class CMASServiceAuthorizationMgr : ServiceAuthorizationManager
  {
    private Dictionary<string, List<IMTCompositeCapability>> m_ServiceCaps = new Dictionary<string, List<IMTCompositeCapability>>();

    public CMASServiceAuthorizationMgr(Type svcType)
    {
      try
      {
        IMTSecurity sec = new MTSecurityClass();
        IMTCompositeCapability compCap;
        List<IMTCompositeCapability> capsList;

        MethodInfo[] opInfos = svcType.GetMethods(BindingFlags.Instance | BindingFlags.DeclaredOnly | BindingFlags.Public);

        foreach (MethodInfo opInfo in opInfos)
        {
          capsList = new List<IMTCompositeCapability>();

          object[] caps = opInfo.GetCustomAttributes(typeof(OperationCapabilityAttribute), false);

          foreach (OperationCapabilityAttribute cap in caps)
          {
            compCap = sec.GetCapabilityTypeByName(cap.CapabilityName).CreateInstance();

            capsList.Add(compCap);
          }

          m_ServiceCaps.Add(opInfo.Name, capsList);
        }
      }
      catch (Exception)
      {
        m_ServiceCaps.Clear();
      }
    }

    protected override bool CheckAccessCore(OperationContext operationContext)
    {
      bool retval = true;

      retval = base.CheckAccessCore(operationContext);

      if(retval)
      {
        CMASClientIdentity client = operationContext.ServiceSecurityContext.PrimaryIdentity as CMASClientIdentity;
        string action = operationContext.IncomingMessageHeaders.Action;
        string operation = action.Substring(action.LastIndexOf('/') + 1);

        if (m_ServiceCaps.ContainsKey(operation))
        {
          foreach (IMTCompositeCapability compCap in m_ServiceCaps[operation])
          {
            if (!client.SessionContext.SecurityContext.CoarseHasAccess(compCap))
            {
              throw new MASBasicException("Access is Denied");
            }
          }
        }
        else
        {
          throw new MASBasicException("Access is Denied");
        }
      }

      return retval;
    }

    protected override System.Collections.ObjectModel.ReadOnlyCollection<IAuthorizationPolicy> GetAuthorizationPolicies(OperationContext operationContext)
    {
        ReadOnlyCollection<IAuthorizationPolicy> basePolicies =  base.GetAuthorizationPolicies(operationContext);
        List<IAuthorizationPolicy> policies = new List<IAuthorizationPolicy>();

        if (operationContext.ServiceSecurityContext.PrimaryIdentity.GetType() == typeof(CMASClientIdentity))
        {
            policies.AddRange(basePolicies);
        }
        else
        {
            if (string.Compare(operationContext.ServiceSecurityContext.PrimaryIdentity.AuthenticationType, "X509", true) == 0)
            {
                try
                {
                    // Then try to login to MetraNet to validate the cert has been registered
                    // and to get the session context
                    IMTLoginContext loginContext = new MTLoginContextClass();
                    IMTSessionContext sessionContext = null;

                    X509Certificate2 certificate = ((X509SecurityToken)operationContext.IncomingMessageProperties.Security.TransportToken.SecurityToken).Certificate;

                    sessionContext = loginContext.Login(
                        certificate.SerialNumber,
                        "auth",
                        certificate.Thumbprint);

                    CMASIdentityAuthPolicy.SetSessionContext(certificate.SerialNumber, sessionContext);

                    policies.Add(new CMASIdentityAuthPolicy(certificate.SerialNumber));
                }
                catch (Exception e)
                {
                    throw new FaultException("Unknown Username or Password, " + e.Message);
                }
            }
            else
            {
                policies.Add(new CMASIdentityAuthPolicy(operationContext.ServiceSecurityContext.PrimaryIdentity.Name));
            }
        }

        return policies.AsReadOnly();
    }
  }

  internal class CMASIdentityAuthPolicy : IAuthorizationPolicy
  {
      private static Dictionary<string, Queue<IMTSessionContext>> m_SessionContexts = new Dictionary<string, Queue<IMTSessionContext>>();

      private string m_UserName;

      public CMASIdentityAuthPolicy(string userName)
      {
          m_UserName = userName;
      }

      #region IAuthorizationPolicy Members

      public bool Evaluate(EvaluationContext evaluationContext, ref object state)
      {
          evaluationContext.AddClaimSet(this, ClaimSet.System);

          object value;
          IList<IIdentity> contextIdentities;
          if (!evaluationContext.Properties.TryGetValue("Identities", out value))
          {
              contextIdentities = new List<IIdentity>(1);
              evaluationContext.Properties.Add("Identities", contextIdentities);
          }
          else
          {
              contextIdentities = value as IList<IIdentity>;
          }

          IMTSessionContext sessionContext = null;
          lock (m_SessionContexts)
          {
              sessionContext = m_SessionContexts[m_UserName].Dequeue();
          }

          contextIdentities.Add(new CMASClientIdentity(m_UserName, sessionContext));

          evaluationContext.RecordExpirationTime(DateTime.MaxValue);
          return true;
      }

      public ClaimSet Issuer
      {
          get { return ClaimSet.System; }
      }

      #endregion

      #region IAuthorizationComponent Members

      public string Id
      {
          get { return Guid.NewGuid().ToString(); }
      }

      #endregion

      public static void SetSessionContext(string userName, IMTSessionContext sessionContext)
      {
          lock (m_SessionContexts)
          {
              if (!m_SessionContexts.ContainsKey(userName))
              {
                  m_SessionContexts[userName] = new Queue<IMTSessionContext>();
              }

              m_SessionContexts[userName].Enqueue(sessionContext);
          }
      }
  }

}
