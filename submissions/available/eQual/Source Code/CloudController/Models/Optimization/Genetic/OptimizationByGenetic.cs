using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using CloudController.Models.Optimization.Genetic;

namespace CloudController.Models.Optimization
{
    public delegate void FinishedEventHanlder(OptimizationByGenetic algo);
    public class OptimizationByGenetic : OptimizationAlgorithmBase
    {
        private static Random random = new Random();
        public double MutationRate { set; get; }
        public double CrossoverRate { set; get; }
        public int GenerationSize { set; get; }
        public int CurrentGeneration { set; get; } = 1;
        public double TotalFitness { set; get; }
        public bool Elitism { set; get; }
        public event FinishedEventHanlder Finished;
        private List<Genome> ThisGeneration;
        private List<Genome> NextGenration;
        private List<double> FitnessTable;
        private Random _random = new Random();
        public int GenomeSize
        {
            get { return this.BoundariesList.Count; }
        }

        public int PopulationSize { set; get; }
        /// <summary>
        /// Default constructor set mutation rate to 5%, crossover to 80%, population to 100,
        /// and generations to 2000.
        /// </summary>
        /// <param name="guid"></param>
        public OptimizationByGenetic(string guid) : base(guid)
        {
            Elitism = true;
            MutationRate = 0.05;
            CrossoverRate = .8;
            PopulationSize = 4000;
            GenerationSize =1;

        }

        public OptimizationByGenetic(string guid, double mutationRate, double crossoverRate, int generationSize,
             bool elitism):base(guid)
        {
            MutationRate = mutationRate;
            CrossoverRate = crossoverRate;
            GenerationSize = generationSize;
            Elitism = elitism;
        }
        /// <summary>
        /// This is the method that starts Genetic Algorithm execution.
        /// </summary>
        public override void RunOptimization()
        {
            FitnessTable = new List<double>();
            ThisGeneration = new List<Genome>();
            NextGenration = new List<Genome>();
            CreateGenomes();
            //RankPopulation();

            //for (int i = 0; i < GenerationSize; i++)
            //{
            //    CreateNextGeneration();
            //    RankPopulation();
            //}
        }

        private void CreateNextGeneration()
        {
            
            NextGenration.Clear();

            Genome g = null;
            if (Elitism)
                g = (Genome)ThisGeneration[PopulationSize - 1];

            for (int i = 0; i < PopulationSize; i += 2)
            {
                int pidx1 = RouletteSelection();
                int pidx2 = 0;
                while ((pidx2 = RouletteSelection()) == pidx1)
                {
                }
                Genome parent1, parent2, child1, child2;
                parent1 = (ThisGeneration[pidx1]);
                parent2 = (ThisGeneration[pidx2]);

                if (_random.NextDouble() < CrossoverRate)
                {
                    parent1.Crossover( parent2, out child1, out child2);
                }
                else
                {
                    child1 = parent1;
                    child2 = parent2;
                }
                child1.Mutate();
                child2.Mutate();

                NextGenration.Add(child1);
                NextGenration.Add(child2);
            }
            if (Elitism && g != null)
                NextGenration[0] = g;

            ThisGeneration.Clear();
            for (int i = 0; i < PopulationSize; i++)
            {
                ThisGeneration.Add(NextGenration[i]);
                Coordinator.Instance.SubmitSimulationConfiguration(NextGenration[i].Genes, Guid, this, NextGenration[i].GenomeIdentifier);
            }
        }

        private void RankPopulation()
        {
            RelativelyRankPopulation();
            TotalFitness = 0;
            for (int i = 0; i < PopulationSize; i++)
            {
                Genome g = ((Genome)ThisGeneration[i]);
                g.Fitness = g.Results.OverallUtility;
                //g.Fitness = FitnessFunction(g.Genes());
                TotalFitness += g.Fitness;
            }
            ThisGeneration.Sort(new GenomeComparer());

            if (CurrentGeneration >= GenerationSize)
            {
                //finish it here 
            }

            //  now sorted in order of fitness.
            double fitness = 0.0;
            FitnessTable.Clear();
            for (int i = 0; i < PopulationSize; i++)
            {
                fitness += ((Genome)ThisGeneration[i]).Fitness;
                FitnessTable.Add((double)fitness);
            }
            if (CurrentGeneration < GenerationSize)
            {
                CurrentGeneration++;
                CreateNextGeneration();
            }
            else
            {
                Task.Factory.StartNew( ()=>
                    Coordinator.Instance.DumpDeploymentInformation());
                Finished?.Invoke(this);
            }
        }

