using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.Interop.RCD;
using System.IO;
using System.Configuration;
using MetraTech.ActivityServices.Configuration;
using System.Reflection;

namespace MASPerfConfigEditor
{
    public partial class Form1 : Form
    {
        #region Data
        private const string CONFIG_FILENAME = "masperflogging.config";
        #endregion

        #region Members
        private bool mIsDirty = false;


        private System.Configuration.Configuration mCurrentConfig;
        private MASPerfLoggingConfig mCurrentPerfConfig;
        #endregion

        public Form1()
        {
            InitializeComponent();

            AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(CurrentDomain_AssemblyResolve);
        }

        #region Event Handlers
        Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
        {
            Assembly retval = null;

            string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

            if (!searchName.Contains(".DLL"))
            {
                searchName += ".DLL";
            }

            try
            {
                retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
            }
            catch (Exception)
            {
                try
                {
                    AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
                    retval = Assembly.Load(nm);
                }
                catch (Exception)
                {
                    IMTRcd rcd = new MTRcd();
                    IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

                    if (fileList.Count > 0)
                    {
                        AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
                        retval = Assembly.Load(nm2);
                    }
                }
            }

            return retval;
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            AboutBox1 about = new AboutBox1();

            about.ShowDialog();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (mIsDirty)
            {
                DialogResult result = MessageBox.Show("Do you wish to save your changes before you to exit?", "Exiting", MessageBoxButtons.YesNoCancel);

                if (result != System.Windows.Forms.DialogResult.Cancel)
                {
                    if (result == System.Windows.Forms.DialogResult.Yes)
                    {
                        SaveConfig();
                    }

                    Application.Exit();
                }
            }
            else
            {
                if (MessageBox.Show("Are you sure you want to exit?", "Exiting", MessageBoxButtons.YesNo) == System.Windows.Forms.DialogResult.Yes)
                {
                    Application.Exit();
                }
            }

        }

        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveConfig();
        }

        private void reloadConfigToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult res = System.Windows.Forms.DialogResult.Yes;
            if (mIsDirty)
            {
                res = MessageBox.Show("You have unsaved changes.  Are you sure you wish to reload the configuration?  All your changes will be lost.", "Reload", MessageBoxButtons.YesNo);
            }

            if (res == System.Windows.Forms.DialogResult.Yes)
            {
                treeView1.Nodes.Clear();
                mIsDirty = false;

                LoadConfig();
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadConfig();
        }

        private void treeView1_AfterCheck(object sender, TreeViewEventArgs e)
        {
            mIsDirty = true;
        } 
        #endregion

