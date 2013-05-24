using System;
using MetraTech.DataAccess;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Text;

[assembly: GuidAttribute("b5722be5-2c5f-4aee-8d62-19cdb8a7e108")]

namespace MetraTech.Localization
{
  /// <summary>
  /// Summary description for LocalizedDescription.
  /// </summary>
  /// 

  [Guid("A62A8098-052A-4d83-B4FA-5EE7DBFEDCF1")]
  public interface ILocalizedEntry
  {
    string LanguageCode{get;}
    string Value{get;}
  }

  [Guid("1595C9FD-A826-4c4f-B2CB-59D35C37B529")]
  [ClassInterface(ClassInterfaceType.None)]
  public class LocalizedEntry : ILocalizedEntry
  {
    public LocalizedEntry(string aLanguage, string aValue)
    {
      mLanguageCode = aLanguage;
      mValue = aValue;
    }

    public string LanguageCode
    {
      get { return mLanguageCode; }
    }

    public string Value
    {
      get { return mValue; }
    }

    private string mLanguageCode;
    private string mValue;

  }

  [ComVisible(false)]
  public class MDMLocalizedText
  {
    private string mID;
    public string ID
    {
      get { return mID; }
    }

    private string mValue;
    public string Value
    {
      get { return mValue; }
    }

    private string mLangCode;
    public string Language
    {
      get { return mLangCode; }
    }

    private string mDesc;
    public string Description 
    {
      get { return mDesc; }
    }

    public MDMLocalizedText(string id, string lang, string value, string description)
    {
      mID = id;
      mValue = value;
      mLangCode = lang;
      mDesc = description;
    }
  }

  [ComVisible(false)]
  public enum MDMLocalizedTextDifferenceType
  {
    Deleted,
    Updated,
    Inserted,
    Unchanged
  }

  [ComVisible(false)]
  public class MDMLocalizedTextDifference
  {
    public MDMLocalizedText LeftText;
    public MDMLocalizedText RightText;
    public MDMLocalizedTextDifferenceType Type;
    public MDMLocalizedTextDifference(MDMLocalizedText left, MDMLocalizedText right, MDMLocalizedTextDifferenceType type)
    {
      Type = type;
      LeftText = left;
      RightText = right;
      System.Diagnostics.Debug.Assert(type != MDMLocalizedTextDifferenceType.Deleted || RightText == null);
      System.Diagnostics.Debug.Assert(type != MDMLocalizedTextDifferenceType.Inserted || LeftText == null);
      System.Diagnostics.Debug.Assert(RightText == null || LeftText == null || RightText.ID == LeftText.ID);
    }
  }

  [ComVisible(false)]
  public class EquiJoinHashCodeProvider : System.Collections.IHashCodeProvider
  {
    private System.Reflection.PropertyInfo [] mProperties;

    public int GetHashCode(Object obj)
    {
      int hash=0;
      for(int i=0; i<mProperties.Length; i++)
      {
        hash += mProperties[i].GetValue(obj, null).GetHashCode();
      }
      return hash;
    }

    public EquiJoinHashCodeProvider(System.Reflection.PropertyInfo [] properties)
    {
      mProperties = properties;
    }
  }

  [ComVisible(false)]
  public class EquiJoinComparer : System.Collections.IComparer
  {
    private System.Reflection.PropertyInfo [] mProperties;

    public int Compare(Object lhs, Object rhs)
    {
      int comp=0;
      for(int i=0; i<mProperties.Length; i++)
      {
        if((comp=((System.IComparable)mProperties[i].GetValue(lhs, null)).CompareTo(mProperties[i].GetValue(rhs, null))) != 0) return comp;
      }
      return 0;
    }

    public EquiJoinComparer(System.Reflection.PropertyInfo [] properties)
    {
      mProperties = properties;
      // Todo: Check that all values implement ICompareable...
    }
  }

  /// <remarks>
  /// A difference algorithm based on a full outer hash join algorithm.
  /// </remarks>
  [ComVisible(false)]
  public abstract class DifferenceAlgorithm
  {
    private class HashNode
    {
      public Object Text;
      public bool Matched;
      public HashNode(Object text)
      {
        Text = text;
        Matched = false;
      }
    }

    protected abstract void ProcessDeleted(Object obj);
    protected abstract void ProcessInserted(Object obj);
    protected abstract void ProcessUpdated(Object lhs, Object rhs);
    protected abstract void ProcessUnchanged(Object lhs, Object rhs);

