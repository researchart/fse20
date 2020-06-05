import numpy as np
import pandas
import random
import re
import sys
from scipy.stats import pearsonr, spearmanr


# ausiliary functions

def buildSeriesByCategory(df, categories):
    res = []
    for cat in categories:
        occ = df.loc[df["category"] == cat].shape[0]
        res.append(occ)
    res_series = pandas.Series(res, index=categories)
    return res_series

def fillList(series):
    list = []
    for label, value in series.items():
        if label != "reacted":
            num = value
            while num > 0:
                list.append(label)
                num = num - 1
    return pandas.Series(list)


def printStatsByCategory(df, categories):
    for cat in categories:
        occ = df.loc[df["category"] == cat].shape[0]
        print(cat + ": " + str(occ))


def buildOverallResultSeries(resulting_series):
    res_list = []
    for label, serie in resulting_series.items():
        sum = 0;
        for value in serie:
            sum += value
        res_list.append(sum)
    return res_list


def fillTwoLists(typ, cat, labels_string, cat_list, label_list):
    labels = labels_string.split(",")
    for label in labels:
        if label != 'nan':
            cat_list.append(cat)
            label_list.append(typ + ":" + label.strip())


def computeProjectSet(list, splitRule, categories):
    resulting_set = set()
    base_link = "https://gitlab.com"

    for name in list:
        if splitRule != "":
            splittedName = name.split(splitRule)

            new_name = base_link

            for token in splittedName:
                if token in categories:
                    break
                else:
                    token = re.sub(r"[ <>#%\"{}|^'`;\[\]/?:@&=+$,\.()\\\\]", my_replace, token)
                    new_name += "/" + token
            resulting_set.add(new_name)

    return resulting_set


def my_replace(match):
    return "-"


def recallSample(start_data_file, rqone_file, rqtwo_file, output_file, categories):
    with open(start_data_file) as dataset_reader, open(rqone_file) as rqone_reader, open(rqtwo_file) as rqtwo_reader:
        dataset = pandas.read_csv(dataset_reader)
        # hasYaml	hasRequirements	hasPoms
        dataset = dataset.loc[dataset['hasYaml']]
        rqone = pandas.read_csv(rqone_reader)
        rqtwo = pandas.read_csv(rqtwo_reader)

        dataset_len = dataset.shape[0]
        rqone_len = rqone.shape[0]
        rqtwo_len = rqtwo.shape[0]
        print("Dataset's size: " + str(dataset_len))
        print("RQ1's size: " + str(rqone_len))
        print("RQ2's size: " + str(rqtwo_len))

        header = dataset.shape[0]
        dataset_proj = dataset['project']
        rqone_proj = rqone['id']
        rqtwo_proj = rqtwo['ID']

        # note that in RQ2 some issues (of different type) belong to the same project and some project are shared by
        # RQ1 and RQ2
        dataset_set = computeProjectSet(dataset_proj, "/", categories)
        rqone_set = computeProjectSet(rqone_proj, "__", categories)
        rqtwo_set = computeProjectSet(rqtwo_proj, "__", categories)
        print("Dataset's size (unique): " + str(len(dataset_set)))
        print("RQ1's size (unique): " + str(len(rqone_set)))
        print("RQ2's size (unique): " + str(len(rqtwo_set)))

        # compute the candidate set
        d0 = dataset_set.difference(rqone_set)
        print("d0 (dataset - RQ1): " + str(len(d0)))
        # print(d0)
        d1 = d0.difference(rqtwo_set)
        print("d1 (d0 - RQ2): " + str(len(d1)))
        # print(d1)
        print("---")

        # compute the recall sample and save it
        sample_size = 8
        recall_sample = random.sample(d1, sample_size)
        recall_projects = {'project': recall_sample}
        recall_df = pandas.DataFrame(recall_projects)
        recall_df.to_csv(output_file, index=False)

    return


def printOccurrences(antipatterns, tot_smells, tot_ana_projects, tot_ana_owners):
    num_smells = antipatterns['ID'].shape[0]
    percentage_num_smells = round(num_smells / tot_smells * 100, 1)
    print("#smells: " + str(num_smells) + "(" + str(percentage_num_smells) + "%)")

    num_smelly_projects = antipatterns['Project'].unique().shape[0]
    percentage_num_smelly_projects = round(num_smelly_projects / tot_ana_projects * 100, 1)
    print("#smelly-projects: " + str(num_smelly_projects) + "(" + str(percentage_num_smelly_projects) + "%)")

    num_smelly_owners = antipatterns['Owner'].unique().shape[0]
    percentage_num_smelly_owners = round(num_smelly_owners / tot_ana_owners * 100, 1)
    print("#smelly-owners: " + str(num_smelly_owners) + "(" + str(percentage_num_smelly_owners) + "%)")


def printOccurrencesPerCluster(apdf, tot_smells, tot_ana_projects, tot_ana_owners, tot_ana_projects_versioning,
                               tot_ana_owners_versioning):
    print("\n-> Versioning")
    versioning = apdf.loc[apdf["Category"] == "Versioning"]
    printOccurrences(versioning, tot_smells, tot_ana_projects_versioning, tot_ana_owners_versioning)

    print("\n-> Job-Allow-Failure")
    allow_failure = apdf.loc[apdf["Category"] == "Job-Allow-Failure"]
    printOccurrences(allow_failure, tot_smells, tot_ana_projects, tot_ana_owners)

    print("\n-> Job-Retry")
    retry = apdf.loc[apdf["Category"] == "Job-Retry"]
    printOccurrences(retry, tot_smells, tot_ana_projects, tot_ana_owners)

    print("\n-> Manual-Job")
    manual = apdf.loc[apdf["Category"] == "Manual-Job"]
    printOccurrences(manual, tot_smells, tot_ana_projects, tot_ana_owners)


