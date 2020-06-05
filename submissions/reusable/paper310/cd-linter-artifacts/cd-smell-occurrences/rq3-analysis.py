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


# RQ3 data analysis
def rqthree_results(input_file, dataset):
    datasetf = pandas.read_csv(dataset)
    datasetf = datasetf.loc[datasetf["hasYaml"]]  # remove projects without yaml
    print("Analyzable projects: " + str(datasetf.shape[0]))

    print("\n### Describe dataset ###")
    summary = datasetf['yml_size'].describe()
    tot_projects = datasetf["project"].unique().shape[0]
    tot_owners = datasetf["owner"].unique().shape[0]
    print("Analyzable repositories: " + str(tot_projects))

    # for versioning different candidates
    versioning_candidates = datasetf.loc[(datasetf["language"] == "Python") | (datasetf["hasPoms"])]
    tot_projects_versioning = versioning_candidates["project"].unique().shape[0]
    tot_owners_versioning = versioning_candidates["owner"].unique().shape[0]
    print("Analyzable repositories (Versioning): " + str(tot_projects_versioning))
    print("Analyzable owners: " + str(tot_owners))
    print("Analyzable owners (Versioning): " + str(tot_owners_versioning))
    yml_first_quartile = summary["25%"]
    print("YML-size (25%): " + str(yml_first_quartile))
    yml_third_quartile = summary["75%"]
    print("YML-size (75%): " + str(yml_third_quartile))

    # Merge antipatterns with dataset
    antipatterns = pandas.read_csv(input_file)
    apdf = pandas.merge(antipatterns, datasetf, left_on='Repository Name', right_on='project', how='left')

    # exclude additional python projects without yaml
    apdf = apdf.loc[pandas.notna(apdf["project"])]

    print("\n### Full-analysis of smells ###")

    print("-> Overall")
    tot_smells = apdf['ID'].shape[0]
    tot_smelly_projects = apdf['Project'].unique().shape[0]
    tot_smelly_owners = apdf['owner'].unique().shape[0]
    print("#smells: " + str(tot_smells))
    print("#smelly-projects: " + str(tot_smelly_projects))
    print("#smelly-owners: " + str(tot_smelly_owners))

    printOccurrencesPerCluster(apdf, tot_smells, tot_projects, tot_owners, tot_projects_versioning,
                               tot_owners_versioning)

    print("\n### YAML-size-based clustering analysis ###")
    tot_versioning = apdf.loc[apdf["Category"] == "Versioning"].shape[0]
    tot_allow = apdf.loc[apdf["Category"] == "Job-Allow-Failure"].shape[0]
    tot_manual = apdf.loc[apdf["Category"] == "Manual-Job"].shape[0]
    tot_retry = apdf.loc[apdf["Category"] == "Job-Retry"].shape[0]

    print("\n-> Projects (small yaml)")
    apdf_small = apdf.loc[apdf["yml_size"] <= yml_first_quartile]
    printOccurrences(apdf_small, tot_smells, tot_smelly_projects, tot_smelly_owners)
    printOccurrencesPerCluster2(apdf_small, tot_versioning, tot_allow, tot_retry, tot_manual)

    print("\n-> Projects (medium yaml)")
    apdf_medium = apdf.loc[(apdf["yml_size"] > yml_first_quartile) & (apdf["yml_size"] < yml_third_quartile)]
    printOccurrences(apdf_medium, tot_smells, tot_smelly_projects, tot_smelly_owners)
    printOccurrencesPerCluster2(apdf_medium, tot_versioning, tot_allow, tot_retry, tot_manual)

    print("\n-> Projects (long yaml)")
    apdf_big = apdf.loc[apdf["yml_size"] >= yml_third_quartile]
    printOccurrences(apdf_big, tot_smells, tot_smelly_projects, tot_smelly_owners)
    printOccurrencesPerCluster2(apdf_big, tot_versioning, tot_allow, tot_retry, tot_manual)

    print("\n### YAML-size-based clustering analysis (Big YAML) ###")

    # reduce starting dataset to the high sample
    big_datasetf = datasetf.loc[datasetf["yml_size"] >= yml_third_quartile]
    big_tot_projects = big_datasetf["project"].unique().shape[0]
    big_tot_owners = big_datasetf["owner"].unique().shape[0]
    print("Analyzable repositories: " + str(big_tot_projects))

    # for versioning different candidates
    big_versioning_candidates = big_datasetf.loc[(big_datasetf["language"] == "Python") | (big_datasetf["hasPoms"])]
    big_tot_projects_versioning = big_versioning_candidates["project"].unique().shape[0]
    big_tot_owners_versioning = big_versioning_candidates["owner"].unique().shape[0]
    print("Analyzable repositories (Versioning): " + str(big_tot_projects_versioning))
    print("Analyzable owners: " + str(big_tot_owners))
    print("Analyzable owners (Versioning): " + str(big_tot_owners_versioning))

    big_tot_smells = apdf_big['ID'].shape[0]
    big_tot_smelly_projects = apdf_big['Project'].unique().shape[0]
    big_tot_smelly_owners = apdf_big['Owner'].unique().shape[0]
    print("#smells: " + str(big_tot_smells))
    print("#smelly-projects: " + str(big_tot_smelly_projects))
    print("#smelly-owners: " + str(big_tot_smelly_owners))

    printOccurrencesPerCluster(apdf_big, big_tot_smells, big_tot_projects, big_tot_owners, big_tot_projects_versioning,
                               big_tot_owners_versioning)

    print("\n# Analysis of versioning issues")

    vapdf = apdf.loc[apdf["Category"] == "Versioning"]  # the versioning frame

    # tot incidents per file
    print("\n-> overall")
    versioning_occurrences_byfile(vapdf)

    print("\n-> missing")
    missing = vapdf.loc[vapdf["Sub-Category"] == "missing"]
    versioning_occurrences_byfile(missing)
    print("\n-> only-major-number")
    only_major_number = vapdf.loc[vapdf["Sub-Category"] == "only-major-number"]
    versioning_occurrences_byfile(only_major_number)
    print("\n-> any-minor-number")
    any_minor_number = vapdf.loc[vapdf["Sub-Category"] == "any-minor-number"]
    versioning_occurrences_byfile(any_minor_number)
    print("\n-> any-upper-version")
    any_upper_version = vapdf.loc[vapdf["Sub-Category"] == "any-upper-version"]
    versioning_occurrences_byfile(any_upper_version)

    return


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


if __name__ == '__main__':

    print("\nRQ3 results")
    dataset_withyml = sys.argv[1] # "dataset_yml-update.csv"
    rqthree_smells = sys.argv[2] # "rq3-results-new.csv"
    rqthree_results(rqthree_smells, dataset_withyml)