    public System.Collections.ArrayList CalculateDifference(System.Type type, IEnumerable probe, IEnumerable table, string [] keys, string [] values)
    {
      System.Collections.ArrayList diff = new System.Collections.ArrayList();

      // Find the prop info for the property names passed in.
      System.Reflection.PropertyInfo [] pis = new System.Reflection.PropertyInfo [keys.Length];
      for(int i=0; i<keys.Length; i++)
      {
        pis[i] = type.GetProperty(keys[i]);
        if (pis[i] == null) 
        {
          throw new ApplicationException("Property " + keys[i] + " not found in type MDMLocalizedText");
        }
      }

      System.Reflection.PropertyInfo [] valueProperties = new System.Reflection.PropertyInfo [values.Length]; 
      for(int i=0; i<values.Length; i++)
      {
        valueProperties[i] = type.GetProperty(values[i]);
        if (valueProperties[i] == null) 
        {
          throw new ApplicationException("Property " + values[i] + " not found in type MDMLocalizedText");
        }
      }

      // Do a full outer hash join to figure out the differences.
      System.Collections.Hashtable hash = new  System.Collections.Hashtable(new EquiJoinHashCodeProvider(pis), new EquiJoinComparer(pis));

      // Load up the hash table.
      foreach(Object text in table)
      {
        hash[text] = new HashNode(text);
      }
      // Probe the hash table.
      foreach(Object text in probe)
      {
        HashNode node = (HashNode) hash[text];
        if(node == null)
        {
          //diff.Add(new MDMLocalizedTextDifference(text, null, MDMLocalizedTextDifferenceType.Deleted));
          ProcessDeleted(text);
        }
        else 
        {
          node.Matched = true;
          bool eq=true;
          for(int i=0; i<valueProperties.Length; i++)
          {
            if(valueProperties[i].GetValue(text, null) != valueProperties[i].GetValue(node.Text, null))
            {
              eq = false;
              break;
            }
          }
          if(!eq)
          {
            //diff.Add(new MDMLocalizedTextDifference(text, node.Text, MDMLocalizedTextDifferenceType.Updated));
            ProcessUpdated(text, node.Text);
          }
          else
          {
            //diff.Add(new MDMLocalizedTextDifference(text, node.Text, MDMLocalizedTextDifferenceType.Unchanged));
            ProcessUnchanged(text, node.Text);
          }
        }
      }

      foreach(HashNode node in hash.Values)
      {
        if(!node.Matched)
        {
          //diff.Add(new MDMLocalizedTextDifference(null, node.Text, MDMLocalizedTextDifferenceType.Inserted));
          ProcessInserted(node.Text);
        }
      }

      return diff;
    }
  }

  [ComVisible(false)]
  public class MDMLocalizedTextDifferenceAlgorithm : DifferenceAlgorithm
  {
    public System.Collections.ArrayList diff = new System.Collections.ArrayList();

    protected override void ProcessDeleted(Object obj)
    {
      diff.Add(new MDMLocalizedTextDifference((MDMLocalizedText) obj, null, MDMLocalizedTextDifferenceType.Deleted));
    }
    protected override void ProcessInserted(Object obj)
    {
      diff.Add(new MDMLocalizedTextDifference(null, (MDMLocalizedText) obj, MDMLocalizedTextDifferenceType.Inserted));
    }
    protected override void ProcessUpdated(Object lhs, Object rhs)
    {
      diff.Add(new MDMLocalizedTextDifference((MDMLocalizedText) lhs, (MDMLocalizedText) rhs, MDMLocalizedTextDifferenceType.Updated));
    }
    protected override void ProcessUnchanged(Object lhs, Object rhs)
    {
      diff.Add(new MDMLocalizedTextDifference((MDMLocalizedText) lhs, (MDMLocalizedText) rhs, MDMLocalizedTextDifferenceType.Unchanged));
    }
  }

  [ComVisible(false)]
  public class ObjectPair
  {
    private Object mLeft;
    public Object Left
    {
      get { return mLeft; }
    }

    private Object mRight; 
    public Object Right
    {
      get { return mRight; }
    }

    public ObjectPair(Object left, Object right)
    {
      mLeft = left;
      mRight = right;
    }
  }

  [ComVisible(false)]
  public class ChangedDataCaptureAlgorithm : DifferenceAlgorithm
  {
    public System.Collections.ArrayList Deleted = new System.Collections.ArrayList();
    public System.Collections.ArrayList Inserted = new System.Collections.ArrayList();
    public System.Collections.ArrayList Updated = new System.Collections.ArrayList();
    public System.Collections.ArrayList Unchanged = new System.Collections.ArrayList();

    protected override void ProcessDeleted(Object obj)
    {
      Deleted.Add(obj);
    }
    protected override void ProcessInserted(Object obj)
    {
      Inserted.Add(obj);
    }
    protected override void ProcessUpdated(Object lhs, Object rhs)
    {
      Updated.Add(new ObjectPair(lhs, rhs));
    }
    protected override void ProcessUnchanged(Object lhs, Object rhs)
    {
      Unchanged.Add(new ObjectPair(lhs, rhs));
    }
  }

  [ComVisible(false)]
  public class MDMLocalizedTexts
  {
    private System.Collections.ArrayList mTexts;
    private System.Collections.Hashtable mText;
    private System.Collections.Hashtable mIndexByLang;

    public System.Collections.ArrayList GetLocalizedText()
    {
      return mTexts;
    }

    public System.Collections.ArrayList GetLocalizedTextForLanguage(string lang)
    {
      // Make sure that lang code is always upper case.
      lang = lang.ToUpper();
      return (System.Collections.ArrayList) mIndexByLang[lang];
    }

    public System.Collections.ArrayList GetLocalizedTextForID(string id)
    {
      return (System.Collections.ArrayList) mText[id];
    }

    public MDMLocalizedText GetLocalizedText(string id, string lang)
    {
      System.Collections.ArrayList list = GetLocalizedTextForID(id);
      foreach(MDMLocalizedText text in list)
      {
        if(text.Language == lang) return text;
      }
      return null;
    }

    public void Add(MDMLocalizedText text)
    {
      mTexts.Add(text);
      System.Collections.ArrayList list = (System.Collections.ArrayList)mText[text.ID];
      if (list == null)
      {
        list = new System.Collections.ArrayList();
        mText[text.ID] = list;
      }
      list.Add(text);

      list = (System.Collections.ArrayList)mIndexByLang[text.Language];
      if (list == null)
      {
        list = new System.Collections.ArrayList();
        mIndexByLang[text.Language] = list;
      }
      list.Add(text);
    }

