
// run with
// nunit-console.exe /assembly:BatchListenerTest.dll

namespace MetraTech.BatchListener.Test
{
  using System;
  using System.Collections.Generic;
  using System.Text;
  using NUnit.Framework;
  using MetraTech.Pipeline.Batch;
  using MetraTech.Interop.MTAuth;
  using MetraTech.BatchListener.Test;
  using System.Web.Services.Protocols;

   [Category("NoAutoRun")]
  [TestFixture]
  public class BatchListenerTest
  {
    #region Members
    protected int ID;
    protected string BatchName;
    protected string Namespace;
    protected string UID;
    #endregion

    [SetUp]
    public void T01InitBatchTest()
    {
      ID = -1;
      BatchName = (System.Environment.TickCount).ToString();
      Namespace = "BatchListenerTest";
      UID = "";

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = new MetraTech.BatchListener.Test.localhost.BatchObject();

      batchObj.ID = -1;
      batchObj.Name = BatchName;
      batchObj.Namespace = Namespace;
      batchObj.SourceCreationDate = System.DateTime.Now;
      batchObj.Source = "Batch Listener nUnit Test";
      batchObj.CompletedCount = 10;
      batchObj.ExpectedCount = 10;
      batchObj.SequenceNumber = BatchName;

      string id = "";

      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      listener.Url = "http://localhost/batch/listener.asmx";
      try
      {
        id = listener.Create(batchObj);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");

        //System.Console.WriteLine("Fault Code Namespace --> {0}", e.Code.Namespace);
        //System.Console.WriteLine("Fault Code --> {0}", e.Code);
        //System.Console.WriteLine("Fault Code Name --> {0}", e.Code.Name);
        //System.Console.WriteLine("SOAP Actor that threw Exception --> {0}", e.Actor);
        //System.Console.WriteLine("Code --> {0}", e.Code);
        //System.Console.WriteLine("Inner Exception is --> {0}",e.InnerException);

      }
      
      //DumpBatch(batchObj);

      Assert.AreNotEqual("", id);

      UID = id;
    }

    [Test]
    public void T02TestLoadBatchByUID()
    {
      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = null;
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      
      try
      {
        batchObj = listener.LoadByUID(UID);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      Assert.AreNotEqual(null, batchObj);

      Assert.AreEqual(BatchName, batchObj.Name);
      Assert.AreEqual(Namespace, batchObj.Namespace);

    }

    [Test]
    public void T03TestLoadByName()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = null;

      try
      {
        batchObj = listener.LoadByName(BatchName, Namespace, BatchName);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");

      }

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual(UID, batchObj.UID);
    }

    [Test]
    public void T04TestMarkAsCompleted()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Completed from BatchListener.Test", UID);
        listener.MarkAsCompleted(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("C", batchObj.Status);
    }

