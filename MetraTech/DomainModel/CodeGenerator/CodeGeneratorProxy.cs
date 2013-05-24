using System;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class CodeGeneratorProxy : MarshalByRefObject
  {
    public void CleanDirectories()
    {
      BaseCodeGenerator.CleanShadowCopyDir();
    }

    public bool GenerateEnums(bool debugMode)
    {
      return EnumGenerator.GetInstance().GenerateCode(true);
    }

    public bool GenerateAccounts(bool debugMode)
    {
      return AccountGenerator.GetInstance().GenerateCode(true);
    }

    public bool GenerateProductOfferings(bool debugMode)
    {
      return ProductOfferingGenerator.GetInstance().GenerateCode(true);
    }

    public bool GenerateProductViews(bool debugMode)
    {
        return ProductViewGenerator.GetInstance().GenerateCode(true);
    }

    public bool GenerateServiceDefs(bool debugMode)
    {
        return ServiceDefGenerator.GetInstance().GenerateCode(true);
    }

    public bool GenerateResources()
    {
      return ResourceGenerator.GenerateResources();
    }
  }
}
