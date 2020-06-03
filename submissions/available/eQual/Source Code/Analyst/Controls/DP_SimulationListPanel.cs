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
using System.Xml.Serialization;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Controls
{
    public class DP_SimulationListPanel : Panel
    {
        public string NameText
        {
            get { return nameLabel.Text; }
            set { nameLabel.Text = value; }
        }

        public string CreatedTimeText
        {
            get { return createdTimeLabel.Text; }
            set { createdTimeLabel.Text = value; }
        }

        public string LastRunTimeText
        {
            get { return lastRunTimeLabel.Text; }
            set { lastRunTimeLabel.Text = value; }
        }

        public int ProgressBarValue
        {
            get
            { return simProgressBar.Value; }
            set
            { simProgressBar.Value = value; }
        }

        private Label nameLabel = new Label();
        private Label createdLabel = new Label();
        private Label createdTimeLabel = new Label();
        private Label lastRunLabel = new Label();
        private Label lastRunTimeLabel = new Label();
        private ProgressBar simProgressBar = new ProgressBar();

        /*
        private DP_Simulation simulation;

        [XmlIgnore]
        public DP_Simulation Simulation
        {
            get { return simulation; }
            set
            {
                simulation = value;
                nameLabel.Text = simulation.Name;
                createdTimeLabel.Text = simulation.CreatedTime.ToString();
                if (simulation.LastRunTime == DateTime.MinValue)
                {
                    lastRunTimeLabel.Text = "Never";
                }
                else
                {
                    lastRunTimeLabel.Text = simulation.LastRunTime.ToString();
                }
                Location = new Point(10, simulation.Position * 105 + 28);
            }
        }
         * */

        public DP_SimulationListPanel()
        {
            Size = new Size(210, 100);
            Left = 10;
            BorderStyle = BorderStyle.FixedSingle;
            BackColor = Color.White;

            nameLabel.Location = new Point(5, 5);
            nameLabel.AutoSize = true;
            Controls.Add(nameLabel);

            Font font = new Font(
                "Microsoft Sans Serif",
                (float)6.8,
                FontStyle.Regular);

            createdLabel.Text = "Created:";
            createdLabel.Font = font;
            createdLabel.Left = 5;
            createdLabel.Top = 25;
            createdLabel.AutoSize = true;
            Controls.Add(createdLabel);

            createdTimeLabel.Font = font;
            createdTimeLabel.Left = 60;
            createdTimeLabel.Top = 25;
            createdTimeLabel.AutoSize = false;
            createdTimeLabel.Size = new Size(145, 15);
            createdTimeLabel.TextAlign = ContentAlignment.TopRight;
            Controls.Add(createdTimeLabel);

            lastRunLabel.Text = "Last Run:";
            lastRunLabel.Font = font;
            lastRunLabel.Left = 5;
            lastRunLabel.Top = 45;
            lastRunLabel.AutoSize = true;
            Controls.Add(lastRunLabel);

            lastRunTimeLabel.Font = font;
            lastRunTimeLabel.Left = 60;
            lastRunTimeLabel.Top = 45;
            lastRunTimeLabel.AutoSize = false;
            lastRunTimeLabel.Size = new Size(145, 15);
            lastRunTimeLabel.TextAlign = ContentAlignment.TopRight;
            Controls.Add(lastRunTimeLabel);

            simProgressBar.Location = new Point(10, 68);
            simProgressBar.Size = new Size(190, 22);
            simProgressBar.Maximum = 1000;
            simProgressBar.Style = ProgressBarStyle.Continuous;
            Controls.Add(simProgressBar);

            nameLabel.Click += ListPanelClick;
            createdLabel.Click += ListPanelClick;
            createdTimeLabel.Click += ListPanelClick;
            lastRunLabel.Click += ListPanelClick;
            lastRunTimeLabel.Click += ListPanelClick;
            simProgressBar.Click += ListPanelClick;
        }

        public void ListPanelClick(object sender, EventArgs e)
        {
            OnClick(e);
        }

        public void Highlight()
        {
            BackColor = Color.DodgerBlue;
            nameLabel.ForeColor = Color.White;
            createdLabel.ForeColor = Color.White;
            createdTimeLabel.ForeColor = Color.White;
            lastRunLabel.ForeColor = Color.White;
            lastRunTimeLabel.ForeColor = Color.White;
        }

        public void Unhighlight()
        {
            BackColor = Color.White;
            nameLabel.ForeColor = Color.Black;
            createdLabel.ForeColor = Color.Black;
            createdTimeLabel.ForeColor = Color.Black;
            lastRunLabel.ForeColor = Color.Black;
            lastRunTimeLabel.ForeColor = Color.Black;
        }

    }
}
