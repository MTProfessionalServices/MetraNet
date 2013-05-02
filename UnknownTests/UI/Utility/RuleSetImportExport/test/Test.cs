using System.Runtime.InteropServices;
using System.Diagnostics;
using System;
using ProdCat = MetraTech.Interop.MTProductCatalog;
using MTEnum = MetraTech.Interop.MTEnumConfig;

namespace MetraTech.UI.Utility.RulesetImportExport.Test
{
	using System;
	using System.Collections;

	using NUnit.Framework;
	using MetraTech.Test;

  using MTRULESETLib = MetraTech.Interop.MTRuleSet;
  using MetraTech.UI.Utility;

  [TestFixture]
  //[Ignore("test DevTest only")]
  public class SmokeTest
  {

    [Test]
    [Ignore("ignore")]
    public void TestLoadingRuleset()
    {
      //This test doesn't test import/export to Excel but just makes sure we can read a ruleset from
      //an xml file before we run other tests
      TestLibrary.Trace("TestLoadingRuleset");
      MTRULESETLib.MTRuleSet srcRuleset = new MTRULESETLib.MTRuleSet();
      
      srcRuleset.Read(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\metratech.com_intlrate.xml");

      MTRULESETLib.MTRule rule = (MTRULESETLib.MTRule)srcRuleset[1];
      foreach (MTRULESETLib.MTAssignmentAction action in rule.Actions)
      {
        string temp= action.PropertyName + "=" + action.PropertyValue;
      }
      foreach (MTRULESETLib.MTSimpleCondition condition in rule.Conditions)
      {
        string temp= condition.PropertyName + " " + condition.Test + " " + condition.Value;
      }

    }

    [Test]
    [Ignore("ignore")]
    public void TestSimpleRulesetImport()
    {
      TestLibrary.Trace("TestSimpleRulesetImport");
      ArrayList userErrors;

      string sOutputFilePath = @"c:\test.xml";

      //IMPORT 
      MTRULESETLib.IMTRuleSet dstRuleset = (MTRULESETLib.IMTRuleSet) new MTRULESETLib.MTRuleSet();
      RuleSetImportExport importRuleset = new RuleSetImportExport();
      userErrors = importRuleset.ImportFromExcelFile(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\excel-reservationapplic.xml",ref dstRuleset);
      
      if (userErrors.Count>0)
      {
        DumpErrorList(ref userErrors);
        WaitForUserInput();
      }

      int iOutputCount = dstRuleset.Count;
      Console.WriteLine(string.Format("Imported {0} rules",iOutputCount));
      DumpRuleSet("TestSimpleRulesetImport", ref dstRuleset);
      WaitForUserInput();

      RuleSetImportExport exportRuleset = new RuleSetImportExport();
      //ArrayList userErrors = exportRuleset.ExportToExcelFile("metratech.com/rateconn", srcRuleset);
      exportRuleset.ExportToExcelFile("metratech.com/reservationapplic", dstRuleset,sOutputFilePath);

      OpenFileInExcel(sOutputFilePath);

    }

    [Test]
    [Ignore("ignore")]
    public void TestSimpleRulesetExport()
    {
      TestLibrary.Trace("TestSimpleRulesetExport");
      
      string sOutputFilePath = @"c:\test.xml";

      //Get a ruleset to export
      MTRULESETLib.MTRuleSet srcRuleset = new MTRULESETLib.MTRuleSet();
      //srcRuleset.Read(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\metratech.com_intlrate.xml");
      srcRuleset.Read(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\metratech.com_reservationapplic.xml");

      RuleSetImportExport exportRuleset = new RuleSetImportExport();
      //exportRuleset.ExportToExcelFile("metratech.com/intlrate", srcRuleset, sOutputFilePath);
      exportRuleset.ExportToExcelFile("metratech.com/reservationapplic", srcRuleset, sOutputFilePath);

      OpenFileInExcel(sOutputFilePath);
    }

    [Test]
    [Ignore("ignore")]
    public void TestSimpleRulesetExportPerformance()
    {
      TestLibrary.Trace("TestSimpleRulesetExportPerformance");
      
      string sOutputFilePath = @"c:\test.xml";

      //Get a ruleset to export
      MTRULESETLib.MTRuleSet srcRuleset = new MTRULESETLib.MTRuleSet();
      //srcRuleset.Read(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\metratech.com_intlrate.xml");
      srcRuleset.Read(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\metratech.com_songsession_10000.xml");

      RuleSetImportExport exportRuleset = new RuleSetImportExport();
      //exportRuleset.ExportToExcelFile("metratech.com/intlrate", srcRuleset, sOutputFilePath);
 
      DateTime d1 = DateTime.Now;
      exportRuleset.ExportToExcelFile("metratech.com/songsession", srcRuleset, sOutputFilePath);
      DateTime d2 = DateTime.Now;

      long delta = (long)((TimeSpan)(d2 - d1)).TotalSeconds;
      decimal tps = (srcRuleset.Count)/delta;
      Console.WriteLine(string.Format("Exported {0} rules in {1} seconds ({2} tps)",srcRuleset.Count, delta,tps));
      WaitForUserInput();

      OpenFileInExcel(sOutputFilePath);
    }

    [Test]
    //[Ignore("ignore")]
    public void TestSimpleRulesetImportPerformance()
    {
      TestLibrary.Trace("TestSimpleRulesetImportPerformance");
      ArrayList userErrors;

      //To better simulate performance, we will create an enumconfig object and save it to simulate an already loaded
      //singleton
      MTEnum.IEnumConfig mtEnumConfig = new MTEnum.EnumConfigClass();

      //IMPORT 
      MTRULESETLib.IMTRuleSet dstRuleset = (MTRULESETLib.IMTRuleSet) new MTRULESETLib.MTRuleSet();
      RuleSetImportExport importRuleset = new RuleSetImportExport();

      DateTime d1 = DateTime.Now;
      userErrors = importRuleset.ImportFromExcelFile(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\excel-songsession_10000.xml",ref dstRuleset);
      DateTime d2 = DateTime.Now;

      long delta = (long)((TimeSpan)(d2 - d1)).TotalSeconds;
      decimal tps = 0.0M;
      if (delta>0) { tps = (dstRuleset.Count)/delta;}
      Console.WriteLine(string.Format("Imported {0} rules in {1} seconds ({2} tps)",dstRuleset.Count, delta,tps));
      WaitForUserInput();     

      if (userErrors.Count>0)
      {
        DumpErrorList(ref userErrors);
        WaitForUserInput();
      }

    }

    [Test]
    [Ignore("ignore")]
    public void TestRulesetImportOfBadValues()
    {
      TestLibrary.Trace("TestSimpleRulesetImport");
      ArrayList userErrors;

      //IMPORT 
      MTRULESETLib.IMTRuleSet dstRuleset = (MTRULESETLib.IMTRuleSet) new MTRULESETLib.MTRuleSet();
      RuleSetImportExport importRuleset = new RuleSetImportExport();
      userErrors = importRuleset.ImportFromExcelFile(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\excel-intlrate-badvaluetypes.xml",ref dstRuleset);
      
      if (userErrors.Count>0)
      {
        DumpErrorList(ref userErrors);
        WaitForUserInput();
      }

      int iOutputCount = dstRuleset.Count;
      Console.WriteLine(string.Format("Imported {0} rules",iOutputCount));
      WaitForUserInput();
    }

    [Test]
    [Ignore("ignore")]
    public void TestRulesetImportOfAllOperators()
    {
      TestLibrary.Trace("TestRulesetImportOfAllOperators");
      ArrayList userErrors;

      //IMPORT 
      MTRULESETLib.IMTRuleSet dstRuleset = (MTRULESETLib.IMTRuleSet) new MTRULESETLib.MTRuleSet();
      RuleSetImportExport importRuleset = new RuleSetImportExport();
      userErrors = importRuleset.ImportFromExcelFile(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\excel-percentdiscount-alloperators.xml",ref dstRuleset);
      
      if (userErrors.Count>0)
      {
        DumpErrorList(ref userErrors);
        WaitForUserInput();
      }

      int iOutputCount = dstRuleset.Count;
      Console.WriteLine(string.Format("Imported {0} rules",iOutputCount));
      DumpRuleSet("TestRulesetImportOfAllOperators", ref dstRuleset);
      WaitForUserInput();
    }

    [Test]
    [Ignore("ignore")]
    public void TestRulesetImportOfCellIndexes()
    {
      TestLibrary.Trace("TestRulesetImportOfAllOperators");
      ArrayList userErrors;

      //IMPORT 
      MTRULESETLib.IMTRuleSet dstRuleset = (MTRULESETLib.IMTRuleSet) new MTRULESETLib.MTRuleSet();
      RuleSetImportExport importRuleset = new RuleSetImportExport();
      userErrors = importRuleset.ImportFromExcelFile(@"T:\Development\UI\Unit Tests\UI COM Objects\RulesetImportExport\data\excel-percentdiscount-cellindexes.xml",ref dstRuleset);
      
      if (userErrors.Count>0)
      {
        DumpErrorList(ref userErrors);
        WaitForUserInput();
      }

      int iOutputCount = dstRuleset.Count;
      Console.WriteLine(string.Format("Imported {0} rules",iOutputCount));
      DumpRuleSet("TestRulesetImportOfAllOperators", ref dstRuleset);
      WaitForUserInput();
    }

    [Test]
    [Ignore("ignore")]
    public void TestDumpAll()
    {
      RuleSetImportExport importRuleset = new RuleSetImportExport();

      //importRuleset.TestDumpAll();

    }

    public void OpenFileInExcel(string sExcelFilePath)
    {
      //Open file in Excel
      Process player = new Process();

      player.StartInfo.FileName   = @"c:\Program Files\Microsoft Office\OFFICE11\EXCEL.EXE";
      player.StartInfo.Arguments = sExcelFilePath;
      player.Start();
    }

    public void WaitForUserInput()
    {
      Console.WriteLine("Press <ENTER> to continue");
      Console.ReadLine();
    }

    public void DumpErrorList(ref ArrayList userErrors)
    {
      Console.WriteLine("ERROR: There are {0} messages", userErrors.Count);
      foreach(string sMsg in userErrors)
      {
        Console.WriteLine("    {0}",sMsg);
      }
    }

    public void DumpRuleSet(string sText,ref MTRULESETLib.IMTRuleSet srcRuleset)
    {
      Console.WriteLine ("DumpRuleSet:{0}",sText);
      Console.WriteLine ("Rules:");
      for(int iRule=1;iRule<=srcRuleset.Count;iRule++)
      {
        string sTemp = "";
        MTRULESETLib.MTRule rule = (MTRULESETLib.MTRule)srcRuleset[iRule];
        sTemp +="Conditions:";
        foreach (MTRULESETLib.MTSimpleCondition condition in rule.Conditions)
        {
          sTemp+= "[" + condition.PropertyName + " test(" + condition.Test + ") value(" + condition.Value + ")] ";
        }
        sTemp +="Actions:";
        foreach (MTRULESETLib.MTAssignmentAction action in rule.Actions)
        {
          sTemp+= "[" + action.PropertyName + "=" + action.PropertyValue+ "] ";
        }
        Console.WriteLine ("\tRule[{0}]: {1}",iRule,sTemp);
      }
    }
  }
}
