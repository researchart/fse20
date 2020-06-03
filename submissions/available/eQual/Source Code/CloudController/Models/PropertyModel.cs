using System;

namespace CloudController.Models
{
    public class PropertyModel
    {
        private static Random random = new Random();
        public string PrimitiveType { set; get; }
        public string Type { set; get; }
        public string Property { set; get; }
        public object Upperbound { set; get; }
        public object LowerBound { set; get; }
        public object DefaultValue { set; get; }
        public string Distribution { set; get; }

        public object GetRandomValueBasedOnDistribution()
        {
            
            if (PrimitiveType.ToLower().Contains("bool"))
            {
                if (this.LowerBound != this.Upperbound)
                    return (random.NextDouble() > 0.5);
                else
                    return LowerBound;
            }
            if (PrimitiveType.ToLower().Contains("double"))
            {
                return random.NextDouble()*
                       ((double.Parse(Upperbound.ToString()) - (double.Parse(LowerBound.ToString())))) +
                       (double.Parse(LowerBound.ToString()));
            }
            if (PrimitiveType.ToLower().Contains("int"))
            {
                return
                    (int) (random.NextDouble()*(int.Parse(Upperbound.ToString()) - (int.Parse(LowerBound.ToString())))) +
                    int.Parse(LowerBound.ToString());
            }
            return DefaultValue;
            
        }
    }
}