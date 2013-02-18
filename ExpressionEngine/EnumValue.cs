using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    public class EnumValue : IExpressionEngineTreeNode
    {
        #region Properties

        /// <summary>
        /// The EnumType to which the value belongs
        /// </summary>
        public readonly EnumType EnumType;

        /// <summary>
        /// The name of the enum value
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// MetraNet enums are repreesnted by an ID that will vary by installation
        /// </summary>
        public int Id { get; set; }

        /// <summary>
        /// The description of the value. TODO: Localize
        /// </summary>
        public string Description { get; set; }
        #endregion

        #region GUI Properties
        /// <summary>
        /// TOGO Localize
        /// </summary>
        public string ToolTip
        {
            get
            {
                var toolTip = Description;
                if (Settings.ShowActualMappings)
                    toolTip += string.Format("[DatabaseId={0}]", Description, Id);
                return toolTip;
            }
        }

        /// <summary>
        /// The 16x16 image associated with the value
        /// </summary>
        public string Image { get { return "EnumValue.png"; } }

        #endregion

        #region Constructor
        public EnumValue(EnumType parent, string value, int id)
        {
            EnumType = parent;
            Name = value;
            Id = id;
        }
        #endregion

        #region Methods
        /// <summary>
        /// Returns the value in a MTSQL format which is used by MVM, MTSQL Pipeline plug-ins and MetraFlow
        /// </summary>
        public string ToMtsql()
        {
            return string.Format("#{0}/{1}/{2}#", EnumType.Parent.Name, EnumType.Name, Name);
        }

        /// <summary>
        /// Returns the value in the proposed future MVM format
        /// </summary>
        public string ToExpressionSnippet
        {
            get
            {
                if (Settings.NewSyntax)
                {
                    var enumSpace = EnumType.Parent.Name.Replace('.', '_');
                    return string.Format("ENUM.{0}.{1}.{2}", enumSpace, EnumType.Name, Name);
                }
                else
                    return ToMtsql();
            }
        }

        public void WriteXmlChildNode(XmlNode parentNode)
        {
            //TODO: We need to write out more stuff
            var valueNode = parentNode.AddChildNode("Value", Name);
        }

        #endregion
    }

}
