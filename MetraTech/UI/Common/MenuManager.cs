using System;
using System.Data;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using System.Xml.Serialization;
using MetraTech.ActivityServices.Common;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.Interop.MTAuth;

namespace MetraTech.UI.Common
{
  [Serializable]
  public class MenuManager
  {
    public List<Menu> Menus = new List<Menu>();
    private static Dictionary<string, MemoryStream> menuFileStreams = new Dictionary<string, MemoryStream>();
    private static object locker = new object();
    private static Logger mLogger = new Logger("[MenuManager]");

    public MenuManager()
    {
    }

    /// <summary>
    /// Indexer to get a menu by ID
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public Menu this[string id]
    {
      get
      {
        foreach (Menu menu in Menus)
        {
          if (menu.ID.ToUpper().Equals(id.ToUpper()))
          {
            return menu;
          }
        }
        return null;
      }
    }

    /// <summary>
    /// Determine if a menu with the specified ID exists.
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public bool Exists(string id)
    {
      foreach (Menu menu in Menus)
      {
        if (menu.ID.ToUpper().Equals(id.ToUpper()))
        {
          return true;
        }
      }

      return false;
    }

    public bool Save(string menuFile)
    {
      // Serialization
      XmlSerializer s = new XmlSerializer(typeof(MenuManager));
      TextWriter w = new StreamWriter(menuFile);
      s.Serialize(w, this);
      w.Close();
      return true;
    }

    public static MenuManager Load(string menuFile)
    {
      return Load(menuFile, false);
    }

    public static MenuManager Load(string menuFile, bool forceReloadFromFile)
    {
      // Deserialization from cached memory stream
      XmlSerializer s = new XmlSerializer(typeof(MenuManager));

      //Determine if we need to remove file from cache
      if (forceReloadFromFile && menuFileStreams.ContainsKey(menuFile))
      {
        //Remove existing file stream from cache
        lock (locker)
        {
          if (menuFileStreams.ContainsKey(menuFile))
          {
            menuFileStreams.Remove(menuFile);
          }
        }
      }

      //Load file into cache if it is not loaded
      if (!menuFileStreams.ContainsKey(menuFile))
      {
        //Load file stream into cache
        lock (locker)
        {
          if (!menuFileStreams.ContainsKey(menuFile))
          {
            using (StreamReader rdr = new StreamReader(menuFile))
            {
              byte[] bytes = new byte[rdr.BaseStream.Length + 1];
              rdr.BaseStream.Read(bytes, 0, bytes.Length);
              menuFileStreams.Add(menuFile, new MemoryStream(bytes));
            }
          }
        }
      }

      MenuManager mm;
      lock (locker)
      {
        MemoryStream menuFileStream = menuFileStreams[menuFile];
        menuFileStream.Seek(0, SeekOrigin.Begin);
        mm = (MenuManager) s.Deserialize(menuFileStream);
      }

      return mm;
    }
    
    public enum MenuType
    {
      Horizontal,
      Vertical,
      Table,
      Context
    }

    /// <summary>
    /// Checks to see if the given menu should be visible for the given security context.
    /// </summary>
    /// <param name="sc"></param>
    /// <param name="menu"></param>
    /// <returns></returns>
    public static bool IsMenuSectionVisible(IMTSecurityContext sc, Menu menu)
    {
      IMTSecurity security = new MTSecurityClass();
      bool menuHasAccess = false;

      foreach (var itm in menu.MenuSections)
      {
        if (IsMenuSectionVisible(sc, itm))
        {
          menuHasAccess = true;
          break;
        }
      }
      return menuHasAccess;
    }

    /// <summary>
    /// Checks to see if the given menu section should be visible for the given security context.
    /// </summary>
    /// <param name="sc"></param>
    /// <param name="menuSection"></param>
    /// <returns></returns>
    public static bool IsMenuSectionVisible(IMTSecurityContext sc, MenuSection menuSection)
    {
      IMTSecurity security = new MTSecurityClass();
      bool sectionHasAccess = false;

      foreach (MenuItem menuItem in menuSection.MenuItems)
      {
        if(IsMenuItemVisible(sc, menuItem))
        {
          sectionHasAccess = true;
          break;
        }
      }
      return sectionHasAccess;
    }

