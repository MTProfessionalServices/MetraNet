using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data.OleDb;

namespace MetraTech.BusinessEntity.ImportExport
{
  class WriteToCsv
  {
    public void Write()
    {
      //create a temp directory for the CSV output
      string tempFile = Path.GetTempFileName();
      File.Delete(tempFile);
      tempFile = Path.GetFileNameWithoutExtension(tempFile);
      string dir = Path.Combine(Path.GetTempPath(), tempFile);
      dir = @"c:\temp\be2\";
      Directory.CreateDirectory(dir);
      string csvFile = Path.Combine(dir, "data.csv");

      string cnStr =
          "Provider=Microsoft.Jet.OLEDB.4.0;" +
          "Extended Properties='text;HDR=Yes;FMT=Delimited;characterset=65001';" +
          "Data Source=" + dir + ";";

      using (var cn = new OleDbConnection(cnStr))
      {
        cn.Open();

        //define the file layout (a.k.a. the table)
        var cmd = new OleDbCommand(
            "CREATE TABLE data.csv (CharColumn VARCHAR(30), IntColumn INT)", cn);
        cmd.ExecuteNonQuery();

        //start pumping data
        cmd = new OleDbCommand(
            "INSERT INTO data.csv (CharColumn, IntColumn) VALUES (?, ?)", cn);

        //in a more realistic example this part
        // would be inside some type of loop

        //1st record
        cmd.Parameters.AddWithValue("?", "11111111");
        cmd.Parameters.AddWithValue("?", 1234);
        cmd.ExecuteNonQuery();

        //2nd record
        cmd.Parameters.Clear();
        cmd.Parameters.AddWithValue("?", "22222\"22222");
        cmd.Parameters.AddWithValue("?", 6789);
        cmd.ExecuteNonQuery();

        //etc...
      }

      //read the csv formatted data
      string csv = File.ReadAllText(csvFile);

      //cleanup
      //Directory.Delete(dir, true);

      Console.WriteLine("Result:");
      Console.WriteLine("--------------------");
      Console.WriteLine(csv);
      Console.ReadLine();
    }
  }


}
