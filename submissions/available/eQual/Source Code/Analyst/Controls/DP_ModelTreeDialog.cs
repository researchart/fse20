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
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using DomainPro.Analyst.Controls;

namespace DomainPro.Analyst.Controls
{
    public partial class DP_ModelTreeDialog : Form
    {
        private DP_SimpleModelTree modelTree;

        public TreeNode Selected
        {
            get { return modelTree.SelectedNode; }
        }

        public DP_ModelTreeDialog()
        {
            InitializeComponent();

            modelTree = new DP_SimpleModelTree(DomainProAnalyst.Instance.SelectedSimulation.ModelType);
            modelTree.Location = new Point(12, 12);
            Controls.Add(modelTree);
        }
    }
}
