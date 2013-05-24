using System.Diagnostics;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.DataAccess;
using System.Collections.Generic;

namespace MetraTech.Tax.Framework.MetraTax
{
  using System;

  /// <summary>
  /// Used to calculate VAT/GST tax for a collection of amounts.
  /// The amounts and corresponding tax parameter details are
  /// expected to be in an input table.  The calculated taxes
  /// are written to an output table.
  /// </summary>
  public class MetraTaxSyncTaxManagerDBBatch : SyncTaxManagerBatchDb
  {
    // Used to provide the appropriate rate schedules holding MetraTax configured tax information.
    private readonly TaxRateScheduleManager m_taxRateScheduleManager;

    /// <summary>
    /// Used to find the most appropriate rate schedule to use.
    /// This class holds the properties of all rate schedules in memory.
    /// Using this information, this class can find the most appropriate
    /// rate schedule to use for a given account, for a given date.
    /// </summary>
    private readonly RateScheduleFinder m_rateScheduleFinder;

    /// Given an accountId, retrieves values from the the account related to
    /// tax calculations.
    private TaxAccountViewReader m_taxAccountViewReader;

    // Logger
    private static readonly Logger mLogger = new Logger("[MetraTax]");

    // Name of the MetraTax parameter table mapping product and country to a tax band.
    private const string TAX_BAND_PARAMETER_TABLE_NAME = "metratech.com/taxBand";

    // Name of the MetraTax parameter table mapping a country and tax band to a rate.
    private const string TAX_RATE_PARAMETER_TABLE_NAME = "metratech.com/taxRate";

    /// <summary>
    /// Provides access to MetraTax specific configuration values
    /// </summary>
    private readonly MetraTaxConfiguration m_configuration = null;

    /// <summary>
    /// Constructor
    /// </summary>
    public MetraTaxSyncTaxManagerDBBatch()
    {
      m_configuration = new MetraTaxConfiguration();
      m_taxRateScheduleManager = new TaxRateScheduleManager();
      m_rateScheduleFinder = new RateScheduleFinder();
      m_taxAccountViewReader = new TaxAccountViewReader();
    }

    /// <summary>
    /// Calculate taxes.  Before calling this, make sure you have set
    /// the TaxRunId.
    /// There are 3 steps: 
    /// (1) read the input table containing the tax parameters,
    /// (2) computes the taxes,
    /// (3) store the results in the output table
    /// </summary>
    public override void CalculateTaxes()
    {
      CalculateTaxesViaInputTable();
    }

    /// <summary>
    /// Calculate taxes for a single transaction.  Before calling this, make sure
    /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
    /// (4) have filled taxableTransaction with the transaction.
    /// </summary>
    /// <param name="taxableTransaction">an input row filled with transaction to tax.</param>
    /// <param name="transactionSummary">an output row is allocated and filled with results.</param>
    /// <param name="transactionDetails">a list is allocated.  If TaxDetailsNeeded, filled with results.</param>
    public override void CalculateTaxes(TaxableTransaction taxableTransaction,
                                        out TransactionTaxSummary transactionSummary,
                                        out List<TransactionIndividualTax> transactionDetails)
    {
      mLogger.LogInfo("Beginning of MetraTax calculation. -------------------------------------");
      Stopwatch stopWatch = new Stopwatch();
      stopWatch.Start();

      mLogger.LogDebug("Are tax details needed? = " + TaxDetailsNeeded);

      PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

      if (TaxDetailsNeeded)
      {
        // Create the writer for the tax details table.
        var detailWriter = new TaxManagerBatchDbTableWriter(GetTaxDetailTableName(), 1);
        foreach (TransactionIndividualTax row in transactionDetails)
        {
          detailWriter.Add(row);
        }
      }
      stopWatch.Stop();
      mLogger.LogDebug("TIMING: CalculateTaxes elapsed milliseconds={0}", stopWatch.ElapsedMilliseconds);
    }

