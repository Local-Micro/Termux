#!/data/data/com.termux/files/usr/bin/bash
msfpath='/data/data/com.termux/files/usr/share/metasploit-framework/'
rubypath='/data/data/com.termux/files/usr/share/metasploit-framework/ruby/bin/'
msfversion='6.0.30'
echo '[*]开始下载metasploit-framework依赖包'
apt install -y libiconv zlib autoconf bison clang coreutils curl findutils git apr apr-util libffi libgmp libpcap postgresql readline libsqlite openssl libtool libxml2 libxslt ncurses pkg-config wget make ruby2 libgrpc termux-tools ncurses-utils ncurses unzip zip tar termux-elf-cleaner
echo '[*]开始删除旧版metasploit-framework'
rm -rf /data/data/com.termux/files/home/metasploit-framework /data/data/com.termux/files/usr/share/metasploit-framework
echo '[*]开始下载metasploit-framework归档包'
wget https://github.com/rapid7/metasploit-framework/archive/${msfversion}.tar.gz
echo '[*]开始解压metasploit-framework归档包'
tar -xf ${msfversion}.tar.gz -C ${msfpath}
echo '[*]开始下载2.7.1版本的ruby源码包'
wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.1.tar.gz
echo '[*]开始解压2.7.1版本的ruby'
tar -xf ruby-2.7.1.tar.gz
echo '[*]开始配置2.7.1版本的ruby'
cd ruby-2.7.1
./config --prefix=/data/data/com.termux/files/usr/share/metasploit-framework/ruby/
echo '[*]开始编译2.7.1版本的ruby'
make
echo '[*]开始安装2.7.1版本的ruby'
mkdir -p /data/data/com.termux/files/usr/share/metasploit-framework/ruby/
make install
echo '[*]开始安装metasploit-framework'
${rubypath}gem install --no-document --verbose bundler:1.17.3
${rubypath}bundle config build.nokogiri --use-system-libraries
${rubypath}bundle install -j5
echo '[*]开始修改metasploit-framework的软件'
sed -i '1c#!/data/data/com.termux/files/usr/bin/env /data/data/com.termux/files/usr/share/metasploit-framework/ruby/bin/ruby' ${msfpath}msfconsole ${msfpath}msfd ${msfpath}msfdb ${msfpath}msfrpc ${msfpath}msfrpcd ${msfpath}msfupdate ${msfpath}msfvenom
echo '[*]开始配置数据库'
mkdir -p ${msfpath}config
wget https://raw.githubusercontent.com/Hax4us/Metasploit_termux/master/database.yml -P ${msfpath}config/
mkdir -p $PREFIX/var/lib/postgresql
pg_ctl -D "$PREFIX"/var/lib/postgresql stop > /dev/null 2>&1 || true 
if ! pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent; then     initdb "$PREFIX"/var/lib/postgresql     pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent
fi
if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then     createuser msf
fi
if [ -z "$(psql -l | grep msf_database)" ]; then     createdb msf_database
fi
echo '[*]开始将metasploit-framework加入PATH路径'
echo "export PATH=$PATH:${msfpath}" >> $HOME/.bashrc
