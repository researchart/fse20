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
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Controls;
using DomainPro.Core.Models;

namespace DomainPro.Analyst.Engine
{
    public abstract class DP_EventListener : DP_IEventListener
    {
        protected List<ArrayList> timeChartList = new List<ArrayList>();
        protected List<DP_BoxPlot> boxPlotList = new List<DP_BoxPlot>();
        protected DP_DataGridView grid;
        protected Dictionary<Guid, int> instanceDict = new Dictionary<Guid, int>();

        protected string[] seriesNames;

        protected string[] SeriesNames
        {
            get { return seriesNames; }
        }

        public DP_EventListener()
        {
            grid = new DP_DataGridView();
            grid.Visible = false;

            grid.DoubleClick += GridDoubleClick;
        }

        public Control Control
        {
            get { return grid; }
        }

        protected void GridDoubleClick(object sender, EventArgs e)
        {
            if (grid.SelectedCells.Count > 0)
            {
                if (grid.SelectedCells[0].ColumnIndex <= 1)
                {
                    if (boxPlotList.Count > 0)
                    {
                        ((Chart)boxPlotList[grid.SelectedCells[0].RowIndex]).FindForm().Show();
                    }
                }
                else
                {
                    ((Chart)timeChartList[grid.SelectedCells[0].ColumnIndex - 1][grid.SelectedCells[0].RowIndex]).FindForm().Show();
                }
            }
        }

        protected void CreateBoxPlot(int[] indices, Guid id, string title)
        {
            DP_BoxPlot chart = new DP_BoxPlot();
            chart.Titles["Box Plot Title"].Text = title;

            foreach (int i in indices)
            {
                chart.AddSeries(SeriesNames[i]);
            }

            DP_ChartWindow chartWin = new DP_ChartWindow();
            chartWin.Controls.Add(chart);
            boxPlotList.Add(chart);
        }

        protected void CreateTimeChart(int index, string title)
        {
            DP_PointChart chart = new DP_PointChart();
            chart.ChartAreas["Chart Area"].AxisY.Title = SeriesNames[index];
            chart.Titles["Point Chart Title"].Text = title;

            Series series = new Series(SeriesNames[index]);
            series.ChartType = SeriesChartType.FastPoint;
            chart.Series.Add(series);
            
            DP_ChartWindow chartWin = new DP_ChartWindow();
            chartWin.Controls.Add(chart);
            timeChartList[index].Add(chart);
        }

        protected void AddTimeChartPoint(int index, Guid id, double time, double value)
        {
            if (ContextProvider.IsCloudSim)
            {
                Series series = ((Chart)timeChartList[index][instanceDict[id]]).Series[SeriesNames[index]];
                if (series.Points.Count > 1 && series.Points[series.Points.Count - 1].XValue == time)
                {
                    series.Points.RemoveAt(series.Points.Count - 1);
                }

                series.Points.Add(new DataPoint(time, value));

                if (boxPlotList.Count > instanceDict[id])
                {
                    Series boxPlotSeries = ((Chart)boxPlotList[instanceDict[id]]).Series.FindByName(SeriesNames[index]);
                    if (boxPlotSeries != null)
                    {
                        boxPlotSeries.Points.Add(new DataPoint(time, value));
                    }
                }
            }
            else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
        {
                Series series = ((Chart)timeChartList[index][instanceDict[id]]).Series[SeriesNames[index]];
                if (series.Points.Count > 1 && series.Points[series.Points.Count - 1].XValue == time)
                {
                    series.Points.RemoveAt(series.Points.Count - 1);
                }

                series.Points.Add(new DataPoint(time, value));

                if (boxPlotList.Count > instanceDict[id])
                {
                    Series boxPlotSeries = ((Chart)boxPlotList[instanceDict[id]]).Series.FindByName(SeriesNames[index]);
                    if (boxPlotSeries != null)
                    {
                        boxPlotSeries.Points.Add(new DataPoint(time, value));
                    }
                }
            });
        }

        public void Export()
        {
            Microsoft.Office.Interop.Excel.Application excel = new Microsoft.Office.Interop.Excel.Application();
            Microsoft.Office.Interop.Excel.Workbook book = excel.Workbooks.Add(Microsoft.Office.Interop.Excel.XlSheetType.xlWorksheet);

            foreach (ArrayList al in timeChartList)
            {
                foreach (DP_PointChart pc in al)
                {

                    Microsoft.Office.Interop.Excel.Worksheet sheet = book.Sheets.Add(Type.Missing, Type.Missing, Type.Missing, Type.Missing) as Microsoft.Office.Interop.Excel.Worksheet;

                    sheet.Cells[1, 1] = "Time";
                    sheet.Cells[1, 2] = "Value";

                    foreach (Series s in pc.Series)
                    {
                        for (int i = 0; i < s.Points.Count; i++)
                        {
                            sheet.Cells[i + 2, 1] = s.Points[i].XValue;
                            sheet.Cells[i + 2, 2] = s.Points[i].YValues[0];
                        }
                    }
                }
            }

            excel.Visible = true;

        }
        public DP_WatchedTypeOutput ExportToText(string watchedTypeName)
        {
            DP_WatchedTypeOutput res = new DP_WatchedTypeOutput();
            res.WatchedTypeName = watchedTypeName;
            int index = 0;
            foreach (ArrayList al in timeChartList)
            {
                index++;
                string name = SeriesNames[index - 1];
                //index in seriesname[timechartlist-1]  
                foreach (DP_PointChart pc in al)
                {
                    foreach (Series s in pc.Series)
                    {
                        DP_WatchedTypeOutput.SeriesData serie = new DP_WatchedTypeOutput.SeriesData();
                        serie.SeriesName = name;
                        for (int i = 0; i < s.Points.Count; i++)
                        {
                            Pair<double, double> val = new Pair<double,double>(s.Points[i].XValue, s.Points[i].YValues[0]);
                            serie.Data.Add(val);
                        }
                        res.Series.Add(serie);
                    }

                }
            }

            //TO DO: exprot this as xml to return 
            //try to see if there are any situations where there are multiple pc 
            return res;
        }
    }
}
