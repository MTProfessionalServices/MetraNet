using System;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;

namespace MetraTech.Application
{
  /// <summary>
  /// Represents utilities for work with effective date class
  /// </summary>
  public static class EffectiveDateUtils
  {
    const int TimespanKind = 160;

    public static ProdCatTimeSpan.MTPCDateType GetEndDateType(int endDate)
    {
      switch (endDate)
      {
          /*      NoDate = 0, Absolute = 1, SubscriptionRelative = 2, NextBillingPeriod = 3,Null = 4,  */
        case 0:
          return ProdCatTimeSpan.MTPCDateType.NoDate;              
        case 1:
          return ProdCatTimeSpan.MTPCDateType.Absolute;              
        case 2:
          return ProdCatTimeSpan.MTPCDateType.SubscriptionRelative;
        case 3:
          return ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
        case 4:
          return ProdCatTimeSpan.MTPCDateType.Null;
        default:
          throw new MASBasicException("Unrecognized Date type");
      }
    }

    public static ProdCatTimeSpan GetEffectiveDate(IMTDataReader dataReader, string prefix)
    {
      var effectiveDate = new ProdCatTimeSpan
        {
          TimeSpanId = dataReader.GetInt32(prefix + "_Id"),
          StartDateType = GetEndDateType(dataReader.GetInt32(prefix + "_BeginType"))
        };
      if (effectiveDate.StartDateType == ProdCatTimeSpan.MTPCDateType.NoDate)
        effectiveDate.StartDate = null;
      else
      {
        if (!dataReader.IsDBNull(prefix + "_StartDate"))
          effectiveDate.StartDate = dataReader.GetDateTime(prefix + "_StartDate");
        else
          effectiveDate.StartDate = null;
      }

      effectiveDate.StartDateOffset = dataReader.GetInt32(prefix + "_BeginOffset");
      effectiveDate.EndDateType = GetEndDateType(dataReader.GetInt32(prefix + "_EndType"));

      // handle nulls
      if (effectiveDate.EndDateType == ProdCatTimeSpan.MTPCDateType.Null)
        effectiveDate.EndDate = null;
      else
      {
        if (!dataReader.IsDBNull(prefix + "_EndDate"))
          effectiveDate.EndDate = dataReader.GetDateTime(prefix + "_EndDate");
        else
          effectiveDate.EndDate = null;
      }

      effectiveDate.EndDateOffset = dataReader.GetInt32(prefix + "_EndOffSet");

      return effectiveDate;
    }

    public static void ValidateAndSetEffectiveDate(IMTAdapterStatement updateDtStmt, ProdCatTimeSpan effectiveDate)
    {
      // I've tried to rationalize the behavior here with what the UI does when you don't set a value.
      //  In those cases, it sets the the date type to Null, which is then interpreted to mean no start
      //  date or no end date.  Logically, you might expect that to be expressed with the type NoDate,
      //  but NoDate breaks all the places expecting it to be Null, and the UI gets messed up.
      //
      //  So I'm using NoDate to mean null was passed in, although this should never happen anyway.
      if (effectiveDate == null)
      {
        updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
        updateDtStmt.AddParam("%%START_DATE%%", null);
        updateDtStmt.AddParam("%%END_DATE%%", null);
        updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
        updateDtStmt.AddParam("%%BEGIN_OFFSET%%", 0);
        updateDtStmt.AddParam("%%END_OFFSET%%", 0);
        return;
      }
      if (effectiveDate.StartDate.HasValue)
      {
        if (effectiveDate.StartDate.Value > MetraTime.Max)
        {
          effectiveDate.StartDate = MetraTime.Max;
        }
        if (effectiveDate.StartDate.Value < MetraTime.Min)
        {
          effectiveDate.StartDate = MetraTime.Min;
        }
        updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.Absolute);
        updateDtStmt.AddParam("%%START_DATE%%", effectiveDate.StartDate.Value);
      }
      else
      {
        updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
        updateDtStmt.AddParam("%%START_DATE%%", null);
      }

      if (effectiveDate.StartDateOffset.HasValue)
        updateDtStmt.AddParam("%%BEGIN_OFFSET%%", effectiveDate.StartDateOffset.Value);
      else
        updateDtStmt.AddParam("%%BEGIN_OFFSET%%", 0);

      if (effectiveDate.EndDate.HasValue)
      {
        if (effectiveDate.EndDate.Value > MetraTime.Max)
        {
          effectiveDate.EndDate = MetraTime.Max;
        }
        else if (effectiveDate.EndDate.Value < MetraTime.Min)
        {
          effectiveDate.EndDate = MetraTime.Min;
        }
        else if (effectiveDate.StartDate.HasValue)
        {
          if (effectiveDate.EndDate.Value < effectiveDate.StartDate.Value)
          {
            throw new MASBasicException("Incorrect Start / End date values. Start date appears to be after the end date.");
          }
        }

        updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.Absolute);
        updateDtStmt.AddParam("%%END_DATE%%", effectiveDate.EndDate.Value);
      }
      else
      {
        updateDtStmt.AddParam("%%END_DATE%%", null);
        updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.Null);
      }

      if (effectiveDate.EndDateOffset.HasValue)
        updateDtStmt.AddParam("%%END_OFFSET%%", effectiveDate.EndDateOffset.Value);
      else
        updateDtStmt.AddParam("%%END_OFFSET%%", 0);
    }

    public static void UpdateEffectiveDate(ProdCatTimeSpan effectiveDate, string condition)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement updateDtStmt = conn.CreateAdapterStatement("queries\\PCWS", "__UPDATE_EFF_DATE_PCWS__"))
        {
          updateDtStmt.AddParam("%%ID_EFF_DATE%%", condition);

          ValidateAndSetEffectiveDate(updateDtStmt, effectiveDate);

          updateDtStmt.ExecuteNonQuery();
        }
      }
    }

    public static void UpdateEffectiveDate(ProdCatTimeSpan effectiveDate)
    {
      UpdateEffectiveDate(effectiveDate, String.Format("{0}", effectiveDate.TimeSpanId.GetValueOrDefault()));
    }

    public static int CreateEffectiveDate(IMTSessionContext context, ProdCatTimeSpan effectiveDate)
    {
      var effDateId = BasePropsUtils.CreateBaseProps(context, "", "", "", TimespanKind);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (var updateDtStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_EFF_DATE__"))
        {
          updateDtStmt.AddParam("%%ID_EFF_DATE%%", effDateId);

          ValidateAndSetEffectiveDate(updateDtStmt, effectiveDate);

          updateDtStmt.ExecuteNonQuery();
        }
      }

      return effDateId;
    }
  }
}
