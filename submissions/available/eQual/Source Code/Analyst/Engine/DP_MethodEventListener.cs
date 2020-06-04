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
using DomainPro.Analyst.Controls;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Engine
{
    public class DP_MethodEventListener : DP_EventListener
    {
        private BindingList<MethodGridData> methodDisplayList = new BindingList<MethodGridData>();
        private Dictionary<Guid, MethodInstanceData> methodInvocations = new Dictionary<Guid, MethodInstanceData>();



        public DP_MethodEventListener()
        {
            seriesNames = new string[10] {
            "",
            "Number of Invocations",
            "Invocation Interval",
            "Average Invocation Interval",
            "Blocking Time",
            "Average Blocking Time",
            "Maximum Blocking Time",
            "Executing Time",
            "Average Executing Time",
            "Maximum Executing Time"};

            foreach (string s in SeriesNames)
            {
                timeChartList.Add(new ArrayList());
            }

            grid.DataSource = methodDisplayList;
        }

        public void MethodChanged(object sender, DP_MethodChangedEventArgs e)
        {
            lock (this)
            {
                if (!instanceDict.ContainsKey(e.ParentId))
                {
                    MethodGridData data = new MethodGridData();
                    data.Id = e.Id;
                    data.ParentId = e.ParentId;
                    if (ContextProvider.IsCloudSim)
                    {
                        methodDisplayList.Add(data);
                        instanceDict.Add(e.ParentId, methodDisplayList.Count - 1);

                        CreateTimeChart(1, "Total Number of Method Invocations");
                        CreateTimeChart(2, "Interval Since Previous Invocation");
                        CreateTimeChart(3, "Average Interval Between Method Invocations");
                        CreateTimeChart(4, "Time Spent Blocking");
                        CreateTimeChart(5, "Average Time Spent Blocking");
                        CreateTimeChart(6, "Maximum Time Spent Blocking");
                        CreateTimeChart(7, "Time Spent Executing");
                        CreateTimeChart(8, "Average Time Spent Executing");
                        CreateTimeChart(9, "Maximum Time Spent Executing");

                        int[] seriesIndices = { 2, 4, 7 };
                        CreateBoxPlot(seriesIndices, e.ParentId, "Method Data");

                    }
                    else
                        DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                   {
                       methodDisplayList.Add(data);
                       instanceDict.Add(e.ParentId, methodDisplayList.Count - 1);

                       CreateTimeChart(1, "Total Number of Method Invocations");
                       CreateTimeChart(2, "Interval Since Previous Invocation");
                       CreateTimeChart(3, "Average Interval Between Method Invocations");
                       CreateTimeChart(4, "Time Spent Blocking");
                       CreateTimeChart(5, "Average Time Spent Blocking");
                       CreateTimeChart(6, "Maximum Time Spent Blocking");
                       CreateTimeChart(7, "Time Spent Executing");
                       CreateTimeChart(8, "Average Time Spent Executing");
                       CreateTimeChart(9, "Maximum Time Spent Executing");

                       int[] seriesIndices = { 2, 4, 7 };
                       CreateBoxPlot(seriesIndices, e.ParentId, "Method Data");

                        /*
                        Series numInvocationsSeries = ((Chart)timeChartList[1][instanceDict[e.ParentId]]).Series["Number of Invocations"];
                        Series lastInvocationSeries = ((Chart)timeChartList[2][instanceDict[e.ParentId]]).Series["Invocation Interval"];
                        Series avgInvocationIntervalSeries = ((Chart)timeChartList[3][instanceDict[e.ParentId]]).Series["Average Invocation Interval"];
                        Series lastBlockingTimeSeries = ((Chart)timeChartList[4][instanceDict[e.ParentId]]).Series["Blocking Time"];
                        Series avgBlockingTimeSeries = ((Chart)timeChartList[5][instanceDict[e.ParentId]]).Series["Average Blocking Time"];
                        Series maxBlockingTimeSeries = ((Chart)timeChartList[6][instanceDict[e.ParentId]]).Series["Maximum Blocking Time"];
                        Series lastExecutingTimeSeries = ((Chart)timeChartList[7][instanceDict[e.ParentId]]).Series["Executing Time"];
                        Series avgExecutingTimeSeries = ((Chart)timeChartList[8][instanceDict[e.ParentId]]).Series["Average Executing Time"];
                        Series maxExecutingTimeSeries = ((Chart)timeChartList[9][instanceDict[e.ParentId]]).Series["Maximum Executing Time"];
                         * */

                   });
                }

                if (e.Event == DP_MethodChangedEventArgs.MethodEvent.Invoked)
                {
                    methodInvocations.Add(e.Id, new MethodInstanceData());
                    methodInvocations[e.Id].InvocationTime = e.Time;
                    int numInv = methodDisplayList[instanceDict[e.ParentId]].NumberOfInvocations;
                    numInv++;
                    double lastInvTime = methodDisplayList[instanceDict[e.ParentId]].lastInvocationTime;
                    double avgInterval = methodDisplayList[instanceDict[e.ParentId]].AverageInterval;
                    double lastInterval = 0;
                    if (lastInvTime != -1)
                    {
                        lastInterval = methodInvocations[e.Id].InvocationTime - lastInvTime;
                        avgInterval = (avgInterval * (numInv - 2) + lastInterval) / (numInv - 1);
                    }
                    methodDisplayList[instanceDict[e.ParentId]].NumberOfInvocations = numInv;
                    methodDisplayList[instanceDict[e.ParentId]].lastInvocationTime = methodInvocations[e.Id].InvocationTime;
                    methodDisplayList[instanceDict[e.ParentId]].LastInvocationInterval = lastInterval;
                    methodDisplayList[instanceDict[e.ParentId]].AverageInterval = avgInterval;
                    if (grid.Visible)
                    {
                        if (ContextProvider.IsCloudSim)
                        {

                        }
                        else
                            DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                       {
                           grid.InvalidateCell(1, instanceDict[e.ParentId]);
                           grid.InvalidateCell(2, instanceDict[e.ParentId]);
                           grid.InvalidateCell(3, instanceDict[e.ParentId]);
                       });
                    }
                    AddTimeChartPoint(1, e.ParentId, e.Time, numInv);
                    AddTimeChartPoint(2, e.ParentId, e.Time, lastInterval);
                    AddTimeChartPoint(3, e.ParentId, e.Time, avgInterval);
                }
                else if (e.Event == DP_MethodChangedEventArgs.MethodEvent.StartedExecution)
                {
                    methodInvocations[e.Id].StartExecutionTime = e.Time;
                    double avgWait = methodDisplayList[instanceDict[e.ParentId]].AverageBlockingTime;
                    double lastWait = methodInvocations[e.Id].StartExecutionTime - methodInvocations[e.Id].InvocationTime;
                    int numInv = methodDisplayList[instanceDict[e.ParentId]].NumberOfInvocations;
                    avgWait = (avgWait * (numInv - 1) + lastWait) / numInv;
                    double maxWait = Math.Max(methodDisplayList[instanceDict[e.ParentId]].MaximumBlockingTime, lastWait);
                    methodDisplayList[instanceDict[e.ParentId]].LastBlockingTime = lastWait;
                    methodDisplayList[instanceDict[e.ParentId]].AverageBlockingTime = avgWait;
                    methodDisplayList[instanceDict[e.ParentId]].MaximumBlockingTime = maxWait;
                    if (grid.Visible)
                    {
                        if (ContextProvider.IsCloudSim)
                        {
                            grid.InvalidateCell(4, instanceDict[e.ParentId]);
                            grid.InvalidateCell(5, instanceDict[e.ParentId]);
                            grid.InvalidateCell(6, instanceDict[e.ParentId]);

                        }
                        else
                            DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                       {
                           grid.InvalidateCell(4, instanceDict[e.ParentId]);
                           grid.InvalidateCell(5, instanceDict[e.ParentId]);
                           grid.InvalidateCell(6, instanceDict[e.ParentId]);
                       });
                    }
                    AddTimeChartPoint(4, e.ParentId, e.Time, lastWait);
                    AddTimeChartPoint(5, e.ParentId, e.Time, avgWait);
                    AddTimeChartPoint(6, e.ParentId, e.Time, maxWait);
                }
                else if (e.Event == DP_MethodChangedEventArgs.MethodEvent.Returned)
                {
                    methodInvocations[e.Id].CompletionTime = e.Time;
                    double avgRun = methodDisplayList[instanceDict[e.ParentId]].AverageExecutingTime;
                    double lastRun = methodInvocations[e.Id].CompletionTime - methodInvocations[e.Id].StartExecutionTime;
                    int numInv = methodDisplayList[instanceDict[e.ParentId]].NumberOfInvocations;
                    avgRun = (avgRun * (numInv - 1) + lastRun) / numInv;
                    double maxRun = Math.Max(methodDisplayList[instanceDict[e.ParentId]].MaximumExecutingTime, lastRun);
                    methodDisplayList[instanceDict[e.ParentId]].LastExecutingTime = lastRun;
                    methodDisplayList[instanceDict[e.ParentId]].AverageExecutingTime = avgRun;
                    methodDisplayList[instanceDict[e.ParentId]].MaximumExecutingTime = maxRun;
                    if (grid.Visible)
                    {
                        if (ContextProvider.IsCloudSim)
                        {
                            grid.InvalidateCell(7, instanceDict[e.ParentId]);
                            grid.InvalidateCell(8, instanceDict[e.ParentId]);
                            grid.InvalidateCell(9, instanceDict[e.ParentId]);
                        }
                        else
                            DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                       {
                           grid.InvalidateCell(7, instanceDict[e.ParentId]);
                           grid.InvalidateCell(8, instanceDict[e.ParentId]);
                           grid.InvalidateCell(9, instanceDict[e.ParentId]);
                       });
                    }
                    AddTimeChartPoint(7, e.ParentId, e.Time, lastRun);
                    AddTimeChartPoint(8, e.ParentId, e.Time, avgRun);
                    AddTimeChartPoint(9, e.ParentId, e.Time, maxRun);
                }
            }
        }

        public class MethodGridData
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

            private int numberOfInvocations;

            [DisplayName("Number of Invocations")]
            public int NumberOfInvocations
            {
                get { return numberOfInvocations; }
                set { numberOfInvocations = value; }
            }

            public double lastInvocationTime = -1;

            private double lastInvocationInterval;

            [DisplayName("Invocation Interval")]
            public double LastInvocationInterval
            {
                get { return lastInvocationInterval; }
                set { lastInvocationInterval = value; }
            }

            private double averageInterval;

            [DisplayName("Avg Invocation Interval")]
            public double AverageInterval
            {
                get { return averageInterval; }
                set { averageInterval = value; }
            }

            private double lastBlockingTime;

            [DisplayName("Blocking Time")]
            public double LastBlockingTime
            {
                get { return lastBlockingTime; }
                set { lastBlockingTime = value; }
            }

            private double averageBlockingTime;

            [DisplayName("Avg Blocking Time")]
            public double AverageBlockingTime
            {
                get { return averageBlockingTime; }
                set { averageBlockingTime = value; }
            }

            private double maximumBlockingTime;

            [DisplayName("Max Blocking Time")]
            public double MaximumBlockingTime
            {
                get { return maximumBlockingTime; }
                set { maximumBlockingTime = value; }
            }

            private double lastExecutingTime;

            [DisplayName("Executing Time")]
            public double LastExecutingTime
            {
                get { return lastExecutingTime; }
                set { lastExecutingTime = value; }
            }

            private double averageExecutingTime;

            [DisplayName("Avg Executing Time")]
            public double AverageExecutingTime
            {
                get { return averageExecutingTime; }
                set { averageExecutingTime = value; }
            }

            private double maximumExecutingTime;

            [DisplayName("Maximum Executing Time")]
            public double MaximumExecutingTime
            {
                get { return maximumExecutingTime; }
                set { maximumExecutingTime = value; }
            }
        }

        private class MethodInstanceData
        {
            private double invocationTime;

            public double InvocationTime
            {
                get { return invocationTime; }
                set { invocationTime = value; }
            }

            private double startExecutionTime;

            public double StartExecutionTime
            {
                get { return startExecutionTime; }
                set { startExecutionTime = value; }
            }

            private double completionTime;

            public double CompletionTime
            {
                get { return completionTime; }
                set { completionTime = value; }
            }
        }

    }
}
