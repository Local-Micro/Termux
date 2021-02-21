#!/data/data/com.termux/files/usr/bin/bash
msfpath='/data/data/com.termux/files/usr/share/metasploit-framework'
rubypath='/data/data/com.termux/files/usr/share/ruby'
msfversion='6.0.30'
rubyversion='2.7.1'
echo '[*]开始下载metasploit-framework-${msfversion}依赖包'
apt install -y libiconv zlib autoconf bison clang coreutils curl findutils git apr apr-util libffi libgmp libpcap postgresql readline libsqlite openssl libtool libxml2 libxslt ncurses pkg-config wget make libgrpc termux-tools ncurses-utils ncurses unzip zip tar termux-elf-cleaner
echo '[*]开始删除旧版metasploit-framework'
rm -rf /data/data/com.termux/files/home/metasploit-framework /data/data/com.termux/files/usr/share/metasploit-framework
echo '[*]开始下载metasploit-framework归档包'
wget https://github.com/rapid7/metasploit-framework/archive/${msfversion}.tar.gz -P ${TMPDIR}/
echo '[*]开始解压metasploit-framework归档包'
tar -xf ${TMPDIR}/${msfversion}.tar.gz -C ${TMPDIR}
mkdir -p ${msfpath}
cp -r ${TMPDIR}/metasploit-framework-${msfversion}/* ${msfpath}/
echo '[*]开始下载ruby-${rubyversion}源码包'
wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.1.tar.gz -P ${TMPDIR}/
echo '[*]开始解压ruby-${rubyversion}源码包'
tar -xf ${TMPDIR}/ruby-${rubyversion}.tar.gz -C ${TMPDIR}/
echo '[*]开始配置ruby-${rubyversion}'
cd ${TMPDIR}/ruby-${rubyversion}
./config --prefix=/data/data/com.termux/files/usr/share/ruby/${rubyversion}/
echo '[*]开始编译2.7.1版本的ruby'
make
echo '[*]开始安装2.7.1版本的ruby'
mkdir -p /data/data/com.termux/files/usr/share/ruby/${rubyversion}
make install
make clean
echo '[*]开始安装metasploit-framework'
cd ${msfpath}
${rubypath}/${rubyversion}/bin/gem install --no-document --verbose bundler:1.17.3
${rubypath}/${rubyversion}/bin/bundle config build.nokogiri --use-system-libraries
${rubypath}/${rubyversion}/bin/bundle install -j5
echo '[*]开始修改metasploit-framework的软件'
sed -i '1c#!/data/data/com.termux/files/usr/bin/env /data/data/com.termux/files/usr/share/ruby/${rubyversion}/bin/ruby' ${msfpath}/msfconsole ${msfpath}/msfd ${msfpath}/msfdb ${msfpath}/msfrpc ${msfpath}/msfrpcd ${msfpath}/msfupdate ${msfpath}/msfvenom
echo '[*]执行一些修复'
sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" ${msfpath}/lib/net/dns/resolver.rb
find ${msfpath} -type f -executable -print0 | xargs -0 -r termux-fix-shebang
find ${rubypath}/${rubyversion}/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner
echo '[*]开始配置数据库'
mkdir -p ${msfpath}/config/
wget https://raw.githubusercontent.com/Local-Micro/Termux/main/metasploit-framework/database.yml -P ${msfpath}/config/
mkdir -p $PREFIX/var/lib/postgresql
pg_ctl -D $PREFIX/var/lib/postgresql stop > /dev/null 2>&1 || true 
if ! pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent; then     initdb "$PREFIX"/var/lib/postgresql     pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent
fi
if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then     createuser msf
fi
if [ -z "$(psql -l | grep msf_database)" ]; then     createdb msf_database
fi
echo '[*]开始将metasploit-framework加入PATH路径'
echo "export PATH=$PATH:${msfpath}" >> $HOME/.bashrc
echo '[*]处理安装文件'
rm -rf ${TMPDIR}/${msfversion}.tar.gz ${TMPDIR}/ruby-${rubyversion}.tar.gz ${TMPDIR}ruby-${rubyversion}/
