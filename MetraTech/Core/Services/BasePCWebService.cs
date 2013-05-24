using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using System.Reflection;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.Interop.MTAuth;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Collections;
using System.IO;
using System.ComponentModel;
using MetraTech.Interop.QueryAdapter;


namespace MetraTech.Core.Services
{
    public abstract class BasePCWebService : CMASServiceBase
    {
        #region Protected Members
        protected const string PCWS_QUERY_FOLDER = @"queries\PCWS";
        protected const string ADJUSTMENT_QUERY_FOLDER = @"queries\Adjustments";
        protected const string PROD_CATALOG_QUERY_FOLDER = @"queries\ProductCatalog";

        protected const int PRODUCT_OFFERING_KIND = 100;
        protected const int TIMESPAN_KIND = 160;
        protected const int PRICELIST_KIND = 150;
        protected const int NON_SHARED_PL_TYPE = 2;
        protected const int ADJUSTMENT_TYPE = 340;
        protected const int RATE_SCHEDULE_KIND = 130;
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

        protected int CreateBaseProps(IMTSessionContext apCTX, string aName, string aDescription, string aDisplayName, int nKind)
        {
            int retVal = -1;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("InsertBasePropsV2"))
                {
                    stmt.AddParam("id_lang_code", MTParameterType.Integer, apCTX.LanguageID);
                    stmt.AddParam("a_kind", MTParameterType.Integer, nKind);
                    stmt.AddParam("a_approved", MTParameterType.WideString, "N");
                    stmt.AddParam("a_archive", MTParameterType.WideString, "N");
                    stmt.AddParam("a_nm_name", MTParameterType.WideString, !string.IsNullOrEmpty(aName) ? aName : null);
                    stmt.AddParam("a_nm_desc", MTParameterType.WideString, !string.IsNullOrEmpty(aDescription) ? aDescription : null);
                    stmt.AddParam("a_nm_display_name", MTParameterType.WideString, !string.IsNullOrEmpty(aDisplayName) ? aDisplayName : null);
                    stmt.AddOutputParam("a_id_prop", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();
                    retVal = (int)stmt.GetOutputValue("a_id_prop");
                }
            }
            return retVal;

        }

