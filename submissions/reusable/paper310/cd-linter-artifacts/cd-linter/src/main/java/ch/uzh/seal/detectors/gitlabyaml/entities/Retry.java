package ch.uzh.seal.detectors.gitlabyaml.entities;

public class Retry {

    private int max = 0;
    private RetryWhen when = RetryWhen.always;

    public int getMax() {
        return max;
    }

    public void setMax(int max) {
        this.max = max;
    }

    public RetryWhen getWhen() {
        return when;
    }

    public void setWhen(RetryWhen when) {
        this.when = when;
    }

    public void setWhen(String when) {
        this.when = RetryWhen.valueOf(when);
    }
}
