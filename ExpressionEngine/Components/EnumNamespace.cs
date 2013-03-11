using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Components
{ 
    [DataContract (Namespace = "MetraTech")]
    public class EnumNamespace : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The name of the Enumeration namespace. Used to prevent naming collisions
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        public string FullName { get { return Name; } }

        //I'm not sure if this is needed due to bad data or real data
        public string NameWithNoSlashes
        {
            get
            {
                return Name.Replace('/', '_');
            }
        }

        /// <summary>
        /// The description the user enters
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The data enumerated types. This isn't serialized because we want each category in a seperate file 
        /// because we have had production issues when people don't merge things properly
        /// </summary>
        public Collection<EnumCategory> Categories { get; private set; }


        /// <summary>
        /// The Extension that defined the EnumNamespace
        /// </summary>
        public string Extension { get; set; }

        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumNamespace.png"; } }
        #endregion

        #region Constructor
        public EnumNamespace(string name, string description)
        {
            Name = name;
            Description = description;
            Categories =  new Collection<EnumCategory>();
        }

        /// <summary>
        /// This is used to fix things that aren't done properly during deserilizaiton. Specifically
        /// we chose not to serialize Categories because we want each of them in a seperate XML file
        /// for merging, diff'ing etc purposes. Thus we must allocate it here.
        /// </summary>
        ///            deserilization
        public void FixDeserilization()
        {
            if (Categories == null)
                Categories = new Collection<EnumCategory>();
        }
        #endregion

        #region Methods

        public EnumCategory AddCategory(EnumMode enumMode, string name, int id, string description)
        {
            var category = new EnumCategory(this, enumMode, name, id, description);
            Categories.Add(category);
            return category;
        }
        public void AddCategory(EnumCategory enumCategory)
        {
            enumCategory.EnumNamespace = this;
            Categories.Add(enumCategory);
        }
        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "Enum.{0}", Name);
            }
        }

        public bool TryGetEnumCategory(string name, out EnumCategory enumCategory)
        {
            foreach (var category in Categories)
            {
                if (category.Name.Equals(name, StringComparison.InvariantCultureIgnoreCase))
                {
                    enumCategory = category;
                    return true;
                }
            }
            enumCategory = null;
            return false;
        }
        #endregion

        #region IO Methods

        public void SaveInExtension(string extensionsDir)
        {
            var dirPath = IOHelper.GetMetraNetConfigPath(extensionsDir, Extension, "Enumerations");
            Save(dirPath);
        }

        public void Save(string dirPath)
        {
            //A underscore is used so that when alpha sorted (i.e., file system) the namespace occurs before the categories
            var file = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}._.xml", dirPath, NameWithNoSlashes);
            IOHelper.Save(file, this);

            foreach (var category in Categories)
            {
                category.Save(dirPath);
            }
        }

        public static void LoadDirectoryIntoContext(string dirPath, string extension, Context context)
        {
            if (context == null)
                throw new ArgumentException("context");

            foreach (var enumNamespace in LoadDirectory(dirPath, extension, context.DeserilizationMessages))
            {
                context.EnumNamespaces.Add(enumNamespace.Name, enumNamespace);
            }
        }


        /// <summary>
        /// Assumes proper naming!!!! Could do better checking!!!!
        /// If messaages is not null, exceptions will be placed into it otherwise they are thrown.
        /// </summary>
        public static List<EnumNamespace> LoadDirectory(string dirPath, string extension, ValidationMessageCollection messages=null)
        {
            var namespaces = new List<EnumNamespace>();

            if (string.IsNullOrEmpty(dirPath))
                throw new ArgumentException("dirPath is null or empty");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return namespaces;

            var fileInfos = dirInfo.GetFiles("*.xml");
            EnumNamespace ns = null;
            var sortedFileInfos = fileInfos.OrderBy(f => f.Name);
            var nsFileName = string.Empty;
            foreach (var fileInfo in sortedFileInfos)
            {
                if (fileInfo.FullName.EndsWith("._.xml", StringComparison.InvariantCultureIgnoreCase))
                {
                    try
                    {
                        ns = CreateFromFile(fileInfo.FullName);
                    }
                    catch (SerializationException exception)
                    {
                        if (messages == null)
                            throw;
                        messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, fileInfo.FullName), exception);
                    }

                    ns.Extension = extension;
                    namespaces.Add(ns);
                    nsFileName = fileInfo.Name.Substring(0, fileInfo.Name.Length - 5);
                }
                else //it's a enumCategory
                {
                    try
                    {
                        if (!fileInfo.Name.StartsWith(nsFileName, StringComparison.InvariantCultureIgnoreCase))
                            throw new Exception("expected file to start with " + nsFileName);
                        ns.FixDeserilization();
                        var category = EnumCategory.CreateFromFile(fileInfo.FullName);
                        ns.AddCategory(category);
                    }
                    catch (Exception exception)
                    {
                        if (messages == null)
                            throw;
                        messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, fileInfo.FullName), exception);
                    }
                }
            }

            return namespaces;
        }

        public static EnumNamespace CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString(xmlContent);
        }

        public static EnumNamespace CreateFromString(string xmlContent)
        {
            return IOHelper.CreateFromString<EnumNamespace>(xmlContent);
        }
    

        #endregion
    }
}
