for i in `docker inspect --format='{{.Id}}' $(docker ps -q) | cut -c1-12`
        do container_port=`docker inspect --format='{{.NetworkSettings.Ports}}' $i | cut -c5-6`
		container_name=`docker inspect --format='{{.Name}}' $i | cut -f2 -d\/`
        container_image=`docker inspect --format='{{.Config.Image}}' $i`
		echo "$container_image"
		save_file="/var/backups/$container_name/$container_name-image.tar"
		mkdir /var/backups/$container_name
		if [[ "$container_port" == 33 ]]; then
			db_name=`docker exec $i env | grep MYSQL_DATABASE | cut -c16-`
			db_pass=`docker exec $i env | grep MYSQL_ROOT_PASSWORD | cut -c21-`
			docker exec $container_name /usr/bin/mysqldump -u root --password=$db_pass $db_name > /var/backups/$container_name/$container_name.sql
			docker save -o $save_file $container_image
		else
			docker save -o $save_file $container_image
		fi		
done
tar -czpf /var/backups/cntrbackups.tar.gz * /var/backups
lftp   -e "put /var/backups/cntrbackups.tar.gz; bye"
rm -rf /var/backups/*