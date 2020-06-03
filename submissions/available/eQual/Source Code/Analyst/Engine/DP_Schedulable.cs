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
using System.Threading;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Engine
{
    public class DP_Schedulable
    {
        private DP_IResource resource;

        public DP_IResource Resource
        {
            get { return resource; }
            set { resource = value; }
        }

        private DP_IMethod method;

        public DP_IMethod Method
        {
            get { return method; }
            set { method = value; }
        }

        private double completionTime;
        
        public double CompletionTime
        {
            get { return completionTime; }
            set { completionTime = value; }
        }

        private AutoResetEvent blocked = new AutoResetEvent(false);

        private Thread thread;

        private DP_Simulator simulator;

        public DP_Schedulable(DP_Simulator sim, DP_IMethod method)
        {
            simulator = sim;
            Method = method;
            Resource = method.Resource;
            thread = new Thread(new ThreadStart(method.Complete));
            thread.Priority = ThreadPriority.Highest;
            thread.Name = method.Type.Name + ": " + simulator.Simulation.Name;
            simulator.BlockedEvents.Add(thread.ManagedThreadId, blocked);
        }

        public void Schedule()
        {
            if (Method != null)
            {
                Method.Invoke();
            }
            if (Resource == null)
            {
                CompletionTime = Method.ExecutionTime + simulator.Scheduler.Time;
                simulator.Scheduler.Schedule(this);
            }
            else
            {
                Resource.Schedule(this);
            }
        }

        public void Work()
        {
            if (Method != null)
            {
                Method.Work();
            }
        }

        public void Complete()
        {
            if (Resource != null)
            {
                Resource.Complete(this);
            }

            if (Method != null)
            {
                thread.Start();

                WaitHandle[] handles = new WaitHandle[2];
                handles[0] = Method.Completed;
                handles[1] = blocked;
                WaitHandle.WaitAny(handles);
            }
        }
    }
}