    public MDMLocalizedText Add(string id, string lang, string value, string description)
    {
      // Make sure that lang code is always upper case.
      lang = lang.ToUpper();
      MDMLocalizedText text = new MDMLocalizedText(id, lang, value, description);
      Add(text);
      return text;
    }

    public System.Collections.ArrayList CalculateDifference(MDMLocalizedTexts texts, string [] keys, string [] values)
    {
      MDMLocalizedTextDifferenceAlgorithm diff = new MDMLocalizedTextDifferenceAlgorithm();
      diff.CalculateDifference(typeof(MDMLocalizedText), this.GetLocalizedText(), texts.GetLocalizedText(), keys, values);
      return diff.diff;
    }

    public MDMLocalizedTexts()
    {
      mTexts = new System.Collections.ArrayList();
      mText = new System.Collections.Hashtable();
      mIndexByLang = new System.Collections.Hashtable();
      // Initialize with the list of configured languages.
      LanguageList languages = new LanguageList();
      foreach(string langCode in languages.Codes)
      {
        mIndexByLang[langCode] = new System.Collections.ArrayList();
      }
    }
  }

  [ComVisible(false)]
  public class EnumerationLocalizedTextsReader
  {
    public void ReadAllLocales(MDMLocalizedTexts texts)
    {
      MetraTech.Interop.MTLocaleConfig.ILocaleConfig localeConfig = new MetraTech.Interop.MTLocaleConfig.LocaleConfig();
      localeConfig.LoadLanguage("");
      MetraTech.Interop.MTLocaleConfig.IMTLocalizedCollection coll = localeConfig.LocalizedCollection;
      coll.Begin();
      while(0 == coll.End())
      {
        texts.Add(coll.GetFQN(), coll.GetLanguageCode(), coll.GetLocalizedString(), "");
        // The following are also needed for creating a localization file:
        // coll.GetExtension(); coll.GetNamespace();
        coll.Next();
      }
    }
  }

  /// <remarks>
  /// Represents information about an MDM localization file.  MDM localization files
  /// follow a naming convention in which the language for the file is stored in the
  /// directory structure (e.g. UI\\MOM\\default\\localized\\us\\Dictionary\\MDM\\LocalizedMDMGrid.xml).
  /// This object maintains the "parsed" version of the filename into the prefix, language
  /// and suffix.  This makes it easy to figure out the proper name of the "same" file in different
  /// languages.
  /// </remarks>
  [ComVisible(false)]
  public class MDMLocalizationFileInfo 
  {
    private string mLangCode;
    public string Language
    {
      get { return mLangCode; }
    }

    private string mPathPrefix;
    public string PathPrefix
    {
      get { return mPathPrefix; }
    }

//     private string mPathRoot;
//     public string PathRoot
//     {
//       get { return mPathRoot; }
//     }

    private string mPathSuffix;
    public string PathSuffix
    {
      get { return mPathSuffix; }
    }

//     private bool mIsCustom;
//     public bool IsCustom
//     {
//       get { return mIsCustom; }
//     }

    public string Name
    {
      get { return mFileSystemInfo.Name; }
    }

    private System.IO.FileSystemInfo mFileSystemInfo;
    public System.IO.FileSystemInfo Info
    {
      get { return mFileSystemInfo; }
    }

    /// <summary>
    /// Create the file info for the "same" localization file but in a different language.
    /// </summary>
    public MDMLocalizationFileInfo GetFileForLanguage(string lang)
    {
      return new MDMLocalizationFileInfo(PathPrefix, lang.ToUpper(), PathSuffix, Name);
    }

    public MDMLocalizationFileInfo(string pathPrefix, string lang, string pathSuffix, string name)
    {
      mPathPrefix = pathPrefix;
      mLangCode = lang.ToUpper();
      mPathSuffix = pathSuffix;
      mFileSystemInfo = new System.IO.FileInfo(System.IO.Path.Combine(System.IO.Path.Combine(System.IO.Path.Combine(pathPrefix, lang), pathSuffix), name));

    }

    public MDMLocalizationFileInfo(System.IO.FileSystemInfo info, string pathPrefix, string lang, string pathSuffix)
    {
      mFileSystemInfo = info;
      mPathPrefix = pathPrefix;
      mLangCode = lang.ToUpper();
      mPathSuffix = pathSuffix;

      if(System.IO.Path.Combine(System.IO.Path.Combine(pathPrefix, lang), pathSuffix) != System.IO.Path.GetDirectoryName(info.FullName))
      {
        throw new ApplicationException("Invalid MDMLocalizationFileInfo: " + info.FullName + "; " + pathPrefix + "; " + lang + "; " + pathSuffix);
      }
    }
  }

  [ComVisible(false)]
  public class MDMLocalizedTextsReader
  {
    private void GetMDMLocalizedFiles(System.IO.DirectoryInfo di, string pathPrefix, string lang, string pathSuffix, System.Collections.ArrayList list)
    {
      System.IO.FileSystemInfo [] files = di.GetFileSystemInfos("*.xml");
      for(int i=0; i<files.Length; i++)
      {
        list.Add(new MDMLocalizationFileInfo(files[i], pathPrefix, lang, pathSuffix));
      }
      // Recurse down the directory tree.
      foreach(System.IO.DirectoryInfo subDir in di.GetDirectories())
      {
        GetMDMLocalizedFiles(subDir, pathPrefix, lang, System.IO.Path.Combine(pathSuffix, subDir.Name), list);
      }
    }

