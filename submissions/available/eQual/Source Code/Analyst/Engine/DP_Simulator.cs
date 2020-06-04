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
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Reflection;
using System.Windows.Forms;
using System.Timers;
using System.Threading;
using DomainPro.Analyst;
using DomainPro.Analyst.Types;
using DomainPro.Analyst.Controls;
using DomainPro.Analyst.Interfaces;
using DomainPro.Analyst.Objects;

namespace DomainPro.Analyst.Engine
{
    public class DP_Simulator
    {
        private DP_Scheduler scheduler;

        public DP_Scheduler Scheduler
        {
            get { return scheduler; }
            set { scheduler = value; }
        }

        private DP_Random random = new DP_Random();

        public DP_Random Random
        {
            get
            {
                return random;
            }
        }

        private DP_Simulation simulation;

        public DP_Simulation Simulation
        {
            get { return simulation; }
            set { simulation = value; }
        }

        private bool Terminate
        {
            get
            {
                if (Simulation.TerminationConditions.MaxSimTime > 0 &&
                    Scheduler.NextTime > Simulation.TerminationConditions.MaxSimTime)
                {
                    Simulation.Status = "Idle";
                    return true;
                }
                else if (Simulation.TerminationConditions.MaxRunTime > TimeSpan.Zero &&
                    Simulation.RunningTime > Simulation.TerminationConditions.MaxRunTime)
                {
                    Simulation.Status = "Idle";
                    return true;
                }
                else if (Simulation.TerminationConditions.MaxCycles > 0 &&
                    cycles >= Simulation.TerminationConditions.MaxCycles)
                {
                    Simulation.Status = "Idle";
                    return true;
                }

                return false;
            }
        }

        private Dictionary<int, AutoResetEvent> blockedEvents = new Dictionary<int, AutoResetEvent>();

        public Dictionary<int, AutoResetEvent> BlockedEvents
        {
            get { return blockedEvents; }
            set { blockedEvents = value; }
        }

        private SimClock clock;
        private SimClock cloudClock;
        private DomainProAnalyst app;
        private DP_SimulationRun run;
        private long cycles;

        public DP_Simulator(DP_Simulation simulation)
        {
            app = DomainProAnalyst.Instance;
            Random.SeedFromSystemTime();
            scheduler = new DP_Scheduler();
            Simulation = simulation;
        }

        //public DateTime creationTime = DateTime.MinValue;

        //public DateTime reflectTime = DateTime.MinValue;
        public void RunForCloud()
        {
            if (Simulation == null)
            {
                return;
            }
            
                if (Simulation.Status == "Idle")
                {
                    InitializeForCloud();
                }

                Simulation.Status = "Executing";

                cloudClock.Start();
                while (
                    !(Scheduler.Quiescent && BlockedEvents.Count == 0) &&
                    Simulation.Status != "Paused" &&
                    Simulation.Status != "Idle")
                {
                    if (Scheduler.Quiescent)
                    {
                        Thread.Yield();
                    }
                    Step();
                }
                cloudClock.Stop();

                if (Scheduler.Quiescent ||
                    Simulation.Status == "Idle")
                {
                    Complete();
                }
            
           
        }
        private void InitializeForCloud()
        {
            //Simulation.LastRunTime = DateTime.Now;
            //Simulation.RunningTime = TimeSpan.Zero;
            //Simulation.SimulationTime = 0;
            //Simulation.Progress = 0;


            run = new DP_SimulationRun();
            run.StartTime = Simulation.LastRunTime;
            Simulation.Runs.Add(run);
            Simulation.InitializeNewListenersForCloud();

            clock = new SimClock(this);

            CreateStartInstancesForCloud();

        }
        public void Run()
        {
            if (Simulation == null)
            {
                return;
            }
            try
            {
                if (Simulation.Status == "Idle")
                {
                    Initialize();
                }

                Simulation.Status = "Executing";

                clock.Start();
                while (
                    !(Scheduler.Quiescent && BlockedEvents.Count == 0) &&
                    Simulation.Status != "Paused" &&
                    Simulation.Status != "Idle")
                {
                    if (Scheduler.Quiescent)
                    {
                        Thread.Yield();
                    }
                    Step();
                }
                clock.Stop();

                if (Scheduler.Quiescent ||
                    Simulation.Status == "Idle")
                {
                    Complete();
                }
            }
            catch (Exception ex)
            {
                string filePath = @"C:\Error.text";
                using (StreamWriter writer = new StreamWriter(filePath, true))
                {
                    writer.WriteLine("Message :" + ex.Message + "<br/>" + Environment.NewLine + "StackTrace :" + ex.StackTrace +
                       "" + Environment.NewLine + "Date :" + DateTime.Now.ToString());
                    writer.WriteLine(Environment.NewLine + "-----------------------------------------------------------------------------" + Environment.NewLine);
                }
            }


        }
        public void Run_()
        {
            if (Simulation == null)
            {
                return;
            }
            try
            {
                if (Simulation.Status == "Idle")
                {
                    Initialize();
                }

                Simulation.Status = "Executing";

                clock.Start();
                while (
                    !(Scheduler.Quiescent && BlockedEvents.Count == 0) &&
                    Simulation.Status != "Paused" &&
                    Simulation.Status != "Idle")
                {
                    if (Scheduler.Quiescent)
                    {
                        Thread.Yield();
                    }
                    Step();
                }
                clock.Stop();

                if (Scheduler.Quiescent ||
                    Simulation.Status == "Idle")
                {
                    Complete();
                }
            }
            catch (Exception e)
            {
                DialogResult result = MessageBox.Show(
                        "An exception was thrown during simulation \"" + Simulation.Name + ".\"\n\n" +
                        "Exception: " +
                        e.Message,
                        "DomainPro",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);
                return;
            }
        }

