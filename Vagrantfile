Vagrant.configure("2") do |config|
  boxes = ["centos/7"]
  boxes.each_index do |machine_id|
    config.vm.define "machine#{machine_id}" do |machine|
      machine.vm.provision "file", source: "~/Github/dotfiles", destination: "~/.dotfiles"
      machine.vm.box = boxes[machine_id]
      machine.vm.hostname = "machine#{machine_id}"

      if machine_id == boxes.length - 1
        machine.vm.provision "shell", inline: "yum install -y https://repo.ius.io/ius-release-el7.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
        machine.vm.provision "shell", inline: "sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
        machine.vm.provision "shell", inline: "/bin/sh -c 'echo -e \"[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" > /etc/yum.repos.d/vscode.repo'"
        machine.vm.provision "shell", inline: "yum install -y git zsh vim tmux2 code"
      end
      machine.vm.provision "shell", inline: "/bin/sh $HOME/.dotfiles/install-profile", args: "linux", privileged: false
    end
  end
end
