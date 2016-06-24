# coding: utf-8
# Copyright 2016 Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

account_json = ::File.expand_path('/tmp/gcloud/service_account.json')

package 'git'

chef_gem 'googleauth' do
  compile_time true
  action :install
end

chef_gem 'google-api-client' do
  compile_time true
  action :install
end

chef_gem 'json' do
  compile_time true
  action :install
end

bash "Install gems into the chefdk" do
  user "root"
  cwd "/tmp"
  creates "/opt/chefdk/embedded/lib/ruby/gems/2.1.0/gems/google-api-client-0.8.6"
  code <<-EOH
  STATUS=0
  chef gem install googleauth || STATUS=1
  chef gem install google-api-client || STATUS=1
  exit $STATUS
  EOH
end

git node.default['appengine']['source_location'] do
  repository node.default['appengine']['repository']
  reference  node.default['appengine']['branch']
  user 'root'
  group 'root'
  action :sync
end

directory '/tmp/gcloud' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/tmp/gcloud/service_account.json' do
  source 'service_account.json'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

if node.default['appengine']['demo'] == true
  appengine 'formal-platform-134918' do
    service_id 'default'
    bucket_name 'chef-conf16-appengine'
    service_account_json account_json
    source '/tmp/hello_world'
  end
end
