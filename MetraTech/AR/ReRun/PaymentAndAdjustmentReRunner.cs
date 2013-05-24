using System;
using System.Xml;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.AR;
using MetraTech.AR.Adapters;
using MetraTech.DataAccess;
using MetraTech.Pipeline.ReRun;
using MetraTech.Xml;
using MetraTech.Interop.MTARInterfaceExec;

[assembly: GuidAttribute("E04984EC-400C-41a9-BA5A-F531B70439E0")]

namespace MetraTech.AR.ReRun
{
  [Guid("18665F94-2A0D-4407-A959-7F7929324294")]
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  public class PaymentAndAdjustmentReRunner : ServicedComponent, IReRunTask
  {
      [AutoComplete]
      public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
                                                  int rerunID, string rerunTableName, bool useDBQueues)
      {
          //TODO:Marc, Rudi -- we need to create a query with the tag "GET_EXPORTED_AR_ITEMS_FOR_RERUN_4.0"
          // that takes a table name, rather than the rerun id and does exactly the same
          // as the original query

          using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
          {
              Logger logger = new Logger("[PmtAdjReRun]");

              // step: see if rerun set contains any payments or ARAdjustments that have been exported
              logger.LogDebug("Checking for exported payments and AR adjustments");

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__GET_EXPORTED_AR_ITEMS_FOR_RERUN_DBQUEUES__"))
              {
                  stmt.AddParam("%%RERUN_TABLE_NAME%%", rerunTableName);

                  //loop over result and construct XML docs to query AR for 
                  int numExportedPayments = 0;
                  int numExportedARAdjustments = 0;
                  ARDocWriter paymentDoc = ARDocWriter.CreateWithARDocuments();
                  ARDocWriter ARAdjustmentDoc = ARDocWriter.CreateWithARDocuments();

                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      while (reader.Read())
                      {
                          int id = reader.GetInt32("ID");

                          //type is NULL for payments, "Credit" or "Debit" for adjustments
                          string type = "";
                          if (!reader.IsDBNull("Type"))
                              type = reader.GetString("Type");

                          if (type.Length == 0)
                          {
                              //append payment
                              string pmtIDPrefix = ARConfiguration.GetInstance().PaymentIDPrefix;
                              paymentDoc.WriteARDocumentStart("CanDeletePayment");
                              paymentDoc.WriteElementString("PaymentID", pmtIDPrefix + id.ToString());
                              paymentDoc.WriteARDocumentEnd();
                              numExportedPayments++;
                          }
                          else
                          {
                              //append AR adjustment
                              string adjIDPrefix = ARConfiguration.GetInstance().ARAdjustmentIDPrefix;
                              ARAdjustmentDoc.WriteARDocumentStart("CanDeleteAdjustment");
                              ARAdjustmentDoc.WriteElementString("AdjustmentID", adjIDPrefix + id.ToString());
                              ARAdjustmentDoc.WriteElementString("Type", type);
                              ARAdjustmentDoc.WriteARDocumentEnd();
                              numExportedARAdjustments++;
                          }
                      }
                  }

                  string xmlPayment = paymentDoc.GetXmlAndClose();
                  string xmlARAdjustment = ARAdjustmentDoc.GetXmlAndClose();

                  logger.LogDebug("Found {0} exported payments, {1} exported AR adjustments",
                    numExportedPayments, numExportedARAdjustments);

                  // step: see if ARItems can be backed out
                  if (numExportedPayments + numExportedARAdjustments > 0)
                  {
                      logger.LogDebug("Checking if exported AR items can be backed out");
                      int numNotBackoutablePayments = 0;
                      int numNotBackoutableARAdjustments = 0;

                      //create AR config state
                      IMTARConfig ARConfig = new MTARConfigClass();
                      object ARConfigState = ARConfig.Configure("");

                      //call AR interface and populate #NonBackOutable table
                      if (numExportedPayments > 0)
                      {
                          numNotBackoutablePayments = CheckARItemsForBackout(true, xmlPayment, rerunID, conn, ARConfigState, logger, rerunTableName, useDBQueues);
                      }

                      if (numExportedARAdjustments > 0)
                      {
                          numNotBackoutableARAdjustments = CheckARItemsForBackout(false, xmlARAdjustment, rerunID, conn, ARConfigState, logger, rerunTableName, useDBQueues);
                      }

                      logger.LogDebug("Marked {0} payments and {1} AR adjustments as \"not-backoutable\"",
                        numNotBackoutablePayments, numNotBackoutableARAdjustments);
                  }
              }
          }
      }

    [AutoComplete]
    public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
												int rerunID, string rerunTableName, bool useDBQueues)
    {

		Logger logger = new Logger("[PmtAdjReRun]");
		if (ARConfiguration.GetInstance().IsAREnabled)
		{
			logger.LogDebug("Backing out from AR system");

			//let the PaymentAndAdjustmentWriter do the work
			PaymentAndAdjustmentWriter writer = new PaymentAndAdjustmentWriter();
			int numItemsBackedOut = writer.ReverseForRerunID(rerunID, rerunTableName, useDBQueues, logger);

			logger.LogDebug("Backed out {0} items from AR", numItemsBackedOut);
		}
		else
			logger.LogDebug("AR not enabled - ignoring backout");
    }

    /// <summary>
    /// call AR interface and mark "non-backoutable" session in t_rerun_sessions
    /// </summary>
    /// <returns>number or items that cannot be backed out</returns>
    int CheckARItemsForBackout(bool isPayment, string xmlDoc, int rerunID, IMTConnection conn, object ARConfigState, Logger logger, string rerunTableName, bool useDBQueues)
    {
      //set up strings that differ for types
      string IDPrefix;
      string IDTag;
      string canDeleteTag;
      if (isPayment)
      { IDPrefix = ARConfiguration.GetInstance().PaymentIDPrefix;
        IDTag = "PaymentID";
        canDeleteTag = "CanDeletePayment";
      }
      else
      { IDPrefix = ARConfiguration.GetInstance().ARAdjustmentIDPrefix;
        IDTag = "AdjustmentID";
        canDeleteTag = "CanDeleteAdjustment";
      }

      
      string xmlResponse;
      IMTARReader ARReader = new MTARReaderClass();

      if (isPayment)
        xmlResponse = ARReader.CanDeletePayments(xmlDoc, ARConfigState);
      else
        xmlResponse = ARReader.CanDeleteAdjustments(xmlDoc, ARConfigState);

      //loop over response and update t_rerun_sessions
      // for items with Exists:true and CanDelete:false
      MTXmlDocument responseDoc = new MTXmlDocument();
      responseDoc.LoadXml(xmlResponse);

      int numNonBackoutableItems = 0;

      //loop over all CanDeleteItem nodes, writing to deleteDoc
      foreach (XmlNode node in responseDoc.SelectNodes("//" + canDeleteTag))
      {
        bool exists = MTXmlDocument.GetNodeValueAsBool(node, "Exists");
        bool canDelete = MTXmlDocument.GetNodeValueAsBool(node, "CanDelete");
        if (exists && ! canDelete) 
        {
          // mark session in t_rerun_sessions as "non-backoutable"
          // note: could select into a temp table and then do a bulk update if performance is critical
          //       Consider that bulk insert currently uses a different connection, making temp tables less useful.
          //       (Also there is an issue with repeated use of temp tables in a DTC txn)

          //extract session ID from prefixed ID
          string externalID = MTXmlDocument.GetNodeValueAsString(node, IDTag);
          if(!externalID.StartsWith(IDPrefix))
            throw new ARException("AR system returned invalid ID: {0}", externalID);
          
          string sessionID = externalID.Remove(0, IDPrefix.Length );

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__UPDATE_RERUN_FOR_NON_BACKOUTABLE_SESSION_DBQUEUES__"))
          {
              stmt.AddParam("%%RERUN_TABLE_NAME%%", rerunTableName);
              stmt.AddParam("%%ID_SESS%%", sessionID);
              stmt.ExecuteNonQuery();
          }

          numNonBackoutableItems ++;
        }
      }
      return numNonBackoutableItems;
    }
  }
}
