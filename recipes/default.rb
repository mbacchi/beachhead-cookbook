#
# Cookbook Name:: beachhead-cookbook
# Recipe:: default
#

require 'mixlib/shellout'

### Create eucalyptus user
beachhead_user = node['beachhead']["user"]
beachhead_group = node['beachhead']["group"]
sandbox_dir = node['beachhead']['dependency_sandbox_dir']
archive_name = node['beachhead']['dependency_archive_name']
archive_path = File.join(sandbox_dir, archive_name)
yum_repo_hash = node['beachhead']['repos']

user beachhead_user do
  supports :manage_home => true
  comment "Eucalyptus BeachHead User"
  home "/home/#{beachhead_user}"
  shell "/bin/bash"
  only_if { "whoami" == "root" }
end

group beachhead_group do
  action :modify
  members beachhead_user
  append true
  only_if { "whoami" == "root" }
end

# Create the dir to download/create dependency artifacts
username = Mixlib::ShellOut.new("whoami")
username.run_command
name = username.stdout.strip
if "#{name}" == "root"
  directory sandbox_dir do
    owner beachhead_user
    group beachhead_group
    mode '0755'
    action :create
    only_if { "whoami" == "root" }
  end
else
  node.override['beachhead']["user"] = name
  node.override['beachhead']["group"] = name
  directory sandbox_dir do
    #cwd '.'
    owner "#{name}"
    group "#{name}"
    mode '0755'
    action :create
    not_if { ls -l "#{sandbox_dir}"}
  end
end
