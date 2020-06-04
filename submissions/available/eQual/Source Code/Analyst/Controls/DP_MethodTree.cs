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
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using DomainPro.Analyst.Types;

namespace DomainPro.Analyst.Controls
{
    public class DP_MethodTree : TreeView
    {
        public DP_MethodTree()
        {
            CheckBoxes = true;

            /*
            TreeNode rootNode = new TreeNode();
            rootNode.Text = instanceTree.Nodes[0].Text;
            rootNode.Tag = instanceTree.Nodes[0];
            Nodes.Add(rootNode);

            foreach (DP_InstanceTreeNode instanceNode in instanceTree.Nodes[0].Nodes)
            {
                AddToTree(rootNode, instanceNode);
            }
             * */
        }

        /*
        public void AddToTree(TreeNode parentNode, DP_InstanceTreeNode instanceNode)
        {
            if (instanceNode.BoxText != "0")
            {
                TreeNode newNode = new TreeNode();
                newNode.Text = instanceNode.Text;
                newNode.Tag = instanceNode.Tag;
                parentNode.Nodes.Add(newNode);

                foreach (DP_ConcreteType subType in ((DP_ConcreteType)newNode.Tag).Structure.Types)
                {
                    if (subType.GetType().IsSubclassOf(typeof(DP_MethodType)))
                    {
                        TreeNode newMethodNode = new TreeNode();
                        newMethodNode.Text = subType.Name;
                        newMethodNode.Tag = subType;
                        newNode.Nodes.Add(newMethodNode);
                    }
                }

                foreach (DP_InstanceTreeNode nextInstanceNode in instanceNode.Nodes)
                {
                    AddToTree(newNode, nextInstanceNode);
                }
            }
        }
         * */

        protected override void OnBeforeCheck(TreeViewCancelEventArgs e)
        {
            base.OnBeforeCheck(e);

            if (e.Node.Tag is DP_MethodType)
            {
                if (e.Node.Checked)
                {
                    // The node is being unchecked
                    TreeNode parent = e.Node.Parent;
                    bool foundChecked = false;
                    while (parent != null && !foundChecked)
                    {
                        TreeNode sibling = parent.FirstNode;
                        while (sibling != null && !foundChecked)
                        {
                            if (sibling.Checked && sibling != e.Node)
                            {
                                foundChecked = true;
                            }
                            sibling = sibling.NextNode;
                        }
                        if (!foundChecked)
                        {
                            parent.Checked = false;
                        }
                        parent = parent.Parent;
                    }
                }
                else
                {
                    // The node is being checked
                    TreeNode parent = e.Node.Parent;
                    while (parent != null && !parent.Checked)
                    {
                        parent.Checked = true;
                        parent = parent.Parent;
                    }
                }
            }
            else if (e.Action == TreeViewAction.ByMouse || e.Action == TreeViewAction.ByKeyboard)
            {
                e.Cancel = true;
            }
        }
    }
}
