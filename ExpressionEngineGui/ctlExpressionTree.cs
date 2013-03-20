using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using System.IO;
using System.Drawing;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace PropertyGui
{
    public class ctlExpressionTree : TreeView
    {
        #region Constants
        private const string PropertyListPlaceHolder = "PropertyListPlaceHoder";
        #endregion

        #region Properties
        private Context Context;
        public static ImageList Images = new ImageList();

        public MvcAbstraction.ViewModeType ViewMode { get; set; }
        public string EntityTypeFilter { get; set; }
        public Type PropertyTypeFilter { get; set; }
        public string FunctionFilter { get; set; }
        public bool ShowNamespaces { get; set; }
        public bool AllowEntityExpand { get; set; }
        public ContextMenuStrip EnumValueContextMenu { get; set; }

        //TreeState
        private object LastSelectedNodeTag;
        private List<object> LastExpandedNodeTags = new List<object>(); 
        #endregion

        #region Static Constructor
        static ctlExpressionTree()
        {
            var path = Path.Combine(DemoLoader.DirPath, "Images");
            var dirInfo = new DirectoryInfo(path);
            if (!dirInfo.Exists)
                throw new Exception("Can't find " + path);

            foreach (var file in dirInfo.GetFiles("*.png"))
            {
                Images.Images.Add(file.Name, Image.FromFile(file.FullName));
            }

            //Create an overlay for every image
            Image overlayImage = Images.Images["CoreOverlay.png"];
            var newImages = new List<KeyValuePair<string, Image>>();
            foreach (var key in Images.Images.Keys)
            {
                var image = Images.Images[key];
                var newImage = MvcAbstraction.GetOverlayImage(image, overlayImage);
                var newImageName = GetOverlayImageName(key);
                newImages.Add(new KeyValuePair<string, Image>(newImageName, newImage));
            }

            foreach (var kvp in newImages)
            {
                Images.Images.Add(kvp.Key, kvp.Value);
            }
        }
        #endregion

        #region Constructor
        public ctlExpressionTree()
        {
            ImageList = Images;
            ShowNodeToolTips = true;
            PathSeparator = ".";
            AllowEntityExpand = true;
            HideSelection = false;
        }
        #endregion

        #region Methods
        public void Init(Context context, ContextMenuStrip enumValueMenu)
        {
            Context = context;
            EnumValueContextMenu = enumValueMenu;
        }

        public void LoadTree()
        {
            BeginUpdate();
            ShowRootLines = true;
            Scrollable = true;
            Nodes.Clear();
            switch (ViewMode)
            {
                case MvcAbstraction.ViewModeType.Entities:
                    LoadTreeEntityMode();
                    break;
                case MvcAbstraction.ViewModeType.Functions:
                    LoadTreeFunctionsMode();
                    break;
                case MvcAbstraction.ViewModeType.Properties:
                    LoadTreeProperties();
                    break;
                case MvcAbstraction.ViewModeType.Enumerations:
                    LoadTreeEnums();
                    break;
                case MvcAbstraction.ViewModeType.AQGs:
                    LoadGeneric(Context.Aqgs.Values);
                    break;
                case MvcAbstraction.ViewModeType.UQGs:
                    LoadGeneric(Context.Uqgs.Values);
                    break;
                case MvcAbstraction.ViewModeType.InputsOutputs:
                    LoadInputsOutputs();
                    break;
                case MvcAbstraction.ViewModeType.Emails:
                    LoadGeneric(Context.EmailInstances.Values);
                    break;
                case MvcAbstraction.ViewModeType.Expressions:
                    LoadGeneric(Context.Expressions.Values);
                    break;
                case MvcAbstraction.ViewModeType.PageLayouts:
                    LoadGeneric(Context.PageLayouts.Values);
                    break;
                default:
                    throw new NotImplementedException();
            }
            Sort();

            if (Nodes.Count == 1)
                Nodes[0].Expand();

            EndUpdate();
        }

        private void LoadGeneric(IEnumerable<IExpressionEngineTreeNode> items)
        {
            foreach (var item in items)
            {
                CreateNode(item, null);
            }
        }

        private void LoadInputsOutputs()
        {
            var results = Context.GetExpressionParseResults();
            foreach (var property in results.Parameters)
            {
                var node = CreateNode(property);
                node.SelectedImageKey = property.ImageDirection;
                node.ImageKey = property.ImageDirection;
            }
        }

        private void LoadTreeEnums()
        {
            foreach (var enumCategory in Context.EnumCategories)
            {
                var typeNode = CreateNode(enumCategory, null);
                AddEnumValues(enumCategory, typeNode);
            }
        }

        private void AddEnumValues(EnumCategory enumType, TreeNode parentNode)
        {
            foreach (var value in enumType.Items)
            {
                var node = CreateNode(value, parentNode);
                node.ContextMenuStrip = EnumValueContextMenu;
            }
        }

        private void LoadTreeProperties()
        {
            var properties = Context.GetProperties(PropertyTypeFilter);
            var existingNodes = new Dictionary<string, TreeNode>();
            foreach (var property in properties)
            {
                TreeNode propertyNode;
                if (!existingNodes.TryGetValue(property.Name, out propertyNode))
                {
                    propertyNode = CreateNode(property);
                    existingNodes.Add(property.Name, propertyNode);
                }

                //Add the propertyBag to which it belongs
                CreateNode(property.PropertyBag, propertyNode);
            }
        }

        private void LoadTreeFunctionsMode()
        {
            foreach (var func in Context.Functions)
            {
                if (FunctionFilter != "<All>" && !string.IsNullOrEmpty(FunctionFilter) && FunctionFilter != func.Category)
                    continue;

                CreateNode(func, null);
            }
        }

        private void LoadTreeEntityMode()
        {
            var filter = new List<string>();
            filter.Add(EntityTypeFilter);
            var entities = Context.PropertyBagManager.GetPropertyBags(null, filter, null, PropertyTypeFilter);
            foreach (var entity in entities)
            {
                //Create the propertyBag node
                var entityNode = CreateNode(entity, null);

                //Create the property nodes
                AddProperties(entityNode, entity.Properties, PropertyTypeFilter);
            }
        }

        public void AddProperties(TreeNode parentNode, PropertyCollection properties, Type filter = null)
        {
            foreach (var property in properties)
            {
                if (filter == null || property.Type.IsBaseTypeFilterMatch(filter))
                {
                    var node = CreateNode(property, parentNode);

                    if (property.Type.IsPropertyBag && AllowEntityExpand)
                    {
                        node.Nodes.Add(new TreeNode(PropertyListPlaceHolder));
                    }
                }
            }
        }

        public TreeNode CreateNode(IExpressionEngineTreeNode item, TreeNode parentNode = null)
        {
            var node = new TreeNode();
            node.Tag = item;
            UpdateNode(node);

            //Set the parent
            if (parentNode == null)
                Nodes.Add(node);
            else
                parentNode.Nodes.Add(node);

            if (item is Property)
            {
                var property = (Property)item;

                //If it's an enum, append all of the values
                if (property.Type.IsEnum)
                {
                    var enumType = Context.GetEnumCategory((EnumerationType)property.Type);
                    if (enumType != null)
                        AddEnumValues(enumType, node);
                }

                //Append Units link, if any
                var unitsProperty = property.GetUnitsProperty();
                if (unitsProperty != null)
                {
                    var linkNode = new TreeNode(string.Format("Units PropertyDriven Link: {0}", unitsProperty.Name));
                    linkNode.ToolTipText = "";
                    linkNode.SelectedImageKey = "Link.png";
                    linkNode.ImageKey = "Link.png";
                    node.Nodes.Add(linkNode);
                }

                //Append UoM link, if any
                var uomProperty = property.GetUnitOfMeasureProperty();
                if (uomProperty != null)
                {
                    var linkNode = new TreeNode(string.Format("UoM PropertyDriven Link: {0}", uomProperty.Name));
                    linkNode.ToolTipText = "";
                    linkNode.SelectedImageKey = "Link.png";
                    linkNode.ImageKey = "Link.png";
                    node.Nodes.Add(linkNode);
                }
            }

            return node;
        }

        public void UpdateSelectedNode()
        {
            UpdateNode(SelectedNode);
        }
        public void UpdateNode(TreeNode node)
        {
            var item = (IExpressionEngineTreeNode) node.Tag;
            string label;
            if (ShowNamespaces)
                label = item.FullName;
            else
                label = item.Name;

            if (item is Property)
                label += ((Property)item).Type.ListSuffix;

            node.Text = label;
            node.ToolTipText = item.ToolTip;
            node.SelectedImageKey = item.Image;
            node.ImageKey = item.Image;
        }

        private static string GetOverlayImageName(string name)
        {
            var parts = name.Split('.');
            return parts[0] + "IsCoreOverlay.png";
        }

        public void PreserveState()
        {
            if (SelectedNode == null)
                LastSelectedNodeTag = null;
            else
                LastSelectedNodeTag = SelectedNode.Tag;

            LastExpandedNodeTags.Clear();
            var nodes = this.GetAllNodes();
            foreach (var node in nodes)
            {
              if (node.IsExpanded)  
                  LastExpandedNodeTags.Add(node.Tag);
            }
        }

        public void RestoreState()
        {
            var nodes = this.GetAllNodes();
            foreach (var node in nodes)
            {
                if (node.Nodes.Count > 0 && LastExpandedNodeTags.Contains(node.Tag))
                    node.Expand();
                if (node.Tag.Equals((object)LastSelectedNodeTag))
                    SelectedNode = node;
            }
        }
        #endregion

        #region Events
        protected override void OnBeforeExpand(TreeViewCancelEventArgs e)
        {
            base.OnBeforeExpand(e);

            if (e.Action != TreeViewAction.Expand)
                return;

            var node = e.Node;
            if (node.Nodes.Count == 1 && node.Nodes[0].Text == PropertyListPlaceHolder)
            {
                node.Nodes.Clear();
                var property = (Property)node.Tag;
                var propertyBagTypeName = ((PropertyBagType)property.Type).Name;
                var propertyBag = Context.MasterContext.GetPropertyBag(propertyBagTypeName);
                if (propertyBag == null)
                    return;
                AddProperties(node, propertyBag.Properties);
            }
        }
        #endregion

    }
}
