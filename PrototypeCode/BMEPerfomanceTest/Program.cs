using System;
using System.Collections.Generic;
using System.Transactions;
using System.Diagnostics;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.SmokeTest.TestBME;
using _TestBMEPerfomance;
using log4net;
using MetraTech.Debug.Diagnostics;


namespace _AllDataTypeBME
{
  class Program
  {
    public static List<AllDataTypeBME> allDataTypeBMEList = new List<AllDataTypeBME>();
    private static readonly ILog logger = LogManager.GetLogger("AllDataTypeBME");
    private static List<string> logs = new List<string>();

    static void Main(string[] args)
    {
      if (args.Length == 0)
      {
        return;
      }

      long countRecords;

      if (!Int64.TryParse(args[0], out countRecords))
      {
        countRecords = 1000;
      }

      switch(args[1])
      {
        case "stopwatch":
          {
            #region Stopwatch

            Stopwatch stopWatch = new Stopwatch();

            stopWatch.Start();
            RepositoryAccess.Instance.Initialize();
            stopWatch.Stop();
            TimeSpan ts = stopWatch.Elapsed;

            var msg = string.Format("{0}. Elapsed time: {1:00}:{2:00}:{3:00}.{4:00}", "Perfomence RepositoryAccess initialize",
                                    ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10);

            logs.Add(msg);

            Console.WriteLine(msg);

            stopWatch = new Stopwatch();
            stopWatch.Start();
            SaveAllDataTypeBME(countRecords);
            stopWatch.Stop();
            ts = stopWatch.Elapsed;

            msg = string.Format("{0}. Elapsed time: {1:00}:{2:00}:{3:00}.{4:00}", "BMEs end insert one at time",
                                    ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10);
            logs.Add(msg);

            Console.WriteLine(msg);

            var standardRepository = RepositoryAccess.Instance.GetRepository();

            stopWatch = new Stopwatch();
            stopWatch.Start();
            SaveManyAllDataTypeBME(countRecords, standardRepository);
            stopWatch.Stop();
            ts = stopWatch.Elapsed;

            msg = string.Format("{0}. Elapsed time: {1:00}:{2:00}:{3:00}.{4:00}", "BMEs start insert many at time",
                                    ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10);

            logs.Add(msg);

            Console.WriteLine(msg);

            stopWatch = new Stopwatch();
            stopWatch.Start();
            DeleteAllDataTypeBMEInstances(standardRepository);
            stopWatch.Stop();
            ts = stopWatch.Elapsed;

            msg = string.Format("{0}. Elapsed time: {1:00}:{2:00}:{3:00}.{4:00}", "BMEs start delete",
                                    ts.Hours, ts.Minutes, ts.Seconds, ts.Milliseconds / 10);

            logs.Add(msg);

            Console.WriteLine(msg);

            #endregion

            break;
          }
        case "standard":
          {
            logger.Info("++Start perfomance test++");
            try
            {

            
            using (new HighResolutionTimer("Perfomance test for "+countRecords + " items"))
            {
              CheckPerfomanceRepositoryAccess("RepositoryAccess start initialize", "RepositoryAccess end initialize",
                                              "Perfomence RepositoryAccess initialize");
              Console.WriteLine(String.Format("Perfomance test for {0} items", countRecords));
              //Console.WriteLine();

              var standardRepository = RepositoryAccess.Instance.GetRepository();

              #region BMEs start insert one at time

              //var startTime = GetAndOutTime("BMEs start insert one at time");
            SaveAllDataTypeBME(countRecords);
              //DateTime endTime = GetAndOutTime("BMEs end insert one at time");
              //ShowResult("Performance BME insert one at time", startTime, endTime);

              #endregion

              #region Perfomance BMEs insert one at time by Client

              //startTime = GetAndOutTime("BMEs start insert one at time by Client");
            SaveAllDataTypeBMEByClient(countRecords);
              //endTime = GetAndOutTime("BMEs end insert one at time by Client");
              //ShowResult("Performance BME insert one at time by Client", startTime, endTime);

              #endregion

              //#region Perfomance BMEs insert many at time

              //startTime = GetAndOutTime("BMEs start insert many at time");
            //SaveManyAllDataTypeBME(countRecords, standardRepository);
              //endTime = GetAndOutTime("BMEs end insert many at time");
              //ShowResult("Performance BME insert many at time", startTime, endTime);

              //#endregion

              #region Perfomance BMEs delete

              //startTime = GetAndOutTime("BMEs start delete");
            //DeleteAllDataTypeBMEInstances(standardRepository);
              //endTime = GetAndOutTime("BMEs end delete");
              //ShowResult("Performance BME delete", startTime, endTime);

              #endregion

            }
            }
            catch (Exception ex)
            {
              logger.Error(ex.Message);              
            }
            logger.Info("++ End perfomance test++");

            break;
          }

        case "mu":
          {
            RepositoryAccess.Instance.Initialize();
      
            var standardRepository = RepositoryAccess.Instance.GetRepository();

            BulkUpdateHelper.ClearDB(standardRepository);

            BulkUpdateHelper.PrepareDataForUpdate(countRecords);

            BulkUpdateHelper.SaveDataForUpdate(standardRepository);

            BulkUpdateHelper.RunUpdateEntitiesByGuidByClient(standardRepository);

            break;
          }

        case "add":
          {
            RepositoryAccess.Instance.Initialize();

            var standardRepository = RepositoryAccess.Instance.GetRepository();

            using (new HighResolutionTimer(String.Format("Adding {0} AllDataTypeBMEs", countRecords)))
            {
              Console.WriteLine(String.Format("Adding {0} AllDataTypeBMEs", countRecords));

              
              //BulkUpdateHelper.ClearDB(standardRepository);
              BulkUpdateHelper.PrepareDataForUpdate(countRecords);
              BulkUpdateHelper.SaveDataForUpdate(standardRepository);
            }

            break;
          }
      }

      foreach (string log in logs)
      {
        logger.Debug(log);
      }

      //Console.ReadLine();
    }

