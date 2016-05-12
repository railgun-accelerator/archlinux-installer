#!/usr/bin/env bash
set -o errexit

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

#echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc || true

pacman -Syy archlinux-keyring --noconfirm --needed
packages="mosh fish tmux git pkgfile"
if grep '^\[multilib\]' /etc/pacman.conf; then
    devel="gcc-multilib lib32-fakeroot lib32-libltdl autoconf  automake  binutils  bison  fakeroot  file  findutils  flex  gawk  gettext  grep  groff  gzip  libtool  m4  make  pacman  patch  pkg-config  sed  sudo  texinfo  util-linux  which"
    yes | pacman -Syu ${packages} ${devel} --needed
else
    devel="base-devel"
    pacman -Syu ${packages} ${devel} --needed --noconfirm
fi

sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config

pkgfile --update
pkgfile makepkg

useradd -m -g users -G wheel -s /usr/bin/zsh railgun
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/railgun
chmod 400 /etc/sudoers.d/railgun

su - railgun -c sh <<USER
set -o errexit
cd ~
mkdir -p ~/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtRix6NrCSXMNpL9WuD6DA198aGirvb8cYIcx5fS98/EWqA8n8yjBEjfLkWZviSh8J6hDw5x4rlZWa777eP+qFfwZO5MjQp/n3cgpZgnbJFRUROuNEyaGQvv09uO05cgRKemVDysqte6xjH6YOts/+oX6dC/JK+Cwi7K0kUETQ2WLLTghyQfLkwKoXkP30v/j18yfyswyWsM1E70stmezMRYswsAeOP6j5/dZiSY9vPCPHJ0w3cGhV+YZcWVE3687cQyf++Iv4AGBzRWlGStGHfb3UB8fkeIClChkQDjjzrxfbrmeS3kC5w6hkbZFsreM8ZvWhDvB1eBxjU9KKbV0iQ== zh99998@ZH99998-PC' >> ~/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEAt9hNMurMJDvZAT5oMgNMCEYvpxSY3S/sV9JAZNbW8PFxUO6UcIfHX62b+GsSXya0bQ2/6fwYHk8lIkrpzROmr5MsRtTFKuAt3lqEyezwv8guun2BzzLCfIY4Cq+OwpnkV3HZ6IC0RmY7xX8stROnNkjCJOns42cQMuH74YaAoTHBp6bQ1V1QgvlvCxMCuUwkK98YkDMI/rHKYbl/FRUk5WTzhSC0MQh76MQwimheDjqKCAOi6DbijjABTeipDqWaI3NLCrZxQj4HC1mQdbrApjcmD0IIBtEQurEk9KXwTKaAuYUJe4mhkJk6fo0JIo8YhcdnYoC+6bk6ZXqKdqCY2PM2IW1h1V1XMalF7v6z8+4FbbgnFykY8fCuYJpz0Jo30xI21uaTPmP7uv+D4zg7nKYo1Nz7DMbHLAVTEJvr5ri5fDtP8WRuy09vVWNp2JbWhEijvwlklTnYubEZSKnrWmFDbePpIsI7UTHRGiPVeh7e7iIAsIF+iuTwA3BucGhyKlkiJslOJln9T7CjAw1LngRKW4Ut084AHbjY5EMnbe7Yfm6KUJQM3i20Vp81P6u2SKGUcSNax2G1pi6gF7/Ba6zoc4cAzqOuj7SZDQhb53prS3d9cLpnjwCELE98TzTs/6+jOt6I1p8wjEivrmOEND8TDEvgRiBthQG9HHbTfVc= QiaoHao@HERBERT' >> ~/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAtRix6NrCSXMNpL9WuD6DA198aGirvb8cYIcx5fS98/EWqA8n8yjBEjfLkWZviSh8J6hDw5x4rlZWa777eP+qFfwZO5MjQp/n3cgpZgnbJFRUROuNEyaGQvv09uO05cgRKemVDysqte6xjH6YOts/+oX6dC/JK+Cwi7K0kUETQ2WLLTghyQfLkwKoXkP30v/j18yfyswyWsM1E70stmezMRYswsAeOP6j5/dZiSY9vPCPHJ0w3cGhV+YZcWVE3687cQyf++Iv4AGBzRWlGStGHfb3UB8fkeIClChkQDjjzrxfbrmeS3kC5w6hkbZFsreM8ZvWhDvB1eBxjU9KKbV0iQ== zh99998@ZH99998-PC' > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa
chmod 700 ~/.ssh

git config --global user.email "zh99998@gmail.com"
git config --global user.name "zh99998"
git config --global push.default simple

curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf install robbyrussell

echo 'set-option -g default-terminal "screen-256color"
set-option -g default-shell /usr/bin/fish
set -g status-right "[#(cat /proc/loadavg | cut -d \" \" -f 1,2,3)] #h"
new-session' > /etc/tmux.conf

USER
