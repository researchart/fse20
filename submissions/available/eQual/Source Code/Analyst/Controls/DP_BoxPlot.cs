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
    public class DP_BoxPlot : Chart
    {
        public DP_BoxPlot()
        {
            Location = new Point(10, 10);
            Size = new Size(400, 300);
            Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;

            Title title = new Title();
            title.Name = "Box Plot Title";
            title.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold);
            Titles.Add(title);
        }

        public void AddSeries(string seriesName)
        {
            ChartArea chartArea = new ChartArea();
            chartArea.Name = seriesName + " Chart Area";

            chartArea.AxisX.CustomLabels.Add(new CustomLabel(0.1, 1.9, seriesName, 0, LabelMarkStyle.None));
            chartArea.AxisX.InterlacedColor = System.Drawing.Color.WhiteSmoke;
            chartArea.AxisX.IsInterlaced = true;
            chartArea.AxisX.IsLabelAutoFit = false;
            chartArea.AxisX.LabelAutoFitMaxFontSize = 9;
            chartArea.AxisX.LabelAutoFitStyle = LabelAutoFitStyles.DecreaseFont;
            chartArea.AxisX.LabelStyle.Font = new System.Drawing.Font("Segoe UI", 9F, FontStyle.Regular);
            chartArea.AxisX.LineColor = Color.Black;
            chartArea.AxisX.LineWidth = 2;
            chartArea.AxisX.MajorGrid.LineColor = Color.DarkGray;
            chartArea.AxisX.MajorGrid.LineDashStyle = ChartDashStyle.Dash;
            chartArea.AxisX.Minimum = 0;

            chartArea.AxisY.IsLabelAutoFit = false;
            chartArea.AxisY.LabelAutoFitMaxFontSize = 9;
            chartArea.AxisY.LabelAutoFitStyle = LabelAutoFitStyles.DecreaseFont;
            chartArea.AxisY.LineColor = Color.DimGray;
            chartArea.AxisY.LineWidth = 2;
            chartArea.AxisY.MajorGrid.LineColor = Color.DarkGray;
            chartArea.AxisY.MajorGrid.LineDashStyle = ChartDashStyle.Dash;

            chartArea.Position.Auto = false;
            chartArea.InnerPlotPosition.Auto = false;
            chartArea.IsSameFontSizeForAllAxes = true;
            chartArea.ShadowOffset = 5;

            Series series = new Series(seriesName + "Box Plot Series");
            series.BackGradientStyle = GradientStyle.DiagonalLeft;
            series.BackSecondaryColor = Color.ForestGreen;
            series.BorderColor = Color.Black;
            series.BorderWidth = 2;
            series.ChartType = SeriesChartType.BoxPlot;
            series.Color = Color.LawnGreen;
            series.MarkerSize = 8;
            series.MarkerStyle = MarkerStyle.Circle;
            series["PointWidth"] = "0.5";
            series.ChartArea = seriesName + " Chart Area";
            Series.Add(series);

            Series dataSeries = new Series(seriesName);
            dataSeries.Enabled = false;
            Series.Add(dataSeries);

            series["BoxPlotSeries"] = seriesName;

            //chartArea.InnerPlotPosition.Auto = true;

            //chartArea.Position.Width = 100F;
            //chartArea.Position.Height = 100F;
            chartArea.InnerPlotPosition.Width = 70F; // widthPercent;
            chartArea.InnerPlotPosition.X = 20F;
            chartArea.InnerPlotPosition.Height = 80F;
            chartArea.InnerPlotPosition.Y = 2F;

            if (ChartAreas.Count > 0)
            {
                chartArea.AlignmentOrientation = AreaAlignmentOrientations.Horizontal;
                chartArea.AlignWithChartArea = ChartAreas[0].Name;
            }

            ChartAreas.Add(chartArea);

            float widthPercent = 100 / (float)ChartAreas.Count;
            for (int i = 0; i < ChartAreas.Count; i++)
            {
                ChartAreas[i].Position.Width = widthPercent;
                ChartAreas[i].Position.X = widthPercent * i;
                ChartAreas[i].Position.Height = 100F;
                ChartAreas[i].Position.Y = 15F;
            }

            
        }
    }
}
