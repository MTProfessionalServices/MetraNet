using System;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;

namespace MetraTech.Domain.DataAccess
{
  /// <summary>
  /// Represents utilities for work with a database
  /// </summary>
  public static class DatabaseUtils
  {
    /// <summary>
    /// Returns the value of the object in the correct format for the database.
    /// </summary>
    /// <param name="value">input object</param>
    /// <returns>string with correct format for database</returns>
    public static string FormatValueForDB(object value)
    {
      string retval = null;

      if (value == null)
      {
        retval = "NULL";
      }
      else if (value is DateTime)
      {
        retval = DBUtil.ToDBString(((DateTime)value));
      }
      else if (value is string || value is String)
      {
        retval = String.Format("'{0}'", DBUtil.ToDBString(((string)value)));
      }
      else if (value.GetType().IsEnum)
      {
        if (value is RateEntryOperators)
        {
          switch ((RateEntryOperators)value)
          {
            case RateEntryOperators.Equal:
              retval = "'='";
              break;
            case RateEntryOperators.Greater:
              retval = "'>'";
              break;
            case RateEntryOperators.GreaterEqual:
              retval = "'>='";
              break;
            case RateEntryOperators.Less:
              retval = "'<'";
              break;
            case RateEntryOperators.LessEqual:
              retval = "'<='";
              break;
            case RateEntryOperators.NotEqual:
              retval = "'!='";
              break;
          }
        }
        else
        {
          retval = String.Format("{0}", EnumHelper.GetDbValueByEnum(value));
        }
      }
      else if (value is bool)
      {
        retval = ((bool)value ? "1" : "0");
      }
      else
      {
        retval = String.Format("{0}", value);
      }

      return retval;
    }
  }
}
