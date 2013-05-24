using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using MetraTech.Basic.Config;
using Microsoft.Build.BuildEngine;

namespace MetraTech.Basic
{
  #pragma warning disable 618
  public static class ExtensionsMethods
  {
    #region String Extensions
    public static string ReplaceMtRmp(this string input)
    {
      if (String.IsNullOrEmpty(input))
      {
        return input;
      }

      string returnValue = input.ToLower().Replace("$(mtrmp)", SystemConfig.GetRmpDir().ToLower());
      return returnValue.ToLower().Replace("$(mtrmpbin)", SystemConfig.GetRmpBinDir().ToLower());
    }

    public static string LowerCaseFirst(this string input)
    {
      if (String.IsNullOrEmpty(input))
      {
        return input;
      }

      Char[] letters = input.ToCharArray();
      letters[0] = Char.ToLower(letters[0]);
      return new string(letters);
    }

    public static string UpperCaseFirst(this string input)
    {
      if (String.IsNullOrEmpty(input))
      {
        return input;
      }

      Char[] letters = input.ToCharArray();
      letters[0] = Char.ToUpper(letters[0]);
      return new string(letters);
    }

    /// <summary>
    ///    Return the first occurrence of the 
    ///    string that is preceded by 'startDelimiter' and succeeded by 'endDelimiter'.
    /// 
    ///    Return an empty string, if either the 'startDelimiter' or the 'endDelimiter' is not found
    /// </summary>
    /// <param name="input"></param>
    /// <param name="startDelimiter"></param>
    /// <param name="endDelimiter"></param>
    /// <returns></returns>
    public static string Between(this string input, string startDelimiter, string endDelimiter)
    {
      Check.Require(!String.IsNullOrEmpty(input), "input cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(startDelimiter), "startDelimiter cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(endDelimiter), "endDelimiter cannot be null or empty");

      string result = String.Empty;

      int startIndex = input.IndexOf(startDelimiter);
      if (startIndex == -1)
      {
        return result;
      }

      // Move the startIndex to just after the end of the 'startDelimiter'
      startIndex = startIndex + startDelimiter.Length;

      int endIndex = input.IndexOf(endDelimiter, startIndex);
      if (endIndex == -1)
      {
        return result;
      }

      // Is there something in between
      if (endIndex - startIndex > 1)
      {
        result = input.Substring(startIndex, endIndex - startIndex);
      }
      
      return result;
    }
    #endregion

    /// <summary>
    ///    Define ForEach for IEnumerable
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="value"></param>
    /// <param name="action"></param>
    public static void ForEach<T>(this IEnumerable<T> value, Action<T> action)
    {
      foreach (T item in value)
      {
        action(item);
      }
    }

    /// <summary>Searches and returns attributes. The inheritance chain is not used to find the attributes.</summary>
    /// <typeparam name="T">The type of attribute to search for.</typeparam>
    /// <param name="type">The type which is searched for the attributes.</param>
    /// <returns>Returns all attributes.</returns>
    public static T[] GetCustomAttributes<T>(this Type type) where T : Attribute
    {
      return GetCustomAttributes(type, typeof(T), false).Select(arg => (T)arg).ToArray();
    }

    /// <summary>Searches and returns attributes.</summary>
    /// <typeparam name="T">The type of attribute to search for.</typeparam>
    /// <param name="type">The type which is searched for the attributes.</param>
    /// <param name="inherit">Specifies whether to search this member's inheritance chain to find the attributes. Interfaces will be searched, too.</param>
    /// <returns>Returns all attributes.</returns>
    public static T[] GetCustomAttributes<T>(this Type type, bool inherit) where T : Attribute
    {
      return GetCustomAttributes(type, typeof(T), inherit).Select(arg => (T)arg).ToArray();
    }

    /// <summary>
    ///   Return the assembly qualified name without the version and public key
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    public static string GetAssemblyQualifiedName(this Type type)
    {
      return type.FullName + ", " + type.Assembly.GetName().Name;
    }