    /// <summary>
    /// Calculate taxes.  Before calling this, make sure you have set
    /// the TaxRunId.
    /// There are 3 steps: 
    /// (1) read the input table containing the tax parameters,
    /// (2) computes the taxes,
    /// (3) store the results in the output table
    /// 
    /// NOTE: this method is used for unit testing.  Unit test fills the accountViewReader
    /// with fake account info so that tests can be run.
    /// </summary>
    public void CalculateTaxes(TaxAccountViewReader accountViewReader)
    {
      m_taxAccountViewReader = accountViewReader;
      CalculateTaxes();
    }

    /// <summary>
    /// Calculate taxes with the given account Reader.  This method
    /// provides an ability to test.  You can create an account reader and
    /// set the cache of the account reader to hold an account with 
    /// specific MetraTax configuration values.  You then can call 
    /// calculate taxes, testing the configuration.
    /// </summary>
    private void CalculateTaxesViaInputTable()
    {
      mLogger.LogInfo("Beginning of MetraTax calculations. -------------------------------------");

      ReportInfo("Starting tax calculations.");

      mLogger.LogDebug("Are tax details needed? = " + TaxDetailsNeeded);
      mLogger.LogDebug("Opening the tax input table for reading: " + GetInputTaxTableName());
      var reader = new TaxManagerVendorInputTableReader(TaxVendor.MetraTax, TaxRunId, false);

      // Create the output table.
      mLogger.LogDebug("Creating the tax output table: " + GetOutputTaxTableName());
      ReportInfo("Creating tax output table.");

      TaxManagerBatchDbTableWriter.CreateOutputTable(GetOutputTaxTableName());
      var outputWriter = new TaxManagerBatchDbTableWriter(GetOutputTaxTableName(), GetBulkInsertSize());

      // Create the writer for the tax details table.
      var detailWriter = new TaxManagerBatchDbTableWriter(GetTaxDetailTableName(), GetBulkInsertSize());

      // Create storage for a row from the input table.
      TaxableTransaction taxableTransaction;

      int nTransactionsProcessed = 0;
      int errCount = 0;

      while (null != (taxableTransaction = reader.GetNextTaxableTransaction()))
      {
        int idAcc = 0;
        long idTaxCharge = 0;

        // Holder for the output row
        TransactionTaxSummary transactionSummary;

        try
        {
          // Holder for the details row
          List<TransactionIndividualTax> transactionDetails;

          PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

          if (TaxDetailsNeeded)
          {
            foreach (TransactionIndividualTax transactionIndividualTax in transactionDetails)
            {
              detailWriter.Add(transactionIndividualTax);
            }
          }

          // Tell the writers about the new rows.
          outputWriter.Add(transactionSummary);

          nTransactionsProcessed++;
          ReportProgress(nTransactionsProcessed);
        }
        catch (TaxException e)
        {
          String msg = "Failed calculating taxes for account: " + idAcc +
                       " (id_tax_charge: " + idTaxCharge +
                       "). Error: " + e.Message;

          // We've already logged the error at a lower level.
          errCount++;

          // If we exceed the maximum number of errors, we throw the
          // exception and stop.  Otherwise, we keep going.
          if (errCount > MaximumNumberOfErrors)
          {
            outputWriter.Commit();
            detailWriter.Commit();
            reader.Close();
            throw;
          }

          ReportWarning(msg + ". Execution continuing since under the maximum number of errors.");
        }
        catch (Exception)
        {
          // We've already logged the error at a lower level.
          outputWriter.Commit();
          detailWriter.Commit();
          reader.Close();
          throw;
        }
      }

      mLogger.LogDebug("Writing to output table.");
      outputWriter.Commit();
      mLogger.LogDebug("Writing to details table.");
      detailWriter.Commit();
      reader.Close();
      ReportInfo("Completed MetraTax calculations. " + nTransactionsProcessed +
                 " tax transactions processed.");
    }

