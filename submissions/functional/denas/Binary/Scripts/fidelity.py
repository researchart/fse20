from Binary.Scripts.utils import *
import matplotlib.pyplot as plt
from Binary.Scripts.LEMNA import xai_rnn
import innvestigate




class FidelityMetric():
    def __init__(self, data, model, important, maxselNum, neg_x, step = 5):
        self.data = data.copy()
        self.important = important
        self.maxselNum = maxselNum
        self.neg_x  = neg_x
        self.step = step
        self.iter = int(maxselNum / step)
        self.model = model


    def AugmentTest(self):
        AugmentRes = []
        for i in range(self.iter):
            testdata = self.neg_x.copy()
            xpos = np.arange(0, len(self.data))
            for j in range(i * self.step):
                pos = np.int32(self.important[:, j])
                testdata[xpos, pos] = self.data[xpos, pos]
            AugmentRes.append(np.sum(self.model.predict(testdata)[:, 100, 1] > 0.5) / len(self.data))
        return AugmentRes


    def DeductionTest(self):
        DeductionRes = []
        for i in range(self.iter):
            testdata = self.data.copy()
            xpos = np.arange(0, len(self.data))
            for j in range(i * self.step):
                pos = np.int32(self.important[:, j])
                testdata[xpos, pos] = 0    #1 - self.data[xpos, pos]
            DeductionRes.append(np.sum(self.model.predict(testdata)[:, 100, 1] > 0.5)/ len(self.data))
        return DeductionRes



def calImportance(puppetModel, activationPossible, Template):
    activationPossible = activationPossible.reshape([3, 200, 16])
    puppetModel = set_acpos(puppetModel, activationPossible, [2, 4, 6])
    vec = puppetModel.predict(Template, batch_size=5000)[:, 100, ]
    vec = vec[:, 1] - vec[:, 0]
    vec = vec.reshape([FEANUM])
    return vec


def Construct(x):
    Template = np.zeros([FEANUM, FEANUM])
    for i in range(FEANUM):
        Template[i, i] = x[0,i]
    return Template


class FidelityTest():
    def __init__(self, model, puppetmodel, x, y, neg_x, testNum = 100, selNum = 25, step = 5):
        self.model = model
        self.EmbeddingModel =  self.getEmbeddingModel()
        self.Embedding = Model(model.input, model.layers[0].output)
        self.puppetmodel = puppetmodel

        index = np.random.choice(np.arange(len(x)), testNum)
        x = x[index]
        y = y[index]

        self.x = x
        self.embed_x = self.Embedding.predict(self.x)
        self.y = y
        self.testNum = testNum
        self.selNum = selNum
        self.neg_x = neg_x[0 : testNum]
        self.step = step
        self.baseline = [
            "gradient",
            "integrated_gradients",
            "lrp.epsilon"
        ]

    def getEmbeddingModel(self):
        model = keras.Sequential()
        model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True, )))
        model.add(Activation('relu'))
        model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
        model.add(Activation('relu'))
        model.add(Bidirectional(SimpleRNN(8, activation=None, return_sequences=True)))
        model.add(Activation('relu'))
        model.add(Flatten())
        model.add(Dense(16, use_bias=False, ))
        model.add(Dense(2, activation=None))

        #model.add(Activation('softmax'))


        model.build(input_shape=(None, 200, 16))
        model.compile(optimizer='sgd', loss='binary_crossentropy')
        WWW = np.zeros([3200, 16])
        for i in range(16):
            WWW[1600 + i, i] = 1

        m = self.model
        model.layers[0].set_weights(m.layers[1].get_weights())
        model.layers[2].set_weights(m.layers[3].get_weights())
        model.layers[4].set_weights(m.layers[5].get_weights())
        model.layers[7].set_weights([WWW])
        model.layers[8].set_weights(m.layers[-1].get_weights())

        return model


    def Denasfidelity(self, ):
        importantInx = []
        for i in range(self.testNum):
            x = self.x[i: i + 1]
            Template = Construct(x)
            rule = []
            importantpos = []
            while len(rule) <= self.selNum:
                activationState = calAcStateFromRule(rule, self.model)
                contributionVec = calImportance(self.puppetmodel, activationState, Template)
                for pt in rule:
                    contributionVec[int(pt/BIT)] = -10000
                add = 0
                while add <= self.step:
                    pos = np.argmax((contributionVec))
                    val = x[0,pos]
                    importantpos.append(pos)
                    rule.append(pos * BIT + val)
                    add += 1
                    contributionVec[pos] = -10000
            importantInx.append(np.array(importantpos))
        importantInx = np.array(importantInx)
        RuleSet = []
        for i in range(len(self.x)):
            rule = [[int(j), self.x[i, int(j)]] for j in importantInx[i]]
            RuleSet.append(rule)
        f = open('../RuleSet/denas.pkl', 'wb')
        pickle.dump(RuleSet, f)
        f.close()
        print("denas explain finished")
        metric = FidelityMetric(self.x, self.model, importantInx, self.selNum, self.neg_x, step = self.step)
        a = metric.AugmentTest()
        b = metric.DeductionTest()
        return a, b


    def Lemnafidelity(self,):
        importantInx = np.zeros_like(self.x)
        for i in range(self.testNum):
            x_test = self.x[i: (i + 1)]
            xai_test = xai_rnn(self.model, x_test)
            importantInx[i] = np.array(xai_test.xai_feature(500))
        RuleSet = []
        for i in range(len(self.x)):
            rule = [[int(j), self.x[i, int(j)]] for j in importantInx[i]]
            RuleSet.append(rule)
        f = open('../RuleSet/lemna.pkl', 'wb')
        pickle.dump(RuleSet, f)
        f.close()

        print("lemna finish extract explanation")

        metric = FidelityMetric(self.x, self.model, importantInx, self.selNum, self.neg_x, step = self.step)
        a = metric.AugmentTest()
        b = metric.DeductionTest()
        return a, b


    def Baselinefidelity(self, i_num, num = 2):
        analysis = np.zeros_like(self.embed_x, dtype=np.float32)
        step = int(self.testNum / num)
        ig = innvestigate.create_analyzer(self.baseline[i_num], self.EmbeddingModel)
        for i in range(num):
            st = int((i) * step)
            ed = int((i + 1) * step)
            analysis[st : ed] = ig.analyze(self.embed_x[st : ed])

        analysis = np.sum(analysis, 2)
        importIndex = np.argsort(-analysis, axis= 1)
        RuleSet = []
        for i in range(len(self.x)):
            rule = [[j, self.x[i,j] ] for j in importIndex[i]]
            RuleSet.append(rule)
        f = open('../RuleSet/'+ self.baseline[i_num] + '.pkl', 'wb')
        pickle.dump(RuleSet, f)
        f.close()

        print(self.baseline[i_num], "finish explanation")
        metric = FidelityMetric(self.x, self.model, importIndex, self.selNum, self.neg_x)
        a = metric.AugmentTest()
        b = metric.DeductionTest()
        return a, b


