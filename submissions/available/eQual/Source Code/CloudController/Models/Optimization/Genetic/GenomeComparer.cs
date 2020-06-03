using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CloudController.Models.Optimization.Genetic
{
    public class GenomeComparer:IComparer<Genome>
    {
        public GenomeComparer()
        {
            
        }
   

        public int Compare(Genome x, Genome y)
        {
            if (((Genome)x).Fitness > ((Genome)y).Fitness)
                return 1;
            else if (Math.Abs(((Genome)x).Fitness - ((Genome)y).Fitness) < 0.00001)
                return 0;
            else
                return -1;
        }
    }
}