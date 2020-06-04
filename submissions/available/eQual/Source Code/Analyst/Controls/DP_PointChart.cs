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
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace DomainPro.Analyst.Controls
{
    public class DP_PointChart : Chart
    {
        public DP_PointChart()
        {
            Location = new Point(10, 10);
            Size = new Size(400, 300);
            Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;

            //((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            //this.SuspendLayout();

            ChartArea chartArea = new ChartArea();
            chartArea.Name = "Chart Area";
            chartArea.AxisX.ArrowStyle = AxisArrowStyle.Triangle;
            chartArea.AxisX.Crossing = -1.7976931348623157E+308;
            chartArea.AxisX.InterlacedColor = System.Drawing.Color.WhiteSmoke;
            chartArea.AxisX.IsInterlaced = true;
            chartArea.AxisX.IsLabelAutoFit = false;
            chartArea.AxisX.LabelAutoFitMaxFontSize = 9;
            chartArea.AxisX.LabelAutoFitStyle = LabelAutoFitStyles.DecreaseFont;
            chartArea.AxisX.LabelStyle.Font = new System.Drawing.Font("Segoe UI", 9F, FontStyle.Regular);
            chartArea.AxisX.LineColor = Color.ForestGreen;
            chartArea.AxisX.LineWidth = 2;
            chartArea.AxisX.MajorGrid.LineColor = Color.DarkGray;
            chartArea.AxisX.MajorGrid.LineDashStyle = ChartDashStyle.Dash;
            chartArea.AxisX.Minimum = 0;
            chartArea.AxisX.Title = "Simulation Time";
            chartArea.AxisX.ToolTip = "Represents the amount of simulated time that has passed.";
            chartArea.AxisY.ArrowStyle = AxisArrowStyle.Triangle;
            chartArea.AxisY.Crossing = -1.7976931348623157E+308;
            chartArea.AxisY.IntervalAutoMode = IntervalAutoMode.VariableCount;
            chartArea.AxisY.IsLabelAutoFit = false;
            chartArea.AxisY.LabelAutoFitMaxFontSize = 9;
            chartArea.AxisY.LabelAutoFitStyle = LabelAutoFitStyles.DecreaseFont;
            chartArea.AxisY.LineColor = Color.DimGray;
            chartArea.AxisY.LineWidth = 2;
            chartArea.AxisY.MajorGrid.LineColor = Color.DarkGray;
            chartArea.AxisY.MajorGrid.LineDashStyle = ChartDashStyle.Dash;
            chartArea.InnerPlotPosition.Auto = false;
            chartArea.InnerPlotPosition.Height = 80F;
            chartArea.InnerPlotPosition.Width = 80F;
            chartArea.InnerPlotPosition.X = 12F;
            chartArea.InnerPlotPosition.Y = 2F;
            chartArea.IsSameFontSizeForAllAxes = true;
            chartArea.ShadowOffset = 5;
            ChartAreas.Add(chartArea);

            Title title = new Title();
            title.Name = "Point Chart Title";
            title.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            Titles.Add(title);
                    
        }
    }
}
