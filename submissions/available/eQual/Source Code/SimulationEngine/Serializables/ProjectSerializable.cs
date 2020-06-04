using System.Runtime.Serialization;

namespace SimulationEngine.Serializables
{
    [DataContract]
    public class ProjectSerializable
    {
        [DataMember]
        public string Name { set; get; }
        [DataMember]
        public byte[] LanguageAssembly { set; get; }
        public byte[] Model { set; get; }
    }
}
