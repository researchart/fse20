import os, sys
from pdb import set_trace as st
import pickle
import pandas as pd

from sklearn import tree
from sklearn.ensemble import (
    AdaBoostClassifier,
    GradientBoostingClassifier,
    RandomForestClassifier,
)
import numpy  as np

# Model config
model_label = "dropout"
model_dir = f"result/resnet10cifar10/model_{model_label}"
feature_dir = f"{model_dir}/nninst_mu_posneg/forward_feature"

def load_data(name):
    path = os.path.join(feature_dir, f"{name}.pkl")
    with open(path, "rb") as f:
        data = pickle.load(f)
    feature = data["features"]
    label = data["labels"]
    pred = data["preds"]
    b = feature.shape[0]
    feature = feature.reshape((b, -1))
    return feature, label, pred

def train_clf():
    train_data, train_label, _ = load_data("train")
    clf=tree.DecisionTreeClassifier(
        # max_depth = 20,
        # min_samples_leaf = 2,
    )
    clf = clf.fit(train_data, train_label)
    train_prediction = clf.predict(train_data)
    acc = (train_prediction == train_label).sum() / len(train_label)
    print(f"Train acc: {acc:.3f}")
    
    test_data, test_label, _ = load_data("original")
    test_prediction = clf.predict(test_data)
    test_acc = ( (test_prediction == test_label).sum()
                            / len(test_label) )
    print(f"Clean test acc: {test_acc:.3f}")
    
    return clf
    
def test_clf(clf):
    test_data, test_label, _ = load_data("original")
    test_prediction = clf.predict(test_data)
    test_acc = ( (test_prediction == test_label).sum()
                            / len(test_label) )
    print(f"Clean test acc: {test_acc:.3f}")
    
    result = []
    for attack_name in [
        # "original",
        "FGSM_2", "FGSM_4", "FGSM_8",
        "DeepFoolLinf", "DeepFoolL2",
        "JSMA",
        "RPGD_2", 
        "RPGD_4", "RPGD_8",
        "CWL2", "ADef",
        "SinglePixel", "LocalSearch",
        "Boundary", "Spatial", "Pointwise", "GaussianBlur",
    ]:
        test_adversarial_data, test_adversarial_label, test_adversarial_raw_pred = load_data(attack_name)
        test_adversarial_prediction = clf.predict(test_adversarial_data)
        test_adversarial_acc = ( (test_adversarial_prediction == test_adversarial_label).sum()
                                / len(test_adversarial_label) )
        
        detection_label = np.concatenate((
            np.zeros(test_label.shape[0]),
            np.zeros(test_adversarial_label.shape[0]) + 1
        )).astype(np.int8)
        detection_pred = np.concatenate((
            test_prediction != test_label,
            test_adversarial_prediction != test_adversarial_raw_pred,
        )).astype(np.int8)
        
        true_positive = ( (detection_label == detection_pred) * (1 == detection_label) )
        recall = true_positive.sum() / detection_label.sum()
        precision = true_positive.sum() / detection_pred.sum()
        f1 = 2*precision*recall / (precision + recall + 0.01)
        print(f"{attack_name}: acc={test_adversarial_acc:.3f}, "
            f"f1={f1:.3f}, recall={recall:.3f}, precision={precision:.3f}")
        result.append({
            "name": attack_name,
            "f1": f1,
            "recall": recall,
            "precision": precision,
        })
    result = pd.DataFrame(result)
    result.to_csv(os.path.join(feature_dir, "result.csv"))
    
    
def main():
    # clf = train_clf()
    # with open(os.path.join(feature_dir, "clf.pkl"), "wb") as f:
    #     pickle.dump(clf, f)
        
    with open(os.path.join(feature_dir, "clf.pkl"), "rb") as f:
        clf = pickle.load(f)
    test_clf(clf)
    
main()