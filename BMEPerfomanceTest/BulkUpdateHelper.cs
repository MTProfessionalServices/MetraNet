using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.SmokeTest.TestBME;
using MetraTech.Debug.Diagnostics;

namespace _TestBMEPerfomance
{
  public static class BulkUpdateHelper
  {
    private static List<AllDataTypeBME> _initialData;
    private static string _bmeName = "MetraTech.SmokeTest.TestBME.AllDataTypeBME";

    public static void ClearDB(IStandardRepository standardRepository)
    {
      using (var scope = new TransactionScope(TransactionScopeOption.Required))
      {
        var mtList = new MTList<EntityInstance>();
        mtList = standardRepository.LoadEntityInstances("MetraTech.SmokeTest.TestBME.AllDataTypeBME", mtList);
        foreach(var item in mtList.Items)
          standardRepository.DeleteEntityInstance(item);
        scope.Complete();
      }
    }

    public static List<AllDataTypeBME> PrepareDataForUpdate(long numItems)
    {
      var res = new List<AllDataTypeBME>();
      for(var i=0;i<numItems;i++)
      {
        res.Add(new AllDataTypeBME
                  {
                    Id = new Guid(),
                    //BinaryProperty = new byte[10],
                    BooleanProperty = true,
                    DateTimeProperty = DateTime.Now,
                    DecimalProperty = 11111,
                    DoubleProperty = 22222,
                    //GuidProperty = new Guid(),
                    EnumProperty = CreditCardType.None,
                    Int32Property = i,
                    StringProperty = "String" + i
                  }
               );
      }
      _initialData = res;
      return res;
    }

    public static void SaveDataForUpdate(IStandardRepository standardRepository)
    {
      const int maxBulk = 100;
      
        for (var i = 0; i < _initialData.Count; i += maxBulk)
        {
          using (new HighResolutionTimer("Insert of " + (i+maxBulk) + " items"))
          {
          using (var scope = new TransactionScope(TransactionScopeOption.Required))
          {
            var allDataTypeBmes = _initialData.Skip(i).Take(maxBulk).ToList();
            standardRepository.SaveInstances(ref allDataTypeBmes);
            scope.Complete();
          }
        }
        }
        
    }

    public static EntityInstance SetPropertyValues(IStandardRepository standardRepository)
    {
      var res = standardRepository.LoadEntityInstances(_bmeName, new MTList<EntityInstance>()).Items.First();

      res.SetValue(5000,"Int32Property");

      return res;
    }

    public static Guid[] GetGuids(List<AllDataTypeBME> items)
    {
      return items.Select(bme => bme.Id).ToArray();
    }


    public static void RunUpdateEntitiesByGuid(IEntityInstanceService entityInstanceService, IStandardRepository standardRepository)
    {
      using (var scope = new TransactionScope(TransactionScopeOption.Required))
      {
        entityInstanceService.UpdateEntitiesByGuids(new List<string>() { "Int32Property" }, SetPropertyValues(standardRepository), GetGuids(_initialData));
        scope.Complete();
      } 
    }

    public static void RunUpdateEntitiesByGuidByClient(IStandardRepository standardRepository)
    {
      try
      {
        var updateEntitiesByGuidClient = new EntityInstanceService_UpdateEntitiesByGuids_Client
                                           {
                                             UserName = "admin",
                                             Password = "Admin123",
                                             In_beInstance = SetPropertyValues(standardRepository),
                                             In_ids = GetGuids(_initialData),
                                             In_propertiesToUpdate = new List<string>() {"Int32Property"}
                                           };

        updateEntitiesByGuidClient.Invoke();
      }
      catch (Exception ex)
      {
        {}
        throw;
      }

     
    }

  }
}