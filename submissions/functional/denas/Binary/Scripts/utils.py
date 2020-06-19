import os
os.environ["CUDA_VISIBLE_DEVICES"] = "1"
import random
import numpy as np
from keras.layers import Dense, Activation, Dropout, Layer
from keras.layers import  SimpleRNN, Embedding, Bidirectional,TimeDistributed, Input, Flatten
from keras.models import load_model
import keras.backend as K
import keras
import pickle as pickle
from keras.models import  Model


TerminationLength = 30
THRESHOLD = 0
BIT = 257


SEQLENGTH = 40
FEANUM= 200
STARTINDEX = int(100 - SEQLENGTH / 2)
ENDINDEX = int(100 + SEQLENGTH / 2 + 1)

TESTDATA = np.zeros([SEQLENGTH*BIT, FEANUM])
for i in range(SEQLENGTH):
    for j in range(BIT):
        TESTDATA[i * BIT + j, i + STARTINDEX] = j




class RuleStructure():
    def __init__(self, dataset, rule):
        self.dataset = dataset
        self.rule = rule
        self.predy = 0
        self.size = len(self.dataset)

    def decideRule(self):
        if TerminationLength == len(self.rule) or (self.predy > 0 and len(self.rule) >= 5):
            return True
        else:
            return False


    def SetPredy(self, predy):
        self.predy = predy


    def SplitNode(self, newpt):
        pos = int(newpt / BIT)
        val = newpt % BIT
        selindex = np.where(self.dataset[:, pos] == val)[0]
        if len(selindex) == 0:
            return None
        else:
            newrule = self.rule.copy()
            newrule.append(newpt)
            newdataset = self.dataset[selindex].copy()
            NewNode = RuleStructure(newdataset, newrule)
            self.dataset = np.delete(self.dataset, selindex, axis=0)
            self.size = len(self.dataset)
            return NewNode

    @property
    def __eq__(self, other):
        return len(self.dataset) == len(other.dataset)
    def __lt__(self, other):
        return -len(self.dataset) < -len(other.dataset)



class ActivePossible(Layer):
    def __init__(self, ac=None, **kwargs):
        self.ac = ac
        super(ActivePossible, self).__init__(**kwargs)

    def call(self, x):
        return K.cast(x, K.floatx()) * self.ac


    def compute_output_shape(self, input_shape):
        return input_shape

    def set_ac(self, ac):
        self.ac = ac


def set_acpos(model, ac, index):
    for i in range(len(ac)):
        model.layers[int(index[i])].set_ac(ac[i])
    return model


def getPuppetModel(modelname):
    m = load_model(modelname)
    model = keras.Sequential()

    model.add(Embedding(BIT, 16, input_length=200))
    model.layers[-1].set_weights(m.layers[0].get_weights())

    model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
    model.layers[-1].set_weights(m.layers[1].get_weights())

    model.add(ActivePossible(ac=np.ones([200, 16])))

    model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
    model.layers[-1].set_weights(m.layers[3].get_weights())

    model.add(ActivePossible(ac=np.ones([200, 16])))

    model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
    model.layers[-1].set_weights(m.layers[5].get_weights())

    model.add(ActivePossible(ac=np.ones([200, 16])))

    model.add(TimeDistributed(Dense(2, activation=None)))
    model.layers[-1].set_weights(m.layers[-1].get_weights())

    return model


def saveRuleTxt(fname, rule):
    f = open("RuleSet\\" + fname, "a")
    for val in list(rule):
        f.write(str(val))
        f.write(" ")
    f.write("\n")
    f.close()


def loaddata(filepath = "data\\train_model_data.pkl"):
    f = open(filepath,"rb")
    data = pickle.load(f)
    X = data[0]
    y = data[1]
    return X, y


def calContributionVec(puppetModel, activationPossible):
    activationPossible = activationPossible.reshape([3, 200, 16])
    puppetModel = set_acpos(puppetModel, activationPossible, [2, 4, 6])
    vec = puppetModel.predict(TESTDATA, batch_size= 5000)[:, 100,]
    vec = vec[:, 1] - vec[:, 0]
    vec = vec.reshape([SEQLENGTH, BIT])
    for i in range(1, BIT):
        vec[:, i] = vec[:, i] - vec[:, 0]
    vec[:, 0] = 0
    return vec


def getActiveNode(lay_1, lay_3, lay_5, seed):
    dataNum = len(seed)
    activationNode = np.zeros([dataNum, 3, 200, 16])
    activationNode[:, 0 , : , :] = \
        (lay_1.predict(seed, batch_size= 20000) > 0).reshape(dataNum, 200, 16)
    activationNode[:, 1 , : , :]= \
        (lay_3.predict(seed, batch_size= 20000) > 0).reshape(dataNum, 200, 16)
    activationNode[:, 2 , : , :]= \
        (lay_5.predict(seed, batch_size=20000) > 0).reshape(dataNum, 200, 16)
    return activationNode



def getActivateState(model, x):
    m_1 = Model(inputs=model.input,
                outputs=model.get_layer(index=1).output)
    m_2 = Model(inputs=model.input,
                outputs=model.get_layer(index=3).output)
    m_3 = Model(inputs=model.input,
                outputs=model.get_layer(index=5).output)
    activationNode = getActiveNode(m_1, m_2, m_3, x)
    return activationNode



def calAcStateFromRule(nowrule, model, testNum = 1000):
    data = np.random.randint(0, BIT, [testNum, FEANUM])
    for r in nowrule:
        pos = int(r / BIT)
        val = r % BIT
        data[:, pos] = val
    acstate = getActivateState(model, data) > 0
    acstate = np.mean(acstate, axis=0)
    return acstate



def calPredy(contributionVec, rule):
    y = 0
    rulepos = []
    for r in rule:
        rulepos.append(int(r / BIT))

    for i in range(SEQLENGTH):
        if i + STARTINDEX not in rulepos:
            y += np.mean(contributionVec[i])
    for r in rule:
        pos = int(r / BIT)
        val = r % BIT
        y += contributionVec[pos - STARTINDEX, val]

    return y





def normalizeData(x, y, size = 2000):
    pos_index = np.where(y == 1)
    neg_index = np.where(y == 0)

    pos_x = np.zeros([size, FEANUM * 3])
    neg_x = np.zeros([size, FEANUM * 3])


    index = np.random.choice(len(pos_index[0]),size,replace=False, p=None)
    for i in range(size):
        col, row = pos_index[0][index[i]], pos_index[1][index[i]]
        theta = 300 - row
        pos_x[i, theta : 200 + theta] = x[col] + 1


    index = np.random.choice(len(neg_index[0]),size,replace=False, p=None)
    for i in range(size):
        col, row = neg_index[0][index[i]], neg_index[1][index[i]]
        theta = 300 - row
        neg_x[i, theta : 200 + theta] = x[col] + 1

    return np.concatenate((pos_x[:, 200:400], neg_x[:, 200:400]), axis= 0)



def ReadtxtRule(fileName):
    RuleSet = []
    f = open(fileName, "r")
    R = f.readlines()
    f.close()
    for r in R:
        rule = r.split(' ')
        RuleSet.append([(int(int(i)/BIT), int(i)%BIT) for i in rule])
    return RuleSet

def ReadRuleSet(fileName):
    f = open(fileName, "rb")
    RuleSet = pickle.load(f)
    f.close()
    return RuleSet