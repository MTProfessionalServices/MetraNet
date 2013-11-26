/**************************************************************************
* Copyright 2007 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;

using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.Rowset;
using System.Reflection;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Validators;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.Core.Services
{

  public class BaseSubscriptionService : AccountLoaderService
  {
    public BaseSubscriptionService(){}
    public BaseSubscriptionService(MTAuth.IMTSessionContext sessionContext) : base(sessionContext) { }

    private Logger m_Logger = new Logger("[BaseSubscriptionService]");

    #region Static Methods
    public static MTPCTimeSpan CastTimeSpan(ProdCatTimeSpan prodCatTimeSpan)
    {
      MTPCTimeSpan retval = new MTPCTimeSpanClass();

      if (prodCatTimeSpan.TimeSpanId != null)
      {
        retval.ID = (int)prodCatTimeSpan.TimeSpanId;
      }

      if (prodCatTimeSpan.StartDate != null)
      {
        retval.StartDate = (DateTime)prodCatTimeSpan.StartDate;
      }

      if (prodCatTimeSpan.IsStartDateTypeDirty)
      {
        retval.StartDateType = (MetraTech.Interop.MTProductCatalog.MTPCDateType)prodCatTimeSpan.StartDateType;
      }

      if (prodCatTimeSpan.StartDateOffset != null)
      {
        retval.StartOffset = (int)prodCatTimeSpan.StartDateOffset;
      }

      if (prodCatTimeSpan.EndDate != null)
      {
        retval.EndDate = (DateTime)prodCatTimeSpan.EndDate;
      }

      if (prodCatTimeSpan.IsEndDateTypeDirty)
      {
        retval.EndDateType = (MetraTech.Interop.MTProductCatalog.MTPCDateType)prodCatTimeSpan.EndDateType;
      }

      if (prodCatTimeSpan.EndDateOffset != null)
      {
        retval.EndOffset = (int)prodCatTimeSpan.EndDateOffset;
      }

      return retval;
    }

    public static ProdCatTimeSpan CastTimeSpan(IMTPCTimeSpan timeSpan)
    {
      ProdCatTimeSpan retval = new ProdCatTimeSpan();

      retval.TimeSpanId = timeSpan.ID;

      if (timeSpan.StartDate >= MetraTime.Min && timeSpan.StartDate <= MetraTime.Max)
      {
        retval.StartDate = timeSpan.StartDate;
      }

      retval.StartDateType = (ProdCatTimeSpan.MTPCDateType)timeSpan.StartDateType;
      retval.StartDateOffset = timeSpan.StartOffset;

      if (timeSpan.EndDate >= MetraTime.Min && timeSpan.EndDate <= MetraTime.Max)
      {
        retval.EndDate = timeSpan.EndDate;
      }

      retval.EndDateType = (ProdCatTimeSpan.MTPCDateType)timeSpan.EndDateType;
      retval.EndDateOffset = timeSpan.EndOffset;

      return retval;
    }

    public static Cycle CastCycle(IMTPCCycle pcCycle)
    {
      Cycle cycle = new Cycle();

      switch (pcCycle.CycleTypeID)
      {
        case 1: // Monthly
          {
            cycle.CycleType = UsageCycleType.Monthly;
            cycle.DayOfMonth = pcCycle.EndDayOfMonth;
            break;
          }
        case 3: // Daily
          {
            cycle.CycleType = UsageCycleType.Daily;
            break;
          }
        case 4: // Weekly
          {
            cycle.CycleType = UsageCycleType.Weekly;
            switch(pcCycle.EndDayOfWeek)
            {
              case 1:
                cycle.DayOfWeek = DayOfTheWeek.Sunday;
                break;

              case 2:
                cycle.DayOfWeek = DayOfTheWeek.Monday;
                break;

              case 3:
                cycle.DayOfWeek = DayOfTheWeek.Tuesday;
                break;

              case 4:
                cycle.DayOfWeek = DayOfTheWeek.Wednesday;
                break;

              case 5:
                cycle.DayOfWeek = DayOfTheWeek.Thursday;
                break;

              case 6:
                cycle.DayOfWeek = DayOfTheWeek.Friday;
                break;

              case 7:
                cycle.DayOfWeek = DayOfTheWeek.Saturday;
                break;

            }
           // cycle.DayOfWeek = (<Nullable<DayOfTheWeek>)pcCycle.EndDayOfWeek.ToString();
            break;
          }
        case 5: // Bi-weekly
          {
            cycle.CycleType = UsageCycleType.Bi_weekly;
            cycle.StartDay = pcCycle.StartDay;
            cycle.StartMonth = ConvertStartMonthIntToEnumValue(pcCycle.StartMonth, cycle);
            cycle.StartYear = pcCycle.StartYear;
            break;
          }
        case 6: // Semi-monthly
          {
            cycle.CycleType = UsageCycleType.Semi_monthly;
            cycle.FirstDayOfMonth = pcCycle.EndDayOfMonth;
            cycle.SecondDayOfMonth = pcCycle.EndDayOfMonth2;
            break;
          }
        case 7: // Quarterly
          {
            cycle.CycleType = UsageCycleType.Quarterly;
            cycle.StartDay = pcCycle.StartDay;
            cycle.StartMonth = ConvertStartMonthIntToEnumValue(pcCycle.StartMonth, cycle);
            break;
          }
        case 8: // Annually
          {
            cycle.CycleType = UsageCycleType.Annually;
            cycle.StartDay = pcCycle.StartDay;
            cycle.StartMonth = ConvertStartMonthIntToEnumValue(pcCycle.StartMonth, cycle);
            break;
          }
        case 9: // Semi-Annually
          {
            cycle.CycleType = UsageCycleType.Semi_Annually;
            cycle.StartDay = pcCycle.StartDay;
            cycle.StartMonth = ConvertStartMonthIntToEnumValue(pcCycle.StartMonth, cycle);
            break;
          }
        default:
          {
            Logger logger = new Logger("[BaseSubscriptionService]");
            logger.LogError(String.Format("Invalid cycle type id '{0}'", pcCycle.CycleTypeID));
            throw new MASBasicException("Invalid cycle type id");
          }
      }

      return cycle;
    }

    public static MTPCCycle CastCycle(Cycle cycle)
    {
      MTPCCycle pcCycle = new MTPCCycle();

      switch (cycle.CycleType)
      {
        case UsageCycleType.Monthly: // Monthly
          {
            pcCycle.CycleTypeID = 1;
            pcCycle.EndDayOfMonth = cycle.DayOfMonth.Value;
            break;
          }
        case UsageCycleType.Daily: // Daily
          {
            pcCycle.CycleTypeID = 3;
            break;
          }
        case UsageCycleType.Weekly: // Weekly
          {
            pcCycle.CycleTypeID = 4;
            switch(cycle.DayOfWeek.Value)
            {
              case DayOfTheWeek.Sunday:
                pcCycle.EndDayOfWeek = 1;
                break;

              case DayOfTheWeek.Monday:
                pcCycle.EndDayOfWeek = 2;
                break;

              case DayOfTheWeek.Tuesday:
                pcCycle.EndDayOfWeek = 3;
                break;

              case DayOfTheWeek.Wednesday:
                pcCycle.EndDayOfWeek = 4;
                break;

              case DayOfTheWeek.Thursday:
                pcCycle.EndDayOfWeek = 5;
                break;

              case DayOfTheWeek.Friday:
                pcCycle.EndDayOfWeek = 6;
                break;

              case DayOfTheWeek.Saturday:
                pcCycle.EndDayOfWeek = 7;
                break;

            }
            break;
          }
        case UsageCycleType.Bi_weekly: // Bi-weekly
          {
            pcCycle.CycleTypeID = 5;
            pcCycle.StartDay = cycle.StartDay.Value;
            pcCycle.StartMonth = ConvertStartMonthEnumValueToInt(cycle.StartMonth.Value, pcCycle);
            pcCycle.StartYear = cycle.StartYear.Value;
            break;
          }
        case UsageCycleType.Semi_monthly: // Semi-monthly
          {
            pcCycle.CycleTypeID = 6;
            pcCycle.EndDayOfMonth = cycle.FirstDayOfMonth.Value;
            pcCycle.EndDayOfMonth2 = cycle.SecondDayOfMonth.Value;
            break;
          }
        case UsageCycleType.Quarterly: // Quarterly
          {
            pcCycle.CycleTypeID = 7;
            pcCycle.StartDay = cycle.StartDay.Value;
            pcCycle.StartMonth = ConvertStartMonthEnumValueToInt(cycle.StartMonth.Value, pcCycle);
            break;
          }
        case UsageCycleType.Annually: // Annually
          {
            pcCycle.CycleTypeID = 8;
            pcCycle.StartDay = cycle.StartDay.Value;
            pcCycle.StartMonth = ConvertStartMonthEnumValueToInt(cycle.StartMonth.Value, pcCycle);
            break;
          }
        case UsageCycleType.Semi_Annually: // SemiAnnually
          {
            pcCycle.CycleTypeID = 9;
            pcCycle.StartDay = cycle.StartDay.Value;
            pcCycle.StartMonth = ConvertStartMonthEnumValueToInt(cycle.StartMonth.Value, pcCycle);
            break;
          }
        default:
          {
            Logger logger = new Logger("[BaseSubscriptionService]");
            logger.LogError("Invalid cycle type");
            throw new MASBasicException("Invalid cycle type id");
          }
      }

      return pcCycle;
    }
    #endregion

    public static int ConvertStartMonthEnumValueToInt(Nullable<MonthOfTheYear> startMonth, MTPCCycle pcCycle)
    {
      switch (startMonth)
      {
        case MonthOfTheYear.January:
          pcCycle.StartMonth = 1;
          break;

        case MonthOfTheYear.February:
          pcCycle.StartMonth = 2;
          break;

        case MonthOfTheYear.March:
          pcCycle.StartMonth = 3;
          break;

        case MonthOfTheYear.April:
          pcCycle.StartMonth = 4;
          break;

        case MonthOfTheYear.May:
          pcCycle.StartMonth = 5;
          break;

        case MonthOfTheYear.June:
          pcCycle.StartMonth = 6;
          break;

        case MonthOfTheYear.July:
          pcCycle.StartMonth = 7;
          break;

        case MonthOfTheYear.August:
          pcCycle.StartMonth = 8;
          break;

        case MonthOfTheYear.September:
          pcCycle.StartMonth = 9;
          break;

        case MonthOfTheYear.October:
          pcCycle.StartMonth = 10;
          break;

        case MonthOfTheYear.November:
          pcCycle.StartMonth = 11;
          break;

        case MonthOfTheYear.December:
          pcCycle.StartMonth = 12;
          break;
      }
      return pcCycle.StartMonth;
    }


    public static Nullable<MonthOfTheYear> ConvertStartMonthIntToEnumValue(int startMonth, Cycle cycle)
    {
      switch (startMonth)
      {
        case 1: 
          cycle.StartMonth =  MonthOfTheYear.January;
          break;

        case 2:
          cycle.StartMonth = MonthOfTheYear.February;
          break;

        case 3:
          cycle.StartMonth = MonthOfTheYear.March;
          break;

        case 4:
          cycle.StartMonth = MonthOfTheYear.April;
          break;

        case 5:
          cycle.StartMonth = MonthOfTheYear.May;
          break;

        case 6:
          cycle.StartMonth = MonthOfTheYear.June;
          break;

        case 7:
          cycle.StartMonth = MonthOfTheYear.July;
          break;

        case 8:
          cycle.StartMonth = MonthOfTheYear.August;
          break;

        case 9:
          cycle.StartMonth = MonthOfTheYear.September;
          break;

        case 10:
          cycle.StartMonth = MonthOfTheYear.October;
          break;

        case 11:
          cycle.StartMonth = MonthOfTheYear.November;
          break;

        case 12:
          cycle.StartMonth = MonthOfTheYear.December;
          break;
      }
      return cycle.StartMonth;
    }

    #region Protected Members
   

    protected ProductOffering GetProductOffering(int productOfferingId)
    {
      MTAuth.IMTSessionContext sessionContext = GetSessionContext();

      IMTProductCatalog prodCat = new MTProductCatalogClass();
      prodCat.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)sessionContext);

      IMTProductOffering mtProductOffering = prodCat.GetProductOffering(productOfferingId);
      ProductOffering productOffering = null;

      if (mtProductOffering != null)
      {
        productOffering = new ProductOffering();
        productOffering.ProductOfferingId = productOfferingId;
        productOffering.Name = mtProductOffering.Name;
        productOffering.DisplayName = mtProductOffering.DisplayName;
        productOffering.Description = mtProductOffering.Description;
        productOffering.EffectiveTimeSpan = CastTimeSpan(mtProductOffering.EffectiveDate);
        productOffering.AvailableTimeSpan = CastTimeSpan(mtProductOffering.AvailabilityDate);
        productOffering.GroupSubscriptionRequiresCycle = mtProductOffering.GroupSubscriptionRequiresCycle();
        
        MTUsageCycleType usageCycleType = mtProductOffering.GetConstrainedCycleType();

        switch (usageCycleType)
        {
          case MTUsageCycleType.NO_CYCLE:
            productOffering.UsageCycleType = 0;
            break;

          case MTUsageCycleType.MONTHLY_CYCLE:
            productOffering.UsageCycleType = 1;
            break;

          case MTUsageCycleType.DAILY_CYCLE:
            productOffering.UsageCycleType = 3;
            break;

          case MTUsageCycleType.WEEKLY_CYCLE:
            productOffering.UsageCycleType = 4;
            break;

          case MTUsageCycleType.BIWEEKLY_CYCLE:
            productOffering.UsageCycleType = 5;
            break;

          case MTUsageCycleType.SEMIMONTHLY_CYCLE:
            productOffering.UsageCycleType = 6;
            break;

          case MTUsageCycleType.QUARTERLY_CYCLE:
            productOffering.UsageCycleType = 7;
            break;

          case MTUsageCycleType.ANNUALLY_CYCLE:
            productOffering.UsageCycleType = 8;
            break;

          case MTUsageCycleType.SEMIANNUALLY_CYCLE:
            productOffering.UsageCycleType = 9;
            break;
        }
      }

      return productOffering;
    }

    protected void AdjustTimeValues(ref Subscription sub)
    {
        if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_Subscription_TruncateTimeValues))
        {
            if (sub.SubscriptionSpan != null)
            {
                if (sub.SubscriptionSpan.StartDate != null)
                {
                    DateTime start = sub.SubscriptionSpan.StartDate.Value;
                    sub.SubscriptionSpan.StartDate = new DateTime(start.Year, start.Month, start.Day, 0, 0, 0);
                }

                if (sub.SubscriptionSpan.EndDate != null)
                {
                    DateTime end = sub.SubscriptionSpan.EndDate.Value;
                    sub.SubscriptionSpan.EndDate = new DateTime(end.Year, end.Month, end.Day).AddDays(1).AddSeconds(-1);
                }
            }
        }

      if (sub.UDRCValues != null)
      {
        foreach (List<UDRCInstanceValue> vals in sub.UDRCValues.Values)
        {
          foreach (UDRCInstanceValue val in vals)
          {
            if (val.StartDate == null || val.StartDate == DateTime.MinValue)
            {
              val.StartDate = MetraTime.Min;
            }

            if (val.EndDate == null || val.EndDate == DateTime.MaxValue)
            {
              val.EndDate = MetraTime.Max;
            }
          }
        }
      }
    }

    protected void ValidateSubscription(Subscription sub, out List<UDRCInstance> udrcInstances)
    {
      SubscriptionValidator validator = new SubscriptionValidator();
      List<string> validationErrors = null;
      if (!validator.Validate(sub, out validationErrors))
      {
        MASBasicException err = new MASBasicException("Error validating subscription");

        foreach (string validationError in validationErrors)
        {
          err.AddErrorMessage(validationError);
        }

        throw err;
      }

      udrcInstances = null;

      GetUDRCInstancesForPOInternal(sub.ProductOfferingId, out udrcInstances);

      if (udrcInstances != null && udrcInstances.Count > 0)
      {
        if (sub.IsUDRCValuesDirty && sub.UDRCValues != null)
        {
          foreach (UDRCInstance inst in udrcInstances)
          {
            if (!sub.UDRCValues.ContainsKey(inst.ID.ToString()) ||
                  sub.UDRCValues[inst.ID.ToString()] == null ||
                  sub.UDRCValues[inst.ID.ToString()].Count == 0)
            {
              throw new MASBasicException(string.Format("No values have been specified for the UDRC {0}", inst.DisplayName));
            }
          }
        }
        else
        {
          throw new MASBasicException("UDRC instance values were not specified and specified product offering has UDRCs");
        }
      }
    }

    protected void GetUDRCInstancesForPOInternal(int productOfferingId, out List<UDRCInstance> udrcInstances)
    {
      udrcInstances = new List<UDRCInstance>();

      try
      {
        IMTProductCatalog prodCatalog = new MTProductCatalogClass();
        IMTProductOffering po = prodCatalog.GetProductOffering(productOfferingId);
        IMTCollection instances = po.GetPriceableItems();

        UDRCInstance udrcInstance;
        foreach (IMTPriceableItem possibleRC in instances)
        {
          if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
          {
            IMTRecurringCharge rc = (IMTRecurringCharge)possibleRC;
            udrcInstance = new UDRCInstance();
            udrcInstance.ID = rc.ID;
            udrcInstance.DisplayName = rc.DisplayName;
            udrcInstance.Name = rc.Name;
            udrcInstance.UnitName = rc.UnitName;
            udrcInstance.UnitDisplayName = rc.UnitDisplayName;
            udrcInstance.MaxValue = decimal.Parse(rc.MaxUnitValue.ToString());
            udrcInstance.MinValue = decimal.Parse(rc.MinUnitValue.ToString());
            udrcInstance.IsIntegerValue = rc.IntegerUnitValue;
            udrcInstance.ChargePerParticipant = rc.ChargePerParticipant;

            if (rc.UnitValueEnumeration.Count > 0)
            {
              udrcInstance.UnitValueEnumeration = new List<decimal>();

              foreach (decimal val in rc.UnitValueEnumeration)
              {
                udrcInstance.UnitValueEnumeration.Add(val);
              }
            }

            udrcInstances.Add(udrcInstance);
          }
        }
      }
      catch (COMException comE)
      {
        m_Logger.LogException("COM Exception in GetUDRCInstancesForPO", comE);

        throw new MASBasicException(comE.Message);
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception in GetUDRCInstancesForPO", e);

        throw new MASBasicException("Error getting UDRC instances for product offering");
      }
    }

    protected void GetUDRCValues(MetraTech.Interop.MTProductCatalog.IMTRowSet rs,
                                 out Dictionary<string, List<UDRCInstanceValue>> udrcValues)
    {
      udrcValues = new Dictionary<string, List<UDRCInstanceValue>>();

      List<UDRCInstanceValue> instValues;
      UDRCInstanceValue val;

      if (rs.RecordCount > 0)
      {
        rs.MoveFirst();
        while (!Convert.ToBoolean(rs.EOF))
        {
          val = new UDRCInstanceValue();

          val.UDRC_Id = (int)rs.get_Value("id_prop");
          val.Value = (decimal)rs.get_Value("n_value");
          val.StartDate = (DateTime)rs.get_Value("vt_start");
          val.EndDate = (DateTime)rs.get_Value("vt_end");

          if (udrcValues.ContainsKey(val.UDRC_Id.ToString()))
          {
            udrcValues[val.UDRC_Id.ToString()].Add(val);
          }
          else
          {
            instValues = new List<UDRCInstanceValue>();
            instValues.Add(val);

            udrcValues.Add(val.UDRC_Id.ToString(), instValues);
          }

          rs.MoveNext();
        }
      }
    }


    #endregion

    
  }
}
