#!/bin/bash
#!/bin/bash
path=$1
generate_files() {
for i in $(seq 1 $2); do
fallocate -l 100M $path/file_$i.txt
done
}
#first test
echo "first test"
rm -rf $path/*
generate_files $path 7
./script.sh $path 2
rm -rf $path/*
echo "test 1 done"

echo "second test"
generate_files $path 2
./script.sh $path 2
rm -rf $path/*
echo "test 2 done"

#third test
echo "third test"
generate_files $path 8
./script.sh $path 10
rm -rf $path/*
echo "test 3 done"

#fourth test
echo "fourth test"
generate_files $path 0
./script.sh $path 2
rm -rf $path/*
echo "test 4 done"