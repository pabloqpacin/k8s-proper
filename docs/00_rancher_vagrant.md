https://ranchermanager.docs.rancher.com/getting-started/quick-start-guides/deploy-rancher-manager/vagrant


---

```bash
mkdir /tmp/rancher_vagrant && cd $_
git clone --depth 1 https://github.com/rancher/quickstart
cd quickstart/rancher/vagrant

sed -i 's/count: 1/count: 3/' config.yaml
vagrant up --provider=virtualbox

xdg-open https://192.168.56.101
    # admin/adminPassword

# 
# "Cluster agent is not connected"
# 

cd /tmp/rancher_vagrant/quickstart/rancher/vagrant
vagrant destroy -f
```
