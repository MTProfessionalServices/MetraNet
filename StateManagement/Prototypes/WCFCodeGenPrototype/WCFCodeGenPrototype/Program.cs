using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.Reflection; 

namespace WCFCodeGenPrototype
{
  class Program
  {
    static void Main(string[] args)
    {
      WCFClassGeneratorTest tst = new WCFClassGeneratorTest("Test");
      Assembly codeDomAssembly = tst.GenerateWCFClass("CodeDomWCF1");

      Uri baseAddress = new Uri("http://localhost:8000/");
      Uri baseAddress2 = new Uri("http://localhost:8001/");

      foreach (Type newType in codeDomAssembly.GetTypes())
      {
        Console.WriteLine("Type: {0}", newType.Name);
      }

      Type genType = codeDomAssembly.GetType("Metratech.CodeGenWCF.CodeDomWCF1", true);
      ServiceHost host = new ServiceHost(genType, baseAddress);

      ServiceHost host2 = new ServiceHost(typeof(TestWCF1), baseAddress2);

      ServiceMetadataBehavior behave = new ServiceMetadataBehavior();
      behave.HttpGetEnabled = true;

      host.Description.Behaviors.Add(behave);
      host2.Description.Behaviors.Add(behave);

      BasicHttpBinding httpBinding = new BasicHttpBinding();
      //WSHttpBinding wsHttpBinding = new WSHttpBinding();

      Type intfType = codeDomAssembly.GetType("Metratech.CodeGenWCF.ICodeDomWCF1", true);
      host.AddServiceEndpoint(intfType, new BasicHttpBinding(), baseAddress);
      host2.AddServiceEndpoint(typeof(ITestWCF1), new BasicHttpBinding(), baseAddress2);
      //host.AddServiceEndpoint(typeof(ITestWCF1), wsHttpBinding, new Uri("http://localhost/TestWCF1"));
      
      host.Open();
      host2.Open();

      Console.WriteLine("Press 'q' to exit");
      while ((char)Console.Read() != 'q') ;
      
      host.Close();
      host2.Close();

    }
  }
}
