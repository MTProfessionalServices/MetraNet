using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.MASv2Test.ClientProxies;
using MetraTech.DomainModel;
using System.ServiceModel;

namespace TestMASPrototype
{
  class Program
  {
    static void Main(string[] args)
    {
      SequentialTest1Client seqTest1Client = new SequentialTest1Client();
      EventTest1Client eventTest1 = new EventTest1Client();
      eventTest1.ClientCredentials.UserName.UserName = "su";
      eventTest1.ClientCredentials.UserName.Password = "su123";

      string input;
      Guid processorId = Guid.Empty;

      do
      {
        PrintMenu();

        input = Console.ReadLine();

        string inMsg, outMsg, errText;
        bool bLoop = true;
        bool condVal = false;
        int acctId;
        Dictionary<string, object> initData = null;
        
        switch (input)
        {
          case "1":
            #region Fire Sequential 1
            Console.WriteLine("Enter the InputMessage (string):");
            inMsg = Console.ReadLine();

            do
            {
              Console.WriteLine("Enter the Condition value (bool):");
              string condStr = Console.ReadLine();

              if (string.Compare(condStr, bool.TrueString, true) == 0 ||
                   string.Compare(condStr, bool.FalseString, true) == 0)
              {
                bLoop = false;

                condVal = bool.Parse(condStr);
              }
            }
            while (bLoop);

            
            if (seqTest1Client.LaunchSequentialTest1(inMsg, condVal, out outMsg, out errText))
            {
              Console.WriteLine("SequentialTest1 returned: {0}", outMsg);
            }
            else
            {
              Console.WriteLine("Error firing SequentialTest1: {0}", errText);
            }
            #endregion
            break;
          case "2":
            #region Fire Sequential 2
            Console.WriteLine("Enter the InputMessage (string):");
            inMsg = Console.ReadLine();

            do
            {
              Console.WriteLine("Enter the Condition value (bool):");
              string condStr = Console.ReadLine();

              if (string.Compare(condStr, bool.TrueString, true) == 0 ||
                   string.Compare(condStr, bool.FalseString, true) == 0)
              {
                bLoop = false;

                condVal = bool.Parse(condStr);
              }
            }
            while (bLoop);

            if (seqTest1Client.LaunchSequentialTest2(inMsg, condVal, out outMsg, out errText))
            {
              Console.WriteLine("SequentialTest2 returned: {0}", outMsg);
            }
            else
            {
              Console.WriteLine("Error firing SequentialTest2: {0}", errText);
            }
            #endregion
            break;
          case "3":
            #region Fire Event1
            Console.WriteLine("Enter the account id (int):");
            acctId = Int32.Parse(Console.ReadLine());

            Console.WriteLine("Enter the InputMessage (string):");
            inMsg = Console.ReadLine();

            do
            {
              Console.WriteLine("Enter the Condition value (bool):");
              string condStr = Console.ReadLine();

              if (string.Compare(condStr, bool.TrueString, true) == 0 ||
                   string.Compare(condStr, bool.FalseString, true) == 0)
              {
                bLoop = false;

                condVal = bool.Parse(condStr);
              }
            }
            while (bLoop);

            CoreSubscriberAccount acc = new CoreSubscriberAccount();
            acc.UserName= "Tweiler";
            
            acc.InternalView = new InternalView();
            acc.InternalView.Billable = true;
            acc.InternalView.InvoiceMethod = InvoiceMethod.None;
            acc.InternalView.Language = LanguageCode.English;
            acc.InternalView.PaymentMethod = PaymentMethod.CashOrCheck;
            acc.InternalView.SecurityQuestion = SecurityQuestion.MothersMaidenName;
            acc.InternalView.StatusReason = StatusReason.None;
            acc.InternalView.TimeZoneID = MTTimeZone.Eastern;
            acc.InternalView.UsageCycleType = UsageCycleType.Monthly;

            outMsg = "";

            string startNew;
            do
            {
              Console.WriteLine("Do you wish to start a new workflow (y/n)?");
              startNew = Console.ReadLine();
            }
            while (startNew.ToUpper() != "Y" && startNew.ToUpper() != "N");

            if (startNew.ToUpper() == "Y")
            {
              processorId = Guid.Empty;
            }

            using (System.Transactions.TransactionScope scope = new System.Transactions.TransactionScope())
            {
              if (eventTest1.LaunchEvent1(ref processorId, acctId, inMsg, condVal, acc, ref outMsg, out initData, out errText))
              {
                Console.WriteLine("Event1 returned: {0} ({1})", outMsg, errText);

                if (initData != null)
                {
                  foreach (KeyValuePair<string, object> kvp in initData)
                  {
                    Console.WriteLine("Key: {0}\tValue: {1}", kvp.Key, kvp.Value.ToString());
                  }
                }

                Console.WriteLine("ProcessorId is :{0}", processorId.ToString());
              }
              else
              {
                Console.WriteLine("Error firing Event1: {0}", errText);
              }
            }
            #endregion
            break;
          case "4":
            #region Fire Event2
            Console.WriteLine("Enter the account id (int):");
            acctId = Int32.Parse(Console.ReadLine());

            Console.WriteLine("Enter the InputMessage (string):");
            inMsg = Console.ReadLine();

            if (eventTest1.LaunchEvent2(ref processorId, acctId, inMsg, out outMsg, out initData, out errText))
            {
              Console.WriteLine("Event2 returned: {0} ({1})", outMsg, errText);

              if (initData != null)
              {
                foreach (KeyValuePair<string, object> kvp in initData)
                {
                  Console.WriteLine("Key: {0}\tValue: {1}", kvp.Key, kvp.Value.ToString());
                }
              }
            }
            else
            {
              Console.WriteLine("Error firing Event2: {0}", errText);
            }
            #endregion
            break;

          case "5":
            #region Fire BackEvent
            Console.WriteLine("Enter the account id (int):");
            acctId = Int32.Parse(Console.ReadLine());

            if (eventTest1.LaunchBackEvent(ref processorId, acctId, out initData, out errText))
            {
              Console.WriteLine("BackEvent returned: {0}", errText);

              if (initData != null)
              {
                foreach (KeyValuePair<string, object> kvp in initData)
                {
                  Console.WriteLine("Key: {0}\tValue: {1}", kvp.Key, kvp.Value.ToString());
                }
              }
            }
            else
            {
              Console.WriteLine("Error firing BackEvent: {0}", errText);
            }
            #endregion
            break;
        };
      }
      while (input.ToUpper() != "Q");

      seqTest1Client.Close();
      eventTest1.Close();
    }

