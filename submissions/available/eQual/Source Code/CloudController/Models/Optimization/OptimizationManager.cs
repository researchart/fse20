namespace CloudController.Models.Optimization
{
    public class OptimizationManager
    {
        

        public OptimizationManager(string guid, OptimizationAlgorithmBase algorithm)
        {
            Guid = guid;
            Algorithm = algorithm;
        }

        public void RunOptimzation()
        {
            Algorithm.RunOptimization();
        }
        public OptimizationAlgorithmBase Algorithm { set; get; }
    
        public string Guid { set; get; }
    }
}