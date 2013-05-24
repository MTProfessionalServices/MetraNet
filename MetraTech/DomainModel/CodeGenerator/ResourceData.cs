using System;
using System.Collections.Generic;

namespace MetraTech.DomainModel.CodeGenerator
{
  public class ResourceData
  {
    #region Public Methods
    public ResourceData()
    {
      resourceHelpers = new List<ResourceHelper>();
    }

    public void AddResource(string mtLocalizationId, string resourceId, string defaultValue, string extension, string localeSpace)
    {
      resourceHelpers.Add(new ResourceHelper(mtLocalizationId, resourceId, defaultValue, extension, localeSpace));
    }

    public Dictionary<string, string> GetResources(string language)
    {
      Dictionary<string, string> resources = new Dictionary<string, string>();

      GetResources(language, ref resources);

      return resources;
    }

    public void GetResources(string language, ref Dictionary<string, string> resources)
    {
        foreach (ResourceHelper resourceHelper in resourceHelpers)
        {
            string value = resourceHelper.GetResource(language);
            if (resources.ContainsKey(resourceHelper.ResourceId))
            {
                // logger.LogError(String.Format("Attempting to add duplicate Resource Key '{0}' for language '{1}", resourceHelper.ResourceId, language.MetraTech));
                continue;
            }
            resources.Add(resourceHelper.ResourceId, value);
        }
    }
    #endregion

    #region Properties

    private readonly List<ResourceHelper> resourceHelpers;
    protected static Logger logger =
      new Logger("Logging\\DomainModel\\CodeGenerator", "[CodeGenerator]");
    #endregion
  }

  #region ResourceHelper
  class ResourceHelper
  {
    public string DefaultValue;
    public string ResourceId;
    public string MTLocalizationId;
    public string Extension;
    public string LocaleSpace;


    #region Public Methods
    public ResourceHelper(string mtLocalizationId, 
                          string resourceId, 
                          string defaultValue, 
                          string extension,
                          string localeSpace)
    {
      MTLocalizationId = mtLocalizationId;
      ResourceId = resourceId;
      DefaultValue = defaultValue;
      Extension = extension;
      LocaleSpace = localeSpace;
    }

    public string GetResource(string language)
    {
      if (String.IsNullOrEmpty(MTLocalizationId))
      {
        // Use default value
        return DefaultValue;
      }

      string value = LocalizationFileData.GetLocalizedValue(language, Extension, LocaleSpace, MTLocalizationId);
      if (String.IsNullOrEmpty(value))
      {
        // Use default value
        value = DefaultValue;
      }

      return value;
    }
    #endregion
  }
  #endregion
}
