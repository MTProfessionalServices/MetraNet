using System;
using System.Threading;
using agsXMPP;
using agsXMPP.protocol.client;
using MetraTech.Interop.MTServerAccess;
using MetraTech.OnlineBill;
using MetraTech.Security;


namespace MetraTech.Events
{
  #region EventArgs
  /// <summary>
  /// EventArgs class that is fired when a new event is received.
  /// </summary>
  public class ReceiveEventEventArg: EventArgs
  {
    public string From { get; set; }
    public string MessageId { get; set; }
    public string Json { get; set; }
    public EventMessageBase EventObject { get; set; }
  }
  #endregion

  /// <summary>
  /// EventManager class manages XMPP connections to ejabberd server.  Uses the agsXMPP SDK. 
  /// </summary>
  public class EventManager : IDisposable
  {
    #region Member variables
    private string _jabberServer;
    private string _jabberId;
    private bool _isLoggedIn;
    private XmppClientConnection _xmpp;
    private readonly Logger _logger = new Logger("[MetraTech.Events]");
    private static volatile MTServerAccessDataSet _serveraccess;
    private static readonly object _syncRoot = new Object();
    #endregion

    #region Properties

    #endregion

    #region Events
    // The event we publish to receive incoming messages
    public delegate void NewEventsHandler(object sender, ReceiveEventEventArg args);
    public event NewEventsHandler NewEvents;
    #endregion

    #region Constructors
    /// <summary>
    /// Constructor takes in the MetraNet username and namespace.  This is turned into
    /// a jabber id in the format:
    ///   username-namespace-tenant@server 
    /// The tenant and server are taken from the JabberServer in ServerAccess/servers.xml.
    /// All accounts use a MetraNet managed password so there is no need for jabber server
    /// registration as an external auth module is used in ejabberd.
    /// </summary>
    public EventManager(string userName, string nameSpace)
    {
      _jabberServer = GetJabberServerName();
      if (!string.IsNullOrEmpty(_jabberServer))
      {
        Login(userName, nameSpace);
        WaitForLoginComplete();
      }
      else
      {
        _logger.LogInfo("No JabberServer found... not sending messages...");
      }
    }

    /// <summary>
    /// Constructor with no params will login as admin.  Admin account is taken from
    /// JabberServer in ServerAccess/servers.xml where the UserName is in the format:
    /// username-namespace
    /// </summary>
    public EventManager()
    {
      _jabberServer = GetJabberServerName();
      if (!string.IsNullOrEmpty(_jabberServer))
      {
        MTServerAccessData server = GetServer();
        string userName = server.UserName.Substring(0, server.UserName.LastIndexOf("-"));
        string nameSpace = server.UserName.Substring(server.UserName.LastIndexOf("-") + 1);
        Login(userName, nameSpace);
        WaitForLoginComplete();
      }
      else
      {
        _logger.LogInfo("No JabberServer found... not sending messages...");
      }
    }
    #endregion

    #region Static Methods
    /// <summary>
    /// Returns the MTServerAccessData for the "JabberServer in ServerAccess/servers.xml.
    /// </summary>
    private static MTServerAccessData GetServer()
    {
      if (_serveraccess == null)
      {
        lock (_syncRoot)
        {
          if (_serveraccess == null)
          {
            _serveraccess = new MTServerAccessDataSetClass();
            _serveraccess.Initialize();
          }
        }
      }
      return _serveraccess.FindAndReturnObjectIfExists("JabberServer");
    }
    
    /// <summary>
    /// Reads ServerAccess/servers.xml to get the "JabberServer" name. 
    /// </summary>
    /// <returns></returns>
    static public string GetJabberServerName()
    {
      MTServerAccessData jabberServer = GetServer();
      return jabberServer == null ? null : jabberServer.ServerName;
    }

    /// <summary>
    /// Reads ServerAccess/servers.xml to get the "JabberServer" source name (this is like a Tenant). 
    /// </summary>
    /// <returns></returns>
    static public string GetJabberSourceName()
    {
      MTServerAccessData jabberServer = GetServer();
      return jabberServer == null ? null : jabberServer.DataSource;
    }

    /// <summary>
    /// Generates a Jabber token for the specified jabber ID.
    /// </summary>
    /// <returns></returns>
    static public string GenerateJabberToken(string userName, string nameSpace)
    {
      string token;
      Auth auth = new Auth();
      auth.Initialize(userName, nameSpace);
      token = auth.CreateTicket();

      QueryStringEncrypt queryStringEncrypt = new QueryStringEncrypt();
      token = queryStringEncrypt.EncryptString(token);
      return token;
    }

