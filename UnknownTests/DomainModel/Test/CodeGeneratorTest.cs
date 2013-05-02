using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.Globalization;
using System.Threading;
using System.IO;
using System.Xml;

using NUnit.Framework;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
// using MetraTech.DomainModel.Enums.Generated;

using MetraTech.DomainModel.CodeGenerator;

namespace MetraTech.DomainModel.Test
{
  /// <summary>
  ///   Unit Tests for CodeGenerator.
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.DomainModel.Test.CodeGeneratorTest /assembly:O:\debug\bin\MetraTech.DomainModel.Test.dll
  /// </summary>
  [TestFixture]
  public class CodeGeneratorTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
    }
    
    [TestFixtureTearDown]
    public void TearDown()
    {
    }

    [Test]
    [Category("TestEnumGeneration")]
    public void TestEnumGeneration()
    {
      EnumGenerator.GetInstance().GenerateCode(true);
    }

    [Test]
    [Category("TestPOGeneration")]
    public void TestPOGeneration()
    {
      ProductOfferingGenerator.GetInstance().GenerateCode(true);
    }

    [Test]
    [Category("TestAccountGeneration")]
    public void TestAccountGeneration()
    {
      AccountGenerator.GetInstance().GenerateCode(true);
    }

    [Test]
    [Category("TestResourceGeneration")]
    public void TestResourceGeneration()
    {
      ResourceGenerator.GenerateResources();
    }

  }
}
