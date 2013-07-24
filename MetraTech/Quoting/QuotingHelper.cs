using System;
using System.Xml.Linq;
using Core.Quoting;
using MetraTech.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.Interop.QueryAdapter;

namespace MetraTech.Quoting
{
  public static class QuotingHelper
  {
    public static TEl GetElementValue<TEl>(this XElement configuration, string paramName, TEl defaultValue)
    {
      var value = configuration.Element(paramName) != null ? configuration.Element(paramName).Value : defaultValue.ToString();

      TEl returnValue;

      try
      {
        returnValue = (TEl)Convert.ChangeType(value, typeof(TEl));
      }
      catch (FormatException)
      {
        returnValue = defaultValue;
      }

      return returnValue;
    }

    public static QuoteLog ConvertToQuoteLog(this QuoteLogRecord record)
    {
      return new QuoteLog()
      {
        QuoteIdentifier = record.QuoteIdentifier,
        DateAdded = record.DateAdded,
        Message = record.Message
      };
    }

    public static bool GetInstanceRCStateAndSwitchItOff()
    {
      bool instantRCsEnabled = true;
      //Check and turn off InstantRCs
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var stmt = conn.CreateAdapterStatement(@"Queries\ProductCatalog", "__GET_INSTANTRC_VALUE__"))
        {
          using (IMTDataReader reader = stmt.ExecuteReader())
          {
            if (reader.Read())
            {
              instantRCsEnabled = reader.GetBoolean("InstantRCValue");
            }
            else
            {
              string errorMessage = "Unable to retrieve InstantRC setting";
              throw new ApplicationException(errorMessage);
            }
          }
        }

        if (instantRCsEnabled)
        {
          using (IMTStatement stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(false)))
          {
            stmt.ExecuteNonQuery();
          }
        }
      }
      return instantRCsEnabled;
    }

    public static void BackOnInstanceRC(bool instantRCsEnabled)
    {
      if (instantRCsEnabled)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (
            IMTStatement stmt = conn.CreateStatement(GetQueryToUpdateInstantRCConfigurationValue(instantRCsEnabled)))
          {
            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    public static string GetQueryToUpdateInstantRCConfigurationValue(bool value)
    {
      IMTQueryAdapter qa = new MTQueryAdapterClass();
      qa.Init(@"Queries\ProductCatalog");

      qa.SetQueryTag("__SET_INSTANTRC_VALUE__");
      qa.AddParam("%%INSTANT_RC_ENABLED%%", value.ToString().ToLower());

      return qa.GetQuery().Trim();
    }
  }
}
