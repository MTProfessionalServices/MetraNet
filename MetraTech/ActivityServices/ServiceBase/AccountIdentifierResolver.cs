#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;

namespace MetraTech.ActivityServices.Services.Common
{
  public class AccountIdentifierResolver
  {
    private static Logger m_Logger;

    static AccountIdentifierResolver()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[AccountIdentifierResolver]");
    }

    public static int ResolveAccountIdentifier(AccountIdentifier acct)
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

                  stmt.AddParam("login", MTParameterType.WideString, acct.Username);
                  stmt.AddParam("namespace", MTParameterType.WideString, acct.Namespace);

                  stmt.ExecuteNonQuery();

                  int retval = (int)stmt.ReturnValue;

                  return retval;
              }
          }
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception resolving account by username/namespace", e);

          throw new MASBasicException("Unable to locate account specified");
        }
      }
    }
  }
}
