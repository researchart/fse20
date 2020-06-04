/*
Copyright 2013 George Edwards

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. 
*/
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Controls
{
    public class DP_InstanceTree : TreeView
    {
        private DP_MethodTree methodTree;

        public DP_MethodTree MethodTree
        {
            get { return methodTree; }
        }

        public DP_InstanceTree(DP_ModelType model)
        {
            methodTree = new DP_MethodTree();
            methodTree.Location = Location;
            methodTree.Size = Size;
            
            DP_InstanceTreeNode instanceRootNode = new DP_InstanceTreeNode();
            instanceRootNode.Text = model.Name;
            instanceRootNode.Tag = model;
            Nodes.Add(instanceRootNode);
            
            instanceRootNode.methodTreeNode = new TreeNode();
            instanceRootNode.methodTreeNode.Text = instanceRootNode.Text;
            instanceRootNode.methodTreeNode.Tag = instanceRootNode.Tag;
            methodTree.Nodes.Add(instanceRootNode.methodTreeNode);

            foreach (DP_ConcreteType type in model.Structure.Types)
            {
                AddToTree(instanceRootNode, type);
            }

            foreach (DP_StartInstance si in DomainProAnalyst.Instance.SelectedSimulation.StartInstances)
            {
                SetInstanceCount(instanceRootNode, si);
            }
        }

        private void SetInstanceCount(DP_InstanceTreeNode parent, DP_StartInstance instance)
        {
            foreach (DP_InstanceTreeNode node in parent.Nodes.Find(instance.Type, false))
            {
                node.BoxText = instance.Count.ToString();
                foreach (string methodName in instance.Methods)
                {
                    foreach (TreeNode methodNode in node.methodTreeNode.Nodes.Find(methodName, false))
                    {
                        methodNode.Checked = true;
                    }
                }

                foreach (DP_StartInstance subinstance in instance.Instances)
                {
                    SetInstanceCount(node as DP_InstanceTreeNode, subinstance);
                }
            }
        }

        private void AddToTree(DP_InstanceTreeNode parent, DP_ConcreteType type)
        {
            Type typeInfo = type.GetType();
            if (typeInfo.IsSubclassOf(typeof(DP_ComponentType)) ||
                typeInfo.IsSubclassOf(typeof(DP_ResourceType)) || 
                typeInfo.IsSubclassOf(typeof(DP_LinkType)) ||
                typeInfo.IsSubclassOf(typeof(DP_DependencyType)))
            {

                DP_InstanceTreeNode newNode = new DP_InstanceTreeNode();
                newNode.Tag = type;
                newNode.Name = type.Name;
                newNode.Text = type.Name;
                parent.Nodes.Add(newNode);
                Controls.Add(newNode.nodeTextBox);

                newNode.methodTreeNode = new TreeNode();
                newNode.methodTreeNode.Text = newNode.Text;
                newNode.methodTreeNode.Tag = newNode.Tag;
                parent.methodTreeNode.Nodes.Add(newNode.methodTreeNode);

                foreach (DP_ConcreteType subType in ((DP_ConcreteType)newNode.methodTreeNode.Tag).Structure.Types)
                {
                    if (subType is DP_MethodType)
                    {
                        TreeNode newMethodNode = new TreeNode();
                        newMethodNode.Name = subType.Name;
                        newMethodNode.Text = subType.Name;
                        newMethodNode.Tag = subType;
                        newNode.methodTreeNode.Nodes.Add(newMethodNode);
                    }
                }

                SizeChanged += newNode.SetTextBoxLocation;
                AfterExpand += newNode.SetTextBoxLocation;
                AfterCollapse += newNode.SetTextBoxLocation;

                newNode.nodeTextBox.Location = new Point(Width - newNode.nodeTextBox.Width - 7, newNode.Bounds.Top);

                foreach (DP_ConcreteType subtype in type.Structure.Types)
                {
                    AddToTree(newNode, subtype);
                }

                newNode.BoxText = "0";
            }
            
        }

        protected override void OnAfterSelect(TreeViewEventArgs e)
        {
            base.OnAfterSelect(e);

            ((DP_InstanceTreeNode)SelectedNode).nodeTextBox.Focus();
            ((DP_InstanceTreeNode)SelectedNode).nodeTextBox.SelectAll();
        }

        protected override void OnSizeChanged(EventArgs e)
        {
            base.OnSizeChanged(e);
            methodTree.Size = Size;
        }

        protected override void OnLocationChanged(EventArgs e)
        {
            base.OnLocationChanged(e);
            methodTree.Location = Location;
        }
    }
}
