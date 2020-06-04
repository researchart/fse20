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

namespace DomainPro.Analyst.Engine
{
    public class DP_Thread
    {
        private AutoResetEvent blocked = new AutoResetEvent(false);
        
        public AutoResetEvent Blocked 
        { get { return blocked; } }

        private AutoResetEvent completed = new AutoResetEvent(false);

        public AutoResetEvent Completed
        { get { return completed; } }

        private Thread thread;

        public DP_Thread(ThreadStart start)
        {
            thread = new Thread(start);
        }

        public void Start()
        {
            thread.Start();
        }
    }
}
