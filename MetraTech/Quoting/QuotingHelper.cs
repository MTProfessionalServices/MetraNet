using System;
using System.Xml.Linq;
using Core.Quoting;
using MetraTech.DomainModel.BaseTypes;

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
  }
}
