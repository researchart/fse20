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

namespace DomainPro.Analyst.Controls
{
    public partial class DP_TerminationConditionsDialog : Form
    {
        public string MaxSimTimeText
        {
            get { return maxSimTimeText.Text; }
            //set { maxSimTimeText.Text = value; }
        }

        public string MaxRunTimeText
        {
            get { return maxRunTimeText.Text; }
            //set { maxRunTimeText.Text = value; }
        }

        public string MaxCyclesText
        {
            get { return maxCyclesText.Text; }
            //set { maxCyclesText.Text = value; }
        }

        public string CustomConditionText
        {
            get { return customConditionText.Text; }
            //set { customConditionText.Text = value; }
        }

        public DP_TerminationConditionsDialog()
        {
            InitializeComponent();
            maxSimTimeText.Text = DomainProAnalyst.Instance.SelectedSimulation.TerminationConditions.MaxSimTime.ToString();
            maxRunTimeText.Text = DomainProAnalyst.Instance.SelectedSimulation.TerminationConditions.MaxRunTime.ToString();
            maxCyclesText.Text = DomainProAnalyst.Instance.SelectedSimulation.TerminationConditions.MaxCycles.ToString();
            customConditionText.Text = DomainProAnalyst.Instance.SelectedSimulation.TerminationConditions.CustomCondition;
            
            maxSimTimeText.Validating += SimTimeTextValidating;
            maxRunTimeText.Validating += RunTimeTextValidating;
            maxCyclesText.Validating += CyclesTextValidating;
        }

        private void SimTimeTextValidating(object sender, EventArgs e)
        {
            try
            {
                double.Parse(maxSimTimeText.Text);
            }
            catch (Exception)
            {
                maxSimTimeText.Undo();
            }
        }

        private void RunTimeTextValidating(object sender, EventArgs e)
        {
            TimeSpan ts;
            if (!TimeSpan.TryParse(maxRunTimeText.Text, out ts))
            {
                maxRunTimeText.Undo();
            }
        }

        private void CyclesTextValidating(object sender, EventArgs e)
        {
            try
            {
                long.Parse(maxCyclesText.Text);
            }
            catch (Exception)
            {
                maxCyclesText.Undo();
            }
        }

    }
}
