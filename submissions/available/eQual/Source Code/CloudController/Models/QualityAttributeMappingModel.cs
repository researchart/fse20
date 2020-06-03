using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;
using DomainPro.Analyst.Engine;

namespace CloudController.Models
{
    public class QualityAttributeMappingModel
    {
        public QualityAttributeMappingModel()
        {
            QA = new QualityAttribute();
            Relation=new QualityWatchedTypeRelationship();
            SerieType = new SeriesType();
        }
        //[UIHint("WatchedTypeList")]
        [Editable(false)]
        public string WatchedType { set; get; }
        
        [UIHint("QualityAttributeEditor")]
        public QualityAttribute QA { set; get; }
        [UIHint("RelationshipsList")]
        public QualityWatchedTypeRelationship Relation { set; get; }
        public double ImportanceCoefficient { set; get; }
        [UIHint("WatchedTypeSeriesList")]
        public SeriesType SerieType { set; get; }

    }

    public struct SeriesType
    {
        public WatchedTypeKinds WatchedTypeKind { set; get; }
        public string SerieName { set; get; }

        public int Index()
        {
            List<string> seriesNameList =null;
            switch (WatchedTypeKind)
            {
                case WatchedTypeKinds.Component:
                    seriesNameList = new List<string>() {"Blocking Methods",
            "Executing Methods"};
                    break;
                case WatchedTypeKinds.Method:
                    seriesNameList = new List<string>() {"Number of Invocations",
            "Invocation Interval",
            "Average Invocation Interval",
            "Blocking Time",
            "Average Blocking Time",
            "Maximum Blocking Time",
            "Executing Time",
            "Average Executing Time",
            "Maximum Executing Time"};
                    break;
                case WatchedTypeKinds.Data:
                    seriesNameList = new List<string>() { "Value" };
                    break;
                case WatchedTypeKinds.Resource:
                    seriesNameList = new List<string>() { "Idle Capacity",
            "Queue Length"};
                    break;
            }
           return seriesNameList.IndexOf(SerieName);
        }
    }

    public enum WatchedTypeKinds
    {
        Component,
        Data,
        Method,
        Resource
    }
    public class QualityAttribute
    {
        public string Name { set; get; }
    }

    public class QualityWatchedTypeRelationship
    {
        public enum Direction
        {
            Direct,
            Inverse
        }
        public QualityWatchedTypeRelationship() { }
        public QualityWatchedTypeRelationship(Direction dir)
        {
            this.RelationDirection = dir;
        }
        public Direction RelationDirection { set; get; }
    }
}