    private void PerformTaxTransaction(
      TaxableTransaction taxableTransaction,
      out TransactionTaxSummary transactionSummary,
      out List<TransactionIndividualTax> transactionDetails)
    {
      transactionSummary = new TransactionTaxSummary();
      transactionDetails = new List<TransactionIndividualTax>();

      var transactionIndividualTax = new TransactionIndividualTax();

      int idAcc = 0;
      int idUsageInterval = 0;
      long idTaxCharge = 0;
      try
      {
        // Get all the critical values from the taxableTransaction
        idAcc = taxableTransaction.GetInt32("id_acc").GetValueOrDefault();
        idTaxCharge = taxableTransaction.GetInt64("id_tax_charge").GetValueOrDefault();
        idUsageInterval = taxableTransaction.GetInt32("id_usage_interval").GetValueOrDefault();

        decimal amount = taxableTransaction.GetDecimal("amount").GetValueOrDefault();
        DateTime invoiceDate = taxableTransaction.GetDateTime("invoice_date").GetValueOrDefault();
        string productCode = taxableTransaction.GetString("product_code");
        RoundingAlgorithm roundingAlgorithm = Rounding.GetAlgorithm(taxableTransaction.GetString("round_alg"));
        int roundingDigits = taxableTransaction.GetInt32("round_digits").GetValueOrDefault();
        Boolean isImpliedTax = taxableTransaction.GetBool("is_implied_tax").GetValueOrDefault();
        Boolean isStandardImpliedTaxAlgorithm = taxableTransaction.GetBool("is_std_implied_tax_alg").GetValueOrDefault();

        mLogger.LogDebug("Calculating tax------------------------");
        mLogger.LogDebug("Calculating tax for " +
                         " id_tax_charge: " + idTaxCharge +
                         " account: " + idAcc +
                         " product code: " + productCode +
                         " amount: " + amount +
                         " date: " + invoiceDate.ToShortDateString());

        // We will store audit details for this tax calculation here.
        AuditDetail auditDetail = new AuditDetail();

        // Find the appropriate rate schedules for the parameter tables.
        int rateSchedIdTaxBand = m_rateScheduleFinder.GetBestRateScheduleId(idAcc, invoiceDate,
                                                                            TAX_BAND_PARAMETER_TABLE_NAME);
        int rateSchedIdTaxRate = m_rateScheduleFinder.GetBestRateScheduleId(idAcc, invoiceDate,
                                                                            TAX_RATE_PARAMETER_TABLE_NAME);

        // Store audit details about selected tables.
        auditDetail.TaxBandRateScheduleID = rateSchedIdTaxBand;
        auditDetail.TaxRateRateScheduleID = rateSchedIdTaxRate;

        // Read the tax account view
        TaxAccountView view = m_taxAccountViewReader.GetView(idAcc);

        // Make sure that none of the required fields are null (not specified in database).
        if (view.IsNullMetraTaxCountry || view.IsNullMetraTaxCountryZone || view.IsNullHasMetraTaxOverride ||
            (view.HasMetraTaxOverride && view.IsNullMetraTaxOverrideTaxBand))
        {
          string err = "One or more tax account properties has not been initialized for account " +
                       idAcc +
                       ".  Examine t_av_internal for the MetraTax fields country, country zone, " +
                       "has override, and override band.";
          mLogger.LogError(err);
          if (view.IsNullMetraTaxCountry) mLogger.LogError("MetraTaxCountry is null");
          if (view.IsNullMetraTaxCountryZone) mLogger.LogError("MetraTaxCountryZone is null");
          if (view.IsNullHasMetraTaxOverride) mLogger.LogError("HasMetraTaxOverride is null");
          if (view.IsNullMetraTaxOverrideTaxBand) mLogger.LogError("MetraTaxOverrideTaxBand is null");
          throw new TaxException(err);
        }

        // Using the rates schedules and tax parameters, determine the rate
        string taxName; // The configured name for the tax (from PT:TaxRate)

        decimal taxRate = GetTaxRate(idAcc,
                                     rateSchedIdTaxBand,
                                     rateSchedIdTaxRate,
                                     productCode,
                                     view.MetraTaxCountryCode,
                                     view.MetraTaxCountryZone,
                                     view.HasMetraTaxOverride,
                                     view.MetraTaxOverrideTaxBand,
                                     auditDetail,
                                     out taxName);

        transactionSummary.IdTaxCharge = idTaxCharge;
        CalculateTaxWithThisRate(amount, taxRate, view.MetraTaxCountryCode,
                                 transactionSummary, isImpliedTax, isStandardImpliedTaxAlgorithm,
                                 roundingAlgorithm, roundingDigits);

        // Fill in a structure that is holding the tax transaction details
        {
          var individualTax = new TransactionIndividualTax();

          // The configured jurisdication tells us where the calculated tax was stored.
          // Copy this to the tax detail record.
          switch (m_configuration.JurisdicationToUse)
          {
            case TaxJurisdiction.State:
              individualTax.TaxAmount = transactionSummary.TaxStateAmount.GetValueOrDefault();
              individualTax.TaxJurLevel = (int)TaxJurisdiction.State;
              break;

            case TaxJurisdiction.County:
              individualTax.TaxAmount = transactionSummary.TaxCountyAmount.GetValueOrDefault();
              individualTax.TaxJurLevel = (int)TaxJurisdiction.County;
              break;

            case TaxJurisdiction.Local:
              individualTax.TaxAmount = transactionSummary.TaxLocalAmount.GetValueOrDefault();
              individualTax.TaxJurLevel = (int)TaxJurisdiction.Local;
              break;

            case TaxJurisdiction.Other:
              individualTax.TaxAmount = transactionSummary.TaxOtherAmount.GetValueOrDefault();
              individualTax.TaxJurLevel = (int)TaxJurisdiction.Other;
              break;

            case TaxJurisdiction.Federal:
            default:
              individualTax.TaxAmount = transactionSummary.TaxFedAmount.GetValueOrDefault();
              individualTax.TaxJurLevel = (int)TaxJurisdiction.Federal;
              break;
          }

          DateTime now = DateTime.Now;
          individualTax.DateOfCalc = now;
          individualTax.IdTaxCharge = idTaxCharge;
          individualTax.IdAcc = idAcc;
          individualTax.IdUsageInterval = idUsageInterval;
          individualTax.IdTaxDetail = 1;
          individualTax.IdTaxRun = mTaxRunId;
          individualTax.Rate = taxRate;
          individualTax.IsImplied = isImpliedTax;
          individualTax.TaxType = 0;
          individualTax.TaxTypeName = taxName;


          if (IsAuditingNeeded == true)
          {
            individualTax.Notes = auditDetail.ToString();
          }
          else
          {
            individualTax.Notes = "";
          }

          individualTax.TaxJurName = view.MetraTaxCountryZone.ToString();

          // If configured, we attempt to convert the country code into an actual country name.
          string countryName = GetCountryName(view.MetraTaxCountryCode);
          if (countryName.Length > 0)
          {
            individualTax.TaxJurName = countryName + "_" + view.MetraTaxCountryZone.ToString();
          }

          transactionDetails.Add(individualTax);
        }

      }
      catch (TaxException e)
      {
        String msg = "Failed calculating taxes for account: " + idAcc +
                     " (id_tax_charge: " + idTaxCharge +
                     "). Error: " + e.Message;
        mLogger.LogException(msg, e);
        throw;
      }
      catch (Exception e)
      {
        String msg = "Fatal error calculating taxes for account: " + idAcc +
                     " (id_tax_charge: " + idTaxCharge +
                     "). Error: " + e.Message;
        mLogger.LogException(msg, e);
        throw;
      }
    }

