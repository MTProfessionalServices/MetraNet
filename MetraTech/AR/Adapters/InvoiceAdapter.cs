using System;
using System.Xml;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;
using System.IO;

namespace MetraTech.AR.Adapters
{
  /// <summary>
  /// Export invoices to A/R and checks balances.
  /// 
  /// Dependencies:
  ///   (1) Invoice Adapter 
  ///       t_invoice should have been populated with invoice amounts and balances
  ///       for all accounts that had usage for the interval being closed. 
  ///   (2) ARPaymentAndAdjustmentAdapter
  ///       payments should exported before comparing balances
  /// 
  /// Details:
  /// The adapter looks for all invoices in t_invoice for the given interval and 
  /// exports them to A/R in sets (set size is configurable). All sets will be submitted 
  /// with the batch ID "INV123" where 123 is the Interval being processed. 
  /// Each set gets submitted in a transaction. An error in one invoice rolls back the whole set,
  /// not the batch, since it is assumed that an interval back out will be run on failure.
  /// If the invoice export succeeds the adapter (optionally) checks the balances for all
  /// accounts that had invoices created. The balances are checked in sets (same set size
  /// as the invoice export). If an account has a different balance in MetraNet than in 
  /// A/R, a warning will be logged in the adapter run history and the MTLog and the check 
  /// continues. A balance mismatch is an exceptional circumstance and will need manual 
  /// intervention by operations.
  /// 
  /// Back out:
  /// Back out of the interval 123 will delete the batch "INV123" on the A/R side.
  /// </summary>
  public class InvoiceAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // data
    private Logger mLogger = new Logger("[ARInvoiceAdapter]");
    private int mSetSize = 0;
    private bool mExportInvoices = true;
    private bool mCheckBalances = false;
    private bool mCheckBalancesErrorIfMismatch = false;
    private bool mExportInvoiceTaxDetails = true;
    private string mExportInvoiceQuery = "";
    private string mExportInvoiceTaxDetailQuery = "";

    private ArrayList mAccountNameSpaces;
    private object mARConfigState;
    private Dictionary<string, string> mDatabaseToInterfacePropertyMappings;

