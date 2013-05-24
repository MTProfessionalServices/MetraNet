using System;
using System.Configuration;
using System.IO;
using MetraTech.Core.Services.ClientProxies;

namespace ExternalAuthenticationCSharpScript
{
	class Program
	{
	  private static bool _isDebug;

		static void Main(string[] args)
		{
      if (ConfigurationManager.AppSettings.Get("debug") == "true")
      {
        _isDebug = true;
      }

      Log(String.Format("Using external auth for ejabberd... {0}", DateTime.Now));

      while (true)
      {
        string opcode = "";		       		      // operation code, isuser, auth, or setpass
        string username = "";
        string host = "";
        string password = "";

        // Read data from stdin
        char[] charray = new char[2];
        int read = Console.In.Read(charray, 0, 2);	// number of bytes read
        if (read != 2)
        {
          continue;
        }

        // Perform big endian conversion
        int len = charray[1] + (charray[0] * 256);
        Log(String.Format("Reading... {0}", len));

        // Read opcode, username and password
        charray = new char[len];
        Console.In.ReadBlock(charray, 0, len);

        // Splits the data
        string data = new string(charray);
        string[] elements = data.Split(':');

        if (elements.Length > 2)
        {
          opcode = elements[0];
          username = elements[1];
          host =elements[2];
        }

        if (opcode != "isuser")
        {
          if (elements.Length > 3)
          {
            password = elements[3];
          }
        }
        else
        {
          Log("is user check...");
          // here we are just returning true
          WriteResponse(true);
          continue;
        }

        //
        // PERFORM AUTHENTICATION HERE
        //
        bool isValid = CheckMetraNetAuth(username, password, host, opcode);
        WriteResponse(isValid);
      }
    }

    /// <summary>
    /// Write true or false to the console, in the ejabberd format.
    /// </summary>
    /// <param name="isValid"></param>
	  private static void WriteResponse(bool isValid)
	  {
	    char[] charray = new char[4];

	    // Prepare return value, first short is always 2
	    charray[0] = (char)0;
	    charray[1] = (char)2;

	    // Second short is 1 for success, 0 for failure
	    charray[2] = (char)0;
	    if (isValid)
	    {
	      charray[3] = (char)1; // 1 for success
	    }
	    else
	    {
	      charray[3] = (char)0; // 0 for failure
	    }

      // Send return value
      Log(String.Format("result:  {0}", isValid));
      Console.Out.Write(charray, 0, 4);
	  }

	  /// <summary>
    /// Log messages by just appending to file
    /// </summary>
    /// <param name="msg"></param>
    private static void Log(string msg)
    {
      if(!_isDebug) return;

      string tmp = Environment.GetEnvironmentVariable("temp") ?? "c:\\";
      using (StreamWriter file = new StreamWriter(File.Open(Path.Combine(tmp, "jabberd_auth_log.txt"),
                                                  FileMode.Append, FileAccess.Write, FileShare.ReadWrite)))
      {
        file.WriteLine(String.Format("{0} {1}", DateTime.Now, msg));
      }
    }

    /// <summary>
    /// Check auth against MetraNet system.
    /// </summary>
    /// <param name="username"></param>
    /// <param name="password"></param>
    /// <param name="host"></param>
    /// <param name="operation"></param>
    /// <returns></returns>
    static private bool CheckMetraNetAuth(string username, string password, string host, string operation)
    {
      bool isValid = false;

      // log info
      Log(String.Format("Checking MetraNet Auth:  {0}, {1}, {2}, {3}", operation, host, username, password));

      // admin console login
      if (username.ToLower() == ConfigurationManager.AppSettings.Get("JabberAdmin") &&
        password == ConfigurationManager.AppSettings.Get("JabberPassword"))
      {
        return true;
      }
 
      // jid in the format:  user-namespace-tenant
      string[] vals = username.Split(new[] { '-' });
      if (vals.Length != 3)
      {
        return false;
      }

      string user = vals[0];
      string nameSpace = vals[1];
      string tenant = vals[2];
      string jabberServer = ConfigurationManager.AppSettings.Get("JabberServer");
      tenant = tenant.Replace("@" + jabberServer, "");   // cleanup @servername for some clients

      switch (operation)
      {
        case "auth":
          // TODO:  need to find a good place to store the password on the jabber server, or maybe we can use a cert.
          var validateTicketClient = new TicketingService_ValidatetTicket_Client(tenant)
                                       {
                                         UserName = "su",
                                         Password = "su123",
                                         In_userName = user,
                                         In_nameSpace = nameSpace,
                                         In_ticket = password
                                       };

          validateTicketClient.Invoke();
          isValid = validateTicketClient.Out_isValid;
          break;
        
        case "setpass":
          // no need to support this
          break;

        case "isuser":
          // No password in this case, just check username.  If we can get a ticket, that's good.
          try
          {
            // TODO:  need to find a good place to store the password on the jabber server, or maybe we can use a cert.
            var getTicketClient = new TicketingService_GetTicket_Client(tenant)
                                    {
                                      UserName = "su",
                                      Password = "su123",
                                      In_userName = user,
                                      In_nameSpace = nameSpace
                                    };
            getTicketClient.Invoke();
            string ticket = getTicketClient.Out_ticket;
            if(ticket != null)
            {
              isValid = true;
            }
          }
          catch (Exception)
          {
            isValid = false;
          }
          break;

        default:
          break;
      }

      return isValid;
    }

	}
}