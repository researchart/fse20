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
    public class DP_InstanceTreeNode : TreeNode
    {
        public TextBox nodeTextBox = new TextBox();

        public TreeNode methodTreeNode;

        public string BoxText
        {
            get { return nodeTextBox.Text; }
            set { nodeTextBox.Text = value; }
        }

        public DP_InstanceTreeNode()
        {
            nodeTextBox.Size = new Size(30, 14);
            nodeTextBox.TextChanged += NodeTextBoxTextChanged;
            nodeTextBox.LostFocus += NodeTextBoxLostFocus; 
        }

        public void NodeTextBoxTextChanged(object sender, EventArgs e)
        {
            if (BoxText == "0")
            {
                methodTreeNode.Parent.Nodes.Remove(methodTreeNode);
                DisableChildNodeTextBoxes();
            }
            else
            {
                if (!((DP_InstanceTreeNode)Parent).methodTreeNode.Nodes.Contains(methodTreeNode))
                {
                    ((DP_InstanceTreeNode)Parent).methodTreeNode.Nodes.Add(methodTreeNode);
                }
                EnableChildNodeTextBoxes();
                
            }
        }

        public void NodeTextBoxLostFocus(object sender, EventArgs e)
        {
            if (BoxText == "")
            {
                BoxText = "0";
            }
        }

        public void SetTextBoxLocation(object sender, EventArgs e)
        {
            nodeTextBox.Location = new Point(TreeView.Width - nodeTextBox.Width - 7, Bounds.Top);
            if (IsVisible)
            {
                nodeTextBox.Show();
            }
            else
            {
                nodeTextBox.Hide();
            }
        }

        public void DisableChildNodeTextBoxes()
        {
            foreach (DP_InstanceTreeNode node in Nodes)
            {
                node.nodeTextBox.Enabled = false;
                if (node.BoxText != "0")
                {
                    node.DisableChildNodeTextBoxes();
                }
            }
        }

        public void EnableChildNodeTextBoxes()
        {
            foreach (DP_InstanceTreeNode node in Nodes)
            {
                node.nodeTextBox.Enabled = true;
                if (node.BoxText != "0")
                {
                    node.EnableChildNodeTextBoxes();
                }
            }
        }
    }
}
