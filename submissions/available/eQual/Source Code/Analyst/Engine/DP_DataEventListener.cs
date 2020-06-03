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
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Controls;

namespace DomainPro.Analyst.Engine
{
    public class DP_DataEventListener : DP_EventListener
    {
        BindingList<DataGridData> dataDisplayList = new BindingList<DataGridData>();

        public DP_DataEventListener()
        {
            seriesNames = new string[2] {
            "",
            "Value"};

            foreach (string s in SeriesNames)
            {
                timeChartList.Add(new ArrayList());
            }

            grid.DataSource = dataDisplayList;
        }

        public void DataValueChanged(object sender, DP_DataChangedEventArgs e)
        {
            lock (this)
            {
                Guid id = e.Id;
                Guid parentId = e.ParentId;
                object val = e.Value;

                if (!instanceDict.ContainsKey(id))
                {
                    DataGridData data = new DataGridData();
                    data.Id = id;
                    data.ParentId = parentId;
                    data.Value = val.ToString();
                    if (ContextProvider.IsCloudSim)
                    {
                        dataDisplayList.Add(data);
                        instanceDict.Add(id, dataDisplayList.Count - 1);

                        DP_PointChart dataValueChart = new DP_PointChart();
                        dataValueChart.ChartAreas["Chart Area"].AxisY.Title = "Value";
                        dataValueChart.ChartAreas["Chart Area"].AxisY.ToolTip = "Represents the value stored in the data instance.";
                        dataValueChart.Titles["Point Chart Title"].Text = "Data Value";

                        Series dataValueSeries = new Series("Data Value");

                        if (e.Value is int)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, (int)e.Value));
                        }
                        else if (e.Value is double)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, (double)e.Value));
                        }
                        else if (e.Value is bool)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, ((bool)e.Value) == true ? 1 : 0));
                        }

                        dataValueSeries.ChartType = SeriesChartType.FastPoint;
                        dataValueChart.Series.Add(dataValueSeries);

                        DP_ChartWindow dataValueChartWin = new DP_ChartWindow();
                        dataValueChartWin.Controls.Add(dataValueChart);

                        timeChartList[1].Add(dataValueChart);
                    }
                    else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                    {
                        dataDisplayList.Add(data);
                    instanceDict.Add(id, dataDisplayList.Count - 1);

                    DP_PointChart dataValueChart = new DP_PointChart();
                    dataValueChart.ChartAreas["Chart Area"].AxisY.Title = "Value";
                    dataValueChart.ChartAreas["Chart Area"].AxisY.ToolTip = "Represents the value stored in the data instance.";
                    dataValueChart.Titles["Point Chart Title"].Text = "Data Value";

                    Series dataValueSeries = new Series("Data Value");

                    if (e.Value is int)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, (int)e.Value));
                    }
                    else if (e.Value is double)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, (double)e.Value));
                    }
                    else if (e.Value is bool)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, ((bool)e.Value) == true ? 1 : 0));
                    }

                    dataValueSeries.ChartType = SeriesChartType.FastPoint;
                    dataValueChart.Series.Add(dataValueSeries);

                    DP_ChartWindow dataValueChartWin = new DP_ChartWindow();
                    dataValueChartWin.Controls.Add(dataValueChart);

                    timeChartList[1].Add(dataValueChart);
                    });
                }
                else
                {
                    if (ContextProvider.IsCloudSim)
                    {
                        dataDisplayList[instanceDict[id]].Value = val.ToString();

                        Series dataValueSeries = ((Chart)timeChartList[1][instanceDict[e.Id]]).Series["Data Value"];
                        // CD: added "dataValueSeries.Points.Count > 0" to capture when count = 0, not sure when/why that happens
                        if (dataValueSeries.Points.Count > 0 && dataValueSeries.Points[dataValueSeries.Points.Count - 1].XValue == e.Time)
                        {
                            dataValueSeries.Points.RemoveAt(dataValueSeries.Points.Count - 1);
                        }

                        if (e.Value is int)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, (int)e.Value));
                        }
                        else if (e.Value is double)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, (double)e.Value));
                        }
                        else if (e.Value is bool)
                        {
                            dataValueSeries.Points.Add(new DataPoint(e.Time, ((bool)e.Value) == true ? 1 : 0));
                        }
                }
                    else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                    {
                        dataDisplayList[instanceDict[id]].Value = val.ToString();

                    Series dataValueSeries = ((Chart)timeChartList[1][instanceDict[e.Id]]).Series["Data Value"];
                    // CD: added "dataValueSeries.Points.Count > 0" to capture when count = 0, not sure when/why that happens
                    if (dataValueSeries.Points.Count > 0 && dataValueSeries.Points[dataValueSeries.Points.Count - 1].XValue == e.Time)
                    {
                        dataValueSeries.Points.RemoveAt(dataValueSeries.Points.Count - 1);
                    }

                    if (e.Value is int)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, (int)e.Value));
                    }
                    else if (e.Value is double)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, (double)e.Value));
                    }
                    else if (e.Value is bool)
                    {
                        dataValueSeries.Points.Add(new DataPoint(e.Time, ((bool)e.Value) == true ? 1 : 0));
                    }
                    });
                }

                if (grid.Visible)
                {
                    if (ContextProvider.IsCloudSim)
                    {
                        grid.InvalidateCell(1, instanceDict[id]);
                    }
                    else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                    {
                    grid.InvalidateCell(1, instanceDict[id]);
                    });
                }
            }
        }

        public class DataGridData
        {
            private Guid id;

            public Guid Id
            {
                get { return id; }
                set { id = value; }
            }

            private Guid parentId;

            public Guid ParentId
            {
                get { return parentId; }
                set { parentId = value; }
            }

            private string val;

            public string Value
            {
                get { return val; }
                set { val = value; }
            }
        }
    }
}
