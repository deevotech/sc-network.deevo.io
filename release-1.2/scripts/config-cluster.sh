#!/bin/bash
set -e
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"admin", "node_count":"3"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "port": 5984, "node_count": "3", "remote_node": "13.229.71.175", "admin": "admin", "admin": "admin" }'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "add_node", "host":"54.255.205.146", "port": 5984, "username": "admin", "password":"admin"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "add_node", "host":"54.179.187.79", "port": 5984, "username": "admin", "password":"admin"}'
curl -X POST -H "Content-Type: application/json" http://admin:admin@127.0.0.1:5984/_cluster_setup -d '{"action": "finish_cluster"}'
curl http://admin:admin@127.0.0.1:5984/_cluster_setup
curl http://admin:admin@127.0.0.1:5984/_membership