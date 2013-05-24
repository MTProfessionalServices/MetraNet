using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

using MetraTech.Interop.MTHooklib;
using MetraTech;
using MetraTech.DomainModel.CodeGenerator;

namespace MetraTech.DomainModel.Hooks
{
  [Guid("2568F3D7-5AA8-4fea-BB68-7DD125005697")]
  public interface IDomainModelHook : MetraTech.Interop.MTHooklib.IMTHook
  {
  }

  [Guid("20B0B6D8-8F7D-4ee5-B7A4-7592FB314D06")]
  [ClassInterface(ClassInterfaceType.None)]
  public class DomainModelHook : IDomainModelHook
  {
    public DomainModelHook()
    {
      logger = new Logger("Logging\\DomainModel", "[DomainModelHook]");
    }

    public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
    {
      try
      {
        // Clean temp directories
        AppDomainHelper.CleanDirectories();

        logger.LogDebug(String.Format("Generating enums in assembly '{0}'", EnumGenerator.enumAssemblyName));
        if (AppDomainHelper.GenerateEnums(true))
        {
          logger.LogDebug(String.Format("Successfully generated '{0}'", EnumGenerator.enumAssemblyName));
        }
        else
        {
          logger.LogDebug(String.Format("Unable to generate assembly '{0}'", EnumGenerator.enumAssemblyName));
        }
       
   
        logger.LogDebug(String.Format("Generating account types in assembly '{0}'", AccountGenerator.generatedAccountAssemblyName));
        if (AppDomainHelper.GenerateAccounts(true))
        {
          logger.LogDebug(String.Format("Successfully generated '{0}'", AccountGenerator.generatedAccountAssemblyName));
        }
        else
        {
          logger.LogDebug(String.Format("Unable to generate assembly '{0}'", AccountGenerator.generatedAccountAssemblyName));
        }

        logger.LogDebug(String.Format("Generating product offering types in assembly '{0}'", ProductOfferingGenerator.productOfferingAssemblyName));
        if (AppDomainHelper.GenerateProductOfferings(true))
        {
          logger.LogDebug(String.Format("Successfully generated '{0}'", ProductOfferingGenerator.productOfferingAssemblyName));
        }
        else
        {
          logger.LogDebug(String.Format("Unable to generate assembly '{0}'", ProductOfferingGenerator.productOfferingAssemblyName));
        }

        logger.LogDebug(String.Format("Generating product view types in assembly '{0}'", ProductViewGenerator.billingAssemblyName));
        if (AppDomainHelper.GenerateProductViews(true))
        {
            logger.LogDebug(String.Format("Successfully generated '{0}'", ProductViewGenerator.billingAssemblyName));
        }
        else
        {
            logger.LogDebug(String.Format("Unable to generate assembly '{0}'", ProductViewGenerator.billingAssemblyName));
        }

        logger.LogDebug(String.Format("Generating service definition types in assembly '{0}'", ServiceDefGenerator.serviceDefAssemblyName));
        if (AppDomainHelper.GenerateServiceDefinitions(true))
        {
            logger.LogDebug(String.Format("Successfully generated '{0}'", ServiceDefGenerator.serviceDefAssemblyName));
        }
        else
        {
            logger.LogDebug(String.Format("Unable to generate assembly '{0}'", ServiceDefGenerator.serviceDefAssemblyName));
        }

        logger.LogDebug(String.Format("Generating resources")); 
        if (AppDomainHelper.GenerateResources())
        {
          logger.LogDebug(String.Format("Successfully generated resource assemblies"));
        }
        else 
        {
          logger.LogDebug(String.Format("Unable to generated resource assemblies"));
        }
      }
      catch (System.Exception e)
      {
        logger.LogException("DomainModelHook failed with the exception: ", e);
        throw e;
      }
    }


    #region Data
    private MetraTech.Logger logger;
    #endregion
  }
}
