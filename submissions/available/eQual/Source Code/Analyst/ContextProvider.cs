using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using DomainPro.Core.Application;
using DomainPro.Core.Interfaces;

namespace DomainPro.Analyst
{
    public class ContextProvider
    {
        public static AppDomain Domain { set; get; }
        public static Assembly ModelAssembly {
            set
            {
                if (DomainProAnalyst.Instance == null)
                {
                    DomainProAnalyst.instance = new DomainProAnalyst();
                }
                DomainProAnalyst.Instance.ModelAssembly = value;
            }
            get { return DomainProAnalyst.Instance.ModelAssembly; }
        }

        public static Assembly LanguageAssembly
        {
            set { DomainProAnalyst.Instance.LanguageAssembly = value; }
            get { return DomainProAnalyst.Instance.LanguageAssembly; }
        }

        public static DP_IModelFactory ModelFactory
        {
            set { DomainProAnalyst.Instance.ModelFactory = value; }
            get { return DomainProAnalyst.Instance.ModelFactory; }
        }

        public static DP_Project Project
        {
            set { DomainProAnalyst.Instance.Project = value; }
            get { return DomainProAnalyst.Instance.Project; }
        }

        public static DP_Language Language
        {
            set { DomainProAnalyst.Instance.Language = value; }
            get { return DomainProAnalyst.Instance.Language; }
        }

        public static bool IsCloudSim { set; get; }
    }
}