    /// <summary>
    /// Determine the tax rate to use.
    /// 
    /// 1. If the accounts is marked as exempt, use 0 for the tax rate else
    /// 2. Determine the product tax rate by using the given the rate schedules 
    ///    to use for parameter table taxBand and taxRate,
    ///    and given the product code, account, and transaction date,
    /// 3. Determine if the account has an override.  If so, use the rate schedules
    ///    to get the override rate.
    /// 4. Use the lower of the product tax rate and the override rate (if there
    ///    was one).
    /// </summary>
    /// <param name="accountID">account ID </param>
    /// <param name="taxBandRateScheduleId">rate schedule ID for instance of t_pt_taxBand</param>
    /// <param name="taxRateRateScheduleId">rate schedule ID for instance of t_pt_taxRate</param>
    /// <param name="productCode">product code as entered in t_pt_taxBand</param>
    /// <param name="countryCode">This is the country associated with the account
    ///                       corresponding to the taxable amount.  
    ///                       It is: enum global/CountryName</param>
    /// <param name="taxZone">This is the country zone associated with the account
    ///                       corresponding to the taxable amount.  The zone is used
    ///                       in special cases when there's a region of the country that has
    ///                       special tax bands.
    ///                       It is: enum MetraTax/TaxZone</param>
    /// <param name="hasOverrideBand">true if the account has an override band. </param>
    /// <param name="overrideBand">If the account has an override band, the band to use.</param>
    /// <param name="auditDetail">Audit details will be set, namely, override tax band and rate schedule audit id's. </param>
    /// <param name="taxName">An output giving the name of the selected tax band for
    ///                       the rate.  This comes from the configured value in the PT TaxRate.
    ///                       If exempt, the tax name is "Exempt".</param>
    /// <returns></returns>
    public decimal GetTaxRate(int accountID, int taxBandRateScheduleId, int taxRateRateScheduleId, string productCode,
                              int countryCode, TaxZone taxZone, bool hasOverrideBand, TaxBand overrideBand,
                              AuditDetail auditDetail, out string taxName)
    {
      // Does the account have an override tax band of exempt?
      // No need to go further.
      if (hasOverrideBand && overrideBand == TaxBand.Exempt)
      {
        mLogger.LogDebug("Account: " + accountID + " has an override tax band: exempt. Rate is 0.");
        taxName = "Exempt";
        auditDetail.OverrideTaxBand = (int)TaxBand.Exempt;
        return 0.0m;
      }

      // We expect to find a row in the taxBand schedule for the given productCode
      // and country, telling us the taxBand to use.
      int taxBandAuditID;
      TaxBand taxBand = m_taxRateScheduleManager.GetTaxBand(taxBandRateScheduleId, productCode, countryCode,
                                                            out taxBandAuditID);
      auditDetail.TaxBandAuditID = taxBandAuditID;

      // We expect to find a row in the taxRate schedule for the given country, zone, and
      // tax band telling us the tax rate.
      int taxRateAuditID;
      decimal productRate = m_taxRateScheduleManager.GetTaxRate(taxRateRateScheduleId, countryCode, taxZone, taxBand,
                                                                out taxName, out taxRateAuditID);
      auditDetail.TaxRateAuditID = taxRateAuditID;

      decimal rate = productRate;

      // Check if there is an override for the account.
      // If there is, check if the override rate is lower than the product rate.
      // If so, use the override rate.
      if (hasOverrideBand)
      {
        decimal overrideRate = m_taxRateScheduleManager.GetTaxRate(taxRateRateScheduleId, countryCode, taxZone,
                                                                   overrideBand, out taxName, out taxRateAuditID);
        if (overrideRate < productRate)
        {
          mLogger.LogDebug("Using account " + accountID + " override rate since it is lower than " +
                           "the product rate: " + productRate);
          auditDetail.OverrideTaxBand = (int)overrideBand;
          rate = overrideRate;
        }
        else
        {
          mLogger.LogDebug("Not using account " + accountID + " override rate: " + overrideRate +
                           " since it is no lower than the product rate: " + productRate);
        }
      }

      mLogger.LogDebug("Using tax rate " + rate + " Tax band: " + taxBand +
                       " product code: " + productCode +
                       " country: " + countryCode + " zone: " + taxZone + " name: " + taxName);
      return rate;
    }

