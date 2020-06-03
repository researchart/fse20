using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace SimulationService.Models
{
    public static class SerializationHelper
    {
        public static string SerializeObjectToString<T>(this T toSerialize)
        {
            XmlSerializer xmlSerializer = new XmlSerializer(toSerialize.GetType());

            using (StringWriter textWriter = new StringWriter())
            {
                xmlSerializer.Serialize(textWriter, toSerialize);
                return textWriter.ToString();
            }
        }
        public static string SerializeObjectToFile<T>(this T toSerialize)
        {
            XmlSerializer serializer = new XmlSerializer(toSerialize.GetType());
            string savePath = System.Web.Hosting.HostingEnvironment.MapPath("~/TempResults/");
            if (!Directory.Exists(savePath))
            {
                Directory.CreateDirectory(savePath);
            }
            var guid = Guid.NewGuid().ToString();
            TextWriter textWriter = new StreamWriter(savePath + guid + ".xml");
            serializer.Serialize(textWriter, toSerialize);
            textWriter.Close();
            return savePath + guid + ".xml";
        }
    }
}