    // adapter capabilities
    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public bool HasBillingGroupConstraints { get { return false; } }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.BillingGroup; } }

    public InvoiceAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      if (limitedInit)
      {
        mLogger.LogDebug("Intializing adapter (limited)");
      }
      else
      {
        mLogger.LogDebug("Intializing Adapter");

        ReadConfig(configFile);

        mAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;
        mDatabaseToInterfacePropertyMappings = ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings;

        //configure ARInterface
        IMTARConfig ARConfig = new MTARConfigClass();
        mARConfigState = ARConfig.Configure("");
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
      mLogger.LogDebug("ARInvoiceAdapter::Execute() starts processing interval: {0}, billing group ID: {1}", context.UsageIntervalID, context.BillingGroupID);

      string returnMessage = "";

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        if (mExportInvoices)
        {
          //set batchID as "INV123", where 123 is the IntervalID closed
          string batchID;
          batchID = String.Format("INV{0}", context.UsageIntervalID); //from config!!

          int numInvoicesExported;
          //export non-negative invoices
          ExportInvoices(false, conn, context, out numInvoicesExported);
          returnMessage += String.Format("Exported {0} invoice{1}",
                                          numInvoicesExported,
                                          numInvoicesExported == 1 ? "" : "s");

          //export negative invoices (as credit adjustments)
          ExportInvoices(true, conn, context, out numInvoicesExported);
          returnMessage += String.Format(", {0} credit memo{1}.",
                                          numInvoicesExported,
                                          numInvoicesExported == 1 ? "" : "s");
        }

        if (mCheckBalances)
        {
          int numBalanceMatches;
          int numBalanceMismatches;
          CheckBalances(conn, context, out numBalanceMatches, out numBalanceMismatches);

          returnMessage += String.Format(" {0} balance{1} OK, {2} balance{3} did not match.",
                                          numBalanceMatches,
                                          numBalanceMatches == 1 ? "" : "s",
                                          numBalanceMismatches,
                                          numBalanceMismatches == 1 ? "" : "s");

          if (mCheckBalancesErrorIfMismatch & (numBalanceMismatches != 0))
          {
            string msg;
            msg = "All work completed successfully but Balance Check configured to trigger adapter failure at end of processing if any balances mismatch.";
            msg += returnMessage;
            throw new ARException(msg);
          }

        }
      }

      return returnMessage;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string batchID = MakeBatchID(context);
      mLogger.LogDebug("Reversing interval {0}, billing group ID {1}. Deleting AR batch {2}", context.UsageIntervalID, context.BillingGroupID, batchID);

      string msg;
      if (AdapterUtil.DeleteAdapterBatch(batchID, mARConfigState, context, out msg))
      {
        return "Reverse succeeded. " + msg;
      }
      else
      {
        msg = String.Format("Unable to delete AR Batch {0}. {1}", batchID, msg);
        mLogger.LogWarning(msg);
        throw new ARException(msg);
      }

      /*
      if (AdapterUtil.DeleteAdapterBatch(batchID, mARConfigState, context, out BatchExists, out msg))
      {
        mLogger.LogDebug("Reverse succeeded, batch deleted.");
        detail = "Successfully deleted AR batch " + batchID;
      }
      else
      {
        if (BatchExists)
        {
          msg = String.Format("Unable to delete AR Batch {0}. The batch exists but cannot be deleted, most likely because it has already been posted.",
            batchID);
          mLogger.LogWarning(msg);
          //context.RecordWarning(msg);
          throw new ARException(msg);
        }
        else
        {
          mLogger.LogDebug("Reverse succeeded, batch does not exist.");
          detail = String.Format("No AR cleanup needed; AR batch {0} does not exist.", batchID);
        }
      }
			*/

      //return detail;
    }

    public void SplitReverseState(int parentRunID,
                    int parentBillingGroupID,
                    int childRunID,
                    int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Invoice Adapter");
    }

    public void Shutdown()
    {
    }


    private void ReadConfig(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mSetSize = doc.GetNodeValueAsInt("//SetSize", 500);
      mExportInvoices = doc.GetNodeValueAsBool("//ExportInvoices", true);
      mCheckBalances = doc.GetNodeValueAsBool("//CheckBalances", false);
      mCheckBalancesErrorIfMismatch = doc.GetNodeValueAsBool("//CheckBalancesErrorIfMismatch", false);
      mExportInvoiceTaxDetails = doc.GetNodeValueAsBool("//ExportInvoiceTaxDetails", false);
      if (mExportInvoiceTaxDetails)
      {
        mExportInvoiceQuery = doc.GetNodeValueAsString("//ExportInvoiceQueryWithTaxSummary");
        mExportInvoiceTaxDetailQuery = doc.GetNodeValueAsString("//ExportInvoiceTaxDetailQuery");
      }
      else
      {
        mExportInvoiceQuery = doc.GetNodeValueAsString("//ExportInvoiceQuery", "__GET_INVOICES_TO_EXPORT__");
      }
    }

    /// <summary>
    /// returns a batch ID given the context
    /// format is "PREFIX123", using the interval id
    /// </summary>
    private string MakeBatchID(IRecurringEventRunContext context)
    {
      Debug.Assert(context.EventType == RecurringEventType.EndOfPeriod);
      return ARConfiguration.GetInstance().InvoiceBatchPrefix + context.BillingGroupID;
    }

    private void ExportInvoices(bool exportAdjustments,
                  IMTConnection conn,
                  IRecurringEventRunContext context,
                  out int numInvoicesExported)
    {
      int billgroupID = context.BillingGroupID;
      string IDPrefix;
      string queryTag;
      string docType;
      string msgLabel;
      string joinColumnForTaxDetails;

      numInvoicesExported = 0;

      if (exportAdjustments)
      {
        mLogger.LogDebug("Exporting invoice adjustments");
        msgLabel = "Invoice Adjustments";
        IDPrefix = ARConfiguration.GetInstance().InvoiceAdjustmentIDPrefix;
        queryTag = "__GET_INVOICE_ADJUSTMENTS_TO_EXPORT__";
        docType = "CreateAdjustment";
        joinColumnForTaxDetails = "AdjustmentID";
      }
      else
      {
        mLogger.LogDebug("Exporting invoices");
        msgLabel = "Invoices";
        IDPrefix = ARConfiguration.GetInstance().InvoiceIDPrefix;
        queryTag = mExportInvoiceQuery; //"__GET_INVOICES_TO_EXPORT__" or __INVOICE_TAX_SUMMARY_FOR_EXTERNAL_AR_SYSTEM__;
        docType = "CreateInvoice";
        joinColumnForTaxDetails = "InvoiceID";
      }

      string batchID = MakeBatchID(context);

      // export for each account namespace
      int numInvoicesExportedForNamespace;
      string sAccountNameSpace;
      string msg;
      for (int i = 0; i < mAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = mAccountNameSpaces[i].ToString();
        numInvoicesExportedForNamespace = 0;

        // step: get all invoices/adjustments to export
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", queryTag))
        {
            stmt.AddParam("%%ID_PREFIX%%", IDPrefix);
            stmt.AddParam("%%BATCH_ID%%", batchID);
            stmt.AddParam("%%NAME_SPACE%%", sAccountNameSpace);
            stmt.AddParam("%%ID_BILLGROUP%%", billgroupID);

            IMTDataReader readerTaxDetails = null;
            IMTConnection connTaxDetails = null;
            bool bHasChildren = false;
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                if (mExportInvoiceTaxDetails)
                {
                    connTaxDetails = ConnectionManager.CreateConnection();
                    mLogger.LogDebug("Reading invoice tax details to export using query [" + mExportInvoiceTaxDetailQuery + "]");
                    IMTAdapterStatement stmtTaxDetails = connTaxDetails.CreateAdapterStatement("Queries\\AR", mExportInvoiceTaxDetailQuery);
                    stmtTaxDetails.AddParam("%%ID_PREFIX%%", IDPrefix);
                    //stmtTaxDetails.AddParam("%%BATCH_ID%%", batchID); 
                    stmtTaxDetails.AddParam("%%NAME_SPACE%%", sAccountNameSpace);
                    stmtTaxDetails.AddParam("%%ID_BILLGROUP%%", billgroupID);
                    readerTaxDetails = stmtTaxDetails.ExecuteReader();

                    // Make sure the childReader cursor is positioned on the first record, if there is one.
                    //bHasChildren = readerTaxDetails.Read();
                }

                // loop to export mSetSize rows at a time
                while (true)
                {
                    //step: load mSetSize rows as XML
                    int numRowsRead;
                    string xml = "";
                    if (mExportInvoiceTaxDetails)
                    {
                        xml = ReadParentAndChildReadersToXml(reader, readerTaxDetails, bHasChildren, joinColumnForTaxDetails, @"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", docType, "TaxDetails", "TaxDetail", mSetSize, out numRowsRead, mDatabaseToInterfacePropertyMappings);
                    }
                    else
                    { //Just use the base functionality to generate the xml for each row
                        xml = reader.ReadToXml(@"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", docType, mSetSize, out numRowsRead, mDatabaseToInterfacePropertyMappings);
                    }

                    if (numRowsRead == 0)
                    {
                        if (numInvoicesExportedForNamespace == 0)
                        {
                            msg = String.Format("{0}: There are no documents to export for AccountNamespace {1}", msgLabel, sAccountNameSpace);
                            context.RecordInfo(msg);
                        }
                        else
                        {
                            msg = String.Format("{0}: Sent {1} documents total to AR Batch {2} for AccountNamespace {3}", msgLabel, numInvoicesExportedForNamespace, batchID, sAccountNameSpace);
                            context.RecordInfo(msg);
                        }
                        break;
                    }

                    msg = String.Format("{0}: Sending {1} documents to AR Batch {2} for AccountNamespace {3}", msgLabel, numRowsRead, batchID, sAccountNameSpace);
                    context.RecordInfo(msg);

                    //step: Export invoices/adjustment to A/R
                    IMTARWriter writer = new MTARWriterClass();
                    if (exportAdjustments)
                    {
                        writer.CreateAdjustments(xml, mARConfigState);
                    }
                    else
                    {
                        if (mExportInvoiceTaxDetails)
                        {
                            writer.CreateInvoicesWithTaxDetails(xml, mARConfigState);
                        }
                        else
                        {
                            writer.CreateInvoices(xml, mARConfigState);
                        }
                    }

                    numInvoicesExportedForNamespace += numRowsRead;
                    numInvoicesExported += numRowsRead;
                }
            }
        }
      }
    }

    /// <summary>
    ///  checks balance for accounts that have invoices and balances given an interval
    /// Precondition for this function:
    ///  - t_invoice records should have been created
    ///  - invoices should have been propagated to AR
    /// </summary>
    private void CheckBalances(IMTConnection conn,
                               IRecurringEventRunContext context,
                               out int numBalanceMatches,
                               out int numBalanceMismatches)
    {
      string msg;

      numBalanceMatches = 0;
      numBalanceMismatches = 0;

      mLogger.LogDebug("Checking balances");

      // check balances for each account namespace
      int numBalanceMismatchesForNamespace;
      int numBalanceMatchesForNamespace;
      string sAccountNameSpace;

      for (int i = 0; i < mAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = mAccountNameSpaces[i].ToString();
        numBalanceMismatchesForNamespace = 0;
        numBalanceMatchesForNamespace = 0;

        // step: get all balances to check
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__GET_ACCOUNTS_AND_BALANCES_TO_CHECK_WITH_EXTERNAL_AR_SYSTEM__"))
        {
            stmt.AddParam("%%NAME_SPACE%%", sAccountNameSpace);
            stmt.AddParam("%%ID_INTERVAL%%", context.UsageIntervalID);
            stmt.AddParam("%%ID_BILLGROUP%%", context.BillingGroupID);

            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                // loop to check mSetSize rows at a time
                while (true)
                {
                    //step: load mSetSize rows into xmlBalancesInMetraNet
                    int numRowsRead;
                    string xmlBalancesInMetraNet = reader.ReadToXml(@"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", "GetBalance", mSetSize, out numRowsRead, mDatabaseToInterfacePropertyMappings);

                    if (numRowsRead == 0)
                    {
                        break;
                    }

                    //step: call interface to get balance from A/R
                    // NOTE: the xml will also have an extra <Balance> element in the generated ARDocument.
                    // To strictly adhere to the interface that element should not occur and could be stripped out (eg XSL transform).
                    // Currently, there is no need for that, since the GreatPlains interface does not care about extra elements.

                    IMTARReader ARReader = new MTARReaderClass();
                    string xmlBalancesInAR = ARReader.GetBalances(xmlBalancesInMetraNet, mARConfigState);

                    //step: compare xmlBalancesInMetraNet against xmlBalancesInAR

                    //load up docs
                    MTXmlDocument docBalancesInMetraNet = new MTXmlDocument();
                    docBalancesInMetraNet.LoadXml(xmlBalancesInMetraNet);

                    MTXmlDocument docBalancesInAR = new MTXmlDocument();
                    docBalancesInAR.LoadXml(xmlBalancesInAR);

                    //for all nodes in docBalancesInMetraNet
                    XmlNodeList balanceNodes = docBalancesInMetraNet.SelectNodes("//GetBalance");
                    Debug.Assert(numRowsRead == balanceNodes.Count);

                    foreach (XmlNode balanceNode in balanceNodes)
                    {
                        //get account IDs and balance from MetraNet
                        string ExtAccountID = MTXmlDocument.GetNodeValueAsString(balanceNode, "./ExtAccountID");
                        decimal MetraNetBalance = MTXmlDocument.GetNodeValueAsDecimal(balanceNode, "./Balance");

                        //find balance for ExtAccountID in AR balance

                        //create XPath qry to search for balance node given ExtAccountID 
                        string qry = "//CurrentUnpostedBalance[../ExtAccountID=\"";
                        qry += ExtAccountID;
                        qry += "\"]";

                        XmlNode ARBalanceNode = docBalancesInAR.SelectSingleNode(qry);
                        if (ARBalanceNode == null)
                            throw new ARException("ExtAccountID '{0}' not found in XML doc returned by ARInterface", ExtAccountID);

                        Decimal ARBalance = Convert.ToDecimal(ARBalanceNode.InnerText);

                        // compare the balances
                        if (MetraNetBalance == ARBalance)
                        {
                            numBalanceMatchesForNamespace++;
                            mLogger.LogDebug(String.Format("Balance OK for account: '{0}' in AR system {2}, balance: {1}",
                              ExtAccountID, MetraNetBalance, sAccountNameSpace));
                        }
                        else
                        {
                            numBalanceMismatchesForNamespace++;
                            msg = String.Format("Balance mismatch for account: '{0}' in AR system {3}, MetraNet balance: {1}, AR balance: {2}",
                              ExtAccountID, MetraNetBalance, ARBalance, sAccountNameSpace);

                            //record in log and usm run history
                            mLogger.LogWarning(msg);
                            context.RecordWarning(msg);
                        }
                    }
                }
            }
        }

        numBalanceMatches += numBalanceMatchesForNamespace;
        numBalanceMismatches += numBalanceMismatchesForNamespace;
        msg = String.Format("Checking balances completed for AR system {1} with {0} balance mismatches", numBalanceMismatchesForNamespace, sAccountNameSpace);
        mLogger.LogDebug(msg);
        if (numBalanceMismatchesForNamespace > 0)
        {
          context.RecordWarning(msg);
        }
        else
        {
          context.RecordInfo(msg);
        }
      }

      msg = String.Format("Checking balances completed with {0} balance mismatches", numBalanceMismatches);
      mLogger.LogDebug(msg);
      if (numBalanceMismatches > 0)
      {
        context.RecordWarning(msg);
      }
      else
      {
        context.RecordInfo(msg);
      }


    }

    /// <remarks>Helper routine to generate xml from two datareaders<remarks>
    /// <param name="rowTagInner">"" if not provided</param>
    /// <param name="maxRows">0  if not provided</param>
    public virtual String ReadParentAndChildReadersToXml(IMTDataReader parentReader, IMTDataReader childReader, bool bHasChildren, String joinColumn, String rootTag, String rowTag, String rowTagInner, String childRootTag, String childRowTag, int maxRows, out int rowsRead, Dictionary<string, string> propertyNameMapping)
    {
      rowsRead = 0;

      System.Text.StringBuilder xml = new System.Text.StringBuilder();
      System.Text.StringBuilder childXml = null;
      xml.Append("<");
      xml.Append(rootTag);
      xml.Append(">");

      //Make sure the childReader has information and start the ball rolling
      bool MoreChildRows = false;
      MoreChildRows = childReader.Read();

      // read up to maxRows rows (if maxRows > 0)
      for (int numRows = 0; maxRows <= 0 || numRows < maxRows; numRows++)
      {
        if (!parentReader.Read())
          break;

        rowsRead++;

        //Generate the child xml if any
        //Get the join value from parent
        string joinValue = parentReader.GetString(joinColumn);
        childXml = new System.Text.StringBuilder();

        if (joinValue != null && joinValue.Length > 0)  //Darn it, where is the IsNullOrEmpty
        {
          //We are essentially peeking ahead, when the child reader joinValue changes then we know that
          //we are done reading child rows (since the parent and child MUST be sorted by the joinColumn)
          while (MoreChildRows && String.Compare(joinValue, childReader.GetString(joinColumn), true) == 0)
          {
            //Add this row to the child xml
            if (childXml.Length == 0)
            {
              //Append the child root node
              childXml.Append("<");
              childXml.Append(childRootTag);
              childXml.Append(">");
            }

            childXml.Append(childReader.ToXml(childRowTag, propertyNameMapping));

            if (!childReader.Read())
            {
              MoreChildRows = false;
            }
          }

          if (childXml.Length != 0)
          {
            //Append the child root node
            childXml.Append("</");
            childXml.Append(childRootTag);
            childXml.Append(">");
          }
        }

        if (rowTagInner.Length == 0)
          xml.Append(parentReader.ToXml(rowTag));
        else
        {
          xml.Append("<");
          xml.Append(rowTag);
          xml.Append(">");
          xml.Append(parentReader.ToXml(rowTagInner, propertyNameMapping, childXml.ToString()));

          xml.Append("</");
          xml.Append(rowTag);
          xml.Append(">");
        }
      }

      xml.Append("</");
      int pos;
      if ((pos = rootTag.IndexOf(' ')) != -1)
      {
        xml.Append(rootTag.Substring(0, pos));
      }
      else
      {
        xml.Append(rootTag);
      }
      xml.Append(">");

      return xml.ToString();
    }
  
  }
}

