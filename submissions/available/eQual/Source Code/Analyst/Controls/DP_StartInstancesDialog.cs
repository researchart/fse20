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
using System.Reflection;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Controls
{
    public partial class DP_StartInstancesDialog : Form
    {
        private DP_InstanceTree instanceTree;

        public DP_InstanceTree InstanceTree
        {
            get { return instanceTree; }
            set { instanceTree = value; }
        }
        

        /*
        private DP_InstanceTreeNode startComp;

        public DP_InstanceTreeNode StartComp
        {
            get { return startComp; }
            set { startComp = value; }
        }

        private DP_InstanceTreeNode startMethod;

        public DP_InstanceTreeNode StartMethod
        {
            get { return startMethod; }
            set { startMethod = value; }
        }

        private DP_InstanceTreeNode startRsrc;

        public DP_InstanceTreeNode StartRsrc
        {
            get { return startRsrc; }
            set { startRsrc = value; }
        }
         * */

        //private DP_TreeNode dependency;

        /*
        private DP_Simulation simulation;

        public DP_Simulation Simulation
        {
            get { return simulation; }
            set { simulation = value; }
        }
         * */

        private int step = 2;

        public DP_StartInstancesDialog()
        {
            InitializeComponent();

            instanceTree = new DP_InstanceTree(DomainProAnalyst.Instance.SelectedSimulation.ModelType);
            instanceTree.Location = new Point(13, 34);
            instanceTree.Size = new Size(364, 344);
            Controls.Add(instanceTree);

            instanceTree.MethodTree.Hide();
            Controls.Add(instanceTree.MethodTree);

            GoToStep2(null, null);
        }

        /*
        private void Step1()
        {
            selectTypeLabel.Hide();
            instanceTree.Hide();

            simNameLabel.Show();
            simNameTextBox.Show();
            runUntilLabel.Show();
            runUntilTextBox.Show();

            backButton.Enabled = false;
            nextButton.Enabled = true;
            nextButton.Text = "Next";
            
        }
         * */

        /*
        private void GoToStep1(object sender, EventArgs e)
        {
            backButton.Click -= GoToStep1;
            nextButton.Click -= GoToStep3;

            step = 1;
            nextButton.Click += GoToStep2;
            Step1();
        }
         * */

        private void GoToStep2(object sender, EventArgs e)
        {
            if (step == 3)
            {
                instanceTree.MethodTree.Hide();
                backButton.Click -= GoToStep2;
                nextButton.DialogResult = DialogResult.None;
                nextButton.Text = "Next";
            }

            step = 2;
            backButton.Enabled = false;
            nextButton.Click += GoToStep3;
            Step2();
        }

        private void GoToStep3(object sender, EventArgs e)
        {
            if (step == 2)
            {
                instanceTree.Hide();
                backButton.Enabled = true;
                nextButton.Click -= GoToStep3;
                nextButton.Text = "Finish";
            }
                /*
            else if (step == 4)
            {
                backButton.Click -= GoToStep3;
                nextButton.Click -= Finish;
            }
                 * */

            step = 3;
            backButton.Click += GoToStep2;
            nextButton.DialogResult = DialogResult.OK;
            Step3();
        }

        /*
        private void GoToStep4(object sender, EventArgs e)
        {
            backButton.Click -= GoToStep2;
            nextButton.Click -= GoToStep4;
            instanceTree.MethodTree.Hide();
            nextButton.Text = "Finish";

            step = 4;
            backButton.Click += GoToStep3;
            AcceptButton = nextButton;
            Step4();
        }
        */
        /*
        private void ShowTreeStep()
        {
            simNameLabel.Hide();
            simNameTextBox.Hide();
            runUntilLabel.Hide();
            runUntilTextBox.Hide();

            selectTypeLabel.Show();
            

            backButton.Enabled = true;
        }
         * */

        private void Step2()
        {
            instanceTree.Show();
            instructionLabel.Text = "Select types to instantiate at startup:";
            //nextButton.Text = "Next";


            //DP_TreeNode selected = (DP_TreeNode)objectTreeView.SelectedNode;
            //&& selected.type.GetType().IsSubclassOf(typeof(DP_MethodType))
            /*
            if (StartComp != null)
            {
                instanceTree.SelectedNode = StartComp;
                instanceTree.Focus();
                nextButton.Enabled = true;
            }
            else
            {
                nextButton.Enabled = false;
            }
             * */

            
        }

        private void Step3()
        {
            
            instanceTree.MethodTree.Show();
            instructionLabel.Text = "Select methods to begin at startup:";
            

            /*
            if (StartMethod != null)
            {
                instanceTree.SelectedNode = StartMethod;
                instanceTree.Focus();
                nextButton.Enabled = true;
            }
            else
            {
                nextButton.Enabled = false;
            }
             * */

        }

        private void Step4()
        {


            //ShowTreeStep();
            /*
            instructionLabel.Text = "Select resources to instantiate at startup:";
            nextButton.Text = "Finish";

            if (StartRsrc != null)
            {
                instanceTree.SelectedNode = StartRsrc;
                instanceTree.Focus();
                nextButton.Enabled = true;
            }
            else
            {
                nextButton.Enabled = false;
            }
             * */

        }

        //private void Finish(object sender, EventArgs e)
        //{
            /*
            DomainProAnalyst.Instance.SelectedSimulation.SetStartInstances(
                (DP_ConcreteType)StartComp.Type,
                (DP_ConcreteType)StartMethod.Type,
                (DP_ConcreteType)StartRsrc.Type);
             * */
            //Dispose();
        //}

        /*
        private void TypeClicked(object sender, TreeViewEventArgs e)
        {
            DP_InstanceTreeNode selected = (DP_InstanceTreeNode)instanceTree.SelectedNode;
            nextButton.Enabled = false;
            if (step == 2)
            {
                if (selected.Tag.GetType().IsSubclassOf(typeof(DP_ComponentType)))
                {
                    startComp = selected;
                    nextButton.Enabled = true;
                }
            }
            else if (step == 3)
            {
                if (selected.Tag.GetType().IsSubclassOf(typeof(DP_MethodType)))
                {
                    startMethod = selected;
                    nextButton.Enabled = true;
                }
            }
            else if (step == 4)
            {
                if (selected.Tag.GetType().IsSubclassOf(typeof(DP_ResourceType)))
                {
                    startRsrc = selected;
                    nextButton.Enabled = true;
                }
            }
        }
         * */
    }
}