    /// <summary>
    /// Return the collection of filenames that should exist for a given language based on
    /// the set of filenames that exist in another language.  E.g. knowing/assuming that US English
    /// is localized, get the list of files that are required for localizing German.  These may or may not exist.
    /// </summary>
    public System.Collections.ArrayList GetMDMLocalizedFilesForLanguage(string relativeDir, string referenceLanguage, string targetLanguage)
    {
      System.Collections.ArrayList files = new System.Collections.ArrayList();
      foreach(MDMLocalizationFileInfo info in GetMDMLocalizedFilesForLanguage(relativeDir, referenceLanguage))
      {
        files.Add(info.GetFileForLanguage(targetLanguage));
      }
      return files;
    }

    /// <summary>
    /// Return the collection of all localization files in the filesystem.
    /// If lang is the empty string then return localized files for all languages, otherwise only return 
    /// files for the specified language.
    /// </summary>
    public System.Collections.ArrayList GetMDMLocalizedFilesForLanguage(string relativeDir, string lang)
    {
      Microsoft.Win32.RegistryKey installDirKey = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("Software\\MetraTech\\Install");
      string installDir = (string)installDirKey.GetValue("InstallDir");
      // Before combining make sure that there is no leading \ in the relative dir.
      if(System.IO.Path.DirectorySeparatorChar == relativeDir[0])
      {
        throw new ApplicationException("Invalid relative path");
      }
      System.IO.DirectoryInfo di = new System.IO.DirectoryInfo(System.IO.Path.Combine(installDir,relativeDir));

      // We assume that the first level beneath the dir is the set of languages.  
      // We further assume that we only process the "configured" languages.
      // TODO: Warn if one of the languages isn't in the language code list.
      LanguageList languages = new LanguageList();
      System.Collections.ArrayList list = new System.Collections.ArrayList();
      foreach(System.IO.DirectoryInfo subDir in di.GetDirectories())
      {
        foreach(string langCode in languages.Codes)
        {
          if((lang.Length == 0 || lang.ToUpper() == subDir.Name.ToUpper()) && langCode.ToUpper() == subDir.Name.ToUpper()) 
          {
            GetMDMLocalizedFiles(subDir, di.FullName, subDir.Name, "", list);
          }
        }
      }

      return list;
    }

    /// <summary>
    /// Return all localization files for all languages in any subdirectory of the specified directory.
    /// </summary>
    public System.Collections.ArrayList GetMDMLocalizedFiles(string relativeDir)
    {
      return GetMDMLocalizedFilesForLanguage(relativeDir, "");
    }

    /// <summary>
    /// Read all of the localization files in the location relativeDir and store them
    /// in mdmTexts.
    /// </summary>
    public void ReadFiles(string relativeDir, MDMLocalizedTexts mdmTexts)
    {
      foreach(MDMLocalizationFileInfo fi in GetMDMLocalizedFiles(relativeDir))
      {
        try 
        {
          ReadFile(fi.Info.FullName, fi.Language, mdmTexts);
        }
        catch(Exception e)
        {
          System.Console.WriteLine("Exception reading file: " + fi.Info.FullName);
          System.Console.WriteLine(e.Message);
        }
      }
    }
    
    /// <summary>
    /// Read all of the localization information from filename into mdmTexts.  Assumes
    /// that the localization information is in the language lang.  Recall that MDM localization
    /// files to not contain information about the language (that is encoded in the path to the file).
    /// </summary>
    public void ReadFile(string filename, string lang, MDMLocalizedTexts mdmTexts)
    {
      MetraTech.Xml.MTXmlDocument doc = new MetraTech.Xml.MTXmlDocument();
      // TODO: Find files to load
      doc.Load(filename);
      System.Xml.XmlElement texts = (System.Xml.XmlElement) doc.SelectOnlyNode("texts");
      if (texts == null) 
      {
        // Not a valid localization file.
        return;
      }
      string textsId = texts.GetAttribute("id");
      if(textsId.Length == 0) throw new ApplicationException("Localization texts.@id must not be empty");
      string textsType = texts.GetAttribute("type");
      if(textsType.Length == 0) throw new ApplicationException("Localization texts.@type must not be empty");

      if(null != MetraTech.Xml.MTXmlDocument.SingleNodeExists(texts, "description"))
      {
        MetraTech.Xml.MTXmlDocument.GetNodeValueAsString(texts, "description");
      }

      foreach(System.Xml.XmlElement text in doc.SelectNodes("/texts/text"))
      {
        string textId = text.GetAttribute("id");
        if (textId.Length == 0) throw new ApplicationException("Localization texts.text.@id must not be empty");
        string value = MetraTech.Xml.MTXmlDocument.GetNodeValueAsString(text, "value");
        string description = "";
        System.Xml.XmlNode descriptionNode = null;
        if(null != (descriptionNode=MetraTech.Xml.MTXmlDocument.SingleNodeExists(text, "description")))
        {
          MetraTech.Xml.MTXmlDocument.GetNodeValueAsString(descriptionNode);
        }
        mdmTexts.Add(textId, lang, value, description);
      }
    }

