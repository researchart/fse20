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
    public class DP_ComponentEventListener : DP_EventListener
    {
        BindingList<ComponentGridData> compDisplayList = new BindingList<ComponentGridData>();

        public DP_ComponentEventListener()
        {
            seriesNames = new string[3] {
            "",
            "Blocking Methods",
            "Executing Methods"};

            foreach (string s in SeriesNames)
            {
                timeChartList.Add(new ArrayList());
            }

            grid.DataSource = compDisplayList;
        }

        public void ComponentChanged(object sender, DP_ComponentChangedEventArgs e)
        {
            lock (this)
            {
                if (!instanceDict.ContainsKey(e.Id))
                {
                    ComponentGridData data = new ComponentGridData();
                    data.Id = e.Id;
                    data.ParentId = e.ParentId;
                    if (ContextProvider.IsCloudSim)
                    {
                        compDisplayList.Add(data);
                        instanceDict.Add(e.Id, compDisplayList.Count - 1);

                        CreateTimeChart(1, "Number of Blocking Methods");
                        CreateTimeChart(2, "Number of Executing Methods");
                    }
                    else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                    {
                        compDisplayList.Add(data);
                        instanceDict.Add(e.Id, compDisplayList.Count - 1);

                        CreateTimeChart(1, "Number of Blocking Methods");
                        CreateTimeChart(2, "Number of Executing Methods");
                    });
                }

                compDisplayList[instanceDict[e.Id]].BlockingMethods = e.BlockingMethods;
                compDisplayList[instanceDict[e.Id]].ExecutingMethods = e.ExecutingMethods;
                if (grid.Visible)
                {
                    if (ContextProvider.IsCloudSim)
                    {
                        grid.InvalidateCell(1, instanceDict[e.Id]);
                        grid.InvalidateCell(2, instanceDict[e.Id]);
                    }
                    else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                    {
                        grid.InvalidateCell(1, instanceDict[e.Id]);
                        grid.InvalidateCell(2, instanceDict[e.Id]);
                    });
                }
                AddTimeChartPoint(1, e.Id, e.Time, e.BlockingMethods);
                AddTimeChartPoint(2, e.Id, e.Time, e.ExecutingMethods);
            }
        }

        public class ComponentGridData
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

            private int blockingMethods;

            [DisplayName("Blocking Methods")]
            public int BlockingMethods
            {
                get { return blockingMethods; }
                set { blockingMethods = value; }
            }

            private int executingMethods;

            [DisplayName("Executing Methods")]
            public int ExecutingMethods
            {
                get { return executingMethods; }
                set { executingMethods = value; }
            }

        }

    }
}
