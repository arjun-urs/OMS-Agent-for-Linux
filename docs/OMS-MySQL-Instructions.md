# MySQL Log Monitoring Solution for Operations Management Suite

1. Setup a Linux(Ubuntu/Redhat) machine and install [MySQL](http://dev.mysql.com/doc/refman/5.7/en/installing.html).

2. Download and Install [OMS Agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux) on the machine. 

 
2. Configure MySQL to generate slow, error and general logs.

3. Verify and update the MySQL log file path in the configuration file ```/etc/opt/microsoft/omsagent/conf/omsagent.d/mysql_logs.conf```

  ```config
  # MySql General Log
  
  <source>
    ...
    path <MySQL-file-path-for-general-logs>
    ...
  </source>
  
  # MySql Error Log
  
  <source>
    ...
    path <MySQL-file-path-for-error-logs>
    ...
  </source>
  
  # MySql Slow Query Log
  
  <source>
    ...
    path <MySQL-file-path-for-slow-query-logs>
    ...
  </source>
  ```

4. Restart the MySQL daemon:
```sudo service mysql restart``` or ```/etc/init.d/mysqld restart```

5. Restart the OMS agent:
```sudo service omsagent restart```


6. Confirm that there are no errors in the OMS Agent log:  
```tail /var/opt/microsoft/omsagent/log/omsagent.log```
