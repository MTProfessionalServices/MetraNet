using System;
using System.Collections.Generic;
using COMAdmin; //Interop assembly - import from comadmin.dll


namespace COMPlusSecurityConfiguration
{
  

  class MetraTechComPlusObjects
  {
    public static string[] MTComObjects =
    {
      "IIS Out of Process Pooled Application",
      "IIS-{Default Web Site//Root//AccountHierarchy}",
      "IIS-{Default Web Site//Root//Batch}",
      "IIS-{Default Web Site//Root//BillingRerun}",
      "IIS-{Default Web Site//Root//Desktop}",
      "IIS-{Default Web Site//Root//ImageHandler}",
      "IIS-{Default Web Site//Root//mam}",
      "IIS-{Default Web Site//Root//mcm}",
      "IIS-{Default Web Site//Root//MetraCareHelp}",
      "IIS-{Default Web Site//Root//MetraCare}",
      "IIS-{Default Web Site//Root//MetraNet}",
      "IIS-{Default Web Site//Root//mom}",
      "IIS-{Default Web Site//Root//mpm}",
      "IIS-{Default Web Site//Root//mpte}",
      "IIS-{Default Web Site//Root//msix}",
      "IIS-{Default Web Site//Root//PaymentSvr}",
      "IIS-{Default Web Site//Root//Res}",
      "IIS-{Default Web Site//Root//SampleSite}",
      "IIS-{Default Web Site//Root//Suggest}",
      "IIS-{Default Web Site//Root//validation}",
    };

    public static bool IsAMetraTechCOMPlusObject(String name)
    {
      foreach (String mtObj in MTComObjects)
      {
        if (name == mtObj)
        {
//          Console.WriteLine("Full Match");
          return true;
        }
        else if (name.Contains("IIS"))
        {
//          Console.WriteLine("Partial Match");
          return true;
        }
      }
      return false;
    }

    public static void Main()
    {
      COMAdminCatalog ca = new COMAdminCatalogClass();
      COMAdminCatalogCollection cacc = (COMAdminCatalogCollection)ca.GetCollection("Applications");
      cacc.Populate();
      foreach (COMAdminCatalogObject cac in cacc)
      {
        if (IsAMetraTechCOMPlusObject(cac.Name.ToString()))
        {
          Console.WriteLine("Setting "  + cac.Name + " to use NetworkServicde Identity");
          //Console.WriteLine("\nLocated a MetraTech COM+ Object");
          //Console.WriteLine(cac.get_Value("Identity"));
          cac.set_Value("Identity", "NT AUTHORITY\\NetworkService");
          //cac.set_Value("Password", "AdminPwd");
          cacc.SaveChanges();
        }
      }
    }
  }
}
