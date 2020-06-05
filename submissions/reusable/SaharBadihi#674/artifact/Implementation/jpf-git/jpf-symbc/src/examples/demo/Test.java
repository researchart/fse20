package demo;
public class Test{
    int test(int a){
        boolean b = true;
        if(b){
            return a;
        }
        return 2;
    }

    public static void main(String[] args){
        Test test = new Test();
        test.test(2);
    }
}