        public void Advance()
        {
            if (Simulation == null)
            {
                return;
            }

            if (Simulation.Status == "Idle")
            {
                Initialize();
            }

            Simulation.Status = "Executing";

            clock.Start();
            if (!(Scheduler.Quiescent && BlockedEvents.Count == 0))
            {
                Step();
            }
            clock.Stop();

            Simulation.Status = "Paused";


            if (Scheduler.Quiescent)
            {
                Complete();
            }
        }

        private void Initialize()
        {
            try
            {
                app.Report("Starting simulation " + Simulation.Name + "...");
                if (ContextProvider.IsCloudSim)
                {
                    Simulation.LastRunTime = DateTime.Now;
                    Simulation.RunningTime = TimeSpan.Zero;
                    Simulation.SimulationTime = 0;
                    Simulation.Progress = 0;
                }
                else DomainProAnalyst.Instance.Invoke((MethodInvoker) delegate
                {
                    Simulation.LastRunTime = DateTime.Now;
                    Simulation.RunningTime = TimeSpan.Zero;
                    Simulation.SimulationTime = 0;
                    Simulation.Progress = 0;
                });
            }
            catch { }
            run = new DP_SimulationRun();
            run.StartTime = Simulation.LastRunTime;
            Simulation.Runs.Add(run);
            Simulation.InitializeNewListeners();

            clock = new SimClock(this);
            
            CreateStartInstances();

        }

        private void Step()
        {
            if (Scheduler.Quiescent || Terminate)
            {
                return;
            }

            DP_Schedulable finished = Scheduler.NextImminent();

            try
            {
                finished.Complete();
            }
            catch (Exception e)
            {
                DialogResult continueAfterError = MessageBox.Show(
                    "An exception occurred during execution of method \"" + finished.Method.Type.Name + "\".\n\n" +
                    "Do you want to continue the simulation?\n\n" +
                    "Exception:\n\n" +
                    e.Message,
                    "DomainPro",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Exclamation);

                if (continueAfterError == DialogResult.No)
                {
                    Simulation.Status = "Idle";
                    return;
                }
            }

            //app.Report("Finished executing method " + finished.Method.Type.Name);

            cycles++;
        }

        private void Complete()
        {
            clock.End();
            run.EndTime = DateTime.Now;
            run.SimTime = Scheduler.Time;
            Simulation.UpdateSimulationStats();

            if (ContextProvider.IsCloudSim)
            {
                Simulation.Status = "Idle";
            }
            else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
            {
                Simulation.Status = "Idle";
            });
            
            app.Report("Simulation \"" + Simulation.Name + "\" completed.");
            //app.Report("Creation time: \"" + creationTime.ToString() + "");
            //app.Report("Reflection time: \"" + reflectTime.ToString() + "");
            //app.Report("Ending simulation time: " + Scheduler.Time);
            app.Report("********************************************************************************");
            app.Report("");
        }

        private void CreateStartInstancesForCloud()
        {
            foreach (DP_StartInstance instance in Simulation.StartInstances)
            {
                for (int i = 0; i < instance.Count; i++)
                {
                    DP_IObject obj = (Simulation.ModelInstance as DP_Model).CreateForCloud(instance.Type);
                    foreach (string method in instance.Methods)
                    {
                        DP_IMethod nextMethod = (DP_IMethod)obj.Create(method);
                        DP_Schedulable schedulable = new DP_Schedulable(this, nextMethod);
                        schedulable.Schedule();
                    }

                    CreateSubInstancesForCloud(obj, instance);
                }
            }

            Simulation.ModelInstance.Initialize();
        }
        private void CreateStartInstances()
        {
            foreach (DP_StartInstance instance in Simulation.StartInstances)
            {
                for (int i = 0; i < instance.Count; i++)
                {
                    DP_IObject obj = Simulation.ModelInstance.Create(instance.Type);
                    foreach (string method in instance.Methods)
                    {
                        DP_IMethod nextMethod = (DP_IMethod)obj.Create(method);
                        DP_Schedulable schedulable = new DP_Schedulable(this, nextMethod);
                        schedulable.Schedule();
                    }

                    CreateSubInstances(obj, instance);
                }
            }

            Simulation.ModelInstance.Initialize();
        }

