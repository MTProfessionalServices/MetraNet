using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui
{
    public partial class ctlCalculationSequence : UserControl
    {
        #region Propterties
        private ProductViewEntity ProductView;
        private Property CurrentProperty = null;
        #endregion

        #region Constructor
        public ctlCalculationSequence()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(ProductViewEntity productView)
        {
            if (productView == null)
                throw new ArgumentException("productView is null");
            ProductView = productView;
        }

        public void SyncToForm()
        {
            treSequence.BeginUpdate();
            treSequence.Nodes.Clear();
            foreach (var property in ProductView.Properties)
            {
                if (property.IsCalculated)
                    AddNode(property);
            }
            treSequence.EndUpdate();

            lstProperties.BeginUpdate();
            lstProperties.Items.Clear();
            lstProperties.DisplayMember = "Name";
            foreach (var property in ProductView.Properties)
            {
                lstProperties.Items.Add(property);
            }
            lstProperties.EndUpdate();
        }

        public void SyncToObject()
        {
            ProductView.CalculationSequence = new List<string>();
            var nodes = treSequence.GetAllNodes();
            foreach (var treeNode in nodes)
            {
                ProductView.CalculationSequence.Add(((Property) treeNode.Tag).Name);
            }
        }

        public TreeNode AddNode(Property property)
        {
            var node = new TreeNode();
            node.Text = string.Format("{0} = {1}", property.Name, property.CalculationExpression);
            node.ToolTipText = property.Description;
            node.ImageKey = "Edit.png";
            node.SelectedImageKey = "Edit.png";
            node.Tag = property;
            treSequence.Nodes.Add(node);
            return node;
        }
        #endregion

        private void treSequence_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (treSequence.SelectedNode == null)
            {
                CurrentProperty = null;
                return;
            }

            CurrentProperty = (Property) treSequence.SelectedNode.Tag;
            txtExpression.Text = CurrentProperty.CalculationExpression;
        }

        private void lstProperties_DoubleClick(object sender, EventArgs e)
        {
            if (lstProperties.SelectedItem != null)
                txtExpression.Paste("USAGE." + ((Property) lstProperties.SelectedItem).DatabaseName);
        }


        private void lstFunctions_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (lstFunctions.SelectedItem != null)
                txtExpression.Paste(lstFunctions.SelectedItem.ToString());
        }

        private void btnMoveUp_Click(object sender, EventArgs e)
        {
            if (treSequence.SelectedNode == null)
                return;

            int index;
            if (treSequence.SelectedNode.Index == 0)
                index = treSequence.Nodes.Count - 1;
            else
                index = treSequence.SelectedNode.Index - 1;
            
            MoveNode(treSequence.SelectedNode, index);
        }

        private void MoveNode(TreeNode node, int index)
        {
            treSequence.Nodes.RemoveAt(node.Index);
            treSequence.Nodes.Insert(index, node);
            treSequence.SelectedNode = node;
        }

        private void btnMoveDown_Click(object sender, EventArgs e)
        {
            if (treSequence.SelectedNode == null)
                return;

            int index;
            if (treSequence.SelectedNode.Index == treSequence.Nodes.Count - 1)
                index = 0;
            else
                index = treSequence.SelectedNode.Index + 1;

            MoveNode(treSequence.SelectedNode, index);
        }


    }
}
