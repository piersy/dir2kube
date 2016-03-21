# dir2kube

Aims to simplify getting a directory of config into kube via the secrets
mechanism.

dir2kube baseDir targetDir mountDir kubeConfigPath yamlFile/s


Given a root directory,a path relative to that root, a mount path,
pathToKubeConfig and a list of yaml files it will update the yaml files to
contain all the conthent of the directory mounted as secrets mirroring the
original directory layout. It will also create the relevant secrets in
kubernetes.

The name of the secret is defined by the path of the folder relative to the base
dir that is being represented with dots and slashes replaced by hyphens.

E.g

baseDir=/home/piers
targetDir=config/kube


Secret name will be config-kube

usage dir2kube 
