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
    public class DP_SimpleModelTree : TreeView
    {
        public DP_SimpleModelTree(DP_ModelType model)
        {
            Size = new Size(360, 360);
            PathSeparator = ".";
            
            TreeNode rootNode = new TreeNode();
            rootNode.Text = model.Name;
            rootNode.Tag = model;
            Nodes.Add(rootNode);

            foreach (DP_ConcreteType type in model.Structure.Types)
            {
                AddToTree(rootNode, type);
            }
        }

        private void AddToTree(TreeNode parent, DP_ConcreteType type)
        {
            TreeNode newNode = new TreeNode();
            newNode.Text = type.Name;
            newNode.Tag = type;
            parent.Nodes.Add(newNode);
            foreach (DP_ConcreteType subtype in type.Structure.Types)
            {
                AddToTree(newNode, subtype);
            }
        }
    }
}