    /// <summary>
    /// Takes in a metranet user name and namespace and returns a lowercase jabber id in the format:
    /// username-namespace-tenant@server
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="nameSpace"></param> 
    /// <returns></returns>
    static public string NormalizeJabberId(string userName, string nameSpace)
    {
      if (userName == null) throw new ArgumentNullException("userName");
      if (nameSpace == null) throw new ArgumentNullException("nameSpace");

      string jabberId = string.Format("{0}-{1}-{2}@{3}", userName, nameSpace, GetJabberSourceName(), GetJabberServerName());
      return jabberId.ToLower();
    }
    #endregion

    #region Private Methods
    /// <summary>
    /// Logs the user into the jabber server and sets up event handling.
    /// </summary>
    /// <param name="userName"></param>
    /// <param name="nameSpace"></param>
    private void Login(string userName, string nameSpace)
    {
      try
      {
        _jabberId = NormalizeJabberId(userName, nameSpace);
        string jabberPassword = GenerateJabberToken(userName, nameSpace);

        Jid jidSender = new Jid(_jabberId);
        _xmpp = new XmppClientConnection(jidSender.Server);
        _xmpp.OnLogin += XmppOnLogin;
        _xmpp.OnPresence += XmppOnPresence;
        _xmpp.OnMessage += XmppOnMessage;
        _xmpp.Resource = "MetraNet_" + Guid.NewGuid();
        _xmpp.Open(jidSender.User, jabberPassword);
      }
      catch (Exception e)
      {
        throw new EventsException(String.Format(EventsResource.ERROR_UNABLE_TO_LOGIN, _jabberId), e);
      }
    }
    #endregion

    #region Public Methods
    /// <summary>
    /// Sends an event message to the MetraNet user specified, and takes in a message derrived from EventMessageBase.
    /// </summary>
    /// <param name="nameSpace"></param>
    /// <param name="msg"></param>
    /// <param name="userName"></param>
    public void Send(string userName, string nameSpace, EventMessageBase msg)
    {
      if (_isLoggedIn)
      {
        _jabberId = NormalizeJabberId(userName, nameSpace);
        _logger.LogInfo("Sending XMPP msg to: {0}, : {1}", _jabberId, msg.ToJson());
        _xmpp.Send(new Message(new Jid(_jabberId), MessageType.chat, msg.ToJson()));
      }
    }

    /// <summary>
    /// Sends presence status
    /// </summary>
    /// <param name="pres"></param>
    public void SetPresence(ShowType pres)
    {
      _logger.LogInfo("Sentting presence for {0} to {1}", _jabberId, pres);
      
      Presence p = new Presence(pres, "Online");
      p.Type = PresenceType.available;
      _xmpp.Send(p);
    }
    #endregion

    #region Event Handlers
    /// <summary>
    /// Is called, if the precence of a roster contact changed 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="pres"></param>
    private void XmppOnPresence(object sender, Presence pres)
    {
      // TODO:  we can expose presence like GetEvents
      _logger.LogInfo("XMPP Presence: ");
      _logger.LogInfo("{0}@{1}  {2}", pres.From.User, pres.From.Server, pres.Type);
    }

    /// <summary>
    /// Is raised when login and authentication is finished 
    /// </summary>
    /// <param name="sender"></param>
    private void XmppOnLogin(object sender)
    {
      _isLoggedIn = true;
      _logger.LogInfo("Logged in to jabber server: {0}", _jabberId);

      SetPresence(ShowType.chat);
    }

    /// <summary>
    /// This event is fired each time a message is received and passed on to the client
    /// of EventManager if they have registered a delegate.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="msg"></param>
    private void XmppOnMessage(object sender, Message msg)
    {
      if (msg.Body != null)
      {
        // if we have listeners fire NewEvents
        if (NewEvents != null)
        {
          _logger.LogInfo("Fire XMPP OnMessage from {0}, {1}", msg.From.User, msg.Body);
          EventMessageBase emb = EventMessageBase.FromJson(msg.Body);
          var args = new ReceiveEventEventArg
          {
            From = msg.From.User,
            Json = msg.Body,
            MessageId = emb.MessageId,
            EventObject = emb
          };
          NewEvents(this, args);
        }
      }
    }

    /// <summary>
    /// Waits 25 seconds max for login to finish
    /// </summary>
    private void WaitForLoginComplete()
    {
      int i = 0;
      while (!_isLoggedIn)
      {
        i++;
        Thread.Sleep(100);
        if(i > 250)
        {
          throw new EventsException(String.Format(EventsResource.ERROR_UNABLE_TO_LOGIN, _jabberId));
        }
      }   
    }
    #endregion

    #region Dispose
    /// <summary>
    /// Clean up the jabber connection
    /// </summary>
    public void Dispose()
    {
      if(_xmpp != null)
      {
        _xmpp.Close();
      }
      GC.SuppressFinalize(this);
    }

    ~EventManager()
    {
      Dispose();
    }
    #endregion

  }
}
