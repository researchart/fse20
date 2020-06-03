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

namespace DomainPro.Analyst.Interfaces
{
    public class DP_EventArgs : EventArgs
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

        private double time;

        public double Time
        {
            get { return time; }
            set { time = value; }
        }

        public DP_EventArgs(Guid id, Guid parentId, double time)
        {
            Id = id;
            ParentId = parentId;
            Time = time;
        }
    }

    public delegate void DP_ComponentChangedEventHandler(object sender, DP_ComponentChangedEventArgs e);

    public class DP_ComponentChangedEventArgs : DP_EventArgs
    {
        private int blockingMethods;

        public int BlockingMethods
        {
            get { return blockingMethods; }
            set { blockingMethods = value; }
        }

        private int executingMethods;

        public int ExecutingMethods
        {
            get { return executingMethods; }
            set { executingMethods = value; }
        }

        public DP_ComponentChangedEventArgs(Guid id, Guid parentId, double time, int blockingMethods, int executingMethods) :
            base(id, parentId, time)
        {
            BlockingMethods = blockingMethods;
            ExecutingMethods = executingMethods;
        }
    }

    public delegate void DP_MethodChangedEventHandler(object sender, DP_MethodChangedEventArgs e);

    public class DP_MethodChangedEventArgs : DP_EventArgs
    {
        public enum MethodEvent { Invoked, StartedExecution, Returned };

        private MethodEvent evt;

        public MethodEvent Event
        {
            get { return evt; }
            set { evt = value; }
        }

        public DP_MethodChangedEventArgs(Guid id, Guid parentId, double time, MethodEvent evt) :
            base(id, parentId, time)
        {
            Event = evt;
        }
    }

    public delegate void DP_DataChangedEventHandler(object sender, DP_DataChangedEventArgs e);

    public class DP_DataChangedEventArgs : DP_EventArgs
    {
        private object val;

        public object Value
        {
            get { return val; }
            set { val = value; }
        }

        public DP_DataChangedEventArgs(Guid id, Guid parentId, double time, object val) :
            base(id, parentId, time)
        {
            Value = val;
        }
    }

    public delegate void DP_ResourceChangedEventHandler(object sender, DP_ResourceChangedEventArgs e);

    public class DP_ResourceChangedEventArgs : DP_EventArgs
    {
        private int idleCapacity;

        public int IdleCapacity
        {
            get { return idleCapacity; }
            set { idleCapacity = value; }
        }

        private int queueLength;

        public int QueueLength
        {
            get { return queueLength; }
            set { queueLength = value; }
        }

        public DP_ResourceChangedEventArgs(Guid id, Guid parentId, double time, int idleCapacity, int queueLength) :
            base(id, parentId, time)
        {
            IdleCapacity = idleCapacity;
            QueueLength = queueLength;
        }
    }

    
}
