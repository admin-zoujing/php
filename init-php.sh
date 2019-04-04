#! /bin/bash
#centos7.4 php安装脚本
sourceinstall=/usr/local/src/php
chmod -R 777 $sourceinstall
#时间时区同步，修改主机名
ntpdate ntp1.aliyun.com
hwclock -w
echo "*/30 * * * * root ntpdate -s ntp1.aliyun.com" >> /etc/crontab
crontab /etc/crontab
sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/selinux/config
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/selinux/config
sed -i 's|SELINUX=.*|SELINUX=disabled|' /etc/sysconfig/selinux
sed -i 's|SELINUXTYPE=.*|#SELINUXTYPE=targeted|' /etc/sysconfig/selinux
setenforce 0 && systemctl stop firewalld && systemctl disable firewalld

rm -rf /var/run/yum.pid
rm -rf /var/run/yum.pid

yum -y install epel-release
yum -y install wget vim pcre pcre-devel openssl openssl-devel libicu-devel gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel ncurses ncurses-devel curl curl-devel krb5-devel libidn libidn-devel openldap openldap-devel nss_ldap jemalloc-devel cmake boost-devel bison automake libevent libevent-devel gd gd-devel libtool* libmcrypt libmcrypt-devel mcrypt mhash libxslt libxslt-devel readline readline-devel gmp gmp-devel libcurl libcurl-devel openjpeg-devel
#yum -y install yasm libmcrypt tiff libpng freetype jpeg libgd 

#1、配置php服务
#yasm源码包是一款常见的开源汇编器，解压、编译、安装过程：
cd $sourceinstall
mkdir -pv /usr/local/yasm
tar -zxvf yasm-1.3.0.tar.gz -C /usr/local/yasm
cd /usr/local/yasm/yasm-1.3.0/
./configure --prefix=/usr/local/yasm
make && make install
#libmcrypt源码包是用于加密算法的扩展库程序，解压、编译、安装过程：
cd $sourceinstall
mkdir -pv /usr/local/libmcrypt
tar zxvf libmcrypt-2.5.8.tar.gz -C /usr/local/libmcrypt
cd /usr/local/libmcrypt/libmcrypt-2.5.8
./configure --prefix=/usr/local/libmcrypt
make && make install

#tiff源码包是用于提供标签图像文件格式的服务程序，解压、编译、安装过程：
cd $sourceinstall
mkdir -p /usr/local/tiff
tar -zxvf tiff-4.0.3.tar.gz -C /usr/local/tiff
cd /usr/local/tiff/tiff-4.0.3
./configure --prefix=/usr/local/tiff --enable-shared
make && make install
#libpng源码包是用于提供png图片格式支持函数库的服务程序，解压、编译、安装过程：
cd $sourceinstall
mkdir -p /usr/local/libpng
tar -zxvf libpng-1.6.32.tar.gz -C /usr/local/libpng
cd /usr/local/libpng/libpng-1.6.32/
./configure --prefix=/usr/local/libpng --enable-shared
make && make install
#freetype源码包是用于提供字体支持引擎的服务程序，解压、编译、安装过程：
cd $sourceinstall
mkdir -p /usr/local/freetype
tar -zxvf freetype-2.8.tar.gz -C /usr/local/freetype
cd /usr/local/freetype/freetype-2.8/
./configure --prefix=/usr/local/freetype --enable-shared
make && make install
#jpeg源码包是用于提供jpeg图片格式支持函数库的服务程序，解压、编译、安装过程：
cd $sourceinstall
mkdir -p /usr/local/jpeg
tar -zxvf jpegsrc.v9b.tar.gz -C /usr/local/jpeg
cd /usr/local/jpeg/jpeg-9b/
./configure --prefix=/usr/local/jpeg --enable-shared
make && make install
#libgd源码包是用于提供图形处理的服务程序，解压、编译、安装过程，而在编译libgd源码包的时候请记得>写入的是jpeg、libpng、freetype、tiff、libvpx等服务程序在系统中的安装路径，即在上面安装过程中使--perfix参数指定的目录路径：
cd $sourceinstall
mkdir -p /usr/local/libgd
tar -zxvf libgd-2.2.5.tar.gz -C /usr/local/libgd
cd /usr/local/libgd/libgd-2.2.5/
./configure --prefix=/usr/local/libgd --enable-shared --with-jpeg=/usr/local/jpeg --with-png=/usr/local/libpng --with-freetype=/usr/local/freetype --with-fontconfig=/usr/local/freetype --with-xpm=/usr/ --with-tiff=/usr/local/tiff
make && make install

