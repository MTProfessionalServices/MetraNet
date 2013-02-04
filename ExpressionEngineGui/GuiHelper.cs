using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Properties;
using System.Windows.Forms;
using System.IO;
using System.Drawing;

namespace PropertyGui
{
    public static class GuiHelper
    {
        public static ImageList Images = new ImageList();


        static GuiHelper()
        {
            var hardcodedPath = @"C:\Users\scott\Desktop\Properties\Images";
            var dirInfo = new DirectoryInfo(hardcodedPath);
            if (!dirInfo.Exists)
                throw new Exception("Can't find " + hardcodedPath);

            foreach (var file in dirInfo.GetFiles("*.png"))
            {
                Images.Images.Add(file.Name, Image.FromFile(file.FullName));
            }
        }
        public static TreeNode CreatePropertyTreeNode(Property property, TreeNode parentNode=null)
        {
            var node = new TreeNode(property.Name);
            node.Tag = property;
            node.ToolTipText = property.ToolTip;

            SetImage(node, property.Image);

            if (parentNode != null)
                parentNode.Nodes.Add(node);

            return node;
        }

        public static TreeNode CreateEntityTreeNode(Entity entity, TreeNode parentNode = null)
        {
            var node = new TreeNode(entity.Name);
            node.Tag = entity;
            node.ToolTipText = entity.ToolTip;

            SetImage(node, entity.Name);
            if (parentNode != null)
                parentNode.Nodes.Add(node);

            return node;
        }



        public static TreeNode CreateEntityTypeNode(Entity.EntityTypeEnum type, TreeNode parentNode = null)
        {
            var node = new TreeNode(type.ToString() + "s");
            node.Tag = type;
            //node.ToolTipText = entity.ToolTip;

            SetImage(node, "Folder.png");
            if (parentNode != null)
                parentNode.Nodes.Add(node);

            return node;
        }

        public static void SetImage(TreeNode node, string imageName)
        {
            node.SelectedImageKey = imageName;
            node.ImageKey = imageName;
        }


    }
}