    /// <summary>
    /// Return true if the specified capability exists in the DB.  Return false otherwise.
    /// </summary>
    /// <param name="capabilityName">search for this capability name</param>
    /// <returns>Return true if the specified capability exists in the DB.  Return false otherwise.</returns>
    private static bool DoesCapabilityExistInDb(string capabilityName)
    {
      bool doesCapabilityExist = false;
      try
      {
        IMTSecurity security = new MTSecurityClass();
        MTSessionContext sessionContext = (MTSessionContext)UserData.GetSystemAcctUserData().SessionContext;
        IMTSQLRowset capabilityRowSet = security.GetCapabilityTypesAsRowset(sessionContext);

        // loop over capabilities in the DB looking for the specified capabilityName
        while ((Int16) capabilityRowSet.EOF == 0)
        {
          // Note: the third column (tx_name) holds the capability name
          var currentCapabilityName = (string)capabilityRowSet.Value[2];

          if (currentCapabilityName.ToUpper() == capabilityName.ToUpper())
          {
            doesCapabilityExist = true;
            break;
          }
          capabilityRowSet.MoveNext();
        }
      }
      catch (Exception e)
      {
        mLogger.LogError("DoesCapabilityExistInDb: capabilityName={0}, exception thrown {1}, returning false, stackTrace={2}", capabilityName, e.Message, e.StackTrace);
      }

      mLogger.LogDebug("DoesCapabilityExistInDb: capabilityName={0}, returning {1}", capabilityName, doesCapabilityExist);
      return doesCapabilityExist;
    }

    /// <summary>
    /// Determines if the given menu item should be visible for the given security context.
    /// </summary>
    /// <param name="sc"></param>
    /// <param name="menuItem"></param>
    /// <returns></returns>
    public static bool IsMenuItemVisible(IMTSecurityContext sc, MetraTech.UI.Common.MenuItem menuItem)
    {
      IMTSecurity security = new MTSecurityClass();
      bool hasAccess = true;
      

      if (menuItem.RequiredCapabilities.Operator == OperatorType.And)
      { // Operator "And"
        foreach (string cap in menuItem.RequiredCapabilities.Capabilities)
        {
          try
          {
            IMTCompositeCapability requiredCap = security.GetCapabilityTypeByNameControlLogging(cap, false).CreateInstance();
            if (requiredCap != null)
            {
              // If any capability check fails, skip it
              if (!sc.CoarseHasAccess(requiredCap)) // just a coarse check
              {
                hasAccess = false;
                break;
              }
            }
          }
          catch (Exception)
          {
            // this capability doesn't exist in the system
            hasAccess = false;
            break;
          }          
        }
      }
      else // Operator "Or"
      {
        bool gotOne = false;
        foreach (string cap in menuItem.RequiredCapabilities.Capabilities)
        {
          IMTCompositeCapability requiredCap = security.GetCapabilityTypeByNameControlLogging(cap, false).CreateInstance();
          // If any capability check fails, skip it
          if (sc.CoarseHasAccess(requiredCap)) // just a coarse check
          {
            gotOne = true;
            break;
          }
        }
        if(!gotOne)
        {
          hasAccess = false;
        }
      }


      foreach (var compositeCapability in menuItem.RequiredCapabilities.CompositeCapabilities)
      {
        // Custom check for BE capabilities
        if (compositeCapability.Name.ToLower() == "write business modeling entities" ||
           compositeCapability.Name.ToLower() == "read business modeling entities")
        {

          if (compositeCapability.AtomicCapabilities.Count > 0)
          {
            AccessType accessType = compositeCapability.Name.ToLower() == "write modeling business entities" ? AccessType.Write : AccessType.Read;
            hasAccess = CheckBECapability(compositeCapability.AtomicCapabilities[0].Value, accessType, sc);
            if (!hasAccess)
              break;
          }
          else
          {
            hasAccess = false;
            break;
          }
        }
        else
        {
          // TODO:  support for composit capabilities in menu
          IMTCompositeCapability requiredCap = security.GetCapabilityTypeByName(compositeCapability.Name).CreateInstance();
          foreach (var atomicCapability in compositeCapability.AtomicCapabilities)
          {
            switch (atomicCapability.AtomicType)
            {
              case AtomicCapabilityType.Decimal:
                throw new NotImplementedException("We don't support atomic decimal parameters on the menu yet.");
//                break;
              case AtomicCapabilityType.Path:
                throw new NotImplementedException("We don't support atomic path parameters on the menu yet.");
//                break;

              case AtomicCapabilityType.EnumType:
                requiredCap.GetAtomicEnumCapability().SetParameter(atomicCapability.Value);
                if (!sc.HasAccess(requiredCap))
                {
                  hasAccess = false;
                  break;
                }
                break;
              default:
                throw new ArgumentOutOfRangeException();
            }
          }
        }

        if(!hasAccess) 
          break;
      }
      return hasAccess;
    }