    private static void CheckPerfomanceRepositoryAccess(string startMessage, string endMessage, string resultMessage)
    {
      //var startTime = GetAndOutTime(startMessage);

      using (new HighResolutionTimer("Check RepositoryAccess Initialize"))
      {
        RepositoryAccess.Instance.Initialize();
      }

      //DateTime endTime = GetAndOutTime(endMessage);

      //ShowResult(resultMessage, startTime, endTime);
    }

    private static void ShowResult(string resultMessage, DateTime startTime, DateTime endTime)
    {
      long elapsedTicks = endTime.Ticks - startTime.Ticks;
      TimeSpan elapsedSpan = new TimeSpan(elapsedTicks);
      var msg = string.Format("{0} {1:N0} days, {2} hours, {3} minutes, {4} seconds, {5} milliseconds",
        resultMessage, elapsedSpan.Days, elapsedSpan.Hours, elapsedSpan.Minutes, elapsedSpan.Seconds,
        elapsedSpan.Milliseconds);
      logs.Add(msg);
      Console.WriteLine(msg);
      Console.WriteLine();
    }

    private static DateTime GetAndOutTime(string message)
    {
      
      DateTime time = DateTime.Now;
      var msg = string.Format("{0} {1}", message, time);
      logs.Add(msg);
      Console.WriteLine(msg);
      return time;
    }

    private static void DeleteAllDataTypeBMEInstances(IStandardRepository standardRepository)
    {
      using (var scope = new TransactionScope(TransactionScopeOption.Required))
      {
        standardRepository.Delete(typeof(AllDataTypeBME).FullName);

        scope.Complete();
      }
    }

    private static void SaveAllDataTypeBME(long count)
    {
      using (new HighResolutionTimer("SaveAllDataTypeBME"))
      {
        for (int i = 0; i < count; i++)
        {
        var AllDataTypeBME = new AllDataTypeBME
                                    {
                             BooleanProperty = true,
                             DateTimeProperty = DateTime.Now,
                             DecimalProperty = 11111,
                             DoubleProperty = 22222,
                             EnumProperty = CreditCardType.None,
                             Int32Property = i,
                             Int64Property = i + 10,
                             StringProperty = "String" + i
                                    };


        AllDataTypeBME.Save();
        }
    }
    } 
    
    private static void SaveAllDataTypeBMEByClient(long count)
    {
      using (new HighResolutionTimer("SaveAllDataTypeBMEByClient"))
      {

        var createNewEntityInstanceClient = new EntityInstanceService_GetNewEntityInstance_Client
                                              {
                                                UserName = "admin",
                                                Password = "123",
                                                In_entityName = "MetraTech.SmokeTest.TestBME.AllDataTypeBME"
                                              };

        var clientSaveEntityInstance = new EntityInstanceService_SaveEntityInstance_Client
                       {
                         UserName = "admin", 
                         Password = "123"
                       };

        for (int i = 0; i < count; i++)
        {
          createNewEntityInstanceClient.Invoke();
          var BE = createNewEntityInstanceClient.Out_entityInstance;

          BE["BooleanProperty"].Value = true;
          BE["DataTimeProperty"].Value = DateTime.Now;
          BE["DecimalProperty"].Value = 11111;
          BE["DoubleProperty"].Value = 22222;
          BE["EnumProperty"].Value = CreditCardType.None;
          BE["Int32Property"].Value = i;
          BE["Int64Property"].Value = i + 10;
          BE["StringProperty"].Value = "String" + i;

          clientSaveEntityInstance.InOut_entityInstance = BE;
          clientSaveEntityInstance.Invoke();         
       }
      }

    }

    private static void SaveManyAllDataTypeBME(long count, IStandardRepository standardRepository)
    {
      using (new HighResolutionTimer("SaveManyAllDataTypeBME"))
      {
        for (int i = 0; i < count; i++)
        {
          ListAdder(i);
        }

        using (var scope = new TransactionScope(TransactionScopeOption.Required))
        {

          standardRepository.SaveInstances(ref allDataTypeBMEList);

          scope.Complete();
        }
      }
    }

    private static void ListAdder(int i)
    {
      var AllDataTypeBME = new AllDataTypeBME
      {
        BooleanProperty = true,
        DateTimeProperty = DateTime.Now,
        DecimalProperty = 11111,
        DoubleProperty = 22222,
        EnumProperty = CreditCardType.None,
        Int32Property = i,
        Int64Property = i + 10,
        StringProperty = "String" + i
      };

      allDataTypeBMEList.Add(AllDataTypeBME);
    }

  }
}
