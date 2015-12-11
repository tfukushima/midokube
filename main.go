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
	"flag"
	"fmt"
	"os"

	"github.com/golang/glog"
	kubenetwork "github.com/kubernetes/kubernetes/pkg/kubelet/network"
	kubetypes "k8s.io/kubernetes/pkg/kubelet/types"
)

func runPlugin() int {
	flag.Parse()
	nargs := flag.NArg()
	if nargs < 4 {
		fmt.Fprintf(os.Stderr,
			"Usage: midokube <action> <pod_namespace> <pod_name> <docker_id_of_infra_container>\n")
		return -1
	}
	args := flag.Args()
	action := args[0]

	plugin := &NetworkPlugin{}

	switch action {
	case Init:
		host := kubenetwork.NewFakeHost(nil)
		plugin.Init(host)
	case Setup:
		plugin.SetupPod(args[1], args[2], kubetypes.DockerID(args[3]))
	case Teardown:
		plugin.TearDownPod(args[1], args[2], kubetypes.DockerID(args[3]))
	case Status:
		plugin.Status(args[1], args[2], kubetypes.DockerID(args[3]))
	default:
		glog.Fatalf("Invalid action. ")
		return -1
	}
	return 1
}

func main() {
	os.Exit(runPlugin())
}