    #region BE Capability Checks
    public static bool CheckBECapability(string extensionName, AccessType accessType, IMTSecurityContext securityContext)
    {
      try
      {
        if (accessType == AccessType.Read)
        {
          if (!CheckReadAccess(extensionName, securityContext) && !CheckWriteAccess(extensionName, securityContext))
          {
            return false;
          }
        }
        else if (accessType == AccessType.Write)
        {
          if (!CheckWriteAccess(extensionName, securityContext))
          {
            return false;
          }
        }
      }
      catch (MASBasicException)
      {
        throw;
      }
      catch (Exception)
      {
        string message = String.Format("Failed capability check for extension '{0}'", extensionName);
        throw new MASBasicException(message);
      }

      return true;
    }

    private static bool CheckReadAccess(string extensionName, IMTSecurityContext securityContext)
    {
      IMTCompositeCapability capability = null;
      var security = new MTSecurityClass();

      string capabilityName = "Read Business Modeling Entities";
      capability = security.GetCapabilityTypeByName(capabilityName).CreateInstance();
      Check.Require(capability != null,
                    String.Format("Cannot create capability with name '{0}'", capabilityName),
                    SystemConfig.CallerInfo);
      capability.GetAtomicEnumCapability().SetParameter(extensionName);

      return securityContext.HasAccess(capability);
    }

    private static bool CheckWriteAccess(string extensionName, IMTSecurityContext securityContext)
    {
      IMTCompositeCapability capability = null;
      var security = new MTSecurityClass();

      string capabilityName = "Write Business Modeling Entities";
      capability = security.GetCapabilityTypeByName(capabilityName).CreateInstance();
      Check.Require(capability != null,
                    String.Format("Cannot create capability with name '{0}'", capabilityName),
                    SystemConfig.CallerInfo);
      capability.GetAtomicEnumCapability().SetParameter(extensionName);

      return securityContext.HasAccess(capability);
    }
    #endregion

  }

  [Serializable]
  public class Menu
  {
    public string ID = "";
    public MenuManager.MenuType Type = MenuManager.MenuType.Horizontal;
    public List<MenuItem> MenuItems = new List<MenuItem>();
    public List<MenuSection> MenuSections = new List<MenuSection>();

    /// <summary>
    /// Removes an menu item by id
    /// </summary>
    /// <param name="id"></param>
    public void RemoveMenuItemById(string id)
    {
      MenuSection menuSection;
      MenuItem itm = FindMenuItemById(id, out menuSection);
      if (itm != null)
      {
        menuSection.MenuItems.Remove(itm);
      }
    }

    /// <summary>
    /// Finds a menu item by id and returns it and the section.
    /// </summary>
    /// <param name="id"></param>
    /// <param name="menuSection"></param>
    /// <returns></returns>
    public MenuItem FindMenuItemById(string id, out MenuSection menuSection)
    {
      foreach (MenuSection section in MenuSections)
      {
        foreach (MenuItem itm in section.MenuItems)
        {
          if (id.ToLower() == itm.ID.ToLower())
          {
            menuSection = section;
            return itm;
          }
        }
      }

      menuSection = null;
      return null;
    }

  }

  [Serializable]
  public class MenuSection
  {
    public string ID = "";
    public LocalizableString Caption = new LocalizableString();
    public List<MenuItem> MenuItems = new List<MenuItem>();
  }

  [Serializable]
  public class MenuItem
  {
    public string ID = "";
    public LocalizableString Caption = new LocalizableString();
    public string Link = "";
    public string Target = "";
    public string Icon = "";
    /// <summary>
    /// Type of action which handle 'click' event of menu item.
    /// </summary>
    public string Action = string.Empty;
    public RequiredCapabilityList RequiredCapabilities = new RequiredCapabilityList();
    public bool IsRenderDependFromLocalization = true;
  }

  [Serializable]
  public class RequiredCapabilityList
  {
    [XmlAttribute("operator")]
    public OperatorType Operator = OperatorType.And;

    [XmlElement("Capability")]
    public List<string> Capabilities = new List<string>();
    
    [XmlElement("CompositeCapability")]
    public List<CompositeCapability> CompositeCapabilities = new List<CompositeCapability>();
  }

  [Serializable]
  public enum OperatorType
  {
    And,
    Or
  }

  [Serializable]
  public class CompositeCapability
  {
    [XmlAttribute("name")]
    public string Name;

    [XmlElement("AtomicCapability")]
    public List<AtomicCapability> AtomicCapabilities = new List<AtomicCapability>();        
  }

  [Serializable]
  public class AtomicCapability
  {
    [XmlAttribute("atomic-type")]
    public AtomicCapabilityType AtomicType;

    [XmlAttribute("value")]
    public string Value;
  }

  [Serializable]
  public enum AtomicCapabilityType
  {
    Decimal,
    Path,
    EnumType
  }
}