    public MDMLocalizedTexts ReadFile(string filename, string lang)
    {
      MDMLocalizedTexts mdmTexts = new MDMLocalizedTexts();
      ReadFile(filename, lang, mdmTexts);
      return mdmTexts;
    }
  }

  [ComVisible(false)]
  public class MDMLocalizationCatalog
  {
    private string [] mPaths;
    private System.Collections.Hashtable mInvalidFiles;
    private System.Collections.Hashtable mTextToFileIndex;
    private System.Collections.Hashtable mFileToTextIndex;

    private MDMLocalizedTexts mTexts;

    public void Import(string filename)
    {
      System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
      doc.Load(filename);
      Import(doc);
    }

    public void Import(System.Xml.XmlDocument doc)
    {
      // TODO: Use some XMLSchema and do a validating parse!
      foreach(System.Xml.XmlNode node in doc.DocumentElement.SelectNodes("/texts/text"))
      {
        string id = node.SelectSingleNode("ID").InnerText;
        string language = node.SelectSingleNode("Language").InnerText;
        string value = node.SelectSingleNode("Value").InnerText;
        string description = node.SelectSingleNode("Description").InnerText;
        string pathPrefix = node.SelectSingleNode("PathPrefix").InnerText;
        string pathSuffix = node.SelectSingleNode("PathSuffix").InnerText;
        string name = node.SelectSingleNode("Name").InnerText;

        MDMLocalizedText text = mTexts.Add(id, language, value, description);

        // Check for a file object with the filename...
        MDMLocalizationFileInfo info = null;
        foreach(MDMLocalizationFileInfo info2 in mFileToTextIndex.Keys)
        {
          if(info2.Name == name && info2.PathPrefix == pathPrefix && info2.Language == language && pathSuffix == info2.PathSuffix)
          {
            info = info2;
            break;
          }
        }
        if (info == null)
        {
          info = new MDMLocalizationFileInfo(node.SelectSingleNode("PathPrefix").InnerText,
                                             node.SelectSingleNode("Language").InnerText,
                                             node.SelectSingleNode("PathSuffix").InnerText,
                                             node.SelectSingleNode("Name").InnerText);
          mFileToTextIndex[info] = new System.Collections.ArrayList();
        }

        // Update indexes of file object.
        ((System.Collections.ArrayList)mFileToTextIndex[info]).Add(text);
        mTextToFileIndex[text]=info;
      }
    }

    public void Export(string filename)
    {
      System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
      doc.AppendChild(doc.CreateElement("texts"));
      System.Xml.XmlElement root = doc.DocumentElement;
      // Write out all of the localization text with information about the
      // files from which the text was created.
      foreach(MDMLocalizationFileInfo file in mFileToTextIndex.Keys)
      {
        foreach(MDMLocalizedText text in ((System.Collections.ArrayList)mFileToTextIndex[file]))
        {
          System.Xml.XmlElement elt = doc.CreateElement("text");
          System.Xml.XmlNode nodeID = doc.CreateElement("ID");
          elt.AppendChild(nodeID);
          nodeID.AppendChild(doc.CreateCDataSection(text.ID));
          System.Xml.XmlNode nodeLang = doc.CreateElement("Language");
          elt.AppendChild(nodeLang);
          nodeLang.AppendChild(doc.CreateCDataSection(text.Language));
          System.Xml.XmlNode nodeValue = doc.CreateElement("Value");
          elt.AppendChild(nodeValue);
          nodeValue.AppendChild(doc.CreateCDataSection(text.Value));
          System.Xml.XmlNode nodeDesc = doc.CreateElement("Description");
          elt.AppendChild(nodeDesc);
          nodeDesc.AppendChild(doc.CreateCDataSection(text.Description));
          System.Xml.XmlNode nodePrefix = doc.CreateElement("PathPrefix");
          elt.AppendChild(nodePrefix);
          nodePrefix.AppendChild(doc.CreateCDataSection(file.PathPrefix));
          System.Xml.XmlNode nodeSuffix = doc.CreateElement("PathSuffix");
          elt.AppendChild(nodeSuffix);
          nodeSuffix.AppendChild(doc.CreateCDataSection(file.PathSuffix));
          System.Xml.XmlNode nodeName = doc.CreateElement("Name");
          elt.AppendChild(nodeName);
          nodeName.AppendChild(doc.CreateCDataSection(file.Name));
          root.AppendChild(elt);
        }
      }

      doc.Save(filename);
    }
    
    public void BindToFilesystem()
    {
      // TODO: There is something that needs to be done to handle the concept
      // of default/custom.
      MDMLocalizedTextsReader reader = new MDMLocalizedTextsReader();

      for(int i=0; i<mPaths.Length; i++)
      {
        // Load every file from each of the relative directories.
        foreach(MDMLocalizationFileInfo fi in reader.GetMDMLocalizedFiles(mPaths[i]))
        {
          try 
          {
            MDMLocalizedTexts mdmTexts = new MDMLocalizedTexts();
            reader.ReadFile(fi.Info.FullName, fi.Language, mdmTexts);
            System.Collections.ArrayList index = new System.Collections.ArrayList();
            mFileToTextIndex[fi] = index;
            foreach(MDMLocalizedText text in mdmTexts.GetLocalizedText())
            {
              mTextToFileIndex[text] = fi;
              index.Add(text);
              mTexts.Add(text);
            }
          }
          catch(Exception e)
          {
            mInvalidFiles[fi] = e.Message;
          }
        }
      }
    }

