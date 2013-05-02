using System;
using System.Collections.Generic;
using NUnit.Framework;

using MetraTech.Core.Services.ClientProxies;
using MetraTech.Security;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.TicketingServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class TicketingServiceTest
  {
    [Test]
    [Category("GetTicket")]
    public void GetTicket()
    {
      string userName = "su";
      string nameSpace = "system_user";

      TicketingService_GetTicket_Client ticketClient = new TicketingService_GetTicket_Client();
      ticketClient.In_userName = userName;
      ticketClient.In_nameSpace = nameSpace;

      ticketClient.UserName = "su";
      ticketClient.Password = "su123";

      ticketClient.Invoke();

      string ticket = ticketClient.Out_ticket;

      Auth auth = new Auth();
      auth.Initialize(userName, nameSpace);
      object sessionContext = null;
      LoginStatus loginStatus = auth.LoginWithTicket(ticket, ref sessionContext);

      Assert.AreEqual(LoginStatus.OK, loginStatus);

    }
  }
}