#此时终于把编译php服务源码包的相关软件包都已经安装部署妥当了，在开始编译源码包前先定义一个名称LD_LIBRARY_PATH的全局环境变量，该环境变量的作用是帮助系统找到指定的动态链接库文件，是编译php服源码包的必须元素之一。编译php服务源码包时除了定义要安装到的目录以外，还需要依次定义配置Php服务置文件保存目录、Mysql数据库服务程序所在目录、Mysql数据库服务程序配置文件所在目录以及libpng、jpeg、freetype、libvpx、zlib、t1lib等等服务程序的安装目录路径，并通过参数启动php服务程序的诸多默认能：
cd $sourceinstall
groupadd php
useradd php -s /sbin/nologin -g php
mkdir -p /usr/local/php
tar -zxvf php-7.2.14.tar.gz -C /usr/local/php
cd /usr/local/php/php-7.2.14
export LD_LIBRARY_PATH=/usr/local/libgd/lib
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-gd --with-png-dir=/usr/local/libpng --with-jpeg-dir=/usr/local/jpeg --with-freetype-dir=/usr/local/freetype --with-xpm-dir=/usr/  --with-zlib-dir=/usr/local/zlib  --with-iconv --enable-libxml --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-opcache --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --enable-ctype
#./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysqli=/usr/local/mysql/bin/mysql_config --with-mysql-sock=/usr/local/mysql/logs/mysql.sock --with-pdo-mysql=/usr/local/mysql --with-gd --with-png-dir=/usr/local/libpng --with-jpeg-dir=/usr/local/jpeg --with-freetype-dir=/usr/local/freetype --with-xpm-dir=/usr/  --with-zlib-dir=/usr/local/zlib  --with-iconv --enable-libxml --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-opcache --enable-mbregex --enable-fpm --enable-mbstring --enable-ftp --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --enable-ctype 
make -j2 && make install
#在等待php源码包程序安装完成后，需要删除掉当前默认的配置文件，然后从php服务程序目录中复制对应的>配置文件过来：
cp -rpf php.ini-production /usr/local/php/etc/php.ini
cp -rpf /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
#php-fpm.conf是php服务程序的重要配置文件之一，咱们需要将其配置内容中约25行左右的pid文件保存路径>启用，并在约148-149行的user与group参数分别修改为www帐户和用户组名称：
sed -i 's|;pid = run/php-fpm.pid|pid = run/php-fpm.pid|' /usr/local/php/etc/php-fpm.conf
sed -i 's|user = nobody|user = php|' /usr/local/php/etc/php-fpm.conf
sed -i 's|group = nobody|group = php|' /usr/local/php/etc/php-fpm.conf
#配置妥当后便可把服务管理脚本文件复制到/etc/rc.d/init.d中啦，为了能够有执行脚本请记得要给予755限，最后把php-fpm服务程序加入到开机启动项中：
cat >> /usr/lib/systemd/system/php-fpm.service <<EOF
[Unit] 
Description=php-fpm 
After=network.target

[Service] 
Type=simple
PIDFile=/run/php-fpm.pid
ExecStart=/usr/local/php/sbin/php-fpm --nodaemonize --fpm-config /usr/local/php/etc/php-fpm.conf
ExecStop=/bin/kill -SIGINT \$MAINPID
ExecReload=/bin/kill -USR2 \$MAINPID
PrivateTmp=true

