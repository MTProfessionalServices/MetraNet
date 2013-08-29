using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Reflection;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Application;
using MetraTech.Domain;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Core.Global;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.RCD;
using System.Transactions;
using MetraTech.DomainModel.Enums.Core.Metratech_com_calendar;
using MetraTech.Debug.Diagnostics;
using DatabaseUtils = MetraTech.Domain.DataAccess.DatabaseUtils;

namespace MetraTech.Core.Services
{
  [ServiceContract]
  public interface IProductCatalogService
  {
    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceableItemTypes(ref MTList<PriceableItemType> piTypes);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceableItemType(PCIdentifier piTypeID, out PriceableItemType piType);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceableItemTemplates(ref MTList<BasePriceableItemTemplate> piTemplates);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetPriceableItemTemplate(PCIdentifier piTemplateID, out BasePriceableItemTemplate piTemplate);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SavePriceableItemTemplate(ref BasePriceableItemTemplate piTemplate);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void DeletePriceableItemTemplate(PCIdentifier piTemplateID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void CreatePIInstanceFromTemplate(PCIdentifier piTemplateID, out BasePriceableItemInstance piInstance);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetCalendars(ref MTList<Calendar> calendars);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetCalendar(PCIdentifier calendarID, out Calendar calendar);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void SaveCalendar(Calendar calendar);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void RemoveHolidayFromCalendar(PCIdentifier calendarID, PCIdentifier holidayID);

    [OperationContract]
    [FaultContract(typeof(MASBasicFaultDetail))]
    void GetReasonCodes(ref MTList<ReasonCode> reasonCodes);

  }

  [ServiceBehavior(ConcurrencyMode = ConcurrencyMode.Multiple, InstanceContextMode = InstanceContextMode.Single)]
  public class ProductCatalogService : BasePCWebService, IProductCatalogService
  {
    #region Private Members

    private static Logger m_Logger = new Logger("[ProductCatalogService]");
    private Dictionary<int?, PriceableItemType> m_dicPriceableItemTypes;

    #endregion

    #region IProductCatalogService Members

    public void GetPriceableItemTemplates(ref MTList<BasePriceableItemTemplate> piTemplates)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceableItemTemplates"))
      {
        MTAuth.IMTSessionContext sessionContext = GetSessionContext();
        IMTProductCatalog prodCatalog = new MTProductCatalogClass();
        prodCatalog.SetSessionContext((IMTSessionContext)sessionContext);

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {

            Dictionary<int, BasePriceableItemTemplate> templateDictionary = new Dictionary<int, BasePriceableItemTemplate>();
            string piTemplateIds = "";
            // return high level list of product offerings in the sytste
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_PI_TEMPLATE_HL_DETAILS__"))
            {
              ApplyFilterSortCriteria<BasePriceableItemTemplate>(stmt, piTemplates);

              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                //if there are records, create a PriceableItem Template
                while (dataReader.Read())
                {
                  BasePriceableItemTemplate template = null;
                  Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
                  Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();

                  int templateId = dataReader.GetInt32("ID");
                  string name = dataReader.GetString("Name");
                  string dispName = dataReader.IsDBNull("DisplayName") ? null : dataReader.GetString("DisplayName");
                  string description = dataReader.IsDBNull("Description") ? null : dataReader.GetString("Description");
                  int piType = dataReader.GetInt32("PIType");
                  string piTypeName = dataReader.GetString("PITypeName");
                  int nKind = dataReader.GetInt32("PIKind");
                  PriceableItemKinds pki = (PriceableItemKinds)nKind;

                  object o = RetrieveClassName(piTypeName, "PITemplate");
                  template = (BasePriceableItemTemplate)o;

                  template.ID = templateId;
                  template.Name = name;
                  template.DisplayName = dispName;
                  template.PIKind = pki;
                  template.Description = description;

                  piTemplateIds = piTemplateIds + templateId + ",";
                  template.LocalizedDisplayNames = localizedNames;
                  template.LocalizedDescriptions = localizedDesc;

                  templateDictionary.Add(template.ID.Value, template);
                  piTemplates.Items.Add(template);

                }

                piTemplates.TotalRows = stmt.TotalRows;
              }
            }

            if (piTemplateIds.Length > 0)
            {
              // remove trailing comma
              int length = piTemplateIds.Length - 1;
              piTemplateIds = piTemplateIds.Remove(length, 1);

              using (IMTAdapterStatement local = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_PROPS__"))
              {
                local.AddParam("%%PITYPE_IDS%%", piTemplateIds);
                using (IMTDataReader localizedReader = local.ExecuteReader())
                {
                  while (localizedReader.Read())
                  {
                    int id = localizedReader.GetInt32("ID");
                    BasePriceableItemTemplate pit = templateDictionary[id];

                    if (!localizedReader.IsDBNull("LanguageCode"))
                    {
                      LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                      pit.LocalizedDisplayNames.Add(langCode, localizedReader.IsDBNull("DisplayName") ? null : localizedReader.GetString("DisplayName"));
                      pit.LocalizedDescriptions.Add(langCode, localizedReader.IsDBNull("Description") ? null : localizedReader.GetString("Description"));
                    }
                  }
                }
              }
            }
          }
          m_Logger.LogDebug("Retrieved {0} priceable item templates ", piTemplates.Items.Count);
        }
        catch (CommunicationException e)
        {
          m_Logger.LogException("Cannot retrieve priceable item templates from system ", e);
          throw;
        }

        catch (Exception e)
        {
          m_Logger.LogException("Error retrieving priceable item templates from the system ", e);
          throw new MASBasicException("Error retrieving priceable item templates");
        }
      }
    }

    public void GetPriceableItemTemplate(PCIdentifier piTemplateID, out BasePriceableItemTemplate piTemplate)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceableItemTemplate"))
      {
        if (piTemplateID == null)
        {
          throw new MASBasicException("Must specify identifier of priceable item template to be loaded");
        }

        int templateID = PCIdentifierResolver.ResolvePriceableItemTemplate(piTemplateID);
        if (templateID == -1)
          throw new MASBasicException("Invalid Priceable Item Template ID sepecified.");

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
          {

            PopulateBasePITemplateProps(templateID, out piTemplate);

            PropertyInfo parentPIProperty = piTemplate.GetProperty("ParentPITemplate");
            if (parentPIProperty != null)
            {
              throw new MASBasicException("Cannot get child template without parent.");
            }

            if ((piTemplate.PIKind == PriceableItemKinds.Usage || piTemplate.PIKind == PriceableItemKinds.AggregateCharge))
            {
              m_Logger.LogDebug("About to Populate Child Templates for {0} Template", piTemplate.Name);
              RetrieveAndPopulateChildTemplates(piTemplate);
              m_Logger.LogDebug("Successfully Populated Child Templates for {0} Template", piTemplate.Name);
            }
            m_Logger.LogDebug("Successfully Retrieved {0} Template", piTemplate.Name);
          }
        }
        catch (CommunicationException e)
        {
          m_Logger.LogException("Cannot retrieve priceable item template from system ", e);
          throw;
        }

