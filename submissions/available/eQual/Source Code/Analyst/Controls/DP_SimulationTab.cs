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
using System.Xml.Serialization;
using System.Windows.Forms;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Controls
{
    public class DP_SimulationTab : TabPage
    {
        /*
        private DP_Simulation simulation;

        public DP_Simulation Simulation
        {
            get { return simulation; }
            set
            {
                if (simulation != null)
                {
                    Enter -= simulation.PanelClick;
                }

                simulation = value;
                Text = simulation.Name;
                nameText.Text = simulation.Name;
                if (simulation != null)
                {
                    Enter += simulation.PanelClick;
                }
            }
        }
         * */

        public string NameText
        {
            get { return nameText.Text; }
            set { nameText.Text = value; }
        }

        public string StatusText
        {
            get { return statusText.Text; }
            set
            {
                try
                {
                    DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                    {
                        statusText.Text = value;
                    });
                }
                catch (Exception e)
                {
                    
                }
            }
        }

        public string StartedAtText
        {
            get { return startedAtText.Text; }
            set { startedAtText.Text = value; }
        }

        public string RunningTimeText
        {
            get { return runningTimeText.Text; }
            set { runningTimeText.Text = value; }
        }

        public string EstimatedCompletionText
        {
            get { return estimatedCompletionText.Text; }
            set { estimatedCompletionText.Text = value; }
        }

        public string SimulationTimeText
        {
            get { return simulationTimeText.Text; }
            set { simulationTimeText.Text = value; }
        }

        public string SelectedWatchedType
        {
            get
            {
                if (watchedTypeListBox.SelectedItem != null)
                {
                    return watchedTypeListBox.SelectedItem.ToString();
                }
                else
                {
                    return null;
                }
            }
            set
            {
                foreach (object o in watchedTypeListBox.Items)
                {
                    if (o.ToString() == value)
                    {
                        watchedTypeListBox.SelectedItem = o;
                        return;
                    }
                }
                watchedTypeListBox.SelectedItems.Clear();
            }
        }

        public ListBox.ObjectCollection WatchedTypeListItems
        {
            get { return watchedTypeListBox.Items; }
        }

        private TextBox nameText = new TextBox();
        private Label statusText = new Label();
        private Label startedAtText = new Label();
        private Label runningTimeText = new Label();
        private Label estimatedCompletionText = new Label();
        private Label simulationTimeText = new Label();
        private ListBox watchedTypeListBox = new ListBox();

        public event EventHandler NameChanged;
        public event EventHandler WatchedTypeAdded;
        public event EventHandler WatchedTypeChanged;
        public event EventHandler WatchedTypeDeleted;
        public event PropertyValueChangedEventHandler PropertyOverrideChanged;
        public event EventHandler StartInstancesSet;
        public event EventHandler ExportData;

        public event DP_TerminationConditionsEventHandler TerminationConditionsSet;

        public delegate void DP_TerminationConditionsEventHandler(object sender, DP_TerminationConditionsEventArgs e);

        public class DP_TerminationConditionsEventArgs : EventArgs
        {
            private readonly double maxSimTime;

            public double MaxSimTime
            {
                get { return maxSimTime; }
            }

            private readonly TimeSpan maxRunTime;

            public TimeSpan MaxRunTime
            {
                get { return maxRunTime; }
            }

            private readonly long maxCycles;

            public long MaxCycles
            {
                get { return maxCycles; }
            }

            private readonly string customCondition;

            public string CustomCondition
            {
                get { return customCondition; }
            }

            public DP_TerminationConditionsEventArgs(double s, TimeSpan r, long c, string custom)
            {
                maxSimTime = s;
                maxRunTime = r;
                maxCycles = c;
                customCondition = custom;
            }
        }

        //private DP_StartInstancesDialog startInstancesDialog;
        //private DP_NewWatchedTypeDialog newWatchedTypeDialog;
        //private DP_PropertyOverridesDialog propertyOverridesDialog;

        //private DP_WatchedType selectedWatchedType;
    
        public DP_SimulationTab()
        {
            BackColor = Color.White;

            Font font = new Font(
                "Microsoft Sans Serif",
                (float)6.8,
                FontStyle.Regular);

            Label nameLabel = new Label();
            nameLabel.Text = "Name:";
            nameLabel.Location = new Point(5, 10);
            nameLabel.AutoSize = true;
            nameLabel.Font = font;
            Controls.Add(nameLabel);

            nameText.Location = new Point(95, 7);
            nameText.Size = new Size(130, 13);
            nameText.Font = font;
            nameText.TextAlign = HorizontalAlignment.Right;
            Controls.Add(nameText);

            Label statusLabel = new Label();
            statusLabel.Text = "Status:";
            statusLabel.Location = new Point(5, 25);
            statusLabel.AutoSize = true;
            statusLabel.Font = font;
            Controls.Add(statusLabel);

            statusText.Location = new Point(95, 25);
            statusText.Size = new Size(130, 15);
            statusText.Font = font;
            statusText.TextAlign = ContentAlignment.TopRight;
            Controls.Add(statusText);

            Label startedAtLabel = new Label();
            startedAtLabel.Text = "Started At:";
            startedAtLabel.Location = new Point(5, 40);
            startedAtLabel.AutoSize = true;
            startedAtLabel.Font = font;
            Controls.Add(startedAtLabel);

            startedAtText.Location = new Point(95, 40);
            startedAtText.Size = new Size(130, 15);
            startedAtText.Font = font;
            startedAtText.TextAlign = ContentAlignment.TopRight;
            Controls.Add(startedAtText);

            Label runningTimeLabel = new Label();
            runningTimeLabel.Text = "Running Time:";
            runningTimeLabel.Location = new Point(5, 55);
            runningTimeLabel.AutoSize = true;
            runningTimeLabel.Font = font;
            Controls.Add(runningTimeLabel);

            runningTimeText.Location = new Point(95, 55);
            runningTimeText.Size = new Size(130, 15);
            runningTimeText.Font = font;
            runningTimeText.TextAlign = ContentAlignment.TopRight;
            Controls.Add(runningTimeText);

            Label estimatedCompletionLabel = new Label();
            estimatedCompletionLabel.Text = "Estimated Completion:";
            estimatedCompletionLabel.Location = new Point(5, 70);
            estimatedCompletionLabel.AutoSize = true;
            estimatedCompletionLabel.Font = font;
            Controls.Add(estimatedCompletionLabel);

            estimatedCompletionText.Location = new Point(135, 70);
            estimatedCompletionText.Size = new Size(90, 15);
            estimatedCompletionText.Font = font;
            estimatedCompletionText.TextAlign = ContentAlignment.TopRight;
            Controls.Add(estimatedCompletionText);

            Label simulationTimeLabel = new Label();
            simulationTimeLabel.Text = "Simulation Time:";
            simulationTimeLabel.Location = new Point(5, 85);
            simulationTimeLabel.AutoSize = true;
            simulationTimeLabel.Font = font;
            Controls.Add(simulationTimeLabel);

            simulationTimeText.Location = new Point(105, 85);
            simulationTimeText.Size = new Size(120, 15);
            simulationTimeText.Font = font;
            simulationTimeText.TextAlign = ContentAlignment.TopRight;
            Controls.Add(simulationTimeText);

            Button startInstancesButton = new Button();
            startInstancesButton.Text = "Startup Instances...";
            startInstancesButton.Location = new Point(5, 104);
            startInstancesButton.Size = new Size(220, 23);
            startInstancesButton.Font = font;
            startInstancesButton.UseVisualStyleBackColor = true;
            Controls.Add(startInstancesButton);

            Button propertyOverridesButton = new Button();
            propertyOverridesButton.Text = "Property Overrides...";
            propertyOverridesButton.Location = new Point(5, 133);
            propertyOverridesButton.Size = new Size(220, 23);
            propertyOverridesButton.Font = font;
            propertyOverridesButton.UseVisualStyleBackColor = true;
            Controls.Add(propertyOverridesButton);

            Button terminationConditionsButton = new Button();
            terminationConditionsButton.Text = "Termination Conditions...";
            terminationConditionsButton.Location = new Point(5, 162);
            terminationConditionsButton.Size = new Size(220, 23);
            terminationConditionsButton.Font = font;
            terminationConditionsButton.UseVisualStyleBackColor = true;
            Controls.Add(terminationConditionsButton);

            Label watchedTypesLabel = new Label();
            watchedTypesLabel.Text = "Watched Types:";
            watchedTypesLabel.Location = new Point(245, 10);
            watchedTypesLabel.AutoSize = true;
            watchedTypesLabel.Font = font;
            Controls.Add(watchedTypesLabel);

            Button addWatchedTypeButton = new Button();
            addWatchedTypeButton.Text = "Add New...";
            addWatchedTypeButton.Location = new Point(360, 5);
            addWatchedTypeButton.Size = new Size(100, 23);
            addWatchedTypeButton.Font = font;
            addWatchedTypeButton.UseVisualStyleBackColor = true;
            Controls.Add(addWatchedTypeButton);

            watchedTypeListBox.Location = new Point(245, 35);
            watchedTypeListBox.Size = new Size(325, 60);
            watchedTypeListBox.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left;
            watchedTypeListBox.Font = font;
            Controls.Add(watchedTypeListBox);

            Button exportButton = new Button();
            exportButton.Text = "Export to Excel";
            exportButton.Location = new Point(470, 5);
            exportButton.Size = new Size(100, 23);
            exportButton.Font = font;
            exportButton.UseVisualStyleBackColor = true;
            Controls.Add(exportButton);

            nameText.TextChanged += NameTextChanged;
            addWatchedTypeButton.Click += AddWatchedTypeButtonClick;
            startInstancesButton.Click += SetStartInstancesButtonClick;
            propertyOverridesButton.Click += AddPropertyOverridesButtonClick;
            terminationConditionsButton.Click += SetTerminationConditionsButtonClick;
            watchedTypeListBox.SelectedIndexChanged += WatchedTypeListSelectedChanged;
            watchedTypeListBox.KeyUp += WatchedTypeListKeyUp;
            exportButton.Click += ExportButtonClick;
        }

        private void NameTextChanged(object sender, EventArgs e)
        {
            if (NameChanged != null)
            {
                NameChanged(this, e);
            }
        }

        private void WatchedTypeListSelectedChanged(object sender, EventArgs e)
        {
            if (WatchedTypeChanged != null)
            {
                WatchedTypeChanged(this, e);
            }
        }

        private void WatchedTypeListKeyUp(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Delete)
            {
                if (SelectedWatchedType != null)
                {
                    WatchedTypeDeleted(this, e);
                }
            }
        }

        private void AddWatchedTypeButtonClick(object sender, EventArgs e)
        {
            DP_WatchedTypeDialog newWatchedTypeDialog = new DP_WatchedTypeDialog();
            DialogResult newWatched = newWatchedTypeDialog.ShowDialog();
            if (newWatched == DialogResult.OK)
            {
                if (WatchedTypeAdded != null)
                {
                    WatchedTypeAdded(newWatchedTypeDialog, e);
                }
            }
            newWatchedTypeDialog.Dispose();
        }

        private void SetStartInstancesButtonClick(object sender, EventArgs e)
        {
            DP_StartInstancesDialog startInstancesDialog = new DP_StartInstancesDialog();
            DialogResult startInstancesSet = startInstancesDialog.ShowDialog();
            if (startInstancesSet == DialogResult.OK)
            {
                if (StartInstancesSet != null)
                {
                    StartInstancesSet(startInstancesDialog.InstanceTree, e);
                }
            }
            startInstancesDialog.Dispose();
        }

        private void AddPropertyOverridesButtonClick(object sender, EventArgs e)
        {
            DP_PropertyOverridesDialog propertyOverridesDialog = new DP_PropertyOverridesDialog();
            propertyOverridesDialog.PropertyOverrideChanged += PropertyOverrideValueChanged;
            DialogResult propertyOverridesAdded = propertyOverridesDialog.ShowDialog();
            propertyOverridesDialog.Dispose();
        }

        private void PropertyOverrideValueChanged(object sender, PropertyValueChangedEventArgs e)
        {
            if (PropertyOverrideChanged != null)
            {
                PropertyOverrideChanged(sender, e);
            }
            
        }

        private void SetTerminationConditionsButtonClick(object sender, EventArgs e)
        {
            DP_TerminationConditionsDialog terminationConditionsDialog = new DP_TerminationConditionsDialog();
            DialogResult terminationConditionsSet = terminationConditionsDialog.ShowDialog();
            if (terminationConditionsSet == DialogResult.OK)
            {
                if (TerminationConditionsSet != null)
                {
                    TimeSpan ts = TimeSpan.Zero;
                    TimeSpan.TryParse(terminationConditionsDialog.MaxRunTimeText, out ts);
                    TerminationConditionsSet(
                        terminationConditionsDialog,
                        new DP_TerminationConditionsEventArgs(
                            double.Parse(terminationConditionsDialog.MaxSimTimeText),
                            ts,
                            long.Parse(terminationConditionsDialog.MaxCyclesText),
                            terminationConditionsDialog.CustomConditionText));
                }
            }
            terminationConditionsDialog.Dispose();
        }

        private void ExportButtonClick(object sender, EventArgs e)
        {
            if (ExportData != null)
            {
                ExportData(sender, e);
            }
        }

        /*
        public void SetStartInstances(object sender, EventArgs e)
        {
            Guid compId = startInstancesDialog.StartComp.type.Id;
            Guid methodId = startInstancesDialog.StartMethod.type.Id;
            Guid rsrcId = startInstancesDialog.StartRsrc.type.Id;
            startInstancesDialog.Dispose();
            Simulation.SetStartInstances(compId, methodId, rsrcId);
        }
         * */

        /*
        public void AddWatchedType(object sender, EventArgs e)
        {
            DP_WatchedType watched = new DP_WatchedType();
            watched.TypeName = newWatchedTypeDialog.typeNameText.Text;
            newWatchedTypeDialog.Dispose();
            Simulation.AddWatched(watched);
        }
         * */

        /*
        public void AddPropertyOverrides(object sender, EventArgs e)
        {
            List<DP_PropertyOverride> overrides = propertyOverridesDialog.PropertyOverrides;
            propertyOverridesDialog.Dispose();
            Simulation.AddOverrides(overrides);
        }
         * */
    }
}
