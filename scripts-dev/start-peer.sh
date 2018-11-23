#!/bin/bash
#
# Copyright Deevo Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
export FABRIC_CFG_PATH=/opt/gopath/src/github.com/hyperledger/fabric/sampleconfig/
$GOPATH/src/github.com/hyperledger/fabric/.build/bin/peer node start
