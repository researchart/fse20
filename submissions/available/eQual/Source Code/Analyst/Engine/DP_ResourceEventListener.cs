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
using System.Drawing;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;
using System.ComponentModel;
using DomainPro.Analyst.Controls;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Engine
{
    public class DP_ResourceEventListener : DP_EventListener
    {
        BindingList<ResourceGridData> resourceDisplayList = new BindingList<ResourceGridData>();
        //List<DP_PointChart> idleCapacityChartList = new List<DP_PointChart>();
        //List<DP_PointChart> queueLengthChartList = new List<DP_PointChart>();

        public DP_ResourceEventListener()
        {
            seriesNames = new string[3] {
            "",
            "Idle Capacity",
            "Queue Length"};

            foreach (string s in SeriesNames)
            {
                timeChartList.Add(new ArrayList());
            }

            grid.DataSource = resourceDisplayList;
        }

        public void ResourceValueChanged(object sender, DP_ResourceChangedEventArgs e)
        {
            lock (this)
            {
                if (!instanceDict.ContainsKey(e.Id))
                {
                    ResourceGridData data = new ResourceGridData();
                    data.Id = e.Id;
                    data.ParentId = e.ParentId;
                    data.IdleCapacity = e.IdleCapacity;
                    data.QueueLength = e.QueueLength;
                    if (ContextProvider.IsCloudSim)
                    {
                        resourceDisplayList.Add(data);
                        instanceDict.Add(data.Id, resourceDisplayList.Count - 1);

                        CreateTimeChart(1, "Resource Idle Capacity");

                        CreateTimeChart(2, "Resource Queue Length");
                    }
                    else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                    {
                        resourceDisplayList.Add(data);
                        instanceDict.Add(data.Id, resourceDisplayList.Count - 1);

                        CreateTimeChart(1, "Resource Idle Capacity");

                        CreateTimeChart(2, "Resource Queue Length");
                    });

                }

                resourceDisplayList[instanceDict[e.Id]].IdleCapacity = e.IdleCapacity;
                resourceDisplayList[instanceDict[e.Id]].QueueLength = e.QueueLength;
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
                AddTimeChartPoint(1, e.Id, e.Time, e.IdleCapacity);
                AddTimeChartPoint(2, e.Id, e.Time, e.QueueLength);
            }
        }

        public class ResourceGridData
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

            private int idleCapacity;

            [DisplayName("Idle Capacity")]
            public int IdleCapacity
            {
                get { return idleCapacity; }
                set { idleCapacity = value; }
            }

            private int queueLength;

            [DisplayName("Queue Length")]
            public int QueueLength
            {
                get { return queueLength; }
                set { queueLength = value; }
            }
        }
    }
}
