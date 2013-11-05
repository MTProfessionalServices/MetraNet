using System;
using System.Collections.Generic;
using System.Diagnostics;
using NUnit.Framework;

using MetraTech.Security;
using MetraTech;
using MetraTech.Test.Common;
using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using System.Collections;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.BaseTypes;
using System.Linq;
using System.Reflection;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.ActivityServices.Services.Common;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.ProductCatalogServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class ProductCatalogServiceTest
  {

    private Logger m_Logger = new Logger("[ProdCatalogTestLogger]");
    //private BasePriceableItemTemplate deleteTemplate = null;

    #region tests

    [Test]
    [Category("SaveCalendar")]
    public void T01SaveCalendar()
    {
      var client = new ProductCatalogServiceClient
      {
        ClientCredentials = {UserName = {UserName = "su", Password = "su123"}}
      };
      
      var calendarName = "my calendar " + Guid.NewGuid().GetHashCode();
      var c = new Calendar
      {
        DefaultWeekday = new CalendarWeekday
        {
          Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Peak,
          Periods = GetCalendarDayPeriods()
        },
        DefaultWeekend = new CalendarWeekday
        {
          Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Off_Peak,
          Periods = GetCalendarDayPeriods()
        },
        Description = calendarName,
        Name = calendarName,
        Friday = new CalendarWeekday
        {
          Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Peak,
          Periods = GetCalendarDayPeriods()
        },
        Holidays = new List<CalendarHoliday>
        {
          new CalendarHoliday
          {
            Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Holiday,
            Date = new DateTime(2009, 12, 17),
            Name = "birthday",
            Periods = new List<CalendarDayPeriod>()
          }
        }
      };
      
      c.Holidays[0].Periods.Add(new CalendarDayPeriod
      {
        StartTime = new DateTime(2009, 12, 17, 9, 0, 0),
        EndTime = new DateTime(2009, 12, 17, 18, 0, 0),
        Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Holiday
      });

      client.SaveCalendar(c);
      client.GetCalendar(new PCIdentifier(c.Name), out c);
      c.Holidays[0].Date = new DateTime(2009, 12, 18);
      client.SaveCalendar(c);
      client.GetCalendar(new PCIdentifier(c.Name), out c);
      client.RemoveHolidayFromCalendar(new PCIdentifier(c.ID.Value), new PCIdentifier(c.Holidays[0].HolidayID.Value));
      client.SaveCalendar(c);
    }

    [Test]
    [Category("TestGetPriceableItemTypes")]
    public void T02TestGetPriceableItemTypes()
    {

      MTList<PriceableItemType> list = GetPriceableItemTypes();

      Assert.IsNotEmpty(list.Items);
      Assert.Greater(list.TotalRows, 0);

      var Query = (from i in list.Items
                   where i.Name == null ||
                   i.Name.Length <= 0 ||
                   i.ProductViewName == null ||
                   i.ProductViewName.Length <= 0 ||
                   i.ServiceDefName == null ||
                   i.ServiceDefName.Length <= 0
                   select i);

      Assert.AreEqual(Query.Count(), 0);

      foreach (PriceableItemType piType in list.Items)
      {
        PriceableItemType pi = GetPriceableItemType(new PCIdentifier(piType.Name));

        Assert.IsNotNull(pi);
        Assert.AreEqual(pi.Name, piType.Name, "Name didnt match");
        Assert.AreEqual(pi.ServiceDefName, piType.ServiceDefName, "service def name didnt match");
        Assert.AreEqual(pi.Kind, piType.Kind, "NKind are not equal");
        Assert.AreEqual(pi.Description, piType.Description, "description are not equal");
        Assert.AreEqual(pi.ProductViewName, piType.ProductViewName, "Product view name are not equal");

        if (pi.ChildPriceableItemTypes != null)
        {
            foreach (PCIdentifier childPI in pi.ChildPriceableItemTypes)
            {
                Assert.IsNotNull(childPI.Name, "child priceable item name is null");
                Assert.IsNotEmpty(childPI.Name, "child priceable item name is empty");
            }
        }

      }

    }

    [Test]
    [Category("CreatePIInstanceSongSessionFromTemplateTest")]
    public void T03CreatePIInstanceSongSessionFromTemplateTest()
    {

      ProductCatalogServiceClient pcClient = new ProductCatalogServiceClient();
      pcClient.ClientCredentials.UserName.UserName = "su";
      pcClient.ClientCredentials.UserName.Password = "su123";
      pcClient.Open();


      MTList<BasePriceableItemTemplate> piTemplates = new MTList<BasePriceableItemTemplate>();
      piTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Song Session"));


      piTemplates.PageSize = 100;

      pcClient.GetPriceableItemTemplates(ref piTemplates);


      BasePriceableItemTemplate Template = piTemplates.Items[0];


      Assert.IsNotNull(Template);

      BasePriceableItemInstance Instance = null;


      pcClient.CreatePIInstanceFromTemplate(new PCIdentifier((int)Template.ID), out Instance);

      Assert.IsNotNull(Instance);
      Assert.IsNotNull(Instance.GetProperty("Song_Session_Child").GetValue(Instance, null));

      pcClient.Close();

    }
   
    [Test]
    [Category("TestCreatePriceableItemInstaceFromTemplate")]
    public void T04TestCreatePriceableItemInstaceFromTemplate()
    {
        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        client.Open();

        MTList<BasePriceableItemTemplate> piTemplates = new MTList<BasePriceableItemTemplate>();
        piTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Non Recurring Charge"));
        //piTemplates.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, "Flag Discount"));
        //piTemplates.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, "Flat Rate Recurring Charge"));
        piTemplates.PageSize = 100;

        client.GetPriceableItemTemplates(ref piTemplates);

        Assert.Greater(piTemplates.Items.Count, 0);

        //BasePriceableItemTemplate Template = piTemplates.Items.Find(item => item.Name == "Flat Discount");
        BasePriceableItemTemplate Template = piTemplates.Items[0]; //Find(item => item.Name == "Flat Rate Recurring Charge");

        Assert.IsNotNull(Template);

        
        //Assert.IsInstanceOfType(typeof(Flat_DiscountPITemplate), Template);
        //Assert.IsInstanceOfType(typeof(Flat_Rate_Recurring_ChargePITemplate), Template);

        //BasePriceableItemInstance Instance = new Flat_DiscountPIInstance();
        BasePriceableItemInstance Instance = null;

        client.CreatePIInstanceFromTemplate(new PCIdentifier((int)Template.ID), out Instance);

        Assert.IsNotNull(Instance);



    }
    
    [Test]
    [Category("GetReasonCodes")]
    public void T05GetReasonCodes()
    {
        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";

        MTList<ReasonCode> reasonCodes = new MTList<ReasonCode>();
        client.GetReasonCodes(ref reasonCodes);
        Assert.Greater(reasonCodes.Items.Count, 0);

    }

    protected ProductOffering SetupPOWithPIInstance()
    {
      //create new PO with available and effective dates set
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();

      SavePO(ref po);

      return po;
    }



      protected int SavePO(ref ProductOffering po)
    {
      //save PO
      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";
      int poID = 0;
      try
      {
        poServiceClient.Open();
        poServiceClient.SaveProductOffering(ref po);
        poID = po.ProductOfferingId.Value;
        poServiceClient.Close();
      }
      catch (Exception e)
      {
        m_Logger.LogException("Error saving PO", e);
        //throw e;
        return poID;
      }

      return poID;
    }

    protected bool DeletePO(ProductOffering po)
    {
      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";

      try
      {
        poServiceClient.Open();
        poServiceClient.DeleteProductOffering(new PCIdentifier(po.ProductOfferingId.Value));
        poServiceClient.Close();
      }
      catch (Exception e)
      {
        m_Logger.LogException("Error deleting po ", e);
        return false;
      }

      return true;
    }

    [Test]
    [Category("AvailablePOTest")]
    public void T06AvailablePOTest()
    {
      m_Logger.LogInfo("Starting Available PO Test");

      string poName = string.Empty;

      //create a PO      
      ProductOffering po = SetupPOWithPIInstance();
      m_Logger.LogInfo(string.Format("initial save: po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));   
      if (po.ProductOfferingId <= 0)
      {
          m_Logger.LogInfo("unable to save initial product offerring");
          throw new Exception("Error creating product offerrring");
      }
  
      Assert.IsNotNull(po.PriceableItems[0].PITemplate);
      Assert.Greater(po.PriceableItems[0].PITemplate.ID.Value, 0);

      m_Logger.LogInfo("Template ID on priceable instance : " + po.PriceableItems[0].PITemplate.ID.Value.ToString());

      ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
      effectiveDate.StartDate = System.DateTime.Now.AddDays(-1);
      effectiveDate.StartDateOffset = 0;
      effectiveDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
      effectiveDate.EndDate = System.DateTime.Now.AddYears(5);
      effectiveDate.EndDateOffset = 0;
      effectiveDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;


      po.EffectiveTimeSpan.StartDate = effectiveDate.StartDate.Value;
      po.EffectiveTimeSpan.StartDateType = effectiveDate.StartDateType; ;
      po.EffectiveTimeSpan.StartDateOffset = effectiveDate.StartDateOffset;
      po.EffectiveTimeSpan.EndDate = effectiveDate.EndDate.Value;
      po.EffectiveTimeSpan.EndDateType = effectiveDate.EndDateType; ;
      po.EffectiveTimeSpan.EndDateOffset = effectiveDate.EndDateOffset;


      ProdCatTimeSpan availableDate = new ProdCatTimeSpan();
      availableDate.StartDate = System.DateTime.Now.AddDays(-1);
      availableDate.StartDateOffset = 0;
      availableDate.StartDateType = ProdCatTimeSpan.MTPCDateType.Absolute;
      availableDate.EndDate = System.DateTime.Now.AddYears(5);
      availableDate.EndDateOffset = 0;
      availableDate.EndDateType = ProdCatTimeSpan.MTPCDateType.Absolute;


      po.AvailableTimeSpan.StartDate = availableDate.StartDate.Value;
      po.AvailableTimeSpan.StartDateType = availableDate.StartDateType; ;
      po.AvailableTimeSpan.StartDateOffset = availableDate.StartDateOffset;
      po.AvailableTimeSpan.EndDate = availableDate.EndDate.Value;
      po.AvailableTimeSpan.EndDateType = availableDate.EndDateType; ;
      po.AvailableTimeSpan.EndDateOffset = availableDate.EndDateOffset;

      po.AvailableTimeSpan.StartDate = availableDate.StartDate;

      m_Logger.LogInfo(string.Format("call save po after dates are set. po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));
      int poID = SavePO(ref po);

      if (poID <= 0)
      {
        m_Logger.LogInfo("Unable to save PO after Available and Effective dates were set");
        throw new Exception("Error saving Product offering");
      }

      //make a change to the PO
      po.DisplayName = "Updated on " + DateTime.Now.ToLongTimeString();
      po.Currency = MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies.SystemCurrencies.CAD;

      //preserve poname before updating po object
      poName = po.Name;
      po.Name += " modified on " + DateTime.Now.ToString();

      m_Logger.LogInfo(string.Format("call savepo after po.name is modified. po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));
      //save it again -- should fail
      if (SavePO(ref po) > 0)
      {
        m_Logger.LogInfo("Error: Active PO's should not be modified");
        throw new Exception ("Error: Active PO's should not be modified");
      }
      
     //rollback poname since po save is failed. so the po name is in sync with databasde.
      po.Name = poName;

        //remove pi from po after avail dates are set.
      ProductOfferingServiceClient offClient = new ProductOfferingServiceClient();
      offClient.ClientCredentials.UserName.UserName = "su";
      offClient.ClientCredentials.UserName.Password = "su123";
      offClient.Open();
      m_Logger.LogInfo(string.Format("remove pi instance from po after avail dates are set. po.id => {0}, po.name => {1}",
          po.ProductOfferingId.Value, po.Name));
      m_Logger.LogInfo(string.Format("eff st date => {0}, avail st date => {1}", po.EffectiveTimeSpan.StartDate, po.AvailableTimeSpan.StartDate));
      try
      {
          offClient.RemovePIInstanceFromPO(new PCIdentifier(po.ProductOfferingId.Value), new PCIdentifier(po.PriceableItems[0].ID.Value));
          m_Logger.LogInfo("Error: Active PO's Priceable Items were removed");
          throw new Exception("Error: Active PO's Priceable Items were removed");
      }
      catch (Exception e)
      {
          m_Logger.LogException("Exception Occurred at availablePOTest method ", e);
      }
      offClient.Close();




      ProductCatalogServiceClient catClient = new ProductCatalogServiceClient();
      catClient.ClientCredentials.UserName.UserName = "su";
      catClient.ClientCredentials.UserName.Password = "su123";
      catClient.Open();
     
      //attempt adding a PI

      MTList<BasePriceableItemTemplate> templates = new MTList<BasePriceableItemTemplate>();
      templates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.NonRecurring));
      templates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Non Recurring Charge"));

      templates.PageSize = 100;
        
      catClient.GetPriceableItemTemplates(ref templates);
      BasePriceableItemInstance bpi = null;
      catClient.CreatePIInstanceFromTemplate(new PCIdentifier(templates.Items[0].ID.Value), out bpi);
      catClient.Close();

      //SMSPIInstance inst = new SMSPIInstance();
      //inst.PITemplate = new PCIdentifier("SMS");
      //inst.Description = "Another Instance";
      //inst.Name = "SMS2";
      bpi.Name = bpi.Name + "append";
      bpi.Description = (string.IsNullOrEmpty(bpi.Description) ? "" : bpi.Description) + "append";
      bpi.DisplayName = (string.IsNullOrEmpty(bpi.DisplayName) ? "" : bpi.DisplayName) + "append"; 

      po.PriceableItems.Add(bpi);

      m_Logger.LogInfo(string.Format("call save po after pi is added with date set. po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));
      if (SavePO(ref po) > 0)
      {
        m_Logger.LogInfo("Error: added priceable item to an Active PO");
        throw new Exception("Error: added priceable item to an Active PO");
      }

      //m_Logger.LogInfo(string.Format("Call Delete PO: {0} {1} {2}", po.ProductOfferingId.Value, po.Name, po.AvailableTimeSpan.StartDate));
      //attempt to delete the PO.
      //Findings: Current release allows deletion of Active PO (with available date set)
        // Try calling delete after adding atleast one subscription
      //if (DeletePO(po))
      //{
      //  m_Logger.LogInfo("Error: Active PO was removed");
      //  throw new Exception("Error: Active PO was removed");
      //}

      //wipe out dates,and clean up
      //po.EffectiveTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Null;
      //po.AvailableTimeSpan.StartDateType = ProdCatTimeSpan.MTPCDateType.Null;

      po.EffectiveTimeSpan.StartDate = null;
      po.EffectiveTimeSpan.StartDateOffset = null;
      po.AvailableTimeSpan.StartDate = null;
      po.AvailableTimeSpan.StartDateOffset = null;
      po.EffectiveTimeSpan.EndDate = null;
      po.EffectiveTimeSpan.EndDateOffset = null;
      po.AvailableTimeSpan.EndDate = null;
      po.AvailableTimeSpan.EndDateOffset = null;

      //m_Logger.LogInfo(string.Format("eff start date: {0}, avail st date : {1}", po.EffectiveTimeSpan.StartDate.t == null ? "null" : "not null", po.AvailableTimeSpan == null? "null" : "not null"));
      m_Logger.LogInfo(string.Format("call savepo after dates are cleared. po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));


      if (SavePO(ref po) <= 0)
      {
        m_Logger.LogInfo("Error saving PO after Available Date was cleared");
        throw new Exception("Error saving PO");
      }

      m_Logger.LogInfo(string.Format("calling deletepo after dates are cleared. po.id => {0}, po.name =>{1}", po.ProductOfferingId, po.Name));
      if (!DeletePO(po))
      {
        m_Logger.LogInfo("Error deleting PO");
        throw new Exception("Error deleting PO");
      }

      //verify if PO is deleted
      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";

      MTList<ProductOffering> items = new MTList<ProductOffering>();
      items.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, po.Name));
      items.PageSize = 100;
  
      poServiceClient.Open();
      poServiceClient.GetProductOfferings(ref items);
      poServiceClient.Close();

      foreach (ProductOffering tempPO in items.Items)
      {
        if (tempPO.ProductOfferingId.Value == poID)
        {
          m_Logger.LogInfo("Error: PO " + poID + " has not been deleted");
          throw new Exception("Error: Product Offering " + poID + " has not been deleted");
        }
      }
    }

    [Test]
    [Category("CheckMultiplePIInstancesWithSameTemplate1")]
    public void T07CheckMultiplePIInstancesWithSameTemplate1()
    {
      //Get the list of PI templates
      ProductCatalogService_GetPriceableItemTemplates_Client client = new ProductCatalogService_GetPriceableItemTemplates_Client();
      
      client.UserName = "su";
      client.Password = "su123";

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();
      list.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Non Recurring Charge"));
      list.PageSize = 100;
      client.InOut_piTemplates = list;
      client.Invoke();
      list = client.InOut_piTemplates;

      if (list.Items.Count == 0)
      {
        // need to create a template..return for now
        return;
      }

      //Get the first template
      BasePriceableItemTemplate tpl = list.Items[0];

      //Create two separate PI instances from the same template
      ProductCatalogService_CreatePIInstanceFromTemplate_Client createInstanceClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
      createInstanceClient.UserName = "su";
      createInstanceClient.Password = "su123";
      createInstanceClient.In_piTemplateID = new PCIdentifier(tpl.ID.Value);

      createInstanceClient.Invoke();

      BasePriceableItemInstance piInstance1 = createInstanceClient.Out_piInstance;

      //create the second pi instance
      createInstanceClient = new ProductCatalogService_CreatePIInstanceFromTemplate_Client();
      createInstanceClient.UserName = "su";
      createInstanceClient.Password = "su123";
      createInstanceClient.In_piTemplateID = new PCIdentifier(tpl.ID.Value);

      createInstanceClient.Invoke();

      BasePriceableItemInstance piInstance2 = createInstanceClient.Out_piInstance;


      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();
      //po.AvailableStartDate = DateTime.Now;
      ProdCatTimeSpan availDate = new ProdCatTimeSpan();
      availDate.StartDate = System.DateTime.Now;
      po.AvailableTimeSpan.StartDate = availDate.StartDate;

      //add both PI's
      po.PriceableItems.Add(piInstance1);
      po.PriceableItems.Add(piInstance2);

      //save PO
      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";

      try
      {
        poServiceClient.Open();
        poServiceClient.SaveProductOffering(ref po);
        poServiceClient.Close();
      }
      catch (Exception)
      {
        //error should occur on Save, thus preventing addding both PI instances
        return;
      }

      throw new Exception("Incorrectly saved multiple PI instances of the same PI template");

    }

    [Test]
    [Category("UpdatePIInstanceTest")]
    public void T08UpdatePIInstanceTest()
    {
      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();
      SavePO(ref po);

      BasePriceableItemInstance pi = po.PriceableItems[0];
      pi.Description = pi.Description + "_modified";

      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";

      try
      {
        poServiceClient.Open();
        poServiceClient.UpdatePIInstance(pi);
        poServiceClient.Close();
      }
      catch (Exception e)
      {
        poServiceClient.Abort();
        m_Logger.LogException("Error updating PI Instance", e);
        throw;
      }
    }


    [Test]
    [Category("UpdatePIInstanceWithOverridePropertyTest")]
    public void T09UpdatePIInstanceWithOverridePropertyTest()
    {
        //Dictionary<string, object> AssertList = new Dictionary<string, object>();

        //create a PO
        ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();

        ProductCatalogServiceClient pcClient = new ProductCatalogServiceClient();
        pcClient.ClientCredentials.UserName.UserName = "su";
        pcClient.ClientCredentials.UserName.Password = "su123";
        pcClient.Open();

        MTList<BasePriceableItemTemplate> templateList = new MTList<BasePriceableItemTemplate>();
        templateList.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.NonRecurring));
        templateList.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Non Recurring Charge"));
        templateList.PageSize = 100;
        pcClient.GetPriceableItemTemplates(ref templateList);
        

        #region Add one pi instance of each kind.
        foreach (BasePriceableItemTemplate template in templateList.Items)
        {
            if ((template as NonRecurringChargePITemplate) != null )
            {
                BasePriceableItemInstance pinstance;
                pcClient.CreatePIInstanceFromTemplate(new PCIdentifier((int)template.ID), out pinstance);
                pinstance.DisplayName = (string.IsNullOrEmpty(pinstance.DisplayName) ? "" : pinstance.DisplayName) + "append";
                pinstance.Description = (string.IsNullOrEmpty(pinstance.Description) ? "" : pinstance.Description) + "append";
                po.PriceableItems.Add(pinstance);
                break;
            }

        }

        templateList = new MTList<BasePriceableItemTemplate>();
        templateList.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.Recurring));
        templateList.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Recurring Charge"));
        templateList.PageSize = 100;
        pcClient.GetPriceableItemTemplates(ref templateList);

        foreach (BasePriceableItemTemplate template in templateList.Items)
        {
            if ((template as RecurringChargePITemplate) != null)
            {
                BasePriceableItemInstance pinstance;
                pcClient.CreatePIInstanceFromTemplate(new PCIdentifier((int)template.ID), out pinstance);
                po.PriceableItems.Add(pinstance);
                break;
            }

        }

        templateList = new MTList<BasePriceableItemTemplate>();
        templateList.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.Discount));
        templateList.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Discount"));
        templateList.PageSize = 100;
        pcClient.GetPriceableItemTemplates(ref templateList);

        foreach (BasePriceableItemTemplate template in templateList.Items)
        {
            if ((template as DiscountPITemplate) != null)
            {
                BasePriceableItemInstance pinstance;
                pcClient.CreatePIInstanceFromTemplate(new PCIdentifier((int)template.ID), out pinstance);
                po.PriceableItems.Add(pinstance);
                break;
            }

        }

        templateList = new MTList<BasePriceableItemTemplate>();
        templateList.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Equal, (int)PriceableItemKinds.AggregateCharge));
        templateList.PageSize = 100;
        pcClient.GetPriceableItemTemplates(ref templateList);

        foreach (BasePriceableItemTemplate template in templateList.Items)
        {
            if ((template as AggregateChargePITemplate) != null)
            {
                BasePriceableItemInstance pinstance;
                pcClient.CreatePIInstanceFromTemplate(new PCIdentifier((int)template.ID), out pinstance);
                po.PriceableItems.Add(pinstance);
                break;
            }

        }
        #endregion


        pcClient.Close();
        SavePO(ref po);


        BasePriceableItemInstance pi = po.PriceableItems[0];
        pi.Description = pi.Description + "_modified";



        #region updates non overridable properties to test for failure.

        if (!PCConfigManager.IsPropertyOverridable((int)po.PriceableItems[0].PIKind, "Description"))
        {
            po.PriceableItems[0].Description = "ZZZ" + po.PriceableItems[0].Description;
            //AssertList.Add("Description", po.PriceableItems[0].Description);
        }
        if (!PCConfigManager.IsPropertyOverridable((int)po.PriceableItems[0].PIKind, "DisplayName"))
        {
            po.PriceableItems[0].DisplayName = "ZZZ" + po.PriceableItems[0].DisplayName;
            //AssertList.Add("DisplayName", po.PriceableItems[0].DisplayName);
        }


        if (po.PriceableItems[0].LocalizedDescriptions != null && po.PriceableItems[0].LocalizedDescriptions.Count > 0)
        {
            if (!PCConfigManager.IsPropertyOverridable((int)po.PriceableItems[0].PIKind, "Descriptions"))
            {
                po.PriceableItems[0].LocalizedDescriptions.ToList().ForEach(item => po.PriceableItems[0].LocalizedDescriptions[item.Key] = "ZZZ" + item.Value );
            }
                
        }

        if (po.PriceableItems[0].LocalizedDisplayNames != null && po.PriceableItems[0].LocalizedDisplayNames.Count > 0)
        {
            if (!PCConfigManager.IsPropertyOverridable((int)po.PriceableItems[0].PIKind, "DisplayNames"))
            {
                po.PriceableItems[0].LocalizedDisplayNames.ToList().ForEach(item => po.PriceableItems[0].LocalizedDisplayNames[item.Key] = "ZZZ" + item.Value);
            }
        }
        
        SavePO(ref po);

        Assert.AreNotSame("ZZZ", po.PriceableItems[0].Description.Substring(0, 3).ToUpper());
        Assert.AreNotSame("ZZZ", po.PriceableItems[0].DisplayName.Substring(0, 3).ToUpper());
        
        if (po.PriceableItems[0].LocalizedDescriptions != null && po.PriceableItems[0].LocalizedDescriptions.Count > 0)
        {
            po.PriceableItems[0].LocalizedDescriptions.ToList().ForEach(item => Assert.AreNotSame("ZZZ", item.Value.Substring(0,3).ToUpper()));
        }
        if (po.PriceableItems[0].LocalizedDisplayNames != null && po.PriceableItems[0].LocalizedDisplayNames.Count > 0)
        {
            po.PriceableItems[0].LocalizedDisplayNames.ToList().ForEach(item => Assert.AreNotSame("ZZZ", item.Value.Substring(0, 3).ToUpper()));
        }

        #endregion

        Dictionary<string, object> AssertList;

        foreach (BasePriceableItemInstance bpi in po.PriceableItems)
        {
            AssertList = new Dictionary<string, object>();

            if (bpi.GetProperty("EventType") is PropertyInfo && bpi.GetValue("EventType") != null && 
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.NonRecurring, "EventType"))
            {
                if (((NonRecurringChargeEvents)bpi.GetValue("EventType")) == NonRecurringChargeEvents.Subscribe)
                {
                    bpi.SetValue("EventType", (int)NonRecurringChargeEvents.Unsubscribe);
                    
                }
                else
                {
                    bpi.SetValue("EventType", (int)NonRecurringChargeEvents.Subscribe);
                    
                }
                AssertList.Add("EventType", bpi.GetValue("EventType"));
            }

            if (bpi.GetProperty("Cycle") is PropertyInfo && bpi.GetValue("Cycle") != null && !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "Cycle"))
            {
                if ((bpi.GetValue("Cycle") as MonthlyUsageCycleInfo) != null)
                {
                    WeeklyUsageCycyleInfo wcycle = new WeeklyUsageCycyleInfo();
                    wcycle.DayOfWeek = DayOfWeek.Thursday;
                    bpi.SetValue("Cycle", wcycle);
                    
                }
                else
                {
                    MonthlyUsageCycleInfo mcycle = new MonthlyUsageCycleInfo();
                    mcycle.EndDay = 10;
                    bpi.SetValue("Cycle", mcycle);
                }

                AssertList.Add("Cycle", bpi.GetValue("Cycle"));
            }

            if (bpi.GetProperty("FixedProrationLength") is PropertyInfo && bpi.GetValue("FixedProrationLength") != null && 
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "FixedProrationLength"))
            {
                bpi.SetValue("FixedProrationLength",!((bool)bpi.GetValue("FixedProrationLength")));
                AssertList.Add("FixedProrationLength", bpi.GetValue("FixedProrationLength"));
            }

            if (bpi.GetProperty("ProrateOnDeactivation") is PropertyInfo && bpi.GetValue("ProrateOnDeactivation") != null && 
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "ProrateOnDeactivation"))
            {
                bpi.SetValue("ProrateOnDeactivation", !((bool)bpi.GetValue("ProrateOnDeactivation")));
                AssertList.Add("ProrateOnDeactivation", bpi.GetValue("ProrateOnDeactivation"));
            }

            if (bpi.GetProperty("ProrateInstantly") is PropertyInfo && bpi.GetValue("ProrateInstantly") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "ProrateInstantly"))
            {
              bpi.SetValue("ProrateInstantly", !((bool)bpi.GetValue("ProrateInstantly")));
              AssertList.Add("ProrateInstantly", bpi.GetValue("ProrateInstantly"));
            }

            if (bpi.GetProperty("ProrateOnActivation") is PropertyInfo && bpi.GetValue("ProrateOnActivation") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "ProrateOnActivation"))
            {
                bpi.SetValue("ProrateOnActivation", !((bool)bpi.GetValue("ProrateOnActivation")));
                AssertList.Add("ProrateOnActivation", bpi.GetValue("ProrateOnActivation"));
            }


            if (bpi.GetProperty("ChargeAdvance") is PropertyInfo && bpi.GetValue("ChargeAdvance") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "ChargeAdvance"))
            {
                bpi.SetValue("ChargeAdvance", !((bool)bpi.GetValue("ChargeAdvance")));
                AssertList.Add("ChargeAdvance", bpi.GetValue("ChargeAdvance"));
            }

            if (bpi.GetProperty("ChargePerParticipant") is PropertyInfo && bpi.GetValue("ChargePerParticipant") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "ChargePerParticipant"))
            {
                bpi.SetValue("ChargePerParticipant", !((bool)bpi.GetValue("ChargePerParticipant")));
                AssertList.Add("ChargePerParticipant", bpi.GetValue("ChargePerParticipant"));
            }

            if (bpi.GetProperty("UnitDisplayName") is PropertyInfo && bpi.GetValue("UnitDisplayName") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "UnitDisplayName"))
            {

                bpi.SetValue("UnitDisplayName", bpi.GetValue("UnitDisplayName") + "-update");
                AssertList.Add("UnitDisplayName", bpi.GetValue("UnitDisplayName"));
                
                if (bpi.GetValue("LocalizedUnitDisplayNames") != null
                    && (((Dictionary<LanguageCode, string>)bpi.GetValue("LocalizedUnitDisplayNames")).Count > 0))
                {
                    Dictionary<LanguageCode, string> dicLocalUnitDispName = ((Dictionary<LanguageCode, string>)bpi.GetValue("LocalizedUnitDisplayNames"));
                    dicLocalUnitDispName[dicLocalUnitDispName.First().Key] = dicLocalUnitDispName[dicLocalUnitDispName.First().Key] + "update";
                    bpi.SetValue("LocalizedUnitDisplayNames", dicLocalUnitDispName);
                    AssertList.Add("LocalizedUnitDisplayNames", bpi.GetValue("LocalizedUnitDisplayNames"));
                }
            }

            if (bpi.GetProperty("RatingType") is PropertyInfo && bpi.GetValue("RatingType") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "RatingType"))
            {

                bpi.SetValue("RatingType", (((UDRCRatingType)bpi.GetValue("RatingType")) == UDRCRatingType.Tapered) ? UDRCRatingType.Tiered : UDRCRatingType.Tapered);
                AssertList.Add("RatingType", bpi.GetValue("RatingType"));
            }

            if (bpi.GetProperty("IntegerUnitValue") is PropertyInfo && bpi.GetValue("IntegerUnitValue") != null &&
                 !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "IntegerUnitValue"))
            {

                bpi.SetValue("IntegerUnitValue", !((bool)bpi.GetValue("IntegerUnitValue")));
                AssertList.Add("IntegerUnitValue", bpi.GetValue("IntegerUnitValue"));
            }

            if (bpi.GetProperty("MaxUnitValue") is PropertyInfo && bpi.GetValue("MaxUnitValue") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "MaxUnitValue"))
            {

                bpi.SetValue("MaxUnitValue", (((decimal)bpi.GetValue("MaxUnitValue")) == 1.00M) ? 10.00M : 100.00M);
                AssertList.Add("MaxUnitValue", bpi.GetValue("MaxUnitValue"));
            }

            if (bpi.GetProperty("MinUnitValue") is PropertyInfo && bpi.GetValue("MinUnitValue") != null &&
                !PCConfigManager.IsPropertyOverridable((int)PriceableItemKinds.Recurring, "MinUnitValue"))
            {

                bpi.SetValue("MinUnitValue", (((decimal)bpi.GetValue("MinUnitValue")) == 1.00M) ? 2.00M : 20.00M);
                AssertList.Add("MinUnitValue", bpi.GetValue("MinUnitValue"));
            }

            if (bpi.GetProperty("AllowedUnitValues") is PropertyInfo && bpi.GetValue("AllowedUnitValues") != null)
            {
                    List<decimal> dec = ((List<Decimal>)bpi.GetValue("AllowedUnitValues"));
                    dec.Add(3.00M);
                    bpi.SetValue("AllowedUnitValues", dec);
                    AssertList.Add("AllowedUnitValues", bpi.GetValue("AllowedUnitValues"));
            }

            ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
            poServiceClient.ClientCredentials.UserName.UserName = "su";
            poServiceClient.ClientCredentials.UserName.Password = "su123";
            try
            {
                poServiceClient.Open();
                m_Logger.LogDebug("Calling Update PI Instance");

                poServiceClient.UpdatePIInstance(pi);
                m_Logger.LogDebug("Update PI Success");
                //poServiceClient.Close();

                BasePriceableItemInstance updatedPI = null;
                poServiceClient.GetPIInstanceForPO(new PCIdentifier((int)po.ProductOfferingId), new PCIdentifier((int)pi.ID), out updatedPI);

                //poServiceClient.Close();

                if (updatedPI == null)
                    m_Logger.LogDebug("updated PI returned null");

                Assert.IsNotNull(updatedPI, "updated pi returned null");

                foreach (KeyValuePair<string, object> item in AssertList)
                {
                    if (!(updatedPI.GetProperty(item.Key) is PropertyInfo))
                        continue;

                    if ((item.Value as Dictionary<LanguageCode, string>) != null)
                    {
                        Dictionary<LanguageCode, string> oldValue = item.Value as Dictionary<LanguageCode, string>;
                        Dictionary<LanguageCode, string> newValue = updatedPI.GetValue(item.Key) as Dictionary<LanguageCode, string>;

                        var Query = from old in oldValue
                                    from n in newValue
                                    where old.Key == n.Key &&
                                    old.Value == n.Value
                                    select n;
                        Assert.AreEqual(oldValue.Count, Query.Count(), item.Key + "didnt match");
                    }
                    else if ((item.Value as List<decimal>) != null)
                    {
                        List<decimal> oldDValue = item.Value as List<decimal>;
                        List<decimal> newDValue = updatedPI.GetValue(item.Key) as List<decimal>;

                        var dQuery = from old in oldDValue
                                     from n in newDValue
                                     where old == n
                                     select n;
                        Assert.AreEqual(oldDValue.Count, dQuery.Count(), item.Key + "didnt match");
                    }
                    else
                    {
                        m_Logger.LogDebug("validating " + item.Key.ToString());
                        m_Logger.LogDebug("item value" + updatedPI.GetValue(item.Key.ToString()));
                        Assert.AreEqual(item.Value, updatedPI.GetValue(item.Key), item.Key + "didnt match");
                    }


                }



            }
            catch (Exception e)
            {
                poServiceClient.Abort();
                m_Logger.LogException("Error updating PI Instance", e);
                throw;
            }
            finally
            {
                if (poServiceClient != null && poServiceClient.State == CommunicationState.Opened)
                    poServiceClient.Close();

            }
        }
        Assert.AreEqual(0, 0);

    }
    
    

    [Test]
    [Category("DeletePIInstanceTest")]
    public void T10DeletePIInstanceTest()
    {
      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();

      if (SavePO(ref po) <= 0)
      {
        m_Logger.LogInfo("Unable to save PO");
        throw new Exception("DeletePIInstanceTest: Unable to save PO");
      }

      BasePriceableItemInstance pi = po.PriceableItems[0];
      int piID = pi.ID.Value;

      ProductOfferingServiceClient poServiceClient = new ProductOfferingServiceClient("WSHttpBinding_IProductOfferingService");
      poServiceClient.ClientCredentials.UserName.UserName = "su";
      poServiceClient.ClientCredentials.UserName.Password = "su123";


      try
      {
        poServiceClient.Open();
        poServiceClient.RemovePIInstanceFromPO(new PCIdentifier(po.ProductOfferingId.Value), new PCIdentifier(pi.ID.Value));
        //poServiceClient.Close();
      }
      catch (Exception e)
      {
        poServiceClient.Abort();
        m_Logger.LogException("Error removing PI Instance", e);
        throw;
      }

      //verify that pi was deleted
      //ProductCatalogServiceClient pcServiceClient = new ProductCatalogServiceClient();
      //pcServiceClient.ClientCredentials.UserName.UserName = "su";
      //pcServiceClient.ClientCredentials.UserName.Password = "su123";
      MTList<BasePriceableItemInstance> items = new MTList<BasePriceableItemInstance>();
      try
      {
        //pcServiceClient.Open();
        poServiceClient.GetPIInstancesForPO(new PCIdentifier(po.ProductOfferingId.Value), ref items);
        //pcServiceClient.Close();
      }
      catch (Exception e)
      {
        //pcServiceClient.Abort();
        m_Logger.LogException("Error retrieving PI Instances for PO", e);
        throw;
      }

      foreach (BasePriceableItemInstance curInstance in items.Items)
      {
        if (curInstance.ID.Value == piID)
        {
          m_Logger.LogInfo("Unable to verify that PI was deleted");
          throw new Exception("Unable to verify that PI was deleted");
        }
      }
    }

    [Test]
    [Category("CheckPartialUpdates")]
    public void T11CheckPartialUpdates()
    {
      m_Logger.LogInfo("Starting CheckPartialUpdates test");

      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();
      
      //read some of the fields
      string glCode = po.Glcode;
      string internalURL = po.InternalInformationURL;
      string externalURL = po.ExternalInformationURL;

      //change description
      po.Description += " modified on " + DateTime.Now.ToString();

      //save the po
      SavePO(ref po);

      Assert.AreEqual(glCode, po.Glcode);
      Assert.AreEqual(internalURL, po.InternalInformationURL);
      Assert.AreEqual(externalURL, po.ExternalInformationURL);

    }


    [Test]
    [Category("CheckIncompatibleCycles")]
    public void T12CheckIncompatibleCycles()
    {
      m_Logger.LogInfo("Starting CheckIncompatibleCycles test");

      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();

      Flat_DiscountPIInstance fd = new Flat_DiscountPIInstance();
      WeeklyUsageCycyleInfo weeklyCycle = new WeeklyUsageCycyleInfo();
      weeklyCycle.DayOfWeek = DayOfWeek.Friday;
      fd.Cycle = weeklyCycle;
      fd.Name = "FlatDisc1";
      fd.Description = "Flat Discount";
      po.PriceableItems.Add(fd);

      Flat_Unconditional_DiscountPIInstance ud = new Flat_Unconditional_DiscountPIInstance();
      MonthlyUsageCycleInfo monthly = new MonthlyUsageCycleInfo();
      monthly.EndDay = 12;
      ud.Cycle = monthly;
      ud.Name = "unconditionalDiscount";
      ud.Description = "Discount";
      po.PriceableItems.Add(ud);

      if (SavePO(ref po) > 0)
      {
        m_Logger.LogInfo("Error: incorrectly saved PO with Weekly and Monthly priceable item instances");
        throw new Exception ("Error: incorrectly saved PO with Weekly and Monthly priceable item instances");
      }
    }

    [Test]
    [Category("AddInstanceWithChildsNull")]
    public void T13AddInstanceWithChildsNull()
    {
      m_Logger.LogInfo("Starting CheckMultiplePIInstancesWithSameTemplate test");

      //create a PO
      ProductOffering po = new ProductOfferingServiceTests().SetUpProductOffering();
      /*
      ProdCatTimeSpan availDate = new ProdCatTimeSpan();
      availDate.StartDate = System.DateTime.Now;
      po.AvailableTimeSpan.StartDate = availDate.StartDate;
      */

      AudioConfCallPIInstance inst = new AudioConfCallPIInstance();
      inst.PITemplate = new PCIdentifier(po.PriceableItems[0].PITemplate.ID.Value);
      inst.Description = "Another Instance1";
      inst.Name = "ACCall1";
      po.PriceableItems.Add(inst);

      //Save should not succeed, e.g. return the PO ID
      if (SavePO(ref po) > 0)
      {
          m_Logger.LogInfo("Incorrectly saved  PI instances with childs null");
          throw new Exception("Incorrectly saved  PI instances with childs null");
      }
    }

    [Test]
    [Category("SavePriceableItemTemplate")]
    public void T14SavePriceableItemTemplate()
    {

      SaveAndVerifyNonRecurringPITemplate();
      SaveAndVerifyRecurringPITemplate();
      SaveAndVerifyUnitDepRecurringPITemplate();
      SaveAndVerifyDiscountPITemplate();  
      //SaveAndVerifyUsagePITemplateFails();

    }

    [Test]
    [Category("SaveTemplate")]
    public void T15SaveTemplate()
    {
        SaveNonRecurringTemplate();
        SaveRecurringTemplate();
        SaveUnitDepRecurringTemplate();
        SaveDiscountTemplate();

    }

    [Test]
    [Category("DeletePriceableItemTemplate")]
    public void T16DeletePriceableItemTemplate()
    {
      MTList<BasePriceableItemTemplate> initalTemplates = new MTList<BasePriceableItemTemplate>();
      initalTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Greater, 20));
      initalTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Recurring Charge"));  
      initalTemplates.PageSize = 100;
      ProductCatalogService_GetPriceableItemTemplates_Client client = new ProductCatalogService_GetPriceableItemTemplates_Client();
      client.UserName = "su";
      client.Password = "su123";
      client.InOut_piTemplates = initalTemplates;
      client.Invoke();
      initalTemplates = client.InOut_piTemplates;

      m_Logger.LogDebug(initalTemplates.Items.Count.ToString());
      
      if (initalTemplates.Items.Count > 0)
      {
          //deleteTemplate = null;
        int templateId =  SaveAndVerifyNonRecurringPITemplate();

        //deleteTemplate = initalTemplates.Items[0];

        PCIdentifier deleteMe = new PCIdentifier(templateId);
        m_Logger.LogDebug("Deleting Priceable Item Template {0}", deleteMe.ID.Value);
        ProductCatalogService_DeletePriceableItemTemplate_Client deleteClient = new ProductCatalogService_DeletePriceableItemTemplate_Client();
        deleteClient.UserName = "su";
        deleteClient.Password = "su123";
        deleteClient.In_piTemplateID = deleteMe;
        deleteClient.Invoke();

        MTList<BasePriceableItemTemplate> postTemplates = new MTList<BasePriceableItemTemplate>();
        postTemplates.Filters.Add(new MTFilterElement("PIKind", MTFilterElement.OperationType.Greater, 20));
        postTemplates.Filters.Add(new MTFilterElement("PITypeName", MTFilterElement.OperationType.Equal, "Flat Rate Recurring Charge"));
        postTemplates.PageSize = 100;
        ProductCatalogService_GetPriceableItemTemplates_Client checkClient = new ProductCatalogService_GetPriceableItemTemplates_Client();
        checkClient.UserName = "su";
        checkClient.Password = "su123";
        checkClient.InOut_piTemplates = postTemplates;
        checkClient.Invoke();

        Assert.AreNotEqual(initalTemplates.TotalRows, postTemplates.TotalRows);

        m_Logger.LogDebug("deleted priceable item id : " + deleteMe.ID.Value.ToString());
        //ProductCatalogService_GetPriceableItemTemplate_Client getClient = new ProductCatalogService_GetPriceableItemTemplate_Client();
        BasePriceableItemTemplate basePriceableItemTemplate = null;
        ProductCatalogServiceClient getClient = new ProductCatalogServiceClient();
        getClient.ClientCredentials.UserName.UserName = "su";
        getClient.ClientCredentials.UserName.Password = "su123";
        getClient.Open();

        try
        {
            getClient.GetPriceableItemTemplate(new PCIdentifier(deleteMe.ID.Value), out basePriceableItemTemplate);
        }
        catch
        {
            m_Logger.LogDebug("Error fetching pi template after delete. which is fine");
        }

        Assert.IsNull(basePriceableItemTemplate, "Priceable Item template exists after delete");

        getClient.Close();
      }
    }

    [Test]
    [Category("DeleteUsagePriceableItemTemplate")]
    public void T17DeleteUsagePriceableItemTemplate()
    {
      bool threwException = false;
      ProductCatalogService_DeletePriceableItemTemplate_Client deleteClient = new ProductCatalogService_DeletePriceableItemTemplate_Client();
      PCIdentifier usage = new PCIdentifier("SMS");
      deleteClient.UserName = "su";
      deleteClient.Password = "su123";
      deleteClient.In_piTemplateID = usage;

      try
      {
        deleteClient.Invoke();
      }
      catch (Exception)
      {
        m_Logger.LogDebug("Did not delete usage template");
        threwException = true;
      }

      if (!threwException)
        throw new MASBasicException("Deleted Template");
    }
    #endregion



    #region Internal Methods


    private void SaveUnitDepRecurringTemplate()
    {
        string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
        Unit_Dependent_Recurring_ChargePITemplate template = new Unit_Dependent_Recurring_ChargePITemplate();
        template.Description = string.Format("{0}-{1}", " UDRC Recur-Desc", GUIDHashCode);
        template.DisplayName = string.Format("{0}-{1}", " UDRC Recur-Disp", GUIDHashCode);
        template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
        template.Name = string.Format("{0}-{1}", "UDRC  Recurring", GUIDHashCode);

        WeeklyUsageCycyleInfo wuci = new WeeklyUsageCycyleInfo();
        wuci.DayOfWeek = DayOfWeek.Thursday;
        template.Cycle = wuci;

        template.ChargeAdvance = true;
        template.ProrateOnActivation = true;
        template.ProrateInstantly = false;
        template.ProrateOnDeactivation = false;
        template.ChargePerParticipant = true;
        template.FixedProrationLength = false;



        template.PIKind = PriceableItemKinds.UnitDependentRecurring;

        List<ReasonCode> rsnCodes = new List<ReasonCode>();
        ReasonCode rsncode1 = new ReasonCode();
        rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
        rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
        rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
        rsnCodes.Add(rsncode1);
        ReasonCode rsncode2 = new ReasonCode();
        rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
        rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
        rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
        rsnCodes.Add(rsncode2);

        AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
        flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
        flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
        flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

        AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
        percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
        percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
        percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

        flatAdjTemplate.ReasonCodes = rsnCodes;
        percentAdjTemplate.ReasonCodes = rsnCodes;

        template.UnitDependentRecurringChargeFlatAdjustment = flatAdjTemplate;
        template.UnitDependentRecurringChargePercentAdjustment= percentAdjTemplate;

        template.AllowedUnitValues = new List<decimal>() { 10.00M, 11.00M, 12.00M };
        template.IntegerUnitValue = true;

        template.MaxUnitValue = 15.00M;
        template.MinUnitValue = 5.00M;

        template.RatingType = UDRCRatingType.Tiered;

        template.UnitDisplayName = string.Format("udisplyname:{0}", GUIDHashCode);
        template.UnitName = string.Format("unitname-{0}", GUIDHashCode);

        BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        client.SavePriceableItemTemplate(ref bpt);



        BasePriceableItemTemplate bpt1;

        client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

        Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

        template = bpt1 as Unit_Dependent_Recurring_ChargePITemplate;

        template.Description = "updated " + template.Description;
        template.DisplayName = "updated " + template.DisplayName;

        Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
        localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate UDrecurring  desc {IT}", GUIDHashCode));
        localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate UDrecurring desc {DE}", GUIDHashCode));

        Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
        localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate UDrecurring disp {IT}", GUIDHashCode));
        localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate UDrecurring disp {DE}", GUIDHashCode));

        template.LocalizedDisplayNames = localDisp1;
        template.LocalizedDescriptions = localDesc1;
        template.FixedProrationLength = true;
        template.MinUnitValue = 3.00M;
        template.RatingType = UDRCRatingType.Tapered;

        bpt1 = template as BasePriceableItemTemplate;
        client.SavePriceableItemTemplate(ref bpt1);
    }

    private void SaveRecurringTemplate()
    {
        string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
        Flat_Rate_Recurring_ChargePITemplate template = new Flat_Rate_Recurring_ChargePITemplate();
        template.Description = string.Format("{0}-{1}", " Recur-Desc", GUIDHashCode);
        template.DisplayName = string.Format("{0}-{1}", " Recur-Disp", GUIDHashCode);
        template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
        template.Name = string.Format("{0}-{1}", "Flat Rate  Recurring", GUIDHashCode);

        MonthlyUsageCycleInfo muci = new MonthlyUsageCycleInfo();
        muci.EndDay = 20;
        template.Cycle = muci;

        template.ChargeAdvance = true;
        template.ProrateOnActivation = true;
        template.ProrateInstantly = false;
        template.ProrateOnDeactivation = false;
        template.ChargePerParticipant = true;
        template.FixedProrationLength = false;



        template.PIKind = PriceableItemKinds.Recurring;

        List<ReasonCode> rsnCodes = new List<ReasonCode>();
        ReasonCode rsncode1 = new ReasonCode();
        rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
        rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
        rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
        rsnCodes.Add(rsncode1);
        ReasonCode rsncode2 = new ReasonCode();
        rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
        rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
        rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
        rsnCodes.Add(rsncode2);

        AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
        flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
        flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
        flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

        AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
        percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
        percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
        percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

        flatAdjTemplate.ReasonCodes = rsnCodes;
        percentAdjTemplate.ReasonCodes = rsnCodes;

        template.FlatRecurringChargeFlatAdjustment = flatAdjTemplate;
        template.FlatRecurringChargePercentAdjustment = percentAdjTemplate;


        BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        client.SavePriceableItemTemplate(ref bpt);


        BasePriceableItemTemplate bpt1;

        client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

        Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

        template = bpt1 as Flat_Rate_Recurring_ChargePITemplate;

        template.Description = "updated " + template.Description;
        template.DisplayName = "updated " + template.DisplayName;

        Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
        localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate recurring  desc {IT}", GUIDHashCode));
        localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate recurring desc {DE}", GUIDHashCode));

        Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
        localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate recurring disp {IT}", GUIDHashCode));
        localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate recurring disp {DE}", GUIDHashCode));

        template.LocalizedDisplayNames = localDisp1;
        template.LocalizedDescriptions = localDesc1;

        bpt1 = template as BasePriceableItemTemplate;
        client.SavePriceableItemTemplate(ref bpt1);

        BasePriceableItemTemplate rbpt;
        client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);

        Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
        Assert.AreEqual(bpt1.Name, rbpt.Name);
        Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
        Assert.AreEqual(bpt1.Description, rbpt.Description);
        Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
        Assert.IsNotNull(rbpt.LocalizedDescriptions);

        Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);



    }

    private void SaveNonRecurringTemplate()
    {
        string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
        Flat_Rate_Non_Recurring_ChargePITemplate template = new Flat_Rate_Non_Recurring_ChargePITemplate();
        template.Description = string.Format("{0}-{1}", "Non Recur-Desc", GUIDHashCode);
        template.DisplayName = string.Format("{0}-{1}", "Non Recur-Disp", GUIDHashCode);
        template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
        template.Name = string.Format("{0}-{1}", "Flat Rate Non Recurring", GUIDHashCode);
        template.EventType = NonRecurringChargeEvents.Subscribe;
        template.PIKind = PriceableItemKinds.NonRecurring;

        List<ReasonCode> rsnCodes = new List<ReasonCode>();
        ReasonCode rsncode1 = new ReasonCode();
        rsncode1.Description = string.Format("reasoncode-{0}{1}", 1, template.Description);
        rsncode1.DisplayName = string.Format("reasoncode-{0}{1}", 1, template.DisplayName);
        rsncode1.Name = string.Format("reasoncode-{0}{1}", 1, template.Name);
        rsnCodes.Add(rsncode1);
        ReasonCode rsncode2 = new ReasonCode();
        rsncode2.Description = string.Format("reasoncode-{0}{1}", 2, template.Description);
        rsncode2.DisplayName = string.Format("reasoncode-{0}{1}", 2, template.DisplayName);
        rsncode2.Name = string.Format("reasoncode-{0}{1}", 2, template.Name);
        rsnCodes.Add(rsncode2);

        AdjustmentTemplate flatAdjTemplate = new AdjustmentTemplate();
        flatAdjTemplate.Description = string.Format("adjustment-flat-{0}", template.Description);
        flatAdjTemplate.DisplayName = string.Format("adjustment-flat-{0}", template.DisplayName);
        flatAdjTemplate.Name = string.Format("adjustment-flat-{0}", template.Name);

        AdjustmentTemplate percentAdjTemplate = new AdjustmentTemplate();
        percentAdjTemplate.Description = string.Format("adjustment-percent-{0}", template.Description);
        percentAdjTemplate.DisplayName = string.Format("adjustment-percent-{0}", template.DisplayName);
        percentAdjTemplate.Name = string.Format("adjustment-percent-{0}", template.Name);

        flatAdjTemplate.ReasonCodes = rsnCodes;
        percentAdjTemplate.ReasonCodes = rsnCodes;

        template.FlatNonRecurringChargeFlatAdjustment = flatAdjTemplate;
        template.FlatNonRecurringChargePercentAdjustment = percentAdjTemplate;


        BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        client.SavePriceableItemTemplate(ref bpt);


        BasePriceableItemTemplate bpt1;

        client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

        Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

        template = bpt1 as Flat_Rate_Non_Recurring_ChargePITemplate;

        template.Description = "updated " + template.Description;
        template.DisplayName = "updated " + template.DisplayName;

        template.EventType = NonRecurringChargeEvents.Unsubscribe;

        Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
        localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate non recurring  desc {IT}", GUIDHashCode));
        localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate non recurring desc {DE}", GUIDHashCode));

        Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
        localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat rate non recurring disp {IT}", GUIDHashCode));
        localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat rate non recurring disp {DE}", GUIDHashCode));

        template.LocalizedDisplayNames = localDisp1;
        template.LocalizedDescriptions = localDesc1;

        Assert.IsNotNull(template.FlatNonRecurringChargeFlatAdjustment);

        flatAdjTemplate = template.FlatNonRecurringChargeFlatAdjustment;
        flatAdjTemplate.Description = "updated " + flatAdjTemplate.Description;
        flatAdjTemplate.DisplayName = "updated " + flatAdjTemplate.DisplayName;

        flatAdjTemplate.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
        flatAdjTemplate.LocalizedDescriptions.Add(LanguageCode.FR, template.Description + "{FR}");
        flatAdjTemplate.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
        flatAdjTemplate.LocalizedDisplayNames.Add(LanguageCode.FR, template.Description + "{FR}");
        
        flatAdjTemplate.ReasonCodes.RemoveAt(0);
        ReasonCode rsnCode = flatAdjTemplate.ReasonCodes[0];
        rsnCode.Description = "updated " + rsnCode.Description;
        rsnCode.DisplayName = "updated " + rsnCode.DisplayName;
        rsnCode.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
        rsnCode.LocalizedDescriptions.Add(LanguageCode.FR, "local description {FR}");
        rsnCode.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
        rsnCode.LocalizedDisplayNames.Add(LanguageCode.FR, "local display name {FR}");
        flatAdjTemplate.ReasonCodes[0] = rsnCode;

        template.FlatNonRecurringChargeFlatAdjustment = flatAdjTemplate;

        bpt1 = template as BasePriceableItemTemplate;
        client.SavePriceableItemTemplate(ref bpt1);


        BasePriceableItemTemplate rbpt;
        client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);

        Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
        Assert.AreEqual(bpt1.Name, rbpt.Name);
        Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
        Assert.AreEqual(bpt1.Description, rbpt.Description);
        Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
        Assert.IsNotNull(rbpt.LocalizedDescriptions);

        Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);
        
    }

    private void SaveDiscountTemplate()
    {

        //***********************************************************************/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
        string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
        Flat_DiscountPITemplate template = new Flat_DiscountPITemplate();
        template.Description = string.Format("{0}-{1}", " flat discount-Desc", GUIDHashCode);
        template.DisplayName = string.Format("{0}-{1}", " flat discount-Disp", GUIDHashCode);
        template.Glcode = string.Format("{0}-{1}", "GlName", GUIDHashCode);
        template.Name = string.Format("{0}-{1}", "flat discount", GUIDHashCode);

        SumOfOnePropertyCounter counter = new SumOfOnePropertyCounter();
        counter.Name = string.Format("{0}-{1}", "flat discount counter", GUIDHashCode);
        counter.Description = string.Format("{0}-{1}", "flat discount counter desc", GUIDHashCode);
        counter.DisplayName = string.Format("{0}-{1}", "flat discount counter displayname", GUIDHashCode);
        counter.A = "metratech.com/FlatDiscount/amount";

        template.Qualifier = counter;
        BiWeeklyUsageCycleInfo bwuci = new BiWeeklyUsageCycleInfo();
        bwuci.StartDay = 17;
        bwuci.StartMonth = 12;
        bwuci.StartYear = 2009;
        template.Cycle = bwuci;

        template.DistributionCounterPropName = string.Format("{0}-{1}", "MySum", GUIDHashCode);


        template.PIKind = PriceableItemKinds.Discount;

        Dictionary<LanguageCode, string> localDesc = new Dictionary<LanguageCode,string>();
        localDesc.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount  desc {IT}", GUIDHashCode));
        localDesc.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount desc {DE}", GUIDHashCode));
        localDesc.Add(LanguageCode.FR, string.Format("{0}-{1}", "flat discount desc {FR}", GUIDHashCode));
        localDesc.Add(LanguageCode.JP, string.Format("{0}-{1}", "flat discount desc {JP}", GUIDHashCode));

        Dictionary<LanguageCode, string> localDisp = new Dictionary<LanguageCode, string>();
        localDisp.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount-Disp {IT}", GUIDHashCode));
        localDisp.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount-Disp {DE}", GUIDHashCode));
        localDisp.Add(LanguageCode.FR, string.Format("{0}-{1}", "flat discount-Disp {FR}", GUIDHashCode));
        localDisp.Add(LanguageCode.JP, string.Format("{0}-{1}", "flat discount-Disp {JP}", GUIDHashCode));

        template.LocalizedDescriptions = localDesc;
        template.LocalizedDisplayNames = localDisp;

        
        BasePriceableItemTemplate bpt = template as BasePriceableItemTemplate;

        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        client.SavePriceableItemTemplate(ref bpt);

        BasePriceableItemTemplate bpt1;

        client.GetPriceableItemTemplate(new PCIdentifier(bpt.ID.Value), out bpt1);

        Assert.AreEqual(bpt.ID.Value, bpt1.ID.Value);

        template = bpt1 as Flat_DiscountPITemplate;

        template.Description = "updated " + template.Description;
        template.DisplayName = "updated " + template.DisplayName;

        Dictionary<LanguageCode, string> localDesc1 = new Dictionary<LanguageCode, string>();
        localDesc1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount  desc {IT}", GUIDHashCode));
        localDesc1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount desc {DE}", GUIDHashCode));

        Dictionary<LanguageCode, string> localDisp1 = new Dictionary<LanguageCode, string>();
        localDisp1.Add(LanguageCode.IT, string.Format("{0}-{1}", "flat discount-Disp {IT}", GUIDHashCode));
        localDisp1.Add(LanguageCode.DE, string.Format("{0}-{1}", "flat discount-Disp {DE}", GUIDHashCode));

        template.LocalizedDisplayNames = localDisp1;
        template.LocalizedDescriptions = localDesc1;


        SumOfTwoPropertiesCounter counter1 = new SumOfTwoPropertiesCounter();
        counter1.Description = "updated " + template.Qualifier.Description;
        counter1.DisplayName = "updated " + template.Qualifier.DisplayName;
        counter1.Name = template.Qualifier.Name;
        counter1.ID = template.Qualifier.ID.Value;
        counter.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
        counter.LocalizedDescriptions.Add(LanguageCode.FR, counter1.Description + "{FR}");

        counter.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
        counter.LocalizedDisplayNames.Add(LanguageCode.FR, counter1.DisplayName + "{FR}");

        counter1.B = "metratech.com/FlatDiscount/price";
        counter1.A = "metratech.com/FlatDiscount/amount";
        
        template.Qualifier = counter1;




        bpt1 = template as BasePriceableItemTemplate;
        client.SavePriceableItemTemplate(ref bpt1);

        BasePriceableItemTemplate rbpt;
        client.GetPriceableItemTemplate(new PCIdentifier(bpt1.ID.Value), out rbpt);


        Assert.AreEqual(bpt1.ID.Value, rbpt.ID.Value);
        Assert.AreEqual(bpt1.Name, rbpt.Name);
        Assert.AreEqual(bpt1.DisplayName, rbpt.DisplayName);
        Assert.AreEqual(bpt1.Description, rbpt.Description);
        Assert.AreEqual(bpt1.PIKind, rbpt.PIKind);
        Assert.IsNotNull(rbpt.LocalizedDescriptions);

        Assert.AreEqual(bpt1.LocalizedDescriptions.Count, rbpt.LocalizedDescriptions.Count);

    }



    private void SaveAndVerifyUsagePITemplateFails()
    {
      //MTProductCatalogClass pc = new MTProductCatalogClass();
      //MTPriceableItemTypeClass piType = (MTPriceableItemTypeClass)pc.GetPriceableItemTypeByName("Flat Discount");
      //IMTPriceableItem pi = piType.CreateTemplate(true);

      //ProductCatalogServiceClient client = new ProductCatalogServiceClient();

    }

    private void SaveAndVerifyDiscountPITemplate()
    {
      #region Discount PI Template Test.

      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_DiscountPITemplate discount = new Flat_DiscountPITemplate();

      string Description = string.Format("{0}-{1}", "Flat-Disc-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "Flat-disc-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Flat Discount", GUIDHashCode);
      string CounterName = string.Format("{0}-{1}", "flat discount counter", GUIDHashCode);
      string CounterDescription = string.Format("{0}-{1}", "flat discount counter desc", GUIDHashCode);
      string CounterDisplayName = string.Format("{0}-{1}", "flat discount counter disp", GUIDHashCode);

      discount.Name = Name;
      discount.Description = Description;
      discount.DisplayName = DisplayName;
      discount.PIKind = PriceableItemKinds.Discount;

      BiWeeklyUsageCycleInfo cycle = new BiWeeklyUsageCycleInfo();
      cycle.StartDay = 10;
      cycle.StartMonth = 11;
      cycle.StartYear = 2009;
      discount.Cycle = cycle;

      MTPropertyMetaData md = new MTPropertyMetaDataClass();

      SumOfOnePropertyCounter counter = new SumOfOnePropertyCounter();
      counter.Name = CounterName;
      counter.Description = CounterDescription;
      counter.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
      counter.LocalizedDescriptions.Add(LanguageCode.FR, CounterDescription + "{FR}");
      counter.DisplayName = CounterDisplayName;
      counter.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
      counter.LocalizedDisplayNames.Add(LanguageCode.FR, CounterDisplayName + "{FR}");


      counter.A = "metratech.com/FlatDiscount/amount";

      discount.Qualifier = counter;
  
      BasePriceableItemTemplate bpt = discount as BasePriceableItemTemplate;

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.Open();

      client.SavePriceableItemTemplate(ref bpt);

      discount = bpt as Flat_DiscountPITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;
      client.GetPriceableItemTemplates(ref list);
      
      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Flat_DiscountPITemplate template = list.Items.First() as Flat_DiscountPITemplate;

      Assert.AreEqual(discount.DisplayName, template.DisplayName);
      Assert.AreEqual(discount.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Flat_DiscountPITemplate() as BasePriceableItemTemplate;

      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Flat_DiscountPITemplate templateDetail = bTemplateDetail as Flat_DiscountPITemplate;


      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(BiWeeklyUsageCycleInfo), templateDetail.Cycle);
      //StartYear and StartMonth are not relevant. It is converted and stored as Jan2000 in database.  
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartYear, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartYear);
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartMonth, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartMonth);
      //Assert.AreEqual((int)((BiWeeklyUsageCycleInfo)discount.Cycle).StartDay, (int)((BiWeeklyUsageCycleInfo)templateDetail.Cycle).StartDay);

      Counter c = (Counter)templateDetail.GetValue(templateDetail.GetProperties().First(p => p.Name.ToLower().Equals("qualifier")));
      Assert.AreEqual(CounterName, c.Name);
      Assert.AreEqual(CounterDescription, c.Description);
      

      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }

    private void SaveAndVerifyUnitDepRecurringPITemplate()
    {
      #region Unit Dependent Recurring Test.
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();

      Unit_Dependent_Recurring_ChargePITemplate rc = new Unit_Dependent_Recurring_ChargePITemplate();

      string GlName = string.Format("{0}-{1}", "GlName", GUIDHashCode);

      string Description = string.Format("{0}-{1}", "UDRecur-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "UDRecur-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Unit Dep Recurring", GUIDHashCode);
      string UnitName = string.Format("{0}-{1}", "Unit Name", GUIDHashCode);
      string UnitDisplayName = string.Format("{0}-{1}", "Unit Display Name", GUIDHashCode);

      rc.Name = Name;
      rc.Description = Description;
      rc.DisplayName = DisplayName;
      rc.PIKind = PriceableItemKinds.UnitDependentRecurring;

      WeeklyUsageCycyleInfo cycle = new WeeklyUsageCycyleInfo();
      cycle.DayOfWeek = System.DayOfWeek.Tuesday;
      rc.Cycle = cycle;
      rc.ChargeAdvance = false;
      rc.ProrateOnActivation = true;
      rc.ProrateInstantly= false;
      rc.ProrateOnDeactivation = false;
      rc.ChargePerParticipant = false;
      rc.FixedProrationLength = true;

      //foreach (MTProperty prop in rc.Properties)
      //{
      //  if (prop.Name.ToLower() == "glcode")
      //      prop.Value = GlName;
      //}


      rc.UnitName = UnitName;
      rc.UnitDisplayName = UnitDisplayName;
      rc.IntegerUnitValue = false;
      rc.MinUnitValue = 10.00M;
      rc.MaxUnitValue = 15.00M;
      rc.AllowedUnitValues.Add(11.00M);
      rc.AllowedUnitValues.Add(12.00M);
      rc.AllowedUnitValues.Add(13.00M);
      rc.AllowedUnitValues.Add(14.00M);
      rc.RatingType = UDRCRatingType.Tapered;;

      BasePriceableItemTemplate bpt = rc as BasePriceableItemTemplate;  
      

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();

      client.SavePriceableItemTemplate(ref bpt);

      rc = bpt as Unit_Dependent_Recurring_ChargePITemplate;
      
      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;

      client.GetPriceableItemTemplates(ref list);

      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Unit_Dependent_Recurring_ChargePITemplate template = (Unit_Dependent_Recurring_ChargePITemplate)list.Items.First();

      Assert.AreEqual(rc.DisplayName, template.DisplayName);
      Assert.AreEqual(rc.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Unit_Dependent_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Unit_Dependent_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Unit_Dependent_Recurring_ChargePITemplate;


            Assert.AreEqual(rc.UnitName, templateDetail.UnitName);
            Assert.AreEqual(rc.UnitDisplayName, templateDetail.UnitDisplayName);
            Assert.AreEqual(rc.IntegerUnitValue, templateDetail.IntegerUnitValue);
            Assert.AreEqual(rc.MinUnitValue, templateDetail.MinUnitValue);
            Assert.AreEqual(rc.MaxUnitValue, templateDetail.MaxUnitValue);
            //templateDetail.GetMTProperties().Find(p => p.Name.ToLower().Contains("glcode") && !p.Name.ToLower().Contains("dirty")).GetValue(templateDetail, null);

      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(WeeklyUsageCycyleInfo), templateDetail.Cycle);
      Assert.AreEqual((int)((WeeklyUsageCycyleInfo)rc.Cycle).DayOfWeek, (int)((WeeklyUsageCycyleInfo)templateDetail.Cycle).DayOfWeek);
      
      Assert.AreEqual(rc.ChargeAdvance, templateDetail.ChargeAdvance, "ChargeAdvance property in Recurring Template does not match");
      Assert.AreEqual(rc.ProrateOnActivation, templateDetail.ProrateOnActivation);
      Assert.AreEqual(rc.ProrateInstantly, templateDetail.ProrateInstantly);
      Assert.AreEqual(rc.ProrateOnDeactivation, templateDetail.ProrateOnDeactivation);
      Assert.AreEqual(rc.ChargePerParticipant, templateDetail.ChargeAdvance);
      Assert.AreEqual(rc.FixedProrationLength, templateDetail.FixedProrationLength);


      Assert.AreEqual(rc.UnitName, templateDetail.UnitName);
      Assert.AreEqual(rc.UnitDisplayName, templateDetail.UnitDisplayName);
      Assert.AreEqual(rc.IntegerUnitValue, templateDetail.IntegerUnitValue);
      Assert.AreEqual(rc.MinUnitValue, rc.MinUnitValue);
      Assert.AreEqual(rc.MaxUnitValue, rc.MaxUnitValue);

     
      Assert.AreEqual(rc.AllowedUnitValues.Count, templateDetail.AllowedUnitValues.Count);


      var Query = from td in templateDetail.AllowedUnitValues
                  from id in rc.AllowedUnitValues
                  where td == id
                  select td;

      Assert.AreEqual(Query.Count(), templateDetail.AllowedUnitValues.Count());

      Assert.AreEqual((int)rc.RatingType, (int)templateDetail.RatingType);



      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }

    private void SaveAndVerifyRecurringPITemplate()
    {
      #region Recurring Test.
      string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();
      Flat_Rate_Recurring_ChargePITemplate rc = new Flat_Rate_Recurring_ChargePITemplate();

      string Description = string.Format("{0}-{1}", "Recur-Desc", GUIDHashCode);
      string DisplayName = string.Format("{0}-{1}", "Recur-Disp", GUIDHashCode);
      string Name = string.Format("{0}-{1}", "Flat Rate Recurring", GUIDHashCode);
      string GlName = string.Format("{0}-{1}", "GlName", GUIDHashCode);

      rc.Name = Name;
      rc.Description = Description;
      rc.DisplayName = DisplayName;
      rc.PIKind = PriceableItemKinds.Recurring;

      rc.Glcode = GlName;

      MonthlyUsageCycleInfo cycle = new MonthlyUsageCycleInfo();
      cycle.EndDay = 20;

      rc.Cycle = cycle;
    
      rc.ChargeAdvance = true;
      rc.ProrateOnActivation = true;
      rc.ProrateInstantly = true; 
      rc.ProrateOnDeactivation = true;
      rc.ChargePerParticipant = true;
      rc.FixedProrationLength = true;
      

      ProductCatalogServiceClient client = new ProductCatalogServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";
      client.Open();

      BasePriceableItemTemplate bpt = rc as BasePriceableItemTemplate;
      client.SavePriceableItemTemplate(ref bpt);
      rc = bpt as Flat_Rate_Recurring_ChargePITemplate;

      MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

      list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));
      list.PageSize = 100;
      client.GetPriceableItemTemplates(ref list);

      Assert.IsNotNull(list);
      Assert.IsNotEmpty(list.Items);

      Flat_Rate_Recurring_ChargePITemplate template = (Flat_Rate_Recurring_ChargePITemplate)list.Items.First();

      Assert.AreEqual(rc.DisplayName, template.DisplayName);
      Assert.AreEqual(rc.Description, template.Description);

      BasePriceableItemTemplate bTemplateDetail = new Flat_Rate_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
      client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
      Flat_Rate_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Flat_Rate_Recurring_ChargePITemplate;

      Assert.IsNotNull(templateDetail.Cycle);
      Assert.IsInstanceOf(typeof(MonthlyUsageCycleInfo), templateDetail.Cycle);
      Assert.AreEqual(((MonthlyUsageCycleInfo)rc.Cycle).EndDay, ((MonthlyUsageCycleInfo)templateDetail.Cycle).EndDay);
      Assert.AreEqual(rc.ChargeAdvance, templateDetail.ChargeAdvance, "ChargeAdvance property in Recurring Template does not match");
      Assert.AreEqual(rc.ProrateOnActivation, templateDetail.ProrateOnActivation);
      Assert.AreEqual(rc.ProrateInstantly, templateDetail.ProrateInstantly);
      Assert.AreEqual(rc.ProrateOnDeactivation, templateDetail.ProrateOnDeactivation);
      Assert.AreEqual(rc.ChargePerParticipant, templateDetail.ChargeAdvance);
      Assert.AreEqual(rc.FixedProrationLength, templateDetail.FixedProrationLength);
      
      Assert.AreEqual(rc.Glcode,templateDetail.Glcode);
 
      foreach (PropertyInfo p in template.GetMTProperties())
      {
        //TODO: Fix needed for enumeration issues
        //if (p.Name.ToLower() == "pikind")
        //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
      }
      #endregion
    }


    private int SaveAndVerifyNonRecurringPITemplate()
    {
        #region Non Recurring Test.
        string GUIDHashCode = Guid.NewGuid().GetHashCode().ToString();

        Flat_Rate_Non_Recurring_ChargePITemplate pi = new Flat_Rate_Non_Recurring_ChargePITemplate();

        string Description = string.Format("{0}-{1}", "DESC", GUIDHashCode);
        string DisplayName = string.Format("{0}-{1}", "DISP", GUIDHashCode);
        string Name = string.Format("{0}-{1}", "Flat Rate Non Recurring Charge", GUIDHashCode);

        pi.Name = Name;
        pi.Description = Description;
        pi.DisplayName = DisplayName;
        pi.PIKind = PriceableItemKinds.NonRecurring;
        pi.EventType = NonRecurringChargeEvents.Subscribe;

        BasePriceableItemTemplate bpt = pi as BasePriceableItemTemplate;

        ProductCatalogServiceClient client = new ProductCatalogServiceClient();
        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        client.Open();

        client.SavePriceableItemTemplate(ref bpt);
        pi = bpt as Flat_Rate_Non_Recurring_ChargePITemplate;

        MTList<BasePriceableItemTemplate> list = new MTList<BasePriceableItemTemplate>();

        list.Filters.Add(new MTFilterElement("Name", MTFilterElement.OperationType.Equal, Name));

        list.PageSize = 100;
        client.GetPriceableItemTemplates(ref list);


        Assert.IsNotNull(list);
        Assert.IsNotEmpty(list.Items);


        Flat_Rate_Non_Recurring_ChargePITemplate template = (Flat_Rate_Non_Recurring_ChargePITemplate)list.Items.First();

        Assert.AreEqual(pi.DisplayName, template.DisplayName);
        Assert.AreEqual(pi.Description, template.Description);

        foreach (PropertyInfo p in template.GetMTProperties())
        {
            //TODO: Fix needed for enumeration issues
            //if (p.Name.ToLower() == "pikind")
            //    Assert.AreEqual((int)pi.Kind, (int)p.GetValue(template, null));
        }

        BasePriceableItemTemplate bTemplateDetail = new Flat_Rate_Non_Recurring_ChargePITemplate() as BasePriceableItemTemplate;
        client.GetPriceableItemTemplate(new PCIdentifier((int)template.ID), out bTemplateDetail);
        Flat_Rate_Non_Recurring_ChargePITemplate templateDetail = bTemplateDetail as Flat_Rate_Non_Recurring_ChargePITemplate;


        //Assert.AreEqual(GlName, templateDetail.Glcode);

        Assert.AreEqual(pi.DisplayName, template.DisplayName);
        Assert.AreEqual(pi.Description, template.Description);

        return templateDetail.ID.Value;



        #endregion

    }

    private PriceableItemType GetPriceableItemType(PCIdentifier piTypeID)
    {

      ProductCatalogServiceClient prodCatClient = new ProductCatalogServiceClient();
      prodCatClient.ClientCredentials.UserName.UserName = "su";
      prodCatClient.ClientCredentials.UserName.Password = "su123";


      PriceableItemType pit;
      prodCatClient.Open();
      prodCatClient.GetPriceableItemType(piTypeID, out pit);

      Assert.IsNotNull(pit);
      Assert.AreEqual(piTypeID.Name, pit.Name);

      return pit;

    }

    private MTList<PriceableItemType> GetPriceableItemTypes()
    {

      ProductCatalogServiceClient prodCatClient = new ProductCatalogServiceClient();
      prodCatClient.ClientCredentials.UserName.UserName = "su";
      prodCatClient.ClientCredentials.UserName.Password = "su123";
      prodCatClient.Open();
      MTList<PriceableItemType> list = new MTList<PriceableItemType>();

      prodCatClient.GetPriceableItemTypes(ref list);

      return list;
    }

    private static List<CalendarDayPeriod> GetCalendarDayPeriods()
    {
      return new List<CalendarDayPeriod>
      {
        new CalendarDayPeriod
        {
          Code = DomainModel.Enums.Core.Metratech_com_calendar.CalendarCode.Peak,
          EndTime = DateTime.Now.AddDays(1),
          StartTime = DateTime.Now
        }
      };
    }


    #endregion

  }
}