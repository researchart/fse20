echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/power/test/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/Eq/oldV.java --path2 ../benchmarks/power/test/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/Eq/oldV.java --path2 ../benchmarks/power/test/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/Eq/oldV.java --path2 ../benchmarks/power/test/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/power/test/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/NEq/oldV.java --path2 ../benchmarks/power/test/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/NEq/oldV.java --path2 ../benchmarks/power/test/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/power/test/NEq/oldV.java --path2 ../benchmarks/power/test/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/dart/test/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/Eq/oldV.java --path2 ../benchmarks/dart/test/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/Eq/oldV.java --path2 ../benchmarks/dart/test/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/Eq/oldV.java --path2 ../benchmarks/dart/test/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/dart/test/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/NEq/oldV.java --path2 ../benchmarks/dart/test/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/NEq/oldV.java --path2 ../benchmarks/dart/test/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/dart/test/NEq/oldV.java --path2 ../benchmarks/dart/test/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/sine/mysin/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/Eq/oldV.java --path2 ../benchmarks/sine/mysin/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/Eq/oldV.java --path2 ../benchmarks/sine/mysin/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/Eq/oldV.java --path2 ../benchmarks/sine/mysin/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/sine/mysin/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/NEq/oldV.java --path2 ../benchmarks/sine/mysin/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/NEq/oldV.java --path2 ../benchmarks/sine/mysin/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/sine/mysin/NEq/oldV.java --path2 ../benchmarks/sine/mysin/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Airy/MAX/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/Eq/oldV.java --path2 ../benchmarks/Airy/MAX/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/Eq/oldV.java --path2 ../benchmarks/Airy/MAX/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/Eq/oldV.java --path2 ../benchmarks/Airy/MAX/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Airy/MAX/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/NEq/oldV.java --path2 ../benchmarks/Airy/MAX/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/NEq/oldV.java --path2 ../benchmarks/Airy/MAX/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/MAX/NEq/oldV.java --path2 ../benchmarks/Airy/MAX/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Airy/Sign/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/Eq/oldV.java --path2 ../benchmarks/Airy/Sign/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/Eq/oldV.java --path2 ../benchmarks/Airy/Sign/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/Eq/oldV.java --path2 ../benchmarks/Airy/Sign/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Airy/Sign/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/NEq/oldV.java --path2 ../benchmarks/Airy/Sign/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/NEq/oldV.java --path2 ../benchmarks/Airy/Sign/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Airy/Sign/NEq/oldV.java --path2 ../benchmarks/Airy/Sign/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/Eq/oldV.java --path2 ../benchmarks/Bess/bessi/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/Eq/oldV.java --path2 ../benchmarks/Bess/bessi/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/Eq/oldV.java --path2 ../benchmarks/Bess/bessi/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/NEq/oldV.java --path2 ../benchmarks/Bess/bessi/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/NEq/oldV.java --path2 ../benchmarks/Bess/bessi/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi/NEq/oldV.java --path2 ../benchmarks/Bess/bessi/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/pythag/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/Eq/oldV.java --path2 ../benchmarks/Bess/pythag/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/Eq/oldV.java --path2 ../benchmarks/Bess/pythag/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/Eq/oldV.java --path2 ../benchmarks/Bess/pythag/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/pythag/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/NEq/oldV.java --path2 ../benchmarks/Bess/pythag/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/NEq/oldV.java --path2 ../benchmarks/Bess/pythag/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/pythag/NEq/oldV.java --path2 ../benchmarks/Bess/pythag/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy1/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/Eq/oldV.java --path2 ../benchmarks/Bess/bessy1/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/Eq/oldV.java --path2 ../benchmarks/Bess/bessy1/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/Eq/oldV.java --path2 ../benchmarks/Bess/bessy1/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy1/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/NEq/oldV.java --path2 ../benchmarks/Bess/bessy1/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/NEq/oldV.java --path2 ../benchmarks/Bess/bessy1/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy1/NEq/oldV.java --path2 ../benchmarks/Bess/bessy1/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy0/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/Eq/oldV.java --path2 ../benchmarks/Bess/bessy0/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/Eq/oldV.java --path2 ../benchmarks/Bess/bessy0/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/Eq/oldV.java --path2 ../benchmarks/Bess/bessy0/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy0/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/NEq/oldV.java --path2 ../benchmarks/Bess/bessy0/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/NEq/oldV.java --path2 ../benchmarks/Bess/bessy0/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy0/NEq/oldV.java --path2 ../benchmarks/Bess/bessy0/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/probks/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/Eq/oldV.java --path2 ../benchmarks/Bess/probks/Eq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/Eq/oldV.java --path2 ../benchmarks/Bess/probks/Eq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/Eq/oldV.java --path2 ../benchmarks/Bess/probks/Eq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/probks/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/NEq/oldV.java --path2 ../benchmarks/Bess/probks/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/NEq/oldV.java --path2 ../benchmarks/Bess/probks/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/probks/NEq/oldV.java --path2 ../benchmarks/Bess/probks/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk0/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/Eq/oldV.java --path2 ../benchmarks/Bess/bessk0/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/Eq/oldV.java --path2 ../benchmarks/Bess/bessk0/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/Eq/oldV.java --path2 ../benchmarks/Bess/bessk0/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk0/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/NEq/oldV.java --path2 ../benchmarks/Bess/bessk0/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/NEq/oldV.java --path2 ../benchmarks/Bess/bessk0/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk0/NEq/oldV.java --path2 ../benchmarks/Bess/bessk0/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/SQR/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/Eq/oldV.java --path2 ../benchmarks/Bess/SQR/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/Eq/oldV.java --path2 ../benchmarks/Bess/SQR/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/Eq/oldV.java --path2 ../benchmarks/Bess/SQR/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/SQR/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/NEq/oldV.java --path2 ../benchmarks/Bess/SQR/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/NEq/oldV.java --path2 ../benchmarks/Bess/SQR/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SQR/NEq/oldV.java --path2 ../benchmarks/Bess/SQR/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/dawson/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/Eq/oldV.java --path2 ../benchmarks/Bess/dawson/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/Eq/oldV.java --path2 ../benchmarks/Bess/dawson/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/Eq/oldV.java --path2 ../benchmarks/Bess/dawson/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/dawson/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/NEq/oldV.java --path2 ../benchmarks/Bess/dawson/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/NEq/oldV.java --path2 ../benchmarks/Bess/dawson/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/dawson/NEq/oldV.java --path2 ../benchmarks/Bess/dawson/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk1/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/Eq/oldV.java --path2 ../benchmarks/Bess/bessk1/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/Eq/oldV.java --path2 ../benchmarks/Bess/bessk1/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/Eq/oldV.java --path2 ../benchmarks/Bess/bessk1/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk1/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/NEq/oldV.java --path2 ../benchmarks/Bess/bessk1/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/NEq/oldV.java --path2 ../benchmarks/Bess/bessk1/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk1/NEq/oldV.java --path2 ../benchmarks/Bess/bessk1/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi0/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/Eq/oldV.java --path2 ../benchmarks/Bess/bessi0/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/Eq/oldV.java --path2 ../benchmarks/Bess/bessi0/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/Eq/oldV.java --path2 ../benchmarks/Bess/bessi0/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi0/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/NEq/oldV.java --path2 ../benchmarks/Bess/bessi0/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/NEq/oldV.java --path2 ../benchmarks/Bess/bessi0/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi0/NEq/oldV.java --path2 ../benchmarks/Bess/bessi0/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj1/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/Eq/oldV.java --path2 ../benchmarks/Bess/bessj1/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/Eq/oldV.java --path2 ../benchmarks/Bess/bessj1/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/Eq/oldV.java --path2 ../benchmarks/Bess/bessj1/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj1/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/NEq/oldV.java --path2 ../benchmarks/Bess/bessj1/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/NEq/oldV.java --path2 ../benchmarks/Bess/bessj1/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj1/NEq/oldV.java --path2 ../benchmarks/Bess/bessj1/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj0/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/Eq/oldV.java --path2 ../benchmarks/Bess/bessj0/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/Eq/oldV.java --path2 ../benchmarks/Bess/bessj0/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/Eq/oldV.java --path2 ../benchmarks/Bess/bessj0/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj0/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/NEq/oldV.java --path2 ../benchmarks/Bess/bessj0/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/NEq/oldV.java --path2 ../benchmarks/Bess/bessj0/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj0/NEq/oldV.java --path2 ../benchmarks/Bess/bessj0/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi1/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/Eq/oldV.java --path2 ../benchmarks/Bess/bessi1/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/Eq/oldV.java --path2 ../benchmarks/Bess/bessi1/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/Eq/oldV.java --path2 ../benchmarks/Bess/bessi1/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessi1/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/NEq/oldV.java --path2 ../benchmarks/Bess/bessi1/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/NEq/oldV.java --path2 ../benchmarks/Bess/bessi1/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessi1/NEq/oldV.java --path2 ../benchmarks/Bess/bessi1/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/Eq/oldV.java --path2 ../benchmarks/Bess/bessj/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/Eq/oldV.java --path2 ../benchmarks/Bess/bessj/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/Eq/oldV.java --path2 ../benchmarks/Bess/bessj/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessj/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/NEq/oldV.java --path2 ../benchmarks/Bess/bessj/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/NEq/oldV.java --path2 ../benchmarks/Bess/bessj/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessj/NEq/oldV.java --path2 ../benchmarks/Bess/bessj/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/Eq/oldV.java --path2 ../benchmarks/Bess/bessk/Eq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/Eq/oldV.java --path2 ../benchmarks/Bess/bessk/Eq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/Eq/oldV.java --path2 ../benchmarks/Bess/bessk/Eq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessk/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/NEq/oldV.java --path2 ../benchmarks/Bess/bessk/NEq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/NEq/oldV.java --path2 ../benchmarks/Bess/bessk/NEq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessk/NEq/oldV.java --path2 ../benchmarks/Bess/bessk/NEq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/Eq/oldV.java --path2 ../benchmarks/Bess/bessy/Eq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/Eq/oldV.java --path2 ../benchmarks/Bess/bessy/Eq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/Eq/oldV.java --path2 ../benchmarks/Bess/bessy/Eq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/bessy/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/NEq/oldV.java --path2 ../benchmarks/Bess/bessy/NEq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/NEq/oldV.java --path2 ../benchmarks/Bess/bessy/NEq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/bessy/NEq/oldV.java --path2 ../benchmarks/Bess/bessy/NEq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/SIGN/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/Eq/oldV.java --path2 ../benchmarks/Bess/SIGN/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/Eq/oldV.java --path2 ../benchmarks/Bess/SIGN/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/Eq/oldV.java --path2 ../benchmarks/Bess/SIGN/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Bess/SIGN/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/NEq/oldV.java --path2 ../benchmarks/Bess/SIGN/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/NEq/oldV.java --path2 ../benchmarks/Bess/SIGN/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Bess/SIGN/NEq/oldV.java --path2 ../benchmarks/Bess/SIGN/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/plgndr/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/Eq/oldV.java --path2 ../benchmarks/Ell/plgndr/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/Eq/oldV.java --path2 ../benchmarks/Ell/plgndr/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/Eq/oldV.java --path2 ../benchmarks/Ell/plgndr/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/plgndr/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/NEq/oldV.java --path2 ../benchmarks/Ell/plgndr/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/NEq/oldV.java --path2 ../benchmarks/Ell/plgndr/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/plgndr/NEq/oldV.java --path2 ../benchmarks/Ell/plgndr/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/ell/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/Eq/oldV.java --path2 ../benchmarks/Ell/ell/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/Eq/oldV.java --path2 ../benchmarks/Ell/ell/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/Eq/oldV.java --path2 ../benchmarks/Ell/ell/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/ell/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/NEq/oldV.java --path2 ../benchmarks/Ell/ell/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/NEq/oldV.java --path2 ../benchmarks/Ell/ell/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ell/NEq/oldV.java --path2 ../benchmarks/Ell/ell/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rf/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/Eq/oldV.java --path2 ../benchmarks/Ell/rf/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/Eq/oldV.java --path2 ../benchmarks/Ell/rf/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/Eq/oldV.java --path2 ../benchmarks/Ell/rf/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rf/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/NEq/oldV.java --path2 ../benchmarks/Ell/rf/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/NEq/oldV.java --path2 ../benchmarks/Ell/rf/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rf/NEq/oldV.java --path2 ../benchmarks/Ell/rf/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/dbrent/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/Eq/oldV.java --path2 ../benchmarks/Ell/dbrent/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/Eq/oldV.java --path2 ../benchmarks/Ell/dbrent/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/Eq/oldV.java --path2 ../benchmarks/Ell/dbrent/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/dbrent/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/NEq/oldV.java --path2 ../benchmarks/Ell/dbrent/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/NEq/oldV.java --path2 ../benchmarks/Ell/dbrent/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/dbrent/NEq/oldV.java --path2 ../benchmarks/Ell/dbrent/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/ellpi/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/Eq/oldV.java --path2 ../benchmarks/Ell/ellpi/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/Eq/oldV.java --path2 ../benchmarks/Ell/ellpi/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/Eq/oldV.java --path2 ../benchmarks/Ell/ellpi/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/ellpi/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/NEq/oldV.java --path2 ../benchmarks/Ell/ellpi/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/NEq/oldV.java --path2 ../benchmarks/Ell/ellpi/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/ellpi/NEq/oldV.java --path2 ../benchmarks/Ell/ellpi/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/brent/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/Eq/oldV.java --path2 ../benchmarks/Ell/brent/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/Eq/oldV.java --path2 ../benchmarks/Ell/brent/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/Eq/oldV.java --path2 ../benchmarks/Ell/brent/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/brent/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/NEq/oldV.java --path2 ../benchmarks/Ell/brent/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/NEq/oldV.java --path2 ../benchmarks/Ell/brent/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/brent/NEq/oldV.java --path2 ../benchmarks/Ell/brent/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rd/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/Eq/oldV.java --path2 ../benchmarks/Ell/rd/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/Eq/oldV.java --path2 ../benchmarks/Ell/rd/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/Eq/oldV.java --path2 ../benchmarks/Ell/rd/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rd/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/NEq/oldV.java --path2 ../benchmarks/Ell/rd/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/NEq/oldV.java --path2 ../benchmarks/Ell/rd/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rd/NEq/oldV.java --path2 ../benchmarks/Ell/rd/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rc/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/Eq/oldV.java --path2 ../benchmarks/Ell/rc/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/Eq/oldV.java --path2 ../benchmarks/Ell/rc/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/Eq/oldV.java --path2 ../benchmarks/Ell/rc/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rc/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/NEq/oldV.java --path2 ../benchmarks/Ell/rc/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/NEq/oldV.java --path2 ../benchmarks/Ell/rc/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rc/NEq/oldV.java --path2 ../benchmarks/Ell/rc/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rj/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/Eq/oldV.java --path2 ../benchmarks/Ell/rj/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/Eq/oldV.java --path2 ../benchmarks/Ell/rj/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/Eq/oldV.java --path2 ../benchmarks/Ell/rj/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/rj/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/NEq/oldV.java --path2 ../benchmarks/Ell/rj/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/NEq/oldV.java --path2 ../benchmarks/Ell/rj/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/rj/NEq/oldV.java --path2 ../benchmarks/Ell/rj/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/zbrent/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/Eq/oldV.java --path2 ../benchmarks/Ell/zbrent/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/Eq/oldV.java --path2 ../benchmarks/Ell/zbrent/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/Eq/oldV.java --path2 ../benchmarks/Ell/zbrent/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ell/zbrent/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/NEq/oldV.java --path2 ../benchmarks/Ell/zbrent/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/NEq/oldV.java --path2 ../benchmarks/Ell/zbrent/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ell/zbrent/NEq/oldV.java --path2 ../benchmarks/Ell/zbrent/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/caldat/julday/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/Eq/oldV.java --path2 ../benchmarks/caldat/julday/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/Eq/oldV.java --path2 ../benchmarks/caldat/julday/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/Eq/oldV.java --path2 ../benchmarks/caldat/julday/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/caldat/julday/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/NEq/oldV.java --path2 ../benchmarks/caldat/julday/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/NEq/oldV.java --path2 ../benchmarks/caldat/julday/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/julday/NEq/oldV.java --path2 ../benchmarks/caldat/julday/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/caldat/badluk/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/Eq/oldV.java --path2 ../benchmarks/caldat/badluk/Eq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/Eq/oldV.java --path2 ../benchmarks/caldat/badluk/Eq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/Eq/oldV.java --path2 ../benchmarks/caldat/badluk/Eq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/caldat/badluk/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/NEq/oldV.java --path2 ../benchmarks/caldat/badluk/NEq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/NEq/oldV.java --path2 ../benchmarks/caldat/badluk/NEq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/caldat/badluk/NEq/oldV.java --path2 ../benchmarks/caldat/badluk/NEq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/poidev/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/Eq/oldV.java --path2 ../benchmarks/Ran/poidev/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/Eq/oldV.java --path2 ../benchmarks/Ran/poidev/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/Eq/oldV.java --path2 ../benchmarks/Ran/poidev/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/poidev/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/NEq/oldV.java --path2 ../benchmarks/Ran/poidev/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/NEq/oldV.java --path2 ../benchmarks/Ran/poidev/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/poidev/NEq/oldV.java --path2 ../benchmarks/Ran/poidev/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/expdev/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/Eq/oldV.java --path2 ../benchmarks/Ran/expdev/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/Eq/oldV.java --path2 ../benchmarks/Ran/expdev/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/Eq/oldV.java --path2 ../benchmarks/Ran/expdev/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/expdev/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/NEq/oldV.java --path2 ../benchmarks/Ran/expdev/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/NEq/oldV.java --path2 ../benchmarks/Ran/expdev/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/expdev/NEq/oldV.java --path2 ../benchmarks/Ran/expdev/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gamdev/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/Eq/oldV.java --path2 ../benchmarks/Ran/gamdev/Eq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/Eq/oldV.java --path2 ../benchmarks/Ran/gamdev/Eq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/Eq/oldV.java --path2 ../benchmarks/Ran/gamdev/Eq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gamdev/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/NEq/oldV.java --path2 ../benchmarks/Ran/gamdev/NEq/newV.java --tool D --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/NEq/oldV.java --path2 ../benchmarks/Ran/gamdev/NEq/newV.java --tool I --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gamdev/NEq/oldV.java --path2 ../benchmarks/Ran/gamdev/NEq/newV.java --tool A --s coral --b 3 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/bnldev/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/Eq/oldV.java --path2 ../benchmarks/Ran/bnldev/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/Eq/oldV.java --path2 ../benchmarks/Ran/bnldev/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/Eq/oldV.java --path2 ../benchmarks/Ran/bnldev/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/bnldev/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/NEq/oldV.java --path2 ../benchmarks/Ran/bnldev/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/NEq/oldV.java --path2 ../benchmarks/Ran/bnldev/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/bnldev/NEq/oldV.java --path2 ../benchmarks/Ran/bnldev/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/ranzero/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/Eq/oldV.java --path2 ../benchmarks/Ran/ranzero/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/Eq/oldV.java --path2 ../benchmarks/Ran/ranzero/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/Eq/oldV.java --path2 ../benchmarks/Ran/ranzero/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/ranzero/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/NEq/oldV.java --path2 ../benchmarks/Ran/ranzero/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/NEq/oldV.java --path2 ../benchmarks/Ran/ranzero/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ranzero/NEq/oldV.java --path2 ../benchmarks/Ran/ranzero/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/ran/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/Eq/oldV.java --path2 ../benchmarks/Ran/ran/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/Eq/oldV.java --path2 ../benchmarks/Ran/ran/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/Eq/oldV.java --path2 ../benchmarks/Ran/ran/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/ran/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/NEq/oldV.java --path2 ../benchmarks/Ran/ran/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/NEq/oldV.java --path2 ../benchmarks/Ran/ran/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/ran/NEq/oldV.java --path2 ../benchmarks/Ran/ran/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gammln/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/Eq/oldV.java --path2 ../benchmarks/Ran/gammln/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/Eq/oldV.java --path2 ../benchmarks/Ran/gammln/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/Eq/oldV.java --path2 ../benchmarks/Ran/gammln/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gammln/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/NEq/oldV.java --path2 ../benchmarks/Ran/gammln/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/NEq/oldV.java --path2 ../benchmarks/Ran/gammln/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gammln/NEq/oldV.java --path2 ../benchmarks/Ran/gammln/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gasdev/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/Eq/oldV.java --path2 ../benchmarks/Ran/gasdev/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/Eq/oldV.java --path2 ../benchmarks/Ran/gasdev/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/Eq/oldV.java --path2 ../benchmarks/Ran/gasdev/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/Ran/gasdev/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/NEq/oldV.java --path2 ../benchmarks/Ran/gasdev/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/NEq/oldV.java --path2 ../benchmarks/Ran/gasdev/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/Ran/gasdev/NEq/oldV.java --path2 ../benchmarks/Ran/gasdev/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/expint/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/Eq/oldV.java --path2 ../benchmarks/gam/expint/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/Eq/oldV.java --path2 ../benchmarks/gam/expint/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/Eq/oldV.java --path2 ../benchmarks/gam/expint/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/expint/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/NEq/oldV.java --path2 ../benchmarks/gam/expint/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/NEq/oldV.java --path2 ../benchmarks/gam/expint/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/expint/NEq/oldV.java --path2 ../benchmarks/gam/expint/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gser/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/Eq/oldV.java --path2 ../benchmarks/gam/gser/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/Eq/oldV.java --path2 ../benchmarks/gam/gser/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/Eq/oldV.java --path2 ../benchmarks/gam/gser/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gser/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/NEq/oldV.java --path2 ../benchmarks/gam/gser/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/NEq/oldV.java --path2 ../benchmarks/gam/gser/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gser/NEq/oldV.java --path2 ../benchmarks/gam/gser/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/betacf/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/Eq/oldV.java --path2 ../benchmarks/gam/betacf/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/Eq/oldV.java --path2 ../benchmarks/gam/betacf/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/Eq/oldV.java --path2 ../benchmarks/gam/betacf/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/betacf/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/NEq/oldV.java --path2 ../benchmarks/gam/betacf/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/NEq/oldV.java --path2 ../benchmarks/gam/betacf/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betacf/NEq/oldV.java --path2 ../benchmarks/gam/betacf/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/betai/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/Eq/oldV.java --path2 ../benchmarks/gam/betai/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/Eq/oldV.java --path2 ../benchmarks/gam/betai/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/Eq/oldV.java --path2 ../benchmarks/gam/betai/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/betai/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/NEq/oldV.java --path2 ../benchmarks/gam/betai/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/NEq/oldV.java --path2 ../benchmarks/gam/betai/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/betai/NEq/oldV.java --path2 ../benchmarks/gam/betai/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/erfcc/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/Eq/oldV.java --path2 ../benchmarks/gam/erfcc/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/Eq/oldV.java --path2 ../benchmarks/gam/erfcc/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/Eq/oldV.java --path2 ../benchmarks/gam/erfcc/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/erfcc/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/NEq/oldV.java --path2 ../benchmarks/gam/erfcc/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/NEq/oldV.java --path2 ../benchmarks/gam/erfcc/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/erfcc/NEq/oldV.java --path2 ../benchmarks/gam/erfcc/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gammp/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/Eq/oldV.java --path2 ../benchmarks/gam/gammp/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/Eq/oldV.java --path2 ../benchmarks/gam/gammp/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/Eq/oldV.java --path2 ../benchmarks/gam/gammp/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gammp/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/NEq/oldV.java --path2 ../benchmarks/gam/gammp/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/NEq/oldV.java --path2 ../benchmarks/gam/gammp/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammp/NEq/oldV.java --path2 ../benchmarks/gam/gammp/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gammq/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/Eq/oldV.java --path2 ../benchmarks/gam/gammq/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/Eq/oldV.java --path2 ../benchmarks/gam/gammq/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/Eq/oldV.java --path2 ../benchmarks/gam/gammq/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gammq/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/NEq/oldV.java --path2 ../benchmarks/gam/gammq/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/NEq/oldV.java --path2 ../benchmarks/gam/gammq/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gammq/NEq/oldV.java --path2 ../benchmarks/gam/gammq/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/ei/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/Eq/oldV.java --path2 ../benchmarks/gam/ei/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/Eq/oldV.java --path2 ../benchmarks/gam/ei/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/Eq/oldV.java --path2 ../benchmarks/gam/ei/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/ei/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/NEq/oldV.java --path2 ../benchmarks/gam/ei/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/NEq/oldV.java --path2 ../benchmarks/gam/ei/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/ei/NEq/oldV.java --path2 ../benchmarks/gam/ei/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gcf/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/Eq/oldV.java --path2 ../benchmarks/gam/gcf/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/Eq/oldV.java --path2 ../benchmarks/gam/gcf/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/Eq/oldV.java --path2 ../benchmarks/gam/gcf/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/gam/gcf/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/NEq/oldV.java --path2 ../benchmarks/gam/gcf/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/NEq/oldV.java --path2 ../benchmarks/gam/gcf/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/gam/gcf/NEq/oldV.java --path2 ../benchmarks/gam/gcf/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/normAngle/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/Eq/oldV.java --path2 ../benchmarks/tsafe/normAngle/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/Eq/oldV.java --path2 ../benchmarks/tsafe/normAngle/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/Eq/oldV.java --path2 ../benchmarks/tsafe/normAngle/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/normAngle/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/NEq/oldV.java --path2 ../benchmarks/tsafe/normAngle/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/NEq/oldV.java --path2 ../benchmarks/tsafe/normAngle/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/normAngle/NEq/oldV.java --path2 ../benchmarks/tsafe/normAngle/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/snippet/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/Eq/oldV.java --path2 ../benchmarks/tsafe/snippet/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/Eq/oldV.java --path2 ../benchmarks/tsafe/snippet/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/Eq/oldV.java --path2 ../benchmarks/tsafe/snippet/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/snippet/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/NEq/oldV.java --path2 ../benchmarks/tsafe/snippet/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/NEq/oldV.java --path2 ../benchmarks/tsafe/snippet/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/snippet/NEq/oldV.java --path2 ../benchmarks/tsafe/snippet/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/conflict/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/Eq/oldV.java --path2 ../benchmarks/tsafe/conflict/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/Eq/oldV.java --path2 ../benchmarks/tsafe/conflict/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/Eq/oldV.java --path2 ../benchmarks/tsafe/conflict/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tsafe/conflict/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/NEq/oldV.java --path2 ../benchmarks/tsafe/conflict/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/NEq/oldV.java --path2 ../benchmarks/tsafe/conflict/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tsafe/conflict/NEq/oldV.java --path2 ../benchmarks/tsafe/conflict/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/NonCrossingBiasedClimb/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/NonCrossingBiasedClimb/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedClimb/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/NonCrossingBiasedDescend/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/NonCrossingBiasedDescend/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/oldV.java --path2 ../benchmarks/tcas/NonCrossingBiasedDescend/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/altseptest/Eq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/Eq/oldV.java --path2 ../benchmarks/tcas/altseptest/Eq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/Eq/oldV.java --path2 ../benchmarks/tcas/altseptest/Eq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/Eq/oldV.java --path2 ../benchmarks/tcas/altseptest/Eq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/tcas/altseptest/NEq     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/NEq/oldV.java --path2 ../benchmarks/tcas/altseptest/NEq/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/NEq/oldV.java --path2 ../benchmarks/tcas/altseptest/NEq/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/tcas/altseptest/NEq/oldV.java --path2 ../benchmarks/tcas/altseptest/NEq/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopMult2     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult2/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult2/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult2/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopMult5     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult5/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult5/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult5/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/UnchLoop     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/Eq/UnchLoop/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/Eq/UnchLoop/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/Eq/UnchLoop/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopMult15     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult15/newV.java --tool D --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult15/newV.java --tool I --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult15/newV.java --tool A --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopUnreach2     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach2/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach2/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach2/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopUnreach5     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach5/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach5/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach5/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopSub     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopSub/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopSub/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopSub/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopUnreach15     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach15/newV.java --tool D --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach15/newV.java --tool I --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach15/newV.java --tool A --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/Comp     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Comp/oldV.java --path2 ../benchmarks/ModDiff/Eq/Comp/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Comp/oldV.java --path2 ../benchmarks/ModDiff/Eq/Comp/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Comp/oldV.java --path2 ../benchmarks/ModDiff/Eq/Comp/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/Const     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Const/oldV.java --path2 ../benchmarks/ModDiff/Eq/Const/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Const/oldV.java --path2 ../benchmarks/ModDiff/Eq/Const/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Const/oldV.java --path2 ../benchmarks/ModDiff/Eq/Const/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/Sub     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Sub/oldV.java --path2 ../benchmarks/ModDiff/Eq/Sub/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Sub/oldV.java --path2 ../benchmarks/ModDiff/Eq/Sub/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Sub/oldV.java --path2 ../benchmarks/ModDiff/Eq/Sub/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/Add     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Add/oldV.java --path2 ../benchmarks/ModDiff/Eq/Add/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Add/oldV.java --path2 ../benchmarks/ModDiff/Eq/Add/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/Add/oldV.java --path2 ../benchmarks/ModDiff/Eq/Add/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopMult20     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult20/newV.java --tool D --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult20/newV.java --tool I --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult20/newV.java --tool A --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopUnreach10     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach10/newV.java --tool D --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach10/newV.java --tool I --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach10/newV.java --tool A --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopMult10     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult10/newV.java --tool D --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult10/newV.java --tool I --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopMult10/newV.java --tool A --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/Eq/LoopUnreach20     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach20/newV.java --tool D --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach20/newV.java --tool I --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/Eq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/Eq/LoopUnreach20/newV.java --tool A --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopMult2     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult2/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult2/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult2/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopMult5     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult5/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult5/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult5/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/UnchLoop     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/NEq/UnchLoop/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/NEq/UnchLoop/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/UnchLoop/oldV.java --path2 ../benchmarks/ModDiff/NEq/UnchLoop/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopMult15     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult15/newV.java --tool D --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult15/newV.java --tool I --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult15/newV.java --tool A --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopUnreach2     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach2/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach2/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach2/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach2/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopUnreach5     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach5/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach5/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach5/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach5/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopSub     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopSub/newV.java --tool D --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopSub/newV.java --tool I --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopSub/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopSub/newV.java --tool A --s coral --b 10 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopUnreach15     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach15/newV.java --tool D --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach15/newV.java --tool I --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach15/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach15/newV.java --tool A --s coral --b 20 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopMult20     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult20/newV.java --tool D --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult20/newV.java --tool I --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult20/newV.java --tool A --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopUnreach10     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach10/newV.java --tool D --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach10/newV.java --tool I --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach10/newV.java --tool A --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopMult10     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult10/newV.java --tool D --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult10/newV.java --tool I --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopMult10/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopMult10/newV.java --tool A --s coral --b 15 & TIMEOUT /T 300 
echo "###################################################################################################" 
echo "###################################################################################################" 
echo "###################################    ../benchmarks/ModDiff/NEq/LoopUnreach20     ###################################" 
echo "###################################################################################################" 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach20/newV.java --tool D --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach20/newV.java --tool I --s coral --b 25 & TIMEOUT /T 300 
echo "###################################################################################################" 
START java -Djava.library.path=jpf-git/jpf-symbc/lib -Xmx20G -Xms16G -jar target/artifacts/Implementation_jar/Implementation.jar --path1 ../benchmarks/ModDiff/NEq/LoopUnreach20/oldV.java --path2 ../benchmarks/ModDiff/NEq/LoopUnreach20/newV.java --tool A --s coral --b 25 & TIMEOUT /T 300 
