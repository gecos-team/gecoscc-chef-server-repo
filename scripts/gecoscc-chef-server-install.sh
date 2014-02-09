#!/bin/bash
#
# Authors: Roberto C. Morano <rcmorano<at>emergya.com>
#
# Copyright 2013, Junta de Andalucia
# http://www.juntadeandalucia.es/
#
# All rights reserved - EUPL License V 1.1
# http://www.osor.eu/eupl

export GEM_DEPENDS="chef berkshelf"
export CHEF_REPO_NAME='gecoscc-chef-server-repo'
export CHEF_REPO_URL="https://github.com/gecos-team/${CHEF_REPO_NAME}.git"
grep "$HOSTNAME" /etc/hosts || sed -i "s|\(127.0.0.1.*\)|\1 $HOSTNAME|g" /etc/hosts

# install rvm
curl -L https://get.rvm.io | bash -s stable --ruby
. /etc/profile.d/rvm.sh 
rvm use --default $(rvm current)
gem install $GEM_DEPENDS --no-ri --no-rdoc

# install git
PLATFORM=$(ohai |grep platform_family|awk -F: '{print $2}'|sed 's|[", ]||g')

case $PLATFORM in
  "rhel")
    yum install -y git
    ;;
  "debian")
    apt-get install -y git
    ;;
  *)
    echo "Platform not supported! Only 'rhel' and 'debian' are."
    echo "yes" | rvm implode
    exit 0
    ;;
esac


# create chef-solo config
cat > /tmp/solo.rb << EOF
root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root
cookbook_path root + '/${CHEF_REPO_NAME}/cookbooks'
EOF

# create node's json
cat > /tmp/solo.json << EOF
{
    "run_list": [ "recipe[gecoscc-chef-server]" ]
}
EOF

# cleanup tmp dirs just in case there were any from older intallation tries
LOCAL_CHEF_REPO="/tmp/${CHEF_REPO_NAME}"
test -d $LOCAL_CHEF_REPO && rm -rf $LOCAL_CHEF_REPO

# download chef-repo
git clone $CHEF_REPO_URL $LOCAL_CHEF_REPO
cd $LOCAL_CHEF_REPO
git submodule init
git submodule update
for cookbook in cookbooks/*
do
  cd $cookbook
  test -f Berksfile && berks install
  cd -
done
cd

# link berks installed cookbooks to cookbook path removing version
for cookbook in /root/.berkshelf/cookbooks/*
do
  ln -s $cookbook $LOCAL_CHEF_REPO/cookbooks/$(echo $cookbook | sed 's|\(.*\)\(-.*\)|\1|g'|xargs basename)
done

# install software via cookbooks
chef-solo -c /tmp/solo.rb -j /tmp/solo.json 

# remove temporal rvm installation
echo "yes" | rvm implode

# finish chef-server installation
chef-server-ctl reconfigure
chef-server-ctl test
