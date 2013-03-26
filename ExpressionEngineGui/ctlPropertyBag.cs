using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;

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
        private Property CurrentProperty = null;
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

            //Init the property editor
            ctlPropertyEditor.OnChangeEvent = PropertyChangeEvent;
            ctlPropertyEditor.Init(Context, PropertyBag);

            //Init and load the tree
            treProperties.Init(Context, mnuContext);
            treProperties.AllowEntityExpand = false;
            treProperties.HideSelection = false;
            LoadTree();
            EnsureNodeSelected();
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

            if (!chkShowReferences.Checked)
                LoadFlat();
            else
                LoadHiearchy();

            treProperties.Sort();
            treProperties.RestoreState();
            treProperties.EndUpdate();
        }

        private void LoadHiearchy()
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
                    eventChargeNode = AddPropertyToHiearchy(eventCharge, null, addedProperties);

                //Add the EventTax
                var eventTax = pv.Properties.Get(PropertyBagConstants.EventTax);
                TreeNode eventTaxNode = null;
                if (eventCharge != null)
                    eventTaxNode = AddPropertyToHiearchy(eventTax, null, addedProperties);

                //Add charges and taxes
                foreach (var property in PropertyBag.Properties)
                {
                    if (property.Type.IsCharge && property.Name != PropertyBagConstants.EventCharge)
                        AddPropertyToHiearchy(property, eventChargeNode, addedProperties);
                    else if (property.Type.IsTax && property.Name != PropertyBagConstants.EventTax)
                        AddPropertyToHiearchy(property, eventTaxNode, addedProperties);
                }
            }
           
            foreach (var property in PropertyBag.Properties)
            {
                //If it's been added, don't add it again
                if (addedProperties.Contains(property))
                    continue;

                //Only add things with property references
                if (property.Type.GetPropertyReferences().Count > 0)
                    AddPropertyToHiearchy(property, null, addedProperties);
            }

            //Add anything that hasn't already been added
            foreach (var property in PropertyBag.Properties)
            {
                if (!addedProperties.Contains(property))
                    AddPropertyToHiearchy(property, null, addedProperties);
            }
        }

        private TreeNode AddPropertyToHiearchy(Property property, TreeNode parentNode, List<Property> addedProperties)
        {
            if (property == null)
                throw new ArgumentException("property is null");

            addedProperties.Add(property);
            var node = treProperties.CreateNode(property, parentNode);
            foreach (var propertyReference in property.Type.GetPropertyReferences())
            {
                var childProperty = property.PropertyCollection.Get(propertyReference.PropertyName);
                if (childProperty != null)
                    AddPropertyToHiearchy(childProperty, node, addedProperties);
            }
            return node;
        }

        private void LoadFlat()
        {
            foreach (var property in PropertyBag.Properties)
            {
                    treProperties.CreateNode(property);
            }
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
            var messages = new ValidationMessageCollection();
            PropertyBag.Validate(false, messages, Context);
            if (messages.Count == 0)
                MessageBox.Show("No validation issues found.", "", MessageBoxButtons.OK, MessageBoxIcon.Information);
            else
                frmValidationMessages.Show(messages);
        }


        private void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadTree();
        }

        #endregion
    }
}
