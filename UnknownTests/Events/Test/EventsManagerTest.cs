using System;
using NUnit.Framework;
using MetraTech.Test;

namespace MetraTech.Events.Test
{
  /// <summary>
  ///   Unit Tests for EventManager.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.Events.Test.EventManagerTest /assembly:MetraTech.Events.Test.dll
  /// </summary>
  [TestFixture]
  public class EventManagerTest
  {
    private EventManager _eventManagerDemo;
    private EventManager _eventManagerAdmin;
    private bool _isMessageReceived;

    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void Init()
    {
      TestLibrary.Trace("Logging in...");
      _eventManagerDemo = new EventManager("demo", "mt");
       _eventManagerAdmin = new EventManager();
      _eventManagerAdmin.NewEvents += GetNewEvents;
      TestLibrary.Trace("Logged in...");
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [TestFixtureTearDown]
    public void Dispose()
    {
    }

    [Test]
    [Category("TestEventManager")]
    public void TestEvents()
    {
      Assert.IsNotNull(_eventManagerDemo);
      Assert.IsNotNull(_eventManagerAdmin);

      TestLibrary.Trace("Sending Message...");
      InfoMessage msg = new InfoMessage("Hello", "World");
      _eventManagerDemo.Send("su", "system_user", msg);

      TestLibrary.Trace("Waiting for message...");
      int i = 0;
      while (!_isMessageReceived)
      {
        TestLibrary.Trace("Waiting for message...");
        System.Threading.Thread.Sleep(1000);
        i++;
        if (i > 30)
        {
          break;
        }
      }

      Assert.IsTrue(_isMessageReceived, "Message was not received!");
    }

    void GetNewEvents(object sender, ReceiveEventEventArg args)
    {
      TestLibrary.Trace("Got message from {0}...", args.From);
      if (args.Json == "{\"Info\":\"World\",\"Label\":\"Hello\",\"MessageId\":\"INFO_MESSAGE\",\"EventTime\":null}")
      {
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine(args.From);
        Console.WriteLine(args.Json);
        Console.ResetColor();

         _isMessageReceived = true;
      }
    }

  }
}
