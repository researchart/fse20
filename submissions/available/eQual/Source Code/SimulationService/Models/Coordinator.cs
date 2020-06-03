using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SimulationService.Models
{
    class Coordinator
    {
        private static readonly Lazy<Coordinator> lazy = new Lazy<Coordinator>(()=>new Coordinator());
        public static Coordinator Instance
        {
            get
            {
                return lazy.Value;
            }
        }
        private Coordinator()
        {
            IsRunning = false;
        }
        //requested guid, hook combinations kept in a queue for future simulation
        public ConcurrentQueue<KeyValuePair<string, string>> RequestedHooks = new ConcurrentQueue<KeyValuePair<string,string>>();
        public bool IsRunning { set; get; }

    }
}