    private static void PrintMenu()
    {
        Console.WriteLine("1) Call SequentialTest1.LaunchSequentialTest1");
        Console.WriteLine("2) Call SequentialTest1.LaunchSequentialTest2");
        Console.WriteLine();
        Console.WriteLine("3) Call EventTest1.LaunchEvent1");
        Console.WriteLine("4) Call EventTest1.LaunchEvent2");
        Console.WriteLine("5) Call EventTest1.LaunchBackEvent");
        Console.WriteLine();
        Console.WriteLine("Q) To Quit");
    }

    //static void Main(string[] args)
    //{
    //  string input = "", idStr = "", msg = "";
    //  TestDTEventsClient client = new TestDTEventsClient();
    //  TestDTEvents2Client client2 = new TestDTEvents2Client();
    //  int id;

    //  MyServiceHost.StartService();

    //  CMASResultCallbackDef callbackDef = new CMASResultCallbackDef();
    //  callbackDef.BindingType = "basicHttpBinding";
    //  callbackDef.Address = "http://tweilerpc/MASCallBackService";

    //  string errorMsg;

    //  Guid msgId;
    //  do
    //  {
    //    PrintMenu();

    //    input = Console.ReadLine();

    //    switch (input)
    //    {
    //      case "1":
    //        Console.WriteLine("Enter the dataId (int):");
    //        idStr = Console.ReadLine();

    //        id = Convert.ToInt32(idStr);

    //        Console.WriteLine("Enter a string to be sent to workflow:");
    //        msg = Console.ReadLine();

    //        if (client.FireEvent1(out msgId, out errorMsg, id, msg, callbackDef))
    //        {
    //          Console.WriteLine("Message {0} fired", msgId.ToString());
    //        }
    //        else
    //        {
    //          Console.WriteLine("Error firing message: {0}", errorMsg);
    //        }
    //        break;
    //      case "2":
    //        Console.WriteLine("Enter the dataId (int):");
    //        idStr = Console.ReadLine();

    //        id = Convert.ToInt32(idStr);

    //        Console.WriteLine("Enter a string to be sent to workflow:");
    //        msg = Console.ReadLine();

    //        CMASResultCallbackDef siCallback = new CMASResultCallbackDef();
    //        siCallback.Address = callbackDef.Address;
    //        siCallback.BindingType = callbackDef.BindingType;

    //        if (client.FireEvent2(out msgId, out errorMsg, id, msg, DateTime.Now, siCallback, callbackDef))
    //        {
    //          Console.WriteLine("Message {0} fired", msgId.ToString());
    //        }
    //        else
    //        {
    //          Console.WriteLine("Error firing message: {0}", errorMsg);
    //        }

    //        Console.WriteLine("Message {0} fired", msgId.ToString());
    //        break;
    //      case "3":
    //        Console.WriteLine("Enter the dataId (int):");
    //        idStr = Console.ReadLine();

    //        id = Convert.ToInt32(idStr);

    //        Console.WriteLine("Enter a string to be sent to workflow:");
    //        msg = Console.ReadLine();

    //        if (client2.FireEvent1(out msgId, out errorMsg, id, msg, callbackDef))
    //        {
    //          Console.WriteLine("Message {0} fired", msgId.ToString());
    //        }
    //        else
    //        {
    //          Console.WriteLine("Error firing message: {0}", errorMsg);
    //        }

    //        Console.WriteLine("Message {0} fired", msgId.ToString());
    //        break;
    //      case "4":
    //        Console.WriteLine("Enter the dataId (int):");
    //        idStr = Console.ReadLine();

    //        id = Convert.ToInt32(idStr);

    //        Console.WriteLine("Enter a string to be sent to workflow:");
    //        msg = Console.ReadLine();

    //        if (client2.FireEvent2(out msgId, out errorMsg, id, msg, callbackDef))
    //        {
    //          Console.WriteLine("Message {0} fired", msgId.ToString());
    //        }
    //        else
    //        {
    //          Console.WriteLine("Error firing message: {0}", errorMsg);
    //        }

    //        Console.WriteLine("Message {0} fired", msgId.ToString());
    //        break;
    //    };
    //  }
    //  while (input.ToUpper() != "Q");

    //  client.Close();

    //  MyServiceHost.StopService();
    //}

    //static void PrintMenu()
    //{
    //  Console.WriteLine("1) Call Client.FireEvent1");
    //  Console.WriteLine("2) Call Client.FireEvent2");
    //  Console.WriteLine("3) Call Client2.FireEvent1");
    //  Console.WriteLine("4) Call Client2.FireEvent2");
    //  Console.WriteLine();
    //  Console.WriteLine("Q) To Quit");
    //}
  }
}
