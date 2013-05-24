using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Persistence.Sync
{
  public class ComputedPropertySync
  {
    public void Synchronize(List<ComputedPropertyData> addComputedPropertyDataList,
                            List<ComputedPropertyData> deleteComputedPropertyDataList)
    {
      // Add
      // Categorize ComputedProperty by EntityGroupData
      Dictionary<EntityGroupData, List<ComputedPropertyData>> categorizedList =
        CategorizeComputedPropertyData(addComputedPropertyDataList);

      var codeFileNameToContentMap = new Dictionary<string, string>();

      foreach(EntityGroupData entityGroupData in categorizedList.Keys)
      {
        List<ComputedPropertyData> computedPropertyDataList = categorizedList[entityGroupData];
        var referenceAssemblies = new List<ReferenceAssembly>();

        foreach(ComputedPropertyData computedPropertyData in computedPropertyDataList)
        {
          codeFileNameToContentMap.Add(computedPropertyData.FileName, computedPropertyData.Code);
          referenceAssemblies.AddRange(computedPropertyData.GetReferenceAssemblies());
        }

        InitializeComputedPropertyDir(entityGroupData);

        BuildUtil.AddFilesAndBuild(entityGroupData.ComputedPropertyDir,
                                   codeFileNameToContentMap,
                                   referenceAssemblies);
      }

      // For each category
      // -- Create csproj, if necessary
      // -- Copy ComputedProperty folder content to temp
      // -- Generate msbuild project and build
      // -- Update csproj
      // -- If successful, copy Temp folder contents to ComputedProperty

      // Delete
    }

    public static Dictionary<EntityGroupData, List<ComputedPropertyData>> CategorizeComputedPropertyData(List<ComputedPropertyData> computedPropertyDataList)
    {
      var categorizedList = new Dictionary<EntityGroupData, List<ComputedPropertyData>>();

      foreach(ComputedPropertyData computedPropertyData in computedPropertyDataList)
      {
        EntityGroupData entityGroupData = EntityGroupData.CreateEntityGroupData(computedPropertyData.EntityName);
        List<ComputedPropertyData> list;
        categorizedList.TryGetValue(entityGroupData, out list);
        if (list == null)
        {
          list = new List<ComputedPropertyData>();
          list.Add(computedPropertyData);
          categorizedList.Add(entityGroupData, list);
        }
        else
        {
          list.Add(computedPropertyData);
        }
      }

      return categorizedList;
    }
    
    public void InitializeComputedPropertyDir(EntityGroupData entityGroupData)
    {
      if (!Directory.Exists(entityGroupData.ComputedPropertyDir))
      {
        Directory.CreateDirectory(entityGroupData.ComputedPropertyDir);
      }

      // Create csproj, if it doesn't exist
      string csProjFile = Name.GetComputedPropertyCsProj(entityGroupData.ExtensionName,
                                                         entityGroupData.EntityGroupName);
      if (!File.Exists(csProjFile))
      {
        string nameSpace = Name.GetComputedPropertyNamespace(entityGroupData.ExtensionName,
                                                             entityGroupData.EntityGroupName);

        string csProjContent = 
          BuildUtil.CreateCsProjFile(nameSpace, 
                                        GetReferenceAssemblies(entityGroupData.ExtensionName, 
                                                               entityGroupData.EntityGroupName));

        File.WriteAllText(Path.Combine(entityGroupData.ComputedPropertyDir, csProjFile), csProjContent);
      }
    }

    private static List<ReferenceAssembly> GetReferenceAssemblies(string extensionName, string entityGroupName)
    {
      return new List<ReferenceAssembly>()
               {
                 new ReferenceAssembly("MetraTech.Basic.dll"),
                 new ReferenceAssembly("MetraTech.BusinessEntity.Core.dll"),
                 new ReferenceAssembly("MetraTech.BusinessEntity.DataAccess.dll"),
                 new ReferenceAssembly("MetraTech.DomainModel.Enums.Generated.dll"),
                 new ReferenceAssembly("NHibernate.dll"),
                 new ReferenceAssembly(Name.GetEntityAssemblyName(extensionName, entityGroupName) + ".dll"),
                 new ReferenceAssembly(Name.GetInterfaceAssemblyNameFromExtension(extensionName))
               };
    }
  }
}