def printOccurrences2(df, tot):
    num_smells = df['ID'].shape[0]
    percentage_num_smells = round(num_smells / tot * 100, 1)
    print("#smells: " + str(num_smells) + "(" + str(percentage_num_smells) + "%)")


def printOccurrencesPerCluster2(apdf, tot_versioning, tot_allow, tot_retry, tot_manual):
    print("-> Versioning")
    versioning = apdf.loc[apdf["Category"] == "Versioning"]
    printOccurrences2(versioning, tot_versioning)

    print("-> Job-Allow-Failure")
    allow_failure = apdf.loc[apdf["Category"] == "Job-Allow-Failure"]
    printOccurrences2(allow_failure, tot_allow)

    print("-> Job-Retry")
    retry = apdf.loc[apdf["Category"] == "Job-Retry"]
    printOccurrences2(retry, tot_retry)

    print("-> Manual-Job")
    manual = apdf.loc[apdf["Category"] == "Manual-Job"]
    printOccurrences2(manual, tot_manual)


def recall_computation(file):
    df = pandas.read_csv(file)
    TTP = df.loc[(df["manual validation"] == "YES")]
    TP = TTP.loc[TTP["match with cd-linter"] == "YES"]
    print("True Positives (TP): " + str(TTP.shape[0]))
    print("Total True Positives (TTP): " + str(TP.shape[0]))
    rec = round(TP.shape[0]/TTP.shape[0], 2)
    print("Recall: " + str(rec))


def versioning_occurrences_byfile(smell):
    tot_incidents = smell.shape[0]
    affected_files = smell["Remote Configuration File Link"].unique().shape[0]

    yml_incidents = smell.loc[smell["Configuration File Name"] == ".gitlab-ci.yml"]
    tot_yml_incidents = yml_incidents.shape[0]
    tot_affected_yml = yml_incidents["Remote Configuration File Link"].unique().shape[0]

    req_incidents = smell.loc[smell["Configuration File Name"] == "requirements.txt"]
    tot_req_incidents = req_incidents.shape[0]
    tot_affected_req = req_incidents["Remote Configuration File Link"].unique().shape[0]

    pom_incidents = smell.loc[(smell["Configuration File Name"] != ".gitlab-ci.yml") &
                              (smell["Configuration File Name"] != "requirements.txt")]
    tot_pom_incidents = pom_incidents.shape[0]
    tot_affected_pom = pom_incidents["Remote Configuration File Link"].unique().shape[0]

    print("tot_incidents: " + str(tot_incidents))
    print("affected_files: " + str(affected_files))
    print("tot_yml_incidents: " + str(tot_yml_incidents) + "(" + str(
        round(tot_yml_incidents / tot_incidents * 100, 2)) + "%)")
    print("affected_yml_files: " + str(tot_affected_yml))
    print("tot_req_incidents: " + str(tot_req_incidents) + "(" + str(
        round(tot_req_incidents / tot_incidents * 100, 2)) + "%)")
    print("affected_req_files: " + str(tot_affected_req))
    print("tot_pom_incidents: " + str(tot_pom_incidents) + "(" + str(
        round(tot_pom_incidents / tot_incidents * 100, 2)) + "%)")
    print("affected_pom_files: " + str(tot_affected_pom))

def precision_results(issueReportFile):

    with open(issueReportFile) as input_file:
        frame = pandas.read_csv(input_file) # read file in a dataframe

        pf = frame.groupby('TYPE')

        for name, group in pf:
            print("-> " + name)
            true_positives = group.loc[(group["RATING"] == True)]
            false_positives = group.loc[(group["RATING"] == False)]
            tp = true_positives.shape[0]
            fp = false_positives.shape[0]
            print("True Positives (TP): " + str(tp))
            print("False Positives (FP): " + str(fp))
            pr = round((tp/(tp + fp)), 2)
            print("Precision: " + str(pr))
            # print(type(group))
            # ls = group['label']
            # print(ls.value_counts())

        frame_versioning = frame.loc[(frame["TYPE"] == "Versioning")]

        pf_ver = frame_versioning.groupby('SUBTYPE')

        for name, group in pf_ver:
            print("-> " + name)
            true_positives = group.loc[(group["RATING"] == True)]
            false_positives = group.loc[(group["RATING"] == False)]
            tp = true_positives.shape[0]
            fp = false_positives.shape[0]
            print("True Positives (TP): " + str(tp))
            print("False Positives (FP): " + str(fp))
            pr = round((tp/(tp + fp)), 2)
            print("Precision: " + str(pr))


if __name__ == '__main__':
    
    # compute precision
    print("### RQ2: Compute Precision ###\n")
    rqtwo_precision = sys.argv[1] # "rq2-precision.csv"
    precision_results(rqtwo_precision)

    print("\n### RQ2: Compute Recall ###\n")
    # recall_results(rqthree_file, dataset_withyml)
    rqtwo_recall = sys.argv[2] #"rq2-recall.csv";
    recall_computation(rqtwo_recall)