        private void CreateSubInstancesForCloud(DP_IObject parentObject, DP_StartInstance parentInstance)
        {
            foreach (DP_StartInstance instance in parentInstance.Instances)
            {
                for (int i = 0; i < instance.Count; i++)
                {
                    if ((parentObject as DP_Object) == null)
                    {
                        MessageBox.Show("bang bang bang parentobject hamishe dp object nist");
                    }
                    DP_IObject obj = (parentObject as DP_Object).CreateForCloud(instance.Type);
                    foreach (string method in instance.Methods)
                    {
                        DP_IMethod nextMethod = (DP_IMethod)obj.Create(method);
                        DP_Schedulable schedulable = new DP_Schedulable(this, nextMethod);
                        schedulable.Schedule();
                    }

                    CreateSubInstancesForCloud(obj, instance);
                }

            }
        }
        private void CreateSubInstances(DP_IObject parentObject, DP_StartInstance parentInstance)
        {
            foreach (DP_StartInstance instance in parentInstance.Instances)
            {
                for (int i = 0; i < instance.Count; i++)
                {
                    DP_IObject obj = parentObject.Create(instance.Type);
                    foreach (string method in instance.Methods)
                    {
                        DP_IMethod nextMethod = (DP_IMethod)obj.Create(method);
                        DP_Schedulable schedulable = new DP_Schedulable(this, nextMethod);
                        schedulable.Schedule();
                    }

                    CreateSubInstances(obj, instance);
                }

            }
        }

        private class SimClock
        {
            private DP_Simulator simulator;

            private TimeSpan runningTime = TimeSpan.Zero;
            private long lastTick;

            System.Timers.Timer secTimer = new System.Timers.Timer(200);

            public SimClock(DP_Simulator sim)
            {
                simulator = sim;
                secTimer.Elapsed += Tick;
            }

            public void Start()
            {
                secTimer.Start();
                lastTick = DateTime.Now.Ticks;
            }

            public void Stop()
            {
                runningTime.Add(new TimeSpan(DateTime.Now.Ticks - lastTick));
                secTimer.Stop();
                UpdateDisplay();
            }

            public void End()
            {
                runningTime.Add(new TimeSpan(DateTime.Now.Ticks - lastTick));
                secTimer.Stop();
                secTimer.Elapsed -= Tick;
                secTimer.Dispose();
                if (ContextProvider.IsCloudSim)
                {
                    simulator.Simulation.RunningTime = runningTime;
                    simulator.Simulation.SimulationTime = simulator.scheduler.Time;
                    simulator.Simulation.Progress = 1000;

                }
                else DomainProAnalyst.Instance.Invoke((MethodInvoker)delegate
                {
                    simulator.Simulation.RunningTime = runningTime;
                    simulator.Simulation.SimulationTime = simulator.scheduler.Time;
                    simulator.Simulation.Progress = 1000;
                });


            }

            private void Tick(object sender, EventArgs e)
            {
                runningTime += new TimeSpan(0, 0, 0, 0, 200);
                lastTick = DateTime.Now.Ticks;

                UpdateDisplay();
            }

            private void UpdateDisplay()
            {
                if (ContextProvider.IsCloudSim)
                {
                    simulator.Simulation.RunningTime = runningTime;
                    simulator.Simulation.SimulationTime = simulator.scheduler.Time;
                }
                else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                {
                    simulator.Simulation.RunningTime = runningTime;
                    simulator.Simulation.SimulationTime = simulator.scheduler.Time;
                });

                if (simulator.Simulation.AverageRunningTime != 0)
                {
                    double progress = ((runningTime.Ticks / (double)simulator.Simulation.AverageRunningTime) +
                        (simulator.Scheduler.Time / simulator.Simulation.AverageSimulationTime)) / 2;

                    if (progress >= 0.8)
                    {
                        progress = 1 - (0.16 / progress);
                    }
                    if (ContextProvider.IsCloudSim)
                    {
                        simulator.Simulation.Progress = (int)Math.Floor(progress * 1000);
                    }
                    else DomainProAnalyst.Instance.BeginInvoke((MethodInvoker)delegate
                    {
                        simulator.Simulation.Progress = (int)Math.Floor(progress * 1000);
                    });
                }
            }
        }

     
    }
}
