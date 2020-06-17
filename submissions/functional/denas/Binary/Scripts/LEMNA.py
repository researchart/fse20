from Binary.Scripts.utils import *
import scipy.optimize as opt
from scipy import stats
from sklearn.linear_model import LinearRegression
import numpy as np
np.random.seed(1234)




#
#






def obj_fun(theta, x, y_):
    pre_dis = np.dot(x, theta)
    loss = np.sum((pre_dis - y_) ** 2)
    return loss







class xai_rnn(object):
    """class for explaining the rnn prediction"""
    def __init__(self, model, data,):
        """
        Args:
            model: target rnn model.
            data: data sample needed to be explained.
            label: label of the data sample.
            start: value of function start.
        """
        self.model = model
        self.data = data
        self.seq_len = data.shape[1]
        self.seq_len = data[0].shape[0]



    def xai_feature(self, samp_num, option= 'None'):
        """extract the important features from the input data
        Arg:
            fea_num: number of features that needed by the user
            samp_num: number of data used for explanation
        return:
            fea: extracted features
        """
        # cen = int(self.seq_len/2)
        # half_tl = int(self.tl/2)
        sample = np.random.randint(0, FEANUM, samp_num)
        data_explain = np.zeros([samp_num, 200])
        for i, size in enumerate(sample, start=0):
            inactive = np.random.choice(FEANUM, size, replace=False)

            tmp_sampled = np.copy(self.data)
            tmp_sampled[0,inactive] = 0 # np.random.choice(range(257), size, replace = True)     #1 - tmp_sampled[0,inactive]
            data_explain[i] = tmp_sampled


        # label_sampled = label_sampled.reshape(label_sampled.shape[0], 1)

        label_sampled = self.model.predict(data_explain, batch_size = 500, verbose = 0)[:, 100, 1:2]

        linreg = LinearRegression(fit_intercept=False)
        linreg.fit(data_explain, label_sampled)
        result = np.argsort(np.abs(linreg.coef_)).reshape([FEANUM])
        importance_score = result[::-1]
        return importance_score

    def gauss_mix_model(self, X, y, model_num, min_err=0.1):
        [data_num, fea_num] = np.shape(X)
        mean = np.random.random([model_num, 1]) * 100
        sigma = np.random.random([model_num, 1]) * 100
        pi = np.ones([model_num, 1]) / model_num

        new_mean = np.zeros_like(mean)
        new_sigma = np.zeros_like(sigma)
        new_pi = np.zeros_like(pi)

        new_z = np.zeros([data_num, model_num])
        err = np.linalg.norm(mean - new_mean)
        nk = np.zeros((model_num, 1))
        while (err > min_err):
            for index in range(data_num):
                for kindex in range(model_num):
                    new_z[index, kindex] = pi[kindex] * stats.norm(mean[kindex, 0], sigma[kindex, 0]).pdf(y[index])
                new_z[index, :] = new_z[index, :] / np.sum(new_z[index, :])
            for kindex in range(model_num):
                nk[kindex] = np.sum(new_z[:, kindex])
                new_pi[kindex, 0] = np.sum(new_z[:, kindex]) / data_num
                sum_mean = 0
                sum_sigma = 0
                for nindex in range(data_num):
                    tmp = new_z[nindex, kindex] * y[nindex]
                    sum_mean = sum_mean + tmp
                new_mean[kindex, :] = sum_mean / nk[kindex]

                for nindex in range(data_num):
                    vec = (y[nindex] - new_mean[kindex, 0])
                    tmp = new_z[nindex, kindex] * (vec * vec)
                    sum_sigma = sum_sigma + tmp
                new_sigma[kindex, 0] = sum_sigma / nk[kindex]
            err = np.linalg.norm(new_mean - mean)
            sigma = new_sigma
            pi = new_pi
            mean = new_mean

        weight = np.zeros(fea_num)
        s = 1e4
        init_k = np.ones([fea_num, 1])
        cons = ({'type': 'ineq',
                 'fun': lambda x: np.array([s - (x[0] - x[1]) ** 2 - (x[1] - x[2]) ** 2])})
        # for iindex in range(fea_num):
        #     for kindex in range(model_num):
        #         result = opt.minimize(obj_fun, init_k, args=(np.array(X), np.array(mean[kindex, :])),
        #                               constraints=cons)
        #         weight[iindex] = result.x[iindex] * pi[kindex] + weight[iindex]
        result = opt.minimize(obj_fun, init_k, args=(np.array(X), np.array(mean[kindex, :])),
                              constraints=cons)
        weight = result.x
######################################################################################
        # X = r.matrix(X, nrow=data_explain.shape[0], ncol=data_explain.shape[1])
        # Y = r.matrix(label_sampled, nrow=label_sampled.shape[0], ncol=label_sampled.shape[1])
        #
        # n = r.nrow(X)
        # p = r.ncol(X)
        # results = r.fusedlasso1d(y=Y, X=X)  # eps = 1e4
        #
        # result = np.array(r.coef(results, np.sqrt(n * np.log(p)))[0])[:, -1]

        return weight
