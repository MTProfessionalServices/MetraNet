using System;
using System.EnterpriseServices;
using System.Xml;
using System.Xml.Serialization;
using MetraTech;
using MetraTech.DataAccess;

namespace ExecuteQueries
{
	/// <summary>
	/// Utility which allows to execute queries in xml file that complies with Queries.xml MT format.
	/// Currenct InstallUtilTest requires MTDBObjects.xml file which contains all the query tags for
	/// execution. ExecuteQueries doesn't.
	/// </summary>
	
  [Transaction(TransactionOption.Required)]
  class ExecuteQueries : ServicedComponent
  {
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
    [STAThread]
    static void Main(string[] args)
    {
      ICommandLineParser parser = new CommandLineParser(args);
      parser.Parse();
      if(!parser.OptionExists("file"))
      {
        PrintUsage();
        return;
      }

      string filePath = parser.GetStringOption("file");
      System.Console.Out.WriteLine(filePath);
      System.Console.Out.WriteLine(System.String.Format("Executing Queries from <{0}>", filePath));

      try
      {
        XmlDocument doc = new XmlDocument( );
        doc.Load(filePath);
        XmlNodeList queries = doc.GetElementsByTagName("query");
        using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
          foreach(XmlNode query in queries)
          {
            //string tag = query.ChildNodes.
            string tag = query.SelectSingleNode("query_tag").InnerText;
            System.Console.Out.WriteLine(System.String.Format("Executing Tag <{0}>", tag));
            string querystr = query.SelectSingleNode("query_string").InnerText;
            IMTStatement stmt = conn.CreateStatement(querystr);
            stmt.ExecuteNonQuery();
          }
        }
      }
      catch(Exception ex)
      {
        System.Console.Out.WriteLine(ex.Message);
        return;
      }
    }
    static void PrintUsage()
    {
      System.Console.Out.WriteLine("Usage: ExecuteQueries [options]");
      System.Console.Out.WriteLine("Options:");
      System.Console.Out.WriteLine("file - Specify full path of the file to execute");
      System.Console.Out.WriteLine("Example: ");
      System.Console.Out.WriteLine("Example: ExecuteQueries /file:s:\\config\\Queries\\DBInstall\\Adjustments\\Queries.xml");

    }
	}
}