    [Test]
    public void T05TestMarkAsFailed()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      
      try
      {
        string comment = string.Format("Marking batch {0} as Failed from BatchListener.Test", UID);
        listener.MarkAsFailed(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("F", batchObj.Status);
    }

    [Test]
    public void T06TestMarkAsBackout()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Failed from BatchListener.Test", UID);
        listener.MarkAsFailed(UID, comment);

        comment = string.Format("Marking batch {0} as Backed Out from BatchListener.Test", UID);
        listener.MarkAsBackout(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("B", batchObj.Status);
    }

    [Test]
    public void T07TestMarkAsBackoutFailureFromActive()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Backed Out from BatchListener.Test", UID);
        listener.MarkAsBackout(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("A", batchObj.Status);
    }


    [Test]
    public void T08TestMarkAsBackoutFailureFromCompleted()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Completed from BatchListener.Test", UID);
        listener.MarkAsCompleted(UID, comment);

        comment = string.Format("Marking batch {0} as Backed Out from BatchListener.Test", UID);
        listener.MarkAsBackout(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("C", batchObj.Status);
    }

    [Test]
    public void T09TestMarkAsDismissed()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      
      try
      {
        string comment = string.Format("Marking batch {0} as Failed from BatchListener.Test", UID);
        listener.MarkAsFailed(UID, comment);

        comment = string.Format("Marking batch {0} as Backed Out from BatchListener.Test", UID);
        listener.MarkAsBackout(UID, comment);

        comment = string.Format("Marking batch {0} as Dismissed from BatchListener.Test", UID);
        listener.MarkAsDismissed(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("D", batchObj.Status);
    }

    [Test]
    public void T10TestMarkAsDismissedFailureFromActive()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Dismissed from BatchListener.Test", UID);
        listener.MarkAsDismissed(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("A", batchObj.Status);
    }

    [Test]
    public void T11TestMarkAsDismissedFailureFromFailed()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();

      try
      {
        string comment = string.Format("Marking batch {0} as Failed from BatchListener.Test", UID);
        listener.MarkAsFailed(UID, comment);

        comment = string.Format("Marking batch {0} as Dismissed from BatchListener.Test", UID);
        listener.MarkAsDismissed(UID, comment);
      }
      catch (SoapException e)
      {
        //System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
        string strippedMessage = StripSOAPException(e.Message);
        System.Console.WriteLine("-----------------------");
        System.Console.WriteLine("{0}", strippedMessage);
        System.Console.WriteLine("-----------------------");
      }

      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual("F", batchObj.Status);
    }

    [Test]
    public void T12TestUpdateMeteredCount()
    {
      MetraTech.BatchListener.Test.localhost.Listener listener = new MetraTech.BatchListener.Test.localhost.Listener();
      int meteredCount = 10;
      
      try
      {
        listener.UpdateMeteredCount(UID, meteredCount);
      }
      catch (SoapException e)
      {
        System.Console.WriteLine("Update Metered Count Failed!", e.ToString());
      }


      MetraTech.BatchListener.Test.localhost.BatchObject batchObj = listener.LoadByUID(UID);

      Assert.AreNotEqual(null, batchObj);
      Assert.AreEqual(meteredCount, batchObj.MeteredCount);
    }


    #region Helper Methods
    private string StripSOAPException(string soapexception)
    {
      int index = soapexception.IndexOf("Fusion log");
      // this is a soap exception
      if (index != -1)
      {
        int totallength = soapexception.Length;
        System.Console.WriteLine("Index --> {0}", index);
        System.Console.WriteLine("Total Length --> {0}", totallength);
        return (soapexception.Remove(index, (totallength - index)));
      }
      else
        return soapexception;
    }

    //private void DumpBatch(MetraTech.BatchListener.Test.localhost.BatchObject batchobject)
    //{
    //  System.Console.WriteLine("---------------------------------------");
    //  System.Console.WriteLine("ID = {0}", batchobject.ID);
    //  System.Console.WriteLine("UID Encoded = {0}", batchobject.UID);
    //  System.Console.WriteLine("Name = {0}", batchobject.Name);
    //  System.Console.WriteLine("Namespace = {0}", batchobject.Namespace);
    //  System.Console.WriteLine("Status = {0}", batchobject.Status);
    //  System.Console.WriteLine("Creation Date = {0}", batchobject.CreationDate);
    //  System.Console.WriteLine("Source = {0}", batchobject.Source);
    //  System.Console.WriteLine("Sequence Number = {0}", batchobject.SequenceNumber);
    //  System.Console.WriteLine("Completed Count = {0}", batchobject.CompletedCount);
    //  System.Console.WriteLine("Expected Count = {0}", batchobject.ExpectedCount);
    //  System.Console.WriteLine("Failure Count = {0}", batchobject.FailureCount);
    //  System.Console.WriteLine("Source Creation Date = {0}", batchobject.SourceCreationDate);
    //  System.Console.WriteLine("---------------------------------------");

    //  return;
    //}
    #endregion
  }
}
