namespace MetraTech.Dataflow.Test
{
    using System;
    using System.Runtime.InteropServices;
    using System.Threading;
    using System.Data;
    using NUnit.Framework;
    using RS = MetraTech.Interop.Rowset;
    using MetraTech.Dataflow;
    using MetraTech.ActivityServices.Services.Common;
    using MetraTech.Interop.MTServerAccess;
    using MetraTech.Interop.MTAuth;

  [ComVisible(false)]
  public class TaxwarePlan
  {
    private MetraFlowPreparedProgram mProgram;
    
    private System.Data.DataSet mInputs;
    public System.Data.DataSet Inputs
    {
      get { return mInputs; }
    }

    private System.Data.DataSet mOutputs;

    public System.Data.DataSet Outputs
    {
      get { return mOutputs; }
    }

    public void Run()
    {
      mProgram.Run();
    }

    public TaxwarePlan()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "inputConvert:expr[program=\"CREATE PROCEDURE c \n"
      + "@wCompanyID NVARCHAR \n"
      + "@wShipFromCountryCode NVARCHAR\n"
      + "@wShipFromProvinceCode NVARCHAR\n"
      + "@wShipFromCity NVARCHAR\n"
      + "@wShipFromPostalCode NVARCHAR\n"
      + "@wDestinationCountryCode NVARCHAR\n"
      + "@wDestinationProvinceCode NVARCHAR\n"
      + "@wDestinationCity NVARCHAR\n"
      + "@wDestinationPostalCode NVARCHAR\n"
      + "@wPOOCountryCode NVARCHAR\n"
      + "@wPOOProvinceCode NVARCHAR\n"
      + "@wPOOCity NVARCHAR\n"
      + "@wPOOPostalCode NVARCHAR\n"
      + "@wPOACountryCode NVARCHAR\n"
      + "@wPOAProvinceCode NVARCHAR\n"
      + "@wPOACity NVARCHAR\n"
      + "@wPOAPostalCode NVARCHAR\n"
      + "@CompanyID VARCHAR OUTPUT \n"
      + "@ShipFromCountryCode VARCHAR OUTPUT\n"
      + "@ShipFromProvinceCode VARCHAR OUTPUT\n"
      + "@ShipFromCity VARCHAR OUTPUT\n"
      + "@ShipFromPostalCode VARCHAR OUTPUT\n"
      + "@DestinationCountryCode VARCHAR OUTPUT\n"
      + "@DestinationProvinceCode VARCHAR OUTPUT\n"
      + "@DestinationCity VARCHAR OUTPUT\n"
      + "@DestinationPostalCode VARCHAR OUTPUT\n"
      + "@POOCountryCode VARCHAR OUTPUT\n"
      + "@POOProvinceCode VARCHAR OUTPUT\n"
      + "@POOCity VARCHAR OUTPUT\n"
      + "@POOPostalCode VARCHAR OUTPUT\n"
      + "@POACountryCode VARCHAR OUTPUT\n"
      + "@POAProvinceCode VARCHAR OUTPUT\n"
      + "@POACity VARCHAR OUTPUT\n"
      + "@POAPostalCode VARCHAR OUTPUT\n"
      + "AS\n"
      + "SET @CompanyID = CAST(@wCompanyID AS VARCHAR) \n"
      + "SET @ShipFromCountryCode = CAST(@wShipFromCountryCode AS VARCHAR)\n"
      + "SET @ShipFromProvinceCode = CAST(@wShipFromProvinceCode AS VARCHAR)\n"
      + "SET @ShipFromCity = CAST(@wShipFromCity AS VARCHAR)\n"
      + "SET @ShipFromPostalCode = CAST(@wShipFromPostalCode AS VARCHAR)\n"
      + "SET @DestinationCountryCode = CAST(@wDestinationCountryCode AS VARCHAR)\n"
      + "SET @DestinationProvinceCode = CAST(@wDestinationProvinceCode AS VARCHAR)\n"
      + "SET @DestinationCity = CAST(@wDestinationCity AS VARCHAR)\n"
      + "SET @DestinationPostalCode = CAST(@wDestinationPostalCode AS VARCHAR)\n"
      + "SET @POOCountryCode = CAST(@wPOOCountryCode AS VARCHAR)\n"
      + "SET @POOProvinceCode = CAST(@wPOOProvinceCode AS VARCHAR)\n"
      + "SET @POOCity = CAST(@wPOOCity AS VARCHAR)\n"
      + "SET @POOPostalCode = CAST(@wPOOPostalCode AS VARCHAR)\n"
      + "SET @POACountryCode = CAST(@wPOACountryCode AS VARCHAR)\n"
      + "SET @POAProvinceCode = CAST(@wPOAProvinceCode AS VARCHAR)\n"
      + "SET @POACity = CAST(@wPOACity AS VARCHAR)\n"
      + "SET @POAPostalCode = CAST(@wPOAPostalCode AS VARCHAR)\n"
      + "\"];\n"
      + "taxware[companyID=\"CompanyID\",\n"
      + "shipFromCountryCode=\"ShipFromCountryCode\",\n"
      + "shipFromProvinceCode=\"ShipFromProvinceCode\",\n"
      + "shipFromCity=\"ShipFromCity\",\n"
      + "shipFromPostalCode=\"ShipFromPostalCode\",\n"
      + "destinationCountryCode=\"DestinationCountryCode\",\n" 
      + "destinationProvinceCode=\"DestinationProvinceCode\",\n"
      + "destinationCity=\"DestinationCity\",\n"
      + "destinationPostalCode=\"DestinationPostalCode\",\n"
      + "pooCountryCode=\"POOCountryCode\",\n" 
      + "pooProvinceCode=\"POOProvinceCode\",\n"
      + "pooCity=\"POOCity\",\n"
      + "pooPostalCode=\"POOPostalCode\",\n"
      + "poaCountryCode=\"POACountryCode\",\n"
      + "poaProvinceCode=\"POAProvinceCode\",\n"
      + "poaCity=\"POACity\",\n"
      + "poaPostalCode=\"POAPostalCode\",\n"
      + "lineItemAmount=\"TaxAmount\",\n"
      + "taxSelParm=\"TaxSelParm\",\n"
      + "calculatedAmountCountry=\"FederalTax\",\n"
      + "calculatedAmountTerritory=\"TerritoryTax\",\n"
      + "calculatedAmountProvince=\"StateTax\",\n"
      + "calculatedAmountCounty=\"CountyTax\",\n"
      + "calculatedAmountCity=\"CityTax\",\n"
      + "generalCompletionCode=\"GeneralErrorCode\",\n"
      + "generalCompletionCodeDescription=\"GeneralErrorCodeDescription"
      + "\"];\n"
      + "bProj:project[column=\"CityTax\", column=\"FederalTax\", column=\"CountyTax\", column=\"StateTax\", column=\"TerritoryTax\"];\n" 
      + "b:export_queue[queueName=\"{1}\"];\n"
      + "errorConvert:expr[program=\"CREATE PROCEDURE p \n"
      + "@GeneralErrorCode VARCHAR\n"
      + "@GeneralErrorCodeDescription VARCHAR\n"
      + "@wGeneralErrorCode NVARCHAR OUTPUT\n"
      + "@wGeneralErrorCodeDescription NVARCHAR OUTPUT\n"
      + "AS\n"
      + "SET @wGeneralErrorCode = CAST(@GeneralErrorCode AS NVARCHAR)\n"
      + "SET @wGeneralErrorCodeDescription = CAST(@GeneralErrorCodeDescription AS NVARCHAR)\"];\n"
      + "cProj:project[column=\"wGeneralErrorCode\", column=\"wGeneralErrorCodeDescription\"];\n"
      + "c:export_queue[queueName=\"{2}\"];\n"
      + "a -> inputConvert -> taxware;\n"
      + "taxware(0)-> bProj -> b;\n"
      + "taxware(1)-> errorConvert -> cProj -> c;\n";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      mInputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("wCompanyID", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOACountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOAProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOACity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOAPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("TaxAmount", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("TaxSelParm", System.Type.GetType("System.Int32")));
      mInputs.Tables.Add(table);


      // Now define the outputs.
      mOutputs = new System.Data.DataSet();
      String tableB = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableB);
      table.Columns.Add(new System.Data.DataColumn("CityTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("FederalTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("CountyTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("StateTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("TerritoryTax", System.Type.GetType("System.Int64")));
      mOutputs.Tables.Add(table);

      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("wGeneralErrorCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wGeneralErrorCodeDescription", System.Type.GetType("System.String")));
      mOutputs.Tables.Add(table);

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA, tableB, tableC);

      mProgram = new MetraTech.Dataflow.MetraFlowPreparedProgram(programText, mInputs, mOutputs);
    }