    /// <summary>Private helper for searching attributes.</summary>
    /// <param name="type">The type which is searched for the attribute.</param>
    /// <param name="attributeType">The type of attribute to search for.</param>
    /// <param name="inherit">Specifies whether to search this member's inheritance chain to find the attribute. Interfaces will be searched, too.</param>
    /// <returns>An array that contains all the custom attributes, or an array with zero elements if no attributes are defined.</returns>
    private static object[] GetCustomAttributes(Type type, Type attributeType, bool inherit)
    {
      if (!inherit)
      {
        return type.GetCustomAttributes(attributeType, false);
      }

      var attributeCollection = new Collection<object>();
      var baseType = type;

      do
      {
        baseType.GetCustomAttributes(attributeType, true).Apply(attributeCollection.Add);
        baseType = baseType.BaseType;
      }
      while (baseType != null);

      foreach (var interfaceType in type.GetInterfaces())
      {
        GetCustomAttributes(interfaceType, attributeType, true).Apply(attributeCollection.Add);
      }

      var attributeArray = new object[attributeCollection.Count];
      attributeCollection.CopyTo(attributeArray, 0);
      return attributeArray;
    }

    /// <summary>Applies a function to every element of the list.</summary>
    private static void Apply<T>(this IEnumerable<T> enumerable, Action<T> function)
    {
      foreach (var item in enumerable)
      {
        function.Invoke(item);
      }
    }

    public static bool IsGuid(this string value)
    {
      return !string.IsNullOrEmpty(value) ? guidRegex.IsMatch(value) : false;
    }

    public static Guid ConvertToGuid(this string value)
    {
      return string.IsNullOrEmpty(value) ? 
          Guid.Empty : 
         (guidRegex.IsMatch(value) ? new Guid(value) : Guid.Empty);
    }

    #region Project Extensions
    public static string GetAssemblyName(this Project project)
    {
      foreach (BuildPropertyGroup buildPropertyGroup in project.PropertyGroups)
      {
        foreach (BuildProperty buildProperty in buildPropertyGroup)
        {
          if (buildProperty.Name == "AssemblyName")
          {
            return buildProperty.Value;
          }
        }
      }

      return null;
    }

    public static string GetRootNamespace(this Project project)
    {
      foreach (BuildPropertyGroup buildPropertyGroup in project.PropertyGroups)
      {
        foreach (BuildProperty buildProperty in buildPropertyGroup)
        {
          if (buildProperty.Name == "RootNamespace")
          {
            return buildProperty.Value;
          }
        }
      }

      return null;
    }

    public static bool GetSignAssembly(this Project project, out string keyFile)
    {
      bool signAssembly = false;
      keyFile = null;

      foreach (BuildPropertyGroup buildPropertyGroup in project.PropertyGroups)
      {
        foreach (BuildProperty buildProperty in buildPropertyGroup)
        {
          if (buildProperty.Name == "SignAssembly")
          {
            signAssembly = Convert.ToBoolean(buildProperty.Value);
          }
          else if (buildProperty.Name == "AssemblyOriginatorKeyFile")
          {
            keyFile = buildProperty.Value.ReplaceMtRmp();
          }
        }
      }

      return signAssembly;
    }

