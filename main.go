package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"reflect"

	"gopkg.in/yaml.v2"
)

type volume struct {
	Name   string
	Secret struct {
		SecretName string
	}
}

func main() {
	filename := os.Args[1]
	source, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	var m map[string]interface{}
	err = yaml.Unmarshal(source, &m)
	if err != nil {
		panic(err)
	}
	volumes := m["spec"].(map[interface{}]interface{})["template"].(map[interface{}]interface{})["spec"].(map[interface{}]interface{})["volumes"]
	volumesSlice := volumes.([]interface{})
	fmt.Printf("Type: %v\n", reflect.TypeOf(volumes))
	fmt.Printf("Value: %#v\n", m["spec"].(map[interface{}]interface{})["template"].(map[interface{}]interface{})["spec"].(map[interface{}]interface{})["volumes"])
	volume := make(map[string]interface{})
	secret := make(map[string]interface{})
	volume["name"] = "my-secret"
	secret["secretName"] = "my-secret"
	volume["secret"] = secret
	volumesSlice = append(volumesSlice, volume)
	fmt.Printf("Value: %#v\n", volumesSlice)
}
