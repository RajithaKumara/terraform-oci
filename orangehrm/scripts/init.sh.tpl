#!/bin/bash
set -ex

# SSH key
cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${ssh_public_key}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

# Install Nodejs
dnf -y module install nodejs:18/common

# firewall-cmd --add-service=http --permanent
# firewall-cmd --add-service=https --permanent
# firewall-cmd --reload

# Start server
cd ${home_dir}

cat << EOF > ./server.js;
const http = require("http");

const hostname = "127.0.0.1";
const port = 80;

const server = http.createServer((req, res) => {
  console.log(req.headers);
  res.statusCode = 200;
  res.setHeader("Content-Type", "text/plain");
  res.end("Hello World");
});

server.listen(port, hostname, () => {
  console.log("Server running at http://" + hostname + ":"  + port);
});
EOF

ls
nohup node server.js >> app.log 2>&1 &
