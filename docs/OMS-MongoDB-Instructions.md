# MongoDB Log Monitoring Solution for Operations Management Suite

1. Setup a Linux(Ubuntu/Redhat) machine and install [MongoDB](https://docs.mongodb.com/manual/installation/).

2. Download and Install [OMS Agent for Linux](https://github.com/Microsoft/OMS-Agent-for-Linux) on the machine. 

3. Configure MongoDB to generate logs.

4. Verify and update the MongoDB log file path in the configuration file ```/etc/opt/microsoft/omsagent/conf/omsagent.d/mongo_logs.conf```

  ```config
  <source>
  ...
  path <MongoDB-log-path>
  ...
  </source>
  ```

5. Restart the MongoDB daemon:
```sudo service mongod restart```

6. Restart the OMS agent:
```sudo service omsagent restart```


7. Confirm that there are no errors in the OMS Agent log:  
```tail /var/opt/microsoft/omsagent/log/omsagent.log```
