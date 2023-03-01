package main

import (
	"context"
	"flag"
	"fmt"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
)

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}

func run() error {
	kubeClient, err := setupClient(kubeconfigPath())
	if err != nil {
		return err
	}

	podList, err := kubeClient.CoreV1().Pods("openshift-authentication").List(context.Background(), metav1.ListOptions{})
	if err != nil {
		return err
	}

	for i, pod := range podList.Items {
		fmt.Printf("PodName No. %d: %s\n", i+1, pod.Name)
	}

	return nil
}

func kubeconfigPath() string {
	kubeconfig := flag.String("kubeconfig", "~/.kube/config", "kubeconfig file")
	flag.Parse()

	fmt.Printf(`
== Given Config =======
  - %s: %s
=======================
`, "kubeconfig", *kubeconfig)

	return *kubeconfig
}

func setupClient(kubeconfig string) (*kubernetes.Clientset, error) {
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		return nil, err
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, err
	}

	return clientset, nil
}