    protected override void RollbackVendorAudit()
    {
      // There's no concept of rollback a vendor audit for MetraTech.
    }

    /// <summary>
    /// Calculate federal taxes by taking the given rate times the given
    /// amount.  All other taxes are set to 0.
    /// </summary>
    /// <param name="amount"></param>
    /// <param name="rate"></param>
    /// <param name="countryCode"></param>
    /// <param name="transactionSummary"></param>
    /// <param name="isImplied"> </param>
    /// <param name="roundingAlgorithm"> </param>
    /// <param name="roundingDigits"> </param>
    private void CalculateTaxWithThisRate(decimal amount,
                                          decimal rate,
                                          int countryCode,
                                          TransactionTaxSummary transactionSummary,
                                          Boolean isImplied,
                                          Boolean isStandardImpliedTaxAlgorithm,
                                          RoundingAlgorithm roundingAlgorithm,
                                          int roundingDigits)
    {
      transactionSummary.TaxFedAmount = 0;
      transactionSummary.TaxFedName = "Federal Tax Value";
      transactionSummary.TaxFedRounded = 0;
      transactionSummary.TaxStateAmount = 0;
      transactionSummary.TaxStateName = "State Tax Value";
      transactionSummary.TaxStateRounded = 0;
      transactionSummary.TaxCountyAmount = 0;
      transactionSummary.TaxCountyName = "County Tax Value";
      transactionSummary.TaxCountyRounded = 0;
      transactionSummary.TaxLocalAmount = 0;
      transactionSummary.TaxLocalName = "Local Tax Value";
      transactionSummary.TaxLocalRounded = 0;
      transactionSummary.TaxOtherAmount = 0;
      transactionSummary.TaxOtherName = "Other Tax Value";
      transactionSummary.TaxOtherRounded = 0;

      decimal taxAmount;
      if (!isImplied)
      {
        taxAmount = amount * rate;
      }
      else
      {
        taxAmount = CalculateImpliedTax(amount, rate, isStandardImpliedTaxAlgorithm);
      }

      decimal taxAmountRounded = Rounding.Round(taxAmount, roundingAlgorithm, roundingDigits);

      // Based on configuration, determine which jurisdication we want to
      // use to store the taxes.
      switch (m_configuration.JurisdicationToUse)
      {
        case TaxJurisdiction.State:
          transactionSummary.TaxStateAmount = taxAmount;
          transactionSummary.TaxStateName = GetCountryName(countryCode);
          transactionSummary.TaxStateRounded = taxAmountRounded;
          break;

        case TaxJurisdiction.County:
          transactionSummary.TaxCountyAmount = taxAmount;
          transactionSummary.TaxCountyName = GetCountryName(countryCode);
          transactionSummary.TaxCountyRounded = taxAmountRounded;
          break;

        case TaxJurisdiction.Local:
          transactionSummary.TaxLocalAmount = taxAmount;
          transactionSummary.TaxLocalName = GetCountryName(countryCode);
          transactionSummary.TaxLocalRounded = taxAmountRounded;
          break;

        case TaxJurisdiction.Other:
          transactionSummary.TaxOtherAmount = taxAmount;
          transactionSummary.TaxOtherName = GetCountryName(countryCode);
          transactionSummary.TaxOtherRounded = taxAmountRounded;
          break;

        case TaxJurisdiction.Federal:
        default:
          transactionSummary.TaxFedAmount = taxAmount;
          transactionSummary.TaxFedName = GetCountryName(countryCode);
          transactionSummary.TaxFedRounded = taxAmountRounded;
          break;
      }
    }

    private static decimal CalculateImpliedTax(decimal amount, decimal rate, bool isStandardImpliedTaxAlgorithm)
    {
      decimal tax = 0.0M;
      if (isStandardImpliedTaxAlgorithm)
      {
        tax = amount - (amount / (rate + 1.0M));
      }
      else // Use the Brazillian tax algorithm
      {
        tax = amount * rate;
      }
      return tax;
    }

    /// <summary>
    /// If configured to return a country name for a country code,
    /// then attempt to convert the code into the MetraTech global
    /// country enum, and from there to a string.  Returns an empty
    /// string if anything goes wrong.
    /// </summary>
    /// <param name="countryCode"></param>
    /// <returns></returns>
    private
      string GetCountryName
      (int
      countryCode)
    {
      if (!m_configuration.ShouldUseCountryName)
      {
        return "";
      }

      try
      {
        CountryName countryName = (CountryName)MetraTech.DomainModel.Enums.EnumHelper.GetCSharpEnum(countryCode);
        return countryName.ToString();
      }
      catch
      {
        return "";
      }
    }
  }
}