    public void CalculateDifference(MDMLocalizationCatalog cat)
    {
      // Do a diff at the level of files.
      ChangedDataCaptureAlgorithm fileDiff = new ChangedDataCaptureAlgorithm();
      fileDiff.CalculateDifference(typeof(MDMLocalizationFileInfo),
                                   this.mFileToTextIndex.Keys, 
                                   cat.mFileToTextIndex.Keys, 
                                   new string [] {"PathPrefix", "Language", "PathSuffix", "Name"}, 
                                   new string [] {});
      // Just do a diff of the underlying MDMLocalizedTexts
      System.Collections.ArrayList diffs = mTexts.CalculateDifference(cat.mTexts, new string[] {"ID", "Language"}, new string [] {"Value"});
    }

    public void InitializeLanguage(string referenceLanguage, string targetLanguage)
    {
      // Get all of the files for the target language.
      System.Collections.ArrayList referenceFiles = new System.Collections.ArrayList();
      System.Collections.ArrayList targetFiles = new System.Collections.ArrayList();

      MDMLocalizedTextsReader reader = new MDMLocalizedTextsReader();
      for(int i=0; i<mPaths.Length; i++)
      {
        // Load every file from each of the relative directories.
        foreach(MDMLocalizationFileInfo fi in reader.GetMDMLocalizedFilesForLanguage(mPaths[i], referenceLanguage))
        {
          referenceFiles.Add(fi);
        }
        foreach(MDMLocalizationFileInfo fi in reader.GetMDMLocalizedFilesForLanguage(mPaths[i], targetLanguage))
        {
          targetFiles.Add(fi);
        }
      }

      // Do a diff at the level of files.  Assumes that the only difference between
      // files names for different languages is the Language component.
      ChangedDataCaptureAlgorithm fileDiff = new ChangedDataCaptureAlgorithm();
      fileDiff.CalculateDifference(typeof(MDMLocalizationFileInfo),
                                   targetFiles, 
                                   referenceFiles, 
                                   new string [] {"PathPrefix", "PathSuffix", "Name"}, 
                                   new string [] {});

      // Only process inserts and deletes.  
      foreach(MDMLocalizationFileInfo fi in fileDiff.Deleted)
      {
        ((System.IO.FileInfo) fi.Info).Delete();
      }

      foreach(MDMLocalizationFileInfo fi in fileDiff.Inserted)
      {
        // Check to see if the directory exists.  Create it if it doesn't.
        if(!((System.IO.FileInfo)fi.GetFileForLanguage(targetLanguage).Info).Directory.Exists)
        {
          ((System.IO.FileInfo)fi.GetFileForLanguage(targetLanguage).Info).Directory.Create();
        }
        ((System.IO.FileInfo) fi.Info).CopyTo(fi.GetFileForLanguage(targetLanguage).Info.FullName);
      }
    }

    public MDMLocalizationCatalog()
    {
      mPaths = new string [] {"UI\\MOM\\default\\localized",
                              "UI\\MCM\\default\\localized",
                              "UI\\MAM\\default\\localized"};

      mTextToFileIndex = new System.Collections.Hashtable();
      mFileToTextIndex = new System.Collections.Hashtable();
      mInvalidFiles = new System.Collections.Hashtable();
      mTexts = new MDMLocalizedTexts();
    }
  }

  [Guid("e5723c7f-61ad-43f8-92eb-f4929895aafb")]
  public interface ILocalizedEntity  
  {
    string ToString();
    int ID{get;set;}
    void Save();
    void SaveWithID(int aID);
    IEnumerable LanguageMappings{get;}
    void SetMapping(string aLanguage, string aLocalized);
    IEnumerator GetEnumerator();
    void Copy(ILocalizedEntity aSource);
    string GetMapping(string aLanguage);
    string GetDefaultMapping();
  }

  [Guid("5d8a4ebc-b3bf-4d88-8e2e-2e785ea7086e")]
  [ClassInterface(ClassInterfaceType.None)]
  public class LocalizedEntity : ILocalizedEntity
  {
    override public string ToString()
    {
      StringBuilder temp = new StringBuilder();

      foreach (string languageCode in mMappings.Keys)
      {
        temp.AppendFormat("{0}={1};", languageCode, mMappings[languageCode]);
      }
      
      return temp.ToString();
    }

    private class LocalizedEntityEnumerator : IEnumerator
    {
      public LocalizedEntityEnumerator(LocalizedEntity le)
      {
        this.mLocalizedEntity = le;
        
        if (le.mMappings.Keys.Count==0)
        {
          //No mappings have been loaded, in this case we most likely do not have an ID to load from (item was just created) so
          //instead we will load the mappings with blanks for each of the language codes
          le.LoadBlankLocalizedTextForAllLanguages();
        }

        mLanguageKeys = new string[le.mMappings.Keys.Count];
        le.mMappings.Keys.CopyTo(mLanguageKeys,0);
        mIndex=-1;
      }
      
      public bool MoveNext()
      {
        mIndex++;
        if (mIndex>=mLanguageKeys.Length)
          return false;
        else
          return true;
        //return mEnumerator.MoveNext();
      }

      public void Reset()
      {
        mIndex=-1;
        //mEnumerator.Reset();
      }

      public object Current
      {
        get
        {
          LocalizedEntry le = new LocalizedEntry(mLanguageKeys[mIndex],mLocalizedEntity.mMappings[mLanguageKeys[mIndex]].ToString());
          //DictionaryEntry temp = (DictionaryEntry) mEnumerator.Current;
          //LocalizedEntry le = new LocalizedEntry((string)temp.Key,(string)temp.Value);
          return le;
        }
      }

