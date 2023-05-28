#!/bin/bash
set -ex

####
# Use `$ cat /var/log/cloud-init-output.log` inside the instance to debug this script
# To debug further can use `$ sudo cat /var/log/cloud-init.log`
####

# SSH key
cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${ssh_public_key}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

# Install Nodejs
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

sudo systemctl stop firewalld
sudo firewall-offline-cmd --add-service=http
sudo systemctl restart firewalld

# Start server
cd ${home_dir}

cat << EOF > ./server.js;
const http = require("http");

const port = 80;

const server = http.createServer((req, res) => {
  console.log(req.headers);
  res.statusCode = 200;
  res.setHeader("Content-Type", "text/plain");
  res.end("Hello World");
});

server.listen(port, () => {
  console.log("Server running on port: " + port);
});
EOF

ls
nohup node server.js >> app.log 2>&1 &
