using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Transactions;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTAuditEvents;
using MetraTech.ActivityServices.Services.Common;

namespace MetraTech.Agreements.Models
{
  /// <summary>
  /// This interface handles all the actions one would want to take on an agreement template.
  /// </summary>
    public interface IAgreementTemplateServices
    {
        /// <summary>
        /// Save an agreement template.  If the template's ID is null, create a new template ID the DB.
        /// </summary>
        /// <param name="template">The template to save</param>
        /// <returns>A copy of the saved template.  If the template's ID was null, the ID of the new template is put in</returns>
        AgreementTemplateModel Save(AgreementTemplateModel template);

        /// <summary>
        /// Copy a template, but strip the members that have to be unique (like ID, name)
        /// </summary>
        /// <param name="template">The template to copy</param>
        /// <returns>A copy of the first template, with ID and name stripped out and replaced with nulls</returns>
        AgreementTemplateModel Copy(AgreementTemplateModel template);

        /// <summary> 
        /// Get All Agreement Templates currently available in the system,
        /// subject to filter, sorting, and paging criteria.  NB: We only fill in core
        /// template properties for these templates; it's too expensive to grab all the POs, etc
        /// for each template in the klist of all templates.
        /// </summary>
        /// <param name="filterpropertiesList">List of filter properties to apply to the search</param>
        /// <param name="sortCriteria">List of sort criteria to apply to the search results</param>
        /// <param name="pageSize">Number of elements to return per result page</param>
        /// <param name="pageNum">Which page of results to fetch</param>
        /// <param name="templateList">The list of templates that satisfies the given filtering, sorting and paging requirements </param>
        /// <returns>The total number of templates that match the filter properties
        /// (spanning all the pages of results, not just the current page)</returns>
        int GetAgreementTemplates(List<FilterElement> filterpropertiesList,
                                  List<SortCriteria> sortCriteria, 
                                  int pageSize, int pageNum, 
                                  out List<AgreementTemplateModel> templateList);


        ///<summary>Get details of the Agreement Template for the given template ID</summary> 
        ///
        /// <param name="IdTemplate">Id of the template to return</param>
        /// <returns>The agreement template</returns>
        /// <exception cref="DataException">Throws DataException if no template found for this ID</exception>
        AgreementTemplateModel GetAgreementTemplate(int IdTemplate);

        /// <summary>
        /// Get all eligible entities (POs, RMEs) that can be added to an agreement template.
        /// If there are none, returns an empty list.
        /// </summary>
        /// <param name="templateEntities">List (possibly empty) of POs and RMEs already added to a specific agreement template.</param>
        /// <returns>A list (possibly empty) of POs and RMEs.</returns>
        List<AgreementEntityModel> GetAgreementTemplateEntities(AgreementEntitiesModel templateEntities);
    }

#region AgreementTemplateServicesStub
    internal class AgreementTemplateServicesStub : BaseService, IAgreementTemplateServices
    {
        private readonly Random m_random = new Random();

        private SortedDictionary<int, AgreementTemplateModel> m_savedTemplates = new SortedDictionary<int, AgreementTemplateModel>();

        public AgreementTemplateModel Save(AgreementTemplateModel template)
        {
            int templateId = template.AgreementTemplateId ?? m_random.Next(10000);

            // Prevent duplicate template names.)
            foreach (KeyValuePair<int, AgreementTemplateModel> kvp in m_savedTemplates)
            {
                AgreementTemplateModel model = kvp.Value;
                if ((model.CoreTemplateProperties.AgreementTemplateName == template.CoreTemplateProperties.AgreementTemplateName) &&
                    (model.AgreementTemplateId != templateId))
                {
                    throw new DataException("Agreement Template name already in use: " +
                                            template.CoreTemplateProperties.AgreementTemplateName);
                }
            }

            // Prevent duplicate entries for same id.
            m_savedTemplates.Remove(templateId);

            template.AgreementTemplateId = templateId;
            m_savedTemplates.Add(templateId, template);

            return template;
        }

        public AgreementTemplateModel Copy(AgreementTemplateModel template)
        {
            return template;
        }

