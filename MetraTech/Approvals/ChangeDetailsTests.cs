using Microsoft.VisualStudio.TestTools.UnitTesting;

//using MetraTech.Security;
//using MetraTech.DomainModel.Common;
//using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTAuth;
using System;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using System.Runtime.Serialization;
using System.Collections.Generic;
//using MetraTech.DomainModel.BaseTypes;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Approvals.Test.ChangeDetailsTest /assembly:O:\debug\bin\MetraTech.Approvals.Test.dll
//
namespace MetraTech.Approvals.Test
{
  [TestClass]
  public class ChangeDetailsTest
  {

    private Logger m_Logger = new Logger("[ApprovalManagementTest]");

    #region tests

    [TestMethod]
    [TestCategory("SetChangeDetails")]
    public void SetChangeDetails()
    {
      ChangeDetailsHelper changeDetails = new ChangeDetailsHelper();
      changeDetails["FirstName"] = "Rudi";
      changeDetails["LastName"] = "Perkins";

      string changeDetailsBuffer = changeDetails.ToBuffer();

      ChangeDetailsHelper incommingChangeDetails = new ChangeDetailsHelper();
      incommingChangeDetails.FromBuffer(changeDetailsBuffer);

      string lastName = (string)changeDetails["LastName"];
      Assert.AreEqual(lastName, "Perkins");

    }

        [TestMethod]
    [TestCategory("VerifyWeCanSerializeAccount")]
    public void VerifyWeCanSerializeAccount()
    {
      //Create the change
      int accountIdToUpdate = 123;

      //MetraTech.DomainModel.BaseTypes.Account account = new MetraTech.DomainModel.BaseTypes.Account();
      MetraTech.DomainModel.AccountTypes.IndependentAccount accountIn = new IndependentAccount();

      accountIn._AccountID = accountIdToUpdate;

      //Change something on the account
      ContactView shipToContactView;
      shipToContactView = (ContactView)MetraTech.DomainModel.BaseTypes.View.CreateView(@"metratech.com/contact");
      shipToContactView.ContactType = ContactType.Ship_To;
      shipToContactView.FirstName = "Rudi";
      shipToContactView.LastName = "Perkins";
      shipToContactView.Address1 = MetraTime.Now.ToString();

      accountIn.AddView(shipToContactView, "LDAP");

      //Now serialize it

      ChangeDetailsHelper changeDetailsOut = new ChangeDetailsHelper();
      changeDetailsOut["Account"] = accountIn;

      string buffer = changeDetailsOut.ToXml();

      //Attempt #2: Set Known Types Array
      //List<Type> knownTypes = new List<Type> { typeof(List<string>) };
      //DataContractSerializer serializer = new DataContractSerializer(typeof(Dictionary<string, object>), knownTypes);

      List<Type> knownTypes = new List<Type> { typeof(MetraTech.DomainModel.AccountTypes.IndependentAccount) };

      Dictionary<string, object> detailsIn = new Dictionary<string, object>();

      var serializer = new DataContractSerializer(detailsIn.GetType(), knownTypes);
      //var serializer = new DataContractSerializer(detailsIn.GetType());
      using (var backing = new System.IO.StringReader(buffer))
      {
        using (var reader = new System.Xml.XmlTextReader(backing))
        {
          detailsIn = serializer.ReadObject(reader) as Dictionary<string, object>;
        }
      }

      MetraTech.DomainModel.AccountTypes.IndependentAccount accountOut;

      //ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      //changeDetailsIn.FromXml(buffer);

      object o = detailsIn["Account"];
      accountOut = (MetraTech.DomainModel.AccountTypes.IndependentAccount)o;

      Assert.AreEqual(accountIn._AccountID, accountOut._AccountID);



      ////Attempt #3: Serialize Only Our MetraTech Object
      ////List<Type> knownTypes = new List<Type> { typeof(List<string>) };
      ////DataContractSerializer serializer = new DataContractSerializer(typeof(Dictionary<string, object>), knownTypes);


      // object o = null;

      // var serializerIn = new DataContractSerializer(accountIn.GetType());
      // using (var backing = new System.IO.StringWriter())
      // {
      //   using (var writer = new System.Xml.XmlTextWriter(backing))
      //   {
      //     serializerIn.WriteObject(writer, accountIn);
      //     buffer = backing.ToString();
      //   }
      // }

      ////var serializer = new DataContractSerializer(detailsIn.GetType(), knownTypes);
      //var serializer = new DataContractSerializer(typeof(object));
      //using (var backing = new System.IO.StringReader(buffer))
      //{
      //  using (var reader = new System.Xml.XmlTextReader(backing))
      //  {
      //    o = serializer.ReadObject(reader);
      //  }
      //}

      

      ////ChangeDetailsHelper changeDetailsIn = new ChangeDetailsHelper();
      ////changeDetailsIn.FromXml(buffer);

      //MetraTech.DomainModel.AccountTypes.IndependentAccount accountOut = (MetraTech.DomainModel.AccountTypes.IndependentAccount) o;

      //Assert.AreEqual(accountIn._AccountID, accountOut._AccountID);
    }
  }
    #endregion
}