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
using System.Xml.Serialization;
using DomainPro.Analyst.Interfaces;

namespace DomainPro.Analyst.Engine
{
    public class DP_SimulationRun
    {
        private DateTime startTime;

        public DateTime StartTime
        {
            get { return startTime; }
            set { startTime = value; }
        }

        private DateTime endTime;

        public DateTime EndTime
        {
            get { return endTime; }
            set { endTime = value; }
        }

        private Double simTime;

        public Double SimTime
        {
            get { return simTime; }
            set { simTime = value; }
        }

        public TimeSpan RunningTime
        {
            get { return endTime - startTime; }
        }

        private Dictionary<string, DP_IEventListener> watchedDict = new Dictionary<string, DP_IEventListener>();

        [XmlIgnore]
        public Dictionary<string, DP_IEventListener> WatchedDict
        {
            get { return watchedDict; }
            set { watchedDict = value; }
        }
    }
}
