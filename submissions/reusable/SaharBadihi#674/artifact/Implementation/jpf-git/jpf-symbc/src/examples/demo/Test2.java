package demo;
public class Test2{
        int test(int a){
            boolean b = false;
            if(b){
                return a;
            }
            return 2;
        }

    public static void main(String[] args){
        Test2 test = new Test2();
        test.test(2);
    }
}