        private void CreateGenomes()
        {
            for (int i = 0; i < PopulationSize; i++)
            {
                Genome g = new Genome(this.BoundariesList)
                {
                    MutationRate = MutationRate
                };
                g.CreateRandomGenome();
                ThisGeneration.Add(g);
                Coordinator.Instance.SubmitSimulationConfiguration(g.Genes, Guid, this, g.GenomeIdentifier);
                //when it finishes coordinator calls updategenomefitness function and updates it
            }
        }

        private int RouletteSelection()
        {
            
            double randomFitness = random.NextDouble()*TotalFitness;
            int idx = -1;
            int mid;
            int first = 0;
            int last = PopulationSize - 1;
            mid = (last - first) / 2;
            
            //  ArrayList's BinarySearch is for exact values only
            //  so do this by hand.
            while (idx == -1 && first <= last)
            {
                if (randomFitness <= (double)FitnessTable[mid])
                {
                    last = mid;
                }
                else if (randomFitness > (double)FitnessTable[mid])
                {
                    first = mid;
                }
                mid = (first + last) / 2;
                //  lies between i and i+1
                if ((last - first) == 1)
                    idx = last;
            }
            return idx;
        }

        private void RelativelyRankPopulation()
        {
            var AnalysisSummaries = (from items in ThisGeneration select items.Results).ToList();
            List<Range> maxRanges = new List<Range>();
            foreach (var item in AnalysisSummaries)
            {
                for (int i = 0; i < item.List.Count; i++)
                {
                    if (maxRanges.Count <= i)
                    {
                        maxRanges.Add(new Range()
                        {
                            UpperBound = -Double.MaxValue,
                            LowerBound = Double.MaxValue
                        });
                    }
                    if (item.List[i].Range.UpperBound >= maxRanges[i].UpperBound)
                        maxRanges[i].UpperBound = item.List[i].Range.UpperBound;
                    if (item.List[i].Range.LowerBound < maxRanges[i].LowerBound)
                        maxRanges[i].LowerBound = item.List[i].Range.LowerBound;
                }
            }
            
            List<Range> utilityRnages = new List<Range>();
            double max = -double.MaxValue;
            foreach (var item in AnalysisSummaries)
            {
                for (int i = 0; i < item.List.Count; i++)
                {
                    var qaInCurrentSimulation = item.List[i];
                    if (utilityRnages.Count <= i)
                    {
                        utilityRnages.Add(new Range()
                        {
                            UpperBound = -Double.MaxValue,
                            LowerBound = Double.MaxValue
                        });
                    }
                    qaInCurrentSimulation.OverallUtility = (qaInCurrentSimulation.Average - maxRanges[i].LowerBound) /
                                                  (maxRanges[i].UpperBound - maxRanges[i].LowerBound);
                    if (QAList[i].Relation.RelationDirection == QualityWatchedTypeRelationship.Direction.Inverse)
                        qaInCurrentSimulation.OverallUtility = 1 - qaInCurrentSimulation.OverallUtility;
                    qaInCurrentSimulation.OverallUtility = QAList[i].ImportanceCoefficient *
                                                           qaInCurrentSimulation.OverallUtility;

                    if (qaInCurrentSimulation.OverallUtility > max)
                        max = qaInCurrentSimulation.OverallUtility;
                }
            }
            foreach (var item in AnalysisSummaries)
            {
                for (int i = 0; i < item.List.Count; i++)
                {
                    item.List[i].OverallUtility /= max;
                    //item.List[i].OverallUtility = (item.List[i].OverallUtility - utilityRnages[i].LowerBound) / (utilityRnages[i].UpperBound - utilityRnages[i].LowerBound);
                }
                item.OverallUtility = item.List.Average(s => s.OverallUtility);
            }
        }
        public void UpdateGenomeFitnessInfo(DeploymentInformation depInfo)
        {
            var genome =
                (from items in this.ThisGeneration where items.GenomeIdentifier == depInfo.Identifier select items)
                    .FirstOrDefault();
            genome.Results = depInfo.SimulatinoAnalysisSummary;
            if (ThisGeneration.All(s => s.Results != null))
            {
                RankPopulation();
            }
        }
    }
}