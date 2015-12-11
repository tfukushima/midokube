/*
Copyright 2015 Midokura SARL

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"github.com/golang/glog"
	kubenetwork "github.com/kubernetes/kubernetes/pkg/kubelet/network"
	kubetypes "k8s.io/kubernetes/pkg/kubelet/types"
)

const Init = "init"
const Setup = "setup"
const Teardown = "teardown"
const Status = "status"
const DefaultPluginName = "midokube"

// The network plugin for MidoNet
type NetworkPlugin struct {
	kubenetwork.NetworkPlugin
}

// Initilizes the plugin.
func (plugin *NetworkPlugin) Init(host kubenetwork.Host) error {
	glog.Infoln("Init is called")
	return nil
}

// Returns the plugin name.
func (plugin *NetworkPlugin) Name() string {
	return DefaultPluginName
}

// Set up MidoNet network and plumb a container in the pod.
func (plugin *NetworkPlugin) SetupPod(namespace string, name string, id kubetypes.DockerID) error {
	glog.Infof("SetUpPod is called with %s %s %s\n", namespace, name, id)
	return nil
}

// Cleanup the network set up by  SetUpPod.
func (plugin *NetworkPlugin) TearDownPod(namespace string, name string, id kubetypes.DockerID) error {
	glog.Infof("TearDownPod is called with %s %s %s\n", namespace, name, id)
	return nil
}

// Returns the IP address of the container
func (plugin *NetworkPlugin) Status(namespace string, name string, id kubetypes.DockerID) (*kubenetwork.PodNetworkStatus, error) {
	glog.Infof("Status is called with %s %s %s\n", namespace, name, id)
	return nil, nil
}
