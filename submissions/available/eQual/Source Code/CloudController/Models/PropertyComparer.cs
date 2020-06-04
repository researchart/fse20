using System;
using System.Collections;
using System.Collections.Generic;
using DomainPro.Analyst.Engine;

namespace CloudController.Models
{
    public class PropertyComparer : IEqualityComparer<DP_PropertyOverride>
    {
        public bool Equals(DP_PropertyOverride x, DP_PropertyOverride y)
        {
            if (x.Type == y.Type && x.Property == y.Property)
                return true;
            return false;
        }

        public int GetHashCode(DP_PropertyOverride obj)
        {
            return (obj.Type + obj.Property).GetHashCode();
        }
    }
}