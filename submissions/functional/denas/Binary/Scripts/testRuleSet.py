from Binary.Scripts.Metric import *
import matplotlib.pyplot as plt


class GlobalTest():
    def __init__(self, x, y, model, testRuleNum=1000):
        self.x = x
        self.y = y
        self.model = model
        self.mean_vec = np.mean(np.sum(x, axis=1))
        self.pred_y = (model.predict(x, batch_size = 500)[:,:,1] > 0.5)

        self.pos_x = []
        for i in range(len(x)):
            for j in range(20, 170):
                if  self.pred_y[i][j] == 1:
                    tmp = np.zeros([1, 200])
                    tmp[0, 80:121] = self.x[i][j-20:j+21]
                    self.pos_x.append(tmp)
        self.pos_x= np.concatenate(self.pos_x, axis=0)
        self.pos_x = x[np.where(self.pred_y == 1)[0]]


        self.DenasRule = ReadRuleSet('../RuleSet/RuleSet.pkl')
        self.DenasRule = [r[:10] for r in self.DenasRule]
        self.TreeRule = ReadRuleSet("../RuleSet/tre.pkl")
        self.TreeRule = self.TreeRule[:testRuleNum]
        self.LemnaRule  = ReadRuleSet("../RuleSet/lemna.pkl")
        self.LemnaRule = [r[:10] for r in self.LemnaRule]
        self.GradientRule = ReadRuleSet("../RuleSet/gradient.pkl")
        self.GradientRule = [r[:10] for r in self.GradientRule]
        self.IGRule = ReadRuleSet("../RuleSet/integrated_gradients.pkl")
        self.IGRule = [r[:10] for r in self.IGRule]
        self.DPDrule =  ReadRuleSet("../RuleSet/lrp.epsilon.pkl")
        self.DPDrule = [r[:10] for r in self.DPDrule]
        self.testRuleNum = testRuleNum



    def CompareCoverage(self):
        self.coverage = np.zeros([self.testRuleNum, 6])

        self.coverage[:, 0] = testCoverage(self.DenasRule, self.pos_x)
        self.coverage[:, 1] = testCoverage(self.TreeRule, self.pos_x)
        self.coverage[:, 2] = testCoverage(self.GradientRule, self.pos_x)
        self.coverage[:, 3] = testCoverage(self.IGRule, self.pos_x)
        self.coverage[:, 4] = testCoverage(self.DPDrule, self.pos_x)
        self.coverage[:, 5] = testCoverage(self.LemnaRule, self.pos_x)

        np.savetxt('../Results/coverage.csv', self.coverage, delimiter=',')
        print("get coverage result")


    def CompareConsistIn(self):
        self.consist_in = np.zeros([5, 6])
        maxlen  = 5
        consistency_1 =  ConsistencyIn(self.x, self.DenasRule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 0] = np.mean(consistency_1)
        consistency_2 =  ConsistencyIn(self.x, self.TreeRule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 1] = np.mean(consistency_2)

        consistency_3 =  ConsistencyIn(self.x, self.GradientRule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 2] = np.mean(consistency_3)
        consistency_4 =  ConsistencyIn(self.x, self.IGRule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 3] = np.mean(consistency_4)
        consistency_5 =  ConsistencyIn(self.x, self.DPDrule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 4] = np.mean(consistency_5)
        consistency_6 =  ConsistencyIn(self.x, self.LemnaRule, self.pred_y, maxlength=maxlen)
        self.consist_in[4, 5] = np.mean(consistency_6)

        self.DenasRule = [ self.DenasRule[i] for i in range(len(consistency_1)) if consistency_1[i] != 0][
                         0: self.testRuleNum]
        self.TreeRule =[ self.TreeRule[i] for i in range(len(consistency_2)) if consistency_2[i] != 0][
                       0 : self.testRuleNum]
        self.GradientRule = [ self.GradientRule[i] for i in range(len(consistency_3)) if consistency_3[i] != 0][
                            0: self.testRuleNum]
        self.IGRule = [self.IGRule[i] for i in range(len(consistency_4)) if consistency_4[i] != 0][
                            0: self.testRuleNum]
        self.DPDrule = [self.DPDrule[i] for i in range(len(consistency_5)) if consistency_5[i] != 0][
                            0: self.testRuleNum]
        self.LemnaRule = [self.LemnaRule[i] for i in range(len(consistency_6)) if consistency_6[i] != 0][
                            0: self.testRuleNum]

        #np.savetxt('../Results/con_in.csv', self.consist_in, delimiter=',')
        #print("get consistency result in distribution")


    def CompareConsistOut(self):
        self.consist_out = np.zeros([5, 6])
        newx = self.x + np.int32(np.random.random(self.x.shape) < (self.mean_vec * 10 / FEANUM))
        newx = (newx != 0)
        newy = (self.model.predict(newx, batch_size=200) > 0.5)

        maxlen = 5
        self.consist_out[4, 0] = np.mean(ConsistencyIn(newx, self.DenasRule, newy, maxlength=maxlen))
        self.consist_out[4, 1] = np.mean(ConsistencyIn(newx, self.TreeRule, newy, maxlength=maxlen))
        self.consist_out[4, 2] = np.mean(ConsistencyIn(newx, self.GradientRule, newy, maxlength=maxlen))
        self.consist_out[4, 3] = np.mean(ConsistencyIn(newx, self.IGRule, newy, maxlength=maxlen))
        self.consist_out[4, 4] = np.mean(ConsistencyIn(newx, self.DPDrule, newy, maxlength=maxlen))
        self.consist_out[4, 5] = np.mean(ConsistencyIn(newx, self.LemnaRule, newy, maxlength=maxlen))

        #np.savetxt('../Results/con_out.csv', self.consist_out, delimiter=',')
        #print("get consistency result out of distribution")


    def PlotResult(self):
        self.CompareConsistOut()
        self.CompareConsistIn()
        self.CompareCoverage()

        name = ['denas', 'tree', 'gradient', 'IG', 'deeptaylor', 'lemna']

        print(self.coverage)
        L = []
        for i in range(6):
            l, = plt.plot(self.coverage[:,i])
            L.append(l)
        plt.legend(handles=L, labels=name)
        plt.savefig('../Results/coverage.png')
        #plt.show()



def main():

    x = np.load('../Results/x.npy')
    y = np.load('../Results/y.npy')

    model = load_model('../model/rnn_model.h5')
    g = GlobalTest(x, y, model,testRuleNum=1000)
    g.PlotResult()


if __name__ == '__main__':
    main()