      private string[] mLanguageKeys; //A temporary list of the language codes/keys to enumerate through
      private int mIndex;
      private LocalizedEntity mLocalizedEntity;
      //private IDictionaryEnumerator mEnumerator;
    }

    public IEnumerator GetEnumerator()
    {
      return (IEnumerator) new LocalizedEntityEnumerator(this);
    }

    public int ID
    {
      get{return mID;}
      set
      {
        //if (Debug.Listeners.Count==1)
        //  Debug.Listeners.Add(new TextWriterTraceListener(Console.Out));

        //DebugDumpMappings();
        //Debug.WriteLine("Debug:LocalizedEntity.ID Set[" + value + "] Previous Value [" + mID + "]");
				  
        LoadLocalizedTextFromId(value);
        //DebugDumpMappings();
        mID=value;
      }
    }

    private int mID=-1;
    private Hashtable mMappings =  new Hashtable();
    public IEnumerable LanguageMappings
    {
      get{return (IEnumerable) mMappings;}
    }

    public void SetMapping(string aLanguage, string aLocalized)
    {
      //if (Debug.Listeners.Count==1)
      //  Debug.Listeners.Add(new TextWriterTraceListener(Console.Out));
      //DebugDumpMappings();
      //Debug.WriteLine("Debug:LocalizedEntity.SetMapping [" + aLanguage + "] to [" + aLocalized + "]");
      //Debug.WriteLine("Debug:LocalizedEntity.SetMapping current ID is [" + mID + "]");

      mMappings[aLanguage] = aLocalized;

      //DebugDumpMappings();
      return;
    }

    public string GetMapping(string aLanguage)
    {
        if (mMappings.ContainsKey(aLanguage))
        {
            return (string)mMappings[aLanguage];
        }
        else
        {
            return null;
        }
    }

    public string GetDefaultMapping()
    {
        if (mMappings.Count > 0)
        {
            IDictionaryEnumerator iter = mMappings.GetEnumerator();

            while (iter.MoveNext())
            {
                if (!string.IsNullOrEmpty((string)iter.Entry.Value))
                {
                    return (string)iter.Entry.Value;
                }
            }


        }
     
        return null;
    }

    public void DebugDumpMappings()
    {
      //if (Debug.Listeners.Count==1)
      //  Debug.Listeners.Add(new TextWriterTraceListener(Console.Out));

      //Debug.WriteLine("Dumping mMappings (Count:" + mMappings.Count + ")");
      //Debug.Indent();
      foreach (string languageCode in mMappings.Keys)
      {
        Debug.WriteLine("Mapping " + languageCode + "= [" + mMappings[languageCode] + "]");
      }
      //Debug.Unindent();
    }

    public void Save()
    {
      if (mID<0)
        throw new ApplicationException("Localized Entity Save called with invalid description id");
      else
        SaveWithID(mID);
    }

    public void SaveWithID(int aID)
    {
      //DebugDumpMappings();
      mID = aID;
      LanguageList languages = new LanguageList();
      Hashtable updatedEntries = new Hashtable(); //A hashtable of changed entries we can use to update the cache

      foreach (string languageCode in mMappings.Keys)
      {
        if (mMappings[languageCode].ToString().CompareTo("")!=0)
        {
          int languageId = languages.GetLanguageID(languageCode);

          using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertDescription"))
              {

                  stmt.AddParam("id_lang_code", MTParameterType.Integer, languageId);
                  stmt.AddParam("a_nm_desc", MTParameterType.WideString, mMappings[languageCode]);
                  stmt.AddParam("a_id_desc_in", MTParameterType.String, aID);

                  stmt.AddOutputParam("a_id_desc", MTParameterType.Integer);

                  stmt.ExecuteNonQuery();
              }

            //int	batchID	=	(int)stmt.GetOutputValue("a_id_desc");
            updatedEntries.Add(languageId, mMappings[languageCode]);
          }
        }
      }

      //Update the cache
      LocalizedDescription ld = LocalizedDescription.GetInstance();
      ld.UpdateCollection(aID, updatedEntries);


      return;
    }
	
    public void LoadLocalizedTextFromId(int idDesc)
    {
      LocalizedDescription ld = LocalizedDescription.GetInstance();

      Hashtable localizedText = ld.GetByIDForAllLanguages(idDesc);
      LanguageList languages = new LanguageList();

      foreach (string languageCode in languages.Codes)
      {
        int languageId = languages.GetLanguageID(languageCode);
        if (localizedText.Contains(languageId))
          mMappings.Add(languageCode,localizedText[languageId]);
        else
          mMappings.Add(languageCode,"");
      }

      //mMappings=ld.GetByIDForAllLanguages(idDesc);
	   
      return;
    }
  
    public void LoadBlankLocalizedTextForAllLanguages()
    {
      mMappings.Clear();

      LanguageList languages = new LanguageList();

      foreach (string languageCode in languages.Codes)
      {
          mMappings.Add(languageCode,"");
      }

      return;
    }


