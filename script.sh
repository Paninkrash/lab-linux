#!/bin/bash
if [ $# -ne 2 ]
then
echo "wrong number of arguments!"
exit 1
fi
#Принимаем от пользователя путь к папке и количество файлов, подлежащих архивации при превышении лимита
path=$1
if [ ! -d $path ]
then
echo "no such file of directory: $path"
exit 1
fi
N=$2
parent_path=$(dirname $path)
#Выделчем место на диске и отдаем его fs.img, создаем файловую систему, монтируем ее к входному каталогу
sudo fallocate -l 1G $parent_path/fs.img
sudo mkfs.ext4 $parent_path/fs.img

mkdir -p $parent_path/temp
sudo mv "$path"/* "$parent_path/temp"/

sudo mount -o loop $parent_path/fs.img $path

sudo mv "$parent_path/temp"/* "$path"/

#Вычисляем процент заполненнности 
used=$(du -s $path | cut -f1)
all_space=$(df $path | awk 'NR==2 {print $2}')
per_of_usage=$(($used * 100 / $all_space))

#В случае выполнения условия запичываем в old N самых старых файлов и производим их архивацию в /backup с последующим удаление из входной папки
if [ $per_of_usage -gt 70 ]
then
echo "start arch"
if [ ! -d backup ]
then
mkdir backup
fi
old=$(ls -1t $path | tail -n $((N+1)) | head -n $N)
sudo tar -czf backup/old.tar.gz -C  $path $old
for file in $old
do
sudo rm $path/$file
done

fi
#Демонтируем файловую сисему
sudo mv "$path"/* "$parent_path/temp"/

sudo umount $parent_path/fs.img

sudo mv "$parent_path/temp"/* "$path"/
rmdir $parent_path/temp
rm $parent_path/fs.img

