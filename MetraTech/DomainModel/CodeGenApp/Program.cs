using System;

using MetraTech.DomainModel.CodeGenerator;

namespace MetraTech.DomainModel.CodeGenApp
{
  class Program
  {
    static int Main(string[] args)
    {
      AppDomainHelper.CleanDirectories();

      bool createEnums = false;
      bool createAccounts = false;
      bool createProductOffering = false;
      bool createProductViews = false;
      bool createServiceDefs = false;
      bool debugMode = false;
      bool printUsage = false;

      if (args.Length == 0)
      {
        createEnums = true;
        createAccounts = true;
        createProductOffering = true;
        createProductViews = true;
        createServiceDefs = true;
      }
      else
      {
        foreach (string arg in args)
        {
          switch (arg.ToLower())
          {
            case "-account":
            case "-ac":
              createAccounts = true;
              break;
            case "-enums":
            case "-en":
              createEnums = true;
              break;
            case "-productoffering":
            case "-po":
              createProductOffering = true;
              break;
            case "-productViews":
            case "-pv":
              createProductViews = true;
              break;
            case "-sd":
            case "-serviceDefinitions":
              createServiceDefs = true;
              break;
            case "-debug":
            case "-d":
              debugMode = true;
              break;
            case "-release":
            case "-r":
              debugMode = false;
              break;
            case "/?":
            case "-h":
              printUsage = true;
              break;
            default:
              Console.WriteLine(String.Format("Unrecognized argument '{0}'", arg));
              printUsage = true;
              break;
          }

          if (printUsage)
          {
            break;
          }
        }
      }

      if (printUsage)
      {
        PrintUsage();
        return 0;
      }

      // -d was the only argument
      if (args.Length == 1 && debugMode)
      {
        createEnums = true;
        createAccounts = true;
        createProductOffering = true;
        createProductViews = true;
        createServiceDefs = true;
      }

      int returnCode = 0;
      if (createEnums)
      {
        Console.WriteLine("Generating enums in assembly " + EnumGenerator.enumAssemblyName);
        if (AppDomainHelper.GenerateEnums(debugMode))
        {
          Console.WriteLine("Finished generating " + EnumGenerator.enumAssemblyName);
        }
        else
        {
          returnCode++; //return non zero value to indicate that gendm failed miserably
          Console.WriteLine("Error: building " + EnumGenerator.enumAssemblyName + ". See log for details.");
        }

        Console.WriteLine();
      }

      if (createAccounts)
      {
        Console.WriteLine("Generating account types in assembly " + AccountGenerator.generatedAccountAssemblyName);
        if (AppDomainHelper.GenerateAccounts(debugMode))
        {
          Console.WriteLine("Finished generating " + AccountGenerator.generatedAccountAssemblyName);
        }
        else
        {
          returnCode++; //return non zero value to indicate that gendm failed miserably
          Console.WriteLine("Error: building " + AccountGenerator.generatedAccountAssemblyName + ". See log for details.");
        }
      }

      if (createProductOffering)
      {
        Console.WriteLine("Generating product offering types in assembly " + ProductOfferingGenerator.productOfferingAssemblyName);
        if (AppDomainHelper.GenerateProductOfferings(debugMode))
        {
          Console.WriteLine("Finished generating " + ProductOfferingGenerator.productOfferingAssemblyName);
        }
        else
        {
          returnCode++; //return non zero value to indicate that gendm failed miserably
          Console.WriteLine("Error: building " + ProductOfferingGenerator.productOfferingAssemblyName + ". See log for details.");
        }
      }

      if (createProductViews)
      {
          Console.WriteLine("Generating product view types in assembly " + ProductViewGenerator.billingAssemblyName);
          if (AppDomainHelper.GenerateProductViews(debugMode))
          {
              Console.WriteLine("Finished generating " + ProductViewGenerator.billingAssemblyName);
          }
          else
          {
            returnCode++; //return non zero value to indicate that gendm failed miserably
            Console.WriteLine("Error: building " + ProductViewGenerator.billingAssemblyName + ". See log for details.");
          }
      }


      if (createServiceDefs)
      {
          Console.WriteLine("Generating service definition types in assembly " + ServiceDefGenerator.serviceDefAssemblyName);
          if (AppDomainHelper.GenerateServiceDefinitions(debugMode))
          {
              Console.WriteLine("Finished generating " + ServiceDefGenerator.serviceDefAssemblyName);
          }
          else
          {
            returnCode++; //return non zero value to indicate that gendm failed miserably
            Console.WriteLine("Error: building " + ServiceDefGenerator.serviceDefAssemblyName + ". See log for details.");
          }
      }

      Console.WriteLine("Generating resource assemblies");
      if (AppDomainHelper.GenerateResources())
      {
        Console.WriteLine("Finished generating resource assemblies");
      }
      else
      {
        returnCode++; //return non zero value to indicate that gendm failed miserably
        Console.WriteLine("Error: generating resource assemblies. See log for details.");
      }

      return returnCode;
    }

    private static void PrintUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("Gendm [/?] [-en] [-ac] [-po] [-pv] [-d]");
      Console.WriteLine("  /?\tPrint Usage");
      Console.WriteLine("  -en\tGenerate enums in MetraTech.DomainModel.Enums.Generated.dll.");
      Console.WriteLine("  -ac\tGenerate accounts and views in MetraTech.DomainModel.AccountTypes.Generated.dll");
      Console.WriteLine("  -po\tGenerate product offerings in MetraTech.DomainModel.ProductCatalog.Generated.dll");
      Console.WriteLine("  -pv\tGenerate product views in MetraTech.DomainModel.Billing.Generated.dll");
      Console.WriteLine("  -sd\tGenerate service definitions in MetraTech.DomainModel.ServiceDefinitions.Generated.dll");
      Console.WriteLine("  -d\tBuild assemblies in debug mode.");
      Console.WriteLine("  Gendm\tGenerate enums, accounts, product offerings and product views in release mode.");
    }
  }
}