def getFidelityRes(fid ):
    baselineNum = 3
    AugplotArr = np.zeros([5, baselineNum + 2])
    DecplotArr = np.zeros([5, baselineNum + 2])

    x_axis = np.arange(0, 25, 5)
    for i in range(baselineNum):
        AugplotArr[:, i ], DecplotArr[:, i ] = fid.Baselinefidelity(i)
    AugplotArr[:, baselineNum], DecplotArr[:, baselineNum] = fid.Lemnafidelity()
    AugplotArr[:, baselineNum + 1], DecplotArr[:, baselineNum + 1] = fid.Denasfidelity()

    np.savetxt("../Results/AugplotArr.csv", AugplotArr, delimiter=',')
    np.savetxt("../Results/DecplotArr.csv", DecplotArr, delimiter=',')
    print('AugoArr')
    print(AugplotArr)
    print('DecArr')
    print(DecplotArr)

    L = []
    name = ["gradient", "ig", "deeptaylor", 'lemna', 'denas']
    for i in range(baselineNum + 2):
        l, = plt.plot(x_axis, AugplotArr[:, i])
        L.append(l)
    plt.legend(handles=L, labels=name)
    plt.savefig("../Results/AugplotArr.png")
    plt.cla()



    L = []
    for i in range(baselineNum + 2):
        l, = plt.plot(x_axis, DecplotArr[:, i])
        L.append(l)
    plt.legend(handles=L, labels=name)
    plt.savefig("../Results/DecplotArr.png")
    plt.cla()




def main():
    model = load_model("../model/rnn_model.h5")
    x, y = loaddata("../data/test_DNN_data.pkl")
    x = normalizeData(x, y)

    np.save('../Results/x', x)
    np.save('../Results/y', y)

    pred_y = (model.predict(x, batch_size=5000)[:, 100, 1]) > 0.5
    print(np.sum(pred_y))


    pos_x = x[np.where(pred_y > 0)[0]]
    neg_x = x[np.where(pred_y == 0)[0]]

    puppetModel = getPuppetModel("../model/rnn_model.h5")


    fid = FidelityTest(model, puppetModel, pos_x, y, neg_x, testNum= 1000)
    getFidelityRes(fid)
    print("finish accuracy experiment")


if __name__ == "__main__":
    main()






