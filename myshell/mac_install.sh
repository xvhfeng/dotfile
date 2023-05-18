brew install expect
brew install lua python ruby
brew install nnn ranger
brew install cmake
brew install autojump
brew install ripgrep
brew install wget
brew install node
sudo npm install -g gitbook-cli

#brew 安装的软件,都在/usr/local/opt中存在软连接

mkdir -p ~/pkgs/vim
git clone --depth=1 https://github.com/vim/vim.git

cd vim
./configure --enable-multibyte --enable-perlinterp=dynamic --enable-rubyinterp=dynamic --with-ruby-command=/usr/local/opt/ruby/bin/ruby --enable-pythoninterp=dynamic --with-python-config-dir=/usr/lib/python2.7/config --enable-python3interp --with-python3-config-dir=/usr/local/opt/python/libexec/bin --enable-luainterp --with-lua-prefix=/usr/local/opt/lua --enable-cscope --enable-gui=auto --with-features=huge --enable-fontset --enable-largefile --disable-netbeans --enable-fail-if-missing --prefix=/usr/local/vim8
make -j4
sudo make install

cd ~/pkgs/
git clone https://github.com/xvhfeng/myvim.git
cd myvim
git fetch origin mac
git checkout -b mac origin/mac
mkdir bundle
cd bundle
git clone https://github.com/xvhfeng/vim-plug.git
ln -s ~/pkgs/myvim/ ~/.vim
ln -s ~/pkgs/myvim/main.vimrc ~/.vimrc
ls -las ~/ | grep vim
vim +PlugInstall +qall
cd ~/.vim/bundle/vimproc
make

cd ~/pkgs/
git clone https://github.com/xvhfeng/sexpect.git
cd sexpect
mkdir build
cd build
cmake ..
make 
make install

cd ~/pkgs/
git clone https://gitee.com/spkx/myshell.git
git clone https://gitee.com/spkx/mymac.git
ln -s ~/pkgs/mymac/aliasrc ~/.aliasrc
ln -s ~/pkgs/mymac/bash_profile ~/.profile
ln -s ~/pkgs/mymac/bashrc ~/.bashrc
ln -s ~/pkgs/mymac/dircolors ~/.dircolors
ln -s ~/pkgs/mymac/git-completion.bash ~/.git-completion.bash
ln -s ~/pkgs/mymac/inputrc ~/.inputrc
ln -s ~/pkgs/mymac/path.bash ~/.path.bash

echo 'export MYSHELL_HOME=/Users/xuhaifeng/pkgs/myshell' >> ~/pkgs/mymac/path.bash
echo 'export PATH="$MYSHELL_HOME/:$PATH"' >> ~/pkgs/mymac/path.bash

echo 'export GO_HOME=/Users/xuhaifeng/works/bin/go' >> ~/pkgs/mymac/path.bash
echo 'export PATH="$GO_HOME/bin/:$PATH"' >> ~/pkgs/mymac/path.bash

echo 'export MVN_HOME=/Users/xuhaifeng/works/bin/maven' >> ~/pkgs/mymac/path.bash
echo 'export PATH="$MVN_HOME/bin/:$PATH"' >> ~/pkgs/mymac/path.bash

echo 'export PROTOC_HOME=/Users/xuhaifeng/works/bin/protoc3' >> ~/pkgs/mymac/path.bash
echo 'export PATH="$PROTOC_HOME/bin/:$PATH"' >> ~/pkgs/mymac/path.bash

source ~/.profile

# 设置无法打开go编译器
sudo spctl --master-disable

# 显示隐藏文件：
defaults write com.apple.Finder AppleShowAllFiles YES;KillAll Finder

# 关闭修改后缀更改
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

