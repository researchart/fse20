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
using DomainPro.Core.Types;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Objects
{
    public class DP_Resource : DP_Object
    {
        public new DP_ResourceType Type
        {
            get { return type as DP_ResourceType; }
            set { type = value; }
        }

        public event DP_ResourceChangedEventHandler ResourceChanged;

        protected void OnResourceChanged(DP_ResourceChangedEventArgs e)
        {
            if (ResourceChanged != null)
            {
                ResourceChanged(this, e);
            }
        }

        protected class Worker
        {
            private double velocity = 1;

            public double Velocity
            {
                get { return velocity; }
                set { velocity = value; }
            }

            int id;

            public int Id
            {
                get { return id; }
                set { id = value; }
            }
        }

        protected Dictionary<string, ICollection> queues = new Dictionary<string, ICollection>();

        protected Dictionary<DP_Schedulable, Worker> running = new Dictionary<DP_Schedulable, Worker>();

        protected Queue<Worker> idle = new Queue<Worker>();

        public void Schedule(DP_Schedulable sched)
        {
            if (queues[sched.Method.Type.ResourceRequest] is Queue)
            {
                Queue queue = queues[sched.Method.Type.ResourceRequest] as Queue;
                queue.Enqueue(sched);
            }
            else
            {
                Stack stack = queues[sched.Method.Type.ResourceRequest] as Stack;
                stack.Push(sched);
            }
            
            ProcessQueues();
        }

        public void Complete(DP_Schedulable sched)
        {
            Worker idleWorker = running[sched];

            running.Remove(sched);

            idle.Enqueue(idleWorker);

            ProcessQueues();
        }

        private void ProcessQueues()
        {
            Worker[] idleCopy = new Worker[idle.Count];
            idle.CopyTo(idleCopy, 0);
            foreach (Worker worker in idleCopy)
            {
                bool gotWork = false;
                foreach (string processedQueue in Type.Workers[worker.Id].Queues)
                {
                    if (queues[processedQueue].Count > 0)
                    {
                        DP_Schedulable nextSched;
                        if (queues[processedQueue] is Queue)
                        {
                            Queue queue = queues[processedQueue] as Queue;
                            nextSched = queue.Dequeue() as DP_Schedulable;
                        }
                        else
                        {
                            Stack stack = queues[processedQueue] as Stack;
                            nextSched = stack.Pop() as DP_Schedulable;
                        }
                        Worker nextWorker = idle.Dequeue();
                        running.Add(nextSched, worker);
                        nextSched.CompletionTime = nextSched.Method.ExecutionTime / worker.Velocity + Model.Simulation.Simulator.Scheduler.Time;
                        Model.Simulation.Simulator.Scheduler.Schedule(nextSched);
                        OnResourceChanged(new DP_ResourceChangedEventArgs(Id, Context.Id, Model.Simulation.Simulator.Scheduler.Time, idle.Count, queues[processedQueue].Count));
                        gotWork = true;
                        break;
                    }
                }
                if (!gotWork)
                {
                    Worker idleWorker = idle.Dequeue();
                    idle.Enqueue(idleWorker);
                }
            }
            
        }
    }
}
