#!/bin/bash
#By:Dr.v
#FTP配置
Fhost=
Fport=
Fuser=
Fpasswd=
Fbakfile=
#MYSQL配置
Muser=
Mpasswd=
Mdb=
#BAK路径
BakDir=/home/DBback
#压缩密码
Tpasswd=
#定义数据库的名字
DBbakName=${Mdb}_$(date +"%Y%m%d").tar.gz
DBbakSQL=${Mdb}_$(date +"%Y%m%d").sql
FrmFile=${Mdb}_$(date -d -2day +"%Y%m%d").tar.gz

#判断是否有安装FTP
if [ ! -f /usr/bin/ftp ]; then
    yum install ftp -y
fi
#判断是否创建数据库备份目录
if [ ! -d ${BakDir} ]; then
    mkdir ${BakDir}
fi

#删除当天备份避免冲突
rm -rf ${BakDir}/${DBbakName}

#删除本地2天前的数据
rm -rf ${BakDir}/${Mdb}_$(date -d -2day +"%Y%m%d").tar.gz

#导出数据库
/opt/mysql/bin/mysqldump -u${Muser} -p${Mpasswd} -E -R ${Mdb} > ${BakDir}/${DBbakSQL}

#压缩数据
cd ${BakDir}
tar -zcf - ${DBbakSQL} |openssl des3 -salt -k ${Tpasswd} | dd of=${DBbakName} && rm -rf ${DBbakSQL}

#上传到FTP空间
ftp -v -n ${Fhost} ${Fport} << End
user ${Fuser} ${Fpasswd}
type binary
cd ${Fbakfile}
delete ${FrmFile}
put ${DBbakName}
bye
End

