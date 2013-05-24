using System;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;
using System.Diagnostics;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;

namespace MetraTech.AR.Adapters
{
  /// <summary>
  /// COM+ object to do payment and adjustment work in transactions.
  /// used by PaymentAndAdjustmentAdapter and PaymentAndAdjustmentReRunner
  /// </summary>
	[ComVisible(true)]
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("904E2A45-02B0-4d50-BC04-D98551DED623")]
  public class PaymentAndAdjustmentWriter : ServicedComponent
  {
    [AutoComplete]
    public int ExportSet(ExportType expType, int setSize, string IDPrefix, string batchID, string accountNameSpace, string batchNameSpace, IRecurringEventRunContext context, object ARConfigState, Logger logger)
    {
      int numRowsRead = 0; 
      string populateQuery; //query to populate temp table
      string getQuery; //query to get temp table result
      string updateQuery; //query to update propagation state
      string xmlTag; //tag in AR xml document

      //set up strings that differ for types
      switch(expType)
      {
        case ExportType.PAYMENTS:
          populateQuery = "__POPULATE_PAYMENTS_TO_PROPAGATE__";
          getQuery = "__GET_PAYMENTS_TO_PROPAGATE__";
          updateQuery = "__UPDATE_PROPAGATED_PAYMENTS__";
          xmlTag = "CreatePayment";
          break;
        case ExportType.AR_ADJUSTMENTS:
          populateQuery = "__POPULATE_AR_ADJUSTMENTS_TO_PROPAGATE__";
          getQuery = "__GET_AR_ADJUSTMENTS_TO_PROPAGATE__";
          updateQuery = "__UPDATE_PROPAGATED_AR_ADJUSTMENTS__";
          xmlTag = "CreateAdjustment";
          break;
        case ExportType.PB_ADJUSTMENTS:
          populateQuery = "__POPULATE_PB_ADJUSTMENTS_TO_PROPAGATE__";
          getQuery = "__GET_PB_ADJUSTMENTS_TO_PROPAGATE__";
          updateQuery = "__UPDATE_PROPAGATED_PB_ADJUSTMENTS__";
          xmlTag = "CreateAdjustment";
          break;
        case ExportType.DELETED_PB_ADJUSTMENTS:
          return ExportSetOfDeletedPBAdj(setSize, IDPrefix, batchID, accountNameSpace, batchNameSpace, context, ARConfigState, logger);
        default:
          throw new ARException("unknown ExportType");
      }

      // use a connection that participates in the AR txn
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          logger.LogDebug("getting set of {0} to export to {1}", expType, accountNameSpace);

          //step: find chunks of unpropagated payments/adjustments
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", populateQuery))
          {
              stmt.AddParam("%%SET_SIZE%%", setSize);
              stmt.AddParam("%%ID_PREFIX%%", IDPrefix);
              stmt.AddParam("%%DEF_BATCH_ID%%", batchID);
              stmt.AddParam("%%ACC_NAME_SPACE%%", accountNameSpace);
              if (expType != ExportType.PB_ADJUSTMENTS)
                  stmt.AddParam("%%BATCH_NAME_SPACE%%", batchNameSpace);

              stmt.ExecuteNonQuery();

              stmt.ClearQuery();
              stmt.QueryTag = getQuery;
              string xml;
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  //step: convert rows to xml
                  xml = reader.ReadToXml(@"ARDocuments ExtNamespace='" + accountNameSpace + @"'", "ARDocument", xmlTag, 0, out numRowsRead, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
              }

              if (numRowsRead == 0)
              {
                  logger.LogDebug("no {0} found for export to {1}", expType, accountNameSpace);
              }
              else
              {
                  //step: Export to A/R
                  string msg = String.Format("exporting {0} {1} to {2}", numRowsRead, AdapterUtil.ToString(expType, numRowsRead != 1), accountNameSpace);
                  if (context != null)
                      context.RecordInfo(msg);
                  logger.LogDebug(msg);

                  IMTARWriter ARWriter = new MTARWriterClass();
                  if (expType == ExportType.PAYMENTS)
                  {
                      ARWriter.CreatePayments(xml, ARConfigState);
                  }
                  else
                  {
                      ARWriter.CreateAdjustments(xml, ARConfigState);
                  }

                  //step: Update propagation state
                  logger.LogDebug("setting ARBatchID");

                  stmt.ClearQuery();
                  stmt.QueryTag = updateQuery;
                  stmt.AddParam("%%BATCH_ID%%", batchID);
                  stmt.AddParam("%%ID_PREFIX%%", IDPrefix);

                  stmt.ExecuteNonQuery();
              }
          }
      }
      
      return numRowsRead;
    }

    [AutoComplete]
    /// <summary>
    /// reverse a set of AR items for a given batchID
    /// </summary>
    /// <returns>number of items who's export was reverse (includes items that do not exist in AR anymore)</returns>
    public int ReverseSet(ExportType expType, int setSize, string batchID, IRecurringEventRunContext context, string batchNameSpace, object ARConfigState, Logger logger)
    {
      int numRowsRead = 0; 

      //set up queryTag depending on expType
      string queryTag; 
      switch(expType)
      {
        case ExportType.PAYMENTS:
          queryTag = "__POPULATE_PAYMENTS_TO_REVERSE__";
          break;
        case ExportType.AR_ADJUSTMENTS:
          queryTag = "__POPULATE_AR_ADJUSTMENTS_TO_REVERSE__";
          break;
        case ExportType.PB_ADJUSTMENTS:
          queryTag = "__POPULATE_PB_ADJUSTMENTS_TO_REVERSE__";
          break;
        case ExportType.DELETED_PB_ADJUSTMENTS:
          return ReverseSetOfDeletedPBAdj(setSize, batchID, context, ARConfigState, logger);
        default:
          throw new ARException("unknown ExportType");
      }

      // use a connection that participates in the AR txn
      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        logger.LogDebug("getting set of {0} to reverse", expType);

        //step: find chunk of payments/adjustments to reverse and populate tmp_ARReverse temp table
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", queryTag))
        {
            stmt.AddParam("%%SET_SIZE%%", setSize);
            stmt.AddParam("%%AR_BATCH_ID%%", batchID);
            if (expType != ExportType.PB_ADJUSTMENTS)
                stmt.AddParam("%%BATCH_NAME_SPACE%%", batchNameSpace);

            stmt.ExecuteNonQuery();
        }

        // do the rest of the work based on the tmp_ARReverse temp table
        numRowsRead = ReverseFromTempTable(expType, conn, context, ARConfigState, logger);
      }
      return numRowsRead;
    }

    /// <summary>
    /// reverse AR items for a given rerunID
    /// </summary>
    /// <returns>number of items who's export was reversed</returns>
    /// </summary>
    [AutoComplete]
    public int ReverseForRerunID(int rerunID, string rerunTableName, bool useDBQueues, Logger logger)
    {
      int numItemsReversed = 0;

      //setup common objects
      string batchNameSpace = ARConfiguration.GetInstance().BatchNameSpace;

      IMTARConfig ARConfig = new MTARConfigClass();
      object ARConfigState = ARConfig.Configure("");

      // reverse one type at a time
      // (PB adjustments cannot be reversed in billing rerun)
      numItemsReversed += ReverseForRerunID(ExportType.PAYMENTS, rerunID, rerunTableName, useDBQueues, batchNameSpace, ARConfigState, logger);
      numItemsReversed += ReverseForRerunID(ExportType.AR_ADJUSTMENTS, rerunID, rerunTableName, useDBQueues, batchNameSpace, ARConfigState, logger);

      return numItemsReversed;
    }

    /// <summary>
    /// do the reversal for a particular ExpType, given a rerun ID
    /// </summary>
    /// <returns>number of items who's export was reversed</returns>
    int ReverseForRerunID(ExportType expType, int rerunID, string rerunTableName, bool useDBQueues, string batchNameSpace, object ARConfigState, Logger logger)
    {
      int numItemsReversed = 0;
      //create new queries that do exactly the same thing but take rerunTableName as input param
      string queryTag; 
      switch(expType)
      {
        case ExportType.PAYMENTS:
          queryTag = "__POPULATE_PAYMENTS_TO_REVERSE_FOR_RERUN__";
          break;
        case ExportType.AR_ADJUSTMENTS:
          queryTag = "__POPULATE_AR_ADJUSTMENTS_TO_REVERSE_FOR_RERUN__";
          break;
        default:
          throw new ARException("unsupported ExportType");
      }

      // use a connection that participates in the AR txn
      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        logger.LogDebug("getting {0} to reverse", expType);

        //step: find payments/adjustments to reverse and populate tmp_ARReverse temp table
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", queryTag))
        {
            stmt.AddParam("%%BATCH_NAME_SPACE%%", batchNameSpace);
            stmt.AddParam("%%RERUN_TABLE_NAME%%", rerunTableName);

            stmt.ExecuteNonQuery();
        }

        // do the rest of the work based on the tmp_ARReverse temp table
        numItemsReversed = ReverseFromTempTable(expType, conn, null, ARConfigState, logger);
      }
      return numItemsReversed;
    }

    int ExportSetOfDeletedPBAdj(int setSize, string IDPrefix, string batchID, string accountNameSpace, string batchNameSpace, IRecurringEventRunContext context, object ARConfigState, Logger logger)
    {
      int numAdjustmentsDeleted = 0; 
      int numAdjustmentsCompensated = 0; 

      using(IMTConnection conn = ConnectionManager.CreateConnection())
      {
        logger.LogDebug("getting set of deleted post bill adjustments to export to {0}", accountNameSpace);

        //step: find chunks of pb adjustments to delete
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__POPULATE_DELETED_PB_ADJUSTMENTS_TO_PROPAGATE__"))
        {
            stmt.AddParam("%%SET_SIZE%%", setSize);
            stmt.AddParam("%%ID_PREFIX%%", IDPrefix);
            stmt.AddParam("%%DESCRIPTION_PREFIX%%", ARConfiguration.GetInstance().CompensatingPostBillAdjustmentDescriptionPrefix);
            stmt.AddParam("%%DEF_BATCH_ID%%", batchID);
            stmt.AddParam("%%ACC_NAME_SPACE%%", accountNameSpace);
            stmt.ExecuteNonQuery();

            //step: check in AR which one can be deleted

            // create CanDelete xml doc
            stmt.ClearQuery();
            stmt.QueryTag = "__GET_DELETED_PB_ADJUSTMENTS_FOR_CAN_DELETE__";
            stmt.AddParam("%%ID_PREFIX%%", IDPrefix);

            int numRows;
            string xmlCanDeleteDoc;
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                //convert rows to xml
                xmlCanDeleteDoc = reader.ReadToXml(@"ARDocuments ExtNamespace='" + accountNameSpace + @"'", "ARDocument", "CanDeleteAdjustment", 0, out numRows, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
            }

            if (numRows == 0)
            {
                logger.LogDebug("no deleted post bill adjustments found in {0}", accountNameSpace);
                return 0; //done
            }

            string msg = String.Format("checking {0} {1} for deletability in {2}", numRows,
              AdapterUtil.ToString(ExportType.PB_ADJUSTMENTS, numRows != 1), accountNameSpace);
            if (context != null)
                context.RecordInfo(msg);
            logger.LogDebug(msg);

            //call A/R interface to CanDeleteAdjustments
            string xmlResponse;
            IMTARReader ARReader = new MTARReaderClass();
            xmlResponse = ARReader.CanDeleteAdjustments(xmlCanDeleteDoc, ARConfigState);

            //step: check CanDelete response docs and update ARDelAction field in tmp_PBAdjustments
            //      (needed for final update)
            //      Action 'N' = does not exist in AR, nothing to do
            //      Action 'D' = delete in AR
            //      Action 'C' = compensate in AR (create new adjustment)

            MTXmlDocument canDeleteDoc = new MTXmlDocument();
            canDeleteDoc.LoadXml(xmlResponse);

            //loop over all CanDeleteItem nodes, updating tmp_PBAdjustments
            foreach (XmlNode node in canDeleteDoc.SelectNodes("//CanDeleteAdjustment"))
            {
                string externalID = MTXmlDocument.GetNodeValueAsString(node, "AdjustmentID");
                if (!externalID.StartsWith(IDPrefix))
                    throw new ARException("AR system returned invalid ID: {0}", externalID);
                string adjID = externalID.Remove(0, IDPrefix.Length);

                bool exists = MTXmlDocument.GetNodeValueAsBool(node, "Exists");
                bool canDelete = MTXmlDocument.GetNodeValueAsBool(node, "CanDelete");

                string action;
                if (exists)
                    if (canDelete)
                        action = "D";
                    else
                        action = "C";
                else
                    action = "N";

                //warning if not exists
                if (action == "N")
                {
                    msg = String.Format("Not deleting {0}. Item does not exist in {1}.", externalID, accountNameSpace);
                    if (context != null)
                        context.RecordWarning(msg);
                    logger.LogWarning(msg);
                }

                //set action
                stmt.ClearQuery();
                stmt.QueryTag = "__UPDATE_DELETED_PB_ADJUSTMENTS_ACTION__";
                stmt.AddParam("%%ID%%", adjID);
                stmt.AddParam("%%ACTION%%", action);
                stmt.ExecuteNonQuery();
            }

            //step: get pb adjustments to delete (the ones that have not been posted)

            // create Delete xml doc
            stmt.ClearQuery();
            stmt.QueryTag = "__GET_DELETED_PB_ADJUSTMENTS_TO_DELETE_IN_AR__";
            stmt.AddParam("%%ID_PREFIX%%", IDPrefix);

            string xmlDeleteDoc;
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                //convert rows to xml
                xmlDeleteDoc = reader.ReadToXml(@"ARDocuments ExtNamespace='" + accountNameSpace + @"'", "ARDocument", "DeleteAdjustment", 0, out numAdjustmentsDeleted, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
            }

            if (numAdjustmentsDeleted > 0)
            {
                //step: call AR to delete
                msg = String.Format("deleting {0} non-posted {1} in {2}", numAdjustmentsDeleted,
                  AdapterUtil.ToString(ExportType.PB_ADJUSTMENTS, numAdjustmentsDeleted != 1), accountNameSpace);
                if (context != null)
                    context.RecordInfo(msg);
                logger.LogDebug(msg);

                IMTARWriter ARWriter = new MTARWriterClass();
                ARWriter.DeleteAdjustments(xmlDeleteDoc, ARConfigState);

                //step: delete batches that are now empty
                DeleteEmptyBatches(conn, "__GET_DELETED_PB_ADJUSTMENT_BATCHES_TO_DELETE_IN_AR__", accountNameSpace, context, ARConfigState, logger);
            }

            //step: get pb adjustments to compensate

            // create CreateAdjustment xml doc
            stmt.ClearQuery();
            stmt.QueryTag = "__GET_DELETED_PB_ADJUSTMENTS_TO_COMPENSATE_IN_AR__";
            stmt.AddParam("%%ID_PREFIX%%", ARConfiguration.GetInstance().CompensatingPostBillAdjustmentIDPrefix);

            string xmlCreateDoc;
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                //convert rows to xml
                xmlCreateDoc = reader.ReadToXml(@"ARDocuments ExtNamespace='" + accountNameSpace + @"'", "ARDocument", "CreateAdjustment", 0, out numAdjustmentsCompensated, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
            }

            if (numAdjustmentsCompensated > 0)
            {
                //step: call AR to create compensating adjustments
                msg = String.Format("compensating {0} posted {1} in {2}", numAdjustmentsCompensated,
                  AdapterUtil.ToString(ExportType.DELETED_PB_ADJUSTMENTS, numAdjustmentsCompensated != 1), accountNameSpace);
                if (context != null)
                    context.RecordInfo(msg);
                logger.LogDebug(msg);

                IMTARWriter ARWriter = new MTARWriterClass();
                ARWriter.CreateAdjustments(xmlCreateDoc, ARConfigState);
            }

            //step: Update propagation state (ARDelBatchID and ARDelAction)
            logger.LogDebug("setting ARDelBatchID and ARDelAction");

            stmt.ClearQuery();
            stmt.QueryTag = "__UPDATE_DELETED_PB_ADJUSTMENTS_STATE__";
            stmt.AddParam("%%BATCH_ID%%", batchID);
            stmt.ExecuteNonQuery();

        }
      }
      return numAdjustmentsDeleted + numAdjustmentsCompensated;
    }


    /// <summary>
    /// do the reversal for a particular ExpType, given a populated tmp_ARReverse temp table
    /// </summary>
    /// <returns>number of items who's export was reversed (includes items that do not exist in AR anymore)</returns>
    int ReverseFromTempTable(ExportType expType, IMTConnection conn, IRecurringEventRunContext context, object ARConfigState, Logger logger)
    {
      //set up strings that differ for types
      string IDPrefix;
      string IDTag;
      string canDeleteTag;
      string deleteTag;
      string getQuery;
      string updateQuery;
      
      switch(expType)
      {
        case ExportType.PAYMENTS:
          IDPrefix = ARConfiguration.GetInstance().PaymentIDPrefix;
          IDTag = "PaymentID";
          canDeleteTag = "CanDeletePayment";
          deleteTag = "DeletePayment";
          getQuery = "__GET_PAYMENTS_TO_REVERSE__";
          updateQuery = "__UPDATE_REVERSED_PAYMENTS__";
          break;
        case ExportType.AR_ADJUSTMENTS:
          IDPrefix = ARConfiguration.GetInstance().ARAdjustmentIDPrefix;
          IDTag = "AdjustmentID";
          canDeleteTag = "CanDeleteAdjustment";
          deleteTag = "DeleteAdjustment";
          getQuery = "__GET_ADJUSTMENTS_TO_REVERSE__";
          updateQuery = "__UPDATE_REVERSED_AR_ADJUSTMENTS__";
          break;
        case ExportType.PB_ADJUSTMENTS:
          IDPrefix = ARConfiguration.GetInstance().PostBillAdjustmentIDPrefix;
          IDTag = "AdjustmentID";
          canDeleteTag = "CanDeleteAdjustment";
          deleteTag = "DeleteAdjustment";
          getQuery = "__GET_ADJUSTMENTS_TO_REVERSE__";
          updateQuery = "__UPDATE_REVERSED_PB_ADJUSTMENTS__";
          break;
        default:
          throw new ARException("unknown ExportType");
      }

      // Start "for each company" processing loop.

      ArrayList arrAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;
      string    sAccountNameSpace;
      int       numItemsReversed = 0;

      for (int i = 0; i < arrAccountNameSpaces.Count; i++)
      {
          sAccountNameSpace = arrAccountNameSpaces[i].ToString();

          // step: find out which of the AR Items in the temp table can be deleted

          // create CanDelete xml doc
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", getQuery))
          {
              stmt.AddParam("%%ID_PREFIX%%", IDPrefix);
              stmt.AddParam("%%ACC_NAME_SPACE%%", sAccountNameSpace);
              string xmlCanDeleteDoc;
              int curItemsReversed = 0;
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  //convert rows to xml
                  xmlCanDeleteDoc = reader.ReadToXml(@"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", canDeleteTag, 0, out curItemsReversed, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
              }

              if (curItemsReversed == 0)
              {
                  logger.LogDebug("no {0} found to reverse in {1}", expType, sAccountNameSpace);
                  continue; //done
              }

              string msg = String.Format("checking {0} {1} in {2} for deletability", curItemsReversed,
                AdapterUtil.ToString(expType, curItemsReversed != 1), sAccountNameSpace);
              if (context != null)
                  context.RecordInfo(msg);
              logger.LogDebug(msg);

              //call A/R interface to CanDeletePayments

              string xmlResponse;

              IMTARReader ARReader = new MTARReaderClass();
              if (expType == ExportType.PAYMENTS)
              {
                  xmlResponse = ARReader.CanDeletePayments(xmlCanDeleteDoc, ARConfigState);
              }
              else
              {
                  xmlResponse = ARReader.CanDeleteAdjustments(xmlCanDeleteDoc, ARConfigState);
              }

              //step: check CanDelete response docs and create Delete doc for all items that exist.
              //      Log warning for non-existing items, fail if item cannot be deleted (posted).
              // A XSLT transform could work as well, but generation of errors, warnings, and numExistingItems
              // is easier and more efficient in good ole sequential programming.

              logger.LogDebug("verifying {0} in {1}", expType, sAccountNameSpace);

              MTXmlDocument canDeleteDoc = new MTXmlDocument();
              canDeleteDoc.LoadXml(xmlResponse);

              ARDocWriter deleteDoc = ARDocWriter.CreateWithARDocuments(sAccountNameSpace);

              int numExistingItems = 0;

              //loop over all CanDeleteItem nodes, writing to deleteDoc
              foreach (XmlNode node in canDeleteDoc.SelectNodes("//" + canDeleteTag))
              {
                  string ID = MTXmlDocument.GetNodeValueAsString(node, IDTag);
                  bool exists = MTXmlDocument.GetNodeValueAsBool(node, "Exists");
                  bool canDelete = MTXmlDocument.GetNodeValueAsBool(node, "CanDelete");
                  string adjustmentType = "";
                  if (expType != ExportType.PAYMENTS)
                      adjustmentType = MTXmlDocument.GetNodeValueAsString(node, "Type");

                  if (exists)
                  {
                      if (canDelete)
                      {
                          //add to deleteDoc
                          deleteDoc.WriteARDocumentStart(deleteTag);
                          deleteDoc.WriteElementString(IDTag, ID);
                          if (expType != ExportType.PAYMENTS)
                              deleteDoc.WriteElementString("Type", adjustmentType);
                          deleteDoc.WriteARDocumentEnd();
                          numExistingItems++;
                      }
                      else
                      { //can't delete posted items
                          throw new ARException("Cannot delete posted item: {0} in {1}", ID, sAccountNameSpace);
                      }
                  }
                  else
                  {
                      //log warning
                      msg = String.Format("Not deleting {0} in {1}. Item does not exist in AR system.", ID, sAccountNameSpace);
                      if (context != null)
                          context.RecordWarning(msg);
                      logger.LogWarning(msg);
                  }
              }

              string xmlDeleteDoc = deleteDoc.GetXmlAndClose();

              if (numExistingItems == 0)
              {
                  logger.LogDebug("none of the {0} in {1} to be reversed exists in AR", expType, sAccountNameSpace);
                  // still update propagation state for the items that do not exist in AR
              }
              else
              {
                  //step: call AR to delete
                  msg = String.Format("deleting {0} existing {1} from {2}", numExistingItems,
                    AdapterUtil.ToString(expType, numExistingItems != 1), sAccountNameSpace);
                  if (context != null)
                      context.RecordInfo(msg);
                  logger.LogDebug(msg);

                  IMTARWriter ARWriter = new MTARWriterClass();
                  if (expType == ExportType.PAYMENTS)
                  {
                      ARWriter.DeletePayments(xmlDeleteDoc, ARConfigState);
                  }
                  else
                  {
                      ARWriter.DeleteAdjustments(xmlDeleteDoc, ARConfigState);
                  }
              }

              //step: Update propagation state
              logger.LogDebug("setting ARBatchID to NULL");

              stmt.ClearQuery();
              stmt.QueryTag = updateQuery;
              stmt.ExecuteNonQuery();

              DeleteEmptyBatches(conn, "__GET_REVERSED_BATCHES__", sAccountNameSpace, context, ARConfigState, logger);

              numItemsReversed += curItemsReversed;
          }
      }

      // Finished "for each company" processing loop.

      return numItemsReversed;
    }

    /// <summary>
    /// Delete empty batches specified by running query called queryTag
    /// </summary>
    /// <returns>number of batches that were deleted (includes batches that do not exist in AR anymore)</returns>
    int DeleteEmptyBatches(IMTConnection conn, string queryTag, string sAccountNameSpace, IRecurringEventRunContext context, object ARConfigState, Logger logger)
    {
      // step: check for empty batches to be deleted
      logger.LogDebug("Checking for empty batches to be deleted for {0}", sAccountNameSpace);

      using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", queryTag))
      {
          if (queryTag == "__GET_REVERSED_BATCHES__")
              stmt.AddParam("%%ACC_NAME_SPACE%%", sAccountNameSpace);

          int numBatchesToCheck = 0;
          string xmlCanDeleteBatches;

          using (IMTDataReader reader = stmt.ExecuteReader())
          {
              //convert rows to xml
              xmlCanDeleteBatches = reader.ReadToXml(@"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", "CanDeleteBatch", 0, out numBatchesToCheck, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
          }

          if (numBatchesToCheck == 0)
          {
              logger.LogDebug("No empty batches to be deleted were found in {0}", sAccountNameSpace);
              return 0; //done
          }

          //call A/R interface 
          IMTARReader ARReader = new MTARReaderClass();
          string xmlResponse = ARReader.CanDeleteBatches(xmlCanDeleteBatches, ARConfigState);

          //step: check CanDelete response docs and create Delete doc
          //      for all batches that exist AND contain no more transactions (items)
          //      Log warning for non-existing batches, fail if batch cannot be deleted (posted).
          // A XSLT transform could work as well, but generation of errors, warnings, and numEmptyBatches
          // is easier and more efficient in good ole sequential programming.
          logger.LogDebug("verifying batches for {0}", sAccountNameSpace);

          MTXmlDocument canDeleteDoc = new MTXmlDocument();
          canDeleteDoc.LoadXml(xmlResponse);

          ARDocWriter deleteDoc = ARDocWriter.CreateWithARDocuments(sAccountNameSpace);

          int numEmptyBatches = 0;
          int numDeletedBatches = 0;

          //loop over all CanDeleteItem nodes, writing to deleteDoc
          foreach (XmlNode node in canDeleteDoc.SelectNodes("//CanDeleteBatch"))
          {
              string batchID = MTXmlDocument.GetNodeValueAsString(node, "BatchID");
              bool exists = MTXmlDocument.GetNodeValueAsBool(node, "Exists");
              bool canDelete = MTXmlDocument.GetNodeValueAsBool(node, "CanDelete");
              int numTransactions = MTXmlDocument.GetNodeValueAsInt(node, "NumTransactions");

              if (exists)
              {
                  if (numTransactions == 0)
                  {
                      if (canDelete)
                      {
                          //add to deleteDoc
                          deleteDoc.WriteARDocumentStart("DeleteBatch");
                          deleteDoc.WriteElementString("BatchID", batchID);
                          deleteDoc.WriteARDocumentEnd();
                          numEmptyBatches++;
                      }
                      else
                      { //can't delete posted batch
                          throw new ARException("Cannot delete posted batch: {0}", batchID);
                      }
                  }
                  else
                  {
                      logger.LogDebug("Batch {0} in {1} is not empty", batchID, sAccountNameSpace);
                  }
              }
              else
              {
                  //log warning
                  string msg = String.Format("Not deleting batch {0} in {1}. Batch does not exist in AR system.", batchID, sAccountNameSpace);
                  if (context != null)
                      context.RecordWarning(msg);
                  logger.LogWarning(msg);
                  numDeletedBatches++;
              }
          }

          string xmlDeleteDoc = deleteDoc.GetXmlAndClose();

          if (numEmptyBatches == 0)
          {
              logger.LogDebug("There were no empty batches deleted in {0}", sAccountNameSpace);
          }
          else
          {
              string msg = String.Format("deleting {0} empty batch{1} from {2}", numEmptyBatches,
                numEmptyBatches == 1 ? "" : "es", sAccountNameSpace);
              if (context != null)
                  context.RecordInfo(msg);
              logger.LogDebug(msg);

              //step: call AR to delete
              IMTARWriter ARWriter = new MTARWriterClass();
              ARWriter.DeleteBatches(xmlDeleteDoc, ARConfigState);
          }

          return numEmptyBatches + numDeletedBatches;
      }
    }

    int ReverseSetOfDeletedPBAdj(int setSize, string batchID, IRecurringEventRunContext context, object ARConfigState, Logger logger)
    {
      int numAdjustments = 0;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
          // step: get chunk of deleted PB adjustments to reverse (and populate tmp_ARReverse)
          logger.LogDebug("getting set of deleted post bill adjustments to reverse");

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\AR", "__POPULATE_DELETED_PB_ADJUSTMENTS_TO_REVERSE__"))
          {
              stmt.AddParam("%%SET_SIZE%%", setSize);
              stmt.AddParam("%%AR_BATCH_ID%%", batchID);
              stmt.ExecuteNonQuery();

              // Start "for each company" processing loop.

              ArrayList arrAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;

              string sIDPrefix;
              string sAccountNameSpace;
              int numDeletedAdjustmentsRecreated;
              int numCompensatedAdjustmentsReversed;

              sIDPrefix = ARConfiguration.GetInstance().PostBillAdjustmentIDPrefix;

              for (int i = 0; i < arrAccountNameSpaces.Count; i++)
              {
                  sAccountNameSpace = arrAccountNameSpaces[i].ToString();

                  numDeletedAdjustmentsRecreated = 0;
                  numCompensatedAdjustmentsReversed = 0;

                  // step: get the deleted PB adjustments that have been deleted in AR
                  //       and recreate the original PB adjustment in AR

                  stmt.ClearQuery();
                  stmt.QueryTag = "__GET_DELETED_PB_ADJUSTMENTS_TO_RECREATE__";
                  stmt.AddParam("%%ID_PREFIX%%", sIDPrefix);
                  stmt.AddParam("%%ACC_NAME_SPACE%%", sAccountNameSpace);
                  string xmlCreateDoc;
                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      //convert rows to xml
                      xmlCreateDoc = reader.ReadToXml(@"ARDocuments ExtNamespace='" + sAccountNameSpace + @"'", "ARDocument", "CreateAdjustment", 0, out numDeletedAdjustmentsRecreated, ARConfiguration.GetInstance().DatabaseToInterfacePropertyMappings);
                  }

                  if (numDeletedAdjustmentsRecreated > 0)
                  {
                      //call AR to recreate the adjustments
                      string msg = String.Format("recreating {0} {1} in {2}", numDeletedAdjustmentsRecreated,
                        AdapterUtil.ToString(ExportType.DELETED_PB_ADJUSTMENTS, numDeletedAdjustmentsRecreated != 1), sAccountNameSpace);
                      if (context != null)
                          context.RecordInfo(msg);
                      logger.LogDebug(msg);

                      IMTARWriter ARWriter = new MTARWriterClass();
                      ARWriter.CreateAdjustments(xmlCreateDoc, ARConfigState);
                  }

                  // step: delete compensating adjustments for deleted post bill adjustments
                  //      (by deleting whole batch)
                  // get number of compensated PB adjustments
                  stmt.ClearQuery();
                  stmt.QueryTag = "__GET_NUM_OF_COMPENSATED_DELETED_PB_ADJUSTMENTS_TO_REVERSE__";
                  stmt.AddParam("%%ACC_NAME_SPACE%%", sAccountNameSpace);
                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      reader.Read();
                      numCompensatedAdjustmentsReversed = reader.GetInt32(0);
                  }

                  if (numCompensatedAdjustmentsReversed > 0)
                  {
                      string msg = String.Format("deleting {0} compensating {1} in batch {2} from {3}", numCompensatedAdjustmentsReversed,
                        AdapterUtil.ToString(ExportType.PB_ADJUSTMENTS, numCompensatedAdjustmentsReversed != 1),
                        batchID, sAccountNameSpace);
                      if (context != null)
                          context.RecordInfo(msg);
                      logger.LogDebug(msg);

                      bool batchExisted;
                      if (!AdapterUtil.DeleteBatch(batchID, sAccountNameSpace, ARConfigState, out batchExisted))
                      {
                          //Log Warning
                          if (batchExisted)
                              msg = String.Format("Unable to delete AR Batch {0} from {1}. The batch exists but cannot be deleted, most likely because it has already been posted.", batchID, sAccountNameSpace);
                          else
                              msg = String.Format("Batch {0} does not exist in {1}", batchID, sAccountNameSpace);

                          if (context != null)
                              context.RecordWarning(msg);
                          logger.LogWarning(msg);
                      }
                  }

                  numAdjustments += numDeletedAdjustmentsRecreated + numCompensatedAdjustmentsReversed;
              }

              //step: Update propagation state (ARDelBatchID and ARDelAction)
              logger.LogDebug("setting ARDelBatchID and ARDelAction to NULL");

              stmt.ClearQuery();
              stmt.QueryTag = "__UPDATE_REVERSED_DELETED_PB_ADJUSTMENTS_STATE__";
              stmt.ExecuteNonQuery();
          }
      }

      return numAdjustments; 
    }
  }
}
