using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Application;
using MetraTech.DataAccess;
using System.Reflection;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.QueryAdapter;
using DatabaseUtils = MetraTech.Domain.DataAccess.DatabaseUtils;

namespace MetraTech.Core.Services
{
    public abstract class BasePCWebService : CMASServiceBase
    {
        #region Protected Members
        protected const string PCWS_QUERY_FOLDER = @"queries\PCWS";
        protected const string ADJUSTMENT_QUERY_FOLDER = @"queries\Adjustments";
        protected const string PROD_CATALOG_QUERY_FOLDER = @"queries\ProductCatalog";

        protected const int PRODUCT_OFFERING_KIND = 100;
        protected const int PRICELIST_KIND = 150;
        protected const int NON_SHARED_PL_TYPE = 2;
        protected const int ADJUSTMENT_TYPE = 340;
        protected const int CALENDAR_KIND = 240;
        protected const int REASON_CODE_KIND = 350;
        protected const int COUNTER_KIND = 170;
        protected const int ADJUSTMENT_KIND = 320;

      protected static Dictionary<Type, List<PropertyInfo>> mExendedPropertyProperties = new Dictionary<Type, List<PropertyInfo>>();

        private static Dictionary<Type, List<PropertyInfo>> m_CachedTypeBasedProperties = new Dictionary<Type, List<PropertyInfo>>();

        private static Logger m_Logger = new Logger("[BasePCWebService]");
        
        #endregion

        static BasePCWebService()
        {
            CMASServiceBase.ServiceStarting += new ServiceStartingEventHandler(CMASServiceBase_ServiceStarting);
        }

        #region Service Startup Methods
        protected static void CMASServiceBase_ServiceStarting()
        {
            m_Logger.LogInfo("In BasePCWebService.ServiceStarting - Loading Param Tables");
            CacheManager.InitializeParameterTableCache();
            
            #region Load Attribute MetaData

            #endregion

        }
        #endregion

        #region Protected Helper Methods

        protected Type GetPIKindInstanceType(PriceableItemKinds PIKind)
        {
            switch (PIKind)
            {
                case PriceableItemKinds.Recurring:
                    return typeof(RecurringChargePIInstance);
                    break;
                case PriceableItemKinds.UnitDependentRecurring:
                    return typeof(UnitDependentRecurringChargePIInstance);
                    break;
                case PriceableItemKinds.Usage:
                    return typeof(UsagePIInstance);
                    break;
                case PriceableItemKinds.NonRecurring:
                    return typeof(NonRecurringChargePIInstance);
                    break;
                case PriceableItemKinds.Discount:
                    return typeof(DiscountPIInstance);
                    break;
                case PriceableItemKinds.AggregateCharge:
                    return typeof(AggregateChargePIInstance);
                    break;
                default:
                    throw new MASBasicException("Invalid PIKind..");
            }
        }

