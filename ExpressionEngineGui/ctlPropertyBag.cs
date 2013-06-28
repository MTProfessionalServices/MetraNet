using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;
using MetraTech.ExpressionEngine.PropertyBags.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    /// <summary>
    /// Wraps a PropertyBag. Intetent is to drop this into the ProductView form in ICE. That's why it's a 
    /// control and not a form
    /// </summary>
    public partial class ctlPropertyBag : UserControl
    {
        #region Properties
        private Context Context;
        private PropertyBag PropertyBag;
        private ProductViewEntity ProductView { get { return (ProductViewEntity) PropertyBag; } }
        private Property CurrentProperty = null;
        private bool IgnoreChanges = false;
        #endregion

        #region Constructor
        public ctlPropertyBag()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public void Init(Context context, PropertyBag propertyBag)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (propertyBag == null)
                throw new ArgumentException("propertyBag is null");
            Context = context;
            PropertyBag = propertyBag;
            PropertyBag.Context = Context;

            IgnoreChanges = true;
            ((ProductViewEntity)PropertyBag).UpdateFlow(Context);
            ctlFlowEditor.Init(Context, ((ProductViewEntity)PropertyBag).Flow);
            SyncToForm();
            IgnoreChanges = false;
        }
        
        public void SyncToForm()
        {
            IgnoreChanges = true;

            //Init the general stuff
            txtFullName.Text = PropertyBag.FullName;
            cboParent.Text = ProductView.Parent;
            chkUsesCommerceDecisionEngine.Checked = ProductView.UsesCommerceDecisionEngine;
            txtDescription.Text = PropertyBag.Description;
            GuiHelper.LoadEnum<EventType>(cboEventType);
            cboEventType.SelectedItem = ProductView.EventType;

            //Init the filter
            GuiHelper.LoadMetraNetBaseTypes(cboDataTypeFilter, true, true);
            cboDataTypeFilter.SelectedItem = BaseType.Any;

            //Init the property editor
            ctlPropertyEditor.OnChangeEvent = PropertyChangeEvent;
            ctlPropertyEditor.Init(Context, PropertyBag);
            ctlPropertyEditor.OnPropertyCreated = PropertyCreatedEvent;

            //Init and load the tree
            treProperties.Init(Context, mnuContext);
            treProperties.AllowEntityExpand = false;
            treProperties.AllowEnumExpand = false;
            treProperties.HideSelection = false;
            LoadTree();
            EnsureNodeSelected();

            ctlFlowEditor.SyncToForm();
            tabMain.SelectedTab = tabProperties;

            IgnoreChanges = false;
        }

        public void SyncToObject()
        {
            ProductView.Parent = cboParent.Text;
            PropertyBag.Description = txtDescription.Text;
            ProductView.EventType = (EventType)cboEventType.SelectedItem;
            ProductView.UsesCommerceDecisionEngine = chkUsesCommerceDecisionEngine.Checked;
            ctlPropertyEditor.SyncToObject();
            ctlFlowEditor.SyncToObject();
        }

        private void EnsureNodeSelected()
        {
            if (treProperties.SelectedNode == null && treProperties.Nodes.Count > 0)
            {
                ctlPropertyEditor.Visible = true;
                treProperties.SelectedNode = treProperties.Nodes[0];
            }
            else
            {
                ctlPropertyEditor.Visible = false;
            }
        }

        public void LoadTree()
        {
            treProperties.BeginUpdate();
            treProperties.PreserveState();
            treProperties.Nodes.Clear();

            var filter = (BaseType)cboDataTypeFilter.SelectedItem;
            if (!chkShowReferences.Checked)
                LoadFlat(filter);
            else
                LoadHiearchy(filter);

            treProperties.Sort();
            treProperties.RestoreState();
            treProperties.EndUpdate();
        }

        private void LoadHiearchy(BaseType filter)
        {
            var addedProperties = new List<Property>();

            //If it's a ProductView, load the charges
            if (PropertyBag is ProductViewEntity)
            {
                var pv = (ProductViewEntity) PropertyBag;

                //Add the EventCharge
                var eventCharge = pv.GetEventCharge();
                TreeNode eventChargeNode = null;
                if (eventCharge != null)
                    eventChargeNode = AddPropertyToHiearchy(eventCharge, null, addedProperties, filter);

                //Add the EventTax
                var eventTax = pv.Properties.Get(PropertyBagConstants.EventTax);
                TreeNode eventTaxNode = null;
                if (eventCharge != null)
                    eventTaxNode = AddPropertyToHiearchy(eventTax, null, addedProperties, filter);

                //Add charges and taxes
                foreach (var property in PropertyBag.Properties)
                {
                    if (property.Type.IsCharge && property.Name != PropertyBagConstants.EventCharge)
                        AddPropertyToHiearchy(property, eventChargeNode, addedProperties, filter);
                    else if (property.Type.IsTax && property.Name != PropertyBagConstants.EventTax)
                        AddPropertyToHiearchy(property, eventTaxNode, addedProperties, filter);
                }
            }
           
            foreach (var property in PropertyBag.Properties)
            {
                //If it's been added, don't add it again
                if (addedProperties.Contains(property))
                    continue;

                //Only add things with property references
                if (property.Type.GetPropertyLinks().Count > 0)
                    AddPropertyToHiearchy(property, null, addedProperties, filter);
            }

            //Add anything that hasn't already been added
            foreach (var property in PropertyBag.Properties)
            {
                if (!addedProperties.Contains(property))
                    AddPropertyToHiearchy(property, null, addedProperties, filter);
            }
        }

        private TreeNode AddPropertyToHiearchy(Property property, TreeNode parentNode, List<Property> addedProperties, BaseType filter)
        {
            if (property == null)
                throw new ArgumentException("property is null");

            addedProperties.Add(property);
            var node = treProperties.CreateNode(property, filter, parentNode);
            foreach (var propertyLink in property.Type.GetPropertyLinks())
            {
                var childProperty = property.PropertyCollection.Get(propertyLink.GetFullName());
                if (childProperty != null)
                    AddPropertyToHiearchy(childProperty, node, addedProperties, filter);
            }
            return node;
        }

        private void LoadFlat(BaseType filter)
        {
            foreach (var property in PropertyBag.Properties)
            {
                treProperties.CreateNode(property, filter);
            }
        }

        private void RefreshTree()
        {
            ctlPropertyEditor.SyncToObject();
            LoadTree();
        }

        private void Delete()
        {
            if (!treProperties.CheckNodeIsSelected(true))
                return;
            if (((Property)treProperties.SelectedNode.Tag).IsCore)
            {
                MessageBox.Show("Core properties can't be deleted.", null, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            treProperties.SelectedNode.Remove();
            RefreshTree();
        }

        #endregion

        #region Misc Events
        public void PropertyCreatedEvent(Property property)
        {
            btnRefresh_Click(null, null);
            if (treProperties.SelectedNode != null)
                treProperties.SelectedNode.Expand();
            else if (treProperties.Nodes.Count > 0)
                treProperties.SelectedNode = treProperties.Nodes[0];

        }
        #endregion

        #region Misc Events
        private void mnuContext_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem.Equals(mnuExpandAll))
                treProperties.ExpandAll();
            else if (e.ClickedItem.Equals(mnuCollapseAll))
                treProperties.CollapseAll();
        }
        #endregion

        #region Tree Events
        private void treProperties_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (CurrentProperty != null)
                ctlPropertyEditor.SyncToObject();

            CurrentProperty = (Property)treProperties.SelectedNode.Tag;
            ctlPropertyEditor.SyncToForm(CurrentProperty);
            ctlPropertyEditor.Visible = true;
        }
        #endregion

        #region Button Events

        public void PropertyChangeEvent()
        {
            if (treProperties.SelectedNode == null)
                return;

            SuspendLayout();
            treProperties.UpdateSelectedNode();
            ResumeLayout();
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            var newName = PropertyBag.Properties.GetNewSequentialPropertyName();
            var property = PropertyFactory.Create(newName, TypeFactory.CreateString(), true, null);
            var node = treProperties.CreateNode(property, null);
            PropertyBag.Properties.Add(property);
            LoadTree();

            var nodes = treProperties.GetAllNodes();
            foreach (var treeNode in nodes)
            {
                if (treeNode.Text == newName)
                    treProperties.SelectedNode = treeNode;
            }
        }

        private void btnValidate_Click(object sender, EventArgs e)
        {
            SyncToObject();
            var messages = new ValidationMessageCollection();
            Context.GlobalComponentCollection.Load();
            PropertyBag.Validate(messages, Context);
            if (messages.Count == 0)
                MessageBox.Show("No validation issues found.", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
            else
                frmValidationMessages.Show(messages);
        }
       

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            if (!IgnoreChanges)
                RefreshTree();
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }

        private void btnRename_Click(object sender, EventArgs e)
        {
         
        }

        #endregion

        private void tabMain_SelectedIndexChanged(object sender, EventArgs e)
        {
            SyncToObject();
            if (tabMain.SelectedTab.Equals(tabCalculationSequence))
            {
              
            }
        }

        private void cboParent_DropDown(object sender, EventArgs e)
        {
            cboParent.BeginUpdate();
            cboParent.Items.Clear();
            foreach (var pv in Context.PropertyBagManager.PropertyBags)
            {
                if (pv is ProductViewEntity)
                    cboParent.Items.Add(pv.FullName);
            }
            cboParent.EndUpdate();
        }



    }
}
