### For Filebeat
# Bootstrap filebeat.yml on all nodes by running this on one of the UCP (or swarm) manager nodes. _Do not run this using the UCP client bundle_
```
docker service create -d --mode global --restart-max-attempts 1 --mount type=bind,source=/var/tmp,destination=/filebeat anoop/filebeat-config
```
The command above will place the `filebeat.yml` file under `/var/tmp/filebeat/` on all nodes in the cluster.

### For Elasticsearch
The `vm.max_map_count` setting on each Linux host may need to be increased for elasticsearch to work. It can be set permanently in `/etc/sysctl.conf`:
```
$ grep vm.max_map_count /etc/sysctl.conf
vm.max_map_count=262144
```
To apply the setting on a live system type: 
```
sysctl -w vm.max_map_count=262144
```

### Bring up the FELK stack. _Better to run this too without the UCP client bundle_
```
docker stack deploy -c elk-docker-compose.yml elk
```

### To insert dummy entries into logstash for testing, follow these steps:

1. First find the containerid of the logstash container. In my case it is `74a`.
2. Exec into the container as shown below:
```
ᐅ docker exec -it 74a bash
```
3. Find the path for logstash and use that to invoke a new logstash process using `stdin` as the input and `elasticsearch` as the output.
```
root@74a68eea3f2f:/# logstash --path.data /tmp/logstash/data     -e 'input { stdin { } } output { elasticsearch { hosts => ["elasticsearch"] } }'
...
17:11:42.724 [main] INFO  logstash.modules.scaffold - Initializing module {:module_name=>"fb_apache", :directory=>"/usr/share/logstash/modules/fb_apache/configuration"}
17:11:43.673 [[main]-pipeline-manager] INFO  logstash.outputs.elasticsearch - New Elasticsearch output {:class=>"LogStash::Outputs::ElasticSearch", :hosts=>["//elasticsearch"]}
...
...
The stdin plugin is now waiting for input:
17:11:43.801 [Api Webserver] INFO  logstash.agent - Successfully started Logstash API endpoint {:port=>9601}

```
4. Now type some dummy entries as below (in stdin). Hit ^C when done:
```
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entrythis is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
this is a dummy entry
^C17:13:23.427 [SIGINT handler] WARN  logstash.runner - SIGINT received. Shutting down the agent.
17:13:23.434 [LogStash::Runner] WARN  logstash.agent - stopping pipeline {:id=>"main"}
root@74a68eea3f2f:/#
```
5. In kibana, search for "dummy entry" and you should see it in the search results.
