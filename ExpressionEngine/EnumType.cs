using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Collections.ObjectModel;

namespace MetraTech.ExpressionEngine
{
    public class EnumType : IExpressionEngineTreeNode
    {
        #region Properties
        public readonly EnumSpace Parent;
        public string Name { get; set; }
        public int Id { get; set; }
        public string Description { get; set; }
        public Collection<EnumValue> Values = new Collection<EnumValue>();
        #endregion

        #region GUI Support Properties (should be moved in future)

        public string TreeNodeLabel { get { return Name; } }
        public string Image { get { return "EnumType.png"; } }

        /// <summary>
        /// TOGO Localize
        /// </summary>
        public string ToolTip
        {
            get
            {
                var toolTip = "EnumType";
                if (!string.IsNullOrEmpty(Description))
                    toolTip += "\r\n" + Description;
                if (UserSettings.ShowActualMappings)
                    toolTip += string.Format("\r\n[DatabaseId={0}]", Id);
                return toolTip;
            }
        }
        #endregion

        #region Constructor
        public EnumType(EnumSpace parent, string name, int id, string description)
        {
            Parent = parent;
            Name = name;
            Id = id;
            Description = description;
        }
        #endregion

        #region Methods
        public EnumValue AddValue(string value, int id)
        {
            var enumValue = new EnumValue(this, value, id);
            Values.Add(enumValue);
            return enumValue;
        }

        public string ToExpressionSnippet
        {
            get
            {
                throw new NotImplementedException();
            }
        }

        public void Save(string dirPath)
        {
            throw new NotImplementedException();
            ////var doc = new XmlDocument();
         
            ////var enumSpace = Parent.Name.Replace('\\', '_');
            ////var name = Name.Replace('\\', '_');
            ////if (enumSpace.Contains(@"\") || name.Contains(@"\"))
            ////    throw new Exception("found backslash");
            ////doc.SaveFormatted(string.Format(@"{0}\{1}.{2}.EnumType.xml", dirPath, enumSpace, name));
        }
        #endregion
    }
}