[Install] 
WantedBy=multi-user.target
EOF
chmod 755 /usr/lib/systemd/system/php-fpm.service
systemctl daemon-reload && systemctl enable php-fpm.service && systemctl restart php-fpm.service
#由于php服务程序的配置参数直接会影响到Web网站服务的运行环境，如果默认开启了例如允许用户在网页中>执行Linux命令等等不必要且高危的功能，进而会降低了骇客入侵网站的难度，甚至加大了骇客提权到整台服>务器的管理权限的几率。因此需要编辑php.ini配置文件，在约305左右的disable_functions参数后面追加上>要禁止的功能名称吧，下面的禁用功能名单是依据运营网站经验而定制的，也许并不能适合每个生产环境，以在此基础上根据自身工作要求而酌情删减：
sed -i 's|disable_functions =|disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restor e,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,g etservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,po six_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix_getppid,posix_getpwnam,posix_ getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_ setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname|' /usr/local/php/etc/php.ini

#2、安装PHP redis扩展
cd $sourceinstall
mkdir -pv /usr/local/php/phpredis
tar -zxvf phpredis-4.2.0.tar.gz -C /usr/local/php/phpredis
cd /usr/local/php/phpredis/phpredis-4.2.0
/usr/local/php/bin/phpize
./configure --prefix=/usr/local/php/phpredis --enable-redis --with-php-config=/usr/local/php/bin/php-config
make
make test
make install
#编辑php.ini，整合php和xcache,将xcache提供的样例配置导入php.ini
echo 'extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/redis.so' >> /usr/local/php/etc/php.ini
chown -Rf php:php /usr/local/php/phpredis
systemctl daemon-reload && systemctl restart php-fpm.service


#后面写上负责运行nginx服务程序的帐户名称用户组名称，把约45行左右的index参数后面写上网站的首页名>称。最后是把约第65-71行参数前的#（井号）去除来启动参数，主要是修改约第69行的脚本名称路径参数，中$document_root变量即为网站资料存储的根目录路径，若没有设置的话nginx服务程序是找不到网站资料的>，因此会提示出404页面未找到的报错信息，确认参数信息填写正确后便可重启nginx服务与php-fpm服务，结>束了对LNMP动态网站环境架构的配置实验。
# sed -i 's|#user  nobody;|user nginx nginx;|' /usr/local/nginx/conf/nginx.conf
# sed -i 's|index  index.html index.htm;|index  index.html index.htm index.php;|' /usr/local/nginx/conf/nginx.conf
# sed -i '65,72 s|#| |g' /usr/local/nginx/conf/nginx.conf
# sed -i 's|root           html;|root           /usr/local/nginx/html;|' /usr/local/nginx/conf/nginx.conf
# sed -i 's|fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;|fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;|' /usr/local/nginx/conf/nginx.conf
# chown -Rf php:php /usr/local/php
# systemctl daemon-reload && systemctl restart nginx.service && systemctl restart php-fpm.service
#注释111行和112行    sed -i '111,112 s|^|#|g' /usr/local/nginx/conf/nginx.conf
#去掉注释111行和112行sed -i '111,112 s|#||g' /usr/local/nginx/conf/nginx.conf

# mkdir -pv /usr/local/nginx/html/php/ && touch /usr/local/nginx/html/php/index.php
# cat >> /usr/local/nginx/html/php/index.php <<EOF
# <?php
# phpinfo();
# ?>
# EOF
# chown -R nginx:nginx /usr/local/nginx/html/php/
# systemctl daemon-reload && systemctl restart php-fpm.service && systemctl restart nginx.service


#调优：nginx、php、Apache隐藏版本号
# sed -i '/sendfile            on;/a\    server_tokens      off;' /usr/local/nginx/conf/nginx.conf
# sed -i 's|expose_php = On|expose_php = Off|' /usr/local/php/etc/php.ini 
# systemctl daemon-reload && systemctl restart php-fpm.service && systemctl restart nginx.service

# sed -i '45c \ServerTokens Prod;' /etc/httpd/conf/httpd.conf 
# sed -i '46c \ServerSignature Off;' /etc/httpd/conf/httpd.conf 
# sed -i '44 s|^|#|g' /etc/httpd/conf/httpd.conf 

ps aux |grep mysql
sleep 5
ps aux |grep nginx
sleep 5
ps aux |grep php
sleep 5