        #region Helpers
        private void LoadConfig()
        {
            IMTRcd rcd = new MTRcd();
            string filePath = Path.Combine(rcd.ConfigDir, @"Logging\ActivityServices\Perf");

            ExeConfigurationFileMap map = new ExeConfigurationFileMap();
            map.ExeConfigFilename = Path.Combine(filePath, CONFIG_FILENAME);
            mCurrentConfig = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
            mCurrentPerfConfig = (MASPerfLoggingConfig)mCurrentConfig.GetSection("MASPerfLoggingConfig");

            IMTRcdFileList fileList = null;

            fileList = rcd.RunQuery(@"config\ActivityServices\*.xml", false);

            CMASConfiguration interfaceConfig;

            SortedDictionary<string, TreeNode> mainNodes = new SortedDictionary<string, TreeNode>(StringComparer.InvariantCultureIgnoreCase);
            SortedDictionary<string, TreeNode> operations = new SortedDictionary<string, TreeNode>(StringComparer.InvariantCultureIgnoreCase);

            foreach (string fileName in fileList)
            {
                interfaceConfig = new CMASConfiguration(fileName);

                foreach (CMASEventService interfaceDef in interfaceConfig.EventServiceDefs.Values)
                {
                    TreeNode node = new TreeNode(interfaceDef.InterfaceName);
                    node.ContextMenuStrip = contextMenuStrip1;

                    if (mCurrentPerfConfig.Services[interfaceDef.InterfaceName] != null)
                    {
                        node.Checked = mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Enabled;
                    }

                    operations.Clear();
                    foreach (string method in interfaceDef.EventMethods.Keys)
                    {
                        TreeNode childNode = new TreeNode(method);
                        childNode.ContextMenuStrip = contextMenuStrip1;

                        if (mCurrentPerfConfig.Services[interfaceDef.InterfaceName] != null &&
                            mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Operations[method] != null)
                        {
                            childNode.Checked = mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Operations[method].Enabled;
                        }

                        operations[childNode.Text] = childNode;
                    }

                    foreach (TreeNode childNode in operations.Values)
                    {
                        node.Nodes.Add(childNode);
                    }

                    mainNodes[node.Text] = node;
                }

                foreach (CMASProceduralService interfaceDef in interfaceConfig.ProceduralServiceDefs.Values)
                {
                    TreeNode node = new TreeNode(interfaceDef.InterfaceName);
                    node.ContextMenuStrip = contextMenuStrip1;

                    if (mCurrentPerfConfig.Services[interfaceDef.InterfaceName] != null)
                    {
                        node.Checked = mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Enabled;
                    }

                    operations.Clear();
                    foreach (string method in interfaceDef.ProceduralMethods.Keys)
                    {
                        TreeNode childNode = new TreeNode(method);
                        childNode.ContextMenuStrip = contextMenuStrip1;

                        if (mCurrentPerfConfig.Services[interfaceDef.InterfaceName] != null &&
                            mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Operations[method] != null)
                        {
                            childNode.Checked = mCurrentPerfConfig.Services[interfaceDef.InterfaceName].Operations[method].Enabled;
                        }

                        operations[childNode.Text] = childNode;
                    }

                    foreach (TreeNode childNode in operations.Values)
                    {
                        node.Nodes.Add(childNode);
                    }

                    mainNodes[node.Text] = node;
                }

                foreach (KeyValuePair<string, CMASCodeService> kvp in interfaceConfig.CodeServiceDefs)
                {
                    TreeNode node = new TreeNode(kvp.Value.ElementName);
                    node.ContextMenuStrip = contextMenuStrip1;

                    if (mCurrentPerfConfig.Services[node.Text] != null)
                    {
                        node.Checked = mCurrentPerfConfig.Services[node.Text].Enabled;
                    }

                    operations.Clear();
                    foreach (CMASCodeInterface codeInterface in kvp.Value.Interfaces)
                    {
                        Type interfaceType = Type.GetType(codeInterface.ContractType, true, true);

                        foreach (MethodInfo method in interfaceType.GetMethods(BindingFlags.Instance | BindingFlags.Public))
                        {
                            TreeNode childNode = new TreeNode(method.Name);
                            childNode.ContextMenuStrip = contextMenuStrip1;

                            if (mCurrentPerfConfig.Services[node.Text] != null &&
                            mCurrentPerfConfig.Services[node.Text].Operations[method.Name] != null)
                            {
                                childNode.Checked = mCurrentPerfConfig.Services[node.Text].Operations[method.Name].Enabled;
                            }

                            operations[childNode.Text] = childNode;
                        }
                    }

                    foreach (TreeNode childNode in operations.Values)
                    {
                        node.Nodes.Add(childNode);
                    }

                    mainNodes[node.Text] = node;
                }

            }

            foreach (TreeNode node in mainNodes.Values)
            {
                treeView1.Nodes.Add(node);
            }
        }

        private void SaveConfig()
        {
            mCurrentPerfConfig.Services.Clear();

            foreach (TreeNode node in treeView1.Nodes)
            {
                if (node.Checked || HasCheckedChildren(node))
                {
                    MASPerfLoggingService svc = new MASPerfLoggingService() { Name = node.Text, Enabled = node.Checked };
                    mCurrentPerfConfig.Services.Add(svc);

                    foreach (TreeNode child in node.Nodes)
                    {
                        if (child.Checked)
                        {
                            MASPerfLoggingOperation operation = new MASPerfLoggingOperation() { Name = child.Text, Enabled = child.Checked };
                            svc.Operations.Add(operation);
                        }
                    }
                }
            }

            mCurrentConfig.Save();

            mIsDirty = false;
        }

        private bool HasCheckedChildren(TreeNode node)
        {
            bool retval = false;

            foreach (TreeNode child in node.Nodes)
            {
                if (child.Checked)
                {
                    retval = true;
                    break;
                }
            }

            return retval;
        }

        
        #endregion

        private void selectAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            TreeNode node = treeView1.SelectedNode;

            if (node.Parent != null)
            {
                node = node.Parent;
            }

            node.Expand();

            node.Checked = true;

            foreach (TreeNode child in node.Nodes)
            {
                child.Checked = true;
            }
        }

        private void clearAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            TreeNode node = treeView1.SelectedNode;

            if (node.Parent != null)
            {
                node = node.Parent;
            }

            node.Collapse();

            node.Checked = false;

            foreach (TreeNode child in node.Nodes)
            {
                child.Checked = false;
            }
        }

        private void expandAllServicesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            treeView1.ExpandAll();
        }

        private void collapseAllServicesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            treeView1.CollapseAll();
        }

        private void treeView1_NodeMouseClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            treeView1.SelectedNode = e.Node;
        }

        private void clearAllServicesMenuItem_Click(object sender, EventArgs e)
        {
            foreach (TreeNode node in treeView1.Nodes)
            {
                node.Checked = false;
                node.Collapse();

                foreach (TreeNode child in node.Nodes)
                {
                    child.Checked = false;
                }
            }
        }

        private void selectAllServicesMenuItem_Click(object sender, EventArgs e)
        {
            foreach (TreeNode node in treeView1.Nodes)
            {
                node.Checked = true;
                node.Expand();

                foreach (TreeNode child in node.Nodes)
                {
                    child.Checked = true;
                }
            }
        }
    }
}
