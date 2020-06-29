~/.bash_profile

export PATH="$PATH:/usr/local/bin"
or
export PATH="$PATH:/bin"
or
export PATH="$PATH:/usr/bin"
====================================

# Creating Python Virtual Environment in Linux 

cd /home/centos     #you can create envirment varibale at any path
python3 -m venv env_varibale_name
cd /home/centos
source env_varibale_name/bin/activate

====================================
# Creating Python Virtual Environment in Linux

pip install virtualenv

virtualenv virtualenv_name

virtualenv -p /usr/bin/python3 virtualenv_name
or
virtualenv -p /usr/bin/python2.7 virtualenv_name


source virtualenv_name/bin/activate