       public int GetAgreementTemplates(List<FilterElement> filterpropertiesList,
                                                                  List<SortCriteria> sortCriteria, int pageSize,
                                                                  int pageNum, out List<AgreementTemplateModel> templateList)
        {
            templateList = new List<AgreementTemplateModel>();
            foreach (AgreementTemplateModel model in m_savedTemplates.Values)
            {
                templateList.Add(model);
            }
            return templateList.Count;
        }


        public AgreementTemplateModel GetAgreementTemplate(int IdTemplate)
        {
            AgreementTemplateModel model;
            if (m_savedTemplates.TryGetValue(IdTemplate, out model))
            {
                return model;
            }
            throw new DataException("No Agreement Template found for ID " + IdTemplate);
        }



        public List<AgreementEntityModel> GetAgreementTemplateEntities(
            AgreementEntitiesModel templateEntities)
        {
            // NOTE: returning a list of fake product offerings that are not inside the NetMeter db.
            var availablePOs = new List<AgreementEntityModel>
                                   {
                                       new AgreementEntityModel
                                           {
                                               EntityId = 100,
                                               EntityName = "DummyProductOffering100",
                                               EntityType = EntityTypeEnum.ProductOffering
                                           },
                                       new AgreementEntityModel
                                           {
                                               EntityId = 200,
                                               EntityName = "DummyProductOffering200",
                                               EntityType = EntityTypeEnum.ProductOffering
                                           },
                                       new AgreementEntityModel
                                           {
                                               EntityId = 300,
                                               EntityName = "DummyProductOffering300",
                                               EntityType = EntityTypeEnum.ProductOffering
                                           },
                                       new AgreementEntityModel
                                           {
                                               EntityId = 400,
                                               EntityName = "DummyProductOffering400",
                                               EntityType = EntityTypeEnum.ProductOffering
                                           },
                                       new AgreementEntityModel
                                           {
                                               EntityId = 500,
                                               EntityName = "DummyProductOffering500",
                                               EntityType = EntityTypeEnum.ProductOffering
                                           }
                                   };

            
            return availablePOs;
        }

        
        public bool HasManageAgreementTemplateCapability(string Login, string Password)
        {
            throw new NotImplementedException();
        }

    } // AgreementTemplateServicesStub
#endregion

    public class AgreementTemplateServicesFactory
    {
        public static IAgreementTemplateServices GetAgreementTemplateService(int i = 0)
        {
            if (i == 0)
            {
                return new AgreementTemplateServices(1);
            }
            else
            {
                return new AgreementTemplateServicesStub();
            }
        }
    }

    public class AgreementTemplateServices : BaseService, IAgreementTemplateServices
    {
        //Create Agreement Auditor
        private Auditor m_agreementAuditor = new Auditor();
        private Logger m_logger = new Logger("[AgreementTemplateServices]");

        /// <summary>
        /// Public constructor.  We don't really want people to call this; they should be using the factory.
        /// </summary>
        /// <param name="DoNotCallThisConstructor">Dummy parameter</param>
        protected internal AgreementTemplateServices(int DoNotCallThisConstructor)
        {
        }

        /// <summary>
        /// Internal constructor, because you should be using the factory.
        /// </summary>
        protected AgreementTemplateServices()
        {
        }

