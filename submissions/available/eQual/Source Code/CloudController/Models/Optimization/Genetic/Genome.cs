using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CloudController.Models.Optimization.Genetic
{
    /// <summary>
    /// Genome represents the genome structure for genetic algorithm.
    /// It contains a model configuration alongside its fitness value (relatively computed among that generation).
    /// </summary>
    public class Genome
    {
        private Random random = new Random();
        private List<PropertyModel> _propertyModels;
        public List<PropertyOverride> Genes { set; get; }
        public double MutationRate { set; get; }
        public double Fitness { set; get; }
        public AnalysisSummary Results { set; get; }
        public Guid GenomeIdentifier { set; get; }
        public Genome(List<PropertyModel> propertyModels )
        {
            Genes = new List<PropertyOverride>();
            MutationRate = 0.01;
            GenomeIdentifier = Guid.NewGuid();
            _propertyModels = propertyModels;
        }
        public Genome(List<PropertyOverride> genes, List<PropertyModel> propertyModels, double mutationRate)
        {
            GenomeIdentifier = Guid.NewGuid();
            this.Genes = genes;
            MutationRate = mutationRate;
            _propertyModels = propertyModels;
        }

        public void Crossover(Genome genome2, out Genome child1, out Genome child2)
        {
            int pos = (int)(random.NextDouble() * (double)Genes.Count);
            child1 = new Genome(_propertyModels);
            child2 = new Genome(_propertyModels);
            for (int i = 0; i < Genes.Count; i++)
            {
                //TODO: this is implicitly assumed that property overrides orders are the same in every instnace of it. Verify this
                if (i < pos)
                {
                    child1.Genes.Add(this.Genes[i]);
                    child2.Genes.Add(genome2.Genes[i]);
                }
                else
                {
                    child1.Genes.Add(genome2.Genes[i]);
                    child2.Genes.Add(this.Genes[i]);
                }
            }
        }

        public void CreateRandomGenome()
        {
            foreach (var item in _propertyModels)
            {
                Genes.Add(new PropertyOverride()
                {
                    PrimitiveType = item.PrimitiveType,
                    Property = item.Property,
                    Type = item.Type
                });
            }
            foreach (var item in Genes)
            {
                item.Value =
                    (_propertyModels.First(s => s.Property == item.Property).GetRandomValueBasedOnDistribution());
            }
        }
        public void Mutate()
        {
            foreach (var item in Genes)
            {
                if (random.NextDouble() < MutationRate)
                {
                    var propMod =
                        (from items in _propertyModels where items.Property == item.Property select items)
                            .FirstOrDefault();
                    item.Value = propMod.GetRandomValueBasedOnDistribution();
                }
            }
        }
    }
}