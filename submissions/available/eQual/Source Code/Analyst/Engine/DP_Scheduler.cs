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
using DomainPro.Analyst.Types;

namespace DomainPro.Analyst.Engine
{
    public class DP_Scheduler
    {
        DomainProAnalyst app;

        public double Time
        {
            get { return time; }
            set { time = value; }
        }

        public double NextTime
        {
            get
            {
                if (heap.Count > 0)
                {
                    return heap.Peek().Key;
                }
                else
                {
                    return double.MaxValue;
                }
            }
        }

        public bool Quiescent
        {
            get
            {
                if (heap.Count == 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        private double time;

        private PriorityQueue<double, DP_Schedulable> heap = new PriorityQueue<double, DP_Schedulable>();

        /*
        private class Schedulable
        {
            public Schedulable(double compTime, DP_Method method)
            {
                CompletionTime = compTime;
                Method = method;
            }
            public double CompletionTime;
            public DP_Method Method;
        }
         * */

        public DP_Scheduler()
        {
            app = DomainProAnalyst.Instance;

        }

        public void Schedule(DP_Schedulable sched)
        {
            heap.Enqueue(sched.CompletionTime, sched);
            sched.Work();
        }

        public DP_Schedulable NextImminent()
        {
            if (heap.Count > 0)
            {
                DP_Schedulable next = heap.DequeueValue();
                Time = next.CompletionTime;
                return next;
            }

            return null;
        }

        /*
        private static int CompareSchedulables(DP_Schedulable x, DP_Schedulable y)
        {
            if (x == null)
            {
                if (y == null)
                    return 0;
                else
                    return -1;
            }
            else
            {
                if (y == null)
                {
                    return 1;
                }
                else
                {
                    if (x.CompletionTime < y.CompletionTime)
                        return -1;
                    else if (x.CompletionTime > y.CompletionTime)
                        return 1;
                    else
                        return 0;
                }
            }
        }
         * */
    }
}