        /// <summary>
        /// Save an agreement template.  If the template's ID is null, create a new template in the DB.
        /// </summary>
        /// <param name="template">The template to save</param>
        /// <returns>A copy of the saved template.  If the template's ID was null, the ID of the new template is put in</returns>
        public AgreementTemplateModel Save(AgreementTemplateModel template)
        {
            var resourceManager = new ResourcesManager();
            int auditOwner = template.CoreTemplateProperties.CreatedBy;
            string auditString = "";
            try
            {
                //We need to wrap this whole thing in a transaction so that POs are updated at the same time as the main template info
                using (var scope = new TransactionScope(TransactionScopeOption.Required,
                                                        new TransactionOptions(),
                                                        EnterpriseServicesInteropOption.Full))
                {
                    var auditType = AuditManager.MTAuditEvents.AUDITEVENT_AGREEMENT_TEMPLATECREATED;
                    if (!template.AgreementTemplateId.HasValue)
                    {
                        //We need to create a new template
                        template.AgreementTemplateId = CreateTemplate(template.CoreTemplateProperties);
                        auditString = String.Format(
                            resourceManager.GetLocalizedResource("CREATED_AGREEMENT_TEMPLATE_AUDIT"),
                            template.AgreementTemplateId);


                    }
                    else
                    {
                        auditType = AuditManager.MTAuditEvents.AUDITEVENT_AGREEMENT_TEMPLATEUPDATED;
                        var oldTemplate = GetAgreementTemplate(template.AgreementTemplateId.Value);
                        var changedProps = AgreementTemplateModel.Compare(oldTemplate, template);
                        auditString =
                            changedProps.Aggregate(
                                String.Format(resourceManager.GetLocalizedResource("UPDATED_AGREEMENT_TEMPLATE_AUDIT"),
                                              template.AgreementTemplateId), (current, x) => current + (x + " "));
                        UpdateTemplateProperties((int) template.AgreementTemplateId, template.CoreTemplateProperties);
                        if (template.CoreTemplateProperties.UpdatedBy != null)
                            auditOwner = (int) template.CoreTemplateProperties.UpdatedBy;
                    }

                    UpdateEntities((int) template.AgreementTemplateId, template.AgreementEntities);
                    UpdateCoreAgreementProperties((int) template.AgreementTemplateId, template.CoreAgreementProperties);
                    m_agreementAuditor.FireEvent(
                        (int) auditType,
                        auditOwner,
                        (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_AGREEMENT,
                        (int) template.AgreementTemplateId,
                        auditString);
                    scope.Complete();
                }
            }catch(Exception e)
            {
                m_logger.LogException(String.Format(resourceManager.GetLocalizedResource("FAILED_TO_SAVE_AGREEMENT_TEMPLATE"),
                                              template.AgreementTemplateId), e);
                m_agreementAuditor.FireFailureEvent(
                    (int)AuditManager.MTAuditEvents.AUDITEVENT_AGREEMENT_UPDATE_FAILED,
                auditOwner,
                (int) AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_AGREEMENT,
                template.AgreementTemplateId == null ? -1 : (int) template.AgreementTemplateId,
                String.Format(resourceManager.GetLocalizedResource("FAILED_TO_SAVE_AGREEMENT_TEMPLATE"),
                                              template.AgreementTemplateId));
                throw;
            }
            return template;
        }

        private void UpdateCoreAgreementProperties(int templateId, AgreementPropertiesModel agreementProps)
        {
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\ProductCatalog");
            qa.SetQueryTag("__UPDATE_TEMPLATE_AGREEMENT_PROPERTIES__");
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qa.GetQuery()))
                {
                    stmt.AddParam("id_agr_template", MTParameterType.Integer, templateId);
                    stmt.AddParam("effective_start_date", MTParameterType.DateTime, agreementProps.EffectiveStartDate);
                    stmt.AddParam("effective_end_date", MTParameterType.DateTime, agreementProps.EffectiveEndDate);

                    stmt.ExecuteNonQuery();
                }
            }
        }

        private void UpdateEntities(int templateId, AgreementEntitiesModel entities)
        {
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\ProductCatalog");
            qa.SetQueryTag("__DELETE_OLD_AGR_TEMPLATE_ENTITIES__");
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {

                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qa.GetQuery()))
                {
                    stmt.AddParam("id_agr_template", MTParameterType.Integer, templateId);
                    stmt.ExecuteNonQuery();

                }

                qa.SetQueryTag("__ADD_AGR_TEMPLATE_ENTITIES__");
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qa.GetQuery()))
                {
                    foreach (var entity in entities.AgreementEntityList)
                    {
                        stmt.ClearParams();
                        stmt.AddParam("id_agr_template", MTParameterType.Integer, templateId);
                        stmt.AddParam("id_entity", MTParameterType.Integer, entity.EntityId);
                        stmt.AddParam("entity_type", MTParameterType.Integer, (int) entity.EntityType);
                        stmt.ExecuteNonQuery();
                    }
                }
            }
        }

        private void UpdateTemplateProperties(int agreementTemplateId, AgreementTemplatePropertiesModel templateProps)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                //Retrieve the template before change
                var beforechangeTemplate = GetAgreementTemplate(agreementTemplateId);

                IMTQueryAdapter qa = new MTQueryAdapter();
                qa.Init("Queries\\ProductCatalog");
                qa.SetQueryTag("__UPDATE_AGR_TEMPLATE__");

                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(qa.GetQuery()))
                {
                    stmt.AddParam("nm_template_name", MTParameterType.String, templateProps.AgreementTemplateName);
                    stmt.AddParam("n_template_description", MTParameterType.Integer,
                                  templateProps.AgreementTemplateDescId);
                    stmt.AddParam("nm_template_description", MTParameterType.String,
                                  templateProps.AgreementTemplateDescription);
                    stmt.AddParam("updated_date", MTParameterType.DateTime, DateTime.Now);
                    templateProps.UpdatedDate = DateTime.Now;
                    stmt.AddParam("updated_by", MTParameterType.Integer, templateProps.UpdatedBy);
                    stmt.AddParam("available_start_date", MTParameterType.DateTime,
                                  templateProps.AvailableStartDate);
                    stmt.AddParam("available_end_date", MTParameterType.DateTime, templateProps.AvailableEndDate);
                    stmt.AddParam("id_agr_template", MTParameterType.Integer, agreementTemplateId);

                    stmt.ExecuteNonQuery();

                }
                ProcessLocalizationData(templateProps.AgreementTemplateNameId, templateProps.LocalizedDisplayNames,
                                        templateProps.AgreementTemplateDescId, templateProps.LocalizedDescriptions);

            }
        }

        private int CreateTemplate(AgreementTemplatePropertiesModel template)
        {
            int newTemplateId;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("CreateAgrTemplate"))
                {
                    int createdbyuserid = template.CreatedBy;
                    stmt.AddParam("n_template_name", MTParameterType.Integer,
                                  template.AgreementTemplateNameId);
                    stmt.AddParam("nm_template_name", MTParameterType.String, template.AgreementTemplateName);
                    stmt.AddParam("n_template_description", MTParameterType.Integer,
                                  template.AgreementTemplateDescId);
                    stmt.AddParam("nm_template_description", MTParameterType.String,
                                  template.AgreementTemplateDescription);
                    stmt.AddParam("created_date", MTParameterType.DateTime, DateTime.Now);
                    stmt.AddParam("created_by", MTParameterType.String, template.CreatedBy);
                    stmt.AddParam("available_start_date", MTParameterType.DateTime,
                                  template.AvailableStartDate);
                    stmt.AddParam("available_end_date", MTParameterType.DateTime, template.AvailableEndDate);
                    stmt.AddOutputParam("id_agr_template", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();

                    newTemplateId = (int) stmt.GetOutputValue("id_agr_template");

                }
            }
            return newTemplateId;
        }

        /// <summary>
        /// Copy a template, but strip the members that have to be unique (like ID, name)
        /// </summary>
        /// <param name="template">The template to copy</param>
        /// <returns>A copy of the first template, with ID and name stripped out and replaced with nulls</returns>
        public AgreementTemplateModel Copy(AgreementTemplateModel template)
        {
            var copyObject = new AgreementTemplateModel
                                 {
                                     AgreementTemplateId = null,
                                     CoreTemplateProperties =
                                         {
                                             AgreementTemplateDescId =
                                                 template.CoreTemplateProperties.AgreementTemplateDescId,
                                             AgreementTemplateDescription =
                                                 template.CoreTemplateProperties.AgreementTemplateDescription,
                                             AgreementTemplateName = null,
                                             AgreementTemplateNameId = null,
                                             CreatedBy = template.CoreTemplateProperties.CreatedBy,
                                             CreatedDate = DateTime.Now,
                                             AvailableEndDate = template.CoreTemplateProperties.AvailableEndDate,
                                             AvailableStartDate = template.CoreTemplateProperties.AvailableStartDate,
                                             UpdatedBy = null,
                                             UpdatedDate = null
                                         },
                                     CoreAgreementProperties =
                                         {
                                             EffectiveStartDate = template.CoreAgreementProperties.EffectiveStartDate,
                                             EffectiveEndDate = template.CoreAgreementProperties.EffectiveEndDate
                                         }
                                 };

            foreach (var entity in template.AgreementEntities.AgreementEntityList)
            {
                copyObject.AgreementEntities.AddEntity(entity.Copy());
            }


            return copyObject;
        }

        /// <summary> 
        /// Get All Agreement Templates currently available in the system.  For now, only get core properties.
        /// If needed, we can fill in the others, but it will mean more trips to the DB.
        /// </summary>
        /// <param name="filterpropertiesList">List of filter properties</param>
        /// <param name="sortCriteria">List of Sort properties</param>
        /// <param name="pageSize">Page size</param>
        /// <param name="pageNum">Which page of results to fetch</param>
        /// <returns>A Filtered and Sorted list of agreement templates based on the filter/sorting criteria</returns>
        public int GetAgreementTemplates(List<FilterElement> filterpropertiesList,
                                         List<SortCriteria> sortCriteria, int pageSize,
                                         int pageNum, out List<AgreementTemplateModel> templateList)
        {
            templateList = new List<AgreementTemplateModel>();
            int totalRows;
            //This takes a few steps.  First, we'll get all the agreements and their core properties.
            //  Then we'll circle back through the list and get the associated agreement properties
            //  and entities.  Still not sure if we want to bother filling those in.
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
                {

                    using (
                        var stmt = conn.CreateFilterSortStatement("Queries\\ProductCatalog",
                                                                  "__GET_AGREEMENT_TEMPLATES__"))
                    {
                        ApplySortingFiltering(filterpropertiesList, sortCriteria, stmt);

                        stmt.PageSize = pageSize;
                        stmt.CurrentPage = pageNum;


                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                AgreementTemplateModel template = new AgreementTemplateModel();
                                AgreementTemplatePropertiesModel coreProps = new AgreementTemplatePropertiesModel();

                                template.AgreementTemplateId = rdr.GetInt32("AgreementTemplateId");
                                coreProps.AgreementTemplateNameId = rdr.GetInt32("AgreementTemplateNameId");
                                coreProps.AgreementTemplateName = rdr.GetString("AgreementTemplateName");
                                coreProps.AgreementTemplateDescId = rdr.IsDBNull("AgreementTemplateDescId")
                                                                        ? (int?) null
                                                                        : rdr.GetInt32("AgreementTemplateDescId");
                                coreProps.AgreementTemplateDescription = rdr.IsDBNull("AgreementTemplateDescription")
                                                                             ? String.Empty
                                                                             : rdr.GetString(
                                                                                 "AgreementTemplateDescription");
                                coreProps.CreatedDate = rdr.GetDateTime("CreatedDate");
                                coreProps.CreatedBy = rdr.GetInt32("CreatedBy");
                                coreProps.UpdatedDate = rdr.IsDBNull("UpdatedDate")
                                                            ? (DateTime?) null
                                                            : rdr.GetDateTime("UpdatedDate");
                                coreProps.UpdatedBy = rdr.IsDBNull("UpdatedBy")
                                                          ? (int?) null
                                                          : rdr.GetInt32("UpdatedBy");
                                coreProps.AvailableStartDate = rdr.IsDBNull("AvailableStartDate")
                                                                   ? (DateTime?) null
                                                                   : rdr.GetDateTime("AvailableStartDate");
                                coreProps.AvailableEndDate = rdr.IsDBNull("AvailableEndDate")
                                                                 ? (DateTime?) null
                                                                 : rdr.GetDateTime("AvailableEndDate");
                                coreProps.ErrorDescription = "";

                                template.CoreTemplateProperties = coreProps;
                                templateList.Add(template);

                            }
                            totalRows = stmt.TotalRows;
                        }

                    }
                }
                return totalRows;
            }
            catch (Exception e)
            {
                throw new DataException("Could not retrieve Agreement Templates..", e);
            }

        }


        ///<summary>Get Detail of the Agreement Template for the given template ID</summary> 
        ///
        /// <param name="IdTemplate">Id of the template to return</param>
        /// <returns>The agreement template</returns>
        /// <exception cref="DataException">Could not retrieve agreement template for this ID</exception>
        public AgreementTemplateModel GetAgreementTemplate(int IdTemplate)
        {
            var retVal = new AgreementTemplateModel();
            try
            {
                retVal.AgreementTemplateId = IdTemplate;
                retVal.CoreTemplateProperties = GetCoreTemplateProperties(IdTemplate);
                retVal.AgreementEntities = GetAgreementTemplateMappedEntities(IdTemplate);
                retVal.CoreAgreementProperties = GetCoreAgreementProperties(IdTemplate);

            }
            catch (Exception e)
            {
                throw new DataException("Could not retrieve Agreement Template for ID " + IdTemplate, e);
            }

            return retVal;
        }

        private AgreementPropertiesModel GetCoreAgreementProperties(int IdTemplate)
        {
            var retVal = new AgreementPropertiesModel();
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
            {
                IMTQueryAdapter qa = new MTQueryAdapter();
                qa.Init("Queries\\ProductCatalog");
                qa.SetQueryTag("__GET_TEMPLATE_AGREEMENT_PROPERTIES__");
                using (
                    var stmt = conn.CreatePreparedFilterSortStatement(qa.GetQuery()))
                {
                    stmt.AddParam("id_agr_template", MTParameterType.Integer, IdTemplate);
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (stmt.TotalRows == 1)
                        {
                            rdr.Read();
                            retVal.EffectiveEndDate = rdr.IsDBNull("EffectiveEndDate")
                                                          ? (DateTime?) null
                                                          : rdr.GetDateTime("EffectiveEndDate");
                            retVal.EffectiveStartDate = rdr.IsDBNull("EffectiveStartDate")
                                                            ? (DateTime?) null
                                                            : rdr.GetDateTime("EffectiveStartDate");
                        }
                        else
                        {
                            throw new DataException("No Core Agreement properties found for ID " + IdTemplate);

                        }
                    }
                }
            }
            return retVal;
        }

        private AgreementTemplatePropertiesModel GetCoreTemplateProperties(int IdTemplate)
        {
            var resourceManager = new ResourcesManager();
            var atm = new AgreementTemplatePropertiesModel();
            using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
            {
                IMTQueryAdapter qa = new MTQueryAdapter();
                qa.Init("Queries\\ProductCatalog");
                qa.SetQueryTag("__GET_AGREEMENT_TEMPLATE_BY_ID__");
                using (
                    var stmt = conn.CreatePreparedFilterSortStatement(qa.GetQuery()))
                {
                    stmt.AddParam("ID_TEMPLATE", MTParameterType.Integer, IdTemplate);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (stmt.TotalRows == 1)
                        {
                            rdr.Read();
                            atm.AgreementTemplateNameId = rdr.IsDBNull("AgreementTemplateNameId")
                                                              ? -1
                                                              : rdr.GetInt32("AgreementTemplateNameId");
                            atm.AgreementTemplateName = rdr.GetString("AgreementTemplateName");
                            atm.AgreementTemplateDescId = rdr.IsDBNull("AgreementTemplateDescId")
                                                              ? (int?) null
                                                              : rdr.GetInt32("AgreementTemplateDescId");
                            atm.AgreementTemplateDescription = rdr.IsDBNull("AgreementTemplateDescription")
                                                                   ? null
                                                                   : rdr.GetString("AgreementTemplateDescription");
                            atm.CreatedDate = rdr.GetDateTime("CreatedDate");
                            atm.CreatedBy = rdr.GetInt32("CreatedBy");
                            atm.UpdatedDate = rdr.IsDBNull("UpdatedDate")
                                                  ? (DateTime?) null
                                                  : rdr.GetDateTime("UpdatedDate");
                            atm.UpdatedBy = rdr.IsDBNull("UpdatedBy") ? (int?) null : rdr.GetInt32("UpdatedBy");
                            atm.AvailableStartDate = rdr.IsDBNull("AvailableStartDate")
                                                         ? (DateTime?) null
                                                         : rdr.GetDateTime("AvailableStartDate");
                            atm.AvailableEndDate = rdr.IsDBNull("AvailableEndDate")
                                                       ? (DateTime?) null
                                                       : rdr.GetDateTime("AvailableEndDate");
                        }
                        else
                        {
                            throw new DataException("No Agreement Template found for ID " + IdTemplate);
                        }
                    }
                }
                m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVING_LOCALE"));
                atm.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                atm.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                using (
                    IMTMultiSelectAdapterStatement localStmt = conn.CreateMultiSelectStatement("Queries\\PCWS",
                                                                                               "__GET_AGREEMENT_LOCALIZATION__")
                    )
                {
                    localStmt.AddParam("%%ID_DISPLAY_NAME%%", atm.AgreementTemplateNameId);
                    localStmt.AddParam("%%ID_DESCRIPTION%%", atm.AgreementTemplateDescId);
                    localStmt.SetResultSetCount(2);

                    using (IMTDataReader rdr = localStmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var langCode =
                                (LanguageCode)
                                EnumHelper.GetEnumByValue(typeof (LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                            atm.LocalizedDisplayNames.Add(langCode,
                                                          (!rdr.IsDBNull("DisplayNameDescription"))
                                                              ? rdr.GetString("DisplayNameDescription")
                                                              : null);
                        }
                        rdr.NextResult();
                        while (rdr.Read())
                        {
                            var langCode =
                                (LanguageCode)
                                EnumHelper.GetEnumByValue(typeof (LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                            atm.LocalizedDescriptions.Add(langCode,
                                                          (!rdr.IsDBNull("Description"))
                                                              ? rdr.GetString("Description")
                                                              : null);
                        }
                    }
                }
                m_logger.LogDebug(resourceManager.GetLocalizedResource("TEXT_RETRIEVED_LOCALE"));
            }

            return atm;
        }

        /// <summary>
        /// Get all eligible entities (POs, RMEs) that can be added to an agreement template.
        /// If there are none, returns an empty list.
        /// </summary>
        /// <returns>A list (possibly empty) of POs and RMEs.</returns>
        public List<AgreementEntityModel> GetAgreementTemplateEntities(
            AgreementEntitiesModel templateEntities)
        {
            var mappableEntities = new List<AgreementEntityModel>();

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
                {
                    using (
                        IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\ProductCatalog",
                                                                                     "__GET_ALL_AGREEMENT_TEMPLATE_ENTITIES__")
                        )
                    {
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                var me = new AgreementEntityModel
                                             {
                                                 EntityId = rdr.GetInt32("EntityId"),
                                                 EntityType = (EntityTypeEnum) rdr.GetInt32("EntityType"),
                                                 EntityName =
                                                     rdr.IsDBNull("EntityName")
                                                         ? String.Empty
                                                         : rdr.GetString("EntityName")
                                             };



                                mappableEntities.Add(me);
                            }
                        }

                    }
                }
                return mappableEntities;
            }
            catch (Exception e)
            {
                throw new DataException("Could not retrieve mappable entities for agreement templates.", e);
            }
        }

        /// <summary>
        /// Get all eligible entities (POs, RMEs) that have been added to a specific agreement template.
        /// If there are none, returns an empty list.
        /// </summary>
        /// <returns>A list (possibly empty) of POs and RMEs associated with the agreement template.</returns>
       private AgreementEntitiesModel GetAgreementTemplateMappedEntities(int IdTemplate)
        {
            var retVal = new AgreementEntitiesModel();
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection(true))
                {
                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapter();
                        queryAdapter.Item.Init("queries\\ProductCatalog");
                        queryAdapter.Item.SetQueryTag("__GET_AGREEMENT_TEMPLATE_MAPPED_ENTITIES__");
                        string rawSql = queryAdapter.Item.GetRawSQLQuery(true);

                        using (
                            //IMTFilterSortStatement stmt = conn.CreateFilterSortStatement("Queries\\ProductCatalog","__GET_AGREEMENT_TEMPLATE_MAPPED_ENTITIES__")
                            IMTPreparedFilterSortStatement stmt = conn.CreatePreparedFilterSortStatement(rawSql)
                            )
                        {
                            stmt.AddParam("ID_TEMPLATE", MTParameterType.Integer, IdTemplate);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    var mae = new AgreementEntityModel();

                                    mae.EntityId = rdr.GetInt32("EntityId");

                                    mae.EntityType = (EntityTypeEnum) rdr.GetInt32("EntityType");


                                    mae.EntityName = rdr.GetString("EntityName");

                                    retVal.AddEntity(mae);
                                }
                            }
                        }
                    }
                }
                return retVal;
            }
            catch (Exception e)
            {
                throw new DataException("Could not retrieve mapped entities to agreement template id .." + IdTemplate, e);
            }
        }

    }
}