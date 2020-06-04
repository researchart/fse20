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
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Engine;

namespace DomainPro.Analyst.Objects
{
    public abstract class DP_Method : DP_Object
    {
        public new DP_MethodType Type
        {
            get { return type as DP_MethodType; }
            set { type = value; }
        }

        private DP_IResource resource;

        [DisplayName("Resource Dependency"),
        Category("Simulation"),
        Description("Sets the resource type that the executes the method.")]
        public DP_IResource Resource
        {
            get { return resource; }
            set { resource = value; }
        }

        /*
        private AutoResetEvent blocked = new AutoResetEvent(false);

        public AutoResetEvent Blocked
        {
            get { return blocked; }
        }
         * */

        private ManualResetEvent completed = new ManualResetEvent(false);

        // Completed must be a ManualResetEvent rather than an AutoResetEvent to release all blocked threads
        public ManualResetEvent Completed
        {
            get { return completed; }
        }

        public override void Initialize()
        {
            base.Initialize();

            DP_IObject nextContext = (DP_IObject)this;
            DP_IDependency dependency = null;
            while (dependency == null && nextContext != null)
            {
                IEnumerable<KeyValuePair<Guid, DP_IDependency>> dependencies = nextContext.Dependencies.Where(
                    d => d.Value.Type.Name == Type.ResourceDependency);

                IEnumerator<KeyValuePair<Guid, DP_IDependency>> dependencyEnum = dependencies.GetEnumerator();
                if (dependencyEnum.MoveNext())
                {
                    dependency = dependencyEnum.Current.Value;
                }

                /*
                 * Slow!! The context could contain thousands of objects.
                if (dependency == null)
                {
                    start = DateTime.Now;
                    dependency = (DP_IDependency)nextContext.Objects.Find(
                        delegate(DP_IObject c)
                        {
                            return c.GetType().IsSubclassOf(typeof(DP_IDependency)) &&
                                (c.Type.Name == ((DP_MethodType)Type).RsrcDependencyProp.Value ||
                                c.Type.Name == ((DP_MethodType)Type).RsrcDependencyProp.Value);
                        });
                    end = DateTime.Now;
                    app.Simulator.reflectTime += end - start;
                }
                 * */
                nextContext = nextContext.Context;
            }

            

            if (dependency != null)
            {
                Resource = dependency.Resource;
            }
        }

        public abstract double Duration
        {
            get;
        }

        public abstract void Run();

        private double executionTime = -1;

        public double ExecutionTime
        {
            get
            {
                if (executionTime == -1)
                {
                    executionTime = Duration;
                }
                return executionTime;
            }
        }

        public void Invoke()
        {
            if (Context is DP_Component)
            {
                ((DP_Component)Context).MethodInvoked();
            }
            OnMethodChanged(new DP_MethodChangedEventArgs(
                Id, Context.Id,
                Model.Simulation.Simulator.Scheduler.Time,
                DP_MethodChangedEventArgs.MethodEvent.Invoked));
        }

        public void Work()
        {
            if (Context is DP_Component)
            {
                ((DP_Component)Context).MethodWorking();
            }
            OnMethodChanged(
                new DP_MethodChangedEventArgs(
                    Id, Context.Id,
                    Model.Simulation.Simulator.Scheduler.Time,
                    DP_MethodChangedEventArgs.MethodEvent.StartedExecution));
        }

        public void Complete()
        {
            Run();

            if (Context is DP_Component)
            {
                ((DP_Component)Context).MethodCompleted();
            }

            OnMethodChanged(new DP_MethodChangedEventArgs(
                Id, Context.Id,
                Model.Simulation.Simulator.Scheduler.Time,
                DP_MethodChangedEventArgs.MethodEvent.Returned));

            //DP_MethodType finishedMethod = Type as DP_MethodType;

            foreach (DP_FlowType flow in Type.Flows)
            {
                if (flow.Role1Attached == Type)
                {
                    DP_IObject flowContext = Context;
                    while (flowContext != null && !flowContext.Type.Structure.Types.Contains(flow))
                    {
                        flowContext = flowContext.Context;
                    }

                    if (flowContext == null)
                    {
                        continue;
                    }

                    DP_IFlow flowDef = flowContext.Create(flow.Name) as DP_IFlow;

                    bool trigger = false;
                    try
                    {
                        trigger = flowDef.Trigger(this as DP_IMethod);
                    }
                    catch (Exception e)
                    {
                        DialogResult continueAfterError = MessageBox.Show(
                            "An exception occurred during trigger of flow \"" + flowDef.Type.Name + "\".\n\n" +
                            "Do you want to continue the simulation?\n\n" +
                            "Exception:\n\n" +
                            e.Message,
                            "DomainPro",
                            MessageBoxButtons.YesNo,
                            MessageBoxIcon.Exclamation);

                        if (continueAfterError == DialogResult.No)
                        {
                            Model.Simulation.Status = "Idle";
                            return;
                        }
                    }

                    if (trigger)
                    {
                        DP_IObject methodContext = flowDef.Resolve(this as DP_IMethod);

                        if (methodContext == null)
                        {
                            continue;
                        }

                        DP_IMethod next = methodContext.Create(flow.Role2Attached.Name) as DP_IMethod;

                        try
                        {
                            flowDef.Transfer(this as DP_IMethod, next);
                        }
                        catch (Exception e)
                        {
                            DialogResult continueAfterError = MessageBox.Show(
                                "An exception occurred during transfer of flow \"" + flowDef.Type.Name + "\".\n\n" +
                                "Do you want to continue the simulation?\n\n" +
                                "Exception:\n\n" +
                                e.Message,
                                "DomainPro",
                                MessageBoxButtons.YesNo,
                                MessageBoxIcon.Exclamation);

                            if (continueAfterError == DialogResult.No)
                            {
                                Model.Simulation.Status = "Idle";
                                return;
                            }
                        }

                        //CD+OS: why is this thread never used, or where is it?!
                        //Thread newThread = new Thread(new ThreadStart(next.Complete));
                        //newThread.Priority = ThreadPriority.Highest;
                        //newThread.Name = next.Type.Name + ": " + Model.Simulation.Name;
                        DP_Schedulable schedulable = new DP_Schedulable(Model.Simulation.Simulator, next);
                        schedulable.Schedule();
                    }
                }
            }

            Model.Simulation.Simulator.BlockedEvents.Remove(Thread.CurrentThread.ManagedThreadId);

            Completed.Set();
        }

        public event DP_MethodChangedEventHandler MethodChanged;

        protected void OnMethodChanged(DP_MethodChangedEventArgs e)
        {
            if (MethodChanged != null)
            {
                MethodChanged(this, e);
            }
        }
    }
}
