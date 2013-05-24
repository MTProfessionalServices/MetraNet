/**************************************************************************
* Copyright 2010 by MetraTech
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
using System.Data;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.Text;
//MetraTech
using Core.Core;
using MetraTech.Adjustments;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com_Dispute;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DataAccess;
using MetraTech.DomainModel.ProductCatalog;
using PC = MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using Auth = MetraTech.Interop.MTAuth;
using MetraTech.Interop.QueryAdapter;
// BME
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
// Services
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Debug.Diagnostics;

namespace MetraTech.Core.Services
{
  // NOTE: You can use the "Rename" command on the "Refactor" menu to 
  // change the interface name "IDisputeService" in both code and config file together.
  [ServiceContract]
  public interface IDisputeService
  {

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetDisputes(ref MTList<Dispute> disputes);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetDispute(DisputeBusinessKey key,
                    out Dispute dispute);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveDispute(ref Dispute dispute);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdjustmentsForDispute(DisputeBusinessKey key,
                                  ref MTList<AdjustmentBase> adjustments);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddInvoiceAdjustment(DisputeBusinessKey key,
                              ref InvoiceAdjustment adjustment);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdjustablePITemplates(LanguageCode language,
                                  out List<AdjustablePITemplate> adjustableTemplates);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetAdjustmentTypesForTemplate(PCIdentifier piTemplate,
                                       LanguageCode language,
                                       out List<AdjustmentTemplateMetaData> adjustmentTypes);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CalculateChargeAdjustment(DisputeBusinessKey key,
                                   ChargeAdjustment adjustment,
                                   AdjustmentInput inputs,
                                   out AdjustmentOutput outputs);


    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void AddChargeAdjustment(DisputeBusinessKey key,
                             ChargeAdjustment adjustment,
                             AdjustmentInput inputs,
                             out AdjustmentOutput outputs);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SubmitForApproval(DisputeBusinessKey key);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ApproveDispute(DisputeBusinessKey key);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RejectDispute(DisputeBusinessKey key);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void ReverseApprovedDispute(DisputeBusinessKey key);

  } // end IDisputeService Interface Definition

  // NOTE: You can use the "Rename" command on the "Refactor" menu to
  // change the class name "DisputeService" in both code and config file together.
  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class DisputeService : CMASServiceBase, IDisputeService
  {
    #region Members
    private Logger mLogger = new Logger("[DisputeService]");
    #endregion

    #region Public Methods

    //[OperationCapability("Retrieve List of All Disputes")]
    public void GetDisputes(ref MTList<Dispute> disputes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetDisputes"))
      {

        // Create empty Temp MTList
        MTList<DataObject> tmpDisputeList = new MTList<DataObject>();

        try
        {
          // Set Default Properties from passed in object
          tmpDisputeList.PageSize = disputes.PageSize;
          tmpDisputeList.CurrentPage = disputes.CurrentPage;
          tmpDisputeList.Filters.AddRange(disputes.Filters);
          tmpDisputeList.SortCriteria.AddRange(disputes.SortCriteria);

          // Load All Dispute instances from Repository
          tmpDisputeList =
              StandardRepository.Instance.LoadInstances(new DisputeBusinessKey().EntityFullName,
                                                        tmpDisputeList);

          foreach (DataObject obj in tmpDisputeList.Items)
          {
            // Add object to MTList
            disputes.Items.Add(((Dispute)obj));
          }

          disputes.TotalRows = tmpDisputeList.TotalRows;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in GetDisputes(): ", e);

          throw new MASBasicException("Error in DisputeService:GetDisputes(). Unable to Retrieve Disputes");
        }
      }
    } // end GetDisputes(..)


    //[OperationCapability("Get Dispute")]
    public void GetDispute(DisputeBusinessKey key,
                           out Dispute dispute)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetDispute"))
      {
        mLogger.LogDebug("GetDispute()");
        dispute = new Dispute();
        try
        {
          //Attempt to Load Disput entity from the Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in GetDispute(): ", e);

          throw new MASBasicException("Error in DisputeService:GetDispute(). Unable to Retrieve Dispute");
        }
      }
    } // end GetDispute(..)

    //[OperationCapability("Save Specified Dispute entity")]
    public void SaveDispute(ref Dispute dispute)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveDispute"))
      {
        mLogger.LogDebug("SaveDispute()");

        // Hold status from caller
        DisputeStatus inputStatus = dispute.status;

        // Check for a Business Key...if none..newly created dispute object
        DisputeBusinessKey key = dispute.DisputeBusinessKey;

        try
        {
          if (System.Guid.Empty == key.InternalKey)
          {
            // New Dispute Entity...set status to "Pending"
            dispute.status = DisputeStatus.Pending;

            dispute.Save();
          }
          else
          {
            // Attempt to Load Disput entity from the Repository
            dispute =
                StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

            // Was specified dispute in Repository?
            if (dispute != null)
            {
              // Verify status is same...if not throw exception
              if (dispute.status != inputStatus)
              {
                mLogger.LogError("SaveDispute(): Dispute Status Mismatch");

                throw new MASBasicException("DisputeService:SaveDispute(). Dispute Status Mismatch");
              }
            } // end if...found dispute in repository
            else
            {
              // New Dispute Entity...set status to "Pending"
              dispute.status = DisputeStatus.Pending;
            } // End else...Entity NOT found in Repository

            // All set....save Dispute Instance
            dispute.Save();
          }  // end else.....Dispute Found in Repository         
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception ex)
        {
          mLogger.LogException("SaveDispute(): Error Saving Disput Entity: ", ex);

          throw new MASBasicException("DisputeService:SaveDispute(). Error Saving Disput Entity");
        }
      }
    } // end SaveDispute(..)

    //[OperationCapability("Retrieve adjustments for the specified Dispute entity")]
    public void GetAdjustmentsForDispute(DisputeBusinessKey key,
                                         ref MTList<AdjustmentBase> adjustments)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdjustmentsForDispute"))
      {
        mLogger.LogDebug("GetAdjustmentsForDispute()");

        Dispute dispute = new Dispute();

        // temp list to hold results
        MTList<ChargeAdjustment> chgAdjList = new MTList<ChargeAdjustment>();
        MTList<InvoiceAdjustment> invAdjList = new MTList<InvoiceAdjustment>();

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

          if (dispute == null)
          {
            mLogger.LogError("GetAdjustmentsForDispute() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:GetAdjustmentsForDispute().Dispute NOT Retrieved from DB");
          }

          // Set Default MTList values supplied by client
          chgAdjList.PageSize = adjustments.PageSize;
          chgAdjList.CurrentPage = adjustments.CurrentPage;
          chgAdjList.Filters.AddRange(adjustments.Filters);
          chgAdjList.SortCriteria.AddRange(adjustments.SortCriteria);

          // Get all the Adjustments
          StandardRepository.Instance.LoadInstancesFor<Dispute, ChargeAdjustment>(dispute.Id, ref chgAdjList);
          InvoiceAdjustment invAdj =
              StandardRepository.Instance.LoadInstanceFor<Dispute, InvoiceAdjustment>(dispute.Id);

          // Is there an Invoice Adjusmtent
          if (invAdj != null)
          {
            adjustments.Items.Add(invAdj);
            adjustments.TotalRows = 1;
          }
          else
          {
            // If values returned...copy to returned list
            adjustments.TotalRows = chgAdjList.TotalRows;
            if (chgAdjList.TotalRows > 0)
            {
              // move adjustment items to the returned list 
              foreach (AdjustmentBase adjust in chgAdjList.Items)
              {
                adjustments.Items.Add((adjust));
              }
            }
            else
            {
              adjustments = null;
            } // end else....No ChargeAdjustments
          } // end else...process Charge Adjustments
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in GetAdjustmentsForDispute(): ", e);

          throw new MASBasicException("Error in DisputeService:GetAdjustmentsForDispute(). Unable to Retrieve Dispute List");

        }
      }
    } // End GetAdjustmentsForDispute(...)


    //[OperationCapability("Adds a Miscellaneous adjustment to a Dispute entity")]
    public void AddInvoiceAdjustment(DisputeBusinessKey key,
                                     ref InvoiceAdjustment adjustment)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddInvoiceAdjustment"))
      {
        mLogger.LogDebug("AddInvoiceAdjustment():");

        Dispute dispute = null;

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
          if (null == dispute)
          {
            mLogger.LogError("AddInvoiceAdjustment() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:AddInvoiceAdjustment().Dispute NOT Retrieved from DB");
          }

          if (dispute.status != DisputeStatus.Pending)
          {
            mLogger.LogError("AddInvoiceAdjustment() Dispute Status NOT Pending");
            throw new MASBasicException("Error in DisputeService:AddInvoiceAdjustment(). Dispute Status NOT Pending");
          }

          dispute.status = DisputeStatus.Pending;

          adjustment.Save();

          // Assign the relationship for this adjustment to the dispute
          dispute.InvoiceAdjustment = (InvoiceAdjustment)adjustment;

          // Save to Repository with Relationship
          dispute.Save();

          // Meter CreditRequest.
          SubmitCreditRequest credReq = new SubmitCreditRequest();

          // Fill DS
          credReq.fillDS(dispute);

          credReq.Run();
          credReq.Close();
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("AddInvoiceAdjustment(): Exception ", e);

          throw new MASBasicException("Error in DisputeService:AddInvoiceAdjustment(). Unable to Add Invoice");
        }
      }
    } // End AddInvoiceAdjustment(...)


    //[OperationCapability("Retrieves a list of adjustable PI templates")]
    public void GetAdjustablePITemplates(LanguageCode language,
                                         out List<AdjustablePITemplate> adjustableTemplates)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdjustablePITemplates"))
      {
        mLogger.LogDebug("GetAjustablePITemplates()");

        // Get Query
        IMTQueryAdapter qa = new MTQueryAdapter();
        qa.Init("Queries\\DisputeService");
        qa.SetQueryTag("__LOAD_ADJUSTABLE_TEMPLATES__");
        string sGetPITemplateQuery = qa.GetQuery();
        mLogger.LogError("GetAjustablePITemplates() qury  " + sGetPITemplateQuery);

        adjustableTemplates = new List<AdjustablePITemplate>();

        // Convert LanguageCode to ID
        MetraTech.Localization.LanguageList languages =
            new MetraTech.Localization.LanguageList();
        int languageID = languages.GetLanguageID(language.ToString());

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTPreparedStatement prepStmt =
                conn.CreatePreparedStatement(sGetPITemplateQuery))
            {

              // Add Language Parameter.
              prepStmt.AddParam(MTParameterType.Integer, languageID);

              // Execute Reader, to grab the data.
              using (IMTDataReader reader = prepStmt.ExecuteReader())
              {

                // Loop results to populate list which is returned to client
                while (reader.Read())
                {
                  AdjustablePITemplate adjPITempObj = new AdjustablePITemplate();

                  // Populate Object
                  adjPITempObj.ID = Convert.ToInt32(reader.GetValue("id_template"));
                  adjPITempObj.Name = reader.GetValue("nm_name").ToString();
                  adjPITempObj.DisplayName = reader.GetValue("nm_display_name").ToString();

                  // All set add to List returned to client
                  adjustableTemplates.Add(adjPITempObj);
                }
              } // end Using Reader
            } // end Using Statement
          } // end Using Connection
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in GetAdjustablePITemplates(): ", e);

          throw new MASBasicException("Error in DisputeService:GetAdjustablePITemplates(). Unable to Retrieve PI Templates");

        }
      }
    } // end GetAdjustablePITemplates(...)

    //[OperationCapability("Retrieves metadata for configured adjustement types for PI templates")]
    public void GetAdjustmentTypesForTemplate(PCIdentifier piTemplate,
                                              LanguageCode language,
                                              out List<AdjustmentTemplateMetaData> adjustmentTypes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetAdjustmentTypesForTemplate"))
      {
        // Get Query
        IMTQueryAdapter qa = new MTQueryAdapter();
        qa.Init("Queries\\DisputeService");
        qa.SetQueryTag("__GET_ADJUSTMENT_TYPES_FOR_TEMPLATE__");
        string sGetPITemplateQuery = qa.GetQuery();

        // Convert LanguageCode to ID
        MetraTech.Localization.LanguageList languages =
            new MetraTech.Localization.LanguageList();
        int languageID = languages.GetLanguageID(language.ToString());

        Dictionary<int, AdjustmentTemplateMetaData> tempMap =
                        new Dictionary<int, AdjustmentTemplateMetaData>();

        adjustmentTypes = new List<AdjustmentTemplateMetaData>();

        // Load the necessary Assembly for the generated classes which will
        // be used to create the appropriate AdjustmentInput instance.
        System.Reflection.Assembly assembly =
            System.Reflection.Assembly.Load("MetraTech.DomainModel.ProductCatalog.Generated");


        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement prepStmt =
              conn.CreatePreparedStatement(sGetPITemplateQuery))
          {
            // Make sure there is 3 resultSets.
            prepStmt.SetResultSetCount(3);

            // Add Language Parameter.
            prepStmt.AddParam("langCode", MTParameterType.Integer, languageID);
            prepStmt.AddParam("templateID", MTParameterType.Integer, piTemplate.ID.Value);

            // Execute Reader, to grab the data.
            using (IMTDataReader reader = prepStmt.ExecuteReader())
            {
              // Loop results to populate list which is returned to client
              while (reader.Read())
              {
                AdjustmentTemplateMetaData tempMD = new AdjustmentTemplateMetaData();

                // Populate Object
                tempMD.ID = Convert.ToInt32(reader.GetValue("AdjustmentID"));
                tempMD.Name = reader.GetValue("Name").ToString();
                tempMD.DisplayName = reader.GetValue("DisplayName").ToString();
                tempMD.Description = reader.GetValue("Description").ToString();

                // Get AdjustmentKind and translate
                int kind = Convert.ToInt32(reader.GetValue("AdjustmentKind"));
                AdjustmentKind k = (AdjustmentKind)kind;
                tempMD.Kind = k;

                // Get Bulk value and translate to bool
                string isBulk = reader.GetValue("SupportsBulk").ToString();
                if (isBulk.Equals("N"))
                  tempMD.SupportsBulk = false;
                else
                  tempMD.SupportsBulk = true;


                // Create specific instance of Inputs
                string sInputClass = "MetraTech.DomainModel.ProductCatalog." + tempMD.Name + "Inputs";
                System.Type t = assembly.GetType(sInputClass);
                // Verify a type was present...if not, do NOT populate the Dictionary
                if (t != null)
                {
                  tempMD.RequiredInputs =
                      (AdjustmentInput)System.Activator.CreateInstance(t);
                }
                else
                {
                  mLogger.LogInfo("GetAdjustmentTypesForTemplate() Input Class Does NOT Exist " + sInputClass);
                  continue;  // Do not add to Map, so go grab the next entry.
                }

                // Create RC List
                tempMD.ReasonCodes = new List<AdjustmentReasonCode>();

                // All set add to Map based on the ID Key.
                tempMap.Add(tempMD.ID, tempMD);

              } // end while...1st resultset

              // Get Next Record in the ResultSet
              reader.NextResult();
              while (reader.Read())
              {
                // Retrieve Values
                int ID = Convert.ToInt32(reader.GetValue("AdjustmentID"));
                int propID = Convert.ToInt32(reader.GetValue("ID"));
                string Name = reader.GetValue("Name").ToString();
                string DisplayName = reader.GetValue("DisplayName").ToString();

                // If value is in the map...add the AdjustmentInstance to the value stored
                // in the value of the map for the ID key.
                if (tempMap.ContainsKey(ID))
                {
                  AdjustmentTemplateMetaData md =
                      new AdjustmentTemplateMetaData();

                  tempMap.TryGetValue(ID, out md);

                  // Build Display name property string
                  string propName = Name + "DisplayNames";

                  // Verify Property Exists
                  System.Reflection.PropertyInfo prop = md.RequiredInputs.GetProperty(propName);
                  if (prop == null)
                  {
                    mLogger.LogInfo("GetAdjustmentTypesForTemplate() Property Does NOT Exist " + propName);
                    continue;
                  }

                  Dictionary<LanguageCode, string> dict = (Dictionary<LanguageCode, string>)
                      md.RequiredInputs.GetValue(propName);

                  dict.Add(language, DisplayName);

                  md.RequiredInputs.SetValue(propName, dict);
                }
              } // end while...2nd resultset


              // Get Next Record in the ResultSEt
              reader.NextResult();
              while (reader.Read())
              {
                AdjustmentReasonCode adjRC = new AdjustmentReasonCode();

                // Populate Values
                adjRC.ID = Convert.ToInt32(reader.GetValue("AdjustmentID"));
                adjRC.Name = reader.GetValue("Name").ToString();
                adjRC.DisplayName = reader.GetValue("DisplayName").ToString();
                adjRC.Description = reader.GetValue("Description").ToString();

                // If value is in the map...add the AdjustmentReasonCode to collection
                // property stored in the value of the map for the ID key.
                if (tempMap.ContainsKey(adjRC.ID))
                {
                  tempMap[adjRC.ID].ReasonCodes.Add(adjRC);
                }
              } // end while...3rd resultset

            } // end using Reader
          } // end using Statement
        } // end Using Connection

        // AllSet Copy Map contents to List to be returned to the caller
        if (tempMap.Count > 0)
        {
          foreach (AdjustmentTemplateMetaData tempMD in tempMap.Values)
          {
            adjustmentTypes.Add(tempMD);
          }
        } // end if...copy to output list
        else
        {
          adjustmentTypes = null;
        }
      }
    }

    //[OperationCapability("Calculates Charges after Adjustment")]
    public void CalculateChargeAdjustment(DisputeBusinessKey key,
                                          ChargeAdjustment adjustment,
                                          AdjustmentInput inputs,
                                          out AdjustmentOutput outputs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CalculateChargeAdjustment"))
      {
        mLogger.LogDebug("CalculateChargeAdjustment()");

        outputs = null;

        Dispute dispute;

        PC.MTProductCatalog mPC = new PC.MTProductCatalogClass();
        AdjustmentCatalog adjCatalog = new AdjustmentCatalog();

        MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
        PC.IMTSessionContext ctx =
            (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

        adjCatalog.Initialize(ctx);

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

          if (null == dispute)
          {
            mLogger.LogError("CalculateChargeAdjustment() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:CalculateChargeAdjustment().Dispute NOT Retrieved from DB");
          }

          //Load Adjustment type using the Catalog
          var adjType = adjCatalog.GetAdjustmentType(adjustment.AdjustmentType);
          if (adjType == null)
          {
            mLogger.LogError("CalculateChargeAdjustment()  NOTYPE!!");
          }

          // Get Session Intances
          var mtListSessions = new MTList<ChargeAdjustmentSession>();

          StandardRepository.Instance.LoadInstancesFor<ChargeAdjustment, ChargeAdjustmentSession>(adjustment, ref mtListSessions);

          // Create TransactionSet using the ChargeAdjustment Sessions
          MetraTech.Interop.GenericCollection.IMTCollection sessions =
              new MetraTech.Interop.GenericCollection.MTCollectionClass();

          for (int i = 0; i < mtListSessions.TotalRows; i++)
          {
            sessions.Add(mtListSessions.Items[i].SessionId);
          }

          IAdjustmentTransactionSet transSet =
              adjType.CreateAdjustmentTransactions(sessions);

          // Required
          transSet.ReasonCode = new MetraTech.Adjustments.ReasonCode();
          transSet.ReasonCode.ID = adjustment.ReasonCode.Value;

          // Set Inputs Parameter
          transSet.Inputs = (MetraTech.Interop.MTProductCatalog.IMTProperties)inputs;

          // Allset...calculate the adjustments
          transSet.CalculateAdjustments(null);

          // Build the instance name
          string sType = "MetraTech.DomainModel.ProductCatalog." +
              getInstanceName(adjustment.AdjustmentType) + "Outputs";

          // Load the necessary Assemblye for the generated classes
          System.Reflection.Assembly assembly =
              System.Reflection.Assembly.Load("MetraTech.DomainModel.ProductCatalog.Generated");

          // Get specified Type from the Adjustment.
          System.Type t = assembly.GetType(sType);

          outputs = System.Activator.CreateInstance(t) as AdjustmentOutput;

          //TODO  Error handling for Calculation

          foreach (IMTProperty prop in transSet.Outputs)
          {
            try
            {
              outputs.SetValue(prop.Name, prop.Value);
            }
            catch (ApplicationException)
            {
              // Property Name, not found so log and continue
              mLogger.LogInfo("CalculateChargeAdjustment() Mismatch Propert Name " + prop.Name.ToString());
              continue;
            }
          } // end foreach(..)
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in CalculateChargeAdjustment(): ", e);

          throw new MASBasicException("Error in DisputeService:CalculateChargeAdjustment(). Unable to Calculate Charge Adjustment");
        }
      }
    } // end CalculateChargeAdjustment(...)

    //[OperationCapability("Add a charge level adjustment to a Dispute")]
    public void AddChargeAdjustment(DisputeBusinessKey key,
                                    ChargeAdjustment adjustment,
                                    AdjustmentInput inputs,
                                    out AdjustmentOutput outputs)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("AddChargeAdjustment"))
      {
        mLogger.LogDebug("AddChargeAdjustment()");

        outputs = null;
        Dispute dispute;

        PC.MTProductCatalog mPC = new PC.MTProductCatalogClass();
        AdjustmentCatalog adjCatalog = new AdjustmentCatalog();

        MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
        PC.IMTSessionContext ctx =
            (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

        adjCatalog.Initialize(ctx);

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

          if (null == dispute)
          {
            mLogger.LogError("AddChargeAdjustment() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:AddChargeAdjustment().Dispute NOT Retrieved from DB");
          }

          //Load Adjustment type using the Catalog
          var adjType = adjCatalog.GetAdjustmentType(adjustment.AdjustmentType);
          if (adjType == null)
          {
            mLogger.LogError("AddChargeAdjustment()  NOTYPE!!");
          }

          // Get Session Intances
          var mtListSessions = new MTList<ChargeAdjustmentSession>();

          StandardRepository.Instance.LoadInstancesFor<ChargeAdjustment, ChargeAdjustmentSession>(adjustment, ref mtListSessions);

          // Create TransactionSet using the ChargeAdjustment Sessions
          MetraTech.Interop.GenericCollection.IMTCollection sessions =
              new MetraTech.Interop.GenericCollection.MTCollectionClass();

          for (int i = 0; i < mtListSessions.TotalRows; i++)
          {
            sessions.Add(mtListSessions.Items[i].SessionId);
          }

          IAdjustmentTransactionSet transSet =
              adjType.CreateAdjustmentTransactions(sessions);

          // Required
          transSet.ReasonCode = new MetraTech.Adjustments.ReasonCode();
          transSet.ReasonCode.ID = adjustment.ReasonCode.Value;

          // Set Inputs Parameter
          transSet.Inputs = (MetraTech.Interop.MTProductCatalog.IMTProperties)inputs;

          // Allset...calculate the adjustments
          transSet.CalculateAdjustments(null);
          // Build the instance name
          string sType = "MetraTech.DomainModel.ProductCatalog." +
              getInstanceName(adjustment.AdjustmentType) + "Outputs";

          // Load the necessary Assemblye for the generated classes
          System.Reflection.Assembly assembly =
              System.Reflection.Assembly.Load("MetraTech.DomainModel.ProductCatalog.Generated");

          // Get specified Type from the Adjustment.
          System.Type t = assembly.GetType(sType);

          outputs = System.Activator.CreateInstance(t) as AdjustmentOutput;

          //TODO  Error handling for Calculation

          foreach (IMTProperty prop in transSet.Outputs)
          {
            try
            {
              outputs.SetValue(prop.Name, prop.Value);
            }
            catch (ApplicationException)
            {
              // Property Name, not found so log and continue
              mLogger.LogInfo("AddChargeAdjustment() Mismatch Propert Name " + prop.Name.ToString());
              continue;
            }
          } // end foreach(..)

          // Save Adjustment calculations           
          transSet.SaveAdjustments(adjustment);

          // Save back to repository
          adjustment.Save();
          dispute.Save();
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in AddChargeAdjustment: ", e);

          throw new MASBasicException("Error in DisputeService:AddChargeAdjustment(). Unable to Add Charge Adjustment");
        }
      }
    }  // End AddChargeAdjustment(...)


    //[OperationCapability("Starts the approval process for approval of dispute")]
    public void SubmitForApproval(DisputeBusinessKey key)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SubmitForApproval"))
      {
        mLogger.LogDebug("SubmitForApproval()");

        Dispute dispute;

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
          if (null == dispute)
          {
            mLogger.LogError("SubmitForApproval() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:SubmitForApproval().Dispute NOT Retrieved from DB");
          }

          // Must be in correct State
          if (dispute.status != DisputeStatus.Pending)
          {
            mLogger.LogError("SubmitForApproval(): Dispute enity NOT Pending, Submit For Approval Dispute Failed");

            throw new MASBasicException("Error in DisputeService:SubmitForApproval().Submit For Approval Dispute Failed");
          }

          // Verify MetraAR is installed
          if (isARAvail())
          {
            // Verify invoiceID
            if (!dispute.invoiceId.HasValue)
            {
              mLogger.LogError("SubmitForApproval(): NO InvoiceID Specified");

              throw new MASBasicException("DisputeService:SubmitForApproval() NO InvoiceID Specified");
            }

            if (isUserCapable())
            {
              ApproveDispute(key);
            }
            else
            {
              mLogger.LogError("SubmitForApproval(): User Lacking Creditials");

              throw new MASBasicException("DisputeService:SubmitForApproval() User Lacking Creditials");
            }
          }
          else
          {
            mLogger.LogError("SubmitForApproval(): MetraAR NOT Installed");

            throw new MASBasicException("DisputeService:SubmitForApproval() MetraAR NOT Installed");
          }
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in SubmitForApproval: ", e);

          throw new MASBasicException("Error in DisputeService:SubmitForApproval(). Submit Dispute for Approval Failed");

        }
      }
    }


    //[OperationCapability("Approves a pending dispute")]
    public void ApproveDispute(DisputeBusinessKey key)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ApproveDispute"))
      {
        mLogger.LogDebug("ApproveDispute()");

        Dispute dispute;

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
          if (null == dispute)
          {
            mLogger.LogError("ApproveDispute() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:ApproveDispute().Dispute NOT Retrieved from DB");
          }

          // Must be in correct State
          if (dispute.status != DisputeStatus.Pending)
          {
            mLogger.LogError("ApproveDispute(): Dispute enity NOT Pending, Reject Dispute Failed");

            throw new MASBasicException("Error in DisputeService:ApproveDispute(). Reject Dispute Failed");
          }

          // Get adjustments from repository...Try Invoice 1st
          InvoiceAdjustment invAdj =
              StandardRepository.Instance.LoadInstanceFor<Dispute, InvoiceAdjustment>(dispute.Id);

          // Is there an Invoice Adjusmtent
          if (invAdj != null)
          {
            mLogger.LogDebug("ApproveDispute(): Process Invoice Adjustment");

            // Meter Account Credit Data.
            SubmitAccountCredit accCredit = new SubmitAccountCredit();

            // Get Data
            try
            {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTPreparedStatement prepStmt =
                    conn.CreatePreparedStatement("__LOAD_ACCOUNTCREDIT_DATA__"))
                {
                  // Should only be 1 resultSet.
                  prepStmt.SetResultSetCount(1);

                  // Add Dispute ID Parameter.
                  prepStmt.AddParam(MTParameterType.Integer,
                                    dispute.invoiceId.Value);

                  // Execute Reader, to grab the data.
                  using (IMTDataReader reader = prepStmt.ExecuteReader())
                  {
                    // Loop results to populate list which is returned to client
                    while (reader.Read())
                    {
                      // Fill DS
                      accCredit.fillDS(reader, invAdj.Currency);
                    }
                  } // end Using Reader
                } // end Using Statement
              } // end Using Connection
            }
            catch (Exception e)
            {
              mLogger.LogException("ApproveDispute() Problem fetching Session IDs ", e);
              throw e;
            }

            accCredit.Run();
            accCredit.Close();
          } // end if...process InvoiceAdjustment
          else
          {
            mLogger.LogDebug("ApproveDispute(): Process Charge Adjustments");

            PC.MTProductCatalog mPC = new PC.MTProductCatalogClass();
            AdjustmentCatalog adjCatalog = new AdjustmentCatalog();

            MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
            PC.IMTSessionContext ctx =
                (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

            adjCatalog.Initialize(ctx);

            // Get Charge Adjustments from DB
            MTList<ChargeAdjustment> chgAdjList = new MTList<ChargeAdjustment>();
            StandardRepository.Instance.LoadInstancesFor<Dispute, ChargeAdjustment>(dispute.Id, ref chgAdjList);

            // Create TransactionSet using the ChargeAdjustment Sessions
            MetraTech.Interop.GenericCollection.IMTCollection sessions =
                new MetraTech.Interop.GenericCollection.MTCollectionClass();

            // Loop Adjustments
            for (int i = 0; i < chgAdjList.Items.Count; i++)
            {
              //Load Adjustment type using the Catalog
              var adjType =
                  adjCatalog.GetAdjustmentType(chgAdjList.Items[i].AdjustmentType);

              // Get Session Intances
              var mtListSessions = new MTList<ChargeAdjustmentSession>();
              StandardRepository.Instance.LoadInstancesFor<ChargeAdjustment, ChargeAdjustmentSession>(chgAdjList.Items[i], ref mtListSessions);

              // Load Session IDs
              for (int j = 0; j < mtListSessions.TotalRows; j++)
              {
                sessions.Add(mtListSessions.Items[j].SessionId);
              }

              IAdjustmentTransactionSet transSet =
                  adjType.CreateAdjustmentTransactions(sessions);

              // Required
              transSet.ReasonCode = new MetraTech.Adjustments.ReasonCode();
              transSet.ReasonCode.ID = chgAdjList.Items[i].ReasonCode.Value;

              transSet.DeleteAndSave(chgAdjList.Items[i]);
            } // end for()...loop Adjustment List
          } // end else...process ChargeAdjustments

          // Mark status "Approved"
          dispute.status = DisputeStatus.Approved;
          dispute.Save();
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in ApproveDispute: ", e);

          throw new MASBasicException("Error in DisputeService:ApproveDispute(). Approving Dispute Failed");
        }
      }
    }

    //[OperationCapability("Rejects a current PENDING dispute")]
    public void RejectDispute(DisputeBusinessKey key)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RejectDispute"))
      {
        mLogger.LogDebug("RejectDispute()");

        Dispute dispute;

        try
        {
          // Get Dispute from Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);
          if (null == dispute)
          {
            mLogger.LogError("RejectDispute() Dispute NOT Retrieved from DB");
            throw new MASBasicException("Error in DisputeService:RejectDispute().Dispute NOT Retrieved from DB");
          }

          // Must be in correct State
          if (dispute.status != DisputeStatus.Pending)
          {
            mLogger.LogError("RejectDispute(): Dispute enity NOT Pending, Reject Dispute Failed");

            throw new MASBasicException("Error in DisputeService:RejectDispute(). Reject Dispute Failed");
          }

          // Get adjustments from repository...Try Invoice 1st
          InvoiceAdjustment invAdj =
              StandardRepository.Instance.LoadInstanceFor<Dispute, InvoiceAdjustment>(dispute.Id);

          // Is there an Invoice Adjusmtent
          if (invAdj != null)
          {
            mLogger.LogError("RejectDispute(): Process Invoice Adjustment");

            // Meter Account Credit Data.
            SubmitAccountCredit accCredit = new SubmitAccountCredit();

            // Get Data
            try
            {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTPreparedStatement prepStmt =
                    conn.CreatePreparedStatement("__LOAD_ACCOUNTCREDIT_DATA__"))
                {
                  // Should only be 1 resultSet.
                  prepStmt.SetResultSetCount(1);

                  // Add Dispute ID Parameter.
                  prepStmt.AddParam(MTParameterType.Integer,
                                    dispute.invoiceId.Value);

                  // Execute Reader, to grab the data.
                  using (IMTDataReader reader = prepStmt.ExecuteReader())
                  {
                    // Loop results to populate list which is returned to client
                    while (reader.Read())
                    {
                      // Fill DS
                      accCredit.fillDS(reader, invAdj.Currency);
                    }
                  } // end Using Reader
                } // end Using Statement
              } // end Using Connection
            }
            catch (Exception e)
            {
              mLogger.LogException("RejectDispute() Problem fetching Session IDs ", e);
              throw e;
            }

            // Meter it...
            accCredit.Run();
            accCredit.Close();
          } // end if...process InvoiceAdjustment
          else
          {
            mLogger.LogError("RejectDispute(): Process Charge Adjustments");

            PC.MTProductCatalog mPC = new PC.MTProductCatalogClass();
            AdjustmentCatalog adjCatalog = new AdjustmentCatalog();

            MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
            PC.IMTSessionContext ctx =
                (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

            adjCatalog.Initialize(ctx);

            // Get Charge Adjustments from DB
            MTList<ChargeAdjustment> chgAdjList = new MTList<ChargeAdjustment>();
            StandardRepository.Instance.LoadInstancesFor<Dispute, ChargeAdjustment>(dispute.Id, ref chgAdjList);

            // Create TransactionSet using the ChargeAdjustment Sessions
            MetraTech.Interop.GenericCollection.IMTCollection sessions =
                new MetraTech.Interop.GenericCollection.MTCollectionClass();

            // Loop Adjustments
            for (int i = 0; i < chgAdjList.Items.Count; i++)
            {
              //Load Adjustment type using the Catalog
              var adjType =
                  adjCatalog.GetAdjustmentType(chgAdjList.Items[i].AdjustmentType);

              // Get Session Intances
              var mtListSessions = new MTList<ChargeAdjustmentSession>();
              StandardRepository.Instance.LoadInstancesFor<ChargeAdjustment, ChargeAdjustmentSession>(chgAdjList.Items[i], ref mtListSessions);

              // Load Session IDs
              for (int j = 0; j < mtListSessions.TotalRows; j++)
              {
                sessions.Add(mtListSessions.Items[j].SessionId);
              }

              IAdjustmentTransactionSet transSet =
                  adjType.CreateAdjustmentTransactions(sessions);

              // Required
              transSet.ReasonCode = new MetraTech.Adjustments.ReasonCode();
              transSet.ReasonCode.ID = chgAdjList.Items[i].ReasonCode.Value;

              transSet.DeleteAndSave(chgAdjList.Items[i]);

            } // end for()...loop Adjustment List
          } // end else...process ChargeAdjustments

          // Allset, set to "Rejected"
          dispute.status = DisputeStatus.Rejected;
          dispute.Save();
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in RejectDispute: ", e);

          throw new MASBasicException("Error in DisputeService:RejectDispute(). Reject Dispute Failed");
        }
      }
    }

    //[OperationCapability("Reverses a previously approved dispute back to PendingApproval")]
    public void ReverseApprovedDispute(DisputeBusinessKey key)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("ReverseApprovedDispute"))
      {
        mLogger.LogDebug("ReverseApprovedDispute()");

        Dispute dispute;

        try
        {
          // Attempt to Load Disput entity from the Repository
          dispute = StandardRepository.Instance.LoadInstanceByBusinessKey<Dispute, DisputeBusinessKey>(key);

          // Status MUST be "Approved"
          if (dispute.status != DisputeStatus.Approved)
          {
            mLogger.LogError("ReverseApprovedDispute(): Dispute enity NOT Approved, Reverse Dispute Approval Failed");

            throw new MASBasicException("Error in DisputeService:ReverseApprovedDispute(). Reverse Dispute Approval Failed");
          }

          // Get adjustments from repository...Try Invoice 1st
          InvoiceAdjustment invAdj =
              StandardRepository.Instance.LoadInstanceFor<Dispute, InvoiceAdjustment>(dispute.Id);

          // Is there an Invoice Adjusmtent
          if (invAdj != null)
          {
            mLogger.LogDebug("ReverseApprovedDispute(): Process Invoice Adjustment");

            string sComment = "Reverse Approved Dispute";

            MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
            PC.IMTSessionContext ctx =
                (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

            // BillingRerun to Backout
            MetraTech.Pipeline.ReRun.Client rerun = new MetraTech.Pipeline.ReRun.Client();

            // Log in as super user
            rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext)ctx);

            // Create rerun table and set something in comment field.
            rerun.Setup(sComment);

            // Populate the rerun table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\DisputeService",
                  "__REVERSE_CREDIT_APPROVAL__"))
              {
                stmt.AddParam("%%SESS_ID%%", dispute.invoiceId.Value);
                mLogger.LogError("ReverseApprovedDispute(): execute query");
                stmt.ExecuteNonQuery();
              }
            }

            rerun.Analyze(sComment);
            rerun.BackoutDelete(sComment);

            // Update status locally
            // Get Query
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\DisputeService");
            qa.SetQueryTag("__UPDATE_ACCOUNTCREDIT_STATUS__");
            string sUpdateStatusQuery = qa.GetQuery();

            try
            {
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTPreparedStatement prepStmt =
                    conn.CreatePreparedStatement(sUpdateStatusQuery))
                {
                  // Add Dispute ID Parameter.
                  prepStmt.AddParam(MTParameterType.Integer,
                                    dispute.invoiceId.Value);

                  // Update Status
                  prepStmt.ExecuteNonQuery();
                } // end Using Statement
              } // end Using Connection
            }
            catch (Exception e)
            {
              mLogger.LogException("ReverseApprovedDispute() Problem Reversing Credit ", e);
              throw e;
            }
          } // end if...Process Invoice/Misc Adjustment
          else
          {
            mLogger.LogDebug("ReverseApprovedDispute(): Process Charge Adjustments");

            PC.MTProductCatalog mPC = new PC.MTProductCatalogClass();
            AdjustmentCatalog adjCatalog = new AdjustmentCatalog();

            MetraTech.Interop.MTAuth.IMTLoginContext logincontext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
            PC.IMTSessionContext ctx =
                (PC.IMTSessionContext)logincontext.Login("su", "system_user", "su123");

            adjCatalog.Initialize(ctx);

            // Get Charge Adjustments from DB
            MTList<ChargeAdjustment> chgAdjList = new MTList<ChargeAdjustment>();
            StandardRepository.Instance.LoadInstancesFor<Dispute, ChargeAdjustment>(dispute.Id, ref chgAdjList);

            // Create TransactionSet using the ChargeAdjustment Sessions
            MetraTech.Interop.GenericCollection.IMTCollection sessions =
                new MetraTech.Interop.GenericCollection.MTCollectionClass();

            // Loop Adjustments
            for (int i = 0; i < chgAdjList.Items.Count; i++)
            {
              //Load Adjustment type using the Catalog
              var adjType =
                  adjCatalog.GetAdjustmentType(chgAdjList.Items[i].AdjustmentType);

              // Get Session Intances
              var mtListSessions = new MTList<ChargeAdjustmentSession>();
              StandardRepository.Instance.LoadInstancesFor<ChargeAdjustment, ChargeAdjustmentSession>(chgAdjList.Items[i], ref mtListSessions);

              // Load Session IDs
              for (int j = 0; j < mtListSessions.TotalRows; j++)
              {
                sessions.Add(mtListSessions.Items[j].SessionId);
              }

              IAdjustmentTransactionSet transSet =
                  adjType.CreateAdjustmentTransactions(sessions);

              // Required
              transSet.ReasonCode = new MetraTech.Adjustments.ReasonCode();
              transSet.ReasonCode.ID = chgAdjList.Items[i].ReasonCode.Value;

              transSet.DeleteAndSave(chgAdjList.Items[i]);
            } // end for()...loop Adjustment List
          } // end else...Process ChargeAdjustments

          // Allset, set new status to "Rejected"
          dispute.status = DisputeStatus.Rejected;
          dispute.Save();
        }
        catch (MASBasicException)
        {
          throw;
        }
        catch (Exception e)
        {
          mLogger.LogException("Error in ReverseApprovedDispute(): ", e);
          throw new MASBasicException("Error in DisputeService:ReverseApprovedDispute(). Dispute Reversal Failed");
        }
      }
    } // End ReverseApprovedDispute(...)


    #endregion


    #region Private Methods

    // Verifies if the MetraAR is installed/availble
    private bool isARAvail()
    {
      bool rc = true;

      return rc;
    }

    // Verifies if the User has Access Rights
    private bool isUserCapable()
    {
      bool rc = true;

      return rc;
    }

    private string getInstanceName(int adjustmentType)
    {
      string sInstanceName = "";

      // Get Query
      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\DisputeService");
      qa.SetQueryTag("__GET_INSTANCE_NAME_FORADJUSTMENT__");
      string sGetInstanceNameQuery = qa.GetQuery();

      // Get Data
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement prepStmt =
              conn.CreatePreparedStatement(sGetInstanceNameQuery))
          {
            // Add AjustmentType ID Parameter.
            prepStmt.AddParam(MTParameterType.Integer,
                              adjustmentType);

            // Execute Reader, to grab the data.
            using (IMTDataReader reader = prepStmt.ExecuteReader())
            {
              // Loop results to populate list which is returned to client
              while (reader.Read())
              {
                sInstanceName = reader.GetValue("Name").ToString();
              }
            } // end Using Reader
          } // end Using Statement
        } // end Using Connection
      }
      catch (Exception e)
      {
        mLogger.LogException("RejectDispute() Problem fetching Instance Name ", e);
        throw e;
      }

      return sInstanceName;
    } // end getInstanceName(...)

    private int getID()
    {
      int genNum;

      // Generate a number
      Random random = new Random();
      genNum = random.Next(1000, 100000);

      return genNum;
    }

    // Create and populate a new Dispute Object.
    Dispute createNewDisputeObj()
    {
      Dispute dispute = new Dispute();

      dispute.Id = Guid.NewGuid();
      dispute.status =
          MetraTech.DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;

      return dispute;
    }
    /*
   void createNewDisputeObj(ref Dispute dispute)
    {
           
        dispute.Id = Guid.NewGuid();

        dispute.status = MetraTech.DomainModel.Enums.Core.Metratech_com_Dispute.DisputeStatus.Pending;
              
    } */
    /*
   private void createNewAdjustmentObj(ref AdjustmentBase  adjustment, 
                                       String sType)
   {
       adjustment.ReasonCode = 0;
       adjustment.InternalId = getID();
       adjustment.Description = "Test Description";
   }
    */
    #endregion

    //*********************************************************************
    //   CLASS SubmitAccountCredit
    //
    //   Class Used to Meter Credit Request
    //*********************************************************************
    private class SubmitAccountCredit
    {
      private MetraTech.Dataflow.MetraFlowPreparedProgram procAccountCredit;

      private string mInputTableID;
      private string mErrorTableID;
      private DataSet inputDS;

      public SubmitAccountCredit()
      {
        #region Setup Input/Error Table
        Type intType = typeof(Int32);
        Type strType = typeof(String);
        Type decType = typeof(Decimal);

        inputDS = new DataSet();

        string inputTableID = Guid.NewGuid().ToString();
        mInputTableID = inputTableID;
        // New DataTable
        DataTable inputTable = new DataTable(inputTableID);

        inputTable.Columns.Add(new DataColumn("c__AccountID", intType));
        inputTable.Columns.Add(new DataColumn("c__Amount", decType));
        inputTable.Columns.Add(new DataColumn("c__Currency", strType));

        inputTable.Columns.Add(new DataColumn("c_Reason", intType));
        inputTable.Columns.Add(new DataColumn("c_Other", strType));
        inputTable.Columns.Add(new DataColumn("c_Status", strType));
        inputTable.Columns.Add(new DataColumn("c_CreditAmount", decType));
        inputTable.Columns.Add(new DataColumn("c_EmailNotification", strType));
        inputTable.Columns.Add(new DataColumn("c_EmailAddress", strType));
        inputTable.Columns.Add(new DataColumn("c_ContentionSessionID", strType));
        inputTable.Columns.Add(new DataColumn("c_Description", strType));
        inputTable.Columns.Add(new DataColumn("c_SubscriberAccountId", intType));
        inputTable.Columns.Add(new DataColumn("c_GuideIntervalID", intType));
        inputTable.Columns.Add(new DataColumn("c_Currency", strType));
        inputTable.Columns.Add(new DataColumn("c_IntervalID", intType));
        // Add Table to DataSet
        inputDS.Tables.Add(inputTable);

        string programText = string.Empty;

        // Create Query Adapter to populate the DB
        IMTQueryAdapter queryAdapter = new MTQueryAdapter();
        queryAdapter.Init("Queries\\DisputeService");
        queryAdapter.SetQueryTag("__INSERT_ACCOUNT_CREDIT__");
        queryAdapter.AddParam("%%INPUT_QUEUE%%", inputTableID, true);

        programText = queryAdapter.GetQuery();

        //Pass empty dataset for outputs. but don't disect after the call.
        DataSet outputDS = new DataSet();
        string errorTableID = Guid.NewGuid().ToString();
        mErrorTableID = errorTableID;

        procAccountCredit =
            new MetraTech.Dataflow.MetraFlowPreparedProgram(programText, inputDS, outputDS);

        #endregion
      }

      public DataTable Input
      {
        get { return procAccountCredit.InputDataSet.Tables[mInputTableID]; }
      }

      //public DataTable ErrorOutput
      //{
      //    get { return procPaymentRecord.OutputDataSet.Tables[mErrorTableID]; }
      //}

      public void Run()
      {
        procAccountCredit.Run();
      }
      public void Close()
      {
        procAccountCredit.Close();
      }

      public DataRow fillDS(IMTDataReader reader, string sCurr)
      {

        // t_svc_AccountCreditRequest
        DataRow row = Input.NewRow();

        // TODO  Where is Real AccountID????
        row["c__AccountID"] = Convert.ToInt32(reader.GetValue("c_SubscriberAccountID"));
        row["c__Amount"] = Convert.ToInt32(reader.GetValue("c_CreditAmount"));
        row["c__Currency"] = sCurr;

        row["c_Reason"] = Convert.ToInt32(reader.GetValue("c_Reason"));
        row["c_Other"] = reader.GetValue("c_Other");
        // Set to Denied
        row["c_Status"] = "DENIED";
        row["c_CreditAmount"] = Convert.ToInt32(reader.GetValue("c_CreditAmount"));
        row["c_EmailNotification"] = reader.GetValue("c_EmailNotification");
        row["c_EmailAddress"] = reader.GetValue("c_EmailAddress");
        row["c_ContentionSessionID"] = reader.GetValue("c_ContentionSessionID");
        row["c_Description"] = reader.GetValue("c_Description");
        row["c_EmailNotification"] = DBNull.Value;
        row["c_EmailAddress"] = DBNull.Value;
        row["c_SubscriberAccountID"] = Convert.ToInt32(reader.GetValue("c_SubscriberAccountID"));
        row["c_GuideIntervalID"] = Convert.ToInt32(reader.GetValue("c_GuideIntervalID"));
        row["c_IntervalID"] = 0;

        // Add row to Dataset
        inputDS.Tables[mInputTableID].Rows.Add(row);

        return row;
      }
    } // End SubmitCredit Class

    //*********************************************************************
    //   CLASS SubmitCreditRequest()
    //
    //   Class Used to Meter Credit Request
    //*********************************************************************
    private class SubmitCreditRequest
    {
      private MetraTech.Dataflow.MetraFlowPreparedProgram procAccountCredReq;

      private string mInputTableID;
      private string mErrorTableID;
      private DataSet inputDS;

      public SubmitCreditRequest()
      {

        #region Setup Input/Error Table
        Type intType = typeof(Int32);
        Type strType = typeof(String);
        Type dtType = typeof(DateTime);
        Type decType = typeof(Decimal);
        Type uniqType = typeof(Guid);

        inputDS = new DataSet();

        string inputTableID = Guid.NewGuid().ToString();
        mInputTableID = inputTableID;
        // New DataTable
        DataTable inputTable = new DataTable(inputTableID);

        inputTable.Columns.Add(new DataColumn("c__AccountID", intType));
        inputTable.Columns.Add(new DataColumn("c__Amount", decType));
        inputTable.Columns.Add(new DataColumn("c__Currency", strType));

        inputTable.Columns.Add(new DataColumn("c_Reason", intType));
        inputTable.Columns.Add(new DataColumn("c_Other", strType));
        inputTable.Columns.Add(new DataColumn("c_Status", strType));
        inputTable.Columns.Add(new DataColumn("c_CreditAmount", decType));
        inputTable.Columns.Add(new DataColumn("c_EmailNotification", strType));
        inputTable.Columns.Add(new DataColumn("c_EmailAddress", strType));
        inputTable.Columns.Add(new DataColumn("c_ContentionSessionID", strType));
        inputTable.Columns.Add(new DataColumn("c_Description", strType));
        inputTable.Columns.Add(new DataColumn("c_SubscriberAccountId", intType));
        inputTable.Columns.Add(new DataColumn("c_GuideIntervalID", intType));
        inputTable.Columns.Add(new DataColumn("c_Currency", strType));
        inputTable.Columns.Add(new DataColumn("c_IntervalID", intType));

        // Add Table to DataSet
        inputDS.Tables.Add(inputTable);

        string programText = string.Empty;

        // Create Query Adapter to populate the DB
        IMTQueryAdapter queryAdapter = new MTQueryAdapter();
        queryAdapter.Init("Queries\\DisputeService");
        queryAdapter.SetQueryTag("__INSERT_ACCOUNT_CREDIT_REQUEST__");
        queryAdapter.AddParam("%%INPUT_QUEUE%%", inputTableID, true);

        programText = queryAdapter.GetQuery();


        //Pass empty dataset for outputs. but don't disect after the call.
        DataSet outputDS = new DataSet();
        string errorTableID = Guid.NewGuid().ToString();
        mErrorTableID = errorTableID;

        procAccountCredReq =
            new MetraTech.Dataflow.MetraFlowPreparedProgram(programText, inputDS, outputDS);

        #endregion
      }

      public DataTable Input
      {
        get { return procAccountCredReq.InputDataSet.Tables[mInputTableID]; }
      }

      //public DataTable ErrorOutput
      //{
      //    get { return procPaymentRecord.OutputDataSet.Tables[mErrorTableID]; }
      //}

      public void Run()
      {
        procAccountCredReq.Run();
      }
      public void Close()
      {
        procAccountCredReq.Close();
      }

      public DataRow fillDS(Dispute dispute)
      {
        // t_svc_AccountCreditRequest
        DataRow row = Input.NewRow();

        // TODO  Where is Real AccountID????
        row["c__AccountID"] = dispute.InvoiceAdjustment.InternalId.Value;
        row["c__Amount"] = dispute.InvoiceAdjustment.Amount.Value;
        row["c__Currency"] = dispute.InvoiceAdjustment.Currency;

        row["c_Reason"] = dispute.InvoiceAdjustment.ReasonCode.Value;
        row["c_Other"] = DBNull.Value;
        row["c_Status"] = dispute.status;
        row["c_CreditAmount"] = dispute.InvoiceAdjustment.Amount.Value;
        row["c_Currency"] = dispute.InvoiceAdjustment.Currency;
        row["c_EmailNotification"] = DBNull.Value;
        row["c_EmailAddress"] = DBNull.Value;
        row["c_ContentionSessionID"] = dispute.invoiceId.Value;
        row["c_Description"] = dispute.InvoiceAdjustment.Description;
        row["c_SubscriberAccountID"] = dispute.InvoiceAdjustment.InternalId.Value;
        row["c_IntervalID"] = dispute.InvoiceAdjustment.InternalId.Value;
        row["c_GuideIntervalID"] = 0;

        // Add row to Dataset
        inputDS.Tables[mInputTableID].Rows.Add(row);

        return row;
      }
    } // End SubmitCreditRequest Class
  } // end DisputeService Class
}
