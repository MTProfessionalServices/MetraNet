using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Transactions;

using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.ImportExport
{
  class Program
  {
    static void Main(string[] args)
    {
      EntityExporter exporter = new EntityExporter();
      //exporter.ExportEntity("Core.UI.Site", true);
      //exporter.ExportEntity("SmokeTest.ImportExport.Manufacturer", @"c:\temp\be\car2", true);
      exporter.AddEntity("SmokeTest.ImportExport.Manufacturer", false);
      exporter.AddEntity("SmokeTest.ImportExport.Dealer", true);
      exporter.AddEntity("SmokeTest.ImportExport.Manufacturer", true);
      exporter.Export(@"c:\temp\be\car4");

      exporter.Clear();
      exporter.AddEntity("Core.UI.Site", true);
      exporter.Export(@"c:\temp\be\Site");

      EntityImporter importer = new EntityImporter();
      //Options.IgnoreMetadataDifferences = true;
      //importer.ImportEntity("SmokeTest.ImportExport.Manufacturer", @"c:\temp\be\car2", true);
      importer.AddEntity("SmokeTest.ImportExport.Manufacturer", true);
      importer.Import(@"c:\temp\be\car4");

      importer.Clear();
      importer.AddEntity("Core.UI.Site", true);
      importer.Import(@"c:\temp\be\Site");

      // start a transaction so that nobody deletes rows while we are exporting them
      //WriteToCsv writeToCsv = new WriteToCsv();
      //writeToCsv.Write();


    }
  }
}