  public void Copy(ILocalizedEntity aSource)
  {
    mMappings.Clear();

    foreach (LocalizedEntry le in aSource)
    {
      mMappings.Add(le.LanguageCode,le.Value);
    }
  }
	
}
   
   
  [ComVisible(false)]
  public class LocalizedDescription
  {
    private static LocalizedDescription mInstance;
    private static LanguageList mLangList;
    private LocalizedDescription()
    {
      mLangList = new LanguageList();
      //BuildCol();
      mFQNMap = new Hashtable();
      mIDMap = new Hashtable();
    }
    

    public static LocalizedDescription GetInstance()
    {
      //double checked locking
      if(mInstance == null)
      {
        lock(typeof(LocalizedDescription))
        {
          //never be null
          if(mInstance == null)
            mInstance =  new LocalizedDescription();
        }
      }
      return mInstance;
    }
    public string GetByName(string aLangCode, string aFQN)
    {
      int langid = mLangList.GetLanguageID(aLangCode);
      return GetByName(langid, aFQN);
    }

    public string GetByName(int aLangID, string aFQN)
    {
      string desc = null;

      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Localization", "__GET_LOCALIZED_STRING_BY_LANGUAGE_AND_FQN__"))
          {
              stmt.AddParam("%%ID_LANGUAGE%%", aLangID);
              stmt.AddParam("%%FQN%%", aFQN.ToUpper());

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      desc = String.Empty;

                      if (!reader.IsDBNull("tx_desc"))
                      {
                          desc = reader.GetString("tx_desc");
                      }
                      break;
                  }
              }
          }
      }

      if (desc == null)
      {
        throw new ApplicationException(String.Format("{0} is not localized in {1}({2}) language", aFQN, aLangID, mLangList.GetLanguageCode(aLangID)));
      }

      return desc;
    
    }

    public string GetByID(string aLangCode, int aID)
    {
      int langid = mLangList.GetLanguageID(aLangCode);
      return GetByID(langid, aID);

    }

    public string GetByID(int aLangID, int aID)
    {
      string desc = null;

      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Localization", "__GET_LOCALIZED_STRING_BY_LANGUAGE_AND_ID__"))
          {
              stmt.AddParam("%%ID_LANGUAGE%%", aLangID);
              stmt.AddParam("%%ID_DESC%%", aID);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      desc = String.Empty;

                      if (!reader.IsDBNull("tx_desc"))
                      {
                          desc = reader.GetString("tx_desc");
                      }
                      break;
                  }
              }
          }
      }

      if (desc == null)
      {
        throw new ApplicationException(String.Format("ID {0} is invalid or not localized", aID));
      }

      return desc;
    }

    public Hashtable GetByIDForAllLanguages(int aID)
    {
      if(!mIDMap.ContainsKey(aID))
      {
        if(!UpdateCollectionFromDatabase(aID))
        {
          throw new ApplicationException(String.Format("ID {0} is invalid or not localized", aID));
        }
      }

      return (Hashtable)mIDMap[aID];
    }

    public void UpdateCollection(int aID, Hashtable aNewEntries)
    {
      mIDMap[aID] = aNewEntries;
    }

    public bool UpdateCollectionFromDatabase(int aID)
    {
      bool bFoundInDatabase = false;
      
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Localization", "__GET_LOCALIZED_STRINGS_FOR_ID__"))
          {
              stmt.AddParam("%%DESC_ID%%", aID);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  int prevID = -1;
                  //mFQNMap = new Hashtable();
                  //mIDMap = new Hashtable();
                  Hashtable langs = null;

                  while (reader.Read())
                  {
                      int id = reader.GetInt32("DescriptionID");
                      int langid = reader.GetInt32("LanguageID");
                      string fqn = null;
                      if (!reader.IsDBNull("nm_enum_data"))
                          fqn = reader.GetString("nm_enum_data");
                      string desc = "";
                      if (!reader.IsDBNull("Description"))
                          desc = reader.GetString("Description");
                      //still same string, different lang code
                      if (id == prevID)
                      {
                          Debug.Assert(langs != null);
                          langs.Add(langid, desc);
                      }
                      else
                      {
                          langs = new Hashtable();
                          langs.Add(langid, desc);
                          if (fqn != null)
                              mFQNMap[fqn.ToUpper()] = langs;
                          mIDMap[id] = langs;
                          prevID = id;
                          bFoundInDatabase = true;
                      }

                  }

              }
          }

      }
  
      return bFoundInDatabase;
    }

    private void BuildCol()
    {

      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        using(IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Localization", "__GET_LOCALIZED_STRINGS__"))
        {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
                int prevID = -1;
                mFQNMap = new Hashtable();
                mIDMap = new Hashtable();
                Hashtable langs = null;
                while (reader.Read())
                {
                    int id = reader.GetInt32("DescriptionID");
                    int langid = reader.GetInt32("LanguageID");
                    string fqn = null;
                    if (!reader.IsDBNull("nm_enum_data"))
                        fqn = reader.GetString("nm_enum_data");
                    string desc = "";
                    if (!reader.IsDBNull("Description"))
                        desc = reader.GetString("Description");
                    //still same string, different lang code
                    if (id == prevID)
                    {
                        Debug.Assert(langs != null);
                        langs.Add(langid, desc);
                    }
                    else
                    {
                        langs = new Hashtable();
                        langs.Add(langid, desc);
                        if (fqn != null)
                            mFQNMap.Add(fqn.ToUpper(), langs);
                        mIDMap.Add(id, langs);
                        prevID = id;
                    }

                }
            }
        }
        return;
      }
    }
    
    private Hashtable mFQNMap;
    private Hashtable mIDMap;

  }


  
}
