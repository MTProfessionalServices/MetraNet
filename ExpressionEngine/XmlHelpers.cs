using System;
using System.Collections.Generic;
using System.Xml;
using System.Text;
using System.IO;

namespace MetraTech.ExpressionEngine
{
    #region Xml Node Extension Methods

    public static class XmlHelpers
    {
        public static XmlNode GetChildNode(this XmlNode node, string tag)
        {
            XmlNode childNode = node.SelectSingleNode(tag);
            if (childNode == null)
                throw new Exception(string.Format("Unable to find the '{0}' tag.", tag));

            return childNode;
        }

        public static string GetChildTag(this XmlNode node, string tag)
        {
            var childNode = GetChildNode(node, tag);
            return childNode.InnerText;
        }

        public static byte GetChildByte(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            byte value;
            if (!byte.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid byte value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static int GetChildInt(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            int value;
            if (!int.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid int value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static UInt16 GetChildUInt16(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            UInt16 value;
            if (!UInt16.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid UInt16 value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static UInt32 GetChildUInt32(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            UInt32 value;
            if (!UInt32.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid UInt32 value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static double GetChildDouble(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            double value;
            if (!double.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid double value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static float GetChildFloat(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            float value;
            if (!float.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid float value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static bool GetChildBool(this XmlNode node, string tag)
        {
            XmlNode childNode = GetChildNode(node, tag);

            bool value;
            if (!bool.TryParse(childNode.InnerText, out value))
                throw new Exception(string.Format("Invalid boolean value '{0}' for the '{1}' tag.", childNode.InnerText, tag));

            return value;
        }

        public static T GetChildEnum<T>(this XmlNode node, T type, string tag)
        {
            if (!typeof(T).IsEnum)
                throw new ArgumentException("T must be an enumerated type");

            var value = node.GetChildTag(tag);

            try
            {
                return (T)Enum.Parse(typeof(T), value, true);
            }
            catch
            {
                throw new Exception(string.Format("Invalid enum value '{0}' for enum type '{1}' [{2}]", value, type, node.InnerText));
            }
        }

        public static T GetChildEnum<T>(this XmlNode node, string tag)
        {
            if (!typeof(T).IsEnum)
                throw new ArgumentException("T must be an enumerated type");

            var value = node.GetChildTag(tag);

            try
            {
                return (T)Enum.Parse(typeof(T), value, true);
            }
            catch
            {
                throw new Exception(string.Format("Invalid enum value '{0}' for enum type '{1}' [{2}]", value, typeof(T), node.InnerText));
            }
        }

        public static string GetAttribute(this XmlNode node, string tag)
        {
            var attribute = node.Attributes[tag];
            if (attribute == null)
                throw new Exception(string.Format("Unable to find the '{0}' attribute in '{1}'.", tag, node.InnerXml));
            return attribute.Value;
        }

        public static int GetAttributeInt(this XmlNode node, string tag)
        {
            var valueStr = node.GetAttribute(tag);

            int value;
            if (!int.TryParse(valueStr, out value))
                throw new Exception(string.Format("Invalid boolean value '{0}' for the '{1}' tag.", valueStr, tag));

            return value;
        }

        public static XmlNode AddChildNode(this XmlNode node, string tag = null)
        {
            return AddChildNode(node, tag, null);
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, string value)
        {
            XmlNode newNode;
            if (node is XmlDocument)
                newNode = ((XmlDocument)node).CreateElement(tag);
            else
                newNode = node.OwnerDocument.CreateElement(tag);

            newNode.InnerText = value;
            node.AppendChild(newNode);
            return newNode;
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, bool value)
        {
            return node.AddChildNode(tag, value.ToString());
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, double value)
        {
            return node.AddChildNode(tag, value.ToString());
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, float value)
        {
            return node.AddChildNode(tag, value.ToString());
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, int value)
        {
            return node.AddChildNode(tag, value.ToString());
        }
        public static XmlNode AddChildNode(this XmlNode node, string tag, UInt16 value)
        {
            return node.AddChildNode(tag, value.ToString());
        }

        public static XmlAttribute AddAttribute(this XmlNode node, string attributeName, string value)
        {
            XmlAttribute attribute = node.OwnerDocument.CreateAttribute(attributeName);
            attribute.InnerText = value;
            node.Attributes.Append(attribute);
            return attribute;
        }
        #endregion

        #region Xml Document Extension Methods
        public static XmlNode LoadAndGetRootNode(this XmlDocument doc, string filePath, string tag)
        {
            doc.Load(filePath);

            XmlNode rootNode = doc.SelectSingleNode(tag);
            if (rootNode == null)
                throw new Exception("Unable to find root node: " + tag);
            return rootNode;
        }

        public static void SaveFormatted(this XmlDocument doc, string filePath)
        {
            var dirInfo = new DirectoryInfo(Path.GetDirectoryName(filePath));
            if (!dirInfo.Exists)
                dirInfo.Create();

            doc.Save(filePath);
        }

    #endregion

    }
}