    #region Compile Items
    /// <summary>
    ///    Return the compile items
    /// </summary>
    /// <param name="project"></param>
    /// <returns></returns>
    public static List<string> GetCompileItems(this Project project)
    {
      var compileItems = new List<string>();

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "compile")
          {
            compileItems.Add(buildItem.Include.ToLower().ReplaceMtRmp());
          }
        }
      }

      return compileItems;
    }

    /// <summary>
    ///    Add the compile items 
    /// </summary>
    /// <param name="project"></param>
    /// <returns></returns>
    public static void AddCompileItems(this Project project, List<string> compileItems) 
    {
      Check.Require(compileItems != null, "compileItems cannot be null");

      foreach(string compileItem in compileItems)
      {
        project.AddCompileItem(compileItem);
      }
    }

    public static void AddCompileItem(this Project project, string compileItem)
    {
      if (project.CompileItemExists(compileItem))
      {
        return;
      }

      BuildItemGroup buildItemGroup = project.GetBuildItemGroup();
      buildItemGroup.AddNewItem("Compile", compileItem);
    }

    /// <summary>
    ///    Remove the compile items
    /// </summary>
    /// <param name="project"></param>
    /// <returns></returns>
    public static void RemoveCompileItems(this Project project, List<string> compileItems)
    {
      Check.Require(compileItems != null, "compileItems cannot be null");

      foreach (string compileItem in compileItems)
      {
        project.RemoveCompileItem(compileItem);
      }
    }

    public static void RemoveCompileItem(this Project project, string compileItem)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetCompileItemInfo(compileItem, out buildItemGroup, out buildItem);
      if (buildItemGroup != null)
      {
        buildItemGroup.RemoveItem(buildItem);
      }
    }

    public static bool CompileItemExists(this Project project, string compileItem)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetCompileItemInfo(compileItem, out buildItemGroup, out buildItem);

      if (buildItemGroup == null)
      {
        return false;
      }

      return true;
    }

    public static void GetCompileItemInfo(this Project project,
                                          string compileItem,
                                          out BuildItemGroup targetBuildItemGroup,
                                          out BuildItem targetBuildItem)
    {
      targetBuildItemGroup = null;
      targetBuildItem = null;

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        if (targetBuildItemGroup != null)
        {
          break;
        }

        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "compile")
          {
            if (Path.GetFileName(buildItem.Include).ToLower() ==
                Path.GetFileName(compileItem).ToLower())
            {
              targetBuildItem = buildItem;
              targetBuildItemGroup = buildItemGroup;
              break;
            }
          }
        }
      }
    }
    #endregion

    #region References
    /// <summary>
    ///   Return the references 
    /// </summary>
    /// <param name="project"></param>
    /// <returns></returns>
    public static List<string> GetReferences(this Project project)
    {
      var references = new List<string>();

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "reference")
          {
            string reference = buildItem.GetMetadata("HintPath");
            if (String.IsNullOrEmpty(reference))
            {
              reference = buildItem.Include;
            }

            if (!reference.EndsWith(".dll"))
            {
              reference = reference + ".dll";
            }

            references.Add(reference.ReplaceMtRmp().ToLower());
          }
        }
      }

      return references;
    }

    public static void AddReferencesForCsProj(this Project project, List<ReferenceAssembly> referenceAssemblies)
    {
      foreach (ReferenceAssembly referenceAssembly in referenceAssemblies)
      {
        project.AddReferenceForCsProj(referenceAssembly);
      }
    }

    public static void AddReferenceForCsProj(this Project project, ReferenceAssembly referenceAssembly)
    {
      if (project.ReferenceExists(referenceAssembly.Name))
      {
        return;
      }

      BuildItemGroup buildItemGroup = project.GetBuildItemGroup();

      string referenceValue = Path.GetFileNameWithoutExtension(referenceAssembly.Name);

      if (referenceAssembly.IsSystem)
      {
        buildItemGroup.AddNewItem("Reference", referenceValue);
      }
      else
      {
        BuildItem referenceItem = buildItemGroup.AddNewItem("Reference", referenceValue);
        referenceItem.SetMetadata("SpecificVersion", "false");
        referenceItem.SetMetadata("HintPath", Path.Combine("$(MTRMPBIN)", referenceValue + ".dll"));
        referenceItem.SetMetadata("Private", "false");
      }
    }

    public static void AddReferencesForMsBuildProj(this Project project, List<string> references)
    {
      foreach (string reference in references)
      {
        project.AddReferenceForMsBuildProj(reference);
      }
    }

    public static void AddReferenceForMsBuildProj(this Project project, string reference)
    {
      if (project.ReferenceExists(reference))
      {
        return;
      }

      BuildItemGroup buildItemGroup = project.GetBuildItemGroup();
      buildItemGroup.AddNewItem("Reference", reference);
    }

    public static void RemoveReferences(this Project project, List<string> references)
    {
      Check.Require(references != null, "references cannot be null");

      foreach (string reference in references)
      {
        project.RemoveReference(reference);
      }
    }

    public static void RemoveReference(this Project project, string reference)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetReferenceInfo(reference, out buildItemGroup, out buildItem);
      if (buildItemGroup != null)
      {
        buildItemGroup.RemoveItem(buildItem);
      }
    }

    public static bool ReferenceExists(this Project project, string reference)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetReferenceInfo(reference, out buildItemGroup, out buildItem);

      if (buildItemGroup == null)
      {
        return false;
      }

      return true;
    }

    public static void GetReferenceInfo(this Project project,
                                        string reference,
                                        out BuildItemGroup targetBuildItemGroup,
                                        out BuildItem targetBuildItem)
    {
      targetBuildItemGroup = null;
      targetBuildItem = null;

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        if (targetBuildItemGroup != null)
        {
          break;
        }

        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "reference")
          {
            // See if the assembly name matches
            if (Path.GetFileNameWithoutExtension(buildItem.Include).ToLower() == 
                Path.GetFileNameWithoutExtension(reference).ToLower())
            {
              targetBuildItem = buildItem;
              targetBuildItemGroup = buildItemGroup;
              break;
            }
          }
        }
      }
    }

    #endregion

    #region Embedded Resources
    public static List<string> GetEmbeddedResources(this Project project)
    {
      var embeddedResources = new List<string>();

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "embeddedresource")
          {
            embeddedResources.Add(buildItem.Include.ToLower());
          }
        }
      }

      return embeddedResources;
    }

    public static void AddEmbeddedResources(this Project project, List<string> embeddedResources)
    {
      Check.Require(embeddedResources != null, "embeddedResources cannot be null");

      foreach (string embeddedResource in embeddedResources)
      {
        project.AddEmbeddedResource(embeddedResource);
      }
    }

    public static void AddEmbeddedResource(this Project project, string embeddedResource)
    {
      if (project.EmbeddedResourceExists(embeddedResource))
      {
        return;
      }

      BuildItemGroup buildItemGroup = project.GetBuildItemGroup();
      buildItemGroup.AddNewItem("EmbeddedResource", embeddedResource);
    }

    public static void RemoveEmbeddedResources(this Project project, List<string> embeddedResources)
    {
      Check.Require(embeddedResources != null, "compileItems cannot be null");

      foreach (string embeddedResource in embeddedResources)
      {
        project.RemoveEmbeddedResource(embeddedResource);
      }
    }

    public static void RemoveEmbeddedResource(this Project project, string embeddedResource)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetEmbeddedResourceInfo(embeddedResource, out buildItemGroup, out buildItem);
      if (buildItemGroup != null)
      {
        buildItemGroup.RemoveItem(buildItem);
      }
    }

    public static bool EmbeddedResourceExists(this Project project, string embeddedResource)
    {
      BuildItemGroup buildItemGroup;
      BuildItem buildItem;

      project.GetEmbeddedResourceInfo(embeddedResource, out buildItemGroup, out buildItem);

      if (buildItemGroup == null)
      {
        return false;
      }

      return true;
    }

    public static void GetEmbeddedResourceInfo(this Project project,
                                               string embeddedResource,
                                               out BuildItemGroup targetBuildItemGroup,
                                               out BuildItem targetBuildItem)
    {
      targetBuildItemGroup = null;
      targetBuildItem = null;

      foreach (BuildItemGroup buildItemGroup in project.ItemGroups)
      {
        if (targetBuildItemGroup != null)
        {
          break;
        }

        // Iterate through each Item in the ItemGroup.
        foreach (BuildItem buildItem in buildItemGroup)
        {
          if (buildItem.Name.ToLower() == "embeddedresource")
          {
            if (Path.GetFileName(buildItem.Include).ToLower() ==
                Path.GetFileName(embeddedResource).ToLower())
            {
              targetBuildItem = buildItem;
              targetBuildItemGroup = buildItemGroup;
              break;
            }
          }
        }
      }
    }
    #endregion


    #endregion

    #region Private Methods
    private static BuildItemGroup GetBuildItemGroup(this Project project)
    {
      BuildItemGroup buildItemGroup = null;
      foreach (BuildItemGroup itemGroup in project.ItemGroups)
      {
        buildItemGroup = itemGroup;
        break;
      }

      if (buildItemGroup == null)
      {
        buildItemGroup = project.AddNewItemGroup();
      }

      return buildItemGroup;
    }
    #endregion

    #region Data
    private static readonly Regex guidRegex = 
      new Regex(@"^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$", RegexOptions.Compiled);
    #endregion

  }
}