        protected void CanProductOfferingBeModified(int id_po)
        {
            m_Logger.LogDebug("Checking if product offering {0} can be modified", id_po);

            if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_CheckModification))
            {
                if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_ProdOff_NoModificationIfAvailable))
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__IS_PO_AVAILABILITY_SET__"))
                        {
                            stmt.AddParam("%%PO_ID%%", id_po);

                            using (IMTDataReader rdr = stmt.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    if (rdr.GetInt32("AvailabilitySet") == 1)
                                    {
                                        throw new MASBasicException("Unable to modify ProductOffering because it is available");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

      internal class ExtendedPropUpsertData
        {
            public string ColumnList { get; set; }
            public string ValueList { get; set; }
            public string UpdateList { get; set; }
        }

        protected void PropagateExtendedProps(int id, BaseObject instance)
        {
            UpsertExtendedProps(id, instance, true);
        }
        protected void UpsertExtendedProps(int id, BaseObject instance)
        {
            UpsertExtendedProps(id, instance, false);
        }

        private void UpsertExtendedProps(int id, BaseObject instance, bool bPropagate)
        {
            //Make sure propogate is turned on only for Template objects.
            if(bPropagate)
            {
                object o = instance as BasePriceableItemTemplate;
                if (o == null)
                    bPropagate = false;
            }

            Dictionary<string, ExtendedPropUpsertData> upsertTables = new Dictionary<string, ExtendedPropUpsertData>();

            List<PropertyInfo> props = GetExtendedProperyInfos(instance);

            foreach (PropertyInfo prop in props)
            {
                if (instance.IsDirty(prop))
                {
                    object instValue = prop.GetValue(instance, null);

                    object[] customAttribs = prop.GetCustomAttributes(typeof(MTExtendedPropertyAttribute), false);
                    MTExtendedPropertyAttribute extendedPropAttrib = (MTExtendedPropertyAttribute)customAttribs[0];

                    string tableName = extendedPropAttrib.TableName;
                    string columnName = extendedPropAttrib.ColumnName;
                    string val = DatabaseUtils.FormatValueForDB(instValue);

                    if (upsertTables.ContainsKey(tableName))
                    {
                        ExtendedPropUpsertData data = upsertTables[tableName];

                        data.ColumnList += string.Format(", {0}", columnName);
                        data.ValueList += string.Format(", {0}", val);
                        data.UpdateList += string.Format(", {0} = {1}", columnName, val);
                    }
                    else
                    {
                        ExtendedPropUpsertData upsertData = new ExtendedPropUpsertData();

                        upsertData.ColumnList = columnName;
                        upsertData.ValueList = val;
                        upsertData.UpdateList = string.Format("{0} = {1}", columnName, val);

                        upsertTables[tableName] = upsertData;
                    }
                }
            }

            foreach (KeyValuePair<string, ExtendedPropUpsertData> kvp in upsertTables)
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement stmt = conn.CreateCallableStatement(bPropagate ? "PropagateProperties" : "ExtendedUpsert"))
                    {

                        stmt.AddParam("table_name", MTParameterType.String, kvp.Key);
                        stmt.AddParam("update_list", MTParameterType.String, kvp.Value.UpdateList);
                        stmt.AddParam("insert_list", MTParameterType.String, kvp.Value.ValueList);
                        stmt.AddParam("clist", MTParameterType.String, kvp.Value.ColumnList);
                        stmt.AddParam((bPropagate ? "id_pi_template" : "id_prop"), MTParameterType.Integer, id);

                        if (!bPropagate)
                            stmt.AddOutputParam("status", MTParameterType.Integer);

                        stmt.ExecuteNonQuery();

                        if (!bPropagate)
                        {
                            int status = (int)stmt.GetOutputValue("status");

                            if (status != 0)
                            {
                                m_Logger.LogError("Error upserting extended properties for ID {0}: {1}", id, status);

                                throw new MASBasicException(string.Format("Error upserting extended properties for ID {0}", id));
                            }
                        }
                    }
                }
            }
        }

      protected void UpdateAvailableDateForPO(int idPo, ProdCatTimeSpan effectiveDate)
        {
            EffectiveDateUtils.UpdateEffectiveDate(effectiveDate, String.Format("(select id_avail from t_po where id_po = {0})", idPo));
        }

        protected void UpdateEffectiveDateForPO(int idPo, ProdCatTimeSpan effectiveDate)
        {
            EffectiveDateUtils.UpdateEffectiveDate(effectiveDate, String.Format("(select id_eff_date from t_po where id_po = {0})", idPo));
        }

      protected void GetLocalizedDispAndDesc(int idPo, out int nameId, out int descId)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement getLocalValStmt = conn.CreateAdapterStatement("queries\\PCWS", "__GET_NAME_DISP_ID__"))
                {
                    getLocalValStmt.AddParam("%%ID_PO%%", idPo);
                    nameId = -1;
                    descId = -1;
                    using (IMTDataReader getLocalValReader = getLocalValStmt.ExecuteReader())
                    {
                        while (getLocalValReader.Read())
                        {
                            nameId = getLocalValReader.GetInt32("n_display_name");
                            descId = getLocalValReader.GetInt32("n_desc");
                        }
                    }
                }
            }
        }

        protected void ProcessLocalizationData(int id_prop, 
                                                Dictionary<LanguageCode, string> localizedDisplayNames, 
                                                bool isLocalizedDisplayNamesDirty,
                                                Dictionary<LanguageCode, string> localizedDescriptions,
                                                bool isLocalizedDescriptionsDirty )
        {
            int nameId = -1;
            int descId = -1;
            GetLocalizedDispAndDesc(id_prop, out nameId, out descId);

            if (nameId == -1 || descId == -1)
            {
                throw new MASBasicException("Cannot add localized values if base properties are not created first");
            }

            ProcessLocalizationData(nameId, 
                                    localizedDisplayNames, 
                                    isLocalizedDisplayNamesDirty, 
                                    descId, 
                                    localizedDescriptions, 
                                    isLocalizedDescriptionsDirty);
        }

        protected void ProcessLocalizationData(int? displayNameId,
                                                Dictionary<LanguageCode, string> localizedDisplayNames,
                                                bool isLocalizedDisplayNamesDirty,
                                                int? descId,
                                                Dictionary<LanguageCode, string> localizedDescriptions,
                                                bool isLocalizedDescriptionsDirty)
        {
            bool runUpdate = false;
            bool hasLocalizedDisplayNameValues = false;
            bool hasLocalizedDescriptionValues = false;
            StringBuilder updateDisplayNames = new StringBuilder();
            StringBuilder updateDescriptions = new StringBuilder();
            StringBuilder updateLocalization = new StringBuilder();

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {

                bool isOracle = conn.ConnectionInfo.DatabaseType == DBType.Oracle ? true : false;
                if (isOracle)
                    updateLocalization.Append("DECLARE\n A_ID_DESC NUMBER;\n BEGIN\n A_ID_DESC := NULL; \n");
                else
                    updateLocalization.Append("BEGIN\n declare @a_id_desc int \n");

                if (displayNameId.HasValue && isLocalizedDisplayNamesDirty)
                {
                    if (isOracle)
                    {
                        updateDisplayNames.Append(string.Format("delete from t_description where id_desc = {0};\n", displayNameId.Value));
                    }
                    else
                    {
                        updateDisplayNames.Append(string.Format("delete from t_description where id_desc = {0};\n", displayNameId.Value));
                    }

                    if (localizedDisplayNames != null && localizedDisplayNames.Count > 0)
                    {
                        foreach (KeyValuePair<LanguageCode, string> dispName in localizedDisplayNames)
                        {
                            int lcId = System.Convert.ToInt32(EnumHelper.GetValueByEnum(dispName.Key, 1));

                            if (dispName.Value != null && dispName.Value.Length > 0)
                                hasLocalizedDisplayNameValues = true;

                            if (isOracle)
                                updateDisplayNames.Append(String.Format("UPSERTDESCRIPTIONV2({0},N'{1}',{2},{3});\n", lcId, dispName.Value, displayNameId.Value, "A_ID_DESC"));
                            else
                                updateDisplayNames.Append(String.Format("exec UpsertDescriptionV2 {0},N'{1}',{2},{3}", lcId, dispName.Value, displayNameId.Value, "@a_id_desc OUTPUT;\n"));
                        }
                    }

                    if (displayNameId.Value <= 0)
                    {
                        if (hasLocalizedDisplayNameValues)
                            throw new MASBasicException("Cannot add localized values if default display names are not defined.");

                    }
                    else
                    {
                        updateLocalization.Append(updateDisplayNames.ToString());
                        runUpdate = true;
                    }


                }




                if (descId.HasValue && isLocalizedDescriptionsDirty)
                {
                    if (isOracle)
                    {
                        updateDescriptions.Append(string.Format("delete from t_description where id_desc = {0};\n", descId.Value));
                    }
                    else
                    {
                        updateDescriptions.Append(string.Format("delete from t_description where id_desc =  {0};\n", descId.Value));
                    }

                    if (localizedDescriptions != null && localizedDescriptions.Count > 0)
                    {
                        foreach (KeyValuePair<LanguageCode, string> dispDesc in localizedDescriptions)
                        {
                            int lcId = System.Convert.ToInt32(EnumHelper.GetValueByEnum(dispDesc.Key, 1));

                            if (dispDesc.Value != null && dispDesc.Value.Length > 0)
                                hasLocalizedDescriptionValues = true;

                            if (isOracle)
                                updateDescriptions.Append(String.Format("UPSERTDESCRIPTIONV2({0},N'{1}',{2},{3});\n", lcId, dispDesc.Value, descId.Value, "A_ID_DESC"));
                            else
                                updateDescriptions.Append(String.Format("exec UpsertDescriptionV2 {0},N'{1}',{2},{3}", lcId, dispDesc.Value, descId.Value, "@a_id_desc OUTPUT;\n"));
                        }
                    }

                    if (descId.Value <= 0)
                    {
                        if (hasLocalizedDescriptionValues)
                            throw new MASBasicException("Cannot add localized values if default Descriptions are not defined.");

                    }
                    else
                    {
                        updateLocalization.Append(updateDescriptions.ToString());
                        runUpdate = true;
                    }

                }

                updateLocalization.Append("END;");

                if (runUpdate)
                {
                    using (IMTStatement localizationStmt = conn.CreateStatement(updateLocalization.ToString()))
                    {
                        localizationStmt.ExecuteNonQuery();
                    }
                }
            }
        }

        protected void ResolveUsageCycleInfo(ExtendedUsageCycleInfo usageCycleInfo, out string mode, out int? cycleId, out int? cycleTypeId)
        {

            m_Logger.LogDebug("Resolving usage cycle info");

            cycleId = null;
            cycleTypeId = null;

            if (usageCycleInfo.GetType().IsSubclassOf(typeof(FixedUsageCycleInfo)))
            {
                m_Logger.LogDebug("Usage cycle is Fixed");

                mode = "Fixed";
                cycleId = ResolveUsageCycleId(((FixedUsageCycleInfo)usageCycleInfo));
                cycleTypeId = null;
            }
            else if (usageCycleInfo.GetType() == typeof(RelativeUsageCycleInfo))
            {
                RelativeUsageCycleInfo relativeCycle = (RelativeUsageCycleInfo)usageCycleInfo;

                if (relativeCycle.UsageCycleType.HasValue)
                {
                    m_Logger.LogDebug("Usage cycle is BCR Constrained");
                    mode = "BCR Constrained";
                    cycleId = null;
                    cycleTypeId = (int)relativeCycle.UsageCycleType.Value;
                }
                else
                {
                    m_Logger.LogDebug("Usage cycle is BCR");
                    mode = "BCR";
                    cycleId = null;
                    cycleTypeId = null;
                }
            }
            else
            {
                m_Logger.LogDebug("Usage cycle is EBCR");
                mode = "EBCR";
                cycleId = null;
                cycleTypeId = (int)((ExtendedRelativeUsageCycleInfo)usageCycleInfo).ExtendedUsageCycle;
            }
        }

        protected int ResolveUsageCycleId(FixedUsageCycleInfo usageCycleInfo)
        {
            int retval = -1;

            try
            {
                m_Logger.LogDebug("Resolving fixed usage cycle info to cycle ID");
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\UsageServer", "__FIND_USAGE_CYCLE__"))
                    {
                        stmt.AddParam("%%CYCLE_TYPE%%", (int)usageCycleInfo.GetCycleType());

                        string partialWhereClause = "";
                        switch (usageCycleInfo.GetCycleType())
                        {
                            case CycleType.Weekly:
                                WeeklyUsageCycyleInfo weekly = ((WeeklyUsageCycyleInfo)usageCycleInfo);
                                partialWhereClause = " and day_of_week = ";
                                partialWhereClause += ((int)weekly.DayOfWeek + 1);

                                m_Logger.LogDebug("Cycle type is Weekly - {0}", weekly.DayOfWeek);
                                break;
                            case CycleType.Bi_Weekly:
                                BiWeeklyUsageCycleInfo biWeekly = ((BiWeeklyUsageCycleInfo)usageCycleInfo);

                                DateTime today = new DateTime(biWeekly.StartYear, biWeekly.StartMonth, biWeekly.StartDay);
                                DateTime y2k = new DateTime(2000, 1, 1);
                                string text = string.Empty;

                                TimeSpan tsDiffBnNowAndY2K = today.Subtract(y2k);
                                int diffDaysBnNowAndY2K = tsDiffBnNowAndY2K.Days;

                                int todayOffset = (diffDaysBnNowAndY2K + 1) % 14;

                                partialWhereClause = " and start_day = ";
                                partialWhereClause += todayOffset;
                                partialWhereClause += " and start_month = 1 and start_year = 2000";

                                m_Logger.LogDebug("Cycle type is Bi-Weekly - day {0}", todayOffset);

                                break;
                            case CycleType.Semi_Monthly:
                                SemiMonthlyUsageCycleInfo semi = ((SemiMonthlyUsageCycleInfo)usageCycleInfo);
                                partialWhereClause += " and first_day_of_month = ";
                                partialWhereClause += semi.Day1;
                                partialWhereClause += " and second_day_of_month = ";
                                partialWhereClause += semi.Day2;

                                m_Logger.LogDebug("Cycle type is Semi-Monthly - {0}/{1}", semi.Day1, semi.Day2);

                                break;
                            case CycleType.Monthly:
                                MonthlyUsageCycleInfo monthly = ((MonthlyUsageCycleInfo)usageCycleInfo);
                                partialWhereClause = " and day_of_month = ";
                                partialWhereClause += monthly.EndDay;

                                m_Logger.LogDebug("Cycle type is Monthly - {0}", monthly.EndDay);

                                break;
                            case CycleType.Quarterly:
                                QuarterlyUsageCycleInfo quarterly = ((QuarterlyUsageCycleInfo)usageCycleInfo);
                                partialWhereClause = " and start_day = ";
                                partialWhereClause += quarterly.StartDay;
                                partialWhereClause += " and start_month = ";
                                partialWhereClause += quarterly.StartMonth;

                                m_Logger.LogDebug("Cycle type is Quarterly - Month:{0} Day: {1}", quarterly.StartMonth, quarterly.StartDay);

                                break;
                            case CycleType.Semi_Annually:
                                SemiAnnualUsageCycleInfo semiannual = ((SemiAnnualUsageCycleInfo)usageCycleInfo);
                                partialWhereClause = " and start_day = ";
                                partialWhereClause += semiannual.StartDay;
                                partialWhereClause += " and start_month = ";
                                partialWhereClause += semiannual.StartMonth;

                                m_Logger.LogDebug("Cycle type is Semi-Annually - Month: {0} Day: {1}", semiannual.StartMonth, semiannual.StartDay);

                                break;

                            case CycleType.Annually:
                                AnnualUsageCycleInfo annual = ((AnnualUsageCycleInfo)usageCycleInfo);
                                partialWhereClause = " and start_day = ";
                                partialWhereClause += annual.StartDay;
                                partialWhereClause += " and start_month = ";
                                partialWhereClause += annual.StartMonth;

                                m_Logger.LogDebug("Cycle type is Annually - Month: {0} Day: {1}", annual.StartMonth, annual.StartDay);

                                break;
                        }

                        stmt.AddParam("%%EXT%%", partialWhereClause);

                        m_Logger.LogDebug("Executing Query");
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                retval = rdr.GetInt32("CycleID");
                            }
                            else
                            {
                                throw new MASBasicException("Unable to locate usage cycle");
                            }
                        }
                    }
                }
            }
            catch (MASBasicException masE)
            {
                throw masE;
            }
            catch (Exception e)
            {
                m_Logger.LogException("Unknown error resolving usage cycle id", e);

                throw new MASBasicException("Unknown error resolving usage cycle ID");
            }
            return retval;
        }

        protected object RetrieveClassName(string name, string classSuffix)
        {
          string typename = String.Format("MetraTech.DomainModel.ProductCatalog.{0}{1}", StringUtils.MakeAlphaNumeric(name.Trim()), classSuffix);
          object o = System.Activator.CreateInstance("MetraTech.DomainModel.ProductCatalog.Generated.dll", typename).Unwrap();
          return o;
        }

        protected object RetrieveClassName(string name)
        {
            string typename = String.Format("MetraTech.DomainModel.ProductCatalog.{0}", StringUtils.MakeAlphaNumeric(name.Trim()));
            object o = System.Activator.CreateInstance("MetraTech.DomainModel.ProductCatalog.Generated.dll", typename).Unwrap();
            return o;
        }

        protected void PopulateLocalizedNamesAndDescriptions(string IDs, Dictionary<LanguageCode, string> displayNames, Dictionary<LanguageCode, string> descriptions)
        {
            if (String.IsNullOrEmpty(IDs.Trim()))
            {
                return;
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\PCWS", "__GET_LOCALIZED_PROPS__"))
                {
                    stmt.AddParam("%%PITYPE_IDS%%", IDs);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr != null && rdr.FieldCount > 0)
                        {
                            while (rdr.Read())
                            {

                                string displayName = (!rdr.IsDBNull("DisplayName")) ? rdr.GetString("DisplayName") : null;
                                string description = (!rdr.IsDBNull("Description")) ? rdr.GetString("Description") : null;

                                if (!rdr.IsDBNull("LanguageCode"))
                                {
                                    LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());


                                    if (displayNames != null && displayName != null)
                                    {
                                        displayNames.Add(langCode, displayName);
                                    }

                                    if (descriptions != null && description != null)
                                    {
                                        descriptions.Add(langCode, description);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void PopulateLocalizedNamesAndDescriptions(BasePriceableItemInstance pi)
        {
          pi.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
          pi.LocalizedDescriptions = new Dictionary<LanguageCode, string>();

          PopulateLocalizedNamesAndDescriptions(pi.ID.ToString(), pi.LocalizedDisplayNames, pi.LocalizedDescriptions);
        }

        protected void PopulateLocalizedNamesAndDescriptions(UnitDependentRecurringChargePITemplate pt)
        {
            pt.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
            pt.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
            PopulateLocalizedNamesAndDescriptions(pt.ID.ToString(), pt.LocalizedDisplayNames, pt.LocalizedDescriptions);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                {
                    queryAdapter.Item = new MTQueryAdapterClass();
                    queryAdapter.Item.Init(PCWS_QUERY_FOLDER);
                    queryAdapter.Item.SetQueryTag("__GET_UNITDISPLAY_NAME_FROM_T_DESC__");
                    string rawSql = queryAdapter.Item.GetRawSQLQuery(true);

                    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(rawSql))
                    {
                        stmt.AddParam("id_prop", MTParameterType.Integer, pt.ID);

                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            if (rdr != null && rdr.FieldCount > 0)
                            {
                                pt.LocalizedUnitDisplayNames = new Dictionary<LanguageCode, string>();
                                while (rdr.Read())
                                {

                                    string displayName = (!rdr.IsDBNull("DisplayName")) ? rdr.GetString("DisplayName") : null;
                                    
                                    if (!rdr.IsDBNull("LanguageCode"))
                                    {
                                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                                        pt.LocalizedUnitDisplayNames.Add(langCode, displayName);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void PopulateLocalizedNamesAndDescriptions(UnitDependentRecurringChargePIInstance pi)
        {
            PopulateLocalizedNamesAndDescriptions((BasePriceableItemInstance)pi);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC_PCWS__"))
                {
                    stmt.AddParam("%%ID_PROP%%", pi.ID);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {

                        if (rdr != null && rdr.FieldCount > 0)
                        {
                            int idxUnitDisplayId = rdr.GetOrdinal("n_unit_display_name");
                            StringBuilder paramBuilder = new StringBuilder();

                            while (rdr.Read())
                            {
                                paramBuilder.Append(rdr.GetInt32(idxUnitDisplayId).ToString() + ",");
                            }

                            paramBuilder.Remove(paramBuilder.Length - 1, 1);

                            PopulateLocalizedNamesAndDescriptions(paramBuilder.ToString(), pi.LocalizedUnitDisplayNames, null);
                        }
                    }
                }
            }
        }


        protected void AddExtendedCycleIDsToQuery(IMTAdapterStatement adapterStmt, ExtendedUsageCycleInfo usageCycleInfo)
        {
            string mode;
            int? cycleId, cycleTypeId;

            ResolveUsageCycleInfo(usageCycleInfo, out mode, out cycleId, out cycleTypeId);

            adapterStmt.AddParam("%%TX_CYCLE_MODE%%", mode);
            if (cycleId.HasValue)
            {
                adapterStmt.AddParam("%%ID_USAGE_CYCLE%%", cycleId.Value);
            }
            else
            {
                adapterStmt.AddParam("%%ID_USAGE_CYCLE%%", null);
            }

            if (cycleTypeId.HasValue)
            {
                adapterStmt.AddParam("%%ID_CYCLE_TYPE%%", cycleTypeId.Value);
            }
            else
            {
                adapterStmt.AddParam("%%ID_CYCLE_TYPE%%", null);
            }
        }

        protected void AddCycleIDsToQuery(IMTAdapterStatement adapterStmt, UsageCycleInfo usageCycleInfo)
        {
            object cycleTypeId = null;
            object cycleId = null;

            if (usageCycleInfo.GetType().IsSubclassOf(typeof(FixedUsageCycleInfo)))
            {
                cycleId = ResolveUsageCycleId(((FixedUsageCycleInfo)usageCycleInfo));
            }
            else
            {
                RelativeUsageCycleInfo relCycle = ((RelativeUsageCycleInfo)usageCycleInfo);

                if (relCycle.UsageCycleType.HasValue)
                {
                    cycleTypeId = (int)relCycle.UsageCycleType.Value;
                }
            }

            adapterStmt.AddParam("%%ID_USAGE_CYCLE%%", cycleId);
            adapterStmt.AddParam("%%ID_CYCLE_TYPE%%", cycleTypeId);
        }


        protected RateEntry GetRateEntry(Type rateEntryType, Type defauldRateEntryType, PropertyInfo[] rateEntryProperties, IMTDataReader rdr, out bool bIsDefaultRateEntry)
        {
            try
            {
                bIsDefaultRateEntry = false;

                RateEntry rateEntry = (RateEntry)Activator.CreateInstance(rateEntryType);
                rateEntry.RateScheduleId = rdr.GetInt32("ScheduleID");
                rateEntry.Index = rdr.GetInt32("RateIndex");
                bool bSawConditions = false;
                bool bSawActions = false;
                foreach (PropertyInfo prop in rateEntryProperties)
                {
                  object[] rateEntryAttribs = prop.GetCustomAttributes(typeof(MTRateEntryMetadataAttribute), false);

                  if (rateEntryAttribs.Length > 0)
                  {
                    MTRateEntryMetadataAttribute attr = ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]);

                    string columnName = String.Format("c_{0}", attr.ColumnName);

                    int idxColumn = rdr.GetOrdinal(columnName);
                    if (!rdr.IsDBNull(idxColumn))
                    {
					
                        bSawConditions = bSawConditions || attr.IsCondition;
                        bSawActions = bSawActions || attr.IsAction;						
						
                        object value = GetValue(idxColumn, prop, rdr);

                        if (value != null)
                        {
                            prop.SetValue(rateEntry, value, null);
                        }
                    }
                  }
                }

                if (!bSawConditions && bSawActions)
                {                    
                    RateEntry defaultRateEntry = (RateEntry)Activator.CreateInstance(defauldRateEntryType);

                    List<PropertyInfo> defaultRateEntryProperties = defaultRateEntry.GetMTProperties();

                    foreach (PropertyInfo prop in defaultRateEntryProperties)
                    {
                        prop.SetValue(defaultRateEntry, rateEntry.GetProperty(prop.Name).GetValue(rateEntry, null), null);
                    }

                    bIsDefaultRateEntry = true;

                    rateEntry = defaultRateEntry;
                }
                else if (!(bSawConditions || bSawActions))
                {
                    throw new MASBasicException(String.Format("Rate entry {0} has no conditions or actions", rateEntryType.ToString())); 
                }

                return rateEntry;
            }
            catch (MASBasicException masE)
            {
                throw masE;
            }
            catch (Exception e)
            {
                m_Logger.LogException(String.Format("Failed to create a rate entry: {0}", rateEntryType.ToString()), e);

                throw new MASBasicException(String.Format("Failed to create a rate entry: {0}", rateEntryType.ToString()));
            }
        }

        /// <summary>
        /// Get the default non-shared pricelist for a PO
        /// </summary>
        /// <param name="poId"> Product offering ID </param>
        /// <returns> default non-shared pricelist ID </returns>		
        protected int? GetDefaultNonSharedPriceListForPO(int poId)
        {
            int? priceListId = null;

            using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_DEFAULT_NON_SHARED_PRICELIST_FOR_PO__"))
                {
                    stmt.AddParam("%%PO_ID%%", poId);
                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            priceListId = rdr.GetInt32("PriceListId");
                        }
                    }
                }
            }
            return priceListId;
        }


        protected void PopulateExtendedProperties(BaseObject bpi, int Id)
        {
            // Populate Extended Properties on object
            string columnList = "";
            string tableName = "";
            Dictionary<string, PropertyInfo> epMap = new Dictionary<string, PropertyInfo>();
            List<PropertyInfo> props = GetExtendedProperyInfos(bpi);
            foreach (PropertyInfo prop in props)
            {
                object[] columnName = prop.GetCustomAttributes(typeof(MTExtendedPropertyAttribute), false);
                for (int c = 0; c < columnName.Length; c++)
                {
                    MTExtendedPropertyAttribute a = (MTExtendedPropertyAttribute)columnName[c];
                    columnList += a.ColumnName + ",";
                    if (tableName.Length == 0)
                        tableName = a.TableName;
                    epMap.Add(a.ColumnName.ToLower(), prop);
                }
            }

            if (columnList.Length > 0)
            {
                // remove trailing comma
                int length = columnList.Length - 1;
                columnList = columnList.Remove(length, 1);

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement getEPPropStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__POPULATE_EXTENDED_PROPS__"))
                    {
                        getEPPropStmt.AddParam("%%COLUMN_LIST%%", columnList);
                        getEPPropStmt.AddParam("%%TABLE_NAME%%", tableName);
                        getEPPropStmt.AddParam("%%ID_TEMPLATE%%", Id);

                        using (IMTDataReader epReader = getEPPropStmt.ExecuteReader())
                        {
                            while (epReader.Read())
                            {
                                for (int i = 0; i < epReader.FieldCount; i++)
                                {
                                    // 
                                    string fieldName = epReader.GetName(i).Trim();
                                    PropertyInfo p = epMap[fieldName];

                                    if (!epReader.IsDBNull(i))
                                    {
                                        p.SetValue(bpi, GetValue(i, p, epReader), null);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        #endregion

        #region Protected static methods

        protected static List<PropertyInfo> GetProperties(Type type)
        {
            List<PropertyInfo> properties = null;

            lock (m_CachedTypeBasedProperties)
            {
                if (m_CachedTypeBasedProperties.ContainsKey(type))
                {
                    properties = m_CachedTypeBasedProperties[type];
                }
                else
                {
                    properties = new List<PropertyInfo>(type.GetProperties());
                    m_CachedTypeBasedProperties.Add(type, properties);
                }
            }

            return properties;
        }

        protected static List<PropertyInfo> GetExtendedProperyInfos(BaseObject instance)
        {
            List<PropertyInfo> retval = null;

            lock (mExendedPropertyProperties)
            {
                if (mExendedPropertyProperties.ContainsKey(instance.GetType()))
                {
                    retval = mExendedPropertyProperties[instance.GetType()];
                }
                else
                {
                    retval = new List<PropertyInfo>();

                    List<PropertyInfo> mtProperties = instance.GetMTProperties();

                    foreach (PropertyInfo prop in mtProperties)
                    {
                        object[] customAttribs = prop.GetCustomAttributes(typeof(MTExtendedPropertyAttribute), false);
                        if (customAttribs != null && customAttribs.Length > 0)
                        {
                            retval.Add(prop);
                        }
                    }

                    mExendedPropertyProperties[instance.GetType()] = retval;
                }
            }

            return retval;
        }

        static public object GetValue(String col, PropertyInfo prop, IMTDataReader reader)
        {
            return GetValue(reader.GetOrdinal(col), prop.PropertyType, reader);
        }

        static public object GetValue(int columnIndex, PropertyInfo prop, IMTDataReader reader)
        {
            return GetValue(columnIndex, prop.PropertyType, reader);
        }

        static public object GetValue(String col, Type targetType, IMTDataReader reader)
        {
            return GetValue(reader.GetOrdinal(col), targetType, reader);
        }

        static public object GetValue(int columnIndex, Type targetType, IMTDataReader reader)
        {
            object value = reader.GetValue(columnIndex);

            if (value is DBNull)
            {
                return null;
            }

            Type type = targetType;

            if (type.IsGenericType && type.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
            {
                Type[] genericTypes = type.GetGenericArguments();

                type = genericTypes[0];
            }
            
            if (type.IsEnum)
            {
              object result = null;

              //if there are problems with retrieving of the value we will return null. Exception wouldn't be thrown
              try
              {
                if (type.Equals(typeof(RateEntryOperators)))
                {
                  result = MakeRateEntryOperator((string)value);
                }
                else
                {
                  if (value is String)
                  {
                    result = EnumHelper.GetGeneratedEnumByEntry(type, (string)value);
                  }
                  else
                  {
                    result = EnumHelper.GetCSharpEnum(System.Convert.ToInt32(value));
                  }
                }
              }
              catch (Exception)
              {
                m_Logger.LogDebug("GetValue(): Unable to get the Enum {0} value. Rerurning null", type.ToString());
              }

              return result;
            }
            else
            {
                if (type.IsValueType)
                {
                    if (type.Equals(typeof(bool)))
                    {
                        if (value.GetType().Equals(typeof(string)))
                        {
                            return StringUtils.ConvertToBoolean(((string)reader.GetValue(columnIndex)).Trim());
                        }
                        else
                        {
                            return value;
                        }
                    }
                    else if (type.Equals(typeof(System.Int32)))
                    {
                        if (value.GetType().Equals(typeof(System.Int64)))
                        {
                            return System.Convert.ToInt32(reader.GetInt64(columnIndex));
                        }
                        else
                        {
                            return reader.GetInt32(columnIndex);
                        }
                    }
                    else if (type.Equals(typeof(System.Int64)))
                    {
                        if (value.GetType().Equals(typeof(System.Int32)))
                        {
                            return System.Convert.ToInt64(reader.GetInt32(columnIndex));
                        }
                        else
                        {
                            return reader.GetInt64(columnIndex);
                        }
                    }
                    else
                    {
                        return value;
                    }
                }
                else
                {
                    if (value is string)
                    {
                        return value;
                    }
                    else
                    {
                        object converted = Activator.CreateInstance(type);
                        converted = value;
                        return converted;
                    }
                }
            }
        }

        static private object MakeRateEntryOperator(string value)
        {
            object retval = null;
            switch (value)
            {
                case "=":
                    retval = RateEntryOperators.Equal;
                    break;
                case ">":
                    retval = RateEntryOperators.Greater;
                    break;
                case ">=":
                    retval = RateEntryOperators.GreaterEqual;
                    break;
                case "<":
                    retval = RateEntryOperators.Less;
                    break;
                case "<=":
                    retval = RateEntryOperators.LessEqual;
                    break;
                case "!=":
                    retval = RateEntryOperators.NotEqual;
                    break;
            }

            return retval;
        }


        /// <summary>
        /// Populates Cycle properties from template to instance.
        /// </summary>
        /// <param name="piInstanceCycleInfo">Instance Cycle property </param>
        /// <param name="piTemplateCycleInfo">Template Cycle property</param>
        protected void PopulateCycleProperties(ref ExtendedUsageCycleInfo piInstanceCycleInfo, ExtendedUsageCycleInfo piTemplateCycleInfo)
        {

            PropertyInfo[] cycleProps = piTemplateCycleInfo.GetType().GetProperties();

            //Change Cyle Type if mismatch.
            if (piInstanceCycleInfo == null || piInstanceCycleInfo.GetType() != piTemplateCycleInfo.GetType())
            {
                piInstanceCycleInfo = Activator.CreateInstance(piTemplateCycleInfo.GetType()) as ExtendedUsageCycleInfo;
            }

            //Ignore  "UsageCycleTypeValueDisplayName" property. It is setting usagecycletype property internally.
            var filterQuery = from p in cycleProps
                        where !p.Name.ToLower().Contains("displayname") &&
                        piTemplateCycleInfo.GetProperty(p.Name) is PropertyInfo
                        select p;

            foreach (PropertyInfo pinfo in filterQuery)
            {
                if (piTemplateCycleInfo.GetValue(pinfo.Name) != null &&
                    !piInstanceCycleInfo.IsDirtyProperty(pinfo))
                {
                    piInstanceCycleInfo.SetValue(pinfo.Name, piTemplateCycleInfo.GetValue(pinfo.Name));
                }
            }
        }

        #endregion
    }
}
