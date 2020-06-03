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

namespace DomainPro.Analyst.Engine
{
    public class DP_TerminationConditions
    {
        private double maxSimTime;

        public double MaxSimTime
        {
            get { return maxSimTime; }
            set { maxSimTime = value; }
        }

        private TimeSpan maxRunTime;

        [XmlIgnore]
        public TimeSpan MaxRunTime
        {
            get { return maxRunTime; }
            set { maxRunTime = value; }
        }

        [XmlElement("MaxRunTime")]
        public string MaxRunTimeString
        {
            get { return maxRunTime.ToString(); }
            set
            {
                TimeSpan ts;
                if (TimeSpan.TryParse(value, out ts))
                {
                    maxRunTime = ts;
                }
            }
        }

        private long maxCycles;

        public long MaxCycles
        {
            get { return maxCycles; }
            set { maxCycles = value; }
        }

        private string customCondition;

        public string CustomCondition
        {
            get { return customCondition; }
            set { customCondition = value; }
        }
    }
}
