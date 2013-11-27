using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;

namespace WCFCodeGenPrototype
{
  [ServiceContract]
  public interface ITestWCF1
  {
    [OperationContract]
    void TestMethod1(string txt);
  }

  class TestWCF1 : ITestWCF1
  {
    #region ITestWCF1 Members

    public void TestMethod1(string txt)
    {
      Console.WriteLine("In TestMethod1: {0}", txt);
    }

    #endregion
  }
}
