using System;
using System.Collections.Generic;
using Framework.TaxManager.VertexQ;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.Tax.Framework.DataAccess;

namespace MetraTech.Tax.Framework.VertexQ
{
  /// <summary>
  /// This class interacts with the VertexQ software to compute taxes.
  /// </summary>
  public class VertexSyncTaxManager : SyncTaxManagerBatchDb
  {
    private static readonly Logger Logger = new Logger("[VertexQ]");
    private readonly SocketClient _client;

    /// <summary>
    /// Provides thread safe access to t_tax_input_*
    /// </summary>
    private TaxManagerVendorInputTableReader _reader;

    /// <summary>
    /// Provides thread safe access to t_tax_output_*
    /// </summary>
    private TaxManagerBatchDbTableWriter _writer;

    /// <summary>
    /// Provides thread safe access to t_tax_details
    /// </summary>
    private TaxManagerBatchDbTableWriter _detailWriter;

    /// <summary>
    /// Constructor
    /// </summary>
    public VertexSyncTaxManager()
    {
      Logger.LogDebug(System.Reflection.MethodBase.GetCurrentMethod().Name);
      var configuration = new VertexQConfiguration();
      _client = new SocketClient(Logger, configuration);
      Logger.LogDebug("CalcVertexTaxes.Configure Instatiating the AsynchronousClient with Port - " +
                      configuration.Port);
    }

    /// <summary>
    /// Calculate taxes for a SINGLE transaction.  Before calling this, make sure
    /// you have set: (1) TaxRunID, (2) IsAuditingNeeded, (3) TaxDetailsNeeded,
    /// (4) have filled the taxableTransaction.
    /// </summary>
    /// <param name="taxableTransaction">Contains the name-value pairs needed by the specified tax vendor to compute taxes</param>
    /// <param name="transactionSummary">OUTPUT will contain the tax results summed up for each jurisdiction</param>
    /// <param name="transactionDetails">OUTPUT will contain the individual tax results</param>
    public override void CalculateTaxes(TaxableTransaction taxableTransaction,
                                        out TransactionTaxSummary transactionSummary,
                                        out List<TransactionIndividualTax> transactionDetails)
    {
      Logger.LogDebug("CalculateTaxes: taxableTransaction={0}", taxableTransaction.ToString());
      try
      {
        PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

        if (!TaxDetailsNeeded) return;
        
        // Write the resulting transactionDetails to the t_tax_details table
        var detailWriter = new TaxManagerBatchDbTableWriter(GetTaxDetailTableName(), GetBulkInsertSize());
        foreach (var row in transactionDetails)
          detailWriter.Add(row);
        detailWriter.Commit();
      }
      catch (Exception exc)
      {
        // Assume this exception is lethal.
        // So, rethrow it.
        var msg = String.Format("{0}: caught {1} while processing taxableTransaction {2}",
                                System.Reflection.MethodBase.GetCurrentMethod().Name,
                                exc, taxableTransaction);
        Logger.LogError(msg);
        Logger.LogException(msg, exc);
        throw;
      }
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
      // Keep track of the number of errors that have occurred
      int numErrors = 0;

      // Keep track of the number of rows in t_tax_input_* that have been processed.
      int numRowsProcessed = 0;

      // Create a reader for the input table.
      Logger.LogDebug("Reading {0}", GetInputTaxTableName());
      _reader = new TaxManagerVendorInputTableReader(
        TaxVendor.VertexQ, TaxRunId,
        false // This is NOT an attempt to reverse the audit
        );

      // Create output table.
      ReportInfo("Creating tax output table.");
      TaxManagerBatchDbTableWriter.CreateOutputTable(GetOutputTaxTableName());

      // Create the writer for t_tax_output_*
      _writer = new TaxManagerBatchDbTableWriter(
        GetOutputTaxTableName(), GetBulkInsertSize());

      // Create the writer for the tax details table.
      _detailWriter = new TaxManagerBatchDbTableWriter(
        GetTaxDetailTableName(), GetBulkInsertSize());

      try
      {
        //
        // Loop through all of the potential taxable transactions
        //
        TaxableTransaction taxableTransaction;
        while (null != (taxableTransaction = _reader.GetNextTaxableTransaction()))
        {
          try
          {
            TransactionTaxSummary transactionSummary;
            List<TransactionIndividualTax> transactionDetails;

            // Perform transaction with VertexQ to populate the transactionSummary and taxDetailRows
            PerformTaxTransaction(taxableTransaction, out transactionSummary, out transactionDetails);

            // Write the resulting output row to the t_tax_output_* table
            _writer.Add(transactionSummary);

            if (TaxDetailsNeeded)
            {
              // Write the resulting transactionDetails to the t_tax_details table
              foreach (TransactionIndividualTax row in transactionDetails)
              {
                _detailWriter.Add(row);
              }
            }

            // Report on the progess on this input_table
            numRowsProcessed++;
            ReportProgress(numRowsProcessed);
          }
          catch (TaxException e)
          {
            var msg = String.Format("{0}: caught {1} while processing row {2}",
                                       System.Reflection.MethodBase.GetCurrentMethod().Name,
                                       e.Message, numRowsProcessed);

            Logger.LogError(msg);
            numErrors++;

            // If we exceed the maximum number of errors, we throw the
            // exception and stop.  Otherwise, we keep going.
            if (numErrors > MaximumNumberOfErrors)
            {
              Logger.LogError("{0}: exceeded {1} errors, so rethrowing",
                              System.Reflection.MethodBase.GetCurrentMethod().Name,
                              MaximumNumberOfErrors);
              throw new TaxException(msg);
            }

            ReportWarning(msg + ". Execution continuing since under the maximum number of errors.");
          }
          catch (Exception e)
          {
            // Assume this exception is lethal.
            // So, rethrow it.
            var msg = String.Format("{0}: caught {1} while processing row {2}",
                                       System.Reflection.MethodBase.GetCurrentMethod().Name,
                                       e.Message, numRowsProcessed);
            Logger.LogError(msg);
            throw;
          }
        }

        // Commit the changes to the DB
        _writer.Commit();
        _detailWriter.Commit();

        ReportInfo("Completed VertexQ calculations. " + numRowsProcessed +
                   " tax transactions processed.");
        _reader.Close();
      }
      catch (Exception e)
      {
        Logger.LogError("{0}: caught {1} while processing row {2}, rethrowing",
                        System.Reflection.MethodBase.GetCurrentMethod().Name,
                        e.Message, numRowsProcessed);

        // Commit the changes to the DB
        _writer.Commit();
        _detailWriter.Commit();

        _reader.Close();
        throw;
      }
    }