        protected void UpdateBaseProps(IMTSessionContext apCTX, string aDescription, bool isDescriptionDirty, string aDisplayName, bool isDisplayNameDirty, int aID)
        {
            string oldName = null, oldDesc= null, oldDispName=null;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(BasePCWebService.PCWS_QUERY_FOLDER, "__GET_BASE_PROPS_FOR_UPDATE__"))
                {
                    stmt.AddParam("%%ID_PROP%%", aID);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            oldName = (!rdr.IsDBNull("nm_name")) ? rdr.GetString("nm_name") : null;
                            oldDesc = (!rdr.IsDBNull("nm_desc")) ? rdr.GetString("nm_desc") : null;
                            oldDispName = (!rdr.IsDBNull("nm_display_name")) ? rdr.GetString("nm_display_name") : null;
                        }
                        else
                        {
                            throw new MASBasicException(string.Format("Base properties for {0} do not exist for update", aID));
                        }
                    }
                }


                using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("UpdateBaseProps"))
                {
                    callableStmt.AddParam("a_id_prop", MTParameterType.Integer, aID);
                    callableStmt.AddParam("a_id_lang", MTParameterType.Integer, apCTX.LanguageID);
                    callableStmt.AddParam("a_nm_name", MTParameterType.WideString, oldName);
                    callableStmt.AddParam("a_nm_desc", MTParameterType.WideString, isDescriptionDirty ? (aDescription.Length > 0 ? aDescription : null) : oldDesc);
                    callableStmt.AddParam("a_nm_display_name", MTParameterType.WideString, isDisplayNameDirty ? (aDisplayName.Length > 0 ? aDisplayName : null) : oldDispName);
                    callableStmt.ExecuteNonQuery();
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
                    string val = FormatValueForDB(instValue);

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

        protected int CreateEffectiveDate(IMTSessionContext context, ProdCatTimeSpan effectiveDate)
        {
            int effDateId = CreateBaseProps(context, "", "", "", TIMESPAN_KIND);

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement updateDtStmt = conn.CreateAdapterStatement("queries\\PCWS", "__ADD_EFF_DATE__"))
                {
                    updateDtStmt.AddParam("%%ID_EFF_DATE%%", effDateId);

                    ValidateAndSetEffectiveDate(updateDtStmt, effectiveDate);

                    updateDtStmt.ExecuteNonQuery();
                }
            }

            return effDateId;
        }

        protected void UpdateEffectiveDate(ProdCatTimeSpan effectiveDate)
        {
            UpdateEffectiveDate(effectiveDate, String.Format("{0}", effectiveDate.TimeSpanId.Value));
        }

        protected void UpdateAvailableDateForPO(int idPo, ProdCatTimeSpan effectiveDate)
        {
            UpdateEffectiveDate(effectiveDate, String.Format("(select id_avail from t_po where id_po = {0})", idPo));
        }

        protected void UpdateEffectiveDateForPO(int idPo, ProdCatTimeSpan effectiveDate)
        {
            UpdateEffectiveDate(effectiveDate, String.Format("(select id_eff_date from t_po where id_po = {0})", idPo));
        }

        protected void UpdateEffectiveDate(ProdCatTimeSpan effectiveDate, string condition)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement updateDtStmt = conn.CreateAdapterStatement("queries\\PCWS", "__UPDATE_EFF_DATE_PCWS__"))
                {
                    updateDtStmt.AddParam("%%ID_EFF_DATE%%", condition);

                    ValidateAndSetEffectiveDate(updateDtStmt, effectiveDate);

                    updateDtStmt.ExecuteNonQuery();
                }
            }
        }

        protected void ValidateAndSetEffectiveDate(IMTAdapterStatement updateDtStmt, ProdCatTimeSpan effectiveDate)
        {
		// I've tried to rationalize the behavior here with what the UI does when you don't set a value.
		//  In those cases, it sets the the date type to Null, which is then interpreted to mean no start
		//  date or no end date.  Logically, you might expect that to be expressed with the type NoDate,
		//  but NoDate breaks all the places expecting it to be Null, and the UI gets messed up.
		//
		//  So I'm using NoDate to mean null was passed in, although this should never happen anyway.
            if (effectiveDate == null)
            {
                updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
                updateDtStmt.AddParam("%%START_DATE%%", null);
                updateDtStmt.AddParam("%%END_DATE%%", null);
                updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
                updateDtStmt.AddParam("%%BEGIN_OFFSET%%", 0);
                updateDtStmt.AddParam("%%END_OFFSET%%", 0);
                return;
            }
            if (effectiveDate.StartDate.HasValue)
            {
                if (effectiveDate.StartDate.Value > MetraTime.Max)
                {
                    effectiveDate.StartDate = MetraTime.Max;
                }
                if (effectiveDate.StartDate.Value < MetraTime.Min)
                {
                    effectiveDate.StartDate = MetraTime.Min;
                }
                updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.Absolute);
                updateDtStmt.AddParam("%%START_DATE%%", effectiveDate.StartDate.Value);
            }
            else
            {
              updateDtStmt.AddParam("%%BEGIN_TYPE%%", ProdCatTimeSpan.MTPCDateType.NoDate);
                updateDtStmt.AddParam("%%START_DATE%%", null);
            }

            if (effectiveDate.StartDateOffset.HasValue)
                updateDtStmt.AddParam("%%BEGIN_OFFSET%%", effectiveDate.StartDateOffset.Value);
            else
                updateDtStmt.AddParam("%%BEGIN_OFFSET%%", 0);

            if (effectiveDate.EndDate.HasValue)
            {
                if (effectiveDate.EndDate.Value > MetraTime.Max)
                {
                    effectiveDate.EndDate = MetraTime.Max;
                }
                else if (effectiveDate.EndDate.Value < MetraTime.Min)
                {
                    effectiveDate.EndDate = MetraTime.Min;
                }
                else if (effectiveDate.StartDate.HasValue)
                {
                    if (effectiveDate.EndDate.Value < effectiveDate.StartDate.Value)
                    {
                        throw new MASBasicException("Incorrect Start / End date values. Start date appears to be after the end date.");
                    }
                }

                updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.Absolute);
                updateDtStmt.AddParam("%%END_DATE%%", effectiveDate.EndDate.Value);
            }
            else
            {
                updateDtStmt.AddParam("%%END_DATE%%", null);
                updateDtStmt.AddParam("%%END_TYPE%%", ProdCatTimeSpan.MTPCDateType.Null);
            }

            if (effectiveDate != null && effectiveDate.EndDateOffset.HasValue)
                updateDtStmt.AddParam("%%END_OFFSET%%", effectiveDate.EndDateOffset.Value);
            else
                updateDtStmt.AddParam("%%END_OFFSET%%", 0);
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

        internal class RateScheduleHolder : BaseRateSchedule
        {
            // Only need this class so that can use BaseRateSchedule properties while having it still be abstract
        }

        protected enum PricelistTypes
        {
            DEFAULT = 0,
            ICB_SUB = 1,
            ICB_GSUB = 2
        }

        protected void UpsertRateSchedulesForPricelist(int pricelistId,
                                                        PricelistTypes plType,
                                                        int templateId, 
                                                        int paramTableId, 
                                                        IList rateSchedules)
        {
            Dictionary<int, RateScheduleHolder> existingSchedules = new Dictionary<int, RateScheduleHolder>();
            string startDt = FormatValueForDB(MetraTime.Now);
            string endDt = FormatValueForDB(MetraTime.Max);
            string paramTableTableName = CacheManager.ParamTableIdToNameMap[paramTableId].TableName;
            string paramTableName = CacheManager.ParamTableIdToNameMap[paramTableId].Name;
            string details;
            int auditID;

            if (rateSchedules != null && rateSchedules.Count > 0)
            {
                #region Load existing rate schedules
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_RATESCHEDS_FOR_PT__"))
                    {
                        stmt.AddParam("%%PRICELIST_ID%%", pricelistId);
                        stmt.AddParam("%%PT_ID%%", paramTableId);
                        stmt.AddParam("%%PI_TEMPL_ID%%", templateId);

                        if (!conn.ConnectionInfo.IsOracle)
                        {
                            stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
                        }
                        else
                        {
                            stmt.AddParam("%%UPDLOCK%%", "");
                        }

                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                RateScheduleHolder holder = new RateScheduleHolder();

                                holder.ID = rdr.GetInt32("ID");
                                holder.EffectiveDate = GetEffectiveDate(rdr, "Effective");

                                if (!rdr.IsDBNull("Description"))
                                {
                                    holder.Description = rdr.GetString("Description");
                                }

                                existingSchedules.Add(holder.ID.Value, holder);
                            }
                        }
                    }
                }
                #endregion

                #region Merge Existing RateSchedule info
                foreach (BaseRateSchedule brs in rateSchedules)
                {
                    if (brs.ID.HasValue && existingSchedules.ContainsKey(brs.ID.Value))
                    {
                        RateScheduleHolder holder = existingSchedules[brs.ID.Value];

                        if (!brs.IsDescriptionDirty)
                        {
                            brs.Description = holder.Description;
                        }

                        if (!brs.IsEffectiveDateDirty)
                        {
                            brs.EffectiveDate = holder.EffectiveDate;
                        }
                    }
                    else if (brs.ID.HasValue)
                    {
                        throw new MASBasicException(string.Format("Unable to locate rate schedule with ID {0}", brs.ID.Value));
                    }
                }
                #endregion

                foreach (BaseRateSchedule brs in rateSchedules)
                {
                    if (brs.ID.HasValue)
                    {
                        #region Update Rate Schedule
                        
                        #region Update Effective Dates
                        if (brs.IsEffectiveDateDirty)
                        {
                            UpdateEffectiveDate(brs.EffectiveDate);
                        }
                        #endregion

                        #region Update Base Props
                        if (brs.Description != null)
                        {
                            UpdateBaseProps(GetSessionContext(), brs.Description, true, "", false, brs.ID.Value);
                        }
                        else
                        {
                            UpdateBaseProps(GetSessionContext(), "", true, "", false, brs.ID.Value);
                        }
                        #endregion

                        #region Set end date on existing Rate Entries
                        using (IMTConnection conn = ConnectionManager.CreateConnection())
                        {
                          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__SET_ENDDATE_FOR_CURRENT_RATES_PCWS__"))
                            {
                                stmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                                stmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                                stmt.AddParam("%%TT_START%%", startDt, true);

                                stmt.ExecuteNonQuery();
                            }
                        }
                        #endregion

                        #region Add audit entry
                        AuditManager.MTAuditEvents eventType = 0;
                        switch (plType)
                        {
                            case PricelistTypes.DEFAULT:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_RS_UPDATE;
                                break;
                            case PricelistTypes.ICB_SUB:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_ICB_UPDATE;
                                break;
                            case PricelistTypes.ICB_GSUB:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_GROUP_ICB_UPDATE;
                                break;
                        }

                        details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0, paramTableName, brs.ID.Value);
                        auditID = AuditManager.FireEvent(
                            (int)eventType,
                            GetSessionContext().AccountID,
                            (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                            brs.ID.Value,
                            details);
                        #endregion

                        #endregion

                        // Remove from existing schedules so that it doesn't get deleted below
                        existingSchedules.Remove(brs.ID.Value);
                    }
                    else
                    {
                        #region Add new Rate Schedule

                        #region Create Effective Date
                        if (brs.EffectiveDate == null)
                        {
                            ProdCatTimeSpan timeSpan = new ProdCatTimeSpan();
                            brs.EffectiveDate = timeSpan;
                            brs.EffectiveDate.TimeSpanId = CreateEffectiveDate(GetSessionContext(), timeSpan);
                        }
                        else
                            brs.EffectiveDate.TimeSpanId = CreateEffectiveDate(GetSessionContext(), brs.EffectiveDate);
                        #endregion

                        #region Create Base Props
                        if (brs.Description != null)
                            brs.ID = CreateBaseProps(GetSessionContext(), "", brs.Description, "", RATE_SCHEDULE_KIND);
                        else
                            brs.ID = CreateBaseProps(GetSessionContext(), "", "", "", RATE_SCHEDULE_KIND);
                        #endregion

                        #region Insert RateSchedule record
                        using (IMTConnection conn = ConnectionManager.CreateConnection())
                        {
                          using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_RSCHED_PCWS__"))
                            {
                                adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                                adapterStmt.AddParam("%%ID_PT%%", paramTableId);
                                adapterStmt.AddParam("%%ID_EFFDATE%%", brs.EffectiveDate.TimeSpanId.Value);
                                adapterStmt.AddParam("%%PRICELIST_ID%%", pricelistId);
                                adapterStmt.AddParam("%%ID_TMPL%%", templateId);
                                adapterStmt.AddParam("%%SYS_DATE%%", MetraTime.Now);

                                adapterStmt.ExecuteNonQuery();
                            }
                        }
                        #endregion

                        #region Add audit entry
                        AuditManager.MTAuditEvents eventType = 0;
                        switch (plType)
                        {
                            case PricelistTypes.DEFAULT:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_RS_CREATE;
                                break;
                            case PricelistTypes.ICB_SUB:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_ICB_CREATE;
                                break;
                            case PricelistTypes.ICB_GSUB:
                                eventType = AuditManager.MTAuditEvents.AUDITEVENT_GROUP_ICB_CREATE;
                                break;
                        }

                        details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0, paramTableName, brs.ID.Value);
                        auditID = AuditManager.FireEvent(
                            (int)eventType,
                            GetSessionContext().AccountID,
                            (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                            brs.ID.Value,
                            details);
                        #endregion

                        #endregion
                    }

                    // Save rules
                    #region Add audit entry
                    details = string.Format("Price List: {0}, Price List Id: {1}, ParamTable: {2}, Rate Schedule Id: {3}", "", 0, paramTableName, brs.ID.Value);
                    auditID = AuditManager.FireEvent(
                        (int)AuditManager.MTAuditEvents.AUDITEVENT_RS_RULE_UPDATE,
                        GetSessionContext().AccountID,
                        (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                        brs.ID.Value,
                        details);
                    #endregion

                    #region Insert rate entries
                    PropertyInfo rateEntriesProp = brs.GetProperty("RateEntries");
                    IList rateEntriesList = rateEntriesProp.GetValue(brs, null) as IList;

                    string columns = "";
                    string insertValues = "";
                    int entryIndex = 0;
                    List<PropertyInfo> rateEntryProperties = null;

                    if (rateEntriesList.Count > 0)
                    {
                        SortedList<int, object> sortedEntries = new SortedList<int, object>();

                        foreach (RateEntry entry in rateEntriesList)
                        {
                            sortedEntries.Add(entry.Index, entry);
                        }

                        string queryBatch = "Begin\n";
                        using (IMTConnection conn = ConnectionManager.CreateConnection())
                        {
                            using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RATE_PCWS__"))
                            {

                                rateEntryProperties = ((BaseObject)rateEntriesList[0]).GetMTProperties();
                                foreach (object rateEntry in sortedEntries.Values)
                                {
                                    columns = "";
                                    insertValues = "";

                                    foreach (PropertyInfo rateEntryProp in rateEntryProperties)
                                    {
                                        object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(typeof(MTRateEntryMetadataAttribute), false);
                                        if (rateEntryAttribs.Length > 0)
                                        {
                                            object value = rateEntryProp.GetValue(rateEntry, null);
                                            string valueForDB = FormatValueForDB(value);

                                            object[] deAttribs = rateEntryProp.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

                                            if (deAttribs.HasValue() &&
                                                ((MTDataMemberAttribute)deAttribs[0]).IsRequired &&
                                                (valueForDB == null || (valueForDB != null && valueForDB.Equals("NULL", StringComparison.OrdinalIgnoreCase))))
                                            {
                                                m_Logger.LogError(string.Format("Requied Field  - {0} - not set in rate entry object", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName));
                                                throw new MASBasicException(string.Format("Requied Field  - {0} - not set in rate entry object", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName));
                                            }
                                            columns += string.Format("c_{0}, ", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName);


                                            insertValues += string.Format("{0}, ", FormatValueForDB(value));
                                        }
                                    }

                                    adapterStmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                                    adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                                    adapterStmt.AddParam("%%TT_START%%", startDt, true);
                                    adapterStmt.AddParam("%%TT_END%%", endDt, true);
                                    adapterStmt.AddParam("%%ID_AUDIT%%", auditID);
                                    adapterStmt.AddParam("%%COLUMNS%%", columns.Remove(columns.LastIndexOf(',')), true);

                                    adapterStmt.AddParam("%%ORDER%%", entryIndex++);
                                    adapterStmt.AddParam("%%VALUES%%", insertValues.Remove(insertValues.LastIndexOf(',')), true);

                                    queryBatch += string.Format("{0};\n", adapterStmt.Query);

                                    adapterStmt.ClearQuery();
                                }
                            }
                        }

                        queryBatch += "\nEnd;";

                        try
                        {
                            using (IMTConnection conn = ConnectionManager.CreateConnection())
                            {
                                using (IMTStatement stmt = conn.CreateStatement(queryBatch))
                                {
                                    stmt.ExecuteNonQuery();
                                }
                            }
                        }
                        catch (Exception e)
                        {
                            m_Logger.LogException("Error inserting rate entries", e);
                            throw new MASBasicException("Error inserting rate entries");
                        }
                    }
                    #endregion

                    #region Insert Default Rate Entry
                    columns = "";
                    insertValues = "";

                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                      using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RATE_PCWS__"))
                        {

                            PropertyInfo defaultRateEntryProp = brs.GetProperty("DefaultRateEntry");
                            object defaultRateEntry = defaultRateEntryProp.GetValue(brs, null);

                            if (defaultRateEntry != null)
                            {
                                rateEntryProperties = ((BaseObject)defaultRateEntry).GetMTProperties();
                                foreach (PropertyInfo rateEntryProp in rateEntryProperties)
                                {
                                    object[] rateEntryAttribs = rateEntryProp.GetCustomAttributes(typeof(MTRateEntryMetadataAttribute), false);

                                    if (rateEntryAttribs.Length > 0)
                                    {
                                        columns += string.Format("c_{0}, ", ((MTRateEntryMetadataAttribute)rateEntryAttribs[0]).ColumnName); ;

                                        object value = rateEntryProp.GetValue(defaultRateEntry, null);
                                        insertValues += string.Format("{0}, ", FormatValueForDB(value));
                                    }
                                }

                                adapterStmt.AddParam("%%TABLE_NAME%%", paramTableTableName);
                                adapterStmt.AddParam("%%ID_SCHED%%", brs.ID.Value);
                                adapterStmt.AddParam("%%TT_START%%", startDt, true);
                                adapterStmt.AddParam("%%TT_END%%", endDt, true);
                                adapterStmt.AddParam("%%ID_AUDIT%%", auditID);
                                adapterStmt.AddParam("%%COLUMNS%%", columns.Remove(columns.LastIndexOf(',')), true);

                                adapterStmt.AddParam("%%ORDER%%", entryIndex++);
                                adapterStmt.AddParam("%%VALUES%%", insertValues.Remove(insertValues.LastIndexOf(',')), true);

                                try
                                {
                                    adapterStmt.ExecuteNonQuery();
                                }
                                catch (Exception e)
                                {
                                    m_Logger.LogException("Error inserting default rate entry", e);
                                    throw new MASBasicException("Error inserting default rate entry");
                                }
                            }
                        }
                    }

                    #endregion

                }

                #region Delete any existing RateSchedules not in submitted collection
                foreach (int rsID in existingSchedules.Keys)
                {
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTCallableStatement stmt = conn.CreateCallableStatement("DeleteRateSchedule"))
                        {
                            stmt.AddParam("schedId", MTParameterType.Integer, rsID);
                            stmt.AddOutputParam("status", MTParameterType.Integer);

                            stmt.ExecuteNonQuery();
                        }
                    }

                    details = string.Format("Rate Schedule Id: {0}", rsID);
                    auditID = AuditManager.FireEvent(
                        (int)AuditManager.MTAuditEvents.AUDITEVENT_RS_DELETE,
                        GetSessionContext().AccountID,
                        (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT,
                        -1,
                        details);
                }
                #endregion
            }
            else
            {
                #region Delete all RateSchedules on pricelist for parameter table
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("DeleteRateSchedules"))
                    {
                        callableStmt.AddParam("plId", MTParameterType.Integer, pricelistId);
                        callableStmt.AddParam("piTemp", MTParameterType.Integer, templateId);
                        callableStmt.AddParam("ptId", MTParameterType.Integer, paramTableId);
                        callableStmt.AddOutputParam("status", MTParameterType.Integer);
                        callableStmt.ExecuteNonQuery();
                    }
                }
                #endregion
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

    public static class Extensions
    {
        /// <summary>
        /// Returns true if array is not null and has values defined.
        /// </summary>
        /// <param name="items"></param>
        /// <returns>boolean</returns>
        public static bool HasValue(this object[] items)
        {
            return (items != null && items.Count() > 0);
        }
        /// <summary>
        /// Returns true if collection is not null and has items in it.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="items"></param>
        /// <returns>boolean</returns>
        public static bool HasValue<T>(this IEnumerable<T> items)
        {
            return (items != null && items.Count() > 0);
        }
        
    }
}
