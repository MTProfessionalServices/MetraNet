using System;
using System.Collections.Generic;
using System.Linq;
using MetraNet.DbContext;
using System.Xml.Linq;
using System.Globalization;


namespace MetraNet.Charts
{

  public static class ReportsChartService
  {
    
    public static XElement NewCustomersByMonth(DataMart dbContext, string territoryCode)
    {
      var accountsByMonth = (from c in dbContext.Customer
                             join st in dbContext.SubscriptionTable on c.AccountId equals st.AccountId
                             where st.StartDate.HasValue
                                && st.StartDate.Value >= DateTime.Today.AddMonths(-12)
                                && st.StartDate.Value <= DateTime.Now
                                && (String.IsNullOrEmpty(territoryCode) || c.Territorycode.Equals(territoryCode))
                             group c by new
                             {
                               st.StartDate.Value.Year,
                               st.StartDate.Value.Month,
                             }
                               into group1
                               select new
                               {
                                 Count = group1.Distinct().Count(),
                                 Year = group1.Key.Year,
                                 Month = group1.Key.Month
                               }).OrderBy(x => x.Year).ThenBy(x => x.Month);


      var categories = new List<Category>();
      var dataSet = new DataSet
                          {
                            ShowSeriesInLegend = false,
                            SeriesName = string.Empty,
                            Values = new List<DataSetValue>()
                          };

      var dateFrom = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day).AddMonths(-11);
      // 12 categories that represents months 
      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(dateFrom.Month, dateFrom.Year)
        });

        var count =
          accountsByMonth.Where(
            x =>
            x.Month == dateFrom.Month &&
            x.Year == dateFrom.Year
            ).Select(x => x.Count).SingleOrDefault().ToString(CultureInfo.InvariantCulture);

        ((List<DataSetValue>)dataSet.Values).Add(new DataSetValue
        {
          Value = count,
          DisplayValue = count,
          ToolText = count,
          Color = NodeAndAttributeName.Colors.ElementAt(i)
        });

        dateFrom = dateFrom.AddMonths(1);
      }


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "New Customers By Month" + (territoryCode == null ? string.Empty : " by " + territoryCode),
        Categories = categories,
        DataSets = new List<DataSet>
                      {
                        dataSet
                      },
        XAxisName = "Months",
        YAxisName = "Customers",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    public static XElement MRRByMonth(DataMart dbContext, string productCode, string territoryCode, bool MRRBase, bool MRRNew, bool MRRRenewal, bool MRRPriceChange, bool MRRChurn, bool MRRCancellation)
    {
      var MRRByMonth = (from subByMonth in dbContext.SubscriptionsByMonth
                        join sub in dbContext.SubscriptionTable on subByMonth.SubscriptionId equals sub.SubscriptionId
                        join c in dbContext.Customer on sub.AccountId equals c.AccountId
                        where
                          subByMonth.Month.HasValue &&
                          subByMonth.Month >= DateTime.Today.AddMonths(-13) &&
                          subByMonth.Month < new DateTime(DateTime.Now.AddMonths(12).Year, DateTime.Now.Month, 1) &&
                          (String.IsNullOrEmpty(productCode) || sub.ProductCode.Equals(productCode)) &&
                          (String.IsNullOrEmpty(territoryCode) || c.Territorycode.Equals(territoryCode))
                        group subByMonth by new
                        {
                          Year = subByMonth.Month.Value.Year,
                          Month = subByMonth.Month.Value.Month,
                          CurrencyCode = sub.FeeCurrency
                        } into grp
                        select new
                        {
                          grp.Key.Year,
                          grp.Key.Month,
                          grp.Key.CurrencyCode,
                          Amount = grp.Sum(x =>
                             (MRRBase ? x.MRRBase : 0m) +
                             (MRRNew ? x.MRRNew : 0m) +
                             (MRRRenewal ? x.MRRRenewal : 0m) +
                             (MRRPriceChange ? x.MRRPriceChange : 0m) +
                             (MRRChurn ? x.MRRChurn : 0m) +
                             (MRRCancellation ? x.MRRCancellation : 0m)
                            )
                        }).ToList();

      var currencies = MRRByMonth.Select(x => x.CurrencyCode).Distinct();

      var categories = new List<Category>();
      var categoriesInitialised = false;
      var dataSets = new List<DataSet>();

      // 12 categories that represents months 
      foreach (var currencyCode in currencies)
      {
        var currentDate = DateTime.Now.AddMonths(-12);

        var dataSetValues = new List<DataSetValue>();

        for (var i = 0; i < 24; i++)
        {
          if (!categoriesInitialised)
            categories.Add(new Category
            {
              Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
            });


          var amount =
            MRRByMonth.Where(
              x =>
              x.Month == currentDate.Month &&
              x.Year == currentDate.Year &&
              x.CurrencyCode == currencyCode
              ).Select(x => x.Amount).SingleOrDefault();
          amount = amount ?? 0;

          var dataSetValue = new DataSetValue
          {
            Value = amount.ToString(),
            DisplayValue = CurrencyFormatHelper.MoneyFormattingCurrentCulture(amount.Value, currencyCode, CultureInfo.CurrentCulture)
          };
          dataSetValue.ToolText = dataSetValue.DisplayValue;
          dataSetValues.Add(dataSetValue);

          currentDate = currentDate.AddMonths(1);
        }

        var dataSet = new DataSet
        {
          ShowSeriesInLegend = true,
          SeriesName = currencyCode + " (" + CurrencyFormatHelper.GetCurrencySymbolByMoneyCode(currencyCode) + ")",
          Values = dataSetValues
        };
        dataSets.Add(dataSet);

        categoriesInitialised = true;
      }


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Monthly Recurring Revenue" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "Recurring Revenue",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    /*public static XElement NewTCVByMonth(DataMart dbContext, string code)
    {
      var newTCV = (from subByMonth in dbContext.SubscriptionPrice
                    join sub in dbContext.SubscriptionTable on subByMonth.SubscriptionId equals sub.SubscriptionId
                    join c in dbContext.Customer on sub.AccountId equals c.AccountId
                    where
                          subByMonth.New.HasValue &&
                          subByMonth.New >= DateTime.Today.AddMonths(-13) &&
                          subByMonth.New < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1) &&
                          (code == null || code == string.Empty || c.Territorycode.Equals(code))
                    group subByMonth by new
                    {
                      Year = subByMonth.New.Value.Year,
                      Month = subByMonth.New.Value.Month,
                      CurrencyCode = sub.FeeCurrency
                    } into grp
                    select new
                    {
                      grp.Key.Year,
                      grp.Key.Month,
                      grp.Key.CurrencyCode,
                      Amount = grp.Sum(x => x.TotalContractValue)
                    }).ToList();

      var currencies = newTCV.Select(x => x.CurrencyCode).Distinct();

      var categories = new List<Category>();
      var categoriesInitialised = false;
      var dataSets = new List<DataSet>();

      // 12 categories that represents months 
      foreach (var currencyCode in currencies)
      {
        var currentDate = DateTime.Now.AddMonths(-12);

        var dataSetValues = new List<DataSetValue>();

        for (var i = 0; i < 12; i++)
        {
          if (!categoriesInitialised)
            categories.Add(new Category
            {
              Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
            });


          var amount =
            newTCV.Where(
              x =>
              x.Month == currentDate.Month &&
              x.Year == currentDate.Year &&
              x.CurrencyCode == currencyCode
              ).Select(x => x.Amount).SingleOrDefault();
          amount = amount ?? 0;

          var dataSetValue = new DataSetValue
          {
            Value = amount.ToString(),
            DisplayValue = CurrencyFormatHelper.MoneyFormattingCurrentCulture(amount.Value, currencyCode, CultureInfo.CurrentCulture)
          };
          dataSetValue.ToolText = dataSetValue.DisplayValue;
          dataSetValues.Add(dataSetValue);

          currentDate = currentDate.AddMonths(1);
        }

        var dataSet = new DataSet
        {
          ShowSeriesInLegend = true,
          SeriesName = currencyCode + " (" + CurrencyFormatHelper.GetCurrencySymbolByMoneyCode(currencyCode) + ")",
          Values = dataSetValues
        };
        dataSets.Add(dataSet);

        categoriesInitialised = true;
      }


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "New Total Contract Value" + (code == null ? string.Empty : " by " + code),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "Total Contract Value",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    public static XElement ChurnByMonth(DataMart dbContext, string productCode)
    {
      var newTCV = (from st in dbContext.SubscriptionTable
                    join sm in dbContext.SubscriptionsByMonth on st.SubscriptionId equals sm.SubscriptionId
                    join sp in dbContext.SubscriptionPrice on st.SubscriptionId equals sp.SubscriptionId
                    where
                      sp.Churned.HasValue &&
                      sp.Churned.Value >= DateTime.Today.AddMonths(-13) &&
                      sp.Churned.Value < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1) &&
                      (productCode == null || productCode == string.Empty || st.ProductCode == productCode)
                    group sm by new
                    {
                      Year = sp.Churned.Value.Year,
                      Month = sp.Churned.Value.Month,
                      CurrencyCode = st.FeeCurrency
                    } into grp
                    select new
                    {
                      grp.Key.Year,
                      grp.Key.Month,
                      grp.Key.CurrencyCode,
                      Amount = grp.Sum(x => -1 * x.MRRChurn)
                    }).ToList();

      var currencies = newTCV.Select(x => x.CurrencyCode).Distinct();

      var categories = new List<Category>();
      var categoriesInitialised = false;
      var dataSets = new List<DataSet>();

      // 12 categories that represents months 
      foreach (var currencyCode in currencies)
      {
        var currentDate = DateTime.Now.AddMonths(-12);

        var dataSetValues = new List<DataSetValue>();

        for (var i = 0; i < 12; i++)
        {
          if (!categoriesInitialised)
            categories.Add(new Category
            {
              Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
            });


          var amount =
            newTCV.Where(
              x =>
              x.Month == currentDate.Month &&
              x.Year == currentDate.Year &&
              x.CurrencyCode == currencyCode
              ).Select(x => x.Amount).SingleOrDefault();
          amount = amount ?? 0;

          var dataSetValue = new DataSetValue
          {
            Value = amount.ToString(),
            DisplayValue = CurrencyFormatHelper.MoneyFormattingCurrentCulture(amount.Value, currencyCode, CultureInfo.CurrentCulture)
          };
          dataSetValue.ToolText = dataSetValue.DisplayValue;
          dataSetValues.Add(dataSetValue);

          currentDate = currentDate.AddMonths(1);
        }

        var dataSet = new DataSet
        {
          ShowSeriesInLegend = true,
          SeriesName = currencyCode + " (" + CurrencyFormatHelper.GetCurrencySymbolByMoneyCode(currencyCode) + ")",
          Values = dataSetValues
        };
        dataSets.Add(dataSet);

        categoriesInitialised = true;
      }


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Churn" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "MRR",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    public static XElement ExpiringSubscriptionsByMonth(DataMart dbContext, string code)
    {
      var newTCV = (from subByMonth in dbContext.SubscriptionsByMonth
                    join sub in dbContext.SubscriptionTable on subByMonth.SubscriptionId equals sub.SubscriptionId
                    join c in dbContext.Customer on sub.AccountId equals c.AccountId
                    where sub.EndDate.HasValue &&
                          sub.EndDate.Value >= DateTime.Today.AddMonths(-13) &&
                          sub.EndDate.Value < new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1) &&
						              subByMonth.Month == new DateTime(sub.EndDate.Value.Year, sub.EndDate.Value.Month, 1) &&
                          (code == null || code == string.Empty || c.Territorycode.Equals(code))
                    group subByMonth by new
                    {
                      Year = sub.EndDate.Value.Year,
                      Month = sub.EndDate.Value.Month,
                      CurrencyCode = sub.FeeCurrency
                    } into grp
                    select new
                    {
                      grp.Key.Year,
                      grp.Key.Month,
                      grp.Key.CurrencyCode,
                      Amount = grp.Sum(x => x.MRR)
                    }).ToList();

      var currencies = newTCV.Select(x => x.CurrencyCode).Distinct();

      var categories = new List<Category>();
      var categoriesInitialised = false;
      var dataSets = new List<DataSet>();

      // 12 categories that represents months 
      foreach (var currencyCode in currencies)
      {
        var currentDate = DateTime.Now.AddMonths(-12);

        var dataSetValues = new List<DataSetValue>();

        for (var i = 0; i < 12; i++)
        {
          if (!categoriesInitialised)
            categories.Add(new Category
            {
              Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
            });


          var amount =
            newTCV.Where(
              x =>
              x.Month == currentDate.Month &&
              x.Year == currentDate.Year &&
              x.CurrencyCode == currencyCode
              ).Select(x => x.Amount).SingleOrDefault();
          amount = amount ?? 0;

          var dataSetValue = new DataSetValue
          {
            Value = amount.ToString(),
            DisplayValue = CurrencyFormatHelper.MoneyFormattingCurrentCulture(amount.Value, currencyCode, CultureInfo.CurrentCulture)
          };
          dataSetValue.ToolText = dataSetValue.DisplayValue;
          dataSetValues.Add(dataSetValue);

          currentDate = currentDate.AddMonths(1);
        }

        var dataSet = new DataSet
        {
          ShowSeriesInLegend = true,
          SeriesName = currencyCode + " (" + CurrencyFormatHelper.GetCurrencySymbolByMoneyCode(currencyCode) + ")",
          Values = dataSetValues
        };
        dataSets.Add(dataSet);

        categoriesInitialised = true;
      }


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Expiring Subscriptions" + (code == null ? string.Empty : " by " + code),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "MRR",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    public static XElement ExpiringSubscriptionsQuantityByMonth(DataMart dbContext, string code)
    {
      var query = (from sub in dbContext.SubscriptionTable
                   join c in dbContext.Customer on sub.AccountId equals c.AccountId
                   where
                         sub.EndDate.HasValue &&
                         sub.EndDate.Value >= DateTime.Today.AddMonths(-13) &&
                         sub.EndDate.Value < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1) &&
                         (code == null || code == string.Empty || c.Territorycode.Equals(code))
                   group c by new
                   {
                     Year = sub.EndDate.Value.Year,
                     Month = sub.EndDate.Value.Month
                   } into grp
                   select new
                   {
                     grp.Key.Year,
                     grp.Key.Month,
                     Quantity = grp.Distinct().Count()
                   }).OrderBy(x => x.Year).ThenBy(x => x.Month);

      var categories = new List<Category>();
      var dataSet = new DataSet
      {
        ShowSeriesInLegend = false,
        SeriesName = string.Empty,
        Values = new List<DataSetValue>()
      };

      // 12 categories that represents months 
      var currentDate = DateTime.Now.AddMonths(-12);

      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
        });


        var quantity =
          query.Where(
            x =>
            x.Month == currentDate.Month &&
            x.Year == currentDate.Year
            ).Select(x => x.Quantity).SingleOrDefault().ToString(CultureInfo.InvariantCulture);

        ((List<DataSetValue>)dataSet.Values).Add(new DataSetValue
        {
          Value = quantity,
          DisplayValue = quantity,
          ToolText = quantity,
          Color = NodeAndAttributeName.Colors.ElementAt(i)
        });

        currentDate = currentDate.AddMonths(1);
      }

      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Number Of Customers" + (code == null ? string.Empty : " by " + code),
        Categories = categories,
        DataSets = new List<DataSet>
                      {
                        dataSet
                      },
        XAxisName = "Months",
        YAxisName = "Customers",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = false
      };

      return chart.Render();
    }

    /// <summary>
    /// Bar chart Subscription Counters % bundled units consumed
    /// </summary>
    /// <param name="dbContext"></param>
    /// <param name="productCode"></param>
    /// <param name="salesrepCode"></param>
    /// <param name="customerCode"></param>
    /// <returns></returns>
    public static XElement SubscriptionCountersBundledUnitsPercentsByMonth(DataMart dbContext, string productCode, string salesrepCode, string customerCode)
    {
      int customerId;
      int.TryParse(customerCode, out customerId);

      var counters = (from c in dbContext.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                         && c.BundledUnits != 999999.00m
                      group c by new
                      {
                        Year = c.StartDate.Year,
                        Month = c.StartDate.Month
                      } into grp
                      select new
                      {
                        grp.Key.Year,
                        grp.Key.Month,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits),
                        OverageUnits = grp.Sum(x => x.UnitsConsumed - x.BundledUnits > 0 ? x.UnitsConsumed - x.BundledUnits : 0m)
                      }).ToList();

      var categories = new List<Category>();
      var dataSets = new List<DataSet>();


      var consumedUnitsPercentsSetValues = new List<DataSetValue>();

      // 12 categories that represents months 
      var currentDate = DateTime.Now.AddMonths(-12);
      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
        });

        var monthCounters = counters.SingleOrDefault(x => x.Year == currentDate.Year && x.Month == currentDate.Month);

        // "% bundled units consumed"
        var consumedUnitsPercentsSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0.000" : (monthCounters.ConsumedUnits / monthCounters.BundledUnits * 100).ToString("0.000"),
          DisplayValue = monthCounters == null ? "0.000%" : (monthCounters.ConsumedUnits / monthCounters.BundledUnits).ToString("0.000%")
        };
        consumedUnitsPercentsSetValue.ToolText = consumedUnitsPercentsSetValue.DisplayValue;
        consumedUnitsPercentsSetValues.Add(consumedUnitsPercentsSetValue);

        currentDate = currentDate.AddMonths(1);
      }

      var cunsumedUnitsSet = new DataSet
      {
        ShowSeriesInLegend = false,
        SeriesName = "% bundled units consumed",
        Values = consumedUnitsPercentsSetValues
      };
      dataSets.Add(cunsumedUnitsSet);

      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "% Bundled Units Consumed" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "%",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = true
      };

      return chart.Render();
    }

    /// <summary>
    /// Bar chart Subscription Counters Overage
    /// </summary>
    /// <param name="dbContext"></param>
    /// <param name="productCode"></param>
    /// <param name="salesrepCode"></param>
    /// <param name="customerCode"></param>
    /// <returns></returns>
    public static XElement SubscriptionCountersOverageByMonth(DataMart dbContext, string productCode, string salesrepCode, string customerCode)
    {
      int customerId;
      int.TryParse(customerCode, out customerId);

      var counters = (from c in dbContext.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                         && c.BundledUnits != 999999.00m
                      group c by new
                      {
                        Year = c.StartDate.Year,
                        Month = c.StartDate.Month
                      } into grp
                      select new
                      {
                        grp.Key.Year,
                        grp.Key.Month,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits),
                        OverageUnits = grp.Sum(x => x.UnitsConsumed - x.BundledUnits > 0 ? x.UnitsConsumed - x.BundledUnits : 0m)
                      }).ToList();

      var categories = new List<Category>();
      var dataSets = new List<DataSet>();


      var overageSetValues = new List<DataSetValue>();
      var bundledSetValues = new List<DataSetValue>();

      // 12 categories that represents months 
      var currentDate = DateTime.Now.AddMonths(-12);
      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
        });

        var monthCounters = counters.SingleOrDefault(x => x.Year == currentDate.Year && x.Month == currentDate.Month);

        // Overage
        var overageSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0." : monthCounters.OverageUnits.ToString("0."),
          DisplayValue = monthCounters == null ? "0." : monthCounters.OverageUnits.ToString("0.")
        };
        overageSetValue.ToolText = overageSetValue.DisplayValue;
        overageSetValues.Add(overageSetValue);

        // Bundled
        var bundledSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0." : monthCounters.ConsumedUnits.ToString("0."),
          DisplayValue = monthCounters == null ? "0." : monthCounters.ConsumedUnits.ToString("0.")
        };
        bundledSetValue.ToolText = bundledSetValue.DisplayValue;
        bundledSetValues.Add(bundledSetValue);

        currentDate = currentDate.AddMonths(1);
      }

      var overageUnitsSet = new DataSet
      {
        ShowSeriesInLegend = true,
        SeriesName = "Overage",
        Values = overageSetValues
      };
      dataSets.Add(overageUnitsSet);

      var bundledUnitsSet = new DataSet
      {
        ShowSeriesInLegend = true,
        SeriesName = "Bundled",
        Values = bundledSetValues
      };
      dataSets.Add(bundledUnitsSet);

      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Units" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "Quantity",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = true
      };

      return chart.Render();
    }

    /// <summary>
    /// Bar chart Subscription Counters % overage
    /// </summary>
    /// <param name="dbContext"></param>
    /// <param name="productCode"></param>
    /// <param name="salesrepCode"></param>
    /// <param name="customerCode"></param>
    /// <returns></returns>
    public static XElement SubscriptionCountersOveragePercentsByMonth(DataMart dbContext, string productCode, string salesrepCode, string customerCode)
    {
      int customerId;
      int.TryParse(customerCode, out customerId);

      var counters = (from c in dbContext.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                         && c.BundledUnits != 999999.00m
                      group c by new
                      {
                        Year = c.StartDate.Year,
                        Month = c.StartDate.Month
                      } into grp
                      select new
                      {
                        grp.Key.Year,
                        grp.Key.Month,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits),
                        OverageUnits = grp.Sum(x => x.UnitsConsumed - x.BundledUnits > 0 ? x.UnitsConsumed - x.BundledUnits : 0m)
                      }).ToList();

      var categories = new List<Category>();
      var dataSets = new List<DataSet>();
      var overagePercentsSetValues = new List<DataSetValue>();

      // 12 categories that represents months 
      var currentDate = DateTime.Now.AddMonths(-12);
      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
        });

        var monthCounters = counters.SingleOrDefault(x => x.Year == currentDate.Year && x.Month == currentDate.Month);

        // % Overage
        var overagePercentsSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0.00" : (monthCounters.OverageUnits / monthCounters.ConsumedUnits * 100).ToString("0.00"),
          DisplayValue = monthCounters == null ? "0.00%" : (monthCounters.OverageUnits / monthCounters.ConsumedUnits).ToString("0.00%")
        };
        overagePercentsSetValue.ToolText = overagePercentsSetValue.DisplayValue;
        overagePercentsSetValues.Add(overagePercentsSetValue);

        currentDate = currentDate.AddMonths(1);
      }

      var overagePercentsUnitsSet = new DataSet
      {
        ShowSeriesInLegend = false,
        SeriesName = "% Overage",
        Values = overagePercentsSetValues
      };
      dataSets.Add(overagePercentsUnitsSet);


      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "% Overage Units Consumed" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "%",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = true
      };

      return chart.Render();
    }

    /// <summary>
    /// Bar chart Subscription Counters - Price Per Bundled Unit
    /// </summary>
    /// <param name="dbContext"></param>
    /// <param name="productCode"></param>
    /// <param name="salesrepCode"></param>
    /// <param name="customerCode"></param>
    /// <returns></returns>
    public static XElement SubscriptionCountersPricePerBundledUnitByMonth(DataMart dbContext, string productCode, string salesrepCode, string customerCode)
    {
      int customerId;
      int.TryParse(customerCode, out customerId);

      var counters = (from c in dbContext.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                         && c.BundledUnits != 999999.00m
                      group c by new
                      {
                        Year = c.StartDate.Year,
                        Month = c.StartDate.Month
                      } into grp
                      select new
                      {
                        grp.Key.Year,
                        grp.Key.Month,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits),
                        OverageUnits = grp.Sum(x => x.UnitsConsumed - x.BundledUnits > 0 ? x.UnitsConsumed - x.BundledUnits : 0m),
                        PricePerBundledUnits = grp.Sum(x => x.UnitsConsumed > x.BundledUnits ? 0m : Convert.ToDecimal(x.PricePerUnit)),
                        PricePerOverageUnits = grp.Sum(x => x.UnitsConsumed > x.BundledUnits ? Convert.ToDecimal(x.ProratedBundledPricePerUnit) : 0m)
                      }).ToList();

      var categories = new List<Category>();
      var dataSets = new List<DataSet>();


      var overageSetValues = new List<DataSetValue>();
      var bundledSetValues = new List<DataSetValue>();

      // 12 categories that represents months 
      var currentDate = DateTime.Now.AddMonths(-12);
      for (var i = 0; i < 12; i++)
      {
        categories.Add(new Category
        {
          Label = GetCategoryForMonth(currentDate.Month, currentDate.Year)
        });

        var monthCounters = counters.SingleOrDefault(x => x.Year == currentDate.Year && x.Month == currentDate.Month);

        // Overage
        var overageSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0.00" : monthCounters.PricePerOverageUnits.ToString("0.00"),
          DisplayValue = monthCounters == null ? "0.00" : monthCounters.PricePerOverageUnits.ToString("0.00")
        };
        overageSetValue.ToolText = overageSetValue.DisplayValue;
        overageSetValues.Add(overageSetValue);

        // Bundled
        var bundledSetValue = new DataSetValue
        {
          Value = monthCounters == null ? "0.00" : monthCounters.PricePerBundledUnits.ToString("0.00"),
          DisplayValue = monthCounters == null ? "0.00" : monthCounters.PricePerBundledUnits.ToString("0.00")
        };
        bundledSetValue.ToolText = bundledSetValue.DisplayValue;
        bundledSetValues.Add(bundledSetValue);

        currentDate = currentDate.AddMonths(1);
      }

      var overageUnitsSet = new DataSet
      {
        ShowSeriesInLegend = true,
        SeriesName = "Overage",
        Values = overageSetValues
      };
      dataSets.Add(overageUnitsSet);

      var bundledUnitsSet = new DataSet
      {
        ShowSeriesInLegend = true,
        SeriesName = "Bundled",
        Values = bundledSetValues
      };
      dataSets.Add(bundledUnitsSet);

      var chart = new MSeriesColumn3DChart
      {
        NumberPrefix = string.Empty,
        Caption = "Price Per Bundled Unit" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "Quantity",
        LegendPositionRight = true,
        Styles = GetCommonStylesForChart(),
        ShowValues = true
      };

      return chart.Render();
    }

    /// <summary>
    /// Pie chart Subscription Counters % bundled units consumed
    /// </summary>
    /// <param name="dbContext"></param>
    /// <param name="productCode"></param>
    /// <param name="salesrepCode"></param>
    /// <param name="customerCode"></param>
    /// <returns></returns>
    public static XElement SubscriptionCountersUnitsByMonth(DataMart dbContext, string productCode, string salesrepCode, string customerCode)
    {
      int customerId;
      int.TryParse(customerCode, out customerId);

      var counters = (from c in dbContext.Counters
                      where c.StartDate >= DateTime.Today.AddMonths(-13)
                         && c.StartDate < new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1)
                         && (String.IsNullOrEmpty(customerCode) || c.PayeeID == customerId)
                      group c by new
                      {
                        c.SubscriptionID
                      } into grp
                      select new
                      {
                        Count = grp.Key.SubscriptionID,
                        ConsumedUnits = grp.Sum(x => x.UnitsConsumed>x.BundledUnits ? x.BundledUnits : x.UnitsConsumed),
                        BundledUnits = grp.Sum(x => x.BundledUnits)
                      }).ToList();

      var categories = new List<Category>();
      var dataSets = new List<DataSet>();

      //var consumedUnits = counters.Select(x => x.ConsumedUnits).Sum();
      //var bundledUnits = counters.Select(x => x.BundledUnits).Sum();
      var consumedUnitsPercents = counters.Sum(x => x.ConsumedUnits/x.BundledUnits*100);
      var countSubsribers = counters.Count();

      var consumedUnitsPercentsSetValues = new List<DataSetValue>();

      categories.Add(new Category{Label = "One year"});
      // "% bundled units consumed"
      var consumedUnitsPercentsSetValue = new DataSetValue
      {
        Value = (consumedUnitsPercents / countSubsribers).ToString("0.00"),
        DisplayValue = "Average % Bundled Units Consumed " + (consumedUnitsPercents / countSubsribers).ToString("0.00")
      };
      consumedUnitsPercentsSetValue.ToolText = consumedUnitsPercentsSetValue.DisplayValue;
      consumedUnitsPercentsSetValues.Add(consumedUnitsPercentsSetValue);

      var cunsumedUnitsSet = new DataSet
      {
        ShowSeriesInLegend = true,
        SeriesName = "% bundled units consumed",
        Values = consumedUnitsPercentsSetValues
      };
      dataSets.Add(cunsumedUnitsSet);

      var chart = new Pie2DChart
      {
        NumberPrefix = string.Empty,
        Caption = "% Of Bundled Units Consumed" + (productCode == null ? string.Empty : " by " + productCode),
        Categories = categories,
        DataSets = dataSets,
        XAxisName = "Months",
        YAxisName = "Counters",
        LegendPositionRight = true,
        Styles = GetCommonStylesForPieChart(),
        ShowValues = true,
        ShowPercentageValues = true,
        ShowPercentageInLabel = true,
        ShowLegend = false,
        PieRadius = "100px",
        PieYScale = "90",
        Animation = false
      };

      return chart.Render();
    }

    


    /// <summary>
    /// Get Common Style for chart caption
    /// </summary>
    /// <returns></returns>
    private static Styles GetCommonStylesForPieChart(bool rightToLeft = false)
    {
      return
        new Styles
        {
          Application = new List<Apply>
                            {
                              new Apply {ToObject = "Caption", Styles = "CaptionFont"},
                            },
          Definition = new List<Style>
                           {
                             new Style
                               {
                                 Typestyle = Typestyle.Font,
                                 Color = "ffffff",
                                 Name = "CaptionFont",
                                 Size = 14,
                                 Align = rightToLeft ? NodeAndAttributeName.AlignRightAttributeValue : NodeAndAttributeName.AlignLeftAttributeValue
                               },
                           }
        };
    }*/

    /// <summary>
    /// Get formatted label for category
    /// </summary>
    /// <param name="currentMonth">current month number</param>
    /// <param name="year">current year</param>
    /// <returns></returns>
    private static string GetCategoryForMonth(int currentMonth, int year)
    {
      var cultureInfo =
        DateTimeFormatInfo.GetInstance(CultureInfo.CurrentCulture);

      return string.Concat(cultureInfo.GetAbbreviatedMonthName(currentMonth), "{BR}", year);
    }

    /// <summary>
    /// Get Common Style for chart caption
    /// </summary>
    /// <returns></returns>
    private static Styles GetCommonStylesForChart(bool rightToLeft = false)
    {
      return
        new Styles
        {
          Application = new List<Apply>
                            {
                              new Apply {ToObject = "Caption", Styles = "CaptionFont"},
                            },
          Definition = new List<Style>
                           {
                             new Style
                               {
                                 Typestyle = Typestyle.Font,
                                 Color = "white",
                                 Name = "CaptionFont",
                                 Size = 18,
                                 Align = rightToLeft ? NodeAndAttributeName.AlignRightAttributeValue : NodeAndAttributeName.AlignLeftAttributeValue
                               },
                           }
        };
    }
  }
}