    /// <summary>
    /// Loops through the previously completed transactions and reverses
    /// each transaction.  After each reversal transaction is complete, 
    /// the corresponding row in the output table is removed for book keeping.
    /// </summary>
    protected override void RollbackVendorAudit()
    {
      throw new TaxException("RollbackVendorAudit NOT IMPLEMENTED");
    }

    private void PerformTaxTransaction(
      TaxableTransaction taxableTransaction,
      out TransactionTaxSummary transactionSummary,
      out List<TransactionIndividualTax> transactionDetails)
    {
      transactionSummary = new TransactionTaxSummary();
      transactionDetails = null;
      Logger.LogDebug("CalcVertexTaxes.PerformTaxTransaction Method");
      try
      {
        long idTaxCharge = 0;
        if (taxableTransaction.GetInt64("id_tax_charge").HasValue)
        {
          idTaxCharge = taxableTransaction.GetInt64("id_tax_charge").GetValueOrDefault();
        }

        var vertexParamsXml = new VertexParamsXml();
        var vertexParamsXmlString = vertexParamsXml.GetVertexParametersXml(taxableTransaction);
        var returnXmlStr = InvokeRequest(vertexParamsXmlString);

        var roundingAlgorithm = Rounding.GetAlgorithm(taxableTransaction.GetString("round_alg"));
        var roundingDigits = taxableTransaction.GetInt32("round_digits").GetValueOrDefault();
        transactionSummary = vertexParamsXml.ParseVertexTaxResultsToTransactionTaxSummary(
          idTaxCharge, returnXmlStr, roundingAlgorithm, roundingDigits);

        Logger.LogInfo("TaxDetailsNeeded : {0}", TaxDetailsNeeded);

        // Create the detail information.  It may or may not be stored in the DB.
        var isImpliedTax = taxableTransaction.GetBool("is_implied_tax").GetValueOrDefault();
        var idAcc = taxableTransaction.GetInt32("id_acc").GetValueOrDefault();
        var idUsageInterval = taxableTransaction.GetInt32("id_usage_interval").GetValueOrDefault();

        transactionDetails = vertexParamsXml.ParseVertexTaxResultsToTransactionDetails(
          idTaxCharge, isImpliedTax, idAcc, TaxRunId, idUsageInterval, returnXmlStr);

        Logger.LogDebug("transactionDetails.Count={0}", transactionDetails.Count);
        foreach (var transactionDetail in transactionDetails)
        {
          Logger.LogDebug(transactionDetail.ToString());
        }
      }
      catch (Exception e)
      {
        Logger.LogError(string.Format("CalcVertexTaxes.ProcessSess caught exception {0}", e.Message));
      }
    }

    private string InvokeRequest(string vertexParamsXmlString)
    {
      Logger.LogDebug("sending tax transaction to vertex: {0}", vertexParamsXmlString);

      string returnXmlStr;
      var reattemptCnt = 0;
      do
      {
        returnXmlStr = _client.InitiateTransaction("ProcessSession", vertexParamsXmlString);
        Logger.LogDebug("CalcVertexTaxes.ProcessSess XMLReturn from Server : " + returnXmlStr);
        reattemptCnt++;
      } while (reattemptCnt < 3 && (returnXmlStr.Equals("REMOTESOCKETERROR")));

      if (reattemptCnt == 3 && (returnXmlStr.Equals("REMOTESOCKETERROR")))
      {
        throw new Exception("CalcVertexTaxes.ProcessSess Failed in the Call to Calculate Tax : REMOTESOCKETERROR");
      }
      return returnXmlStr;
    }
  }
}