    public static void RunTest()
    {
      TaxwarePlan p = new TaxwarePlan();
      for(int j=0; j<50; j++)
      {
        p.Inputs.Tables[0].Rows.Clear();
        p.Outputs.Tables[0].Rows.Clear();
        p.Outputs.Tables[1].Rows.Clear();
        System.Data.DataRow row;
        for(int i=0; i<1; i++)
        {
          row = p.Inputs.Tables[0].NewRow();
          row["wCompanyID"] = "aaaaaa";
          row["wShipFromCountryCode"] = "US";
          row["wShipFromProvinceCode"] = "MA";
          row["wShipFromCity"] = "SALEM";
          row["wShipFromPostalCode"] = "01970";
          row["wDestinationCountryCode"] = "US";
          row["wDestinationProvinceCode"] = "CA";
          row["wDestinationCity"] = "SAN JOSE";
          row["wDestinationPostalCode"] = "95123";
          row["wPOOCountryCode"] = "US";
          row["wPOOProvinceCode"] = "CA";
          row["wPOOCity"] = "SAN JOSE";
          row["wPOOPostalCode"] = "95123";
          row["wPOACountryCode"] = "US";
          row["wPOAProvinceCode"] = "CA";
          row["wPOACity"] = "SAN JOSE";
          row["wPOAPostalCode"] = "95123";
          row["TaxAmount"] = 10000;
          row["TaxSelParm"] = 3;
          p.Inputs.Tables[0].Rows.Add(row);
        }
        p.Run(); 
        // Now the output data is populated.
        // There should be 100 rows.
        Assert.AreEqual(1, p.Outputs.Tables[0].Rows.Count);
        Assert.AreEqual(0, p.Outputs.Tables[1].Rows.Count);
      }
    }
  }
    
  //
  // To run the this test fixture:
  //
  // On older systems:
  //    nunit-console /fixture:MetraTech.Dataflow.Test.MetraFlowInteropTests /assembly:o:\debug\bin\MetraTech.Dataflow.Test.dll
  //
  // On newer systems:
  //    cd C:\Program Files (x86)\NUnit 2.5.6\bin\net-2.0
  //    nunit-console-x86.exe /fixture:MetraTech.Dataflow.Test.MetraFlowInteropTests o:\debug\bin\MetraTech.Dataflow.Test.dll
  //
    [TestFixture]
    [ComVisible(false)]
    public class MetraFlowInteropTests 
    {
    private RS.IMTSQLRowset mDummyRowset;
        private MetraTech.Interop.NameID.IMTNameID mNameID;
    //private MicrosoftOnline.Custom.Taxware.VeraZip mVeraZip;
    MetraTech.Interop.QueryAdapter.IMTQueryAdapter mQueryAdapter;



    public MetraFlowInteropTests()
    {
      // COM+ 15 second delay workaround
            mDummyRowset = new RS.MTSQLRowsetClass();
            mDummyRowset.Init("Queries\\database");
      // Name id singleton for performance
      mNameID = new MetraTech.Interop.NameID.MTNameIDClass();
//       // Keep Taxware loaded
      //mVeraZip = new MicrosoftOnline.Custom.Taxware.VeraZip();
      mQueryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
      mQueryAdapter.Init("..\\Extensions\\MSOnline\\config\\queries\\quotes");
    }

    //[Test]
    public void SimpleHashJoinTest()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "b:import_queue[queueName=\"{1}\"];\n"
      + "hj:inner_hash_join[probeKey=\"id_parent_sess\", tableKey=\"id_sess\"];\n"
      + "c:export_queue[queueName=\"{2}\"];\n"
      + "a -> hj(\"table\");\n"
      + "b -> hj(\"probe(0)\");\n"
      + "hj -> c;\n"
      ;

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("id_sess", System.Type.GetType("System.Int32")));
      inputs.Tables.Add(table);

      String tableB = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableB);
      table.Columns.Add(new System.Data.DataColumn("id_parent_sess", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("id_child_sess", System.Type.GetType("System.Int32")));
      inputs.Tables.Add(table);      

      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("id_sess", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("id_parent_sess", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("id_child_sess", System.Type.GetType("System.Int32")));
      outputs.Tables.Add(table);

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA, tableB, tableC);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      System.Data.DataRow row;
      for(int i=0; i<100; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["id_sess"] = i;
        inputs.Tables[tableA].Rows.Add(row);
      }
      for(int i=0; i<1000; i++)
      {
        row = inputs.Tables[tableB].NewRow();
        row["id_parent_sess"] = i%100;
        row["id_child_sess"] = i;
        inputs.Tables[tableB].Rows.Add(row);
      }
      p.Run(); 
      // Now the output data is populated.
      // There should be 1000 rows.
      Assert.AreEqual(1000, outputs.Tables[tableC].Rows.Count);
      for(int i=0; i<1000; i++)
      {
        Assert.AreEqual(i%100, outputs.Tables[tableC].Rows[i]["id_sess"]);        
        Assert.AreEqual(i%100, outputs.Tables[tableC].Rows[i]["id_parent_sess"]);        
        Assert.AreEqual(i, outputs.Tables[tableC].Rows[i]["id_child_sess"]);      
      }
    }

    // [Test]
    public void AllTypesTest()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      
      // This test currently takes 10 seconds.
      // David thought it would be better if it ran more quickly.

      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "access:expr[program=\"CREATE PROCEDURE p @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = @intValue * @intValue\n"
      + "SET @bigintValue = @bigintValue * @bigintValue\n"
      + "SET @decValue = @decValue * @decValue\n"
      + "SET @datetimeValue = dateadd('d',1.0,@datetimeValue) \n"
      + "SET @boolValue = NOT @boolValue\n"
      + "SET @nvarcharValue = @nvarcharValue + @nvarcharValue\n"
      + "\"];\n"
      + "b:export_queue[queueName=\"{1}\"];\n"
      + "a -> access -> b;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("intValue", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("bigintValue", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("decValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("datetimeValue", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("boolValue", System.Type.GetType("System.Boolean")));
      table.Columns.Add(new System.Data.DataColumn("nvarcharValue", System.Type.GetType("System.String")));
      inputs.Tables.Add(table);


      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("intValue", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("bigintValue", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("decValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("datetimeValue", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("boolValue", System.Type.GetType("System.Boolean")));
      table.Columns.Add(new System.Data.DataColumn("nvarcharValue", System.Type.GetType("System.String")));
      outputs.Tables.Add(table);

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA, tableC);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      System.Data.DataRow row;
      for(int i=0; i<10000; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["intValue"] = i;
        row["bigintValue"] = i;
        row["decValue"] = i;
        row["datetimeValue"] = System.DateTime.Parse("2008-06-01");
        row["boolValue"] = true;
        row["nvarcharValue"] = "mystring";
        inputs.Tables[tableA].Rows.Add(row);
      }
      p.Run(); 
      // Now the output data is populated.
      // There should be 100 rows.
      Assert.AreEqual(10000, outputs.Tables[tableC].Rows.Count);
      for(int i=0; i<10000; i++)
      {
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["intValue"]);        
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["bigintValue"]);        
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["decValue"]);      
        Assert.AreEqual(System.DateTime.Parse("2008-06-02"), outputs.Tables[tableC].Rows[i]["datetimeValue"]);      
        Assert.AreEqual(false, outputs.Tables[tableC].Rows[i]["boolValue"]);      
        Assert.AreEqual("mystringmystring", outputs.Tables[tableC].Rows[i]["nvarcharValue"]);      
      }
    }

    //[Test]
    public void NoOutputDataSet()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "access:expr[program=\"CREATE PROCEDURE p @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = @intValue * @intValue\n"
      + "SET @bigintValue = @bigintValue * @bigintValue\n"
      + "SET @decValue = @decValue * @decValue\n"
      + "SET @datetimeValue = dateadd('d',1.0,@datetimeValue) \n"
      + "SET @boolValue = NOT @boolValue\n"
      + "SET @nvarcharValue = @nvarcharValue + @nvarcharValue\n"
      + "\"];\n"
      + "b:devNull[];\n"
      + "a -> access -> b;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("intValue", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("bigintValue", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("decValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("datetimeValue", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("boolValue", System.Type.GetType("System.Boolean")));
      table.Columns.Add(new System.Data.DataColumn("nvarcharValue", System.Type.GetType("System.String")));
      inputs.Tables.Add(table);


      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      System.Data.DataRow row;
      for(int i=0; i<100; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["intValue"] = i;
        row["bigintValue"] = i;
        row["decValue"] = i;
        row["datetimeValue"] = System.DateTime.Parse("2008-06-01");
        row["boolValue"] = true;
        row["nvarcharValue"] = "mystring";
        inputs.Tables[tableA].Rows.Add(row);
      }
      p.Run(); 
    }

    //[Test]
    public void NoInputDataSet()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:generate[program=\"CREATE PROCEDURE g @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = CAST(@@RECORDCOUNT AS INTEGER)\n"
      + "SET @bigintValue = @@RECORDCOUNT\n"
      + "SET @decValue = CAST(@@RECORDCOUNT AS DECIMAL)\n"
      + "SET @datetimeValue = CAST('2008-06-01' AS DATETIME)\n"
      + "SET @boolValue = TRUE\n"
      + "SET @nvarcharValue = N'mystring'\n"
      + "\", numRecords=100];\n"
      + "access:expr[program=\"CREATE PROCEDURE p @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = @intValue * @intValue\n"
      + "SET @bigintValue = @bigintValue * @bigintValue\n"
      + "SET @decValue = @decValue * @decValue\n"
      + "SET @datetimeValue = dateadd('d',1.0,@datetimeValue) \n"
      + "SET @boolValue = NOT @boolValue\n"
      + "SET @nvarcharValue = @nvarcharValue + @nvarcharValue\n"
      + "\"];\n"
      + "b:export_queue[queueName=\"{0}\"];\n"
      + "a -> access -> b;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();

      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableC = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("intValue", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("bigintValue", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("decValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("datetimeValue", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("boolValue", System.Type.GetType("System.Boolean")));
      table.Columns.Add(new System.Data.DataColumn("nvarcharValue", System.Type.GetType("System.String")));
      outputs.Tables.Add(table);

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableC);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      p.Run(); 
      // Now the output data is populated.
      // There should be 100 rows.
      Assert.AreEqual(100, outputs.Tables[tableC].Rows.Count);
      for(int i=0; i<100; i++)
      {
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["intValue"]);        
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["bigintValue"]);        
        Assert.AreEqual(i*i, outputs.Tables[tableC].Rows[i]["decValue"]);      
        Assert.AreEqual(System.DateTime.Parse("2008-06-02"), outputs.Tables[tableC].Rows[i]["datetimeValue"]);      
        Assert.AreEqual(false, outputs.Tables[tableC].Rows[i]["boolValue"]);      
        Assert.AreEqual("mystringmystring", outputs.Tables[tableC].Rows[i]["nvarcharValue"]);      
      }
    }

    //[Test]
    public void NoInputOrOutputDataSet()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:generate[program=\"CREATE PROCEDURE g @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = CAST(@@RECORDCOUNT AS INTEGER)\n"
      + "SET @bigintValue = @@RECORDCOUNT\n"
      + "SET @decValue = CAST(@@RECORDCOUNT AS DECIMAL)\n"
      + "SET @datetimeValue = CAST('2008-06-01' AS DATETIME)\n"
      + "SET @boolValue = TRUE\n"
      + "SET @nvarcharValue = N'mystring'\n"
      + "\", numRecords=100];\n"
      + "access:expr[program=\"CREATE PROCEDURE p @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = @intValue * @intValue\n"
      + "SET @bigintValue = @bigintValue * @bigintValue\n"
      + "SET @decValue = @decValue * @decValue\n"
      + "SET @datetimeValue = dateadd('d',1.0,@datetimeValue) \n"
      + "SET @boolValue = NOT @boolValue\n"
      + "SET @nvarcharValue = @nvarcharValue + @nvarcharValue\n"
      + "\"];\n"
      + "b:devNull[];\n"
      + "a -> access -> b;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();

      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = programTextFormat;

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      p.Run(); 
    }

    //[Test]
    public void RedefinedOperator()
    {
      // We re-define an operator. We except an exception to be thrown.
      String programText = "a:generate; a:print;";

      // Define a dataset that contains table corresponding to each input that is//
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();

      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      try
      {
        p.Run(); 
      }
      catch(MetraFlowParseException e)
      {
        System.Console.WriteLine("A MetraFlow parsing error occurred: \"" + 
            e.Message + "\" Line: " + e.LineNumber + " Column: " +
            e.ColumnNumber);
      }
    }

    //[Test]
    public void PrepareWithParseError()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:badoperator[program=\"CREATE PROCEDURE g @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = CAST(@@RECORDCOUNT AS INTEGER)\n"
      + "SET @bigintValue = @@RECORDCOUNT\n"
      + "SET @decValue = CAST(@@RECORDCOUNT AS DECIMAL)\n"
      + "SET @datetimeValue = CAST('2008-06-01' AS DATETIME)\n"
      + "SET @boolValue = TRUE\n"
      + "SET @nvarcharValue = N'mystring'\n"
      + "\", numRecords=100];\n"
      + "access:expr[program=\"CREATE PROCEDURE p @intValue INTEGER @bigintValue BIGINT @decValue DECIMAL @datetimeValue DATETIME @boolValue BOOLEAN @nvarcharValue NVARCHAR\n"
      + "AS\n"
      + "SET @intValue = @intValue * @intValue\n"
      + "SET @bigintValue = @bigintValue * @bigintValue\n"
      + "SET @decValue = @decValue * @decValue\n"
      + "SET @datetimeValue = dateadd('d',1.0,@datetimeValue) \n"
      + "SET @boolValue = NOT @boolValue\n"
      + "SET @nvarcharValue = @nvarcharValue + @nvarcharValue\n"
      + "\"];\n"
      + "b:devNull[];\n"
      + "a -> access -> b;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();

      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = programTextFormat;

      try 
      {
        MetraTech.Dataflow.MetraFlowPreparedProgram p = new MetraTech.Dataflow.MetraFlowPreparedProgram(programText, inputs, outputs);
        // Should get an exception.
        Assert.AreEqual(true, false);
      }
      catch(Exception e)
      {
        System.Console.WriteLine("Received expected exception: " + e);
      }
    }

    //[Test]
    public void SelectTest()
    {
      try
      {
        System.Console.WriteLine("Select Test");
        var inputs = new System.Data.DataSet();
        var outputs = new System.Data.DataSet();

        MetraFlowProgram mfpp = new MetraFlowProgram(
            "s1: select [mode=\"parallel\", \n" +
            "            baseQuery=\"select nm_login, nm_space, id_acc  \n" +
            "            from t_account_mapper\"];\n" +
            "p1: print[];\n" +
            "d1: devNull[];\n" +
            "s1 -> p1 -> d1;"
            , inputs, outputs);

        if (mfpp == null)
        {
          System.Console.WriteLine("Null pointer");
        }
        else
        {
          mfpp.Run();
        }
        System.Console.WriteLine("Done.");
      }
      catch (Exception ex)
      {
        System.Console.WriteLine("Received expected exception: " + ex);
      }
    }

      [ComVisible(false)]
    public class SelectPreparedProgramTester
    {
      public string m_query="";

      public void SetQuery(int i)
      {
            m_query = 
              "s1: select [mode=\"parallel\", \n" +
              "            baseQuery=\"select nm_login, nm_space, id_acc  \n" +
              "                        from t_account_mapper \n" +
              "                        where id_acc = " + i + "\" ];\n" +
              "p1: print[];\n" +
              "d1: devNull[];\n" +
              "s1 -> p1 -> d1;";
      }

      public void Run()
      {
          System.Console.WriteLine("Test Run of " + m_query);

          try
          {
            var inputs = new System.Data.DataSet();
            var outputs = new System.Data.DataSet();
            MetraTech.Dataflow.MetraFlowPreparedProgram p = 
              new MetraTech.Dataflow.MetraFlowPreparedProgram(
                    m_query, inputs, outputs);

            using(p)
            {
                  if (p == null)
              {
                  System.Console.WriteLine("Null pointer");
                }
                else
                {
                  p.Run();
                }
            }
            System.Console.WriteLine("Done.");
          }
          catch (Exception ex)
          {
            System.Console.WriteLine("Received expected exception: " + ex);
          }
  
      }
    }

    //[Test]
    public void SelectPreparedProgramThreadedTest()
    {
      System.Console.WriteLine("Select Prepared Program Test Run");

      for (int i=0; i<10; i++)
      {
        SelectPreparedProgramTester runner = new SelectPreparedProgramTester();

        {
          runner.SetQuery(i);
          Thread t = new Thread(new ThreadStart(runner.Run));

          t.Start();
          t.Join();
        }

        System.Console.WriteLine("Sleeping...");
        System.Threading.Thread.Sleep(5000);
      }
    }

    [Test]
    public void MeteringSinglepointAuthTest()
    {
      System.Console.WriteLine("Metering Singlepoint Auth Test Run");

      PipelineMeteringHelperCache cache =
        new PipelineMeteringHelperCache("metratech.com/Payment");

      // Provided ability to customize the pool size.  This specifies the 
      // maximum number of instances to maintain in pool
      // Number of actual instances in use can exceed this number, 
      // but when released, they will be destroyed if the pool is 
      // already at this limit
      cache.PoolSize = 30;

      // Get instance of metering helper from cache
      PipelineMeteringHelper helper = cache.GetMeteringHelper();

      // Create instance of data row for root service definition, 
      // row is already added to internal store
      DataRow row = helper.CreateRowForServiceDef(
                                "metratech.com/Payment");

      // Allocate a value for the key column to tie parent and 
      // child records
      string paymentID = Guid.NewGuid().ToString();

      // Specify the values for all the 
      // properties of the service definition
      // Names of the columns in DataRow correspond 
      // to names of properties in the service definition
      // Data types of columns also correspond
      row["Namespace"] = DBNull.Value;
      //row["_AccountID"] = 187;
      row["_Amount"] = -123.34;
      row["Description"] = "Test Description";
      row["EventDate"] = DateTime.Now;
      row["Source"] = "MT";
      row["ReferenceID"] = null;
      row["PaymentTxnID"] = "123";

      //string number = string.Empty;

      row["PaymentMethod"] = 866;
      row["CCType"] = 929;
      row["CheckOrCardNumber"] = "2324";

      // Meter the record(s)
      helper.Meter("tom", "universe", "secret");
      
      if (helper.WasMeterSuccessful())
      {
        System.Console.WriteLine("Metering succeeded.");
      }
      else
      {
        System.Console.WriteLine("Metering failed.");
      }

      // Return the helper instance to the cache so that it can be reused.
      cache.Release(helper);
    }

    //[Test]
    public void MeteringSinglepointEnumTest()
    {
      System.Console.WriteLine("Metering Singlepoint Enum Test Run");

      PipelineMeteringHelperCache cache =
        new PipelineMeteringHelperCache("metratech.com/TranslationServDef");

      // Provided ability to customize the pool size.  This specifies the 
      // maximum number of instances to maintain in pool
      // Number of actual instances in use can exceed this number, 
      // but when released, they will be destroyed if the pool is 
      // already at this limit
      cache.PoolSize = 30;

      // Get instance of metering helper from cache
      PipelineMeteringHelper helper = cache.GetMeteringHelper();

      // Create instance of data row for root service definition, 
      // row is already added to internal store
      DataRow row = helper.CreateRowForServiceDef(
                                "metratech.com/TranslationServDef");

      // Allocate a value for the key column to tie parent and 
      // child records
      string paymentID = Guid.NewGuid().ToString();

      // Specify the values for all the 
      // properties of the service definition
      // Names of the columns in DataRow correspond 
      // to names of properties in the service definition
      // Data types of columns also correspond
      row["Account"]        = "allan";
      row["Duration"]       = 10;
      //row["Language"]       = 4890;  // French
      row["ConferenceID"]   = 100;
      row["ConferenceName"] = "MyConference";

      // Meter the record(s)
      helper.Meter();
      
      // Return the helper instance to the cache so that it can be reused.
      cache.Release(helper);
    }

    //[Test]
    public void MeteringMultipointAuthTest()
    {
      System.Console.WriteLine("Metering Multipoint Auth Test Run");
     PipelineMeteringHelperCache cache = 
          new PipelineMeteringHelperCache("metratech.com/Payment", 
                                          "PaymentID", 
                                          typeof(string), 
                                          new string[] { "metratech.com/PaymentDetails" });


      // Provided ability to customize the pool size.  This specifies the 
      // maximum number of instances to maintain in pool
      // Number of actual instances in use can exceed this number, 
      // but when released, they will be destroyed if the pool is 
      // already at this limit
      cache.PoolSize = 30;

      // Get instance of metering helper from cache
      PipelineMeteringHelper helper = cache.GetMeteringHelper();

      // Create instance of data row for root service definition, 
      // row is already added to internal store
      DataRow row = helper.CreateRowForServiceDef(
                                "metratech.com/Payment");

      // Allocate a value for the key column to tie parent and 
      // child records
      string paymentID = Guid.NewGuid().ToString();

      // Specify the values for all the 
      // properties of the service definition
      // Names of the columns in DataRow correspond 
      // to names of properties in the service definition
      // Data types of columns also correspond
      row["Namespace"] = DBNull.Value;
      row["_AccountID"] = 187;
      row["_Amount"] = -123.34;
      row["Description"] = "Test Description";
      row["EventDate"] = DateTime.Now;
      row["Source"] = "MT";
      row["ReferenceID"] = null;
      row["PaymentTxnID"] = "123";
      row["PaymentMethod"] = 866;
      row["CCType"] = 929;
      row["CheckOrCardNumber"] = "2324";
      row["PaymentID"] = paymentID;

      // Create instance of data row for child service definition, 
      // row is already added to internal store

      row = helper.CreateRowForServiceDef("metratech.com/PaymentDetails");
      row["Namespace"] = DBNull.Value;
      row["_AccountID"] = 187;
      row["InvoiceNum"] = "5555";
      row["PONumber"] = "4312";
      row["InvoiceDate"] = DateTime.Now.AddYears(-1);
      row["_Amount"] = -123.34;
      row["PaymentID"] = paymentID;

        // Get the super user data from servers.xml so that we can create an IMTSessionContext
        // to test using that for auth/auth
      IMTServerAccessDataSet sads = new MTServerAccessDataSet();
      IMTServerAccessData sad = sads.FindAndReturnObject("SuperUser");

      IMTLoginContext loginContext = new MTLoginContext();
      IMTSessionContext context = loginContext.Login(sad.UserName, "system_user", sad.Password);

      // Meter the record(s)
      helper.Meter(context);
      
      // Return the helper instance to the cache so that it can be reused.
      cache.Release(helper);
    }

    //[Test]
    public void OdbcPoolingTest()
    {
          System.Console.WriteLine("Odbc Pooling Test Run");

          // The Odbc connection pool persists as long as you
          // have a MetraFlowPreparedProgram.  If you repeatedly
          // run the same MetraFlowPreparedProgram, pooling will
          // exist across runs.  

          // If you want pooling to persist
          // across multiple MetraFlowPreparedPrograms, then 
          // create a MetraFlowPreparedProgram and hold on to it.
          // Other MetraFlowPreparedPrograms can be created and 
          // destroyed, and pooling will still persist across
          // runs.

          // This test demonstrates pooling across different
          // plans.

          // Create a MetraFlowPreparedProgram that we will
          // hold on to.  This is just an empty plan.
          var emptyIn  = new System.Data.DataSet();
          var emptyOut = new System.Data.DataSet();

          MetraTech.Dataflow.MetraFlowPreparedProgram placeHolderPlan = 
              new MetraTech.Dataflow.MetraFlowPreparedProgram(
                    "", emptyIn, emptyOut);

          OdbcPoolingTestHelper helper = new OdbcPoolingTestHelper();

          // The ODBC connection pool persists and is used 
          // across running plan one and running plan two below.
          helper.RunPlanOne();
          helper.RunPlanTwo();

          System.Console.WriteLine("Done.");
    }

      [ComVisible(false)]
    public class OdbcPoolingTestHelper
    {
      public void RunPlanOne()
      {
          string query = 
              "s1: select [mode=\"parallel\", \n" +
              "            baseQuery=\"select nm_login, nm_space, id_acc  \n" +
              "                        from t_account_mapper \n" +
              "                        where id_acc = 1\" ];\n" +
              "p1: print[];\n" +
              "d1: devNull[];\n" +
              "s1 -> p1 -> d1;";

          // Create our first plan
          var inputs  = new System.Data.DataSet();
          var outputs = new System.Data.DataSet();

          MetraTech.Dataflow.MetraFlowPreparedProgram plan1 = 
            new MetraTech.Dataflow.MetraFlowPreparedProgram(
                    query, inputs, outputs);

          System.Console.WriteLine("Running first plan.");
          plan1.Run();
      }

      public void RunPlanTwo()
      {
          string query = 
              "s1: select [mode=\"parallel\", \n" +
              "            baseQuery=\"select nm_login, nm_space, id_acc  \n" +
              "                        from t_account_mapper \n" +
              "                        where id_acc = 2\" ];\n" +
              "p1: print[];\n" +
              "d1: devNull[];\n" +
              "s1 -> p1 -> d1;";

          // Create our first plan
          var inputs  = new System.Data.DataSet();
          var outputs = new System.Data.DataSet();

          MetraTech.Dataflow.MetraFlowPreparedProgram plan2 = 
            new MetraTech.Dataflow.MetraFlowPreparedProgram(
                    query, inputs, outputs);

          System.Console.WriteLine("Running second plan.");

          plan2.Run();
      }
    }

    //[Test]
    public void InvalidScriptTest1()
    {
      try
      {
        System.Console.WriteLine("Invalid Script Test1");
        var inputs = new System.Data.DataSet();
        var outputs = new System.Data.DataSet();

        MetraFlowProgram mfpp = new MetraFlowProgram(
            "hello; g:generate [\n" +
              "program =\n" +
              "  \"CREATE PROCEDURE gen\n" +
                  "@bigintVal BIGINT\n" +
                  "@intVal INTEGER\n" +
                  "@decVal DECIMAL\n" +
                  "@doubleVal DOUBLE\n" +
                  "@strVal VARCHAR\n" +
                  "@wstrVal NVARCHAR\n" +
                "AS\n" +
                  "SET @bigintVal = @@RECORDCOUNT\n" +
                  "SET @intVal = 1\n" +
                  "SET @decVal = CAST(@@RECORDCOUNT AS DECIMAL)\n" +
                  "SET @strVal = CAST(@@RECORDCOUNT % 100000LL AS VARCHAR)\n" +
                  "SET @wstrVal = CAST(@@RECORDCOUNT % 100000LL AS NVARCHAR)\",\n" +
              "numRecords = 30];\n" +
            "st:assert_sort_order[key=\"intVal\", key=\"bigintVal\"];\n" +
            "print[numToPrint=20];\n" +
            "dn1:devNull;\n" +
            "g -> st -> print -> dn1;\n", inputs, outputs);
        if (mfpp == null)
        {
          System.Console.WriteLine("Null pointer");
        }
        else
        {
          mfpp.Run();
        }
        System.Console.WriteLine("Done.");
      }
      catch (Exception ex)
      {
        System.Console.WriteLine("Received expected exception: " + ex);
      }
    }

    //[Test]
    public void InvalidScriptTest2()
    {
      try
      {
        System.Console.WriteLine("Invalid Script Test2");

        // Define the program are running as a MetraFlowScript program.
        // This example program takes one tables in memory and prints.

        String programTextFormat = 
          "hello; a:import_queue[queueName=\"{0}\"];\n"
        + "p:print[];\n"
        + "b:export_queue[queueName=\"{1}\"];\n"
        + "a -> p -> b;\n";

        // Define a dataset that contains table corresponding to each input that is
        // to come from program state.
        System.Data.DataSet inputs = new System.Data.DataSet();
        String tableA = System.Guid.NewGuid().ToString();
        System.Data.DataTable table = new System.Data.DataTable(tableA);
        table.Columns.Add(new System.Data.DataColumn("SomeName", System.Type.GetType("System.String")));
        table.Columns.Add(new System.Data.DataColumn("SomeValue", System.Type.GetType("System.Int32")));
        inputs.Tables.Add(table);


        // Now define the outputs.
        System.Data.DataSet outputs = new System.Data.DataSet();
        String tableB = System.Guid.NewGuid().ToString();
        table = new System.Data.DataTable(tableB);
        table.Columns.Add(new System.Data.DataColumn("SomeName", System.Type.GetType("System.String")));
        table.Columns.Add(new System.Data.DataColumn("SomeValue", System.Type.GetType("System.Int32")));
        outputs.Tables.Add(table);

        // Now fill in the queue names so the MetraFlow program knows where to look.
        String programText = String.Format(programTextFormat, tableA, tableB);

        MetraTech.Dataflow.MetraFlowPreparedProgram p = new MetraFlowPreparedProgram(programText, inputs, outputs);
      }
      catch (Exception ex)
      {
        System.Console.WriteLine("Received expected exception: " + ex);
        return;
      }

      System.Console.WriteLine("Did not see expected exception.");

    }

    //[Test]
    public void SimpleInputOutputQueueTest()
    {
      try
      {
        System.Console.WriteLine("Simple Input Output Queue Test.");

        // Define the program are running as a MetraFlowScript program.
        // This example program takes one tables in memory and prints.

        String programTextFormat = 
          "a:import_queue[queueName=\"{0}\"];\n"
        + "p:print[];\n"
        + "b:export_queue[queueName=\"{1}\"];\n"
        + "a -> p -> b;\n";

        // Define a dataset that contains table corresponding to each input that is
        // to come from program state.
        System.Data.DataSet inputs = new System.Data.DataSet();
        String tableA = System.Guid.NewGuid().ToString();
        System.Data.DataTable table = new System.Data.DataTable(tableA);
        table.Columns.Add(new System.Data.DataColumn("SomeName", System.Type.GetType("System.String")));
        table.Columns.Add(new System.Data.DataColumn("SomeValue", System.Type.GetType("System.Int32")));
        inputs.Tables.Add(table);


        // Now define the outputs.
        System.Data.DataSet outputs = new System.Data.DataSet();
        String tableB = System.Guid.NewGuid().ToString();
        table = new System.Data.DataTable(tableB);
        table.Columns.Add(new System.Data.DataColumn("SomeName", System.Type.GetType("System.String")));
        table.Columns.Add(new System.Data.DataColumn("SomeValue", System.Type.GetType("System.Int32")));
        outputs.Tables.Add(table);

        // Now fill in the queue names so the MetraFlow program knows where to look.
        String programText = String.Format(programTextFormat, tableA, tableB);

        MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

        // Create input data
        System.Data.DataRow row1, row2;
        row1 = inputs.Tables[tableA].NewRow();
        row1["SomeName"] = "Hello";
        row1["SomeValue"] = 10;
        inputs.Tables[tableA].Rows.Add(row1);

        row2 = inputs.Tables[tableA].NewRow();
        row2["SomeName"] = "World";
        row2["SomeValue"] = 11;
        inputs.Tables[tableA].Rows.Add(row2);

        p.Run(); 

        System.Console.WriteLine("Output:");

        // Now the output data is populated.
        // There should be 2 rows.
        //Assert.AreEqual(1, outputs.Tables[tableB].Rows.Count);
        //Assert.AreEqual(0, outputs.Tables[tableC].Rows.Count);
        for(int i=0; i<outputs.Tables[tableB].Rows.Count; i++)
        {
          System.Console.WriteLine("SomeName={0}; SomeValue={1}",
                                  outputs.Tables[tableB].Rows[i]["SomeName"],
                                  outputs.Tables[tableB].Rows[i]["SomeValue"]);
        }

        System.Console.WriteLine("Done.");
      }
      catch (Exception ex)
      {
        System.Console.WriteLine("Received expected exception: " + ex);
      }
    }

    //[Test]
    public void TaxwareTest()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "inputConvert:expr[program=\"CREATE PROCEDURE c \n"
      + "@wCompanyID NVARCHAR \n"
      + "@wShipFromCountryCode NVARCHAR\n"
      + "@wShipFromProvinceCode NVARCHAR\n"
      + "@wShipFromCity NVARCHAR\n"
      + "@wShipFromPostalCode NVARCHAR\n"
      + "@wDestinationCountryCode NVARCHAR\n"
      + "@wDestinationProvinceCode NVARCHAR\n"
      + "@wDestinationCity NVARCHAR\n"
      + "@wDestinationPostalCode NVARCHAR\n"
      + "@wPOOCountryCode NVARCHAR\n"
      + "@wPOOProvinceCode NVARCHAR\n"
      + "@wPOOCity NVARCHAR\n"
      + "@wPOOPostalCode NVARCHAR\n"
      + "@wPOACountryCode NVARCHAR\n"
      + "@wPOAProvinceCode NVARCHAR\n"
      + "@wPOACity NVARCHAR\n"
      + "@wPOAPostalCode NVARCHAR\n"
      + "@CompanyID VARCHAR OUTPUT \n"
      + "@ShipFromCountryCode VARCHAR OUTPUT\n"
      + "@ShipFromProvinceCode VARCHAR OUTPUT\n"
      + "@ShipFromCity VARCHAR OUTPUT\n"
      + "@ShipFromPostalCode VARCHAR OUTPUT\n"
      + "@DestinationCountryCode VARCHAR OUTPUT\n"
      + "@DestinationProvinceCode VARCHAR OUTPUT\n"
      + "@DestinationCity VARCHAR OUTPUT\n"
      + "@DestinationPostalCode VARCHAR OUTPUT\n"
      + "@POOCountryCode VARCHAR OUTPUT\n"
      + "@POOProvinceCode VARCHAR OUTPUT\n"
      + "@POOCity VARCHAR OUTPUT\n"
      + "@POOPostalCode VARCHAR OUTPUT\n"
      + "@POACountryCode VARCHAR OUTPUT\n"
      + "@POAProvinceCode VARCHAR OUTPUT\n"
      + "@POACity VARCHAR OUTPUT\n"
      + "@POAPostalCode VARCHAR OUTPUT\n"
      + "AS\n"
      + "SET @CompanyID = CAST(@wCompanyID AS VARCHAR) \n"
      + "SET @ShipFromCountryCode = CAST(@wShipFromCountryCode AS VARCHAR)\n"
      + "SET @ShipFromProvinceCode = CAST(@wShipFromProvinceCode AS VARCHAR)\n"
      + "SET @ShipFromCity = CAST(@wShipFromCity AS VARCHAR)\n"
      + "SET @ShipFromPostalCode = CAST(@wShipFromPostalCode AS VARCHAR)\n"
      + "SET @DestinationCountryCode = CAST(@wDestinationCountryCode AS VARCHAR)\n"
      + "SET @DestinationProvinceCode = CAST(@wDestinationProvinceCode AS VARCHAR)\n"
      + "SET @DestinationCity = CAST(@wDestinationCity AS VARCHAR)\n"
      + "SET @DestinationPostalCode = CAST(@wDestinationPostalCode AS VARCHAR)\n"
      + "SET @POOCountryCode = CAST(@wPOOCountryCode AS VARCHAR)\n"
      + "SET @POOProvinceCode = CAST(@wPOOProvinceCode AS VARCHAR)\n"
      + "SET @POOCity = CAST(@wPOOCity AS VARCHAR)\n"
      + "SET @POOPostalCode = CAST(@wPOOPostalCode AS VARCHAR)\n"
      + "SET @POACountryCode = CAST(@wPOACountryCode AS VARCHAR)\n"
      + "SET @POAProvinceCode = CAST(@wPOAProvinceCode AS VARCHAR)\n"
      + "SET @POACity = CAST(@wPOACity AS VARCHAR)\n"
      + "SET @POAPostalCode = CAST(@wPOAPostalCode AS VARCHAR)\n"
      + "\"];\n"
      + "taxware[companyID=\"CompanyID\",\n"
      + "shipFromCountryCode=\"ShipFromCountryCode\",\n"
      + "shipFromProvinceCode=\"ShipFromProvinceCode\",\n"
      + "shipFromCity=\"ShipFromCity\",\n"
      + "shipFromPostalCode=\"ShipFromPostalCode\",\n"
      + "destinationCountryCode=\"DestinationCountryCode\",\n" 
      + "destinationProvinceCode=\"DestinationProvinceCode\",\n"
      + "destinationCity=\"DestinationCity\",\n"
      + "destinationPostalCode=\"DestinationPostalCode\",\n"
      + "pooCountryCode=\"POOCountryCode\",\n" 
      + "pooProvinceCode=\"POOProvinceCode\",\n"
      + "pooCity=\"POOCity\",\n"
      + "pooPostalCode=\"POOPostalCode\",\n"
      + "poaCountryCode=\"POACountryCode\",\n"
      + "poaProvinceCode=\"POAProvinceCode\",\n"
      + "poaCity=\"POACity\",\n"
      + "poaPostalCode=\"POAPostalCode\",\n"
      + "lineItemAmount=\"TaxAmount\",\n"
      + "taxSelParm=\"TaxSelParm\",\n"
      + "calculatedAmountCountry=\"FederalTax\",\n"
      + "calculatedAmountTerritory=\"TerritoryTax\",\n"
      + "calculatedAmountProvince=\"StateTax\",\n"
      + "calculatedAmountCounty=\"CountyTax\",\n"
      + "calculatedAmountCity=\"CityTax\",\n"
      + "generalCompletionCode=\"GeneralErrorCode\",\n"
      + "generalCompletionCodeDescription=\"GeneralErrorCodeDescription"
      + "\"];\n"
      + "bProj:project[column=\"CityTax\", column=\"FederalTax\", column=\"CountyTax\", column=\"StateTax\", column=\"TerritoryTax\"];\n" 
      + "b:export_queue[queueName=\"{1}\"];\n"
      + "errorConvert:expr[program=\"CREATE PROCEDURE p \n"
      + "@GeneralErrorCode VARCHAR\n"
      + "@GeneralErrorCodeDescription VARCHAR\n"
      + "@wGeneralErrorCode NVARCHAR OUTPUT\n"
      + "@wGeneralErrorCodeDescription NVARCHAR OUTPUT\n"
      + "AS\n"
      + "SET @wGeneralErrorCode = CAST(@GeneralErrorCode AS NVARCHAR)\n"
      + "SET @wGeneralErrorCodeDescription = CAST(@GeneralErrorCodeDescription AS NVARCHAR)\"];\n"
      + "cProj:project[column=\"wGeneralErrorCode\", column=\"wGeneralErrorCodeDescription\"];\n"
      + "c:export_queue[queueName=\"{2}\"];\n"
      + "a -> inputConvert -> taxware;\n"
      + "taxware(0)-> bProj -> b;\n"
      + "taxware(1)-> errorConvert -> cProj -> c;\n";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("wCompanyID", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wShipFromPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wDestinationPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOOPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOACountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOAProvinceCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOACity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wPOAPostalCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("TaxAmount", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("TaxSelParm", System.Type.GetType("System.Int32")));
      inputs.Tables.Add(table);


      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableB = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableB);
      table.Columns.Add(new System.Data.DataColumn("CityTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("FederalTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("CountyTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("StateTax", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("TerritoryTax", System.Type.GetType("System.Int64")));
      outputs.Tables.Add(table);

      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("wGeneralErrorCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("wGeneralErrorCodeDescription", System.Type.GetType("System.String")));
      outputs.Tables.Add(table);

      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA, tableB, tableC);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows and 1000 child rows.
      System.Data.DataRow row;
      for(int i=0; i<1; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["wCompanyID"] = "aaaaaa";
        row["wShipFromCountryCode"] = "US";
        row["wShipFromProvinceCode"] = "MA";
        row["wShipFromCity"] = "SALEM";
        row["wShipFromPostalCode"] = "01970";
        row["wDestinationCountryCode"] = "US";
        row["wDestinationProvinceCode"] = "CA";
        row["wDestinationCity"] = "SAN JOSE";
        row["wDestinationPostalCode"] = "95123";
        row["wPOOCountryCode"] = "US";
        row["wPOOProvinceCode"] = "CA";
        row["wPOOCity"] = "SAN JOSE";
        row["wPOOPostalCode"] = "95123";
        row["wPOACountryCode"] = "US";
        row["wPOAProvinceCode"] = "CA";
        row["wPOACity"] = "SAN JOSE";
        row["wPOAPostalCode"] = "95123";
        row["TaxAmount"] = 10000;
        row["TaxSelParm"] = 3;
        inputs.Tables[tableA].Rows.Add(row);
      }
      p.Run(); 
      // Now the output data is populated.
      // There should be 100 rows.
      //Assert.AreEqual(1, outputs.Tables[tableB].Rows.Count);
      //Assert.AreEqual(0, outputs.Tables[tableC].Rows.Count);
      for(int i=0; i<outputs.Tables[tableB].Rows.Count; i++)
      {
        System.Console.WriteLine("CityTax={0}; FederalTax={1}; CountyTax={2}; StateTax={3}; TerritoryTax={4}",
                                 outputs.Tables[tableB].Rows[0]["CityTax"],
                                 outputs.Tables[tableB].Rows[0]["FederalTax"],
                                 outputs.Tables[tableB].Rows[0]["CountyTax"],
                                 outputs.Tables[tableB].Rows[0]["StateTax"],
                                 outputs.Tables[tableB].Rows[0]["TerritoryTax"]);
      }
      for(int i=0; i<outputs.Tables[tableC].Rows.Count; i++)
      {
        System.Console.WriteLine("GeneralErrorCode={0}; GeneralErrorCodeDescription={1}",
                                 outputs.Tables[tableC].Rows[0]["wGeneralErrorCode"],
                                 outputs.Tables[tableC].Rows[0]["wGeneralErrorCodeDescription"]);
      }
    }

    //[Test]
    public void TaxwareMultithreadTest()
    {
      System.Threading.Thread t1 = new System.Threading.Thread(TaxwarePlan.RunTest);
      System.Threading.Thread t2 = new System.Threading.Thread(TaxwarePlan.RunTest);
      System.Threading.Thread t3 = new System.Threading.Thread(TaxwarePlan.RunTest);
      System.Threading.Thread t4 = new System.Threading.Thread(TaxwarePlan.RunTest);
      t1.Start();
      t2.Start();
      t3.Start();
      t4.Start();
      t1.Join();
      t2.Join();
      t3.Join();
      t4.Join();
    }

    //[Test]
    public void PriceableItemLoadTest()
    {
      MetraTech.Interop.MTProductCatalog.IMTProductCatalog prodCatalog = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
      MetraTech.Interop.MTProductCatalog.IMTProductOffering po = prodCatalog.GetProductOffering(432);
      while(true)
      {
        MetraTech.Interop.MTProductCatalog.IMTCollection instances = po.GetPriceableItems();
        System.Runtime.InteropServices.Marshal.ReleaseComObject(instances);
      }
    }

    //[Test]
    public void MSOnlineRecurringChargeTest()
    {
      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      // Inputs are defined at the product level.  Hopefully these inputs are all self-explanatory.
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("PurchaserID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("UnitValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("SubscriptionStart", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToState", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToZip", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("RatingCurrency", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("CountryId", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("BuyerRegistrationNumber", System.Type.GetType("System.String")));
      inputs.Tables.Add(table);

      // Load rates to be cached into a data table bound to the prepared metraflow program.
      String tableAllRateSchedules = Guid.NewGuid().ToString();
      String tableOLSTiered = Guid.NewGuid().ToString();
      String tableOLSTieredDiscount = Guid.NewGuid().ToString();
      String tableOLSUnconditionalDiscount = Guid.NewGuid().ToString();
      String tableOLSPromotionalDiscount = Guid.NewGuid().ToString();
      String tableTaxcodes = Guid.NewGuid().ToString();
      String tableCurrencyMap = Guid.NewGuid().ToString();
      using (MetraTech.DataAccess.IMTConnection conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
      {
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_ALLRATESCHEDULES__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableAllRateSchedules;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSTIERED__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSTiered;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSTIEREDDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSTieredDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSUNCONDITIONALDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSUnconditionalDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSPROMOTIONALDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSPromotionalDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_TAXCODES__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableTaxcodes;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_CURRENCYMAP__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableCurrencyMap;
        inputs.Tables.Add(table);
      }

      // Now define the outputs.

      // The first output table contains the per product pricing information.
      // Note _Amount includes discount but not taxes.
      // ProratedAmount _Amount excluding discount and tax
      // DiscountAmount is the discount
      // olstiered_UnitAmount is the per seat amount.
      //
      // TODO: Right now everything is monthly.  I don't have the logic for annual billing nor have
      // I done the (trivial) calculation to annualize.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableB = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableB);
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_Amount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_FedTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_StateTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_CountyTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_LocalTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_OtherTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("ProratedAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("DiscountAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("DiscountTypeID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("olstiered_UnitAmount", System.Type.GetType("System.Decimal")));
      outputs.Tables.Add(table);
    
      // This table contains the order level summaries of the product details.
      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_TotalAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalFedTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalStateTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalCountyTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalLocalTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalOtherTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("TotalProratedAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("TotalDiscountAmount", System.Type.GetType("System.Decimal")));
      outputs.Tables.Add(table);

      // This table contains any records that has tax calculation errors
      String tableD = Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableD);
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToState", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToZip", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ErrorCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ErrorCodeDescription", System.Type.GetType("System.String")));
      outputs.Tables.Add(table);

      System.Data.DataRow row;
      for(int i=0; i<10; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["PurchaserID"] = i;
        row["OrderID"] = i % 2;
        row["LineItemID"] = i / 2;
        row["UnitValue"] = new Decimal(20.0);
        row["_PriceableItemInstanceID"] = 350;
        row["_ProductOfferingID"] = 339;
        row["SubscriptionStart"] = DateTime.Today;
        row["ShipToCountryCode"] = "USA";
        row["ShipToState"] = "MA";
        row["ShipToZip"] = "01778";
        row["RatingCurrency"] = 283;
        row["CountryId"] = 2317;
        row["BuyerRegistrationNumber"] = "";
        inputs.Tables[tableA].Rows.Add(row);
      }

      // Grab the MetraFlow program and fill in the queue names so the MetraFlow program knows where to look.
      mQueryAdapter.SetQueryTag("__MSONLINE_ORDER_QUOTE_PREFIX__");
      mQueryAdapter.AddParam("%%INPUT1_QUEUE%%", tableA, true);
      //mQueryAdapter.AddParam("%%PARTITION%%", 0, true);
      //mQueryAdapter.AddParam("%%NUMPARTITIONS%%", 1, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_ALLRATESCHEDULES%%", tableAllRateSchedules, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSTIERED%%", tableOLSTiered, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSTIEREDDISCOUNT%%", tableOLSTieredDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSUNCONDITIONALDISCOUNT%%", tableOLSUnconditionalDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSPROMOTIONALDISCOUNT%%", tableOLSPromotionalDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_TAXCODES%%", tableTaxcodes, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_CURRENCYMAP%%", tableCurrencyMap, true);
      String programText = mQueryAdapter.GetQuery();

      mQueryAdapter.SetQueryTag("__MSONLINE_RATE_RECURRING_CHARGES__");
      programText += mQueryAdapter.GetQuery();

      mQueryAdapter.SetQueryTag("__MSONLINE_ORDER_QUOTE_SUFFIX__");
      mQueryAdapter.AddParam("%%OUTPUT1_QUEUE%%", tableB, true);
      mQueryAdapter.AddParam("%%OUTPUT2_QUEUE%%", tableC, true);
      mQueryAdapter.AddParam("%%ERROR_QUEUE%%", tableD, true);
      programText += mQueryAdapter.GetQuery();

      MetraTech.Dataflow.MetraFlowPreparedProgram plan = new MetraFlowPreparedProgram(programText, inputs, outputs);
      plan.Run();
      Assert.AreEqual(10, outputs.Tables[tableB].Rows.Count);      
      for(int i=0; i<10; i++)
      {
        Assert.AreEqual(474, outputs.Tables[tableB].Rows[i]["_PriceableItemInstanceID"]);        
        Assert.AreEqual(470, outputs.Tables[tableB].Rows[i]["_ProductOfferingID"]);        
        Assert.AreEqual(new Decimal (10489.5), outputs.Tables[tableB].Rows[i]["_Amount"]);      
        Assert.AreEqual(new Decimal (4495.5), outputs.Tables[tableB].Rows[i]["DiscountAmount"]);      
        Assert.AreEqual(new Decimal (14985), outputs.Tables[tableB].Rows[i]["ProratedAmount"]);      
        Assert.AreEqual(new Decimal (15), outputs.Tables[tableB].Rows[i]["olstiered_UnitAmount"]);      
        Assert.AreEqual(2158, outputs.Tables[tableB].Rows[i]["DiscountTypeID"]);      
      }

      Assert.AreEqual(2, outputs.Tables[tableC].Rows.Count);      
      for(int i=0; i<2; i++)
      {
        Assert.AreEqual(new Decimal (5*10489.5), outputs.Tables[tableC].Rows[i]["_TotalAmount"]);      
        Assert.AreEqual(new Decimal (5*4495.5), outputs.Tables[tableC].Rows[i]["TotalDiscountAmount"]);      
        Assert.AreEqual(new Decimal (14985*5), outputs.Tables[tableC].Rows[i]["TotalProratedAmount"]);      
      }
      plan.Close();
    }
    //[Test]
    public void MSOnlineRecurringChargeTest2()
    {
//       MetraTech.Dataflow.MetraFlowPreparedProgram.InitAllocCheck();
      for(int j=0;j<10;j++) {
      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      // Inputs are defined at the product level.  Hopefully these inputs are all self-explanatory.
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("PurchaserID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("UnitValue", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("SubscriptionStart", System.Type.GetType("System.DateTime")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToState", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToZip", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("RatingCurrency", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("CountryId", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("BuyerRegistrationNumber", System.Type.GetType("System.String")));
      inputs.Tables.Add(table);

      // Load rates to be cached into a data table bound to the prepared metraflow program.
      String tableAllRateSchedules = Guid.NewGuid().ToString();
      String tableOLSTiered = Guid.NewGuid().ToString();
      String tableOLSTieredDiscount = Guid.NewGuid().ToString();
      String tableOLSUnconditionalDiscount = Guid.NewGuid().ToString();
      String tableOLSPromotionalDiscount = Guid.NewGuid().ToString();
      String tableTaxcodes = Guid.NewGuid().ToString();
      String tableCurrencyMap = Guid.NewGuid().ToString();
      using (MetraTech.DataAccess.IMTConnection conn = MetraTech.DataAccess.ConnectionManager.CreateConnection())
      {
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_ALLRATESCHEDULES__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableAllRateSchedules;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSTIERED__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSTiered;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSTIEREDDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSTieredDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSUNCONDITIONALDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSUnconditionalDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_OLSPROMOTIONALDISCOUNT__"))
        {
          stmt.AddParam("%%PARTITION%%", 0);
          stmt.AddParam("%%NUMPARTITIONS%%", 1);
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableOLSPromotionalDiscount;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_TAXCODES__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableTaxcodes;
        inputs.Tables.Add(table);
        using (MetraTech.DataAccess.IMTAdapterStatement stmt = conn.CreateAdapterStatement("..\\Extensions\\MSOnline\\Config\\Queries\\quotes", "__LOAD_CURRENCYMAP__"))
        {
          using (MetraTech.DataAccess.IMTDataReader rdr = stmt.ExecuteReader())
          {
            table = rdr.GetDataTable();
          }
        }
        table.TableName = tableCurrencyMap;
        inputs.Tables.Add(table);
      }

      // Now define the outputs.

      // The first output table contains the per product pricing information.
      // Note _Amount includes discount but not taxes.
      // ProratedAmount _Amount excluding discount and tax
      // DiscountAmount is the discount
      // olstiered_UnitAmount is the per seat amount.
      //
      // TODO: Right now everything is monthly.  I don't have the logic for annual billing nor have
      // I done the (trivial) calculation to annualize.
      System.Data.DataSet outputs = new System.Data.DataSet();
      String tableB = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableB);
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_Amount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_FedTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_StateTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_CountyTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_LocalTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_OtherTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("ProratedAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("DiscountAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("DiscountTypeID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("olstiered_UnitAmount", System.Type.GetType("System.Decimal")));
      outputs.Tables.Add(table);
    
      // This table contains the order level summaries of the product details.
      String tableC = System.Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableC);
      table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_TotalAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalFedTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalStateTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalCountyTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalLocalTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("_TotalOtherTaxAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("TotalProratedAmount", System.Type.GetType("System.Decimal")));
      table.Columns.Add(new System.Data.DataColumn("TotalDiscountAmount", System.Type.GetType("System.Decimal")));
      outputs.Tables.Add(table);

      // This table contains any records that has tax calculation errors
      String tableD = Guid.NewGuid().ToString();
      table = new System.Data.DataTable(tableD);
      table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCountryCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToState", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToCity", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ShipToZip", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ErrorCode", System.Type.GetType("System.String")));
      table.Columns.Add(new System.Data.DataColumn("ErrorCodeDescription", System.Type.GetType("System.String")));
      outputs.Tables.Add(table);

      System.Data.DataRow row;
      for(int i=0; i<10; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["PurchaserID"] = i;
        row["OrderID"] = i % 2;
        row["LineItemID"] = i / 2;
        row["UnitValue"] = new Decimal(20.0);
        row["_PriceableItemInstanceID"] = 350;
        row["_ProductOfferingID"] = 339;
        row["SubscriptionStart"] = DateTime.Today;
        row["ShipToCountryCode"] = "USA";
        row["ShipToState"] = "MA";
        row["ShipToZip"] = "01778";
        row["RatingCurrency"] = 283;
        row["CountryId"] = 2317;
        row["BuyerRegistrationNumber"] = "";
        inputs.Tables[tableA].Rows.Add(row);
      }

      // Grab the MetraFlow program and fill in the queue names so the MetraFlow program knows where to look.
      mQueryAdapter.SetQueryTag("__MSONLINE_ORDER_QUOTE_PREFIX__");
      mQueryAdapter.AddParam("%%INPUT1_QUEUE%%", tableA, true);
      //mQueryAdapter.AddParam("%%PARTITION%%", 0, true);
      //mQueryAdapter.AddParam("%%NUMPARTITIONS%%", 1, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_ALLRATESCHEDULES%%", tableAllRateSchedules, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSTIERED%%", tableOLSTiered, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSTIEREDDISCOUNT%%", tableOLSTieredDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSUNCONDITIONALDISCOUNT%%", tableOLSUnconditionalDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_OLSPROMOTIONALDISCOUNT%%", tableOLSPromotionalDiscount, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_TAXCODES%%", tableTaxcodes, true);
      mQueryAdapter.AddParam("%%INPUT_QUEUE_CURRENCYMAP%%", tableCurrencyMap, true);
      String programText = mQueryAdapter.GetQuery();

      mQueryAdapter.SetQueryTag("__MSONLINE_RATE_RECURRING_CHARGES__");
      programText += mQueryAdapter.GetQuery();

      mQueryAdapter.SetQueryTag("__MSONLINE_ORDER_QUOTE_SUFFIX__");
      mQueryAdapter.AddParam("%%OUTPUT1_QUEUE%%", tableB, true);
      mQueryAdapter.AddParam("%%OUTPUT2_QUEUE%%", tableC, true);
      mQueryAdapter.AddParam("%%ERROR_QUEUE%%", tableD, true);
      programText += mQueryAdapter.GetQuery();

      MetraTech.Dataflow.MetraFlowPreparedProgram plan = new MetraFlowPreparedProgram(programText, inputs, outputs);
      plan.Run();
      plan.Close();
      }
//       MetraTech.Dataflow.MetraFlowPreparedProgram.DeinitAllocCheck();
    }
//     [Test]
//     public void MSOnlineRecurringChargeTest()
//     {
//       // Define a dataset that contains table corresponding to each input that is
//       // to come from program state.
//       System.Data.DataSet inputs = new System.Data.DataSet();
//       // Inputs are defined at the product level.  Hopefully these inputs are all self-explanatory.
//       String tableA = System.Guid.NewGuid().ToString();
//       System.Data.DataTable table = new System.Data.DataTable(tableA);
//       table.Columns.Add(new System.Data.DataColumn("PurchaserID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("UnitValue", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("SubscriptionStart", System.Type.GetType("System.DateTime")));
//       table.Columns.Add(new System.Data.DataColumn("ShipToCountryCode", System.Type.GetType("System.String")));
//       table.Columns.Add(new System.Data.DataColumn("ShipToState", System.Type.GetType("System.String")));
//       table.Columns.Add(new System.Data.DataColumn("ShipToZip", System.Type.GetType("System.String")));
//       inputs.Tables.Add(table);

//       // Now define the outputs.

//       // The first output table contains the per product pricing information.
//       // Note _Amount includes discount but not taxes.
//       // ProratedAmount _Amount excluding discount and tax
//       // DiscountAmount is the discount
//       // olstiered_UnitAmount is the per seat amount.
//       //
//       // TODO: Right now everything is monthly.  I don't have the logic for annual billing nor have
//       // I done the (trivial) calculation to annualize.
//       System.Data.DataSet outputs = new System.Data.DataSet();
//       String tableB = System.Guid.NewGuid().ToString();
//       table = new System.Data.DataTable(tableB);
//       table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("LineItemID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_PriceableItemInstanceID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_ProductOfferingID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_Amount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_FedTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_StateTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_CountyTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_LocalTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_OtherTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("ProratedAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("DiscountAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("olstiered_UnitAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("DiscountTypeID", System.Type.GetType("System.Int32")));
//       outputs.Tables.Add(table);
    
//       // This table contains the order level summaries of the product details.
//       String tableC = System.Guid.NewGuid().ToString();
//       table = new System.Data.DataTable(tableC);
//       table.Columns.Add(new System.Data.DataColumn("OrderID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalFedTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalStateTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalCountyTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalLocalTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalOtherTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("TotalProratedAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("TotalDiscountAmount", System.Type.GetType("System.Decimal")));
//       outputs.Tables.Add(table);

//       System.Data.DataRow row;
//       for(int i=0; i<10; i++)
//       {
//         row = inputs.Tables[tableA].NewRow();
//         row["PurchaserID"] = i;
//         row["OrderID"] = i % 2;
//         row["LineItemID"] = i / 2;
//         row["UnitValue"] = new Decimal(999.0);
//         row["_PriceableItemInstanceID"] = 474;
//         row["_ProductOfferingID"] = 470;
//         row["SubscriptionStart"] = DateTime.Today;
//         row["ShipToCountryCode"] = "USA";
//         row["ShipToState"] = "MA";
//         row["ShipToZip"] = "01778";
//         inputs.Tables[tableA].Rows.Add(row);
//       }

//       // Grab the MetraFlow program and fill in the queue names so the MetraFlow program knows where to look.
//       MetraTech.Interop.QueryAdapter.IMTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
//       queryAdapter.Init("..\\Extensions\\MSOnline\\config\\queries");
//       queryAdapter.SetQueryTag("__MSONLINE_ORDER_QUOTE__");
//       queryAdapter.AddParam("%%INPUT1_QUEUE%%", tableA, true);
//       queryAdapter.AddParam("%%OUTPUT1_QUEUE%%", tableB, true);
//       queryAdapter.AddParam("%%OUTPUT2_QUEUE%%", tableC, true);
//       queryAdapter.AddParam("%%NUMPARTITIONS%%", 1, true);
//       queryAdapter.AddParam("%%PARTITION%%", 0, true);
//       String programText = queryAdapter.GetQuery();

//       MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);
//       p.Run();

//       Assert.AreEqual(10, outputs.Tables[tableB].Rows.Count);      
//       for(int i=0; i<10; i++)
//       {
//         Assert.AreEqual(474, outputs.Tables[tableB].Rows[i]["_PriceableItemInstanceID"]);        
//         Assert.AreEqual(470, outputs.Tables[tableB].Rows[i]["_ProductOfferingID"]);        
//         Assert.AreEqual(new Decimal (10489.5), outputs.Tables[tableB].Rows[i]["_Amount"]);      
//         Assert.AreEqual(new Decimal (4495.5), outputs.Tables[tableB].Rows[i]["DiscountAmount"]);      
//         Assert.AreEqual(new Decimal (14985), outputs.Tables[tableB].Rows[i]["ProratedAmount"]);      
//         Assert.AreEqual(new Decimal (15), outputs.Tables[tableB].Rows[i]["olstiered_UnitAmount"]);      
//         Assert.AreEqual(2158, outputs.Tables[tableB].Rows[i]["DiscountTypeID"]);      
//       }

//       Assert.AreEqual(2, outputs.Tables[tableC].Rows.Count);      
//       for(int i=0; i<2; i++)
//       {
//         Assert.AreEqual(new Decimal (5*10489.5), outputs.Tables[tableC].Rows[i]["_TotalAmount"]);      
//         Assert.AreEqual(new Decimal (5*4495.5), outputs.Tables[tableC].Rows[i]["TotalDiscountAmount"]);      
//         Assert.AreEqual(new Decimal (14985*5), outputs.Tables[tableC].Rows[i]["TotalProratedAmount"]);      
//       }
//     }
//     [Test]
//     public void MSOnlineCreditCheckTest()
//     {
//       // Define a dataset that contains table corresponding to each input that is
//       // to come from program state.
//       System.Data.DataSet inputs = new System.Data.DataSet();

//       // Now define the outputs.

//       // TODO: Right now everything is monthly.  I don't have the logic for annual billing nor have
//       // I done the (trivial) calculation to annualize.
//       System.Data.DataSet outputs = new System.Data.DataSet();
//       // This table contains the order level summaries of the product details.
//       String tableC = System.Guid.NewGuid().ToString();
//       System.Data.DataTable table = new System.Data.DataTable(tableC);
//       table.Columns.Add(new System.Data.DataColumn("PurchaserID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("PaymentMethodID", System.Type.GetType("System.Int32")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalFedTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalStateTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalCountyTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalLocalTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("_TotalOtherTaxAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("TotalProratedAmount", System.Type.GetType("System.Decimal")));
//       table.Columns.Add(new System.Data.DataColumn("TotalDiscountAmount", System.Type.GetType("System.Decimal")));
//       outputs.Tables.Add(table);

//       // Grab the MetraFlow program and fill in the queue names so the MetraFlow program knows where to look.
//       MetraTech.Interop.QueryAdapter.IMTQueryAdapter queryAdapter = new MetraTech.Interop.QueryAdapter.MTQueryAdapter();
//       queryAdapter.Init("..\\Extensions\\MSOnline\\config\\queries");
//       queryAdapter.SetQueryTag("__GET_CREDIT_LIMIT_PREFIX__");
//       queryAdapter.AddParam("%%CURRENT_DATE%%", DateTime.Now, true);
//       queryAdapter.AddParam("%%ID_ANCESTOR%%", 137, true);
//       String programText = queryAdapter.GetQuery();
      
//       queryAdapter.SetQueryTag("__MSONLINE_RATE_RECURRING_CHARGES__");
//       queryAdapter.AddParam("%%NUMPARTITIONS%%", 1, true);
//       queryAdapter.AddParam("%%PARTITION%%", 0, true);
//       programText += queryAdapter.GetQuery();

//       queryAdapter.SetQueryTag("__GET_CREDIT_LIMIT_SUFFIX__");
//       queryAdapter.AddParam("%%OUTPUT_QUEUE%%", tableC, true);
//       programText += queryAdapter.GetQuery();

//       MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);
//       p.Run();

//       Assert.AreEqual(1, outputs.Tables[tableC].Rows.Count); 
//       Assert.AreEqual(137, outputs.Tables[tableC].Rows[0]["PurchaserID"]); 
//       Assert.AreEqual(405, outputs.Tables[tableC].Rows[0]["PaymentMethodID"]); 
//       System.Console.WriteLine(outputs.Tables[tableC].Rows[0]["_TotalAmount"]);
//     }
//     [Test]
    public void TestVerifyZip()
    {
      MicrosoftOnline.Custom.Taxware.VeraZip veraZip = new MicrosoftOnline.Custom.Taxware.VeraZip();
      int ret = veraZip.VerifyZip("MA", "01778", "WAYLAND");
      Assert.AreEqual(0, ret);
      ret = veraZip.VerifyZip("MA", "01778", "SUDBURY");
      Assert.AreEqual(18, ret);
      ret = veraZip.VerifyZip("MA", "01776", "SUDBURY");
      Assert.AreEqual(0, ret);
      ret = veraZip.VerifyZip("MA", "01776", "Sudbury");
      Assert.AreEqual(0, ret);
      ret = veraZip.VerifyZip("MA", "01778", "Cochituate");
      Assert.AreEqual(0, ret);
    }
    //[Test]
    public void TestExportWithExtendedCharacters()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programTextFormat = 
      "a:import_queue[queueName=\"{0}\"];\n"
      + "c:coll[mode=\"sequential\"];\n"
      + "e:export[\n"
          + "filename=\"C:\\Temp\\VODAPHONE ESPAÑA.txt\",\n"
          + "format=\"\n"
          + "myRec (\n"
          + "int32Value text_delimited_base10_int32(delimiter='|'),\n"
          + "int64Value text_delimited_base10_int64(delimiter='|', null_value=' '),\n"
          + "decValue text_delimited_base10_decimal(delimiter=crlf))\",\n"
          + "mode=\"sequential\"];\n"
          + "a -> c -> e;";

      // Define a dataset that contains table corresponding to each input that is
      // to come from program state.
      System.Data.DataSet inputs = new System.Data.DataSet();
      String tableA = System.Guid.NewGuid().ToString();
      System.Data.DataTable table = new System.Data.DataTable(tableA);
      table.Columns.Add(new System.Data.DataColumn("intValue", System.Type.GetType("System.Int32")));
      table.Columns.Add(new System.Data.DataColumn("bigintValue", System.Type.GetType("System.Int64")));
      table.Columns.Add(new System.Data.DataColumn("decValue", System.Type.GetType("System.Decimal")));
      inputs.Tables.Add(table);


      // Now define the outputs.
      System.Data.DataSet outputs = new System.Data.DataSet();          
      // Now fill in the queue names so the MetraFlow program knows where to look.
      String programText = String.Format(programTextFormat, tableA);

      MetraTech.Dataflow.MetraFlowProgram p = new MetraTech.Dataflow.MetraFlowProgram(programText, inputs, outputs);

      // Create input data: 100 parent rows 
      System.Data.DataRow row;
      for(int i=0; i<100; i++)
      {
        row = inputs.Tables[tableA].NewRow();
        row["intValue"] = i;
        row["bigintValue"] = i;
        row["decValue"] = i;
        inputs.Tables[tableA].Rows.Add(row);
      }
      p.Run(); 
    }

    //[Test]
    public void TestExportWithMetraFlowRunSequential()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programText = 
      "a:generate[program=\"CREATE PROCEDURE p\n"
          + "@int32Value INTEGER\n"
          + "@int64Value BIGINT\n"
          + "@decValue DECIMAL\n"
          + "AS\n"
          + "SET @int32Value = CAST(@@RECORDCOUNT AS INTEGER)\n"
          + "-- Stick nulls in every 100 records\n"
          + "IF @@RECORDCOUNT % 100LL <> 3LL \n"
          + "  SET @int64Value = @@RECORDCOUNT\n"
          + "SET @decValue = CAST(@@RECORDCOUNT AS DECIMAL)\",\n"
          + "numRecords = 1000];\n"
          + "c:coll[mode=\"sequential\"];\n"
          + "e:export[\n"
          + "filename=\"C:\\Temp\\VODAPHONE ESPAÑA.txt\",\n"
          + "format=\"\n"
          + "myRec (\n"
          + "int32Value text_delimited_base10_int32(delimiter='|'),\n"
          + "int64Value text_delimited_base10_int64(delimiter='|', null_value=' '),\n"
          + "decValue text_delimited_base10_decimal(delimiter=crlf))\",\n"
          + "mode=\"sequential\"];\n"
          + "a -> c -> e;";

      MetraTech.UsageServer.IMetraFlowRun mfr = new MetraTech.UsageServer.MetraFlowRun();
      int ret = mfr.Run(programText, "[MetraFlowInteropTest]", null);
      Assert.AreEqual(0, ret);
    }

    //[Test]
    public void TestExportWithMetraFlowRunParallel()
    {
      // Define the program are running as a MetraFlowScript program.
      // This example program takes two tables in memory, performs
      // a join on them and returns the result in memory.
      String programText = 
      "a:generate[program=\"CREATE PROCEDURE p\n"
          + "@int32Value INTEGER\n"
          + "@int64Value BIGINT\n"
          + "@decValue DECIMAL\n"
          + "AS\n"
          + "SET @int32Value = CAST(@@RECORDCOUNT AS INTEGER)\n"
          + "-- Stick nulls in every 100 records\n"
          + "IF @@RECORDCOUNT % 100LL <> 3LL \n"
          + "  SET @int64Value = @@RECORDCOUNT\n"
          + "SET @decValue = CAST(@@RECORDCOUNT AS DECIMAL)\",\n"
          + "numRecords = 1000];\n"
          + "p0:hashpart[key=\"int32Value\"];\n"
          + "c0:coll[];\n"
          + "c:coll[mode=\"sequential\"];\n"
          + "e:export[\n"
          + "filename=\"C:\\Temp\\VODAPHONE ESPAÑA.txt\",\n"
          + "format=\"\n"
          + "myRec (\n"
          + "int32Value text_delimited_base10_int32(delimiter='|'),\n"
          + "int64Value text_delimited_base10_int64(delimiter='|', null_value=' '),\n"
          + "decValue text_delimited_base10_decimal(delimiter=crlf))\",\n"
          + "mode=\"sequential\"];\n"
          + "a -> p0 -> c0 -> c -> e;";

      MetraTech.UsageServer.IMetraFlowConfig mfc = new MetraTech.UsageServer.MetraFlowConfig();
      mfc.Load("C:\\V6.0.2\\development\\Source\\MetraTech\\Dataflow\\Test\\MetraFlowConfig.xml");
      MetraTech.UsageServer.IMetraFlowRun mfr = new MetraTech.UsageServer.MetraFlowRun();
      int ret = mfr.Run(programText, "[MetraFlowInteropTest]", mfc);
      Assert.AreEqual(0, ret);
    }
  }
}
