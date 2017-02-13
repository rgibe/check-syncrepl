**CHECK SYNCREPL**

Simple bash that checks and compares "LDAP contextCSN" to find out if they are in sync   

USAGE

* Replace "LDAP query parameters" in the config file (config.cgf)

Below an example

```
$> more config.cfg.default 
# LDAP query parameters
master_uri=ldap://IP_ADDRESS:PORT
slave_uri=ldap://xxx.xxx.xxx.xxx:PORT
binddn=cn=user,dc=univ,dc=it
password=xxxx
searchbase=dc=univ,dc=it
```

* Launch the script and you will see the following output

```
./check-syncrepl.sh 
0f8 delta: 0
0f9 delta: 0
```

Meaning:

* 0 - ldap in sync
* num - sec to wait before sync complete 

TO DO 

Change output format?

CREDITS

Thanks to Enrico Cavalli (https://github.com/enricocavalli) ... my LDAP Master :-)

LICENSE

GPL - http://www.gnu.org/licenses/gpl-3.0.html
