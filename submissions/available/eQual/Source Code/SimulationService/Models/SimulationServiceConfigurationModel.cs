using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;

namespace SimulationService.Models
{
    class SimulationServiceConfiguration: ConfigurationSection
    {
        private static SimulationServiceConfiguration _instance = null;
        public static SimulationServiceConfiguration Instance
        {
            get
            {
                if (_instance == null)
                    _instance = (SimulationServiceConfiguration)WebConfigurationManager.GetSection("simulationService");
                return _instance;
            }
        }
        [ConfigurationProperty("cloudUrl", IsRequired= true)]
        public string CloudUrl
        {
            get { return (string)base["cloudUrl"]; }
            set { base["cloudUrl"] = value; }
        }

    }
}