        catch (Exception e)
        {
          m_Logger.LogException("Error retrieving priceable item template from the system ", e);
          throw new MASBasicException("Error retrieving priceable item template.");
        }
      }
    }

    public void GetPriceableItemTypes(ref MTList<PriceableItemType> piTypes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceableItemTypes"))
      {
        try
        {
          m_dicPriceableItemTypes = new Dictionary<int?, PriceableItemType>();
          StringBuilder piTypeIDs = new StringBuilder();

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_PRICEABLEITEMTYPES__"))
            {
              ApplyFilterSortCriteria<PriceableItemType>(stmt, piTypes);

              int? piTypeId = -1;

              #region Populate Data into PriceableItemTypes
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                PriceableItemType piType;

                while (rdr.Read())
                {
                  //Add comma only if ID exists.
                  if (piTypeIDs.Length > 0)
                    piTypeIDs.Append(",");

                  piType = PopulatePriceableItemType(rdr, out piTypeId);
                  piType.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                  piTypes.Items.Add(piType);

                  m_dicPriceableItemTypes.Add(piTypeId, piType);

                  piTypeIDs.Append(piTypeId);
                }
              }
              #endregion

              piTypes.TotalRows = stmt.TotalRows;
            }

            using (IMTAdapterStatement localizedDescriptionStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_DESCRIPTIONS__"))
            {
              localizedDescriptionStmt.AddParam("%%PITYPE_IDS%%", piTypeIDs.ToString());

              #region Populate Localized Description
              using (IMTDataReader ldRdr = localizedDescriptionStmt.ExecuteReader())
              {

                while (ldRdr.Read())
                {
                  if (!ldRdr.IsDBNull("LanguageCode"))
                  {
                    m_dicPriceableItemTypes[ldRdr.GetInt32("ID")].LocalizedDescriptions[GetLanguageCode(ldRdr.GetInt32("LanguageCode"))] = (!ldRdr.IsDBNull("Description") ? ldRdr.GetString("Description") : null);
                  }

                }
              }
              #endregion
            }
          }
        }
        catch (MASBasicException mas)
        {
          m_Logger.LogException("MAS Exception caught loading priceable item types.", mas);

          throw mas;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception caught loading priceable item types.", comE);

          MASBasicException mas = new MASBasicException("Error loading product offerings for account template");
          mas.AddErrorMessage(comE.Message);

          throw mas;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting priceable item types in GetPriceableItemTypes", e);

          piTypes.Items.Clear();

          throw new MASBasicException("Failed to retrieve priceable item types.");
        }
      }
    }

    public void GetPriceableItemType(PCIdentifier piTypeID, out PriceableItemType piType)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetPriceableItemType"))
      {
        try
        {
          piType = null;
          int? id = -1;
          PriceableItemType pit = new PriceableItemType();
          Dictionary<int, AdjustmentType> dicAdjustmentTypes = new Dictionary<int, AdjustmentType>();


          MTList<PriceableItemType> piTypes = new MTList<PriceableItemType>();

          if (piTypeID.ID.HasValue)
          {
            piTypes.Filters.Add(new MTFilterElement("ID", MTFilterElement.OperationType.Equal, piTypeID.ID));
          }

          if (!string.IsNullOrEmpty(piTypeID.Name))
          {
            piTypes.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, piTypeID.Name));
          }

          if (piTypes.Filters.Count == 0)
          {
            m_Logger.LogError("Invalid filter values or no filters defined to Get PriceableItemType");
            throw new MASBasicException("Invalid filter values or no filters defined to Get PriceableItemType");
          }

          GetPriceableItemTypes(ref piTypes);

          //Get the record from the list.
          if (!piTypes.Items.HasValue() || !m_dicPriceableItemTypes.HasValue())
          {
            return;
          }

          pit = m_dicPriceableItemTypes.First().Value;
          id = m_dicPriceableItemTypes.First().Key;

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_PRICEABLEITEMTYPE_DETAILS__"))
            {
              stmt.AddParam("%%PITYPE_ID%%", id);
              stmt.SetResultSetCount(7);

              int idxParameterTableName = 1;

              using (IMTDataReader rdr = stmt.ExecuteReader())
              {

                //***********Load Paramater table Names.
                while (rdr.Read())
                {
                  if (pit.ParameterTables == null)
                  {
                    pit.ParameterTables = new List<string>();
                  }

                  pit.ParameterTables.Add(rdr.GetString(idxParameterTableName));

                }

                rdr.NextResult();

                //***********Load Adjustment Types.
                PopulateAdjustmentType(rdr, ref pit, ref dicAdjustmentTypes);


                rdr.NextResult();

                //***********Load Adjustment Value.
                PopulateAdjustmentValue(rdr, ref dicAdjustmentTypes);

                rdr.NextResult();

                //***********Load Application Rule Definitions.
                PopulateApplicabilityRuleDefinitions(rdr, ref dicAdjustmentTypes);

                rdr.NextResult();

                //***********Load Counter Property Definitions.
                PopulateCounterProperty(rdr, ref pit);

                rdr.NextResult();

                //***********Load Charge Properties.
                PopulateChargeProperties(rdr, ref pit);

                rdr.NextResult();

                //Populate pcidentifier for list of child priceable item types.
                while (rdr.Read())
                {
                  if (pit.ChildPriceableItemTypes == null)
                  {
                    pit.ChildPriceableItemTypes = new List<PCIdentifier>();
                  }

                  pit.ChildPriceableItemTypes.Add(new PCIdentifier(rdr.GetString(0)));

                }
              }
            }
          }
          piType = pit;

        }
        catch (MASBasicException masBasic)
        {
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception getting priceable item type", comE);

          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception getting priceable item type", e);

          throw new MASBasicException("Error getting priceable item type");
        }
      }
    }

    public void SavePriceableItemTemplate(ref BasePriceableItemTemplate piTemplate)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SavePriceableItemTemplate"))
      {

        PCIdentifier piTemplateID = null;

        if (piTemplate.ID.HasValue && piTemplate.IsNameDirty)
        {
          piTemplateID = new PCIdentifier(piTemplate.ID.Value, piTemplate.Name);
        }
        else if (piTemplate.ID.HasValue)
        {
          piTemplateID = new PCIdentifier(piTemplate.ID.Value);
        }
        else
        {
          piTemplateID = new PCIdentifier(piTemplate.Name);
        }


        int templateID = PCIdentifierResolver.ResolvePriceableItemTemplate(piTemplateID);
        int? parentTemplateId = null;

        if (piTemplate.ID.HasValue && piTemplate.ID.Value != templateID)
        {
          throw new MASBasicException("Invalid priceable item template ID");
        }

        piTemplate.ID = templateID;

        if (templateID == -1)
        {
          InternalCreatePITemplate(ref piTemplate, parentTemplateId);
        }
        else
        {
          InternalUpdatePITemplate(ref piTemplate);
        }
      }
    }



    public void DeletePriceableItemTemplate(PCIdentifier piTemplateID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("DeletePriceableItemTemplate"))
      {
        try
        {
          using (TransactionScope scope =
                  new TransactionScope(TransactionScopeOption.Required,
                                          new TransactionOptions(),
                                          EnterpriseServicesInteropOption.Full))
          {
            int id_pi = PCIdentifierResolver.ResolvePriceableItemTemplate(piTemplateID, true);

            if (id_pi == -1)
            {
              throw new MASBasicException("Unable to locate specified priceable item template");
            }

            if (DoesTemplateHaveInstances(id_pi))
            {
              throw new MASBasicException("Unable to delete priceable item template as it has priceable item instances that depend on it");
            }

            InternalRemovePITemplate(id_pi);

            scope.Complete();
          }

        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MASBasicException caught removing priceable item template", masE);

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unhandled exception removing priceable item template", e);
          throw new MASBasicException("Unexpected error removing priceable item template.  Ask system administrator to review server logs.");
        }
      }
    }

    public void CreatePIInstanceFromTemplate(PCIdentifier piTemplateID, out BasePriceableItemInstance piInstance)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("CreatePIInstanceFromTemplate"))
      {
        try
        {

          BasePriceableItemTemplate piTemplate;


          GetPriceableItemTemplate(piTemplateID, out piTemplate);

          PopulatePIInstanceFromTemplate(piTemplate, out piInstance);

          if (piTemplate.PIKind == PriceableItemKinds.Usage || piTemplate.PIKind == PriceableItemKinds.AggregateCharge)
          {
            foreach (PropertyInfo templatePropInfo in piTemplate.GetProperties())
            {
              if (templatePropInfo.PropertyType.IsSubclassOf(typeof(BasePriceableItemTemplate)))
              {
                BasePriceableItemTemplate childPITemplate = (BasePriceableItemTemplate)templatePropInfo.GetValue(piTemplate, null);
                BasePriceableItemInstance childPIInstance;
                PopulatePIInstanceFromTemplate(childPITemplate, out childPIInstance);
                //ESR-4322 In result of creation an instance of 'Song session' the Song_Session_Child is null. 
                PropertyInfo childInstanceProperty = piInstance.GetProperty(StringUtils.MakeAlphaNumeric(childPIInstance.DisplayName));
                if (childInstanceProperty != null)
                {
                  childInstanceProperty.SetValue(piInstance, childPIInstance, null);
                }

              }
            }
          }


        }
        catch (MASBasicException masBasic)
        {
          throw masBasic;
        }
        catch (COMException comE)
        {
          m_Logger.LogException("COM Exception creating priceable item instance", comE);

          throw new MASBasicException(comE.Message);
        }
        catch (Exception e)
        {
          m_Logger.LogException("Exception creating priceable item instance", e);

          throw new MASBasicException("Error creating priceable item instance");
        }
      }
    }

    public void GetCalendars(ref MTList<Calendar> calendars)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetCalendars"))
      {
        try
        {
          m_Logger.LogInfo("In GetCalendars");
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            Dictionary<int, Calendar> loadedCalendars = new Dictionary<int, Calendar>();
            string loadedIds = "";

            using (IMTFilterSortStatement filterStmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_CALENDARSP_PCWS__"))
            {
              m_Logger.LogDebug("Set filters");
              ApplyFilterSortCriteria<Calendar>(filterStmt, calendars);

              m_Logger.LogDebug("Execute query");
              using (IMTDataReader rdr = filterStmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  Calendar calendar = new Calendar();

                  calendar.ID = rdr.GetInt32("ID");
                  calendar.Name = rdr.GetString("Name");
                  if (!rdr.IsDBNull("Description"))
                  {
                    calendar.Description = rdr.GetString("Description");
                  }

                  calendars.Items.Add(calendar);

                  loadedCalendars.Add(calendar.ID.Value, calendar);
                  loadedIds += calendar.ID.Value.ToString() + ", ";
                }

                calendars.TotalRows = filterStmt.TotalRows;
              }
            }

            m_Logger.LogDebug("Load localized descriptions");
            using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_PROPS__"))
            {
              adapterStmt.AddParam("%%PITYPE_IDS%%", loadedIds.Substring(0, loadedIds.Length - 2));

              using (IMTDataReader rdr = adapterStmt.ExecuteReader())
              {
                while (rdr.Read())
                {
                  int id = rdr.GetInt32("ID");
                  Calendar cal = loadedCalendars[id];
                  if (!rdr.IsDBNull("LanguageCode"))
                  {
                    LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                    cal.LocalizedDescriptions.Add(langCode, rdr.IsDBNull("Description") ? null : rdr.GetString("Description"));
                  }
                }
              }
            }
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MASBasicException caught getting Calendars", masE);

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unhandled exception getting Calendars", e);

          throw new MASBasicException("Unexpected error getting Calendars.  Ask system administrator to review server logs.");
        }
      }
    }

    public void GetCalendar(PCIdentifier calendarID, out Calendar calendar)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetCalendar"))
      {
        calendar = null;

        m_Logger.LogInfo("In GetCalendar");

        try
        {
          int id_calendar = PCIdentifierResolver.ResolveCalendar(calendarID);

          if (id_calendar == -1)
          {
            throw new MASBasicException("Unable to locate specified Calendar");
          }

          m_Logger.LogInfo("Loading calendar with id {0}", id_calendar);

          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTMultiSelectAdapterStatement stmt = conn.CreateMultiSelectStatement(PCWS_QUERY_FOLDER, "__GET_CALENDAR_PCWS__"))
            {
              stmt.AddParam("%%CALENDAR_ID%%", id_calendar);
              stmt.SetResultSetCount(4);

              m_Logger.LogDebug("Execute load query");
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  Dictionary<int, CalendarDay> loadedDays = new Dictionary<int, CalendarDay>();

                  m_Logger.LogDebug("Create new calendar object and set properties");
                  calendar = new Calendar();

                  calendar.ID = rdr.GetInt32("ID");
                  calendar.Name = rdr.GetString("Name");
                  if (!rdr.IsDBNull("Description"))
                  {
                    calendar.Description = rdr.GetString("Description");
                  }

                  rdr.NextResult();

                  m_Logger.LogDebug("Load week days and holidays");
                  #region Load Calendar Weekdays and Holidays
                  while (rdr.Read())
                  {
                    if (!rdr.IsDBNull("WeekdayID"))
                    {
                      CalendarWeekday weekDay = new CalendarWeekday();
                      weekDay.ID = rdr.GetInt32("DayID");
                      weekDay.Code = (CalendarCode)EnumHelper.GetEnumByValue(typeof(CalendarCode), rdr.GetInt32("Code").ToString());

                      #region Set Appropriate Weekday Property
                      int weekDayID = rdr.GetInt32("WeekdayID");

                      switch (weekDayID)
                      {
                        case 0:
                          calendar.Sunday = weekDay;
                          break;
                        case 1:
                          calendar.Monday = weekDay;
                          break;
                        case 2:
                          calendar.Tuesday = weekDay;
                          break;
                        case 3:
                          calendar.Wednesday = weekDay;
                          break;
                        case 4:
                          calendar.Thursday = weekDay;
                          break;
                        case 5:
                          calendar.Friday = weekDay;
                          break;
                        case 6:
                          calendar.Saturday = weekDay;
                          break;
                        case 7:
                          calendar.DefaultWeekday = weekDay;
                          break;
                        case 8:
                          calendar.DefaultWeekend = weekDay;
                          break;
                      }
                      #endregion

                      loadedDays.Add(weekDay.ID.Value, weekDay);
                    }
                    else
                    {
                      CalendarHoliday holiday = new CalendarHoliday();
                      holiday.ID = rdr.GetInt32("DayID");
                      holiday.Code = (CalendarCode)EnumHelper.GetEnumByValue(typeof(CalendarCode), rdr.GetInt32("Code").ToString());
                      holiday.HolidayID = rdr.GetInt32("HolidayID");
                      holiday.Name = rdr.GetString("HolidayName");
                      holiday.Date = new DateTime(rdr.GetInt32("Year"), rdr.GetInt32("Month"), rdr.GetInt32("Day"));

                      if (calendar.Holidays == null)
                        calendar.Holidays = new List<CalendarHoliday>();

                      calendar.Holidays.Add(holiday);

                      loadedDays.Add(holiday.ID.Value, holiday);
                    }
                  }
                  #endregion

                  rdr.NextResult();

                  m_Logger.LogDebug("Load day periods for week days and holidays");
                  #region Load Calenday Weekday and Holiday Periods
                  while (rdr.Read())
                  {
                    int dayId = rdr.GetInt32("DayID");

                    CalendarDayPeriod period = new CalendarDayPeriod();
                    period.ID = rdr.GetInt32("PeriodID");
                    period.StartTime = new DateTime(1, 1, 1).AddSeconds(rdr.GetInt32("StartTime"));
                    period.EndTime = new DateTime(1, 1, 1).AddSeconds(rdr.GetInt32("EndTime"));
                    period.Code = (CalendarCode)EnumHelper.GetEnumByValue(typeof(CalendarCode), rdr.GetInt32("Code").ToString());

                    if (loadedDays.ContainsKey(dayId))
                    {
                      if (loadedDays[dayId].Periods == null)
                        loadedDays[dayId].Periods = new List<CalendarDayPeriod>();

                      loadedDays[dayId].Periods.Add(period);
                    }
                    else
                    {
                      throw new MASBasicException(string.Format("Calendar day period ID {0} loaded but corresponding calendar day was not", period.ID.Value));
                    }
                  }
                  #endregion

                  rdr.NextResult();

                  m_Logger.LogDebug("Load localized descriptions");
                  #region Load Calendar Localized Descriptions
                  if (rdr.Read())
                  {
                    calendar.LocalizedDescriptions = new Dictionary<LanguageCode, string>();

                    do
                    {
                      if (!rdr.IsDBNull("LanguageCode"))
                      {
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), rdr.GetInt32("LanguageCode").ToString());
                        calendar.LocalizedDescriptions.Add(langCode, ((!rdr.IsDBNull("Description") ? rdr.GetString("Description") : null)));
                      }
                    } while (rdr.Read());
                  }
                  #endregion
                }
                else
                {
                  throw new MASBasicException("Unable to load specified Calendar");
                }
              }
            }
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MASBasicException caught getting Calendar", masE);

          calendar = null;

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unhandled exception getting Calendar", e);

          calendar = null;

          throw new MASBasicException("Unexpected error getting Calendar.  Ask system administrator to review server logs.");
        }
      }
    }

    public void SaveCalendar(Calendar calendar)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("SaveCalendar"))
      {
        m_Logger.LogInfo("Saving calendar");

        try
        {
          using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
          {
            PCIdentifier calendarID = null;
            if (calendar.ID.HasValue && !String.IsNullOrEmpty(calendar.Name))
            {
              calendarID = new PCIdentifier(calendar.ID.Value, calendar.Name);
            }
            else if (calendar.ID.HasValue)
            {
              calendarID = new PCIdentifier(calendar.ID.Value);
            }
            else
            {
              calendarID = new PCIdentifier(calendar.Name);
            }

            m_Logger.LogDebug("Resolve passed in calendar ID to see if calendar exists");
            calendar.ID = PCIdentifierResolver.ResolveCalendar(calendarID, true);

            if (calendar.ID.Value != -1)
            {
              InternalUpdateCalendar(ref calendar);
            }
            else
            {
              InternalCreateCalendar(ref calendar);
            }

            scope.Complete();
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MASBasicException caught saving Calendar", masE);

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unhandled exception saving Calendar", e);

          throw new MASBasicException("Unexpected error saving Calendar.  Ask system administrator to review server logs.");
        }
      }
    }

    public void RemoveHolidayFromCalendar(PCIdentifier calendarID, PCIdentifier holidayID)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("RemoveHolidayFromCalendar"))
      {
        try
        {
          m_Logger.LogInfo("Removing calendar holiday");

          m_Logger.LogDebug("Resolve calendar Id");
          int id_calendar = PCIdentifierResolver.ResolveCalendar(calendarID, true);

          if (id_calendar == -1)
          {
            throw new MASBasicException("Unable to loacate specified calendar");
          }

          m_Logger.LogDebug("Resolve calendar holiday");
          int id_holiday = PCIdentifierResolver.ResolveCalendarHoliday(id_calendar, holidayID, true);

          if (id_holiday == -1)
          {
            throw new MASBasicException("Unale to locate specifeid calendar holiday");
          }

          try
          {
            m_Logger.LogInfo("Removing holiday {0} from calendar {1}", id_holiday, id_calendar);
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_CALENDAR_HOLIDAY_PCWS__"))
              {
                stmt.AddParam("%%HOLIDAY_ID%%", id_holiday);

                stmt.ExecuteNonQuery();
              }
            }
          }
          catch (Exception e)
          {
            m_Logger.LogException(string.Format("Exception deleting holiday {0} from calendar {1}", id_holiday, id_calendar), e);

            throw new MASBasicException("Unexpected error deleting holiday from calendar");
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MASBasicException caught removing Calendar holiday", masE);

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unhandled exception removing Calendar holiday", e);

          throw new MASBasicException("Unexpected error removing Calendar holiday.  Ask system administrator to review server logs.");
        }
      }
    }

    public void GetReasonCodes(ref MTList<ReasonCode> reasonCodes)
    {
      using (HighResolutionTimer timer = new HighResolutionTimer("GetReasonCodes"))
      {
        m_Logger.LogInfo("Getting collection of reason codes");

        try
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            Dictionary<int, ReasonCode> reasonCodeMap = new Dictionary<int, ReasonCode>();
            string reasonCodeIds = "";

            using (IMTFilterSortStatement stmt = conn.CreateFilterSortStatement(PCWS_QUERY_FOLDER, "__GET_REASON_CODES__"))
            {
              ApplyFilterSortCriteria<ReasonCode>(stmt, reasonCodes);

              #region Execute and process results
              using (IMTDataReader dataReader = stmt.ExecuteReader())
              {
                //if there are records, create a PriceableItem Template
                while (dataReader.Read())
                {
                  ReasonCode code = new ReasonCode();
                  code.ID = dataReader.GetInt32("ID");
                  code.Name = dataReader.GetString("Name");

                  if (!dataReader.IsDBNull("Description"))
                  {
                    code.Description = dataReader.GetString("Description");
                  }

                  code.DisplayName = dataReader.GetString("DisplayName");

                  code.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                  code.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();

                  reasonCodes.Items.Add(code);
                  reasonCodeMap.Add(code.ID.Value, code);
                  reasonCodeIds += string.Format("{0}, ", code.ID.Value);
                }
              }
              #endregion

              #region Load localized strings
              if (reasonCodeMap.HasValue())
              {
                // remove trailing comma
                int length = reasonCodeIds.Length - 2;
                reasonCodeIds = reasonCodeIds.Remove(length, 1);

                using (IMTAdapterStatement local = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_LOCALIZED_PROPS__"))
                {
                  local.AddParam("%%PITYPE_IDS%%", reasonCodeIds);
                  using (IMTDataReader localizedReader = local.ExecuteReader())
                  {
                    while (localizedReader.Read())
                    {
                      int id = localizedReader.GetInt32("ID");
                      ReasonCode code = reasonCodeMap[id];

                      if (!localizedReader.IsDBNull("LanguageCode"))
                      {
                        LanguageCode langCode = (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), localizedReader.GetInt32("LanguageCode").ToString());
                        code.LocalizedDisplayNames.Add(langCode, localizedReader.IsDBNull("DisplayName") ? string.Empty : localizedReader.GetString("DisplayName"));
                        code.LocalizedDescriptions.Add(langCode, localizedReader.IsDBNull("Description") ? string.Empty : localizedReader.GetString("Description"));
                      }
                    }
                  }
                }
              }
              #endregion

              reasonCodes.TotalRows = stmt.TotalRows;
            }
          }
        }
        catch (MASBasicException masE)
        {
          m_Logger.LogException("MAS Exception caught getting reason codes", masE);

          throw masE;
        }
        catch (Exception e)
        {
          m_Logger.LogException("Unexpected error caught getting reason codes", e);

          throw new MASBasicException("Unexpected error caught getting reason codes.  Ask system administrator to review server logs.");
        }
      }
    }

    #endregion

    #region Private Methods


    private void InternalCreatePITemplate(ref BasePriceableItemTemplate piTemplate, int? parentTemplateId)
    {

      if (piTemplate.GetType().IsSubclassOf(typeof(UsagePITemplate)) || piTemplate.GetType().IsSubclassOf(typeof(AggregateChargePITemplate)))
      {
        throw new MASBasicException("Usage/Aggregate based template creation is not supported through this interface.");
      }

      if (piTemplate.GetProperty("ParentPITemplate") is PropertyInfo)
      {
        throw new MASBasicException("Child templates cannot be created");
      }

      #region Template name exists in db?

      m_Logger.LogDebug("Checking Template name exists in db");
      PCIdentifier piTemplateID = new PCIdentifier(piTemplate.Name);
      int id = PCIdentifierResolver.ResolvePriceableItemTemplate(piTemplateID);

      if (id > 0)
      {
        throw new MASBasicException("Priceable Template Name already exists.");
      }

      #endregion

      MTAuth.IMTSessionContext context = GetSessionContext();

      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
      {

        using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
        {
          piTemplate.ID = BasePropsUtils.CreateBaseProps(context, piTemplate.Name, piTemplate.Description, piTemplate.DisplayName, (int)piTemplate.PIKind);

          //PCIdentifierResolver.ResolvePriceableItemTemplate(new PCIdentifier(piTemplate.ID.Value), true);

          ProcessLocalizationData(piTemplate.ID.Value, piTemplate.LocalizedDisplayNames,
                                      piTemplate.IsLocalizedDisplayNamesDirty, piTemplate.LocalizedDescriptions,
                                      piTemplate.IsLocalizedDescriptionDirty);

          #region Resolve Priceable Item Type
          object[] priceableItemTemplateAttribs = piTemplate.GetType().GetCustomAttributes(typeof(MTPriceableItemTemplateAttribute), false);

          if (!priceableItemTemplateAttribs.HasValue())
          {
            m_Logger.LogDebug("MTPriceableItemTemplateAttribute not found for the pitemplate");
            throw new MASBasicException("MTPriceableItemTemplateAttribute not found for the pitemplate");
          }

          MTPriceableItemTemplateAttribute att = priceableItemTemplateAttribs[0] as MTPriceableItemTemplateAttribute;

          PCIdentifier piTypeIdentifier = new PCIdentifier(att.PIType);

          int piTypeID = PCIdentifierResolver.ResolvePriceableItemType(piTypeIdentifier);

          if (piTypeID == -1)
          {
            m_Logger.LogDebug(string.Format("Error Fetching priceable item type for template {0}", piTemplate.ID.Value));
            throw new MASBasicException(string.Format("Error Fetching priceable item type for template {0}", piTemplate.ID.Value));
          }
          #endregion

          #region INSERT t_pi_template record.
          using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_PI_TMPL_PCWS__"))
          {
            createStmt.AddParam("%%ID_TMPL%%", piTemplate.ID.Value);
            createStmt.AddParam("%%ID_TMPL_PARENT%%", parentTemplateId.HasValue ? DatabaseUtils.FormatValueForDB(parentTemplateId.Value) : DatabaseUtils.FormatValueForDB(null));
            createStmt.AddParam("%%ID_PI%%", piTypeID);
            createStmt.ExecuteNonQuery();
          }
          #endregion

          #region Add PI Kind Specific Properties
          m_Logger.LogDebug("Add PI Kind Specific Properties");
          try
          {
            switch (piTemplate.PIKind)
            {
              case PriceableItemKinds.NonRecurring:
                m_Logger.LogDebug("Adding NonRecurring specific properties");
                #region Insert NonRecurring Charge Properties

                if (!((NonRecurringChargePITemplate)piTemplate).EventType.HasValue)
                {
                  m_Logger.LogError("Event Type not set on PI Template");
                  throw new MASBasicException("Event Type property is null on PI Template");
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_NRC_PROPERTIES_BY_ID_PCWS__"))
                {
                  NonRecurringChargePITemplate pit = piTemplate as NonRecurringChargePITemplate;
                  stmt.AddParam("%%ID_PROP%%", piTemplate.ID.Value);
                  stmt.AddParam("%%N_EVENT_TYPE%%", (int)pit.EventType);
                  stmt.ExecuteNonQuery();
                }
                #endregion
                break;
              case PriceableItemKinds.Discount:
                #region Insert Discount Properties
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_DISCOUNT_PROPERTIES_BY_ID_PCWS__"))
                {
                  DiscountPITemplate pit = piTemplate as DiscountPITemplate;
                  stmt.AddParam("%%ID_PROP%%", piTemplate.ID.Value);
                  stmt.AddParam("%%N_VALUE_TYPE%%", 0);
                  stmt.AddParam("%%ID_DISTRIBUTION_CPD%%", null);

                  AddCycleIDsToQuery(stmt, pit.Cycle);

                  stmt.ExecuteNonQuery();
                }

                #endregion
                break;

              case PriceableItemKinds.UnitDependentRecurring:
              case PriceableItemKinds.Recurring:
                #region Insert UnitDependentRecurring/Recurring Charge Properties
                BaseRecurringChargePITemplate baseRC = (BaseRecurringChargePITemplate)piTemplate;

                using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_RECURRING_CHARGE_PROPERTIES_BY_ID_PCWS__"))
                {
                  adapterStmt.AddParam("%%ID_PROP%%", piTemplate.ID.Value);

                  adapterStmt.AddParam("%%ID_LANG_CODE%%", GetSessionContext().LanguageID);

                  if (!baseRC.ChargeAdvance.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : ChargeAdvance property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_ADVANCE%%", (baseRC.ChargeAdvance.Value ? "Y" : "N"));

                  if (!baseRC.ProrateOnActivation.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : ProrateOnActivation property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_PRORATE_ON_ACTIVATE%%", (baseRC.ProrateOnActivation.Value ? "Y" : "N"));
                  if (!baseRC.ProrateInstantly.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : ProrateInstantly property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_PRORATE_INSTANTLY%%", (baseRC.ProrateInstantly.Value ? "Y" : "N"));

                  if (!baseRC.ProrateOnDeactivation.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : ProrateOnDeactivation property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_PRORATE_ON_DEACTIVATE%%", (baseRC.ProrateOnDeactivation.Value ? "Y" : "N"));

                  if (!baseRC.FixedProrationLength.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : FixedProrationLength property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_FIXED_PRORATION_LENGTH%%", (baseRC.FixedProrationLength.Value ? "Y" : "N"));

                  if (!baseRC.ChargePerParticipant.HasValue)
                  {
                    throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : ChargePerParticipant property must have a value", piTemplate.ID.Value));
                  }
                  adapterStmt.AddParam("%%B_CHARGE_PER_PARTICIPANT%%", (baseRC.ChargePerParticipant.Value ? "Y" : "N"));

                  if (piTemplate.PIKind == PriceableItemKinds.UnitDependentRecurring)
                  {
                    UnitDependentRecurringChargePITemplate udrcTemplate = ((UnitDependentRecurringChargePITemplate)baseRC);

                    adapterStmt.AddParam("%%NM_UNIT_NAME%%", udrcTemplate.UnitName);
                    adapterStmt.AddParam("%%NM_UNIT_DISPLAY_NAME%%", udrcTemplate.UnitDisplayName);
                    adapterStmt.AddParam("%%N_RATING_TYPE%%", (int)udrcTemplate.RatingType);

                    if (!udrcTemplate.IntegerUnitValue.HasValue)
                    {
                      throw new MASBasicException(String.Format("Error saving PriceableItemTemplate id = {0} : IntegerUnitValue property must have a value of true or false", piTemplate.ID.Value));
                    }
                    adapterStmt.AddParam("%%B_INTEGRAL%%", (udrcTemplate.IntegerUnitValue.Value ? "Y" : "N"));
                    adapterStmt.AddParam("%%MAX_UNIT_VALUE%%", udrcTemplate.MaxUnitValue);
                    adapterStmt.AddParam("%%MIN_UNIT_VALUE%%", udrcTemplate.MinUnitValue);
                  }
                  else
                  {
                    adapterStmt.AddParam("%%NM_UNIT_NAME%%", "");
                    adapterStmt.AddParam("%%NM_UNIT_DISPLAY_NAME%%", "");
                    adapterStmt.AddParam("%%N_RATING_TYPE%%", 1);
                    adapterStmt.AddParam("%%B_INTEGRAL%%", "N");
                    adapterStmt.AddParam("%%MAX_UNIT_VALUE%%", 999999999.000000);
                    adapterStmt.AddParam("%%MIN_UNIT_VALUE%%", 0);
                  }

                  AddExtendedCycleIDsToQuery(adapterStmt, baseRC.Cycle);

                  adapterStmt.ExecuteNonQuery();
                }

                if (piTemplate.PIKind == PriceableItemKinds.UnitDependentRecurring)
                {
                  m_Logger.LogDebug("Adding UDRC unit name");
                  UnitDependentRecurringChargePITemplate udrcTemplate = ((UnitDependentRecurringChargePITemplate)baseRC);
                  int n_unit_displayname = -1;

                  using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC_PCWS__"))
                  {
                    adapterStmt.AddParam("%%ID_PROP%%", piTemplate.ID.Value);

                    using (IMTDataReader rdr = adapterStmt.ExecuteReader())
                    {
                      if (rdr.Read())
                      {
                        n_unit_displayname = rdr.GetInt32("n_unit_display_name");
                      }
                    }
                  }

                  AddUDRCUnitValues(udrcTemplate);

                  ProcessLocalizationData(n_unit_displayname,
                                          udrcTemplate.LocalizedUnitDisplayNames,
                                          udrcTemplate.IsLocalizedUnitDisplayNamesDirty,
                                          null,
                                          null,
                                          false);





                }
                #endregion
                break;
            }
          }
          catch (MASBasicException)
          {
            throw;
          }
          catch (Exception e)
          {
            m_Logger.LogException("Unknown error adding pi template kind specific properties", e);

            throw new MASBasicException("Error adding priceable item template kind specific properties");
          }
          #endregion

          CreateAdjusmentTemplates(ref piTemplate);

          CreateCounters(ref piTemplate);

          UpsertExtendedProps(piTemplate.ID.Value, piTemplate);

          #region Adding Child PI Template
          m_Logger.LogDebug("Adding Child PI Templates");

          List<PropertyInfo> childPIProperties = piTemplate.GetProperties();

          foreach (PropertyInfo childPIProperty in childPIProperties)
          {
            if (childPIProperty.PropertyType.IsSubclassOf(typeof(BasePriceableItemTemplate)))
            {
              try
              {
                object o = childPIProperty.GetValue(piTemplate, null);

                if (o == null)
                {
                  m_Logger.LogError("Child Priceable Item Template cannot be null. error while adding Priceable Item Template");
                  throw new MASBasicException("Child Priceable Item Template cannot be null. error while adding Priceable Item Template");
                }

                BasePriceableItemTemplate bpt = o as BasePriceableItemTemplate;

                InternalCreatePITemplate(ref bpt, piTemplate.ID);

              }
              catch (MASBasicException)
              {
                throw;
              }
              catch (Exception e)
              {
                m_Logger.LogException("Unknown error adding child pi template", e);

                throw new MASBasicException("Error adding child priceable item template");
              }
            }
          }
          #endregion

          #region Audit Entry
          AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_TEMPLATE_CREATE, GetSessionContext().AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, piTemplate.ID.Value,
          String.Format("Successfully created priceable item template : {0}", piTemplate.Name));
          m_Logger.LogDebug(String.Format("Successfully created priceable item template : {0} {1}", piTemplate.ID.Value, piTemplate.Name));
          #endregion



        }

        scope.Complete();

      }

    }

    private void InternalUpdatePITemplate(ref BasePriceableItemTemplate piTemplate)
    {
      if (PCConfigManager.IsBusinessRuleEnabled(PCConfigManager.MTPC_BUSINESS_RULE_PI_CheckCycleChange))
      {
        //TODO: Call validate cycle change. Verify this is applicable for update pitemplate.
        //ValidateCycleChange();

      }

      using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Required, new TransactionOptions(), EnterpriseServicesInteropOption.Full))
      {

        using (IMTConnection conn = ConnectionManager.CreateConnection(PCWS_QUERY_FOLDER))
        {
          BasePropsUtils.UpdateBaseProps(GetSessionContext(), piTemplate.Description, piTemplate.IsDescriptionDirty,
                          piTemplate.DisplayName, piTemplate.IsDisplayNameDirty, piTemplate.ID.Value);

          #region Update Kind Specific Details.
          switch (piTemplate.PIKind)
          {
            case PriceableItemKinds.NonRecurring:
              m_Logger.LogDebug("Updating NonRecurring specific properties");
              #region Updating Nonrecurring specific properties.
              UpdateNonRecurringChargePITemplate(piTemplate as NonRecurringChargePITemplate);
              #endregion
              break;
            case PriceableItemKinds.Discount:
              m_Logger.LogDebug("Updating discount specific properties");
              #region updating Discount Properties
              UpdateDiscountChargePITemplate(piTemplate as DiscountPITemplate);
              #endregion
              break;
            case PriceableItemKinds.UnitDependentRecurring:
            case PriceableItemKinds.Recurring:
              m_Logger.LogDebug("Updating UnitDependentRecurring/Recurring specific properties");
              #region Updating UnitDependentRecurring/Recurring specific properties
              UpdateRecurringChargePITemplate(piTemplate as BaseRecurringChargePITemplate);
              #endregion
              break;
          }
          #endregion

          ProcessLocalizationData(piTemplate.ID.Value, piTemplate.LocalizedDisplayNames,
                                  piTemplate.IsLocalizedDisplayNamesDirty, piTemplate.LocalizedDescriptions,
                                  piTemplate.IsLocalizedDescriptionDirty);

          UpsertExtendedProps(piTemplate.ID.Value, piTemplate);

          PropagateExtendedProps(piTemplate.ID.Value, piTemplate);

          PropagateBaseProps(piTemplate.ID.Value, piTemplate);

          UpdateAdjustmentTemplates(ref piTemplate);

          UpdateCounters(ref piTemplate);

          #region Updating Child Templates.
          List<PropertyInfo> childPIProperties = piTemplate.GetProperties();

          foreach (PropertyInfo childPIProperty in childPIProperties)
          {
            if (childPIProperty.PropertyType.IsSubclassOf(typeof(BasePriceableItemTemplate)))
            {
              try
              {
                object o = childPIProperty.GetValue(piTemplate, null);
                if (o == null)
                {
                  m_Logger.LogError("Child Priceable Item Template cannot be null. error while updating Priceable Item Template");
                  throw new MASBasicException("Child Priceable Item Template cannot be null. error while updating Priceable Item Template");
                }

                BasePriceableItemTemplate bpt = o as BasePriceableItemTemplate;
                InternalUpdatePITemplate(ref bpt);
              }
              catch (MASBasicException)
              {
                throw;
              }
              catch (Exception e)
              {
                m_Logger.LogException("Unknown error whild updating child pi template", e);

                throw new MASBasicException("Error while updating child priceable item template");
              }
            }
          }
          #endregion

          #region Audit Entry
          AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_TEMPLATE_UPDATE, GetSessionContext().AccountID, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, piTemplate.ID.Value,
          String.Format("Successfully updated priceable item template : {0}", piTemplate.Name));
          m_Logger.LogDebug(String.Format("Successfully updated priceable item template : {0} {1}", piTemplate.ID.Value, piTemplate.Name));
          #endregion


        }

        scope.Complete();
      }

    }

    private void PropagateBaseProps(int templateId, BasePriceableItemTemplate piTemplate)
    {
      if (piTemplate.IsDescriptionDirty && !PCConfigManager.IsPropertyOverridable((int)piTemplate.PIKind, "Description"))
      {
        PropagateBaseProps("__PROPAGATE_DESCRIPTION__", templateId);
      }
      if (piTemplate.IsDisplayNameDirty && !PCConfigManager.IsPropertyOverridable((int)piTemplate.PIKind, "DisplayName"))
      {
        PropagateBaseProps("__PROPAGATE_DISPAY_NAME__", templateId);
      }
      if (piTemplate.IsLocalizedDescriptionDirty && !PCConfigManager.IsPropertyOverridable((int)piTemplate.PIKind, "Descriptions"))
      {
        if (!string.IsNullOrEmpty(piTemplate.Description))
        {
          PropagateBaseProps("__PROPAGATE_LOCALIZED_DESCRIPTION__", templateId);
        }
        else
        {
          if (piTemplate.LocalizedDescriptions.HasValue())
          {
            throw new MASBasicException("Cannot add localized values if default description is empty are not defined.");
          }
        }

      }
      if (piTemplate.IsLocalizedDisplayNamesDirty && !PCConfigManager.IsPropertyOverridable((int)piTemplate.PIKind, "DisplayNames"))
      {
        if (!string.IsNullOrEmpty(piTemplate.Description))
        {
          PropagateBaseProps("__PROPAGATE_LOCALIZED_DISPAY_NAME__", templateId);
        }
        else
        {
          if (piTemplate.LocalizedDisplayNames.HasValue())
          {
            throw new MASBasicException("Cannot add localized values if default display name is empty are not defined.");
          }
        }
      }
    }

    private void PropagateBaseProps(string queryTag, int templateId)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, queryTag))
        {
          stmt.AddParam("%%ID_TEMPLATE%%", templateId);
          stmt.AddParamIfFound("%%ID_LANG_CDE%%", GetSessionContext().LanguageID);
          stmt.ExecuteNonQuery();
        }
      }
    }

    private void UpdateAdjustmentTemplates(ref BasePriceableItemTemplate piTemplate)
    {
      foreach (PropertyInfo propInfo in piTemplate.GetProperties())
      {
        if (propInfo.PropertyType != typeof(AdjustmentTemplate))
          continue;

        AdjustmentTemplate adjustTemplate = propInfo.GetValue(piTemplate, null) as AdjustmentTemplate;

        if (piTemplate.IsDirty(propInfo))
        {
          m_Logger.LogDebug("check whether reason codes are dirty and reason code is provided.");

          if (adjustTemplate != null && adjustTemplate.IsReasonCodesDirty)
          {
            if (!adjustTemplate.ReasonCodes.HasValue())
            {
              throw new MASBasicException("Reason codes not provided");
            }
          }

          object[] attribs = propInfo.GetCustomAttributes(typeof(MTAdjustmentTypeAttribute), true);
          if (attribs.HasValue())
          {
            MTAdjustmentTypeAttribute attrib = attribs[0] as MTAdjustmentTypeAttribute;

            int adjTemplateId = -1;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement getStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_ADJ_TEMPL_ID_FOR_UPDATE__"))
              {
                getStmt.AddParam("%%ADJ_NAME%%", attrib.Type);
                getStmt.AddParam("%%PI_ID%%", piTemplate.ID.Value);
                getStmt.AddParam("%%UPDLOCK%%", (conn.ConnectionInfo.IsOracle ? "" : "with(updlock)"));
                using (IMTDataReader rdr = getStmt.ExecuteReader())
                {
                  while (rdr.Read())
                  {
                    if (!rdr.IsDBNull("id_prop"))
                      adjTemplateId = rdr.GetInt32("id_prop");
                  }
                }
              }
            }

            if (adjTemplateId != -1)
            {
              if (adjustTemplate != null)
              {
                m_Logger.LogDebug("Updating adjustment template: {0} for type {1}", adjustTemplate.Name, attrib.Type);

                #region Update BaseProps, Process localization and Update Reasoncode map.
                BasePropsUtils.UpdateBaseProps(GetSessionContext(),
                                adjustTemplate.Description,
                                adjustTemplate.IsDescriptionDirty,
                                adjustTemplate.DisplayName,
                                adjustTemplate.IsDisplayNameDirty,
                                adjTemplateId);

                ProcessLocalizationData(adjTemplateId,
                                        adjustTemplate.LocalizedDisplayNames,
                                        adjustTemplate.IsLocalizedDisplayNamesDirty,
                                        adjustTemplate.LocalizedDescriptions,
                                        adjustTemplate.IsLocalizedDescriptionsDirty);

                UpdateReasonCodeMappings(ref adjustTemplate);
                #endregion
              }
              else
              {
                m_Logger.LogDebug("Deleting adjustment template: {0} for type {1}", adjustTemplate.Name, attrib.Type);

                #region Delete Adjustment Template and base props.
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                  using (IMTCallableStatement stmt = conn.CreateCallableStatement("DeleteAdjustmentTemplate"))
                  {
                    stmt.AddParam("adjTemplId", MTParameterType.Integer, adjTemplateId);
                    stmt.AddOutputParam("status", MTParameterType.Integer, 0);
                    stmt.ExecuteNonQuery();

                    int status = (int)stmt.GetOutputValue("status");

                    if (status == -10)
                    {
                      throw new MASBasicException(string.Format("Unable to remove adjustment template with ID {0} since it is in use.", adjTemplateId));
                    }
                  }

                  using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("DeleteBaseProps"))
                  {
                    callableStmt.AddParam("a_id_prop", MTParameterType.Integer, adjTemplateId);
                    callableStmt.ExecuteNonQuery();
                  }
                }
                #endregion
              }

            }
            else
            {
              CreateAdjustmentTemplate(ref adjustTemplate, piTemplate.ID.Value, propInfo);
            }

          }


        }



      }
    }

    private void UpdateCounters(ref BasePriceableItemTemplate piTemplate)
    {
      Dictionary<string, int> counters = new Dictionary<string, int>();
      m_Logger.LogDebug(string.Format("Fetching all counter for template id {0}", piTemplate.ID.Value));
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_COUNTER_BY_TEMPLATE_ID__"))
        {
          stmt.AddParam("%%TEMPLATE_ID%%", piTemplate.ID.Value);
          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            while (rdr.Read())
            {
              counters.Add(rdr.GetString("Name"), rdr.GetInt32("ID"));
            }
          }
        }
      }

      foreach (PropertyInfo propInfo in piTemplate.GetProperties())
      {
        if (propInfo.PropertyType != typeof(Counter))
          continue;

        Counter counter = propInfo.GetValue(piTemplate, null) as Counter;

        if (counter != null)
        {
          //Add/Update Counter.

          if (string.IsNullOrEmpty(counter.Name))
          {
            throw new MASBasicException("Counter Name is either empty or Null. Cannot proceed.");
          }

          if (!counters.Keys.Contains(counter.Name))
          {
            //Add Mode
            CreateCounter(piTemplate.ID.Value, ref counter, propInfo);
            propInfo.SetValue(piTemplate, counter, null);
          }
          else
          {
            //Update mode.

            #region GetCounterTypeId from custom attributes.
            m_Logger.LogDebug("Check whether CounterTypeMetadataAttributes is present.");
            object[] counterTypeMetaDataAttributes = counter.GetType().GetCustomAttributes(typeof(CounterTypeMetadataAttribute), false);

            if (!counterTypeMetaDataAttributes.HasValue())
            {
              throw new MASBasicException("Counter Type MetaData Attributes are not defined or invalid");
            }

            CounterTypeMetadataAttribute ctattrib = (CounterTypeMetadataAttribute)counterTypeMetaDataAttributes[0];

            m_Logger.LogDebug("Fetch Counter Type ID based on Counter Type name");
            PCIdentifier counterTypeID = new PCIdentifier(ctattrib.Name);
            int counterTypeId = PCIdentifierResolver.ResolveCounterType(counterTypeID);

            if (counterTypeId == -1)
            {
              m_Logger.LogDebug("cannot find counter type id");
              throw new MASBasicException("Could not find counter type");
            }
            #endregion

            if (piTemplate.IsDirty(propInfo))
            {
              #region UpdateCounter in db.
              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTCallableStatement updStmt = conn.CreateCallableStatement("UpdateCounterInstance"))
                {
                  updStmt.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
                  updStmt.AddParam("id_prop", MTParameterType.Integer, DatabaseUtils.FormatValueForDB(counter.ID.Value));
                  updStmt.AddParam("counter_type_id", MTParameterType.Integer, DatabaseUtils.FormatValueForDB(counterTypeId));
                  updStmt.AddParam("nm_name", MTParameterType.String, DatabaseUtils.FormatValueForDB(counter.Name));
                  updStmt.AddParam("nm_desc", MTParameterType.String, DatabaseUtils.FormatValueForDB(counter.Description));
                  updStmt.ExecuteNonQuery();
                }
              }
              #endregion
            }

            #region Delete Existing Counter Params and Add from scratch.
            //Delete Existing Counter Params and Add from scratch.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTCallableStatement delProc = conn.CreateCallableStatement("DeleteCounterParamInstances"))
              {
                delProc.AddParam("id_counter", MTParameterType.Integer, counter.ID.Value);
                delProc.ExecuteNonQuery();
              }
            }

            CreateCounterParameters(ref counter, counterTypeId);
            #endregion

            counters.Remove(counter.Name);
          }
        }
      }

      #region Remove Counters that was not passed this time.
      foreach (KeyValuePair<string, int> counter in counters)
      {
        //DELETE Mode.
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTCallableStatement delStmt = conn.CreateCallableStatement("RemoveCounterInstance"))
          {
            delStmt.AddParam("id_prop", MTParameterType.Integer, DatabaseUtils.FormatValueForDB(counter.Value));
            delStmt.ExecuteNonQuery();
          }
        }

      }
      #endregion

    }

    private void UpdateReasonCodeMappings(ref  AdjustmentTemplate adjTemplate)
    {

      List<int> reasonCodes = new List<int>();

      //Fetch Existing Reason Codes.
      m_Logger.LogDebug("Fetching existing reason codes");
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement getQuery = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_REASON_CODE_BY_ADJ_ID__"))
        {
          getQuery.AddParam("%%ADJ_ID%%", adjTemplate.ID.Value);

          using (IMTDataReader rdr = getQuery.ExecuteReader())
          {
            while (rdr.Read())
            {
              reasonCodes.Add(rdr.GetInt32("ID"));
            }
          }
        }
      }

      foreach (ReasonCode rsnCode in adjTemplate.ReasonCodes)
      {
        SaveReasonCode(rsnCode);

        if (reasonCodes != null && !reasonCodes.Exists(rc => rc == rsnCode.ID.Value))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__CREATE_REASON_CODE_MAPPING__"))
            {
              createStmt.AddParam("%%ID_ADJUSTMENT%%", adjTemplate.ID.Value);
              createStmt.AddParam("%%ID_REASON_CODE%%", rsnCode.ID.Value);
              createStmt.ExecuteNonQuery();
            }
          }
        }
        else
        {
          if (reasonCodes != null)
            reasonCodes.Remove(reasonCodes.Find(rc => rc == rsnCode.ID.Value));
        }
      }

      if (reasonCodes.HasValue())
      {
        //remove reason code mappings.
        m_Logger.LogDebug("remove reason code mappings");
        foreach (int rcode in reasonCodes)
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement delStmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__REMOVE_REASON_CODE_MAPPING__"))
            {
              delStmt.AddParam("%%ID_ADJUSTMENT%%", adjTemplate.ID.Value);
              delStmt.AddParam("%%ID_REASON_CODE%%", rcode);
              delStmt.ExecuteNonQuery();
            }
          }

        }
      }
    }

    private void PropagateProperties(string tableName, string updateList, string columnList, string insertList, int piTemplateId)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTCallableStatement callStmt = conn.CreateCallableStatement("PropagateProperties"))
        {
          callStmt.AddParam("table_name", MTParameterType.String, tableName);
          callStmt.AddParam("update_list", MTParameterType.String, updateList);
          callStmt.AddParam("insert_list", MTParameterType.String, insertList);
          callStmt.AddParam("clist", MTParameterType.String, columnList);
          callStmt.AddParam("id_pi_template", MTParameterType.Integer, piTemplateId);

          callStmt.ExecuteNonQuery();
        }
      }

    }


    private void UpdateRecurringChargePITemplate(BaseRecurringChargePITemplate baseRecurringChargePITemplate)
    {
      bool bRunUpdate = false;
      bool bUpdateLocalizedUnitValueNames = false;
      bool bUpdateUnitValueEnumeration = false;
      bool bUpdateUnitValue = false;
      StringBuilder updateStr = new StringBuilder();
      StringBuilder insertStr = new StringBuilder();
      StringBuilder columnList = new StringBuilder();

      #region Update Cycle
      if (baseRecurringChargePITemplate.IsCycleDirty)
      {
        bRunUpdate = true;

        string mode;
        int? cycleId, cycleTypeId;
        ResolveUsageCycleInfo(baseRecurringChargePITemplate.Cycle, out mode, out cycleId, out cycleTypeId);

        updateStr.Append(String.Format(",id_usage_cycle = {0}, id_cycle_type = {1}", ((cycleId.HasValue) ? cycleId.Value.ToString() : "null"), ((cycleTypeId.HasValue) ? cycleTypeId.Value.ToString() : "null")));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "Cycle"))
        {
          columnList.Append(string.Format(",{0},{1}", DatabaseUtils.FormatValueForDB(cycleId), DatabaseUtils.FormatValueForDB(cycleTypeId)));
          insertStr.Append(",id_usage_cycle, id_cycle_type");
        }

      }
      #endregion

      #region Update FixedProrationLength

      if (baseRecurringChargePITemplate.IsFixedProrationLengthDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_fixed_proration_length = '{0}'", (baseRecurringChargePITemplate.FixedProrationLength.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "FixedProrationLength"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.FixedProrationLength.Value) ? "Y" : "N"));
          insertStr.Append(",b_fixed_proration_length");
        }
      }

      #endregion

      #region Update ProrateOnDeactivation
      if (baseRecurringChargePITemplate.IsProrateOnDeactivationDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_prorate_on_deactivate = '{0}'", (baseRecurringChargePITemplate.ProrateOnDeactivation.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "ProrateOnDeactivation"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.ProrateOnDeactivation.Value) ? "Y" : "N"));
          insertStr.Append(",b_prorate_on_deactivate");
        }

      }
      #endregion

      #region Update ProrateInstantly
      if (baseRecurringChargePITemplate.IsProrateInstantlyDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_prorate_instantly = '{0}'", (baseRecurringChargePITemplate.ProrateInstantly.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "ProrateInstantly"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.ProrateInstantly.Value) ? "Y" : "N"));
          insertStr.Append(",b_prorate_instantly");
        }

      }
      #endregion

      #region Update ProrateOnActivation
      if (baseRecurringChargePITemplate.IsProrateOnActivationDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_prorate_on_activate = '{0}'", (baseRecurringChargePITemplate.ProrateOnActivation.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "ProrateOnActivation"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.ProrateOnActivation.Value) ? "Y" : "N"));
          insertStr.Append(",b_prorate_on_activate");
        }

      }
      #endregion

      #region Update ChargeAdvance
      if (baseRecurringChargePITemplate.IsChargeAdvanceDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_advance = '{0}'", (baseRecurringChargePITemplate.ChargeAdvance.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "ChargeAdvance"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.ChargeAdvance.Value) ? "Y" : "N"));
          insertStr.Append(",b_advance");
        }

      }
      #endregion

      #region Update ChargePerParticipant
      if (baseRecurringChargePITemplate.IsChargePerParticipantDirty)
      {
        bRunUpdate = true;

        updateStr.Append(String.Format(",b_charge_per_participant = '{0}'", (baseRecurringChargePITemplate.ChargePerParticipant.Value) ? "Y" : "N"));

        if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "ChargePerParticipant"))
        {
          columnList.Append(string.Format(",'{0}'", (baseRecurringChargePITemplate.ChargePerParticipant.Value) ? "Y" : "N"));
          insertStr.Append(",b_charge_per_participant");
        }
      }
      #endregion

      if (baseRecurringChargePITemplate.GetType().IsSubclassOf(typeof(UnitDependentRecurringChargePITemplate)))
      {
        UnitDependentRecurringChargePITemplate udrcTemplate = ((UnitDependentRecurringChargePITemplate)baseRecurringChargePITemplate);

        #region Update UnitDisplayName
        if (udrcTemplate.IsUnitDisplayNameDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",nm_unit_display_name = {0}", DatabaseUtils.FormatValueForDB(udrcTemplate.UnitDisplayName)));

          if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "UnitDisplayName"))
          {
            columnList.Append(string.Format(",{0}", DatabaseUtils.FormatValueForDB(udrcTemplate.UnitDisplayName)));
            insertStr.Append(",nm_unit_display_name");
          }
        }

        if (udrcTemplate.IsLocalizedUnitDisplayNamesDirty)
        {
          bUpdateLocalizedUnitValueNames = true;
        }
        #endregion

        #region Update RatingType
        if (udrcTemplate.IsRatingTypeDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",n_rating_type = {0}", (int)udrcTemplate.RatingType));

          if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "RatingType"))
          {
            columnList.Append(string.Format(",{0}", DatabaseUtils.FormatValueForDB(udrcTemplate.RatingType)));
            insertStr.Append(",n_rating_type");
          }
        }
        #endregion

        #region Update IntegerUnitValue
        if (udrcTemplate.IsIntegerUnitValueDirty)
        {
          bRunUpdate = true;

          updateStr.Append(String.Format(",b_integral = '{0}'", (udrcTemplate.IntegerUnitValue.Value) ? "Y" : "N"));

          if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "IntegerUnitValue"))
          {
            columnList.Append(string.Format(",'{0}'", (udrcTemplate.IntegerUnitValue.Value) ? "Y" : "N"));
            insertStr.Append(",b_integral");
          }
        }
        #endregion

        #region Update MaxUnitValue
        if (udrcTemplate.IsMaxUnitValueDirty)
        {
          bRunUpdate = true;
          bUpdateUnitValue = true;

          updateStr.Append(String.Format(",max_unit_value = {0}", udrcTemplate.MaxUnitValue));

          if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "MaxUnitValue"))
          {
            columnList.Append(string.Format(",{0}", DatabaseUtils.FormatValueForDB(udrcTemplate.MaxUnitValue)));
            insertStr.Append(",max_unit_value");
          }
        }
        #endregion

        #region Update MinUnitValue
        if (udrcTemplate.IsMinUnitValueDirty)
        {
          bRunUpdate = true;
          bUpdateUnitValue = true;

          updateStr.Append(String.Format(",min_unit_value = {0}", udrcTemplate.MinUnitValue));

          if (!PCConfigManager.IsPropertyOverridable((int)baseRecurringChargePITemplate.PIKind, "MinUnitValue"))
          {
            columnList.Append(string.Format(",{0}", DatabaseUtils.FormatValueForDB(udrcTemplate.MinUnitValue)));
            insertStr.Append(",min_unit_value");
          }
        }
        #endregion

        #region Check For Updating UnitValueEnumeration
        if (udrcTemplate.IsAllowedUnitValuesDirty)
        {
          bUpdateUnitValueEnumeration = true;
        }
        #endregion
      }

      if (bRunUpdate)
      {
        //Remove comma at the beginning
        updateStr.Remove(0, 1);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_recur");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr.ToString(), true); //third parameter added to stop adding comma for every comma in updatestr which is causing sql syntax error.
            stmt.AddParam("%%ID_PROP%%", baseRecurringChargePITemplate.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }
      }

      #region Propagate recurring properties to all instances.
      if (columnList.Length > 0)
      {
        //Removes comma.
        columnList.Remove(0, 1);
        insertStr.Remove(0, 1);

        PropagateProperties("t_recur", updateStr.ToString(), columnList.ToString(), insertStr.ToString(), baseRecurringChargePITemplate.ID.Value);

      }
      #endregion

      #region Update Localized UnitName values
      if (bUpdateLocalizedUnitValueNames)
      {
        UnitDependentRecurringChargePITemplate udrcTemplate = ((UnitDependentRecurringChargePITemplate)baseRecurringChargePITemplate);

        int n_unit_displayname = -1;
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement adapterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC_PCWS__"))
          {
            adapterStmt.AddParam("%%ID_PROP%%", udrcTemplate.ID.Value);

            using (IMTDataReader rdr = adapterStmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                n_unit_displayname = rdr.GetInt32("n_unit_display_name");
              }
            }
          }
        }
        ProcessLocalizationData(n_unit_displayname,
                                udrcTemplate.LocalizedUnitDisplayNames,
                                udrcTemplate.IsLocalizedUnitDisplayNamesDirty,
                                null,
                                null,
                                false);
      }
      #endregion

      #region Update AllowedUnitValues
      if (bUpdateUnitValueEnumeration)
      {
        UnitDependentRecurringChargePITemplate udrcTemplate = ((UnitDependentRecurringChargePITemplate)baseRecurringChargePITemplate);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_RECURRING_CHARGE_ENUMS_BY_ID_PCWS__"))
          {
            stmt.AddParam("%%ID_PROP%%", udrcTemplate.ID.Value);
            stmt.ExecuteNonQuery();
          }
        }

        AddUDRCUnitValues(udrcTemplate);

        #region Delete and propagate Unit Value enumerations to all Instances.
        if (!PCConfigManager.IsPropertyOverridable((int)udrcTemplate.PIKind, "UnitValueEnumeration"))
        {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTAdapterStatement deleteStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_RECURRING_CHARGE_ENUMS_BY_TEMPLATE_ID_PCWS__"))
            {
              deleteStmt.AddParam("%%ID_PROP%%", udrcTemplate.ID.Value);
              deleteStmt.ExecuteNonQuery();
            }

            using (IMTAdapterStatement propagateStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__PROPAGATE_RECURRING_CHARGE_ENUMS_BY_TEMPLATE_ID_PCWS__"))
            {
              propagateStmt.AddParam("%%ID_PROP%%", udrcTemplate.ID.Value);
              propagateStmt.ExecuteNonQuery();
            }
          }
        }
        #endregion
      }
      #endregion

      #region Check for UnitValue violations
      if (bUpdateUnitValue || bUpdateUnitValueEnumeration)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_UNIT_VALUE_CONSTRAINT_VIOLATIONS_PCWS__"))
          {
            stmt.AddParam("%%TT_MAX%%", MetraTime.Max);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr.Read())
              {
                throw new MASBasicException("Specified Unit value constraints invalidate existing subscriptions");
              }
            }
          }
        }
      }
      #endregion

    }

    private void UpdateNonRecurringChargePITemplate(NonRecurringChargePITemplate nrPITemplate)
    {
      if (nrPITemplate.IsEventTypeDirty)
      {
        string updateStr = String.Format("n_event_type = {0}", (int)nrPITemplate.EventType);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_nonrecur");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr);
            stmt.AddParam("%%ID_PROP%%", nrPITemplate.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }

        if (!PCConfigManager.IsPropertyOverridable((int)nrPITemplate.PIKind, "EventType"))
        {
          string columnList = "n_event_type";
          string insertStr = DatabaseUtils.FormatValueForDB(nrPITemplate.EventType);
          PropagateProperties("t_non_recur", updateStr, columnList, insertStr, nrPITemplate.ID.Value);
        }

      }
    }

    private void UpdateDiscountChargePITemplate(DiscountPITemplate discountPITemplate)
    {
      if (discountPITemplate.IsCycleDirty)
      {
        string mode;
        int? cycleId, cycleTypeId;
        ResolveUsageCycleInfo(discountPITemplate.Cycle, out mode, out cycleId, out cycleTypeId);

        string updateStr = String.Format("id_usage_cycle = {0}, id_cycle_type = {1}", ((cycleId.HasValue) ? cycleId.Value.ToString() : DatabaseUtils.FormatValueForDB(null)), ((cycleTypeId.HasValue) ? cycleTypeId.Value.ToString() : DatabaseUtils.FormatValueForDB(null)));

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_PIKIND_SPECIFIC_PROPERTIES__"))
          {
            stmt.AddParam("%%TABLE_NAME%%", "t_discount");
            stmt.AddParam("%%UPDATE_VALUES%%", updateStr);
            stmt.AddParam("%%ID_PROP%%", discountPITemplate.ID.Value);

            stmt.ExecuteNonQuery();
          }
        }

        if (!PCConfigManager.IsPropertyOverridable((int)discountPITemplate.PIKind, "Cycle"))
        {
          string columnList = "id_usage_cycle, id_cycle_type";
          string insertStr = string.Format("{0},{1}", DatabaseUtils.FormatValueForDB(cycleId), DatabaseUtils.FormatValueForDB(cycleTypeId));
          PropagateProperties("t_discount", updateStr, columnList, insertStr, discountPITemplate.ID.Value);
        }

      }
    }

    private void AddUDRCUnitValues(UnitDependentRecurringChargePITemplate udrcTemplate)
    {
      if (udrcTemplate != null && udrcTemplate.AllowedUnitValues.HasValue())
      {
        m_Logger.LogDebug("Adding UDRC allowed unit values");
        string baseQueryText = "\n INSERT INTO t_recur_enum (id_prop, enum_value) values ({0},{1}); \n";

        string queryText = "BEGIN\n";

        foreach (decimal udrcEnumValue in udrcTemplate.AllowedUnitValues)
        {
          queryText += string.Format(baseQueryText, udrcTemplate.ID.Value, udrcEnumValue.ToString());
        }

        queryText += "\nEND;";

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTStatement stmt = conn.CreateStatement(queryText))
          {
            stmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void CreateAdjustmentTemplate(ref AdjustmentTemplate adjustTemplate, int piTemplateId, PropertyInfo propInfo)
    {

      m_Logger.LogDebug("Create Adjustment Template");

      adjustTemplate.ID = BasePropsUtils.CreateBaseProps(GetSessionContext(), adjustTemplate.Name, adjustTemplate.Description, adjustTemplate.DisplayName, ADJUSTMENT_KIND);

      object[] attribs = propInfo.GetCustomAttributes(typeof(MTAdjustmentTypeAttribute), true);
      if (attribs.HasValue())
      {
        MTAdjustmentTypeAttribute attrib = attribs[0] as MTAdjustmentTypeAttribute;

        string guid = Guid.NewGuid().ToByteArray()[0].ToString();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__INSERT_ADJUSTMENT_TEMPLATE__"))
          {
            createStmt.AddParam("%%ID_PROP%%", adjustTemplate.ID.Value);
            if (conn.ConnectionInfo.IsOracle)
            {
              createStmt.AddParam("%%GUID%%", string.Format("hextoraw({0})", guid));// string.Format("hextoraw({0})", guid));
            }
            else
            {
              createStmt.AddParam("%%GUID%%", "0xABCD");// string.Format("CONVERT(binary,{0})", guid));
            }
            createStmt.AddParam("%%PI_ID%%", piTemplateId);
            createStmt.AddParam("%%ADJ_NAME%%", attrib.Type);

            createStmt.ExecuteNonQuery();
          }
        }
      }

      ProcessLocalizationData(adjustTemplate.ID.Value, adjustTemplate.LocalizedDisplayNames,
                              adjustTemplate.IsLocalizedDisplayNamesDirty, adjustTemplate.LocalizedDescriptions,
                              adjustTemplate.IsLocalizedDescriptionsDirty);


      m_Logger.LogDebug("Save Reason Codes");

      for (int i = 0; i < adjustTemplate.ReasonCodes.Count; i++)
      {
        ReasonCode reasonCode = adjustTemplate.ReasonCodes[i];

        SaveReasonCode(reasonCode);

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__CREATE_REASON_CODE_MAPPING__"))
          {
            createStmt.AddParam("%%ID_ADJUSTMENT%%", adjustTemplate.ID.Value);
            createStmt.AddParam("%%ID_REASON_CODE%%", reasonCode.ID.Value);
            createStmt.ExecuteNonQuery();
          }
        }
      }
    }

    private void CreateAdjusmentTemplates(ref BasePriceableItemTemplate piTemplate)
    {
      foreach (PropertyInfo propInfo in piTemplate.GetProperties())
      {
        if (propInfo.PropertyType != typeof(AdjustmentTemplate))
          continue;

        AdjustmentTemplate adjustTemplate = propInfo.GetValue(piTemplate, null) as AdjustmentTemplate;

        if (adjustTemplate == null)
          continue;

        m_Logger.LogDebug("check whether reason codes are provided.");
        if (!adjustTemplate.ReasonCodes.HasValue())
        {
          throw new MASBasicException("Reason codes required.");
        }

        CreateAdjustmentTemplate(ref adjustTemplate, piTemplate.ID.Value, propInfo);

      }
    }

    private void SaveReasonCode(ReasonCode reasonCode)
    {
      try
      {
        PCIdentifier reasonCodeID = new PCIdentifier(reasonCode.Name);

        int rcodeId = PCIdentifierResolver.ResolveReasonCode(reasonCodeID);

        //reason code not exists
        if (rcodeId <= 0)
        {
          int reasonCodeId;
          try
          {
            reasonCodeId = BasePropsUtils.CreateBaseProps(GetSessionContext(), reasonCode.Name, reasonCode.Description, reasonCode.DisplayName, REASON_CODE_KIND);
            reasonCode.ID = reasonCodeId;
          }
          catch (Exception e)
          {
            m_Logger.LogError("Error while creating base props for reason codes.", e.Message);
            throw;
          }


          try
          {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
              using (IMTAdapterStatement createStmt = conn.CreateAdapterStatement(ADJUSTMENT_QUERY_FOLDER, "__CREATE_REASON_CODE__"))
              {
                createStmt.AddParam("%%ID_PROP%%", reasonCode.ID);
                if (conn.ConnectionInfo.IsOracle)
                {
                  createStmt.AddParam("%%GUID%%", "ABCD"); //string.Format("hextoraw({0})", Guid.NewGuid().ToByteArray()));
                }
                else
                {
                  createStmt.AddParam("%%GUID%%", "0xABCD"); // string.Format("CONVERT(binary,{0})", Guid.NewGuid().ToByteArray()));
                }

                createStmt.ExecuteNonQuery();
              }
            }
          }
          catch (Exception e)
          {
            m_Logger.LogError("Error while executing create reason code query.", e.Message);
            throw;
          }

        }
        else
        {
          reasonCode.ID = rcodeId;
          try
          {
            BasePropsUtils.UpdateBaseProps(GetSessionContext(), reasonCode.Description, reasonCode.IsDescriptionDirty,
                            reasonCode.DisplayName, reasonCode.IsDisplayNameDirty, reasonCode.ID.Value);
          }
          catch (Exception e)
          {
            m_Logger.LogError("Error while updating base props for reason codes.", e.Message);
            throw;
          }
        }

        try
        {
          ProcessLocalizationData(reasonCode.ID.Value, reasonCode.LocalizedDisplayNames, reasonCode.IsLocalizedDisplayNamesDirty,
                                  reasonCode.LocalizedDescriptions, reasonCode.IsLocalizedDescriptionsDirty);
        }
        catch (Exception e)
        {
          m_Logger.LogError("Error while processing localization data for reason codes", e.Message);
          throw;
        }
      }
      catch (MASBasicException mbaE)
      {
        m_Logger.LogError("Error while creating reason codes", mbaE.Message);
        throw;
      }
      catch (Exception e)
      {
        m_Logger.LogError("Error while creating reason codes", e.Message);
        throw new MASBasicException("Error while creating reason codes" + e.Message);
      }
    }

    private void CreateCounter(int templateId, ref Counter counter, PropertyInfo propInfo)
    {
      #region Create Counter Instances and Add Counter Parameters.

      m_Logger.LogDebug("Creating Counter Instances and Adding Counter parameters");
      m_Logger.LogDebug("Check whether CounterTypeMetadataAttributes is present.");
      object[] counterTypeMetaDataAttributes = counter.GetType().GetCustomAttributes(typeof(CounterTypeMetadataAttribute), false);
      if (!counterTypeMetaDataAttributes.HasValue())
      {
        throw new MASBasicException("Counter Type MetaData Attributes are not defined or invalid");
      }

      CounterTypeMetadataAttribute ctattrib = (CounterTypeMetadataAttribute)counterTypeMetaDataAttributes[0];

      m_Logger.LogDebug("Fetch Counter Type ID based on Counter Type name");
      PCIdentifier counterTypeID = new PCIdentifier(ctattrib.Name);
      int counterTypeId = PCIdentifierResolver.ResolveCounterType(counterTypeID);

      if (counterTypeId == -1)
      {
        m_Logger.LogDebug("cannot find counter type id");
        throw new MASBasicException("Could not find counter type");
      }

      #region Adding Counter Instance

      m_Logger.LogDebug("Adding Counter Instance");
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTCallableStatement createCounterInstanceStmt = conn.CreateCallableStatement("AddCounterInstance"))
        {
          createCounterInstanceStmt.AddParam("id_lang_code", MTParameterType.Integer, DatabaseUtils.FormatValueForDB(GetSessionContext().LanguageID));
          createCounterInstanceStmt.AddParam("n_kind", MTParameterType.Integer, COUNTER_KIND);
          createCounterInstanceStmt.AddParam("nm_name", MTParameterType.String, counter.Name);
          createCounterInstanceStmt.AddParam("nm_desc", MTParameterType.String, counter.Description);
          createCounterInstanceStmt.AddParam("counter_type_id", MTParameterType.Integer, counterTypeId);
          createCounterInstanceStmt.AddOutputParam("id_prop", MTParameterType.Integer, 0);

          try
          {
            m_Logger.LogDebug("Calling AddCounterInstance procedure");
            createCounterInstanceStmt.ExecuteNonQuery();
          }
          catch (Exception e)
          {

            m_Logger.LogError("Error executing AddCounterInstance procedure", e.Message);
            throw;
          }

          int counterId = (int)createCounterInstanceStmt.GetOutputValue("id_prop");
          counter.ID = counterId;

        }
      }
      #endregion

      m_Logger.LogDebug("Checking counter property definition attributes");
      object[] counterPropertyDefinitionAttributes = propInfo.GetCustomAttributes(typeof(CounterPropertyDefinitionAttribute), false);
      if (!counterPropertyDefinitionAttributes.HasValue())
      {
        m_Logger.LogDebug("Counter Property Definition attributes not defined or invalid");
        throw new MASBasicException("Counter Property Definition attributes not defined or invalid");
      }

      #region Resolving Counter Property Definition
      CounterPropertyDefinitionAttribute cpdattrib = (CounterPropertyDefinitionAttribute)counterPropertyDefinitionAttributes[0];

      PCIdentifier cntPropDefID = new PCIdentifier(cpdattrib.Name);

      int counterPropDefId = PCIdentifierResolver.ResolveCounterPropDef(cntPropDefID);

      if (counterPropDefId == -1)
      {
        m_Logger.LogDebug("cannot fetch counter property definition.");
        throw new MASBasicException("cannot fetch counter property definition.");
      }
      #endregion

      #region Add Counter Map

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement cntPropCreateStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_COUNTER_MAPPING_PCWS__"))
        {
          cntPropCreateStmt.AddParam("%%ID_COUNTER%%", counter.ID.Value);
          cntPropCreateStmt.AddParam("%%ID_PI%%", templateId);
          cntPropCreateStmt.AddParam("%%ID_CPD%%", counterPropDefId);
          cntPropCreateStmt.ExecuteNonQuery();
        }
      }

      #endregion

      CreateCounterParameters(ref counter, counterTypeId);



      #endregion
    }

    private void CreateCounterParameters(ref Counter counter, int counterTypeId)
    {
      #region Find and Add Counter Parameters.

      m_Logger.LogDebug(" Find and Add Counter Parameters.");
      foreach (PropertyInfo pInfo in counter.GetProperties())
      {
        int counterParamTypeId = -1;

        if (pInfo != null && (!counter.IsDirtyProperty(pInfo)))
        {
          object[] mtDataMemberAttribs = pInfo.GetCustomAttributes(typeof(MTDataMemberAttribute), false);
          if (mtDataMemberAttribs.HasValue())
          {
            #region Process Counter Parameters.
            MTDataMemberAttribute a = (MTDataMemberAttribute)mtDataMemberAttribs[0];
            if (a.Description.Equals("Counter parameter", StringComparison.OrdinalIgnoreCase))
            {
              m_Logger.LogDebug("Counter Property Found, proceeding to add counter parameter");

              string counterValue = pInfo.GetValue(counter, null) as string;

              if (string.IsNullOrEmpty(counterValue))
              {
                throw new MASBasicException("Counter Parameter value is either empty or null.");
              }

              #region Fetch Counter Parameter Type ID
              m_Logger.LogDebug(string.Format("Fetching Counter Parameter Type ID for {0}", pInfo.Name));

              counterParamTypeId = GetCounterParamType(counterTypeId, pInfo.Name);

              if (counterParamTypeId == -1)
              {
                m_Logger.LogDebug("Cannot fetch Counter Param Metadata Information");
                throw new MASBasicException("Cannot fetch Counter Param Metadata Information");
              }
              #endregion

              #region Add counter parameters
              m_Logger.LogDebug("Preparing for AddCounterParam procedure.");

              using (IMTConnection conn = ConnectionManager.CreateConnection())
              {
                using (IMTCallableStatement createCounterParamStmt = conn.CreateCallableStatement("AddCounterParam"))
                {
                  createCounterParamStmt.AddParam("id_lang_code", MTParameterType.Integer, GetSessionContext().LanguageID);
                  createCounterParamStmt.AddParam("id_counter", MTParameterType.Integer, counter.ID);
                  createCounterParamStmt.AddParam("id_counter_param_type", MTParameterType.Integer, counterParamTypeId);
                  createCounterParamStmt.AddParam("nm_counter_value", MTParameterType.String, counterValue);
                  createCounterParamStmt.AddParam("nm_name", MTParameterType.String, DatabaseUtils.FormatValueForDB(null));
                  createCounterParamStmt.AddParam("nm_desc", MTParameterType.String, DatabaseUtils.FormatValueForDB(null));
                  createCounterParamStmt.AddParam("nm_display_name", MTParameterType.String, DatabaseUtils.FormatValueForDB(null));
                  createCounterParamStmt.AddOutputParam("identity", MTParameterType.Integer, 0);
                  try
                  {
                    m_Logger.LogDebug("Executing AddCounterParam Procedure.");
                    createCounterParamStmt.ExecuteNonQuery();
                  }
                  catch (Exception e)
                  {
                    m_Logger.LogError("Error executing AddCounterParam procedure", e.Message);
                    throw;
                  }

                  int counterParamId = (int)createCounterParamStmt.GetOutputValue("identity");

                }
              }
              #endregion

            }
            #endregion
          }
        }

      }
      #endregion
    }

    private void CreateCounters(ref BasePriceableItemTemplate piTemplate)
    {
      try
      {
        foreach (PropertyInfo propInfo in piTemplate.GetProperties())
        {
          if (propInfo.PropertyType != typeof(Counter))
            continue;

          Counter counter = propInfo.GetValue(piTemplate, null) as Counter;

          if (counter == null)
            continue;

          CreateCounter(piTemplate.ID.Value, ref counter, propInfo);

          propInfo.SetValue(piTemplate, counter, null);



        }
      }
      catch (MASBasicException mBaE)
      {
        m_Logger.LogError("Error creating counters", mBaE.Message);
        throw;
      }
      catch (Exception e)
      {
        m_Logger.LogError("Error creating counters", e.Message);
        throw new MASBasicException("Error creating counters. " + e.Message);
      }
    }


    private int GetCounterParamType(int counterTypeId, string counterParamName)
    {
      try
      {
        int counterParamMetaDataId = -1;
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_COUNTER_PARAM_METADATA__"))
          {
            stmt.AddParam("%%COUNTER_TYPE_ID%%", counterTypeId);
            stmt.AddParam("%%COUNTER_PARAM_NAME%%", counterParamName);

            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              while (rdr.Read())
              {
                counterParamMetaDataId = rdr.GetInt32("id_prop");
                break;
              }

            }

          }
        }

        return counterParamMetaDataId;
      }
      catch (Exception e)
      {
        m_Logger.LogError("Error while fetching counter param metadata", e.Message);
        throw new MASBasicException("Error while fetching counter param metadata. " + e.Message);
      }
    }

    /// <summary>
    /// Populates data from template to instance.
    /// </summary>
    /// <param name="piTemplate"></param>
    /// <param name="piInstance"></param>
    private void PopulatePIInstanceFromTemplate(BasePriceableItemTemplate piTemplate, out BasePriceableItemInstance piInstance)
    {
      try
      {
        piInstance = null;

        string name = piTemplate.Name;

        //create type specific instance.
        //piTemplate.PIKind
        if (piTemplate.PIKind == PriceableItemKinds.Recurring ||
            piTemplate.PIKind == PriceableItemKinds.NonRecurring ||
            piTemplate.PIKind == PriceableItemKinds.UnitDependentRecurring ||
            piTemplate.PIKind == PriceableItemKinds.Discount)
        {
          name = piTemplate.GetType().Name;
          name = name.Replace("PITemplate", "");
        }

        object obj = RetrieveClassName(name, "PIInstance");
        BasePriceableItemInstance localPIInstance = (BasePriceableItemInstance)obj;

        localPIInstance.Name = piTemplate.Name;
        localPIInstance.Description = piTemplate.Description;
        localPIInstance.DisplayName = piTemplate.DisplayName;

        localPIInstance.LocalizedDisplayNames = piTemplate.LocalizedDisplayNames;
        localPIInstance.LocalizedDescriptions = piTemplate.LocalizedDescriptions;

        localPIInstance.PITemplate = new PCIdentifier((int)piTemplate.ID, piTemplate.Name);

        localPIInstance.PIKind = piTemplate.PIKind;

        //Get list of extended properties matches both in template and instance type.
        var ExtendedPropListQuery = (from pInfo in GetExtendedProperyInfos(localPIInstance)
                                     from tInfo in GetExtendedProperyInfos(piTemplate)
                                     where pInfo.Name == tInfo.Name
                                     select pInfo).ToList();

        //populate extended properties data into instance from template.
        ExtendedPropListQuery.ForEach(p => p.SetValue(localPIInstance, piTemplate.GetValue(p.Name), null));


        //Populate Kind specific properties. 
        MethodInfo methodInfo = this.GetType().GetMethod("PopulateNKindProperties", BindingFlags.NonPublic | BindingFlags.Instance);
        methodInfo = methodInfo.MakeGenericMethod(GetPIKindInstanceType(piTemplate.PIKind));
        methodInfo.Invoke(this, new object[2] { localPIInstance, piTemplate });


        //Populate Adjustments
        Dictionary<string, PropertyInfo> piInstanceAdjusmentProperties = new Dictionary<string, PropertyInfo>();

        foreach (PropertyInfo propInfo in localPIInstance.GetProperties())
        {
          if (propInfo.PropertyType != typeof(AdjustmentInstance))
            continue;

          piInstanceAdjusmentProperties.Add(propInfo.Name, propInfo);
        }

        if (piInstanceAdjusmentProperties.Count > 0)
        {
          foreach (PropertyInfo propInfo in piTemplate.GetProperties())
          {
            if (propInfo.PropertyType != typeof(AdjustmentTemplate))
              continue;

            AdjustmentTemplate adjustTemplate = propInfo.GetValue(piTemplate, null) as AdjustmentTemplate;

            if (adjustTemplate != null)
            {
              PropertyInfo instanceAdjustment = null;
              if (piInstanceAdjusmentProperties.TryGetValue(propInfo.Name, out instanceAdjustment))
              {
                instanceAdjustment.SetValue(localPIInstance, CreateAdjusmentInstanceFromTemplate(adjustTemplate), null);
              }
            }
          }
        }

        piInstance = localPIInstance;
      }
      catch (MASBasicException masBasic)
      {
        throw masBasic;
      }
      catch (COMException comE)
      {
        m_Logger.LogException("COM Exception while populating data from template to instance.", comE);

        throw new MASBasicException(comE.Message);
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception while populating data from template to instance.", e);

        throw new MASBasicException("Error while populating data from template to instance.");
      }

    }

    private void PopulateChargeProperties(IMTDataReader rdr, ref PriceableItemType piType)
    {

      Charge charge;
      string fieldName;
      int idxLanguageCode = -1;

      while (rdr.Read())
      {
        charge = new Charge();

        if (idxLanguageCode == -1)
        {
          idxLanguageCode = rdr.GetOrdinal("LanguageCode");
        }

        LanguageCode langCode = GetLanguageCode(rdr.GetInt32(idxLanguageCode));

        for (int i = 0; i < rdr.FieldCount; i++)
        {
          fieldName = rdr.GetName(i);

          if (!rdr.IsDBNull(i))
          {
            switch (fieldName.ToLower())
            {
              case "name":
              case "nm_name":
                charge.Name = rdr.GetString(i);
                break;
              case "nm_display_name":
              case "displayname":
                charge.DisplayName = rdr.GetString(i);
                break;
              case "tx_desc":
              case "localizeddisplaynames":
                if (charge.LocalizedDisplayNames == null)
                {
                  charge.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                }
                charge.LocalizedDisplayNames[langCode] = rdr.GetString(i);
                break;
            };
          }
        }

        if (piType.ChargeProperties == null)
        {
          piType.ChargeProperties = new List<Charge>();
        }

        piType.ChargeProperties.Add(charge);

      }
    }

    private void PopulateCounterProperty(IMTDataReader rdr, ref PriceableItemType piType)
    {
      CounterPropertyDefinition counterPropDef;
      string fieldName;
      int idxLanguageCode = -1;

      while (rdr.Read())
      {
        counterPropDef = new CounterPropertyDefinition();

        if (idxLanguageCode == -1)
        {
          idxLanguageCode = rdr.GetOrdinal("LanguageCode");
        }

        LanguageCode langCode = GetLanguageCode(rdr.GetInt32(idxLanguageCode));


        for (int i = 0; i < rdr.FieldCount; i++)
        {
          fieldName = rdr.GetName(i);

          if (!rdr.IsDBNull(i))
          {
            switch (fieldName.ToLower())
            {
              case "name":
              case "nm_name":
                counterPropDef.Name = rdr.GetString(i);
                break;
              case "nm_display_name":
              case "displayname":
                counterPropDef.DisplayName = rdr.GetString(i);
                break;
              case "nm_servicedefprop":
              case "serviceproperty":
                counterPropDef.ServiceProperty = rdr.GetString(i);
                break;
              case "nm_preferredcountertype":
              case "preferredcountertypename":
                counterPropDef.PreferredCounterTypeName = rdr.GetString(i);
                break;
              case "tx_desc":
              case "localizeddisplaynames":
                if (counterPropDef.LocalizedDisplayNames == null)
                {
                  counterPropDef.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                }
                counterPropDef.LocalizedDisplayNames[langCode] = rdr.GetString(i);
                break;
            };
          }
        }

        if (piType.CounterProperties == null)
        {
          piType.CounterProperties = new List<CounterPropertyDefinition>();
        }

        piType.CounterProperties.Add(counterPropDef);

      }
    }

    private void PopulateApplicabilityRuleDefinitions(IMTDataReader rdr, ref Dictionary<int, AdjustmentType> dicAdjustmentTypes)
    {
      ApplicabilityRuleDef appRuleDef;

      int idxLanguageCode = -1;
      string fieldName;
      int adjTypeID;

      while (rdr.Read())
      {
        appRuleDef = new ApplicabilityRuleDef();

        if (idxLanguageCode == -1)
        {
          idxLanguageCode = rdr.GetOrdinal("LanguageCode");
        }

        LanguageCode langCode = GetLanguageCode(rdr.GetInt32(idxLanguageCode));

        adjTypeID = rdr.GetInt32(rdr.GetOrdinal("AdjustmentTypeID"));

        //If no adjustment type, go to next record.
        if (dicAdjustmentTypes[adjTypeID] == null)
          continue;

        for (int i = 0; i < rdr.FieldCount; i++)
        {
          fieldName = rdr.GetName(i);

          if (!rdr.IsDBNull(i))
          {
            switch (fieldName.ToLower())
            {
              case "name":
              case "nm_name":
                appRuleDef.Name = rdr.GetString(i);
                break;
              case "description":
              case "nm_desc":
                appRuleDef.Description = rdr.GetString(i);
                break;
              case "nm_display_name":
              case "displayname":
                appRuleDef.DisplayName = rdr.GetString(i);
                break;
              case "id_engine":
              case "calculationengine":
                appRuleDef.CalculationEngine = (CalculationEngineTypes)rdr.GetInt32(i);
                break;
              case "tx_formula":
              case "formula":
                appRuleDef.Formula = rdr.GetString(i);
                break;
              case "localizeddisplaynames":
                if (appRuleDef.LocalizedDisplayNames == null)
                {
                  appRuleDef.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                }
                appRuleDef.LocalizedDisplayNames[langCode] = rdr.GetString(i);
                break;
              case "tx_desc":
              case "localizeddescriptions":
                if (appRuleDef.LocalizedDescriptions == null)
                {
                  appRuleDef.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                }
                appRuleDef.LocalizedDescriptions[langCode] = rdr.GetString(i);
                break;
            };
          }
        }

        if (dicAdjustmentTypes[adjTypeID].ApplicabilityRuleDefs == null)
        {
          dicAdjustmentTypes[adjTypeID].ApplicabilityRuleDefs = new List<ApplicabilityRuleDef>();
        }

        dicAdjustmentTypes[adjTypeID].ApplicabilityRuleDefs.Add(appRuleDef);

      }
    }

    private void PopulateAdjustmentValue(IMTDataReader rdr, ref Dictionary<int, AdjustmentType> dicAdjustmentTypes)
    {

      AdjustmentValue adjValue;
      int idxLanguageCode = -1;
      string fieldName;
      int adjTypeID;

      while (rdr.Read())
      {
        adjValue = new AdjustmentValue();

        if (idxLanguageCode == -1)
        {
          idxLanguageCode = rdr.GetOrdinal("LanguageCode");
        }

        LanguageCode langCode = GetLanguageCode(rdr.GetInt32(idxLanguageCode));

        adjTypeID = rdr.GetInt32(rdr.GetOrdinal("AdjustmentTypeID"));


        //If no adjustment type, go to next record.
        if (dicAdjustmentTypes[adjTypeID] == null)
          continue;

        for (int i = 0; i < rdr.FieldCount; i++)
        {
          fieldName = rdr.GetName(i);

          if (!rdr.IsDBNull(i))
          {
            switch (fieldName.ToLower())
            {
              case "name":
              case "nm_name":
                adjValue.Name = rdr.GetString(i);
                break;
              case "nm_display_name":
              case "displayname":
                adjValue.DisplayName = rdr.GetString(i);
                break;
              case "nm_datatype":
              case "datatype":
                adjValue.DataType = rdr.GetString(i);
                break;
              case "tx_desc":
              case "localizeddisplaynames":
                if (adjValue.LocalizedDisplayNames == null)
                {
                  adjValue.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                }
                adjValue.LocalizedDisplayNames[langCode] = rdr.GetString(i);
                break;
            };
          }
        }

        if (dicAdjustmentTypes[adjTypeID].Outputs == null)
        {
          dicAdjustmentTypes[adjTypeID].Outputs = new List<AdjustmentValue>();
        }

        dicAdjustmentTypes[adjTypeID].Outputs.Add(adjValue);

      }
    }

    private void PopulateAdjustmentType(IMTDataReader rdr, ref PriceableItemType piType, ref Dictionary<int, AdjustmentType> dicAdjustmentTypes)
    {
      AdjustmentType adjType;
      string fieldName;
      int idxLanguageCode = -1;
      int adjTypeId = -1;

      if (dicAdjustmentTypes == null)
      {
        dicAdjustmentTypes = new Dictionary<int, AdjustmentType>();
      }


      while (rdr.Read())
      {
        if (idxLanguageCode == -1)
        {
          idxLanguageCode = rdr.GetOrdinal("LanguageCode");
        }

        LanguageCode langCode = GetLanguageCode(rdr.GetInt32(idxLanguageCode));
        adjType = new AdjustmentType();

        for (int i = 0; i < rdr.FieldCount; i++)
        {
          fieldName = rdr.GetName(i);

          if (!rdr.IsDBNull(i))
          {
            switch (fieldName.ToLower())
            {
              case "id_prop":
              case "adjustmenttypeid":
                adjTypeId = rdr.GetInt32(i);
                break;
              case "nm_name":
              case "name":
                adjType.Name = rdr.GetString(i);
                break;
              case "nm_desc":
              case "description":
                adjType.Description = rdr.GetString(i);
                break;
              case "nm_display_name":
              case "displayname":
                adjType.Description = rdr.GetString(i);
                break;
              case "tx_formula":
              case "formula":
                adjType.Formula = rdr.GetString(i);
                break;
              case "b_supportbulk":
              case "supportsbulk":
                adjType.SupportsBulk = rdr.GetBoolean(i);
                break;
              case "id_engine":
              case "calculationengine":
                adjType.CalculationEngine = (CalculationEngineTypes)rdr.GetInt32(i);
                break;
              case "localizeddescriptions":
                if (adjType.LocalizedDescriptions == null)
                {
                  adjType.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                }
                adjType.LocalizedDescriptions[langCode] = rdr.GetString(i);
                break;
              case "localizeddisplaynames":
                if (adjType.LocalizedDisplayNames == null)
                {
                  adjType.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                }
                adjType.LocalizedDisplayNames[langCode] = rdr.GetString(i);
                break;
              case "n_adjustmenttype":
              case "adjustmentkind":
                adjType.AdjustmentKind = (AdjustmentKinds)rdr.GetInt32(i);
                break;
            };
          }
        }

        if (piType.AdjustmentTypes == null)
        {
          piType.AdjustmentTypes = new List<AdjustmentType>();
        }

        piType.AdjustmentTypes.Add(adjType);
        dicAdjustmentTypes.Add(adjTypeId, adjType);
      }
    }

    private PriceableItemType PopulatePriceableItemType(IMTDataReader rdr, out int? piTypeId)
    {
      PriceableItemType piType = new PriceableItemType();

      string fieldName;
      piTypeId = -1;

      for (int i = 0; i < rdr.FieldCount; i++)
      {
        fieldName = rdr.GetName(i);


        if (!rdr.IsDBNull(i))
        {
          switch (fieldName.ToLower())
          {
            case "id_prop":
            case "id":
              piTypeId = rdr.GetInt32(i);
              break;
            case "nm_name":
            case "name":
              piType.Name = rdr.GetString(i);
              break;
            case "nm_desc":
            case "description":
              piType.Description = rdr.GetString(i);
              break;
            case "nm_servicedef":
            case "servicedefname":
              piType.ServiceDefName = rdr.GetString(i);
              break;
            case "nm_productview":
            case "productviewname":
              piType.ProductViewName = rdr.GetString(i);
              break;
            case "n_kind":
            case "kind":
              piType.Kind = (PriceableItemKinds)rdr.GetInt32(i);
              break;
            case "id_parent":
            case "ParentPriceableItem":
              piType.ParentPriceableItem = new PCIdentifier(rdr.GetInt32(i));
              break;
          };
        }
      }

      return piType;

    }


    #region Priceable Item Template Helpers
    private ExtendedUsageCycleInfo GetUsageCycleInfo(int? idUsageCycle, string mode, int? idCycleType, int? relativeCycleType, int? dayOfMonth, int? dayOfWeek, int? firstDayOfMonth, int? secondDayOfMonth, int? startDay, int? startMonth, int? startYear, bool isRecurringCharge)
    {
      /*
       *  mode          | CycleID | CycleTypeId
       * Fixed          |   X     |   NULL
       * BCR            |   NULL  |   NULL
       * BCRConstrained |   NULL  |    X
       * EBCR           |   NULL  |    X --> only supported by recurring charges 
       * */
      UsageCycleInfo cycle = null;
      if (idUsageCycle.HasValue)
      {
        CycleType ct = (CycleType)idCycleType.Value;
        switch (ct)
        {
          case CycleType.Semi_Annually:
            SemiAnnualUsageCycleInfo semiannualCycle = new SemiAnnualUsageCycleInfo();
            semiannualCycle.StartDay = startDay.Value;
            semiannualCycle.StartMonth = startMonth.Value;
            return semiannualCycle;
            break;
          case CycleType.Annually:
            AnnualUsageCycleInfo annualCycle = new AnnualUsageCycleInfo();
            annualCycle.StartDay = startDay.Value;
            annualCycle.StartMonth = startMonth.Value;
            return annualCycle;
            break;
          case CycleType.Bi_Weekly:
            BiWeeklyUsageCycleInfo biWeekly = new BiWeeklyUsageCycleInfo();
            biWeekly.StartDay = startDay.Value;
            biWeekly.StartMonth = startMonth.Value;
            biWeekly.StartYear = startYear.Value;
            return biWeekly;
            break;
          case CycleType.Daily:
            DailyUsageCycleInfo daily = new DailyUsageCycleInfo();
            return daily;
            break;
          case CycleType.Monthly:
            MonthlyUsageCycleInfo monthly = new MonthlyUsageCycleInfo();
            monthly.EndDay = dayOfMonth.Value;
            return monthly;
            break;
          case CycleType.Quarterly:
            QuarterlyUsageCycleInfo quarterly = new QuarterlyUsageCycleInfo();
            quarterly.StartDay = startDay.Value;
            quarterly.StartMonth = startMonth.Value;
            return quarterly;
            break;
          case CycleType.Semi_Monthly:
            SemiMonthlyUsageCycleInfo semiMonthly = new SemiMonthlyUsageCycleInfo();
            semiMonthly.Day1 = firstDayOfMonth.Value;
            semiMonthly.Day2 = secondDayOfMonth.Value;
            return semiMonthly;
            break;
          case CycleType.Weekly:
            WeeklyUsageCycyleInfo weekly = new WeeklyUsageCycyleInfo();
            weekly.DayOfWeek = (DayOfWeek)(dayOfWeek.Value - 1);
            return weekly;
            break;
        }
      }
      else
      {
        if (relativeCycleType.HasValue && (mode == null || string.Compare(mode, "EBCR", true) != 0))
        {
          // BCR constrained
          RelativeUsageCycleInfo info = new RelativeUsageCycleInfo();
          info.UsageCycleType = (CycleType)relativeCycleType.Value;
          return info;
        }
        else if (relativeCycleType.HasValue && mode != null && string.Compare(mode, "EBCR", true) == 0)
        {
          ExtendedRelativeUsageCycleInfo ebcr = new ExtendedRelativeUsageCycleInfo();
          ebcr.ExtendedUsageCycle = (ExtendedCycleType)relativeCycleType.Value;
          return ebcr;

        }
        else
        {
          // cycle type is null - BillingCycleRelative
          RelativeUsageCycleInfo info = new RelativeUsageCycleInfo();
          return info;
        }
      }

      return cycle;
    }

    private void PopulateAdjustTemplate(int id, List<PropertyInfo> tempProps, BasePriceableItemTemplate bpit)
    {
      Dictionary<int, AdjustmentTemplate> adjustments = new Dictionary<int, AdjustmentTemplate>();
      string adjustmentTypeName = string.Empty;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement adjStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_ADJ_MAPPING_BY_PI_TEMPLATE_ID__"))
        {
          adjStmt.AddParam("%%PI_TEMPLATE_ID%%", id);
          using (IMTDataReader adjReader = adjStmt.ExecuteReader())
          {
            while (adjReader.Read())
            {
              AdjustmentTemplate template = new AdjustmentTemplate();
              template.ID = adjReader.GetInt32("ID");
              template.Name = adjReader.GetString("Name");
              template.DisplayName = adjReader.GetString("DisplayName");
              //int lCode = adjReader.GetInt32("LanguageCode");
              template.Description = adjReader.GetString("Description");
              adjustmentTypeName = adjReader.GetString("AdjustmentTypeName");

              Dictionary<LanguageCode, string> localizedNames = new Dictionary<LanguageCode, string>();
              Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();
              template.LocalizedDescriptions = localizedDesc;
              template.LocalizedDisplayNames = localizedNames;
              PopulateLocalizedNamesAndDescriptions(template.ID.Value.ToString(), template.LocalizedDisplayNames, template.LocalizedDescriptions);

              foreach (PropertyInfo prop in tempProps)
              {
                if ((prop.PropertyType == typeof(AdjustmentTemplate)) && prop.Name.Equals(adjustmentTypeName, StringComparison.OrdinalIgnoreCase))
                {
                  prop.SetValue(bpit, template, null);
                  break;
                }
              }
              adjustments.Add(template.ID.Value, template);
            }
          }
        }

        using (IMTAdapterStatement reasonCodeStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_REASON_CODE_BY_ADJ_ID__"))
        {
          foreach (KeyValuePair<int, AdjustmentTemplate> templateDate in adjustments)
          {
            reasonCodeStmt.AddParam("%%ADJ_ID%%", templateDate.Key);
            List<ReasonCode> codes = new List<ReasonCode>();
            using (IMTDataReader rcReader = reasonCodeStmt.ExecuteReader())
            {
              while (rcReader.Read())
              {
                ReasonCode code = new ReasonCode();
                code.ID = rcReader.GetInt32("ID");
                code.Name = rcReader.GetString("Name");
                codes.Add(code);
              }

              templateDate.Value.ReasonCodes = codes;
            }

            reasonCodeStmt.ClearQuery();
          }
        }
      }
    }

    private void PopulateCounterDetails(BasePriceableItemTemplate piTemplate)
    {
      int i = 0;
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement counterStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_COUNTER_BY_TEMPLATE_ID__"))
        {
          counterStmt.AddParam("%%TEMPLATE_ID%%", piTemplate.ID.Value);
          using (IMTDataReader counterReader = counterStmt.ExecuteReader())
          {
            while (counterReader.Read())
            {
              Counter counter = new Counter();
              string cName = "";
              string cPropertyName = "";
              int cID = counterReader.GetInt32("ID");
              string counterTypeName = counterReader.GetString("CounterTypeName");
              string description = counterReader.IsDBNull("Description") ? null : counterReader.GetString("Description");
              cName = counterReader.GetString("Name");
              cPropertyName = counterReader.GetString("CounterPropertyName");

              Object counterObject = RetrieveClassName(counterTypeName, "Counter");
              counter = (Counter)counterObject;
              List<string> counterPVProps = GetCounterPVProperty(cID);
              counter.Name = cName;
              counter.ID = cID;
              counter.Description = description;
              PropertyInfo[] propertyInfos = counterObject.GetType().GetProperties();

              // set the product view properties on the counter
              foreach (PropertyInfo prop in propertyInfos)
              {
                if ((prop != null) && (!prop.Name.ToLower().Contains("dirty")))
                {
                  object[] attributes = prop.GetCustomAttributes(typeof(MTDataMemberAttribute), false);
                  if (attributes.HasValue())
                  {
                    MTDataMemberAttribute a = (MTDataMemberAttribute)attributes[0];
                    if (a.Description.Equals("Counter parameter"))
                    {
                      if (counterPVProps.Count == 1)
                        prop.SetValue(counter, counterPVProps[i], null);
                      else
                      {
                        prop.SetValue(counter, counterPVProps[i], null);
                        i++;
                      }
                    }
                  }
                }
              }

              Dictionary<LanguageCode, string> dispNames = new Dictionary<LanguageCode, string>();
              Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();
              counter.LocalizedDescriptions = localizedDesc;
              counter.LocalizedDisplayNames = dispNames;
              PopulateLocalizedNamesAndDescriptions(counter.ID.Value.ToString(), counter.LocalizedDisplayNames, counter.LocalizedDescriptions);

              // set the counter on the template
              PropertyInfo counterProperty = piTemplate.GetProperty(cPropertyName);
              counterProperty.SetValue(piTemplate, counter, null);
            }
          }
        }
      }
    }

    private List<string> GetCounterPVProperty(int counterId)
    {
      List<string> prodViewProps = new List<string>();
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement counterProdViewStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_COUNTER_PROPS__"))
        {
          counterProdViewStmt.AddParam("%%ID_COUNTER%%", counterId);
          using (IMTDataReader prodViewPropReader = counterProdViewStmt.ExecuteReader())
          {
            while (prodViewPropReader.Read())
            {
              prodViewProps.Add(prodViewPropReader.GetString("CounterValue"));
            }
          }
        }
      }

      return prodViewProps;
    }

    private void RetrieveAndPopulateChildTemplates(BasePriceableItemTemplate piTemplate)
    {
      List<int> children = new List<int>();
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement getChildTemplateStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_CHILD_TEMPLATE_ID__"))
        {
          getChildTemplateStmt.AddParam("%%PARENT_TEMPLATE_ID%%", piTemplate.ID.Value);

          using (IMTDataReader childTemplateReader = getChildTemplateStmt.ExecuteReader())
          {
            while (childTemplateReader.Read())
            {
              int templateId = childTemplateReader.GetInt32("ID");
              children.Add(templateId);
            }
          }

          if (children.Count == 0)
            return;

          List<PropertyInfo> tPropInfoList = piTemplate.GetProperties();

          foreach (int i in children)
          {
            BasePriceableItemTemplate child;
            PopulateBasePITemplateProps(i, out child);

            string childDisplayName = child.DisplayName.Replace(' ', '_');
            PropertyInfo childTemplateProperty = tPropInfoList.Find(prop => prop.Name == childDisplayName);
            childTemplateProperty.SetValue(piTemplate, child, null);

          }
        }
      }
    }

    private string GetPropName(int id)
    {
      string name = "";
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement nameStatement = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_PROP_NAME__"))
        {
          nameStatement.AddParam("%%ID_PROP%%", id);

          using (IMTDataReader nameReader = nameStatement.ExecuteReader())
          {
            while (nameReader.Read())
              name = nameReader.GetString("Name");
          }
        }
      }

      return name;
    }

    private void PopulateBasePITemplateProps(int templateId, out BasePriceableItemTemplate bpi)
    {
      #region PopulateProps
      int id = -1;
      string name = "";
      string templateName = "";
      string displayName = "";
      string description = "";
      int piType = -1;
      int nKind = -1;
      string piTypeName = "";
      int idpi = -1;

      int? idUsageCycle = null;
      int? usageCycleType = null;
      int? relativeCycleType = null;
      int? dayOfMonth = null;
      int? dayOfWeek = null;
      int? firstDayOfMonth = null;
      int? secondDayOfMonth = null;
      int? startDay = null;
      int? startMonth = null;
      int? startYear = null;
      string mode = null;

      int? discountCPD = null;
      int eventType = -1;
      bpi = null;
      bool gotClassName = false;

      string unitName = "";
      int ratingType = -1;
      bool bIntegral = false;
      decimal maxUnitValue = 0.0M;
      decimal minUnitValue = 0.0M;
      int nUnitName = -1;
      int nDisplayName = -1;
      string nmUnitDisplayName = "";

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement templateStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_PI_TEMPLATE_DETAILS__"))
        {
          templateStmt.AddParam("%%ID_TEMPLATE%%", templateId);

          using (IMTDataReader templateReader = templateStmt.ExecuteReader())
          {
            while (templateReader.Read())
            {
              for (int i = 0; i < templateReader.FieldCount; i++)
              {
                string fieldName = templateReader.GetName(i);

                if (!templateReader.IsDBNull(i))
                {
                  #region Base PI Template Props
                  switch (fieldName.ToLower())
                  {
                    case "id":
                      id = templateReader.GetInt32(i);
                      break;
                    case "name":
                      name = templateReader.GetString(i);
                      templateName = name;
                      break;
                    case "displayname":
                      displayName = templateReader.GetString(i);
                      break;
                    case "description":
                      description = templateReader.GetString(i);
                      break;
                    case "pitype":
                      piType = templateReader.GetInt32(i);
                      break;
                    case "idpi":
                      idpi = templateReader.GetInt32(i);
                      break;
                    case "pitypename":
                      piTypeName = templateReader.GetString(i);
                      break;
                    case "pikind":
                      nKind = templateReader.GetInt32(i);
                      break;
                  }
                  #endregion

                  #region instantitate base pi template object
                  // find the pi template name that has been code generated
                  if ((nKind != -1) && (!gotClassName))
                  {
                    PriceableItemKinds pki = (PriceableItemKinds)nKind;
                    switch (pki)
                    {
                      case PriceableItemKinds.NonRecurring:
                        name = piTypeName;
                        break;
                      case PriceableItemKinds.Recurring:
                        name = piTypeName;
                        break;
                      case PriceableItemKinds.UnitDependentRecurring:
                        name = piTypeName;
                        break;
                      case PriceableItemKinds.Discount:
                        name = piTypeName;
                        break;
                      //ESR-4292
                      case PriceableItemKinds.Usage:
                        name = piTypeName;
                        break;
                    }
                    object templateObject = RetrieveClassName(name, "PITemplate");
                    gotClassName = true;
                    bpi = (BasePriceableItemTemplate)templateObject;
                    bpi.ID = id;
                    bpi.Name = templateName;
                    bpi.DisplayName = displayName;
                    bpi.Description = description;
                    bpi.PIKind = pki;
                  }
                  #endregion

                  if (bpi != null)
                  {

                    if ((bpi.PIKind == PriceableItemKinds.UnitDependentRecurring) || (bpi.PIKind == PriceableItemKinds.Recurring))
                    {
                      #region recurring charge properties
                      BaseRecurringChargePITemplate bcr = (BaseRecurringChargePITemplate)bpi;
                      switch (fieldName.ToLower())
                      {
                        case "chargeinadvance":
                          bcr.ChargeAdvance = templateReader.GetBoolean(i);
                          break;
                        case "prorateonactivation":
                          bcr.ProrateOnActivation = templateReader.GetBoolean(i);
                          break;
                        case "prorateinstantly":
                          bcr.ProrateInstantly = templateReader.GetBoolean(i);
                          break;
                        case "prorateondeactivation":
                          bcr.ProrateOnDeactivation = templateReader.GetBoolean(i);
                          break;
                        case "fixedprorationlength":
                          bcr.FixedProrationLength = templateReader.GetBoolean(i);
                          break;
                        case "usagecycleid":
                          idUsageCycle = templateReader.GetInt32(i);
                          break;
                        case "usagecycletype":
                          usageCycleType = templateReader.GetInt32(i);
                          break;
                        case "relativecycletype":
                          relativeCycleType = templateReader.GetInt32(i);
                          break;
                        case "dayofmonth":
                          dayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "dayofweek":
                          dayOfWeek = templateReader.GetInt32(i);
                          break;
                        case "firstdayofmonth":
                          firstDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "seconddayofmonth":
                          secondDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "startday":
                          startDay = templateReader.GetInt32(i);
                          break;
                        case "startmonth":
                          startMonth = templateReader.GetInt32(i);
                          break;
                        case "startyear":
                          startYear = templateReader.GetInt32(i);
                          break;
                        case "cyclemode":
                          if (!templateReader.IsDBNull(i))
                          {
                            mode = templateReader.GetString(i);
                          }
                          break;
                        case "chargeperparticipant":
                          bcr.ChargePerParticipant = templateReader.GetBoolean(i);
                          break;
                        case "unitname":
                          unitName = templateReader.GetString(i); ;
                          break;
                        case "ratingtype":
                          ratingType = templateReader.GetInt32(i); ;
                          break;
                        case "integral":
                          bIntegral = templateReader.GetBoolean(i);
                          break;
                        case "maxunitvalue":
                          maxUnitValue = templateReader.GetDecimal(i);
                          break;
                        case "minunitvalue":
                          minUnitValue = templateReader.GetDecimal(i);
                          break;
                        case "nunitname":
                          nUnitName = templateReader.GetInt32(i);
                          break;
                        case "displayname":
                          nDisplayName = templateReader.GetInt32(i);
                          break;
                        case "unitdisplayname":
                          nmUnitDisplayName = templateReader.GetString(i);
                          break;
                      }
                      #endregion
                    }
                    else if (bpi.PIKind == PriceableItemKinds.AggregateCharge)
                    {
                      # region aggregate charge properties
                      switch (fieldName.ToLower())
                      {
                        case "usagecycleid":
                          idUsageCycle = templateReader.GetInt32(i);
                          break;
                        case "usagecycletype":
                          usageCycleType = templateReader.GetInt32(i);
                          break;
                        case "relativecycletype":
                          relativeCycleType = templateReader.GetInt32(i);
                          break;
                        case "dayofmonth":
                          dayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "dayofweek":
                          dayOfWeek = templateReader.GetInt32(i);
                          break;
                        case "firstdayofmonth":
                          firstDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "seconddayofmonth":
                          secondDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "startday":
                          startDay = templateReader.GetInt32(i);
                          break;
                        case "startmonth":
                          startMonth = templateReader.GetInt32(i);
                          break;
                        case "startyear":
                          startYear = templateReader.GetInt32(i);
                          break;
                      }
                      #endregion
                    }
                    else if (bpi.PIKind == PriceableItemKinds.Discount)
                    {
                      #region discount properties
                      switch (fieldName.ToLower())
                      {
                        case "usagecycleid":
                          idUsageCycle = templateReader.GetInt32(i);
                          break;
                        case "usagecycletype":
                          usageCycleType = templateReader.GetInt32(i);
                          break;
                        case "relativecycletype":
                          relativeCycleType = templateReader.GetInt32(i);
                          break;
                        case "dayofmonth":
                          dayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "dayofweek":
                          dayOfWeek = templateReader.GetInt32(i);
                          break;
                        case "firstdayofmonth":
                          firstDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "seconddayofmonth":
                          secondDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "startday":
                          startDay = templateReader.GetInt32(i);
                          break;
                        case "startmonth":
                          startMonth = templateReader.GetInt32(i);
                          break;
                        case "startyear":
                          startYear = templateReader.GetInt32(i);
                          break;
                        case "discountcpd":
                          discountCPD = templateReader.GetInt32(i);
                          break;
                      }
                      #endregion
                    }
                    else if (bpi.PIKind == PriceableItemKinds.NonRecurring)
                    {
                      switch (fieldName.ToLower())
                      {
                        case "eventtype":
                          eventType = templateReader.GetInt32(i);
                          break;
                      }
                    }
                    else if (bpi.PIKind == PriceableItemKinds.Usage)
                    {
                      # region Usage Properties
                      switch (fieldName.ToLower())
                      {
                        case "usagecycleid":
                          idUsageCycle = templateReader.GetInt32(i);
                          break;
                        case "usagecycletype":
                          usageCycleType = templateReader.GetInt32(i);
                          break;
                        case "relativecycletype":
                          relativeCycleType = templateReader.GetInt32(i);
                          break;
                        case "dayofmonth":
                          dayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "dayofweek":
                          dayOfWeek = templateReader.GetInt32(i);
                          break;
                        case "firstdayofmonth":
                          firstDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "seconddayofmonth":
                          secondDayOfMonth = templateReader.GetInt32(i);
                          break;
                        case "startday":
                          startDay = templateReader.GetInt32(i);
                          break;
                        case "startmonth":
                          startMonth = templateReader.GetInt32(i);
                          break;
                        case "startyear":
                          startYear = templateReader.GetInt32(i);
                          break;
                      }
                      #endregion
                    }
                  }
                }
              }
            }

            // set up cycle
            # region UsageCycle
            switch (bpi.PIKind)
            {
              case PriceableItemKinds.AggregateCharge:
                AggregateChargePITemplate aggTemp = (AggregateChargePITemplate)bpi;
                aggTemp.Cycle = (UsageCycleInfo)GetUsageCycleInfo(idUsageCycle, mode, usageCycleType, relativeCycleType, dayOfMonth, dayOfWeek, firstDayOfMonth, secondDayOfMonth, startDay, startMonth, startYear, false);
                PopulateAdjustTemplate(bpi.ID.Value, aggTemp.GetProperties(), aggTemp);
                PopulateCounterDetails(aggTemp);
                break;
              case PriceableItemKinds.Discount:
                DiscountPITemplate discTemp = (DiscountPITemplate)bpi;
                if (discountCPD.HasValue)
                {
                  int cpdId = discountCPD.Value;
                  discTemp.DistributionCounterPropName = GetPropName(cpdId);
                }
                PopulateCounterDetails(discTemp);
                discTemp.Cycle = (UsageCycleInfo)GetUsageCycleInfo(idUsageCycle, mode, usageCycleType, relativeCycleType, dayOfMonth, dayOfWeek, firstDayOfMonth, secondDayOfMonth, startDay, startMonth, startYear, false);
                break;
              case PriceableItemKinds.NonRecurring:
                m_Logger.LogDebug("Populating NonRecurring Charge Template Properties for {0}", bpi.Name);
                NonRecurringChargePITemplate nonRecurTemp = (NonRecurringChargePITemplate)bpi;
                nonRecurTemp.EventType = (NonRecurringChargeEvents)eventType;
                PopulateAdjustTemplate(bpi.ID.Value, nonRecurTemp.GetProperties(), nonRecurTemp);
                break;
              case PriceableItemKinds.Recurring:
                RecurringChargePITemplate rc = (RecurringChargePITemplate)bpi;
                rc.Cycle = GetUsageCycleInfo(idUsageCycle, mode, usageCycleType, relativeCycleType, dayOfMonth, dayOfWeek, firstDayOfMonth, secondDayOfMonth, startDay, startMonth, startYear, true);
                PopulateAdjustTemplate(bpi.ID.Value, rc.GetProperties(), rc);
                break;
              case PriceableItemKinds.UnitDependentRecurring:
                UnitDependentRecurringChargePITemplate udrc = (UnitDependentRecurringChargePITemplate)bpi;
                udrc.UnitName = unitName;
                udrc.RatingType = (UDRCRatingType)ratingType;
                udrc.IntegerUnitValue = bIntegral;
                udrc.MaxUnitValue = maxUnitValue;
                udrc.MinUnitValue = minUnitValue;
                udrc.AllowedUnitValues = GetAllowedUnitValues(id);
                PopulateLocalizedNamesAndDescriptions(udrc);
                udrc.UnitName = unitName;
                udrc.UnitDisplayName = nmUnitDisplayName;
                udrc.Cycle = GetUsageCycleInfo(idUsageCycle, mode, usageCycleType, relativeCycleType, dayOfMonth, dayOfWeek, firstDayOfMonth, secondDayOfMonth, startDay, startMonth, startYear, true);
                PopulateAdjustTemplate(bpi.ID.Value, udrc.GetProperties(), udrc);
                break;
              case PriceableItemKinds.Usage:
                m_Logger.LogDebug("Populating Usage Template Properties");
                UsagePITemplate usageTemp = (UsagePITemplate)bpi;
                PopulateAdjustTemplate(bpi.ID.Value, usageTemp.GetProperties(), usageTemp);
                break;
            }
            #endregion

            PopulateExtendedProperties(bpi, bpi.ID.Value);

            // process localized details
            Dictionary<LanguageCode, string> localizedDisplayNames = new Dictionary<LanguageCode, string>();
            Dictionary<LanguageCode, string> localizedDesc = new Dictionary<LanguageCode, string>();

            bpi.LocalizedDisplayNames = localizedDisplayNames;
            bpi.LocalizedDescriptions = localizedDesc;

            PopulateLocalizedNamesAndDescriptions(bpi.ID.Value.ToString(), bpi.LocalizedDisplayNames, bpi.LocalizedDescriptions);
          }
        }
      }
      #endregion
    }

    #endregion Priceable Item Template Helpers

    /// <summary>
    /// Method to populate kind specific data from Template to Instance.
    /// </summary>
    /// <typeparam name="T"> example NonRecur, Recurr, Discount, aggregate, usage, unit dependent recurring </typeparam>
    /// <param name="piInstance">instance where data needs to be populated</param>
    /// <param name="piTemplate">template where data is pulled from.</param>
    private void PopulateNKindProperties<T>(ref BasePriceableItemInstance piInstance, BasePriceableItemTemplate piTemplate) where T : BaseObject
    {

      T kindObject = piInstance as T;

      List<PropertyInfo> kindPropInfos = GetProperties(typeof(T));
      List<PropertyInfo> basePriceableItemInstancePropertyList = GetProperties(typeof(BasePriceableItemInstance));

      if (!kindPropInfos.HasValue() || !basePriceableItemInstancePropertyList.HasValue())
        return;

      List<PropertyInfo> IgnoreQueryList = (from k in kindPropInfos.ToArray()
                                            from b in GetProperties(typeof(BasePriceableItemInstance)).ToArray()
                                            where k.Name == b.Name
                                            select k).ToList();

      List<PropertyInfo> QueryList = (from k in kindPropInfos.Except(IgnoreQueryList)
                                      from t in GetProperties(piTemplate.GetType())
                                      where k.Name == t.Name
                                      && !kindObject.IsDirtyProperty(k)
                                      select k).ToList();


      //loop through each properties (ignore the once from above query.
      foreach (PropertyInfo kindPropInfo in QueryList)
      {
        //Usage Cycle Info property requires special handling.
        if ((kindPropInfo.PropertyType.IsSubclassOf(typeof(ExtendedUsageCycleInfo)) ||
            kindPropInfo.PropertyType == typeof(ExtendedUsageCycleInfo)) &&
            piTemplate.GetValue(kindPropInfo.Name) != null)
        {
          //create instance based on runtime type.
          ExtendedUsageCycleInfo piInstanceCycleInfo = (ExtendedUsageCycleInfo)Activator.CreateInstance(piTemplate.GetValue(kindPropInfo.Name).GetType());
          ExtendedUsageCycleInfo pitemplateCycleInfo = (ExtendedUsageCycleInfo)piTemplate.GetValue(kindPropInfo.Name);

          //populate cycle properties from template.
          PopulateCycleProperties(ref piInstanceCycleInfo, pitemplateCycleInfo);
          kindObject.SetValue(kindPropInfo.Name, piInstanceCycleInfo);
        }
        else
        {
          kindObject.SetValue(kindPropInfo.Name, piTemplate.GetValue(kindPropInfo.Name));
        }
      }

      piInstance = kindObject as BasePriceableItemInstance;
    }

    private bool DoesTemplateHaveInstances(int id_pi)
    {
      bool retval = false;

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_INSTANCES_FOR_TEMPLATE__"))
        {

          stmt.AddParam("%%TEMPL_ID%%", id_pi);

          // need to add updlock in SQLServer case to prevent deadlocks
          if (conn.ConnectionInfo.IsOracle)
          {
            stmt.AddParam("%%UPDLOCK%%", "");
          }
          else
          {
            stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
          }

          using (IMTDataReader rdr = stmt.ExecuteReader())
          {
            if (rdr.Read())
            {
              retval = true;
            }
          }
        }
      }

      return retval;
    }

    private void InternalRemovePITemplate(int id_pi)
    {
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          //load child priceable item instances for given priceable 
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__LOAD_PI_CHILD_TEMPLATE_IDS__"))
          {
            stmt.AddParam("%%TEMPL_ID%%", id_pi);

            // need to add updlock in SQLServer case to prevent deadlocks
            if (conn.ConnectionInfo.IsOracle)
            {
              stmt.AddParam("%%UPDLOCK%%", "");
            }
            else
            {
              stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
            }

            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                InternalRemovePITemplate(reader.GetInt32(0));
              }
            }
          }

          //delete priceable item instance.
          using (IMTCallableStatement delStmt = conn.CreateCallableStatement("DeletePITemplate"))
          {
            delStmt.AddParam("piTemplateID", MTParameterType.Integer, id_pi);
            delStmt.AddOutputParam("status", MTParameterType.Integer);
            delStmt.ExecuteNonQuery();

            int status = (int)delStmt.GetOutputValue("status");

            if (status == -10)
            {
              throw new MASBasicException(string.Format("Unable to remove priceable item template with ID {0} because Usage and Aggregate Charge templates cannot be deleted", id_pi));
            }
            else if (status == -20)
            {
              throw new MASBasicException(string.Format("Unable to remove priceable item template with ID {0} because there are existing adjustment transactions", id_pi));
            }
            else if (status != 0)
            {
              throw new MASBasicException(string.Format("Unexpected status code returned from DeletePIInstance stored procedure: {0}", status));
            }
          }
        }

        #region Add Audit Entry
        AuditManager.FireEvent((int)AuditManager.MTAuditEvents.AUDITEVENT_PO_DELETEPI, -1, (int)AuditManager.MTAuditEntityType.AUDITENTITY_TYPE_PRODCAT, -1,
        string.Format("Successfully removed Priceable Item template : {0}", id_pi));
        m_Logger.LogInfo(string.Format("Successfully removed Priceable Item template : {0}", id_pi));
        #endregion

      }
      catch (MASBasicException masE)
      {
        m_Logger.LogException("MASBasicException caught removing priceable item template", masE);

        throw masE;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Unhandled exception removing priceable item template", e);
        throw new MASBasicException("Unexpected error removing priceable item template.  Ask system administrator to review server logs.");
      }
    }

    private LanguageCode GetLanguageCode(int code)
    {
      return (LanguageCode)EnumHelper.GetEnumByValue(typeof(LanguageCode), code.ToString());
    }

    private List<decimal> GetAllowedUnitValues(int id)
    {
      List<decimal> allowedUnits = new List<decimal>();
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement unitValStmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_RECURRING_CHARGE_ENUMS_BY_ID_PCWS__"))
        {
          unitValStmt.AddParam("%%ID_PROP%%", id);

          using (IMTDataReader unitReader = unitValStmt.ExecuteReader())
          {
            while (unitReader.Read())
            {
              allowedUnits.Add(unitReader.GetDecimal("enum_value"));
            }
          }
        }
      }

      return allowedUnits;
    }

    private void InternalUpdateCalendar(ref Calendar calendar)
    {
      m_Logger.LogInfo("Updating calendar with id: {0}", calendar.ID.Value);

      if (calendar.IsDefaultWeekdayDirty && calendar.DefaultWeekday == null)
      {
        throw new MASBasicException("Removing default weekday entry is not supported");
      }

      if (calendar.IsDefaultWeekendDirty && calendar.DefaultWeekend == null)
      {
        throw new MASBasicException("Removing default weekend entry is not supported");
      }

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        m_Logger.LogDebug("Update base props");
        BasePropsUtils.UpdateBaseProps(GetSessionContext(),
                calendar.Description,
                calendar.IsDescriptionDirty,
                null,
                false,
                calendar.ID.Value);

        m_Logger.LogDebug("Update calendar days");
        #region Update Calendar Days
        if (calendar.IsSundayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 0, calendar.Sunday);
        }

        if (calendar.IsMondayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 1, calendar.Monday);
        }

        if (calendar.IsTuesdayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 2, calendar.Tuesday);
        }

        if (calendar.IsWednesdayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 3, calendar.Wednesday);
        }

        if (calendar.IsThursdayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 4, calendar.Thursday);
        }

        if (calendar.IsFridayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 5, calendar.Friday);
        }

        if (calendar.IsSaturdayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 6, calendar.Saturday);
        }

        if (calendar.IsDefaultWeekdayDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 7, calendar.DefaultWeekday);
        }

        if (calendar.IsDefaultWeekendDirty)
        {
          UpdateCalendarDay(calendar.ID.Value, 8, calendar.DefaultWeekend);
        }
        #endregion

        m_Logger.LogDebug("Update calendar holidays");
        #region Update Calendar Holidays
        if (calendar.Holidays != null && calendar.Holidays.Count > 0)
        {
          foreach (CalendarHoliday holiday in calendar.Holidays)
          {
            #region Resolve holiday id
            PCIdentifier holidayId = null;

            if (holiday.HolidayID.HasValue && !string.IsNullOrEmpty(holiday.Name))
            {
              holidayId = new PCIdentifier(holiday.HolidayID.Value, holiday.Name);
            }
            else if (holiday.HolidayID.HasValue)
            {
              holidayId = new PCIdentifier(holiday.HolidayID.Value);
            }
            else
            {
              holidayId = new PCIdentifier(holiday.Name);
            }
            #endregion

            int id_holiday = PCIdentifierResolver.ResolveCalendarHoliday(calendar.ID.Value, holidayId, true);

            if (id_holiday == -1)
            {
              #region Add Calendar Holiday
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddCalendarHoliday"))
              {
                stmt.AddParam("id_calendar", MTParameterType.Integer, calendar.ID.Value);
                stmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(holiday.Code));
                stmt.AddParam("nm_name", MTParameterType.String, holiday.Name);
                stmt.AddParam("n_day", MTParameterType.Integer, holiday.Date.Day);
                stmt.AddParam("n_weekday", MTParameterType.Integer, null);
                stmt.AddParam("n_weekofmonth", MTParameterType.Integer, null);
                stmt.AddParam("n_month", MTParameterType.Integer, holiday.Date.Month);
                stmt.AddParam("n_year", MTParameterType.Integer, holiday.Date.Year);
                stmt.AddOutputParam("id_day", MTParameterType.Integer);

                stmt.ExecuteNonQuery();

                holiday.ID = (int)stmt.GetOutputValue("id_day");
              }

              if (holiday.Periods != null && holiday.Periods.Count > 0)
              {
                AddCalendarDayPeriods(holiday);
              }
              #endregion
            }
            else
            {
              holiday.HolidayID = id_holiday;

              #region Update Calendar Holiday
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpdateCalendarHoliday"))
              {
                stmt.AddParam("id_holiday", MTParameterType.Integer, id_holiday);

                if (holiday.IsCodeDirty)
                {
                  stmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(holiday.Code));
                }
                else
                {
                  stmt.AddParam("n_code", MTParameterType.Integer, null);
                }

                if (holiday.IsDateDirty)
                {
                  stmt.AddParam("n_day", MTParameterType.Integer, holiday.Date.Day);
                  stmt.AddParam("n_month", MTParameterType.Integer, holiday.Date.Month);
                  stmt.AddParam("n_year", MTParameterType.Integer, holiday.Date.Year);
                }
                else
                {
                  stmt.AddParam("n_day", MTParameterType.Integer, null);
                  stmt.AddParam("n_month", MTParameterType.Integer, null);
                  stmt.AddParam("n_year", MTParameterType.Integer, null);
                }

                stmt.AddOutputParam("id_day", MTParameterType.Integer);

                stmt.ExecuteNonQuery();

                holiday.ID = (int)stmt.GetOutputValue("id_day");
              }

              UpdateCalendarDayPeriods(holiday);

              #endregion
            }
          }
        }
        #endregion
      }
    }

    private void UpdateCalendarDay(int id_calendar, int n_weekday, CalendarWeekday calendarWeekday)
    {
      m_Logger.LogDebug("Updating calendar day for weekday {0}", n_weekday);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_CALENDAR_DAY_ID__"))
        {
          stmt.AddParam("%%CALENDAR_ID%%", id_calendar);
          stmt.AddParam("%%WEEKDAY%%", n_weekday);

          int dayId = -1;

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
            if (rdr.Read())
            {
              dayId = rdr.GetInt32("id_day");
            }
          }

          if (dayId != -1)
          {
            m_Logger.LogDebug("Calendar day exists in system");

            if (calendarWeekday != null)
            {
              m_Logger.LogDebug("Calendar day not null, so update");
              calendarWeekday.ID = dayId;

              stmt.QueryTag = "__UPDATE_CALENDAR_DAY__";
              stmt.AddParam("%%DAY_ID%%", dayId);
              stmt.AddParam("%%CODE%%", EnumHelper.GetValueByEnum(calendarWeekday.Code));

              stmt.ExecuteNonQuery();


              UpdateCalendarDayPeriods(calendarWeekday);
            }
            else
            {
              m_Logger.LogDebug("Calendar day is null, so delete");
              stmt.QueryTag = "__DELETE_CALENDAR_DAY__";
              stmt.AddParam("%%ID_DAY%%", dayId);

              stmt.ExecuteNonQuery();
            }
          }
          else if (calendarWeekday != null)
          {
            m_Logger.LogDebug("Calendar day not in system, so add it");
            AddCalendarDay(id_calendar, n_weekday, calendarWeekday);
          }
        }
      }
    }

    private void UpdateCalendarDayPeriods(CalendarDay calendarWeekday)
    {
      m_Logger.LogInfo("Updating caledar day periods");

      if (calendarWeekday.IsPeriodsDirty && calendarWeekday.Periods != null)
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          if (calendarWeekday.Periods.Count > 0)
          {
            m_Logger.LogDebug("Periods have been submitted, so update them");
            Dictionary<int, CalendarDayPeriod> periodIds = new Dictionary<int, CalendarDayPeriod>();


            m_Logger.LogDebug("Load exising day periods");
            #region Load existing periods

            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__GET_DAY_PERIOD_IDS__"))
            {
              stmt.AddParam("%%DAY_ID%%", calendarWeekday.ID.Value);

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
                  CalendarDayPeriod period = new CalendarDayPeriod();
                  period.ID = rdr.GetInt32("PeriodID");
                  period.StartTime = new DateTime(1, 1, 1).AddSeconds(rdr.GetInt32("StartTime"));
                  period.EndTime = new DateTime(1, 1, 1).AddSeconds(rdr.GetInt32("EndTime"));
                  period.Code = (CalendarCode)EnumHelper.GetEnumByValue(typeof(CalendarCode), rdr.GetInt32("Code").ToString());

                  periodIds.Add(period.ID.Value, period);
                }
              }
            }
            #endregion

            m_Logger.LogDebug("Merge existing periods with passed in periods with matching IDs");
            #region Merge existing periods with new data
            foreach (CalendarDayPeriod period in calendarWeekday.Periods)
            {
              if (period.ID.HasValue && periodIds.ContainsKey(period.ID.Value))
              {
                CalendarDayPeriod existingPeriod = periodIds[period.ID.Value];

                #region Apply dirty properties
                if (!period.IsCodeDirty)
                {
                  period.Code = existingPeriod.Code;
                }

                if (!period.IsStartTimeDirty)
                {
                  period.StartTime = existingPeriod.StartTime;
                }

                if (!period.IsEndTimeDirty)
                {
                  period.EndTime = existingPeriod.EndTime;
                }
                #endregion

                periodIds.Remove(period.ID.Value);
              }
              else if (period.ID.HasValue)
              {
                throw new MASBasicException(string.Format("Cannot update calendar day period with ID {0} because it does not exist", period.ID.Value));
              }
            }
            #endregion

            m_Logger.LogDebug("Sort periods for updates");
            #region Sort new period for insertion
            SortedDictionary<DateTime, CalendarDayPeriod> sortedDayPeriods = new SortedDictionary<DateTime, CalendarDayPeriod>();

            foreach (CalendarDayPeriod dayPeriod in calendarWeekday.Periods)
            {
              sortedDayPeriods.Add(dayPeriod.StartTime, dayPeriod);
            }
            #endregion

            DateTime? lastEndTime = null;

            foreach (KeyValuePair<DateTime, CalendarDayPeriod> kvp in sortedDayPeriods)
            {
              m_Logger.LogDebug("Validate period data");
              #region Validate new period info
              if (kvp.Value.StartTime > kvp.Value.EndTime)
              {
                throw new MASBasicException("Calendar day period start time time must be before end time");
              }

              if (lastEndTime.HasValue && kvp.Value.StartTime < lastEndTime.Value)
              {
                throw new MASBasicException("Calendar day period start time must be after the end time of the previous period");
              }

              lastEndTime = kvp.Value.EndTime;
              #endregion

              if (kvp.Value.ID.HasValue)
              {
                m_Logger.LogDebug("Period exists, so update");
                #region Update period
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__UPDATE_CALENDAR_PERIOD__"))
                {
                  stmt.AddParam("%%PERIOD_ID%%", kvp.Value.ID.Value);
                  stmt.AddParam("%%CODE%%", EnumHelper.GetValueByEnum(kvp.Value.Code));
                  stmt.AddParam("%%START_TIME%%", (int)kvp.Value.StartTime.TimeOfDay.TotalSeconds);
                  stmt.AddParam("%%END_TIME%%", (int)kvp.Value.EndTime.TimeOfDay.TotalSeconds);

                  stmt.ExecuteNonQuery();
                }
                #endregion
              }
              else
              {
                m_Logger.LogDebug("Period does not exist, so add");
                #region Add new period
                using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("AddCalendarPeriod"))
                {
                  callableStmt.AddParam("id_day", MTParameterType.Integer, calendarWeekday.ID.Value);
                  callableStmt.AddParam("n_begin", MTParameterType.Integer, (int)kvp.Value.StartTime.TimeOfDay.TotalSeconds);
                  callableStmt.AddParam("n_end", MTParameterType.Integer, (int)kvp.Value.EndTime.TimeOfDay.TotalSeconds);
                  callableStmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(kvp.Value.Code));
                  callableStmt.AddOutputParam("id_period", MTParameterType.Integer);

                  callableStmt.ExecuteNonQuery();

                  kvp.Value.ID = (int)callableStmt.GetOutputValue("id_period");
                }
                #endregion
              }
            }

            m_Logger.LogDebug("Delete any existing periods not in the update");
            #region Clean up any periods that exist but were not in the update
            if (periodIds.Count > 0)
            {
              string deletePeriodIds = "";
              foreach (int periodId in periodIds.Keys)
              {
                if (deletePeriodIds.Length > 0)
                {
                  deletePeriodIds += ", " + periodId.ToString();
                }
                else
                {
                  deletePeriodIds += periodId.ToString();
                }
              }

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_CALENDAR_PERIODS_LIST__"))
              {
                stmt.AddParam("%%PERIOD_ID_LIST%%", deletePeriodIds);

                stmt.ExecuteNonQuery();
              }
            }
            #endregion

          }
          else
          {
            m_Logger.LogDebug("Empty periods collection, so delete all periods");
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__DELETE_CALENDAR_PERIODS_PCWS__"))
            {
              stmt.AddParam("%%DAY_ID%%", calendarWeekday.ID);

              stmt.ExecuteNonQuery();
            }
          }
        }
      }

    }

    private void InternalCreateCalendar(ref Calendar calendar)
    {
      m_Logger.LogInfo("Creating new calendar with name: {0}", calendar.Name);

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        m_Logger.LogDebug("Create base props");
        calendar.ID = BasePropsUtils.CreateBaseProps(GetSessionContext(), calendar.Name, calendar.Description, "", CALENDAR_KIND);

        m_Logger.LogDebug("Create calendar record");
        #region Add Calendar Record
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(PCWS_QUERY_FOLDER, "__ADD_CALENDAR_PCWS__"))
        {
          stmt.AddParam("%%ID_CAL%%", calendar.ID.Value);
          stmt.AddParam("%%TZOFFSET%%", 0);
          stmt.AddParam("%%BCOMBWEEKEND%%", "F");

          stmt.ExecuteNonQuery();
        }
        #endregion

        m_Logger.LogDebug("Set default weekend and weekday if needed");
        if (calendar.DefaultWeekend == null)
        {
          calendar.DefaultWeekend = new CalendarWeekday();
          calendar.DefaultWeekend.Code = CalendarCode.Weekend;
        }

        if (calendar.DefaultWeekday == null)
        {
          calendar.DefaultWeekday = new CalendarWeekday();
          calendar.DefaultWeekday.Code = CalendarCode.Off_Peak;
        }

        m_Logger.LogDebug("Add calendar days");
        #region Add Calendar Days
        if (calendar.IsSundayDirty && calendar.Sunday != null)
        {
          AddCalendarDay(calendar.ID.Value, 0, calendar.Sunday);
        }

        if (calendar.IsMondayDirty && calendar.Monday != null)
        {
          AddCalendarDay(calendar.ID.Value, 1, calendar.Monday);
        }

        if (calendar.IsTuesdayDirty && calendar.Tuesday != null)
        {
          AddCalendarDay(calendar.ID.Value, 2, calendar.Tuesday);
        }

        if (calendar.IsWednesdayDirty && calendar.Wednesday != null)
        {
          AddCalendarDay(calendar.ID.Value, 3, calendar.Wednesday);
        }

        if (calendar.IsThursdayDirty && calendar.Thursday != null)
        {
          AddCalendarDay(calendar.ID.Value, 4, calendar.Thursday);
        }

        if (calendar.IsFridayDirty && calendar.Friday != null)
        {
          AddCalendarDay(calendar.ID.Value, 5, calendar.Friday);
        }

        if (calendar.IsSaturdayDirty && calendar.Saturday != null)
        {
          AddCalendarDay(calendar.ID.Value, 6, calendar.Saturday);
        }

        AddCalendarDay(calendar.ID.Value, 7, calendar.DefaultWeekday);
        AddCalendarDay(calendar.ID.Value, 8, calendar.DefaultWeekend);
        #endregion

        m_Logger.LogDebug("Add calendar holidays");
        #region Add Calendar Holidays
        if (calendar.Holidays != null && calendar.Holidays.Count > 0)
        {
          foreach (CalendarHoliday holiday in calendar.Holidays)
          {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddCalendarHoliday"))
            {
              stmt.AddParam("id_calendar", MTParameterType.Integer, calendar.ID.Value);
              stmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(holiday.Code));
              stmt.AddParam("nm_name", MTParameterType.String, holiday.Name);
              stmt.AddParam("n_day", MTParameterType.Integer, holiday.Date.Day);
              stmt.AddParam("n_weekday", MTParameterType.Integer, null);
              stmt.AddParam("n_weekofmonth", MTParameterType.Integer, null);
              stmt.AddParam("n_month", MTParameterType.Integer, holiday.Date.Month);
              stmt.AddParam("n_year", MTParameterType.Integer, holiday.Date.Year);
              stmt.AddOutputParam("id_day", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              holiday.ID = (int)stmt.GetOutputValue("id_day");
            }

            if (holiday.Periods != null && holiday.Periods.Count > 0)
            {
              AddCalendarDayPeriods(holiday);
            }
          }
        }
        #endregion
      }
    }

    private void AddCalendarDay(int id_calendar, int n_weekday, CalendarWeekday calendarWeekday)
    {
      m_Logger.LogInfo("Adding new calendar day for weekday {0}", n_weekday);
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("AddCalendarWeekday"))
        {
          callableStmt.AddParam("id_calendar", MTParameterType.Integer, id_calendar);
          callableStmt.AddParam("n_weekday", MTParameterType.Integer, n_weekday);
          callableStmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(calendarWeekday.Code));

          callableStmt.AddOutputParam("id_day", MTParameterType.Integer);

          callableStmt.ExecuteNonQuery();

          calendarWeekday.ID = (int)callableStmt.GetOutputValue("id_day");
        }
      }

      if (calendarWeekday.Periods != null && calendarWeekday.Periods.Count > 0)
      {
        m_Logger.LogDebug("Calendar day periods have been specified so add them");
        AddCalendarDayPeriods(calendarWeekday);
      }
    }

    private void AddCalendarDayPeriods(CalendarDay calendarWeekday)
    {
      m_Logger.LogInfo("Adding calendar day periods");

      SortedDictionary<DateTime, CalendarDayPeriod> sortedDayPeriods = new SortedDictionary<DateTime, CalendarDayPeriod>();

      m_Logger.LogDebug("Sort day periods for insertion");
      foreach (CalendarDayPeriod dayPeriod in calendarWeekday.Periods)
      {
        sortedDayPeriods.Add(dayPeriod.StartTime, dayPeriod);
      }

      DateTime? lastEndTime = null;

      foreach (KeyValuePair<DateTime, CalendarDayPeriod> kvp in sortedDayPeriods)
      {
        m_Logger.LogDebug("Validate period for insertion");
        if (kvp.Value.StartTime > kvp.Value.EndTime)
        {
          throw new MASBasicException("Calendar day period start time time must be before end time");
        }

        if (lastEndTime.HasValue && kvp.Value.StartTime < lastEndTime.Value)
        {
          throw new MASBasicException("Calendar day period start time must be after the end time of the previous period");
        }

        lastEndTime = kvp.Value.EndTime;

        m_Logger.LogDebug("Add calendar day period");
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTCallableStatement callableStmt = conn.CreateCallableStatement("AddCalendarPeriod"))
          {
            callableStmt.AddParam("id_day", MTParameterType.Integer, calendarWeekday.ID.Value);
            callableStmt.AddParam("n_begin", MTParameterType.Integer, (int)kvp.Value.StartTime.TimeOfDay.TotalSeconds);
            callableStmt.AddParam("n_end", MTParameterType.Integer, (int)kvp.Value.EndTime.TimeOfDay.TotalSeconds);
            callableStmt.AddParam("n_code", MTParameterType.Integer, EnumHelper.GetValueByEnum(kvp.Value.Code));
            callableStmt.AddOutputParam("id_period", MTParameterType.Integer);

            callableStmt.ExecuteNonQuery();

            kvp.Value.ID = (int)callableStmt.GetOutputValue("id_period");
          }
        }
      }
    }

    private AdjustmentInstance CreateAdjusmentInstanceFromTemplate(AdjustmentTemplate templ)
    {
      AdjustmentInstance instance = new AdjustmentInstance();

      instance.Description = templ.Description;
      instance.DisplayName = templ.DisplayName;
      instance.ID = templ.ID;
      instance.LocalizedDescriptions = templ.LocalizedDescriptions.ToDictionary(entry => entry.Key, entry => entry.Value);
      instance.LocalizedDisplayNames = templ.LocalizedDisplayNames.ToDictionary(entry => entry.Key, entry => entry.Value);
      instance.Name = templ.Name;

      return instance;
    }

    #endregion

  }
}
