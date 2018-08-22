#!/bin/bash
set -e
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"admin", "node_count":"4"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "port": 5984, "node_count": "4", "remote_node": "13.229.209.119", "admin": "admin", "admin": "admin" }'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "add_node", "host":"52.221.232.183", "port": 5984, "username": "admin", "password":"admin"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "add_node", "host":"13.251.45.138", "port": 5984, "username": "admin", "password":"admin"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "add_node", "host":"13.229.141.247", "port": 5984, "username": "admin", "password":"admin"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "finish_cluster"}'
curl http://admin:admin@127.0.0.1:5984/_cluster_setup
curl http://admin:admin@127.0.0.1:5984/_membership